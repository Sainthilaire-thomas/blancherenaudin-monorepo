// packages/database/src/index.ts

// ============================================================================
// EXPORTS DE BASE (depuis types.ts)
// ============================================================================
export * from "./types"

// ============================================================================
// EXPORTS TYPES HELPERS (avec résolution du conflit ApiResponse)
// ============================================================================
// ✅ Export des TYPES uniquement avec "export type"
export type {
  // Types avec relations
  OrderWithItems,
  OrderWithDetails,
  OrderWithFullItems,
  ProductWithImages,
  VariantWithProduct,
  CustomerWithAddresses,
  CustomerWithOrders,
  CollectionWithProducts,
  WishlistItemWithProduct,
  
  // Inserts avec relations
  OrderWithItemsInsert,
  ProductWithRelationsInsert,
  
  // Utilities
  AddressJson,
  OrderWithTypedAddresses,
  SupabaseQuery,
  
  // Enums types
  OrderStatusType,
  PaymentStatusType,
  FulfillmentStatusType,
  
  // ✅ Types API (avec des noms différents pour éviter les conflits)
  ApiSuccessResponse,
  ApiErrorResponse,
  ApiResponseUnion,  // Au lieu de ApiResponse qui existe déjà dans types.ts
  NextApiHandler,
  PaginatedApiResponse,
  PaginatedData,
  PaginationMeta,
  
  // Request types
  CreateOrderRequest,
  UpdateProductStockRequest,
  CreateProductRequest,
  SearchProductsQuery,
  AddToWishlistRequest,
  
  // Type export
  DatabaseHelperTypes
} from "./types-helpers"

// ✅ Export des VALEURS (enums, functions) avec "export"
export {
  // Enums (ce sont des objets, pas des types)
  OrderStatusEnum,
  PaymentStatusEnum,
  FulfillmentStatusEnum,
  
  // Type guards (ce sont des fonctions)
  isOrderWithItems,
  isProductWithImages,
  isApiSuccess,
  isApiError,
  
  // Helpers (ce sont des fonctions)
  createApiSuccess,
  createApiError,
  createPaginatedResponse,
} from "./types-helpers"

// ============================================================================
// EXPORTS CLIENTS SUPABASE
// ============================================================================
export { createBrowserClient } from "./client-browser"
export { getServerSupabase, createServerClient } from "./client-server"
export { supabaseAdmin } from "./client-admin"
export { supabaseAdmin as createAdminClient } from "./client-admin"

// ============================================================================
// EXPORTS STOCK MANAGEMENT
// ============================================================================
export * from './stock/decrement-stock'

// ============================================================================
// EXPORTS STRIPE
// ============================================================================
export * from './stripe'

// ============================================================================
// RE-EXPORT EXPLICITE POUR COMPATIBILITÉ
// ============================================================================
// Si le code existant utilise ApiResponse, on peut garder les deux noms
export type { ApiResponseUnion as ApiResponseHelper } from './types-helpers'
export { getCategoryWithChildren } from './types-helpers'
