# Script PowerShell - Vérification détaillée des routes Stripe
# Usage: .\check-stripe-routes.ps1 -ProjectRoot "C:\path\to\project"

param(
    [Parameter(Mandatory=$false)]
    [string]$ProjectRoot = "."
)

Write-Host "`n💳 VÉRIFICATION ROUTES STRIPE" -ForegroundColor Cyan
Write-Host "=" * 70 -ForegroundColor Gray

# Fonction pour analyser un fichier route
function Analyze-RouteFile {
    param([string]$FilePath, [string]$RouteName)
    
    Write-Host "`n📄 $RouteName" -ForegroundColor Yellow
    Write-Host "   Chemin: $FilePath" -ForegroundColor Gray
    
    if (-not (Test-Path $FilePath)) {
        Write-Host "   ❌ Fichier manquant" -ForegroundColor Red
        return @{Exists=$false; HasContent=$false; Lines=0; Imports=@(); Functions=@()}
    }
    
    Write-Host "   ✅ Fichier existe" -ForegroundColor Green
    
    $content = Get-Content -Path $FilePath -Raw
    $lines = (Get-Content -Path $FilePath).Count
    
    Write-Host "   📏 $lines lignes de code" -ForegroundColor Cyan
    
    # Vérifier si c'est un stub ou un vrai fichier
    $isStub = $content -match "TODO|STUB|NOT_IMPLEMENTED|placeholder" -and $lines -lt 20
    
    if ($isStub) {
        Write-Host "   ⚠️  STUB détecté (à implémenter)" -ForegroundColor Yellow
    } else {
        Write-Host "   ✅ Implémentation complète" -ForegroundColor Green
    }
    
    # Extraire les imports
    $imports = [regex]::Matches($content, "import\s+.*?\s+from\s+['\"](.+?)['\"]") | 
               ForEach-Object { $_.Groups[1].Value }
    
    if ($imports.Count -gt 0) {
        Write-Host "   📦 Imports ($($imports.Count)):" -ForegroundColor Cyan
        $imports | Select-Object -First 5 | ForEach-Object {
            Write-Host "      • $_" -ForegroundColor White
        }
        if ($imports.Count -gt 5) {
            Write-Host "      • ... et $($imports.Count - 5) autres" -ForegroundColor Gray
        }
    }
    
    # Extraire les fonctions
    $functions = [regex]::Matches($content, "(async\s+)?function\s+(\w+)|const\s+(\w+)\s*=\s*(async\s*)?\(") |
                 ForEach-Object { 
                     if ($_.Groups[2].Success) { $_.Groups[2].Value }
                     elseif ($_.Groups[3].Success) { $_.Groups[3].Value }
                 }
    
    if ($functions.Count -gt 0) {
        Write-Host "   🔧 Fonctions ($($functions.Count)):" -ForegroundColor Cyan
        $functions | ForEach-Object {
            Write-Host "      • $_" -ForegroundColor White
        }
    }
    
    # Vérifier les exports HTTP
    $hasPOST = $content -match "export\s+(async\s+)?function\s+POST"
    $hasGET = $content -match "export\s+(async\s+)?function\s+GET"
    $hasPUT = $content -match "export\s+(async\s+)?function\s+PUT"
    $hasDELETE = $content -match "export\s+(async\s+)?function\s+DELETE"
    
    $methods = @()
    if ($hasPOST) { $methods += "POST" }
    if ($hasGET) { $methods += "GET" }
    if ($hasPUT) { $methods += "PUT" }
    if ($hasDELETE) { $methods += "DELETE" }
    
    if ($methods.Count -gt 0) {
        Write-Host "   🌐 Méthodes HTTP: $($methods -join ', ')" -ForegroundColor Cyan
    }
    
    # Vérifier les dépendances critiques
    $hasStripe = $content -match "@/lib/stripe|from\s+['\"]stripe['\"]"
    $hasSupabase = $content -match "supabase|@repo/database"
    $hasEmail = $content -match "@repo/email|send.*email"
    
    Write-Host "   🔍 Dépendances:" -ForegroundColor Cyan
    Write-Host "      • Stripe: $(if ($hasStripe) { '✅' } else { '❌' })" -ForegroundColor $(if ($hasStripe) { "Green" } else { "Red" })
    Write-Host "      • Supabase: $(if ($hasSupabase) { '✅' } else { '❌' })" -ForegroundColor $(if ($hasSupabase) { "Green" } else { "Red" })
    Write-Host "      • Email: $(if ($hasEmail) { '✅' } else { '❌' })" -ForegroundColor $(if ($hasEmail) { "Green" } else { "Red" })
    
    return @{
        Exists=$true
        IsStub=$isStub
        Lines=$lines
        Imports=$imports
        Functions=$functions
        Methods=$methods
        HasStripe=$hasStripe
        HasSupabase=$hasSupabase
        HasEmail=$hasEmail
    }
}

