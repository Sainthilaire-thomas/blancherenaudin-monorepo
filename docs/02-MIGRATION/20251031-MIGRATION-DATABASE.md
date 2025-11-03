# 📊 État des lieux et Plan de Migration @repo/database

 **Date** : 31 octobre 2025

 **Commit actuel** : `04a523a` (27 oct - "mise a niveau en react 19")

 **Statut** : ✅ Build storefront réussi sur ce commit

---

## 🎯 Objectif

Migrer `@repo/database` vers l'architecture cible pour :

1. ✅ Éliminer les imports `/server`, `/client-server`, `/client-browser`, `/types`
2. ✅ Avoir un seul point d'entrée `@repo/database`
3. ✅ Structure conforme à l'architecture monorepo

---

## 📋 État actuel de storefront (commit 04a523a)

### Dépendances @repo/* déclarées (package.json)

json

```json
{
"@repo/analytics":"workspace:*",// ⚠️ N'existe plus (maintenant @repo/tools-analytics)
"@repo/auth":"workspace:*",// ✅
"@repo/database":"workspace:*",// ✅
"@repo/email":"workspace:*",// ✅
"@repo/sanity":"workspace:*",// ✅
"@repo/ui":"workspace:*",// ✅
"@repo/utils":"workspace:*"// ✅
}
```

### Imports @repo/database dans le code

**5 patterns différents trouvés** :

<pre class="font-ui border-border-100/50 overflow-x-scroll w-full rounded border-[0.5px] shadow-[0_2px_12px_hsl(var(--always-black)/5%)]"><table class="bg-bg-100 min-w-full border-separate border-spacing-0 text-sm leading-[1.88888] whitespace-normal"><thead class="border-b-border-100/50 border-b-[0.5px] text-left"><tr class="[tbody>&]:odd:bg-bg-500/10"><th class="text-text-000 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] px-2 [&:not(:first-child)]:border-l-[0.5px]">Pattern</th><th class="text-text-000 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] px-2 [&:not(:first-child)]:border-l-[0.5px]">Fichiers</th><th class="text-text-000 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] px-2 [&:not(:first-child)]:border-l-[0.5px]">Statut</th></tr></thead><tbody><tr class="[tbody>&]:odd:bg-bg-500/10"><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]"><code class="bg-text-200/5 border border-0.5 border-border-300 text-danger-000 whitespace-pre-wrap rounded-[0.4rem] px-1 py-px text-[0.9rem]">@repo/database/server</code></td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">15 fichiers</td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">❌ À supprimer</td></tr><tr class="[tbody>&]:odd:bg-bg-500/10"><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]"><code class="bg-text-200/5 border border-0.5 border-border-300 text-danger-000 whitespace-pre-wrap rounded-[0.4rem] px-1 py-px text-[0.9rem]">@repo/database/client-server</code></td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">11 fichiers</td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">❌ À supprimer</td></tr><tr class="[tbody>&]:odd:bg-bg-500/10"><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]"><code class="bg-text-200/5 border border-0.5 border-border-300 text-danger-000 whitespace-pre-wrap rounded-[0.4rem] px-1 py-px text-[0.9rem]">@repo/database/client-browser</code></td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">2 fichiers</td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">❌ À supprimer</td></tr><tr class="[tbody>&]:odd:bg-bg-500/10"><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]"><code class="bg-text-200/5 border border-0.5 border-border-300 text-danger-000 whitespace-pre-wrap rounded-[0.4rem] px-1 py-px text-[0.9rem]">@repo/database/types</code></td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">4 fichiers</td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">❌ À supprimer</td></tr><tr class="[tbody>&]:odd:bg-bg-500/10"><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]"><code class="bg-text-200/5 border border-0.5 border-border-300 text-danger-000 whitespace-pre-wrap rounded-[0.4rem] px-1 py-px text-[0.9rem]">@repo/database</code></td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">9 fichiers</td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">✅ Correct</td></tr></tbody></table></pre>

#### Détail des fichiers par pattern

**`@repo/database/server` (15 fichiers) :**

* `app/account/orders/page.tsx`
* `app/api/auth/ensure-profile/route.ts`
* `app/api/checkout/create-session/route.tsx`
* `app/api/checkout/route.ts`
* `app/api/newsletter/confirm/route.ts`
* `app/api/newsletter/subscribe/route.ts`
* `app/api/webhooks/stripe/resend/route.tsx`
* `app/api/webhooks/stripe/route.ts`
* `app/api/wishlist/route.ts`

**`@repo/database/client-server` (11 fichiers) :**

* `app/account/settings/change-password/page.tsx`
* `app/account/settings/page.tsx`
* `app/account/wishlist/page.tsx`
* `app/account/layout.tsx`
* `app/account/page.tsx`
* `app/api/auth/change-password/route.tsx`
* `app/api/collections/route.ts`
* `app/api/products/by-ids/route.ts`
* `app/api/products/route.ts`
* `app/api/wishlist/route.ts`

**`@repo/database/client-browser` (2 fichiers) :**

* `app/auth/login/page.tsx`
* `app/search/page.tsx`

