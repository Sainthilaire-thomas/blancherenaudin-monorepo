
# 📊 État de la Migration Monorepo - 25 octobre 2025

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
* [X] ⚠️  **PROBLÈME IDENTIFIÉ** : Types relations Supabase (jointures) non gérés
  * TypeScript infère `never` pour les requêtes avec relations
  * Solution temporaire : cast `as any`
  * **TODO** : Créer types helpers pour relations courantes

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

## ⚠️  Phase 5 : Storefront (EN COURS - 40%)

### ✅ Ce qui fonctionne

* [X] Structure `apps/storefront/` créée
* [X] Routes publiques principales migrées :
  * [X] `/` (homepage)
  * [X] `/products`
  * [X] `/collections`
  * [X] `/cart`
  * [X] `/checkout`
  * [X] `/account`
* [X] Imports corrigés vers packages (`@repo/ui`, `@repo/database`)
* [X] `@supabase/ssr` installé
* [X] `AccountSidebar` migré
* [X] Stripe exporté de `@repo/database`

### ⚠️  Problèmes résolus aujourd'hui

* [X] Routes API collections (cast `as any`)
* [X] Import `getServerSupabase` exporté
* [X] Encodage UTF-8 des fichiers

### ❌ Problèmes restants

* [ ] **18 erreurs TypeScript dans `app/account/orders/page.tsx`**
  * Cause : Relations Supabase (`order_items`) typées comme `never`
  * Solution immédiate : Cast `as any` (workaround)
  * Solution propre : Créer types helpers dans `@repo/database`

### ❌ Routes manquantes à migrer

* [ ] `/product/[id]` (détail produit)
* [ ] `/search`
* [ ] Pages `/about`, `/contact`, `/impact`
* [ ] Pages légales
* [ ] API routes publiques restantes

### ❌ Admin mal placé

* [ ] `apps/storefront/app/api/admin/` **À SUPPRIMER**
  * Ces routes doivent aller dans `apps/admin/` (Phase 7-10)

---

## ❌ Phase 6 : Package Admin-Shell (NON COMMENCÉ)

* [ ] Créer `packages/admin-shell/`
* [ ] Types `ModuleProps`, `ModuleServices`
* [ ] `ModuleLoader` component
* [ ] Pattern d'injection de services

---

## ❌ Phase 7-10 : Apps Admin (NON COMMENCÉ)

* [ ] Créer `apps/admin/`
* [ ] Shell admin minimal
* [ ] Configuration routing
* [ ] Déplacer routes API admin de storefront

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
Phase 5    : Storefront        ████████░░░░░░░░░░░░  40%
Phase 6    : Admin-Shell       ░░░░░░░░░░░░░░░░░░░░   0%
Phase 7-10 : Apps Admin        ░░░░░░░░░░░░░░░░░░░░   0%
Phase 11-15: Modules           ░░░░░░░░░░░░░░░░░░░░   0%
Phase 16+  : Tests & Deploy    ░░░░░░░░░░░░░░░░░░░░   0%

TOTAL MIGRATION : ~30%
```

---

## 🚨 Problèmes Architecturaux Identifiés

### 1. Admin dans Storefront ⚠️

**Problème** : Routes admin dans `apps/storefront/app/api/admin/`
**Impact** : Architecture incohérente, ne suit pas la doc
**Solution** :

1. Créer `apps/admin/` (Phase 7)
2. Déplacer toutes les routes `/api/admin/*`
3. Nettoyer storefront

### 2. Types Supabase Relations 🐛

**Problème** : TypeScript infère `never` pour jointures
**Impact** : 18+ erreurs dans orders/page.tsx, workarounds `as any`
**Solution propre** :

typescript

```typescript
// packages/database/src/types-helpers.ts
exporttypeOrderWithItems=Database['public']['Tables']['orders']['Row']&{
  order_items:Database['public']['Tables']['order_items']['Row'][]
}
```

### 3. Modules vides 📁

**Problème** : Dossier `modules/` existe mais vide
**Impact** : 0% de la logique métier migrée
**Solution** : Phases 11-15 à faire

---

## 🎯 Prochaines Étapes Critiques

### Urgent (Finir Phase 5)

1. **Corriger types Supabase** (2h)
   * Créer `types-helpers.ts` dans `@repo/database`
   * Exporter types pour relations courantes
   * Supprimer tous les `as any`
2. **Migrer routes manquantes** (3h)
   * `/product/[id]`
   * `/search`
   * Pages statiques
3. **Nettoyer admin** (1h)
   * Supprimer `apps/storefront/app/api/admin/`
   * Documenter ce qui doit aller dans `apps/admin/`

### Moyen terme (Phases 6-10)

4. **Créer admin-shell** (4h)
5. **Créer apps/admin** (6h)
6. **Migrer 1 module complet** (8h) - products recommandé

---

## 📝 Notes Techniques

### Commandes Utiles

bash

```bash
# TypeCheck storefront
pnpm --filter storefront exec tsc --noEmit

# Build storefront
pnpm run build --filter=storefront

# Compter erreurs
pnpm --filter storefront exec tsc --noEmit 2>&1| Select-String "error TS"| Measure-Object
```

### Fichiers Clés Modifiés Aujourd'hui

* `packages/database/src/index.ts` - Ajout export `getServerSupabase`
* `packages/database/src/stripe.ts` - Copié et exporté
* `apps/storefront/components/account/AccountSidebar.tsx` - Migré
* `apps/storefront/app/api/collections/route.ts` - Cast `as any`
* `apps/storefront/app/account/orders/page.tsx` - En cours

---

## 🤔 Questions en Suspens

1. **Déploiement** : Une instance Vercel ou deux ?
   * Décision : **Une seule** avec routing `/admin`
   * Justification : Plus simple, moins cher, URLs cohérentes
2. **Types Supabase** : Pourquoi `never` sur les relations ?
   * Cause : TypeScript ne peut pas inférer automatiquement les jointures
   * Solution : Types helpers explicites à créer
3. **Priorité modules** : Dans quel ordre les migrer ?
   * Recommandation : products → orders → customers → autres

---

**Dernière mise à jour** : 25 octobre 2025, 21:00
**Durée totale investie** : ~8 heures
**Estimation restante** : 40-50 heures
