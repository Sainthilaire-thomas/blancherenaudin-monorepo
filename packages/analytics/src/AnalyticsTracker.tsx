// packages/analytics/src/AnalyticsTracker.tsx
'use client'

import { useEffect, useRef } from 'react'
import { usePathname, useSearchParams } from 'next/navigation'
import {
  trackPageView,
  trackTimeOnPage,
  preloadAnalyticsData,
} from './analytics' // ✅ Import relatif

export function AnalyticsTracker() {
  const pathname = usePathname()
  const searchParams = useSearchParams()
  const startTimeRef = useRef<number>(0)
  const lastPathRef = useRef<string>('')
  const preloadedRef = useRef<boolean>(false)

  // Preload analytics data (géo + UTM) au premier render
  useEffect(() => {
    if (!preloadedRef.current) {
      preloadedRef.current = true
      preloadAnalyticsData().catch(console.debug)
    }
  }, [])

  useEffect(() => {
    const fullPath =
      pathname + (searchParams.toString() ? `?${searchParams.toString()}` : '')

    // Track time on previous page before switching
    if (lastPathRef.current && startTimeRef.current > 0) {
      const timeOnPage = Math.round((Date.now() - startTimeRef.current) / 1000)
      if (timeOnPage > 0 && timeOnPage < 3600) {
        trackTimeOnPage(lastPathRef.current, timeOnPage).catch(console.debug)
      }
    }

    // Track new page view
    trackPageView(fullPath).catch(console.debug)

    // Update refs for next page
    startTimeRef.current = Date.now()
    lastPathRef.current = fullPath

    // Cleanup
    return () => {
      if (startTimeRef.current > 0) {
        const timeOnPage = Math.round(
          (Date.now() - startTimeRef.current) / 1000
        )
        if (timeOnPage > 0 && timeOnPage < 3600) {
          trackTimeOnPage(lastPathRef.current, timeOnPage).catch(console.debug)
        }
      }
    }
  }, [pathname, searchParams])

  return null
}
