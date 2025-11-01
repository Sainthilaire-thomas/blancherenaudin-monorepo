// apps/storefront/app/api/admin/product-images/[imageId]/signed-url/route.ts
import { NextRequest, NextResponse } from 'next/server'
import { supabaseAdmin } from '@repo/database'

export const runtime = 'nodejs'

interface RouteContext {
  params: Promise<{
    imageId: string
  }>
}

export async function GET(
  request: NextRequest,
  context: RouteContext
) {
  try {
    const { imageId } = await context.params
    const { searchParams } = new URL(request.url)
    
    const variant = searchParams.get('variant') || 'md'
    const format = searchParams.get('format') || 'webp'
    const mode = searchParams.get('mode')

    console.log('🔍 Fetching image:', imageId)

    // Récupérer l'image depuis la base (COLONNES CORRECTES)
    const { data: image, error: imageError } = await supabaseAdmin
      .from('product_images')
      .select('id, product_id, storage_original, storage_master')
      .eq('id', imageId)
      .single()

    if (imageError || !image) {
      console.error('❌ Image not found in DB:', imageId, imageError)
      return NextResponse.json(
        { error: 'Image not found' },
        { status: 404 }
      )
    }

    console.log('✅ Image found:', {
      id: image.id,
      product_id: image.product_id,
      storage_original: image.storage_original,
      storage_master: image.storage_master
    })

    // Utiliser storage_original comme chemin de base
    const originalPath = image.storage_original
    
    if (!originalPath) {
      console.error('❌ No storage path found')
      return NextResponse.json(
        { error: 'No storage path' },
        { status: 500 }
      )
    }

    // Construire le chemin avec variant et format
    // Exemple: products/68123603.../image.jpg → products/68123603.../image-xl.webp
    const basePath = originalPath.replace(/\.[^/.]+$/, '') // Enlever l'extension
    const variantPath = `${basePath}-${variant}.${format}`

    console.log('🔍 Trying variant path:', variantPath)

    // Essayer d'abord avec le variant
    let { data: signedUrlData, error: urlError } = await supabaseAdmin
      .storage
      .from('product-images')
      .createSignedUrl(variantPath, 3600)

    // Si le variant n'existe pas, utiliser l'original
    if (urlError || !signedUrlData) {
      console.log('⚠️  Variant not found, trying original:', originalPath)
      
      const result = await supabaseAdmin
        .storage
        .from('product-images')
        .createSignedUrl(originalPath, 3600)
      
      signedUrlData = result.data
      urlError = result.error
    }

    if (urlError || !signedUrlData) {
      console.error('❌ Failed to create signed URL:', urlError)
      return NextResponse.json(
        { error: 'Failed to create signed URL', details: urlError },
        { status: 500 }
      )
    }

    console.log('✅ Signed URL created successfully')

    // Retourner selon le mode demandé (IMPORTANT: la clé doit être 'signedUrl')
    if (mode === 'json') {
      return NextResponse.json({ signedUrl: signedUrlData.signedUrl })
    }

    // Par défaut, rediriger vers l'URL signée
    return NextResponse.redirect(signedUrlData.signedUrl)

  } catch (error) {
    console.error('💥 Unexpected error in signed-url route:', error)
    return NextResponse.json(
      { error: 'Internal server error', details: String(error) },
      { status: 500 }
    )
  }
}

