# @repo/email - Package Email Transactionnel

**Status**: ✅ Conforme à l'architecture cible
**Date de validation**: 1er novembre 2025

## 📦 Structure

\\\
packages/email/src/
├── templates/              # Templates React Email
│   ├── newsletter-campaign.tsx
│   ├── newsletter-confirmation.tsx
│   ├── order-confirmation.tsx
│   ├── order-delivered.tsx
│   ├── order-shipped.tsx
│   ├── password-reset.tsx
│   ├── welcome.tsx
│   └── index.ts
├── utils/                  # Services d'envoi
│   ├── config.ts          # Configuration emails
│   ├── send.ts            # Service principal
│   └── send-order-confirmation-hook.ts
└── index.ts               # Point d'entrée unique
\\\

## 📤 Exports Publics

\\\	ypescript
import {
  // Services d'envoi
  sendEmail,
  sendOrderConfirmationEmail,
  sendOrderShippedEmail,
  sendOrderDeliveredEmail,
  sendPasswordResetEmail,
  sendWelcomeEmail,
  sendNewsletterConfirmationEmail,
  sendOrderConfirmationHook,
  
  // Templates (si besoin de personnalisation)
  OrderConfirmationEmail,
  OrderShippedEmail,
  OrderDeliveredEmail,
  PasswordResetEmail,
  WelcomeEmail,
  NewsletterConfirmation,
  
  // Config
  EMAIL_CONFIG,
  EmailType,
  
  // Utils
  formatPrice,
} from '@repo/email'

// Export alternatif pour les templates
import { OrderConfirmationEmail } from '@repo/email/templates'
\\\

## 🔧 Configuration Requise

\\\ash
# .env
RESEND_API_KEY=re_xxx
\\\

## 📧 Templates Disponibles

1. **Commandes**
   - \order-confirmation.tsx\ - Confirmation de commande
   - \order-shipped.tsx\ - Expédition
   - \order-delivered.tsx\ - Livraison

2. **Newsletter**
   - \
ewsletter-confirmation.tsx\ - Confirmation inscription
   - \
ewsletter-campaign.tsx\ - Campagne newsletter

3. **Utilisateur**
   - \welcome.tsx\ - Email de bienvenue
   - \password-reset.tsx\ - Réinitialisation mot de passe

## ✅ Validation

\\\ash
cd packages/email
pnpm type-check
# ✅ Aucune erreur
\\\

## 🎯 Utilisation

\\\	ypescript
import { sendOrderConfirmationEmail } from '@repo/email'

// Envoyer email de confirmation
await sendOrderConfirmationEmail({
  to: 'customer@example.com',
  orderNumber: 'BR-2024-001',
  items: [...],
  total: 129.90
})
\\\

## 📋 Dépendances

- \@react-email/components\ - Composants email React
- \@react-email/render\ - Rendu HTML
- \esend\ - Service d'envoi d'emails
- \@repo/database\ - Accès aux données ✅

## ✨ Points Forts

- ✅ Templates React maintenables
- ✅ Type-safe avec TypeScript
- ✅ Configuration centralisée
- ✅ Service Resend intégré
- ✅ Formatting automatique (prix, dates)

## 🚀 Prochaines Améliorations

- [ ] Tests unitaires des templates
- [ ] Preview dev des emails
- [ ] Tracking d'ouverture/clics
- [ ] Support multi-langues
