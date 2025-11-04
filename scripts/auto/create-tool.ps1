# scripts/create-tool.ps1
<#
.SYNOPSIS
    Crée un nouveau tool complet dans le monorepo avec structure validée

.DESCRIPTION
    Génère automatiquement :
    - Structure packages/tools/{tool}
    - Fichiers de base (package.json, tsconfig.json, index.tsx)
    - Routes (list, edit, new)
    - Wrappers dans apps/admin/app/(tools)/{tool}
    - Intégration dans next.config.ts
    - Installation des dépendances

.PARAMETER ToolName
    Nom du tool en kebab-case (ex: products, newsletter, analytics)

.PARAMETER DisplayName
    Nom d'affichage en PascalCase (ex: Products, Newsletter, Analytics)
    Si omis, sera généré depuis ToolName

.PARAMETER Description
    Description du tool (apparaîtra dans package.json)

.PARAMETER WithAPI
    Ajouter des routes API dans apps/admin/app/api/admin/{tool}

.PARAMETER Minimal
    Créer une structure minimale (juste index.tsx, pas de routes)

.EXAMPLE
    .\scripts\create-tool.ps1 -ToolName analytics
    .\scripts\create-tool.ps1 -ToolName social-media -DisplayName "SocialMedia" -WithAPI
    .\scripts\create-tool.ps1 -ToolName test-tool -Minimal
#>

param(
    [Parameter(Mandatory=$true)]
    [ValidatePattern('^[a-z]+(-[a-z]+)*$')]
    [string]$ToolName,
    
    [Parameter(Mandatory=$false)]
    [string]$DisplayName,
    
    [Parameter(Mandatory=$false)]
    [string]$Description,
    
    [switch]$WithAPI,
    [switch]$Minimal
)

$ErrorActionPreference = "Stop"

# ═══════════════════════════════════════════════════════════
# CONFIGURATION
# ═══════════════════════════════════════════════════════════

$MONOREPO_ROOT = Split-Path -Parent $PSScriptRoot
$TOOLS_DIR = Join-Path $MONOREPO_ROOT "packages\tools"
$ADMIN_DIR = Join-Path $MONOREPO_ROOT "apps\admin"
$TOOL_PATH = Join-Path $TOOLS_DIR $ToolName

# Générer DisplayName si non fourni
if (-not $DisplayName) {
    $DisplayName = ($ToolName -split '-' | ForEach-Object { 
        $_.Substring(0,1).ToUpper() + $_.Substring(1).ToLower() 
    }) -join ''
}

# Description par défaut
if (-not $Description) {
    $Description = "Tool $DisplayName pour l'admin Blanche Renaudin"
}

# Couleurs et helpers
function Write-Step { param([string]$Message) Write-Host "`n🔹 $Message" -ForegroundColor Cyan }
function Write-Success { param([string]$Message) Write-Host "   ✅ $Message" -ForegroundColor Green }
function Write-Warning { param([string]$Message) Write-Host "   ⚠️  $Message" -ForegroundColor Yellow }
function Write-Error { param([string]$Message) Write-Host "   ❌ $Message" -ForegroundColor Red }
function Write-Info { param([string]$Message) Write-Host "   ℹ️  $Message" -ForegroundColor Gray }

Write-Host "`n╔════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  🚀 CRÉATION TOOL: @repo/tools-$ToolName" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

Write-Info "Display Name : $DisplayName"
Write-Info "Description  : $Description"
Write-Info "Mode         : $(if ($Minimal) { 'Minimal' } else { 'Complet' })"
Write-Info "API Routes   : $(if ($WithAPI) { 'Oui' } else { 'Non' })"

# ═══════════════════════════════════════════════════════════
# ÉTAPE 1 : Vérifications préalables
# ═══════════════════════════════════════════════════════════
Write-Step "Étape 1/10 : Vérifications préalables"

