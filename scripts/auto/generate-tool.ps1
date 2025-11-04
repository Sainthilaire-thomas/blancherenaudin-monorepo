# scripts/generate-tool.ps1
<#
.SYNOPSIS
    Générateur interactif de tool avec choix des fonctionnalités

.DESCRIPTION
    Pose des questions pour comprendre les besoins et génère un tool complet
    avec la logique métier adaptée (CRUD, liste, filtres, recherche, etc.)

.PARAMETER ToolName
    Nom du tool (optionnel, sera demandé si non fourni)

.PARAMETER NonInteractive
    Mode non-interactif (utilise les valeurs par défaut)

.EXAMPLE
    .\scripts\generate-tool.ps1
    .\scripts\generate-tool.ps1 -ToolName analytics
    .\scripts\generate-tool.ps1 -NonInteractive
#>

param(
    [string]$ToolName,
    [switch]$NonInteractive
)

$ErrorActionPreference = "Stop"
$MONOREPO_ROOT = Split-Path -Parent $PSScriptRoot

# ═══════════════════════════════════════════════════════════
# HELPERS
# ═══════════════════════════════════════════════════════════

function Write-Title { param([string]$Message) Write-Host "`n╔════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan; Write-Host "║  $Message" -ForegroundColor Cyan; Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan }
function Write-Section { param([string]$Message) Write-Host "`n🔹 $Message" -ForegroundColor Yellow }
function Write-Success { param([string]$Message) Write-Host "   ✅ $Message" -ForegroundColor Green }
function Write-Info { param([string]$Message) Write-Host "   ℹ️  $Message" -ForegroundColor Gray }

function Ask-Question {
    param(
        [string]$Question,
        [string]$Default = "",
        [string[]]$Options = @()
    )
    
    if ($NonInteractive) {
        return $Default
    }
    
    if ($Options.Count -gt 0) {
        Write-Host "`n❓ $Question" -ForegroundColor Cyan
        for ($i = 0; $i -lt $Options.Count; $i++) {
            Write-Host "   $($i + 1). $($Options[$i])" -ForegroundColor White
        }
        
        do {
            $response = Read-Host "Choisissez (1-$($Options.Count)) [défaut: 1]"
            if ([string]::IsNullOrWhiteSpace($response)) { $response = "1" }
            $index = [int]$response - 1
        } while ($index -lt 0 -or $index -ge $Options.Count)
        
        return $Options[$index]
    } else {
        if ($Default) {
            $response = Read-Host "`n❓ $Question [défaut: $Default]"
            if ([string]::IsNullOrWhiteSpace($response)) { return $Default }
            return $response
        } else {
            return Read-Host "`n❓ $Question"
        }
    }
}

function Ask-YesNo {
    param(
        [string]$Question,
        [bool]$Default = $true
    )
    
    if ($NonInteractive) {
        return $Default
    }
    
    $defaultText = if ($Default) { "O/n" } else { "o/N" }
    $response = Read-Host "`n❓ $Question [$defaultText]"
    
    if ([string]::IsNullOrWhiteSpace($response)) {
        return $Default
    }
    
    return $response -match '^[oO]'
}

# ═══════════════════════════════════════════════════════════
# ÉTAPE 1 : COLLECTE DES INFORMATIONS
# ═══════════════════════════════════════════════════════════

Write-Title "🚀 GÉNÉRATEUR INTERACTIF DE TOOL"

Write-Host "`nCe générateur va vous poser quelques questions pour créer un tool" -ForegroundColor White
Write-Host "adapté à vos besoins avec toute la logique métier incluse.`n" -ForegroundColor White

# Nom du tool
if (-not $ToolName) {
    do {
        $ToolName = Ask-Question "Nom du tool (kebab-case, ex: analytics, social-media)"
    } while (-not ($ToolName -match '^[a-z]+(-[a-z]+)*$'))
}

$DisplayName = ($ToolName -split '-' | ForEach-Object { 
    $_.Substring(0,1).ToUpper() + $_.Substring(1).ToLower() 
}) -join ''

Write-Success "Nom du tool : $ToolName"
Write-Success "Display name : $DisplayName"

# Type de tool
Write-Section "Type de données gérées"
$dataType = Ask-Question "Quel type de données ce tool va-t-il gérer ?" -Options @(
    "Table simple (ex: catégories, tags)",
    "Table avec relations (ex: produits avec catégories)",
    "Données analytiques (ex: statistiques, métriques)",
    "Configuration/Paramètres",
    "Autre"
)

# Nom de la table Supabase
$defaultTableName = $ToolName -replace '-', '_'
$tableName = Ask-Question "Nom de la table Supabase" -Default $defaultTableName

# Fonctionnalités CRUD
Write-Section "Fonctionnalités CRUD"
$features = @{
    list = Ask-YesNo "Liste des éléments ?" -Default $true
    create = Ask-YesNo "Création d'éléments ?" -Default $true
    edit = Ask-YesNo "Édition d'éléments ?" -Default $true
    delete = Ask-YesNo "Suppression d'éléments ?" -Default $true
    search = Ask-YesNo "Recherche/Filtre ?" -Default $true
    pagination = Ask-YesNo "Pagination ?" -Default $true
    sorting = Ask-YesNo "Tri des colonnes ?" -Default $false
    export = Ask-YesNo "Export CSV/Excel ?" -Default $false
}

# Champs de la table
Write-Section "Structure des données"
Write-Info "Champs automatiques : id, created_at, updated_at"

$fields = @()
$addingFields = $true

while ($addingFields) {
    $fieldName = Ask-Question "Nom du champ (vide pour terminer)" -Default ""
    
    if ([string]::IsNullOrWhiteSpace($fieldName)) {
        $addingFields = $false
        break
    }
    
    $fieldType = Ask-Question "Type du champ '$fieldName'" -Options @(
        "text (court)",
        "textarea (long)",
        "number",
        "boolean",
        "date",
        "select (liste déroulante)",
        "relation (autre table)"
    )
    
    $isRequired = Ask-YesNo "Champ obligatoire ?"
    
    $field = @{
        name = $fieldName
        type = $fieldType
        required = $isRequired
    }
    
    # Options supplémentaires selon le type
    if ($fieldType -eq "select (liste déroulante)") {
        $options = Ask-Question "Options (séparées par des virgules, ex: actif,inactif,archivé)"
        $field.options = $options -split ',' | ForEach-Object { $_.Trim() }
    }
    
    if ($fieldType -eq "relation (autre table)") {
        $relatedTable = Ask-Question "Nom de la table liée"
        $field.relatedTable = $relatedTable
    }
    
    $fields += $field
    Write-Success "Champ '$fieldName' ajouté"
}

# Affichage dans la liste
Write-Section "Colonnes à afficher dans la liste"
$listColumns = @()
foreach ($field in $fields) {
    $show = Ask-YesNo "Afficher '$($field.name)' dans la liste ?" -Default $true
    if ($show) {
        $listColumns += $field.name
    }
}

# ═══════════════════════════════════════════════════════════
# ÉTAPE 2 : RÉSUMÉ DE LA CONFIGURATION
# ═══════════════════════════════════════════════════════════

Write-Title "📋 RÉSUMÉ DE LA CONFIGURATION"

Write-Host "`nTool : $DisplayName ($ToolName)" -ForegroundColor White
Write-Host "Table : $tableName" -ForegroundColor White
Write-Host "Type : $dataType" -ForegroundColor White

Write-Host "`nFonctionnalités :" -ForegroundColor White
$features.GetEnumerator() | ForEach-Object {
    $icon = if ($_.Value) { "✅" } else { "❌" }
    Write-Host "  $icon $($_.Key)" -ForegroundColor Gray
}

Write-Host "`nChamps ($($fields.Count)) :" -ForegroundColor White
foreach ($field in $fields) {
    $req = if ($field.required) { "(obligatoire)" } else { "(optionnel)" }
    Write-Host "  • $($field.name) : $($field.type) $req" -ForegroundColor Gray
}

Write-Host "`nColonnes liste ($($listColumns.Count)) :" -ForegroundColor White
$listColumns | ForEach-Object { Write-Host "  • $_" -ForegroundColor Gray }

if (-not $NonInteractive) {
    $confirm = Ask-YesNo "`nGénérer le tool avec cette configuration ?"
    if (-not $confirm) {
        Write-Host "`n❌ Génération annulée" -ForegroundColor Red
        exit 0
    }
}

# ═══════════════════════════════════════════════════════════
# ÉTAPE 3 : GÉNÉRATION DU CODE
# ═══════════════════════════════════════════════════════════

Write-Title "🔨 GÉNÉRATION DU CODE"

$TOOL_PATH = "$MONOREPO_ROOT\packages\tools\$ToolName"
$ADMIN_PATH = "$MONOREPO_ROOT\apps\admin"

# Créer la structure de base avec create-tool.ps1
Write-Section "Création de la structure de base"
& "$PSScriptRoot\create-tool.ps1" -ToolName $ToolName -WithAPI | Out-Null
Write-Success "Structure de base créée"

# ═══════════════════════════════════════════════════════════
# GÉNÉRATION DES TYPES
# ═══════════════════════════════════════════════════════════

Write-Section "Génération des types TypeScript"

$typesContent = @"
// packages/tools/$ToolName/src/types/index.ts
// Types générés automatiquement

export interface ${DisplayName}Item {
  id: string
  created_at: string
  updated_at: string
"@

foreach ($field in $fields) {
    $tsType = switch -Regex ($field.type) {
        "^text" { "string" }
        "^textarea" { "string" }
        "^number" { "number" }
        "^boolean" { "boolean" }
        "^date" { "string" }
        "^select" { "string" }
        "^relation" { "string" }
        default { "string" }
    }
    
    $optional = if ($field.required) { "" } else { "?" }
    $typesContent += "`n  $($field.name)$optional: $tsType"
}

$typesContent += @"

}

export interface ${DisplayName}FormData {
"@

foreach ($field in $fields) {
    $tsType = switch -Regex ($field.type) {
        "^text" { "string" }
        "^textarea" { "string" }
        "^number" { "number" }
        "^boolean" { "boolean" }
        "^date" { "string" }
        "^select" { "string" }
        "^relation" { "string" }
        default { "string" }
    }
    
    $typesContent += "`n  $($field.name): $tsType"
}

$typesContent += @"

}

export interface ${DisplayName}Filters {
  search?: string
  sortBy?: keyof ${DisplayName}Item
  sortOrder?: 'asc' | 'desc'
"@

if ($features.pagination) {
    $typesContent += @"

  page?: number
  pageSize?: number
"@
}

$typesContent += @"

}
"@

Set-Content -Path "$TOOL_PATH\src\types\index.ts" -Value $typesContent
Write-Success "Types générés"

# ═══════════════════════════════════════════════════════════
# GÉNÉRATION DU HOOK useItems
# ═══════════════════════════════════════════════════════════

Write-Section "Génération du hook personnalisé"

$hookContent = @"
// packages/tools/$ToolName/src/hooks/use${DisplayName}.ts
'use client'

import { useState, useEffect } from 'react'
import type { ${DisplayName}Item, ${DisplayName}Filters } from '../types'

export function use${DisplayName}(filters?: ${DisplayName}Filters) {
  const [data, setData] = useState<${DisplayName}Item[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
"@

if ($features.pagination) {
    $hookContent += @"

  const [totalCount, setTotalCount] = useState(0)
  const [totalPages, setTotalPages] = useState(0)
"@
}

$hookContent += @"


  useEffect(() => {
    async function fetchData() {
      try {
        setLoading(true)
        
        const url = new URL('/api/admin/$ToolName', window.location.origin)
        
        if (filters?.search) {
          url.searchParams.set('search', filters.search)
        }
        
        if (filters?.sortBy) {
          url.searchParams.set('sortBy', filters.sortBy)
          url.searchParams.set('sortOrder', filters.sortOrder || 'asc')
        }
"@

if ($features.pagination) {
    $hookContent += @"

        
        if (filters?.page) {
          url.searchParams.set('page', filters.page.toString())
        }
        
        if (filters?.pageSize) {
          url.searchParams.set('pageSize', filters.pageSize.toString())
        }
"@
}

$hookContent += @"

        
        const response = await fetch(url.toString())
        if (!response.ok) throw new Error('Failed to fetch')
        
        const result = await response.json()
"@

if ($features.pagination) {
    $hookContent += @"

        setData(result.data)
        setTotalCount(result.totalCount)
        setTotalPages(result.totalPages)
"@
} else {
    $hookContent += @"

        setData(result)
"@
}

$hookContent += @"

      } catch (err) {
        setError(err instanceof Error ? err.message : 'Unknown error')
      } finally {
        setLoading(false)
      }
    }

    fetchData()
  }, [filters?.search, filters?.sortBy, filters?.sortOrder"@

if ($features.pagination) {
    $hookContent += @"
, filters?.page, filters?.pageSize"@
}

$hookContent += @"
])

  return { 
    data, 
    loading, 
    error"@

if ($features.pagination) {
    $hookContent += @"
,
    totalCount,
    totalPages"@
}

$hookContent += @"
 
  }
}
"@

New-Item -ItemType Directory -Path "$TOOL_PATH\src\hooks" -Force | Out-Null
Set-Content -Path "$TOOL_PATH\src\hooks\use${DisplayName}.ts" -Value $hookContent
Write-Success "Hook personnalisé généré"

# ═══════════════════════════════════════════════════════════
# GÉNÉRATION DES COMPOSANTS
# ═══════════════════════════════════════════════════════════

Write-Section "Génération des composants UI"

# Formulaire
$formContent = @"
// packages/tools/$ToolName/src/components/${DisplayName}Form.tsx
'use client'

import { useState } from 'react'
import type { ${DisplayName}FormData } from '../types'

interface ${DisplayName}FormProps {
  initialData?: ${DisplayName}FormData
  onSubmit: (data: ${DisplayName}FormData) => Promise<void>
  onCancel?: () => void
}

export function ${DisplayName}Form({ initialData, onSubmit, onCancel }: ${DisplayName}FormProps) {
  const [formData, setFormData] = useState<${DisplayName}FormData>(
    initialData || {
"@

foreach ($field in $fields) {
    $defaultValue = switch -Regex ($field.type) {
        "^text" { "''" }
        "^textarea" { "''" }
        "^number" { "0" }
        "^boolean" { "false" }
        "^date" { "''" }
        "^select" { "''" }
        "^relation" { "''" }
        default { "''" }
    }
    $formContent += "`n      $($field.name): $defaultValue,"
}

$formContent += @"

    }
  )
  
  const [loading, setLoading] = useState(false)

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setLoading(true)
    
    try {
      await onSubmit(formData)
    } catch (error) {
      console.error('Erreur:', error)
    } finally {
      setLoading(false)
    }
  }

  return (
    <form onSubmit={handleSubmit} className="space-y-6">
"@

foreach ($field in $fields) {
    $formContent += @"

      
      {/* Champ: $($field.name) */}
      <div>
        <label className="block text-sm font-medium text-gray-700 mb-2">
          $($field.name)$(if ($field.required) { ' *' } else { '' })
        </label>
"@
    
    if ($field.type -eq "textarea (long)") {
        $formContent += @"

        <textarea
          value={formData.$($field.name)}
          onChange={(e) => setFormData({ ...formData, $($field.name): e.target.value })}
          $(if ($field.required) { 'required' } else { '' })
          rows={4}
          className="w-full px-4 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500"
        />
"@
    } elseif ($field.type -eq "select (liste déroulante)") {
        $formContent += @"

        <select
          value={formData.$($field.name)}
          onChange={(e) => setFormData({ ...formData, $($field.name): e.target.value })}
          $(if ($field.required) { 'required' } else { '' })
          className="w-full px-4 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500"
        >
          <option value="">-- Sélectionner --</option>
"@
        if ($field.options) {
            foreach ($option in $field.options) {
                $formContent += "`n          <option value=`"$option`">$option</option>"
            }
        }
        $formContent += @"

        </select>
"@
    } elseif ($field.type -eq "boolean") {
        $formContent += @"

        <input
          type="checkbox"
          checked={formData.$($field.name)}
          onChange={(e) => setFormData({ ...formData, $($field.name): e.target.checked })}
          className="w-4 h-4 text-blue-600 border-gray-300 rounded focus:ring-blue-500"
        />
"@
    } elseif ($field.type -eq "number") {
        $formContent += @"

        <input
          type="number"
          value={formData.$($field.name)}
          onChange={(e) => setFormData({ ...formData, $($field.name): parseFloat(e.target.value) })}
          $(if ($field.required) { 'required' } else { '' })
          className="w-full px-4 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500"
        />
"@
    } elseif ($field.type -eq "date") {
        $formContent += @"

        <input
          type="date"
          value={formData.$($field.name)}
          onChange={(e) => setFormData({ ...formData, $($field.name): e.target.value })}
          $(if ($field.required) { 'required' } else { '' })
          className="w-full px-4 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500"
        />
"@
    } else {
        $formContent += @"

        <input
          type="text"
          value={formData.$($field.name)}
          onChange={(e) => setFormData({ ...formData, $($field.name): e.target.value })}
          $(if ($field.required) { 'required' } else { '' })
          className="w-full px-4 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500"
        />
"@
    }
    
    $formContent += @"

      </div>
"@
}

$formContent += @"


      {/* Actions */}
      <div className="flex gap-4">
        <button
          type="submit"
          disabled={loading}
          className="px-6 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:opacity-50"
        >
          {loading ? 'Enregistrement...' : 'Enregistrer'}
        </button>
        
        {onCancel && (
          <button
            type="button"
            onClick={onCancel}
            className="px-6 py-2 border border-gray-300 rounded-lg hover:bg-gray-50"
          >
            Annuler
          </button>
        )}
      </div>
    </form>
  )
}
"@

Set-Content -Path "$TOOL_PATH\src\components\${DisplayName}Form.tsx" -Value $formContent
Write-Success "Formulaire généré"

# ═══════════════════════════════════════════════════════════
# GÉNÉRATION DE LA PAGE LIST
# ═══════════════════════════════════════════════════════════

Write-Section "Génération de la page liste"

$listContent = @"
// packages/tools/$ToolName/src/routes/list.tsx
'use client'

import { useState } from 'react'
import { use${DisplayName} } from '../hooks/use${DisplayName}'
import type { ${DisplayName}Filters } from '../types'

export function ${DisplayName}List() {
  const [filters, setFilters] = useState<${DisplayName}Filters>({})
  const { data, loading, error"@

if ($features.pagination) {
    $listContent += @"
, totalCount, totalPages"@
}

$listContent += @"
 } = use${DisplayName}(filters)

  if (loading) {
    return (
      <div className="p-6">
        <div className="animate-pulse">Chargement...</div>
      </div>
    )
  }

  if (error) {
    return (
      <div className="p-6">
        <div className="bg-red-50 text-red-600 p-4 rounded-lg">
          Erreur : {error}
        </div>
      </div>
    )
  }

  return (
    <div className="p-6">
      <div className="flex justify-between items-center mb-6">
        <h1 className="text-2xl font-bold">$DisplayName</h1>
"@

if ($features.create) {
    $listContent += @"

        <a
          href="/$ToolName/new"
          className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700"
        >
          Nouveau
        </a>
"@
}

$listContent += @"

      </div>
"@

if ($features.search) {
    $listContent += @"


      {/* Barre de recherche */}
      <div className="mb-6">
        <input
          type="text"
          placeholder="Rechercher..."
          value={filters.search || ''}
          onChange={(e) => setFilters({ ...filters, search: e.target.value })}
          className="w-full px-4 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500"
        />
      </div>
"@
}

$listContent += @"


      {/* Tableau */}
      <div className="bg-white rounded-lg shadow overflow-hidden">
        <table className="w-full">
          <thead className="bg-gray-50">
            <tr>
"@

foreach ($col in $listColumns) {
    $listContent += @"

              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                $col
              </th>
"@
}

$listContent += @"

              <th className="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">
                Actions
              </th>
            </tr>
          </thead>
          <tbody className="bg-white divide-y divide-gray-200">
            {data.map((item) => (
              <tr key={item.id}>
"@

foreach ($col in $listColumns) {
    $listContent += @"

                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                  {item.$col}
                </td>
"@
}

$listContent += @"

                <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
"@

if ($features.edit) {
    $listContent += @"

                  <a
                    href={`/$ToolName/$\{item.id}`}
                    className="text-blue-600 hover:text-blue-900 mr-4"
                  >
                    Éditer
                  </a>
"@
}

if ($features.delete) {
    $listContent += @"

                  <button
                    onClick={() => handleDelete(item.id)}
                    className="text-red-600 hover:text-red-900"
                  >
                    Supprimer
                  </button>
"@
}

$listContent += @"

                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
"@

if ($features.pagination) {
    $listContent += @"


      {/* Pagination */}
      <div className="mt-6 flex items-center justify-between">
        <div className="text-sm text-gray-700">
          Affichage de {((filters.page || 1) - 1) * (filters.pageSize || 20) + 1} à{' '}
          {Math.min((filters.page || 1) * (filters.pageSize || 20), totalCount)} sur {totalCount} résultats
        </div>
        
        <div className="flex gap-2">
          <button
            onClick={() => setFilters({ ...filters, page: (filters.page || 1) - 1 })}
            disabled={(filters.page || 1) <= 1}
            className="px-4 py-2 border rounded-lg hover:bg-gray-50 disabled:opacity-50"
          >
            Précédent
          </button>
          
          <button
            onClick={() => setFilters({ ...filters, page: (filters.page || 1) + 1 })}
            disabled={(filters.page || 1) >= totalPages}
            className="px-4 py-2 border rounded-lg hover:bg-gray-50 disabled:opacity-50"
          >
            Suivant
          </button>
        </div>
      </div>
"@
}

if ($features.delete) {
    $listContent += @"


  async function handleDelete(id: string) {
    if (!confirm('Êtes-vous sûr de vouloir supprimer cet élément ?')) {
      return
    }
    
    try {
      const response = await fetch(`/api/admin/$ToolName/$\{id}`, {
        method: 'DELETE',
      })
      
      if (!response.ok) throw new Error('Failed to delete')
      
      // Recharger la liste
      window.location.reload()
    } catch (error) {
      console.error('Erreur:', error)
      alert('Erreur lors de la suppression')
    }
  }
"@
}

$listContent += @"

    </div>
  )
}
"@

Set-Content -Path "$TOOL_PATH\src\routes\list.tsx" -Value $listContent
Write-Success "Page liste générée"

# ═══════════════════════════════════════════════════════════
# GÉNÉRATION DES PAGES EDIT ET NEW
# ═══════════════════════════════════════════════════════════

if ($features.edit) {
    Write-Section "Génération de la page édition"
    
    $editContent = @"
// packages/tools/$ToolName/src/routes/edit.tsx
'use client'

import { useState, useEffect } from 'react'
import { ${DisplayName}Form } from '../components/${DisplayName}Form'
import type { ${DisplayName}Item, ${DisplayName}FormData } from '../types'

interface ${DisplayName}EditProps {
  id: string
}

export function ${DisplayName}Edit({ id }: ${DisplayName}EditProps) {
  const [data, setData] = useState<${DisplayName}Item | null>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    async function fetchData() {
      try {
        const response = await fetch(`/api/admin/$ToolName/$\{id}`)
        if (!response.ok) throw new Error('Failed to fetch')
        
        const result = await response.json()
        setData(result)
      } catch (error) {
        console.error('Erreur:', error)
      } finally {
        setLoading(false)
      }
    }

    fetchData()
  }, [id])

  const handleSubmit = async (formData: ${DisplayName}FormData) => {
    const response = await fetch(`/api/admin/$ToolName/$\{id}`, {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(formData),
    })

    if (!response.ok) throw new Error('Failed to update')
    
    // Redirection après succès
    window.location.href = '/$ToolName'
  }

  if (loading) {
    return <div className="p-6">Chargement...</div>
  }

  if (!data) {
    return <div className="p-6">Élément introuvable</div>
  }

  return (
    <div className="p-6">
      <h1 className="text-2xl font-bold mb-6">Éditer $DisplayName</h1>
      
      <div className="bg-white rounded-lg shadow p-6">
        <${DisplayName}Form
          initialData={data}
          onSubmit={handleSubmit}
          onCancel={() => window.location.href = '/$ToolName'}
        />
      </div>
    </div>
  )
}
"@
    
    Set-Content -Path "$TOOL_PATH\src\routes\edit.tsx" -Value $editContent
    Write-Success "Page édition générée"
}

if ($features.create) {
    Write-Section "Génération de la page création"
    
    $newContent = @"
// packages/tools/$ToolName/src/routes/new.tsx
'use client'

import { ${DisplayName}Form } from '../components/${DisplayName}Form'
import type { ${DisplayName}FormData } from '../types'

export function ${DisplayName}New() {
  const handleSubmit = async (formData: ${DisplayName}FormData) => {
    const response = await fetch('/api/admin/$ToolName', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(formData),
    })

    if (!response.ok) throw new Error('Failed to create')
    
    // Redirection après succès
    window.location.href = '/$ToolName'
  }

  return (
    <div className="p-6">
      <h1 className="text-2xl font-bold mb-6">Nouveau $DisplayName</h1>
      
      <div className="bg-white rounded-lg shadow p-6">
        <${DisplayName}Form
          onSubmit={handleSubmit}
          onCancel={() => window.location.href = '/$ToolName'}
        />
      </div>
    </div>
  )
}
"@
    
    Set-Content -Path "$TOOL_PATH\src\routes\new.tsx" -Value $newContent
    Write-Success "Page création générée"
}

# ═══════════════════════════════════════════════════════════
# MISE À JOUR DU INDEX.TSX
# ═══════════════════════════════════════════════════════════

Write-Section "Mise à jour des exports"

$indexContent = @"
// packages/tools/$ToolName/src/index.tsx
// Exports générés automatiquement

// Routes
export { ${DisplayName}List } from './routes/list'
"@

if ($features.edit) {
    $indexContent += "export { ${DisplayName}Edit } from './routes/edit'`n"
}

if ($features.create) {
    $indexContent += "export { ${DisplayName}New } from './routes/new'`n"
}

$indexContent += @"

// Composants
export { ${DisplayName}Form } from './components/${DisplayName}Form'

// Hooks
export { use${DisplayName} } from './hooks/use${DisplayName}'

// Types
export type * from './types'
"@

Set-Content -Path "$TOOL_PATH\src\index.tsx" -Value $indexContent
Write-Success "Exports mis à jour"

# ═══════════════════════════════════════════════════════════
# GÉNÉRATION D'UNE MIGRATION SUPABASE
# ═══════════════════════════════════════════════════════════

Write-Section "Génération de la migration Supabase"

$migrationContent = @"
-- Migration pour la table $tableName
-- Générée automatiquement le $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')

CREATE TABLE IF NOT EXISTS $tableName (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
"@

foreach ($field in $fields) {
    $sqlType = switch -Regex ($field.type) {
        "^text" { "TEXT" }
        "^textarea" { "TEXT" }
        "^number" { "NUMERIC" }
        "^boolean" { "BOOLEAN" }
        "^date" { "DATE" }
        "^select" { "TEXT" }
        "^relation" { "UUID" }
        default { "TEXT" }
    }
    
    $notNull = if ($field.required) { " NOT NULL" } else { "" }
    $migrationContent += "`n  $($field.name) $sqlType$notNull,"
}

$migrationContent = $migrationContent.TrimEnd(',')

$migrationContent += @"


);

-- Index sur created_at pour optimiser les tris
CREATE INDEX idx_${tableName}_created_at ON $tableName(created_at DESC);

-- Trigger pour mettre à jour updated_at automatiquement
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS `$`$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
`$`$ LANGUAGE plpgsql;

CREATE TRIGGER update_${tableName}_updated_at
  BEFORE UPDATE ON $tableName
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Row Level Security (RLS)
ALTER TABLE $tableName ENABLE ROW LEVEL SECURITY;

-- Policy : Admins peuvent tout faire
CREATE POLICY "${tableName}_admin_all" ON $tableName
  FOR ALL
  USING (auth.jwt() ->> 'role' = 'admin')
  WITH CHECK (auth.jwt() ->> 'role' = 'admin');

-- Policy : Utilisateurs authentifiés peuvent lire
CREATE POLICY "${tableName}_authenticated_read" ON $tableName
  FOR SELECT
  USING (auth.role() = 'authenticated');
"@

$migrationPath = "$MONOREPO_ROOT\migrations"
New-Item -ItemType Directory -Path $migrationPath -Force | Out-Null
$migrationFile = "$migrationPath\$(Get-Date -Format 'yyyyMMdd_HHmmss')_create_${tableName}.sql"
Set-Content -Path $migrationFile -Value $migrationContent
Write-Success "Migration SQL générée : $migrationFile"

# ═══════════════════════════════════════════════════════════
# GÉNÉRATION DE LA DOCUMENTATION
# ═══════════════════════════════════════════════════════════

Write-Section "Génération de la documentation"

# ───────────────────────────────────────────────────────────
# README.md (Vue d'ensemble)
# ───────────────────────────────────────────────────────────

$readmeContent = @"
# Tool $DisplayName

> **Généré automatiquement** : $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')  
> **Type** : $dataType  
> **Table** : ``$tableName``

---

## 📋 Vue d'ensemble

Ce tool gère les données de type **$dataType** stockées dans la table ``$tableName``.

### Fonctionnalités

"@

$features.GetEnumerator() | ForEach-Object {
    $icon = if ($_.Value) { "✅" } else { "❌" }
    $readmeContent += "- $icon $($_.Key)`n"
}

$readmeContent += @"


### Champs ($($fields.Count))

| Champ | Type | Obligatoire | Description |
|-------|------|-------------|-------------|
"@

foreach ($field in $fields) {
    $req = if ($field.required) { "✅ Oui" } else { "❌ Non" }
    $desc = switch -Regex ($field.type) {
        "^text" { "Texte court" }
        "^textarea" { "Texte long" }
        "^number" { "Nombre" }
        "^boolean" { "Oui/Non" }
        "^date" { "Date" }
        "^select" { "Liste déroulante" }
        "^relation" { "Relation à une autre table" }
        default { "Texte" }
    }
    $readmeContent += "`n| ``$($field.name)`` | $($field.type) | $req | $desc |"
}

$readmeContent += @"


### Colonnes affichées dans la liste

"@

$listColumns | ForEach-Object { $readmeContent += "- ``$_```n" }

$readmeContent += @"


---

## 🚀 Démarrage rapide

### 1. Appliquer la migration

``````bash
# Via Supabase Dashboard
# Copiez le contenu de migrations/...create_${tableName}.sql

# Ou via Supabase CLI
supabase db push
``````

### 2. Tester le tool

``````bash
pnpm dev
# Ouvrir : http://localhost:3000/$ToolName
``````

### 3. Importer dans votre code

``````typescript
import { 
  ${DisplayName}List,
"@

if ($features.edit) { $readmeContent += "`n  ${DisplayName}Edit," }
if ($features.create) { $readmeContent += "`n  ${DisplayName}New," }

$readmeContent += @"

  ${DisplayName}Form,
  use${DisplayName},
  type ${DisplayName}Item,
  type ${DisplayName}FormData
} from '@repo/tools-$ToolName'
``````

---

## 📁 Architecture

``````
packages/tools/$ToolName/
├── src/
│   ├── index.tsx              # Point d'entrée (exports)
│   ├── types/
│   │   └── index.ts           # Types TypeScript
│   ├── hooks/
│   │   └── use${DisplayName}.ts  # Hook principal
│   ├── components/
│   │   └── ${DisplayName}Form.tsx  # Formulaire
│   └── routes/
│       ├── list.tsx           # Page liste
│       ├── edit.tsx           # Page édition
│       └── new.tsx            # Page création
├── package.json
├── tsconfig.json
├── README.md                  # Ce fichier
└── DEVELOPER-GUIDE.md         # Guide développeur
``````

---

## 🔌 API Routes

| Méthode | Route | Description |
|---------|-------|-------------|
| GET | ``/api/admin/$ToolName`` | Liste avec filtres/pagination |
| POST | ``/api/admin/$ToolName`` | Créer un élément |
| GET | ``/api/admin/$ToolName/[id]`` | Récupérer un élément |
| PUT | ``/api/admin/$ToolName/[id]`` | Mettre à jour un élément |
| DELETE | ``/api/admin/$ToolName/[id]`` | Supprimer un élément |

### Paramètres de requête (GET liste)

- ``search`` : Recherche textuelle
- ``page`` : Numéro de page (pagination)
- ``pageSize`` : Nombre d'éléments par page
- ``sortBy`` : Champ pour le tri
- ``sortOrder`` : ``asc`` ou ``desc``

---

## 🛠️ Personnalisation

### Ajouter une validation

``````typescript
// src/components/${DisplayName}Form.tsx

const handleSubmit = async (e: React.FormEvent) => {
  e.preventDefault()
  
  // ✅ Ajouter vos validations ici
  if (formData.some_field.length < 3) {
    alert('Le champ doit contenir au moins 3 caractères')
    return
  }
  
  setLoading(true)
  // ...
}
``````

### Ajouter un composant

``````bash
# Créer un nouveau composant
touch packages/tools/$ToolName/src/components/MyComponent.tsx
``````

``````typescript
// src/components/MyComponent.tsx
export function MyComponent() {
  return <div>Mon composant</div>
}

// src/index.tsx
export { MyComponent } from './components/MyComponent'
``````

### Modifier la liste

``````typescript
// src/routes/list.tsx

// Ajouter une colonne
<th>Ma nouvelle colonne</th>

// Ajouter des filtres
const [statusFilter, setStatusFilter] = useState('')
``````

---

## ✅ Tests & Validation

``````bash
# Type-check
pnpm --filter @repo/tools-$ToolName type-check

# Build
pnpm --filter @repo/tools-$ToolName build

# Validation complète
.\scripts\validate-tool.ps1 -ToolName $ToolName

# Linter
pnpm --filter @repo/tools-$ToolName lint
``````

---

## 📚 Documentation développeur

Pour plus de détails techniques, consultez **[DEVELOPER-GUIDE.md](./DEVELOPER-GUIDE.md)**.

---

## 🐛 Dépannage

### Le tool ne s'affiche pas

1. Vérifier que la migration SQL a été appliquée
2. Vérifier les logs de la console
3. Valider le tool : ``.\scripts\validate-tool.ps1 -ToolName $ToolName``

### Erreur TypeScript

``````bash
pnpm --filter @repo/tools-$ToolName type-check
``````

### Le formulaire ne soumet pas

Vérifier dans ``src/components/${DisplayName}Form.tsx`` :
- Les champs ``required`` sont bien remplis
- La fonction ``onSubmit`` est bien définie

---

## 🤝 Contribution

Ce tool a été généré automatiquement. Améliorations bienvenues :

1. Créer une branche : ``git checkout -b feature/tool-$ToolName-improvement``
2. Faire vos modifications
3. Valider : ``.\scripts\validate-tool.ps1 -ToolName $ToolName``
4. Commit : ``git commit -m "feat(tools-$ToolName): description"``
5. Push : ``git push``

---

**Généré par** : generate-tool.ps1  
**Date** : $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
"@

Set-Content -Path "$TOOL_PATH\README.md" -Value $readmeContent
Write-Success "README.md généré"

# ───────────────────────────────────────────────────────────
# DEVELOPER-GUIDE.md (Documentation technique complète)
# ───────────────────────────────────────────────────────────

$devGuideContent = @"
# Guide Développeur - Tool $DisplayName

> **Documentation technique complète** pour reprendre et améliorer ce tool  
> **Généré** : $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')

---

## 📚 Table des matières

1. [Architecture du code](#architecture-du-code)
2. [Types TypeScript](#types-typescript)
3. [Hook personnalisé](#hook-personnalisé)
4. [Composants](#composants)
5. [Routes](#routes)
6. [API](#api)
7. [Base de données](#base-de-données)
8. [Patterns utilisés](#patterns-utilisés)
9. [Améliorer le tool](#améliorer-le-tool)

---

## 🏗️ Architecture du code

### Séparation des responsabilités

``````
packages/tools/$ToolName/src/
├── types/           # Définitions TypeScript
├── hooks/           # Logique de récupération données
├── components/      # Composants UI réutilisables
└── routes/          # Pages complètes (RSC + Client)
``````

### Principe : Séparation logique/présentation

- **types/** : Définit la structure des données
- **hooks/** : Contient la logique métier (fetch, state management)
- **components/** : UI pure, reçoit des props, n'a pas de logique métier
- **routes/** : Combine hooks + components pour créer des pages complètes

---

## 📐 Types TypeScript

### Fichier : \`src/types/index.ts\`

#### Type principal : ${DisplayName}Item

``````typescript
export interface ${DisplayName}Item {
  id: string
  created_at: string
  updated_at: string
"@

foreach ($field in $fields) {
    $tsType = switch -Regex ($field.type) {
        "^text" { "string" }
        "^textarea" { "string" }
        "^number" { "number" }
        "^boolean" { "boolean" }
        "^date" { "string" }
        "^select" { "string" }
        "^relation" { "string" }
        default { "string" }
    }
    $optional = if ($field.required) { "" } else { "?" }
    $devGuideContent += "`n  $($field.name)$optional: $tsType"
}

$devGuideContent += @"

}
``````

**Utilisation** :

``````typescript
import type { ${DisplayName}Item } from '@repo/tools-$ToolName'

const item: ${DisplayName}Item = {
  id: 'uuid',
  created_at: '2025-11-03T...',
  updated_at: '2025-11-03T...',
"@

foreach ($field in $fields) {
    $defaultValue = switch -Regex ($field.type) {
        "^text" { "'valeur'" }
        "^textarea" { "'valeur longue'" }
        "^number" { "0" }
        "^boolean" { "true" }
        "^date" { "'2025-11-03'" }
        "^select" { "'option'" }
        "^relation" { "'uuid'" }
        default { "'valeur'" }
    }
    $devGuideContent += "`n  $($field.name): $defaultValue,"
}

$devGuideContent += @"

}
``````

#### Type formulaire : ${DisplayName}FormData

Utilisé pour les données du formulaire (sans id, created_at, updated_at).

``````typescript
export interface ${DisplayName}FormData {
"@

foreach ($field in $fields) {
    $tsType = switch -Regex ($field.type) {
        "^text" { "string" }
        "^textarea" { "string" }
        "^number" { "number" }
        "^boolean" { "boolean" }
        "^date" { "string" }
        "^select" { "string" }
        "^relation" { "string" }
        default { "string" }
    }
    $devGuideContent += "`n  $($field.name): $tsType"
}

$devGuideContent += @"

}
``````

#### Type filtres : ${DisplayName}Filters

Utilisé pour les filtres de recherche et pagination.

``````typescript
export interface ${DisplayName}Filters {
  search?: string
  sortBy?: keyof ${DisplayName}Item
  sortOrder?: 'asc' | 'desc'
"@

if ($features.pagination) {
    $devGuideContent += @"

  page?: number
  pageSize?: number
"@
}

$devGuideContent += @"

}
``````

---

## 🎣 Hook personnalisé

### Fichier : \`src/hooks/use${DisplayName}.ts\`

#### Signature

``````typescript
function use${DisplayName}(filters?: ${DisplayName}Filters): {
  data: ${DisplayName}Item[]
  loading: boolean
  error: string | null
"@

if ($features.pagination) {
    $devGuideContent += @"

  totalCount: number
  totalPages: number
"@
}

$devGuideContent += @"

}
``````

#### Fonctionnement

1. **Initialisation du state** : data, loading, error
2. **useEffect** : Se déclenche quand les filtres changent
3. **Fetch API** : Appelle \`/api/admin/$ToolName\` avec query params
4. **Mise à jour du state** : Avec les données récupérées

#### Utilisation dans un composant

``````typescript
'use client'

import { use${DisplayName} } from '@repo/tools-$ToolName'

export function MyComponent() {
  const [filters, setFilters] = useState<${DisplayName}Filters>({
    search: '',
    page: 1,
    pageSize: 20
  })
  
  const { data, loading, error } = use${DisplayName}(filters)
  
  if (loading) return <div>Chargement...</div>
  if (error) return <div>Erreur : {error}</div>
  
  return (
    <div>
      {data.map(item => (
        <div key={item.id}>{item.name}</div>
      ))}
    </div>
  )
}
``````

#### Personnalisation

**Ajouter un filtre personnalisé** :

``````typescript
// Dans use${DisplayName}.ts

// 1. Ajouter au type Filters
export interface ${DisplayName}Filters {
  // ... existant
  customFilter?: string  // ✅ Nouveau filtre
}

// 2. Utiliser dans le useEffect
if (filters?.customFilter) {
  url.searchParams.set('customFilter', filters.customFilter)
}
``````

---

## 🧩 Composants

### ${DisplayName}Form

**Fichier** : \`src/components/${DisplayName}Form.tsx\`

**Props** :

``````typescript
interface ${DisplayName}FormProps {
  initialData?: ${DisplayName}FormData  // Données initiales (mode édition)
  onSubmit: (data: ${DisplayName}FormData) => Promise<void>  // Callback soumission
  onCancel?: () => void  // Callback annulation
}
``````

**État interne** :

- \`formData\` : État du formulaire
- \`loading\` : État de soumission

**Validation** :

Par défaut, validation HTML5 avec \`required\`.

**Ajouter une validation custom** :

``````typescript
const handleSubmit = async (e: React.FormEvent) => {
  e.preventDefault()
  
  // ✅ Validation personnalisée
  if (!formData.some_field.trim()) {
    alert('Le champ ne peut pas être vide')
    return
  }
  
  if (formData.some_number < 0) {
    alert('Le nombre doit être positif')
    return
  }
  
  setLoading(true)
  try {
    await onSubmit(formData)
  } catch (error) {
    console.error('Erreur:', error)
    alert('Erreur lors de l\'enregistrement')
  } finally {
    setLoading(false)
  }
}
``````

**Ajouter un champ** :

``````typescript
// 1. Ajouter au type FormData
export interface ${DisplayName}FormData {
  // ... existant
  new_field: string  // ✅ Nouveau champ
}

// 2. Ajouter au state initial
const [formData, setFormData] = useState<${DisplayName}FormData>({
  // ... existant
  new_field: initialData?.new_field || ''  // ✅ Avec fallback
})

// 3. Ajouter dans le JSX
<div>
  <label>Nouveau champ</label>
  <input
    type="text"
    value={formData.new_field}
    onChange={(e) => setFormData({ ...formData, new_field: e.target.value })}
    className="..."
  />
</div>
``````

---

## 🗺️ Routes

### Liste : \`src/routes/list.tsx\`

**Responsabilités** :

- Afficher la liste des éléments
- Gérer la recherche et les filtres
- Gérer la pagination
- Actions (éditer, supprimer)

**Structure** :

``````typescript
'use client'

export function ${DisplayName}List() {
  // 1. State des filtres
  const [filters, setFilters] = useState<${DisplayName}Filters>({})
  
  // 2. Hook pour récupérer les données
  const { data, loading, error } = use${DisplayName}(filters)
  
  // 3. Gestion du chargement
  if (loading) return <div>Chargement...</div>
  if (error) return <div>Erreur : {error}</div>
  
  // 4. Rendu : Header + Recherche + Tableau + Pagination
  return (
    <div className="p-6">
      {/* Header avec bouton "Nouveau" */}
      {/* Barre de recherche */}
      {/* Tableau de données */}
      {/* Pagination */}
    </div>
  )
}
``````

**Personnaliser l'affichage** :

``````typescript
// Ajouter une colonne
<th>Nouvelle colonne</th>

// Dans le tbody
<td>{item.new_field}</td>

// Ajouter un badge de statut
<td>
  <span className={\`badge \${item.is_active ? 'badge-success' : 'badge-gray'}\`}>
    {item.is_active ? 'Actif' : 'Inactif'}
  </span>
</td>
``````

### Édition : \`src/routes/edit.tsx\`

**Responsabilités** :

- Charger les données d'un élément existant
- Afficher le formulaire pré-rempli
- Soumettre les modifications

**Pattern** :

``````typescript
'use client'

export function ${DisplayName}Edit({ id }: { id: string }) {
  const [data, setData] = useState<${DisplayName}Item | null>(null)
  const [loading, setLoading] = useState(true)

  // 1. Charger les données au mount
  useEffect(() => {
    async function fetchData() {
      const response = await fetch(\`/api/admin/$ToolName/\${id}\`)
      const result = await response.json()
      setData(result)
      setLoading(false)
    }
    fetchData()
  }, [id])

  // 2. Handler de soumission
  const handleSubmit = async (formData: ${DisplayName}FormData) => {
    await fetch(\`/api/admin/$ToolName/\${id}\`, {
      method: 'PUT',
      body: JSON.stringify(formData)
    })
    window.location.href = '/$ToolName'
  }

  // 3. Rendu
  if (loading) return <div>Chargement...</div>
  if (!data) return <div>Élément introuvable</div>

  return (
    <div className="p-6">
      <h1>Éditer ${DisplayName}</h1>
      <${DisplayName}Form
        initialData={data}
        onSubmit={handleSubmit}
        onCancel={() => window.location.href = '/$ToolName'}
      />
    </div>
  )
}
``````

### Création : \`src/routes/new.tsx\`

**Responsabilités** :

- Afficher le formulaire vide
- Créer un nouvel élément

**Pattern** :

``````typescript
'use client'

export function ${DisplayName}New() {
  const handleSubmit = async (formData: ${DisplayName}FormData) => {
    await fetch('/api/admin/$ToolName', {
      method: 'POST',
      body: JSON.stringify(formData)
    })
    window.location.href = '/$ToolName'
  }

  return (
    <div className="p-6">
      <h1>Nouveau ${DisplayName}</h1>
      <${DisplayName}Form
        onSubmit={handleSubmit}
        onCancel={() => window.location.href = '/$ToolName'}
      />
    </div>
  )
}
``````

---

## 🔌 API

### Routes générées

| Route | Méthode | Fichier | Description |
|-------|---------|---------|-------------|
| \`/api/admin/$ToolName\` | GET | \`route.ts\` | Liste avec filtres |
| \`/api/admin/$ToolName\` | POST | \`route.ts\` | Créer |
| \`/api/admin/$ToolName/[id]\` | GET | \`[id]/route.ts\` | Lire |
| \`/api/admin/$ToolName/[id]\` | PUT | \`[id]/route.ts\` | Mettre à jour |
| \`/api/admin/$ToolName/[id]\` | DELETE | \`[id]/route.ts\` | Supprimer |

### Ajouter une route API personnalisée

**Exemple : Route d'export CSV**

``````typescript
// apps/admin/app/api/admin/$ToolName/export/route.ts

import { NextResponse } from 'next/server'
import { supabaseAdmin } from '@repo/database'

export async function GET() {
  const { data, error } = await supabaseAdmin
    .from('$tableName')
    .select('*')
  
  if (error) {
    return NextResponse.json({ error: error.message }, { status: 500 })
  }
  
  // Générer CSV
  const csv = data.map(item => Object.values(item).join(',')).join('\\n')
  
  return new Response(csv, {
    headers: {
      'Content-Type': 'text/csv',
      'Content-Disposition': 'attachment; filename="export.csv"'
    }
  })
}
``````

**Utiliser dans le frontend** :

``````typescript
<button onClick={() => window.location.href = '/api/admin/$ToolName/export'}>
  Exporter CSV
</button>
``````

---

## 🗄️ Base de données

### Table : \`$tableName\`

**Colonnes** :

| Colonne | Type | Contraintes | Description |
|---------|------|-------------|-------------|
| \`id\` | UUID | PRIMARY KEY | Identifiant unique |
| \`created_at\` | TIMESTAMPTZ | NOT NULL | Date de création |
| \`updated_at\` | TIMESTAMPTZ | NOT NULL | Date de modification |
"@

foreach ($field in $fields) {
    $sqlType = switch -Regex ($field.type) {
        "^text" { "TEXT" }
        "^textarea" { "TEXT" }
        "^number" { "NUMERIC" }
        "^boolean" { "BOOLEAN" }
        "^date" { "DATE" }
        "^select" { "TEXT" }
        "^relation" { "UUID" }
        default { "TEXT" }
    }
    $constraint = if ($field.required) { "NOT NULL" } else { "NULL" }
    $devGuideContent += "`n| ``$($field.name)`` | $sqlType | $constraint | - |"
}

$devGuideContent += @"


### Index

- \`idx_${tableName}_created_at\` : Optimise les tris par date

### Triggers

- \`update_${tableName}_updated_at\` : Met à jour automatiquement \`updated_at\`

### Row Level Security (RLS)

- **Admins** : Accès complet (CRUD)
- **Authentifiés** : Lecture seule (SELECT)

**Modifier les policies** :

``````sql
-- Permettre aux users authentifiés de créer
CREATE POLICY "${tableName}_authenticated_insert" ON $tableName
  FOR INSERT
  USING (auth.role() = 'authenticated')
  WITH CHECK (auth.role() = 'authenticated');
``````

---

## 🎨 Patterns utilisés

### Client Components

Tous les composants avec interactivité utilisent \`'use client'\`.

**Quand utiliser 'use client'** :

- useState, useEffect
- Event handlers (onClick, onChange)
- Hooks personnalisés

### Server Components

Par défaut, les pages sont des Server Components.

**Avantages** :

- Fetch data côté serveur
- Pas de JavaScript envoyé au client
- Meilleure performance

### Pattern Container/Presenter

- **Container** (routes) : Gère l'état et la logique
- **Presenter** (components) : Affiche l'UI

### Hooks personnalisés

Logique réutilisable extraite dans des hooks.

**Exemple : Debounce search**

``````typescript
// src/hooks/useDebounce.ts
export function useDebounce<T>(value: T, delay: number): T {
  const [debouncedValue, setDebouncedValue] = useState(value)
  
  useEffect(() => {
    const timer = setTimeout(() => setDebouncedValue(value), delay)
    return () => clearTimeout(timer)
  }, [value, delay])
  
  return debouncedValue
}

// Utilisation
const debouncedSearch = useDebounce(filters.search, 300)
``````

---

## 🚀 Améliorer le tool

### 1. Ajouter des validations avancées

**Avec Zod** :

``````bash
pnpm add zod
``````

``````typescript
// src/validation/schema.ts
import { z } from 'zod'

export const ${DisplayName}Schema = z.object({
"@

foreach ($field in $fields) {
    $zodType = switch -Regex ($field.type) {
        "^text" { "z.string().min(1, 'Requis')" }
        "^textarea" { "z.string().min(10, 'Min 10 caractères')" }
        "^number" { "z.number().positive('Doit être positif')" }
        "^boolean" { "z.boolean()" }
        "^date" { "z.string().datetime()" }
        "^select" { "z.enum(['option1', 'option2'])" }
        default { "z.string()" }
    }
    if ($field.required) {
        $devGuideContent += "`n  $($field.name): $zodType,"
    } else {
        $devGuideContent += "`n  $($field.name): $zodType.optional(),"
    }
}

$devGuideContent += @"

})

// Dans le formulaire
const result = ${DisplayName}Schema.safeParse(formData)
if (!result.success) {
  console.error(result.error)
  return
}
``````

### 2. Ajouter des tests

``````bash
pnpm add -D vitest @testing-library/react
``````

``````typescript
// src/__tests__/use${DisplayName}.test.ts
import { renderHook, waitFor } from '@testing-library/react'
import { use${DisplayName} } from '../hooks/use${DisplayName}'

describe('use${DisplayName}', () => {
  it('devrait charger les données', async () => {
    const { result } = renderHook(() => use${DisplayName}())
    
    expect(result.current.loading).toBe(true)
    
    await waitFor(() => {
      expect(result.current.loading).toBe(false)
    })
    
    expect(result.current.data).toHaveLength(5)
  })
})
``````

### 3. Ajouter un composant de statistiques

``````typescript
// src/components/${DisplayName}Stats.tsx
'use client'

import { use${DisplayName} } from '../hooks/use${DisplayName}'

export function ${DisplayName}Stats() {
  const { data } = use${DisplayName}()
  
  const stats = {
    total: data.length,
    active: data.filter(item => item.is_active).length,
  }
  
  return (
    <div className="grid grid-cols-2 gap-4 mb-6">
      <div className="bg-white p-4 rounded-lg shadow">
        <h3 className="text-sm text-gray-600">Total</h3>
        <p className="text-2xl font-bold">{stats.total}</p>
      </div>
      <div className="bg-white p-4 rounded-lg shadow">
        <h3 className="text-sm text-gray-600">Actifs</h3>
        <p className="text-2xl font-bold">{stats.active}</p>
      </div>
    </div>
  )
}

// Utiliser dans list.tsx
import { ${DisplayName}Stats } from '../components/${DisplayName}Stats'

export function ${DisplayName}List() {
  return (
    <div>
      <${DisplayName}Stats />
      {/* ... reste */}
    </div>
  )
}
``````

### 4. Ajouter l'export CSV/Excel

``````bash
pnpm add papaparse
pnpm add -D @types/papaparse
``````

``````typescript
// src/components/${DisplayName}ExportButton.tsx
'use client'

import Papa from 'papaparse'
import { use${DisplayName} } from '../hooks/use${DisplayName}'

export function ${DisplayName}ExportButton() {
  const { data } = use${DisplayName}()
  
  const handleExport = () => {
    const csv = Papa.unparse(data)
    const blob = new Blob([csv], { type: 'text/csv' })
    const url = URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = url
    a.download = '$ToolName-export.csv'
    a.click()
  }
  
  return (
    <button onClick={handleExport} className="btn">
      Exporter CSV
    </button>
  )
}
``````

### 5. Ajouter un système de notifications

``````bash
pnpm add sonner
``````

``````typescript
// Dans le formulaire
import { toast } from 'sonner'

const handleSubmit = async (formData: ${DisplayName}FormData) => {
  try {
    await onSubmit(formData)
    toast.success('Enregistré avec succès')
  } catch (error) {
    toast.error('Erreur lors de l\'enregistrement')
  }
}
``````

---

## 📖 Ressources

- **Monorepo Architecture** : \`docs/20251103-ARCHITECTURE-BONNES-PRATIQUES-TOOLS.md\`
- **Next.js 15** : https://nextjs.org/docs
- **Supabase** : https://supabase.com/docs
- **TypeScript** : https://www.typescriptlang.org/docs

---

## ✅ Checklist avant déploiement

- [ ] Tests écrits et passent
- [ ] Type-check OK
- [ ] Lint OK
- [ ] Build OK
- [ ] Migration SQL appliquée
- [ ] RLS policies testées
- [ ] Documentation à jour

---

**Généré par** : generate-tool.ps1  
**Date** : $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')  
**Version** : 1.0
"@

Set-Content -Path "$TOOL_PATH\DEVELOPER-GUIDE.md" -Value $devGuideContent
Write-Success "DEVELOPER-GUIDE.md généré"

# ═══════════════════════════════════════════════════════════
# RÉSUMÉ FINAL
# ═══════════════════════════════════════════════════════════

Write-Title "✅ GÉNÉRATION TERMINÉE"

Write-Host "`n📁 Fichiers générés :" -ForegroundColor Cyan
Write-Host "   • packages/tools/$ToolName/src/types/index.ts" -ForegroundColor White
Write-Host "   • packages/tools/$ToolName/src/hooks/use${DisplayName}.ts" -ForegroundColor White
Write-Host "   • packages/tools/$ToolName/src/components/${DisplayName}Form.tsx" -ForegroundColor White
Write-Host "   • packages/tools/$ToolName/src/routes/list.tsx" -ForegroundColor White

if ($features.edit) {
    Write-Host "   • packages/tools/$ToolName/src/routes/edit.tsx" -ForegroundColor White
}

if ($features.create) {
    Write-Host "   • packages/tools/$ToolName/src/routes/new.tsx" -ForegroundColor White
}

Write-Host "   • packages/tools/$ToolName/src/index.tsx" -ForegroundColor White
Write-Host "   • packages/tools/$ToolName/README.md" -ForegroundColor White
Write-Host "   • migrations/$(Get-Date -Format 'yyyyMMdd_HHmmss')_create_${tableName}.sql" -ForegroundColor White

Write-Host "`n🚀 Prochaines étapes :" -ForegroundColor Cyan
Write-Host "   1. Appliquer la migration Supabase" -ForegroundColor White
Write-Host "   2. Lancer : pnpm dev" -ForegroundColor White
Write-Host "   3. Ouvrir : http://localhost:3000/$ToolName" -ForegroundColor White
Write-Host "   4. Personnaliser le code selon vos besoins" -ForegroundColor White

Write-Host "`n💡 Documentation :" -ForegroundColor Cyan
Write-Host "   • Voir packages/tools/$ToolName/README.md" -ForegroundColor White

Write-Host ""
