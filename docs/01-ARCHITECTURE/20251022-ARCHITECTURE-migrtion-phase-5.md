# 📋 CHECKLIST PHASE 5 : App Storefront (Jour 5-6) - VERSION FINALE

## 🎯 Objectifcd **.**.\**.**.

Migrer l'application publique (storefront) dans `apps/storefront/` en préservant toutes les fonctionnalités existantes.

## ⏱️ Durée estimée : 12-16h

---

## 📦 **5.1 - Setup package Sanity (1h)**

### Créer le package

bash

```bash
mkdir -p packages/sanity/src/{schemas/types,lib}
cd packages/sanity
pnpm init
```

### Fichiers de configuration

* [X] Créer `packages/sanity/package.json`
* [X] Créer `packages/sanity/tsconfig.json`
* [X] Créer `packages/sanity/README.md`

### Migration des schémas

* [X] Copier `sanity/schemas/types/*` → `packages/sanity/src/schemas/types/`
* [X] Copier `sanity/schemas/index.ts` → `packages/sanity/src/schemas/index.ts`

### Migration de la configuration

* [X] Copier `sanity/sanity.config.ts` → `packages/sanity/src/config.ts`
* [X] Copier `sanity/structure.ts` → `packages/sanity/src/structure.ts`

### Migration de la bibliothèque

* [X] Copier `src/lib/queries.ts` → `packages/sanity/src/lib/queries.ts`
* [X] Copier `src/lib/sanity.client.ts` → `packages/sanity/src/lib/client.ts`
* [X] Copier `src/lib/sanity.image.ts` → `packages/sanity/src/lib/image-helpers.ts`

### Fichiers d'export

* [X] Créer `packages/sanity/src/index.ts` (exports principaux)
* [X] Créer `packages/sanity/.npmrc` si nécessaire

### Installation

* [X] `cd packages/sanity && pnpm install`
* [X] Vérifier : `pnpm type-check`

### Commit

* [X] `git add packages/sanity`
* [X] `git commit -m "feat(packages): add sanity package"`

---

## 🏗️ **5.2 - Setup app Storefront (30 min)**

### Créer la structure

bash

```bash
mkdir -p apps/storefront/{app,components,hooks,lib,store,public}
cd apps/storefront
pnpm init
```

### Fichiers de configuration

* [ ] Créer `apps/storefront/package.json`
* [ ] Créer `apps/storefront/next.config.ts`
* [ ] Créer `apps/storefront/tailwind.config.ts`
* [ ] Créer `apps/storefront/tsconfig.json`
* [ ] Créer `apps/storefront/.env.local.example`
* [ ] Créer `apps/storefront/README.md`

### Installation des dépendances

* [ ] `cd apps/storefront && pnpm install`
* [ ] Vérifier que les packages sont linkés

### Variables d'environnement

* [ ] Copier `.env.local.example` → `.env.local`
* [ ] Remplir les variables Supabase
* [ ] Remplir les variables Sanity
* [ ] Remplir les variables Stripe
* [ ] Remplir la variable Resend

---

## 📁 **5.3 - Migration des utilitaires et helpers (30 min)**

### Hooks custom (apps/storefront/hooks/)

* [ ] Créer `apps/storefront/hooks/`
* [ ] Copier `src/hooks/use-mobile.ts` → `apps/storefront/hooks/use-mobile.ts`
* [ ] Copier `src/hooks/use-toast.ts` → `apps/storefront/hooks/use-toast.ts`
* [ ] Copier `src/hooks/useSupabaseAuth.ts` → `apps/storefront/hooks/useSupabaseAuth.ts`
* [ ] Adapter les imports (utiliser `@repo/*`)

### Helpers lib (apps/storefront/lib/)

* [ ] Créer `apps/storefront/lib/`
* [ ] Copier `src/lib/products.ts` → `apps/storefront/lib/products.ts`
* [ ] Copier `src/lib/design-tokens.ts` → `apps/storefront/lib/design-tokens.ts`
* [ ] Vérifier si `src/lib/constants.ts` a du contenu, si oui le copier
* [ ] Adapter les imports (Supabase → `@repo/database`)

