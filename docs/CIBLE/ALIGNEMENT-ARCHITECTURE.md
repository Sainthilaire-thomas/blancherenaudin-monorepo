# Plan d'alignement Architecture : État Actuel → Architecture Cible

## 📊 Analyse des écarts

### ⚠️ CLARIFICATION IMPORTANTE : Storefront vs Admin

**Principe fondamental :**

```
┌─────────────────────────────────────────────────────────────┐
│  apps/storefront/                                          │
│  ├── lib/products.ts      ← ✅ NE PAS TOUCHER              │
│  ├── components/          ← ✅ NE PAS TOUCHER              │
│  │   └── products/                                          │
│  │       ├── ProductImage.tsx                              │
│  │       ├── ProductCard.tsx                               │
│  │       └── ProductGrid.tsx                               │
│  └── app/product/[id]/   ← ✅ Fonctionne bien             │
│                                                              │
│  Ce code gère l'AFFICHAGE PUBLIC (lecture seule)           │
│  → Prix formatés, images optimisées, SEO                    │
│  → Ne touche JAMAIS au stock ni aux variants               │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│  packages/tools/products/  (🆕 À CRÉER)                    │
│  ├── api/                                                   │
│  │   ├── products.ts     ← CRUD complet (create/update)    │
│  │   ├── variants.ts     ← Gestion variantes               │
│  │   ├── stock.ts        ← Ajustements stock               │
│  │   └── images.ts       ← Upload & traitement images      │
│  └── routes/                                                │
│      └── ProductForm.tsx ← Interface admin                 │
│                                                              │
│  Ce code gère la GESTION ADMIN (écriture)                  │
│  → Utilisé UNIQUEMENT dans apps/admin                      │
│  → Jamais importé par le storefront                        │
└─────────────────────────────────────────────────────────────┘
```

**Règle d'or :**

* 🚫 Le storefront **ne doit jamais** importer `@repo/tools-products`
* ✅ Le storefront garde ses propres helpers (`lib/products.ts`, `lib/product-helpers.ts`)
* ✅ Les deux peuvent partager `@repo/database` pour les types et queries

---

### ✅ Ce qui est DÉJÀ en place

#### 1. **Structure Monorepo de base**

* ✅ Turborepo configuré (`turbo.json`)
* ✅ Workspace pnpm (`pnpm-workspace.yaml`)
* ✅ Apps séparées (`apps/admin`, `apps/storefront`)
* ✅ Packages partagés (`packages/*`)

#### 2. **Packages existants**

* ✅ `@repo/ui` - Design system complet (shadcn/ui)
* ✅ `@repo/database` - Clients Supabase + types
* ✅ `@repo/email` - Templates email React
* ✅ `@repo/sanity` - Schémas + queries
* ✅ `@repo/newsletter` - Logique newsletter
* ✅ `@repo/shipping` - Calcul frais de port
* ✅ `@repo/utils` - Utilitaires partagés

#### 3. **Apps fonctionnelles**

* ✅ Admin shell avec route dynamique `[module]/[[...slug]]`
* ✅ Storefront opérationnel
* ✅ Middleware auth en place

---

### ⚠️ ÉCARTS CRITIQUES à corriger

#### 1. **Nomenclature et organisation**

**État actuel :**

```
packages/
├── database/
├── email/
├── newsletter/      ← ⚠️ Devrait être dans tools/
├── sanity/
├── shipping/        ← ⚠️ Devrait être dans tools/
├── ui/
└── utils/
```

**Architecture cible :**

```
packages/
├── tools/           ← 🆕 MANQUANT !
│   ├── products/
│   ├── newsletter/  ← À déplacer
│   ├── customers/   ← À créer
│   ├── orders/      ← À créer
│   ├── media/       ← À créer
│   └── analytics/   ← À créer
├── database/        ← ✅ OK
├── email/           ← ✅ OK
├── sanity/          ← ✅ OK
├── ui/              ← ✅ OK
└── utils/           ← ✅ OK
```

**Impact :** 🔴 CRITIQUE - Toute la structure "tools" est absente

---

#### 2. **Admin Shell - Pas de Registry ni Loader**

**État actuel :**

```
apps/admin/app/(dashboard)/[module]/[[...slug]]/page.tsx
```

→ Route catch-all dynamique SANS registry ni RBAC

**Architecture cible :**

