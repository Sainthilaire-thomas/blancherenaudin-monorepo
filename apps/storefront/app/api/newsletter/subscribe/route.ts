﻿// src/app/api/newsletter/subscribe/route.ts
import { NextRequest, NextResponse } from 'next/server'
import { supabaseAdmin } from '@repo/database/client-admin'
import { sendEmail } from '@repo/email/send'
import { z } from 'zod'
import NewsletterConfirmation from '@repo/email/newsletter-confirmation'

const subscribeSchema = z.object({
  email: z.string().email('Email invalide'),
  first_name: z.string().optional(),
  last_name: z.string().optional(),
})

export async function POST(req: NextRequest) {
  try {
    const body = await req.json()
    const data = subscribeSchema.parse(body)

    // V�rifier si email existe d�j�
    const { data: existing } = await supabaseAdmin
      .from('newsletter_subscribers')
      .select('id, status')
      .eq('email', data.email)
      .single()

    if (existing) {
      if (existing.status === 'active') {
        return NextResponse.json(
          { success: false, error: 'Cet email est d�j� inscrit' },
          { status: 409 }
        )
      }

      // R�activer si d�sabonn�
      if (existing.status === 'unsubscribed') {
        await supabaseAdmin
          .from('newsletter_subscribers')
          .update({ status: 'pending', unsubscribed_at: null })
          .eq('id', existing.id)
      }
    } else {
      // Cr�er nouvel abonn�
      const { error } = await supabaseAdmin
        .from('newsletter_subscribers')
        .insert({
          email: data.email,
          first_name: data.first_name,
          last_name: data.last_name,
          status: 'pending',
          consent_ip: req.headers.get('x-forwarded-for') || null,
          consent_source: 'website_footer',
        })

      if (error) throw error
    }

    // G�n�rer token de confirmation
    const confirmToken = Buffer.from(
      JSON.stringify({
        email: data.email,
        exp: Date.now() + 24 * 60 * 60 * 1000, // 24h
      })
    ).toString('base64')

    // ? CORRECTION : Ajouter /api/ dans l'URL
    const baseUrl =
      process.env.NEXT_PUBLIC_BASE_URL || 'https://www.blancherenaudin.com'
    const confirmUrl = `${baseUrl}/api/newsletter/confirm?token=${confirmToken}`

    console.log('?? Lien de confirmation g�n�r�:', confirmUrl)

    // Envoyer email de confirmation
    await sendEmail({
      to: data.email,
      subject: 'Confirmez votre inscription � la newsletter',
      from: 'newsletter@blancherenaudin.com',
      react: NewsletterConfirmation({
        firstName: data.first_name,
        confirmUrl,
      }),
    })

    return NextResponse.json({
      success: true,
      message: `Email de confirmation envoy� � ${data.email}`,
    })
  } catch (error) {
    if (error instanceof z.ZodError) {
      return NextResponse.json(
        { success: false, error: error.errors[0].message },
        { status: 400 }
      )
    }

    console.error('Subscribe error:', error)
    return NextResponse.json(
      { success: false, error: "Erreur lors de l'inscription" },
      { status: 500 }
    )
  }
}
