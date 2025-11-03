# Architecture Monorepo Évoluée - Blanche Renaudin

> **📅 Dernière mise à jour** : 2 novembre 2025
>
> **✅ Statut** : Architecture en 2 phases validée

---

## 🎯 Évolution architecturale en 2 phases

L'architecture évolue progressivement selon le nombre de tools et la complexité du projet :

### 📊 Vue comparative

| Critère                   | Phase 1 : Simple            | Phase 2 : Avancée        |
| -------------------------- | --------------------------- | ------------------------- |
| **Nombre de tools**  | 1-10 tools                  | 10+ tools                 |
| **Pattern**          | Imports statiques           | Chargement dynamique      |
| **RBAC**             | Basique (enabled/disabled)  | Granulaire (permissions)  |
| **Complexité**      | Faible ⭐                   | Moyenne ⭐⭐⭐            |
| **Build time**       | Rapide                      | Moyen (code splitting)    |
| **Maintenance**      | Simple                      | Nécessite registre       |
| **Quand l'utiliser** | MVP, prototypage, <15 tools | Production, scaling, RBAC |

### 🎯 Règle de décision

```
SI nombre_tools < 10 ET pas_besoin_RBAC_complexe
  ALORS → Phase 1 (Simple)
SINON
  ALORS → Phase 2 (Avancée)
```

> 💡 **Best practice** : Commencer **toujours** en Phase 1, migrer vers Phase 2 seulement quand nécessaire.

---

## 📦 Structure du monorepo

### Vue d'ensemble

```
blancherenaudin-monorepo/
├── apps/
│   ├── admin/                    # Interface d'administration
│   │   ├── app/                  # Next.js App Router
│   │   │   ├── (shell)/          # Layout global
│   │   │   ├── (tools)/          # Pages des tools
│   │   │   └── api/              # API routes
│   │   ├── components/           # Composants admin
│   │   │   ├── providers/        # React Contexts (Phase 1 ou 2)
│   │   │   └── shell/            # Layout & Navigation (Phase 1 ou 2)
│   │   ├── lib/                  # Utils & config
│   │   │   └── types/            # Types admin
│   │   ├── admin.config.ts       # Configuration tools (Phase 1 ou 2)
│   │   └── next.config.ts
│   │
│   └── storefront/               # Site e-commerce client
│       └── [structure similaire]
│
├── packages/
│   ├── ui/                       # Design System (shadcn/ui)
│   │   ├── components/
│   │   └── lib/
│   │
│   ├── database/                 # Client Supabase + helpers
│   │   ├── clients/
│   │   └── types/
│   │
│   ├── auth/                     # Authentification
│   │
│   └── tools/                    # Modules métier indépendants
│       ├── products/
│       │   ├── src/
│       │   │   ├── api/          # Logique métier pure
│       │   │   ├── routes/       # Composants UI (RSC + Client)
│       │   │   └── types/        # Types spécifiques
│       │   └── package.json
│       │
│       ├── orders/
│       ├── customers/
│       ├── categories/
│       └── [autres]/
│
├── turbo.json                    # Config Turborepo
├── pnpm-workspace.yaml           # Workspace pnpm
└── package.json
```

---

## 🏗️ PHASE 1 : Architecture Simple (1-10 tools) ✅ ACTUELLE

### Principe

**Imports statiques directs** : Chaque page Next.js importe directement le composant du tool.

### Structure `apps/admin`

```
apps/admin/
├── app/
│   ├── layout.tsx                      # Root layout avec ThemeProvider
│   │
│   └── (tools)/                        # Groupe de routes tools
│       ├── layout.tsx                  # Layout vide (return children)
│       │
│       ├── categories/
│       │   ├── page.tsx                # Import direct depuis @repo/tools-categories
│       │   └── layout.tsx              # Layout local (optionnel)
│       │
│       ├── products/
│       │   ├── page.tsx                # Import direct depuis @repo/tools-products
│       │   ├── [id]/page.tsx
│       │   └── new/page.tsx
│       │
│       └── orders/
│           └── page.tsx
│
├── components/
│   ├── providers/
│   │   └── ThemeProvider.tsx           # Dark mode context
│   │
│   └── shell/
│       ├── AdminLayout.tsx             # Layout + Navigation intégrée
│       └── ThemeToggle.tsx             # Toggle dark mode
│
├── lib/
│   └── types/
│       └── tool.ts                     # Type ToolDefinition
│
└── admin.config.ts                     # Configuration simple
    └── export const tools: ToolDefinition[]
```

### Configuration : `admin.config.ts` (Phase 1)

