// apps/admin/app/api/admin/product-images/[imageId]/signed-url/route.ts
import { NextResponse } from 'next/server'
import { supabaseAdmin } from '@repo/database'

const IMAGE_FORMATS = ['webp', 'jpeg', 'avif'] as const
const IMAGE_SIZES = ['sm', 'md', 'lg', 'xl'] as const

function getVariantPath(
  productId: string,
  imageId: string,
  variant: typeof IMAGE_SIZES[number],
  format: typeof IMAGE_FORMATS[number]
): string {
  return `products/${productId}/${variant}/${imageId}.${format}`
}

export async function GET(
  req: Request,
  { params }: { params: Promise<{ imageId: string }> }
) {
  const { imageId } = await params
  const url = new URL(req.url)
  const variant = url.searchParams.get('variant') || 'original'
  const format = (url.searchParams.get('format') || 'webp') as typeof IMAGE_FORMATS[number]
  const ttl = Number(url.searchParams.get('ttl') || 600)
  const mode = url.searchParams.get('mode') || 'json'

  const { data, error } = await supabaseAdmin
    .from('product_images')
    .select('*')
    .eq('id', imageId)
    .single()

  if (error || !data) {
    return NextResponse.json(
      { error: error?.message || 'not found' },
      { status: 404 }
    )
  }

  let path = data.storage_original ?? ''
  if (!path) {
    return NextResponse.json(
      { error: 'storage_original manquant' },
      { status: 422 }
    )
  }

  // Variante demandée
  if (variant !== 'original') {
    if (
      !IMAGE_SIZES.includes(variant as any) ||
      !IMAGE_FORMATS.includes(format)
    ) {
      return NextResponse.json(
        { error: 'variant/format invalide' },
        { status: 400 }
      )
    }
    path = getVariantPath(data.product_id, imageId, variant as any, format)
  }

  const { data: signed, error: signErr } = await supabaseAdmin.storage
    .from('product-images')
    .createSignedUrl(path, ttl)

  if (signErr || !signed) {
    return NextResponse.json(
      { error: signErr?.message || 'sign error' },
      { status: 500 }
    )
  }

  // Mode JSON par défaut (pour les composants React)
  if (mode === 'json') {
    return NextResponse.json({
      signedUrl: signed.signedUrl,
      expiresAt: new Date(Date.now() + ttl * 1000).toISOString(),
    })
  }

  // Mode redirect (pour affichage direct dans le navigateur)
  return NextResponse.redirect(signed.signedUrl, 302)
}
