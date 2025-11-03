
# **Document 3 — Guide de contribution (Monorepo Next.js + Supabase + Tools)**

> **📅 Dernière mise à jour** : 2 novembre 2025
>
> **✅ Statut** : Validé avec POC test-tool

---

## 🎉 Points critiques validés

Suite aux tests approfondis du 2 novembre 2025, voici les **règles absolues** pour créer un tool qui fonctionne :

### 🔴 CRITIQUES (ne JAMAIS ignorer)

1. **Extension `.tsx` pour JSX**

   * ✅ `index.tsx` → Fonctionne
   * ❌ `index.ts` → Erreur de compilation JSX
2. **Layouts DOIVENT retourner children**

   * ✅ `return <>{children}</>` → Minimum requis
   * ❌ Layout vide ou sans return → Casse TOUS les exports du groupe
   * 🔍 **Bug silencieux** : L'erreur ne mentionne PAS le layout !
3. **Ajouter comme dépendance workspace**

   ```bash
   cd apps/admin
   pnpm add @repo/tools-xxx@workspace:*
   ```

   * Sans cette étape, Next.js ne trouve pas le package
4. **Déclarer dans `transpilePackages`**

   ```typescript
   // apps/admin/next.config.ts
   transpilePackages: [
     '@repo/tools-xxx',  // ✅ OBLIGATOIRE
   ]
   ```
5. **Export simple dans package.json**

   ```json
   {
     "exports": {
       ".": "./src/index.tsx"  // ✅ Chemin direct
     }
   }
   ```

### 🟡 IMPORTANTES (recommandations fortes)

1. **Workspace pnpm configuré**
   ```yaml
   # pnpm-workspace.yaml
   packages:
     - 'apps/*'
     - 'packages/*'
     - 'packages/tools/*'  # ✅ Inclure tools
   ```
2. **Pas de dépendances inutiles**
   * Commencer minimal (juste React)
   * Ajouter `@repo/ui`, `@repo/database` seulement si nécessaire
3. **Nettoyer le cache si problème**
   ```bash
   rm -rf apps/admin/.next
   pnpm dev
   ```

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

```
.
├─ apps/
│  └─ admin/                      # App shell (Next.js App Router)
│     ├─ app/
│     │  ├─ (shell)/              # Layout global, navigation, auth
│     │  ├─ (tools)/              # Montage des tools (wrappers)
│     │  └─ api/                  # Routes API locales
│     ├─ middleware.ts
│     └─ next.config.ts
│
├─ packages/
│  ├─ ui/                         # @repo/ui - Design System
│  ├─ database/                   # @repo/database - Client + helpers
│  ├─ auth/                       # @repo/auth - Authentication
│  └─ tools/                      # Tools métiers (indépendants)
│     ├─ products/
│     ├─ categories/
│     ├─ newsletter/
│     └─ [autres]/
│
├─ turbo.json
├─ pnpm-workspace.yaml
└─ package.json
```

---

## 🧱 2. Rôles et responsabilités

| Élément                               | Rôle                                                                               |
| --------------------------------------- | ----------------------------------------------------------------------------------- |
| **Shell (`apps/admin`)**        | Gère la navigation, l'authentification, le layout global et le registre des tools. |
| **Tool (`packages/tools/...`)** | Contient la logique métier, ses routes, hooks et composants.                       |
| **UI (`@repo/ui`)**             | Fournit le Design System partagé (shadcn/ui + customs).                            |
| **Database (`@repo/database`)** | Fournit les clients Supabase (browser, server, admin).                              |
| **Auth (`@repo/auth`)**         | Centralise la logique d'authentification.                                           |

> 🔑 **Principe clé** : chaque tool est  **autonome** , mais **ne doit jamais dupliquer** de logique présente dans un package partagé.

---

## 🧠 3. Flux de travail Git standard

### 🪄 Branch naming convention

* `feature/<nom>` → nouvelle fonctionnalité
* `fix/<nom>` → correction de bug
* `refactor/<nom>` → refactor technique
* `docs/<nom>` → documentation
* `chore/<nom>` → maintenance, upgrade de dépendance

Exemples :

```
feature/tool-analytics
fix/categories-delete-bug
refactor/database-types
docs/update-architecture
```

