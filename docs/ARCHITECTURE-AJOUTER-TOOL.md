
# **Document 2 — Création d'un nouveau Tool compatible avec le Shell**

> **📅 Dernière mise à jour** : 2 novembre 2025
>
> **✅ Statut** : Recette validée avec POC `test-tool`

---

## 🎉 Recette validée - POC test-tool

**IMPORTANT** : Cette recette a été validée et fonctionne à 100% avec Next.js 15.0.3 + pnpm workspace.

### ✅ Configuration qui fonctionne

#### 1. Structure du package

```
packages/tools/test-tool/
├── src/
│   └── index.tsx          ← .tsx PAS .ts !
├── package.json
└── node_modules/
```

#### 2. Package.json minimal

```json
{
  "name": "@repo/tools-test",
  "version": "0.0.0",
  "private": true,
  "type": "module",
  "exports": {
    ".": "./src/index.tsx"   // ✅ Pointer vers .tsx
  },
  "dependencies": {
    "react": "^19.0.0"
  }
}
```

#### 3. Composant simple

```tsx
// packages/tools/test-tool/src/index.tsx
export function TestComponent() {
  return <div>Test component works!</div>
}
```

#### 4. Page Next.js

```tsx
// apps/admin/app/test-tool/page.tsx
import { TestComponent } from '@repo/tools-test'

export default function TestToolPage() {
  return (
    <div className="p-8">
      <h1 className="text-2xl font-bold mb-4">Test Tool Page</h1>
      <TestComponent />
    </div>
  )
}
```

#### 5. Installation du package

```bash
# Dans apps/admin
pnpm add @repo/tools-test@workspace:*
```

#### 6. Configuration Next.js

```typescript
// apps/admin/next.config.ts
const nextConfig: NextConfig = {
  transpilePackages: [
    '@repo/tools-test',  // ✅ CRITIQUE
  ],
}
```

### 🎯 Points critiques à respecter

| Point                               | Importance   | Détail                                                  |
| ----------------------------------- | ------------ | -------------------------------------------------------- |
| **Extension .tsx**            | 🔴 CRITIQUE  | Utiliser `.tsx`pour les fichiers avec JSX, pas `.ts` |
| **Ajouter comme dépendance** | 🔴 CRITIQUE  | `pnpm add @repo/xxx@workspace:*`dans apps/admin        |
| **transpilePackages**         | 🔴 CRITIQUE  | Ajouter le package dans next.config.ts                   |
| **Export simple**             | 🟡 Important | `"exports": { ".": "./src/index.tsx" }`                |
| **Symlink pnpm**              | 🟡 Important | Vérifier que `node_modules/@repo/xxx`existe           |

### ⚠️ Erreurs courantes

#### Erreur 0 : "The default export is not a React Component" (LAYOUTS VIDES)

```
Error: The default export is not a React Component in "/page"
```

**Cause** : Un layout parent (groupe de routes) est vide ou corrompu

**Symptôme** : Le composant fonctionne hors du groupe mais pas dedans

**Solution** : Vérifier que TOUS les layouts retournent `{children}` :

```tsx
// ❌ LAYOUT VIDE - CASSE TOUT
export default function Layout() {
  // rien ici
}

// ✅ MINIMUM REQUIS
export default function Layout({ children }: { children: React.ReactNode }) {
  return <>{children}</>
}
```

**Comment vérifier** :

```powershell
# Afficher le contenu du layout
Get-Content "apps/admin/app/(tools)/layout.tsx"

# S'il est vide ou ne retourne rien → LE REMPLACER
```

**Note** : Cette erreur est insidieuse car le message ne mentionne PAS le layout !

#### Erreur 1 : "Expected ';', got 'component'"

```
Error: × Expected ';', got 'component'
```

**Cause** : Le fichier est `.ts` au lieu de `.tsx`

**Solution** : Renommer en `.tsx` et mettre à jour l'export dans package.json

#### Erreur 2 : "Module not found: Can't resolve '@repo/xxx'"

```
Module not found: Can't resolve '@repo/tools-test'
```

**Cause** : Le package n'est pas ajouté comme dépendance

**Solution** :

```bash
cd apps/admin
pnpm add @repo/tools-test@workspace:*
```

#### Erreur 3 : "The default export is not a React Component"

```
Error: The default export is not a React Component in "/page"
```

**Cause multiple possible** :

