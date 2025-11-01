# 📦 Phase 9 : Migration des Modules Admin

## 🎯 Objectif

Migrer les 6 modules admin existants depuis l'ancien projet monolithique vers la nouvelle architecture modulaire avec `modules/` à la racine.

## 🏗️ Architecture

Cette migration utilise **l'Architecture A** (recommandée) :

```
blancherenaudin-monorepo/
├── apps/
│   ├── storefront/
│   └── admin/
├── modules/           ⬅️ À la racine (Architecture A)
│   ├── products/
│   ├── orders/
│   ├── customers/
│   ├── categories/
│   ├── media/
│   └── newsletter/
└── packages/
    ├── ui/
    ├── database/
    ├── auth/
    └── admin-shell/
```

**Pourquoi `modules/` à la racine ?**

* ✅ Séparation claire : `packages/` = infra, `modules/` = métier
* ✅ Imports clairs : `@modules/products` (au lieu de `@repo/admin-modules/products`)
* ✅ Scalabilité : facile d'ajouter d'autres types de modules
* ✅ Convention Turborepo standard

📖 Voir [ARCHITECTURE-CLARIFICATION.md](https://claude.ai/chat/ARCHITECTURE-CLARIFICATION.md) pour les détails

## 📋 Modules à migrer

| Module                   | Priorité | Complexité | Temps estimé | Description                              |
| ------------------------ | --------- | ----------- | ------------- | ---------------------------------------- |
| 📦**products**     | 1         | Haute       | 4-6h          | Gestion produits avec variantes et stock |
| 📋**orders**       | 2         | Haute       | 3-4h          | Gestion des commandes et statuts         |
| 👥**customers**    | 3         | Moyenne     | 3h            | Gestion clients avec notes et adresses   |
| 🏷️**categories** | 4         | Basse       | 2h            | Gestion des catégories de produits      |
| 🖼️**media**      | 5         | Moyenne     | 2-3h          | Médiathèque centralisée               |
| 📧**newsletter**   | 6         | Basse       | 2h            | Gestion des abonnés newsletter          |

## 🚀 Utilisation des scripts

### Script 1 : Migration automatique

Le script `migrate-phase9-modules.ps1` automatise entièrement la migration :

```powershell
# Migrer tous les modules (recommandé)
.\migrate-phase9-modules.ps1

# Migrer un seul module
.\migrate-phase9-modules.ps1 -Module products

# Mode simulation (sans modification)
.\migrate-phase9-modules.ps1 -DryRun

# Avec chemins personnalisés
.\migrate-phase9-modules.ps1 `
    -SourcePath "C:\path\to\site_v1_next" `
    -MonorepoPath "C:\path\to\blancherenaudin-monorepo"
```

**Ce que fait le script :**

1. ✅ Vérifie les prérequis (chemins, pnpm, packages)
2. ✅ Crée la structure `modules/[module]/` à la racine
3. ✅ Copie les fichiers depuis l'ancien projet
4. ✅ Met à jour les imports (`@/components` → `@repo/ui`)
5. ✅ Crée le fichier `index.tsx` avec le composant module
6. ✅ Configure le module dans `apps/admin/admin.config.ts` avec `@modules/`
7. ✅ Ajoute le module dans `apps/admin/next.config.ts`
8. ✅ Met à jour `pnpm-workspace.yaml`
9. ✅ Installe les dépendances (`pnpm install`)
10. ✅ Vérifie TypeScript (`pnpm type-check`)

### Script 2 : Validation post-migration

Le script `validate-phase9-migration.ps1` vérifie que tout fonctionne :

```powershell
# Validation standard
.\validate-phase9-migration.ps1

# Validation détaillée
.\validate-phase9-migration.ps1 -Detailed

# Avec chemin personnalisé
.\validate-phase9-migration.ps1 -MonorepoPath "C:\path\to\monorepo"
```

**Ce que vérifie le script :**

* ✅ Structure `modules/` à la racine (pas `packages/admin-modules/`)
* ✅ Fichiers essentiels présents (`package.json`, `tsconfig.json`, `index.tsx`)
* ✅ Contenu des fichiers valide
* ✅ Imports utilisent `@modules/` au lieu de `@repo/admin-modules/`
* ✅ Modules activés dans `admin.config.ts`
* ✅ Dépendances installées et linkées (`@modules/*` dans node_modules)
* ✅ Aucune erreur TypeScript

## 📖 Workflow recommandé

### Étape 1 : Préparation

```powershell
# 1. Se positionner dans le dossier des scripts
cd C:\Users\thoma\Downloads

# 2. Vérifier que les chemins sont corrects (éditer si nécessaire)
code migrate-phase9-modules.ps1
# Vérifier les lignes 82-83 :
# $SourcePath = "C:\Users\thoma\OneDrive\SONEAR_2025\site_v1_next"
# $MonorepoPath = "C:\Users\thoma\OneDrive\SONEAR_2025\blancherenaudin-monorepo"

# 3. Mode dry-run pour voir ce qui va être fait
.\migrate-phase9-modules.ps1 -DryRun
```

### Étape 2 : Migration

```powershell
# Option A : Migrer tous les modules d'un coup (1-2h)
.\migrate-phase9-modules.ps1

# Option B : Migrer module par module (recommandé pour apprentissage)
.\migrate-phase9-modules.ps1 -Module categories  # Commencer par le plus simple
# Tester categories avant de continuer
.\migrate-phase9-modules.ps1 -Module newsletter
.\migrate-phase9-modules.ps1 -Module media
.\migrate-phase9-modules.ps1 -Module customers
.\migrate-phase9-modules.ps1 -Module products
.\migrate-phase9-modules.ps1 -Module orders
```

### Étape 3 : Validation

```powershell
# Valider la migration
.\validate-phase9-migration.ps1 -Detailed

# Si erreurs, les corriger manuellement puis re-valider
.\validate-phase9-migration.ps1
```

### Étape 4 : Test dans le navigateur

```powershell
# Démarrer l'admin
cd C:\Users\thoma\OneDrive\SONEAR_2025\blancherenaudin-monorepo\apps\admin
pnpm dev

# Ouvrir dans le navigateur et tester chaque module:
# http://localhost:3001/products
# http://localhost:3001/orders
# http://localhost:3001/customers
# http://localhost:3001/categories
# http://localhost:3001/media
# http://localhost:3001/newsletter
```

## 🏗️ Structure créée par les scripts

Après migration, vous aurez cette structure :

```
modules/
├── products/
│   ├── src/
│   │   ├── components/           # Composants React du module
│   │   │   ├── ProductsList.tsx
│   │   │   ├── ProductForm.tsx
│   │   │   └── ...
│   │   ├── api/                  # Logique métier (handlers)
│   │   │   ├── list.ts
│   │   │   ├── create.ts
│   │   │   └── ...
│   │   ├── types/                # Types TypeScript
│   │   │   └── product.types.ts
│   │   └── index.tsx             # ⭐ Point d'entrée du module
│   ├── package.json              # name: "@modules/products"
│   └── tsconfig.json
├── orders/
│   └── ... (même structure)
├── customers/
├── categories/
├── media/
└── newsletter/
```

**Fichier clé : `src/index.tsx`**

Point d'entrée de chaque module, exportant un composant React :

```tsx
// modules/products/src/index.tsx
'use client'

import { ModuleProps } from '@repo/admin-shell/types'

export function ProductsModule({ params, services }: ModuleProps) {
  return (
    <div className="p-8">
      <h1>📦 Products</h1>
      {/* Contenu du module */}
    </div>
  )
}

export default ProductsModule
```

## 🔄 Mise à jour des imports

Les scripts mettent automatiquement à jour les imports :

| Ancien import            | Nouveau import           |
| ------------------------ | ------------------------ |
| `@/components/ui`      | `@repo/ui`             |
| `@/components/admin`   | `@repo/ui/admin`       |
| `@/lib/supabase-admin` | `@repo/database`       |
| `@/lib/database.types` | `@repo/database/types` |
| `@/lib/auth`           | `@repo/auth`           |
| `@/lib/utils`          | `@repo/utils`          |

## ⚙️ Configuration générée

### pnpm-workspace.yaml

```yaml
packages:
  - 'apps/*'
  - 'packages/*'
  - 'modules/*'    # ⬅️ Ajouté automatiquement
```

### apps/admin/admin.config.ts

```typescript
// ⬅️ Imports ajoutés automatiquement avec @modules/
import { ProductsModule } from '@modules/products'
import { OrdersModule } from '@modules/orders'
import { CustomersModule } from '@modules/customers'
import { CategoriesModule } from '@modules/categories'
import { MediaModule } from '@modules/media'
import { NewsletterModule } from '@modules/newsletter'

export const adminModules = [
  {
    id: 'products',
    name: 'Products',
    icon: Package,
    basePath: '/products',
    enabled: true,              // ⬅️ Activé
    component: ProductsModule,  // ⬅️ Composant configuré
  },
  // ... autres modules
]
```

### apps/admin/next.config.ts

```typescript
const nextConfig: NextConfig = {
  transpilePackages: [
    '@repo/ui',
    '@repo/database',
    '@repo/auth',
    '@repo/admin-shell',
    // ⬅️ Modules ajoutés automatiquement
    '@modules/products',
    '@modules/orders',
    '@modules/customers',
    '@modules/categories',
    '@modules/media',
    '@modules/newsletter',
  ],
}
```

### modules/products/package.json

```json
{
  "name": "@modules/products",  // ⬅️ Nom avec @modules/
  "version": "0.0.0",
  "private": true,
  "type": "module",
  "exports": {
    ".": "./src/index.tsx"
  },
  "dependencies": {
    "@repo/ui": "workspace:*",
    "@repo/database": "workspace:*",
    "@repo/auth": "workspace:*",
    "react": "^19.0.0",
    "react-dom": "^19.0.0"
  }
}
```

## 🐛 Dépannage

### Erreur : "Module introuvable"

**Problème :** Le script ne trouve pas l'ancien projet

**Solution :**

```powershell
# Éditer le script et modifier la ligne 82
$SourcePath = "C:\votre\chemin\vers\site_v1_next"
```

### Erreur : "pnpm not found"

**Problème :** pnpm n'est pas installé

**Solution :**

```powershell
npm install -g pnpm
```

### Erreur : "@modules/products not found"

**Problème :** Les dépendances ne sont pas linkées

**Solution :**

```powershell
cd C:\Users\thoma\OneDrive\SONEAR_2025\blancherenaudin-monorepo
pnpm install
```

### Erreur TypeScript après migration

**Problème :** Des erreurs TypeScript apparaissent

**Solutions :**

1. Vérifier les imports dans VS Code (Quick Fix avec Ctrl+.)
2. Réinstaller les dépendances :

```powershell
cd C:\Users\thoma\OneDrive\SONEAR_2025\blancherenaudin-monorepo
pnpm install
```

3. Nettoyer le cache :

```powershell
pnpm store prune
rm -r node_modules
pnpm install
```

### Module ne s'affiche pas dans l'admin

**Vérifications :**

1. Module activé dans admin.config.ts ?

```typescript
enabled: true  // ✅ Doit être true
```

2. Import utilise @modules/ ?

```typescript
import { ProductsModule } from '@modules/products'  // ✅ Correct
```

3. Serveur redémarré ?

```powershell
# Arrêter (Ctrl+C) puis relancer
cd apps/admin
pnpm dev
```

## 📊 Checklist de migration

### Avant de commencer

* [ ] Ancien projet accessible (`site_v1_next`)
* [ ] Monorepo créé et fonctionnel
* [ ] pnpm installé (`pnpm --version`)
* [ ] Phase 8 complétée (Admin Shell App)
* [ ] Backup créé (optionnel mais recommandé)

### Pendant la migration

* [ ] Script `migrate-phase9-modules.ps1` téléchargé
* [ ] Mode dry-run exécuté sans erreur
* [ ] Migration réelle exécutée
* [ ] Aucune erreur critique dans la sortie du script

### Après la migration

* [ ] Script `validate-phase9-migration.ps1` exécuté
* [ ] Validation passée (0 erreurs, avertissements acceptables)
* [ ] `pnpm type-check` passe (0 erreurs)
* [ ] Admin démarre : `cd apps/admin && pnpm dev`
* [ ] Tous les modules visibles dans http://localhost:3001/[module]
* [ ] Aucune erreur dans la console navigateur
* [ ] Structure correcte : `modules/` à la racine (pas `packages/admin-modules/`)

### Documentation

* [ ] MIGRATION-STATUS.md mis à jour
* [ ] Notes prises sur les difficultés rencontrées
* [ ] Prêt pour Phase 10 (implémentation des fonctionnalités)

## 🎯 Prochaines étapes après Phase 9

Une fois tous les modules migrés et validés :

1. **Phase 10 : Implémenter les fonctionnalités**
   * Compléter le module Products avec CRUD complet
   * Compléter le module Orders
   * etc.
2. **Phase 11 : Tests**
   * Tests unitaires pour chaque module
   * Tests d'intégration
   * Tests E2E
3. **Phase 12 : Documentation**
   * README pour chaque module
   * Guide d'utilisation admin
   * API documentation

## 📖 Ressources

* **[ARCHITECTURE-CLARIFICATION.md](https://claude.ai/chat/ARCHITECTURE-CLARIFICATION.md)** - Pourquoi modules/ à la racine
* **[MIGRATION-STATUS.md](https://claude.ai/MIGRATION-STATUS.md)** - Suivi de progression
* **[ARCHITECTURE-migration-archi-modulaire.md](https://claude.ai/ARCHITECTURE-migration-archi-modulaire.md)** - Guide complet

## 💡 Conseils

### Ordre de migration recommandé

Si vous migrez module par module, suivez cet ordre (du plus simple au plus complexe) :

1. **categories** ⭐ (le plus simple, bon pour apprendre)
2. **newsletter** (simple aussi)
3. **media** (moyenne complexité)
4. **customers** (moyenne complexité)
5. **products** (complexe mais crucial)
6. **orders** (le plus complexe, dépend de products et customers)

### Backup avant migration

```powershell
# Créer un backup du monorepo
cd C:\Users\thoma\OneDrive\SONEAR_2025
$date = Get-Date -Format 'yyyyMMdd-HHmmss'
Copy-Item -Path "blancherenaudin-monorepo" `
          -Destination "blancherenaudin-monorepo-backup-$date" `
          -Recurse
```

### Vérifier l'architecture avant de commencer

```powershell
# S'assurer qu'on utilise bien modules/ à la racine
cd C:\Users\thoma\OneDrive\SONEAR_2025\blancherenaudin-monorepo
ls modules  # ✅ Devrait exister après la migration
ls packages\admin-modules  # ❌ Ne devrait PAS exister
```

---

**Date de création :** 28 octobre 2025

**Version :** 2.0 (Architecture A - modules/ à la racine)

**Auteur :** Migration Scripts Phase 9
