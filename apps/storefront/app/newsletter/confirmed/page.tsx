// apps/storefront/app/newsletter/confirmed/page.tsx
import Link from 'next/link'
import { CheckCircle2, XCircle, Clock, AlertTriangle } from 'lucide-react'

interface PageProps {
  searchParams: Promise<{
    error?: string
  }>
}

export default async function NewsletterConfirmedPage({ searchParams }: PageProps) {
  const params = await searchParams
  const error = params.error

  // État: Succès (pas d'erreur)
  if (!error) {
    return (
      <div className="min-h-screen flex items-center justify-center px-4 py-16">
        <div className="max-w-md w-full text-center">
          {/* Icon Success */}
          <div className="mb-8 flex justify-center">
            <CheckCircle2 className="w-20 h-20 text-green-600" />
          </div>

          {/* Title */}
          <h1 className="text-[32px] md:text-[40px] font-bold tracking-[0.05em] lowercase mb-4">
            subscription confirmed
          </h1>

          {/* Message */}
          <p className="text-[15px] leading-relaxed text-grey-medium mb-8 lowercase tracking-[0.02em]">
            thank you for confirming your email address. you&apos;re now
            subscribed to our newsletter and will receive our latest updates,
            exclusive offers, and new collection launches.
          </p>

          {/* CTA Buttons */}
          <div className="flex flex-col sm:flex-row gap-4 justify-center">
            <Link
              href="/"
              className="px-8 py-3 bg-black text-white text-[13px] font-semibold tracking-[0.15em] lowercase hover:bg-grey-dark transition-colors"
            >
              back to homepage
            </Link>
            <Link
              href="/products"
              className="px-8 py-3 border border-black text-black text-[13px] font-semibold tracking-[0.15em] lowercase hover:bg-grey-light transition-colors"
            >
              discover products
            </Link>
          </div>
        </div>
      </div>
    )
  }

  // État: Token expiré
  if (error === 'expired') {
    return (
      <div className="min-h-screen flex items-center justify-center px-4 py-16">
        <div className="max-w-md w-full text-center">
          <div className="mb-8 flex justify-center">
            <Clock className="w-20 h-20 text-orange-500" />
          </div>

          <h1 className="text-[32px] md:text-[40px] font-bold tracking-[0.05em] lowercase mb-4">
            link expired
          </h1>

          <p className="text-[15px] leading-relaxed text-grey-medium mb-8 lowercase tracking-[0.02em]">
            this confirmation link has expired. confirmation links are valid for
            24 hours only.
          </p>

          <p className="text-[15px] leading-relaxed text-grey-medium mb-8 lowercase tracking-[0.02em]">
            please subscribe again using the newsletter form in our footer to
            receive a new confirmation email.
          </p>

          <Link
            href="/"
            className="inline-block px-8 py-3 bg-black text-white text-[13px] font-semibold tracking-[0.15em] lowercase hover:bg-grey-dark transition-colors"
          >
            back to homepage
          </Link>
        </div>
      </div>
    )
  }

  // État: Token invalide
  if (error === 'invalid_token') {
    return (
      <div className="min-h-screen flex items-center justify-center px-4 py-16">
        <div className="max-w-md w-full text-center">
          <div className="mb-8 flex justify-center">
            <XCircle className="w-20 h-20 text-red-600" />
          </div>

          <h1 className="text-[32px] md:text-[40px] font-bold tracking-[0.05em] lowercase mb-4">
            invalid link
          </h1>

          <p className="text-[15px] leading-relaxed text-grey-medium mb-8 lowercase tracking-[0.02em]">
            this confirmation link is invalid or malformed. please check that
            you copied the complete link from your email.
          </p>

          <Link
            href="/"
            className="inline-block px-8 py-3 bg-black text-white text-[13px] font-semibold tracking-[0.15em] lowercase hover:bg-grey-dark transition-colors"
          >
            back to homepage
          </Link>
        </div>
      </div>
    )
  }

  // État: Token manquant
  if (error === 'missing_token') {
    return (
      <div className="min-h-screen flex items-center justify-center px-4 py-16">
        <div className="max-w-md w-full text-center">
          <div className="mb-8 flex justify-center">
            <AlertTriangle className="w-20 h-20 text-yellow-600" />
          </div>

          <h1 className="text-[32px] md:text-[40px] font-bold tracking-[0.05em] lowercase mb-4">
            missing token
          </h1>

          <p className="text-[15px] leading-relaxed text-grey-medium mb-8 lowercase tracking-[0.02em]">
            no confirmation token was provided. please use the link from your
            confirmation email.
          </p>

          <Link
            href="/"
            className="inline-block px-8 py-3 bg-black text-white text-[13px] font-semibold tracking-[0.15em] lowercase hover:bg-grey-dark transition-colors"
          >
            back to homepage
          </Link>
        </div>
      </div>
    )
  }

  // État: Erreur database
  if (error === 'database') {
    return (
      <div className="min-h-screen flex items-center justify-center px-4 py-16">
        <div className="max-w-md w-full text-center">
          <div className="mb-8 flex justify-center">
            <XCircle className="w-20 h-20 text-red-600" />
          </div>

          <h1 className="text-[32px] md:text-[40px] font-bold tracking-[0.05em] lowercase mb-4">
            error occurred
          </h1>

          <p className="text-[15px] leading-relaxed text-grey-medium mb-8 lowercase tracking-[0.02em]">
            an error occurred while confirming your subscription. this may be
            because you&apos;ve already confirmed your email, or there was a
            technical issue.
          </p>

          <p className="text-[15px] leading-relaxed text-grey-medium mb-8 lowercase tracking-[0.02em]">
            if the problem persists, please contact us.
          </p>

          <div className="flex flex-col sm:flex-row gap-4 justify-center">
            <Link
              href="/"
              className="px-8 py-3 bg-black text-white text-[13px] font-semibold tracking-[0.15em] lowercase hover:bg-grey-dark transition-colors"
            >
              back to homepage
            </Link>
            <Link
              href="/contact"
              className="px-8 py-3 border border-black text-black text-[13px] font-semibold tracking-[0.15em] lowercase hover:bg-grey-light transition-colors"
            >
              contact us
            </Link>
          </div>
        </div>
      </div>
    )
  }

  // État: Erreur inconnue (fallback)
  return (
    <div className="min-h-screen flex items-center justify-center px-4 py-16">
      <div className="max-w-md w-full text-center">
        <div className="mb-8 flex justify-center">
          <AlertTriangle className="w-20 h-20 text-yellow-600" />
        </div>

        <h1 className="text-[32px] md:text-[40px] font-bold tracking-[0.05em] lowercase mb-4">
          something went wrong
        </h1>

        <p className="text-[15px] leading-relaxed text-grey-medium mb-8 lowercase tracking-[0.02em]">
          an unexpected error occurred. please try again or contact us if the
          problem persists.
        </p>

        <Link
          href="/"
          className="inline-block px-8 py-3 bg-black text-white text-[13px] font-semibold tracking-[0.15em] lowercase hover:bg-grey-dark transition-colors"
        >
          back to homepage
        </Link>
      </div>
    </div>
  )
}

// Métadonnées SEO
export const metadata = {
  title: 'Newsletter Confirmation | Blanche Renaudin',
  description: 'Confirm your newsletter subscription',
  robots: 'noindex, nofollow', // Pas besoin d'indexer cette page
}