---

## 🧾 4. Conventions de commit (Commitlint)

Les commits suivent la norme **Conventional Commits** :

```
<type>(scope): <description>
```

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

```
feat(tools-categories): ajout formulaire création
fix(ui): corrige padding des boutons
refactor(database): extraction client serveur
docs(architecture): mise à jour recette validée
```

> ✅ Les commits sont validés automatiquement via  **husky + commitlint** .

---

## 🧰 5. Commandes utiles

| Commande            | Description                             |
| ------------------- | --------------------------------------- |
| `pnpm dev`        | Lance le shell et les tools en mode dev |
| `pnpm build`      | Build tous les packages                 |
| `pnpm lint`       | Vérifie les règles ESLint             |
| `pnpm type-check` | Vérifie les types TypeScript           |
| `pnpm test`       | Exécute les tests Vitest               |
| `pnpm clean`      | Nettoie node_modules et .next           |

---

## 🎨 6. Bonnes pratiques UI

1. **Toujours utiliser le Design System**
   * Importer depuis `@repo/ui`
   * Pas de composants UI custom sans raison
2. **Composants réutilisables**
   * Si un composant devient générique, le déplacer vers `@repo/ui`
3. **Tailwind best practices**
   * Utiliser les classes utilitaires
   * Pas de styles inline complexes
   * Privilégier `cn()` pour combiner les classes
4. **Accessibilité (a11y)**
   * Boutons = `<Button>`
   * Liens = `<Link>`
   * Labels explicites pour les inputs
   * Contraste AA minimum

---

## ⚙️ 7. Règles de code et typage

1. **Types centralisés**
   * Types métier dans le package tool
   * Types partagés dans `@repo/database/types`
2. **Imports**
   * Toujours depuis `@repo/ui`, `@repo/database`, etc.
   * Jamais d'import direct entre deux tools
3. **Lint et formatage**
   * ESLint configuré
   * Prettier configuré
   * Pas de `any` sans justification
   * Pas de `console.log` en production
4. **Server Components first**
   * Préférer Server Component par défaut
   * `'use client'` uniquement quand nécessaire

---

## 🔒 8. Sécurité & données

1. **RLS obligatoire**
   * Toute table Supabase doit avoir des policies
   * Jamais de `service_role` côté client
2. **Middleware de sécurité**
   * Vérifie les permissions pour `/tools/*`
   * Redirige vers `/login` si non authentifié
3. **Env & secrets**
   * `.env.local` jamais commité
   * Variables validées avec Zod si possible

---

## 🧭 9. Ajout d'un nouveau Tool - Checklist rapide

### Préparation (5 min)

* [ ] Créer le dossier `packages/tools/mon-tool/`
* [ ] Créer `package.json` minimal
* [ ] Créer `src/index.tsx` avec composant test
* [ ] Ajouter exports dans `pnpm-workspace.yaml` si besoin

### Installation (5 min)

* [ ] `pnpm install` à la racine
* [ ] `cd apps/admin && pnpm add @repo/tools-mon-tool@workspace:*`
* [ ] Ajouter dans `transpilePackages` de next.config.ts

### Intégration (10 min)

* [ ] Créer `apps/admin/app/(tools)/mon-tool/page.tsx`
* [ ] Importer et utiliser le composant
* [ ] Tester dans le navigateur (`/mon-tool`)

### Vérification finale

* [ ] `pnpm type-check` → OK
* [ ] `pnpm lint` → OK
* [ ] `pnpm build` → OK
* [ ] Navigateur → composant s'affiche

**Total : ~20 minutes pour un tool basique**

---

## 🧩 10. Stratégie de tests

| Niveau       | Outil                 | Objectif                                 |
| ------------ | --------------------- | ---------------------------------------- |
| Unitaire     | Vitest                | Vérifier les hooks et API isolés       |
| Intégration | React Testing Library | Vérifier la cohérence UI + logique     |
| E2E          | Playwright            | Tester les parcours utilisateur complets |
| Typecheck    | TypeScript            | Vérifier les types partagés            |

### Bonnes pratiques :

* Un test = une responsabilité
* Nommer les fichiers `.test.ts` ou `.spec.tsx`
* Placer les tests à côté du code : `src/__tests__/`

---

