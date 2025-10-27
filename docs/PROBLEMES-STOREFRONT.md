# 🔧 PROBLÈMES À RÉSOUDRE - Monorepo Blanche Renaudin

**Date** : 26 octobre 2025

**Statut** : En cours de résolution

---

## ✅ CE QUI A ÉTÉ CORRIGÉ

### 1. **Architecture Package Database**

* ✅ Séparation Client/Serveur complète
* ✅ `@repo/database` → exports publics (safe)
* ✅ `@repo/database/server` → exports serveur (admin, stripe, stock)
* ✅ Types `Tables` et `Enums` correctement exportés
* ✅ `decrementStockForOrder` déplacé vers `/server`
* ✅ Variable d'environnement `SUPABASE_SERVICE_ROLE_KEY` corrigée

### 2. **TypeScript**

* ✅ Typecheck `packages/database` : 0 erreurs
* ✅ Typecheck `apps/storefront` : 0 erreurs
* ✅ Build réussi (50 secondes, 45 pages générées)

### 3. **Imports Corrigés**

* ✅ 6 fichiers API routes : `@repo/database/server`
* ✅ `app/search/page.tsx` : `ProductWithRelations`
* ✅ `packages/email` : `supabaseAdmin` depuis `/server`
* ✅ `packages/utils` : `supabaseAdmin` depuis `/server`
* ✅ Webhook Stripe : `decrementStockForOrder` depuis `/server`

---

## 🔴 PROBLÈMES CRITIQUES À RÉSOUDRE

### 1. **Stripe exporté publiquement** ⚠️ URGENT

**Symptôme** :

```
Missing STRIPE_SECRET_KEY at runtime
Error in ProductGridJacquemus.tsx (Client Component)
```

**Cause** :

* `packages/database/src/index.ts` exporte `export * from './stripe'`
* `stripe.ts` vérifie `STRIPE_SECRET_KEY` au chargement
* Les Client Components peuvent importer ce fichier → erreur runtime

**Solution** :

1. Retirer de `packages/database/src/index.ts` :
   ```typescript
   // ❌ RETIRER
   export * from './stripe'
   ```
2. Vérifier que `packages/database/src/server.ts` exporte déjà :
   ```typescript
   // ✅ Déjà présent
   export { stripe } from './stripe'
   ```
3. Trouver tous les fichiers qui importent `stripe` :
   ```powershell
   Get-ChildItem -Recurse -Include "*.ts","*.tsx" -Path "apps\storefront\app" | 
     Select-String "\bstripe\b" | 
     Where-Object { $_.Line -match "from.*@repo/database" } | 
     Select-Object -ExpandProperty Path -Unique
   ```
4. Corriger les imports :
   ```typescript
   // ❌ AVANT
   import { stripe } from '@repo/database'

   // ✅ APRÈS
   import { stripe } from '@repo/database/server'
   ```
5. Rebuild :
   ```powershell
   cd packages\database
   pnpm run build
   cd ..\..\apps\storefront
   Remove-Item -Recurse -Force .next
   pnpm dev
   ```

**Fichiers probablement concernés** :

* `app/api/checkout/create-session/route.tsx`
* `app/api/webhooks/stripe/route.ts`
* Tout autre fichier API utilisant Stripe

---

### 2. **CSS ne s'affiche pas correctement** 🎨 URGENT

**Symptômes** :

* Navigation (HeaderMinimal, FooterMinimal) sans style
* Titres des photos homepage ne s'affichent pas
* Page contact sans style
* Classes custom (`.text-hero`, `.text-section`, `.btn-primary`) ne fonctionnent pas

**Causes possibles** :

1. Tailwind ne trouve pas les fichiers à scanner
2. Cache Next.js corrompu
3. Fonts pas correctement appliquées

**Solution déjà tentée** :

```powershell
# Nettoyage cache
Remove-Item -Recurse -Force .next
Remove-Item -Recurse -Force node_modules\.cache

# Mise à jour tailwind.config.ts
content: [
  './app/**/*.{ts,tsx}',
  './components/**/*.{ts,tsx}',
  '../../packages/ui/src/components/**/*.{ts,tsx}',
]

# Redémarrage
pnpm dev
```

**Actions à faire** :

1. Vérifier dans la console navigateur (F12) :
   * Erreurs de chargement de fonts
   * Erreurs de CSS
   * Classes Tailwind appliquées ou non
2. Si les classes custom ne fonctionnent pas, vérifier que `globals.css` est bien importé dans `layout.tsx` :
   ```typescript
   import './globals.css' // ✅ Doit être présent
   ```
3. Tester une classe simple pour voir si Tailwind fonctionne :
   ```typescript
   <div className="bg-red-500 text-white p-4">Test</div>
   ```
4. Si Tailwind ne fonctionne pas du tout :
   ```powershell
   # Réinstaller les dépendances
   pnpm install

   # Rebuild tout le monorepo
   cd ..\..
   pnpm run build
   ```

**Diagnostic supplémentaire nécessaire** :

* Capture d'écran de la console navigateur
* Vérifier si les fonts sont chargées (onglet Network → Fonts)
* Inspecter un élément avec les devtools pour voir si les classes sont appliquées

---

## 🟡 PROBLÈMES NON-CRITIQUES

### 3. **Package Sanity** (erreurs TypeScript)

**Symptômes** :

```
error TS2307: Cannot find module 'sanity'
error TS2307: Cannot find module '@sanity/vision'
error TS7006: Parameter 'Rule' implicitly has an 'any' type
```

**Impact** :

* Build du package `@repo/sanity` échoue
* N'empêche PAS le build du storefront
* Pas bloquant pour le développement

**Solution** :

