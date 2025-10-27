# 🚀 Scripts de Migration Monorepo - Blanche Renaudin

Collection de scripts PowerShell pour gérer la migration du projet vers une architecture monorepo.

## 📋 Vue d'ensemble

Ces scripts vous permettent de :
- ✅ Vérifier l'état de la migration
- ✅ Analyser les routes Stripe en détail
- ✅ Migrer automatiquement des routes API
- ✅ Déployer des fichiers corrigés
- ✅ Générer des rapports de progression

## 🛠️ Prérequis

- **PowerShell 7+** (recommandé) ou PowerShell 5.1+
- **Node.js 18+** et **pnpm**
- **Git** pour le versioning
- **Stripe CLI** pour tester les webhooks

## 📦 Scripts disponibles

### 1. `master-migration.ps1` - Script principal

Le point d'entrée pour toutes les opérations.

```powershell
# Voir l'état général de la migration
.\master-migration.ps1 -ProjectRoot "C:\projets\blanche-renaudin" -Action status

# Vérifier les routes Stripe en détail
.\master-migration.ps1 -ProjectRoot "C:\projets\blanche-renaudin" -Action stripe-check

# Migrer les routes Stripe
.\master-migration.ps1 -ProjectRoot "C:\projets\blanche-renaudin" -Action migrate-stripe

# Voir les commandes de test Stripe
.\master-migration.ps1 -ProjectRoot "C:\projets\blanche-renaudin" -Action test-stripe

# Exécuter toutes les vérifications
.\master-migration.ps1 -ProjectRoot "C:\projets\blanche-renaudin" -Action all
```

**Actions disponibles:**
- `status` - État général (défaut)
- `stripe-check` - Vérification détaillée Stripe
- `migrate-stripe` - Migration routes Stripe
- `test-stripe` - Guide de test
- `all` - Toutes les vérifications

---

### 2. `explore-migration-status.ps1` - État détaillé

Explore la structure du monorepo et liste tous les modules/routes existants.

```powershell
.\explore-migration-status.ps1 -ProjectRoot "C:\projets\blanche-renaudin"
```

**Affiche:**
- ✅ Liste des packages avec nombre de composants/templates
- ✅ Applications et nombre de pages
- ✅ Routes API par application
- ✅ Routes critiques Stripe
- ✅ Pourcentage de complétion

---

### 3. `check-stripe-routes.ps1` - Analyse Stripe

Analyse en profondeur les routes liées à Stripe.

```powershell
.\check-stripe-routes.ps1 -ProjectRoot "C:\projets\blanche-renaudin"
```

**Pour chaque route, affiche:**
- 📏 Nombre de lignes de code
- 📦 Imports utilisés
- 🔧 Fonctions implémentées
- 🌐 Méthodes HTTP exportées
- 🔍 Dépendances (Stripe, Supabase, Email)
- ⚠️ Détection de stubs

---

### 4. `migrate-api-route.ps1` - Migration automatique

Migre des routes API de l'ancien projet vers le monorepo avec transformation automatique des imports.

```powershell
# Migration avec dry-run (simulation)
.\migrate-api-route.ps1 `
  -OldProjectRoot "C:\projets\site_v1_next" `
  -NewProjectRoot "C:\projets\blanche-renaudin-monorepo" `
  -RouteType "stripe" `
  -DryRun

# Migration réelle
.\migrate-api-route.ps1 `
  -OldProjectRoot "C:\projets\site_v1_next" `
  -NewProjectRoot "C:\projets\blanche-renaudin-monorepo" `
  -RouteType "stripe"

# Migrer toutes les routes
.\migrate-api-route.ps1 `
  -OldProjectRoot "C:\projets\site_v1_next" `
  -NewProjectRoot "C:\projets\blanche-renaudin-monorepo" `
  -RouteType "all"
```