```typescript
// apps/admin/lib/registry.ts
export const toolsRegistry = {
  products: {
    id: 'products',
    permissions: ['products:read'],
    loader: () => import('@repo/tools-products')
  }
}

// apps/admin/components/shell/ToolLoader.tsx
// Vérifie permissions AVANT lazy load
```

**Impact :** 🔴 CRITIQUE - Pas de sécurité RBAC, pas de lazy loading optimisé

---

#### 3. **Pages admin non structurées**

**État actuel :**

```
apps/admin/app/(dashboard)/[module]/[[...slug]]/page.tsx
```

→ UNE SEULE page catch-all pour TOUS les modules

**Architecture cible :**

```
apps/admin/app/(tools)/
├── products/
│   ├── page.tsx          # ≤50 lignes
│   ├── [id]/
│   │   ├── page.tsx
│   │   └── @modal/       # Parallel routes
│   ├── layout.tsx        # Layout local
│   └── loading.tsx
├── newsletter/
│   └── page.tsx
└── customers/
    └── page.tsx
```

**Impact :** 🟡 IMPORTANT - Difficile de maintenir, pas de loading states spécifiques

---

#### 4. **Logique métier admin absente**

**État actuel :**

```
# ❌ Pas de package tools/products
# La logique admin est probablement dispersée dans l'ancien monolithe
```

**Storefront (À NE PAS TOUCHER) :**

```
apps/storefront/lib/
├── products.ts           ← ✅ OK - Helpers affichage public
├── product-helpers.ts    ← ✅ OK - Formatage prix, etc.
└── types.ts              ← ✅ OK - Types affichage
```

**Architecture cible (admin uniquement) :**

```
packages/tools/products/src/
├── api/                  ← CRUD admin (create, update, delete)
│   ├── products.ts       ← Gestion catalogue
│   ├── variants.ts       ← Gestion variantes
│   ├── stock.ts          ← Gestion stock
│   └── images.ts         ← Upload images
├── routes/               ← Écrans admin
│   ├── ProductsList.tsx
│   ├── ProductForm.tsx
│   └── ProductDetail.tsx
└── components/           ← UI admin
    ├── VariantEditor.tsx
    ├── StockManager.tsx
    └── ImageUploader.tsx
```

**Impact :** 🟡 MOYEN - Le storefront fonctionne, on touche UNIQUEMENT à l'admin

**Note importante :**

* ✅ `apps/storefront/lib/products.ts` reste tel quel
* ✅ Les composants storefront (`ProductImage.tsx`, `ProductCard.tsx`) ne bougent pas
* 🎯 On crée `@repo/tools-products` UNIQUEMENT pour l'interface admin

---

#### 5. **Manque de configurations partagées**

**État actuel :**

* ❌ Pas de `packages/typescript-config/`
* ❌ Pas de `packages/eslint-config/`
* ❌ Pas de `packages/tailwind-config/`

**Architecture cible :**

```
packages/
├── typescript-config/
│   ├── base.json
│   ├── nextjs.json
│   └── react-library.json
├── eslint-config/
│   ├── library.js
│   └── next.js
└── tailwind-config/
    └── base.ts
```

**Impact :** 🟡 IMPORTANT - Duplication de config, maintenance difficile

---

#### 6. **Project References TypeScript non configurées**

**État actuel :**

```json
// tsconfig.base.json
{
  "compilerOptions": { ... }
  // ❌ PAS de "composite": true
  // ❌ PAS de "references": []
}
```

**Architecture cible :**

```json
// Root tsconfig.json
{
  "files": [],
  "references": [
    { "path": "./apps/admin" },
    { "path": "./packages/ui" },
    { "path": "./packages/tools/products" }
  ]
}

// packages/tools/products/tsconfig.json
{
  "extends": "@repo/typescript-config/react-library.json",
  "compilerOptions": {
    "composite": true,
    "declaration": true
  }
}
```

**Impact :** 🔴 CRITIQUE - Pas de build incrémental, lenteur

---

#### 7. **transpilePackages manquant dans next.config**

**État actuel :**

```typescript
// apps/admin/next.config.ts
const nextConfig = {
  // ❌ Pas de transpilePackages
}
```

**Architecture cible :**

```typescript
const nextConfig = {
  transpilePackages: [
    '@repo/ui',
    '@repo/database',
    '@repo/tools-products',
    '@repo/tools-newsletter'
  ]
}
```

**Impact :** 🔴 CRITIQUE - Erreurs de compilation des packages

