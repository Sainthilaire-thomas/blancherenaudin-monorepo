// apps/storefront/lib/product-helpers.ts
import type { ProductWithRelations } from '@repo/database'

export function getPrimaryImage(product: ProductWithRelations) {
  if (!product.images || product.images.length === 0) {
    return null
  }
  
  const primaryImage = product.images.find((img) => img.is_primary)
  return primaryImage || product.images[0]
}
