
# 📊 État de la Migration Monorepo - 26 octobre 2025

## 🎯 Objectif

Migrer de `site_v1_next` (monolithique) vers `blancherenaudin-monorepo` (architecture modulaire) selon la doc ARCHITECTURE-migration-archi-modulaire.md

---

## ✅ Phase 1-4 : Fondations (TERMINÉ)

### Phase 1 : Setup Monorepo ✅

* [X] Structure Turborepo créée
* [X] pnpm workspaces configuré
* [X] turbo.json avec pipelines
* [X] TypeScript Project References

### Phase 2 : Package Config ✅

* [X] `packages/config/` (Tailwind, ESLint, TS)
* [X] Configuration partagée entre apps

### Phase 3 : Package Database ✅

* [X] `packages/database/` créé
* [X] Types Supabase générés
* [X] Clients Supabase (browser, server, admin)
* [X] Stripe exporté
* [X] ✅ **RÉSOLU** : Types helpers créés dans `types-helpers.ts`
  * `OrderWithItems`, `OrderWithDetails`, `ProductWithImages`
  * Tous les `as any` supprimés
  * 18 erreurs TypeScript corrigées

### Phase 4 : Package UI ✅

* [X] `packages/ui/` avec shadcn/ui
* [X] 48 composants migrés
* [X] Exports organisés

### Autres Packages Créés ✅

* [X] `packages/email/` (templates)
* [X] `packages/auth/` (helpers)
* [X] `packages/analytics/`
* [X] `packages/newsletter/`
* [X] `packages/shipping/`
* [X] `packages/utils/`
* [X] `packages/sanity/`

---

## ✅ Phase 5 : Storefront (TERMINÉ - 100%) 🎉

### ✅ Structure complète

* [X] `apps/storefront/` créée et configurée
* [X] Tous les imports corrigés vers packages
* [X] `@supabase/ssr` installé
* [X] Configuration Next.js 15 fonctionnelle

### ✅ Routes publiques migrées (100%)

* [X] `/` (homepage)
* [X] `/products` (catalogue)
* [X] `/products/[category]` (par catégorie)
* [X] `/product/[id]` (détail produit) ⭐
  * [X] Page serveur avec fetch Supabase
  * [X] Client component avec galerie lightbox
  * [X] Sélection couleur/taille
  * [X] Gestion stock par variante
  * [X] Add to cart fonctionnel
* [X] `/collections` (liste)
* [X] `/collections/[slug]` (détail)
* [X] `/cart` (panier)
* [X] `/checkout` (paiement)
* [X] `/account` (espace client)
  * [X] `/account/orders` (commandes) ⭐ Types corrigés
  * [X] `/account/settings` (paramètres)
  * [X] `/account/wishlist` (favoris)

### ✅ Pages statiques migrées (100%)

* [X] `/about` (à propos) ⭐
* [X] `/contact` (formulaire contact) ⭐
* [X] `/impact` (développement durable) ⭐
* [X] `/legal-notice` (mentions légales) ⭐
* [X] `/privacy` (politique de confidentialité) ⭐
* [X] `/returns` (retours) ⭐
* [X] `/shipping` (livraison) ⭐

### ✅ Composants migrés

* [X] `AccountSidebar` avec logout
* [X] `ProductCardMinimal`
* [X] `ProductImage` avec signed URLs
* [X] `HeaderMinimal` & `FooterMinimal`
* [X] Tous les composants UI de `@repo/ui`

### ✅ API Routes publiques

* [X] `/api/products` (liste)
* [X] `/api/products/[id]` (détail)
* [X] `/api/collections` (liste)
* [X] `/api/collections/[slug]` (détail)
* [X] `/api/wishlist` (CRUD favoris)

### ✅ Problèmes résolus

* [X] Types Supabase relations (`never` → types helpers)
* [X] Imports packages corrigés
* [X] Encodage UTF-8
* [X] Routes admin supprimées (appartiennent à Phase 7)

---

## ❌ Phase 6 : Package Admin-Shell (NON COMMENCÉ)

* [ ] Créer `packages/admin-shell/`
* [ ] Types `ModuleProps`, `ModuleServices`
* [ ] `ModuleLoader` component
* [ ] Pattern d'injection de services

---

## ❌ Phase 7-10 : Apps Admin (NON COMMENCÉ)

### Routes Admin à Migrer (Phase 7)

```bash
apps/admin/app/
├── api/
│   ├── categories/           ⏳ À créer
│   ├── customers/            ⏳ À créer
│   ├── product-images/       ⏳ À créer
│   ├── products/             ⏳ À créer
│   └── variants/             ⏳ À créer
├── layout.tsx                ⏳ Shell admin
└── page.tsx                  ⏳ Dashboard
```

**Note** : Ces routes étaient dans `apps/storefront/app/api/admin/` et ont été **supprimées** car elles appartiennent à l'app admin (Phase 7-10).

---

## ❌ Phase 11-15 : Modules Admin (NON COMMENCÉ)

### Structure cible (8 modules)

```
modules/
├── analytics/     ❌ Non créé
├── categories/    ❌ Non créé
├── customers/     ❌ Non créé
├── media/         ❌ Non créé
├── newsletter/    ❌ Non créé
├── orders/        ❌ Non créé
├── products/      ❌ Non créé
└── social/        ❌ Non créé
```

