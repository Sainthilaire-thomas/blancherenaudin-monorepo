# install-admin-shell-app.ps1
# Script d'installation automatique Admin Shell App - Blanche Renaudin Monorepo
# Phase 8 : Créer apps/admin avec route dynamique pour modules
# Date: 28 octobre 2025

Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "   🎯 Installation Admin Shell App - Phase 8" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Configuration
$MONOREPO_PATH = "C:\Users\thoma\OneDrive\SONEAR_2025\blancherenaudin-monorepo"

# Vérifier que le monorepo existe
if (-Not (Test-Path $MONOREPO_PATH)) {
    Write-Host "❌ Erreur: Monorepo introuvable à $MONOREPO_PATH" -ForegroundColor Red
    Write-Host "   Veuillez modifier la variable `$MONOREPO_PATH dans le script" -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ Monorepo trouvé: $MONOREPO_PATH" -ForegroundColor Green
Write-Host ""

# Se placer dans le dossier apps
Set-Location "$MONOREPO_PATH\apps"

# Étape 1: Vérifier si admin existe déjà
Write-Host "📁 Étape 1: Vérification de l'app admin..." -ForegroundColor Yellow

if (Test-Path "admin") {
    Write-Host "⚠️  Le dossier apps/admin existe déjà" -ForegroundColor Yellow
    $response = Read-Host "   Voulez-vous le supprimer et le recréer ? (y/N)"
    
    if ($response -eq "y" -or $response -eq "Y") {
        Write-Host "   🗑️  Suppression de apps/admin..." -ForegroundColor Yellow
        Remove-Item -Path "admin" -Recurse -Force
        Write-Host "   ✅ Supprimé" -ForegroundColor Green
    } else {
        Write-Host "   ⏭️  Installation annulée" -ForegroundColor Gray
        exit 0
    }
}

Write-Host ""

# Étape 2: Créer l'app Next.js
Write-Host "🚀 Étape 2: Création de l'app Next.js admin..." -ForegroundColor Yellow
Write-Host "   Configuration: TypeScript ✓ | Tailwind ✓ | App Router ✓" -ForegroundColor Gray
Write-Host ""

# Créer avec pnpm create next-app (mode non-interactif)
pnpm create next-app@latest admin `
    --typescript `
    --tailwind `
    --app `
    --no-src-dir `
    --import-alias "@/*" `
    --eslint

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Erreur lors de la création de l'app Next.js" -ForegroundColor Red
    exit 1
}

Write-Host "✅ App Next.js créée" -ForegroundColor Green
Write-Host ""

# Se placer dans le dossier admin
Set-Location "admin"

# Étape 3: Installer les dépendances workspace
Write-Host "📦 Étape 3: Installation des dépendances workspace..." -ForegroundColor Yellow

$dependencies = @(
    "@repo/admin-shell",
    "@repo/ui",
    "@repo/database",
    "@repo/auth",
    "next@15.0.3",
    "react@19.0.0-rc-66855b96-20241106",
    "react-dom@19.0.0-rc-66855b96-20241106",
    "lucide-react",
    "sonner",
    "zustand"
)

foreach ($dep in $dependencies) {
    Write-Host "   Installing $dep..." -ForegroundColor Gray
}

pnpm add @repo/admin-shell @repo/ui @repo/database @repo/auth `
    next@15.0.3 `
    react@19.0.0-rc-66855b96-20241106 `
    react-dom@19.0.0-rc-66855b96-20241106 `
    lucide-react sonner zustand

if ($LASTEXITCODE -ne 0) {
    Write-Host "⚠️  Certaines dépendances n'ont pas pu être installées" -ForegroundColor Yellow
} else {
    Write-Host "✅ Dépendances installées" -ForegroundColor Green
}

Write-Host ""

# Étape 4: Créer la structure de dossiers
Write-Host "📁 Étape 4: Création de la structure de dossiers..." -ForegroundColor Yellow

$folders = @(
    "app\(auth)\login",
    "app\(dashboard)\[module]\[[...slug]]",
    "app\api\auth",
    "components",
    "lib",
    "middleware"
)