### Helpers pour API Routes (apps/storefront/lib/api/)

* [ ] Créer `apps/storefront/lib/api/`
* [ ] Créer `apps/storefront/lib/api/products.ts` (handlers purs)
* [ ] Créer `apps/storefront/lib/api/collections.ts`
* [ ] Créer `apps/storefront/lib/api/wishlist.ts`
* [ ] Créer `apps/storefront/lib/api/checkout.ts`

### Composants communs (apps/storefront/components/common/)

* [ ] Créer `apps/storefront/components/common/`
* [ ] Copier `src/components/common/LazyImage.tsx` → `apps/storefront/components/common/LazyImage.tsx`
* [ ] Copier `src/components/common/RichTextRenderer.tsx` → `apps/storefront/components/common/RichTextRenderer.tsx`
* [ ] Adapter les imports

### Composant recherche (apps/storefront/components/search/)

* [ ] Créer `apps/storefront/components/search/`
* [ ] Copier `src/components/search/SearchModal.tsx` → `apps/storefront/components/search/SearchModal.tsx`
* [ ] **NE PAS** copier `SearchDebug.tsx` (abandonné)
* [ ] Adapter les imports

---

## 🗄️ **5.4 - Migration des stores Zustand (15 min)**

### Stores (apps/storefront/store/)

* [ ] Créer `apps/storefront/store/`
* [ ] Copier `src/store/index.ts` → `apps/storefront/store/index.ts`
* [ ] Copier `src/store/useAuthStore.ts` → `apps/storefront/store/useAuthStore.ts`
* [ ] Copier `src/store/useCartStore.ts` → `apps/storefront/store/useCartStore.ts`
* [ ] Copier `src/store/useCollectionStore.ts` → `apps/storefront/store/useCollectionStore.ts`
* [ ] Copier `src/store/useProductStore.ts` → `apps/storefront/store/useProductStore.ts`
* [ ] Copier `src/store/useWishListStore.ts` → `apps/storefront/store/useWishListStore.ts`
* [ ] Adapter les imports (types Supabase → `@repo/database`)

---

## 🎨 **5.5 - Migration du layout principal (30 min)**

### Layout root

* [ ] Créer `apps/storefront/app/layout.tsx`
* [ ] Copier depuis `src/app/layout.tsx`
* [ ] Adapter les imports :
  * `@/components/layout/HeaderMinimal` → `@repo/ui/layout`
  * `@/components/layout/FooterMinimal` → `@repo/ui/layout`
  * `@/components/layout/InteractiveEntry` → `@repo/ui/layout`
* [ ] Vérifier les fonts (Archivo Black, Archivo Narrow)

### Styles globaux

* [ ] Copier `src/app/globals.css` → `apps/storefront/app/globals.css`
* [ ] Vérifier les imports Tailwind

### Assets publics

* [ ] Copier `public/*` → `apps/storefront/public/`
* [ ] Copier `favicon.ico`
* [ ] Copier les logos (SVG, PNG)

---

## 🏠 **5.6 - Migration Homepage (30 min)**

### Page d'accueil

* [ ] Copier `src/app/page.tsx` → `apps/storefront/app/page.tsx`
* [ ] Adapter les imports :
  * Sanity queries → `@repo/sanity/queries`
  * Sanity client → `@repo/sanity/client`
  * urlFor → `@repo/sanity/image`
  * Homepage component → `@repo/ui/layout`
  * InteractiveEntry → `@repo/ui/layout`

### Test

* [ ] Lancer : `pnpm dev --filter storefront`
* [ ] Vérifier que la homepage s'affiche
* [ ] Vérifier l'animation lettres flottantes
* [ ] Vérifier les hotspots Sanity sur les images

---

## 📄 **5.7 - Migration pages statiques (30 min)**

### Pages simples

