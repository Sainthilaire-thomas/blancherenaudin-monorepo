// packages/tools/categories/src/types.ts
import type { Database } from '@repo/database'

export type Category = Database['public']['Tables']['categories']['Row']

export interface CategoryWithCounts extends Category {
  product_count?: number
  subcategory_count?: number
}

export interface CategoryFilters {
  search?: string
  is_active?: boolean
  parent_id?: string | null
}