# Vérifier que le monorepo existe
if (-Not (Test-Path $MONOREPO_ROOT)) {
    Write-Error "Monorepo introuvable : $MONOREPO_ROOT"
    exit 1
}
Write-Success "Monorepo trouvé"

# Vérifier que pnpm est installé
try {
    $pnpmVersion = pnpm --version
    Write-Success "pnpm installé : v$pnpmVersion"
} catch {
    Write-Error "pnpm non installé. Installez-le avec : npm install -g pnpm"
    exit 1
}

# Vérifier que le tool n'existe pas déjà
if (Test-Path $TOOL_PATH) {
    Write-Error "Le tool existe déjà : $TOOL_PATH"
    Write-Info "Supprimez-le d'abord ou choisissez un autre nom"
    exit 1
}
Write-Success "Nom de tool disponible"

# ═══════════════════════════════════════════════════════════
# ÉTAPE 2 : Créer structure de base
# ═══════════════════════════════════════════════════════════
Write-Step "Étape 2/10 : Création structure packages/tools/$ToolName"

# Créer dossiers
$folders = @(
    $TOOL_PATH,
    "$TOOL_PATH\src",
    "$TOOL_PATH\src\components",
    "$TOOL_PATH\src\types"
)

if (-not $Minimal) {
    $folders += @(
        "$TOOL_PATH\src\routes",
        "$TOOL_PATH\src\hooks"
    )
}

foreach ($folder in $folders) {
    New-Item -ItemType Directory -Path $folder -Force | Out-Null
    Write-Success "Créé : $(Split-Path -Leaf $folder)"
}

# ═══════════════════════════════════════════════════════════
# ÉTAPE 3 : Créer package.json
# ═══════════════════════════════════════════════════════════
Write-Step "Étape 3/10 : Création package.json"

$packageJson = @{
    name = "@repo/tools-$ToolName"
    version = "0.1.0"
    description = $Description
    private = $true
    exports = @{
        "." = "./src/index.tsx"
    }
    scripts = @{
        build = "tsc --noEmit"
        dev = "tsc --noEmit --watch"
        "type-check" = "tsc --noEmit"
        lint = "eslint . --max-warnings 0"
    }
    dependencies = @{
        react = "^19.0.0"
        "react-dom" = "^19.0.0"
    }
    devDependencies = @{
        "@repo/typescript-config" = "workspace:*"
        typescript = "^5.7.2"
    }
} | ConvertTo-Json -Depth 10

Set-Content -Path "$TOOL_PATH\package.json" -Value $packageJson
Write-Success "package.json créé"

# ═══════════════════════════════════════════════════════════
# ÉTAPE 4 : Créer tsconfig.json
# ═══════════════════════════════════════════════════════════
Write-Step "Étape 4/10 : Création tsconfig.json"

$tsconfig = @{
    extends = "@repo/typescript-config/base.json"
    compilerOptions = @{
        outDir = "dist"
        rootDir = "src"
    }
    include = @("src/**/*")
    exclude = @("node_modules", "dist")
} | ConvertTo-Json -Depth 10

Set-Content -Path "$TOOL_PATH\tsconfig.json" -Value $tsconfig
Write-Success "tsconfig.json créé"

# ═══════════════════════════════════════════════════════════
# ÉTAPE 5 : Créer src/index.tsx
# ═══════════════════════════════════════════════════════════
Write-Step "Étape 5/10 : Création src/index.tsx"

if ($Minimal) {
    $indexContent = @"
// packages/tools/$ToolName/src/index.tsx
// ⚠️ IMPORTANT : Extension .tsx obligatoire pour JSX

export function ${DisplayName}Tool() {
  return (
    <div className="p-6">
      <h1 className="text-2xl font-bold mb-4">$DisplayName</h1>
      <p className="text-gray-600">Tool $DisplayName - En développement</p>
    </div>
  )
}
"@
} else {
    $indexContent = @"
// packages/tools/$ToolName/src/index.tsx
// ⚠️ IMPORTANT : Exporter tous les composants utilisés par apps/admin

// Routes principales
export { ${DisplayName}List } from './routes/list'
export { ${DisplayName}Edit } from './routes/edit'
export { ${DisplayName}New } from './routes/new'

// Types (optionnel mais recommandé)
export type * from './types'
"@
}

