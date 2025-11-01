// packages/tools/categories/src/api/categories.ts
import { supabaseAdmin } from '@repo/database'
import type { Category, CategoryWithCounts, CategoryFilters } from '../types'

export async function listCategories(
  filters?: CategoryFilters
): Promise<{ data: CategoryWithCounts[]; error: Error | null }> {
  try {
    let query = supabaseAdmin
      .from('categories')
      .select('*')
      .order('sort_order', { ascending: true })
      .order('name', { ascending: true })

    if (filters?.search) {
      query = query.ilike('name', `%${filters.search}%`)
    }

    if (filters?.is_active !== undefined) {
      query = query.eq('is_active', filters.is_active)
    }

    if (filters?.parent_id !== undefined) {
      if (filters.parent_id === null) {
        query = query.is('parent_id', null)
      } else {
        query = query.eq('parent_id', filters.parent_id)
      }
    }

    const { data, error } = await query

    if (error) throw error

    // Compter les produits par catégorie
    const categoriesWithCounts = await Promise.all(
      (data || []).map(async (category) => {
        const { count: productCount } = await supabaseAdmin
          .from('products')
          .select('id', { count: 'exact', head: true })
          .eq('category_id', category.id)
          .is('deleted_at', null)

        const { count: subcategoryCount } = await supabaseAdmin
          .from('categories')
          .select('id', { count: 'exact', head: true })
          .eq('parent_id', category.id)
          .eq('is_active', true)

        return {
          ...category,
          product_count: productCount || 0,
          subcategory_count: subcategoryCount || 0,
        }
      })
    )

    return { data: categoriesWithCounts, error: null }
  } catch (error) {
    console.error('Error listing categories:', error)
    return {
      data: [],
      error: error instanceof Error ? error : new Error('Unknown error')
    }
  }
}

export async function getCategory(
  id: string
): Promise<{ data: CategoryWithCounts | null; error: Error | null }> {
  try {
    const { data, error } = await supabaseAdmin
      .from('categories')
      .select('*')
      .eq('id', id)
      .single()

    if (error) throw error

    // Compter les produits et sous-catégories
    const { count: productCount } = await supabaseAdmin
      .from('products')
      .select('id', { count: 'exact', head: true })
      .eq('category_id', id)
      .is('deleted_at', null)

    const { count: subcategoryCount } = await supabaseAdmin
      .from('categories')
      .select('id', { count: 'exact', head: true })
      .eq('parent_id', id)
      .eq('is_active', true)

    return {
      data: {
        ...data,
        product_count: productCount || 0,
        subcategory_count: subcategoryCount || 0,
      },
      error: null
    }
  } catch (error) {
    console.error('Error getting category:', error)
    return {
      data: null,
      error: error instanceof Error ? error : new Error('Unknown error')
    }
  }
}

export async function createCategory(category: {
  name: string
  slug: string
  description?: string | null
  parent_id?: string | null
  sort_order?: number | null
  is_active?: boolean | null
  image_url?: string | null
}): Promise<{ data: Category | null; error: Error | null }> {
  try {
    const { data, error } = await supabaseAdmin
      .from('categories')
      .insert(category)
      .select()
      .single()

    if (error) throw error

    return { data, error: null }
  } catch (error) {
    console.error('Error creating category:', error)
    return {
      data: null,
      error: error instanceof Error ? error : new Error('Unknown error')
    }
  }
}

export async function updateCategory(
  id: string,
  updates: {
    name?: string
    slug?: string
    description?: string | null
    parent_id?: string | null
    sort_order?: number | null
    is_active?: boolean | null
    image_url?: string | null
  }
): Promise<{ data: Category | null; error: Error | null }> {
  try {
    const { data, error } = await supabaseAdmin
      .from('categories')
      .update(updates)
      .eq('id', id)
      .select()
      .single()

    if (error) throw error

    return { data, error: null }
  } catch (error) {
    console.error('Error updating category:', error)
    return {
      data: null,
      error: error instanceof Error ? error : new Error('Unknown error')
    }
  }
}

export async function deleteCategory(
  id: string
): Promise<{ success: boolean; error: Error | null }> {
  try {
    // Vérifier qu'il n'y a pas de produits ou sous-catégories
    const { count: productCount } = await supabaseAdmin
      .from('products')
      .select('id', { count: 'exact', head: true })
      .eq('category_id', id)
      .is('deleted_at', null)

    if (productCount && productCount > 0) {
      throw new Error('Cannot delete category with products')
    }

    const { count: subcategoryCount } = await supabaseAdmin
      .from('categories')
      .select('id', { count: 'exact', head: true })
      .eq('parent_id', id)

    if (subcategoryCount && subcategoryCount > 0) {
      throw new Error('Cannot delete category with subcategories')
    }

    const { error } = await supabaseAdmin
      .from('categories')
      .delete()
      .eq('id', id)

    if (error) throw error

    return { success: true, error: null }
  } catch (error) {
    console.error('Error deleting category:', error)
    return {
      success: false,
      error: error instanceof Error ? error : new Error('Unknown error')
    }
  }
}