---

#### 8. **Pas de tests configurés**

**État actuel :**

* ❌ Pas de Vitest configuré
* ❌ Pas de Playwright
* ❌ Pas de tests unitaires
* ❌ Pas de tests E2E

**Architecture cible :**

```
packages/tools/products/
├── src/api/__tests__/
│   └── products.test.ts
└── vitest.config.ts

tests/
└── e2e/
    └── products.spec.ts
```

**Impact :** 🟡 IMPORTANT - Pas de confiance dans les refactors

---

#### 9. **Pas de budgets de performance**

**État actuel :**

* ❌ Pas de bundle analyzer
* ❌ Pas de budgets définis
* ❌ Pas de monitoring taille des bundles

**Architecture cible :**

```typescript
// apps/admin/next.config.ts
webpack: (config) => {
  config.performance = {
    maxEntrypointSize: 250000,
    maxAssetSize: 200000
  }
}

// scripts/analyze-bundle.ts
const BUDGETS = {
  shell: 250 * 1024,
  toolProducts: 200 * 1024
}
```

**Impact :** 🟡 IMPORTANT - Risque de bundle bloat

---

#### 10. **Services du shell non injectés**

**État actuel :**

* ❌ Pas de services centralisés (notify, navigate, confirm)
* ❌ Couplage fort entre modules et shell

**Architecture cible :**

```typescript
// apps/admin/lib/services.ts
export interface ShellServices {
  notify: { success, error, info }
  navigate: (path) => void
  confirm: (msg) => Promise<boolean>
  hasPermission: (perm) => boolean
}

// Injection dans les tools
<ToolComponent services={shellServices} />
```

**Impact :** 🟡 IMPORTANT - Couplage fort, pas testable

---

## 🎯 Plan d'alignement par phases

### **PHASE 1 : Fondations (1-2 jours)** 🔴 CRITIQUE

#### 1.1 Créer la structure `packages/tools/`

```bash
# Créer dossiers
mkdir -p packages/tools/products
mkdir -p packages/tools/newsletter
mkdir -p packages/tools/customers
mkdir -p packages/tools/orders
mkdir -p packages/tools/media

# Déplacer newsletter existant
mv packages/newsletter packages/tools/newsletter

# Créer package.json pour chaque tool
```

**Fichiers à créer :**

* `packages/tools/products/package.json`
* `packages/tools/products/tsconfig.json`
* `packages/tools/products/src/index.ts`

**Script d'automatisation :**

```powershell
# scripts/create-tools-structure.ps1
$tools = @('products', 'newsletter', 'customers', 'orders', 'media')

foreach ($tool in $tools) {
  New-Item -ItemType Directory -Force "packages/tools/$tool/src"
  
  # Créer package.json
  @"
{
  "name": "@repo/tools-$tool",
  "version": "0.0.0",
  "main": "./src/index.ts",
  "types": "./src/index.ts"
}
"@ | Out-File "packages/tools/$tool/package.json"
  
  # Créer tsconfig.json
  @"
{
  "extends": "@repo/typescript-config/react-library.json",
  "compilerOptions": {
    "composite": true,
    "declaration": true,
    "outDir": "dist"
  },
  "include": ["src"]
}
"@ | Out-File "packages/tools/$tool/tsconfig.json"
  
  # Créer index.ts
  "export {}" | Out-File "packages/tools/$tool/src/index.ts"
}
```

---

#### 1.2 Créer packages de configuration partagés

```bash
mkdir -p packages/typescript-config
mkdir -p packages/eslint-config
mkdir -p packages/tailwind-config
```

**Fichiers à créer :**

```json
// packages/typescript-config/base.json
{
  "compilerOptions": {
    "target": "ES2020",
    "lib": ["ES2020", "DOM"],
    "module": "ESNext",
    "moduleResolution": "bundler",
    "resolveJsonModule": true,
    "jsx": "react-jsx",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "noEmit": true,
    "incremental": true
  }
}
```

```json
// packages/typescript-config/nextjs.json
{
  "extends": "./base.json",
  "compilerOptions": {
    "plugins": [{ "name": "next" }],
    "paths": {
      "@/*": ["./src/*"]
    }
  },
  "include": ["next-env.d.ts", "**/*.ts", "**/*.tsx", ".next/types/**/*.ts"],
  "exclude": ["node_modules"]
}
```

