﻿// src/lib/supabase-browser.ts
'use client'

import { createBrowserClient as createSupabaseClient } from '@supabase/ssr'
import type { Database } from '../types'

// Instance par dÃ©faut
export const supabaseBrowser = createSupabaseClient<Database>(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
)

// âœ… Export de la fonction pour crÃ©er de nouvelles instances
export function createBrowserClient() {
  console.log('ðŸ”‘ Creating Supabase client...')
  console.log('   URL:', process.env.NEXT_PUBLIC_SUPABASE_URL)
  console.log(
    '   Key (first 20 chars):',
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY?.substring(0, 20)
  )

  return createSupabaseClient<Database>(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
  )
}


