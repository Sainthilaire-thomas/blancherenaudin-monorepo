// packages/database/src/index.ts

// === CLIENT EXPORTS ===
export { createBrowserClient, supabaseBrowser } from './clients/client-browser'
export { createServerClient, getServerSupabase } from './clients/client-server'
export { createAdminClient, supabaseAdmin } from './clients/client-admin'

// === TYPES ===
export * from './types'
export type { Database } from './types/database.types'

// === UTILS ===
export * from './utils/types-helpers'

// === STOCK MANAGEMENT ===
export { decrementStockForOrder } from './stock/decrement-stock'
export type { StockDecrementResult } from './stock/decrement-stock'

export * from './validations'
