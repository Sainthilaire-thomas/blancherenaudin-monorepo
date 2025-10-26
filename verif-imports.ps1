# Script de verification de l'etat des imports
Write-Host "`n--- Verification de l'etat actuel des imports ---`n" -ForegroundColor Cyan

Set-Location "apps\storefront\app"

Write-Host "Dossier analyse: $(Get-Location)`n" -ForegroundColor Gray

# Patterns a verifier
$patterns = @(
    "@/components/ui/",
    "@/lib/supabase-server",
    "@/lib/supabase-browser", 
    "@/lib/supabase-admin",
    "@/lib/database.types",
    "@/lib/sanity.client",
    "@/lib/sanity.image",
    "@/lib/queries",
    "@/lib/email/",
    "@/lib/stripe"
)

$totalIssues = 0

foreach ($pattern in $patterns) {
    Write-Host "Recherche de '$pattern'..." -ForegroundColor Cyan
    
    $results = Get-ChildItem -Recurse -Include "*.tsx", "*.ts" -File | Select-String -Pattern $pattern -SimpleMatch
    
    if ($results) {
        $count = ($results | Measure-Object).Count
        $totalIssues += $count
        Write-Host "   ATTENTION: Trouve $count occurrence(s)" -ForegroundColor Yellow
        
        # Afficher les 3 premiers fichiers concernes
        $results | Select-Object -First 3 | ForEach-Object {
            Write-Host "      - $($_.Filename):$($_.LineNumber)" -ForegroundColor Gray
        }
        Write-Host ""
    } else {
        Write-Host "   OK: Aucune occurrence" -ForegroundColor Green
    }
}

Write-Host "`n=== RESUME ===" -ForegroundColor Cyan
Write-Host "   Total d'imports a corriger: $totalIssues`n" -ForegroundColor Yellow

if ($totalIssues -eq 0) {
    Write-Host "PARFAIT: Tous les imports sont corriges!" -ForegroundColor Green
    Write-Host "`nProchaine etape:" -ForegroundColor Cyan
    Write-Host "   cd ..\..\.." -ForegroundColor Gray
    Write-Host "   cd apps\storefront" -ForegroundColor Gray
    Write-Host "   Remove-Item -Recurse -Force .next -ErrorAction SilentlyContinue" -ForegroundColor Gray
    Write-Host "   pnpm dev" -ForegroundColor Gray
} else {
    Write-Host "ATTENTION: Il reste des imports a corriger" -ForegroundColor Yellow
    Write-Host "`nProchaine etape:" -ForegroundColor Cyan
    Write-Host "   cd ..\..\.." -ForegroundColor Gray
    Write-Host "   .\fix-imports-ultra-compatible.ps1" -ForegroundColor Gray
}

Write-Host ""

Set-Location "..\..\.."
