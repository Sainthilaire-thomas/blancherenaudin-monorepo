# fix-react-hook-form.ps1
# Script pour diagnostiquer et corriger react-hook-form

Write-Host "===================================================" -ForegroundColor Cyan
Write-Host "   Diagnostic react-hook-form" -ForegroundColor Cyan
Write-Host "===================================================" -ForegroundColor Cyan
Write-Host ""

$MONOREPO = "C:\Users\thoma\OneDrive\SONEAR_2025\blancherenaudin-monorepo"

cd $MONOREPO

# Verifier l'installation dans @repo/ui
Write-Host "Verification de @repo/ui..." -ForegroundColor Yellow
cd packages\ui

Write-Host "  Contenu de node_modules:" -ForegroundColor Gray
if (Test-Path "node_modules\react-hook-form") {
    Write-Host "    OK - react-hook-form existe" -ForegroundColor Green
    
    # Verifier la version
    $packageJson = Get-Content "node_modules\react-hook-form\package.json" | ConvertFrom-Json
    Write-Host "    Version: $($packageJson.version)" -ForegroundColor Cyan
} else {
    Write-Host "    ERREUR - react-hook-form introuvable" -ForegroundColor Red
}

Write-Host ""
Write-Host "  Contenu de package.json:" -ForegroundColor Gray
$uiPackageJson = Get-Content "package.json" | ConvertFrom-Json
if ($uiPackageJson.dependencies."react-hook-form") {
    Write-Host "    OK - react-hook-form dans dependencies" -ForegroundColor Green
    Write-Host "    Version: $($uiPackageJson.dependencies.'react-hook-form')" -ForegroundColor Cyan
} else {
    Write-Host "    ERREUR - react-hook-form absent de package.json" -ForegroundColor Red
}

Write-Host ""
Write-Host "===================================================" -ForegroundColor Cyan
Write-Host "   Solution" -ForegroundColor Cyan
Write-Host "===================================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "1. Supprimer node_modules de @repo/ui" -ForegroundColor Yellow
Remove-Item node_modules -Recurse -Force -ErrorAction SilentlyContinue
Write-Host "   OK - node_modules supprime" -ForegroundColor Green
Write-Host ""

Write-Host "2. Reinstaller dans @repo/ui" -ForegroundColor Yellow
pnpm install
if ($LASTEXITCODE -eq 0) {
    Write-Host "   OK - Installation reussie" -ForegroundColor Green
} else {
    Write-Host "   ERREUR - Installation echouee" -ForegroundColor Red
}
Write-Host ""

Write-Host "3. Verifier exports de react-hook-form" -ForegroundColor Yellow
if (Test-Path "node_modules\react-hook-form\dist\index.d.ts") {
    $exports = Get-Content "node_modules\react-hook-form\dist\index.d.ts" -Head 50
    if ($exports -match "FormProvider") {
        Write-Host "   OK - FormProvider exporte" -ForegroundColor Green
    } else {
        Write-Host "   ERREUR - FormProvider non trouve" -ForegroundColor Red
    }
    
    if ($exports -match "Controller") {
        Write-Host "   OK - Controller exporte" -ForegroundColor Green
    } else {
        Write-Host "   ERREUR - Controller non trouve" -ForegroundColor Red
    }
    
    if ($exports -match "useFormContext") {
        Write-Host "   OK - useFormContext exporte" -ForegroundColor Green
    } else {
        Write-Host "   ERREUR - useFormContext non trouve" -ForegroundColor Red
    }
} else {
    Write-Host "   ERREUR - Fichier de types introuvable" -ForegroundColor Red
}

Write-Host ""
Write-Host "===================================================" -ForegroundColor Cyan
Write-Host "Appuyez sur une touche pour continuer..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

cd $MONOREPO
