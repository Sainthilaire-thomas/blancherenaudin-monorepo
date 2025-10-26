// packages/database/src/index.ts

// Export types de base (depuis database.types.ts via types.ts)
export * from "./types"

// Export types helpers (relations Supabase - NOUVEAU)
export * from "./types-helpers"

// Export clients Supabase
export { createBrowserClient } from "./client-browser"
export { getServerSupabase, createServerClient } from "./client-server"
export { supabaseAdmin } from "./client-admin"

// Re-export sous un alias plus cohérent
export { supabaseAdmin as createAdminClient } from "./client-admin"

// Export stock management (si activé)
// export * from './stock/decrement-stock'

// Export Stripe
export * from './stripe'
