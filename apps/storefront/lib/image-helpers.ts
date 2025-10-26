/**
 * Helper pour générer les URLs des images produits depuis Supabase Storage
 */

const SUPABASE_URL = process.env.NEXT_PUBLIC_SUPABASE_URL || ''

export type ImageSize = 'sm' | 'md' | 'lg' | 'xl'

/**
 * Génère l'URL d'une image produit avec la taille demandée
 */
export function getProductImageUrl(
  imageId: string,
  size: ImageSize = 'md'
): string {
  if (!imageId || !SUPABASE_URL) {
    return '/placeholder.jpg'
  }

  // Format: product_images/sm_imageId.jpg
  return `${SUPABASE_URL}/storage/v1/object/public/product_images/${size}_${imageId}.jpg`
}