Set-Content -Path "$TOOL_PATH\src\index.tsx" -Value $indexContent
Write-Success "index.tsx créé"

# ═══════════════════════════════════════════════════════════
# ÉTAPE 6 : Créer routes (mode complet uniquement)
# ═══════════════════════════════════════════════════════════
if (-not $Minimal) {
    Write-Step "Étape 6/10 : Création des routes (list, edit, new)"
    
    # Route LIST
    $listContent = @"
// packages/tools/$ToolName/src/routes/list.tsx
'use client'

import { useState } from 'react'

export function ${DisplayName}List() {
  const [items, setItems] = useState([])

  return (
    <div className="p-6">
      <div className="flex justify-between items-center mb-6">
        <h1 className="text-2xl font-bold">$DisplayName</h1>
        <button className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700">
          Nouveau
        </button>
      </div>
      
      <div className="bg-white rounded-lg shadow">
        <div className="p-4 text-gray-500 text-center">
          Aucun élément pour le moment
        </div>
      </div>
    </div>
  )
}
"@
    Set-Content -Path "$TOOL_PATH\src\routes\list.tsx" -Value $listContent
    Write-Success "list.tsx créé"
    
    # Route EDIT
    $editContent = @"
// packages/tools/$ToolName/src/routes/edit.tsx
'use client'

import { useEffect, useState } from 'react'

interface ${DisplayName}EditProps {
  id: string
}

export function ${DisplayName}Edit({ id }: ${DisplayName}EditProps) {
  const [loading, setLoading] = useState(true)
  const [data, setData] = useState<any>(null)

  useEffect(() => {
    // TODO: Charger les données depuis l'API
    setLoading(false)
  }, [id])

  if (loading) {
    return <div className="p-6">Chargement...</div>
  }

  return (
    <div className="p-6">
      <h1 className="text-2xl font-bold mb-6">Édition $DisplayName</h1>
      <div className="bg-white rounded-lg shadow p-6">
        <p className="text-gray-600">ID: {id}</p>
        {/* TODO: Ajouter formulaire d'édition */}
      </div>
    </div>
  )
}
"@
    Set-Content -Path "$TOOL_PATH\src\routes\edit.tsx" -Value $editContent
    Write-Success "edit.tsx créé"
    
    # Route NEW
    $newContent = @"
// packages/tools/$ToolName/src/routes/new.tsx
'use client'

export function ${DisplayName}New() {
  return (
    <div className="p-6">
      <h1 className="text-2xl font-bold mb-6">Nouveau $DisplayName</h1>
      <div className="bg-white rounded-lg shadow p-6">
        {/* TODO: Ajouter formulaire de création */}
        <p className="text-gray-600">Formulaire à implémenter</p>
      </div>
    </div>
  )
}
"@
    Set-Content -Path "$TOOL_PATH\src\routes\new.tsx" -Value $newContent
    Write-Success "new.tsx créé"
} else {
    Write-Step "Étape 6/10 : Routes ignorées (mode minimal)"
}

# ═══════════════════════════════════════════════════════════
# ÉTAPE 7 : Créer types de base
# ═══════════════════════════════════════════════════════════
Write-Step "Étape 7/10 : Création des types"

$typesContent = @"
// packages/tools/$ToolName/src/types/index.ts

export interface ${DisplayName}Item {
  id: string
  name: string
  created_at: string
  updated_at: string
}

export interface ${DisplayName}FormData {
  name: string
}
"@
Set-Content -Path "$TOOL_PATH\src\types\index.ts" -Value $typesContent
Write-Success "types/index.ts créé"

