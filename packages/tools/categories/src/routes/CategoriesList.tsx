// packages/tools/categories/src/routes/CategoriesList.tsx
import { listCategories } from '../api'
import Link from 'next/link'
import { Button } from '@repo/ui'
import { Plus } from 'lucide-react'

export async function CategoriesList() {
  const { data: categories, error } = await listCategories()

  if (error) {
    return (
      <div className="p-8">
        <p className="text-red-600">Erreur: {error.message}</p>
      </div>
    )
  }

  return (
    <div className="p-8">
      <div className="flex justify-between items-center mb-6">
        <h1 className="text-2xl font-bold">Catégories</h1>
        <Link href="/admin/categories/new">
          <Button>
            <Plus className="w-4 h-4 mr-2" />
            Nouvelle catégorie
          </Button>
        </Link>
      </div>

      <div className="bg-white rounded-lg shadow">
        <table className="min-w-full">
          <thead className="bg-gray-50">
            <tr>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
                Nom
              </th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
                Slug
              </th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
                Produits
              </th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
                Statut
              </th>
              <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase">
                Actions
              </th>
            </tr>
          </thead>
          <tbody className="divide-y divide-gray-200">
            {categories.map((category) => (
              <tr key={category.id}>
                <td className="px-6 py-4">
                  <Link 
                    href={`/admin/categories/${category.id}`}
                    className="text-blue-600 hover:underline"
                  >
                    {category.name}
                  </Link>
                </td>
                <td className="px-6 py-4 text-sm text-gray-600">
                  {category.slug}
                </td>
                <td className="px-6 py-4 text-sm text-gray-600">
                  {category.product_count || 0}
                </td>
                <td className="px-6 py-4">
                  <span className={`px-2 py-1 text-xs rounded-full ${
                    category.is_active 
                      ? 'bg-green-100 text-green-800' 
                      : 'bg-gray-100 text-gray-800'
                  }`}>
                    {category.is_active ? 'Active' : 'Inactive'}
                  </span>
                </td>
                <td className="px-6 py-4 text-right">
                  <Link href={`/admin/categories/${category.id}`}>
                    <Button variant="ghost" size="sm">
                      Modifier
                    </Button>
                  </Link>
                </td>
              </tr>
            ))}
          </tbody>
        </table>

        {categories.length === 0 && (
          <div className="text-center py-12 text-gray-500">
            Aucune catégorie. Créez-en une pour commencer.
          </div>
        )}
      </div>
    </div>
  )
}