**Types de routes:**
- `stripe` - Webhook Stripe uniquement
- `checkout` - Routes de checkout
- `orders` - Routes de commandes
- `newsletter` - Routes newsletter
- `all` - Toutes les routes

**Transformations automatiques:**
```typescript
// Avant
from '@/lib/stripe'
from '@/lib/supabase-admin'
from '@/lib/email/send'
from '@/components/ui/button'

// Après
from '@repo/database/server'
from '@repo/database/server'
from '@repo/email'
from '@repo/ui/button'
```

---

### 5. `deploy-stripe-webhook.ps1` - Déploiement webhook

Déploie la version corrigée du webhook Stripe avec backup automatique.

```powershell
# Dry-run (voir ce qui serait fait)
.\deploy-stripe-webhook.ps1 `
  -ProjectRoot "C:\projets\blanche-renaudin-monorepo" `
  -SourceFile "webhook_stripe_route_ts_-_VERSION_CORRIGÉE_COMPLÈTE.txt" `
  -DryRun

# Déploiement avec backup
.\deploy-stripe-webhook.ps1 `
  -ProjectRoot "C:\projets\blanche-renaudin-monorepo" `
  -SourceFile "webhook_stripe_route_ts_-_VERSION_CORRIGÉE_COMPLÈTE.txt" `
  -Backup
```

**Fonctionnalités:**
- ✅ Backup automatique de l'ancien fichier
- ✅ Transformation des imports
- ✅ Vérification des dépendances
- ✅ Validation post-déploiement
- ✅ Guide des prochaines étapes

---

### 6. `generate-migration-report.ps1` - Rapport Markdown

Génère un rapport Markdown complet de l'état de la migration.

```powershell
.\generate-migration-report.ps1 `
  -ProjectRoot "C:\projets\blanche-renaudin-monorepo" `
  -OutputFile "MIGRATION-REPORT.md"
```

**Le rapport contient:**
- 📊 Vue d'ensemble avec progression globale
- 📦 État détaillé de chaque package
- 🏪 État des applications
- 💳 Analyse des routes Stripe
- 🎯 Recommandations priorisées
- 📈 Métriques et statistiques

---

## 🎯 Workflow recommandé

### Étape 1: Vérification initiale

```powershell
# 1. Voir l'état global
.\master-migration.ps1 -ProjectRoot "C:\mon-projet" -Action status

# 2. Générer un rapport détaillé
.\generate-migration-report.ps1 -ProjectRoot "C:\mon-projet"
```

### Étape 2: Migration des routes Stripe

```powershell
# 1. Vérifier ce qui existe déjà
.\check-stripe-routes.ps1 -ProjectRoot "C:\mon-projet"

# 2. Migrer depuis l'ancien projet (si applicable)
.\migrate-api-route.ps1 `
  -OldProjectRoot "C:\ancien-projet" `
  -NewProjectRoot "C:\mon-projet" `
  -RouteType "stripe" `
  -DryRun  # Test d'abord

# 3. Déployer la version corrigée du webhook
.\deploy-stripe-webhook.ps1 `
  -ProjectRoot "C:\mon-projet" `
  -SourceFile "webhook_stripe_route_ts_-_VERSION_CORRIGÉE_COMPLÈTE.txt" `
  -Backup
```

### Étape 3: Tests

```powershell
# 1. Voir le guide de test
.\master-migration.ps1 -ProjectRoot "C:\mon-projet" -Action test-stripe

# 2. Lancer le dev server
cd C:\mon-projet\apps\storefront
pnpm dev

# 3. Dans un autre terminal, lancer Stripe CLI
stripe listen --forward-to localhost:3000/api/webhooks/stripe

# 4. Tester un événement
stripe trigger checkout.session.completed
```

---

## 🐛 Troubleshooting

### Erreur: "Impossible d'exécuter le script"

**Problème:** Politique d'exécution PowerShell

```powershell
# Solution temporaire (session actuelle)
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process

# Solution permanente (administrateur requis)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Les imports ne sont pas transformés

