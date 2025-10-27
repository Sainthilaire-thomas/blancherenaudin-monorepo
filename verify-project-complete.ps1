# ============================================================================
# SCRIPT DE VÉRIFICATION COMPLÈTE - Monorepo Blanche Renaudin
# ============================================================================
# Date: 26 octobre 2025
# Description: Vérifie l'état complet du projet après corrections
# ============================================================================

$ProjectRoot = "C:\Users\thoma\OneDrive\SONEAR_2025\blancherenaudin-monorepo"
$ErrorCount = 0
$WarningCount = 0

Write-Host "`n╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║     VÉRIFICATION COMPLÈTE - Monorepo Blanche Renaudin          ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

Set-Location $ProjectRoot

# ============================================================================
# 1. VÉRIFICATION EXPORTS PACKAGES/DATABASE
# ============================================================================
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Yellow
Write-Host "1️⃣  VÉRIFICATION EXPORTS packages/database" -ForegroundColor Yellow
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Yellow

$IndexPath = "packages\database\src\index.ts"
$ServerPath = "packages\database\src\server.ts"

Write-Host "`n📄 Vérification de $IndexPath..." -ForegroundColor Cyan

if (Test-Path $IndexPath) {
    $IndexContent = Get-Content $IndexPath -Raw
    
    # Vérifier que stripe N'EST PAS exporté depuis index.ts
    if ($IndexContent -match "export.*from.*['\`"]\.\/stripe['\`"]") {
        Write-Host "  ❌ ERREUR: stripe est exporté depuis index.ts (PUBLIC)" -ForegroundColor Red
        Write-Host "     → Cela cause l'erreur 'Missing STRIPE_SECRET_KEY' dans les Client Components" -ForegroundColor Red
        $ErrorCount++
    } else {
        Write-Host "  ✅ OK: stripe n'est PAS exporté depuis index.ts" -ForegroundColor Green
    }
    
    # Vérifier les exports sûrs
    $SafeExports = @(
        "client-browser",
        "client-server", 
        "types",
        "types-helpers"
    )
    
    foreach ($export in $SafeExports) {
        if ($IndexContent -match "export.*from.*['\`"]\./$export['\`"]") {
            Write-Host "  ✅ Export sûr trouvé: $export" -ForegroundColor Green
        } else {
            Write-Host "  ⚠️  Export manquant: $export" -ForegroundColor Yellow
            $WarningCount++
        }
    }
} else {
    Write-Host "  ❌ ERREUR: $IndexPath introuvable" -ForegroundColor Red
    $ErrorCount++
}

Write-Host "`n📄 Vérification de $ServerPath..." -ForegroundColor Cyan

if (Test-Path $ServerPath) {
    $ServerContent = Get-Content $ServerPath -Raw
    
    # Vérifier que stripe EST exporté depuis server.ts
    if ($ServerContent -match "export.*stripe.*from.*['\`"]\.\/stripe['\`"]") {
        Write-Host "  ✅ OK: stripe est exporté depuis server.ts" -ForegroundColor Green
    } else {
        Write-Host "  ❌ ERREUR: stripe n'est PAS exporté depuis server.ts" -ForegroundColor Red
        $ErrorCount++
    }
    
    # Vérifier les exports serveur
    $ServerExports = @(
        "client-admin",
        "stripe",
        "decrementStockForOrder"
    )
    
    foreach ($export in $ServerExports) {
        if ($ServerContent -match "$export") {
            Write-Host "  ✅ Export serveur trouvé: $export" -ForegroundColor Green
        } else {
            Write-Host "  ⚠️  Export serveur manquant: $export" -ForegroundColor Yellow
            $WarningCount++
        }
    }
} else {
    Write-Host "  ❌ ERREUR: $ServerPath introuvable" -ForegroundColor Red
    $ErrorCount++
}

# ============================================================================
# 2. VÉRIFICATION IMPORTS STRIPE DANS STOREFRONT
# ============================================================================
Write-Host "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Yellow
Write-Host "2️⃣  VÉRIFICATION IMPORTS STRIPE dans apps/storefront" -ForegroundColor Yellow
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Yellow

Write-Host "`n🔍 Recherche d'imports incorrects de stripe..." -ForegroundColor Cyan

