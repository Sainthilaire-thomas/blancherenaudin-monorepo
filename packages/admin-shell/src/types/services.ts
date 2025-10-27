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