```json
// packages/typescript-config/react-library.json
{
  "extends": "./base.json",
  "compilerOptions": {
    "composite": true,
    "declaration": true,
    "declarationMap": true,
    "outDir": "dist"
  }
}
```

```json
// packages/typescript-config/package.json
{
  "name": "@repo/typescript-config",
  "version": "0.0.0",
  "files": ["*.json"]
}
```

---

#### 1.3 Configurer TypeScript Project References

**Modifier `tsconfig.base.json` (root) :**

```json
{
  "files": [],
  "references": [
    { "path": "./apps/admin" },
    { "path": "./apps/storefront" },
    { "path": "./packages/ui" },
    { "path": "./packages/database" },
    { "path": "./packages/tools/products" },
    { "path": "./packages/tools/newsletter" }
  ]
}
```

**Modifier `apps/admin/tsconfig.json` :**

```json
{
  "extends": "@repo/typescript-config/nextjs.json",
  "compilerOptions": {
    "composite": true,
    "declaration": true
  },
  "references": [
    { "path": "../../packages/ui" },
    { "path": "../../packages/database" },
    { "path": "../../packages/tools/products" }
  ]
}
```

**Modifier chaque `packages/*/tsconfig.json` :**

```json
{
  "extends": "@repo/typescript-config/react-library.json",
  "compilerOptions": {
    "composite": true,
    "declaration": true,
    "outDir": "dist"
  },
  "include": ["src"]
}
```

---

#### 1.4 Configurer transpilePackages dans Next.js

**Modifier `apps/admin/next.config.ts` :**

```typescript
import type { NextConfig } from 'next'

const nextConfig: NextConfig = {
  reactStrictMode: true,
  
  // ✅ CRITIQUE : Transpiler tous les packages
  transpilePackages: [
    '@repo/ui',
    '@repo/database',
    '@repo/email',
    '@repo/sanity',
    '@repo/newsletter',
    '@repo/shipping',
    '@repo/utils',
    '@repo/tools-products',
    '@repo/tools-newsletter',
    '@repo/tools-customers',
    '@repo/tools-orders',
    '@repo/tools-media'
  ],

  // Optimisation imports
  optimizePackageImports: [
    '@repo/ui',
    'lucide-react',
    'date-fns'
  ]
}

export default nextConfig
```

**Faire de même pour `apps/storefront/next.config.ts`**

---

#### 1.5 Mettre à jour pnpm-workspace.yaml

```yaml
packages:
  - 'apps/*'
  - 'packages/*'
  - 'packages/tools/*'  # ✅ Ajouter cette ligne
```

---

#### 1.6 Tester le build

```bash
# Nettoyer
pnpm clean

# Installer
pnpm install

# Type-check incrémental
pnpm -r type-check

# Build incrémental
pnpm build
```

**Gate PHASE 1 :** ✅ Build passe en <3min, pas d'erreurs TS

---

### **PHASE 2 : Shell Admin & Registry (2-3 jours)** 🔴 CRITIQUE

#### 2.1 Créer le registre des tools

```typescript
// apps/admin/lib/registry.ts

import { PackageIcon, MailIcon, UsersIcon, ShoppingCartIcon, ImageIcon } from 'lucide-react'
import type { LucideIcon } from 'lucide-react'

export interface ToolDefinition {
  id: string
  name: string
  icon: LucideIcon
  route: string
  permissions: string[]
  loader: () => Promise<any>
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
  customers: {
    id: 'customers',
    name: 'Clients',
    icon: UsersIcon,
    route: '/customers',
    permissions: ['customers:read'],
    loader: () => import('@repo/tools-customers'),
    metadata: {
      description: 'Gestion des clients',
      category: 'commerce',
      version: '1.0.0'
    }
  },
  orders: {
    id: 'orders',
    name: 'Commandes',
    icon: ShoppingCartIcon,
    route: '/orders',
    permissions: ['orders:read'],
    loader: () => import('@repo/tools-orders'),
    metadata: {
      description: 'Gestion des commandes',
      category: 'commerce',
      version: '1.0.0'
    }
  },
  media: {
    id: 'media',
    name: 'Médias',
    icon: ImageIcon,
    route: '/media',
    permissions: ['media:read'],
    loader: () => import('@repo/tools-media'),
    metadata: {
      description: 'Médiathèque',
      category: 'content',
      version: '1.0.0'
    }
  }
}

// Helper pour récupérer les tools accessibles
export function getAccessibleTools(userPermissions: string[]): ToolDefinition[] {
  return Object.values(toolsRegistry).filter(tool =>
    tool.permissions.some(perm => userPermissions.includes(perm))
  )
}

// Helper pour récupérer un tool
export function getTool(id: string): ToolDefinition | undefined {
  return toolsRegistry[id]
}
```