**Problème:** Script ne détecte pas les anciens imports

```powershell
# Vérifier le format du fichier source
Get-Content "chemin\vers\route.ts" | Select-String "@/"

# Forcer la transformation manuelle
$content = Get-Content "route.ts" -Raw
$content = $content -replace "from '@/lib/stripe'", "from '@repo/database/server'"
Set-Content "route.ts" -Value $content
```

### Le webhook ne reçoit pas les événements

**Vérifications:**

1. Stripe CLI est connecté: `stripe login`
2. Le forward fonctionne: `stripe listen --forward-to localhost:3000/api/webhooks/stripe`
3. Le serveur dev tourne: `pnpm dev` dans `apps/storefront`
4. La route existe: vérifier `apps/storefront/app/api/webhooks/stripe/route.ts`

---

## 📝 Exemples complets

### Exemple 1: Première utilisation

```powershell
# 1. Cloner le repo
cd C:\projets
git clone [repo] blanche-renaudin-monorepo
cd blanche-renaudin-monorepo

# 2. Vérifier l'état
.\scripts\master-migration.ps1 -Action status

# 3. Générer un rapport
.\scripts\generate-migration-report.ps1

# 4. Ouvrir le rapport
code MIGRATION-REPORT-2025-10-27.md
```

### Exemple 2: Migration complète depuis ancien projet

```powershell
# Définir les chemins
$OLD = "C:\projets\site_v1_next"
$NEW = "C:\projets\blanche-renaudin-monorepo"

# 1. Test à sec
.\migrate-api-route.ps1 -OldProjectRoot $OLD -NewProjectRoot $NEW -RouteType "all" -DryRun

# 2. Migration réelle
.\migrate-api-route.ps1 -OldProjectRoot $OLD -NewProjectRoot $NEW -RouteType "all"

# 3. Vérifier le résultat
.\check-stripe-routes.ps1 -ProjectRoot $NEW

# 4. Déployer la version corrigée du webhook
.\deploy-stripe-webhook.ps1 -ProjectRoot $NEW -Backup
```

### Exemple 3: Workflow quotidien

```powershell
# Matin: Check status
.\master-migration.ps1 -Action status

# Après chaque modification: Vérifier Stripe
.\check-stripe-routes.ps1 -ProjectRoot "C:\mon-projet"

# Fin de journée: Générer rapport
.\generate-migration-report.ps1 -ProjectRoot "C:\mon-projet"
git add MIGRATION-REPORT-*.md
git commit -m "docs: update migration report"
```

---

## 🔧 Personnalisation

### Ajouter une nouvelle route à migrer

Éditer `migrate-api-route.ps1`:

```powershell
# Ajouter dans la section "Définir les routes à migrer"
if ($RouteType -eq "mon-type" -or $RouteType -eq "all") {
    $routesToMigrate += @{
        Name = "Ma Nouvelle Route"
        Source = "src\app\api\ma-route\route.ts"
        Dest = "apps\storefront\app\api\ma-route\route.ts"
    }
}
```

### Ajouter une transformation d'import

Éditer `migrate-api-route.ps1` ou `deploy-stripe-webhook.ps1`:

```powershell
# Ajouter dans $replacements
"from '@/lib/mon-module'" = "from '@repo/mon-package'"
```

---

## 📚 Ressources

- **Documentation Turborepo:** https://turbo.build/repo/docs
- **pnpm Workspaces:** https://pnpm.io/workspaces
- **Stripe CLI:** https://stripe.com/docs/stripe-cli

---

## 🤝 Support

Pour toute question ou problème:

1. Générer un rapport: `.\generate-migration-report.ps1`
2. Consulter le fichier de logs
3. Vérifier les erreurs TypeScript: `pnpm tsc --noEmit`

---

**Version:** 1.0.0  
**Dernière mise à jour:** 27 octobre 2025  
**Auteur:** Scripts de migration Blanche Renaudin

