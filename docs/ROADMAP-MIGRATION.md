# 🗺️ ROADMAP Migration Monorepo - Blanche Renaudin

**Dernière mise à jour** : 1er novembre 2025  
**Progression globale** : 30% ✅

---

## 📊 Vue d'Ensemble

### ✅ Phase 1 : Packages Fondamentaux (TERMINÉE)

| Package | Status | Date | Effort |
|---------|--------|------|--------|
| @repo/database | ✅ Migré | 01/11/2025 | 3h |
| @repo/email | ✅ Validé | 01/11/2025 | 30min |
| @repo/utils | ✅ Validé | 01/11/2025 | 30min |
| @repo/ui | ✅ Validé | 01/11/2025 | 30min |

**Résultat** : 4 packages conformes à l'architecture cible, 35 fichiers corrigés, build storefront ✅

---

## 🎯 Phase 2 : Migration Modules Admin (EN COURS)

**Objectif** : Migrer les 8 modules admin de \pps/admin\ vers \packages/tools/\

### Sprint 1 : Produits & Commandes (8-10h)

#### 1.1 Migration @tools/products 🔥 PRIORITÉ #1
**Effort** : 4h  
**Dépendances** : @repo/database ✅

\\\
packages/tools/products/
├── src/
│   ├── api/              # Routes API
│   │   ├── products.ts
│   │   ├── variants.ts
│   │   └── stock.ts
│   ├── components/       # UI Components
│   │   ├── ProductForm.tsx
│   │   ├── ProductsList.tsx
│   │   └── StockManager.tsx
│   ├── constants.ts
│   ├── manifest.ts       # Tool metadata
│   └── index.ts
├── package.json
└── README.md
\\\

**Tâches** :
- [ ] Créer structure \packages/tools/products\
- [ ] Migrer API routes depuis \pps/admin/app/api/admin/products\
- [ ] Migrer composants depuis \pps/admin/app/(tools)/products\
- [ ] Créer \manifest.ts\ avec metadata du tool
- [ ] Mettre à jour imports dans admin app
- [ ] Tester CRUD complet
- [ ] Documenter dans \docs/TOOLS-PRODUCTS.md\

#### 1.2 Migration @tools/orders
**Effort** : 4h  
**Dépendances** : @repo/database ✅, @tools/products

\\\
packages/tools/orders/
├── src/
│   ├── api/
│   │   ├── orders.ts
│   │   └── fulfillment.ts
│   ├── components/
│   │   ├── OrdersList.tsx
│   │   ├── OrderDetail.tsx
│   │   └── StatusManager.tsx
│   ├── constants.ts
│   ├── manifest.ts
│   └── index.ts
\\\

**Tâches** :
- [ ] Créer structure
- [ ] Migrer API routes
- [ ] Migrer composants
- [ ] Tester workflow commandes
- [ ] Documenter

---

### Sprint 2 : Clients & Newsletter (6-8h)

#### 2.1 Migration @tools/customers
**Effort** : 3h  
**Dépendances** : @repo/database ✅, @repo/utils ✅

\\\
packages/tools/customers/
├── src/
│   ├── api/
│   │   ├── customers.ts
│   │   └── addresses.ts
│   ├── components/
│   │   ├── CustomersList.tsx
│   │   ├── CustomerDetail.tsx
│   │   └── NotesManager.tsx
│   ├── services/
│   │   └── customerService.ts
│   ├── manifest.ts
│   └── index.ts
\\\

**Tâches** :
- [ ] Créer structure
- [ ] Migrer depuis \@repo/utils/services/customerService\
- [ ] Migrer API routes et composants
- [ ] Tester gestion clients
- [ ] Documenter

#### 2.2 Complétion @tools/newsletter
**Effort** : 3h  
**Dépendances** : @repo/database ✅, @repo/email ✅

**État actuel** : Structure existe mais interface admin incomplète

