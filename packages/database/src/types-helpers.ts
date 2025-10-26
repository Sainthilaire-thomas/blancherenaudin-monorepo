// packages/database/src/types-helpers.ts
import { Database } from './database.types'

// ============================================================================
// TYPES DE BASE DEPUIS SUPABASE (pour usage interne uniquement)
// ============================================================================
// Note: Ces types sont déjà exportés depuis types.ts, on les importe ici
// pour les utiliser dans les types helpers, mais on ne les ré-export pas

type Tables = Database['public']['Tables']

type Order = Tables['orders']['Row']
type OrderInsert = Tables['orders']['Insert']
type OrderUpdate = Tables['orders']['Update']

type OrderItem = Tables['order_items']['Row']
type OrderItemInsert = Tables['order_items']['Insert']

type Product = Tables['products']['Row']
type ProductInsert = Tables['products']['Insert']

type ProductVariant = Tables['product_variants']['Row']
type ProductVariantInsert = Tables['product_variants']['Insert']

type ProductImage = Tables['product_images']['Row']
type ProductImageInsert = Tables['product_images']['Insert']

type Customer = Tables['profiles']['Row']
type Address = Tables['addresses']['Row']
type Category = Tables['categories']['Row']
type Collection = Tables['collections']['Row']
type WishlistItem = Tables['wishlist_items']['Row']

// ============================================================================
// TYPES AVEC RELATIONS (résout les erreurs "never" de TypeScript)
// ============================================================================

/**
 * Order avec ses items relationnels
 * 🎯 Utilisé dans : /account/orders, /admin/orders
 * ✅ Résout : Property 'order_items' does not exist on type 'never'
 */
export type OrderWithItems = Order & {
  order_items: OrderItem[]
}

/**
 * Order avec items ET détails produits complets
 * 🎯 Utilisé pour l'affichage détaillé des commandes
 */
export type OrderWithFullItems = Order & {
  order_items: (OrderItem & {
    products?: Product | null
    product_variants?: ProductVariant | null
  })[]
}

/**
 * Order avec toutes les informations nécessaires pour l'affichage client
 * 🎯 Utilisé dans : /account/orders/page.tsx
 * ✅ Résout TOUTES les 18 erreurs TypeScript du fichier
 */
export type OrderWithDetails = Order & {
  order_items: Array<{
    id: string
    quantity: number
    product_name: string | null
    unit_price: number
    total_price: number
    image_url?: string | null
  }>
}

// ⚠️ ProductWithRelations est déjà exporté depuis types.ts - pas de doublon !
// ⚠️ ProductWithPrimaryImage est déjà exporté depuis types.ts - pas de doublon !

/**
 * Product avec seulement ses images (cas courant)
 * 🎯 Utilisé dans les cartes produits, galeries
 */
export type ProductWithImages = Product & {
  product_images: ProductImage[]
}

/**
 * Variant avec le produit parent
 * 🎯 Utilisé dans la gestion du stock
 */
export type VariantWithProduct = ProductVariant & {
  products?: Product | null
}

/**
 * Customer/Profile avec ses adresses
 * 🎯 Utilisé dans : /admin/customers/[id]
 */
export type CustomerWithAddresses = Customer & {
  addresses: Address[]
}

/**
 * Customer avec commandes
 * 🎯 Utilisé pour les stats clients
 */
export type CustomerWithOrders = Customer & {
  orders: Order[]
}

/**
 * Collection avec produits
 * 🎯 Utilisé pour l'affichage des collections
 */
export type CollectionWithProducts = Collection & {
  collection_products: Array<{
    product_id: string
    products?: Product | null
  }>
}

/**
 * Wishlist item avec détails produit
 * 🎯 Utilisé dans /account/wishlist
 */
export type WishlistItemWithProduct = WishlistItem & {
  products?: ProductWithImages | null
}

// ============================================================================
// TYPES POUR LES INSERTS/UPDATES AVEC RELATIONS
// ============================================================================

/**
 * Insert d'une commande avec items
 * 🎯 Utilisé lors de la création de commande
 */
export type OrderWithItemsInsert = OrderInsert & {
  order_items: OrderItemInsert[]
}

/**
 * Insert d'un produit avec variantes et images
 * 🎯 Utilisé dans /admin/products/new
 */
export type ProductWithRelationsInsert = ProductInsert & {
  product_variants?: ProductVariantInsert[]
  product_images?: ProductImageInsert[]
}

