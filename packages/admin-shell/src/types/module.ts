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
