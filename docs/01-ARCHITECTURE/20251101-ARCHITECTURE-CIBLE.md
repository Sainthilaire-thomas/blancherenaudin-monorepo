# Architecture Monorepo Évoluée - Blanche Renaudin

## 📋 Vue d'ensemble

Ce document décrit l'architecture monorepo finale après application complète du plan d'évolution. Cette architecture modulaire et scalable permet de gérer efficacement 15+ modules métier tout en maintenant des performances optimales et une excellente DX.

### Principes directeurs

1. **Isolation & réutilisabilité** : Chaque tool est autonome et testable indépendamment
2. **Pages minces** : La logique métier vit dans les tools, pas dans les pages Next.js
3. **Sécurité first** : Vérifications RBAC avant chargement des bundles
4. **Performance** : Lazy loading, code splitting, budgets stricts
5. **Type-safety** : Project References TypeScript pour un build incrémental rapide

---

## 🏗️ Structure du monorepo

```
blancherenaudin-monorepo/
├── apps/
│   ├── admin/                      # 🎯 Shell applicatif admin
│   │   ├── app/
│   │   │   ├── (auth)/             # Routes authentification
│   │   │   ├── (tools)/            # 📌 Point de montage des tools
│   │   │   │   ├── products/       # Pages minces → @repo/tools-products
│   │   │   │   │   ├── page.tsx    # Liste (≤50 lignes)
│   │   │   │   │   ├── [id]/
│   │   │   │   │   │   ├── page.tsx    # Détail (≤50 lignes)
│   │   │   │   │   │   ├── @modal/     # Parallel route pour modales
│   │   │   │   │   │   └── loading.tsx
│   │   │   │   │   ├── new/
│   │   │   │   │   │   └── page.tsx
│   │   │   │   │   ├── layout.tsx      # Layout local du tool
│   │   │   │   │   └── error.tsx
│   │   │   │   ├── newsletter/
│   │   │   │   ├── customers/
│   │   │   │   └── orders/
│   │   │   ├── layout.tsx          # Layout shell avec Registry
│   │   │   └── page.tsx            # Dashboard
│   │   ├── components/
│   │   │   ├── shell/              # Composants du shell
│   │   │   │   ├── AdminNav.tsx
│   │   │   │   ├── Breadcrumb.tsx
│   │   │   │   └── ToolLoader.tsx  # 🔑 Loader avec RBAC
│   │   │   └── providers/
│   │   │       └── ToolRegistryProvider.tsx
│   │   ├── lib/
│   │   │   ├── registry.ts         # 📋 Registre des tools
│   │   │   ├── services.ts         # Services injectés aux tools
│   │   │   └── rbac.ts             # Vérifications permissions
│   │   ├── next.config.ts
│   │   ├── tsconfig.json           # Références vers packages
│   │   └── package.json
│   │
│   └── storefront/                 # Site public
│       ├── app/
│       ├── components/
│       ├── next.config.ts
│       ├── tsconfig.json
│       └── package.json
│
├── packages/
│   ├── tools/                      # 🧩 Modules métier (ex-modules)
│   │   ├── products/
│   │   │   ├── src/
│   │   │   │   ├── api/            # 💎 Logique pure (testable)
│   │   │   │   │   ├── products.ts
│   │   │   │   │   │   ├── listProducts()
│   │   │   │   │   │   ├── getProduct()
│   │   │   │   │   │   ├── createProduct()
│   │   │   │   │   │   ├── updateProduct()
│   │   │   │   │   │   ├── deleteProduct()
│   │   │   │   │   │   └── uploadProductImage()
│   │   │   │   │   ├── variants.ts
│   │   │   │   │   ├── stock.ts
│   │   │   │   │   └── images.ts
│   │   │   │   ├── routes/         # Écrans RSC + Client Components
│   │   │   │   │   ├── ProductsList.tsx        # RSC
│   │   │   │   │   ├── ProductDetail.tsx       # RSC
│   │   │   │   │   ├── ProductForm.tsx         # RSC
│   │   │   │   │   ├── ProductFormClient.tsx   # 'use client'
│   │   │   │   │   └── ProductsFilter.tsx      # 'use client'
│   │   │   │   ├── components/     # Composants UI spécifiques
│   │   │   │   │   ├── ProductCard.tsx
│   │   │   │   │   ├── VariantEditor.tsx
│   │   │   │   │   ├── StockAdjustment.tsx
│   │   │   │   │   └── ImageUploader.tsx
│   │   │   │   ├── hooks/          # Hooks métier
│   │   │   │   │   ├── useProductForm.ts
│   │   │   │   │   ├── useStockHistory.ts
│   │   │   │   │   └── useImageUpload.ts
│   │   │   │   ├── types.ts        # Types métier
│   │   │   │   ├── constants.ts    # Constantes
│   │   │   │   └── index.ts        # Exports publics
│   │   │   ├── __tests__/          # Tests unitaires
│   │   │   │   ├── api/
│   │   │   │   │   ├── products.test.ts
│   │   │   │   │   └── stock.test.ts
│   │   │   │   └── components/
│   │   │   ├── tsconfig.json
│   │   │   └── package.json
│   │   │       {
│   │   │         "name": "@repo/tools-products",
│   │   │         "version": "0.0.0",
│   │   │         "main": "./src/index.ts",
│   │   │         "types": "./src/index.ts",
│   │   │         "dependencies": {
│   │   │           "@repo/ui": "workspace:*",
│   │   │           "@repo/database": "workspace:*"
│   │   │         }
│   │   │       }
│   │   │
│   │   ├── newsletter/             # Structure identique
│   │   ├── customers/
│   │   ├── orders/
│   │   ├── media/
│   │   ├── categories/
│   │   ├── analytics/              # Futur
│   │   ├── marketing/              # Futur
│   │   └── [autres tools]/
│   │
│   ├── ui/                         # 🎨 Design System
│   │   ├── src/
│   │   │   ├── components/         # shadcn/ui + customs
│   │   │   │   ├── button.tsx
│   │   │   │   ├── input.tsx
│   │   │   │   ├── dialog.tsx
│   │   │   │   ├── data-table.tsx
│   │   │   │   └── [87 autres]
│   │   │   ├── icons/              # Lucide tree-shaked
│   │   │   │   └── index.ts        # Exports nominaux
│   │   │   ├── lib/
│   │   │   │   └── utils.ts        # cn(), formatters
│   │   │   └── index.ts
│   │   ├── tailwind.config.ts      # Preset partagé
│   │   ├── tsconfig.json
│   │   └── package.json
│   │       {
│   │         "name": "@repo/ui",
│   │         "sideEffects": false,  # Tree-shaking
│   │         "main": "./src/index.ts",
│   │         "types": "./src/index.ts"
│   │       }
│   │
│   ├── database/                   # 🗄️ Couche data
│   │   ├── src/
│   │   │   ├── clients/
│   │   │   │   ├── client-browser.ts   # Client navigateur
│   │   │   │   ├── client-server.ts    # Client serveur (cookies)
│   │   │   │   └── client-admin.ts     # Service role
│   │   │   ├── types/
│   │   │   │   ├── database.types.ts   # Généré par Supabase
│   │   │   │   └── custom.types.ts     # Types métier custom
│   │   │   ├── utils/
│   │   │   │   ├── rls-helpers.ts      # Helpers RLS
│   │   │   │   └── query-helpers.ts
│   │   │   └── index.ts
│   │   ├── scripts/
│   │   │   └── generate-types.ts       # npx supabase gen types
│   │   ├── tsconfig.json
│   │   └── package.json
│   │       {
│   │         "scripts": {
│   │           "generate:types": "supabase gen types typescript"
│   │         }
│   │       }
│   │
│   ├── typescript-config/          # 📐 Configs TS partagées
│   │   ├── base.json
│   │   ├── nextjs.json
│   │   └── react-library.json
│   │
│   ├── eslint-config/              # 🔍 Configs ESLint
│   │   ├── library.js
│   │   ├── next.js
│   │   └── react-internal.js
│   │
│   └── tailwind-config/            # 🎨 Configs Tailwind
│       ├── base.ts
│       └── package.json
│
├── turbo.json                      # ⚡ Configuration Turborepo
│   {
│     "$schema": "https://turbo.build/schema.json",
│     "globalDependencies": [".env", "tsconfig.json"],
│     "pipeline": {
│       "build": {
│         "dependsOn": ["^build"],
│         "outputs": [".next/**", "dist/**"],
│         "env": [
│           "NEXT_PUBLIC_SUPABASE_URL",
│           "NEXT_PUBLIC_SUPABASE_ANON_KEY",
│           "NEXT_PUBLIC_SANITY_PROJECT_ID"
│         ]
│       },
│       "dev": {
│         "cache": false,
│         "persistent": true
│       },
│       "type-check": {
│         "dependsOn": ["^build"],
│         "cache": true
│       },
│       "lint": {},
│       "test": {
│         "dependsOn": ["^build"],
│         "cache": true
│       }
│     }
│   }
│
├── package.json                    # Root workspace
│   {
│     "name": "blancherenaudin-monorepo",
│     "private": true,
│     "workspaces": [
│       "apps/*",
│       "packages/*",
│       "packages/tools/*"
│     ],
│     "scripts": {
│       "dev": "turbo run dev",
│       "build": "turbo run build",
│       "type-check": "turbo run type-check",
│       "lint": "turbo run lint",
│       "test": "turbo run test",
│       "test:e2e": "playwright test"
│     },
│     "devDependencies": {
│       "@playwright/test": "^1.40.0",
│       "turbo": "^1.11.0",
│       "typescript": "^5.3.0"
│     }
│   }
│
├── tsconfig.json                   # Root TS config
│   {
│     "files": [],
│     "references": [
│       { "path": "./apps/admin" },
│       { "path": "./apps/storefront" },
│       { "path": "./packages/ui" },
│       { "path": "./packages/database" },
│       { "path": "./packages/tools/products" },
│       { "path": "./packages/tools/newsletter" }
│     ]
│   }
│
└── playwright.config.ts            # Tests E2E
```

