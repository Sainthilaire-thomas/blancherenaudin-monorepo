# **Document 3 — Guide de contribution (Monorepo Next.js + Supabase + Tools)**

---

## 🎯 Objectif du guide

Ce document définit les  **règles de contribution** , **bonnes pratiques** et **outils communs** utilisés dans le monorepo.

Il vise à :

* Assurer la **cohérence technique et visuelle** entre les tools
* Prévenir les **régressions** dans le shell et les dépendances partagées
* Faciliter la **collaboration entre développeurs** sur un même espace de code
* Maintenir une **expérience utilisateur homogène**

---

## 🧩 1. Structure du monorepo

<pre class="overflow-visible!" data-start="733" data-end="1584"><div class="contain-inline-size rounded-2xl relative bg-token-sidebar-surface-primary"><div class="sticky top-9"><div class="absolute end-0 bottom-0 flex h-9 items-center pe-2"><div class="bg-token-bg-elevated-secondary text-token-text-secondary flex items-center gap-4 rounded-sm px-2 font-sans text-xs"></div></div></div><div class="overflow-y-auto p-4" dir="ltr"><code class="whitespace-pre!"><span><span>.
├─ apps/
│  └─ web/                      </span><span># App shell (Next.js App Router)</span><span>
│     ├─ app/
│     │  ├─ (shell)/            </span><span># Layout global, navigation, auth</span><span>
│     │  ├─ (tools)/            </span><span># Montage des tools (wrappers)</span><span>
│     │  └─ api/                </span><span># Routes API locales</span><span>
│     ├─ middleware.ts
│     └─ env.mjs
│
├─ packages/
│  ├─ ui/                       </span><span># @acme</span><span>/ui - Design System MUI
│  ├─ supabase/                 </span><span># @acme</span><span>/supabase - Client + helpers
│  ├─ types/                    </span><span># @acme</span><span>/types - Interfaces, Zod
│  ├─ utils/                    </span><span># @acme</span><span>/utils - Helpers, flags, formatters
│  ├─ config/                   </span><span># @acme</span><span>/config - ESLint, TS, Prettier configs
│  └─ tools/                    </span><span># Tools métiers (indépendants)</span><span>
│     ├─ tool-a/
│     ├─ tool-b/
│     └─ tool-c/
│
├─ turbo.json
├─ pnpm-workspace.yaml
└─ package.json
</span></span></code></div></div></pre>

---

## 🧱 2. Rôles et responsabilités

| Élément                               | Rôle                                                                                |
| --------------------------------------- | ------------------------------------------------------------------------------------ |
| **Shell (`apps/web`)**          | Gère la navigation, l’authentification, le layout global et le registre des tools. |
| **Tool (`packages/tools/...`)** | Contient la logique métier, ses routes, hooks et composants.                        |
| **UI (`@acme/ui`)**             | Fournit le Design System partagé (MUI, thèmes, composants).                        |
| **Supabase (`@acme/supabase`)** | Fournit le client, les hooks et les helpers RLS.                                     |
| **Types (`@acme/types`)**       | Centralise les interfaces et schémas partagés.                                     |
| **Config (`@acme/config`)**     | Définit les règles de lint, TS et formatage.                                       |

> 🔑 **Principe clé :** chaque tool est  **autonome** , mais **ne doit jamais dupliquer** de logique présente dans un package partagé.

---

## 🧠 3. Flux de travail Git standard

### 🪄 Branch naming convention

* `feature/<nom>` → nouvelle fonctionnalité
* `fix/<nom>` → correction de bug
* `refactor/<nom>` → refactor technique
* `docs/<nom>` → documentation
* `chore/<nom>` → maintenance, upgrade de dépendance

Exemples :

