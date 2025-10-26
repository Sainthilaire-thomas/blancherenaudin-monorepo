// src/app/api/products/by-ids/route.ts
import { NextResponse } from 'next/server'
import { createServerClient } from '@repo/database/client-server'

export async function GET(req: Request) {
  const supabase = await createServerClient()
  const { searchParams } = new URL(req.url)
  const idsParam = searchParams.get('ids')

  if (!idsParam) {
    return NextResponse.json(
      { error: 'IDs parameter required' },
      { status: 400 }
    )
  }

  const ids = idsParam.split(',').filter(Boolean)

  if (ids.length === 0) {
    return NextResponse.json({ products: [] })
  }

  try {
    const { data, error } = await supabase
      .from('products')
      .select(
        `
        *,
        images:product_images(*),
        category:categories(*)
      `
      )
      .in('id', ids)
      .eq('is_active', true)

    if (error) {
      return NextResponse.json({ error: error.message }, { status: 500 })
    }

    return NextResponse.json({ products: data ?? [] })
  } catch (error) {
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    )
  }
}
