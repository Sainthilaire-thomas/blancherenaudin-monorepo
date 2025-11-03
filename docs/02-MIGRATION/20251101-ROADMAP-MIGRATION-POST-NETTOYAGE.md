# 🗺️ ROADMAP DE MIGRATION - Post-Nettoyage

## Blanche Renaudin - Guide de continuation après nettoyage

**Date:** 31 octobre 2025

**Statut:** Après Phase 1 du nettoyage

**Référence:** site_v1_next (source de vérité)

---

## 📍 OÙ EN SOMMES-NOUS ?

### ✅ Ce qui est déjà migré et fonctionnel

```
blancherenaudin-monorepo/
├── apps/
│   ├── admin/          ✅ Shell + registry fonctionnel
│   │   └── (tools)/
│   │       └── newsletter/  ✅ Module complet et opérationnel
│   │
│   └── storefront/     ✅ Site public complet
│       ├── app/        ✅ Toutes les routes
│       ├── components/ ✅ Tous les composants
│       ├── hooks/      ✅ Tous les hooks
│       ├── lib/        ✅ Tous les utilitaires
│       └── store/      ✅ Tous les stores Zustand
│
└── packages/
    ├── Core
    │   ├── database/   ✅ Clients Supabase
    │   ├── email/      ✅ Templates email
    │   ├── ui/         ✅ Design system
    │   └── utils/      ✅ Utilitaires
    │
    ├── Configuration
    │   ├── eslint-config/      ✅
    │   └── typescript-config/  ✅
    │
    └── tools/
        ├── analytics/  ✅ Analytics custom
        └── newsletter/ ✅ ⭐ Référence de structure
```

### 🚧 Ce qui reste à migrer depuis site_v1_next

```
site_v1_next/src/app/admin/
├── categories/     → packages/tools/categories/
├── customers/      → packages/tools/customers/
├── media/          → packages/tools/media/
├── orders/         → packages/tools/orders/
└── products/       → packages/tools/products/

+ Leurs API routes respectives
+ Leurs composants spécifiques
+ Leurs stores Zustand
```

---

## 🎯 STRATÉGIE DE MIGRATION DES TOOLS

### Ordre recommandé (par complexité)

#### 1️⃣ **products/** - PRIORITAIRE (le plus complexe)

**Pourquoi en premier ?**

* Module le plus riche (variantes, stock, images)
* Sert de référence pour les autres
* Déjà bien structuré dans site_v1_next

**Complexité:** 🔴🔴🔴🔴 (4/5)

**Contenu à migrer:**

```
site_v1_next/
├── src/app/admin/products/
│   ├── page.tsx                    → routes/ProductsList.tsx
│   ├── [id]/
│   │   └── page.tsx                → routes/ProductDetail.tsx
│   │   └── ProductFormClient.tsx   → routes/ProductFormClient.tsx
│   │   └── actions.ts              → api/products.ts
│   └── new/
│       └── page.tsx                → routes/ProductForm.tsx
│
├── src/app/api/admin/products/
│   ├── route.ts                    → api/products.ts (list, create)
│   ├── [id]/route.ts               → api/products.ts (get, update, delete)
│   └── [id]/variants/route.ts      → api/variants.ts
│   └── [id]/stock-*/               → api/stock.ts
│
├── src/store/useProductStore.ts    → hooks/useProductStore.ts
│
└── src/components/ (spécifiques produits)
    └── admin/
        ├── AdminProductImage.tsx   → components/ProductImage.tsx
        └── ImageEditorModal.tsx    → components/ImageEditor.tsx
```

**Estimation:** 6-8 heures

---

#### 2️⃣ **customers/** - MOYENNE PRIORITÉ

**Pourquoi en deuxième ?**

* Moins complexe que products
* Référence pour les autres modules CRUD
* Besoin pour gérer les commandes

**Complexité:** 🔴🔴🔴 (3/5)

**Contenu à migrer:**

```
site_v1_next/
├── src/app/admin/customers/
│   ├── page.tsx                    → routes/CustomersList.tsx
│   ├── CustomersClient.tsx         → routes/CustomersListClient.tsx
│   └── [id]/
│       ├── page.tsx                → routes/CustomerDetail.tsx
│       ├── CustomerDetailClient.tsx → routes/CustomerDetailClient.tsx
│       └── tabs/
│           ├── AddressesTab.tsx    → components/AddressesTab.tsx
│           ├── NotesTab.tsx        → components/NotesTab.tsx
│           └── OrdersTab.tsx       → components/OrdersTab.tsx
│
├── src/app/api/admin/customers/
│   ├── route.ts                    → api/customers.ts
│   ├── [id]/route.ts               → api/customers.ts
│   ├── [id]/addresses/             → api/addresses.ts
│   ├── [id]/notes/                 → api/notes.ts
│   └── [id]/orders/                → api/orders.ts (partial)
│
└── src/lib/services/customerService.ts → Déjà dans packages/utils/
```