<pre class="overflow-visible!" data-start="2640" data-end="2716"><div class="contain-inline-size rounded-2xl relative bg-token-sidebar-surface-primary"><div class="sticky top-9"><div class="absolute end-0 bottom-0 flex h-9 items-center pe-2"><div class="bg-token-bg-elevated-secondary text-token-text-secondary flex items-center gap-4 rounded-sm px-2 font-sans text-xs"></div></div></div><div class="overflow-y-auto p-4" dir="ltr"><code class="whitespace-pre!"><span><span>feature/tool-d-import
fix/supabase-realtime-desync
refactor/ui-theme
</span></span></code></div></div></pre>

---

## 🧾 4. Conventions de commit (Commitlint)

Les commits suivent la norme **Conventional Commits** :

<pre class="overflow-visible!" data-start="2825" data-end="2861"><div class="contain-inline-size rounded-2xl relative bg-token-sidebar-surface-primary"><div class="sticky top-9"><div class="absolute end-0 bottom-0 flex h-9 items-center pe-2"><div class="bg-token-bg-elevated-secondary text-token-text-secondary flex items-center gap-4 rounded-sm px-2 font-sans text-xs"></div></div></div><div class="overflow-y-auto p-4" dir="ltr"><code class="whitespace-pre!"><span><span><span class="language-xml"><type</span></span><span>>(scope): </span><span><description</span><span>>
</span></span></code></div></div></pre>

### Types autorisés :

| Type         | Usage                                  |
| ------------ | -------------------------------------- |
| `feat`     | nouvelle fonctionnalité               |
| `fix`      | correction de bug                      |
| `refactor` | refactor sans ajout de feature         |
| `style`    | changements de style/code sans logique |
| `docs`     | mise à jour de la documentation       |
| `test`     | ajout/modif de tests                   |
| `chore`    | maintenance, CI, config                |
| `perf`     | amélioration de performance           |

### Exemples :

<pre class="overflow-visible!" data-start="3262" data-end="3411"><div class="contain-inline-size rounded-2xl relative bg-token-sidebar-surface-primary"><div class="sticky top-9"><div class="absolute end-0 bottom-0 flex h-9 items-center pe-2"><div class="bg-token-bg-elevated-secondary text-token-text-secondary flex items-center gap-4 rounded-sm px-2 font-sans text-xs"></div></div></div><div class="overflow-y-auto p-4" dir="ltr"><code class="whitespace-pre!"><span><span>feat</span><span>(tool-c): ajout de la vue liste avec filtres
</span><span>fix</span><span>(ui): corrige le padding des boutons MUI
</span><span>refactor</span><span>(supabase): extraction du client serveur
</span></span></code></div></div></pre>

> ✅ Les commits sont validés automatiquement via  **husky + commitlint** .

---

## 🧰 5. Commandes utiles

| Commande                                     | Description                                |
| -------------------------------------------- | ------------------------------------------ |
| `pnpm dev`                                 | Lance le shell et les tools en mode dev    |
| `pnpm -r build`                            | Build tous les packages                    |
| `pnpm -r lint`                             | Vérifie les règles ESLint                |
| `pnpm -r typecheck`                        | Vérifie les types TypeScript              |
| `pnpm -r test`                             | Exécute les tests Vitest/Jest             |
| `pnpm changeset`                           | Crée une version pour un package modifié |
| `pnpm turbo run dev --filter=@acme/tool-c` | Dev uniquement sur un tool donné          |

---

## 🎨 6. Bonnes pratiques UI & MUI

1. **Toujours utiliser le thème global**
   * Importer depuis `@acme/ui`
   * Pas de `createTheme()` local
   * Typo : `Typography variant="h6"` → cohérence garantie
2. **Favoriser les composants réutilisables**
   * Si un composant devient générique, le déplacer vers `@acme/ui`
3. **Respecter la structure visuelle**
   * Pas de `margin`/`padding` en dur → utiliser `sx` et tokens (`theme.spacing()`)
   * Privilégier `Grid`, `Stack`, `Box`
4. **Accessibilité (a11y)**
   * Boutons = `Button`
   * Liens = `Link`
   * Labels explicites pour les inputs
   * Couleurs testées avec contraste AA minimum

