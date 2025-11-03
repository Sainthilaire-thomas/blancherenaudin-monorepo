# debug-admin-build-simple.ps1
# Script simplifie de diagnostic

Write-Host "===================================================" -ForegroundColor Cyan
Write-Host "   Diagnostic Build Admin" -ForegroundColor Cyan
Write-Host "===================================================" -ForegroundColor Cyan
Write-Host ""

$MONOREPO_PATH = "C:\Users\thoma\OneDrive\SONEAR_2025\blancherenaudin-monorepo"
$LOG_FILE = Join-Path $MONOREPO_PATH "build-debug.txt"

if (-Not (Test-Path $MONOREPO_PATH)) {
    Write-Host "Erreur: Monorepo introuvable" -ForegroundColor Red
    exit 1
}

cd $MONOREPO_PATH

Write-Host "Repertoire: $MONOREPO_PATH" -ForegroundColor Green
Write-Host "Logs: $LOG_FILE" -ForegroundColor Green
Write-Host ""

# Etape 1: Nettoyer les caches
Write-Host "Etape 1: Nettoyage des caches..." -ForegroundColor Yellow
Remove-Item -Path "apps\admin\.next" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path ".turbo" -Recurse -Force -ErrorAction SilentlyContinue
Write-Host "   OK - Caches nettoyes" -ForegroundColor Green
Write-Host ""

# Etape 2: Type-check
Write-Host "Etape 2: Type-check de l'admin..." -ForegroundColor Yellow
cd apps\admin
$typecheckOutput = pnpm run type-check 2>&1 | Out-String
if ($LASTEXITCODE -ne 0) {
    Write-Host "   ERREUR - Type-check echoue" -ForegroundColor Red
    Write-Host $typecheckOutput
    $typecheckOutput | Out-File -FilePath $LOG_FILE -Append
} else {
    Write-Host "   OK - Type-check passe" -ForegroundColor Green
}
Write-Host ""

# Etape 3: Build avec logs
Write-Host "Etape 3: Build avec logs detailles..." -ForegroundColor Yellow
Write-Host "   (Cela peut prendre 1-2 minutes)" -ForegroundColor Gray
Write-Host ""

$buildOutput = pnpm build 2>&1 | Out-String
$buildOutput | Out-File -FilePath $LOG_FILE

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERREUR - Build echoue" -ForegroundColor Red
    Write-Host ""
    Write-Host "Logs complets dans: $LOG_FILE" -ForegroundColor Yellow
    Write-Host ""
    
    # Afficher les erreurs
    Write-Host "Erreurs detectees:" -ForegroundColor Red
    $lines = $buildOutput -split "`n"
    $errorLines = $lines | Where-Object { $_ -match "error|Error|ERROR|failed|Failed" }
    
    if ($errorLines.Count -gt 0) {
        $errorLines | Select-Object -First 15 | ForEach-Object { 
            Write-Host "   $_" -ForegroundColor Red 
        }
    } else {
        Write-Host "   Aucune erreur explicite trouvee" -ForegroundColor Yellow
        Write-Host "   20 dernieres lignes:" -ForegroundColor Yellow
        $lines | Select-Object -Last 20 | ForEach-Object { 
            Write-Host "   $_" -ForegroundColor Gray 
        }
    }
} else {
    Write-Host "OK - Build reussi" -ForegroundColor Green
}

Write-Host ""
Write-Host "===================================================" -ForegroundColor Cyan
Write-Host "Pour voir les logs: code $LOG_FILE" -ForegroundColor Yellow
Write-Host ""

cd $MONOREPO_PATH