\\\
packages/tools/newsletter/
├── src/
│   ├── api/              ✅ Existe
│   │   ├── subscribers.ts
│   │   └── analytics.ts
│   ├── components/       ⚠️ À compléter
│   │   ├── CampaignEditor.tsx     ❌
│   │   ├── SubscribersList.tsx    ❌
│   │   └── AnalyticsDashboard.tsx ❌
│   ├── templates/        ✅ Existe
│   ├── manifest.ts       ✅ Existe
│   └── index.ts          ✅ Existe
\\\

**Tâches** :
- [ ] Créer \CampaignEditor.tsx\ (éditeur campagnes)
- [ ] Créer \SubscribersList.tsx\ (gestion abonnés)
- [ ] Créer \AnalyticsDashboard.tsx\ (stats envois)
- [ ] Intégrer dans admin app
- [ ] Tester flow complet (création → envoi → analytics)
- [ ] Documenter

---

### Sprint 3 : Modules Secondaires (8-10h)

#### 3.1 Migration @tools/media
**Effort** : 3h  
**Dépendances** : @repo/database ✅

\\\
packages/tools/media/
├── src/
│   ├── api/
│   │   ├── upload.ts
│   │   └── images.ts
│   ├── components/
│   │   ├── MediaGrid.tsx
│   │   ├── ImageEditor.tsx
│   │   └── Uploader.tsx
│   ├── manifest.ts
│   └── index.ts
\\\

#### 3.2 Migration @tools/analytics
**Effort** : 3h  
**Dépendances** : @repo/database ✅

\\\
packages/tools/analytics/
├── src/
│   ├── api/
│   │   └── stats.ts
│   ├── components/
│   │   ├── Dashboard.tsx
│   │   ├── SalesChart.tsx
│   │   └── RevenueMetrics.tsx
│   ├── manifest.ts
│   └── index.ts
\\\

#### 3.3 Nouveaux modules

**@tools/categories** (2h)
\\\
- Gestion des catégories produits
- Arbre hiérarchique
- Drag & drop réorganisation
\\\

**@tools/settings** (2h)
\\\
- Configuration générale
- Variables d'environnement
- Préférences admin
\\\

---

## 🔧 Phase 3 : Infrastructure & Outils (6-8h)

### 3.1 Package @repo/payments
**Effort** : 2h  
**Objectif** : Extraire Stripe de storefront

\\\
packages/payments/
├── src/
│   ├── stripe/
│   │   ├── client.ts
│   │   ├── checkout.ts
│   │   ├── webhooks.ts
│   │   └── types.ts
│   ├── config.ts
│   └── index.ts
├── package.json
└── README.md
\\\

**Tâches** :
- [ ] Créer package \@repo/payments\
- [ ] Migrer \pps/storefront/lib/stripe.ts\
- [ ] Migrer logique webhooks
- [ ] Mettre à jour imports dans storefront
- [ ] Mettre à jour imports dans admin (si nécessaire)
- [ ] Documenter dans \docs/PACKAGE-PAYMENTS.md\

### 3.2 Registry System Improvements
**Effort** : 2h  
**Objectif** : Améliorer le système de chargement dynamique des tools

\\\	ypescript
// apps/admin/lib/registry/registry.ts
export const toolRegistry = {
  products: () => import('@tools/products'),
  orders: () => import('@tools/orders'),
  customers: () => import('@tools/customers'),
  // ... etc
}
\\\

### 3.3 Nettoyage & Documentation
**Effort** : 2h

**Tâches** :
- [ ] Supprimer \ackups/\ (1.5GB de fichiers obsolètes)
- [ ] Mettre à jour \README.md\ racine
- [ ] Créer \CONTRIBUTING.md\
- [ ] Mettre à jour \docs/ARCHITECTURE-MONOREPO.md\

---

## 📱 Phase 4 : Admin App Refactoring (4-6h)

**Objectif** : Transformer \pps/admin\ en coquille dynamique

### Architecture Cible

\\\	ypescript
// apps/admin/app/(tools)/[module]/[[...slug]]/page.tsx
import { toolRegistry } from '@/lib/registry'