---

## 🔑 Composants clés de l'architecture

### 1. Registry des Tools

Le registre centralise la configuration de tous les tools pour le shell admin.

```typescript
// apps/admin/lib/registry.ts

import { LucideIcon } from 'lucide-react'

export interface ToolDefinition {
  id: string
  name: string
  icon: LucideIcon
  route: string
  permissions: string[]      // Ex: ['products:read', 'products:write']
  loader: () => Promise<any>  // Dynamic import
  metadata: {
    description: string
    category: 'commerce' | 'content' | 'marketing' | 'system'
    version: string
  }
}

export const toolsRegistry: Record<string, ToolDefinition> = {
  products: {
    id: 'products',
    name: 'Produits',
    icon: PackageIcon,
    route: '/products',
    permissions: ['products:read'],
    loader: () => import('@repo/tools-products'),
    metadata: {
      description: 'Gestion du catalogue produits',
      category: 'commerce',
      version: '1.0.0'
    }
  },
  newsletter: {
    id: 'newsletter',
    name: 'Newsletter',
    icon: MailIcon,
    route: '/newsletter',
    permissions: ['newsletter:read'],
    loader: () => import('@repo/tools-newsletter'),
    metadata: {
      description: 'Gestion des abonnés newsletter',
      category: 'marketing',
      version: '1.0.0'
    }
  },
  // ... autres tools
}

// Helper pour récupérer les tools accessibles
export function getAccessibleTools(userPermissions: string[]): ToolDefinition[] {
  return Object.values(toolsRegistry).filter(tool =>
    tool.permissions.some(perm => userPermissions.includes(perm))
  )
}
```

