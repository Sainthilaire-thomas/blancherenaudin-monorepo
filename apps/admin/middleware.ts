// middleware.ts
import { NextResponse } from 'next/server'
import type { NextRequest } from 'next/server'

export function middleware(request: NextRequest) {
  // TODO: Vérifier l'authentification admin ici
  // Pour l'instant, on laisse passer
  
  const { pathname } = request.nextUrl

  // Protéger les routes /admin sauf /admin/login
  if (pathname.startsWith('/admin') && !pathname.startsWith('/admin/login')) {
    // TODO: Vérifier le token admin
    // const token = request.cookies.get('admin-token')
    // if (!token) {
    //   return NextResponse.redirect(new URL('/admin/login', request.url))
    // }
  }

  return NextResponse.next()
}

export const config = {
  matcher: [
    /*
     * Match all request paths except for the ones starting with:
     * - api (API routes)
     * - _next/static (static files)
     * - _next/image (image optimization files)
     * - favicon.ico (favicon file)
     */
    '/((?!api|_next/static|_next/image|favicon.ico).*)',
  ],
}
