// apps/admin/app/api/admin/categories/route.ts
import { NextRequest, NextResponse } from 'next/server'
import { supabaseAdmin } from '@repo/database'

export async function GET() {
  try {
    const { data, error } = await supabaseAdmin
      .from('categories')
      .select('*')
      .order('sort_order', { ascending: true })
      .order('name', { ascending: true })

    if (error) throw error

    return NextResponse.json({ data })
  } catch (error: any) {
    return NextResponse.json(
      { error: error.message },
      { status: 500 }
    )
  }
}

export async function POST(request: NextRequest) {
  try {
    const body = await request.json()

    const { data, error } = await supabaseAdmin
      .from('categories')
      .insert({
        name: body.name,
        slug: body.slug,
        parent_id: body.parent_id || null,
        sort_order: body.sort_order || 0,
        is_active: body.is_active ?? true,
      })
      .select()
      .single()

    if (error) throw error

    return NextResponse.json({ data })
  } catch (error: any) {
    return NextResponse.json(
      { error: error.message },
      { status: 500 }
    )
  }
}
