// packages/database/src/server.ts
/**
 * ⚠️ SERVER-ONLY exports
 * Ne jamais importer depuis un Client Component
 */

// ============================================================================
// IMPORT DU TYPE DATABASE
// ============================================================================
import type { Database } from './database.types'

// ============================================================================
// RE-EXPORTS DES CLIENTS
// ============================================================================
export { supabaseAdmin } from './client-admin'
export { getServerSupabase, createServerClient } from './client-server'
export { stripe } from './stripe'
export { decrementStockForOrder } from './stock/decrement-stock'

// ============================================================================
// TYPES DE BASE
// ============================================================================
export type { Database } from './database.types'

// ✅ Types utilitaires pour accéder aux tables et enums
export type Tables<T extends keyof Database['public']['Tables']> = Database['public']['Tables'][T]['Row']
export type Enums<T extends keyof Database['public']['Enums']> = Database['public']['Enums'][T]

// ============================================================================
// TYPE HELPERS
// ============================================================================
export type {
  OrderWithItems,
  OrderWithDetails,
  OrderWithFullItems,
  ProductWithImages,
  VariantWithProduct,
  CustomerWithAddresses,
  CustomerWithOrders,
  CollectionWithProducts,
  WishlistItemWithProduct,
  OrderStatusType,
  PaymentStatusType,
  FulfillmentStatusType,
  AddressJson,
  OrderWithTypedAddresses,
  OrderWithItemsInsert,
  ProductWithRelationsInsert,
  ApiSuccessResponse,
  ApiErrorResponse,
  ApiResponseUnion,
  NextApiHandler,
  PaginatedApiResponse,
  PaginatedData,
  PaginationMeta,
  CreateOrderRequest,
  UpdateProductStockRequest,
  CreateProductRequest,
  SearchProductsQuery,
  AddToWishlistRequest,
  DatabaseHelperTypes
} from './types-helpers'

// ============================================================================
// ENUMS & HELPERS
// ============================================================================
export {
  OrderStatusEnum,
  PaymentStatusEnum,
  FulfillmentStatusEnum,
  isOrderWithItems,
  isProductWithImages,
  isApiSuccess,
  isApiError,
  createApiSuccess,
  createApiError,
  createPaginatedResponse,
  getCategoryWithChildren
} from './types-helpers'