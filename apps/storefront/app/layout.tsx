import type { Metadata } from 'next'
import { Archivo_Black, Archivo_Narrow } from 'next/font/google'
import './globals.css'

const archivoBlack = Archivo_Black({
  weight: '400',
  subsets: ['latin'],
  variable: '--font-archivo-black',
  display: 'swap',
})

const archivoNarrow = Archivo_Narrow({
  weight: ['400', '500', '600', '700'],
  subsets: ['latin'],
  variable: '--font-archivo-narrow',
  display: 'swap',
})

export const metadata: Metadata = {
  title: 'Blanche Renaudin',
  description: 'Contemporary Fashion',
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="fr" className={`${archivoBlack.variable} ${archivoNarrow.variable}`}>
      <body className="font-text antialiased">
        {children}
      </body>
    </html>
  )
}
