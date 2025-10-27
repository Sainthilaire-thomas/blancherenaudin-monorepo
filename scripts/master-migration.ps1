# Script PowerShell Master - Migration Monorepo Blanche Renaudin
# Usage: .\master-migration.ps1 -ProjectRoot "C:\path\to\monorepo"

param(
    [Parameter(Mandatory=$false)]
    [string]$ProjectRoot = ".",
    
    [Parameter(Mandatory=$false)]
    [ValidateSet("status", "stripe-check", "migrate-stripe", "test-stripe", "all")]
    [string]$Action = "status"
)

$ErrorActionPreference = "Stop"

# Couleurs et emojis
function Write-Header {
    param([string]$Text)
    Write-Host "`n" -NoNewline
    Write-Host $Text -ForegroundColor Cyan
    Write-Host ("=" * 70) -ForegroundColor Gray
}

function Write-Section {
    param([string]$Text)
    Write-Host "`n$Text" -ForegroundColor Yellow
    Write-Host ("-" * 70) -ForegroundColor Gray
}

function Write-Success {
    param([string]$Text)
    Write-Host "✅ $Text" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Text)
    Write-Host "⚠️  $Text" -ForegroundColor Yellow
}

function Write-Error-Custom {
    param([string]$Text)
    Write-Host "❌ $Text" -ForegroundColor Red
}

function Write-Info {
    param([string]$Text)
    Write-Host "ℹ️  $Text" -ForegroundColor Cyan
}

# Banner
Write-Host "`n"
Write-Host "╔═══════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                                                                   ║" -ForegroundColor Cyan
Write-Host "║        🚀 MIGRATION MONOREPO BLANCHE RENAUDIN 🚀                ║" -ForegroundColor Cyan
Write-Host "║                                                                   ║" -ForegroundColor Cyan
Write-Host "║        Version: 1.0.0 | Date: $(Get-Date -Format 'dd/MM/yyyy')              ║" -ForegroundColor Cyan
Write-Host "║                                                                   ║" -ForegroundColor Cyan
Write-Host "╚═══════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan

Write-Info "Projet: $ProjectRoot"
Write-Info "Action: $Action"
Write-Host ""

# Vérifier que le projet existe
if (-not (Test-Path $ProjectRoot)) {
    Write-Error-Custom "Projet introuvable: $ProjectRoot"
    Write-Host "`nUsage: .\master-migration.ps1 -ProjectRoot 'C:\chemin\vers\projet' -Action status" -ForegroundColor Yellow
    exit 1
}

# Fonction: Vérifier l'existence d'un module
function Test-Module {
    param([string]$Path, [string]$Name)
    
    $fullPath = Join-Path $ProjectRoot $Path
    if (Test-Path $fullPath) {
        Write-Success "$Name"
        return $true
    } else {
        Write-Error-Custom "$Name (manquant: $Path)"
        return $false
    }
}

# Fonction: Compter les fichiers
function Get-FileCount {
    param([string]$Path, [string]$Pattern = "*.tsx")
    
    $fullPath = Join-Path $ProjectRoot $Path
    if (Test-Path $fullPath) {
        return (Get-ChildItem -Path $fullPath -Filter $Pattern -Recurse -File -ErrorAction SilentlyContinue).Count
    }
    return 0
}

