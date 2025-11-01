// packages/tools/products/src/api/products.ts
import { supabaseAdmin } from '@repo/database'
import type { Product, ProductWithDetails, ProductFilters } from '../types'

export async function listProducts(
  filters?: ProductFilters
): Promise<{ data: ProductWithDetails[]; error: Error | null }> {
  try {
    let query = supabaseAdmin
      .from('products')
      .select(`
        *,
        category:categories(id, name),
        images:product_images(*)
      `)
      .is('deleted_at', null)
      .order('created_at', { ascending: false })

    if (filters?.category) {
      query = query.eq('category_id', filters.category)
    }

    if (filters?.search) {
      query = query.ilike('name', `%${filters.search}%`)
    }

    if (filters?.status) {
      query = query.eq('status', filters.status)
    }

    const { data, error } = await query

    if (error) throw error

    return { data: data as ProductWithDetails[], error: null }
  } catch (error) {
    console.error('Error listing products:', error)
    return {
      data: [],
      error: error instanceof Error ? error : new Error('Unknown error')
    }
  }
}

export async function getProduct(
  id: string
): Promise<{ data: ProductWithDetails | null; error: Error | null }> {
  try {
    const { data, error } = await supabaseAdmin
      .from('products')
      .select(`
        *,
        category:categories(id, name),
        variants:product_variants(*),
        images:product_images(*)
      `)
      .eq('id', id)
      .is('deleted_at', null)
      .single()

    if (error) throw error

    return { data: data as ProductWithDetails, error: null }
  } catch (error) {
    console.error('Error getting product:', error)
    return {
      data: null,
      error: error instanceof Error ? error : new Error('Unknown error')
    }
  }
}

export async function createProduct(product: {
  name: string
  slug: string
  price: number
  description?: string | null
  short_description?: string | null
  category_id?: string | null
  sku?: string | null
  stock_quantity?: number | null
  is_active?: boolean | null
  is_featured?: boolean | null
  sale_price?: number | null
  care?: string | null
  composition?: string | null
  craftsmanship?: string | null
  impact?: string | null
}): Promise<{ data: Product | null; error: Error | null }> {
  try {
    const { data, error } = await supabaseAdmin
      .from('products')
      .insert(product)
      .select()
      .single()

    if (error) throw error

    return { data, error: null }
  } catch (error) {
    console.error('Error creating product:', error)
    return {
      data: null,
      error: error instanceof Error ? error : new Error('Unknown error')
    }
  }
}

export async function updateProduct(
  id: string,
  updates: {
    name?: string
    slug?: string
    price?: number
    description?: string | null
    short_description?: string | null
    category_id?: string | null
    sku?: string | null
    stock_quantity?: number | null
    is_active?: boolean | null
    is_featured?: boolean | null
    sale_price?: number | null
    care?: string | null
    composition?: string | null
    craftsmanship?: string | null
    impact?: string | null
  }
): Promise<{ data: Product | null; error: Error | null }> {
  try {
    const { data, error } = await supabaseAdmin
      .from('products')
      .update(updates)
      .eq('id', id)
      .select()
      .single()

    if (error) throw error

    return { data, error: null }
  } catch (error) {
    console.error('Error updating product:', error)
    return {
      data: null,
      error: error instanceof Error ? error : new Error('Unknown error')
    }
  }
}

export async function deleteProduct(
  id: string
): Promise<{ success: boolean; error: Error | null }> {
  try {
    const { error } = await supabaseAdmin
      .from('products')
      .update({ deleted_at: new Date().toISOString() } as any)
      .eq('id', id)

    if (error) throw error

    return { success: true, error: null }
  } catch (error) {
    console.error('Error deleting product:', error)
    return {
      success: false,
      error: error instanceof Error ? error : new Error('Unknown error')
    }
  }
}

