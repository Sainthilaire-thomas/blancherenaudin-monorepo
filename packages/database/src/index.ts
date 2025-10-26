// Export types
export * from "./types"
// Export clients
export { createBrowserClient } from "./client-browser"
export { getServerSupabase, createServerClient } from "./client-server"
export { supabaseAdmin } from "./client-admin"
// Re-export sous un alias plus cohérent
export { supabaseAdmin as createAdminClient } from "./client-admin"
// Export stock management
// export * from './stock/decrement-stock'

// Export Stripe
export * from './stripe'