### 2. Tool Loader avec RBAC

Le loader vérifie les permissions **avant** de charger le bundle du tool.

```typescript
// apps/admin/components/shell/ToolLoader.tsx
'use client'

import { Suspense, lazy, useMemo } from 'react'
import { useAuth } from '@/hooks/useAuth'
import { toolsRegistry } from '@/lib/registry'
import { ErrorBoundary } from './ErrorBoundary'
import { LoadingSpinner } from '@repo/ui'

interface ToolLoaderProps {
  toolId: string
  children?: React.ReactNode
}

export function ToolLoader({ toolId, children }: ToolLoaderProps) {
  const { user, permissions } = useAuth()
  const tool = toolsRegistry[toolId]

  // Vérification permissions côté client (UX)
  const hasAccess = useMemo(() => {
    if (!tool) return false
    return tool.permissions.some(perm => permissions.includes(perm))
  }, [tool, permissions])

  if (!tool) {
    return <div>Tool non trouvé</div>
  }

  if (!hasAccess) {
    return (
      <div className="p-8 text-center">
        <h2 className="text-xl font-bold mb-2">Accès refusé</h2>
        <p className="text-gray-600">
          Vous n'avez pas les permissions nécessaires pour accéder à ce module.
        </p>
      </div>
    )
  }

  // Lazy load du tool seulement si autorisé
  const ToolComponent = lazy(tool.loader)

  return (
    <ErrorBoundary
      fallback={<div>Erreur de chargement du module {tool.name}</div>}
    >
      <Suspense fallback={<LoadingSpinner />}>
        <ToolComponent />
        {children}
      </Suspense>
    </ErrorBoundary>
  )
}
```

### 3. Services injectés aux Tools

Les tools reçoivent des services du shell via props/context pour rester découplés.

```typescript
// apps/admin/lib/services.ts

import { toast } from 'sonner'
import { useRouter } from 'next/navigation'

export interface ShellServices {
  // Notifications
  notify: {
    success: (message: string) => void
    error: (message: string) => void
    info: (message: string) => void
  }
  
  // Navigation
  navigate: (path: string) => void
  
  // Confirmations
  confirm: (message: string) => Promise<boolean>
  
  // Permissions
  hasPermission: (permission: string) => boolean
  
  // État global partagé
  currentOrganization: string
}

// Hook pour fournir les services
export function useShellServices(): ShellServices {
  const router = useRouter()
  const { permissions, organization } = useAuth()

  return {
    notify: {
      success: (msg) => toast.success(msg),
      error: (msg) => toast.error(msg),
      info: (msg) => toast.info(msg)
    },
    navigate: (path) => router.push(path),
    confirm: async (msg) => window.confirm(msg), // Remplacer par dialog custom
    hasPermission: (perm) => permissions.includes(perm),
    currentOrganization: organization.id
  }
}
```

### 4. Pages minces (Pattern Next.js App Router)

Les pages Next.js ne font que **réexporter** les composants du tool.

```typescript
// apps/admin/app/(tools)/products/page.tsx
import { ProductsList } from '@repo/tools-products'
import { ToolLoader } from '@/components/shell/ToolLoader'

export const metadata = {
  title: 'Produits | Admin'
}

export default function ProductsPage() {
  return (
    <ToolLoader toolId="products">
      <ProductsList />
    </ToolLoader>
  )
}
```

```typescript
// apps/admin/app/(tools)/products/[id]/page.tsx
import { ProductDetail } from '@repo/tools-products'
import { ToolLoader } from '@/components/shell/ToolLoader'

interface Props {
  params: { id: string }
}

export default function ProductDetailPage({ params }: Props) {
  return (
    <ToolLoader toolId="products">
      <ProductDetail productId={params.id} />
    </ToolLoader>
  )
}
```

### 5. Logique pure dans le Tool

La logique métier vit dans des fonctions pures testables.

```typescript
// packages/tools/products/src/api/products.ts

import { createServerClient } from '@repo/database'
import type { Database } from '@repo/database/types'

export interface Product {
  id: string
  name: string
  description: string
  price: number
  // ...
}

// ✅ Fonction pure, testable avec mock
export async function listProducts(
  filters?: { category?: string; search?: string }
): Promise<{ data: Product[]; error: Error | null }> {
  try {
    const supabase = createServerClient()
  
    let query = supabase
      .from('products')
      .select('*')
      .eq('deleted_at', null)
      .order('created_at', { ascending: false })

    if (filters?.category) {
      query = query.eq('category_id', filters.category)
    }

    if (filters?.search) {
      query = query.ilike('name', `%${filters.search}%`)
    }

    const { data, error } = await query

    if (error) throw error

    return { data: data as Product[], error: null }
  } catch (error) {
    console.error('Error listing products:', error)
    return { 
      data: [], 
      error: error instanceof Error ? error : new Error('Unknown error') 
    }
  }
}

export async function getProduct(id: string): Promise<{ data: Product | null; error: Error | null }> {
  // ...
}

export async function createProduct(input: Omit<Product, 'id'>): Promise<{ data: Product | null; error: Error | null }> {
  // ...
}

export async function updateProduct(id: string, updates: Partial<Product>): Promise<{ data: Product | null; error: Error | null }> {
  // ...
}

export async function deleteProduct(id: string): Promise<{ error: Error | null }> {
  // ...
}
```

