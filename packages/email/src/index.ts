// packages/email/src/index.ts
// ==========================================
// EXPORTS FONCTIONS D'ENVOI
// ==========================================
export { 
  sendEmail,
  sendOrderConfirmationEmail,
  sendOrderShippedEmail,
  sendOrderDeliveredEmail,
  sendPasswordResetEmail,
  sendWelcomeEmail,
  sendNewsletterConfirmationEmail,
  formatPrice
} from './utils/send'

export { sendOrderConfirmationHook } from './utils/send-order-confirmation-hook'

// ==========================================
// EXPORTS TEMPLATES
// ==========================================
export { default as NewsletterConfirmation } from './templates/newsletter-confirmation'
export { OrderConfirmationEmail } from './templates/order-confirmation'
export { OrderShippedEmail } from './templates/order-shipped'
export { OrderDeliveredEmail } from './templates/order-delivered'
export { PasswordResetEmail } from './templates/password-reset'
export { WelcomeEmail } from './templates/welcome'

// ==========================================
// EXPORTS DE TYPES
// ==========================================
export type { EmailType } from './utils/config'
export { EMAIL_CONFIG } from './utils/config'
