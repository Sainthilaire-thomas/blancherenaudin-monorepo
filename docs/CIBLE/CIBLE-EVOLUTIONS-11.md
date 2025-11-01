# 🧭 ARCHITECTURE CIBLE — RECOMMANDATIONS v1.1

### *Plan d’évolution et d’optimisation continue avant et après la migration du premier tool (`products`)*

---

## 1. 🎯 Objectif du document

Cette page complète la **documentation d’architecture cible** existante.

Elle vise à :

* Sécuriser la **phase de migration des tools** (ex : `products`)
* Renforcer la **robustesse, la maintenabilité et la scalabilité** du monorepo
* Définir un **plan d’amélioration continue** après la première migration

> 📘 Cette version est dite “v1.1 – post-migration” : elle n’introduit pas de refonte, seulement des évolutions structurantes.

---

## 2. 🧱 Structure monorepo et conventions

### ✅ Bonnes pratiques validées

* Architecture **apps / packages / tools**
* Séparation claire entre :
  * `apps/` : shell Next.js (UI globale, routage, sécurité)
  * `packages/tools/` : tools métiers autonomes
  * `packages/ui/`, `packages/database/`, `packages/types/` : partages communs
* Routes “minces” dans l’app Next → logique pure dans les tools

### 🔧 Recommandations

| Amélioration                           | Détail                                                                                                                                | Impact                                                  |
| --------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------- |
| **Automatiser le ToolRegistry**   | Script Node `generate-tool-registry.ts`qui parcourt `packages/tools/*/manifest.ts`et génère `apps/admin/lib/tool-registry.ts`. | Supprime les oublis manuels et maintient la cohérence. |
| **Alias TS `@tools/*`**         | Ajouter dans `tsconfig.base.json`:`"@tools/*": ["packages/tools/*/src"]`                                                           | Lisibilité accrue dans les imports et DX améliorée.  |
| **Convention de nommage stricte** | Tous les packages tools →`@repo/tools-<name>`                                                                                       | Facilite la génération automatique et la CI.          |

---

## 3. 🧭 Routage, Loader et RBAC

### ✅ Bonnes pratiques validées

* App Router → `(tools)/<tool>/` avec pages minces
* `ToolLoader` dynamique avec RBAC client-side
* Vérification d’accès avant lazy-load

### 🔧 Recommandations

| Amélioration                            | Détail                                                                                                                                                                         | Impact                                                           |
| ---------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------- |
| **Guard serveur RSC**              | Ajouter une vérification côté serveur avant rendu du layout du tool :                                                                                                        | Sécurité renforcée, empêche le préchargement non autorisé. |
|                                          | `tsximport { requirePermission } from '@/lib/rbac';export default async function Layout({ children }) {  await requirePermission('products:read');  return <>{children}</>;}` |                                                                  |
| **ErrorBoundary global par tool**  | Wrapper systématique autour du `ToolLoader`(affiche un fallback clair + capture Sentry).                                                                                     | Améliore résilience et observabilité.                         |
| **Loader asynchrone instrumenté** | Log du temps de chargement et des erreurs par tool.                                                                                                                             | Permet des métriques de performance par module.                 |

---

## 4. 🧩 UI et Design System (`@repo/ui`)

### ✅ Bonnes pratiques validées

* Design System MUI partagé, compatible RSC
* Thème et tokens centralisés

### 🔧 Recommandations

| Amélioration                            | Détail                                                                                                     | Impact                                       |
| ---------------------------------------- | ----------------------------------------------------------------------------------------------------------- | -------------------------------------------- |
| **Audit d’accessibilité (a11y)** | Lancer `axe-core`en CI sur chaque preview.                                                                | Améliore la conformité AA/AAA.             |
| **Exports clients explicites**     | Marquer les composants non-RSC (`use client`) dans `@repo/ui`avec suffixe `.client.tsx`.              | Réduit les warnings et erreurs Next.js.     |
| **Catalogue interne**              | Ajouter `/docs/ui-components`(Storybook ou sandbox Next) pour visualiser les composants du design system. | Favorise la cohérence visuelle entre tools. |

---

## 5. 🔒 Sécurité et gestion des accès

### ✅ Bonnes pratiques validées

* RBAC via `ToolRegistry.permissions`
* Middleware Next.js + policies Supabase (RLS)

### 🔧 Recommandations

| Amélioration                         | Détail                                                                                  | Impact                                     |
| ------------------------------------- | ---------------------------------------------------------------------------------------- | ------------------------------------------ |
| **RLS systématique**           | Script SQL d’audit automatisé vérifiant la présence de RLS sur chaque table.         | Garantit la conformité sécurité.        |
| **`ServerGuard`standardisé** | Factory de guards `requirePermission('scope')`→ utilisée par tous les layouts tools. | Uniformité et moins d’erreurs manuelles. |
| **Logs d’accès**              | Enregistrer les accès tools (org_id, user_id, route) dans `logs_access`.              | Audit trail et observabilité sécurité.  |

---

## 6. 🧮 Données, Supabase et Data Layer

### ✅ Bonnes pratiques validées

* Clients `browser`, `server`, `admin` distincts
* Typage auto via `supabase gen types`
* Logique pure et testable dans `packages/tools/*/api`

### 🔧 Recommandations