$BadStripeImports = Get-ChildItem -Recurse -Include "*.ts","*.tsx" -Path "apps\storefront\app" | 
    Select-String "import.*stripe.*from.*['\`"]@repo\/database['\`"]" |
    Where-Object { $_.Line -notmatch "@repo\/database\/server" }

if ($BadStripeImports) {
    Write-Host "  ❌ ERREUR: Imports incorrects de stripe trouvés:" -ForegroundColor Red
    $BadStripeImports | ForEach-Object {
        Write-Host "     → $($_.Path):$($_.LineNumber)" -ForegroundColor Red
        Write-Host "       $($_.Line.Trim())" -ForegroundColor Gray
    }
    $ErrorCount += $BadStripeImports.Count
    
    Write-Host "`n  💡 CORRECTION NÉCESSAIRE:" -ForegroundColor Yellow
    Write-Host "     Remplacer par: import { stripe } from '@repo/database/server'" -ForegroundColor Yellow
} else {
    Write-Host "  ✅ OK: Aucun import incorrect de stripe trouvé" -ForegroundColor Green
}

# Vérifier les imports corrects
$GoodStripeImports = Get-ChildItem -Recurse -Include "*.ts","*.tsx" -Path "apps\storefront\app" | 
    Select-String "import.*stripe.*from.*['\`"]@repo\/database\/server['\`"]"

if ($GoodStripeImports) {
    Write-Host "`n  ✅ Imports corrects trouvés: $($GoodStripeImports.Count)" -ForegroundColor Green
    $GoodStripeImports | ForEach-Object {
        Write-Host "     → $($_.Path | Split-Path -Leaf):$($_.LineNumber)" -ForegroundColor Green
    }
}

# ============================================================================
# 3. VÉRIFICATION SUPABASE ADMIN
# ============================================================================
Write-Host "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Yellow
Write-Host "3️⃣  VÉRIFICATION IMPORTS SUPABASE ADMIN" -ForegroundColor Yellow
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Yellow

Write-Host "`n🔍 Recherche d'imports incorrects de supabaseAdmin..." -ForegroundColor Cyan

$BadAdminImports = Get-ChildItem -Recurse -Include "*.ts","*.tsx" -Path "apps\storefront\app" | 
    Select-String "import.*supabaseAdmin.*from.*['\`"]@repo\/database['\`"]" |
    Where-Object { $_.Line -notmatch "@repo\/database\/server" }

if ($BadAdminImports) {
    Write-Host "  ❌ ERREUR: Imports incorrects de supabaseAdmin trouvés:" -ForegroundColor Red
    $BadAdminImports | ForEach-Object {
        Write-Host "     → $($_.Path):$($_.LineNumber)" -ForegroundColor Red
    }
    $ErrorCount += $BadAdminImports.Count
} else {
    Write-Host "  ✅ OK: Aucun import incorrect de supabaseAdmin trouvé" -ForegroundColor Green
}

# ============================================================================
# 4. TYPECHECK
# ============================================================================
Write-Host "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Yellow
Write-Host "4️⃣  TYPECHECK TypeScript" -ForegroundColor Yellow
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Yellow

Write-Host "`n📦 Typecheck packages/database..." -ForegroundColor Cyan
Set-Location "packages\database"
$TypeCheckDatabase = pnpm exec tsc --noEmit 2>&1
$DatabaseErrors = $TypeCheckDatabase | Select-String "error TS"

if ($DatabaseErrors) {
    Write-Host "  ❌ ERREURS TypeScript dans packages/database:" -ForegroundColor Red
    $DatabaseErrors | ForEach-Object {
        Write-Host "     $_" -ForegroundColor Red
    }
    $ErrorCount += $DatabaseErrors.Count
} else {
    Write-Host "  ✅ OK: Aucune erreur TypeScript dans packages/database" -ForegroundColor Green
}

Set-Location $ProjectRoot

Write-Host "`n📦 Typecheck apps/storefront..." -ForegroundColor Cyan
Set-Location "apps\storefront"
$TypeCheckStorefront = pnpm exec tsc --noEmit 2>&1
$StorefrontErrors = $TypeCheckStorefront | Select-String "error TS"

if ($StorefrontErrors) {
    Write-Host "  ❌ ERREURS TypeScript dans apps/storefront:" -ForegroundColor Red
    $StorefrontErrors | Select-Object -First 10 | ForEach-Object {
        Write-Host "     $_" -ForegroundColor Red
    }
    if ($StorefrontErrors.Count -gt 10) {
        Write-Host "     ... et $($StorefrontErrors.Count - 10) autres erreurs" -ForegroundColor Red
    }
    $ErrorCount += $StorefrontErrors.Count
} else {
    Write-Host "  ✅ OK: Aucune erreur TypeScript dans apps/storefront" -ForegroundColor Green
}

Set-Location $ProjectRoot

# ============================================================================
# 5. VARIABLES D'ENVIRONNEMENT
# ============================================================================
Write-Host "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Yellow
Write-Host "5️⃣  VÉRIFICATION VARIABLES D'ENVIRONNEMENT" -ForegroundColor Yellow
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Yellow

$EnvPath = "apps\storefront\.env.local"

Write-Host "`n📄 Vérification de $EnvPath..." -ForegroundColor Cyan

if (Test-Path $EnvPath) {
    $EnvContent = Get-Content $EnvPath -Raw
    
    $RequiredVars = @{
        "NEXT_PUBLIC_SUPABASE_URL" = "Supabase URL publique"
        "NEXT_PUBLIC_SUPABASE_ANON_KEY" = "Supabase clé anonyme publique"
        "SUPABASE_SERVICE_ROLE_KEY" = "Supabase clé service (admin)"
        "STRIPE_SECRET_KEY" = "Stripe clé secrète"
        "STRIPE_PUBLISHABLE_KEY" = "Stripe clé publique"
        "STRIPE_WEBHOOK_SECRET" = "Stripe webhook secret"
        "RESEND_API_KEY" = "Resend API key"
        "RESEND_FROM_EMAIL" = "Resend email expéditeur"
    }
    
    $MissingVars = @()
    
    foreach ($var in $RequiredVars.Keys) {
        if ($EnvContent -match "$var\s*=\s*.+") {
            Write-Host "  ✅ $var définie" -ForegroundColor Green
        } else {
            Write-Host "  ❌ $var MANQUANTE - $($RequiredVars[$var])" -ForegroundColor Red
            $MissingVars += $var
            $ErrorCount++
        }
    }
    
    # Vérifier l'ancienne variable incorrecte
    if ($EnvContent -match "SUPABASE_SERVICE_KEY\s*=") {
        Write-Host "  ⚠️  WARNING: Ancienne variable SUPABASE_SERVICE_KEY détectée" -ForegroundColor Yellow
        Write-Host "     → Utiliser SUPABASE_SERVICE_ROLE_KEY à la place" -ForegroundColor Yellow
        $WarningCount++
    }
    
    if ($MissingVars.Count -gt 0) {
        Write-Host "`n  💡 Variables manquantes à ajouter:" -ForegroundColor Yellow
        foreach ($var in $MissingVars) {
            Write-Host "     $var=$($RequiredVars[$var])" -ForegroundColor Yellow
        }
    }
} else {
    Write-Host "  ❌ ERREUR: $EnvPath introuvable" -ForegroundColor Red
    Write-Host "     Copier .env.example vers .env.local et remplir les valeurs" -ForegroundColor Yellow
    $ErrorCount++
}

# ============================================================================
# 6. STRUCTURE DES FICHIERS
# ============================================================================
Write-Host "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Yellow
Write-Host "6️⃣  VÉRIFICATION STRUCTURE DES FICHIERS" -ForegroundColor Yellow
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Yellow

$CriticalFiles = @(
    "packages\database\src\index.ts",
    "packages\database\src\server.ts",
    "packages\database\src\client-browser.ts",
    "packages\database\src\client-server.ts",
    "packages\database\src\client-admin.ts",
    "packages\database\src\stripe.ts",
    "packages\database\src\stock\decrement-stock.ts",
    "apps\storefront\app\api\webhooks\stripe\route.ts",
    "apps\storefront\app\layout.tsx",
    "apps\storefront\app\globals.css",
    "apps\storefront\tailwind.config.ts"
)

Write-Host "`n🔍 Vérification des fichiers critiques..." -ForegroundColor Cyan

foreach ($file in $CriticalFiles) {
    if (Test-Path $file) {
        Write-Host "  ✅ $file" -ForegroundColor Green
    } else {
        Write-Host "  ❌ $file MANQUANT" -ForegroundColor Red
        $ErrorCount++
    }
}

# ============================================================================
# 7. BUILD TEST
# ============================================================================
Write-Host "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Yellow
Write-Host "7️⃣  TEST DE BUILD" -ForegroundColor Yellow
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Yellow

Write-Host "`n🔨 Build de packages/database..." -ForegroundColor Cyan
Set-Location "packages\database"
$BuildDatabase = pnpm run build 2>&1
$BuildDatabaseErrors = $BuildDatabase | Select-String "error"

if ($BuildDatabaseErrors) {
    Write-Host "  ❌ ERREURS lors du build de packages/database" -ForegroundColor Red
    $BuildDatabaseErrors | Select-Object -First 5 | ForEach-Object {
        Write-Host "     $_" -ForegroundColor Red
    }
    $ErrorCount++
} else {
    Write-Host "  ✅ Build de packages/database réussi" -ForegroundColor Green
}

Set-Location $ProjectRoot

# ============================================================================
# RÉSUMÉ FINAL
# ============================================================================
Write-Host "`n╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                      RÉSUMÉ DE LA VÉRIFICATION                 ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

Write-Host "`n📊 Statistiques:" -ForegroundColor White
Write-Host "   • Erreurs critiques: $ErrorCount" -ForegroundColor $(if ($ErrorCount -eq 0) { "Green" } else { "Red" })
Write-Host "   • Avertissements: $WarningCount" -ForegroundColor $(if ($WarningCount -eq 0) { "Green" } else { "Yellow" })

if ($ErrorCount -eq 0 -and $WarningCount -eq 0) {
    Write-Host "`n✅ FÉLICITATIONS! Le projet est correctement configuré." -ForegroundColor Green
    Write-Host "   Vous pouvez lancer le dev serveur avec:" -ForegroundColor Green
    Write-Host "   cd apps\storefront" -ForegroundColor Cyan
    Write-Host "   pnpm dev" -ForegroundColor Cyan
} elseif ($ErrorCount -eq 0) {
    Write-Host "`n⚠️  Le projet fonctionne mais a quelques avertissements mineurs." -ForegroundColor Yellow
    Write-Host "   Vous pouvez lancer le dev serveur, mais corrigez les avertissements." -ForegroundColor Yellow
} else {
    Write-Host "`n❌ ATTENTION: Des erreurs critiques doivent être corrigées." -ForegroundColor Red
    Write-Host "   Consultez les détails ci-dessus pour les résoudre." -ForegroundColor Red
}

Write-Host "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`n" -ForegroundColor Cyan