1. Le composant n'est pas exporté correctement
2. Le package n'est pas dans `transpilePackages`
3. Problème de cache Next.js

**Solutions** :

```bash
# 1. Vérifier l'export
Get-Content packages/tools/xxx/src/index.tsx

# 2. Ajouter dans transpilePackages
# Voir next.config.ts

# 3. Nettoyer le cache
Remove-Item -Recurse -Force apps/admin/.next
pnpm dev
```

---

## 🎯 Objectif

Ce guide explique comment :

* Créer un **nouveau tool** modulaire dans `packages/tools/`
* L'intégrer dans le **shell Next.js** (`apps/admin`)
* Le rendre compatible avec :
  * Le **Design System partagé** (`@repo/ui`)
  * Le **client Supabase partagé** (`@repo/database`)
  * Le **système de routage App Router**
  * Le **registre des tools** (manifest & permissions)
  * Le **middleware RBAC**

---

## 🧱 Étape 1 — Structure de base du tool

Chaque tool est un **package indépendant** dans le dossier `packages/tools/`.

Exemple : Création du tool `categories`

```bash
mkdir -p packages/tools/categories/src/{routes,api,components,hooks}
```

**Fichier `package.json` :**

```json
{
  "name": "@repo/tools-categories",
  "version": "0.0.0",
  "private": true,
  "type": "module",
  "exports": {
    ".": "./src/index.ts"
  },
  "dependencies": {
    "@repo/ui": "workspace:*",
    "@repo/database": "workspace:*",
    "react": "^19.0.0",
    "next": "^15.0.0"
  },
  "devDependencies": {
    "typescript": "^5.3.0",
    "vitest": "^2.0.0"
  }
}
```

---

## 🧩 Étape 2 — Créer les composants du tool

### Structure recommandée

```
packages/tools/categories/
├── src/
│   ├── api/              # Logique métier pure
│   │   └── categories.ts
│   ├── routes/           # Composants de pages (RSC + Client)
│   │   ├── CategoriesList.tsx
│   │   └── CategoryDetail.tsx
│   ├── components/       # Composants UI spécifiques
│   │   └── CategoryForm.tsx
│   ├── hooks/           # Hooks métier
│   ├── types.ts         # Types
│   └── index.ts         # Exports publics
```

### ⚠️ Structure Next.js avec layouts

```
apps/admin/app/
├── (tools)/                    # Groupe de routes
│   ├── layout.tsx              ⚠️ DOIT RETOURNER {children}
│   ├── categories/
│   │   ├── layout.tsx          ✅ Optionnel (navigation locale)
│   │   └── page.tsx            ✅ Import depuis @repo/tools-categories
│   └── newsletter/
└── other-routes/
```

**RÈGLE D'OR** : Tout layout DOIT retourner `{children}`, même minimal :

```tsx
// ✅ Minimum requis pour un layout
export default function Layout({ children }: { children: React.ReactNode }) {
  return <>{children}</>
}
```

### Exemple : API pure (testable)

```typescript
// packages/tools/categories/src/api/categories.ts
import { createServerClient } from '@repo/database'

export interface Category {
  id: string
  name: string
  slug: string
  parent_id: string | null
  order_index: number
  is_active: boolean
}

export async function listCategories() {
  const supabase = createServerClient()
  
  const { data, error } = await supabase
    .from('categories')
    .select('*')
    .order('order_index')
  
  return { data, error }
}

export async function getCategory(id: string) {
  const supabase = createServerClient()
  
  const { data, error } = await supabase
    .from('categories')
    .select('*')
    .eq('id', id)
    .single()
  
  return { data, error }
}

export async function createCategory(input: Omit<Category, 'id'>) {
  const supabase = createServerClient()
  
  const { data, error } = await supabase
    .from('categories')
    .insert(input)
    .select()
    .single()
  
  return { data, error }
}
```

### Exemple : Route (Server Component)

```tsx
// packages/tools/categories/src/routes/CategoriesList.tsx
import { listCategories } from '../api/categories'
import { CategoriesClient } from './CategoriesClient'

export async function CategoriesList() {
  const { data: categories, error } = await listCategories()
  
  if (error) {
    return <div>Erreur: {error.message}</div>
  }
  
  return <CategoriesClient initialCategories={categories || []} />
}
```

### Exemple : Client Component