foreach ($folder in $folders) {
    $fullPath = $folder
    if (-Not (Test-Path $fullPath)) {
        New-Item -ItemType Directory -Path $fullPath -Force | Out-Null
        Write-Host "   ✅ Créé: $folder" -ForegroundColor Green
    }
}

Write-Host ""

# Étape 5: Créer les fichiers de configuration
Write-Host "📝 Étape 5: Création des fichiers de configuration..." -ForegroundColor Yellow

# 5.1 - admin.config.ts (Registry des modules)
$adminConfig = @'
// admin.config.ts
import { ModuleDefinition } from '@repo/admin-shell'
import {
  Package,
  ShoppingCart,
  Users,
  FolderOpen,
  Tags,
  Mail,
  BarChart3,
  Share2,
} from 'lucide-react'

/**
 * Registry des modules admin
 * 
 * Ajouter un nouveau module :
 * 1. Créer le module dans modules/nom-module/
 * 2. L'ajouter ici dans adminModules[]
 * 3. Les routes seront automatiques : /admin/nom-module/...
 */
export const adminModules: ModuleDefinition[] = [
  {
    id: 'products',
    name: 'Products',
    icon: Package,
    basePath: '/admin/products',
    enabled: false, // ⚠️ Module pas encore créé
    order: 1,
  },
  {
    id: 'orders',
    name: 'Orders',
    icon: ShoppingCart,
    basePath: '/admin/orders',
    enabled: false, // ⚠️ Module pas encore créé
    badge: 12, // Exemple: commandes en attente
    order: 2,
  },
  {
    id: 'customers',
    name: 'Customers',
    icon: Users,
    basePath: '/admin/customers',
    enabled: false, // ⚠️ Module pas encore créé
    order: 3,
  },
  {
    id: 'categories',
    name: 'Categories',
    icon: Tags,
    basePath: '/admin/categories',
    enabled: false, // ⚠️ Module pas encore créé
    order: 4,
  },
  {
    id: 'media',
    name: 'Media',
    icon: FolderOpen,
    basePath: '/admin/media',
    enabled: false, // ⚠️ Module pas encore créé
    order: 5,
  },
  {
    id: 'newsletter',
    name: 'Newsletter',
    icon: Mail,
    basePath: '/admin/newsletter',
    enabled: false, // ⚠️ Module pas encore créé
    order: 6,
  },
  {
    id: 'analytics',
    name: 'Analytics',
    icon: BarChart3,
    basePath: '/admin/analytics',
    enabled: false, // ⚠️ Module pas encore créé
    order: 7,
  },
  {
    id: 'social',
    name: 'Social',
    icon: Share2,
    basePath: '/admin/social',
    enabled: false, // ⚠️ Module pas encore créé
    order: 8,
  },
]

// Filtrer uniquement les modules activés
export const enabledModules = adminModules.filter((m) => m.enabled)
'@

Set-Content -Path "admin.config.ts" -Value $adminConfig
Write-Host "   ✅ admin.config.ts" -ForegroundColor Green

# 5.2 - middleware.ts (Protection des routes)
$middleware = @'
// middleware.ts
import { NextResponse } from 'next/server'
import type { NextRequest } from 'next/server'

export function middleware(request: NextRequest) {
  // TODO: Vérifier l'authentification admin ici
  // Pour l'instant, on laisse passer
  
  const { pathname } = request.nextUrl

  // Protéger les routes /admin sauf /admin/login
  if (pathname.startsWith('/admin') && !pathname.startsWith('/admin/login')) {
    // TODO: Vérifier le token admin
    // const token = request.cookies.get('admin-token')
    // if (!token) {
    //   return NextResponse.redirect(new URL('/admin/login', request.url))
    // }
  }

  return NextResponse.next()
}

export const config = {
  matcher: [
    /*
     * Match all request paths except for the ones starting with:
     * - api (API routes)
     * - _next/static (static files)
     * - _next/image (image optimization files)
     * - favicon.ico (favicon file)
     */
    '/((?!api|_next/static|_next/image|favicon.ico).*)',
  ],
}
'@

Set-Content -Path "middleware.ts" -Value $middleware
Write-Host "   ✅ middleware.ts" -ForegroundColor Green