**Estimation:** 4-5 heures

---

#### 3️⃣ **orders/** - MOYENNE PRIORITÉ

**Pourquoi en troisième ?**

* Dépend de products et customers
* Logique métier importante
* Intégration Stripe/paiements

**Complexité:** 🔴🔴🔴🔴 (4/5)

**Contenu à migrer:**

```
site_v1_next/
├── src/app/admin/orders/
│   ├── page.tsx                    → routes/OrdersList.tsx
│   └── [id]/
│       ├── page.tsx                → routes/OrderDetail.tsx
│       ├── OrderAdminClient.tsx    → routes/OrderDetailClient.tsx
│       └── actions.ts              → api/orders.ts
│
├── src/app/api/admin/orders/       (si existant)
│
└── Logique webhook Stripe          → api/webhooks.ts
```

**Estimation:** 5-6 heures

---

#### 4️⃣ **categories/** - BASSE PRIORITÉ

**Pourquoi en quatrième ?**

* Module simple (CRUD basique)
* Pas de dépendances complexes
* Rapide à migrer

**Complexité:** 🔴🔴 (2/5)

**Contenu à migrer:**

```
site_v1_next/
├── src/app/admin/categories/
│   ├── page.tsx                    → routes/CategoriesList.tsx
│   └── CategoriesClient.tsx        → routes/CategoriesClient.tsx
│
└── src/app/api/admin/categories/
    ├── route.ts                    → api/categories.ts
    └── [id]/route.ts               → api/categories.ts
```

**Estimation:** 2-3 heures

---

#### 5️⃣ **media/** - MOYENNE-BASSE PRIORITÉ

**Pourquoi en dernier ?**

* Module autonome (galerie)
* Dépend de database et storage uniquement
* Fonctionnalité "nice to have"

**Complexité:** 🔴🔴🔴 (3/5)

**Contenu à migrer:**

```
site_v1_next/
├── src/app/admin/media/
│   ├── page.tsx                    → routes/MediaGrid.tsx
│   ├── MediaGridClient.tsx         → routes/MediaGridClient.tsx
│   └── MediaGridHeader.tsx         → components/MediaGridHeader.tsx
│
└── src/app/api/admin/product-images/ → api/images.ts
    ├── upload/route.ts
    ├── [imageId]/route.ts
    ├── [imageId]/signed-url/route.ts
    └── edit/route.tsx
```

**Estimation:** 3-4 heures

---

## 📋 TEMPLATE DE MIGRATION D'UN TOOL

### Structure cible pour chaque tool

```
packages/tools/{tool-name}/
├── src/
│   ├── api/                # 💎 Logique pure (testable)
│   │   ├── {resource}.ts   # CRUD operations
│   │   ├── utils.ts        # Helpers spécifiques
│   │   └── index.ts        # Exports
│   │
│   ├── routes/             # 🎨 Écrans RSC + Client Components
│   │   ├── {Resource}List.tsx          # Server Component
│   │   ├── {Resource}ListClient.tsx    # 'use client'
│   │   ├── {Resource}Detail.tsx        # Server Component
│   │   ├── {Resource}Form.tsx          # Server Component
│   │   ├── {Resource}FormClient.tsx    # 'use client'
│   │   └── index.ts
│   │
│   ├── components/         # 🧩 Composants UI spécifiques
│   │   ├── {Resource}Card.tsx
│   │   ├── {Resource}Filters.tsx
│   │   ├── {Resource}Actions.tsx
│   │   └── index.ts
│   │
│   ├── hooks/              # 🪝 Hooks métier
│   │   ├── use{Resource}Form.ts
│   │   ├── use{Resource}List.ts
│   │   └── index.ts
│   │
│   ├── types.ts            # 📐 Types TypeScript
│   ├── constants.ts        # 📊 Constantes
│   ├── validation.ts       # ✅ Schémas Zod
│   ├── manifest.ts         # ⚙️ Configuration tool
│   └── index.ts            # 📦 Exports publics
│
├── __tests__/              # 🧪 Tests
│   ├── api/
│   │   └── {resource}.test.ts
│   └── components/
│       └── {Component}.test.tsx
│
├── package.json
├── tsconfig.json
└── README.md
```

### Exemple de manifest.ts

