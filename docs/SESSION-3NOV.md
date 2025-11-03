# 📅 PLAN SESSION - 3 novembre 2025

## 🎯 Objectifs de la session

### Durée estimée : 2-3h

### Progression cible : Phase 9 de 15% → 50%

---

## 📋 TÂCHE 1 : Toggle Dark/Light Mode (45min) ⭐ PRIORITÉ 1

### Objectif

Ajouter un bouton de toggle dark/light dans le header admin pour améliorer l'UX.

### Étape 1.1 : Créer ThemeProvider (15min)

```powershell
# Créer le dossier providers
mkdir "C:\Users\thoma\OneDrive\SONEAR_2025\blancherenaudin-monorepo\apps\admin\components\providers"
```

**Fichier** : `apps/admin/components/providers/ThemeProvider.tsx`

```tsx
'use client'

import { createContext, useContext, useEffect, useState } from 'react'

type Theme = 'light' | 'dark'

interface ThemeContextType {
  theme: Theme
  toggleTheme: () => void
}

const ThemeContext = createContext<ThemeContextType | undefined>(undefined)

export function ThemeProvider({ children }: { children: React.ReactNode }) {
  const [theme, setTheme] = useState<Theme>('light')
  const [mounted, setMounted] = useState(false)

  useEffect(() => {
    setMounted(true)
    const stored = localStorage.getItem('theme') as Theme
    if (stored) {
      setTheme(stored)
      document.documentElement.classList.toggle('dark', stored === 'dark')
    }
  }, [])

  const toggleTheme = () => {
    const newTheme = theme === 'light' ? 'dark' : 'light'
    setTheme(newTheme)
    localStorage.setItem('theme', newTheme)
    document.documentElement.classList.toggle('dark')
  }

  if (!mounted) return <>{children}</>

  return (
    <ThemeContext.Provider value={{ theme, toggleTheme }}>
      {children}
    </ThemeContext.Provider>
  )
}

export function useTheme() {
  const context = useContext(ThemeContext)
  if (!context) throw new Error('useTheme must be used within ThemeProvider')
  return context
}
```

### Étape 1.2 : Créer ThemeToggle (15min)

**Fichier** : `apps/admin/components/shell/ThemeToggle.tsx`

```tsx
'use client'

import { Sun, Moon } from 'lucide-react'
import { useTheme } from '../providers/ThemeProvider'
import { Button } from '@repo/ui'

export function ThemeToggle() {
  const { theme, toggleTheme } = useTheme()

  return (
    <Button
      variant="ghost"
      size="icon"
      onClick={toggleTheme}
      aria-label="Toggle theme"
      className="transition-transform hover:scale-110"
    >
      {theme === 'light' ? (
        <Moon className="h-5 w-5" />
      ) : (
        <Sun className="h-5 w-5" />
      )}
    </Button>
  )
}
```

### Étape 1.3 : Intégrer dans AdminLayout (15min)

**Fichier** : `apps/admin/components/shell/AdminLayout.tsx`

Ajouter le toggle dans le header :

```tsx
import { ThemeToggle } from './ThemeToggle'

// Dans le composant AdminLayout, section header :
<div className="h-16 flex items-center justify-between px-4 border-b border-gray-200 dark:border-gray-700">
  {sidebarOpen && (
    <span className="font-bold text-lg">Admin</span>
  )}
  <div className="flex items-center gap-2">
    <ThemeToggle />
    <button
      onClick={() => setSidebarOpen(!sidebarOpen)}
      className="p-2 hover:bg-gray-100 dark:hover:bg-gray-800 rounded-lg"
    >
      {sidebarOpen ? '←' : '→'}
    </button>
  </div>
</div>
```

### Étape 1.4 : Wrapper app/layout.tsx

**Fichier** : `apps/admin/app/layout.tsx`

```tsx
import { ThemeProvider } from '@/components/providers/ThemeProvider'

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="fr" className={`${archivoNarrow.variable} ${archivoBlack.variable}`}>
      <body>
        <ThemeProvider>
          <AdminLayout modules={tools}>
            {children}
          </AdminLayout>
        </ThemeProvider>
        {/* Scripts... */}
      </body>
    </html>
  )
}
```

### ✅ Tests de validation

* [ ] Cliquer sur le toggle change le thème
* [ ] Le thème persiste au rechargement de la page
* [ ] Le thème s'applique sur toutes les pages (/categories, /, etc.)
* [ ] Animation smooth (transition)
* [ ] Icône change (Sun ↔ Moon)

---

## 📋 TÂCHE 2 : Migration Products (45min)

### Objectif

Migrer le module Products avec liste, détail et formulaire.

### Étape 2.1 : Créer la structure (10min)

