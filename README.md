# Blanche Renaudin - Monorepo

Architecture modulaire pour le site e-commerce Blanche Renaudin.

## Structure

- `apps/storefront` - Site public Next.js
- `apps/admin` - Admin shell Next.js
- `modules/*` - 8 modules admin isolés
- `packages/*` - Code partagé réutilisable
- `shared/*` - Sanity, docs, scripts

## Getting Started
```bash
pnpm install
pnpm dev:storefront
pnpm dev:admin
```
