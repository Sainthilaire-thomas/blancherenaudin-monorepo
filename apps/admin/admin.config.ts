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
