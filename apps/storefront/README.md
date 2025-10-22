# Storefront App

Application publique e-commerce .blancherenaudin

## Stack

* **Framework** : Next.js 15
* **UI** : React 19 + Tailwind CSS
* **State** : Zustand
* **CMS** : Sanity
* **Database** : Supabase
* **Payment** : Stripe

## Installation

```bash
pnpm install
```

## Variables d'environnement

Copiez `.env.local.example` vers `.env.local` et remplissez les variables.

## Développement

```bash
pnpm dev
```

L'app démarre sur [http://localhost:3000](http://localhost:3000/)

## Build

```bash
pnpm build
pnpm start
```

## Structure

```
app/              # Routes Next.js 15
components/       # Composants spécifiques storefront
hooks/            # Hooks custom
lib/              # Utilitaires
store/            # Stores Zustand
public/           # Assets statiques
```

## Packages utilisés

* `@repo/ui` - Composants UI partagés
* `@repo/database` - Client Supabase
* `@repo/email` - Templates email
* `@repo/auth` - Authentification
* `@repo/sanity` - CMS Sanity
* `@repo/analytics` - Analytics
* `@repo/utils` - Utilitaires

## Routes principales

* `/` - Homepage
* `/products` - Catalogue
* `/product/[id]` - Détail produit
* `/cart` - Panier
* `/checkout` - Paiement
* `/account` - Espace client
* `/studio` - Sanity Studio
