// packages/newsletter/src/render.ts
import { render } from '@react-email/render'
import { NewsletterCampaignEmail } from '@repo/email' // ✅ Corrigé
import { generateNewsletterLink, generateUnsubscribeLink } from './utils'
import { createClient } from '@supabase/supabase-js' // ✅ Corrigé

// ✅ Créer l'instance supabaseAdmin localement
const supabaseAdmin = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY!,
  {
    auth: { autoRefreshToken: false, persistSession: false },
  }
)

interface Campaign {
  id: string
  utm_campaign: string
  subject: string
  content: {
    hero_image_url?: string
    title: string
    subtitle?: string
    cta_text: string
    cta_link: string
    products: Array<{
      id: string
      position: number
    }>
  }
}

interface Subscriber {
  id: string
  email: string
  first_name?: string
  last_name?: string
}

// ✅ Type pour les produits
interface ProductImage {
  image_url: string
  is_primary: boolean | null
  sort_order: number | null
}

interface Product {
  id: string
  name: string
  price: number
  slug: string
  product_images?: ProductImage[]
}

/**
 * Génère le HTML complet d'un email de campagne newsletter
 */
export async function renderNewsletterCampaignEmail(
  campaign: Campaign,
  subscriber: Subscriber
): Promise<string> {
  try {
    console.log(
      `📧 Rendering email for campaign ${campaign.id} to ${subscriber.email}`
    )

    // 1. Récupérer les détails des produits
    const productIds = campaign.content.products.map((p: { id: string; position: number }) => p.id)

    const { data: productsData, error: productsError } = await supabaseAdmin
      .from('products')
      .select(
        `
        id,
        name,
        price,
        slug,
        product_images!product_images_product_id_fkey(image_url:storage_original, is_primary, sort_order)
      `
      )
      .in('id', productIds)

    if (productsError) {
      console.error('❌ Error fetching products:', productsError)
      throw productsError
    }

    if (!productsData || productsData.length === 0) {
      throw new Error('No products found for campaign')
    }

    console.log(`✅ Found ${productsData.length} products`)

    // 2. Typer et mapper les produits
    const typedProductsData = productsData as Product[]
    const productsMap = new Map(typedProductsData.map((p) => [p.id, p]))

    const enrichedProducts = await Promise.all(
      campaign.content.products.map(async (campaignProduct) => {
        const product = productsMap.get(campaignProduct.id)
        if (!product) {
          console.warn(`⚠️ Product ${campaignProduct.id} not found`)
          return null
        }

        // Récupérer l'image principale
        const primaryImage = product.product_images?.find(
          (img) => img.is_primary
        )
        const imageUrl =
          primaryImage?.image_url || product.product_images?.[0]?.image_url

        if (!imageUrl) {
          console.warn(`⚠️ No image found for product ${product.id}`)
          return null
        }

        // Générer signed URL
        const { data: signedData } = await supabaseAdmin.storage
          .from('product-images')
          .createSignedUrl(imageUrl, 60 * 60 * 24 * 7)

        const imagePublicUrl = signedData?.signedUrl || ''

        // Générer lien produit avec UTM
        const productLink = generateNewsletterLink(
          `/product/${product.id}`,
          campaign.utm_campaign,
          subscriber.id,
          `product-grid-item-${campaignProduct.position}`
        )

        return {
          id: product.id,
          name: product.name,
          price: product.price,
          image_url: imagePublicUrl,
          link: productLink,
        }
      })
    )

    // Filtrer les null
    const validProducts = enrichedProducts.filter((p): p is NonNullable<typeof p> => p !== null)

    if (validProducts.length === 0) {
      throw new Error('No valid products after enrichment')
    }

    console.log(
      `✅ Enriched ${validProducts.length} products with images and UTM links`
    )

    // 3. Générer le lien CTA avec UTM
    const ctaLink = generateNewsletterLink(
      campaign.content.cta_link,
      campaign.utm_campaign,
      subscriber.id,
      'hero-cta'
    )

    // 4. Générer le lien de désabonnement
    const unsubscribeLink = generateUnsubscribeLink(subscriber.id)

    // 5. Rendre le template React en HTML
    const html = await render(
      NewsletterCampaignEmail({
        campaign: {
          subject: campaign.subject,
          content: {
            ...campaign.content,
            cta_link: ctaLink,
            products: validProducts,
          },
        },
        subscriber: {
          email: subscriber.email,
          first_name: subscriber.first_name,
        },
        unsubscribeLink,
      })
    )

    console.log('✅ Email HTML rendered successfully')

    return html
  } catch (error) {
    console.error('❌ Error rendering newsletter email:', error)
    throw error
  }
}

/**
 * Génère une version preview
 */
export async function renderNewsletterPreview(
  campaign: Campaign,
  testEmail: string = 'preview@example.com'
): Promise<string> {
  const mockSubscriber: Subscriber = {
    id: 'preview-subscriber-id',
    email: testEmail,
    first_name: 'Prénom',
    last_name: 'Nom',
  }

  return renderNewsletterCampaignEmail(campaign, mockSubscriber)
}