```typescript
// apps/admin/admin.config.ts
import { ToolDefinition } from './lib/types/tool'

export const tools: ToolDefinition[] = [
  {
    id: 'categories',
    name: 'Catégories',
    icon: 'Tags',              // String → mappé dans AdminLayout
    path: '/categories',
    enabled: true,
    order: 1,
  },
  {
    id: 'products',
    name: 'Produits',
    icon: 'Package',
    path: '/products',
    enabled: true,
    order: 2,
  },
  // ... autres tools
]
```

### Type : `ToolDefinition` (Phase 1)

```typescript
// apps/admin/lib/types/tool.ts
export interface ToolDefinition {
  id: string
  name: string
  icon: string                // Nom de l'icône Lucide en string
  path: string
  enabled: boolean
  order: number
}
```

### Layout : `AdminLayout.tsx` (Phase 1)

```tsx
// apps/admin/components/shell/AdminLayout.tsx
'use client'

import * as Icons from 'lucide-react'
import Link from 'next/link'
import { usePathname } from 'next/navigation'
import { ToolDefinition } from '@/lib/types/tool'

interface Props {
  children: React.ReactNode
  modules: ToolDefinition[]
}

export function AdminLayout({ children, modules }: Props) {
  const pathname = usePathname()
  
  const enabledTools = modules
    .filter(m => m.enabled)
    .sort((a, b) => a.order - b.order)

  return (
    <div className="flex h-screen">
      {/* Sidebar */}
      <aside className="w-64 bg-white dark:bg-gray-900 border-r">
        <nav>
          {enabledTools.map((tool) => {
            // Mapping dynamique icône string → composant Lucide
            const Icon = Icons[tool.icon as keyof typeof Icons] as any
            const isActive = pathname.startsWith(tool.path)
          
            return (
              <Link
                key={tool.id}
                href={tool.path}
                className={isActive ? 'active' : ''}
              >
                {Icon && <Icon />}
                <span>{tool.name}</span>
              </Link>
            )
          })}
        </nav>
      </aside>

      {/* Main content */}
      <main className="flex-1">
        {children}
      </main>
    </div>
  )
}
```

### Pages : Import direct (Phase 1)

```tsx
// apps/admin/app/(tools)/categories/page.tsx
import { CategoriesList } from '@repo/tools-categories'

export default function CategoriesPage() {
  return <CategoriesList />
}
```

```tsx
// apps/admin/app/(tools)/products/page.tsx
import { ProductsList } from '@repo/tools-products'

export default function ProductsPage() {
  return <ProductsList />
}
```

### Avantages Phase 1

✅ **Simplicité** : Code direct, facile à comprendre

✅ **Rapidité** : Imports statiques = build rapide

✅ **Maintenance** : Peu de couches d'abstraction

✅ **Debugging** : Erreurs claires, stack trace simple

✅ **DX** : TypeScript autocomplete parfait

### Inconvénients Phase 1

❌ Pas de code splitting automatique

❌ RBAC basique (juste enabled/disabled)

❌ Tous les tools chargés au build

### Quand utiliser Phase 1

* ✅ MVP / Prototypage
* ✅ 1-10 tools maximum
* ✅ Équipe <5 développeurs
* ✅ RBAC simple (admin vs non-admin)
* ✅ Tous les tools toujours disponibles

---

## 🚀 PHASE 2 : Architecture Avancée (10+ tools) 🔄 FUTURE

### Principe

**Chargement dynamique avec registre** : Un registre centralisé mappe les tools et les charge à la demande.

### Structure `apps/admin` (Phase 2)

```
apps/admin/
├── app/
│   ├── layout.tsx                      # Root avec ToolRegistryProvider
│   │
│   └── (tools)/
│       └── [toolId]/                   # Route dynamique unique
│           └── page.tsx                # Utilise ToolLoader
│
├── components/
│   ├── providers/
│   │   ├── ThemeProvider.tsx
│   │   └── ToolRegistryProvider.tsx    # 🆕 Registre tools
│   │
│   └── shell/
│       ├── AdminShell.tsx              # 🆕 Shell avec registre
│       ├── ToolLoader.tsx              # 🆕 Chargement dynamique
│       └── Navigation.tsx              # Navigation depuis registre
│
├── lib/
│   ├── registry/
│   │   └── tools.ts                    # 🆕 Registre centralisé
│   │
│   └── types/
│       └── tool.ts                     # Type enrichi avec permissions
│
└── admin.config.ts                     # Configuration avancée
```

### Registre : `tools.ts` (Phase 2)

