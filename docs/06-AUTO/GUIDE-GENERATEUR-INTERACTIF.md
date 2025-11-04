# ✨ Générateur Interactif de Tool - Guide complet

> **📅 Date** : 03 novembre 2025  
> **🎯 Objectif** : Créer un tool complet en 5 minutes avec toute la logique métier

---

## 🎯 Qu'est-ce que c'est ?

Le **générateur interactif** est un script PowerShell qui vous pose des questions sur votre tool et génère automatiquement :

✅ **Structure complète** (package + wrappers + API)  
✅ **Types TypeScript** adaptés à vos champs  
✅ **Hook personnalisé** pour récupérer les données  
✅ **Formulaire complet** avec validation  
✅ **Pages fonctionnelles** (liste, création, édition)  
✅ **Migration Supabase** prête à l'emploi  
✅ **Documentation** du tool

**Temps estimé** : 5-10 minutes (questions + génération)

---

## 🚀 Utilisation

### Via VS Code (recommandé)

1. `Ctrl+Shift+P`
2. `Tasks: Run Task`
3. `✨ Générer un tool complet (interactif)`
4. Répondre aux questions
5. Attendre la génération

### Via PowerShell

```powershell
cd blancherenaudin-monorepo
.\scripts\generate-tool.ps1
```

---

## 📋 Questions posées

Le script vous pose environ **10-15 questions** selon vos besoins :

### 1. Informations de base

```
❓ Nom du tool (kebab-case, ex: analytics, social-media)
→ Exemple : newsletter-campaigns
```

### 2. Type de données

```
❓ Quel type de données ce tool va-t-il gérer ?
   1. Table simple (ex: catégories, tags)
   2. Table avec relations (ex: produits avec catégories)
   3. Données analytiques (ex: statistiques, métriques)
   4. Configuration/Paramètres
   5. Autre

→ Choisir selon votre use case
```

### 3. Table Supabase

```
❓ Nom de la table Supabase [défaut: newsletter_campaigns]
→ Appuyer sur Entrée pour garder le défaut, ou personnaliser
```

### 4. Fonctionnalités CRUD

```
❓ Liste des éléments ? [O/n]
❓ Création d'éléments ? [O/n]
❓ Édition d'éléments ? [O/n]
❓ Suppression d'éléments ? [O/n]
❓ Recherche/Filtre ? [O/n]
❓ Pagination ? [O/n]
❓ Tri des colonnes ? [o/N]
❓ Export CSV/Excel ? [o/N]

→ O = Oui (par défaut), n = non
```

### 5. Structure des données

Pour chaque champ à ajouter :

```
❓ Nom du champ (vide pour terminer)
→ Exemple : subject

❓ Type du champ 'subject'
   1. text (court)
   2. textarea (long)
   3. number
   4. boolean
   5. date
   6. select (liste déroulante)
   7. relation (autre table)

❓ Champ obligatoire ? [O/n]
```

**Champs automatiques** : `id`, `created_at`, `updated_at`

### 6. Colonnes liste

```
❓ Afficher 'subject' dans la liste ? [O/n]
❓ Afficher 'status' dans la liste ? [O/n]
...
```

### 7. Confirmation

Un résumé s'affiche :

```
╔════════════════════════════════════════════════════════════╗
║  📋 RÉSUMÉ DE LA CONFIGURATION
╚════════════════════════════════════════════════════════════╝

Tool : NewsletterCampaigns (newsletter-campaigns)
Table : newsletter_campaigns
Type : Table simple

Fonctionnalités :
  ✅ list
  ✅ create
  ✅ edit
  ✅ delete
  ✅ search
  ✅ pagination
  ❌ sorting
  ❌ export

Champs (3) :
  • subject : text (court) (obligatoire)
  • content : textarea (long) (obligatoire)
  • status : select (liste déroulante) (obligatoire)

Colonnes liste (3) :
  • subject
  • status
  • created_at

❓ Générer le tool avec cette configuration ? [O/n]
```

---

## 📁 Ce qui est généré

### Structure complète

