// packages/database/src/client-server.ts
import { createServerClient as createSupabaseServerClient } from '@supabase/ssr'
import type { Database } from './types'

// ✅ Import dynamique pour éviter l'erreur dans les Client Components
async function getCookies() {
  const { cookies } = await import('next/headers')
  return cookies()
}

export async function createServerClient() {
  const cookieStore = await getCookies()

  return createSupabaseServerClient<Database>(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll() {
          return cookieStore.getAll()
        },
        setAll(cookiesToSet) {
          try {
            cookiesToSet.forEach(({ name, value, options }) =>
              cookieStore.set(name, value, options)
            )
          } catch {
            // Ignore si appelé depuis un Server Component
          }
        },
      },
    }
  )
}

// Backward compatibility
export const getServerSupabase = createServerClient