# ACTION: Status général
if ($Action -eq "status" -or $Action -eq "all") {
    Write-Header "📊 ÉTAT DE LA MIGRATION"
    
    # Packages
    Write-Section "📦 PACKAGES"
    
    $packages = @(
        @{Path="packages\config"; Name="config"},
        @{Path="packages\database"; Name="database"},
        @{Path="packages\ui"; Name="ui"},
        @{Path="packages\utils"; Name="utils"},
        @{Path="packages\auth"; Name="auth"},
        @{Path="packages\email"; Name="email"},
        @{Path="packages\sanity"; Name="sanity"},
        @{Path="packages\shipping"; Name="shipping"},
        @{Path="packages\analytics"; Name="analytics"},
        @{Path="packages\newsletter"; Name="newsletter"}
    )
    
    $packagesExist = 0
    foreach ($pkg in $packages) {
        if (Test-Module -Path $pkg.Path -Name "@repo/$($pkg.Name)") {
            $packagesExist++
        }
    }
    
    Write-Host "`n   Progress: $packagesExist / $($packages.Count) packages" -ForegroundColor Cyan
    $packageProgress = [math]::Round(($packagesExist / $packages.Count) * 100)
    Write-Host "   [$('█' * [math]::Floor($packageProgress / 5))$('░' * (20 - [math]::Floor($packageProgress / 5)))] $packageProgress%" -ForegroundColor Green
    
    # Applications
    Write-Section "🏪 APPLICATIONS"
    
    $storefrontExists = Test-Module -Path "apps\storefront" -Name "storefront"
    $adminExists = Test-Module -Path "apps\admin" -Name "admin"
    
    if ($storefrontExists) {
        $pageCount = Get-FileCount -Path "apps\storefront\app" -Pattern "page.tsx"
        Write-Info "  → $pageCount pages dans storefront"
        
        # Compter les routes API
        $apiPath = Join-Path $ProjectRoot "apps\storefront\app\api"
        if (Test-Path $apiPath) {
            $apiRoutes = (Get-ChildItem -Path $apiPath -Filter "route.ts*" -Recurse -File -ErrorAction SilentlyContinue).Count
            Write-Info "  → $apiRoutes routes API"
        }
    }
    
    if ($adminExists) {
        $pageCount = Get-FileCount -Path "apps\admin\app" -Pattern "page.tsx"
        Write-Info "  → $pageCount pages dans admin"
    }
    
    # Routes critiques Stripe
    Write-Section "💳 ROUTES CRITIQUES STRIPE"
    
    $stripeRoutes = @(
        @{Path="apps\storefront\app\api\webhooks\stripe\route.ts"; Name="Webhook Stripe"},
        @{Path="apps\storefront\app\api\checkout\create-session\route.ts"; Name="Create Checkout Session"},
        @{Path="apps\storefront\app\api\orders\by-session\[sessionId]\route.ts"; Name="Get Order by Session"}
    )
    
    $stripeRoutesExist = 0
    foreach ($route in $stripeRoutes) {
        if (Test-Module -Path $route.Path -Name $route.Name) {
            $stripeRoutesExist++
        }
    }
    
    Write-Host "`n   Progress: $stripeRoutesExist / $($stripeRoutes.Count) routes" -ForegroundColor Cyan
    
    # Recommandations
    Write-Section "💡 RECOMMANDATIONS"
    
    if ($packagesExist -eq $packages.Count -and $storefrontExists -and $stripeRoutesExist -eq $stripeRoutes.Count) {
        Write-Success "Structure de base complète!"
        Write-Info "Prochaine étape: Tests avec 'pnpm dev' et Stripe CLI"
    } elseif ($packagesExist -eq $packages.Count -and $storefrontExists) {
        Write-Warning "Packages OK, mais routes Stripe manquantes"
        Write-Info "Utiliser: .\master-migration.ps1 -Action migrate-stripe"
    } elseif ($packagesExist -gt 5) {
        Write-Warning "Migration en cours..."
        Write-Info "Continuer la création des packages manquants"
    } else {
        Write-Error-Custom "Migration au début"
        Write-Info "Commencer par créer les packages de base"
    }
}

# ACTION: Vérification détaillée Stripe
if ($Action -eq "stripe-check" -or $Action -eq "all") {
    Write-Header "💳 VÉRIFICATION DÉTAILLÉE STRIPE"
    
    # Vérifier le webhook
    $webhookPath = Join-Path $ProjectRoot "apps\storefront\app\api\webhooks\stripe\route.ts"
    
    if (Test-Path $webhookPath) {
        Write-Success "Webhook Stripe trouvé"
        
        $content = Get-Content -Path $webhookPath -Raw
        $lines = (Get-Content -Path $webhookPath).Count
        
        Write-Info "  → $lines lignes de code"
        
        # Vérifier les fonctions critiques
        $functions = @(
            "handleCheckoutSessionCompleted",
            "handlePaymentIntentSucceeded",
            "createOrderItemsFromSession",
            "parseAddress"
        )
        
        Write-Section "🔧 FONCTIONS IMPLÉMENTÉES"
        foreach ($func in $functions) {
            if ($content -match $func) {
                Write-Success "$func"
            } else {
                Write-Error-Custom "$func (manquante)"
            }
        }
        
        # Vérifier les imports
        Write-Section "📦 IMPORTS"
        
        $hasMonorepoImports = $content -match "@repo/"
        $hasOldImports = $content -match "from '@/"
        
        if ($hasMonorepoImports -and -not $hasOldImports) {
            Write-Success "Imports au format monorepo"
        } elseif ($hasOldImports) {
            Write-Warning "Imports à l'ancien format détectés"
            Write-Info "Transformation nécessaire avec migrate-stripe"
        }
        
    } else {
        Write-Error-Custom "Webhook Stripe manquant"
        Write-Info "Fichier attendu: $webhookPath"
    }
}

