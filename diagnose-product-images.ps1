# ============================================================================
# DIAGNOSTIC - Images Produits dans Supabase
# ============================================================================

$ProjectRoot = "C:\Users\thoma\OneDrive\SONEAR_2025\blancherenaudin-monorepo"

Write-Host "`n╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║          DIAGNOSTIC - Images Produits Supabase                 ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

Set-Location $ProjectRoot

Write-Host "📋 Ce script va créer un fichier de test pour interroger la base" -ForegroundColor Yellow
Write-Host "   et vérifier les données des images produits.`n" -ForegroundColor Yellow

# Créer un script Node.js temporaire pour tester
$TestScript = @"
// test-product-images.js
const { createClient } = require('@supabase/supabase-js')

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL
const supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY

if (!supabaseUrl || !supabaseKey) {
  console.error('❌ Variables d''environnement manquantes')
  console.error('   NEXT_PUBLIC_SUPABASE_URL:', supabaseUrl ? '✅' : '❌')
  console.error('   SUPABASE_SERVICE_ROLE_KEY:', supabaseKey ? '✅' : '❌')
  process.exit(1)
}

const supabase = createClient(supabaseUrl, supabaseKey)

async function checkProductImages() {
  console.log('🔍 Vérification des images produits...\n')
  
  // 1. Vérifier le produit
  const productId = '68123603-ade9-41a1-ad5c-31b619812157'
  console.log('📦 Produit ID:', productId)
  
  const { data: product, error: productError } = await supabase
    .from('products')
    .select('id, name, slug')
    .eq('id', productId)
    .single()
  
  if (productError) {
    console.error('❌ Erreur récupération produit:', productError)
    return
  }
  
  if (!product) {
    console.error('❌ Produit introuvable')
    return
  }
  
  console.log('✅ Produit trouvé:', product.name, '(', product.slug, ')\n')
  
  // 2. Vérifier les images du produit
  console.log('🖼️  Recherche des images...')
  
  const { data: images, error: imagesError } = await supabase
    .from('product_images')
    .select('id, product_id, file_path, display_order, created_at')
    .eq('product_id', productId)
    .order('display_order', { ascending: true })
  
  if (imagesError) {
    console.error('❌ Erreur récupération images:', imagesError)
    return
  }
  
  if (!images || images.length === 0) {
    console.error('❌ Aucune image trouvée pour ce produit')
    console.log('\n💡 Le produit existe mais n''a pas d''images associées.')
    console.log('   Vérifiez que les images ont bien été uploadées.')
    return
  }
  
  console.log(\`✅ \${images.length} image(s) trouvée(s):\n\`)
  
  images.forEach((img, index) => {
    console.log(\`   \${index + 1}. ID: \${img.id}\`)
    console.log(\`      File: \${img.file_path}\`)
    console.log(\`      Order: \${img.display_order}\`)
    console.log(\`      Created: \${new Date(img.created_at).toLocaleString()}\n\`)
  })
  
  // 3. Vérifier le storage
  console.log('📦 Vérification du bucket storage...')
  
  const { data: files, error: storageError } = await supabase
    .storage
    .from('product-images')
    .list(\`\${productId}\`, {
      limit: 100,
      offset: 0,
      sortBy: { column: 'name', order: 'asc' }
    })
  
  if (storageError) {
    console.error('❌ Erreur accès storage:', storageError)
    return
  }
  
  if (!files || files.length === 0) {
    console.error('❌ Aucun fichier trouvé dans le storage')
    console.log('\n💡 Les entrées DB existent mais les fichiers sont absents.')
    console.log('   Les images doivent être uploadées dans Supabase Storage.')
    return
  }
  
  console.log(\`✅ \${files.length} fichier(s) dans le storage:\n\`)
  
  files.forEach((file, index) => {
    console.log(\`   \${index + 1}. \${file.name}\`)
    console.log(\`      Size: \${(file.metadata?.size / 1024).toFixed(2)} KB\`)
    console.log(\`      Updated: \${new Date(file.updated_at).toLocaleString()}\n\`)
  })
  
  // 4. Test signed URL
  if (images.length > 0 && files.length > 0) {
    console.log('🔐 Test de génération de signed URL...')
    const testImage = images[0]
    const testPath = testImage.file_path
    
    const { data: signedUrl, error: urlError } = await supabase
      .storage
      .from('product-images')
      .createSignedUrl(testPath, 60)
    
    if (urlError) {
      console.error('❌ Erreur génération signed URL:', urlError)
      console.log('   Path testé:', testPath)
    } else if (signedUrl) {
      console.log('✅ Signed URL générée avec succès')
      console.log('   Path:', testPath)
      console.log('   URL:', signedUrl.signedUrl.substring(0, 80) + '...')
    }
  }
  
  console.log('\n' + '━'.repeat(70))
  console.log('✅ DIAGNOSTIC TERMINÉ')
  console.log('━'.repeat(70) + '\n')
}

checkProductImages().catch(console.error)
"@

Write-Host "📝 Création du script de test..." -ForegroundColor Cyan
Set-Content -Path "test-product-images.js" -Value $TestScript -Encoding UTF8

Write-Host "✅ Script créé: test-product-images.js`n" -ForegroundColor Green

Write-Host "🔄 Exécution du diagnostic..." -ForegroundColor Yellow
Write-Host "━".PadRight(70, '━') -ForegroundColor Gray

# Charger les variables d'environnement
$EnvPath = "apps\storefront\.env.local"
if (Test-Path $EnvPath) {
    Get-Content $EnvPath | ForEach-Object {
        if ($_ -match '^([^=]+)=(.*)$') {
            $name = $matches[1]
            $value = $matches[2]
            [Environment]::SetEnvironmentVariable($name, $value, "Process")
        }
    }
}

# Exécuter le script
node test-product-images.js

Write-Host "`n━".PadRight(70, '━') -ForegroundColor Gray
Write-Host "`n💡 Actions suggérées selon les résultats:" -ForegroundColor Yellow
Write-Host "   • Si 'Aucune image trouvée' → Les images n'ont pas été associées au produit" -ForegroundColor White
Write-Host "   • Si 'Aucun fichier dans storage' → Les images doivent être uploadées" -ForegroundColor White
Write-Host "   • Si tout OK mais erreur 404 → Problème dans la route API`n" -ForegroundColor White

# Nettoyer
Write-Host "🧹 Nettoyage..." -ForegroundColor Cyan
Remove-Item "test-product-images.js" -ErrorAction SilentlyContinue
Write-Host "✅ Terminé`n" -ForegroundColor Green