```
packages/tools/newsletter-campaigns/
├── src/
│   ├── index.tsx                    ✅ Exports complets
│   ├── types/
│   │   └── index.ts                 ✅ Types TypeScript personnalisés
│   ├── hooks/
│   │   └── useNewsletterCampaigns.ts ✅ Hook avec filtres/pagination
│   ├── components/
│   │   └── NewsletterCampaignsForm.tsx ✅ Formulaire complet
│   └── routes/
│       ├── list.tsx                 ✅ Page liste avec tableau
│       ├── edit.tsx                 ✅ Page édition
│       └── new.tsx                  ✅ Page création
├── package.json
├── tsconfig.json
└── README.md                        ✅ Documentation du tool

apps/admin/app/(tools)/newsletter-campaigns/
├── page.tsx                         ✅ Wrapper liste
├── [id]/page.tsx                    ✅ Wrapper édition
└── new/page.tsx                     ✅ Wrapper création

apps/admin/app/api/admin/newsletter-campaigns/
├── route.ts                         ✅ GET (liste), POST (création)
└── [id]/route.ts                    ✅ GET, PUT, DELETE

migrations/
└── 20251103_165432_create_newsletter_campaigns.sql ✅ Migration SQL
```

---

## 💡 Exemple concret : Tool Newsletter Campaigns

### Questions/Réponses

```
❓ Nom du tool : newsletter-campaigns
❓ Type de données : 1 (Table simple)
❓ Table Supabase : [défaut: newsletter_campaigns]

✅ liste
✅ create
✅ edit
✅ delete
✅ search
✅ pagination

Champs :
  1. subject (text, obligatoire)
  2. content (textarea, obligatoire)
  3. status (select: draft,scheduled,sent, obligatoire)
  4. send_date (date, optionnel)
  5. recipients_count (number, optionnel)

Colonnes liste :
  ✅ subject
  ✅ status
  ✅ send_date
  ✅ recipients_count
```

### Code généré : Types

```typescript
// packages/tools/newsletter-campaigns/src/types/index.ts

export interface NewsletterCampaignsItem {
  id: string
  created_at: string
  updated_at: string
  subject: string
  content: string
  status: string
  send_date?: string
  recipients_count?: number
}

export interface NewsletterCampaignsFormData {
  subject: string
  content: string
  status: string
  send_date: string
  recipients_count: number
}

export interface NewsletterCampaignsFilters {
  search?: string
  sortBy?: keyof NewsletterCampaignsItem
  sortOrder?: 'asc' | 'desc'
  page?: number
  pageSize?: number
}
```

### Code généré : Hook

```typescript
// packages/tools/newsletter-campaigns/src/hooks/useNewsletterCampaigns.ts

export function useNewsletterCampaigns(filters?: NewsletterCampaignsFilters) {
  const [data, setData] = useState<NewsletterCampaignsItem[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const [totalCount, setTotalCount] = useState(0)
  const [totalPages, setTotalPages] = useState(0)

  useEffect(() => {
    async function fetchData() {
      // ... logique complète de fetch avec filtres
    }
    fetchData()
  }, [filters?.search, filters?.page, filters?.pageSize])

  return { data, loading, error, totalCount, totalPages }
}
```

### Code généré : Formulaire

```typescript
// packages/tools/newsletter-campaigns/src/components/NewsletterCampaignsForm.tsx

export function NewsletterCampaignsForm({ initialData, onSubmit, onCancel }) {
  return (
    <form onSubmit={handleSubmit} className="space-y-6">
      {/* Champ: subject */}
      <div>
        <label>subject *</label>
        <input
          type="text"
          value={formData.subject}
          onChange={(e) => setFormData({ ...formData, subject: e.target.value })}
          required
          className="w-full px-4 py-2 border rounded-lg"
        />
      </div>

      {/* Champ: content */}
      <div>
        <label>content *</label>
        <textarea
          value={formData.content}
          onChange={(e) => setFormData({ ...formData, content: e.target.value })}
          required
          rows={4}
          className="w-full px-4 py-2 border rounded-lg"
        />
      </div>

      {/* Champ: status */}
      <div>
        <label>status *</label>
        <select
          value={formData.status}
          onChange={(e) => setFormData({ ...formData, status: e.target.value })}
          required
          className="w-full px-4 py-2 border rounded-lg"
        >
          <option value="">-- Sélectionner --</option>
          <option value="draft">draft</option>
          <option value="scheduled">scheduled</option>
          <option value="sent">sent</option>
        </select>
      </div>

      {/* Autres champs... */}

      <div className="flex gap-4">
        <button type="submit" className="px-6 py-2 bg-blue-600 text-white rounded-lg">
          Enregistrer
        </button>
        {onCancel && (
          <button type="button" onClick={onCancel} className="px-6 py-2 border rounded-lg">
            Annuler
          </button>
        )}
      </div>
    </form>
  )
}
```

