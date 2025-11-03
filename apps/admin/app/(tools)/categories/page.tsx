// apps/admin/app/(tools)/categories/page.tsx
import { CategoriesClient } from '@repo/tools-categories'
import { createServerClient } from '@repo/database'

export default async function CategoriesPage() {
  // Charger les catégories depuis Supabase
  const supabase = await createServerClient()  // ✅ Ajout de await ici
  
  const { data: categories, error } = await supabase
    .from('categories')
    .select('*')
    .order('sort_order', { ascending: true })
    .order('name', { ascending: true })

  if (error) {
    console.error('Error loading categories:', error)
    return (
      <div className="p-8">
        <p className="text-red-600 dark:text-red-400">
          Erreur lors du chargement des catégories: {error.message}
        </p>
      </div>
    )
  }

  return <CategoriesClient initialCategories={categories || []} />
}