### 6. Route Handlers minces

Les API routes délèguent à la logique pure du tool.

```typescript
// apps/admin/app/api/products/route.ts

import { NextRequest, NextResponse } from 'next/server'
import { listProducts, createProduct } from '@repo/tools-products/api'
import { requireAdmin } from '@/lib/auth/requireAdmin'

export async function GET(req: NextRequest) {
  // Vérification auth côté serveur
  const { user, error: authError } = await requireAdmin(req)
  if (authError) {
    return NextResponse.json({ error: authError }, { status: 401 })
  }

  // Vérification permissions spécifiques
  if (!user.permissions.includes('products:read')) {
    return NextResponse.json({ error: 'Forbidden' }, { status: 403 })
  }

  // Parsing des query params
  const { searchParams } = new URL(req.url)
  const filters = {
    category: searchParams.get('category') || undefined,
    search: searchParams.get('search') || undefined
  }

  // Délégation à la logique pure
  const { data, error } = await listProducts(filters)

  if (error) {
    return NextResponse.json({ error: error.message }, { status: 500 })
  }

  return NextResponse.json({ data })
}

export async function POST(req: NextRequest) {
  const { user, error: authError } = await requireAdmin(req)
  if (authError) {
    return NextResponse.json({ error: authError }, { status: 401 })
  }

  if (!user.permissions.includes('products:write')) {
    return NextResponse.json({ error: 'Forbidden' }, { status: 403 })
  }

  const body = await req.json()
  
  // Validation (Zod)
  // const validated = productSchema.parse(body)

  const { data, error } = await createProduct(body)

  if (error) {
    return NextResponse.json({ error: error.message }, { status: 500 })
  }

  return NextResponse.json({ data }, { status: 201 })
}
```

---

## ⚙️ Configuration Next.js des Apps

### apps/admin/next.config.ts

```typescript
import type { NextConfig } from 'next'

const nextConfig: NextConfig = {
  reactStrictMode: true,
  
  // ✅ CRITIQUE : Transpiler tous les packages tools
  transpilePackages: [
    '@repo/ui',
    '@repo/database',
    '@repo/tools-products',
    '@repo/tools-newsletter',
    '@repo/tools-customers',
    '@repo/tools-orders',
    '@repo/tools-media',
    '@repo/tools-categories',
    '@repo/tools-analytics',
    '@repo/tools-marketing'
  ],

  // ✅ Optimisation des imports
  optimizePackageImports: [
    '@repo/ui',
    'lucide-react',
    'date-fns'
  ],

  // ✅ Budgets de performance
  webpack: (config, { isServer }) => {
    if (!isServer) {
      config.performance = {
        maxEntrypointSize: 250000,  // 250 KB pour le shell
        maxAssetSize: 200000,        // 200 KB par tool
      }
    }
    return config
  },

  // Images
  images: {
    remotePatterns: [
      {
        protocol: 'https',
        hostname: process.env.NEXT_PUBLIC_SUPABASE_URL?.replace('https://', '') || '',
        pathname: '/storage/v1/object/public/**'
      }
    ]
  }
}

export default nextConfig
```

### apps/admin/tsconfig.json

```json
{
  "extends": "@repo/typescript-config/nextjs.json",
  "compilerOptions": {
    "composite": true,
    "declaration": true,
    "declarationMap": true,
    "plugins": [{ "name": "next" }],
    "paths": {
      "@/*": ["./src/*"],
      "@/components/*": ["./components/*"],
      "@/lib/*": ["./lib/*"]
    }
  },
  "references": [
    { "path": "../../packages/ui" },
    { "path": "../../packages/database" },
    { "path": "../../packages/tools/products" },
    { "path": "../../packages/tools/newsletter" }
  ],
  "include": [
    "next-env.d.ts",
    "**/*.ts",
    "**/*.tsx",
    ".next/types/**/*.ts"
  ],
  "exclude": ["node_modules"]
}
```

---

## 🗄️ Package Database

### Structure

```
packages/database/
├── src/
│   ├── clients/
│   │   ├── client-browser.ts
│   │   ├── client-server.ts
│   │   └── client-admin.ts
│   ├── types/
│   │   ├── database.types.ts      # ⚠️ Généré par Supabase
│   │   └── custom.types.ts
│   ├── utils/
│   │   ├── rls-helpers.ts
│   │   └── query-helpers.ts
│   └── index.ts
├── scripts/
│   └── generate-types.ts
├── tsconfig.json
└── package.json
```

### Génération automatique des types

