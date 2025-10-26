/**
 * Configuration et constantes partagées
 */

// URLs
export const SITE_URL = process.env.NEXT_PUBLIC_SITE_URL || "http://localhost:3000"
export const ADMIN_URL = process.env.NEXT_PUBLIC_ADMIN_URL || "http://localhost:3001"

// Supabase
export const SUPABASE_URL = process.env.NEXT_PUBLIC_SUPABASE_URL!
export const SUPABASE_ANON_KEY = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!

// Stripe
export const STRIPE_PUBLIC_KEY = process.env.NEXT_PUBLIC_STRIPE_PUBLIC_KEY!
export const STRIPE_SECRET_KEY = process.env.STRIPE_SECRET_KEY!
export const STRIPE_WEBHOOK_SECRET = process.env.STRIPE_WEBHOOK_SECRET!

// Email
export const RESEND_API_KEY = process.env.RESEND_API_KEY
export const EMAIL_FROM = process.env.EMAIL_FROM || "noreply@blancherenaudin.com"

// Business rules
export const FREE_SHIPPING_THRESHOLD = 100 // €
export const DEFAULT_SHIPPING_COST = 8.5 // €
export const MAX_CART_QUANTITY = 99
export const SESSION_COOKIE_NAME = "sb-session"

// Pagination
export const PRODUCTS_PER_PAGE = 12
export const ORDERS_PER_PAGE = 20

// Image sizes
export const IMAGE_SIZES = {
  sm: { width: 400, height: 500 },
  md: { width: 800, height: 1000 },
  lg: { width: 1200, height: 1500 },
  xl: { width: 1600, height: 2000 },
} as const

// Order statuses
export const ORDER_STATUSES = {
  PENDING: "pending",
  PAID: "paid",
  PROCESSING: "processing",
  SHIPPED: "shipped",
  DELIVERED: "delivered",
  CANCELLED: "cancelled",
  REFUNDED: "refunded",
} as const

export type OrderStatus = (typeof ORDER_STATUSES)[keyof typeof ORDER_STATUSES]

// Payment statuses
export const PAYMENT_STATUSES = {
  PENDING: "pending",
  PAID: "paid",
  FAILED: "failed",
  REFUNDED: "refunded",
} as const

export type PaymentStatus = (typeof PAYMENT_STATUSES)[keyof typeof PAYMENT_STATUSES]