// ============================================================================
// TYPES UTILITAIRES POUR LES QUERIES SUPABASE
// ============================================================================

/**
 * Type helper pour les requêtes Supabase avec select complexe
 * Permet de typer correctement les jointures
 * 
 * Exemple d'utilisation :
 * ```typescript
 * const { data } = await supabase
 *   .from('orders')
 *   .select('*, order_items(*)')
 *   .returns<OrderWithItems[]>()
 * ```
 */
export type SupabaseQuery<T> = Promise<{
  data: T | null
  error: Error | null
}>

// ⚠️ PaginatedResponse est déjà exporté depuis types.ts - pas de doublon !

// ============================================================================
// TYPES POUR LES ADDRESSES (JSONB)
// ============================================================================

/**
 * Structure des addresses dans les commandes (stockées en JSONB)
 * 🎯 Résout les problèmes avec shipping_address et billing_address
 */
export type AddressJson = {
  first_name: string
  last_name: string
  company?: string
  address_line1: string
  address_line2?: string
  city: string
  postal_code: string
  country: string
  phone?: string
  email?: string
}

/**
 * Order avec addresses typées correctement
 * 🎯 Utilisé pour éviter les erreurs avec Json type
 */
export type OrderWithTypedAddresses = Omit<Order, 'shipping_address' | 'billing_address'> & {
  shipping_address: AddressJson | null
  billing_address: AddressJson | null
}

// ============================================================================
// ENUMS & CONSTANTS (nouveaux, pas de doublon avec types.ts)
// ============================================================================

export const OrderStatusEnum = {
  PENDING: 'pending',
  PAID: 'paid',
  PROCESSING: 'processing',
  SHIPPED: 'shipped',
  DELIVERED: 'delivered',
  CANCELLED: 'cancelled',
  REFUNDED: 'refunded',
} as const

export type OrderStatusType = typeof OrderStatusEnum[keyof typeof OrderStatusEnum]

export const PaymentStatusEnum = {
  PENDING: 'pending',
  PAID: 'paid',
  FAILED: 'failed',
  REFUNDED: 'refunded',
} as const

export type PaymentStatusType = typeof PaymentStatusEnum[keyof typeof PaymentStatusEnum]

export const FulfillmentStatusEnum = {
  PENDING: 'pending',
  PROCESSING: 'processing',
  SHIPPED: 'shipped',
  DELIVERED: 'delivered',
} as const

export type FulfillmentStatusType = typeof FulfillmentStatusEnum[keyof typeof FulfillmentStatusEnum]

// ============================================================================
// TYPE GUARDS (pour vérifier les types à runtime)
// ============================================================================

/**
 * Vérifie si un objet est une commande avec items
 */
export function isOrderWithItems(order: any): order is OrderWithItems {
  return (
    order &&
    typeof order === 'object' &&
    'id' in order &&
    'order_items' in order &&
    Array.isArray(order.order_items)
  )
}

/**
 * Vérifie si un objet est un produit avec images
 */
export function isProductWithImages(product: any): product is ProductWithImages {
  return (
    product &&
    typeof product === 'object' &&
    'id' in product &&
    'product_images' in product &&
    Array.isArray(product.product_images)
  )
}

// ============================================================================
// EXPORTS POUR FACILITER L'UTILISATION
// ============================================================================

// Export tout en tant que namespace pour éviter les conflits
// Note: Les types de base (Order, Product, etc.) sont déjà exportés depuis types.ts
export type DatabaseHelperTypes = {
  // Relations (nouveaux types uniquement - pas de doublons)
  OrderWithItems: OrderWithItems
  OrderWithDetails: OrderWithDetails
  OrderWithFullItems: OrderWithFullItems
  ProductWithImages: ProductWithImages
  CustomerWithAddresses: CustomerWithAddresses
  CustomerWithOrders: CustomerWithOrders
  CollectionWithProducts: CollectionWithProducts
  WishlistItemWithProduct: WishlistItemWithProduct
  VariantWithProduct: VariantWithProduct
  
  // Inserts avec relations
  OrderWithItemsInsert: OrderWithItemsInsert
  ProductWithRelationsInsert: ProductWithRelationsInsert
  
  // Utilities
  AddressJson: AddressJson
  OrderWithTypedAddresses: OrderWithTypedAddresses
  
  // Enums
  OrderStatusType: OrderStatusType
  PaymentStatusType: PaymentStatusType
  FulfillmentStatusType: FulfillmentStatusType
}