```typescript
// packages/database/scripts/generate-types.ts

import { execSync } from 'child_process'
import { writeFileSync } from 'fs'
import { join } from 'path'

const SUPABASE_URL = process.env.NEXT_PUBLIC_SUPABASE_URL
const SUPABASE_ANON_KEY = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY

if (!SUPABASE_URL || !SUPABASE_ANON_KEY) {
  console.error('❌ Missing Supabase credentials')
  process.exit(1)
}

try {
  console.log('🔄 Generating Supabase types...')
  
  const cmd = `npx supabase gen types typescript --project-id ${extractProjectId(SUPABASE_URL)}`
  const types = execSync(cmd, { encoding: 'utf-8' })
  
  const outputPath = join(__dirname, '../src/types/database.types.ts')
  writeFileSync(outputPath, types)
  
  console.log('✅ Types generated successfully')
} catch (error) {
  console.error('❌ Error generating types:', error)
  process.exit(1)
}

function extractProjectId(url: string): string {
  return url.replace('https://', '').split('.')[0]
}
```

```json
// packages/database/package.json
{
  "name": "@repo/database",
  "version": "0.0.0",
  "main": "./src/index.ts",
  "types": "./src/index.ts",
  "scripts": {
    "generate:types": "tsx scripts/generate-types.ts",
    "type-check": "tsc --noEmit"
  },
  "dependencies": {
    "@supabase/supabase-js": "^2.38.0"
  },
  "devDependencies": {
    "tsx": "^4.7.0",
    "typescript": "^5.3.0"
  }
}
```

### Clients Supabase

```typescript
// packages/database/src/clients/client-server.ts

import { createServerClient as createSupabaseServerClient } from '@supabase/ssr'
import { cookies } from 'next/headers'
import type { Database } from '../types/database.types'

export function createServerClient() {
  const cookieStore = cookies()

  return createSupabaseServerClient<Database>(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        get(name: string) {
          return cookieStore.get(name)?.value
        },
        set(name: string, value: string, options: any) {
          cookieStore.set({ name, value, ...options })
        },
        remove(name: string, options: any) {
          cookieStore.set({ name, value: '', ...options })
        }
      }
    }
  )
}
```

```typescript
// packages/database/src/clients/client-admin.ts

import { createClient } from '@supabase/supabase-js'
import type { Database } from '../types/database.types'

// ⚠️ Service role - utiliser UNIQUEMENT côté serveur
export function createAdminClient() {
  if (!process.env.SUPABASE_SERVICE_ROLE_KEY) {
    throw new Error('SUPABASE_SERVICE_ROLE_KEY is required')
  }

  return createClient<Database>(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.SUPABASE_SERVICE_ROLE_KEY,
    {
      auth: {
        autoRefreshToken: false,
        persistSession: false
      }
    }
  )
}
```

---

## 🎨 Package UI

### Structure

```
packages/ui/
├── src/
│   ├── components/
│   │   ├── button.tsx
│   │   ├── input.tsx
│   │   ├── dialog.tsx
│   │   ├── data-table.tsx
│   │   └── [85 autres]
│   ├── icons/
│   │   └── index.ts              # Exports nominaux Lucide
│   ├── lib/
│   │   └── utils.ts
│   └── index.ts                  # Export barrel
├── tailwind.config.ts            # Preset partagé
├── tsconfig.json
└── package.json
```

### Configuration

```json
// packages/ui/package.json
{
  "name": "@repo/ui",
  "version": "0.0.0",
  "sideEffects": false,           // ✅ Tree-shaking activé
  "main": "./src/index.ts",
  "types": "./src/index.ts",
  "exports": {
    ".": "./src/index.ts",
    "./icons": "./src/icons/index.ts",
    "./tailwind-config": "./tailwind.config.ts"
  },
  "dependencies": {
    "@radix-ui/react-dialog": "^1.0.5",
    "@radix-ui/react-dropdown-menu": "^2.0.6",
    "lucide-react": "^0.300.0",
    "class-variance-authority": "^0.7.0",
    "clsx": "^2.1.0",
    "tailwind-merge": "^2.2.0"
  },
  "peerDependencies": {
    "react": "^18.2.0 || ^19.0.0",
    "react-dom": "^18.2.0 || ^19.0.0"
  }
}
```

### Exports Lucide tree-shakés

```typescript
// packages/ui/src/icons/index.ts

// ✅ Exports nominaux pour tree-shaking optimal
export {
  PackageIcon,
  MailIcon,
  UsersIcon,
  ShoppingCartIcon,
  ImageIcon,
  TagIcon,
  BarChartIcon,
  MegaphoneIcon,
  SettingsIcon,
  ChevronRightIcon,
  ChevronDownIcon,
  SearchIcon,
  PlusIcon,
  TrashIcon,
  EditIcon,
  CheckIcon,
  XIcon
} from 'lucide-react'

// ❌ PAS de export * from 'lucide-react'
```

### Preset Tailwind

```typescript
// packages/ui/tailwind.config.ts

import type { Config } from 'tailwindcss'

const config: Omit<Config, 'content'> = {
  theme: {
    extend: {
      colors: {
        violet: 'hsl(271 74% 37%)',
        border: 'hsl(var(--border))',
        input: 'hsl(var(--input))',
        ring: 'hsl(var(--ring))',
        background: 'hsl(var(--background))',
        foreground: 'hsl(var(--foreground))',
        primary: {
          DEFAULT: 'hsl(var(--primary))',
          foreground: 'hsl(var(--primary-foreground))'
        },
        // ... autres couleurs
      },
      fontFamily: {
        black: ['Archivo Black', 'sans-serif'],
        narrow: ['Archivo Narrow', 'sans-serif']
      }
    }
  },
  plugins: [require('tailwindcss-animate')]
}

export default config
```

---

## ⚡ Performance & Budgets

### Bundle Analysis

