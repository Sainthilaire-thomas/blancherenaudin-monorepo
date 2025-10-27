# Script PowerShell - Déploiement du webhook Stripe corrigé
# Usage: .\deploy-stripe-webhook.ps1 -ProjectRoot "C:\path\to\project" -SourceFile "webhook-corrected.txt"

param(
    [Parameter(Mandatory=$true)]
    [string]$ProjectRoot,
    
    [Parameter(Mandatory=$false)]
    [string]$SourceFile = "webhook_stripe_route_ts_-_VERSION_CORRIGÉE_COMPLÈTE.txt",
    
    [Parameter(Mandatory=$false)]
    [switch]$Backup,
    
    [Parameter(Mandatory=$false)]
    [switch]$DryRun
)

Write-Host "`n💳 DÉPLOIEMENT WEBHOOK STRIPE CORRIGÉ" -ForegroundColor Cyan
Write-Host "=" * 70 -ForegroundColor Gray

# Vérifier que le projet existe
if (-not (Test-Path $ProjectRoot)) {
    Write-Host "❌ Erreur: Projet introuvable à $ProjectRoot" -ForegroundColor Red
    exit 1
}

# Chemin du fichier source (version corrigée)
if (-not (Test-Path $SourceFile)) {
    Write-Host "❌ Erreur: Fichier source introuvable: $SourceFile" -ForegroundColor Red
    Write-Host "   Assurez-vous que le fichier 'webhook_stripe_route_ts_-_VERSION_CORRIGÉE_COMPLÈTE.txt' est présent" -ForegroundColor Yellow
    exit 1
}

# Chemin de destination
$destPath = Join-Path $ProjectRoot "apps\storefront\app\api\webhooks\stripe\route.ts"
$destDir = Split-Path -Parent $destPath

Write-Host "`n📋 Configuration:" -ForegroundColor Yellow
Write-Host "   Source: $SourceFile" -ForegroundColor Gray
Write-Host "   Dest:   $destPath" -ForegroundColor Gray
if ($Backup) {
    Write-Host "   Backup: Activé" -ForegroundColor Green
}
if ($DryRun) {
    Write-Host "   Mode:   DRY RUN (simulation)" -ForegroundColor Yellow
}
Write-Host ""

# Lire le contenu du fichier source
$content = Get-Content -Path $SourceFile -Raw

# Analyser le contenu
Write-Host "`n🔍 ANALYSE DU FICHIER SOURCE" -ForegroundColor Yellow
Write-Host "-" * 70 -ForegroundColor Gray

$lines = (Get-Content -Path $SourceFile).Count
Write-Host "   📏 Lignes: $lines" -ForegroundColor Cyan

# Vérifier les imports critiques
$hasStripe = $content -match "from '@/lib/stripe'|from 'stripe'"
$hasSupabase = $content -match "from '@/lib/supabase-admin'"
$hasEmail = $content -match "from '@/lib/email/send-order-confirmation-hook'"
$hasStock = $content -match "from '@/lib/stock/decrement-stock'"

Write-Host "   📦 Dépendances détectées:" -ForegroundColor Cyan
Write-Host "      • Stripe: $(if ($hasStripe) { '✅' } else { '❌' })" -ForegroundColor $(if ($hasStripe) { "Green" } else { "Red" })
Write-Host "      • Supabase Admin: $(if ($hasSupabase) { '✅' } else { '❌' })" -ForegroundColor $(if ($hasSupabase) { "Green" } else { "Red" })
Write-Host "      • Email Hook: $(if ($hasEmail) { '✅' } else { '❌' })" -ForegroundColor $(if ($hasEmail) { "Green" } else { "Red" })
Write-Host "      • Stock Decrement: $(if ($hasStock) { '✅' } else { '❌' })" -ForegroundColor $(if ($hasStock) { "Green" } else { "Red" })

# Vérifier les fonctions principales
$functions = @(
    "handleCheckoutSessionCompleted",
    "handlePaymentIntentSucceeded",
    "handlePaymentIntentFailed",
    "createOrderItemsFromSession",
    "parseAddress",
    "sendConfirmationEmailSafe"
)

Write-Host "`n   🔧 Fonctions implémentées:" -ForegroundColor Cyan
foreach ($func in $functions) {
    $exists = $content -match "function\s+$func|const\s+$func\s*="
    Write-Host "      • $func : $(if ($exists) { '✅' } else { '❌' })" -ForegroundColor $(if ($exists) { "Green" } else { "Red" })
}

# Vérifier le gestionnaire POST
$hasPOST = $content -match "export\s+async\s+function\s+POST"
Write-Host "`n   🌐 Export POST: $(if ($hasPOST) { '✅' } else { '❌' })" -ForegroundColor $(if ($hasPOST) { "Green" } else { "Red" })

# Transformation des imports pour le monorepo
Write-Host "`n🔄 TRANSFORMATION DES IMPORTS" -ForegroundColor Yellow
Write-Host "-" * 70 -ForegroundColor Gray

$updatedContent = $content

# Mapping des imports
$importMappings = @{
    "from '@/lib/stripe'" = "from '@repo/database/server'"
    "from '@/lib/supabase-admin'" = "from '@repo/database/server'"
    "from '@/lib/email/send-order-confirmation-hook'" = "from '@repo/email'"
    "from '@/lib/stock/decrement-stock'" = "from '@repo/database/server'"
}

$transformCount = 0
foreach ($oldImport in $importMappings.Keys) {
    $newImport = $importMappings[$oldImport]
    if ($content -match [regex]::Escape($oldImport)) {
        Write-Host "   ✏️  $oldImport" -ForegroundColor Red
        Write-Host "      → $newImport" -ForegroundColor Green
        $updatedContent = $updatedContent -replace [regex]::Escape($oldImport), $newImport
        $transformCount++
    }
}

