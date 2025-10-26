// src/app/api/webhooks/stripe/route.ts
import { NextRequest, NextResponse } from 'next/server'
import { stripe } from '@repo/database'
import { supabaseAdmin } from '@repo/database/client-admin'
import { sendOrderConfirmationHook } from '@repo/email/send-order-confirmation-hook'
import { decrementStockForOrder } from '@repo/database'

function parseAddress(address: any): any {
  if (!address) return null
  if (typeof address === 'string') {
    try {
      return JSON.parse(address)
    } catch {
      return null
    }
  }
  return address
}

const emailSentForOrders = new Set<string>()

async function sendConfirmationEmailSafe(orderId: string) {
  const uniqueId = `${Date.now()}-${Math.random()}`
  console.log(`?? EMAIL ATTEMPT ${uniqueId} FOR ORDER ${orderId}`)

  // ? V�RIFICATION ANTI-DOUBLON
  if (emailSentForOrders.has(orderId)) {
    console.log(
      `?? Email D�J� envoy� pour ${orderId}, SKIP (attempt ${uniqueId})`
    )
    return
  }

  try {
    const result = await sendOrderConfirmationHook(orderId)
    if (result.success) {
      console.log(`? Email sent ${uniqueId}`)

      // ? MARQUER COMME ENVOY�
      emailSentForOrders.add(orderId)

      // ? AUTO-CLEANUP apr�s 5 minutes (�viter memory leak)
      setTimeout(
        () => {
          emailSentForOrders.delete(orderId)
          console.log(`?? Cleaned up ${orderId} from email cache`)
        },
        5 * 60 * 1000
      )
    } else {
      console.error(`?? Email error ${uniqueId}:`, result.error)
    }
  } catch (error) {
    console.error(`?? Email exception ${uniqueId}:`, error)
  }
}

export const runtime = 'nodejs'

export async function POST(req: NextRequest) {
  const body = await req.text()
  const signature = req.headers.get('stripe-signature')

  if (!signature) {
    return NextResponse.json({ error: 'Missing signature' }, { status: 400 })
  }

  let event: any
  try {
    event = stripe.webhooks.constructEvent(
      body,
      signature,
      process.env.STRIPE_WEBHOOK_SECRET!
    )
  } catch (err: any) {
    console.error('? Webhook error:', err.message)
    return NextResponse.json({ error: err.message }, { status: 400 })
  }

  console.log(`\n?? Webhook: ${event.type}`)

  switch (event.type) {
    case 'checkout.session.completed':
      await handleCheckoutSessionCompleted(event.data.object)
      break
    case 'payment_intent.succeeded':
      await handlePaymentIntentSucceeded(event.data.object)
      break
    case 'payment_intent.payment_failed':
      await handlePaymentIntentFailed(event.data.object)
      break
    default:
      console.log(`?? Unhandled: ${event.type}`)
  }

  return NextResponse.json({ received: true })
}

