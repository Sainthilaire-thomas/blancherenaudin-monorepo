# 🧹 Plan de Nettoyage et Restructuration - Module Products

**Date:** 28 octobre 2025

**Objectif:** Nettoyer le module products et le restructurer selon l'architecture modulaire correcte

**Référence:** Architecture de site_v1_next (projet d'origine)

---

## 📊 État Actuel vs État Cible

### ❌ État Actuel (Non Conforme)

```
modules/products/
├── src/
│   ├── api/                              # ❌ À SUPPRIMER
│   │   ├── actions.ts
│   │   └── products/
│   │       ├── edit-actions.ts
│   │       └── list-actions.ts
│   ├── components/
│   │   ├── forms/
│   │   │   ├── ProductForm.tsx
│   │   │   └── ProductPageWrapper.tsx
│   │   ├── lists/
│   │   │   ├── ProductsFilter.tsx
│   │   │   └── ProductsList.tsx
│   │   ├── page.tsx                      # ❌ À SUPPRIMER
│   │   ├── ProductsFilter.tsx            # ❌ DOUBLON À SUPPRIMER
│   │   └── ProductsList.tsx              # ❌ DOUBLON À SUPPRIMER
│   ├── pages/
│   │   ├── edit-page.tsx                 # ⚠️ Concept correct mais à refactoriser
│   │   ├── list-page.tsx                 # ⚠️ Concept correct mais à refactoriser
│   │   └── new-page.tsx                  # ⚠️ Concept correct mais à refactoriser
│   └── index.tsx
└── package.json
```

### ✅ État Cible (Conforme)

```
modules/products/
├── src/
│   ├── components/                       # Composants React purs
│   │   ├── forms/
│   │   │   ├── ProductForm.tsx           # ✅ Formulaire principal
│   │   │   ├── VariantForm.tsx           # ✅ Formulaire variantes
│   │   │   └── ImageGalleryManager.tsx   # ✅ Gestion images
│   │   ├── lists/
│   │   │   ├── ProductsList.tsx          # ✅ Liste produits
│   │   │   ├── ProductsFilter.tsx        # ✅ Filtres
│   │   │   └── ProductCard.tsx           # ✅ Card produit
│   │   └── detail/
│   │       ├── ProductInfo.tsx           # ✅ Infos produit
│   │       ├── VariantsSection.tsx       # ✅ Section variantes
│   │       └── StockHistory.tsx          # ✅ Historique stock
│   ├── lib/                              # Utilitaires UI
│   │   ├── formatters.ts                 # ✅ Formater prix, dates
│   │   ├── validators.ts                 # ✅ Validation formulaires
│   │   └── constants.ts                  # ✅ Constantes module
│   ├── types/                            # Types module
│   │   └── products.ts                   # ✅ Types UI
│   └── index.tsx                         # ✅ Point d'entrée avec routing
└── package.json
```

---

## 🗂️ Correspondance avec site_v1_next

### Fichiers d'Origine à Reproduire

```
SITE V1 NEXT                          →  MODULE PRODUCTS (CIBLE)
═══════════════════════════════════════════════════════════════════

📁 src/app/admin/products/
├── page.tsx                          →  index.tsx (route: [])
├── [id]/page.tsx                     →  index.tsx (route: [id])
└── new/page.tsx                      →  index.tsx (route: ['new'])

📁 src/components/admin/
├── AdminProductImage.tsx             →  @repo/admin-shell/ProductImage
├── ImageEditorModal.tsx              →  @repo/admin-shell/ImageEditor
├── Breadcrumb.tsx                    →  @repo/admin-shell/Breadcrumb
└── QuickActions.tsx                  →  @repo/admin-shell/QuickActions

📁 src/app/admin/products/ (composants)
├── ProductsFilter.tsx                →  components/lists/ProductsFilter.tsx
├── ProductsList.tsx                  →  components/lists/ProductsList.tsx
├── ProductFormClient.tsx             →  components/forms/ProductForm.tsx
└── ProductPageWrapper.tsx            →  components/forms/ProductPageWrapper.tsx

📁 src/app/api/admin/
├── products/route.ts                 →  apps/admin/app/api/products/route.ts
├── products/[id]/route.ts            →  apps/admin/app/api/products/[id]/route.ts
├── product-images/upload/route.ts    →  apps/admin/app/api/product-images/upload/route.ts
├── product-images/[id]/route.ts      →  apps/admin/app/api/product-images/[id]/route.ts
└── variants/[id]/route.ts            →  apps/admin/app/api/variants/[id]/route.ts

📁 src/lib/validation/
└── adminProducts.ts                  →  @repo/database/validation/products.ts
```

---

## 🔄 Fonctionnalités à Reproduire

### 📋 Liste des Produits (ProductsList.tsx)

**Fonctionnalités d'origine (site_v1_next) :**

* ✅ Tableau avec colonnes : Image, Nom, Prix, Stock, Catégorie, Statut, Actions
* ✅ Filtres : Recherche texte, Catégorie, Statut (actif/inactif/brouillon)
* ✅ Tri par colonne (nom, prix, stock, date création)
* ✅ Pagination (20 produits par page)
* ✅ Actions rapides : Éditer, Dupliquer, Activer/Désactiver, Supprimer
* ✅ Sélection multiple avec actions groupées
* ✅ Export CSV
* ✅ Affichage miniature image produit avec fallback
* ✅ Badge statut (vert/rouge/gris)
* ✅ Indicateur stock bas (< 5 unités)

**Code de référence (structure) :**

```tsx
// modules/products/src/components/lists/ProductsList.tsx
'use client'
import { useState, useEffect } from 'react'
import { Button } from '@repo/ui/button'
import { Input } from '@repo/ui/input'
import { Select } from '@repo/ui/select'
import { Badge } from '@repo/ui/badge'
import { ModuleServices } from '@repo/admin-shell/types'

interface ProductsListProps {
  services: ModuleServices
}

export function ProductsList({ services }: ProductsListProps) {
  const [products, setProducts] = useState([])
  const [loading, setLoading] = useState(true)
  const [filters, setFilters] = useState({
    search: '',
    category: '',
    status: 'all'
  })
  const [pagination, setPagination] = useState({
    page: 1,
    perPage: 20,
    total: 0
  })
  
  // Charger les produits
  useEffect(() => {
    fetchProducts()
  }, [filters, pagination.page])
  
  async function fetchProducts() {
    setLoading(true)
    try {
      const params = new URLSearchParams({
        search: filters.search,
        category: filters.category,
        status: filters.status,
        page: pagination.page.toString(),
        perPage: pagination.perPage.toString()
      })
    
      const response = await fetch(`/api/products?${params}`)
      const json = await response.json()
    
      if (json.success) {
        setProducts(json.data)
        setPagination(prev => ({ ...prev, total: json.total }))
      } else {
        services.notify('Erreur de chargement', 'error')
      }
    } catch (error) {
      services.notify('Erreur réseau', 'error')
    } finally {
      setLoading(false)
    }
  }
  
  // Actions
  const handleCreate = () => services.navigate(['products', 'new'])
  const handleEdit = (id: string) => services.navigate(['products', id])
  const handleDelete = async (id: string) => {
    const confirmed = await services.confirm('Supprimer ce produit ?')
    if (confirmed) {
      try {
        const response = await fetch(`/api/products/${id}`, {
          method: 'DELETE'
        })
        const json = await response.json()
      
        if (json.success) {
          services.notify('Produit supprimé', 'success')
          fetchProducts()
        } else {
          services.notify('Erreur lors de la suppression', 'error')
        }
      } catch (error) {
        services.notify('Erreur réseau', 'error')
      }
    }
  }
  
  if (loading) return <div>Chargement...</div>
  
  return (
    <div className="space-y-4">
      {/* Header avec filtres */}
      <div className="flex justify-between items-center">
        <h1 className="text-2xl font-bold">Produits ({pagination.total})</h1>
        <Button onClick={handleCreate}>Nouveau produit</Button>
      </div>
    
      {/* Filtres */}
      <div className="flex gap-4">
        <Input
          placeholder="Rechercher..."
          value={filters.search}
          onChange={(e) => setFilters(prev => ({ ...prev, search: e.target.value }))}
        />
        <Select
          value={filters.category}
          onValueChange={(val) => setFilters(prev => ({ ...prev, category: val }))}
        >
          <option value="">Toutes catégories</option>
          {/* Liste catégories */}
        </Select>
        <Select
          value={filters.status}
          onValueChange={(val) => setFilters(prev => ({ ...prev, status: val }))}
        >
          <option value="all">Tous statuts</option>
          <option value="active">Actifs</option>
          <option value="inactive">Inactifs</option>
        </Select>
      </div>
    
      {/* Tableau */}
      <table className="w-full">
        <thead>
          <tr>
            <th>Image</th>
            <th>Nom</th>
            <th>Prix</th>
            <th>Stock</th>
            <th>Catégorie</th>
            <th>Statut</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody>
          {products.map(product => (
            <tr key={product.id}>
              <td>
                <img
                  src={product.image_url}
                  alt={product.name}
                  className="w-12 h-12 object-cover"
                />
              </td>
              <td>{product.name}</td>
              <td>{product.price}€</td>
              <td>
                <Badge variant={product.stock < 5 ? 'destructive' : 'default'}>
                  {product.stock}
                </Badge>
              </td>
              <td>{product.category_name}</td>
              <td>
                <Badge variant={product.is_active ? 'success' : 'secondary'}>
                  {product.is_active ? 'Actif' : 'Inactif'}
                </Badge>
              </td>
              <td className="flex gap-2">
                <Button size="sm" onClick={() => handleEdit(product.id)}>
                  Éditer
                </Button>
                <Button
                  size="sm"
                  variant="destructive"
                  onClick={() => handleDelete(product.id)}
                >
                  Supprimer
                </Button>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    
      {/* Pagination */}
      <div className="flex justify-between items-center">
        <div>
          Page {pagination.page} sur {Math.ceil(pagination.total / pagination.perPage)}
        </div>
        <div className="flex gap-2">
          <Button
            disabled={pagination.page === 1}
            onClick={() => setPagination(prev => ({ ...prev, page: prev.page - 1 }))}
          >
            Précédent
          </Button>
          <Button
            disabled={pagination.page >= Math.ceil(pagination.total / pagination.perPage)}
            onClick={() => setPagination(prev => ({ ...prev, page: prev.page + 1 }))}
          >
            Suivant
          </Button>
        </div>
      </div>
    </div>
  )
}
```

---

### 📝 Formulaire Produit (ProductForm.tsx)

**Fonctionnalités d'origine (site_v1_next) :**

* ✅ Onglets : Informations générales, Variantes, Images, SEO
* ✅ **Onglet Infos :**
  * Nom du produit (required)
  * Slug (auto-généré depuis nom)
  * Description riche (Tiptap editor)
  * Catégorie (select)
  * Collection (select, optionnel)
  * Prix (number, required)
  * Prix barré (optionnel)
  * SKU (optionnel)
  * Statut : Brouillon / Actif / Inactif
* ✅ **Onglet Variantes :**
  * Liste des variantes (Taille, Couleur, Stock)
  * Ajouter/Supprimer variante
  * SKU unique par variante
  * Gérer stock par variante
  * Prix spécifique par variante (optionnel)
* ✅ **Onglet Images :**
  * Upload multiple (drag & drop)
  * Réorganiser par drag & drop
  * Définir image principale
  * Éditer image (crop, rotation, zoom)
  * Alt text par image
  * Supprimer image
* ✅ **Onglet SEO :**
  * Meta title (auto-généré ou custom)
  * Meta description
  * Meta keywords
  * OpenGraph image

**Structure suggérée :**

```tsx
// modules/products/src/components/forms/ProductForm.tsx
'use client'
import { useState, useEffect } from 'react'
import { useForm } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import { z } from 'zod'
import { Tabs, TabsList, TabsTrigger, TabsContent } from '@repo/ui/tabs'
import { Button } from '@repo/ui/button'
import { Input } from '@repo/ui/input'
import { Textarea } from '@repo/ui/textarea'
import { Select } from '@repo/ui/select'
import { ModuleServices } from '@repo/admin-shell/types'

// Schema de validation
const productSchema = z.object({
  name: z.string().min(1, 'Nom requis'),
  slug: z.string().min(1, 'Slug requis'),
  description: z.string().optional(),
  category_id: z.string().uuid('Catégorie requise'),
  collection_id: z.string().uuid().optional(),
  price: z.number().positive('Prix requis'),
  compare_at_price: z.number().positive().optional(),
  sku: z.string().optional(),
  is_active: z.boolean(),
})

interface ProductFormProps {
  mode: 'create' | 'edit'
  id?: string
  services: ModuleServices
}

export function ProductForm({ mode, id, services }: ProductFormProps) {
  const [loading, setLoading] = useState(false)
  const [activeTab, setActiveTab] = useState('info')
  
  const form = useForm({
    resolver: zodResolver(productSchema),
    defaultValues: {
      name: '',
      slug: '',
      description: '',
      category_id: '',
      collection_id: '',
      price: 0,
      compare_at_price: undefined,
      sku: '',
      is_active: false,
    }
  })
  
  // Charger le produit en mode édition
  useEffect(() => {
    if (mode === 'edit' && id) {
      fetchProduct(id)
    }
  }, [mode, id])
  
  async function fetchProduct(productId: string) {
    setLoading(true)
    try {
      const response = await fetch(`/api/products/${productId}`)
      const json = await response.json()
    
      if (json.success) {
        form.reset(json.data)
      } else {
        services.notify('Erreur de chargement', 'error')
      }
    } catch (error) {
      services.notify('Erreur réseau', 'error')
    } finally {
      setLoading(false)
    }
  }
  
  // Soumettre le formulaire
  async function onSubmit(data: any) {
    setLoading(true)
    try {
      const url = mode === 'create'
        ? '/api/products'
        : `/api/products/${id}`
    
      const response = await fetch(url, {
        method: mode === 'create' ? 'POST' : 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data)
      })
    
      const json = await response.json()
    
      if (json.success) {
        services.notify(
          mode === 'create' ? 'Produit créé' : 'Produit mis à jour',
          'success'
        )
        services.navigate(['products'])
      } else {
        services.notify(json.error || 'Erreur lors de la sauvegarde', 'error')
      }
    } catch (error) {
      services.notify('Erreur réseau', 'error')
    } finally {
      setLoading(false)
    }
  }
  
  if (loading && mode === 'edit') return <div>Chargement...</div>
  
  return (
    <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-6">
      <div className="flex justify-between items-center">
        <h1 className="text-2xl font-bold">
          {mode === 'create' ? 'Nouveau produit' : 'Éditer le produit'}
        </h1>
        <div className="flex gap-2">
          <Button
            type="button"
            variant="outline"
            onClick={() => services.navigate(['products'])}
          >
            Annuler
          </Button>
          <Button type="submit" disabled={loading}>
            {loading ? 'Enregistrement...' : 'Enregistrer'}
          </Button>
        </div>
      </div>
    
      <Tabs value={activeTab} onValueChange={setActiveTab}>
        <TabsList>
          <TabsTrigger value="info">Informations</TabsTrigger>
          <TabsTrigger value="variants">Variantes</TabsTrigger>
          <TabsTrigger value="images">Images</TabsTrigger>
          <TabsTrigger value="seo">SEO</TabsTrigger>
        </TabsList>
      
        <TabsContent value="info" className="space-y-4">
          {/* Champs du formulaire */}
          <Input
            label="Nom du produit"
            {...form.register('name')}
            error={form.formState.errors.name?.message}
          />
          <Input
            label="Slug"
            {...form.register('slug')}
            error={form.formState.errors.slug?.message}
          />
          <Textarea
            label="Description"
            {...form.register('description')}
            rows={6}
          />
          <Select
            label="Catégorie"
            {...form.register('category_id')}
            error={form.formState.errors.category_id?.message}
          >
            {/* Options catégories */}
          </Select>
          <Input
            label="Prix (€)"
            type="number"
            step="0.01"
            {...form.register('price', { valueAsNumber: true })}
            error={form.formState.errors.price?.message}
          />
        </TabsContent>
      
        <TabsContent value="variants">
          {/* Composant VariantForm */}
        </TabsContent>
      
        <TabsContent value="images">
          {/* Composant ImageGalleryManager */}
        </TabsContent>
      
        <TabsContent value="seo">
          {/* Champs SEO */}
        </TabsContent>
      </Tabs>
    </form>
  )
}
```

---

### 🖼️ Gestionnaire d'Images (ImageGalleryManager.tsx)

**Fonctionnalités d'origine (site_v1_next) :**

* ✅ Upload multiple (drag & drop)
* ✅ Preview des images avec miniatures
* ✅ Réorganiser par drag & drop
* ✅ Marquer comme image principale (étoile)
* ✅ Éditer image (ouvre ImageEditorModal de @repo/admin-shell)
* ✅ Définir alt text
* ✅ Supprimer image avec confirmation
* ✅ Indicateur de progression upload
* ✅ Support formats : JPG, PNG, WebP
* ✅ Taille max : 5MB par image

**Composant suggéré :**

```tsx
// modules/products/src/components/forms/ImageGalleryManager.tsx
'use client'
import { useState } from 'react'
import { ImageEditor } from '@repo/admin-shell/components/products/ImageEditor'
import { ProductImage } from '@repo/admin-shell/components/products/ProductImage'
import { Button } from '@repo/ui/button'
import { Input } from '@repo/ui/input'
import { ModuleServices } from '@repo/admin-shell/types'

interface Image {
  id: string
  url: string
  alt: string
  display_order: number
  is_primary: boolean
}

interface ImageGalleryManagerProps {
  productId: string
  images: Image[]
  services: ModuleServices
  onImagesChange: (images: Image[]) => void
}

export function ImageGalleryManager({
  productId,
  images,
  services,
  onImagesChange
}: ImageGalleryManagerProps) {
  const [uploading, setUploading] = useState(false)
  const [editingImage, setEditingImage] = useState<string | null>(null)
  
  // Upload d'images
  async function handleUpload(files: FileList) {
    setUploading(true)
  
    const formData = new FormData()
    formData.append('product_id', productId)
    Array.from(files).forEach(file => {
      formData.append('images', file)
    })
  
    try {
      const response = await fetch('/api/product-images/upload', {
        method: 'POST',
        body: formData
      })
    
      const json = await response.json()
    
      if (json.success) {
        services.notify(`${json.data.length} image(s) uploadée(s)`, 'success')
        onImagesChange([...images, ...json.data])
      } else {
        services.notify('Erreur lors de l\'upload', 'error')
      }
    } catch (error) {
      services.notify('Erreur réseau', 'error')
    } finally {
      setUploading(false)
    }
  }
  
  // Supprimer une image
  async function handleDelete(imageId: string) {
    const confirmed = await services.confirm('Supprimer cette image ?')
    if (!confirmed) return
  
    try {
      const response = await fetch(`/api/product-images/${imageId}`, {
        method: 'DELETE'
      })
    
      const json = await response.json()
    
      if (json.success) {
        services.notify('Image supprimée', 'success')
        onImagesChange(images.filter(img => img.id !== imageId))
      } else {
        services.notify('Erreur lors de la suppression', 'error')
      }
    } catch (error) {
      services.notify('Erreur réseau', 'error')
    }
  }
  
  // Définir comme image principale
  async function handleSetPrimary(imageId: string) {
    try {
      const response = await fetch(`/api/product-images/${imageId}/set-primary`, {
        method: 'POST'
      })
    
      const json = await response.json()
    
      if (json.success) {
        services.notify('Image principale définie', 'success')
        onImagesChange(
          images.map(img => ({
            ...img,
            is_primary: img.id === imageId
          }))
        )
      } else {
        services.notify('Erreur', 'error')
      }
    } catch (error) {
      services.notify('Erreur réseau', 'error')
    }
  }
  
  return (
    <div className="space-y-4">
      {/* Zone d'upload */}
      <div className="border-2 border-dashed rounded-lg p-8 text-center">
        <input
          type="file"
          multiple
          accept="image/*"
          onChange={(e) => e.target.files && handleUpload(e.target.files)}
          className="hidden"
          id="image-upload"
          disabled={uploading}
        />
        <label htmlFor="image-upload" className="cursor-pointer">
          <div className="text-gray-500">
            {uploading ? 'Upload en cours...' : 'Cliquer ou glisser des images'}
          </div>
        </label>
      </div>
    
      {/* Galerie d'images */}
      <div className="grid grid-cols-4 gap-4">
        {images.map(image => (
          <div key={image.id} className="relative group">
            <ProductImage
              productId={productId}
              imageId={image.id}
              alt={image.alt}
              size="md"
            />
          
            {/* Overlay avec actions */}
            <div className="absolute inset-0 bg-black/50 opacity-0 group-hover:opacity-100 transition-opacity flex items-center justify-center gap-2">
              <Button
                size="sm"
                variant={image.is_primary ? 'default' : 'outline'}
                onClick={() => handleSetPrimary(image.id)}
              >
                ⭐
              </Button>
              <Button
                size="sm"
                onClick={() => setEditingImage(image.id)}
              >
                ✏️
              </Button>
              <Button
                size="sm"
                variant="destructive"
                onClick={() => handleDelete(image.id)}
              >
                🗑️
              </Button>
            </div>
          
            {/* Badge image principale */}
            {image.is_primary && (
              <div className="absolute top-2 right-2 bg-yellow-500 text-white px-2 py-1 rounded text-xs">
                Principale
              </div>
            )}
          </div>
        ))}
      </div>
    
      {/* Modal d'édition */}
      {editingImage && (
        <ImageEditor
          imageId={editingImage}
          productId={productId}
          onClose={() => setEditingImage(null)}
          onSave={() => {
            setEditingImage(null)
            services.notify('Image mise à jour', 'success')
          }}
        />
      )}
    </div>
  )
}
```

---

## 🔧 Étapes de Nettoyage

### Phase 1 : Suppression des Fichiers Non Conformes

```powershell
# Naviguer vers le module products
cd modules/products/src

# 1. Supprimer le dossier api/
Remove-Item -Recurse -Force api/

# 2. Supprimer les doublons dans components/
Remove-Item components/page.tsx
Remove-Item components/ProductsFilter.tsx
Remove-Item components/ProductsList.tsx

# 3. Supprimer tous les fichiers backup
Get-ChildItem -Recurse -Filter "*.backup-*" | Remove-Item -Force

# 4. Supprimer le dossier pages/ (on va le recréer proprement)
Remove-Item -Recurse -Force pages/
```

### Phase 2 : Création de la Structure Propre

```powershell
# Créer la structure cible
mkdir -p components/forms
mkdir -p components/lists
mkdir -p components/detail
mkdir -p lib
mkdir -p types
```

### Phase 3 : Déplacement des Composants Conservés

```powershell
# Les composants dans forms/ et lists/ sont déjà au bon endroit
# Vérifier qu'il n'y a pas de doublons

# S'assurer que la structure est :
# components/
#   ├── forms/
#   │   ├── ProductForm.tsx
#   │   └── ProductPageWrapper.tsx
#   └── lists/
#       ├── ProductsFilter.tsx
#       └── ProductsList.tsx
```

### Phase 4 : Créer les Nouveaux Composants

**À créer :**

1. `components/forms/VariantForm.tsx` - Gestion des variantes
2. `components/forms/ImageGalleryManager.tsx` - Gestion des images
3. `components/lists/ProductCard.tsx` - Card produit individuelle
4. `components/detail/ProductInfo.tsx` - Affichage infos produit
5. `components/detail/VariantsSection.tsx` - Section variantes
6. `components/detail/StockHistory.tsx` - Historique stock
7. `lib/formatters.ts` - Fonctions de formatage
8. `lib/validators.ts` - Validations formulaires
9. `lib/constants.ts` - Constantes du module
10. `types/products.ts` - Types UI du module

### Phase 5 : Refactoriser index.tsx

```typescript
// modules/products/src/index.tsx
'use client'
import { ModuleProps } from '@repo/admin-shell/types'
import { ProductsList } from './components/lists/ProductsList'
import { ProductForm } from './components/forms/ProductForm'

export default function ProductsModule({ subPath, services }: ModuleProps) {
  // Route : /admin/products → Liste
  if (!subPath || subPath.length === 0) {
    return <ProductsList services={services} />
  }
  
  // Route : /admin/products/new → Création
  if (subPath[0] === 'new') {
    return <ProductForm mode="create" services={services} />
  }
  
  // Route : /admin/products/:id → Édition
  if (subPath[0]) {
    return <ProductForm mode="edit" id={subPath[0]} services={services} />
  }
  
  // Fallback
  return <ProductsList services={services} />
}
```

---

## 📋 Checklist Complète

### ✅ Nettoyage

* [ ] Supprimer `api/` du module
* [ ] Supprimer doublons dans `components/`
* [ ] Supprimer `components/page.tsx`
* [ ] Supprimer tous les fichiers `.backup-*`
* [ ] Supprimer `pages/` (ancien système)

### ✅ Structure

* [ ] Créer `components/forms/`
* [ ] Créer `components/lists/`
* [ ] Créer `components/detail/`
* [ ] Créer `lib/`
* [ ] Créer `types/`

### ✅ Composants à Créer

* [ ] `components/forms/ProductForm.tsx` (refacto)
* [ ] `components/forms/VariantForm.tsx` (nouveau)
* [ ] `components/forms/ImageGalleryManager.tsx` (nouveau)
* [ ] `components/lists/ProductsList.tsx` (refacto)
* [ ] `components/lists/ProductsFilter.tsx` (refacto)
* [ ] `components/lists/ProductCard.tsx` (nouveau)
* [ ] `components/detail/ProductInfo.tsx` (nouveau)
* [ ] `components/detail/VariantsSection.tsx` (nouveau)
* [ ] `components/detail/StockHistory.tsx` (nouveau)

### ✅ Utilitaires

* [ ] `lib/formatters.ts` (formater prix, dates, stock)
* [ ] `lib/validators.ts` (validation formulaires côté client)
* [ ] `lib/constants.ts` (constantes : statuts, types, etc.)
* [ ] `types/products.ts` (types UI spécifiques)

### ✅ Point d'Entrée

* [ ] Refactoriser `index.tsx` avec routing via `subPath`
* [ ] Supprimer toute référence à `page.tsx`
* [ ] Utiliser `ModuleProps` correctement
* [ ] Gérer 3 routes : liste, new, :id

### ✅ Routes API à Créer dans apps/admin

* [ ] `app/api/products/route.ts` (GET, POST)
* [ ] `app/api/products/[id]/route.ts` (GET, PUT, DELETE)
* [ ] `app/api/products/[id]/variants/route.ts`
* [ ] `app/api/products/[id]/stock-recompute/route.ts`
* [ ] `app/api/product-images/upload/route.ts`
* [ ] `app/api/product-images/[id]/route.ts`
* [ ] `app/api/product-images/[id]/set-primary/route.ts`
* [ ] `app/api/variants/[id]/route.ts`
* [ ] `app/api/variants/[id]/stock-adjust/route.ts`

### ✅ Tests

* [ ] Accéder à `/admin/products` → Liste affichée
* [ ] Cliquer "Nouveau produit" → Formulaire création
* [ ] Créer un produit → Succès + retour liste
* [ ] Cliquer "Éditer" → Formulaire édition avec données
* [ ] Mettre à jour un produit → Succès + retour liste
* [ ] Supprimer un produit → Confirmation + suppression
* [ ] Tester upload d'images
* [ ] Tester création de variantes
* [ ] Tester filtres et pagination

---

## 🎯 Priorités d'Implémentation

### Priority 1 : Critical (Faire en premier)

1. Nettoyer les fichiers non conformes
2. Créer les routes API dans apps/admin
3. Refactoriser `index.tsx` avec routing via `subPath`
4. Adapter `ProductsList.tsx` pour utiliser `services`
5. Adapter `ProductForm.tsx` pour utiliser `services`

### Priority 2 : Important (Faire ensuite)

6. Créer `ImageGalleryManager.tsx`
7. Créer `VariantForm.tsx`
8. Créer `lib/formatters.ts` et `lib/validators.ts`
9. Créer `ProductCard.tsx` pour la liste

### Priority 3 : Nice to Have (Si temps)

10. Créer les composants `detail/*`
11. Améliorer les filtres
12. Ajouter export CSV
13. Ajouter actions groupées

---

## 📊 Temps Estimé

| Phase                | Tâches                          | Temps         |
| -------------------- | -------------------------------- | ------------- |
| **Nettoyage**  | Supprimer fichiers non conformes | 30 min        |
| **Structure**  | Créer dossiers et organiser     | 15 min        |
| **Routes API** | Créer tous les endpoints        | 2h            |
| **Routing**    | Refactoriser index.tsx           | 1h            |
| **Liste**      | Adapter ProductsList             | 1h30          |
| **Formulaire** | Adapter ProductForm              | 2h            |
| **Images**     | Créer ImageGalleryManager       | 2h            |
| **Variantes**  | Créer VariantForm               | 1h30          |
| **Utils**      | Créer formatters, validators    | 1h            |
| **Tests**      | Tester tout le workflow          | 1h30          |
| **TOTAL**      |                                  | **13h** |

---

## 🚀 Commande de Démarrage Rapide

```powershell
# Script PowerShell pour nettoyer automatiquement
# Sauvegarder ce script : cleanup-products-module.ps1

$modulePath = "modules/products/src"

Write-Host "🧹 Nettoyage du module products..." -ForegroundColor Cyan

# 1. Supprimer api/
if (Test-Path "$modulePath/api") {
    Remove-Item -Recurse -Force "$modulePath/api"
    Write-Host "✅ Supprimé: api/" -ForegroundColor Green
}

# 2. Supprimer doublons components/
$toDelete = @("page.tsx", "ProductsFilter.tsx", "ProductsList.tsx")
foreach ($file in $toDelete) {
    $path = "$modulePath/components/$file"
    if (Test-Path $path) {
        Remove-Item $path
        Write-Host "✅ Supprimé: components/$file" -ForegroundColor Green
    }
}

# 3. Supprimer backups
Get-ChildItem -Path $modulePath -Recurse -Filter "*.backup-*" | ForEach-Object {
    Remove-Item $_.FullName -Force
    Write-Host "✅ Supprimé: $($_.Name)" -ForegroundColor Green
}

# 4. Supprimer pages/
if (Test-Path "$modulePath/pages") {
    Remove-Item -Recurse -Force "$modulePath/pages"
    Write-Host "✅ Supprimé: pages/" -ForegroundColor Green
}

# 5. Créer structure propre
$newDirs = @("lib", "types", "components/detail")
foreach ($dir in $newDirs) {
    $path = "$modulePath/$dir"
    if (-not (Test-Path $path)) {
        New-Item -ItemType Directory -Path $path -Force | Out-Null
        Write-Host "✅ Créé: $dir/" -ForegroundColor Green
    }
}

Write-Host "`n✨ Nettoyage terminé!" -ForegroundColor Cyan
Write-Host "📋 Prochaines étapes:" -ForegroundColor Yellow
Write-Host "   1. Créer les routes API dans apps/admin" -ForegroundColor White
Write-Host "   2. Refactoriser index.tsx" -ForegroundColor White
Write-Host "   3. Adapter les composants existants" -ForegroundColor White
```

---

**Prochaine étape :** Voulez-vous que je vous aide à créer les routes API dans `apps/admin` ou à refactoriser un composant spécifique ?
