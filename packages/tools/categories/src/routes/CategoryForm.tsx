// packages/tools/categories/src/routes/CategoryForm.tsx
'use client'

import { useState } from 'react'
import { useRouter } from 'next/navigation'
import { Button } from '@repo/ui'
import { Input } from '@repo/ui'
import { Textarea } from '@repo/ui'
import { ArrowLeft } from 'lucide-react'
import Link from 'next/link'

interface CategoryFormProps {
  id?: string
}

export function CategoryForm({ id }: CategoryFormProps) {
  const router = useRouter()
  const [loading, setLoading] = useState(false)
  const [formData, setFormData] = useState({
    name: '',
    slug: '',
    description: '',
    is_active: true,
    sort_order: 0,
  })

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setLoading(true)

    try {
      // TODO: Implémenter l'appel API
      console.log('Form data:', formData)
      
      // Rediriger vers la liste
      router.push('/admin/categories')
    } catch (error) {
      console.error('Error:', error)
    } finally {
      setLoading(false)
    }
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

      <div className="bg-white rounded-lg shadow p-6 max-w-2xl">
        <h1 className="text-2xl font-bold mb-6">
          {id ? 'Modifier la catégorie' : 'Nouvelle catégorie'}
        </h1>

        <form onSubmit={handleSubmit} className="space-y-4">
          <div>
            <label className="block text-sm font-medium mb-2">
              Nom *
            </label>
            <Input
              value={formData.name}
              onChange={(e) => setFormData({ ...formData, name: e.target.value })}
              required
              placeholder="Hauts"
            />
          </div>

          <div>
            <label className="block text-sm font-medium mb-2">
              Slug *
            </label>
            <Input
              value={formData.slug}
              onChange={(e) => setFormData({ ...formData, slug: e.target.value })}
              required
              placeholder="hauts"
            />
          </div>

          <div>
            <label className="block text-sm font-medium mb-2">
              Description
            </label>
            <Textarea
              value={formData.description}
              onChange={(e) => setFormData({ ...formData, description: e.target.value })}
              placeholder="Description de la catégorie..."
              rows={4}
            />
          </div>

          <div>
            <label className="flex items-center space-x-2">
              <input
                type="checkbox"
                checked={formData.is_active}
                onChange={(e) => setFormData({ ...formData, is_active: e.target.checked })}
                className="rounded"
              />
              <span className="text-sm font-medium">Active</span>
            </label>
          </div>

          <div>
            <label className="block text-sm font-medium mb-2">
              Ordre d'affichage
            </label>
            <Input
              type="number"
              value={formData.sort_order}
              onChange={(e) => setFormData({ ...formData, sort_order: parseInt(e.target.value) })}
              placeholder="0"
            />
          </div>

          <div className="flex gap-4 pt-4">
            <Button type="submit" disabled={loading}>
              {loading ? 'Enregistrement...' : 'Enregistrer'}
            </Button>
            <Link href="/admin/categories">
              <Button type="button" variant="outline">
                Annuler
              </Button>
            </Link>
          </div>
        </form>
      </div>
    </div>
  )
}