---

#### 2.2 Créer les services du shell

```typescript
// apps/admin/lib/services.ts

import { toast } from 'sonner'
import { useRouter } from 'next/navigation'

export interface ShellServices {
  notify: {
    success: (message: string) => void
    error: (message: string) => void
    info: (message: string) => void
    warning: (message: string) => void
  }
  navigate: (path: string) => void
  confirm: (message: string, title?: string) => Promise<boolean>
  hasPermission: (permission: string) => boolean
  currentOrganization: string
}

// Hook pour fournir les services
export function useShellServices(): ShellServices {
  const router = useRouter()
  // TODO: récupérer permissions et org depuis auth
  const permissions: string[] = []
  const organizationId = ''

  return {
    notify: {
      success: (msg) => toast.success(msg),
      error: (msg) => toast.error(msg),
      info: (msg) => toast.info(msg),
      warning: (msg) => toast.warning(msg)
    },
    navigate: (path) => router.push(path),
    confirm: async (msg, title) => {
      // TODO: remplacer par dialog custom
      return window.confirm(title ? `${title}\n\n${msg}` : msg)
    },
    hasPermission: (perm) => permissions.includes(perm),
    currentOrganization: organizationId
  }
}
```

---

#### 2.3 Créer le Tool Loader avec RBAC

```typescript
// apps/admin/components/shell/ToolLoader.tsx
'use client'

import { Suspense, lazy, useMemo, type ComponentType } from 'react'
import { toolsRegistry } from '@/lib/registry'
import { useShellServices } from '@/lib/services'
import { ErrorBoundary } from './ErrorBoundary'

interface ToolLoaderProps {
  toolId: string
  children?: React.ReactNode
}

export function ToolLoader({ toolId, children }: ToolLoaderProps) {
  const services = useShellServices()
  const tool = toolsRegistry[toolId]

  // Vérification permissions
  const hasAccess = useMemo(() => {
    if (!tool) return false
    return tool.permissions.some(perm => services.hasPermission(perm))
  }, [tool, services])

  if (!tool) {
    return (
      <div className="p-8 text-center">
        <h2 className="text-xl font-bold mb-2">Module non trouvé</h2>
        <p className="text-gray-600">Le module "{toolId}" n'existe pas.</p>
      </div>
    )
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
  const ToolComponent = lazy(tool.loader) as ComponentType<any>

  return (
    <ErrorBoundary
      fallback={
        <div className="p-8 text-center text-red-600">
          Erreur de chargement du module {tool.name}
        </div>
      }
    >
      <Suspense
        fallback={
          <div className="p-8 text-center">
            <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-gray-900 mx-auto" />
            <p className="mt-4 text-gray-600">Chargement de {tool.name}...</p>
          </div>
        }
      >
        <ToolComponent services={services} />
        {children}
      </Suspense>
    </ErrorBoundary>
  )
}
```

---

#### 2.4 Créer ErrorBoundary

```typescript
// apps/admin/components/shell/ErrorBoundary.tsx
'use client'

import { Component, type ReactNode } from 'react'

interface Props {
  children: ReactNode
  fallback: ReactNode
}

interface State {
  hasError: boolean
  error?: Error
}

export class ErrorBoundary extends Component<Props, State> {
  constructor(props: Props) {
    super(props)
    this.state = { hasError: false }
  }

  static getDerivedStateFromError(error: Error): State {
    return { hasError: true, error }
  }

  componentDidCatch(error: Error, errorInfo: any) {
    console.error('ErrorBoundary caught:', error, errorInfo)
    // TODO: Envoyer à Sentry
  }

  render() {
    if (this.state.hasError) {
      return this.props.fallback
    }

    return this.props.children
  }
}
```

---

#### 2.5 Refactoriser les routes admin

**Supprimer :**

```
apps/admin/app/(dashboard)/[module]/[[...slug]]/page.tsx
```

**Créer structure (tools) :**

```
apps/admin/app/(tools)/
├── products/
│   ├── page.tsx
│   ├── [id]/
│   │   └── page.tsx
│   ├── new/
│   │   └── page.tsx
│   └── layout.tsx
├── newsletter/
│   └── page.tsx
├── customers/
│   └── page.tsx
└── orders/
    └── page.tsx
```

