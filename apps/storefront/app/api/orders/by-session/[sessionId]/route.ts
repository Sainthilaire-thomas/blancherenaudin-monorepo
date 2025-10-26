// apps/storefront/app/api/orders/by-session/[sessionId]/route.ts
import { NextRequest, NextResponse } from 'next/server'
import { createServerClient, OrderWithItems } from '@repo/database'

// ✅ SOLUTION OPTIMALE : Utiliser les types helpers existants
export async function GET(
  request: NextRequest,
  { params }: { params: Promise<{ sessionId: string }> }
): Promise<Response> {  // ⭐ Type de retour OBLIGATOIRE
  try {
    const supabase = await createServerClient()
    const { sessionId } = await params

    if (!sessionId) {
      return NextResponse.json(
        { success: false, error: 'Session ID is required' },
        { status: 400 }
      )
    }

    // ✅ Utiliser le type OrderWithItems depuis types-helpers
    const { data: order, error: orderError } = await supabase
      .from('orders')
      .select(`
        *,
        order_items (*)
      `)
      .eq('stripe_session_id', sessionId)
      .single<OrderWithItems>()  // ⭐ Type explicite avec relation

    if (orderError || !order) {
      console.error('Order not found:', orderError)
      return NextResponse.json(
        { success: false, error: 'Order not found' },
        { status: 404 }
      )
    }

    // ✅ Plus besoin de requête séparée pour les items !
    // order.order_items est déjà disponible grâce au type OrderWithItems
    return NextResponse.json({
      success: true,
      data: {
        order: order,
        items: order.order_items || [],
      }
    })

  } catch (error) {
    console.error('Error fetching order:', error)
    return NextResponse.json(
      { success: false, error: 'Internal server error' },
      { status: 500 }
    )
  }
}