// ???????????????????????????????????????????????????????
// CHECKOUT.SESSION.COMPLETED (APPROCHE HYBRIDE INTELLIGENTE)
// R�le : Cr�er items + confirmer paiement SI payment_intent existe
// ???????????????????????????????????????????????????????
async function handleCheckoutSessionCompleted(session: any) {
  console.log('\n-----------------------------------------------------------')
  console.log('?? CHECKOUT SESSION COMPLETED')
  console.log('-----------------------------------------------------------')
  console.log('Session ID:', session.id)

  try {
    console.log('\n?? Step 1: Fetching full session...')
    const fullSession = await stripe.checkout.sessions.retrieve(session.id, {
      expand: ['line_items', 'customer_details', 'payment_intent'],
    })

    const paymentIntentId =
      typeof fullSession.payment_intent === 'string'
        ? fullSession.payment_intent
        : fullSession.payment_intent?.id || null

    // ? APPROCHE HYBRIDE : V�rifier si payment_intent existe
    if (!paymentIntentId) {
      console.log('   ? No payment intent yet')
      console.log('   ??  Will wait for payment_intent.succeeded to process')
      return
    }

    console.log('   ? Payment Intent found:', paymentIntentId)
    console.log('   ? This means payment is being processed by Stripe')

    console.log('\n?? Step 2: Finding order...')
    const { data: orderRaw, error: orderError } = await supabaseAdmin
      .from('orders')
      .select(
        'id, order_number, shipping_address, billing_address, payment_status'
      )
      .eq('stripe_session_id', session.id)
      .single()

    if (orderError || !orderRaw) {
      console.error('   ? Order not found:', orderError)
      return
    }

    console.log('   ? Order found:', orderRaw.order_number)
    console.log('   ??  Current payment status:', orderRaw.payment_status)

    console.log('\n?? Step 3: Checking for existing items...')
    const { data: existingItems } = await supabaseAdmin
      .from('order_items')
      .select('id')
      .eq('order_id', orderRaw.id)
      .limit(1)

    if (existingItems && existingItems.length > 0) {
      console.log('   ?? Items already exist')

      // ? FIX : Si items existent ET payment_status est 'paid'
      // Alors on doit envoyer l'email + d�cr�menter stock
      if (orderRaw.payment_status === 'paid') {
        console.log(
          '   ? Order already paid, sending email + decrementing stock'
        )

        await decrementStockForOrder(orderRaw.id)
        await sendConfirmationEmailSafe(orderRaw.id)

        console.log(
          '-----------------------------------------------------------'
        )
        console.log('? SESSION COMPLETED (email sent)')
        console.log(
          '-----------------------------------------------------------\n'
        )
      } else {
        console.log(
          '   ??  payment_intent.succeeded will handle final confirmation'
        )
      }
      return
    }

    console.log('   ? No items found, creating them now...')

    // ? APPROCHE HYBRIDE : Tout faire ICI si payment_intent existe
    await createOrderItemsAndConfirm(orderRaw.id, fullSession, paymentIntentId)

    console.log('-----------------------------------------------------------')
    console.log('? SESSION COMPLETED (full processing done)')
    console.log('-----------------------------------------------------------\n')
  } catch (error) {
    console.error('? Error:', error)
  }
}

// ???????????????????????????????????????????????????????
// PAYMENT_INTENT.SUCCEEDED (BACKUP + S�CURIT�)
// R�le : Confirmer le paiement si checkout.session.completed l'a rat�
// ???????????????????????????????????????????????????????
async function handlePaymentIntentSucceeded(paymentIntent: any) {
  console.log('\n-----------------------------------------------------------')
  console.log('?? PAYMENT INTENT SUCCEEDED')
  console.log('-----------------------------------------------------------')
  console.log('Payment Intent ID:', paymentIntent.id)

  try {
    console.log('\n?? Step 1: Finding associated session...')
    const sessions = await stripe.checkout.sessions.list({
      payment_intent: paymentIntent.id,
      limit: 1,
    })

    if (sessions.data.length === 0) {
      console.log('   ?? No session found, updating directly')
      await supabaseAdmin
        .from('orders')
        .update({
          payment_status: 'paid',
          status: 'processing',
          paid_at: new Date().toISOString(),
        })
        .eq('payment_intent_id', paymentIntent.id)
      return
    }

    const sessionId = sessions.data[0].id
    console.log('   ? Session found:', sessionId)

    console.log('\n?? Step 2: Finding order...')
    const { data: order, error: orderError } = await supabaseAdmin
      .from('orders')
      .select('id, order_number, payment_status')
      .eq('stripe_session_id', sessionId)
      .single()

    if (orderError || !order) {
      console.error('   ? Order not found:', orderError)
      return
    }

    console.log('   ? Order found:', order.order_number)
    console.log('   ??  Current payment status:', order.payment_status)

    // ? Si d�j� trait� par checkout.session.completed
    if (order.payment_status === 'paid') {
      console.log('   ? Order already marked as paid')
      console.log('   ??  checkout.session.completed handled everything')
      console.log('-----------------------------------------------------------')
      console.log('? PAYMENT SUCCEEDED (already processed)')
      console.log(
        '-----------------------------------------------------------\n'
      )
      return
    }

    // ?? Sinon, traiter maintenant (backup scenario)
    console.log('   ??  Order still pending, processing now as backup')

    console.log('\n?? Step 3: Checking for existing items...')
    const { data: existingItems } = await supabaseAdmin
      .from('order_items')
      .select('id')
      .eq('order_id', order.id)
      .limit(1)

    if (existingItems && existingItems.length > 0) {
      console.log('   ? Items exist, just updating payment status')

      await supabaseAdmin
        .from('orders')
        .update({
          payment_status: 'paid',
          status: 'processing',
          paid_at: new Date().toISOString(),
          payment_intent_id: paymentIntent.id,
        })
        .eq('id', order.id)

      await decrementStockForOrder(order.id)
      await sendConfirmationEmailSafe(order.id)
    } else {
      console.log('   ??  No items exist, creating everything now')

      const fullSession = await stripe.checkout.sessions.retrieve(sessionId, {
        expand: ['line_items', 'customer_details'],
      })

      await createOrderItemsAndConfirm(order.id, fullSession, paymentIntent.id)
    }

    console.log('-----------------------------------------------------------')
    console.log('? PAYMENT SUCCEEDED (backup processing done)')
    console.log('-----------------------------------------------------------\n')
  } catch (error) {
    console.error('? Error:', error)
  }
}