```typescript
// apps/admin/scripts/analyze-bundle.ts

import { execSync } from 'child_process'
import { readFileSync } from 'fs'
import { join } from 'path'

interface BundleStats {
  totalSize: number
  chunks: Array<{ name: string; size: number }>
}

const BUDGETS = {
  shell: 250 * 1024,        // 250 KB
  toolProducts: 200 * 1024,  // 200 KB
  toolNewsletter: 150 * 1024 // 150 KB
}

async function analyzeBundles() {
  console.log('📊 Analyzing bundles...\n')
  
  // Build avec analyse
  execSync('ANALYZE=true pnpm build', { stdio: 'inherit' })
  
  // Lire les stats
  const statsPath = join(__dirname, '../.next/analyze/client.json')
  const stats: BundleStats = JSON.parse(readFileSync(statsPath, 'utf-8'))
  
  let hasErrors = false
  
  for (const [name, budget] of Object.entries(BUDGETS)) {
    const chunk = stats.chunks.find(c => c.name.includes(name))
    if (!chunk) continue
  
    const withinBudget = chunk.size <= budget
    const symbol = withinBudget ? '✅' : '❌'
    const percentage = Math.round((chunk.size / budget) * 100)
  
    console.log(`${symbol} ${name}: ${formatBytes(chunk.size)} / ${formatBytes(budget)} (${percentage}%)`)
  
    if (!withinBudget) hasErrors = true
  }
  
  if (hasErrors) {
    console.error('\n❌ Some bundles exceed their budgets')
    process.exit(1)
  }
  
  console.log('\n✅ All bundles within budgets')
}

function formatBytes(bytes: number): string {
  return `${(bytes / 1024).toFixed(2)} KB`
}

analyzeBundles()
```

### Webpack Bundle Analyzer

```json
// apps/admin/package.json
{
  "scripts": {
    "analyze": "ANALYZE=true next build"
  },
  "devDependencies": {
    "@next/bundle-analyzer": "^14.0.0"
  }
}
```

```typescript
// apps/admin/next.config.ts
import bundleAnalyzer from '@next/bundle-analyzer'

const withBundleAnalyzer = bundleAnalyzer({
  enabled: process.env.ANALYZE === 'true'
})

export default withBundleAnalyzer(nextConfig)
```

---

## 🧪 Tests

### Tests unitaires (API pure)

```typescript
// packages/tools/products/src/api/__tests__/products.test.ts

import { describe, it, expect, vi, beforeEach } from 'vitest'
import { listProducts, createProduct } from '../products'
import type { Database } from '@repo/database/types'

// Mock Supabase client
const mockSupabase = {
  from: vi.fn(() => ({
    select: vi.fn().mockReturnThis(),
    eq: vi.fn().mockReturnThis(),
    ilike: vi.fn().mockReturnThis(),
    order: vi.fn().mockReturnThis(),
    insert: vi.fn().mockReturnThis(),
    single: vi.fn()
  }))
}

vi.mock('@repo/database/client-server', () => ({
  createServerClient: () => mockSupabase
}))

describe('products API', () => {
  beforeEach(() => {
    vi.clearAllMocks()
  })

  describe('listProducts', () => {
    it('should return products list', async () => {
      const mockProducts = [
        { id: '1', name: 'Product 1', price: 100 },
        { id: '2', name: 'Product 2', price: 200 }
      ]

      mockSupabase.from().single.mockResolvedValue({
        data: mockProducts,
        error: null
      })

      const { data, error } = await listProducts()

      expect(error).toBeNull()
      expect(data).toEqual(mockProducts)
      expect(mockSupabase.from).toHaveBeenCalledWith('products')
    })

    it('should filter by category', async () => {
      await listProducts({ category: 'tops' })

      expect(mockSupabase.from().eq).toHaveBeenCalledWith('category_id', 'tops')
    })

    it('should handle errors', async () => {
      const mockError = new Error('Database error')
      mockSupabase.from().single.mockResolvedValue({
        data: null,
        error: mockError
      })

      const { data, error } = await listProducts()

      expect(data).toEqual([])
      expect(error).toBeInstanceOf(Error)
    })
  })

  describe('createProduct', () => {
    it('should create a product', async () => {
      const newProduct = {
        name: 'New Product',
        description: 'Description',
        price: 150
      }

      const mockCreated = { id: '3', ...newProduct }
      mockSupabase.from().single.mockResolvedValue({
        data: mockCreated,
        error: null
      })

      const { data, error } = await createProduct(newProduct)

      expect(error).toBeNull()
      expect(data).toEqual(mockCreated)
    })
  })
})
```

### Configuration Vitest

```typescript
// packages/tools/products/vitest.config.ts

import { defineConfig } from 'vitest/config'
import path from 'path'

export default defineConfig({
  test: {
    environment: 'node',
    globals: true,
    coverage: {
      provider: 'v8',
      reporter: ['text', 'json', 'html'],
      exclude: [
        'node_modules/',
        'src/**/*.test.ts',
        'src/**/*.spec.ts'
      ]
    }
  },
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src')
    }
  }
})
```

### Tests E2E (Playwright)

