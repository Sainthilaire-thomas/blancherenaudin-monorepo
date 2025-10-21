// packages/analytics/src/analytics.ts
import { track } from '@vercel/analytics'

/**
 * Track page view
 */
export async function trackPageView(path: string) {
  try {
    track('pageview', { path })
  } catch (error) {
    console.debug('Failed to track page view:', error)
  }
}

/**
 * Track time spent on page
 */
export async function trackTimeOnPage(path: string, seconds: number) {
  try {
    track('time_on_page', {
      path,
      seconds,
    })
  } catch (error) {
    console.debug('Failed to track time on page:', error)
  }
}

/**
 * Preload analytics data (geo + UTM)
 * Vercel Analytics collecte automatiquement ces données
 */
export async function preloadAnalyticsData() {
  // Vercel Analytics gère automatiquement la géolocalisation et les UTM params
  // Cette fonction est là pour la compatibilité avec le code existant
  return Promise.resolve()
}