**Exemple : `apps/admin/app/(tools)/products/page.tsx`**

```typescript
import { ToolLoader } from '@/components/shell/ToolLoader'

export const metadata = {
  title: 'Produits | Admin Blanche Renaudin'
}

export default function ProductsPage() {
  return (
    <ToolLoader toolId="products">
      {/* Le composant ProductsList sera chargé depuis @repo/tools-products */}
    </ToolLoader>
  )
}
```

---

#### 2.6 Créer la navigation admin

```typescript
// apps/admin/components/shell/AdminNav.tsx
'use client'

import Link from 'next/link'
import { usePathname } from 'next/navigation'
import { getAccessibleTools } from '@/lib/registry'
import { useShellServices } from '@/lib/services'
import { cn } from '@repo/ui/lib/utils'

export function AdminNav() {
  const pathname = usePathname()
  const services = useShellServices()
  
  // Récupérer uniquement les tools accessibles
  const tools = getAccessibleTools([
    'products:read',
    'newsletter:read',
    'customers:read',
    'orders:read'
  ])

  return (
    <nav className="flex items-center gap-6 px-6 py-4 border-b">
      <Link href="/dashboard" className="text-lg font-bold">
        Admin
      </Link>
    
      <div className="flex items-center gap-4">
        {tools.map((tool) => {
          const Icon = tool.icon
          const isActive = pathname.startsWith(tool.route)
        
          return (
            <Link
              key={tool.id}
              href={tool.route}
              className={cn(
                'flex items-center gap-2 px-3 py-2 rounded-lg transition-colors',
                isActive
                  ? 'bg-violet text-white'
                  : 'hover:bg-gray-100'
              )}
            >
              <Icon className="w-4 h-4" />
              <span>{tool.name}</span>
            </Link>
          )
        })}
      </div>
    </nav>
  )
}
```

---

#### 2.7 Mettre à jour le layout admin

```typescript
// apps/admin/app/(tools)/layout.tsx

import { AdminNav } from '@/components/shell/AdminNav'
import { Toaster } from 'sonner'

export default function ToolsLayout({
  children
}: {
  children: React.ReactNode
}) {
  return (
    <>
      <AdminNav />
      <main className="container mx-auto py-8">
        {children}
      </main>
      <Toaster position="top-right" />
    </>
  )
}
```

---

**Gate PHASE 2 :**

* ✅ Registry opérationnel
* ✅ ToolLoader avec RBAC fonctionne
* ✅ Navigation affiche les tools accessibles
* ✅ ErrorBoundary capte les erreurs

---

### **PHASE 3 : Migrer tool Newsletter (1 jour)** 🟡 TEST

Newsletter est le plus simple → parfait pour valider le pattern.

#### 3.1 Restructurer `@repo/tools-newsletter`

```bash
# Structure actuelle
packages/newsletter/
└── src/
    ├── images.ts
    ├── render.ts
    ├── types.ts
    ├── utils.ts
    └── validation.ts

# Structure cible
packages/tools/newsletter/
└── src/
    ├── api/
    │   └── subscribers.ts    # Fonctions pures CRUD
    ├── routes/
    │   └── SubscribersList.tsx  # Composant RSC
    ├── components/
    │   └── SubscriberCard.tsx
    ├── types.ts
    └── index.ts
```

#### 3.2 Créer l'API pure

```typescript
// packages/tools/newsletter/src/api/subscribers.ts

import { createServerClient } from '@repo/database'

export interface Subscriber {
  id: string
  email: string
  status: 'pending' | 'confirmed' | 'unsubscribed'
  confirmed_at?: string
  created_at: string
}

export async function listSubscribers(): Promise<{
  data: Subscriber[]
  error: Error | null
}> {
  try {
    const supabase = createServerClient()
  
    const { data, error } = await supabase
      .from('newsletter_subscribers')
      .select('*')
      .order('created_at', { ascending: false })

    if (error) throw error

    return { data: data as Subscriber[], error: null }
  } catch (error) {
    return {
      data: [],
      error: error instanceof Error ? error : new Error('Unknown error')
    }
  }
}

export async function updateSubscriberStatus(
  id: string,
  status: Subscriber['status']
): Promise<{ error: Error | null }> {
  try {
    const supabase = createServerClient()
  
    const { error } = await supabase
      .from('newsletter_subscribers')
      .update({ status })
      .eq('id', id)

    if (error) throw error

    return { error: null }
  } catch (error) {
    return {
      error: error instanceof Error ? error : new Error('Unknown error')
    }
  }
}
```

