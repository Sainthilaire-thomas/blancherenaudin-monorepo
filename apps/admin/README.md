# 🎯 Admin Shell App - Blanche Renaudin

Application admin modulaire pour Blanche Renaudin.

## 🚀 Démarrage

```bash
# Depuis apps/admin/
pnpm dev

# Ou depuis la racine du monorepo
pnpm --filter admin dev
```

L'admin sera accessible sur **http://localhost:3001**

## 🏗️ Architecture

- **Route dynamique**: `/admin/[module]/[[...slug]]`
- **Registry**: `admin.config.ts` (liste des modules)
- **Layout**: Utilise `AdminLayout` de `@repo/admin-shell`
- **Loader**: `ModuleLoader` charge dynamiquement les modules

## 📦 Modules disponibles

Voir `admin.config.ts` pour la liste complète.

Pour activer un module:
1. Créer le module dans `modules/nom-module/`
2. Mettre `enabled: true` dans `admin.config.ts`

## 🔐 Authentification

Credentials temporaires (dev):
- Email: `admin@blancherenaudin.com`
- Password: `admin`

TODO: Implémenter auth Supabase réelle

## 📂 Structure

```
apps/admin/
├── app/
│   ├── (auth)/
│   │   └── login/          # Page de connexion
│   ├── (dashboard)/
│   │   ├── layout.tsx      # Layout avec AdminLayout
│   │   ├── page.tsx        # Dashboard principal
│   │   └── [module]/       # Route dynamique modules
│   │       └── [[...slug]]/
│   │           └── page.tsx
│   ├── globals.css
│   └── layout.tsx
├── admin.config.ts         # Registry des modules
├── middleware.ts           # Protection routes
└── next.config.ts
```

## 🔧 Configuration

- **Port**: 3001 (pour éviter conflits avec storefront)
- **Packages**: Utilise les packages du monorepo via workspace
- **Tailwind**: Partagé avec @repo/config

## 🎨 Personnalisation

Voir `tailwind.config.ts` pour les tokens de design (couleurs, fonts).

## 📝 Développement

### Ajouter un module

1. Créer dans `modules/nom-module/`
2. Exporter un composant React par défaut avec props `ModuleProps`
3. L'ajouter dans `admin.config.ts`
4. Mettre `enabled: true`

### Routes API

Les routes API des modules doivent être dans `apps/admin/app/api/`.

Exemple:
```typescript
// apps/admin/app/api/products/route.ts
import { listProducts } from '@modules/products/api/list'

export async function GET(request: Request) {
  const products = await listProducts()
  return Response.json(products)
}
```

## 🐛 Debug

- `pnpm type-check` : Vérifier les types
- `pnpm lint` : Vérifier le code