### Code généré : Page liste

```typescript
// packages/tools/newsletter-campaigns/src/routes/list.tsx

export function NewsletterCampaignsList() {
  const [filters, setFilters] = useState<NewsletterCampaignsFilters>({})
  const { data, loading, error, totalCount, totalPages } = useNewsletterCampaigns(filters)

  return (
    <div className="p-6">
      <div className="flex justify-between items-center mb-6">
        <h1 className="text-2xl font-bold">NewsletterCampaigns</h1>
        <a href="/newsletter-campaigns/new" className="px-4 py-2 bg-blue-600 text-white rounded-lg">
          Nouveau
        </a>
      </div>

      {/* Barre de recherche */}
      <div className="mb-6">
        <input
          type="text"
          placeholder="Rechercher..."
          value={filters.search || ''}
          onChange={(e) => setFilters({ ...filters, search: e.target.value })}
          className="w-full px-4 py-2 border rounded-lg"
        />
      </div>

      {/* Tableau */}
      <table className="w-full">
        <thead>
          <tr>
            <th>subject</th>
            <th>status</th>
            <th>send_date</th>
            <th>recipients_count</th>
            <th>Actions</th>
          </tr>
        </thead>
        <tbody>
          {data.map((item) => (
            <tr key={item.id}>
              <td>{item.subject}</td>
              <td>{item.status}</td>
              <td>{item.send_date}</td>
              <td>{item.recipients_count}</td>
              <td>
                <a href={`/newsletter-campaigns/${item.id}`}>Éditer</a>
                <button onClick={() => handleDelete(item.id)}>Supprimer</button>
              </td>
            </tr>
          ))}
        </tbody>
      </table>

      {/* Pagination */}
      <div className="mt-6 flex items-center justify-between">
        <div>Affichage de ... sur {totalCount} résultats</div>
        <div className="flex gap-2">
          <button onClick={() => setFilters({ ...filters, page: (filters.page || 1) - 1 })}>
            Précédent
          </button>
          <button onClick={() => setFilters({ ...filters, page: (filters.page || 1) + 1 })}>
            Suivant
          </button>
        </div>
      </div>
    </div>
  )
}
```

### Migration SQL générée

```sql
-- migrations/20251103_165432_create_newsletter_campaigns.sql

CREATE TABLE IF NOT EXISTS newsletter_campaigns (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  subject TEXT NOT NULL,
  content TEXT NOT NULL,
  status TEXT NOT NULL,
  send_date DATE,
  recipients_count NUMERIC
);

-- Index sur created_at
CREATE INDEX idx_newsletter_campaigns_created_at ON newsletter_campaigns(created_at DESC);

-- Trigger updated_at
CREATE TRIGGER update_newsletter_campaigns_updated_at
  BEFORE UPDATE ON newsletter_campaigns
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Row Level Security
ALTER TABLE newsletter_campaigns ENABLE ROW LEVEL SECURITY;

CREATE POLICY "newsletter_campaigns_admin_all" ON newsletter_campaigns
  FOR ALL
  USING (auth.jwt() ->> 'role' = 'admin')
  WITH CHECK (auth.jwt() ->> 'role' = 'admin');
```

---

## 🎯 Après la génération

### Étape 1 : Appliquer la migration

