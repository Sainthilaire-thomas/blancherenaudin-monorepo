# 🧹 PLAN DE NETTOYAGE DU MONOREPO

## Blanche Renaudin - Nettoyage avant continuation de la migration

**Date:** 31 octobre 2025

**Objectif:** Nettoyer l'arborescence actuelle avant de continuer la migration depuis site_v1_next

**Référence:** site_v1_next (pas de backup nécessaire dans le monorepo)

---

## 🎯 PRINCIPE

**On garde la référence `site_v1_next` comme source de vérité**

→ Pas besoin de backups dans le monorepo

→ En cas de doute, on re-migrate depuis site_v1_next

---

## 📊 ANALYSE DE L'EXISTANT

### ✅ CE QUI EST BIEN MIGRÉ (À GARDER)

#### 1. **apps/admin/** ✅

```
apps/admin/
├── app/
│   ├── (admin)/            ✅ Structure correcte
│   │   └── newsletter/     ✅ Page admin newsletter
│   ├── (auth)/             ✅ Routes auth
│   │   └── login/
│   ├── (protected)/        ✅ Routes protégées
│   │   └── analytics/
│   ├── (tools)/            ✅ Point de montage des tools
│   │   └── newsletter/     ✅ Tool newsletter bien structuré
│   ├── api/                ✅ API routes
│   │   └── newsletter/
│   ├── globals.css         ✅
│   └── layout.tsx          ✅
│
├── components/
│   ├── admin/              ✅ Composants shell
│   │   └── AdminNav.tsx
│   └── analytics/          ✅
│       └── AnalyticsTracker.tsx
│
├── lib/
│   └── registry/           ✅ Registry système
│       ├── index.ts
│       ├── registry.ts
│       ├── ToolErrorBoundary.tsx
│       ├── ToolLoader.tsx
│       └── types.ts
│
└── middleware.ts           ✅ Protection routes

ACTION: ✅ GARDER TEL QUEL
```

#### 2. **apps/storefront/** ✅

```
apps/storefront/
├── app/                    ✅ Structure Next.js complète
│   ├── about/
│   ├── account/
│   ├── api/
│   ├── auth/
│   ├── cart/
│   ├── checkout/
│   ├── collections/
│   ├── contact/
│   ├── newsletter/         ✅ Bien migré
│   ├── product/
│   ├── products/
│   └── ...
│
├── components/             ✅ Composants bien organisés
│   ├── account/
│   ├── common/
│   ├── layout/
│   ├── newsletter/         ✅ NewsletterSubscribe.tsx
│   ├── products/
│   └── search/
│
├── hooks/                  ✅
├── lib/                    ✅
└── store/                  ✅

ACTION: ✅ GARDER TEL QUEL
```

#### 3. **packages/database/** ✅

```
packages/database/
├── src/
│   ├── clients/            ✅ Bien structuré
│   │   ├── client.ts
│   │   ├── server-client.ts
│   │   └── admin-client.ts
│   ├── types/              ✅ Types générés
│   │   └── database.types.ts
│   └── index.ts
└── package.json            ✅

ACTION: ✅ GARDER TEL QUEL
```

#### 4. **packages/email/** ✅

```
packages/email/
├── src/
│   ├── templates/          ✅ Templates React Email
│   │   ├── newsletter-confirmation.tsx
│   │   ├── order-confirmation.tsx
│   │   └── order-shipped.tsx
│   ├── utils/              ✅
│   └── index.ts
└── package.json            ✅

ACTION: ✅ GARDER TEL QUEL
```

#### 5. **packages/ui/** ✅

```
packages/ui/
├── src/
│   ├── components/         ✅ 43 composants shadcn/ui
│   │   ├── accordion.tsx
│   │   ├── button.tsx
│   │   ├── card.tsx
│   │   └── ... (40 autres)
│   ├── hooks/              ✅
│   │   ├── use-mobile.ts
│   │   └── use-toast.ts
│   ├── lib/
│   │   └── utils.ts        ✅ cn() + helpers
│   └── index.ts
├── tailwind.preset.js      ✅ Preset partagé
└── package.json            ✅

ACTION: ✅ GARDER TEL QUEL
```

#### 6. **packages/eslint-config/** ✅

```
packages/eslint-config/
├── library.js
├── next.js
└── package.json

ACTION: ✅ GARDER TEL QUEL
```

#### 7. **packages/typescript-config/** ✅