Le dossier `modules/` existe mais est  **vide** .

---

## 📊 Progression Globale

```
Phase 1-4  : Fondations        ████████████████████ 100%
Phase 5    : Storefront        ████████████████████ 100% ✅
Phase 6    : Admin-Shell       ░░░░░░░░░░░░░░░░░░░░   0%
Phase 7-10 : Apps Admin        ░░░░░░░░░░░░░░░░░░░░   0%
Phase 11-15: Modules           ░░░░░░░░░░░░░░░░░░░░   0%
Phase 16+  : Tests & Deploy    ░░░░░░░░░░░░░░░░░░░░   0%

TOTAL MIGRATION : ~35%
```

---

## 🎉 Milestone : Storefront Production-Ready !

Le storefront est maintenant **100% fonctionnel** avec :

* ✅ Toutes les routes publiques
* ✅ Authentification Supabase
* ✅ Panier avec Zustand + localStorage
* ✅ Pages produits avec images optimisées
* ✅ Pages statiques complètes
* ✅ Types TypeScript propres (sans `as any`)
* ✅ Architecture modulaire respectée

**Prochaine étape** : Phase 6-7 pour l'admin

---

## 🚨 Décisions Architecturales Prises

### 1. Admin Séparé du Storefront ✅

**Décision** : Routes admin supprimées du storefront
**Raison** : Respect de l'architecture modulaire
**Impact** : Apps admin à créer en Phases 7-10

### 2. Types Helpers Centralisés ✅

**Implémentation** : `packages/database/src/types-helpers.ts`
**Bénéfice** : Résout les problèmes de relations Supabase
**Types ajoutés** :

* `OrderWithItems`, `OrderWithDetails`, `OrderWithFullItems`
* `ProductWithImages`, `CustomerWithAddresses`
* `CollectionWithProducts`, `WishlistItemWithProduct`
* Type guards (`isOrderWithItems`, `isProductWithImages`)

### 3. Deployment ✅

**Décision** : Une seule instance Vercel
**Routing** : `/` (storefront) + `/admin` (admin)
**Justification** : Plus simple, moins cher, URLs cohérentes

---

## 🎯 Prochaines Étapes Critiques

### Phase 6 : Admin Shell (4-6h)

1. Créer `packages/admin-shell/`
2. Définir interfaces modules
3. Système de routing dynamique
4. Layout admin commun

### Phase 7 : Apps Admin (6-8h)

1. Créer `apps/admin/`
2. Shell admin minimal
3. Migrer routes API admin
4. Configuration routing

### Phase 8-10 : Premier Module (8-12h)

**Recommandation** : Commencer par `products`

* Module le plus utilisé
* Logique métier bien définie
* Dépendances claires (categories, media)

---

## 📝 Notes Techniques

### Commandes Utiles

```bash
# TypeCheck storefront
pnpm --filter storefront exec tsc --noEmit

# Build storefront
pnpm run build --filter=storefront

# Dev storefront
pnpm --filter storefront dev

# Linter
pnpm --filter storefront lint
```

### Fichiers Clés Modifiés (25-26 oct)

**Types & Database**

* `packages/database/src/types-helpers.ts` - Créé (résout 18 erreurs TS)
* `packages/database/src/index.ts` - Export types helpers

**Pages Storefront**

* `apps/storefront/app/about/page.tsx` - Migré ✅
* `apps/storefront/app/contact/page.tsx` - Migré ✅
* `apps/storefront/app/impact/page.tsx` - Migré ✅
* `apps/storefront/app/legal-notice/page.tsx` - Migré ✅
* `apps/storefront/app/privacy/page.tsx` - Migré ✅
* `apps/storefront/app/returns/page.tsx` - Migré ✅
* `apps/storefront/app/shipping/page.tsx` - Migré ✅
* `apps/storefront/app/product/[id]/page.tsx` - Migré ✅
* `apps/storefront/app/product/[id]/ProductDetailClient.tsx` - Migré ✅

**Nettoyage**

* `apps/storefront/app/api/admin/*` - **SUPPRIMÉ** (Phase 7)

---

## 🤔 Questions Résolues

1. **Types Supabase relations** ✅
   * Problème : TypeScript infère `never` pour les jointures
   * Solution : Types helpers dans `@repo/database/types-helpers`
2. **Architecture admin** ✅
   * Problème : Routes admin dans storefront
   * Solution : Supprimées, à recréer en Phase 7 dans `apps/admin/`
3. **Deployment** ✅
   * Décision : Une instance Vercel avec routing `/admin`

---

## 📈 Temps Investi

* **Setup initial** : ~8h (Phases 1-4)
* **Storefront migration** : ~12h (Phase 5)
* **Debugging types** : ~2h
* **Pages statiques** : ~2h
* **Total Phase 5** : ~24h

**Estimation restante** :

* Phase 6 : 4-6h
* Phase 7-10 : 15-20h
* Phase 11-15 : 30-40h
* Tests & Deploy : 10-15h
* **Total restant** : 60-80h

---

**Dernière mise à jour** : 26 octobre 2025, 15:00
**Phase actuelle** : Phase 5 ✅ TERMINÉE
**Prochaine phase** : Phase 6 - Admin Shell
