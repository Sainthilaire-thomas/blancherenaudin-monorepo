// packages/tools/products/src/routes/list.tsx
'use client'

import { useEffect, useState } from 'react'
import { ProductsList } from '../components/products-list'
import { ProductsFilter } from '../components/products-filter'

export default function ProductsIndexPage() {
  const [products, setProducts] = useState<any[]>([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    async function loadProducts() {
      try {
        const res = await fetch('/api/admin/products')
        const data = await res.json()
        setProducts(data || [])  // ✅ CORRIGÉ : data est déjà le tableau
      } catch (err) {
        console.error('Erreur chargement produits:', err)
      } finally {
        setLoading(false)
      }
    }

    loadProducts()
  }, [])

  if (loading) return <div className="p-8">Chargement...</div>

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-semibold">Produits</h1>
      </div>

      <ProductsFilter />
      <ProductsList products={products} />
    </div>
  )
}