# 5.3 - next.config.ts
$nextConfig = @'
// next.config.ts
import type { NextConfig } from 'next'

const nextConfig: NextConfig = {
  reactStrictMode: true,
  
  // Transpiler les packages du monorepo
  transpilePackages: [
    '@repo/admin-shell',
    '@repo/ui',
    '@repo/database',
    '@repo/auth',
  ],

  // Configuration images Supabase
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
'@

Set-Content -Path "next.config.ts" -Value $nextConfig -Force
Write-Host "   ✅ next.config.ts (mis à jour)" -ForegroundColor Green

# 5.4 - tailwind.config.ts
$tailwindConfig = @'
// tailwind.config.ts
import type { Config } from 'tailwindcss'

const config: Config = {
  darkMode: 'class',
  content: [
    './pages/**/*.{js,ts,jsx,tsx,mdx}',
    './components/**/*.{js,ts,jsx,tsx,mdx}',
    './app/**/*.{js,ts,jsx,tsx,mdx}',
    // Inclure les composants des packages
    '../../packages/ui/src/**/*.{js,ts,jsx,tsx}',
    '../../packages/admin-shell/src/**/*.{js,ts,jsx,tsx}',
  ],
  theme: {
    extend: {
      colors: {
        // Couleurs Blanche Renaudin
        violet: 'hsl(271, 74%, 37%)',
        'violet-light': 'hsl(271, 74%, 50%)',
        'violet-dark': 'hsl(271, 74%, 25%)',
      },
      fontFamily: {
        sans: ['Archivo Narrow', 'sans-serif'],
        display: ['Archivo Black', 'sans-serif'],
      },
    },
  },
  plugins: [require('tailwindcss-animate')],
}

export default config
'@

Set-Content -Path "tailwind.config.ts" -Value $tailwindConfig -Force
Write-Host "   ✅ tailwind.config.ts (mis à jour)" -ForegroundColor Green

Write-Host ""

# Étape 6: Créer les layouts
Write-Host "📄 Étape 6: Création des layouts..." -ForegroundColor Yellow

# 6.1 - app/layout.tsx (Root Layout)
$rootLayout = @'
// app/layout.tsx
import type { Metadata } from 'next'
import { Archivo_Narrow, Archivo_Black } from 'next/font/google'
import './globals.css'

const archivoNarrow = Archivo_Narrow({
  subsets: ['latin'],
  variable: '--font-archivo-narrow',
})

const archivoBlack = Archivo_Black({
  weight: '400',
  subsets: ['latin'],
  variable: '--font-archivo-black',
})

export const metadata: Metadata = {
  title: 'Blanche Renaudin - Admin',
  description: 'Administration Blanche Renaudin',
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="fr" suppressHydrationWarning>
      <body
        className={`${archivoNarrow.variable} ${archivoBlack.variable} font-sans antialiased`}
      >
        {children}
      </body>
    </html>
  )
}
'@

Set-Content -Path "app\layout.tsx" -Value $rootLayout -Force
Write-Host "   ✅ app/layout.tsx" -ForegroundColor Green

# 6.2 - app/(auth)/login/page.tsx
$loginPage = @'
// app/(auth)/login/page.tsx
'use client'

import { useState } from 'react'
import { useRouter } from 'next/navigation'
import { Button } from '@repo/ui'
import { toast } from 'sonner'