**`@repo/database/types` (4 fichiers) :**

* `app/account/wishlist/WishlistClient.tsx`
* `app/api/auth/ensure-profile/route.ts`
* `app/api/auth/logout/route.ts`
* `app/api/logout/route.tsx`

**`@repo/database` (9 fichiers - ✅ correct) :**

* `app/checkout/success/CheckoutSuccessContent.tsx`
* `app/products/ProductCardClient.tsx`
* `app/search/page.tsx`
* `components/products/ProductGridJacquemus.tsx`
* `lib/product-helpers.ts`
* `lib/products.ts`
* `lib/types.ts`
* `store/useAuthStore.ts`
* `store/useCollectionStore.ts`
* `store/useProductStore.ts`
* `store/useWishListStore.ts`
* `next.config.ts`

---

## 🗂️ Structure actuelle @repo/database

```
packages/database/
├── src/
│   ├── client-admin.ts          ❌ Devrait être dans clients/
│   ├── client-browser.ts        ❌ Devrait être dans clients/
│   ├── client-server.ts         ❌ Devrait être dans clients/
│   ├── database.types.ts        ❌ Devrait être dans types/
│   ├── index.ts                 ⚠️ Exports incomplets
│   ├── server.ts                ❌ À supprimer (doublon)
│   ├── stripe.ts                ❌ Ne devrait pas être ici
│   ├── types-helpers.ts         ❌ Devrait être dans utils/
│   ├── types.ts                 ❌ Devrait être dans types/
│   └── stock/
│       └── decrement-stock.ts   ✅ OK
├── package.json
└── tsconfig.json
```

### Exports actuels (index.ts) - INCOMPLETS

typescript

```typescript
// EXPORTS DE BASE (depuis types.ts)
export*from"./types"

// EXPORTS CLIENTS SUPABASE (SAFE - Sans Admin)
export{ createBrowserClient }from"./client-browser"
export{ getServerSupabase, createServerClient }from"./client-server"

// ❌ Admin client commenté
// export { supabaseAdmin } from "./client-admin"

// ❌ Stock management commenté
// export * from './stock/decrement-stock'

// EXPORTS HELPERS
exporttype{ApiResponseUnionasApiResponseHelper}from'./types-helpers'
export{ getCategoryWithChildren }from'./types-helpers'
```

**Problèmes identifiés :**

1. ❌ Pas d'export des types Database
2. ❌ Pas d'export du createAdminClient
3. ❌ Pas d'export du stock management
4. ❌ Structure des fichiers non conforme

---

## 🎯 Architecture CIBLE (selon ARCHITECTURE-CIBLE.md)

```
packages/database/
├── src/
│   ├── clients/
│   │   ├── client-browser.ts       # Client navigateur
│   │   ├── client-server.ts        # Client serveur (cookies)
│   │   └── client-admin.ts         # Service role
│   ├── types/
│   │   ├── database.types.ts       # Généré par Supabase
│   │   ├── custom.types.ts         # Types métier custom
│   │   └── index.ts                # Export des types
│   ├── utils/
│   │   ├── types-helpers.ts        # Helpers types
│   │   └── query-helpers.ts        # Helpers queries (futur)
│   ├── stock/
│   │   └── decrement-stock.ts      # Gestion stock
│   └── index.ts                    # ✅ Point d'entrée UNIQUE
├── scripts/
│   └── generate-types.ts           # Script génération types
├── package.json
└── tsconfig.json
```

### Exports CIBLE (index.ts)

typescript

```typescript
// === CLIENT EXPORTS ===
export{ createBrowserClient }from'./clients/client-browser'
export{ createServerClient }from'./clients/client-server'
export{ createAdminClient }from'./clients/client-admin'

// === TYPES ===
export*from'./types'
exporttype{Database}from'./types/database.types'

// === UTILS ===
export*from'./utils/types-helpers'

// === STOCK MANAGEMENT ===
export{ decrementStockForOrder }from'./stock/decrement-stock'
exporttype{StockDecrementResult}from'./stock/decrement-stock'
```

### Imports CIBLE dans storefront

**Avant (❌) :**

typescript

```typescript
import{ getServerSupabase }from'@repo/database/server'
import{ createServerClient }from'@repo/database/client-server'
import{ createBrowserClient }from'@repo/database/client-browser'
importtype{Database}from'@repo/database/types'
```

**Après (✅) :**

typescript

```typescript
import{ createServerClient, createAdminClient }from'@repo/database'
import{ createBrowserClient }from'@repo/database'
importtype{Database}from'@repo/database'
```

---

## 📝 Plan de migration en 4 étapes

### ✅ ÉTAPE 0 : Backup et documentation (FAIT)

* [X] Commit actuel sauvegardé: `4b3a489`
* [X] Build storefront fonctionnel sur `04a523a`
* [X] Audit complet des imports réalisé
* [X] Documentation de l'état actuel

### 🔄 ÉTAPE 1 : Réorganiser @repo/database

**1.1. Créer la nouvelle structure**

powershell