```tsx
// packages/tools/categories/src/routes/CategoriesClient.tsx
'use client'

import { useState } from 'react'
import { Button } from '@repo/ui'
import type { Category } from '../types'

interface Props {
  initialCategories: Category[]
}

export function CategoriesClient({ initialCategories }: Props) {
  const [categories, setCategories] = useState(initialCategories)
  
  return (
    <div className="space-y-4">
      <div className="flex justify-between items-center">
        <h1 className="text-2xl font-bold">Catégories</h1>
        <Button>Nouvelle catégorie</Button>
      </div>
    
      <div className="grid gap-4">
        {categories.map(cat => (
          <div key={cat.id} className="border p-4 rounded">
            {cat.name}
          </div>
        ))}
      </div>
    </div>
  )
}
```

### Exports publics

```typescript
// packages/tools/categories/src/index.ts
export * from './types'
export * from './api'
export * from './routes'
```

---

## 🧭 Étape 3 — Monter le tool dans le Shell Next.js

Le shell (dans `apps/admin/app/(tools)/`) héberge les routes du tool.

### Structure

```
apps/admin/app/(tools)/categories/
├── page.tsx              # Liste des catégories
├── [id]/
│   └── page.tsx          # Détail d'une catégorie
├── new/
│   └── page.tsx          # Nouvelle catégorie
├── layout.tsx            # Layout local (navigation)
└── error.tsx             # Error boundary
```

### Pages minces (wrapper de composants)

```tsx
// apps/admin/app/(tools)/categories/page.tsx
import { CategoriesList } from '@repo/tools-categories'

export default async function CategoriesPage() {
  return <CategoriesList />
}
```

```tsx
// apps/admin/app/(tools)/categories/[id]/page.tsx
import { CategoryDetail } from '@repo/tools-categories'

interface Props {
  params: { id: string }
}

export default async function CategoryDetailPage({ params }: Props) {
  return <CategoryDetail categoryId={params.id} />
}
```

### Layout local (navigation du tool)

```tsx
// apps/admin/app/(tools)/categories/layout.tsx
'use client'

import Link from 'next/link'
import { usePathname } from 'next/navigation'

export default function CategoriesLayout({
  children,
}: {
  children: React.ReactNode
}) {
  const pathname = usePathname()
  
  return (
    <div>
      <nav className="border-b mb-4">
        <div className="flex gap-4 p-4">
          <Link 
            href="/categories"
            className={pathname === '/categories' ? 'font-bold' : ''}
          >
            Liste
          </Link>
          <Link 
            href="/categories/new"
            className={pathname === '/categories/new' ? 'font-bold' : ''}
          >
            Nouveau
          </Link>
        </div>
      </nav>
    
      {children}
    </div>
  )
}
```

---

## ⚙️ Étape 4 — Configuration Next.js

### Ajouter le package comme dépendance

```bash
cd apps/admin
pnpm add @repo/tools-categories@workspace:*
```

### Configurer transpilePackages

```typescript
// apps/admin/next.config.ts
import type { NextConfig } from 'next'

const nextConfig: NextConfig = {
  reactStrictMode: true,
  
  // ✅ CRITIQUE : Transpiler tous les packages tools
  transpilePackages: [
    '@repo/ui',
    '@repo/database',
    '@repo/tools-categories',  // ✅ Ajouter le nouveau tool
  ],
  
  images: {
    remotePatterns: [
      {
        protocol: 'https',
        hostname: '*.supabase.co',
      },
    ],
  },
}

export default nextConfig
```

---

## 🔒 Étape 5 — Sécurité & RBAC (optionnel)

### Ajouter au registre des tools

```typescript
// apps/admin/lib/registry.ts
import { TagIcon } from 'lucide-react'

export const toolsRegistry = {
  categories: {
    id: 'categories',
    name: 'Catégories',
    icon: TagIcon,
    route: '/categories',
    permissions: ['categories:read'],
    loader: () => import('@repo/tools-categories'),
  },
  // ... autres tools
}
```

### Middleware de sécurité

```typescript
// apps/admin/middleware.ts
import { NextResponse } from 'next/server'
import type { NextRequest } from 'next/server'
import { createServerClient } from '@repo/database'

export async function middleware(request: NextRequest) {
  const { pathname } = request.nextUrl

  // Protection des routes tools
  if (pathname.startsWith('/categories')) {
    const supabase = createServerClient()
    const { data: { session } } = await supabase.auth.getSession()
  
    if (!session) {
      return NextResponse.redirect(new URL('/login', request.url))
    }
  
    // Vérifier permissions (TODO: implémenter)
  }

  return NextResponse.next()
}
```