export default function LoginPage() {
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [loading, setLoading] = useState(false)
  const router = useRouter()

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault()
    setLoading(true)

    try {
      // TODO: Implémenter l'auth Supabase ici
      // const { data, error } = await supabase.auth.signInWithPassword({
      //   email,
      //   password,
      // })

      // Mock pour le moment
      if (email === 'admin@blancherenaudin.com' && password === 'admin') {
        toast.success('Connexion réussie')
        router.push('/admin')
      } else {
        toast.error('Email ou mot de passe incorrect')
      }
    } catch (error) {
      toast.error('Erreur de connexion')
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="flex min-h-screen items-center justify-center bg-gray-50">
      <div className="w-full max-w-md space-y-8 rounded-lg bg-white p-8 shadow-lg">
        {/* Logo */}
        <div className="text-center">
          <h1 className="font-display text-3xl uppercase tracking-wider">
            blanche renaudin
          </h1>
          <p className="mt-2 text-sm text-gray-600">Administration</p>
        </div>

        {/* Form */}
        <form onSubmit={handleLogin} className="mt-8 space-y-6">
          <div className="space-y-4">
            <div>
              <label
                htmlFor="email"
                className="block text-sm font-medium text-gray-700"
              >
                Email
              </label>
              <input
                id="email"
                type="email"
                required
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2 text-sm focus:border-violet focus:outline-none focus:ring-violet"
                placeholder="admin@blancherenaudin.com"
              />
            </div>

            <div>
              <label
                htmlFor="password"
                className="block text-sm font-medium text-gray-700"
              >
                Mot de passe
              </label>
              <input
                id="password"
                type="password"
                required
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                className="mt-1 block w-full rounded-md border border-gray-300 px-3 py-2 text-sm focus:border-violet focus:outline-none focus:ring-violet"
                placeholder="••••••••"
              />
            </div>
          </div>

          <Button
            type="submit"
            className="w-full"
            disabled={loading}
          >
            {loading ? 'Connexion...' : 'Se connecter'}
          </Button>

          {/* Aide dev */}
          <p className="text-center text-xs text-gray-500">
            Dev: admin@blancherenaudin.com / admin
          </p>
        </form>
      </div>
    </div>
  )
}
'@

New-Item -ItemType Directory -Path "app\(auth)\login" -Force | Out-Null
Set-Content -Path "app\(auth)\login\page.tsx" -Value $loginPage
Write-Host "   ✅ app/(auth)/login/page.tsx" -ForegroundColor Green

# 6.3 - app/(dashboard)/layout.tsx (Layout avec AdminLayout)
$dashboardLayout = @'
// app/(dashboard)/layout.tsx
'use client'

import { AdminLayout } from '@repo/admin-shell'
import { enabledModules } from '@/admin.config'
import { Toaster } from 'sonner'

export default function DashboardLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <>
      <AdminLayout modules={enabledModules}>
        {children}
      </AdminLayout>
      <Toaster position="top-right" />
    </>
  )
}
'@

Set-Content -Path "app\(dashboard)\layout.tsx" -Value $dashboardLayout
Write-Host "   ✅ app/(dashboard)/layout.tsx" -ForegroundColor Green

# 6.4 - app/(dashboard)/page.tsx (Dashboard principal)
$dashboardPage = @'
// app/(dashboard)/page.tsx
import { Package, ShoppingCart, Users, TrendingUp } from 'lucide-react'

export default function DashboardPage() {
  // TODO: Récupérer les vraies stats depuis Supabase
  const stats = [
    {
      name: 'Produits',
      value: '24',
      icon: Package,
      change: '+3 ce mois',
      color: 'text-blue-600',
    },
    {
      name: 'Commandes',
      value: '12',
      icon: ShoppingCart,
      change: '+2 aujourd\'hui',
      color: 'text-green-600',
    },
    {
      name: 'Clients',
      value: '89',
      icon: Users,
      change: '+5 cette semaine',
      color: 'text-violet',
    },
    {
      name: 'Revenus',
      value: '2,450€',
      icon: TrendingUp,
      change: '+12% ce mois',
      color: 'text-orange-600',
    },
  ]

  return (
    <div className="space-y-6">
      {/* Header */}
      <div>
        <h1 className="text-3xl font-bold">Dashboard</h1>
        <p className="mt-1 text-sm text-gray-600">
          Vue d'ensemble de votre boutique
        </p>
      </div>

      {/* Stats Grid */}
      <div className="grid gap-6 sm:grid-cols-2 lg:grid-cols-4">
        {stats.map((stat) => {
          const Icon = stat.icon
          return (
            <div
              key={stat.name}
              className="rounded-lg border bg-white p-6 shadow-sm"
            >
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-sm font-medium text-gray-600">
                    {stat.name}
                  </p>
                  <p className="mt-2 text-3xl font-semibold">{stat.value}</p>
                  <p className="mt-1 text-xs text-gray-500">{stat.change}</p>
                </div>
                <Icon className={`h-8 w-8 ${stat.color}`} />
              </div>
            </div>
          )
        })}
      </div>

      {/* Message d'accueil */}
      <div className="rounded-lg border border-violet/20 bg-violet/5 p-6">
        <h2 className="font-display text-xl uppercase tracking-wide">
          Bienvenue sur votre admin modulaire 🎉
        </h2>
        <p className="mt-2 text-sm text-gray-700">
          L'infrastructure admin est prête. Les modules seront ajoutés progressivement :
        </p>
        <ul className="mt-4 space-y-2 text-sm text-gray-600">
          <li>⏳ Module Products - À venir</li>
          <li>⏳ Module Orders - À venir</li>
          <li>⏳ Module Customers - À venir</li>
          <li>⏳ Module Categories - À venir</li>
          <li>⏳ Module Media - À venir</li>
          <li>⏳ Module Newsletter - À venir</li>
          <li>⏳ Module Analytics - À venir</li>
          <li>⏳ Module Social - À venir</li>
        </ul>
      </div>
    </div>
  )
}
'@

