# ============================================================================
# CRÉATION ROUTE API - Signed URLs pour images produits
# ============================================================================

$ProjectRoot = "C:\Users\thoma\OneDrive\SONEAR_2025\blancherenaudin-monorepo"

Write-Host "`n╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║      CRÉATION ROUTE API - /api/admin/product-images           ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

Set-Location $ProjectRoot

# Créer la structure de dossiers
$ApiPath = "apps\storefront\app\api\admin\product-images\[imageId]\signed-url"

Write-Host "📁 Création de la structure de dossiers..." -ForegroundColor Cyan
New-Item -ItemType Directory -Path $ApiPath -Force | Out-Null
Write-Host "  ✅ Dossier créé: $ApiPath" -ForegroundColor Green

# Créer le fichier route.ts
$RouteFile = Join-Path $ApiPath "route.ts"

$RouteContent = @"
// apps/storefront/app/api/admin/product-images/[imageId]/signed-url/route.ts
import { NextRequest, NextResponse } from 'next/server'
import { supabaseAdmin } from '@repo/database/server'

export const runtime = 'nodejs'

export async function GET(
  request: NextRequest,
  { params }: { params: { imageId: string } }
) {
  try {
    const { imageId } = params
    const { searchParams } = new URL(request.url)
    
    const variant = searchParams.get('variant') || 'md'
    const format = searchParams.get('format') || 'webp'
    const mode = searchParams.get('mode') // 'json' or undefined

    // Récupérer l'image depuis la base
    const { data: image, error: imageError } = await supabaseAdmin
      .from('product_images')
      .select('product_id, file_path')
      .eq('id', imageId)
      .single()

    if (imageError || !image) {
      console.error('Image not found:', imageId, imageError)
      return NextResponse.json(
        { error: 'Image not found' },
        { status: 404 }
      )
    }

    // Construire le chemin avec variant et format
    const basePath = image.file_path.replace(/\.[^/.]+`$`, '') // Remove extension
    const imagePath = ``${basePath}-${variant}.${format}``

    // Générer une signed URL (valide 1 heure)
    const { data: signedUrlData, error: urlError } = await supabaseAdmin
      .storage
      .from('product-images')
      .createSignedUrl(imagePath, 3600)

    if (urlError || !signedUrlData) {
      console.error('Error creating signed URL:', urlError)
      
      // Fallback: essayer sans le variant si le fichier n'existe pas
      const fallbackPath = image.file_path
      const { data: fallbackData } = await supabaseAdmin
        .storage
        .from('product-images')
        .createSignedUrl(fallbackPath, 3600)

      if (fallbackData?.signedUrl) {
        if (mode === 'json') {
          return NextResponse.json({ signedUrl: fallbackData.signedUrl })
        }
        return NextResponse.redirect(fallbackData.signedUrl)
      }

      return NextResponse.json(
        { error: 'Failed to create signed URL' },
        { status: 500 }
      )
    }

    // Retourner selon le mode demandé (IMPORTANT: la clé doit être 'signedUrl')
    if (mode === 'json') {
      return NextResponse.json({ signedUrl: signedUrlData.signedUrl })
    }

    // Par défaut, rediriger vers l'URL signée
    return NextResponse.redirect(signedUrlData.signedUrl)

  } catch (error) {
    console.error('Unexpected error in signed-url route:', error)
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    )
  }
}
"@

Write-Host "`n📝 Création du fichier route.ts..." -ForegroundColor Cyan
$RouteContent | Out-File -FilePath $RouteFile -Encoding UTF8
Write-Host "  ✅ Fichier créé: $RouteFile" -ForegroundColor Green

Write-Host "`n✅ SUCCÈS: Route API créée!" -ForegroundColor Green
Write-Host "   📍 Chemin: $ApiPath\route.ts" -ForegroundColor Green

Write-Host "`n🔄 Prochaines étapes:" -ForegroundColor Yellow
Write-Host "   1. Redémarrer le dev serveur:" -ForegroundColor White
Write-Host "      cd apps\storefront" -ForegroundColor Cyan
Write-Host "      # Arrêter avec Ctrl+C puis:" -ForegroundColor Gray
Write-Host "      Remove-Item -Recurse -Force .next" -ForegroundColor Cyan
Write-Host "      pnpm dev" -ForegroundColor Cyan
Write-Host "`n   2. Tester l'URL du produit:" -ForegroundColor White
Write-Host "      http://localhost:3000/product/68123603-ade9-41a1-ad5c-31b619812157`n" -ForegroundColor Cyan