```typescript
// apps/admin/lib/registry/tools.ts
import { ToolDefinition } from '../types/tool'
import { Package, ShoppingCart, Users, Tags } from 'lucide-react'

export const toolsRegistry: Record<string, ToolDefinition> = {
  products: {
    id: 'products',
    name: 'Produits',
    icon: Package,                        // Composant direct (pas string)
    path: '/products',
    permissions: ['products:read'],       // 🆕 Permissions granulaires
    loader: () => import('@repo/tools-products'), // 🆕 Dynamic import
    enabled: true,
    order: 1,
  },
  
  orders: {
    id: 'orders',
    name: 'Commandes',
    icon: ShoppingCart,
    path: '/orders',
    permissions: ['orders:read'],
    loader: () => import('@repo/tools-orders'),
    enabled: true,
    order: 2,
  },
  
  // ... autres tools
}

export function getEnabledTools(): ToolDefinition[] {
  return Object.values(toolsRegistry)
    .filter(t => t.enabled)
    .sort((a, b) => a.order - b.order)
}

export function getTool(id: string): ToolDefinition | undefined {
  return toolsRegistry[id]
}
```

### Type enrichi (Phase 2)

```typescript
// apps/admin/lib/types/tool.ts
import { LucideIcon } from 'lucide-react'

export interface ToolDefinition {
  id: string
  name: string
  icon: LucideIcon                          // Composant React (pas string)
  path: string
  permissions: string[]                     // 🆕 Permissions RBAC
  loader: () => Promise<any>                // 🆕 Dynamic import
  enabled: boolean
  order: number
}
```

### Provider : `ToolRegistryProvider.tsx` (Phase 2)

```tsx
// apps/admin/components/providers/ToolRegistryProvider.tsx
'use client'

import { createContext, useContext, ReactNode } from 'react'
import { toolsRegistry, getEnabledTools } from '@/lib/registry/tools'
import { ToolDefinition } from '@/lib/types/tool'

interface ToolRegistryContextType {
  tools: Record<string, ToolDefinition>
  enabledTools: ToolDefinition[]
  getTool: (id: string) => ToolDefinition | undefined
}

const ToolRegistryContext = createContext<ToolRegistryContextType | undefined>(undefined)

export function ToolRegistryProvider({ children }: { children: ReactNode }) {
  const value = {
    tools: toolsRegistry,
    enabledTools: getEnabledTools(),
    getTool: (id: string) => toolsRegistry[id],
  }

  return (
    <ToolRegistryContext.Provider value={value}>
      {children}
    </ToolRegistryContext.Provider>
  )
}

export function useToolRegistry() {
  const context = useContext(ToolRegistryContext)
  if (!context) {
    throw new Error('useToolRegistry must be used within ToolRegistryProvider')
  }
  return context
}
```

### Loader : `ToolLoader.tsx` (Phase 2)

```tsx
// apps/admin/components/shell/ToolLoader.tsx
'use client'

import { Suspense, lazy, useMemo } from 'react'
import { useToolRegistry } from '../providers/ToolRegistryProvider'

interface Props {
  toolId: string
}

export function ToolLoader({ toolId }: Props) {
  const { getTool } = useToolRegistry()
  
  const tool = getTool(toolId)
  
  if (!tool) {
    return <div>Tool not found: {toolId}</div>
  }

  // Chargement dynamique lazy
  const ToolComponent = useMemo(
    () => lazy(async () => {
      const module = await tool.loader()
      return { default: module.default }
    }),
    [tool]
  )

  return (
    <Suspense fallback={<LoadingSpinner />}>
      <ToolComponent />
    </Suspense>
  )
}
```

### Page dynamique (Phase 2)

```tsx
// apps/admin/app/(tools)/[toolId]/page.tsx
import { ToolLoader } from '@/components/shell/ToolLoader'

interface Props {
  params: { toolId: string }
}

export default function ToolPage({ params }: Props) {
  return <ToolLoader toolId={params.toolId} />
}
```

### Avantages Phase 2

✅ **Code splitting** : Chaque tool charge à la demande

✅ **RBAC granulaire** : Permissions par action

✅ **Scaling** : Gère facilement 50+ tools

✅ **Flexibilité** : Activer/désactiver sans rebuild

✅ **Performance** : Bundle initial plus petit

### Inconvénients Phase 2

❌ **Complexité** : Plus de couches (registre, provider, loader)

❌ **Debug** : Erreurs dynamic import plus obscures

❌ **Setup time** : Plus long à mettre en place

❌ **Overhead** : Lazy loading = latence initiale

### Quand utiliser Phase 2

* ✅ Production avec 10+ tools
* ✅ RBAC complexe (permissions granulaires)
* ✅ Équipe >5 développeurs
* ✅ Tools activables/désactivables dynamiquement
* ✅ Marketplace de tools tiers

---

## 🔄 Migration Phase 1 → Phase 2

### Quand migrer ?

Déclencher la migration si **AU MOINS 2** de ces conditions :