---

## ⚙️ 7. Règles de code et typage

1. **Types centralisés**
   * Tous les modèles viennent de `@acme/types`
   * Pas de duplication de type dans un tool
2. **Imports**
   * `@acme/ui`, `@acme/supabase`, `@acme/types`, `@acme/utils`
   * Jamais d’import direct entre deux tools (`tool-a` → `tool-b` ❌)
3. **Lint et formatage**
   * ESLint + Prettier configurés via `@acme/config`
   * Interdiction des `any` non justifiés
   * Interdiction des console.log en prod
4. **Server components**
   * Préférer `Server Component` pour la data initiale (via `createServerSupabase`)
   * `use client` uniquement quand nécessaire (interaction, hooks React)

---

## 🔒 8. Sécurité & données

1. **RLS obligatoire**
   * Toute table Supabase doit avoir une policy `USING (org_id = auth.jwt() →> 'org_id')`
   * Les outils ne doivent jamais interroger `service_role` côté client
2. **Middleware de sécurité**
   * Vérifie les rôles pour `/tool-x/**`
   * Le shell redirige vers `/forbidden` si non autorisé
3. **Env & secrets**
   * `.env.local` jamais commité
   * Variables validées par `env.mjs` avec Zod

---

## 🧭 9. Ajout d’un nouveau Tool

Pour créer un nouveau tool, suivre le **Document 2** (guide de création).

Résumé rapide :

1️⃣ `packages/tools/tool-x` → création du package

2️⃣ `src/manifest.ts` → manifest du tool

3️⃣ `src/routes/` → composants (Home, List, Detail…)

4️⃣ `apps/web/app/(tools)/tool-x/` → pages minces Next

5️⃣ `tool-registry.ts` → ajout du manifest

6️⃣ `middleware.ts` → mise à jour des rôles

7️⃣ Supabase → création du schéma `tool_x` + RLS

> 🔁 Les tools sont montés automatiquement dans le shell via le registre global.

---

## 🧩 10. Stratégie de tests

| Niveau       | Outil                 | Objectif                                  |
| ------------ | --------------------- | ----------------------------------------- |
| Unitaire     | Vitest / Jest         | Vérifier les hooks et composants isolés |
| Intégration | React Testing Library | Vérifier la cohérence UI + logique      |
| E2E          | Playwright            | Tester les parcours utilisateur complets  |
| Typecheck    | TypeScript            | Vérifier les types partagés et exports  |

### Bonnes pratiques :

* Un test = une responsabilité
* Nommer les fichiers `.test.ts` ou `.spec.tsx`
* Placer les tests à côté du code :

  `src/routes/__tests__/list.test.tsx`

---

## 🔄 11. Pull Requests & Review

1. **Ouvrir une PR par fonctionnalité**
   * `feature/tool-c-filtering`
2. **Inclure un résumé clair**
   * Description
   * Impact
   * Étapes de test
3. **Checklist PR**
   * [ ] Lint OK
   * [ ] Typecheck OK
   * [ ] Tests passent
   * [ ] RLS vérifié (si Supabase)
   * [ ] Screenshots (si UI)
4. **Review**
   * Deux reviewers minimum
   * Aucune merge sans approbation

---

## 🧱 12. CI/CD (Turborepo + Vercel)

### Pipelines Turborepo

