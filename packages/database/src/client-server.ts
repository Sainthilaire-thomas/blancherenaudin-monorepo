// src/lib/supabase-server.ts
import {
  createServerClient as createSupabaseServerClient,
  type CookieOptions,
} from '@supabase/ssr'
import type { Database } from './types'
import { cookies } from "next/headers";

// âœ… Fonction principale (votre code existant)
export async function getServerSupabase() {
  const cookieStore = await cookies();

  return createSupabaseServerClient<Database>(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        // âœ… nouvelle API attendue par @supabase/ssr
        getAll() {
          return cookieStore.getAll()
        },
        setAll(cookiesToSet) {
          try {
            cookiesToSet.forEach(({ name, value, options }) => {
              cookieStore.set({
                name,
                value,
                ...(options as CookieOptions | undefined),
              })
            })
          } catch {
            // AppelÃ© depuis un Server Component pur -> on ne peut pas Ã©crire des cookies ici, c'est OK.
          }
        },
      },
    }
  )
}

// âœ… Alias pour l'API analytics (mÃªme fonction, nom diffÃ©rent)
export const createServerClient = getServerSupabase;

