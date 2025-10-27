// packages/database/src/client-admin.ts
import { createClient } from '@supabase/supabase-js'
import type { Database } from './types'

// ✅ Vérification runtime côté client
if (typeof window !== 'undefined') {
  throw new Error(
    '🚨 SECURITY ERROR: supabaseAdmin cannot be used in Client Components!\n' +
    'Use createBrowserClient() or createServerClient() instead.'
  )
}

const URL = process.env.NEXT_PUBLIC_SUPABASE_URL
const SERVICE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY

if (!URL || !SERVICE_KEY) {
  throw new Error(
    'Missing Supabase environment variables:\n' +
    `- NEXT_PUBLIC_SUPABASE_URL: ${URL ? '✅' : '❌'}\n` +
    `- SUPABASE_SERVICE_ROLE_KEY: ${SERVICE_KEY ? '✅' : '❌'}`
  )
}

/**
 * ⚠️ Admin client with SERVICE_ROLE privileges
 * SERVER-ONLY - Never use in Client Components
 */
export const supabaseAdmin = createClient<Database>(URL, SERVICE_KEY, {
  auth: {
    autoRefreshToken: false,
    persistSession: false,
  },
  global: {
    headers: { 'X-Client-Info': 'admin-server' },
  },
})
