// packages/auth/src/requireAdmin.ts
import { createServerClient } from '@supabase/ssr'
import { cookies } from 'next/headers'

import type { User } from '@supabase/supabase-js'
import type { Database } from './types' 

// ✅ Type simplifié sans spécifier le type exact de SupabaseClient
type RequireAdminResult =
  | { ok: false; status: 401 | 403 | 500; message: string }
  | { ok: true; user: User; supabase: ReturnType<typeof createServerClient<Database>> }

export async function requireAdmin(): Promise<RequireAdminResult> {
  const cookieStore = await cookies()

  const supabase = createServerClient<Database>(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        get(name: string) {
          return cookieStore.get(name)?.value
        },
        set() {},
        remove() {},
      },
    }
  )

  const {
    data: { user },
    error,
  } = await supabase.auth.getUser()
  
  if (error || !user)
    return { ok: false, status: 401, message: 'Unauthorized' }

  const { data: profile, error: pErr } = await supabase
    .from('profiles')
    .select('role')
    .eq('id', user.id)
    .single()

  if (pErr) return { ok: false, status: 500, message: pErr.message }
  
  if (!profile || (profile as { role: string | null }).role !== 'admin')
    return { ok: false, status: 403, message: 'Forbidden' }

  return { ok: true, user, supabase }
}