// ???????????????????????????????????????????????????????
// HELPER: Cr�er items + confirmer paiement + stock + email
// ???????????????????????????????????????????????????????
async function createOrderItemsAndConfirm(
  orderId: string,
  fullSession: any,
  paymentIntentId: any
) {
  try {
    const paymentIntentIdString =
      typeof paymentIntentId === 'string'
        ? paymentIntentId
        : paymentIntentId?.id || null

    if (!paymentIntentIdString) {
      console.error('? No valid payment intent ID')
      return
    }

    // ??????????????????????????????????????????
    // STEP A: Mettre � jour le statut de paiement
    // ??????????????????????????????????????????
    console.log('\n?? Step A: Updating payment status...')

    const { error: updateError } = await supabaseAdmin
      .from('orders')
      .update({
        payment_status: 'paid',
        status: 'processing',
        paid_at: new Date().toISOString(),
        payment_intent_id: paymentIntentIdString,
      })
      .eq('id', orderId)

    if (updateError) {
      console.error('   ? Update error:', updateError)
      return
    }

    console.log('   ? Payment status updated to PAID')

    // ??????????????????????????????????????????
    // STEP B: Cr�er les order_items
    // ??????????????????????????????????????????
    console.log('\n?? Step B: Creating order items...')

    const itemsString = fullSession.metadata?.items || '[]'
    let items
    try {
      items = JSON.parse(itemsString)
    } catch (e) {
      console.error('   ? Error parsing items:', e)
      return
    }

    if (!items || items.length === 0) {
      console.error('   ? No items in metadata')
      return
    }

    console.log(`   ? Found ${items.length} items`)

    const orderItems = items.map((item: any) => ({
      order_id: orderId,
      product_id: item.product_id,
      variant_id: item.variant_id || null,
      product_name: item.name || null,
      variant_name:
        item.size || item.color
          ? `${item.size || ''} ${item.color || ''}`.trim()
          : null,
      image_url: item.image || null,
      quantity: item.quantity,
      unit_price: item.price,
      total_price: item.price * item.quantity,
    }))

    const { data: insertedItems, error: itemsError } = await supabaseAdmin
      .from('order_items')
      .insert(orderItems)
      .select()

    if (itemsError) {
      if (itemsError.code === '23505') {
        console.log('   ?? Items already exist (race condition)')
        return
      }
      console.error('   ? Insert error:', itemsError)
      return
    }

    console.log(`   ? Created ${insertedItems.length} items`)

    // ??????????????????????????????????????????
    // STEP C: D�cr�menter le stock
    // ??????????????????????????????????????????
    console.log('\n?? Step C: Decrementing stock...')

    const stockResult = await decrementStockForOrder(orderId)
    if (stockResult.success) {
      console.log(`   ? Stock decremented: ${stockResult.decremented} items`)
    } else {
      console.error('   ?? Stock errors:', stockResult.errors)
    }

    // ??????????????????????????????????????????
    // STEP D: Envoyer l'email de confirmation
    // ??????????????????????????????????????????
    console.log('\n?? Step D: Sending confirmation email...')

    await sendConfirmationEmailSafe(orderId)

    console.log('\n? Full order processing completed')
  } catch (error) {
    console.error('? Error in createOrderItemsAndConfirm:', error)
  }
}

// ???????????????????????????????????????????????????????
// PAYMENT_INTENT.FAILED
// ???????????????????????????????????????????????????????
async function handlePaymentIntentFailed(paymentIntent: any) {
  console.log('\n? Payment failed:', paymentIntent.id)

  await supabaseAdmin
    .from('orders')
    .update({
      payment_status: 'failed',
      status: 'cancelled',
      cancelled_at: new Date().toISOString(),
    })
    .eq('payment_intent_id', paymentIntent.id)

  console.log('   ? Order marked as failed/cancelled')
}