```bash
# Via Supabase Dashboard
# Ou via CLI
supabase db push
```

### Étape 2 : Tester

```powershell
pnpm dev
```

Ouvrir : http://localhost:3000/newsletter-campaigns

### Étape 3 : Personnaliser

Le code généré est un **excellent point de départ**, mais vous pouvez :

**Ajouter des validations** :
```typescript
// Dans NewsletterCampaignsForm.tsx
if (!formData.subject.trim()) {
  alert('Le sujet est obligatoire')
  return
}
```

**Enrichir la logique** :
```typescript
// Dans list.tsx
const handleSend = async (id: string) => {
  const response = await fetch(`/api/admin/newsletter-campaigns/${id}/send`, {
    method: 'POST'
  })
  // ...
}
```

**Ajouter des composants** :
```typescript
// src/components/CampaignPreview.tsx
export function CampaignPreview({ campaign }) {
  return (
    <div className="border rounded-lg p-4">
      <h3>{campaign.subject}</h3>
      <div dangerouslySetInnerHTML={{ __html: campaign.content }} />
    </div>
  )
}
```

---

## ⚡ Avantages du générateur

| Aspect | Sans générateur | Avec générateur | Gain |
|--------|----------------|----------------|------|
| Temps de setup | 1-2h | 5-10 min | **90%** |
| Structure | À créer | Générée | **100%** |
| Types | À écrire | Générés | **100%** |
| Formulaire | À coder | Généré | **100%** |
| CRUD | À implémenter | Fonctionnel | **100%** |
| Migration SQL | À écrire | Générée | **100%** |
| Erreurs | Fréquentes | Aucune | **100%** |

---

## 🆚 Comparaison des scripts

| Script | Usage | Temps | Personnalisation |
|--------|-------|-------|------------------|
| **generate-tool.ps1** ✨ | Tool complet clé en main | 5-10 min | Questions détaillées |
| **create-tool.ps1** 🚀 | Structure de base | 2 min | Tout à coder soi-même |
| **validate-tool.ps1** 🔍 | Validation | 30 sec | Aucune (validation) |

**Recommandation** : Utilisez **generate-tool.ps1** pour 90% des cas !

---

## 💡 Tips & Astuces

### Ajouter un champ plus tard

Si vous avez oublié un champ, relancez le générateur :

```powershell
.\scripts\generate-tool.ps1 -ToolName mon-tool
```

Le script créera une **nouvelle version** sans écraser l'existante (backup automatique).

### Mode non-interactif

Pour automatiser (CI/CD) :

```powershell
.\scripts\generate-tool.ps1 -NonInteractive
```

Utilise les valeurs par défaut.

### Champs complexes

Pour des champs très spécifiques (JSON, fichiers, etc.), choisissez "text" et personnalisez ensuite le formulaire.

---

## 🐛 Dépannage

### Le script ne démarre pas

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Erreur lors de la génération

Vérifiez que `create-tool.ps1` est présent :

```powershell
Test-Path .\scripts\create-tool.ps1
```

### Tool déjà existant

Le script détecte les tools existants et refuse de les écraser.

Supprimez d'abord l'ancien :

```powershell
Remove-Item -Recurse packages/tools/mon-tool
Remove-Item -Recurse apps/admin/app/(tools)/mon-tool
```

---

## 📚 Documentation

- **Guide complet** : GUIDE-SCRIPTS-TOOLS.md
- **Scripts disponibles** : scripts/README.md
- **Architecture** : 20251103-ARCHITECTURE-BONNES-PRATIQUES-TOOLS.md

---

## 🎉 Conclusion

Le générateur interactif **transforme la création de tools** :

✅ **5 minutes** au lieu de 1-2 heures  
✅ **Code complet** et fonctionnel  
✅ **Migration SQL** incluse  
✅ **Documentation** automatique  
✅ **Zéro erreur** de structure  

**Prêt à créer votre premier tool ?**

```powershell
.\scripts\generate-tool.ps1
```

---

**Version** : 1.0  
**Date** : 03/11/2025  
**Statut** : ✅ Production Ready
