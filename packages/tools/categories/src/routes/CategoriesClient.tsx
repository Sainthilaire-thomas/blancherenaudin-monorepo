'use client'

import { useState, useTransition } from 'react'
import { useRouter } from 'next/navigation'
import { toast } from 'sonner'

type Category = {
  id: string
  name: string
  slug: string
  parent_id: string | null
  sort_order: number | null
  is_active: boolean | null
  description: string | null
  image_url: string | null
  created_at: string
  updated_at: string
}

type Props = {
  initialCategories: Category[]
}

export function CategoriesClient({ initialCategories }: Props) {
  const router = useRouter()
  const [isPending, startTransition] = useTransition()
  const [categories, setCategories] = useState(initialCategories)
  const [editingId, setEditingId] = useState<string | null>(null)

  const [newCategory, setNewCategory] = useState({
    name: '',
    slug: '',
    parent_id: '',
    sort_order: '0',
    is_active: true,
  })

  const [editForm, setEditForm] = useState<Partial<Category>>({})

  async function handleCreate(e: React.FormEvent) {
    e.preventDefault()

    startTransition(async () => {
      try {
        const res = await fetch('/api/admin/categories', {
          method: 'POST',
          headers: { 'content-type': 'application/json' },
          body: JSON.stringify({
            name: newCategory.name,
            slug: newCategory.slug,
            parent_id: newCategory.parent_id || null,
            sort_order: Number(newCategory.sort_order),
            is_active: newCategory.is_active,
          }),
        })

        if (!res.ok) throw new Error('Erreur création')

        const { data } = await res.json()
        setCategories([...categories, data])
        setNewCategory({
          name: '',
          slug: '',
          parent_id: '',
          sort_order: '0',
          is_active: true,
        })
        toast.success('Catégorie créée')
        router.refresh()
      } catch (err: any) {
        toast.error(err.message || 'Erreur')
      }
    })
  }

  async function handleUpdate(id: string) {
    startTransition(async () => {
      try {
        const res = await fetch(`/api/admin/categories/${id}`, {
          method: 'PATCH',
          headers: { 'content-type': 'application/json' },
          body: JSON.stringify(editForm),
        })

        if (!res.ok) throw new Error('Erreur mise à jour')

        const { data } = await res.json()
        setCategories(categories.map((c) => (c.id === id ? data : c)))
        setEditingId(null)
        setEditForm({})
        toast.success('Catégorie mise à jour')
        router.refresh()
      } catch (err: any) {
        toast.error(err.message || 'Erreur')
      }
    })
  }

  async function handleDelete(id: string) {
    if (!confirm('Supprimer cette catégorie ?')) return

    startTransition(async () => {
      try {
        const res = await fetch(`/api/admin/categories/${id}`, {
          method: 'DELETE',
        })

        if (!res.ok) throw new Error('Erreur suppression')

        setCategories(categories.filter((c) => c.id !== id))
        toast.success('Catégorie supprimée')
        router.refresh()
      } catch (err: any) {
        toast.error(err.message || 'Erreur')
      }
    })
  }

  function startEdit(category: Category) {
    setEditingId(category.id)
    setEditForm({
      name: category.name,
      slug: category.slug,
      parent_id: category.parent_id,
      sort_order: category.sort_order,
      is_active: category.is_active,
    })
  }

  function cancelEdit() {
    setEditingId(null)
    setEditForm({})
  }

  return (
    <div className="space-y-6">
      <h1 className="text-2xl font-semibold dark:text-white">Catégories</h1>

      {/* Formulaire de création */}
      <div className="border border-gray-300 dark:border-gray-600 rounded-lg p-4 bg-white dark:bg-gray-800">
        <h2 className="font-medium mb-3 dark:text-white">Créer une catégorie</h2>
        <form onSubmit={handleCreate} className="grid md:grid-cols-5 gap-3">
          <input
            name="name"
            placeholder="Nom"
            value={newCategory.name}
            onChange={(e) =>
              setNewCategory({ ...newCategory, name: e.target.value })
            }
            className="border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-900 dark:text-white p-2 rounded"
            required
          />
          <input
            name="slug"
            placeholder="slug"
            value={newCategory.slug}
            onChange={(e) =>
              setNewCategory({ ...newCategory, slug: e.target.value })
            }
            className="border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-900 dark:text-white p-2 rounded"
            required
          />
          <select
            name="parent_id"
            value={newCategory.parent_id}
            onChange={(e) =>
              setNewCategory({ ...newCategory, parent_id: e.target.value })
            }
            className="border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-900 dark:text-white p-2 rounded"
          >
            <option value="">(Sans parent)</option>
            {categories.map((c) => (
              <option key={c.id} value={c.id}>
                {c.name}
              </option>
            ))}
          </select>
          <input
            name="sort_order"
            type="number"
            placeholder="Ordre"
            value={newCategory.sort_order}
            onChange={(e) =>
              setNewCategory({ ...newCategory, sort_order: e.target.value })
            }
            className="border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-900 dark:text-white p-2 rounded"
          />
          <label className="inline-flex items-center gap-2 dark:text-white">
            <input
              name="is_active"
              type="checkbox"
              checked={newCategory.is_active}
              onChange={(e) =>
                setNewCategory({ ...newCategory, is_active: e.target.checked })
              }
              className="rounded border-gray-300 text-violet focus:ring-violet"
            />
            <span className="text-sm">Active</span>
          </label>
          <div className="md:col-span-5">
            <button
              type="submit"
              disabled={isPending}
              className="border border-gray-300 dark:border-gray-600 rounded px-4 py-2 hover:bg-violet hover:text-white hover:border-violet transition disabled:opacity-50 dark:text-white"
            >
              {isPending ? 'Création...' : 'Créer'}
            </button>
          </div>
        </form>
      </div>

      {/* Liste des catégories */}
      <div className="border border-gray-300 dark:border-gray-600 rounded-lg overflow-hidden bg-white dark:bg-gray-800">
        <div className="overflow-x-auto">
          <table className="w-full text-sm">
            <thead className="bg-gray-50 dark:bg-gray-900 border-b border-gray-300 dark:border-gray-600">
              <tr>
                <th className="text-left py-3 px-4 font-medium dark:text-gray-300">Nom</th>
                <th className="text-left py-3 px-4 font-medium dark:text-gray-300">Slug</th>
                <th className="text-left py-3 px-4 font-medium dark:text-gray-300">Parent</th>
                <th className="text-left py-3 px-4 font-medium dark:text-gray-300">Ordre</th>
                <th className="text-left py-3 px-4 font-medium dark:text-gray-300">Statut</th>
                <th className="text-left py-3 px-4 font-medium dark:text-gray-300">Actions</th>
              </tr>
            </thead>
            <tbody>
              {categories.map((cat) => (
                <tr
                  key={cat.id}
                  className="border-b border-gray-200 dark:border-gray-700 last:border-0"
                >
                  {editingId === cat.id ? (
                    <>
                      <td className="py-2 px-4">
                        <input
                          value={editForm.name ?? ''}
                          onChange={(e) =>
                            setEditForm({ ...editForm, name: e.target.value })
                          }
                          className="w-full border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-900 dark:text-white p-1 rounded text-sm"
                        />
                      </td>
                      <td className="py-2 px-4">
                        <input
                          value={editForm.slug ?? ''}
                          onChange={(e) =>
                            setEditForm({ ...editForm, slug: e.target.value })
                          }
                          className="w-full border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-900 dark:text-white p-1 rounded text-sm"
                        />
                      </td>
                      <td className="py-2 px-4">
                        <select
                          value={editForm.parent_id ?? ''}
                          onChange={(e) =>
                            setEditForm({
                              ...editForm,
                              parent_id: e.target.value || null,
                            })
                          }
                          className="w-full border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-900 dark:text-white p-1 rounded text-sm"
                        >
                          <option value="">—</option>
                          {categories
                            .filter((c) => c.id !== cat.id)
                            .map((c) => (
                              <option key={c.id} value={c.id}>
                                {c.name}
                              </option>
                            ))}
                        </select>
                      </td>
                      <td className="py-2 px-4">
                        <input
                          type="number"
                          value={editForm.sort_order ?? 0}
                          onChange={(e) =>
                            setEditForm({
                              ...editForm,
                              sort_order: Number(e.target.value),
                            })
                          }
                          className="w-20 border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-900 dark:text-white p-1 rounded text-sm"
                        />
                      </td>
                      <td className="py-2 px-4">
                        <label className="inline-flex items-center gap-1">
                          <input
                            type="checkbox"
                            checked={editForm.is_active ?? false}
                            onChange={(e) =>
                              setEditForm({
                                ...editForm,
                                is_active: e.target.checked,
                              })
                            }
                            className="rounded border-gray-300 text-violet focus:ring-violet"
                          />
                          <span className="text-xs dark:text-gray-300">
                            {editForm.is_active ? 'Oui' : 'Non'}
                          </span>
                        </label>
                      </td>
                      <td className="py-2 px-4">
                        <div className="flex gap-2">
                          <button
                            onClick={() => handleUpdate(cat.id)}
                            disabled={isPending}
                            className="text-green-600 dark:text-green-400 hover:underline disabled:opacity-50"
                          >
                            ✓ Sauver
                          </button>
                          <button
                            onClick={cancelEdit}
                            disabled={isPending}
                            className="text-gray-600 dark:text-gray-400 hover:underline disabled:opacity-50"
                          >
                            ✕ Annuler
                          </button>
                        </div>
                      </td>
                    </>
                  ) : (
                    <>
                      <td className="py-2 px-4 dark:text-white">{cat.name}</td>
                      <td className="py-2 px-4 text-gray-500 dark:text-gray-400">
                        {cat.slug}
                      </td>
                      <td className="py-2 px-4 text-gray-500 dark:text-gray-400">
                        {categories.find((p) => p.id === cat.parent_id)?.name ??
                          '—'}
                      </td>
                      <td className="py-2 px-4 text-gray-500 dark:text-gray-400">
                        {cat.sort_order ?? 0}
                      </td>
                      <td className="py-2 px-4">
                        <span
                          className={`inline-block px-2 py-0.5 rounded text-xs ${
                            cat.is_active
                              ? 'bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-200'
                              : 'bg-gray-100 text-gray-800 dark:bg-gray-700 dark:text-gray-300'
                          }`}
                        >
                          {cat.is_active ? 'Active' : 'Inactive'}
                        </span>
                      </td>
                      <td className="py-2 px-4">
                        <div className="flex gap-2">
                          <button
                            onClick={() => startEdit(cat)}
                            disabled={isPending}
                            className="text-violet dark:text-violet-400 hover:underline disabled:opacity-50"
                          >
                            Éditer
                          </button>
                          <button
                            onClick={() => handleDelete(cat.id)}
                            disabled={isPending}
                            className="text-red-600 dark:text-red-400 hover:underline disabled:opacity-50"
                          >
                            Supprimer
                          </button>
                        </div>
                      </td>
                    </>
                  )}
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  )
}