```
packages/typescript-config/
├── base.json
├── nextjs.json
├── react-library.json
└── package.json

ACTION: ✅ GARDER TEL QUEL
```

#### 8. **packages/tools/analytics/** ✅

```
packages/tools/analytics/
├── src/
│   ├── lib/
│   │   ├── analytics.ts    ✅ Logique analytics custom
│   │   └── track.ts
│   ├── index.ts
│   └── types.ts
└── package.json

ACTION: ✅ GARDER TEL QUEL
```

#### 9. **packages/tools/newsletter/** ✅

```
packages/tools/newsletter/
├── __tests__/              ✅ Tests présents
│   ├── api/
│   └── components/
├── src/
│   ├── api/                ✅ Logique métier
│   │   ├── analytics.ts
│   │   └── subscribers.ts
│   ├── components/         ✅ Composants UI
│   ├── hooks/              ✅ Hooks métier
│   ├── routes/             ✅ Pages/layouts
│   ├── types/
│   ├── constants.ts
│   ├── manifest.ts         ✅ Configuration tool
│   ├── validation.ts
│   └── index.ts
├── package.json            ✅
└── vitest.config.ts        ✅

ACTION: ✅ GARDER TEL QUEL (référence de structure)
```

#### 10. **packages/utils/** ✅

```
packages/utils/
├── src/
│   ├── services/
│   │   └── customerService.ts  ✅
│   ├── validation/
│   │   └── adminCustomers.ts   ✅
│   ├── cn.ts               ✅
│   ├── formatters.ts       ✅
│   ├── images.ts           ✅
│   ├── validators.ts       ✅
│   └── index.ts
└── package.json            ✅

ACTION: ✅ GARDER TEL QUEL
```

---

## ❌ CE QUI DOIT ÊTRE SUPPRIMÉ

### 1. **packages/admin-shell/** ❌ DOUBLON

```
Raison: La logique du shell est dans apps/admin/lib/registry/
Conflit: Crée de la confusion sur où mettre la logique shell

ACTION: 🗑️ SUPPRIMER COMPLÈTEMENT
```

### 2. **packages/analytics/** ❌ DOUBLON

```
Raison: Doublon de packages/tools/analytics/
Problème: Deux packages analytics différents = confusion

ACTION: 🗑️ SUPPRIMER (garder packages/tools/analytics/)
```

### 3. **packages/auth/** 🔍 À ÉVALUER

```
Situation: Utilisé par apps/admin et apps/storefront
Options:
  A) Si auth générique → GARDER à la racine packages/
  B) Si auth spécifique admin → MIGRER vers packages/tools/auth/

DÉCISION NÉCESSAIRE: Analyser le contenu avant de décider

ACTION: ⏸️ ANALYSER D'ABORD (voir section "Décisions à prendre")
```

### 4. **packages/config/** 🔍 À ANALYSER

```
Situation: Utilisé par plusieurs apps/packages
Contenu: À vérifier - configurations générales ?

Options:
  A) Configs générales → GARDER
  B) Configs spécifiques → FUSIONNER dans les packages concernés

ACTION: ⏸️ ANALYSER LE CONTENU
```

### 5. **packages/sanity/** 🔍 À ÉVALUER

```
Situation: Configuration Sanity CMS
Utilisé par: apps/storefront uniquement

Options:
  A) Renommer en packages/sanity-config/ (cohérence)
  B) Garder tel quel si temporaire
  C) Migrer dans apps/storefront/sanity/ si spécifique

ACTION: ⏸️ DÉCIDER DE L'ORGANISATION
```

### 6. **packages/shipping/** ❌ INUTILISÉ

```
Raison: Aucune utilisation dans le code
Impact: 0 (package mort)

ACTION: 🗑️ SUPPRIMER IMMÉDIATEMENT
```

### 7. **modules/** ❌ ANCIENNE STRUCTURE

```
Raison: Structure de l'ancienne tentative de migration
Contenu:
  - modules/analytics/   → Fusionner avec packages/tools/analytics/
  - modules/customers/   → Migrer vers packages/tools/customers/
  - modules/media/       → Migrer vers packages/tools/media/
  - modules/newsletter/  → Fusionner avec packages/tools/newsletter/
  - modules/orders/      → Migrer vers packages/tools/orders/
  - modules/products/    → Migrer vers packages/tools/products/

ACTION: 🔄 MIGRER VERS packages/tools/ puis SUPPRIMER modules/
```

### 8. **Fichiers de backup** ❌