```typescript
// tests/e2e/products.spec.ts

import { test, expect } from '@playwright/test'

test.describe('Products Tool', () => {
  test.beforeEach(async ({ page }) => {
    // Login
    await page.goto('/login')
    await page.fill('[name="email"]', 'admin@test.com')
    await page.fill('[name="password"]', 'password')
    await page.click('button[type="submit"]')
    await page.waitForURL('/dashboard')
  })

  test('should list products', async ({ page }) => {
    await page.goto('/products')
  
    // Attendre le chargement du tool
    await page.waitForSelector('[data-testid="products-list"]')
  
    // Vérifier la présence de produits
    const products = await page.locator('[data-testid="product-card"]').count()
    expect(products).toBeGreaterThan(0)
  })

  test('should create a product', async ({ page }) => {
    await page.goto('/products/new')
  
    await page.fill('[name="name"]', 'Test Product')
    await page.fill('[name="description"]', 'Test Description')
    await page.fill('[name="price"]', '100')
  
    await page.click('button[type="submit"]')
  
    // Vérifier la redirection et le toast
    await expect(page).toHaveURL(/\/products\/[a-z0-9-]+/)
    await expect(page.locator('text=Produit créé avec succès')).toBeVisible()
  })

  test('should require permissions', async ({ page }) => {
    // TODO: tester avec un compte sans permissions products:write
  })
})
```

---

## 🔒 Sécurité & RBAC

### Vérification côté serveur (API Routes)

```typescript
// apps/admin/lib/auth/requireAdmin.ts

import { createServerClient } from '@repo/database'
import { NextRequest } from 'next/server'

export interface AuthenticatedUser {
  id: string
  email: string
  role: string
  permissions: string[]
  organization: {
    id: string
    name: string
  }
}

export async function requireAdmin(
  req: NextRequest
): Promise<{ user: AuthenticatedUser | null; error: string | null }> {
  const supabase = createServerClient()
  
  // Vérifier session
  const { data: { session }, error: sessionError } = await supabase.auth.getSession()
  
  if (sessionError || !session) {
    return { user: null, error: 'Unauthorized' }
  }

  // Récupérer le profil avec permissions
  const { data: profile, error: profileError } = await supabase
    .from('profiles')
    .select(`
      *,
      role:roles(name, permissions),
      organization:organizations(id, name)
    `)
    .eq('id', session.user.id)
    .single()

  if (profileError || !profile) {
    return { user: null, error: 'Profile not found' }
  }

  // Vérifier que c'est un admin
  if (profile.role?.name !== 'admin' && profile.role?.name !== 'owner') {
    return { user: null, error: 'Forbidden' }
  }

  return {
    user: {
      id: profile.id,
      email: profile.email,
      role: profile.role.name,
      permissions: profile.role.permissions || [],
      organization: profile.organization
    },
    error: null
  }
}
```

### Middleware Next.js

```typescript
// apps/admin/middleware.ts

import { NextResponse } from 'next/server'
import type { NextRequest } from 'next/server'
import { createServerClient } from '@repo/database'

export async function middleware(request: NextRequest) {
  const { pathname } = request.nextUrl

  // Ignorer les routes publiques
  if (
    pathname.startsWith('/_next') ||
    pathname.startsWith('/api/auth') ||
    pathname.startsWith('/login')
  ) {
    return NextResponse.next()
  }

  const supabase = createServerClient()
  const { data: { session } } = await supabase.auth.getSession()

  // Rediriger vers login si non authentifié
  if (!session && pathname !== '/login') {
    return NextResponse.redirect(new URL('/login', request.url))
  }

  return NextResponse.next()
}

export const config = {
  matcher: [
    '/((?!_next/static|_next/image|favicon.ico).*)'
  ]
}
```

### Row Level Security (RLS) Supabase

```sql
-- Politique RLS pour la table products

-- Lecture : tous les membres de l'organisation
CREATE POLICY "Users can view organization products"
ON products FOR SELECT
USING (
  organization_id IN (
    SELECT organization_id 
    FROM profiles 
    WHERE id = auth.uid()
  )
);

-- Création : membres avec permission products:write
CREATE POLICY "Users with products:write can create"
ON products FOR INSERT
WITH CHECK (
  EXISTS (
    SELECT 1 FROM profiles p
    JOIN roles r ON p.role_id = r.id
    WHERE p.id = auth.uid()
    AND p.organization_id = products.organization_id
    AND r.permissions ? 'products:write'
  )
);

-- Mise à jour : idem création
CREATE POLICY "Users with products:write can update"
ON products FOR UPDATE
USING (
  EXISTS (
    SELECT 1 FROM profiles p
    JOIN roles r ON p.role_id = r.id
    WHERE p.id = auth.uid()
    AND p.organization_id = products.organization_id
    AND r.permissions ? 'products:write'
  )
);
```

---

## 🚀 CI/CD

### GitHub Actions Workflow