1. ✅ Vous avez >10 tools implémentés
2. ✅ Besoin de permissions granulaires (ex: `products:create`, `orders:refund`)
3. ✅ Bundle size >500KB (trop gros)
4. ✅ Besoin d'activer/désactiver tools sans rebuild
5. ✅ Ajout de tools tiers / marketplace

### Plan de migration (4-6h)

#### Étape 1 : Créer le registre (1h)

```powershell
# Créer la structure
mkdir apps/admin/lib/registry
New-Item apps/admin/lib/registry/tools.ts

# Transformer admin.config.ts → registre
# Ajouter loaders et permissions
```

#### Étape 2 : Créer ToolRegistryProvider (1h)

```powershell
New-Item apps/admin/components/providers/ToolRegistryProvider.tsx
```

#### Étape 3 : Créer ToolLoader (1h)

```powershell
New-Item apps/admin/components/shell/ToolLoader.tsx
```

#### Étape 4 : Refactorer les routes (1-2h)

```powershell
# Supprimer les routes individuelles
Remove-Item apps/admin/app/(tools)/categories -Recurse
Remove-Item apps/admin/app/(tools)/products -Recurse

# Créer la route dynamique
mkdir apps/admin/app/(tools)/[toolId]
New-Item apps/admin/app/(tools)/[toolId]/page.tsx
```

#### Étape 5 : Tests et ajustements (1h)

```bash
pnpm type-check
pnpm build
pnpm dev
# Tester chaque tool
```

### Rétrocompatibilité

Si migration trop complexe, garder **Phase 1** indéfiniment. L'architecture Phase 2 n'est  **pas obligatoire** , c'est une optimisation pour scaling.

---

## 📊 Comparaison côte à côte

### Import d'un tool

| Phase 1 (Simple)                                            | Phase 2 (Avancée)      |
| ----------------------------------------------------------- | ----------------------- |
| `import { CategoriesList } from '@repo/tools-categories'` | `await tool.loader()` |
| Direct, statique                                            | Dynamique, lazy         |
| TypeScript ✅                                               | TypeScript ⚠️ (any)   |

### Configuration

| Phase 1                   | Phase 2                        |
| ------------------------- | ------------------------------ |
| `admin.config.ts`simple | Registre complexe avec loaders |
| 30 lignes                 | 100+ lignes                    |

### RBAC

| Phase 1              | Phase 2                   |
| -------------------- | ------------------------- |
| `enabled: boolean` | `permissions: string[]` |
| Binaire              | Granulaire                |

### Performance

| Phase 1                       | Phase 2                    |
| ----------------------------- | -------------------------- |
| Tous les tools dans le bundle | Code splitting automatique |
| Bundle initial: ~800KB        | Bundle initial: ~300KB     |
| Load time: rapide             | Load time: lazy            |

---

## 🎯 Recommandation officielle

### Pour 99% des projets

**Utiliser Phase 1** jusqu'à ce que vous rencontriez **concrètement** les limites :

* Bundle size >1MB
* Besoin RBAC granulaire prouvé
* > 15 tools actifs
  >

### Ne pas sur-architecturer

> "Premature optimization is the root of all evil" - Donald Knuth

La Phase 2 ajoute de la **complexité sans bénéfice immédiat** pour les petits projets.

### Évolution naturelle

```
Projet naissant (0-5 tools)     → Phase 1 obligatoire
Projet en croissance (5-10)     → Phase 1 recommandée
Projet mature (10-15)           → Évaluer Phase 2
Projet entreprise (15+)         → Phase 2 recommandée
```

---

## ✅ Checklist de validation

### Pour Phase 1 (actuelle)

* [X] `apps/admin/components/shell/AdminLayout.tsx` existe
* [X] `apps/admin/admin.config.ts` avec `ToolDefinition[]`
* [X] Pages tools font import direct depuis `@repo/tools-*`
* [X] Navigation fonctionne avec `tools` config
* [X] Dark mode avec `ThemeProvider`

### Pour Phase 2 (future)

* [ ] `apps/admin/lib/registry/tools.ts` créé
* [ ] `ToolRegistryProvider` implémenté
* [ ] `ToolLoader` avec dynamic import
* [ ] Route `[toolId]/page.tsx` dynamique
* [ ] Permissions RBAC dans registre
* [ ] Tests E2E des dynamic imports

---

## 📚 Documents connexes

* **ARCHITECTURE-AJOUTER-TOOL.md** : Guide création d'un tool (Phase 1)
* **ARCHITECTURE-BONNES-PRATIQUES-TOOLS.md** : Best practices
* **plan-session-03-11-2025.md** : Prochaines étapes

---

**Version** : 2.0

**Date** : 2 novembre 2025

**Statut** : Architecture Phase 1 validée et opérationnelle ✅