```
Fichiers .backup-* disséminés:
  - apps/admin/components/admin/AdminNav.tsx.backup-20251029-092032
  - apps/storefront/components/layout/FooterMinimal.tsx.backup-20251027-101200
  - packages/ui/package.json.backup-*
  - tsconfig.*.backup

Raison: Pollue l'arborescence, source = site_v1_next

ACTION: 🗑️ SUPPRIMER TOUS LES .backup-*
```

### 9.  **scripts/analytics-** * ❌ RÉSULTATS D'AUDIT

```
scripts/
├── analytics-audit-results/        ❌ Résultats d'analyse anciens
├── analytics-dependencies-analysis/ ❌ Résultats d'analyse
└── monorepo-compatibility-check/    ❌ Résultats d'analyse

Raison: Résultats d'audits anciens, pas du code source

ACTION: 🗑️ DÉPLACER vers /docs/archives/ OU SUPPRIMER
```

### 10. **Scripts PowerShell anciens** ⚠️ À TRIER

```
scripts/
├── analyze-*.ps1           ⚠️ Utiles pour debug
├── audit-*.ps1             ⚠️ Utiles pour debug
├── check-*.ps1             ⚠️ Utiles pour debug
├── cleanup-backups.ps1     ✅ GARDER (utile)
├── create-newsletter-tool.ps1  ❌ Déjà fait
├── diagnose-*.ps1          ⚠️ Utiles pour debug
├── fix-*.ps1               ❌ One-shot déjà exécutés
├── migrate-*.ps1           ❌ One-shot déjà exécutés
└── test-newsletter-build.ps1   ⚠️ Utile pour tests

ACTION: 
  - GARDER: Scripts réutilisables (analyze, diagnose, check, test)
  - SUPPRIMER: Scripts one-shot déjà exécutés (fix-*, migrate-*, create-*)
```

---

## 🎯 DÉCISIONS À PRENDRE AVANT NETTOYAGE

### Décision 1: packages/auth/

**Question:** Auth est-il un package core ou un tool métier ?

**Analyse nécessaire:**

```bash
# Vérifier les dépendances
grep -r "@repo/auth" apps/*/package.json packages/*/package.json

# Vérifier le contenu
ls -la packages/auth/src/
```

**Options:**

* **A) Core package** → Garder à `packages/auth/`
  * Si: Auth générique utilisé partout (storefront + admin)
  * Si: Pas de logique métier spécifique
* **B) Tool métier** → Migrer vers `packages/tools/auth/`
  * Si: Auth spécifique à l'admin avec RBAC complexe
  * Si: Logique métier (roles, permissions)

**Recommandation:** Probablement **A) Core** car utilisé par storefront aussi

---

### Décision 2: packages/config/

**Question:** Quel est le contenu de ce package ?

**Analyse nécessaire:**

```bash
# Voir la structure
tree packages/config/

# Voir les utilisations
grep -r "@repo/config" apps/ packages/
```

**Options:**

* **A) Configs générales** → Garder et documenter
* **B) Configs spécifiques** → Fusionner dans les packages concernés
* **C) Configs inutilisées** → Supprimer

---

### Décision 3: packages/sanity/

**Question:** Organisation de la config Sanity

**Options:**

* **A) Renommer** en `packages/sanity-config/` (cohérence avec autres configs)
* **B) Déplacer** dans `apps/storefront/sanity/` (si usage exclusif storefront)
* **C) Garder** tel quel si temporaire

**Recommandation:** **B) Déplacer** dans storefront si usage exclusif

---

### Décision 4: modules/

**Question:** Comment gérer les modules existants ?

**Stratégie recommandée:**