---

## 🧮 Étape 6 — Schéma Supabase (optionnel)

```sql
-- Créer la table categories
CREATE TABLE categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  slug TEXT UNIQUE NOT NULL,
  parent_id UUID REFERENCES categories(id),
  order_index INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- RLS
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public can view active categories"
ON categories FOR SELECT
USING (is_active = true);

CREATE POLICY "Admins can manage categories"
ON categories FOR ALL
USING (
  EXISTS (
    SELECT 1 FROM profiles
    WHERE id = auth.uid()
    AND role IN ('admin', 'owner')
  )
);
```

---

## 🧪 Étape 7 — Tests

### Tests unitaires (API)

```typescript
// packages/tools/categories/src/api/__tests__/categories.test.ts
import { describe, it, expect, vi } from 'vitest'
import { listCategories, createCategory } from '../categories'

vi.mock('@repo/database', () => ({
  createServerClient: () => ({
    from: vi.fn(() => ({
      select: vi.fn().mockReturnThis(),
      order: vi.fn().mockResolvedValue({
        data: [
          { id: '1', name: 'Hauts' },
          { id: '2', name: 'Bas' }
        ],
        error: null
      })
    }))
  })
}))

describe('categories API', () => {
  it('should list categories', async () => {
    const { data, error } = await listCategories()
  
    expect(error).toBeNull()
    expect(data).toHaveLength(2)
    expect(data[0].name).toBe('Hauts')
  })
})
```

---

## ✅ Checklist finale

Avant de considérer le tool terminé :

### Configuration

* [ ] Package créé dans `packages/tools/`
* [ ] `package.json` avec exports corrects
* [ ] Extensions `.tsx` pour fichiers JSX
* [ ] Package ajouté comme dépendance dans `apps/admin`
* [ ] Package dans `transpilePackages` de next.config.ts

### Code

* [ ] API pure dans `src/api/`
* [ ] Routes dans `src/routes/`
* [ ] Types définis dans `src/types.ts`
* [ ] Exports publics dans `src/index.ts`

### Integration

* [ ] Pages Next.js créées dans `apps/admin/app/(tools)/`
* [ ] Layout local avec navigation
* [ ] Symlink pnpm créé (`node_modules/@repo/xxx`)

### Tests & Qualité

* [ ] Type-check OK (`pnpm type-check`)
* [ ] Lint OK (`pnpm lint`)
* [ ] Tests unitaires écrits
* [ ] Build réussi (`pnpm build`)
* [ ] Test manuel dans le navigateur

### Sécurité (optionnel)

* [ ] Ajouté au registre des tools
* [ ] Permissions définies
* [ ] Middleware configuré
* [ ] RLS Supabase configuré

---

## 🐛 Troubleshooting

### Le composant ne s'affiche pas

1. **Vérifier le symlink** :

```powershell
Get-Item "apps/admin/node_modules/@repo/tools-xxx"
```

2. **Vérifier l'import** :

```tsx
// ✅ Correct
import { Component } from '@repo/tools-xxx'

// ❌ Incorrect
import { Component } from '@repo/tools-xxx/routes/Component'
```

3. **Nettoyer le cache** :

```bash
rm -rf apps/admin/.next
pnpm dev
```

### Erreur de compilation TypeScript

1. **Vérifier les types** :

```bash
cd packages/tools/xxx
pnpm type-check
```

2. **Vérifier les dépendances** :

```json
{
  "dependencies": {
    "@repo/ui": "workspace:*",
    "@repo/database": "workspace:*",
    "react": "^19.0.0"
  }
}
```

### Performance lente

1. **Vérifier transpilePackages** : Tous les `@repo/*` doivent être listés
2. **Activer le cache Turbo** :

```json
// turbo.json
{
  "pipeline": {
    "dev": {
      "cache": false,
      "persistent": true
    }
  }
}
```

---

## 🎓 Ressources

* [Next.js 15 Documentation](https://nextjs.org/docs)
* [pnpm Workspace](https://pnpm.io/workspaces)
* [TypeScript Project References](https://www.typescriptlang.org/docs/handbook/project-references.html)
* [Vitest](https://vitest.dev/)

---

## 📝 Changelog

* **2025-11-02** : Ajout de la section "Recette validée" avec POC test-tool
* **2025-10-29** : Version initiale du document

---

**Document validé et testé** ✅
