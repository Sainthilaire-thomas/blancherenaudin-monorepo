# install-admin-shell.ps1
# Script d'installation automatique Admin Shell - Blanche Renaudin Monorepo
# Date: 27 octobre 2025
# Phase 7: Package Admin Shell (infrastructure modulaire)

Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "   🏗️  Installation Admin Shell - Blanche Renaudin" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Configuration
$MONOREPO_PATH = "C:\Users\thoma\OneDrive\SONEAR_2025\blancherenaudin-monorepo"
$PACKAGE_PATH = Join-Path $MONOREPO_PATH "packages\admin-shell"

# Vérifier que le monorepo existe
if (-Not (Test-Path $MONOREPO_PATH)) {
    Write-Host "❌ Erreur: Monorepo introuvable à $MONOREPO_PATH" -ForegroundColor Red
    Write-Host "   Veuillez modifier la variable `$MONOREPO_PATH dans le script" -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ Monorepo trouvé: $MONOREPO_PATH" -ForegroundColor Green
Write-Host ""

# ═══════════════════════════════════════════════════════════
# ÉTAPE 1: Créer la structure de dossiers
# ═══════════════════════════════════════════════════════════
Write-Host "📁 Étape 1: Création de la structure de dossiers..." -ForegroundColor Yellow
Write-Host ""

$FOLDERS = @(
    "src\types",
    "src\components",
    "src\hooks",
    "src\contexts"
)

foreach ($folder in $FOLDERS) {
    $fullPath = Join-Path $PACKAGE_PATH $folder
    if (-Not (Test-Path $fullPath)) {
        New-Item -ItemType Directory -Path $fullPath -Force | Out-Null
        Write-Host "   ✅ Créé: packages\admin-shell\$folder" -ForegroundColor Green
    } else {
        Write-Host "   ⏭️  Existe déjà: packages\admin-shell\$folder" -ForegroundColor Gray
    }
}

Write-Host ""

# ═══════════════════════════════════════════════════════════
# ÉTAPE 2: Créer package.json
# ═══════════════════════════════════════════════════════════
Write-Host "📦 Étape 2: Création de package.json..." -ForegroundColor Yellow
Write-Host ""

$packageJson = @"
{
  "name": "@repo/admin-shell",
  "version": "0.1.0",
  "private": true,
  "exports": {
    ".": {
      "types": "./src/index.ts",
      "default": "./src/index.ts"
    },
    "./types": {
      "types": "./src/types/index.ts",
      "default": "./src/types/index.ts"
    },
    "./components": {
      "types": "./src/components/index.ts",
      "default": "./src/components/index.ts"
    }
  },
  "scripts": {
    "lint": "eslint .",
    "type-check": "tsc --noEmit"
  },
  "dependencies": {
    "@repo/ui": "workspace:*",
    "lucide-react": "^0.263.1",
    "react": "^19.0.0",
    "sonner": "^1.5.0"
  },
  "devDependencies": {
    "@repo/typescript-config": "workspace:*",
    "@types/react": "^19.0.0",
    "eslint": "^9.0.0",
    "typescript": "^5.6.0"
  }
}
"@

$packageJsonPath = Join-Path $PACKAGE_PATH "package.json"
Set-Content -Path $packageJsonPath -Value $packageJson -Encoding UTF8
Write-Host "   ✅ package.json créé" -ForegroundColor Green
Write-Host ""

# ═══════════════════════════════════════════════════════════
# ÉTAPE 3: Créer tsconfig.json
# ═══════════════════════════════════════════════════════════
Write-Host "⚙️  Étape 3: Création de tsconfig.json..." -ForegroundColor Yellow
Write-Host ""

$tsconfig = @"
{
  "extends": "@repo/typescript-config/react-library.json",
  "compilerOptions": {
    "outDir": "./dist",
    "rootDir": "./src"
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist"]
}
"@

$tsconfigPath = Join-Path $PACKAGE_PATH "tsconfig.json"
Set-Content -Path $tsconfigPath -Value $tsconfig -Encoding UTF8
Write-Host "   ✅ tsconfig.json créé" -ForegroundColor Green
Write-Host ""

# ═══════════════════════════════════════════════════════════
# ÉTAPE 4: Créer les fichiers TypeScript (types)
# ═══════════════════════════════════════════════════════════
Write-Host "🔷 Étape 4: Création des types TypeScript..." -ForegroundColor Yellow
Write-Host ""

# src/types/module.ts
$moduleTypes = @"
import type { LucideIcon } from 'lucide-react'

/**
 * Définition d'une route au sein d'un module
 */
export interface RouteDefinition {
  path: string
  label: string
  icon?: LucideIcon
}

/**
 * Définition complète d'un module admin
 */
export interface ModuleDefinition {
  /** Identifiant unique du module (ex: 'products', 'orders') */
  id: string
  
  /** Nom affiché dans la navigation */
  name: string
  
  /** Icône Lucide pour la navigation */
  icon: LucideIcon
  
  /** Chemin de base du module (ex: '/admin/products') */
  basePath: string
  
  /** Module activé ou non */
  enabled: boolean
  
  /** Routes supplémentaires du module */
  routes?: RouteDefinition[]
  
  /** Badge optionnel (ex: nombre d'items) */
  badge?: number | string
  
  /** Ordre d'affichage dans la navigation */
  order?: number
}

/**
 * Configuration globale des modules
 */
export interface ModulesConfig {
  modules: ModuleDefinition[]
}
"@

$moduleTypesPath = Join-Path $PACKAGE_PATH "src\types\module.ts"
Set-Content -Path $moduleTypesPath -Value $moduleTypes -Encoding UTF8
Write-Host "   ✅ src/types/module.ts créé" -ForegroundColor Green

# src/types/services.ts
$servicesTypes = @"
/**
 * Services fournis par le shell admin aux modules
 */
export interface ModuleServices {
  /**
   * Afficher une notification toast
   * @param message Message à afficher
   * @param type Type de notification
   */
  notify: (
    message: string, 
    type?: 'success' | 'error' | 'info' | 'warning'
  ) => void

  /**
   * Afficher une boîte de dialogue de confirmation
   * @param message Message de confirmation
   * @returns Promise<boolean> true si confirmé
   */
  confirm: (message: string) => Promise<boolean>

  /**
   * Naviguer vers un chemin
   * @param path Segments de chemin (ex: ['products', 'edit', '123'])
   */
  navigate: (path: string[]) => void

  /**
   * Vérifier si l'utilisateur a une permission
   * @param permission Permission à vérifier
   * @returns boolean
   */
  hasPermission: (permission: string) => boolean

  /**
   * Recharger les données du module
   */
  refresh?: () => void
}

/**
 * Props injectées dans chaque composant de module
 */
export interface ModuleProps {
  /** Sous-chemin actuel dans le module */
  subPath: string[]
  
  /** Services fournis par le shell */
  services: ModuleServices
}
"@

$servicesTypesPath = Join-Path $PACKAGE_PATH "src\types\services.ts"
Set-Content -Path $servicesTypesPath -Value $servicesTypes -Encoding UTF8
Write-Host "   ✅ src/types/services.ts créé" -ForegroundColor Green

# src/types/index.ts
$typesIndex = @"
export * from './module'
export * from './services'
"@

$typesIndexPath = Join-Path $PACKAGE_PATH "src\types\index.ts"
Set-Content -Path $typesIndexPath -Value $typesIndex -Encoding UTF8
Write-Host "   ✅ src/types/index.ts créé" -ForegroundColor Green
Write-Host ""

# ═══════════════════════════════════════════════════════════
# ÉTAPE 5: Créer les composants
# ═══════════════════════════════════════════════════════════
Write-Host "⚛️  Étape 5: Création des composants..." -ForegroundColor Yellow
Write-Host ""

# src/components/ModuleLoader.tsx
$moduleLoader = @"
'use client'

import React from 'react'
import { useRouter } from 'next/navigation'
import { toast } from 'sonner'
import type { ModuleDefinition, ModuleProps, ModuleServices } from '../types'

interface ModuleLoaderProps {
  module: ModuleDefinition
  subPath: string[]
  children: React.ComponentType<ModuleProps>
}

/**
 * ModuleLoader
 * Charge un module et lui injecte les services du shell
 */
export function ModuleLoader({ module, subPath, children: ModuleComponent }: ModuleLoaderProps) {
  const router = useRouter()

  // Services fournis aux modules
  const services: ModuleServices = React.useMemo(() => ({
    notify: (message: string, type: 'success' | 'error' | 'info' | 'warning' = 'info') => {
      switch (type) {
        case 'success':
          toast.success(message)
          break
        case 'error':
          toast.error(message)
          break
        case 'warning':
          toast.warning(message)
          break
        default:
          toast.info(message)
      }
    },

    confirm: async (message: string): Promise<boolean> => {
      return window.confirm(message)
    },

    navigate: (path: string[]) => {
      const fullPath = `${module.basePath}/${path.join('/')}`
      router.push(fullPath)
    },

    hasPermission: (permission: string): boolean => {
      // TODO: Implémenter la logique de permissions
      console.log('Checking permission:', permission)
      return true
    },

    refresh: () => {
      router.refresh()
    },
  }), [module.basePath, router])

  return <ModuleComponent subPath={subPath} services={services} />
}
"@

$moduleLoaderPath = Join-Path $PACKAGE_PATH "src\components\ModuleLoader.tsx"
Set-Content -Path $moduleLoaderPath -Value $moduleLoader -Encoding UTF8
Write-Host "   ✅ src/components/ModuleLoader.tsx créé" -ForegroundColor Green

# src/components/AdminLayout.tsx
$adminLayout = @"
'use client'

import React from 'react'
import { usePathname } from 'next/navigation'
import Link from 'next/link'
import { cn } from '@repo/ui/lib/utils'
import type { ModuleDefinition } from '../types'

interface AdminLayoutProps {
  children: React.ReactNode
  modules: ModuleDefinition[]
}

/**
 * AdminLayout
 * Layout principal de l'admin avec sidebar de navigation
 */
export function AdminLayout({ children, modules }: AdminLayoutProps) {
  const pathname = usePathname()
  const [sidebarOpen, setSidebarOpen] = React.useState(true)

  const enabledModules = modules.filter(m => m.enabled).sort((a, b) => (a.order || 0) - (b.order || 0))

  return (
    <div className="flex h-screen bg-gray-50">
      {/* Sidebar */}
      <aside 
        className={cn(
          "bg-white border-r border-gray-200 transition-all duration-300",
          sidebarOpen ? "w-64" : "w-20"
        )}
      >
        <div className="h-full flex flex-col">
          {/* Logo */}
          <div className="h-16 flex items-center justify-between px-4 border-b border-gray-200">
            {sidebarOpen && (
              <span className="font-bold text-lg">Admin</span>
            )}
            <button
              onClick={() => setSidebarOpen(!sidebarOpen)}
              className="p-2 hover:bg-gray-100 rounded-lg"
            >
              {sidebarOpen ? '←' : '→'}
            </button>
          </div>

          {/* Navigation */}
          <nav className="flex-1 overflow-y-auto py-4">
            <ul className="space-y-1 px-2">
              {enabledModules.map((module) => {
                const Icon = module.icon
                const isActive = pathname.startsWith(module.basePath)

                return (
                  <li key={module.id}>
                    <Link
                      href={module.basePath}
                      className={cn(
                        "flex items-center gap-3 px-3 py-2 rounded-lg transition-colors",
                        isActive 
                          ? "bg-violet-50 text-violet-600" 
                          : "text-gray-700 hover:bg-gray-100"
                      )}
                    >
                      <Icon className="w-5 h-5" />
                      {sidebarOpen && (
                        <span className="font-medium">{module.name}</span>
                      )}
                      {sidebarOpen && module.badge && (
                        <span className="ml-auto text-xs bg-gray-200 px-2 py-0.5 rounded-full">
                          {module.badge}
                        </span>
                      )}
                    </Link>
                  </li>
                )
              })}
            </ul>
          </nav>
        </div>
      </aside>

      {/* Main Content */}
      <main className="flex-1 overflow-y-auto">
        {children}
      </main>
    </div>
  )
}
"@

$adminLayoutPath = Join-Path $PACKAGE_PATH "src\components\AdminLayout.tsx"
Set-Content -Path $adminLayoutPath -Value $adminLayout -Encoding UTF8
Write-Host "   ✅ src/components/AdminLayout.tsx créé" -ForegroundColor Green

# src/components/AdminNav.tsx
$adminNav = @"
'use client'

import React from 'react'
import { useRouter } from 'next/navigation'
import { LogOut, User, Settings } from 'lucide-react'
import { Button } from '@repo/ui/components/button'

interface AdminNavProps {
  userName?: string
  userEmail?: string
  onLogout?: () => void
}

/**
 * AdminNav
 * Navigation top avec informations utilisateur
 */
export function AdminNav({ userName, userEmail, onLogout }: AdminNavProps) {
  const router = useRouter()

  const handleLogout = () => {
    if (onLogout) {
      onLogout()
    } else {
      router.push('/admin/login')
    }
  }

  return (
    <header className="h-16 bg-white border-b border-gray-200 px-6 flex items-center justify-between">
      <div className="flex items-center gap-4">
        <h1 className="text-xl font-bold">Blanche Renaudin Admin</h1>
      </div>

      <div className="flex items-center gap-4">
        {/* User Info */}
        <div className="flex items-center gap-3">
          <div className="flex flex-col items-end text-sm">
            <span className="font-medium">{userName || 'Admin'}</span>
            <span className="text-gray-500">{userEmail}</span>
          </div>
          <div className="w-10 h-10 bg-violet-100 rounded-full flex items-center justify-center">
            <User className="w-5 h-5 text-violet-600" />
          </div>
        </div>

        {/* Actions */}
        <Button
          variant="ghost"
          size="icon"
          onClick={() => router.push('/admin/settings')}
        >
          <Settings className="w-5 h-5" />
        </Button>

        <Button
          variant="ghost"
          size="icon"
          onClick={handleLogout}
        >
          <LogOut className="w-5 h-5" />
        </Button>
      </div>
    </header>
  )
}
"@

$adminNavPath = Join-Path $PACKAGE_PATH "src\components\AdminNav.tsx"
Set-Content -Path $adminNavPath -Value $adminNav -Encoding UTF8
Write-Host "   ✅ src/components/AdminNav.tsx créé" -ForegroundColor Green

# src/components/index.ts
$componentsIndex = @"
export { ModuleLoader } from './ModuleLoader'
export { AdminLayout } from './AdminLayout'
export { AdminNav } from './AdminNav'
"@

$componentsIndexPath = Join-Path $PACKAGE_PATH "src\components\index.ts"
Set-Content -Path $componentsIndexPath -Value $componentsIndex -Encoding UTF8
Write-Host "   ✅ src/components/index.ts créé" -ForegroundColor Green
Write-Host ""

# ═══════════════════════════════════════════════════════════
# ÉTAPE 6: Créer le fichier index principal
# ═══════════════════════════════════════════════════════════
Write-Host "📝 Étape 6: Création de l'index principal..." -ForegroundColor Yellow
Write-Host ""

$mainIndex = @"
// Types
export * from './types'

// Components
export * from './components'
"@

$mainIndexPath = Join-Path $PACKAGE_PATH "src\index.ts"
Set-Content -Path $mainIndexPath -Value $mainIndex -Encoding UTF8
Write-Host "   ✅ src/index.ts créé" -ForegroundColor Green
Write-Host ""

# ═══════════════════════════════════════════════════════════
# ÉTAPE 7: Créer README
# ═══════════════════════════════════════════════════════════
Write-Host "📖 Étape 7: Création du README..." -ForegroundColor Yellow
Write-Host ""

$readme = @"
# @repo/admin-shell

Infrastructure modulaire pour l'interface d'administration.

## 📦 Vue d'ensemble

Ce package fournit l'infrastructure de base pour l'admin :

- **Types TypeScript** : Définitions pour modules, services, props
- **ModuleLoader** : Charge dynamiquement les modules et injecte les services
- **AdminLayout** : Layout avec sidebar de navigation
- **AdminNav** : Barre de navigation supérieure

## 🏗️ Architecture

```
@repo/admin-shell/
├── types/
│   ├── module.ts       # ModuleDefinition, RouteDefinition
│   └── services.ts     # ModuleServices, ModuleProps
├── components/
│   ├── ModuleLoader.tsx   # Chargeur de modules
│   ├── AdminLayout.tsx    # Layout principal
│   └── AdminNav.tsx       # Navigation top
└── index.ts
```

## 🚀 Utilisation

### Dans l'app admin

\`\`\`tsx
// apps/admin/app/(dashboard)/layout.tsx
import { AdminLayout } from '@repo/admin-shell'
import { adminModules } from '@/admin.config'

export default function DashboardLayout({ children }) {
  return (
    <AdminLayout modules={adminModules}>
      {children}
    </AdminLayout>
  )
}
\`\`\`

### Charger un module

\`\`\`tsx
// apps/admin/app/(dashboard)/[module]/[[...slug]]/page.tsx
import { ModuleLoader } from '@repo/admin-shell'
import { getModuleBySlug } from '@/admin.config'

export default async function ModulePage({ params }) {
  const module = getModuleBySlug(params.module)
  const ModuleComponent = await import(\`@/modules/\${module.id}\`)
  
  return (
    <ModuleLoader 
      module={module} 
      subPath={params.slug || []}
    >
      {ModuleComponent.default}
    </ModuleLoader>
  )
}
\`\`\`

### Créer un module

\`\`\`tsx
// modules/products/index.tsx
'use client'

import type { ModuleProps } from '@repo/admin-shell'

export default function ProductsModule({ subPath, services }: ModuleProps) {
  const handleSave = () => {
    services.notify('Produit sauvegardé !', 'success')
  }

  const handleDelete = async () => {
    const confirmed = await services.confirm('Supprimer ce produit ?')
    if (confirmed) {
      // Delete logic
    }
  }

  return <div>Products Module</div>
}

// modules/products/module.config.ts
import { Package } from 'lucide-react'
import type { ModuleDefinition } from '@repo/admin-shell'

export const productsModule: ModuleDefinition = {
  id: 'products',
  name: 'Products',
  icon: Package,
  basePath: '/admin/products',
  enabled: true,
  order: 1,
}
\`\`\`

## 🔧 Services disponibles

Les modules reçoivent automatiquement ces services :

- **notify(message, type)** : Afficher une toast notification
- **confirm(message)** : Afficher une boîte de dialogue
- **navigate(path)** : Naviguer dans l'admin
- **hasPermission(permission)** : Vérifier les permissions
- **refresh()** : Recharger les données

## 📝 Types

Voir \`src/types/\` pour les définitions TypeScript complètes.
"@

$readmePath = Join-Path $PACKAGE_PATH "README.md"
Set-Content -Path $readmePath -Value $readme -Encoding UTF8
Write-Host "   ✅ README.md créé" -ForegroundColor Green
Write-Host ""

# ═══════════════════════════════════════════════════════════
# ÉTAPE 8: Installer les dépendances
# ═══════════════════════════════════════════════════════════
Write-Host "📦 Étape 8: Installation des dépendances..." -ForegroundColor Yellow
Write-Host ""

# Vérifier si pnpm est disponible
$pnpmAvailable = Get-Command pnpm -ErrorAction SilentlyContinue

if ($pnpmAvailable) {
    Write-Host "   🔄 Installation avec pnpm..." -ForegroundColor Cyan
    Set-Location $MONOREPO_PATH
    
    try {
        & pnpm install
        Write-Host "   ✅ Dépendances installées avec succès" -ForegroundColor Green
    } catch {
        Write-Host "   ⚠️  Erreur lors de l'installation" -ForegroundColor Yellow
        Write-Host "   Veuillez exécuter: pnpm install" -ForegroundColor White
    }
} else {
    Write-Host "   ⚠️  pnpm non trouvé" -ForegroundColor Yellow
    Write-Host "   Veuillez exécuter manuellement: pnpm install" -ForegroundColor White
}

Write-Host ""

# ═══════════════════════════════════════════════════════════
# RÉSUMÉ
# ═══════════════════════════════════════════════════════════
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "   ✅ Installation terminée avec succès !" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

Write-Host "📊 Résumé de l'installation:" -ForegroundColor Yellow
Write-Host ""
Write-Host "   📁 Dossiers créés:" -ForegroundColor White
Write-Host "      - packages/admin-shell/src/types" -ForegroundColor Gray
Write-Host "      - packages/admin-shell/src/components" -ForegroundColor Gray
Write-Host "      - packages/admin-shell/src/hooks" -ForegroundColor Gray
Write-Host "      - packages/admin-shell/src/contexts" -ForegroundColor Gray
Write-Host ""
Write-Host "   📄 Fichiers créés:" -ForegroundColor White
Write-Host "      - package.json" -ForegroundColor Gray
Write-Host "      - tsconfig.json" -ForegroundColor Gray
Write-Host "      - src/types/module.ts" -ForegroundColor Gray
Write-Host "      - src/types/services.ts" -ForegroundColor Gray
Write-Host "      - src/components/ModuleLoader.tsx" -ForegroundColor Gray
Write-Host "      - src/components/AdminLayout.tsx" -ForegroundColor Gray
Write-Host "      - src/components/AdminNav.tsx" -ForegroundColor Gray
Write-Host "      - src/index.ts" -ForegroundColor Gray
Write-Host "      - README.md" -ForegroundColor Gray
Write-Host ""

Write-Host "🚀 Prochaines étapes:" -ForegroundColor Yellow
Write-Host ""
Write-Host "   1️⃣  Vérifier la compilation:" -ForegroundColor White
Write-Host "      cd packages/admin-shell" -ForegroundColor Cyan
Write-Host "      pnpm type-check" -ForegroundColor Cyan
Write-Host ""
Write-Host "   2️⃣  Créer l'app admin (Phase 8):" -ForegroundColor White
Write-Host "      cd apps" -ForegroundColor Cyan
Write-Host "      pnpm create next-app@latest admin" -ForegroundColor Cyan
Write-Host ""
Write-Host "   3️⃣  Tester le package:" -ForegroundColor White
Write-Host "      Importer { AdminLayout, ModuleLoader } from '@repo/admin-shell'" -ForegroundColor Cyan
Write-Host ""

Write-Host "📖 Documentation:" -ForegroundColor Yellow
Write-Host "   - README: packages/admin-shell/README.md" -ForegroundColor White
Write-Host "   - Types: packages/admin-shell/src/types/" -ForegroundColor White
Write-Host ""

Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Pause pour lire les messages
Write-Host "Appuyez sur une touche pour fermer..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
