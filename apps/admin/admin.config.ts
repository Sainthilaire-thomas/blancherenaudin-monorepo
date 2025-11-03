// admin.config.ts
import { ToolDefinition } from './lib/types/tool'

export const tools: ToolDefinition[] = [
  {
    id: 'products',
    name: 'Produits',
    icon: 'Package',
    path: '/products',
    enabled: true,
    order: 1,
  },
  {
    id: 'orders',
    name: 'Commandes',
    icon: 'ShoppingCart',
    path: '/orders',
    enabled: true,
    order: 2,
  },
  {
    id: 'customers',
    name: 'Clients',
    icon: 'Users',
    path: '/customers',
    enabled: true,
    order: 3,
  },
  {
    id: 'categories',
    name: 'Catégories',
    icon: 'Tags',
    path: '/categories',
    enabled: true,
    order: 4,
  },
  {
    id: 'media',
    name: 'Médias',
    icon: 'FolderOpen',
    path: '/media',
    enabled: true,
    order: 5,
  },
  {
    id: 'newsletter',
    name: 'Newsletter',
    icon: 'Mail',
    path: '/newsletter',
    enabled: true,
    order: 6,
  },
  {
    id: 'analytics',
    name: 'Analytics',
    icon: 'BarChart3',
    path: '/analytics',
    enabled: false,
    order: 7,
  },
  {
    id: 'marketing',
    name: 'Marketing',
    icon: 'Megaphone',
    path: '/marketing',
    enabled: false,
    order: 8,
  },
]