* [ ] Copier `src/app/about/` → `apps/storefront/app/about/`
* [ ] Copier `src/app/contact/` → `apps/storefront/app/contact/`
* [ ] Copier `src/app/impact/` → `apps/storefront/app/impact/`
* [ ] Copier `src/app/legal-notice/` → `apps/storefront/app/legal-notice/`
* [ ] Copier `src/app/privacy/` → `apps/storefront/app/privacy/`
* [ ] Copier `src/app/returns/` → `apps/storefront/app/returns/`
* [ ] Copier `src/app/shipping/` → `apps/storefront/app/shipping/`

### Adapter les imports

* [ ] Remplacer chemins relatifs par `@repo/*`
* [ ] Sanity queries → `@repo/sanity/queries`
* [ ] Sanity client → `@repo/sanity/client`
* [ ] RichTextRenderer → depuis `apps/storefront/components/common/`

### Tests

* [ ] Tester chaque page (navigation, contenu)

---

## 🛍️ **5.8 - Migration catalogue produits (1h30)**

### Pages produits

* [ ] Copier `src/app/products/` → `apps/storefront/app/products/`
* [ ] Copier `src/app/product/[id]/` → `apps/storefront/app/product/[id]/`

### Pages collections

* [ ] Copier `src/app/collections/` → `apps/storefront/app/collections/`
* [ ] Copier `src/app/collections-editoriales/` → `apps/storefront/app/collections-editoriales/`

### Pages lookbooks

* [ ] Copier `src/app/lookbooks/` → `apps/storefront/app/lookbooks/`
* [ ] Copier `src/app/silhouettes/` → `apps/storefront/app/silhouettes/`

### Adapter les imports

* [ ] ProductImage → `@repo/ui/products`
* [ ] ProductCard* → `@repo/ui/products`
* [ ] ProductGrid* → `@repo/ui/products`
* [ ] WishlistButton → `@repo/ui/products`
* [ ] Supabase client → `@repo/database`
* [ ] Sanity queries → `@repo/sanity/queries`
* [ ] Stores → depuis `@/store/`

### Tests

* [ ] Tester navigation catalogue
* [ ] Tester détail produit
* [ ] Tester galerie images (lightbox)
* [ ] Tester sélection variantes (tailles, couleurs)
* [ ] Tester ajout au panier depuis détail produit
* [ ] Tester ajout à la wishlist
* [ ] Tester collections Sanity
* [ ] Tester lookbooks

---

## 🔍 **5.9 - Migration recherche (20 min)**

### Page recherche

* [ ] Copier `src/app/search/` → `apps/storefront/app/search/`
* [ ] Adapter les imports
* [ ] SearchModal → depuis `apps/storefront/components/search/`

### Tests

* [ ] Tester ouverture modal recherche
* [ ] Tester recherche produits
* [ ] Tester filtres
* [ ] Tester suggestions

---

## 🔐 **5.10 - Migration authentification (30 min)**

### Pages auth

* [ ] Copier `src/app/auth/login/` → `apps/storefront/app/auth/login/`

### Composants auth

* [ ] Vérifier que `AuthModal` est dans `@repo/ui/auth`
* [ ] Si non, copier `src/components/auth/AuthModal.tsx` → `apps/storefront/components/auth/`

### Adapter les imports

* [ ] Auth helpers → `@repo/auth`
* [ ] Supabase → `@repo/database`
* [ ] useAuthStore → depuis `@/store/`

### Tests

* [ ] Tester signup
* [ ] Tester login
* [ ] Tester logout
* [ ] Vérifier redirection après login
* [ ] Vérifier persistance session

---

## 👤 **5.11 - Migration espace compte (45 min)**

### Pages account

* [ ] Copier `src/app/account/page.tsx` → `apps/storefront/app/account/page.tsx`
* [ ] Copier `src/app/account/layout.tsx` → `apps/storefront/app/account/layout.tsx`
* [ ] Copier `src/app/account/orders/` → `apps/storefront/app/account/orders/`
* [ ] Copier `src/app/account/settings/` → `apps/storefront/app/account/settings/`
* [ ] Copier `src/app/account/wishlist/` → `apps/storefront/app/account/wishlist/`