# ═══════════════════════════════════════════════════════════
# ÉTAPE 8 : Créer wrappers dans apps/admin
# ═══════════════════════════════════════════════════════════
Write-Step "Étape 8/10 : Création wrappers apps/admin/app/(tools)/$ToolName"

$adminToolPath = "$ADMIN_DIR\app\(tools)\$ToolName"
New-Item -ItemType Directory -Path $adminToolPath -Force | Out-Null

if ($Minimal) {
    # Page unique en mode minimal
    $pageContent = @"
// apps/admin/app/(tools)/$ToolName/page.tsx
import { ${DisplayName}Tool } from '@repo/tools-$ToolName'

export default function ${DisplayName}Page() {
  return <${DisplayName}Tool />
}
"@
    Set-Content -Path "$adminToolPath\page.tsx" -Value $pageContent
    Write-Success "page.tsx créé"
} else {
    # Page LIST
    $pageContent = @"
// apps/admin/app/(tools)/$ToolName/page.tsx
import { ${DisplayName}List } from '@repo/tools-$ToolName'

export default function ${DisplayName}Page() {
  return <${DisplayName}List />
}
"@
    Set-Content -Path "$adminToolPath\page.tsx" -Value $pageContent
    Write-Success "page.tsx créé"
    
    # Page EDIT
    New-Item -ItemType Directory -Path "$adminToolPath\[id]" -Force | Out-Null
    $editPageContent = @"
// apps/admin/app/(tools)/$ToolName/[id]/page.tsx
import { ${DisplayName}Edit } from '@repo/tools-$ToolName'

interface Props {
  params: Promise<{ id: string }>
}

export default async function ${DisplayName}EditPage({ params }: Props) {
  const { id } = await params
  return <${DisplayName}Edit id={id} />
}
"@
    Set-Content -Path "$adminToolPath\[id]\page.tsx" -Value $editPageContent
    Write-Success "[id]/page.tsx créé"
    
    # Page NEW
    New-Item -ItemType Directory -Path "$adminToolPath\new" -Force | Out-Null
    $newPageContent = @"
// apps/admin/app/(tools)/$ToolName/new/page.tsx
import { ${DisplayName}New } from '@repo/tools-$ToolName'

export default function ${DisplayName}NewPage() {
  return <${DisplayName}New />
}
"@
    Set-Content -Path "$adminToolPath\new\page.tsx" -Value $newPageContent
    Write-Success "new/page.tsx créé"
}

# ═══════════════════════════════════════════════════════════
# ÉTAPE 9 : Créer routes API (optionnel)
# ═══════════════════════════════════════════════════════════
if ($WithAPI) {
    Write-Step "Étape 9/10 : Création routes API"
    
    $apiPath = "$ADMIN_DIR\app\api\admin\$ToolName"
    New-Item -ItemType Directory -Path $apiPath -Force | Out-Null
    
    $apiContent = @"
// apps/admin/app/api/admin/$ToolName/route.ts
import { NextResponse } from 'next/server'
import { supabaseAdmin } from '@repo/database'

// GET - Liste des items
export async function GET() {
  try {
    const { data, error } = await supabaseAdmin
      .from('$ToolName')
      .select('*')
      .order('created_at', { ascending: false })

    if (error) throw error

    return NextResponse.json(data)
  } catch (error) {
    console.error('Error fetching $ToolName:', error)
    return NextResponse.json(
      { error: 'Failed to fetch $ToolName' },
      { status: 500 }
    )
  }
}

// POST - Créer un item
export async function POST(req: Request) {
  try {
    const body = await req.json()

    const { data, error } = await supabaseAdmin
      .from('$ToolName')
      .insert(body)
      .select()
      .single()

    if (error) throw error

    return NextResponse.json(data, { status: 201 })
  } catch (error) {
    console.error('Error creating $ToolName:', error)
    return NextResponse.json(
      { error: 'Failed to create $ToolName' },
      { status: 500 }
    )
  }
}
"@
    Set-Content -Path "$apiPath\route.ts" -Value $apiContent
    Write-Success "API route.ts créé"
    
    # Route [id]
    New-Item -ItemType Directory -Path "$apiPath\[id]" -Force | Out-Null
    $apiIdContent = @"
// apps/admin/app/api/admin/$ToolName/[id]/route.ts
import { NextResponse } from 'next/server'
import { supabaseAdmin } from '@repo/database'

// GET - Récupérer un item
export async function GET(
  req: Request,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const { id } = await params

    const { data, error } = await supabaseAdmin
      .from('$ToolName')
      .select('*')
      .eq('id', id)
      .single()

    if (error) throw error
    if (!data) {
      return NextResponse.json({ error: 'Not found' }, { status: 404 })
    }

    return NextResponse.json(data)
  } catch (error) {
    console.error('Error fetching $ToolName:', error)
    return NextResponse.json(
      { error: 'Failed to fetch $ToolName' },
      { status: 500 }
    )
  }
}

