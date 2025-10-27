# @repo/admin-shell

Infrastructure modulaire pour l'interface d'administration.

## 📦 Vue d'ensemble

Ce package fournit l'infrastructure de base pour l'admin :

- **Types TypeScript** : Définitions pour modules, services, props
- **ModuleLoader** : Charge dynamiquement les modules et injecte les services
- **AdminLayout** : Layout avec sidebar de navigation
- **AdminNav** : Barre de navigation supérieure

## 🏗️ Architecture

`
@repo/admin-shell/
├── types/
│   ├── module.ts       # ModuleDefinition, RouteDefinition
│   └── services.ts     # ModuleServices, ModuleProps
├── components/
│   ├── ModuleLoader.tsx   # Chargeur de modules
│   ├── AdminLayout.tsx    # Layout principal
│   └── AdminNav.tsx       # Navigation top
└── index.ts
`

## 🚀 Utilisation

### Dans l'app admin

\\\	sx
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
\\\

### Charger un module

\\\	sx
// apps/admin/app/(dashboard)/[module]/[[...slug]]/page.tsx
import { ModuleLoader } from '@repo/admin-shell'
import { getModuleBySlug } from '@/admin.config'

export default async function ModulePage({ params }) {
  const module = getModuleBySlug(params.module)
  const ModuleComponent = await import(\@/modules/\\)
  
  return (
    <ModuleLoader 
      module={module} 
      subPath={params.slug || []}
    >
      {ModuleComponent.default}
    </ModuleLoader>
  )
}
\\\

### Créer un module

\\\	sx
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
\\\

## 🔧 Services disponibles

Les modules reçoivent automatiquement ces services :

- **notify(message, type)** : Afficher une toast notification
- **confirm(message)** : Afficher une boîte de dialogue
- **navigate(path)** : Naviguer dans l'admin
- **hasPermission(permission)** : Vérifier les permissions
- **refresh()** : Recharger les données

## 📝 Types

Voir \src/types/\ pour les définitions TypeScript complètes.