### Composants account

* [ ] Vérifier que `AccountSidebar` est dans `@repo/ui/account`
* [ ] Si non, copier `src/components/account/` → `apps/storefront/components/account/`

### Adapter les imports

* [ ] Supabase → `@repo/database`
* [ ] Auth → `@repo/auth`
* [ ] Stores → depuis `@/store/`

### Tests

* [ ] Tester accès espace compte (auth required)
* [ ] Tester liste des commandes
* [ ] Tester détail commande
* [ ] Tester édition profil
* [ ] Tester gestion adresses
* [ ] Tester wishlist

---

## 🛒 **5.12 - Migration panier & checkout (1h)**

### Pages

* [ ] Copier `src/app/cart/` → `apps/storefront/app/cart/`
* [ ] Copier `src/app/checkout/` → `apps/storefront/app/checkout/`

### Adapter les imports

* [ ] Stripe → `@repo/database` (ou créer helper local)
* [ ] useCartStore → depuis `@/store/`
* [ ] Supabase → `@repo/database`

### Tests

* [ ] Tester affichage panier
* [ ] Tester modification quantité
* [ ] Tester suppression item
* [ ] Tester localStorage (persist après refresh)
* [ ] Tester passage au checkout
* [ ] Tester création session Stripe
* [ ] ⚠️ NE PAS tester paiement réel (attendre migration webhook)

---

## 🔌 **5.13 - Migration API Routes (2h)**

### Structure

* [ ] Créer `apps/storefront/app/api/`

### Auth endpoints

* [ ] Copier `src/app/api/auth/ensure-profile/` → `apps/storefront/app/api/auth/ensure-profile/`
* [ ] Créer handler pur dans `apps/storefront/lib/api/auth.ts`
* [ ] Adapter route pour appeler le handler
* [ ] Adapter imports (Supabase → `@repo/database`)

### Collections endpoints

* [ ] Copier `src/app/api/collections/` → `apps/storefront/app/api/collections/`
* [ ] Copier `src/app/api/collections/[slug]/` → `apps/storefront/app/api/collections/[slug]/`
* [ ] Créer handler pur dans `apps/storefront/lib/api/collections.ts`
* [ ] Adapter routes pour appeler les handlers
* [ ] Adapter imports

### Products endpoints

* [ ] Copier `src/app/api/products/` → `apps/storefront/app/api/products/`
* [ ] Copier `src/app/api/products/[id]/` → `apps/storefront/app/api/products/[id]/`
* [ ] Copier `src/app/api/products/by-ids/` → `apps/storefront/app/api/products/by-ids/`
* [ ] Créer handlers purs dans `apps/storefront/lib/api/products.ts`
* [ ] Adapter routes pour appeler les handlers
* [ ] Adapter imports

### Wishlist endpoints

* [ ] Copier `src/app/api/wishlist/` → `apps/storefront/app/api/wishlist/`
* [ ] Copier `src/app/api/wishlist/[id]/` → `apps/storefront/app/api/wishlist/[id]/`
* [ ] Créer handlers purs dans `apps/storefront/lib/api/wishlist.ts`
* [ ] Adapter routes pour appeler les handlers
* [ ] Adapter imports

### Checkout endpoint

* [ ] Copier `src/app/api/checkout/` → `apps/storefront/app/api/checkout/`
* [ ] Créer handler pur dans `apps/storefront/lib/api/checkout.ts`
* [ ] Adapter route pour appeler le handler
* [ ] Adapter imports (Stripe, Supabase)

### Orders endpoint

* [ ] Copier `src/app/api/orders/by-session/` → `apps/storefront/app/api/orders/by-session/`
* [ ] Créer handler pur dans `apps/storefront/lib/api/orders.ts`
* [ ] Adapter route
* [ ] Adapter imports

### Newsletter endpoint

* [ ] Copier `src/app/api/newsletter/` (routes publiques) → `apps/storefront/app/api/newsletter/`
* [ ] Adapter imports (Email → `@repo/email`)