| Amélioration                             | Détail                                                                                      | Impact                                                |
| ----------------------------------------- | -------------------------------------------------------------------------------------------- | ----------------------------------------------------- |
| **Créer un “Data Layer” commun** | Dossier `packages/database/src/repositories/`: fonctions réutilisables multi-tools.       | Réduit duplication et divergence des requêtes.      |
| **Validation systématique Zod**    | Chaque API handler utilise un schéma `inputSchema.safeParse()`.                           | Typage runtime + prévention des erreurs utilisateur. |
| **Abstraction RPC**                 | Fonctions `callRpc('function', params)`pour éviter les appels SQL directs dans les tools. | Simplifie la maintenance et la sécurité.            |

---

## 7. ⚙️ Tests et qualité

### ✅ Bonnes pratiques validées

* Unit tests sur les API “pures”
* Tests E2E de base via Playwright

### 🔧 Recommandations

| Amélioration                              | Détail                                             | Impact                                            |
| ------------------------------------------ | --------------------------------------------------- | ------------------------------------------------- |
| **Tests d’intégration API routes** | Mock Supabase et vérifier les statuts 200/403/500. | Couverture du pipeline RBAC complète.            |
| **Rapport de couverture (Codecov)**  | Intégrer dans la CI → badge de couverture global. | Mesure continue de la qualité.                   |
| **Snapshots UI**                     | Intégrer Storybook +`chromatic`ou `happo.io`.  | Détection automatique de régressions visuelles. |

---

## 8. 🧱 Performance et observabilité

### ✅ Bonnes pratiques validées

* `optimizePackageImports`
* Budgets de bundles
* Turborepo cache et CI optimisée

### 🔧 Recommandations

| Amélioration                                | Détail                                                                         | Impact                                   |
| -------------------------------------------- | ------------------------------------------------------------------------------- | ---------------------------------------- |
| **Sentry global**                      | Brancher Sentry au niveau du `ErrorBoundary`du ToolLoader.                    | Traçabilité des erreurs runtime.       |
| **Dashboard interne “Tools Status”** | Afficher par tool : version, taille bundle, temps de load, erreurs.             | Monitoring interne clair pour le DevOps. |
| **Compression et image CDN**           | Configurer les headers `NextResponse`+ images optimisées via `next/image`. | Réduction du TTFB et du LCP.            |

---

## 9. 🧰 CI/CD et DevOps

### ✅ Bonnes pratiques validées

* Workflow complet (typecheck, lint, build, test)
* Turbo pipelines
* Preview automatique sur PR

### 🔧 Recommandations

| Amélioration                             | Détail                                                              | Impact                                    |
| ----------------------------------------- | -------------------------------------------------------------------- | ----------------------------------------- |
| **Job “Generate Supabase Types”** | Vérifie les diffs sur les types DB avant merge.                     | Détecte les breaking changes DB.         |
| **Analyse de bundle automatisée**  | Intégrer `next-bundle-analyzer`en job CI avec seuils max.         | Suivi des performances sur le long terme. |
| **Preview E2E**                     | Lancer un test Playwright sur la preview Vercel après déploiement. | Assurance qualité avant merge.           |

---

## 10. 📈 Scalabilité à moyen terme

| Thème                              | Recommandation                                                                                                                   | Objectif                                              |
| ----------------------------------- | -------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------- |
| **Communication inter-tools** | Implémenter un `ShellEventBus`(pub/sub React Context) pour propager des événements (`product.updated`,`order.refresh`). | Synchronisation inter-tools sans dépendance directe. |
| **Versioning des tools**      | Ajouter un champ `version`dans chaque manifest + registry.                                                                     | Compatibilité ascendante et audit.                   |
| **Docs API automatiques**     | Génération Markdown/OpenAPI à partir des fonctions dans `packages/tools/*/api`.                                             | Documentation vivante des endpoints.                  |
| **Feature Flags**             | Table `features`Supabase + hook `useFeatureFlag('tool_x')`.                                                                  | Activer/désactiver des tools dynamiquement.          |

---

## 11. 🧠 Synthèse

| Domaine          | État actuel | Prochaine étape                             |
| ---------------- | ------------ | -------------------------------------------- |
| Monorepo & Build | ✅ Stable    | Automatiser le registry & alias TS           |
| Routage & Loader | ✅ Fiable    | Ajouter guard serveur & instrumentation      |
| Data Layer       | ✅ Solide    | Introduire `repositories/`& validation Zod |
| Sécurité       | ✅ Complète | Audit RLS & logs d’accès                   |
| Tests            | 🟡 Partiel   | Étendre à intégration & couverture        |
| CI/CD            | 🟢 Avancé   | Reporting bundle & génération types        |
| Observabilité   | ⚪ Optionnel | Sentry + dashboard “Tools Status”          |

---

## 12. 🧩 Conclusion

L’architecture cible actuelle est **très bien conçue** — claire, modulaire et alignée sur les standards modernes de Next.js 15 / Turborepo / Supabase.

Les recommandations ci-dessus visent uniquement à :

* **Renforcer la robustesse** (guard serveur, RLS audité)
* **Améliorer la maintenabilité** (registry auto, data layer partagé)
* **Optimiser la qualité et la visibilité** (tests, Sentry, dashboards)

> 🚀 Une fois ces ajustements appliqués, ton architecture atteindra le niveau d’un  **design “enterprise-ready”** , prêt à accueillir des dizaines de tools indépendants avec un cycle CI/CD maîtrisé.
>