if ($transformCount -eq 0) {
    Write-Host "   ℹ️  Aucun import à transformer (déjà au bon format?)" -ForegroundColor Yellow
} else {
    Write-Host "`n   ✅ $transformCount imports transformés" -ForegroundColor Green
}

# Vérifier si le fichier destination existe
if (Test-Path $destPath) {
    Write-Host "`n⚠️  FICHIER EXISTANT DÉTECTÉ" -ForegroundColor Yellow
    Write-Host "-" * 70 -ForegroundColor Gray
    
    $existingContent = Get-Content -Path $destPath -Raw
    $existingLines = (Get-Content -Path $destPath).Count
    
    Write-Host "   📄 Fichier actuel: $existingLines lignes" -ForegroundColor Cyan
    Write-Host "   📄 Nouvelle version: $lines lignes" -ForegroundColor Cyan
    
    # Comparer les contenus
    if ($existingContent.Trim() -eq $updatedContent.Trim()) {
        Write-Host "`n   ℹ️  Les fichiers sont identiques, aucune action nécessaire" -ForegroundColor Green
        exit 0
    }
}

if ($DryRun) {
    Write-Host "`n🔍 DRY RUN - Aperçu des changements:" -ForegroundColor Yellow
    Write-Host "-" * 70 -ForegroundColor Gray
    Write-Host "`n   Le fichier SERAIT créé/mis à jour avec:" -ForegroundColor Cyan
    Write-Host "   • $lines lignes de code" -ForegroundColor White
    Write-Host "   • $transformCount imports transformés" -ForegroundColor White
    Write-Host "   • $(($functions | Where-Object { $content -match $_ }).Count) fonctions" -ForegroundColor White
    
    Write-Host "`n   Pour appliquer les changements, relancez sans -DryRun" -ForegroundColor Yellow
    exit 0
}

# Backup si demandé
if ($Backup -and (Test-Path $destPath)) {
    $backupPath = "$destPath.backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    Write-Host "`n💾 BACKUP" -ForegroundColor Yellow
    Write-Host "   Sauvegarde: $backupPath" -ForegroundColor Gray
    Copy-Item -Path $destPath -Destination $backupPath
    Write-Host "   ✅ Backup créé" -ForegroundColor Green
}

# Créer le dossier si nécessaire
if (-not (Test-Path $destDir)) {
    Write-Host "`n📁 Création du dossier: $destDir" -ForegroundColor Cyan
    New-Item -ItemType Directory -Path $destDir -Force | Out-Null
}

# Écrire le fichier
Write-Host "`n💾 ÉCRITURE DU FICHIER" -ForegroundColor Yellow
Write-Host "-" * 70 -ForegroundColor Gray

Set-Content -Path $destPath -Value $updatedContent -Encoding UTF8
Write-Host "   ✅ Fichier webhook déployé avec succès!" -ForegroundColor Green

# Vérifications post-déploiement
Write-Host "`n✅ VÉRIFICATIONS POST-DÉPLOIEMENT" -ForegroundColor Yellow
Write-Host "-" * 70 -ForegroundColor Gray

$deployed = Get-Content -Path $destPath -Raw
$deployedLines = (Get-Content -Path $destPath).Count

Write-Host "   📏 Lignes écrites: $deployedLines" -ForegroundColor Cyan
Write-Host "   📦 Taille: $([math]::Round((Get-Item $destPath).Length / 1KB, 2)) KB" -ForegroundColor Cyan

# Vérifier que les imports critiques sont présents
$checkImports = @(
    "@repo/database/server",
    "@repo/email"
)

Write-Host "`n   🔍 Vérification des imports critiques:" -ForegroundColor Cyan
foreach ($imp in $checkImports) {
    $found = $deployed -match [regex]::Escape($imp)
    Write-Host "      • $imp : $(if ($found) { '✅' } else { '❌' })" -ForegroundColor $(if ($found) { "Green" } else { "Red" })
}

# Prochaines étapes
Write-Host "`n`n📝 PROCHAINES ÉTAPES" -ForegroundColor Yellow
Write-Host "-" * 70 -ForegroundColor Gray

Write-Host "`n1️⃣  Vérifier la compilation TypeScript:"
Write-Host "   cd apps\storefront" -ForegroundColor Cyan
Write-Host "   pnpm tsc --noEmit" -ForegroundColor Cyan

Write-Host "`n2️⃣  Lancer le serveur de développement:"
Write-Host "   pnpm dev" -ForegroundColor Cyan

Write-Host "`n3️⃣  Tester le webhook avec Stripe CLI (dans un autre terminal):"
Write-Host "   stripe listen --forward-to localhost:3000/api/webhooks/stripe" -ForegroundColor Cyan
Write-Host "   stripe trigger checkout.session.completed" -ForegroundColor Cyan

Write-Host "`n4️⃣  Vérifier les dépendances dans @repo/email:"
Write-Host "   • sendOrderConfirmationHook doit être exporté" -ForegroundColor White
Write-Host "   • Vérifier packages/email/src/index.ts" -ForegroundColor White

Write-Host "`n5️⃣  Vérifier les dépendances dans @repo/database:"
Write-Host "   • stripe, supabaseAdmin doivent être exportés" -ForegroundColor White
Write-Host "   • decrementStockForOrder doit être exporté" -ForegroundColor White
Write-Host "   • Vérifier packages/database/src/server.ts" -ForegroundColor White

Write-Host "`n✨ Déploiement terminé!`n" -ForegroundColor Cyan