```powershell
cd "C:\Users\thoma\OneDrive\SONEAR_2025\blancherenaudin-monorepo\packages\tools\products"

# Créer les dossiers manquants
mkdir src\routes

# Vérifier que API existe déjà
Test-Path src\api\products.ts  # Devrait retourner True
```

### Étape 2.2 : Créer ProductsList.tsx (25min)

**Fichier** : `packages/tools/products/src/routes/ProductsList.tsx`

**Fonctionnalités** :

* Tableau avec colonnes : Image (thumbnail), Nom, SKU, Prix, Stock, Statut
* Filtres : Catégorie (dropdown), Statut (active/inactive), Recherche (input)
* Actions par ligne : Éditer, Dupliquer, Supprimer
* Pagination si >50 produits
* États de chargement

**Référence** : Copier le pattern de `CategoriesList` et adapter :

* `site_v1_next/src/app/admin/products/ProductsList.tsx` - Code original
* `packages/tools/categories/src/routes/CategoriesClient.tsx` - Pattern établi

### Étape 2.3 : Créer les pages Next.js (10min)

```powershell
cd "C:\Users\thoma\OneDrive\SONEAR_2025\blancherenaudin-monorepo\apps\admin\app\(tools)"

# Créer la structure products
mkdir products
mkdir products\[id]
mkdir products\new
```

**Fichier** : `apps/admin/app/(tools)/products/page.tsx`

```tsx
import { ProductsList } from '@repo/tools-products'

export default function ProductsPage() {
  return <ProductsList />
}
```

**Fichier** : `apps/admin/app/(tools)/products/layout.tsx`

```tsx
export default function ProductsLayout({ children }: { children: React.ReactNode }) {
  return <div className="products-tool">{children}</div>
}
```

### Étape 2.4 : Configuration (5min)

```powershell
cd "C:\Users\thoma\OneDrive\SONEAR_2025\blancherenaudin-monorepo\apps\admin"

# Vérifier que @repo/tools-products est installé
pnpm list @repo/tools-products

# Si pas installé
pnpm add @repo/tools-products@workspace:*
```

Vérifier `next.config.ts` :

```typescript
transpilePackages: [
  '@repo/ui',
  '@repo/database',
  '@repo/auth',
  '@repo/tools-categories',
  '@repo/tools-newsletter',
  '@repo/tools-products',  // ✅ Ajouter
],
```

### ✅ Tests de validation

* [ ] `/products` s'affiche sans erreur
* [ ] Tableau affiche les produits depuis la DB
* [ ] Filtres fonctionnent
* [ ] Actions Éditer/Supprimer fonctionnent
* [ ] Dark mode s'applique correctement

---

## 📋 TÂCHE 3 : Migration Orders (45min)

### Objectif

Créer le module Orders de zéro avec liste et détail.

### Étape 3.1 : Créer le package (15min)

```powershell
cd "C:\Users\thoma\OneDrive\SONEAR_2025\blancherenaudin-monorepo\packages\tools"

# Créer la structure
mkdir orders
cd orders
pnpm init
```

**Fichier** : `packages/tools/orders/package.json`

```json
{
  "name": "@repo/tools-orders",
  "version": "0.0.0",
  "private": true,
  "type": "module",
  "exports": {
    ".": "./src/index.tsx"
  },
  "dependencies": {
    "@repo/ui": "workspace:*",
    "@repo/database": "workspace:*",
    "react": "^19.0.0",
    "next": "^15.0.0",
    "lucide-react": "^0.263.0"
  }
}
```

**Structure** :

```powershell
mkdir src
mkdir src\api
mkdir src\routes
mkdir src\types
```

### Étape 3.2 : API orders.ts (15min)

**Fichier** : `packages/tools/orders/src/api/orders.ts`

```typescript
import { createServerClient } from '@repo/database'

export interface Order {
  id: string
  order_number: string
  customer_name: string
  customer_email: string
  total: number
  status: 'pending' | 'paid' | 'shipped' | 'delivered' | 'cancelled'
  created_at: string
  paid_at: string | null
  shipped_at: string | null
}

export async function listOrders() {
  const supabase = createServerClient()
  
  const { data, error } = await supabase
    .from('orders')
    .select('*')
    .order('created_at', { ascending: false })
  
  return { data, error }
}

export async function getOrder(id: string) {
  const supabase = createServerClient()
  
  const { data, error } = await supabase
    .from('orders')
    .select(`
      *,
      order_items (
        id,
        product_name,
        variant_name,
        quantity,
        unit_price,
        total_price
      )
    `)
    .eq('id', id)
    .single()
  
  return { data, error }
}

export async function updateOrderStatus(id: string, status: Order['status']) {
  const supabase = createServerClient()
  
  const { data, error } = await supabase
    .from('orders')
    .update({ status })
    .eq('id', id)
    .select()
    .single()
  
  return { data, error }
}
```

