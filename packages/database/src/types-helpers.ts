// packages/database/src/types-helpers.ts
import { Database } from './database.types'

// ============================================================================
// TYPES DE BASE DEPUIS SUPABASE (pour usage interne uniquement)
// ============================================================================
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

export type OrderWithItems = Order & {
  order_items: OrderItem[]
}

export type OrderWithFullItems = Order & {
  order_items: (OrderItem & {
    products?: Product | null
    product_variants?: ProductVariant | null
  })[]
}

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

export type ProductWithImages = Product & {
  product_images: ProductImage[]
}

export type VariantWithProduct = ProductVariant & {
  products?: Product | null
}

export type CustomerWithAddresses = Customer & {
  addresses: Address[]
}

export type CustomerWithOrders = Customer & {
  orders: Order[]
}

export type CollectionWithProducts = Collection & {
  collection_products: Array<{
    product_id: string
    products?: Product | null
  }>
}

export type WishlistItemWithProduct = WishlistItem & {
  products?: ProductWithImages | null
}

// ============================================================================
// TYPES POUR LES INSERTS/UPDATES AVEC RELATIONS
// ============================================================================

export type OrderWithItemsInsert = OrderInsert & {
  order_items: OrderItemInsert[]
}

export type ProductWithRelationsInsert = ProductInsert & {
  product_variants?: ProductVariantInsert[]
  product_images?: ProductImageInsert[]
}

// ============================================================================
// TYPES UTILITAIRES POUR LES QUERIES SUPABASE
// ============================================================================

export type SupabaseQuery<T> = Promise<{
  data: T | null
  error: Error | null
}>

// ============================================================================
// TYPES POUR LES ADDRESSES (JSONB)
// ============================================================================

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

export type OrderWithTypedAddresses = Omit<Order, 'shipping_address' | 'billing_address'> & {
  shipping_address: AddressJson | null
  billing_address: AddressJson | null
}

// ============================================================================
// ENUMS & CONSTANTS
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
// TYPES POUR LES API RESPONSES
// ============================================================================
// ⚠️ On utilise des noms différents pour éviter le conflit avec types.ts

export type ApiSuccessResponse<T = unknown> = {
  success: true
  data: T
  message?: string
}

export type ApiErrorResponse = {
  success: false
  error: string
  message?: string
  details?: unknown
}

export type ApiResponseUnion<T = unknown> = ApiSuccessResponse<T> | ApiErrorResponse

export type NextApiHandler<T = unknown> = (
  request: Request
) => Promise<Response> | Response

// ============================================================================
// TYPES POUR LES RÉPONSES PAGINÉES
// ============================================================================

export interface PaginationMeta {
  page: number
  limit: number
  total: number
  totalPages: number
}

export interface PaginatedData<T> {
  items: T[]
  pagination: PaginationMeta
}

export type PaginatedApiResponse<T> = ApiSuccessResponse<PaginatedData<T>>

// ============================================================================
// TYPES POUR LES API REQUESTS
// ============================================================================

export interface CreateOrderRequest {
  items: Array<{
    product_id: string
    variant_id?: string | null
    quantity: number
    unit_price: number
  }>
  shipping_address: AddressJson
  billing_address: AddressJson
  customer_email: string
  customer_name: string
  customer_phone?: string
  shipping_method: string
  shipping_amount: number
  tax_amount: number
  discount_amount?: number
  promo_code?: string
  total_amount: number
  stripe_session_id?: string
}

export interface UpdateProductStockRequest {
  variant_id: string
  delta: number
  reason: string
}

export interface CreateProductRequest extends Omit<Product, 'id' | 'created_at' | 'updated_at'> {
  variants?: Array<Omit<ProductVariant, 'id' | 'product_id' | 'created_at'>>
  images?: Array<{
    storage_original: string
    alt?: string
    is_primary?: boolean
    sort_order?: number
  }>
}

export interface SearchProductsQuery {
  query?: string
  category?: string
  min_price?: number
  max_price?: number
  in_stock?: boolean
  page?: number
  limit?: number
}

export interface AddToWishlistRequest {
  product_id: string
  user_id: string
}

// ============================================================================
// TYPE GUARDS
// ============================================================================

export function isOrderWithItems(order: any): order is OrderWithItems {
  return (
    order &&
    typeof order === 'object' &&
    'id' in order &&
    'order_items' in order &&
    Array.isArray(order.order_items)
  )
}

// ✅ FIX : Corrigé 'order' → 'product'
export function isProductWithImages(product: any): product is ProductWithImages {
  return (
    product &&
    typeof product === 'object' &&
    'id' in product &&
    'product_images' in product &&
    Array.isArray(product.product_images)
  )
}

export function isApiSuccess<T>(response: ApiResponseUnion<T>): response is ApiSuccessResponse<T> {
  return response.success === true
}

export function isApiError<T>(response: ApiResponseUnion<T>): response is ApiErrorResponse {
  return response.success === false
}

// ============================================================================
// EXPORTS POUR FACILITER L'UTILISATION
// ============================================================================

// ✅ FIX : Types génériques correctement définis
export type DatabaseHelperTypes = {
  OrderWithItems: OrderWithItems
  OrderWithDetails: OrderWithDetails
  OrderWithFullItems: OrderWithFullItems
  ProductWithImages: ProductWithImages
  CustomerWithAddresses: CustomerWithAddresses
  CustomerWithOrders: CustomerWithOrders
  CollectionWithProducts: CollectionWithProducts
  WishlistItemWithProduct: WishlistItemWithProduct
  VariantWithProduct: VariantWithProduct
  OrderWithItemsInsert: OrderWithItemsInsert
  ProductWithRelationsInsert: ProductWithRelationsInsert
  AddressJson: AddressJson
  OrderWithTypedAddresses: OrderWithTypedAddresses
  OrderStatusType: OrderStatusType
  PaymentStatusType: PaymentStatusType
  FulfillmentStatusType: FulfillmentStatusType
  ApiSuccessResponse: <T>() => ApiSuccessResponse<T>
  ApiErrorResponse: ApiErrorResponse
  ApiResponseUnion: <T>() => ApiResponseUnion<T>
  NextApiHandler: <T>() => NextApiHandler<T>
  PaginatedApiResponse: <T>() => PaginatedApiResponse<T>
  PaginatedData: <T>() => PaginatedData<T>
  PaginationMeta: PaginationMeta
  CreateOrderRequest: CreateOrderRequest
  UpdateProductStockRequest: UpdateProductStockRequest
  CreateProductRequest: CreateProductRequest
  SearchProductsQuery: SearchProductsQuery
  AddToWishlistRequest: AddToWishlistRequest
}

// ============================================================================
// HELPERS POUR CRÉER DES RÉPONSES API TYPÉES
// ============================================================================

export function createApiSuccess<T>(data: T, message?: string): ApiSuccessResponse<T> {
  // ✅ FIX : Éviter le spread sur undefined
  const response: ApiSuccessResponse<T> = {
    success: true,
    data
  }
  if (message) {
    response.message = message
  }
  return response
}

export function createApiError(error: string, message?: string, details?: unknown): ApiErrorResponse {
  // ✅ FIX : Éviter le spread sur undefined
  const response: ApiErrorResponse = {
    success: false,
    error
  }
  if (message) {
    response.message = message
  }
  if (details !== undefined) {
    response.details = details
  }
  return response
}

export function createPaginatedResponse<T>(
  items: T[],
  page: number,
  limit: number,
  total: number
): PaginatedApiResponse<T> {
  return {
    success: true,
    data: {
      items,
      pagination: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit)
      }
    }
  }
}
