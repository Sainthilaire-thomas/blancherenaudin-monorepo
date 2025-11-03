// packages/tools/products/src/routes/edit.tsx
'use client'

import { useEffect, useState } from 'react'
import { ProductForm } from '../components/product-form'

interface ProductEditPageProps {
  productId: string
}

export default function ProductEditPage({ productId }: ProductEditPageProps) {
  const [data, setData] = useState<any>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    async function loadData() {
      try {
        const url = `/api/admin/products/${productId}`
        const productRes = await fetch(url)
        if (!productRes.ok) throw new Error('Produit introuvable')
        const productData = await productRes.json()

        const categoriesRes = await fetch('/api/admin/categories')
        const categoriesData = await categoriesRes.json()

        setData({
          product: productData,  // ✅ CORRIGÉ : pas de .product
          variants: productData.variants || [],
          categories: categoriesData || []  // ✅ CORRIGÉ : pas de .categories
        })
      } catch (err: any) {
        setError(err.message)
      } finally {
        setLoading(false)
      }
    }

    loadData()
  }, [productId])

  if (loading) return <div className="p-8">Chargement...</div>
  if (error) return <div className="p-8 text-red-500">Erreur: {error}</div>
  if (!data) return <div className="p-8">Produit introuvable</div>

  return (
    <ProductForm
      product={data.product}
      variants={data.variants}
      productId={productId}
      categories={data.categories}
    />
  )
}
