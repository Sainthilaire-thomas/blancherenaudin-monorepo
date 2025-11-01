# Plan d’évolution avant la migration du tool `products`

## 0) Objectif & principe de migration

* **Objectif** : préparer l’architecture (shell, registry, build, sécurité, data, tests) pour que la migration de `products` soit  **une opération mécanique et peu risquée** .
* **Principe clé** : **pages & route handlers minces** côté app Next, **logique pure** dans le tool (testable, réutilisable par Server Actions et routes), conformément au pattern décrit dans ta doc. ARCHITECTURE-migration-archi-mo…

  ARCHITECTURE-migration-archi-mo…

---

## 1) Alignement monorepo & TypeScript

### 1.1 Project References & tsconfig

* Activer/valider les **Project References** (`composite`, `declaration`) au root et dans chaque package pour un **build incrémental** rapide. ARCHITECTURE-migration-archi-mo…
* Vérifier la chaîne “apps → packages (ui, database, tools/*)” dans `tsconfig.json` de chaque app. ARCHITECTURE-migration-archi-mo…

### 1.2 Turborepo pipelines

* Confirmer le  **pipeline Turbo** : `build` dépend de `^build`, `type-check`, `lint`, `test`, et exposer les **env** nécessaires aux builds. ARCHITECTURE-migration-archi-mo…
* Garder `dev` non-caché & persistant pour un DX fluide. ARCHITECTURE-migration-archi-mo…

**Gate** : `pnpm -r type-check && pnpm -r build` < 3min, aucun warning critique. ARCHITECTURE-migration-archi-mo…

---

## 2) Packaging “tools” et transpilation Next

### 2.1 Renommer “modules” → “tools” et déplacer dans `packages/tools/*`

* Ex. `packages/tools/products/` (UI métier, hooks, services, API “pures”).
* **Zéro import horizontal entre tools** ; passer par le shell/registry et des **services injectés** si nécessaire (toast, confirm, navigate, hasPermission). ARCHITECTURE-migration-archi-mo…

### 2.2 Transpile côté apps Next

* Ajouter tous les `@repo/tools-*` (ex-`@modules/*`) à `transpilePackages` dans **chaque app** qui les consomme (shell admin, storefront si besoin). ARCHITECTURE-migration-archi-mo…

**Gate** : `next build` de l’app shell passe avec tous les tools listés en `transpilePackages`. ARCHITECTURE-migration-archi-mo…

---

## 3) Shell, Registry & RBAC

### 3.1 Registry des tools

* Centraliser un **registre** (id, nom, route, permissions, loader/lazy) pour piloter la **nav** et le  **chargement conditionnel** . ARCHITECTURE-migration-archi-mo…
* **Charger le bundle d’un tool seulement si autorisé** (vérif rôle/permissions **avant** import dynamique). ARCHITECTURE-migration-archi-mo…

### 3.2 Module/Tool Loader + services injectés

* Garantir l’isolation : le tool consomme des **services du shell** (notify/confirm/navigate/hasPermission) injectés via props. ARCHITECTURE-migration-archi-mo…
* Envelopper le chargement dans un **ErrorBoundary** par tool. ARCHITECTURE-migration-archi-mo…

**Gate** : un tool simple (ex. `newsletter`) déjà monté via registry + loader (smoke test) — pattern validé. ARCHITECTURE-migration-archi-mo…

---

## 4) UI & Design System

* `@repo/ui`  **RSC-compatible** , `sideEffects:false`, preset Tailwind, imports nominaux (icônes tree-shakées). ARCHITECTURE-migration-archi-mo…

  ARCHITECTURE-migration-archi-mo…

  ARCHITECTURE-migration-archi-mo…
* Apps configurées pour **scanner** les chemins des packages dans Tailwind (éviter purge). ARCHITECTURE-migration-archi-mo…

**Gate** : l’app shell affiche une page de démo utilisant des composants `@repo/ui` sans flash ni purge CSS. ARCHITECTURE-migration-archi-mo…

---

## 5) Data & Supabase

### 5.1 Package database

* Centraliser clients Supabase (`client-browser`, `client-server`, `client-admin`) et **génération de types** automatisée (`generate:types`) dans `@repo/database`. ARCHITECTURE-migration-archi-mo…
* **Ne jamais** appeler un client admin/server dans un composant client ; passer par **Server Actions** ou **Route Handlers** minces. ARCHITECTURE-migration-archi-mo…

### 5.2 Pattern “logique pure”

* Écrire la logique CRUD dans `packages/tools/products/src/api/*` (fonctions pures testables) et appeler ces fonctions depuis des  **route handlers minces** . ARCHITECTURE-migration-archi-mo…

  ARCHITECTURE-migration-archi-mo…

**Gate** : un endpoint d’exemple appelle une fonction pure d’un tool et renvoie un JSON (test unitaire vert + smoke E2E). ARCHITECTURE-migration-archi-mo…

---

## 6) Routage Next (App Router)

* **Pages minces** dans `apps/admin/app/(tools)/products/**` qui **réexportent** les écrans du tool.
* Navigation interne au tool via son **layout local** (tabs, breadcrumb), `loading.tsx`, `error.tsx`, parallel/intercepting routes si besoin (modales).  *(Pattern déjà utilisé dans ta doc de migration)* . ARCHITECTURE-migration-archi-mo…

**Gate** : navigation shell → `products` → liste/détail factices OK, modale optionnelle OK.

---

## 7) Performance, Budgets & Observabilité

* **Budgets** de bundle (ex : Shell ≤ 250KB, Tool Products ≤ 200KB) + script de vérification. ARCHITECTURE-migration-archi-mo…
* **optimizePackageImports** pour `@repo/ui`, `lucide-react`, etc. ARCHITECTURE-migration-archi-mo…
* ErrorBoundary par tool + Sentry branchée côté shell. ARCHITECTURE-migration-archi-mo…

**Gate** : build d’analyse OK, tailles < budgets, Sentry reçoit une erreur simulée.

---

## 8) Tests & CI/CD

### 8.1 Tests

* **Unitaires** sur API “pure” du tool (`products`) avec mock Supabase. ARCHITECTURE-migration-archi-mo…
* **E2E smoke** (Playwright) : auth → accès tool → liste produits → création/édition simulée. ARCHITECTURE-migration-archi-mo…
* **Type-check & lint** : obligatoires sur PR. ARCHITECTURE-migration-archi-mo…

### 8.2 CI

* Job “Generate Supabase Types” + check diff types. ARCHITECTURE-migration-archi-mo…
* Pipelines Turbo standard (build/type-check/lint/test) sur PR + préviews. ARCHITECTURE-migration-archi-mo…

**Gate** : pipeline vert, préview Vercel fonctionnelle.

---

## 9) Sécurité & accès

* Vérif **auth/rôle/permissions** côté serveur **avant** le lazy-load du tool ; si refus : message clair (route protégée). ARCHITECTURE-migration-archi-mo…
* Côté DB : **RLS** déjà en place ; `products` utilisera les mêmes claims (`org_id`, rôles) que les autres tools.  *(cohérent avec le reste de ta doc)* . ARCHITECTURE-migration-archi-mo…

**Gate** : un compte sans permission `products:*` n’instancie pas le bundle `products` et voit “Accès refusé”. ARCHITECTURE-migration-archi-mo…

---

## 10) Séquence pratique (avant migration `products`)

1. **Fondations** : TS refs + Turbo + UI + Database + Registry + Loader + RBAC (smoke avec un tool simple). ARCHITECTURE-migration-archi-mo…
2. **Routage** : pages minces `products` factices (home/liste/détail), layout local, modale.
3. **Data** : créer `packages/tools/products/src/api/…` (list, get, create, update, delete) **sans** les brancher encore à une vraie table (mock). ARCHITECTURE-migration-archi-mo…
4. **Tests** : unitaires + 1 E2E smoke (liste factice). ARCHITECTURE-migration-archi-mo…
5. **Perf/Obs** : budgets, analyze, Sentry. ARCHITECTURE-migration-archi-mo…
6. **CI** : jobs en place, préviews OK. ARCHITECTURE-migration-archi-mo…

**Critère “GO migration `products`”** : toutes les **Gates** ci-dessus sont au vert.

---

## 11) Migration `products` (aperçu du diff réel que tu feras ensuite)

* **Créer** `packages/tools/products/` :
  * `src/api/products.ts` (fonctions pures : list/create/update/delete/uploadImage, etc.)
  * `src/routes/…` (écrans RSC + clients ciblés)
  * `src/index.ts` (exports)
* **Monter** dans `apps/admin/app/(tools)/products/**` via pages minces.
* **Adapter les API routes** existantes pour déléguer aux fonctions pures. ARCHITECTURE-migration-archi-mo…
* **Brancher Supabase** depuis `@repo/database` uniquement côté serveur (Server Actions/Routes). ARCHITECTURE-migration-archi-mo…
* **Tests** : activer tests métier, E2E basiques (CRUD). ARCHITECTURE-migration-archi-mo…

---

## 12) Checklists prêtes à cocher

**Infra & Build**

* [ ] TS Project Refs OK, Turbo OK. ARCHITECTURE-migration-archi-mo…

  ARCHITECTURE-migration-archi-mo…
* [ ] `transpilePackages` inclut `@repo/tools-products`. ARCHITECTURE-migration-archi-mo…
* [ ] UI RSC + Tailwind scan multi-packages OK. ARCHITECTURE-migration-archi-mo…

**Shell & Sécurité**

* [ ] Registry/Loader opérationnels, ErrorBoundary branché. ARCHITECTURE-migration-archi-mo…
* [ ] RBAC empêche le bundle d’être chargé si refus. ARCHITECTURE-migration-archi-mo…

**Data & API**

* [ ] `@repo/database` + génération des types en CI. ARCHITECTURE-migration-archi-mo…
* [ ] Route handlers minces → fonctions pures du tool. ARCHITECTURE-migration-archi-mo…

  ARCHITECTURE-migration-archi-mo…

**Tests & Perf**

* [ ] Unitaires + E2E smoke verts. ARCHITECTURE-migration-archi-mo…
* [ ] Budgets bundle respectés, analyze OK. ARCHITECTURE-migration-archi-mo…
* [ ] Sentry capte une erreur test.

---

### Conclusion

Tu as déjà posé les bons fondements dans ta doc. En appliquant **ces prérequis et “gates”** avant d’attaquer `products`, tu **dé-risques** la migration :

* **couplage maîtrisé** (registry/loader/services),
* **builds rapides** (TS Refs + Turbo),
* **sécurité** (RBAC côté serveur),
* **qualité** (tests unitaires & E2E + budgets).

Quand tout est au vert, la migration de `products` devient un **simple portage mécanique** du code vers un tool packagé, avec des **pages minces** et des **APIs pures** — exactement le pattern recommandé dans ta doc. ARCHITECTURE-migration-archi-mo…

 ARCHITECTURE-migration-archi-mo…