### Étape 3.3 : OrdersList.tsx (15min)

**Fichier** : `packages/tools/orders/src/routes/OrdersList.tsx`

**Fonctionnalités** :

* Tableau : N° commande, Date, Client, Total, Statut, Actions
* Badge coloré par statut (vert=paid, bleu=shipped, gris=pending, rouge=cancelled)
* Filtres : Statut (dropdown), Date range, Recherche client
* Actions : Voir détail, Changer statut

**Pattern** : S'inspirer de `CategoriesClient.tsx`

### Étape 3.4 : Pages et configuration (10min)

Même pattern que Products :

* Créer `apps/admin/app/(tools)/orders/`
* Ajouter dans `transpilePackages`
* Installer la dépendance workspace

### ✅ Tests de validation

* [ ] `/orders` affiche la liste
* [ ] Badges de statut colorés
* [ ] Filtres fonctionnent
* [ ] Changement de statut fonctionne
* [ ] Navigation vers détail fonctionne

---

## 📋 TÂCHE 4 : Documentation et commit (30min)

### Étape 4.1 : Mettre à jour ARCHITECTURE-CIBLE.md (10min)

```markdown
## 📊 État d'avancement Phase 9

### Packages tools
- [x] @repo/tools-categories (100%) ✅
- [x] @repo/tools-products (100%) ✅
- [x] @repo/tools-orders (100%) ✅
- [x] @repo/tools-newsletter (API existe)
- [ ] @repo/tools-customers (0%)
- [ ] @repo/tools-media (0%)
- [ ] @repo/tools-analytics (partiel)

### Modules admin
- [x] Categories ✅
- [x] Products ✅
- [x] Orders ✅
- [ ] Customers
- [ ] Media
- [ ] Analytics

**Progression** : 50% (3/6 modules opérationnels)
```

### Étape 4.2 : Tests manuels complets (10min)

**Checklist UX** :

Navigation :

* [ ] Sidebar affiche tous les tools
* [ ] Clic sur chaque tool → page correcte
* [ ] Highlight du tool actif fonctionne

Dark mode :

* [ ] Toggle fonctionne sur toutes les pages
* [ ] Persiste au rechargement
* [ ] Styles corrects (pas de flash)

Fonctionnalités :

* [ ] Categories : CRUD complet
* [ ] Products : Liste + filtres
* [ ] Orders : Liste + changement statut

Performance :

* [ ] Aucune erreur console
* [ ] Type-check : 0 erreur
* [ ] Build réussit

### Étape 4.3 : Commit et push (10min)

```powershell
cd "C:\Users\thoma\OneDrive\SONEAR_2025\blancherenaudin-monorepo"

# Vérifier les changements
git status

# Add all
git add -A

# Commit descriptif
git commit -m "feat(admin): dark mode toggle + migration products/orders

Features:
- ThemeProvider avec localStorage persistence
- ThemeToggle dans AdminLayout (Sun/Moon icons)
- Migration complète @repo/tools-products (liste + filtres)
- Migration complète @repo/tools-orders (liste + statuts)
- AdminLayout avec navigation tools
- Suppression admin-shell obsolète

Tests:
- Dark mode fonctionne et persiste
- 3/6 tools opérationnels (categories, products, orders)
- Navigation fluide entre tools
- Type-check: 0 erreur

Progress: Phase 9 à 50% (vs 15% début session)"

# Push
git push origin main
```

---

## 📊 Résultat attendu fin de session

### Métriques

**Packages tools** : 4/7 (57%)

* ✅ categories
* ✅ products
* ✅ orders
* ✅ newsletter (API)
* ⏳ customers
* ⏳ media
* ⏳ analytics

**Modules admin** : 3/6 (50%)

* ✅ Categories
* ✅ Products
* ✅ Orders
* ⏳ Customers
* ⏳ Media
* ⏳ Analytics

**Phase 9** : 50% complété

### Livrables

1. ✅ Toggle dark/light mode fonctionnel
2. ✅ 3 modules tools opérationnels
3. ✅ AdminLayout avec navigation
4. ✅ Documentation à jour
5. ✅ 0 erreur TypeScript
6. ✅ Code commité et pushé

---

## 🎯 Si temps supplémentaire (bonus)

### Option A : Améliorer AdminLayout (30min)

* Ajouter logo Blanche Renaudin dans sidebar
* Ajouter user menu (dropdown) : Profile, Settings, Logout
* Améliorer animation toggle sidebar (slide smooth)