Set-Content -Path "app\(dashboard)\page.tsx" -Value $dashboardPage
Write-Host "   ✅ app/(dashboard)/page.tsx" -ForegroundColor Green

# 6.5 - app/(dashboard)/[module]/[[...slug]]/page.tsx (Route dynamique pour modules)
$modulePage = @'
// app/(dashboard)/[module]/[[...slug]]/page.tsx
'use client'

import { useParams } from 'next/navigation'
import { ModuleLoader } from '@repo/admin-shell'
import { adminModules } from '@/admin.config'
import { useRouter } from 'next/navigation'
import { toast } from 'sonner'

export default function ModulePage() {
  const params = useParams()
  const router = useRouter()
  
  const moduleId = params.module as string
  const subPath = (params.slug as string[]) || []

  // Trouver la config du module
  const moduleConfig = adminModules.find((m) => m.id === moduleId)

  if (!moduleConfig) {
    return (
      <div className="flex min-h-[400px] items-center justify-center">
        <div className="text-center">
          <h1 className="text-2xl font-bold text-gray-900">
            Module introuvable
          </h1>
          <p className="mt-2 text-gray-600">
            Le module "{moduleId}" n'existe pas
          </p>
        </div>
      </div>
    )
  }

  if (!moduleConfig.enabled) {
    return (
      <div className="flex min-h-[400px] items-center justify-center">
        <div className="text-center">
          <h1 className="text-2xl font-bold text-gray-900">
            Module non disponible
          </h1>
          <p className="mt-2 text-gray-600">
            Le module "{moduleConfig.name}" n'est pas encore activé
          </p>
          <p className="mt-4 text-sm text-gray-500">
            Il sera ajouté dans les prochaines phases de migration
          </p>
        </div>
      </div>
    )
  }

  // Créer les services à injecter dans le module
  const services = {
    notify: (msg: string, type: 'success' | 'error' | 'info' | 'warning' = 'info') => {
      toast[type](msg)
    },
    confirm: async (msg: string) => {
      return window.confirm(msg)
    },
    navigate: (path: string[]) => {
      router.push(`/admin/${moduleId}/${path.join('/')}`)
    },
    hasPermission: (perm: string) => {
      // TODO: Implémenter vraie gestion des permissions
      return true
    },
    refresh: () => {
      router.refresh()
    },
  }

  return (
    <ModuleLoader
      moduleConfig={moduleConfig}
      subPath={subPath}
      services={services}
    />
  )
}
'@

New-Item -ItemType Directory -Path "app\(dashboard)\[module]\[[...slug]]" -Force | Out-Null
Set-Content -Path "app\(dashboard)\[module]\[[...slug]]\page.tsx" -Value $modulePage
Write-Host "   ✅ app/(dashboard)/[module]/[[...slug]]/page.tsx" -ForegroundColor Green

Write-Host ""

# Étape 7: Créer le globals.css
Write-Host "🎨 Étape 7: Configuration des styles..." -ForegroundColor Yellow

$globalsCss = @'
@tailwind base;
@tailwind components;
@tailwind utilities;

