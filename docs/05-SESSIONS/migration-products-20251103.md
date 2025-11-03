# Migration Module Products - 03/11/2025

## 📊 Résumé de la migration

**Date**: 03 novembre 2025 à 14:58
**Source**: site_v1_next (monolithique)
**Destination**: blancherenaudin-monorepo (architecture modulaire)
**Statut**: ✅ Phases 1-4 terminées

---

## ✅ Ce qui a été migré

### Phase 1: AdminProductImage → @repo/ui
- ✅ Copie de `AdminProductImage.tsx` vers `packages/ui/src/admin-product-image.tsx`
- ✅ Export ajouté dans `packages/ui/src/index.ts`
- ℹ️  Distinction claire entre:
  - **AdminProductImage**: Composant admin avec signed URLs
  - **ProductImage**: Composant storefront (publique)

### Phase 2: Validations → @repo/database
- ✅ Création du dossier `packages/database/src/validations/`
- ✅ Copie de `adminProducts.ts` vers `admin-products.ts`
- ✅ Création de `validations/index.ts`
- ✅ Export ajouté dans `packages/database/src/index.ts`

### Phase 3: Composants → @repo/tools-products
Fichiers copiés dans `packages/tools/products/src/components/`:
- ✅ `products-list.tsx` (ex ProductsList.tsx)
- ✅ `products-filter.tsx` (ex ProductsFilter.tsx)
- ✅ `product-form.tsx` (ex ProductFormClient.tsx)
- ✅ `components/index.ts` créé

### Phase 4: Actions serveur → @repo/tools-products
Fichiers copiés dans `packages/tools/products/src/actions/`:
- ✅ `products-actions.ts` (actions liste produits)
- ✅ `product-actions.ts` (actions produit individuel)
- ✅ `actions/index.ts` créé

---

## 📦 Structure finale du tool
```
packages/tools/products/
├── src/
│   ├── api/              ✅ (existant)
│   │   ├── index.ts
│   │   └── products.ts
│   ├── actions/          ✅ NOUVEAU
│   │   ├── index.ts
│   │   ├── products-actions.ts
│   │   └── product-actions.ts
│   ├── components/       ✅ NOUVEAU
│   │   ├── index.ts
│   │   ├── products-list.tsx
│   │   ├── products-filter.tsx
│   │   └── product-form.tsx
│   ├── routes/           ⚠️ À CRÉER (Phase 5)
│   │   ├── index.tsx
│   │   ├── edit.tsx
│   │   └── new.tsx
│   ├── constants.ts      ✅ (existant)
│   ├── types.ts          ✅ (existant)
│   └── index.ts          ✅ (existant)
├── package.json          ✅
├── tsconfig.json         ✅
└── README.md             ✅
```

---

## ⚠️ Étapes manuelles restantes

### 1. Adapter les imports (EN COURS)

Remplacements nécessaires dans les fichiers migrés:

| Ancien import | Nouveau import |
|---------------|----------------|
| `@/components/products/ProductImage` | `@repo/ui` (AdminProductImage) |
| `@/components/admin/Toast` | `sonner` (toast.success/error) |
| `@/lib/supabase-admin` | `@repo/database` |
| `@/lib/validation/adminProducts` | `@repo/database/validations` |
| `@/lib/database.types` | `@repo/database/types` |

**Script disponible**: `adapt-imports-products.ps1`

### 2. Créer les routes (Phase 5)

Créer dans `packages/tools/products/src/routes/`:

#### `index.tsx` - Liste des produits
```tsx
// packages/tools/products/src/routes/index.tsx
import { ProductsList } from '../components/products-list'
import { ProductsFilter } from '../components/products-filter'

export default function ProductsPage() {
  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <h1 className="text-3xl font-bold">Products</h1>
        <ProductsFilter />
      </div>
      <ProductsList />
    </div>
  )
}
```

#### `edit.tsx` - Édition produit
```tsx
// packages/tools/products/src/routes/edit.tsx
import { ProductForm } from '../components/product-form'

interface EditProductPageProps {
  params: { id: string }
}

export default function EditProductPage({ params }: EditProductPageProps) {
  return (
    <div className="max-w-4xl mx-auto">
      <h1 className="text-3xl font-bold mb-6">Edit Product</h1>
      <ProductForm productId={params.id} />
    </div>
  )
}
```

#### `new.tsx` - Création produit
```tsx
// packages/tools/products/src/routes/new.tsx
import { ProductForm } from '../components/product-form'

export default function NewProductPage() {
  return (
    <div className="max-w-4xl mx-auto">
      <h1 className="text-3xl font-bold mb-6">New Product</h1>
      <ProductForm />
    </div>
  )
}
```

**Puis**: Créer `routes/index.ts` pour les exports

### 3. Créer les wrappers dans l'admin shell (Phase 6)

Créer dans `apps/admin/app/(tools)/products/`:

#### `page.tsx` - Liste
```tsx
// apps/admin/app/(tools)/products/page.tsx
import ProductsPage from '@repo/tools-products/routes'

export default ProductsPage
```

#### `[id]/page.tsx` - Édition
```tsx
// apps/admin/app/(tools)/products/[id]/page.tsx
import EditProductPage from '@repo/tools-products/routes/edit'

export default EditProductPage
```

#### `new/page.tsx` - Création
```tsx
// apps/admin/app/(tools)/products/new/page.tsx
import NewProductPage from '@repo/tools-products/routes/new'

export default NewProductPage
```

### 4. Vérifier transpilePackages

S'assurer que `apps/admin/next.config.ts` contient:
```typescript
transpilePackages: [
  '@repo/ui',
  '@repo/database',
  '@repo/tools-products', // ✅ Doit être présent
]
```

### 5. Builder et tester
```bash
# Installer les dépendances
pnpm install

# Builder le monorepo
pnpm build

# Lancer l'admin en dev
cd apps/admin
pnpm dev
```

**Tester**:
- ✅ Liste des produits: http://localhost:3000/products
- ✅ Création produit: http://localhost:3000/products/new
- ✅ Édition produit: http://localhost:3000/products/[id]

---

## 🔧 Dépendances ajoutées

### @repo/ui
- `AdminProductImage` (signed URLs pour l'admin)

### @repo/database
- `validations/admin-products` (schémas Zod)
- Clients Supabase (browser, server, admin)
- Types database

### @repo/tools-products
- `components/*` (UI du module)
- `actions/*` (Server actions)
- `api/*` (Logique métier)

---

## 📈 Métriques

- **Fichiers copiés**: 7
- **Fichiers créés**: 5
- **Erreurs**: 0
- **Temps estimé**: ~20 minutes
- **Phases complétées**: 4/7

---

## 📚 Ressources

- [Architecture Cible](./ARCHITECTURE-CIBLE-V2.md)
- [Guide d'ajout de tool](./ARCHITECTURE-AJOUTER-TOOL.md)
- [Bonnes pratiques](./ARCHITECTURE-BONNES-PRATIQUES-TOOLS.md)

---

## ✅ Checklist de validation

- [x] Phase 1: AdminProductImage migré
- [x] Phase 2: Validations migrées
- [x] Phase 3: Composants migrés
- [x] Phase 4: Actions migrées
- [ ] Imports adaptés (@/ → @repo/)
- [ ] Phase 5: Routes créées
- [ ] Phase 6: Wrappers admin créés
- [ ] Build réussi (`pnpm build`)
- [ ] Tests manuels OK
- [ ] Types TypeScript OK

---

**Documentation générée automatiquement le 03/11/2025 à 14:58**
