// packages/tools/products/src/types.ts
import type { Database } from '@repo/database'

export type Product = Database['public']['Tables']['products']['Row']
export type ProductVariant = Database['public']['Tables']['product_variants']['Row']
export type ProductImage = Database['public']['Tables']['product_images']['Row']

export interface ProductWithDetails extends Product {
  variants?: ProductVariant[]
  images?: ProductImage[]
  category?: {
    id: string
    name: string
  }
}

export interface ProductFilters {
  category?: string
  search?: string
  status?: 'draft' | 'published' | 'archived'
}

// Utiliser les types Supabase directement dans l'API
// Au lieu de ProductInsert/ProductUpdate
