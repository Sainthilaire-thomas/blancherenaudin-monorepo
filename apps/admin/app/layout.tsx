// app/layout.tsx
import type { Metadata } from 'next'
import { Archivo_Narrow, Archivo_Black } from 'next/font/google'
import './globals.css'

const archivoNarrow = Archivo_Narrow({
  subsets: ['latin'],
  variable: '--font-archivo-narrow',
})

const archivoBlack = Archivo_Black({
  weight: '400',
  subsets: ['latin'],
  variable: '--font-archivo-black',
})

export const metadata: Metadata = {
  title: 'Blanche Renaudin - Admin',
  description: 'Administration Blanche Renaudin',
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="fr" suppressHydrationWarning>
      <body
        className={`${archivoNarrow.variable} ${archivoBlack.variable} font-sans antialiased`}
      >
        {children}
      </body>
    </html>
  )
}