@layer base {
  :root {
    --background: 0 0% 100%;
    --foreground: 0 0% 3.9%;
    --card: 0 0% 100%;
    --card-foreground: 0 0% 3.9%;
    --popover: 0 0% 100%;
    --popover-foreground: 0 0% 3.9%;
    --primary: 271 74% 37%;
    --primary-foreground: 0 0% 98%;
    --secondary: 0 0% 96.1%;
    --secondary-foreground: 0 0% 9%;
    --muted: 0 0% 96.1%;
    --muted-foreground: 0 0% 45.1%;
    --accent: 0 0% 96.1%;
    --accent-foreground: 0 0% 9%;
    --destructive: 0 84.2% 60.2%;
    --destructive-foreground: 0 0% 98%;
    --border: 0 0% 89.8%;
    --input: 0 0% 89.8%;
    --ring: 271 74% 37%;
    --radius: 0.5rem;
  }

  .dark {
    --background: 0 0% 3.9%;
    --foreground: 0 0% 98%;
    --card: 0 0% 3.9%;
    --card-foreground: 0 0% 98%;
    --popover: 0 0% 3.9%;
    --popover-foreground: 0 0% 98%;
    --primary: 271 74% 50%;
    --primary-foreground: 0 0% 9%;
    --secondary: 0 0% 14.9%;
    --secondary-foreground: 0 0% 98%;
    --muted: 0 0% 14.9%;
    --muted-foreground: 0 0% 63.9%;
    --accent: 0 0% 14.9%;
    --accent-foreground: 0 0% 98%;
    --destructive: 0 62.8% 30.6%;
    --destructive-foreground: 0 0% 98%;
    --border: 0 0% 14.9%;
    --input: 0 0% 14.9%;
    --ring: 271 74% 50%;
  }
}

@layer base {
  * {
    @apply border-border;
  }
  body {
    @apply bg-background text-foreground;
  }
}
'@

Set-Content -Path "app\globals.css" -Value $globalsCss -Force
Write-Host "   ✅ app/globals.css" -ForegroundColor Green

Write-Host ""

# Étape 8: Mettre à jour package.json
Write-Host "📦 Étape 8: Configuration du package.json..." -ForegroundColor Yellow

$packageJson = Get-Content "package.json" -Raw | ConvertFrom-Json

# Ajouter les scripts
$packageJson.scripts = @{
    "dev" = "next dev -p 3001"
    "build" = "next build"
    "start" = "next start -p 3001"
    "lint" = "next lint"
    "type-check" = "tsc --noEmit"
}

$packageJson | ConvertTo-Json -Depth 10 | Set-Content "package.json"
Write-Host "   ✅ Scripts configurés (port 3001)" -ForegroundColor Green

Write-Host ""

# Étape 9: Créer un fichier README
Write-Host "📖 Étape 9: Création du README..." -ForegroundColor Yellow

$readme = @'
# 🎯 Admin Shell App - Blanche Renaudin

Application admin modulaire pour Blanche Renaudin.

## 🚀 Démarrage

```bash
# Depuis apps/admin/
pnpm dev

# Ou depuis la racine du monorepo
pnpm --filter admin dev
```

L'admin sera accessible sur **http://localhost:3001**

## 🏗️ Architecture

- **Route dynamique**: `/admin/[module]/[[...slug]]`
- **Registry**: `admin.config.ts` (liste des modules)
- **Layout**: Utilise `AdminLayout` de `@repo/admin-shell`
- **Loader**: `ModuleLoader` charge dynamiquement les modules

## 📦 Modules disponibles

Voir `admin.config.ts` pour la liste complète.

Pour activer un module:
1. Créer le module dans `modules/nom-module/`
2. Mettre `enabled: true` dans `admin.config.ts`

## 🔐 Authentification

Credentials temporaires (dev):
- Email: `admin@blancherenaudin.com`
- Password: `admin`

TODO: Implémenter auth Supabase réelle

## 📂 Structure