<pre class="overflow-visible!" data-start="7343" data-end="7566"><div class="contain-inline-size rounded-2xl relative bg-token-sidebar-surface-primary"><div class="sticky top-9"><div class="absolute end-0 bottom-0 flex h-9 items-center pe-2"><div class="bg-token-bg-elevated-secondary text-token-text-secondary flex items-center gap-4 rounded-sm px-2 font-sans text-xs"></div></div></div><div class="overflow-y-auto p-4" dir="ltr"><code class="whitespace-pre! language-json"><span><span>{</span><span>
  </span><span>"pipeline"</span><span>:</span><span></span><span>{</span><span>
    </span><span>"build"</span><span>:</span><span></span><span>{</span><span></span><span>"dependsOn"</span><span>:</span><span></span><span>[</span><span>"^build"</span><span>]</span><span>,</span><span></span><span>"outputs"</span><span>:</span><span></span><span>[</span><span>".next/**"</span><span>,</span><span></span><span>"dist/**"</span><span>]</span><span></span><span>}</span><span>,</span><span>
    </span><span>"lint"</span><span>:</span><span></span><span>{</span><span></span><span>"outputs"</span><span>:</span><span></span><span>[</span><span>]</span><span></span><span>}</span><span>,</span><span>
    </span><span>"typecheck"</span><span>:</span><span></span><span>{</span><span></span><span>"outputs"</span><span>:</span><span></span><span>[</span><span>]</span><span></span><span>}</span><span>,</span><span>
    </span><span>"test"</span><span>:</span><span></span><span>{</span><span></span><span>"outputs"</span><span>:</span><span></span><span>[</span><span>"coverage/**"</span><span>]</span><span></span><span>}</span><span>
  </span><span>}</span><span>
</span><span>}</span><span>
</span></span></code></div></div></pre>

### Intégration continue

* Lancement auto de `lint`, `test`, `typecheck` sur chaque PR
* Prévisualisation Vercel (`vercel preview`) par branche
* Build de production seulement sur `main`

---

## 🧱 13. Guidelines de versioning (Changesets)

* Chaque package peut évoluer indépendamment (`@acme/tool-a@1.2.0`)
* Utiliser `pnpm changeset` :
  <pre class="overflow-visible!" data-start="7910" data-end="7940"><div class="contain-inline-size rounded-2xl relative bg-token-sidebar-surface-primary"><div class="sticky top-9"><div class="absolute end-0 bottom-0 flex h-9 items-center pe-2"><div class="bg-token-bg-elevated-secondary text-token-text-secondary flex items-center gap-4 rounded-sm px-2 font-sans text-xs"></div></div></div><div class="overflow-y-auto p-4" dir="ltr"><code class="whitespace-pre! language-bash"><span><span>pnpm changeset
  </span></span></code></div></div></pre>
* Version sémantique :
  * `major` : breaking change
  * `minor` : ajout de feature
  * `patch` : bugfix ou amélioration interne
* Les releases sont agrégées dans le changelog global

---

## 🧭 14. Workflow de développement recommandé

1️⃣ Créer une branche `feature/...`

2️⃣ Développer le code localement

3️⃣ Lancer `pnpm dev` pour voir le tool monté

4️⃣ Ajouter les tests (`pnpm test`)

5️⃣ Vérifier lint + types (`pnpm lint && pnpm typecheck`)

6️⃣ Commit propre avec message conventionnel

7️⃣ Ouvrir une PR → Review → Merge → Preview auto

---

## 📚 15. Documentation

* Chaque package a un `README.md` avec :
  * Objectif
  * Exemple d’utilisation
  * Points d’intégration
* Le shell (`apps/web`) a un `docs/architecture.md` détaillant :
  * Le rôle du shell
  * La logique du routage
  * La configuration Supabase
  * La gestion du thème

---

## ✅ 16. Résumé

| Domaine                | Bon réflexe                                         |
| ---------------------- | ---------------------------------------------------- |
| **Architecture** | Isoler le métier par tool, mutualiser tout le reste |
| **UI**           | Utiliser exclusivement `@acme/ui`                  |
| **Supabase**     | Client mutualisé + RLS strict                       |
| **Routing**      | Layout global (shell) + layout local (tool)          |
| **Sécurité**   | RBAC via middleware                                  |
| **Tests**        | Unitaires + e2e systématiques                       |
| **Commits**      | Conventionnels et explicites                         |
| **CI/CD**        | Turborepo + Vercel (preview sur PR)                  |