## 🔄 11. Pull Requests & Review

1. **Ouvrir une PR par fonctionnalité**
   * `feature/tool-analytics-dashboard`
2. **Inclure un résumé clair**
   * Description
   * Impact
   * Étapes de test
3. **Checklist PR**
   * [ ] Lint OK
   * [ ] Typecheck OK
   * [ ] Tests passent
   * [ ] Screenshots (si UI)
4. **Review**
   * Au moins un reviewer
   * Aucune merge sans approbation

---

## 🧱 12. CI/CD (Turborepo + Vercel)

### Pipelines Turborepo

```json
{
  "pipeline": {
    "build": {
      "dependsOn": ["^build"],
      "outputs": [".next/**", "dist/**"]
    },
    "lint": {},
    "type-check": {},
    "test": {
      "outputs": ["coverage/**"]
    }
  }
}
```

### Intégration continue

* Lancement auto de `lint`, `test`, `type-check` sur chaque PR
* Prévisualisation Vercel par branche
* Build de production sur `main`

---

## 🐛 13. Debugging - Guide rapide

### Le composant ne s'affiche pas ("default export is not a React Component")

**PRIORITÉ 1 : Vérifier les layouts**

```powershell
# 1. Vérifier le layout du groupe
Get-Content "apps/admin/app/(tools)/layout.tsx"

# S'il est vide ou ne retourne rien → C'EST LE PROBLÈME
# Remplacer par :
$layout = @'
export default function Layout({ children }: { children: React.ReactNode }) {
  return <>{children}</>
}
'@
```

**PRIORITÉ 2 : Tester hors du groupe**

```powershell
# Créer une page de test à la racine
mkdir apps/admin/app/test-mon-tool
# Si ça marche là → Le problème vient du groupe (tools)
```

**PRIORITÉ 3 : Vérifier le package**

1. **Vérifier l'extension** : `.tsx` pour JSX, pas `.ts`
2. **Vérifier transpilePackages** : Tool ajouté dans next.config.ts ?
3. **Nettoyer le cache** : `rm -rf apps/admin/.next`

### Le composant ne s'affiche pas

1. **Vérifier le symlink** :
   ```bash
   ls -la apps/admin/node_modules/@repo/tools-xxx
   ```
2. **Vérifier l'export** : Composant bien exporté dans `index.ts` ?
3. **Vérifier l'import** : Import correct dans la page ?

### Erreur TypeScript

1. **Type-check le tool** :
   ```bash
   cd packages/tools/xxxpnpm type-check
   ```
2. **Régénérer les types Supabase** :
   ```bash
   cd packages/databasepnpm generate:types
   ```

---

## ✅ 14. Résumé des règles d'or

| Domaine                | Règle                                          |
| ---------------------- | ----------------------------------------------- |
| **Architecture** | Isoler le métier par tool, mutualiser le reste |
| **Extensions**   | `.tsx`pour JSX,`.ts`pour logic pure         |
| **Installation** | `pnpm add @repo/xxx@workspace:*`OBLIGATOIRE   |
| **Next.js**      | Tool dans `transpilePackages`OBLIGATOIRE      |
| **UI**           | Utiliser exclusivement `@repo/ui`             |
| **Database**     | Client centralisé + RLS strict                 |
| **Tests**        | Unitaires sur API pure minimum                  |
| **Commits**      | Conventionnels et explicites                    |

---

## 📚 15. Documentation connexe

* **ARCHITECTURE-AJOUTER-TOOL.md** : Guide complet de création d'un tool
* **ARCHITECTURE-CIBLE.md** : Architecture finale du monorepo
* **ARCHITECTURE-MIGRATION.md** : Plan de migration
* **README.md** : Vue d'ensemble du projet

---

## 🎓 16. Ressources externes

* [Next.js 15 Documentation](https://nextjs.org/docs)
* [pnpm Workspaces](https://pnpm.io/workspaces)
* [Turborepo](https://turbo.build/repo/docs)
* [Vitest](https://vitest.dev/)
* [Supabase](https://supabase.com/docs)

---

## 📝 Changelog

* **2025-11-02** : Ajout section "Points critiques validés" + guide debugging
* **2025-10-29** : Version initiale du document

---

**Document validé et testé** ✅
