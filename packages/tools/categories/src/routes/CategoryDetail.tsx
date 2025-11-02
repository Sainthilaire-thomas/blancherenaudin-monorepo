// packages/tools/categories/src/routes/CategoryDetail.tsx
import { getCategory } from '../api'
import Link from 'next/link'
import { Button } from '@repo/ui'
import { ArrowLeft, Edit } from 'lucide-react'
import { notFound } from 'next/navigation'

interface CategoryDetailProps {
  id: string
}

export async function CategoryDetail({ id }: CategoryDetailProps) {
  const { data: category, error } = await getCategory(id)

  if (error || !category) {
    notFound()
  }

  return (
    <div className="p-8">
      <div className="mb-6">
        <Link href="/admin/categories">
          <Button variant="ghost" size="sm">
            <ArrowLeft className="w-4 h-4 mr-2" />
            Retour
          </Button>
        </Link>
      </div>

      <div className="bg-white rounded-lg shadow p-6">
        <div className="flex justify-between items-start mb-6">
          <div>
            <h1 className="text-3xl font-bold">{category.name}</h1>
            <p className="text-gray-600 mt-2">/{category.slug}</p>
          </div>
          <Link href={`/admin/categories/${category.id}/edit`}>
            <Button>
              <Edit className="w-4 h-4 mr-2" />
              Modifier
            </Button>
          </Link>
        </div>

        <div className="grid grid-cols-2 gap-6">
          <div>
            <h3 className="text-sm font-medium text-gray-500 mb-2">Description</h3>
            <p className="text-gray-900">
              {category.description || 'Aucune description'}
            </p>
          </div>

          <div>
            <h3 className="text-sm font-medium text-gray-500 mb-2">Statut</h3>
            <span className={`px-3 py-1 text-sm rounded-full ${
              category.is_active 
                ? 'bg-green-100 text-green-800' 
                : 'bg-gray-100 text-gray-800'
            }`}>
              {category.is_active ? 'Active' : 'Inactive'}
            </span>
          </div>

          <div>
            <h3 className="text-sm font-medium text-gray-500 mb-2">Produits</h3>
            <p className="text-2xl font-bold">{category.product_count || 0}</p>
          </div>

          <div>
            <h3 className="text-sm font-medium text-gray-500 mb-2">Sous-catégories</h3>
            <p className="text-2xl font-bold">{category.subcategory_count || 0}</p>
          </div>

          {category.parent_id && (
            <div>
              <h3 className="text-sm font-medium text-gray-500 mb-2">Catégorie parente</h3>
              <Link href={`/admin/categories/${category.parent_id}`}>
                <Button variant="link">Voir la parente</Button>
              </Link>
            </div>
          )}

          <div>
            <h3 className="text-sm font-medium text-gray-500 mb-2">Ordre d'affichage</h3>
            <p className="text-gray-900">{category.sort_order || 0}</p>
          </div>
        </div>
      </div>
    </div>
  )
}

