# 📋 Documentation de Vérification - Migration Storefront

## 🎯 PROBLÈME À RÉSOUDRE

Après migration vers l'architecture monorepo (Phase 5), le site storefront présente deux problèmes majeurs :

### 1. **Erreur 404 sur les routes**

* URL testée : `localhost:3000/products/bas`
* Erreur : "404 - This page could not be found"
* **Cause** : Les routes de l'ancien projet n'ont pas été migrées

### 2. **Styles CSS non appliqués**

* Header et Footer invisibles ou mal affichés
* Comparaison : `localhost:3000` ≠ `blancherenaudin.com`
* **Cause probable** : Configuration Tailwind incomplète ou imports manquants

---

## 📊 ÉTAT DES LIEUX

### Structure actuelle (d'après arborescence)

**apps/storefront/app/** contient seulement :

* ✅ `globals.css`
* ✅ `layout.tsx`
* ✅ `page.tsx`

**Il MANQUE tous les dossiers de routes** :

* ❌ `products/`
* ❌ `collections/`
* ❌ `product/`
* ❌ `cart/`
* ❌ `checkout/`
* ❌ `account/`
* ❌ `api/`
* ❌ `contact/`, `about/`, `search/`, `impact/`, etc.

---

## 📋 PLAN D'ACTION DE VÉRIFICATION

### Phase 1 : Vérifier la configuration existante

### Phase 2 : Identifier les routes manquantes

### Phase 3 : Comparer les fichiers de config avec l'ancien projet

### Phase 4 : Migrer les routes manquantes

### Phase 5 : Corriger les imports

### Phase 6 : Tester et valider

---

## 🔍 PHASE 1 : VÉRIFICATION DE LA CONFIGURATION EXISTANTE

### 1.1 Vérifier `tailwind.config.ts`

**Fichier** : `apps/storefront/tailwind.config.ts`

**Commande** :

powershell

```powershell
Get-Content apps\storefront\tailwind.config.ts
```

**Points à vérifier** :

✅ **Le tableau `content` doit inclure** :

typescript

```typescript
content:[
'./app/**/*.{js,ts,jsx,tsx,mdx}',
'./components/**/*.{js,ts,jsx,tsx,mdx}',
'../../packages/ui/src/**/*.{js,ts,jsx,tsx}',// ← CRITIQUE
],
```

✅ **Les fonts doivent être définies** :

typescript

```typescript
theme:{
  extend:{
    fontFamily:{
'archivo-black':['Archivo Black','sans-serif'],
'archivo-narrow':['Archivo Narrow','sans-serif'],
},
}
}
```

✅ **La couleur violet doit être définie** :

typescript

```typescript
colors:{
  violet:'hsl(271, 74%, 37%)',
}
```

**❌ Problème si** :

* Le chemin `../../packages/ui/src/**` est absent
* Les fonts ne sont pas définies
* La couleur violet est absente

---

### 1.2 Vérifier `globals.css`

**Fichier** : `apps/storefront/app/globals.css`

**Commande** :

powershell

```powershell
Get-Content apps\storefront\app\globals.css |Select-Object-First 30
```

**Points à vérifier** :

✅ **Les directives Tailwind doivent être présentes** :

css

```css
@tailwind base;
@tailwind components;
@tailwind utilities;
```

✅ **L'import des fonts Google** :

css

```css
@importurl('https://fonts.googleapis.com/css2?family=Archivo+Black&family=Archivo+Narrow:wght@400;500;600;700&display=swap');
```

✅ **Les variables CSS** :

css

```css
:root{
--violet:27174%37%;
--black:00%0%;
--white:00%100%;
--grey-light:00%95%;
--grey-medium:00%50%;
--grey-dark:00%20%;
}
```

✅ **Le reset CSS de base** :

css

```css
*{
box-sizing: border-box;
padding:0;
margin:0;
}
```

**❌ Problème si** :

* Les directives `@tailwind` sont absentes
* Les fonts ne sont pas importées
* Les variables CSS sont manquantes

---

### 1.3 Vérifier `layout.tsx`

**Fichier** : `apps/storefront/app/layout.tsx`

**Commande** :

powershell

```powershell
Get-Content apps\storefront\app\layout.tsx
```

**Points à vérifier** :

✅ **L'import de globals.css EN PREMIER** :

tsx

```tsx
import'./globals.css'// ← Doit être la PREMIÈRE ligne d'import
```

✅ **La classe de font sur le body** :

tsx

```tsx
<bodyclassName="font-archivo-narrow">
```

✅ **Les Providers nécessaires** (si présents dans l'ancien) :

tsx

```tsx
// Exemples de providers à vérifier
<AuthProvider>
<CartProvider>
<ToastProvider>
```

**❌ Problème si** :

* `globals.css` n'est pas importé
* La classe `font-archivo-narrow` est absente
* Des Providers manquent

---

### 1.4 Vérifier `postcss.config.mjs`

**Fichier** : `apps/storefront/postcss.config.mjs`

**Commande** :

powershell

```powershell
Get-Content apps\storefront\postcss.config.mjs
```

**Contenu attendu** :

javascript

```javascript
exportdefault{
plugins:{
tailwindcss:{},
autoprefixer:{},
},
}
```

**❌ Problème si** :

* Le fichier n'existe pas
* Les plugins `tailwindcss` et `autoprefixer` sont absents

---

## 🔍 PHASE 2 : IDENTIFIER LES ROUTES MANQUANTES

### 2.1 Lister les routes actuelles

**Commande** :

powershell

```powershell
Get-ChildItem-Path apps\storefront\app\ -Directory |Select-Object Name
```

**Résultat attendu** : Seulement quelques dossiers ou aucun

---

### 2.2 Lister les routes de l'ancien projet

**Commande** (adapter le chemin) :

powershell

```powershell
Get-ChildItem-Path C:\chemin\vers\site_v1_next\src\app\ -Directory |Select-Object Name
```

**Routes attendues dans l'ancien projet** :

* `products/`
* `collections/`
* `product/`
* `cart/`
* `checkout/`
* `account/`
* `api/`
* `contact/`
* `about/`
* `search/`
* `impact/`
* `lookbooks/`
* `silhouettes/`
* `collections-editoriales/`
* `auth/` (peut-être)
* `studio/` (Sanity)

---

### 2.3 Comparer les deux listes

**Créer une checklist** :

<pre class="font-ui border-border-100/50 overflow-x-scroll w-full rounded border-[0.5px] shadow-[0_2px_12px_hsl(var(--always-black)/5%)]"><table class="bg-bg-100 min-w-full border-separate border-spacing-0 text-sm leading-[1.88888] whitespace-normal"><thead class="border-b-border-100/50 border-b-[0.5px] text-left"><tr class="[tbody>&]:odd:bg-bg-500/10"><th class="text-text-000 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] px-2 [&:not(:first-child)]:border-l-[0.5px]">Route</th><th class="text-text-000 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] px-2 [&:not(:first-child)]:border-l-[0.5px]">Ancien projet</th><th class="text-text-000 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] px-2 [&:not(:first-child)]:border-l-[0.5px]">Nouveau projet</th><th class="text-text-000 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] px-2 [&:not(:first-child)]:border-l-[0.5px]">À migrer</th></tr></thead><tbody><tr class="[tbody>&]:odd:bg-bg-500/10"><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]"><code class="bg-text-200/5 border border-0.5 border-border-300 text-danger-000 whitespace-pre-wrap rounded-[0.4rem] px-1 py-px text-[0.9rem]">products/</code></td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">✅</td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">❌</td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">✅</td></tr><tr class="[tbody>&]:odd:bg-bg-500/10"><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]"><code class="bg-text-200/5 border border-0.5 border-border-300 text-danger-000 whitespace-pre-wrap rounded-[0.4rem] px-1 py-px text-[0.9rem]">collections/</code></td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">✅</td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">❌</td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">✅</td></tr><tr class="[tbody>&]:odd:bg-bg-500/10"><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]"><code class="bg-text-200/5 border border-0.5 border-border-300 text-danger-000 whitespace-pre-wrap rounded-[0.4rem] px-1 py-px text-[0.9rem]">product/</code></td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">✅</td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">❌</td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">✅</td></tr><tr class="[tbody>&]:odd:bg-bg-500/10"><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]"><code class="bg-text-200/5 border border-0.5 border-border-300 text-danger-000 whitespace-pre-wrap rounded-[0.4rem] px-1 py-px text-[0.9rem]">cart/</code></td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">✅</td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">❌</td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">✅</td></tr><tr class="[tbody>&]:odd:bg-bg-500/10"><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]"><code class="bg-text-200/5 border border-0.5 border-border-300 text-danger-000 whitespace-pre-wrap rounded-[0.4rem] px-1 py-px text-[0.9rem]">checkout/</code></td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">✅</td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">❌</td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">✅</td></tr><tr class="[tbody>&]:odd:bg-bg-500/10"><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]"><code class="bg-text-200/5 border border-0.5 border-border-300 text-danger-000 whitespace-pre-wrap rounded-[0.4rem] px-1 py-px text-[0.9rem]">account/</code></td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">✅</td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">❌</td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">✅</td></tr><tr class="[tbody>&]:odd:bg-bg-500/10"><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]"><code class="bg-text-200/5 border border-0.5 border-border-300 text-danger-000 whitespace-pre-wrap rounded-[0.4rem] px-1 py-px text-[0.9rem]">api/</code></td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">✅</td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">❌</td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">✅</td></tr><tr class="[tbody>&]:odd:bg-bg-500/10"><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]"><code class="bg-text-200/5 border border-0.5 border-border-300 text-danger-000 whitespace-pre-wrap rounded-[0.4rem] px-1 py-px text-[0.9rem]">contact/</code></td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">✅</td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">❌</td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">✅</td></tr><tr class="[tbody>&]:odd:bg-bg-500/10"><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]"><code class="bg-text-200/5 border border-0.5 border-border-300 text-danger-000 whitespace-pre-wrap rounded-[0.4rem] px-1 py-px text-[0.9rem]">about/</code></td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">✅</td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">❌</td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">✅</td></tr><tr class="[tbody>&]:odd:bg-bg-500/10"><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]"><code class="bg-text-200/5 border border-0.5 border-border-300 text-danger-000 whitespace-pre-wrap rounded-[0.4rem] px-1 py-px text-[0.9rem]">search/</code></td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">✅</td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">❌</td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">✅</td></tr><tr class="[tbody>&]:odd:bg-bg-500/10"><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]"><code class="bg-text-200/5 border border-0.5 border-border-300 text-danger-000 whitespace-pre-wrap rounded-[0.4rem] px-1 py-px text-[0.9rem]">impact/</code></td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">✅</td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">❌</td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">✅</td></tr><tr class="[tbody>&]:odd:bg-bg-500/10"><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]"><code class="bg-text-200/5 border border-0.5 border-border-300 text-danger-000 whitespace-pre-wrap rounded-[0.4rem] px-1 py-px text-[0.9rem]">lookbooks/</code></td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">✅</td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">❌</td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">✅</td></tr><tr class="[tbody>&]:odd:bg-bg-500/10"><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]"><code class="bg-text-200/5 border border-0.5 border-border-300 text-danger-000 whitespace-pre-wrap rounded-[0.4rem] px-1 py-px text-[0.9rem]">silhouettes/</code></td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">✅</td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">❌</td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">✅</td></tr><tr class="[tbody>&]:odd:bg-bg-500/10"><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]"><code class="bg-text-200/5 border border-0.5 border-border-300 text-danger-000 whitespace-pre-wrap rounded-[0.4rem] px-1 py-px text-[0.9rem]">collections-editoriales/</code></td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">✅</td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">❌</td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">✅</td></tr></tbody></table></pre>

---

## 🔍 PHASE 3 : COMPARER LES FICHIERS DE CONFIG

### 3.1 Comparer les `tailwind.config.ts`

**Commandes** :

powershell

```powershell
# Ancien projet
Get-Content C:\chemin\vers\site_v1_next\tailwind.config.ts

# Nouveau projet
Get-Content apps\storefront\tailwind.config.ts
```

**Comparer manuellement** :

* Les paths dans `content[]`
* Les extensions dans `theme.extend`
* Les plugins

---

### 3.2 Comparer les `globals.css`

**Commandes** :

powershell

```powershell
# Ancien projet
Get-Content C:\chemin\vers\site_v1_next\src\app\globals.css

# Nouveau projet
Get-Content apps\storefront\app\globals.css
```

**Comparer** :

* Les imports de fonts
* Les variables CSS
* Les styles de base

---

### 3.3 Comparer les `package.json`

**Commandes** :

powershell

```powershell
# Ancien projet - dépendances
Get-Content C:\chemin\vers\site_v1_next\package.json |Select-String-Pattern "dependencies"-Context 0,20

# Nouveau projet - dépendances
Get-Content apps\storefront\package.json |Select-String-Pattern "dependencies"-Context 0,20
```

**Vérifier que ces packages sont présents** :

* `next` (même version si possible)
* `react`, `react-dom`
* `tailwindcss`
* `@radix-ui/*` (si utilisés)
* `lucide-react`
* `zustand`
* `@repo/ui` (package workspace)
* `@repo/database` (package workspace)

---

## 🔍 PHASE 4 : MIGRER LES ROUTES MANQUANTES

### 4.1 Copier les routes une par une

**Template de commande** :

powershell

```powershell
Copy-Item-Path "C:\chemin\vers\site_v1_next\src\app\NOM_ROUTE"-Destination "apps\storefront\app\"-Recurse -Force
```

**Exemple pour chaque route** :

powershell

```powershell
# Products
Copy-Item-Path "C:\chemin\vers\site_v1_next\src\app\products"-Destination "apps\storefront\app\"-Recurse -Force

# Collections
Copy-Item-Path "C:\chemin\vers\site_v1_next\src\app\collections"-Destination "apps\storefront\app\"-Recurse -Force

# Product (détail)
Copy-Item-Path "C:\chemin\vers\site_v1_next\src\app\product"-Destination "apps\storefront\app\"-Recurse -Force

# Cart
Copy-Item-Path "C:\chemin\vers\site_v1_next\src\app\cart"-Destination "apps\storefront\app\"-Recurse -Force

# Checkout
Copy-Item-Path "C:\chemin\vers\site_v1_next\src\app\checkout"-Destination "apps\storefront\app\"-Recurse -Force

# Account
Copy-Item-Path "C:\chemin\vers\site_v1_next\src\app\account"-Destination "apps\storefront\app\"-Recurse -Force

# API routes
Copy-Item-Path "C:\chemin\vers\site_v1_next\src\app\api"-Destination "apps\storefront\app\"-Recurse -Force

# Pages statiques
Copy-Item-Path "C:\chemin\vers\site_v1_next\src\app\contact"-Destination "apps\storefront\app\"-Recurse -Force
Copy-Item-Path "C:\chemin\vers\site_v1_next\src\app\about"-Destination "apps\storefront\app\"-Recurse -Force
Copy-Item-Path "C:\chemin\vers\site_v1_next\src\app\search"-Destination "apps\storefront\app\"-Recurse -Force
Copy-Item-Path "C:\chemin\vers\site_v1_next\src\app\impact"-Destination "apps\storefront\app\"-Recurse -Force

# Lookbooks et collections éditoriales
Copy-Item-Path "C:\chemin\vers\site_v1_next\src\app\lookbooks"-Destination "apps\storefront\app\"-Recurse -Force
Copy-Item-Path "C:\chemin\vers\site_v1_next\src\app\silhouettes"-Destination "apps\storefront\app\"-Recurse -Force
Copy-Item-Path "C:\chemin\vers\site_v1_next\src\app\collections-editoriales"-Destination "apps\storefront\app\"-Recurse -Force
```

---

### 4.2 Vérifier que les routes sont copiées

**Commande** :

powershell

```powershell
Get-ChildItem-Path apps\storefront\app\ -Directory |Select-Object Name
```

**Résultat attendu** : Tous les dossiers de routes doivent apparaître

---

## 🔍 PHASE 5 : CORRIGER LES IMPORTS

### 5.1 Comprendre les changements d'imports

Dans l'architecture monorepo, les imports changent :

**AVANT (ancien projet)** :

tsx

```tsx
import{Button}from'@/components/ui/button'
import{ supabaseBrowser }from'@/lib/supabase-browser'
import{ sanityClient }from'@/lib/sanity.client'
import{ sendEmail }from'@/lib/email/send'
```

**APRÈS (monorepo)** :

tsx

```tsx
import{Button}from'@repo/ui'
import{ supabaseBrowser }from'@repo/database'
import{ sanityClient }from'@repo/sanity'
import{ sendEmail }from'@repo/email'
```

---

### 5.2 Tableau de correspondance des imports

<pre class="font-ui border-border-100/50 overflow-x-scroll w-full rounded border-[0.5px] shadow-[0_2px_12px_hsl(var(--always-black)/5%)]"><table class="bg-bg-100 min-w-full border-separate border-spacing-0 text-sm leading-[1.88888] whitespace-normal"><thead class="border-b-border-100/50 border-b-[0.5px] text-left"><tr class="[tbody>&]:odd:bg-bg-500/10"><th class="text-text-000 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] px-2 [&:not(:first-child)]:border-l-[0.5px]">Ancien import</th><th class="text-text-000 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] px-2 [&:not(:first-child)]:border-l-[0.5px]">Nouvel import</th><th class="text-text-000 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] px-2 [&:not(:first-child)]:border-l-[0.5px]">Package concerné</th></tr></thead><tbody><tr class="[tbody>&]:odd:bg-bg-500/10"><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]"><code class="bg-text-200/5 border border-0.5 border-border-300 text-danger-000 whitespace-pre-wrap rounded-[0.4rem] px-1 py-px text-[0.9rem]">@/components/ui/*</code></td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]"><code class="bg-text-200/5 border border-0.5 border-border-300 text-danger-000 whitespace-pre-wrap rounded-[0.4rem] px-1 py-px text-[0.9rem]">@repo/ui</code></td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]"><code class="bg-text-200/5 border border-0.5 border-border-300 text-danger-000 whitespace-pre-wrap rounded-[0.4rem] px-1 py-px text-[0.9rem]">packages/ui</code></td></tr><tr class="[tbody>&]:odd:bg-bg-500/10"><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]"><code class="bg-text-200/5 border border-0.5 border-border-300 text-danger-000 whitespace-pre-wrap rounded-[0.4rem] px-1 py-px text-[0.9rem]">@/lib/supabase*</code></td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]"><code class="bg-text-200/5 border border-0.5 border-border-300 text-danger-000 whitespace-pre-wrap rounded-[0.4rem] px-1 py-px text-[0.9rem]">@repo/database</code></td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]"><code class="bg-text-200/5 border border-0.5 border-border-300 text-danger-000 whitespace-pre-wrap rounded-[0.4rem] px-1 py-px text-[0.9rem]">packages/database</code></td></tr><tr class="[tbody>&]:odd:bg-bg-500/10"><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]"><code class="bg-text-200/5 border border-0.5 border-border-300 text-danger-000 whitespace-pre-wrap rounded-[0.4rem] px-1 py-px text-[0.9rem]">@/lib/sanity*</code></td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]"><code class="bg-text-200/5 border border-0.5 border-border-300 text-danger-000 whitespace-pre-wrap rounded-[0.4rem] px-1 py-px text-[0.9rem]">@repo/sanity</code></td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]"><code class="bg-text-200/5 border border-0.5 border-border-300 text-danger-000 whitespace-pre-wrap rounded-[0.4rem] px-1 py-px text-[0.9rem]">packages/sanity</code></td></tr><tr class="[tbody>&]:odd:bg-bg-500/10"><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]"><code class="bg-text-200/5 border border-0.5 border-border-300 text-danger-000 whitespace-pre-wrap rounded-[0.4rem] px-1 py-px text-[0.9rem]">@/lib/email/*</code></td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]"><code class="bg-text-200/5 border border-0.5 border-border-300 text-danger-000 whitespace-pre-wrap rounded-[0.4rem] px-1 py-px text-[0.9rem]">@repo/email</code></td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]"><code class="bg-text-200/5 border border-0.5 border-border-300 text-danger-000 whitespace-pre-wrap rounded-[0.4rem] px-1 py-px text-[0.9rem]">packages/email</code></td></tr><tr class="[tbody>&]:odd:bg-bg-500/10"><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]"><code class="bg-text-200/5 border border-0.5 border-border-300 text-danger-000 whitespace-pre-wrap rounded-[0.4rem] px-1 py-px text-[0.9rem]">@/lib/shipping/*</code></td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]"><code class="bg-text-200/5 border border-0.5 border-border-300 text-danger-000 whitespace-pre-wrap rounded-[0.4rem] px-1 py-px text-[0.9rem]">@repo/shipping</code></td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]"><code class="bg-text-200/5 border border-0.5 border-border-300 text-danger-000 whitespace-pre-wrap rounded-[0.4rem] px-1 py-px text-[0.9rem]">packages/shipping</code></td></tr><tr class="[tbody>&]:odd:bg-bg-500/10"><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]"><code class="bg-text-200/5 border border-0.5 border-border-300 text-danger-000 whitespace-pre-wrap rounded-[0.4rem] px-1 py-px text-[0.9rem]">@/lib/auth/*</code></td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]"><code class="bg-text-200/5 border border-0.5 border-border-300 text-danger-000 whitespace-pre-wrap rounded-[0.4rem] px-1 py-px text-[0.9rem]">@repo/auth</code></td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]"><code class="bg-text-200/5 border border-0.5 border-border-300 text-danger-000 whitespace-pre-wrap rounded-[0.4rem] px-1 py-px text-[0.9rem]">packages/auth</code></td></tr><tr class="[tbody>&]:odd:bg-bg-500/10"><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]"><code class="bg-text-200/5 border border-0.5 border-border-300 text-danger-000 whitespace-pre-wrap rounded-[0.4rem] px-1 py-px text-[0.9rem]">@/lib/utils</code></td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]"><code class="bg-text-200/5 border border-0.5 border-border-300 text-danger-000 whitespace-pre-wrap rounded-[0.4rem] px-1 py-px text-[0.9rem]">@repo/utils</code></td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]"><code class="bg-text-200/5 border border-0.5 border-border-300 text-danger-000 whitespace-pre-wrap rounded-[0.4rem] px-1 py-px text-[0.9rem]">packages/utils</code></td></tr></tbody></table></pre>

**⚠️ ATTENTION** : Les imports locaux ne changent PAS :

tsx

```tsx
importHeaderMinimalfrom'@/components/layout/HeaderMinimal'// ← OK (local)
import{ useCartStore }from'@/store/useCartStore'// ← OK (local)
```

---

### 5.3 Remplacer les imports automatiquement

**Commande PowerShell** :

powershell

```powershell
# Se placer dans le dossier app
cd apps\storefront\app

# Remplacer @/components/ui par @repo/ui
Get-ChildItem-Recurse -Include "*.tsx","*.ts"|ForEach-Object{
$content = Get-Content$_.FullName -Raw
if($content-match'@/components/ui/'){
$content = $content-replace'@/components/ui/','@repo/ui/'
Set-Content$_.FullName -Value $content
Write-Host"✅ Modifié : $($_.Name)"
}
}

# Remplacer @/lib/supabase par @repo/database
Get-ChildItem-Recurse -Include "*.tsx","*.ts"|ForEach-Object{
$content = Get-Content$_.FullName -Raw
if($content-match'@/lib/supabase'){
$content = $content-replace'@/lib/supabase','@repo/database'
Set-Content$_.FullName -Value $content
Write-Host"✅ Modifié : $($_.Name)"
}
}

# Remplacer @/lib/sanity par @repo/sanity
Get-ChildItem-Recurse -Include "*.tsx","*.ts"|ForEach-Object{
$content = Get-Content$_.FullName -Raw
if($content-match'@/lib/sanity'){
$content = $content-replace'@/lib/sanity','@repo/sanity'
Set-Content$_.FullName -Value $content
Write-Host"✅ Modifié : $($_.Name)"
}
}

# Remplacer @/lib/email par @repo/email
Get-ChildItem-Recurse -Include "*.tsx","*.ts"|ForEach-Object{
$content = Get-Content$_.FullName -Raw
if($content-match'@/lib/email'){
$content = $content-replace'@/lib/email','@repo/email'
Set-Content$_.FullName -Value $content
Write-Host"✅ Modifié : $($_.Name)"
}
}

# Revenir à la racine
cd ..\..\..
```

---

### 5.4 Vérifier manuellement les imports complexes

**Chercher les imports restants** :

powershell

```powershell
cd apps\storefront\app
Get-ChildItem-Recurse -Include "*.tsx","*.ts"|Select-String"@/lib/"|Select-Object-First 20
```

**Corriger manuellement** si nécessaire.

---

## 🔍 PHASE 6 : TESTER ET VALIDER

### 6.1 Rebuild complet

**Commandes** :

powershell

```powershell
# Nettoyer le cache
cd apps\storefront
Remove-Item-Recurse -Force .next
Remove-Item-Recurse -Force node_modules

# Réinstaller
pnpm install

# Lancer le dev
pnpm dev
```

---

### 6.2 Tester les routes

**Dans le navigateur, tester** :

- ✅ `http://localhost:3000/` → Homepage
- ✅ `http://localhost:3000/products/hauts` → Liste produits
- ✅ `http://localhost:3000/products/bas` → Liste produits
- ✅ `http://localhost:3000/collections` → Collections
- ✅ `http://localhost:3000/cart` → Panier
- ✅ `http://localhost:3000/checkout` → Checkout
- ✅ `http://localhost:3000/account` → Compte
- ✅ `http://localhost:3000/contact` → Contact

**❌ Si 404** : La route n'a pas été copiée ou le dossier est mal placé

---

### 6.3 Vérifier l'affichage CSS

**Comparer visuellement** :

- Header : Logo + Navigation + Icônes
- Footer : Liens + Texte
- Typographie : Fonts Archivo visibles
- Couleurs : Violet appliqué

**❌ Si les styles ne s'appliquent pas** :

1. Vérifier la console navigateur (F12)
2. Vérifier que `globals.css` se charge (Network tab)
3. Vérifier les erreurs Tailwind dans le terminal

---

### 6.4 Vérifier la console navigateur

**Ouvrir les DevTools (F12)** et vérifier :

✅ **Aucune erreur dans l'onglet Console**
✅ **Les fonts se chargent (Network tab)**
✅ **Les composants UI se chargent**

**❌ Erreurs courantes** :

```
Module not found: Can't resolve '@repo/ui'
→ Le package n'est pas installé ou mal configuré

Module not found: Can't resolve '@/components/ui/button'
→ Import non corrigé

Failed to load resource: globals.css
→ globals.css n'est pas importé dans layout.tsx
```

---

## 📊 CHECKLIST FINALE DE VALIDATION

### Configuration

* [ ] `tailwind.config.ts` contient le path `../../packages/ui/src/**`
* [ ] `globals.css` contient les directives `@tailwind`
* [ ] `globals.css` importe les fonts Google
* [ ] `layout.tsx` importe `./globals.css` en premier
* [ ] `postcss.config.mjs` existe et est correct

### Routes

* [ ] Dossier `products/` existe
* [ ] Dossier `collections/` existe
* [ ] Dossier `product/` existe
* [ ] Dossier `cart/` existe
* [ ] Dossier `checkout/` existe
* [ ] Dossier `account/` existe
* [ ] Dossier `api/` existe
* [ ] Pages statiques (`contact`, `about`, etc.) existent

### Imports

* [ ] `@/components/ui/*` remplacé par `@repo/ui`
* [ ] `@/lib/supabase*` remplacé par `@repo/database`
* [ ] `@/lib/sanity*` remplacé par `@repo/sanity`
* [ ] `@/lib/email/*` remplacé par `@repo/email`

### Tests

* [ ] Homepage s'affiche correctement
* [ ] Route `/products/bas` ne fait plus 404
* [ ] Header et Footer sont visibles
* [ ] Fonts Archivo s'affichent
* [ ] Couleur violet appliquée
* [ ] Aucune erreur dans la console

---

## 🚨 TROUBLESHOOTING

### Problème : Tailwind ne s'applique pas

**Symptôme** : Les classes Tailwind ne fonctionnent pas, tout est en noir et blanc

**Solutions** :

1. Vérifier que `globals.css` est bien importé dans `layout.tsx`
2. Vérifier que les directives `@tailwind` sont présentes dans `globals.css`
3. Vérifier le path `../../packages/ui/src/**` dans `tailwind.config.ts`
4. Rebuild : `Remove-Item -Recurse -Force .next`, puis `pnpm dev`

---

### Problème : Fonts ne s'affichent pas

**Symptôme** : La police par défaut du navigateur s'affiche

**Solutions** :

1. Vérifier l'import Google Fonts dans `globals.css`
2. Vérifier la définition des fonts dans `tailwind.config.ts`
3. Vérifier la classe `font-archivo-narrow` sur le `<body>`
4. Vérifier la console (Network tab) que les fonts se chargent

---

### Problème : Composants UI introuvables

**Symptôme** : Erreur `Module not found: Can't resolve '@repo/ui'`

**Solutions** :

1. Vérifier que le package est dans les dépendances de `apps/storefront/package.json`
2. Rebuild : `pnpm install` depuis la racine
3. Vérifier que le package `@repo/ui` est bien buildé : `cd packages/ui && pnpm build`

---

### Problème : Routes 404 même après copie

**Symptôme** : Les routes font toujours 404 après la migration

**Solutions** :

1. Vérifier que les dossiers sont bien dans `apps/storefront/app/` (pas dans un sous-dossier)
2. Vérifier la structure : `apps/storefront/app/products/[category]/page.tsx`
3. Rebuild : `Remove-Item -Recurse -Force .next`, puis `pnpm dev`

---

## 📝 NOTES IMPORTANTES

1. **Ne pas modifier les packages** pendant la vérification, seulement l'app storefront
2. **Faire des backups** avant les remplacements en masse
3. **Tester après chaque phase** pour identifier rapidement les problèmes
4. **Documenter les différences** trouvées entre l'ancien et le nouveau projet

---

**Document créé le** : 22 octobre 2025

**Version** : 1.0

**Usage** : Guide de vérification systématique post-migration Phase 5
