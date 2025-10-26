// src/lib/analytics/track.ts
import { track } from '@vercel/analytics'

/**
 * Helper pour tracker les �v�nements e-commerce avec Vercel Analytics
 *
 * Usage:
 * import { trackEvent } from '@repo/analytics''
 *
 * trackEvent.viewProduct(product.id, product.name, product.price)
 */

export const trackEvent = {
  /**
   * Track quand un utilisateur voit un produit
   */
  viewProduct: (productId: string, productName: string, price: number) => {
    track('view_product', {
      product_id: productId,
      product_name: productName,
      price: price,
    })
  },

  /**
   * Track quand un utilisateur ajoute un produit au panier
   */
  addToCart: (
    productId: string,
    productName: string,
    price: number,
    quantity: number
  ) => {
    track('add_to_cart', {
      product_id: productId,
      product_name: productName,
      price: price,
      quantity: quantity,
      value: price * quantity,
    })
  },

  /**
   * Track quand un utilisateur retire un produit du panier
   */
  removeFromCart: (productId: string, productName: string) => {
    track('remove_from_cart', {
      product_id: productId,
      product_name: productName,
    })
  },

  /**
   * Track quand un utilisateur commence le checkout
   */
  beginCheckout: (cartValue: number, itemCount: number) => {
    track('begin_checkout', {
      value: cartValue,
      items: itemCount,
    })
  },

  /**
   * Track quand un achat est compl�t�
   * Note: Les d�tails des produits sont s�rialis�s en JSON string pour compatibilit� Vercel Analytics
   */
  purchase: (
    orderId: string,
    totalAmount: number,
    itemCount: number,
    products: Array<{
      id: string
      name: string
      price: number
      quantity: number
    }>
  ) => {
    track('purchase', {
      order_id: orderId,
      value: totalAmount,
      items: itemCount,
      // S�rialiser le tableau en JSON string pour �viter les erreurs de type
      products_json: JSON.stringify(products),
      // Ajouter aussi des infos agr�g�es directement accessibles
      product_ids: products.map((p) => p.id).join(','),
      product_names: products.map((p) => p.name).join(','),
    })
  },

  /**
   * Track quand un utilisateur ajoute un produit � sa wishlist
   */
  addToWishlist: (productId: string, productName: string) => {
    track('add_to_wishlist', {
      product_id: productId,
      product_name: productName,
    })
  },

  /**
   * Track les recherches
   */
  search: (query: string, resultsCount: number) => {
    track('search', {
      query: query,
      results: resultsCount,
    })
  },

  /**
   * Track quand un utilisateur visite une collection
   */
  viewCollection: (collectionSlug: string, collectionName: string) => {
    track('view_collection', {
      collection_slug: collectionSlug,
      collection_name: collectionName,
    })
  },

  /**
   * Track inscription newsletter
   */
  subscribeNewsletter: (email: string) => {
    track('subscribe_newsletter', {
      // Hash l'email pour la confidentialit� si n�cessaire
      email_domain: email.split('@')[1] || 'unknown',
    })
  },
}