### Option B : Commencer Customers (45min)

* Créer `@repo/tools-customers`
* API CRUD basique
* Liste simple avec recherche

### Option C : Breadcrumbs (20min)

* Créer composant `Breadcrumb`
* Intégrer dans chaque page tool
* Ex: `Admin > Products > Liste`

---

## 📚 Documents de référence OBLIGATOIRES

### À ouvrir AVANT de commencer

1. **ARCHITECTURE-AJOUTER-TOOL.md** ⭐⭐⭐⭐⭐
   * Section "Recette validée"
   * Checklist de création tool
   * Points critiques (.tsx, transpilePackages, layouts)
2. **ARCHITECTURE-BONNES-PRATIQUES-TOOLS.md** ⭐⭐⭐⭐
   * Guide debugging
   * Règles d'or
   * Troubleshooting layouts
3. **point-etape-9-oct-2025.md** ⭐⭐⭐⭐
   * Composants existants
   * Structure complète site_v1_next
   * Specs métier
4. **solution-finale-layout-vide.md** ⭐⭐⭐
   * Bug résolu aujourd'hui
   * Pattern layouts validé

### Code source de référence

```
site_v1_next/src/app/admin/
├── products/          → Référence Products
├── orders/            → Référence Orders
└── customers/         → Référence Customers (si temps)

packages/tools/
└── categories/        → Pattern établi ✅
```

---

## ⚠️ Points d'attention CRITIQUES

### Erreurs à ÉVITER (apprises aujourd'hui)

1. ❌ **Layout vide** → Tous les layouts doivent retourner `{children}`
2. ❌ **Extension .ts** → Utiliser `.tsx` pour JSX
3. ❌ **Oublier transpilePackages** → Ajouter chaque tool dans next.config.ts
4. ❌ **Dépendance non installée** → `pnpm add @repo/xxx@workspace:*`

### Nouveaux pièges à surveiller

1. ⚠️ **ThemeProvider** → Doit avoir `'use client'`
2. ⚠️ **localStorage** → Vérifier `typeof window !== 'undefined'`
3. ⚠️ **useEffect** → ThemeProvider nécessite `mounted` state
4. ⚠️ **Icons lucide** → Import `* as Icons` puis `Icons[name]`

---

## 🛠️ Commandes rapides

### Démarrer la session

```powershell
cd C:\Users\thoma\OneDrive\SONEAR_2025\blancherenaudin-monorepo
pnpm install
cd apps\admin
pnpm dev
```

### Créer un tool

```powershell
# Template rapide
cd packages\tools
mkdir nom-tool
cd nom-tool
pnpm init

# Copier structure depuis categories
Copy-Item ..\categories\src -Destination .\src -Recurse
```

### Vérifications

```powershell
# Type-check
pnpm type-check

# Build
cd packages\tools\nom-tool
pnpm build

# Test serveur
cd apps\admin
pnpm dev
# Ouvrir http://localhost:3001/nom-tool
```

### Git

```bash
git status
git add -A
git commit -m "feat: description"
git push origin main
```

---

## ✅ Checklist pré-session

### Environnement

* [ ] VS Code ouvert sur le monorepo
* [ ] Terminal PowerShell prêt
* [ ] Serveur admin tourne (`pnpm dev`)
* [ ] Navigateur sur `localhost:3001/categories`

### Documentation

* [ ] ARCHITECTURE-AJOUTER-TOOL.md ouvert
* [ ] ARCHITECTURE-BONNES-PRATIQUES-TOOLS.md ouvert
* [ ] point-etape-9-oct-2025.md ouvert
* [ ] Ce document (plan session) ouvert

### Mental

* [ ] ☕ Café/thé prêt
* [ ] 🎧 Musique focus (optionnel)
* [ ] 🚫 Notifications désactivées
* [ ] ⏰ 2-3h bloquées sans interruption
* [ ] 📝 Bloc-notes pour idées/questions

---

## 🎯 Objectif final de la session

**Au moment du commit final, on doit pouvoir dire** :

> "L'interface admin a un toggle dark/light qui fonctionne. La moitié des modules métier sont opérationnels (categories, products, orders). L'architecture monorepo est validée et réplicable. Le code est propre, typé, et sans erreur."

**Métriques de succès** :

* ✅ Dark mode : fonctionne + persiste
* ✅ Tools : 3/6 opérationnels (50%)
* ✅ TypeScript : 0 erreur
* ✅ Git : code commité et pushé
* ✅ Documentation : à jour

---

**Durée totale estimée** : 2h30-3h

**Breaks recommandés** : 1 pause de 10min toutes les heures

**Date cible** : 3 novembre 2025

**Bonne session ! 🚀**
