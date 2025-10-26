# 🔧 FIX : Corriger le Monorepo (Sans Revenir en Arrière)

**Objectif** : Faire fonctionner le monorepo avec l'architecture packages correcte

**Stratégie** : Séparer les exports serveur/client dans `@repo/database`

---

## 🎯 Solution : Exports Séparés avec Subpaths

### Principe

```
@repo/database
├── index (public) → createBrowserClient, createServerClient, types
└── /server (privé) → supabaseAdmin uniquement
```

**Règle** : 
- Client Components → `import from '@repo/database'` (PAS d'admin)
- Server Components → `import from '@repo/database/server'` (avec admin)

---

## 📝 Étape 1 : Restructurer `packages/database/`

### 1.1 Créer le Fichier Server

**Nouveau fichier** : `packages/database/src/server.ts`

```typescript
// packages/database/src/server.ts
/**
 * ⚠️ SERVER-ONLY exports
 * Ne jamais importer depuis un Client Component
 */

// Re-export du client admin
export { supabaseAdmin } from './client-admin'

// Re-export du client server (utile aussi)
export { createServerClient } from './client-server'

// Types
export type { Database, Tables, Enums } from './types'
```

---

### 1.2 Modifier l'Index Principal

**Fichier** : `packages/database/src/index.ts`

```typescript
// packages/database/src/index.ts
/**
 * ✅ PUBLIC exports (safe pour Client Components)
 */

// Clients SANS admin
export { createBrowserClient } from './client-browser'
export { createServerClient } from './client-server'

// ❌ NE PAS EXPORTER supabaseAdmin ici !
// export { supabaseAdmin } from './client-admin' // ❌ RETIRÉ

// Types
export type { Database, Tables, Enums } from './types'

// Type helpers
export * from './types-helpers'

// Stripe (si utilisé côté client)
export { stripe } from './stripe'
```

---

### 1.3 Améliorer le Client Admin (Sécurité)

**Fichier** : `packages/database/src/client-admin.ts`

```typescript
// packages/database/src/client-admin.ts
import { createClient } from '@supabase/supabase-js'
import type { Database } from './types'

// ✅ Vérification runtime côté client
if (typeof window !== 'undefined') {
  throw new Error(
    '🚨 SECURITY ERROR: supabaseAdmin cannot be used in Client Components!\n' +
    'Use createBrowserClient() or createServerClient() instead.'
  )
}

const URL = process.env.NEXT_PUBLIC_SUPABASE_URL
const SERVICE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY

if (!URL || !SERVICE_KEY) {
  throw new Error(
    'Missing Supabase environment variables:\n' +
    `- NEXT_PUBLIC_SUPABASE_URL: ${URL ? '✅' : '❌'}\n` +
    `- SUPABASE_SERVICE_ROLE_KEY: ${SERVICE_KEY ? '✅' : '❌'}`
  )
}

/**
 * ⚠️ Admin client with SERVICE_ROLE privileges
 * SERVER-ONLY - Never use in Client Components
 */
export const supabaseAdmin = createClient<Database>(URL, SERVICE_KEY, {
  auth: {
    autoRefreshToken: false,
    persistSession: false,
  },
  global: {
    headers: { 'X-Client-Info': 'admin-server' },
  },
})
```

---

### 1.4 Configurer package.json

**Fichier** : `packages/database/package.json`

```json
{
  "name": "@repo/database",
  "version": "0.0.0",
  "private": true,
  "main": "./src/index.ts",
  "types": "./src/index.ts",
  "exports": {
    ".": {
      "types": "./src/index.ts",
      "default": "./src/index.ts"
    },
    "./server": {
      "types": "./src/server.ts",
      "default": "./src/server.ts"
    },
    "./types": {
      "types": "./src/types.ts",
      "default": "./src/types.ts"
    },
    "./types-helpers": {
      "types": "./src/types-helpers.ts",
      "default": "./src/types-helpers.ts"
    }
  },
  "dependencies": {
    "@supabase/supabase-js": "^2.38.0",
    "@supabase/ssr": "^0.1.0"
  }
}
```

---

## 📝 Étape 2 : Corriger les Imports dans `apps/storefront/`

### 2.1 Identifier les Fichiers à Corriger

```bash
cd apps/storefront

# Trouver tous les fichiers important @repo/database
grep -r "from '@repo/database'" . \
  --include="*.ts" \
  --include="*.tsx" \
  --exclude-dir="node_modules" \
  --exclude-dir=".next"
```

---

### 2.2 Règles de Remplacement

**Server Components / API Routes** :

```typescript
// ❌ AVANT
import { supabaseAdmin } from '@repo/database'

// ✅ APRÈS
import { supabaseAdmin } from '@repo/database/server'
```

**Client Components** :

```typescript
// ❌ AVANT
import { createBrowserClient } from '@repo/database'

// ✅ APRÈS (pas de changement nécessaire)
import { createBrowserClient } from '@repo/database'
```

---

### 2.3 Exemples de Corrections

#### Exemple 1 : Page Serveur

**Fichier** : `apps/storefront/app/products/[category]/page.tsx`

```typescript
// ✅ Server Component
import { supabaseAdmin } from '@repo/database/server'
import type { Database } from '@repo/database/types'

export default async function CategoryPage({ params }: { params: { category: string } }) {
  const { data: products } = await supabaseAdmin
    .from('products')
    .select('*')
    .eq('category', params.category)

  return <ProductGrid products={products} />
}
```

---

#### Exemple 2 : API Route

**Fichier** : `apps/storefront/app/api/products/route.ts`

```typescript
// ✅ API Route
import { NextResponse } from 'next/server'
import { supabaseAdmin } from '@repo/database/server'

export async function GET() {
  const { data, error } = await supabaseAdmin
    .from('products')
    .select('*')

  if (error) {
    return NextResponse.json({ error: error.message }, { status: 500 })
  }

  return NextResponse.json(data)
}
```

---

#### Exemple 3 : Client Component

**Fichier** : `apps/storefront/components/products/ProductCard.tsx`

```typescript
'use client'

// ✅ Client Component
import { createBrowserClient } from '@repo/database'
import { useState } from 'react'

export function ProductCard({ productId }: { productId: string }) {
  const [product, setProduct] = useState(null)

  // Utiliser createBrowserClient (pas supabaseAdmin)
  const supabase = createBrowserClient()

  // ... fetch avec supabase.from('products')
}
```

---

#### Exemple 4 : Composant Mixte (avec Server Action)

**Fichier** : `apps/storefront/app/product/[id]/ProductDetailClient.tsx`

```typescript
'use client'

import { useState } from 'react'
import { createBrowserClient } from '@repo/database'
import type { Tables } from '@repo/database/types'

type Product = Tables<'products'>

export function ProductDetailClient({ product }: { product: Product }) {
  const supabase = createBrowserClient()
  
  // ✅ Fetch supplémentaire côté client si besoin
  const handleAddToWishlist = async () => {
    const { error } = await supabase
      .from('wishlist')
      .insert({ product_id: product.id })
    
    // ...
  }

  return (
    <div>
      {/* ... */}
    </div>
  )
}
```

**Fichier** : `apps/storefront/app/product/[id]/page.tsx` (Server Component)

```typescript
// ✅ Server Component
import { supabaseAdmin } from '@repo/database/server'
import { ProductDetailClient } from './ProductDetailClient'

export default async function ProductPage({ params }: { params: { id: string } }) {
  // Fetch côté serveur avec admin client
  const { data: product } = await supabaseAdmin
    .from('products')
    .select('*, product_images(*), variants(*)')
    .eq('id', params.id)
    .single()

  // Passer les données au Client Component
  return <ProductDetailClient product={product} />
}
```

---

### 2.4 Script de Remplacement Automatique

```bash
cd apps/storefront

# Sauvegarder d'abord
git add -A
git commit -m "Backup before fixing imports"

# Remplacer dans les Server Components / API Routes
# (Identifier manuellement ou avec grep)

# Pour les pages (Server Components)
find app -name "page.tsx" -type f -exec sed -i.bak \
  "s|from '@repo/database'|from '@repo/database/server'|g" {} +

# Pour les API routes
find app/api -name "route.ts" -type f -exec sed -i.bak \
  "s|from '@repo/database'|from '@repo/database/server'|g" {} +

# Nettoyer les backups
find . -name "*.bak" -delete
```

**⚠️ Attention** : Ce script remplace TOUS les imports. Il faut ensuite **vérifier manuellement** que les Client Components utilisent bien `createBrowserClient` et pas `supabaseAdmin`.

---

## 📝 Étape 3 : Vérifier les Composants Client

### 3.1 Trouver les Client Components

```bash
cd apps/storefront

# Trouver tous les fichiers avec 'use client'
grep -r "use client" . \
  --include="*.tsx" \
  --exclude-dir="node_modules" \
  --exclude-dir=".next"
```

---

### 3.2 Vérifier Chaque Fichier

Pour chaque Client Component trouvé :

1. **Vérifier** : Utilise-t-il `supabaseAdmin` ?
2. **Si OUI** : ❌ ERREUR ! Remplacer par `createBrowserClient`
3. **Si NON** : ✅ OK

**Exemple de correction** :

```typescript
// ❌ AVANT (dans Client Component)
'use client'
import { supabaseAdmin } from '@repo/database/server'  // ❌ INTERDIT !

// ✅ APRÈS
'use client'
import { createBrowserClient } from '@repo/database'   // ✅ OK

export function MyComponent() {
  const supabase = createBrowserClient()
  // ...
}
```

---

## 📝 Étape 4 : Vérifier les Variables d'Environnement

### 4.1 Fichier .env.local

**Fichier** : `apps/storefront/.env.local`

```env
# ✅ Variables PUBLIQUES (client + serveur)
NEXT_PUBLIC_SUPABASE_URL=https://xxx.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGc...

# ✅ Variable PRIVÉE (serveur uniquement)
SUPABASE_SERVICE_ROLE_KEY=eyJhbGc...

# Sanity
NEXT_PUBLIC_SANITY_PROJECT_ID=abc123
NEXT_PUBLIC_SANITY_DATASET=production

# Stripe
NEXT_PUBLIC_STRIPE_PUBLIC_KEY=pk_test_...
STRIPE_SECRET_KEY=sk_test_...
STRIPE_WEBHOOK_SECRET=whsec_...
```

---

### 4.2 Vérifier que les Variables sont Chargées

```bash
cd apps/storefront

# Test rapide
node -e "
require('dotenv').config({ path: '.env.local' });
console.log('URL:', process.env.NEXT_PUBLIC_SUPABASE_URL ? '✅' : '❌');
console.log('ANON_KEY:', process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY ? '✅' : '❌');
console.log('SERVICE_KEY:', process.env.SUPABASE_SERVICE_ROLE_KEY ? '✅' : '❌');
"
```

---

## 📝 Étape 5 : Tester

### 5.1 Nettoyer et Redémarrer

```bash
cd apps/storefront

# Nettoyer le cache Next.js
rm -rf .next

# Réinstaller si besoin
pnpm install

# Lancer en dev
pnpm dev
```

---

### 5.2 Tests Manuels

**Console navigateur** (F12) :

* [ ] Pas d'erreur "env manquantes"
* [ ] Pas d'erreur "cannot be used in Client Components"

**Pages à tester** :

```bash
# Homepage
http://localhost:3000

# Catalogue
http://localhost:3000/products
http://localhost:3000/products/tops

# Détail produit (avec un UUID réel)
http://localhost:3000/product/[UUID]

# Panier
http://localhost:3000/cart

# Account
http://localhost:3000/account
```

---

### 5.3 Vérifier TypeScript

```bash
cd apps/storefront

# TypeCheck complet
pnpm exec tsc --noEmit

# Si erreurs de types, les corriger
```

---

## 📝 Étape 6 : Documenter l'Architecture

Créer un README dans le package :

**Fichier** : `packages/database/README.md`

```markdown
# @repo/database

Package Supabase partagé avec séparation client/serveur.

## Usage

### Client Components

```typescript
'use client'
import { createBrowserClient } from '@repo/database'

const supabase = createBrowserClient()
```

### Server Components / API Routes

```typescript
import { supabaseAdmin } from '@repo/database/server'

const { data } = await supabaseAdmin.from('products').select('*')
```

## Architecture

- `index.ts` : Exports publics (browser, server clients)
- `server.ts` : Exports serveur uniquement (admin client)
- `client-admin.ts` : Admin client (SERVICE_ROLE)
- `client-browser.ts` : Browser client (ANON_KEY)
- `client-server.ts` : Server client (ANON_KEY + cookies)

## Sécurité

⚠️ **JAMAIS** importer `supabaseAdmin` dans un Client Component !

```typescript
// ❌ INTERDIT
'use client'
import { supabaseAdmin } from '@repo/database/server'

// ✅ OK
'use client'
import { createBrowserClient } from '@repo/database'
```
```

---

## ✅ Checklist Complète

### Package Database

* [ ] `src/server.ts` créé avec export `supabaseAdmin`
* [ ] `src/index.ts` NE contient PAS `supabaseAdmin`
* [ ] `src/client-admin.ts` a le check `typeof window`
* [ ] `package.json` a les exports configurés
* [ ] README.md créé

### Apps Storefront

* [ ] Tous les Server Components importent depuis `/server`
* [ ] Tous les Client Components importent depuis `/`
* [ ] Aucun Client Component n'utilise `supabaseAdmin`
* [ ] `.env.local` configuré
* [ ] TypeCheck passe

### Tests

* [ ] `pnpm dev` démarre sans erreurs
* [ ] Homepage s'affiche
* [ ] Catalogue fonctionne
* [ ] Détail produit OK
* [ ] Pas d'erreurs console navigateur

---

## 🚨 Troubleshooting

### Erreur : "env manquantes"

**Cause** : Client Component importe `supabaseAdmin`

**Solution** : Chercher et remplacer par `createBrowserClient`

```bash
grep -r "supabaseAdmin" apps/storefront/components/
```

---

### Erreur : "Cannot find module '@repo/database/server'"

**Cause** : `package.json` exports mal configurés

**Solution** : Vérifier `packages/database/package.json` exports

---

### Erreur TypeScript : "Module not found"

**Cause** : Cache TypeScript

**Solution** :

```bash
rm -rf apps/storefront/.next
rm -rf node_modules/.cache
pnpm install
```

---

## 📊 Résumé

**Avant** : `@repo/database` exportait tout publiquement → erreur côté client

**Après** : 
- `@repo/database` → browser + server clients (safe)
- `@repo/database/server` → admin client (server-only)

**Résultat** : Client Components ne peuvent plus importer accidentellement le client admin