```typescript
// packages/tools/products/src/manifest.ts

import { Package } from 'lucide-react'
import type { ToolManifest } from '@repo/admin-shell'

export const manifest: ToolManifest = {
  id: 'products',
  name: 'Produits',
  description: 'Gestion des produits, variantes et stock',
  icon: Package,
  version: '1.0.0',
  
  // Routes exposées
  routes: {
    base: '/products',
    list: '/products',
    detail: '/products/:id',
    create: '/products/new'
  },
  
  // Permissions requises
  permissions: {
    read: 'products:read',
    write: 'products:write',
    delete: 'products:delete'
  },
  
  // Dépendances
  dependencies: [
    '@repo/database',
    '@repo/ui',
    '@repo/utils'
  ],
  
  // Navigation
  navigation: {
    label: 'Produits',
    order: 1,
    category: 'Catalogue'
  }
}
```

---

## 🔄 PROCESSUS DE MIGRATION STEP-BY-STEP

### Pour chaque tool (exemple: products)

#### ÉTAPE 1: Préparation (15 min)

```powershell
# 1. Créer la structure
cd packages\tools\
mkdir products
cd products

# 2. Copier depuis newsletter (template)
Copy-Item ..\newsletter\package.json .\package.json
Copy-Item ..\newsletter\tsconfig.json .\tsconfig.json
Copy-Item ..\newsletter\README.md .\README.md

# 3. Adapter package.json
code package.json
# Changer: "name": "@repo/tools-products"

# 4. Créer l'arborescence
mkdir src\api, src\routes, src\components, src\hooks, __tests__
New-Item src\types.ts, src\constants.ts, src\validation.ts, src\manifest.ts, src\index.ts
```

#### ÉTAPE 2: Migration API (logique pure) (2-3h)

```powershell
# Source: site_v1_next/src/app/api/admin/products/

# 1. Ouvrir deux fenêtres VS Code côte à côte
code C:\path\to\site_v1_next\src\app\api\admin\products\
code .\src\api\

# 2. Extraire la logique pure (sans Next.js)
# - route.ts → api/products.ts (fonctions CRUD)
# - [id]/route.ts → api/products.ts (suite)
# - [id]/variants/route.ts → api/variants.ts
# - [id]/stock-*/route.ts → api/stock.ts

# 3. Créer api/images.ts si nécessaire
```

**Règles:**

* ✅ Fonctions pures (pas de `NextRequest`, `NextResponse`)
* ✅ Utiliser `@repo/database` pour les queries
* ✅ Utiliser Zod pour la validation
* ❌ Pas de logique Next.js

**Exemple:**

```typescript
// ❌ Avant (route.ts dans site_v1_next)
export async function GET(req: NextRequest) {
  const products = await supabase.from('products').select()
  return NextResponse.json(products)
}

// ✅ Après (api/products.ts dans tool)
export async function listProducts(filters?: ProductFilters) {
  const { database } = await import('@repo/database')
  const query = database.from('products').select('*')
  
  if (filters?.category) {
    query.eq('category_id', filters.category)
  }
  
  const { data, error } = await query
  if (error) throw error
  return data
}
```

#### ÉTAPE 3: Migration Routes (pages Next.js) (1-2h)

```powershell
# Source: site_v1_next/src/app/admin/products/

# 1. Copier les pages
# page.tsx → routes/ProductsList.tsx (Server Component)
# [id]/page.tsx → routes/ProductDetail.tsx (Server Component)
# new/page.tsx → routes/ProductForm.tsx (Server Component)

# 2. Copier les clients
# ProductsClient.tsx → routes/ProductsListClient.tsx
# [id]/ProductFormClient.tsx → routes/ProductFormClient.tsx
```

**Règles:**

* ✅ Server Components par défaut
* ✅ `'use client'` seulement quand nécessaire
* ✅ Importer depuis `./api` (logique locale)
* ❌ Pas d'appels API externes dans les RSC

#### ÉTAPE 4: Migration Composants (UI) (1h)

```powershell
# Source: site_v1_next/src/components/admin/ (filtrer ceux liés au tool)

# Copier dans components/
# - ProductCard.tsx
# - ProductFilters.tsx
# - VariantEditor.tsx
# - StockAdjustment.tsx
# etc.
```

#### ÉTAPE 5: Migration Hooks (1h)

```powershell
# Source: site_v1_next/src/store/ + hooks custom

# useProductStore.ts → hooks/useProductStore.ts
# Autres hooks spécifiques → hooks/use*.ts
```

**Adaptation:**

```typescript
// ❌ Import absolu dans site_v1_next
import { useProductStore } from '@/store/useProductStore'

// ✅ Import relatif dans tool
import { useProductStore } from '../hooks/useProductStore'
```

#### ÉTAPE 6: Types et Validation (30 min)