# Routes à vérifier
$routes = @(
    @{
        Name="Checkout Session Creation"
        Path="apps\storefront\app\api\checkout\create-session\route.ts"
        Priority="🔴 CRITIQUE"
        Description="Crée la session Stripe et la commande en DB"
    },
    @{
        Name="Stripe Webhook"
        Path="apps\storefront\app\api\webhooks\stripe\route.ts"
        Priority="🔴 CRITIQUE"
        Description="Traite les événements Stripe (payment_intent.succeeded, etc.)"
    },
    @{
        Name="Order by Session"
        Path="apps\storefront\app\api\orders\by-session\[sessionId]\route.ts"
        Priority="🟡 IMPORTANT"
        Description="Récupère une commande depuis son session ID"
    },
    @{
        Name="Signed URLs Images"
        Path="apps\storefront\app\api\admin\product-images\[imageId]\signed-url\route.ts"
        Priority="🟡 IMPORTANT"
        Description="Génère des URLs signées pour les images produits"
    }
)

Write-Host "`n📋 ANALYSE DES ROUTES" -ForegroundColor Cyan
Write-Host "-" * 70 -ForegroundColor Gray

$results = @{}
foreach ($route in $routes) {
    $fullPath = Join-Path $ProjectRoot $route.Path
    $analysis = Analyze-RouteFile -FilePath $fullPath -RouteName $route.Name
    
    Write-Host "`n   Priority: $($route.Priority)" -ForegroundColor White
    Write-Host "   Description: $($route.Description)" -ForegroundColor Gray
    
    $results[$route.Name] = $analysis
}

# Résumé
Write-Host "`n`n📊 RÉSUMÉ STRIPE" -ForegroundColor Yellow
Write-Host "-" * 70 -ForegroundColor Gray

$totalRoutes = $routes.Count
$existingRoutes = ($results.Values | Where-Object { $_.Exists }).Count
$completeRoutes = ($results.Values | Where-Object { $_.Exists -and -not $_.IsStub }).Count
$stubRoutes = ($results.Values | Where-Object { $_.IsStub }).Count

Write-Host "`n✅ Routes existantes: $existingRoutes/$totalRoutes" -ForegroundColor Green
Write-Host "🟢 Routes complètes: $completeRoutes/$totalRoutes" -ForegroundColor $(if ($completeRoutes -eq $totalRoutes) { "Green" } elseif ($completeRoutes -gt 0) { "Yellow" } else { "Red" })
Write-Host "⚠️  Stubs à compléter: $stubRoutes" -ForegroundColor $(if ($stubRoutes -eq 0) { "Green" } else { "Yellow" })
Write-Host "❌ Routes manquantes: $($totalRoutes - $existingRoutes)" -ForegroundColor $(if ($existingRoutes -eq $totalRoutes) { "Green" } else { "Red" })

# Recommandations
Write-Host "`n`n💡 RECOMMANDATIONS" -ForegroundColor Yellow
Write-Host "-" * 70 -ForegroundColor Gray

if ($existingRoutes -eq $totalRoutes -and $stubRoutes -eq 0) {
    Write-Host "`n🎉 Toutes les routes Stripe sont implémentées!" -ForegroundColor Green
    Write-Host "   → Prêt pour les tests avec Stripe CLI" -ForegroundColor Cyan
} elseif ($existingRoutes -eq $totalRoutes) {
    Write-Host "`n⚠️  Toutes les routes existent mais certaines sont des stubs" -ForegroundColor Yellow
    Write-Host "   → Priorité: compléter les implémentations manquantes" -ForegroundColor Cyan
} else {
    Write-Host "`n❌ Routes manquantes détectées" -ForegroundColor Red
    Write-Host "   → Priorité: créer les routes manquantes" -ForegroundColor Cyan
}

# Commandes de test suggérées
if ($completeRoutes -gt 0) {
    Write-Host "`n`n🧪 COMMANDES DE TEST" -ForegroundColor Yellow
    Write-Host "-" * 70 -ForegroundColor Gray
    
    Write-Host "`n# Lancer le serveur de dev"
    Write-Host "cd apps/storefront" -ForegroundColor Cyan
    Write-Host "pnpm dev" -ForegroundColor Cyan
    
    if ($results["Stripe Webhook"].Exists -and -not $results["Stripe Webhook"].IsStub) {
        Write-Host "`n# Tester le webhook Stripe (dans un autre terminal)"
        Write-Host "stripe listen --forward-to localhost:3000/api/webhooks/stripe" -ForegroundColor Cyan
        Write-Host "stripe trigger checkout.session.completed" -ForegroundColor Cyan
    }
}

Write-Host "`n`n✨ Vérification terminée!`n" -ForegroundColor Cyan
