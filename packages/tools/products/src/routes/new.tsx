// packages/tools/products/src/routes/new.tsx
'use client'

import { useEffect, useState } from 'react'
import { ProductForm } from '../components/product-form'

export default function ProductNewPage() {
  const [categories, setCategories] = useState<any[]>([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    async function loadCategories() {
      try {
        const res = await fetch('/api/admin/categories')
        const data = await res.json()
        setCategories(data.categories || [])
      } catch (err) {
        console.error('Erreur chargement categories:', err)
      } finally {
        setLoading(false)
      }
    }
    loadCategories()
  }, [])

  if (loading) return <div className="p-8">Chargement...</div>

  const emptyProduct = {
    name: '',
    slug: '',
    price: 0,
    category_id: null,
    is_active: true,
    is_featured: false,
  }

  return (
    <ProductForm
      product={emptyProduct}
      variants={[]}
      productId=""
      categories={categories}
    />
  )
}