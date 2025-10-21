// Templates avec exports nommés
export { NewsletterCampaignEmail } from './newsletter-campaign'
export { OrderConfirmationEmail } from './order-confirmation'
export { OrderDeliveredEmail } from './order-delivered'
export { OrderShippedEmail } from './order-shipped'
export { PasswordResetEmail } from './password-reset'
export { WelcomeEmail } from './welcome'

// Newsletter confirmation utilise export default
export { default as NewsletterConfirmationEmail } from './newsletter-confirmation'
