Write-Host '======================================' -ForegroundColor Cyan
Write-Host '   VRAIE STRUCTURE DES PACKAGES' -ForegroundColor Cyan
Write-Host '======================================' -ForegroundColor Cyan

Write-Host "
[DATABASE PACKAGE]" -ForegroundColor Yellow
Get-ChildItem packages/database/src -File -ErrorAction SilentlyContinue | ForEach-Object {
    Write-Host "  - $($_.Name)" -ForegroundColor Cyan
}

Write-Host "
[SANITY PACKAGE]" -ForegroundColor Yellow
Get-ChildItem packages/sanity/src -File -ErrorAction SilentlyContinue | ForEach-Object {
    Write-Host "  - $($_.Name)" -ForegroundColor Cyan
}

Write-Host "
[AUTH PACKAGE]" -ForegroundColor Yellow
Get-ChildItem packages/auth/src -File -Recurse -ErrorAction SilentlyContinue | ForEach-Object {
    Write-Host "  - $($_.Name)" -ForegroundColor Cyan
}

Write-Host "
[UI COMPONENTS]" -ForegroundColor Yellow
$uiComponents = Get-ChildItem packages/ui/src/components -File -Recurse -Filter '*.tsx' -ErrorAction SilentlyContinue
Write-Host "  Total: $($uiComponents.Count) composants" -ForegroundColor Cyan

Write-Host "
[STOREFRONT COMPONENTS]" -ForegroundColor Yellow
if (Test-Path 'apps/storefront/components') {
    $storefrontComponents = Get-ChildItem apps/storefront/components -File -Recurse -Filter '*.tsx' -ErrorAction SilentlyContinue
    Write-Host "  Total: $($storefrontComponents.Count) composants" -ForegroundColor Cyan
} else {
    Write-Host "  Dossier n'existe pas" -ForegroundColor Gray
}

Write-Host "
[EMAIL TEMPLATES]" -ForegroundColor Yellow
Get-ChildItem packages/email/src -File -Recurse -ErrorAction SilentlyContinue | ForEach-Object {
    Write-Host "  - $($_.Name)" -ForegroundColor Cyan
}

Write-Host "
[UTILS]" -ForegroundColor Yellow
Get-ChildItem packages/utils/src -File -ErrorAction SilentlyContinue | ForEach-Object {
    Write-Host "  - $($_.Name)" -ForegroundColor Cyan
}

Write-Host "
======================================" -ForegroundColor Cyan