```powershell
# Créer les dossiers
New-Item-ItemType Directory -Path "packages\database\src\clients"-Force
New-Item-ItemType Directory -Path "packages\database\src\types"-Force
New-Item-ItemType Directory -Path "packages\database\src\utils"-Force
```

**1.2. Déplacer les fichiers**

powershell

```powershell
# Clients
Move-Item"packages\database\src\client-browser.ts""packages\database\src\clients\client-browser.ts"
Move-Item"packages\database\src\client-server.ts""packages\database\src\clients\client-server.ts"
Move-Item"packages\database\src\client-admin.ts""packages\database\src\clients\client-admin.ts"

# Types
Move-Item"packages\database\src\database.types.ts""packages\database\src\types\database.types.ts"
Move-Item"packages\database\src\types.ts""packages\database\src\types\custom.types.ts"

# Utils
Move-Item"packages\database\src\types-helpers.ts""packages\database\src\utils\types-helpers.ts"

# Supprimer les doublons
Remove-Item"packages\database\src\server.ts"-Force
Remove-Item"packages\database\src\stripe.ts"-Force
```

**1.3. Créer types/index.ts**

typescript

```typescript
// packages/database/src/types/index.ts
export*from'./database.types'
export*from'./custom.types'
```

**1.4. Réécrire index.ts**

typescript

```typescript
// packages/database/src/index.ts

// === CLIENT EXPORTS ===
export{ createBrowserClient, supabaseBrowser }from'./clients/client-browser'
export{ createServerClient, getServerSupabase }from'./clients/client-server'
export{ createAdminClient }from'./clients/client-admin'

// === TYPES ===
export*from'./types'
exporttype{Database}from'./types/database.types'

// === UTILS ===
export*from'./utils/types-helpers'

// === STOCK MANAGEMENT ===
export{ decrementStockForOrder }from'./stock/decrement-stock'
exporttype{StockDecrementResult}from'./stock/decrement-stock'
```

**1.5. Corriger les imports internes**

Les fichiers dans `clients/`, `types/`, `utils/` devront ajuster leurs imports relatifs :

* `../types/database.types` au lieu de `./database.types`
* etc.

### 🔄 ÉTAPE 2 : Corriger les imports dans storefront

**Script de remplacement automatique :**

powershell

```powershell
Get-ChildItem-Path apps\storefront -Include "*.ts","*.tsx"-Recurse -ErrorAction SilentlyContinue |
Where-Object{$_.FullName -notmatch"node_modules|\.next"}|
ForEach-Object{
$content = Get-Content$_.FullName -Raw -ErrorAction SilentlyContinue
if($content-match"@repo/database/(server|client-server|client-browser|types)"){
$content = $content-replace"@repo/database/server","@repo/database"
$content = $content-replace"@repo/database/client-server","@repo/database"
$content = $content-replace"@repo/database/client-browser","@repo/database"
$content = $content-replace"@repo/database/types","@repo/database"
Set-Content-Path $_.FullName -Value $content
Write-Host"✅ Corrigé: $($_.Name)"-ForegroundColor Green
}
}
```

### 🧪 ÉTAPE 3 : Tests et validation

powershell

```powershell
# 1. Vérifier la compilation du package
cd packages\database
pnpm type-check

# 2. Build storefront
cd ..\..
pnpm --filter storefront build

# 3. Lancer en dev pour tester
pnpm --filter storefront dev
```

### ✅ ÉTAPE 4 : Commit et documentation

powershell

```powershell
git add .
git commit -m "refactor(database): align package structure with target architecture

- Reorganize into clients/, types/, utils/ folders
- Create single entry point in index.ts
- Remove /server, /client-server, /client-browser sub-imports
- Update all storefront imports to use @repo/database directly
- Add proper exports for types, clients, and stock management

BREAKING CHANGE: @repo/database sub-paths removed, use direct imports"
```

---

## 🎯 Points d'attention

### Risques identifiés

1. **Imports cassés temporairement** : Entre l'étape 1 et 2, les imports seront cassés
2. **Tests** : Pas de tests unitaires actuellement sur @repo/database
3. **Admin** : Admin utilise-t-il aussi @repo/database ? À vérifier

### Stratégie de rollback

Si problème après migration :

powershell

```powershell
git checkout 04a523a -- packages/database apps/storefront
pnpm install
```

---

## 📊 Métriques de succès

* [ ] Structure @repo/database conforme à l'architecture cible
* [ ] Aucun import `@repo/database/xxx` dans storefront
* [ ] Build storefront réussi
* [ ] Dev storefront fonctionnel
* [ ] Tous les clients Supabase accessibles via `@repo/database`
* [ ] Types Database exportés correctement

---

## 🚀 Prochaines étapes après migration database

1. **Supprimer @repo/analytics** du package.json storefront (obsolète)
2. **Auditer les autres packages** (@repo/email, @repo/utils, @repo/auth)
3. **Vérifier admin** : Faire le même audit pour l'app admin
4. **Documentation** : Mettre à jour les docs avec la nouvelle structure

---

 **Document généré le** : 31 octobre 2025 19:30

 **Auteur** : Migration @repo/database

 **Statut** : 📋 Plan validé, prêt pour exécution