```powershell
cd packages\sanity

# Installer @types/node
pnpm install @types/node --save-dev

# Vérifier que sanity et @sanity/vision sont installés
pnpm install sanity @sanity/vision --save

# TypeCheck
pnpm exec tsc --noEmit
```

---

### 4. **Warnings react-hook-form**

**Symptômes** :

```
Attempted import error: 'FormProvider' is not exported from 'react-hook-form'
```

**Cause** :

* `packages/ui/src/components/form.tsx` utilise peut-être une ancienne API

**Solution** :

* Vérifier la version de `react-hook-form` dans `packages/ui/package.json`
* Mettre à jour si nécessaire :
  ```powershell
  cd packages\uipnpm update react-hook-form
  ```

---

### 5. **Warnings punycode deprecated**

**Symptômes** :

```
DeprecationWarning: The `punycode` module is deprecated
```

**Impact** : Aucun (warning Node.js)

**Solution** : Ignorer pour le moment (ne casse rien)

---

## 📋 CHECKLIST DE VÉRIFICATION

Avant de considérer le projet comme "résolu" :

### Build & TypeScript

* [ ] `pnpm run type-check` → 0 erreurs
* [ ] `pnpm run build` → succès
* [ ] Aucune erreur "SECURITY ERROR: supabaseAdmin"
* [ ] Aucune erreur "Missing STRIPE_SECRET_KEY"

### Fonctionnalités

* [ ] Homepage s'affiche correctement avec styles
* [ ] Navigation (header/footer) stylée correctement
* [ ] Page `/products/hauts` fonctionne
* [ ] Page `/contact` s'affiche correctement
* [ ] Panier fonctionne
* [ ] Pas d'erreurs dans la console navigateur

### Variables d'environnement

* [ ] `.env.local` contient toutes les variables nécessaires :
  ```bash
  NEXT_PUBLIC_SUPABASE_URL=...NEXT_PUBLIC_SUPABASE_ANON_KEY=...SUPABASE_SERVICE_ROLE_KEY=...  # ✅ Pas SUPABASE_SERVICE_KEYSTRIPE_SECRET_KEY=...STRIPE_PUBLISHABLE_KEY=...STRIPE_WEBHOOK_SECRET=...RESEND_API_KEY=...RESEND_FROM_EMAIL=...
  ```

---

## 🚀 ORDRE DE RÉSOLUTION RECOMMANDÉ

### Priorité 1 : Stripe (bloquant runtime)

1. Retirer `export * from './stripe'` de `index.ts`
2. Corriger les imports dans les API routes
3. Rebuild et tester

### Priorité 2 : CSS (UX critique)

1. Nettoyer les caches
2. Vérifier console navigateur
3. Tester avec une classe simple
4. Corriger `tailwind.config.ts` si nécessaire

### Priorité 3 : Package Sanity (non-bloquant)

1. Installer les dépendances manquantes
2. TypeCheck
3. Corriger les types `any` si nécessaire

---

## 📝 COMMANDES UTILES

### Diagnostic rapide

```powershell
# TypeCheck complet
cd "C:\Users\thoma\OneDrive\SONEAR_2025\blancherenaudin-monorepo"
pnpm run type-check

# Build complet
pnpm run build

# Nettoyage complet
cd apps\storefront
Remove-Item -Recurse -Force .next
Remove-Item -Recurse -Force node_modules\.cache
pnpm dev
```

### Recherche d'imports

```powershell
# Trouver tous les imports de stripe
Get-ChildItem -Recurse -Include "*.ts","*.tsx" -Path "apps\storefront" | 
  Select-String "stripe.*from.*@repo/database" | 
  Select-Object -ExpandProperty Path -Unique

# Trouver tous les imports de supabaseAdmin
Get-ChildItem -Recurse -Include "*.ts","*.tsx" -Path "apps\storefront" | 
  Select-String "supabaseAdmin.*from" | 
  Select-Object -ExpandProperty Path -Unique
```

---

## 📚 DOCUMENTATION DE RÉFÉRENCE

### Architecture actuelle

```
packages/database/
├── src/
│   ├── index.ts              # ✅ Exports publics (SANS admin, stripe)
│   ├── server.ts             # ✅ Exports serveur (admin, stripe, stock)
│   ├── client-admin.ts       # ⚠️ Check sécurité runtime
│   ├── client-browser.ts     # ✅ Client browser
│   ├── client-server.ts      # ✅ Client server
│   ├── stripe.ts             # ⚠️ Doit rester server-only
│   ├── types.ts              # ✅ Types de base
│   ├── types-helpers.ts      # ✅ Types avancés
│   └── stock/
│       └── decrement-stock.ts # ⚠️ Server-only (importe admin)
```

### Règles d'import

```typescript
// ✅ Dans Server Components / API Routes
import { supabaseAdmin, stripe, decrementStockForOrder } from '@repo/database/server'

// ✅ Dans Client Components
import { createBrowserClient, ProductWithRelations } from '@repo/database'

// ❌ JAMAIS dans Client Components
import { supabaseAdmin } from '@repo/database/server' // ERROR!
```

---

## 🎯 OBJECTIF FINAL

**Site fonctionnel avec :**

* ✅ Build sans erreurs
* ✅ Styles CSS appliqués correctement
* ✅ Pas d'erreurs runtime dans le navigateur
* ✅ Séparation client/serveur respectée
* ✅ Toutes les pages accessibles et stylées

**Une fois ces problèmes résolus, vous pourrez :**

1. Développer de nouvelles fonctionnalités sereinement
2. Déployer en production
3. Tester le système de paiement Stripe
4. Tester l'envoi d'emails

---

**Bon courage ! 💪**

*N'hésitez pas à revenir avec les résultats des commandes de diagnostic pour qu'on puisse avancer ensemble.*