### Launch notifications

* [ ] Copier `src/app/api/launch-notifications/` → `apps/storefront/app/api/launch-notifications/`
* [ ] Adapter imports

### Webhook Stripe ⚠️ CRITIQUE

* [ ] Copier `src/app/api/webhooks/stripe/route.ts` → `apps/storefront/app/api/webhooks/stripe/route.ts`
* [ ] Adapter imports :
  * Stripe → depuis `lib/stripe.ts` local ou `@repo/database`
  * Supabase admin → `@repo/database`
  * Email → `@repo/email`
  * Stock helpers → vérifier localisation
* [ ] Vérifier la logique de décrémentation du stock
* [ ] Vérifier le parsing des adresses JSONB

### Tests API

* [ ] Tester GET /api/products
* [ ] Tester GET /api/products/[id]
* [ ] Tester POST /api/wishlist
* [ ] Tester POST /api/checkout (session Stripe)
* [ ] Tester GET /api/collections
* [ ] ⚠️ Webhook Stripe : tester en local avec Stripe CLI

bash

```bash
  stripe listen --forward-to localhost:3000/api/webhooks/stripe
  stripe trigger checkout.session.completed
```

---

## 🎨 **5.14 - Migration Sanity Studio (30 min)**

### Studio dans storefront

* [ ] Copier `src/app/studio/` → `apps/storefront/app/studio/`
* [ ] Adapter imports (config → `@repo/sanity/config`)

### Tests Sanity

* [ ] Accéder à `/studio`
* [ ] Vérifier connexion Sanity
* [ ] Tester édition homepage
* [ ] Tester création lookbook
* [ ] Tester preview des contenus

---

## ✅ **5.15 - Vérification finale & tests (1h)**

### Build

* [ ] `pnpm build --filter storefront`
* [ ] Vérifier 0 erreur TypeScript
* [ ] Vérifier 0 erreur de build
* [ ] Vérifier taille bundle < 600KB

### Tests fonctionnels critiques

* [ ] Homepage s'affiche avec animation
* [ ] Navigation entre toutes les pages fonctionne
* [ ] Détail produit avec galerie
* [ ] Sélection variantes (tailles, couleurs)
* [ ] Ajout au panier
* [ ] Panier persiste après refresh (localStorage)
* [ ] Checkout démarre (création session Stripe)
* [ ] Login/Signup fonctionne
* [ ] Espace compte accessible
* [ ] Liste commandes s'affiche
* [ ] Recherche fonctionne
* [ ] Wishlist fonctionne
* [ ] Collections Sanity s'affichent
* [ ] Lookbooks s'affichent
* [ ] Sanity Studio accessible

### Tests responsive

* [ ] Mobile : menu hamburger fonctionne
* [ ] Mobile : navigation OK
* [ ] Mobile : panier OK
* [ ] Mobile : checkout OK
* [ ] Tablet : layout OK
* [ ] Desktop : tout OK

### Performance

* [ ] Vérifier bundle size storefront < 600KB
* [ ] Pas de console.error() dans la console
* [ ] Images se chargent correctement (lazy loading)

### Tests spécifiques

* [ ] Animation lettres flottantes fonctionne
* [ ] Hotspot Sanity sur images homepage fonctionne
* [ ] Signed URLs Supabase pour images produits

---

## 📚 **5.16 - Documentation (15 min)**

### README

* [ ] Créer `apps/storefront/README.md`
* [ ] Documenter variables d'environnement
* [ ] Documenter scripts npm disponibles
* [ ] Documenter architecture des dossiers
* [ ] Documenter intégration Stripe (webhook)

---

## 🎉 **5.17 - Commit final**

### Git

* [ ] `git status` (vérifier tous les fichiers)
* [ ] `git add apps/storefront packages/sanity`
* [ ] `git commit -m "feat(apps): add storefront application with Sanity package"`
* [ ] `git push origin main`

---

## 🚨 **Points d'attention critiques**