#### 3.3 Créer le composant liste (RSC)

```typescript
// packages/tools/newsletter/src/routes/SubscribersList.tsx

import { listSubscribers } from '../api/subscribers'
import { SubscriberCard } from '../components/SubscriberCard'

export async function SubscribersList() {
  const { data: subscribers, error } = await listSubscribers()

  if (error) {
    return <div className="text-red-600">Erreur : {error.message}</div>
  }

  if (subscribers.length === 0) {
    return <div>Aucun abonné</div>
  }

  return (
    <div className="space-y-4">
      <h1 className="text-2xl font-bold">Abonnés Newsletter</h1>
      <div className="grid gap-4">
        {subscribers.map((subscriber) => (
          <SubscriberCard key={subscriber.id} subscriber={subscriber} />
        ))}
      </div>
    </div>
  )
}
```

#### 3.4 Créer le composant card (client)

```typescript
// packages/tools/newsletter/src/components/SubscriberCard.tsx
'use client'

import { useState } from 'react'
import type { Subscriber } from '../api/subscribers'
import { Badge } from '@repo/ui/components/badge'

interface Props {
  subscriber: Subscriber
}

export function SubscriberCard({ subscriber }: Props) {
  const [status, setStatus] = useState(subscriber.status)

  const statusColors = {
    pending: 'bg-yellow-100 text-yellow-800',
    confirmed: 'bg-green-100 text-green-800',
    unsubscribed: 'bg-gray-100 text-gray-800'
  }

  return (
    <div className="border rounded-lg p-4 flex items-center justify-between">
      <div>
        <p className="font-medium">{subscriber.email}</p>
        <p className="text-sm text-gray-600">
          {new Date(subscriber.created_at).toLocaleDateString()}
        </p>
      </div>
    
      <Badge className={statusColors[status]}>
        {status}
      </Badge>
    </div>
  )
}
```

#### 3.5 Exporter depuis index

```typescript
// packages/tools/newsletter/src/index.ts

export { SubscribersList } from './routes/SubscribersList'
export { SubscriberCard } from './components/SubscriberCard'
export * from './api/subscribers'
export * from './types'
```

#### 3.6 Créer la page admin

```typescript
// apps/admin/app/(tools)/newsletter/page.tsx

import { ToolLoader } from '@/components/shell/ToolLoader'
import { SubscribersList } from '@repo/tools-newsletter'

export const metadata = {
  title: 'Newsletter | Admin'
}

export default function NewsletterPage() {
  return (
    <ToolLoader toolId="newsletter">
      <SubscribersList />
    </ToolLoader>
  )
}
```

#### 3.7 Tester

```bash
pnpm --filter admin dev
```

Naviguer vers `/newsletter` et vérifier :

* ✅ Lazy loading fonctionne
* ✅ Liste s'affiche
* ✅ Pas d'erreurs console

**Gate PHASE 3 :** ✅ Newsletter fonctionne en tant que tool isolé

---

### **PHASE 4 : Tests & Qualité (2 jours)** 🟡 IMPORTANT

#### 4.1 Configurer Vitest

```typescript
// packages/tools/newsletter/vitest.config.ts

import { defineConfig } from 'vitest/config'

export default defineConfig({
  test: {
    environment: 'node',
    globals: true,
    coverage: {
      provider: 'v8',
      reporter: ['text', 'json', 'html']
    }
  }
})
```

#### 4.2 Écrire tests unitaires

```typescript
// packages/tools/newsletter/src/api/__tests__/subscribers.test.ts

import { describe, it, expect, vi } from 'vitest'
import { listSubscribers, updateSubscriberStatus } from '../subscribers'

// Mock Supabase
vi.mock('@repo/database/client-server', () => ({
  createServerClient: () => ({
    from: vi.fn(() => ({
      select: vi.fn().mockReturnThis(),
      order: vi.fn().mockReturnThis(),
      update: vi.fn().mockReturnThis(),
      eq: vi.fn().mockResolvedValue({ data: [], error: null })
    }))
  })
}))

describe('subscribers API', () => {
  it('should list subscribers', async () => {
    const { data, error } = await listSubscribers()
    expect(error).toBeNull()
    expect(Array.isArray(data)).toBe(true)
  })

  it('should update subscriber status', async () => {
    const { error } = await updateSubscriberStatus('123', 'confirmed')
    expect(error).toBeNull()
  })
})
```

