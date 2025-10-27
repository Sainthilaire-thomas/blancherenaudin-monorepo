# Script PowerShell - Migration de routes API vers le monorepo
# Usage: .\migrate-api-route.ps1 -OldProjectRoot "C:\old" -NewProjectRoot "C:\new" -RouteType "stripe"

param(
    [Parameter(Mandatory=$true)]
    [string]$OldProjectRoot,
    
    [Parameter(Mandatory=$true)]
    [string]$NewProjectRoot,
    
    [Parameter(Mandatory=$false)]
    [ValidateSet("stripe", "checkout", "orders", "newsletter", "all")]
    [string]$RouteType = "all",
    
    [Parameter(Mandatory=$false)]
    [switch]$DryRun
)

Write-Host "`n🔄 MIGRATION DE ROUTES API" -ForegroundColor Cyan
Write-Host "=" * 70 -ForegroundColor Gray
Write-Host "Ancien projet: $OldProjectRoot" -ForegroundColor Gray
Write-Host "Nouveau projet: $NewProjectRoot" -ForegroundColor Gray
Write-Host "Type de routes: $RouteType" -ForegroundColor Gray
if ($DryRun) {
    Write-Host "Mode: DRY RUN (simulation uniquement)" -ForegroundColor Yellow
}
Write-Host ""

# Vérifier que les chemins existent
if (-not (Test-Path $OldProjectRoot)) {
    Write-Host "❌ Erreur: Ancien projet introuvable à $OldProjectRoot" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path $NewProjectRoot)) {
    Write-Host "❌ Erreur: Nouveau projet introuvable à $NewProjectRoot" -ForegroundColor Red
    exit 1
}

# Fonction pour transformer les imports
function Update-Imports {
    param([string]$Content)
    
    $updated = $content
    
    # Remplacer les imports de l'ancien système
    $replacements = @{
        "from '@/lib/stripe'" = "from '@repo/database/server'"
        "from '@/lib/supabase-admin'" = "from '@repo/database/server'"
        "from '@/lib/supabase-server'" = "from '@repo/database/server'"
        "from '@/lib/email/send'" = "from '@repo/email'"
        "from '@/lib/email/send-order-confirmation'" = "from '@repo/email'"
        "from '@/lib/validation/" = "from '@repo/utils/validation/"
        "from '@/lib/utils'" = "from '@repo/utils'"
        "from '@/components/ui/" = "from '@repo/ui/"
    }
    
    foreach ($old in $replacements.Keys) {
        $new = $replacements[$old]
        $updated = $updated -replace [regex]::Escape($old), $new
    }
    
    return $updated
}

# Fonction pour migrer un fichier
function Migrate-RouteFile {
    param(
        [string]$SourcePath,
        [string]$DestPath,
        [string]$RouteName
    )
    
    Write-Host "`n📄 Migration: $RouteName" -ForegroundColor Yellow
    Write-Host "   Source: $SourcePath" -ForegroundColor Gray
    Write-Host "   Dest:   $DestPath" -ForegroundColor Gray
    
    if (-not (Test-Path $SourcePath)) {
        Write-Host "   ⚠️  Fichier source introuvable, skip" -ForegroundColor Yellow
        return $false
    }
    
    if ((Test-Path $DestPath) -and -not $DryRun) {
        Write-Host "   ⚠️  Fichier destination existe déjà" -ForegroundColor Yellow
        $response = Read-Host "   Écraser? (o/N)"
        if ($response -ne "o" -and $response -ne "O") {
            Write-Host "   ⏭️  Skip" -ForegroundColor Gray
            return $false
        }
    }
    
    # Lire le contenu
    $content = Get-Content -Path $SourcePath -Raw
    
    # Mettre à jour les imports
    $updatedContent = Update-Imports -Content $content
    
    # Compter les changements
    $changes = 0
    if ($content -ne $updatedContent) {
        $changes = ([regex]::Matches($content, "from '@/")).Count
        Write-Host "   ✏️  $changes imports mis à jour" -ForegroundColor Cyan
    }
    
    if ($DryRun) {
        Write-Host "   🔍 DRY RUN: Affichage des changements" -ForegroundColor Yellow
        
        # Afficher les différences d'imports
        $oldImports = [regex]::Matches($content, 'from\s+[' + "'" + '"](@/[^' + "'" + '"]+)[' + "'" + '"]') | 
                      ForEach-Object { $_.Groups[1].Value } | 
                      Select-Object -Unique
        
        $newImports = [regex]::Matches($updatedContent, 'from\s+[' + "'" + '"](@repo/[^' + "'" + '"]+)[' + "'" + '"]') | 
                      ForEach-Object { $_.Groups[1].Value } | 
                      Select-Object -Unique
        
        if ($oldImports.Count -gt 0) {
            Write-Host "`n   Imports transformés:" -ForegroundColor Cyan
            foreach ($old in $oldImports) {
                Write-Host "      ❌ $old" -ForegroundColor Red
            }
            foreach ($new in $newImports) {
                Write-Host "      ✅ $new" -ForegroundColor Green
            }
        }
        
        return $true
    }
    
    # Créer le dossier de destination si nécessaire
    $destDir = Split-Path -Parent $DestPath
    if (-not (Test-Path $destDir)) {
        Write-Host "   📁 Création du dossier: $destDir" -ForegroundColor Cyan
        New-Item -ItemType Directory -Path $destDir -Force | Out-Null
    }
    
    # Écrire le fichier
    Set-Content -Path $DestPath -Value $updatedContent -Encoding UTF8
    Write-Host "   ✅ Fichier migré avec succès!" -ForegroundColor Green
    
    return $true
}

