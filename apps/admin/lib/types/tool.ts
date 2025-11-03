// lib/types/tool.ts
export interface ToolDefinition {
  id: string
  name: string
  icon: string  // Nom de l'icône en string
  path: string
  enabled: boolean
  order: number
}