1. **Comparer** modules/* avec site_v1_next/src/app/admin/*
2. **Fusionner** les bons éléments dans packages/tools/*
3. **Supprimer** modules/ après migration

**Ordre suggéré:**

1. `modules/newsletter/` → Fusionner avec `packages/tools/newsletter/` ✅ (déjà fait ?)
2. `modules/analytics/` → Fusionner avec `packages/tools/analytics/`
3. `modules/products/` → Créer `packages/tools/products/`
4. `modules/orders/` → Créer `packages/tools/orders/`
5. `modules/customers/` → Créer `packages/tools/customers/`
6. `modules/media/` → Créer `packages/tools/media/`

---

## 📋 PLAN D'EXÉCUTION DU NETTOYAGE

### PHASE 1️⃣ : Suppressions immédiates (sans risque)

**Durée estimée:** 5 minutes

```powershell
# 1. Supprimer shipping (non utilisé)
Remove-Item -Recurse packages\shipping\

# 2. Supprimer analytics doublon
Remove-Item -Recurse packages\analytics\

# 3. Supprimer admin-shell doublon
Remove-Item -Recurse packages\admin-shell\

# 4. Supprimer tous les backups
Get-ChildItem -Recurse -Include "*.backup*" | Remove-Item -Force

# 5. Nettoyer les résultats d'audit
Remove-Item -Recurse scripts\analytics-audit-results\
Remove-Item -Recurse scripts\analytics-dependencies-analysis\
Remove-Item -Recurse scripts\monorepo-compatibility-check\

# 6. Supprimer scripts one-shot déjà exécutés
Remove-Item scripts\fix-*.ps1
Remove-Item scripts\migrate-*.ps1
Remove-Item scripts\create-newsletter-tool.ps1

# 7. Réinstaller les dépendances
pnpm install
```

**Vérification:**

```powershell
pnpm build
pnpm type-check
```

**Rollback si erreur:** Consulter site_v1_next pour re-migrer

---

### PHASE 2️⃣ : Analyse et décisions

**Durée estimée:** 15 minutes

```powershell
# 1. Analyser packages/auth/
tree packages\auth\
code packages\auth\src\

# Vérifier les usages
grep -r "@repo/auth" apps\ packages\

# 2. Analyser packages/config/
tree packages\config\
code packages\config\src\

# Vérifier les usages
grep -r "@repo/config" apps\ packages\

# 3. Analyser packages/sanity/
tree packages\sanity\
grep -r "@repo/sanity" apps\

# 4. Comparer modules/ avec site_v1_next
# Ouvrir deux fenêtres VS Code côte à côte
code modules\
code ..\site_v1_next\src\app\admin\
```

**Prendre les décisions** selon les analyses

---

### PHASE 3️⃣ : Réorganisation selon décisions

**Durée estimée:** 30 minutes

**Selon décisions prises:**

#### Si auth → core (recommandé)

```powershell
# Garder packages/auth/ tel quel
# Rien à faire
```

#### Si config → à fusionner

```powershell
# Exemple: si config contient juste des constantes
# → Fusionner dans packages/utils/
Move-Item packages\config\src\* packages\utils\src\config\
Remove-Item -Recurse packages\config\
```

#### Si sanity → storefront

```powershell
# Déplacer dans storefront
Move-Item packages\sanity\ apps\storefront\sanity\

# Mettre à jour les imports dans storefront
# Remplacer "@repo/sanity" par "@/sanity" ou "../sanity"
```

---

### PHASE 4️⃣ : Migration modules/ → packages/tools/

**Durée estimée:** 2 heures

**Pour chaque module:**

```powershell
# Exemple avec products:

# 1. Créer la structure tool
New-Item -ItemType Directory packages\tools\products\src\api
New-Item -ItemType Directory packages\tools\products\src\components
New-Item -ItemType Directory packages\tools\products\src\hooks
New-Item -ItemType Directory packages\tools\products\src\routes
New-Item -ItemType Directory packages\tools\products\__tests__

# 2. Copier depuis site_v1_next (SOURCE DE VÉRITÉ)
# API = src/app/api/admin/products/
# Components = src/app/admin/products/ + src/components/admin/ (liés produits)
# Stores = src/store/useProductStore.ts

# 3. Créer package.json (copier de tools/newsletter/)
Copy-Item packages\tools\newsletter\package.json packages\tools\products\
# Adapter le nom: "@repo/tools-products"

# 4. Créer manifest.ts
# Copier de tools/newsletter/src/manifest.ts

# 5. Tester le build
cd packages\tools\products\
pnpm build

# 6. Supprimer modules/products/ seulement après validation
Remove-Item -Recurse modules\products\
```

**Ordre recommandé:**

1. ✅ newsletter (déjà fait)
2. products (complexe, faire en premier pour avoir le pattern)
3. orders
4. customers
5. media
6. analytics (fusion avec packages/tools/analytics/ existant)

---

### PHASE 5️⃣ : Validation finale

**Durée estimée:** 30 minutes

```powershell
# 1. Vérifier qu'il ne reste pas de modules/
Test-Path modules\  # Doit retourner False

# 2. Build complet
pnpm install
pnpm build

# 3. Type-check
pnpm type-check

# 4. Tests
pnpm test

# 5. Dev local
pnpm dev

# Tester:
# - Admin login
# - Navigation entre tools
# - CRUD dans products, orders, customers
# - Newsletter subscription (storefront)
```

---

## 📊 RÉSULTAT FINAL ATTENDU

### Structure nettoyée et organisée:

```
blancherenaudin-monorepo/
├── apps/
│   ├── admin/              ✅ Shell léger + registry
│   └── storefront/         ✅ Site public complet
│
├── packages/
│   ├── Core (racine)
│   │   ├── database/       ✅
│   │   ├── email/          ✅
│   │   ├── ui/             ✅
│   │   ├── auth/           ✅ (si décision A)
│   │   └── utils/          ✅
│   │
│   ├── Configuration
│   │   ├── eslint-config/  ✅
│   │   ├── typescript-config/ ✅
│   │   └── tailwind-config/ ✅ (si créé)
│   │
│   └── tools/              ✅ Tous les modules métier
│       ├── analytics/      ✅
│       ├── customers/      ✅ (migré)
│       ├── media/          ✅ (migré)
│       ├── newsletter/     ✅
│       ├── orders/         ✅ (migré)
│       └── products/       ✅ (migré)
│
├── scripts/                ✅ Nettoyé (utiles uniquement)
├── tests/                  ✅
└── docs/                   ✅ (si archivage d'audits)
```

### Packages supprimés:

* ❌ packages/admin-shell/
* ❌ packages/analytics/ (doublon)
* ❌ packages/shipping/
* ❌ modules/
* ❌ Tous les .backup-*
* ❌ Scripts one-shot

### Packages réorganisés:

* 🔄 packages/auth/ (selon décision)
* 🔄 packages/config/ (selon décision)
* 🔄 packages/sanity/ (selon décision)

---

## ✅ CHECKLIST DE VALIDATION

### Après Phase 1 (suppressions)

* [ ] `pnpm install` sans erreur
* [ ] `pnpm build` passe
* [ ] Aucun import cassé vers packages supprimés
* [ ] Apps démarrent en dev

### Après Phase 2 (analyses)

* [ ] Décision prise pour auth/
* [ ] Décision prise pour config/
* [ ] Décision prise pour sanity/
* [ ] Inventaire modules/ vs site_v1_next fait

### Après Phase 3 (réorganisation)

* [ ] Packages réorganisés selon décisions
* [ ] Imports mis à jour
* [ ] Build passe
* [ ] Type-check OK

### Après Phase 4 (migration modules/)

* [ ] Tous les tools migrés dans packages/tools/
* [ ] Chaque tool a sa structure complète
* [ ] Chaque tool a son manifest.ts
* [ ] modules/ supprimé
* [ ] Build + type-check OK

### Après Phase 5 (validation)

* [ ] Structure finale propre
* [ ] 0 fichiers .backup-*
* [ ] 0 doublons de packages
* [ ] Tests passent
* [ ] Apps fonctionnelles en dev
* [ ] Documentation à jour

---

## 🎯 APRÈS LE NETTOYAGE

Une fois le monorepo nettoyé, vous pourrez:

1. **Continuer la migration** depuis site_v1_next en toute clarté
2. **Ajouter de nouveaux tools** facilement (structure standardisée)
3. **Comprendre l'architecture** rapidement (organisation cohérente)
4. **Collaborer efficacement** (pas de confusion sur l'emplacement du code)

### Prochaines étapes après nettoyage:

1. Migrer les modules admin restants de site_v1_next
2. Implémenter le Registry complet
3. Ajouter les tests E2E
4. Optimiser les performances (lazy loading)
5. CI/CD

---

## 📝 NOTES IMPORTANTES

### ⚠️ Pendant le nettoyage:

1. **Commit fréquemment** (chaque phase = 1 commit)
2. **Tester après chaque phase**
3. **Ne pas hésiter à consulter site_v1_next** en cas de doute
4. **Documenter les décisions** prises (pourquoi auth → core, etc.)

### 💡 Si quelque chose casse:

1. **Pas de panique** - site_v1_next est la référence
2. **Identifier le package cassé**
3. **Re-migrer depuis site_v1_next** (source de vérité)
4. **Commit la correction**

---

**Document créé le:** 31 octobre 2025

**Version:** 1.0

**Statut:** Plan de nettoyage prêt à exécuter

**Référence:** site_v1_next (source de vérité)