# ACTION: Migration Stripe
if ($Action -eq "migrate-stripe") {
    Write-Header "🔄 MIGRATION ROUTES STRIPE"
    
    Write-Warning "Cette action va déployer la version corrigée du webhook Stripe"
    Write-Host "`nAssurez-vous d'avoir le fichier 'webhook_stripe_route_ts_-_VERSION_CORRIGÉE_COMPLÈTE.txt'" -ForegroundColor Yellow
    
    $confirm = Read-Host "`nContinuer? (o/N)"
    
    if ($confirm -eq "o" -or $confirm -eq "O") {
        # Appeler le script de déploiement
        $deployScript = Join-Path $PSScriptRoot "deploy-stripe-webhook.ps1"
        
        if (Test-Path $deployScript) {
            Write-Info "Lancement du script de déploiement..."
            & $deployScript -ProjectRoot $ProjectRoot -Backup
        } else {
            Write-Error-Custom "Script deploy-stripe-webhook.ps1 introuvable"
        }
    } else {
        Write-Info "Migration annulée"
    }
}

# ACTION: Tests Stripe
if ($Action -eq "test-stripe") {
    Write-Header "🧪 TESTS STRIPE"
    
    Write-Section "📝 COMMANDES DE TEST"
    
    Write-Host "`n1️⃣  Terminal 1 - Serveur de développement:"
    Write-Host "   cd apps\storefront" -ForegroundColor Cyan
    Write-Host "   pnpm dev" -ForegroundColor Cyan
    
    Write-Host "`n2️⃣  Terminal 2 - Stripe CLI:"
    Write-Host "   stripe login" -ForegroundColor Cyan
    Write-Host "   stripe listen --forward-to localhost:3000/api/webhooks/stripe" -ForegroundColor Cyan
    
    Write-Host "`n3️⃣  Terminal 3 - Déclencher un événement test:"
    Write-Host "   stripe trigger checkout.session.completed" -ForegroundColor Cyan
    
    Write-Section "✅ VÉRIFICATIONS ATTENDUES"
    
    Write-Host "`n• Le webhook doit recevoir l'événement" -ForegroundColor White
    Write-Host "• Une commande doit être créée en DB" -ForegroundColor White
    Write-Host "• Les order_items doivent être créés" -ForegroundColor White
    Write-Host "• Le stock doit être décrémenté" -ForegroundColor White
    Write-Host "• Un email de confirmation doit être envoyé" -ForegroundColor White
    
    Write-Section "📊 LOGS À SURVEILLER"
    
    Write-Host "`nDans les logs du serveur, chercher:" -ForegroundColor Yellow
    Write-Host "   🔔 Webhook received: checkout.session.completed" -ForegroundColor Cyan
    Write-Host "   ✅ Order found: ..." -ForegroundColor Cyan
    Write-Host "   ✅ Stock decremented: X items" -ForegroundColor Cyan
    Write-Host "   📧 Confirmation email sent successfully" -ForegroundColor Cyan
}

# Footer
Write-Host "`n"
Write-Host ("─" * 70) -ForegroundColor Gray
Write-Host "✨ Script terminé | $(Get-Date -Format 'HH:mm:ss')" -ForegroundColor Cyan
Write-Host ("─" * 70) -ForegroundColor Gray
Write-Host ""
