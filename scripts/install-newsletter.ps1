# install-newsletter.ps1
# Script d'installation automatique Newsletter - Blanche Renaudin Monorepo
# Date: 27 octobre 2025

Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "   📧 Installation Newsletter - Blanche Renaudin" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Configuration
$MONOREPO_PATH = "C:\Users\thoma\OneDrive\SONEAR_2025\blancherenaudin-monorepo"
$DOWNLOADS_PATH = "$env:USERPROFILE\Downloads" # Adapter si nécessaire

# Vérifier que le monorepo existe
if (-Not (Test-Path $MONOREPO_PATH)) {
    Write-Host "❌ Erreur: Monorepo introuvable à $MONOREPO_PATH" -ForegroundColor Red
    Write-Host "   Veuillez modifier la variable `$MONOREPO_PATH dans le script" -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ Monorepo trouvé: $MONOREPO_PATH" -ForegroundColor Green
Write-Host ""

# Étape 1: Créer les dossiers nécessaires
Write-Host "📁 Étape 1: Création des dossiers..." -ForegroundColor Yellow

$FOLDERS = @(
    "apps\storefront\app\newsletter\confirmed",
    "apps\storefront\components\newsletter"
)

foreach ($folder in $FOLDERS) {
    $fullPath = Join-Path $MONOREPO_PATH $folder
    if (-Not (Test-Path $fullPath)) {
        New-Item -ItemType Directory -Path $fullPath -Force | Out-Null
        Write-Host "   ✅ Créé: $folder" -ForegroundColor Green
    } else {
        Write-Host "   ⏭️  Existe déjà: $folder" -ForegroundColor Gray
    }
}

Write-Host ""

# Étape 2: Copier les fichiers
Write-Host "📋 Étape 2: Copie des fichiers..." -ForegroundColor Yellow

# Fonction pour copier avec confirmation
function Copy-WithConfirmation {
    param(
        [string]$Source,
        [string]$Destination,
        [string]$Description
    )
    
    if (Test-Path $Source) {
        # Backup si le fichier existe déjà
        if (Test-Path $Destination) {
            $backup = "$Destination.backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
            Copy-Item $Destination $backup -Force
            Write-Host "   💾 Backup: $(Split-Path $backup -Leaf)" -ForegroundColor Cyan
        }
        
        Copy-Item $Source $Destination -Force
        Write-Host "   ✅ $Description" -ForegroundColor Green
        return $true
    } else {
        Write-Host "   ❌ Fichier source introuvable: $Source" -ForegroundColor Red
        return $false
    }
}

# Mapping des fichiers
$FILES = @{
    "newsletter-confirmed-page.tsx" = @{
        destination = "apps\storefront\app\newsletter\confirmed\page.tsx"
        description = "Page de confirmation newsletter"
    }
    "newsletter-subscribe-component.tsx" = @{
        destination = "apps\storefront\components\newsletter\NewsletterSubscribe.tsx"
        description = "Composant formulaire newsletter"
    }
    "footer-minimal-updated.tsx" = @{
        destination = "apps\storefront\components\layout\FooterMinimal.tsx"
        description = "Footer avec newsletter active"
    }
}

$success = 0
$total = $FILES.Count

foreach ($file in $FILES.GetEnumerator()) {
    $sourcePath = Join-Path $DOWNLOADS_PATH $file.Key
    $destPath = Join-Path $MONOREPO_PATH $file.Value.destination
    
    if (Copy-WithConfirmation -Source $sourcePath -Destination $destPath -Description $file.Value.description) {
        $success++
    }
}

Write-Host ""

# Résumé
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "   📊 Résumé de l'installation" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "Fichiers copiés: $success / $total" -ForegroundColor $(if ($success -eq $total) { "Green" } else { "Yellow" })
Write-Host ""

if ($success -eq $total) {
    Write-Host "✅ Installation réussie !" -ForegroundColor Green
    Write-Host ""
    Write-Host "🚀 Prochaines étapes:" -ForegroundColor Yellow
    Write-Host "   1. Ouvrir le projet dans VS Code" -ForegroundColor White
    Write-Host "   2. Exécuter: cd apps/storefront && pnpm dev" -ForegroundColor White
    Write-Host "   3. Tester le formulaire newsletter dans le footer" -ForegroundColor White
    Write-Host ""
} else {
    Write-Host "⚠️  Installation partielle" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Fichiers manquants:" -ForegroundColor Red
    foreach ($file in $FILES.GetEnumerator()) {
        $sourcePath = Join-Path $DOWNLOADS_PATH $file.Key
        if (-Not (Test-Path $sourcePath)) {
            Write-Host "   - $($file.Key)" -ForegroundColor Red
        }
    }
    Write-Host ""
    Write-Host "📥 Veuillez télécharger les fichiers manquants et relancer le script" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "📖 Documentation:" -ForegroundColor Cyan
Write-Host "   - README-NEWSLETTER.md (vue d'ensemble)" -ForegroundColor White
Write-Host "   - GUIDE-INSTALLATION-NEWSLETTER.md (guide complet)" -ForegroundColor White
Write-Host "   - check-newsletter-status.md (checklist)" -ForegroundColor White
Write-Host ""

# Pause pour lire les messages
Write-Host "Appuyez sur une touche pour fermer..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