### À NE PAS oublier

* ✅ Garder l'animation lettres flottantes (InteractiveEntry)
* ✅ Préserver les hotspots Sanity sur les images
* ✅ Migrer le webhook Stripe COMPLET (décrémentation stock incluse)
* ✅ Vérifier localStorage pour le panier
* ✅ Tester webhooks avec Stripe CLI

### À NE PAS migrer

* ❌ `SearchDebug.tsx` (abandonné)
* ❌ `EditorialProductSection.tsx` (non utilisé)
* ❌ Routes admin (phase suivante)

---

## 📊 **Checklist récapitulative**

<pre class="font-ui border-border-100/50 overflow-x-scroll w-full rounded border-[0.5px] shadow-[0_2px_12px_hsl(var(--always-black)/5%)]"><table class="bg-bg-100 min-w-full border-separate border-spacing-0 text-sm leading-[1.88888] whitespace-normal"><thead class="border-b-border-100/50 border-b-[0.5px] text-left"><tr class="[tbody>&]:odd:bg-bg-500/10"><th class="text-text-000 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] px-2 [&:not(:first-child)]:border-l-[0.5px]">Étape</th><th class="text-text-000 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] px-2 [&:not(:first-child)]:border-l-[0.5px]">Durée</th><th class="text-text-000 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] px-2 [&:not(:first-child)]:border-l-[0.5px]">Status</th></tr></thead><tbody><tr class="[tbody>&]:odd:bg-bg-500/10"><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">5.1 - Package Sanity</td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">1h</td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">⬜</td></tr><tr class="[tbody>&]:odd:bg-bg-500/10"><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">5.2 - Setup Storefront</td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">30min</td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">⬜</td></tr><tr class="[tbody>&]:odd:bg-bg-500/10"><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">5.3 - Utilitaires</td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">30min</td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">⬜</td></tr><tr class="[tbody>&]:odd:bg-bg-500/10"><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">5.4 - Stores Zustand</td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">15min</td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">⬜</td></tr><tr class="[tbody>&]:odd:bg-bg-500/10"><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">5.5 - Layout principal</td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">30min</td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">⬜</td></tr><tr class="[tbody>&]:odd:bg-bg-500/10"><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">5.6 - Homepage</td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">30min</td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">⬜</td></tr><tr class="[tbody>&]:odd:bg-bg-500/10"><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">5.7 - Pages statiques</td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">30min</td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">⬜</td></tr><tr class="[tbody>&]:odd:bg-bg-500/10"><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">5.8 - Catalogue produits</td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">1h30</td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">⬜</td></tr><tr class="[tbody>&]:odd:bg-bg-500/10"><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">5.9 - Recherche</td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">20min</td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">⬜</td></tr><tr class="[tbody>&]:odd:bg-bg-500/10"><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">5.10 - Authentification</td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">30min</td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">⬜</td></tr><tr class="[tbody>&]:odd:bg-bg-500/10"><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">5.11 - Espace compte</td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">45min</td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">⬜</td></tr><tr class="[tbody>&]:odd:bg-bg-500/10"><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">5.12 - Panier & Checkout</td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">1h</td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">⬜</td></tr><tr class="[tbody>&]:odd:bg-bg-500/10"><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">5.13 - API Routes</td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">2h</td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">⬜</td></tr><tr class="[tbody>&]:odd:bg-bg-500/10"><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">5.14 - Sanity Studio</td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">30min</td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">⬜</td></tr><tr class="[tbody>&]:odd:bg-bg-500/10"><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">5.15 - Tests finaux</td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">1h</td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">⬜</td></tr><tr class="[tbody>&]:odd:bg-bg-500/10"><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">5.16 - Documentation</td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">15min</td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">⬜</td></tr><tr class="[tbody>&]:odd:bg-bg-500/10"><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">5.17 - Commit</td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">5min</td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">⬜</td></tr></tbody></table></pre>

**Total estimé : 12-14h**

---

**✅ Checklist prête à copier-coller dans votre document de migration !**