```
apps/admin/
├── app/
│   ├── (auth)/
│   │   └── login/          # Page de connexion
│   ├── (dashboard)/
│   │   ├── layout.tsx      # Layout avec AdminLayout
│   │   ├── page.tsx        # Dashboard principal
│   │   └── [module]/       # Route dynamique modules
│   │       └── [[...slug]]/
│   │           └── page.tsx
│   ├── globals.css
│   └── layout.tsx
├── admin.config.ts         # Registry des modules
├── middleware.ts           # Protection routes
└── next.config.ts
```

## 🔧 Configuration

- **Port**: 3001 (pour éviter conflits avec storefront)
- **Packages**: Utilise les packages du monorepo via workspace
- **Tailwind**: Partagé avec @repo/config

## 🎨 Personnalisation

Voir `tailwind.config.ts` pour les tokens de design (couleurs, fonts).

## 📝 Développement

### Ajouter un module

1. Créer dans `modules/nom-module/`
2. Exporter un composant React par défaut avec props `ModuleProps`
3. L'ajouter dans `admin.config.ts`
4. Mettre `enabled: true`

### Routes API

Les routes API des modules doivent être dans `apps/admin/app/api/`.

Exemple:
```typescript
// apps/admin/app/api/products/route.ts
import { listProducts } from '@modules/products/api/list'

export async function GET(request: Request) {
  const products = await listProducts()
  return Response.json(products)
}
```

## 🐛 Debug

- `pnpm type-check` : Vérifier les types
- `pnpm lint` : Vérifier le code
'@

Set-Content -Path "README.md" -Value $readme
Write-Host "   ✅ README.md créé" -ForegroundColor Green

Write-Host ""

# Résumé final
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "   ✅ Installation terminée avec succès !" -ForegroundColor Green
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

Write-Host "📂 Structure créée:" -ForegroundColor Yellow
Write-Host "   ✅ apps/admin/ (Next.js 15 + TypeScript)" -ForegroundColor Green
Write-Host "   ✅ Layout avec AdminLayout (@repo/admin-shell)" -ForegroundColor Green
Write-Host "   ✅ Route dynamique [module]/[[...slug]]" -ForegroundColor Green
Write-Host "   ✅ admin.config.ts (registry modules)" -ForegroundColor Green
Write-Host "   ✅ Page login (/admin/login)" -ForegroundColor Green
Write-Host "   ✅ Dashboard principal (/admin)" -ForegroundColor Green
Write-Host ""

Write-Host "🚀 Prochaines étapes:" -ForegroundColor Yellow
Write-Host ""
Write-Host "   1. Tester l'application:" -ForegroundColor White
Write-Host "      cd $MONOREPO_PATH\apps\admin" -ForegroundColor Gray
Write-Host "      pnpm dev" -ForegroundColor Gray
Write-Host ""
Write-Host "   2. Ouvrir dans le navigateur:" -ForegroundColor White
Write-Host "      http://localhost:3001/admin/login" -ForegroundColor Gray
Write-Host ""
Write-Host "   3. Se connecter avec:" -ForegroundColor White
Write-Host "      Email: admin@blancherenaudin.com" -ForegroundColor Gray
Write-Host "      Password: admin" -ForegroundColor Gray
Write-Host ""
Write-Host "   4. Créer votre premier module:" -ForegroundColor White
Write-Host "      Voir modules/products/ (Phase 9)" -ForegroundColor Gray
Write-Host ""

Write-Host "📖 Documentation:" -ForegroundColor Cyan
Write-Host "   - apps/admin/README.md" -ForegroundColor White
Write-Host "   - packages/admin-shell/README.md" -ForegroundColor White
Write-Host ""

Write-Host "⚠️  Notes importantes:" -ForegroundColor Yellow
Write-Host "   - Port 3001 (storefront sur 3000)" -ForegroundColor Gray
Write-Host "   - Tous les modules sont désactivés (enabled: false)" -ForegroundColor Gray
Write-Host "   - Auth temporaire (à implémenter Supabase)" -ForegroundColor Gray
Write-Host ""

Write-Host "✨ Phase 8 complétée ! Prêt pour Phase 9 (Module Products)" -ForegroundColor Green
Write-Host ""

# Pause finale
Write-Host "Appuyez sur une touche pour fermer..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