// PUT - Mettre à jour un item
export async function PUT(
  req: Request,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const { id } = await params
    const body = await req.json()

    const { data, error } = await supabaseAdmin
      .from('$ToolName')
      .update(body)
      .eq('id', id)
      .select()
      .single()

    if (error) throw error

    return NextResponse.json(data)
  } catch (error) {
    console.error('Error updating $ToolName:', error)
    return NextResponse.json(
      { error: 'Failed to update $ToolName' },
      { status: 500 }
    )
  }
}

// DELETE - Supprimer un item
export async function DELETE(
  req: Request,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const { id } = await params

    const { error } = await supabaseAdmin
      .from('$ToolName')
      .delete()
      .eq('id', id)

    if (error) throw error

    return NextResponse.json({ success: true })
  } catch (error) {
    console.error('Error deleting $ToolName:', error)
    return NextResponse.json(
      { error: 'Failed to delete $ToolName' },
      { status: 500 }
    )
  }
}
"@
    Set-Content -Path "$apiPath\[id]\route.ts" -Value $apiIdContent
    Write-Success "API [id]/route.ts créé"
} else {
    Write-Step "Étape 9/10 : Routes API ignorées"
}

# ═══════════════════════════════════════════════════════════
# ÉTAPE 10 : Mise à jour next.config.ts
# ═══════════════════════════════════════════════════════════
Write-Step "Étape 10/10 : Mise à jour next.config.ts"

$nextConfigPath = "$ADMIN_DIR\next.config.ts"
$nextConfig = Get-Content $nextConfigPath -Raw

# Vérifier si le tool est déjà dans transpilePackages
if ($nextConfig -match "transpilePackages\s*:\s*\[(.*?)\]") {
    $packagesBlock = $matches[1]
    
    if ($packagesBlock -notmatch "@repo/tools-$ToolName") {
        # Ajouter le tool à la liste
        $newPackagesBlock = $packagesBlock.TrimEnd() + ",`n    '@repo/tools-$ToolName'"
        $nextConfig = $nextConfig -replace "(transpilePackages\s*:\s*\[)(.*?)(\])", "`$1$newPackagesBlock`n  `$3"
        
        Set-Content -Path $nextConfigPath -Value $nextConfig
        Write-Success "Tool ajouté à transpilePackages"
    } else {
        Write-Info "Tool déjà présent dans transpilePackages"
    }
} else {
    Write-Warning "Impossible de trouver transpilePackages dans next.config.ts"
    Write-Info "Ajoutez manuellement : '@repo/tools-$ToolName'"
}

# ═══════════════════════════════════════════════════════════
# ÉTAPE 11 : Installation des dépendances
# ═══════════════════════════════════════════════════════════
Write-Step "Installation des dépendances"