```typescript
// types.ts
export interface Product {
  id: string
  name: string
  // ...
}

// validation.ts
import { z } from 'zod'

export const productSchema = z.object({
  name: z.string().min(1),
  price: z.number().positive(),
  // ...
})

// constants.ts
export const PRODUCT_STATUSES = {
  DRAFT: 'draft',
  PUBLISHED: 'published',
  ARCHIVED: 'archived'
} as const
```

#### ÉTAPE 7: Manifest (15 min)

```typescript
// manifest.ts
import { Package } from 'lucide-react'

export const manifest = {
  id: 'products',
  name: 'Produits',
  icon: Package,
  routes: { /* ... */ },
  permissions: { /* ... */ }
}
```

#### ÉTAPE 8: Exports publics (15 min)

```typescript
// index.ts
export * from './api'
export * from './routes'
export * from './components'
export * from './hooks'
export * from './types'
export * from './constants'
export { manifest } from './manifest'
```

#### ÉTAPE 9: Intégration dans admin (30 min)

```typescript
// apps/admin/lib/registry.ts
import { manifest as productsManifest } from '@repo/tools-products'

export const toolRegistry = {
  newsletter: newsletterManifest,
  products: productsManifest,  // ← Ajouter
  // ...
}
```

```tsx
// apps/admin/app/(tools)/products/page.tsx
import { ProductsList } from '@repo/tools-products/routes'

export default async function ProductsPage() {
  return <ProductsList />
}
```

#### ÉTAPE 10: Tests et validation (1h)

```powershell
# Build du tool
cd packages\tools\products\
pnpm build

# Type-check
pnpm type-check

# Tests unitaires (si implémentés)
pnpm test

# Build global
cd ..\..\..
pnpm build

# Dev
pnpm dev
# Tester en navigant vers /admin/products
```

---

## ✅ CHECKLIST PAR TOOL

```
Tool: __________

Structure:
[ ] Dossier créé dans packages/tools/
[ ] package.json configuré
[ ] tsconfig.json configuré
[ ] Arborescence src/ créée

Migration:
[ ] API (logique pure) migrée
[ ] Routes (pages) migrées
[ ] Composants UI migrés
[ ] Hooks migrés
[ ] Types définis
[ ] Validation Zod
[ ] Constants définis
[ ] Manifest créé
[ ] Exports index.ts

Intégration:
[ ] Ajouté au registry
[ ] Pages admin créées
[ ] Navigation configurée

Tests:
[ ] pnpm build OK
[ ] pnpm type-check OK
[ ] Tests unitaires (si applicable)
[ ] Test manuel en dev
[ ] CRUD complet fonctionnel

Documentation:
[ ] README.md à jour
[ ] Commentaires API
[ ] Exemples d'usage
```

---

## 🎯 APRÈS MIGRATION DES 5 TOOLS

### Tâches finales

1. **Supprimer modules/** (s'il existe encore)
2. **Nettoyer apps/admin** (supprimer l'ancien code si dupliqué)
3. **Optimiser les imports** (vérifier pas de doublons)
4. **Ajouter tests E2E** (Playwright)
5. **Documentation finale** (README principal)
6. **CI/CD** (GitHub Actions)

---

## 📚 RESSOURCES

### Références de code

* **Tool modèle:** `packages/tools/newsletter/`
* **Source de vérité:** `site_v1_next/`
* **Architecture cible:** `ARCHITECTURE-CIBLE.md`

### Scripts utiles

* **cleanup-phase1.ps1** - Nettoyage déjà fait
* **cleanup-backups.ps1** - Nettoyage backups
* Créer: **migrate-tool.ps1** (script de migration automatique)

### Documentation

* **PLAN-NETTOYAGE-MONOREPO.md** - Plan de nettoyage complet
* **ARCHITECTURE-CIBLE.md** - Architecture finale

---

## 💡 CONSEILS

### Pendant la migration:

1. **Un tool à la fois** - Ne pas commencer le suivant avant de finir
2. **Commit fréquent** - Chaque étape = 1 commit
3. **Tester après chaque étape** - `pnpm build` + `pnpm dev`
4. **Consulter newsletter/** - C'est la référence de structure
5. **En cas de doute** - Revenir à site_v1_next (source de vérité)

### Gestion des erreurs:

* **Import manquant** → Vérifier les exports dans index.ts
* **Type error** → Vérifier database.types.ts à jour
* **Build error** → Vérifier tsconfig.json et dépendances
* **Runtime error** → Vérifier les env vars et Supabase RLS

---

**Document créé le:** 31 octobre 2025

**Version:** 1.0

**Statut:** Guide de continuation post-nettoyage

**Prochaine étape:** Migrer packages/tools/products/