export default async function DynamicToolPage({ 
  params 
}: { 
  params: { module: string; slug?: string[] } 
}) {
  const Tool = await toolRegistry.load(params.module)
  
  return (
    <AdminLayout>
      <Tool.render slug={params.slug} />
    </AdminLayout>
  )
}
\\\

### Bénéfices
- ✅ Chargement dynamique des tools
- ✅ Code splitting automatique
- ✅ Hot reload des tools en dev
- ✅ Ajout de tools sans modifier admin app

**Tâches** :
- [ ] Créer \ToolLoader\ component
- [ ] Implémenter dynamic imports
- [ ] Migrer routes existantes
- [ ] Tester avec tous les tools
- [ ] Mesurer performance (bundle size)

---

## 🧪 Phase 5 : Tests & Qualité (8-10h) - OPTIONNEL

### 5.1 Tests Unitaires Packages (4h)

**@repo/database**
\\\	ypescript
// tests/types-helpers.test.ts
describe('getCategoryWithChildren', () => {
  it('should return category with nested children')
  it('should handle empty children array')
})
\\\

**@repo/utils**
\\\	ypescript
// tests/formatters.test.ts
describe('formatPrice', () => {
  it('formats euros correctly')
  it('handles decimals properly')
})
\\\

**@repo/email**
\\\	ypescript
// tests/templates.test.ts
describe('OrderConfirmationEmail', () => {
  it('renders with correct order data')
})
\\\

### 5.2 Tests E2E Critiques (4h)

**Flows à tester** :
- [ ] Checkout complet (panier → paiement → confirmation)
- [ ] Création produit admin (form → API → DB → refresh)
- [ ] Envoi email (trigger → template → delivery)

**Tools** : Playwright + Vitest

---

## 📈 Métriques & KPIs

### Progression Actuelle

| Catégorie | Actuel | Cible | % |
|-----------|--------|-------|---|
| Packages Core | 4/4 | 4 | 100% ✅ |
| Packages Tools | 1/8 | 8 | 12% ⚠️ |
| Documentation | 5 docs | 15 docs | 33% |
| Tests | 0 | 50+ | 0% ❌ |

### Objectifs Phase 2

- ✅ Tous les tools dans \packages/tools/\
- ✅ Admin app = coquille dynamique
- ✅ Build times < 30s
- ✅ Type-check tous packages sans erreur

---

## 🗓️ Planning Prévisionnel

### Novembre 2025
- **Semaine 1** : Phase 2.1 (Products + Orders)
- **Semaine 2** : Phase 2.2 (Customers + Newsletter)
- **Semaine 3** : Phase 2.3 (Media + Analytics)
- **Semaine 4** : Phase 3 (Infrastructure)

### Décembre 2025
- **Semaine 1** : Phase 4 (Admin Refactoring)
- **Semaine 2** : Phase 5 (Tests - optionnel)
- **Semaine 3-4** : Buffer & ajustements

---

## 🎯 Prochaine Session

**Recommandation** : Migration @tools/products (4h)

**Préparation** :
1. Lire \pps/admin/app/(tools)/products/\
2. Comprendre les API routes existantes
3. Identifier les dépendances

**Résultat attendu** :
- ✅ Package \@tools/products\ créé
- ✅ CRUD fonctionnel
- ✅ Tests manuels passent
- ✅ Documentation à jour

---

## 📚 Ressources

### Documentation Existante
- [ARCHITECTURE-CIBLE.md](./CIBLE/ARCHITECTURE-CIBLE.md)
- [MIGRATION-DATABASE-COMPLETE.md](./MIGRATION-DATABASE-COMPLETE.md)
- [PACKAGE-*.md](./PACKAGE-*.md)

### Standards à Suivre
- Structure tools : Voir \packages/tools/newsletter/\ (exemple)
- Naming conventions : kebab-case pour fichiers, PascalCase pour composants
- Exports : Toujours via \index.ts\
- Types : Co-localisés avec le code

---

**Maintenu par** : Thomas Renaudin  
**Dernière révision** : 1er novembre 2025