Write-Info "Lancement : pnpm install"
Push-Location $MONOREPO_ROOT
try {
    pnpm install 2>&1 | Out-Null
    Write-Success "pnpm install terminé"
} catch {
    Write-Warning "Erreur lors de pnpm install, relancez manuellement"
} finally {
    Pop-Location
}

Write-Info "Ajout du tool à apps/admin : pnpm add @repo/tools-$ToolName@workspace:*"
Push-Location $ADMIN_DIR
try {
    pnpm add "@repo/tools-$ToolName@workspace:*" 2>&1 | Out-Null
    Write-Success "Tool ajouté aux dépendances admin"
} catch {
    Write-Warning "Erreur lors de l'ajout, relancez : cd apps/admin && pnpm add @repo/tools-$ToolName@workspace:*"
} finally {
    Pop-Location
}

# ═══════════════════════════════════════════════════════════
# RÉSUMÉ ET PROCHAINES ÉTAPES
# ═══════════════════════════════════════════════════════════
Write-Host "`n╔════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║  ✅ TOOL CRÉÉ AVEC SUCCÈS !" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Green

Write-Host "`n📁 Structure créée :" -ForegroundColor Cyan
Write-Host "   packages/tools/$ToolName/" -ForegroundColor White
Write-Host "   ├── src/" -ForegroundColor Gray
Write-Host "   │   ├── index.tsx" -ForegroundColor Gray
if (-not $Minimal) {
    Write-Host "   │   ├── routes/ (list, edit, new)" -ForegroundColor Gray
}
Write-Host "   │   ├── components/" -ForegroundColor Gray
Write-Host "   │   └── types/" -ForegroundColor Gray
Write-Host "   ├── package.json" -ForegroundColor Gray
Write-Host "   └── tsconfig.json" -ForegroundColor Gray

Write-Host "`n   apps/admin/app/(tools)/$ToolName/" -ForegroundColor White
Write-Host "   ├── page.tsx" -ForegroundColor Gray
if (-not $Minimal) {
    Write-Host "   ├── [id]/page.tsx" -ForegroundColor Gray
    Write-Host "   └── new/page.tsx" -ForegroundColor Gray
}

if ($WithAPI) {
    Write-Host "`n   apps/admin/app/api/admin/$ToolName/" -ForegroundColor White
    Write-Host "   ├── route.ts" -ForegroundColor Gray
    Write-Host "   └── [id]/route.ts" -ForegroundColor Gray
}

Write-Host "`n🚀 Prochaines étapes :" -ForegroundColor Cyan
Write-Host "   1. cd $MONOREPO_ROOT" -ForegroundColor White
Write-Host "   2. pnpm dev" -ForegroundColor White
Write-Host "   3. Ouvrir : http://localhost:3000/$ToolName" -ForegroundColor White
Write-Host "   4. Développer la logique métier dans packages/tools/$ToolName/" -ForegroundColor White

Write-Host "`n💡 Commandes utiles :" -ForegroundColor Cyan
Write-Host "   # Type-check" -ForegroundColor Gray
Write-Host "   pnpm --filter @repo/tools-$ToolName type-check" -ForegroundColor White
Write-Host ""
Write-Host "   # Build" -ForegroundColor Gray
Write-Host "   pnpm --filter @repo/tools-$ToolName build" -ForegroundColor White
Write-Host ""
Write-Host "   # Valider avant commit" -ForegroundColor Gray
Write-Host "   .\scripts\validate-tool.ps1 $ToolName" -ForegroundColor White

Write-Host "`n📚 Documentation :" -ForegroundColor Cyan
Write-Host "   - docs/20251103-ARCHITECTURE-AJOUTER-TOOL.md" -ForegroundColor White
Write-Host "   - docs/20251103-ARCHITECTURE-BONNES-PRATIQUES-TOOLS.md" -ForegroundColor White

Write-Host ""