#### 4.3 Configurer Playwright

```typescript
// playwright.config.ts

import { defineConfig } from '@playwright/test'

export default defineConfig({
  testDir: './tests/e2e',
  use: {
    baseURL: 'http://localhost:3000',
    screenshot: 'only-on-failure',
    video: 'retain-on-failure'
  },
  projects: [
    {
      name: 'chromium',
      use: { browserName: 'chromium' }
    }
  ]
})
```

#### 4.4 Écrire test E2E

```typescript
// tests/e2e/newsletter.spec.ts

import { test, expect } from '@playwright/test'

test.describe('Newsletter Tool', () => {
  test.beforeEach(async ({ page }) => {
    // Login
    await page.goto('/login')
    await page.fill('[name="email"]', 'admin@test.com')
    await page.fill('[name="password"]', 'password')
    await page.click('button[type="submit"]')
    await page.waitForURL('/dashboard')
  })

  test('should display subscribers list', async ({ page }) => {
    await page.goto('/newsletter')
  
    // Vérifier chargement
    await page.waitForSelector('[data-testid="subscribers-list"]')
  
    // Vérifier présence de données
    const subscribers = await page.locator('[data-testid="subscriber-card"]')
    expect(await subscribers.count()).toBeGreaterThan(0)
  })
})
```

**Gate PHASE 4 :**

* ✅ Tests unitaires passent
* ✅ Coverage >80%
* ✅ Test E2E passe

---

## 📋 Checklist de validation complète

### Infrastructure & Build

* [ ] Structure `packages/tools/` créée
* [ ] TypeScript Project References configurées
* [ ] `transpilePackages` dans next.config
* [ ] Build incrémental < 10s
* [ ] Type-check < 15s

### Shell & Sécurité

* [ ] Registry des tools opérationnel
* [ ] ToolLoader avec RBAC
* [ ] Services injectés (notify, navigate, confirm)
* [ ] ErrorBoundary par tool
* [ ] Navigation dynamique selon permissions

### Tools

* [ ] Newsletter migré et fonctionnel
* [ ] API pure testable
* [ ] Composants RSC + Client séparés
* [ ] Pages admin minces (<50 lignes)

### Tests & Qualité

* [ ] Vitest configuré
* [ ] Tests unitaires >80% coverage
* [ ] Playwright configuré
* [ ] Tests E2E smoke

### Performance

* [ ] Budgets bundle définis
* [ ] Bundle analyzer intégré
* [ ] Lazy loading vérifié

---

## 🚀 Commandes utiles

```bash
# Créer structure tools
pnpm run create-tools-structure

# Type-check incrémental
pnpm -r type-check

# Build incrémental
pnpm build

# Tests unitaires
pnpm --filter @repo/tools-newsletter test

# Tests E2E
pnpm test:e2e

# Analyse bundle
pnpm --filter admin analyze

# Dev mode
pnpm dev
```

---

## 📊 Timeline estimée

| Phase                               | Durée              | Priorité    | Dépendances |
| ----------------------------------- | ------------------- | ------------ | ------------ |
| **PHASE 1**: Fondations       | 1-2 jours           | 🔴 CRITIQUE  | -            |
| **PHASE 2**: Shell & Registry | 2-3 jours           | 🔴 CRITIQUE  | Phase 1      |
| **PHASE 3**: Newsletter       | 1 jour              | 🟡 TEST      | Phase 2      |
| **PHASE 4**: Tests            | 2 jours             | 🟡 IMPORTANT | Phase 3      |
| **TOTAL**                     | **6-8 jours** |              |              |

---

## ✅ Critères de succès

Avant de migrer `products`, on doit avoir :

1. ✅ Toutes les **Gates** passées
2. ✅ Newsletter fonctionnel en tant que tool isolé
3. ✅ Tests unitaires + E2E verts
4. ✅ Build incrémental < 10s
5. ✅ Pas de régression sur storefront

**Quand ces critères sont remplis → GO pour migration `products`** 🚀

---

**Document créé le : 29 octobre 2025**

**Auteur : Assistant Architecture**

**Statut : Plan d'action prêt à exécuter**cd