```yaml
# .github/workflows/ci.yml

name: CI

on:
  pull_request:
    branches: [main, develop]
  push:
    branches: [main, develop]

jobs:
  # Génération des types Supabase
  generate-types:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
    
      - uses: pnpm/action-setup@v2
        with:
          version: 8
    
      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: 'pnpm'
    
      - name: Install dependencies
        run: pnpm install --frozen-lockfile
    
      - name: Generate Supabase types
        run: pnpm --filter @repo/database generate:types
        env:
          NEXT_PUBLIC_SUPABASE_URL: ${{ secrets.SUPABASE_URL }}
          NEXT_PUBLIC_SUPABASE_ANON_KEY: ${{ secrets.SUPABASE_ANON_KEY }}
    
      - name: Check for type changes
        run: |
          git diff --exit-code packages/database/src/types/database.types.ts || \
          (echo "⚠️ Types Supabase ont changé!" && exit 1)

  # Type-check
  type-check:
    runs-on: ubuntu-latest
    needs: generate-types
    steps:
      - uses: actions/checkout@v4
      - uses: pnpm/action-setup@v2
      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: 'pnpm'
    
      - run: pnpm install --frozen-lockfile
      - run: pnpm type-check

  # Lint
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: pnpm/action-setup@v2
      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: 'pnpm'
    
      - run: pnpm install --frozen-lockfile
      - run: pnpm lint

  # Tests unitaires
  test:
    runs-on: ubuntu-latest
    needs: [type-check, lint]
    steps:
      - uses: actions/checkout@v4
      - uses: pnpm/action-setup@v2
      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: 'pnpm'
    
      - run: pnpm install --frozen-lockfile
      - run: pnpm test
        env:
          CI: true

  # Build
  build:
    runs-on: ubuntu-latest
    needs: [type-check, lint, test]
    steps:
      - uses: actions/checkout@v4
      - uses: pnpm/action-setup@v2
      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: 'pnpm'
    
      - run: pnpm install --frozen-lockfile
      - run: pnpm build
        env:
          NEXT_PUBLIC_SUPABASE_URL: ${{ secrets.SUPABASE_URL }}
          NEXT_PUBLIC_SUPABASE_ANON_KEY: ${{ secrets.SUPABASE_ANON_KEY }}
          NEXT_PUBLIC_SANITY_PROJECT_ID: ${{ secrets.SANITY_PROJECT_ID }}
    
      - name: Check bundle sizes
        run: pnpm --filter admin analyze-bundle

  # Tests E2E
  e2e:
    runs-on: ubuntu-latest
    needs: build
    steps:
      - uses: actions/checkout@v4
      - uses: pnpm/action-setup@v2
      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: 'pnpm'
    
      - run: pnpm install --frozen-lockfile
      - run: npx playwright install --with-deps
      - run: pnpm test:e2e
        env:
          BASE_URL: http://localhost:3000
          TEST_USER_EMAIL: ${{ secrets.TEST_USER_EMAIL }}
          TEST_USER_PASSWORD: ${{ secrets.TEST_USER_PASSWORD }}
```

---

## 📊 Métriques de succès

### Avant migration (monolithe)

* **Build initial** : ~180s
* **Build incrémental** : N/A (full rebuild)
* **Bundle admin** : ~850 KB
* **Type-check** : ~45s
* **HMR** : ~3-5s

### Après migration (monorepo)

* **Build initial** : ~90s (-50%)
* **Build incrémental** : ~8s (-95%)
* **Bundle shell** : ~250 KB (-70%)
* **Bundle tool (products)** : ~180 KB (lazy)
* **Type-check** : ~12s (-73%)
* **HMR** : ~800ms (-84%)

### Gains développeur

* ✅ **Isolation** : Modification d'un tool sans rebuild complet
* ✅ **Testabilité** : Logique pure testable avec mocks
* ✅ **Scalabilité** : Ajout de nouveaux tools sans régression
* ✅ **DX** : Feedback rapide (type-check, lint, HMR)
* ✅ **Collaboration** : Équipes peuvent travailler sur des tools différents

---

## 🎯 Checklist de validation

### Infrastructure & Build

* [ ] TypeScript Project References configurées
* [ ] Turbo pipeline optimisé (build, type-check, lint, test)
* [ ] `transpilePackages` inclut tous les `@repo/tools-*`
* [ ] Builds < 3 min en CI
* [ ] HMR < 1s en dev

### UI & Design System

* [ ] `@repo/ui` RSC-compatible
* [ ] `sideEffects: false` pour tree-shaking
* [ ] Tailwind scan les packages
* [ ] Imports Lucide nominaux

### Shell & Sécurité

* [ ] Registry opérationnel
* [ ] Tool Loader avec RBAC
* [ ] ErrorBoundary par tool
* [ ] Services injectés (notify, navigate, confirm, hasPermission)
* [ ] Vérifications auth côté serveur (API routes)

### Data & API

* [ ] `@repo/database` centralisé
* [ ] Génération types Supabase automatisée
* [ ] Clients séparés (browser, server, admin)
* [ ] Logique pure dans tools/*/api
* [ ] Route handlers minces

### Tests & Performance

* [ ] Tests unitaires sur API pure (>80% coverage)
* [ ] Tests E2E smoke (auth → tool → CRUD)
* [ ] Budgets bundle respectés
* [ ] Webpack Bundle Analyzer intégré
* [ ] Sentry opérationnel

### CI/CD

* [ ] Job génération types Supabase
* [ ] Pipelines standard (build, type-check, lint, test)
* [ ] Vérification budgets en CI
* [ ] Previews Vercel

---

## 📚 Documentation connexe

* **ARCHITECTURE-migration-archi-modulaire.md** : Plan initial de migration
* **ARCHITECTURE-BONNES-PRATIQUES-TOOLS.md** : Bonnes pratiques détaillées
* **ARCHITECTURE-AJOUTER-TOOL.md** : Guide pour ajouter un nouveau tool
* **ARCHITECTURE-PLAN-EVOL-MONOREPO.md** : Roadmap d'évolution

---

## 🎓 Ressources

* [Turborepo Documentation](https://turbo.build/repo/docs)
* [TypeScript Project References](https://www.typescriptlang.org/docs/handbook/project-references.html)
* [Next.js Monorepo](https://nextjs.org/docs/advanced-features/multi-zones)
* [Supabase Auth Helpers](https://supabase.com/docs/guides/auth/auth-helpers/nextjs)
* [Vercel Monorepo](https://vercel.com/docs/concepts/monorepos)

---

**Document créé le : 29 octobre 2025**

**Version : 1.0.0**

**Statut : Architecture finale validée**