# Définir les routes à migrer selon le type
$routesToMigrate = @()

if ($RouteType -eq "stripe" -or $RouteType -eq "all") {
    $routesToMigrate += @{
        Name = "Stripe Webhook"
        Source = "src\app\api\webhooks\stripe\route.ts"
        Dest = "apps\storefront\app\api\webhooks\stripe\route.ts"
    }
}

if ($RouteType -eq "checkout" -or $RouteType -eq "all") {
    $routesToMigrate += @{
        Name = "Checkout Create Session"
        Source = "src\app\api\checkout\create-session\route.ts"
        Dest = "apps\storefront\app\api\checkout\create-session\route.ts"
    }
}

if ($RouteType -eq "orders" -or $RouteType -eq "all") {
    $routesToMigrate += @{
        Name = "Orders by Session"
        Source = "src\app\api\orders\by-session\[sessionId]\route.ts"
        Dest = "apps\storefront\app\api\orders\by-session\[sessionId]\route.ts"
    }
}

if ($RouteType -eq "newsletter" -or $RouteType -eq "all") {
    $routesToMigrate += @(
        @{
            Name = "Newsletter Subscribe"
            Source = "src\app\api\newsletter\subscribe\route.ts"
            Dest = "apps\storefront\app\api\newsletter\subscribe\route.ts"
        },
        @{
            Name = "Newsletter Confirm"
            Source = "src\app\api\newsletter\confirm\route.ts"
            Dest = "apps\storefront\app\api\newsletter\confirm\route.ts"
        }
    )
}

# Exécuter les migrations
Write-Host "`n🚀 DÉBUT DE LA MIGRATION" -ForegroundColor Cyan
Write-Host "-" * 70 -ForegroundColor Gray

$successCount = 0
$skipCount = 0

foreach ($route in $routesToMigrate) {
    $sourcePath = Join-Path $OldProjectRoot $route.Source
    $destPath = Join-Path $NewProjectRoot $route.Dest
    
    $result = Migrate-RouteFile -SourcePath $sourcePath -DestPath $destPath -RouteName $route.Name
    
    if ($result) {
        $successCount++
    } else {
        $skipCount++
    }
}

# Résumé
Write-Host "`n`n📊 RÉSUMÉ DE LA MIGRATION" -ForegroundColor Yellow
Write-Host "-" * 70 -ForegroundColor Gray

Write-Host "`n✅ Fichiers migrés: $successCount" -ForegroundColor Green
Write-Host "⏭️  Fichiers skippés: $skipCount" -ForegroundColor Yellow
Write-Host "📦 Total: $($routesToMigrate.Count)" -ForegroundColor Cyan

if ($DryRun) {
    Write-Host "`n💡 Pour exécuter la migration réelle, relancez sans le flag -DryRun" -ForegroundColor Yellow
} else {
    Write-Host "`n✨ Migration terminée!" -ForegroundColor Green
    Write-Host "`n📝 Prochaines étapes:" -ForegroundColor Yellow
    Write-Host "   1. Vérifier les imports dans les fichiers migrés" -ForegroundColor White
    Write-Host "   2. Corriger les imports manquants (auth, validation, etc.)" -ForegroundColor White
    Write-Host "   3. Tester les routes avec: pnpm dev" -ForegroundColor White
    Write-Host "   4. Pour Stripe: stripe listen --forward-to localhost:3000/api/webhooks/stripe" -ForegroundColor White
}

Write-Host ""
