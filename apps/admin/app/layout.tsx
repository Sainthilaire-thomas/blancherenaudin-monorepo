// app/layout.tsx
import type { Metadata } from 'next'
import { Archivo_Narrow, Archivo_Black } from 'next/font/google'
import { AdminLayout } from '@/components/shell/AdminLayout'
import { ThemeProvider } from '@/components/providers/ThemeProvider'
import { tools } from '@/admin.config'
import Script from 'next/script'
import './globals.css'

const archivoNarrow = Archivo_Narrow({
  subsets: ['latin'],
  variable: '--font-archivo-narrow',
  weight: ['400', '500', '600', '700'],
})

const archivoBlack = Archivo_Black({
  subsets: ['latin'],
  variable: '--font-archivo-black',
  weight: '400',
})

export const metadata: Metadata = {
  title: 'Admin - Blanche Renaudin',
  description: 'Interface d\'administration',
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="fr" className={`${archivoNarrow.variable} ${archivoBlack.variable}`}>
      <body>
        <ThemeProvider>
          <AdminLayout modules={tools}>
            {children}
          </AdminLayout>
        </ThemeProvider>
        <Script
          id="vercel-analytics"
          strategy="afterInteractive"
          src="https://va.vercel-scripts.com/v1/script.debug.js"
          data-mode="auto"
        />
      </body>
    </html>
  )
}
