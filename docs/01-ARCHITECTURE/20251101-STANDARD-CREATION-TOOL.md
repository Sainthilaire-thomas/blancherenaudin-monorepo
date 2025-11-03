# 📘 Standard de Création d'un Nouveau Tool (v2.0)

**Version :** 2.0

**Date :** 28 octobre 2025

**Projet :** Blanche Renaudin Monorepo

---

## 🎯 Vue d'ensemble

Ce document décrit le processus standardisé pour créer un nouveau tool. Il distingue :

* ✅ **Les éléments universels** (obligatoires pour tous les tools)
* 🎨 **Les patterns spécifiques** (selon le type de tool)

---

## 📋 Table des matières

1. [Éléments Universels](#%C3%A9l%C3%A9ments-universels) ⭐
2. [Types de Tools](#types-de-tools)
3. [Pattern CRUD (Products, Orders, Customers)](#pattern-crud)
4. [Pattern Dashboard (Analytics, Social Networks)](#pattern-dashboard)
5. [Pattern Configuration (SEO, Shipping)](#pattern-configuration)
6. [Pattern Hybrid (Newsletter, Media)](#pattern-hybrid)
7. [Checklist Universelle](#checklist-universelle)

---

## Éléments Universels

### ⭐ Obligatoire pour TOUS les tools

Ces éléments doivent être présents  **peu importe le type de tool** .

---

### 1. Structure de Base (Universelle)

```
tools/[nom-tool]/
├── package.json              # ⭐ UNIVERSEL
├── tsconfig.json             # ⭐ UNIVERSEL
├── README.md                 # ⭐ UNIVERSEL
└── src/
    ├── index.tsx             # ⭐ UNIVERSEL - Point d'entrée avec routing
    └── config.ts             # ⭐ UNIVERSEL - Configuration du tool
```

**Le reste de la structure varie selon le type de tool.**

---

### 2. package.json (Universel)

json

```json
{
"name":"@tools/[nom-tool]",
"version":"0.0.0",
"private":true,
"main":"./src/index.tsx",
"types":"./src/index.tsx",
"scripts":{
"lint":"eslint . --max-warnings 0",
"type-check":"tsc --noEmit"
},
"dependencies":{
"@repo/admin-shell":"workspace:*",
"@repo/ui":"workspace:*",
"@repo/database":"workspace:*",
"lucide-react":"^0.263.1"
},
"devDependencies":{
"@repo/typescript-config":"workspace:*",
"typescript":"^5.3.0"
}
}
```

**Identique pour tous les tools.**

---

### 3. tsconfig.json (Universel)

json

```json
{
"extends":"@repo/typescript-config/base.json",
"compilerOptions":{
"jsx":"preserve",
"incremental":true,
"paths":{
"@/*":["./src/*"]
}
},
"include":["src/**/*"],
"exclude":["node_modules","dist",".turbo"]
}
```

**Identique pour tous les tools.**

---

### 4. config.ts (Universel)

typescript

```typescript
// tools/[nom]/src/config.ts
import{[IconName]}from'lucide-react'
importtype{ToolConfig}from'@repo/admin-shell/types'

exportconst[nom]ToolConfig:ToolConfig={
// ⭐ Identifiant unique (OBLIGATOIRE)
  id:'[nom]',
  
// ⭐ Nom affiché (OBLIGATOIRE)
  name:'[Nom Affiché]',
  
// ⭐ Icône Lucide React (OBLIGATOIRE)
  icon:[IconName],
  
// ⭐ Description (OBLIGATOIRE)
  description:'Description courte du tool',
  
// ⭐ Chemin de base (OBLIGATOIRE)
  basePath:'/[nom]',
  
// Permissions (OPTIONNEL)
  permissions:['[nom].view','[nom].manage'],
  
// Badge (OPTIONNEL)
  badge:undefined,
  
// Activé (OBLIGATOIRE)
  enabled:true,
}
```

**Structure identique, contenu adapté à chaque tool.**

---

### 5. index.tsx - Structure de Base (Universel)

**Tous les tools doivent avoir cette structure minimale :**

typescript

```typescript
// tools/[nom]/src/index.tsx
'use client'
importtype{ToolProps}from'@repo/admin-shell/types'

// ⭐ Export de la config (OBLIGATOIRE)
export{[nom]ToolConfig}from'./config'

/**
 * Tool [Nom] - Description
 * 
 * Routes supportées :
 * - /admin/[nom]
 * - (autres routes selon le type)
 */
exportdefaultfunction[Nom]Tool({ route, services }:ToolProps){
// ⭐ Routing interne (OBLIGATOIRE - à adapter selon le type)
  
// Route par défaut (/ ou liste)
if(!route || route.length===0){
return<DefaultView services={services}/>
}
  
// Autres routes selon le type de tool
return<div>Route non gérée:{route.join('/')}</div>
}
```

**Le routing interne varie selon le type, mais la structure reste identique.**

---

### 6. Enregistrement dans l'Admin (Universel)

typescript

```typescript
// apps/admin/admin.config.ts
import{[Nom]Tool,[nom]ToolConfig}from'@tools/[nom]'

exportconst adminTools =[
// ... autres tools
{
    config:[nom]ToolConfig,
    component:[Nom]Tool,
},
]
```

**Identique pour tous les tools.**

---

### 7. README.md (Universel)

**Tous les tools doivent avoir un README avec cette structure minimale :**

markdown

```markdown
# Tool: [Nom]

## Description

[Description détaillée du tool]

## Type

[CRUD / Dashboard / Configuration / Hybrid]

## Routes

-`/admin/[nom]` - [Description]
- (autres routes)

## Permissions

-`[nom].view` - [Description]
-`[nom].manage` - [Description]

## Base de Données

[Tables utilisées, si applicable]

## Développement
```bash
cd tools/[nom]
pnpm type-check
```

## TODO

- [ ] ...

```

---

## Types de Tools

### 🎨 Les 4 Types Principaux

| Type | Exemple | Caractéristiques |
|------|---------|------------------|
| **CRUD** | Products, Orders, Customers, Categories | Liste + Formulaire + Détail |
| **Dashboard** | Analytics, Social Networks | Graphiques + Métriques + Filtres temporels |
| **Configuration** | SEO, Shipping | Formulaire de paramètres + Preview |
| **Hybrid** | Newsletter, Media | Mix de plusieurs patterns |

---

## Pattern CRUD

### 📦 Pour : Products, Orders, Customers, Categories, Returns

**Cas d'usage :** Gérer des entités avec création, lecture, mise à jour, suppression.

---

### Structure Spécifique CRUD
```

tools/[nom]/src/
├── index.tsx                 # ⭐ UNIVERSEL
├── config.ts                 # ⭐ UNIVERSEL
│
├── pages/                    # 🎨 SPÉCIFIQUE CRUD
│   ├── [Nom]List.tsx         # Liste avec filtres
│   ├── [Nom]Form.tsx         # Création + Édition
│   └── [Nom]Detail.tsx       # Détail (optionnel si Form suffit)
│
├── components/               # 🎨 SPÉCIFIQUE CRUD
│   ├── [Nom]Card.tsx         # Card pour affichage liste
│   ├── [Nom]Filters.tsx      # Filtres avancés
│   └── [Nom]Actions.tsx      # Actions rapides (edit, delete)
│
└── types/
    └── [nom].types.ts        # Types métier

```




---


### Routing CRUD







typescript

```typescript
// tools/products/src/index.tsx
exportdefaultfunctionProductsTool({ route, services }:ToolProps){
// Route: /admin/products (liste)
if(!route || route.length===0){
return<ProductsList services={services}/>
}
  
// Route: /admin/products/new (création)
if(route[0]==='new'){
return<ProductForm mode="create" services={services}/>
}
  
// Route: /admin/products/123 (édition)
// Optionnel : si besoin de sous-routes
if(route.length===1){
return<ProductForm mode="edit" id={route[0]} services={services}/>
}
  
// Route: /admin/products/123/variants (sous-page optionnelle)
if(route.length===2&& route[1]==='variants'){
return<ProductVariants productId={route[0]} services={services}/>
}
  
return<div>Route non gérée</div>
}
```

**Routes typiques CRUD :**

- `/admin/[nom]` → Liste
- `/admin/[nom]/new` → Création
- `/admin/[nom]/[id]` → Édition/Détail
- `/admin/[nom]/[id]/[action]` → Sous-pages (optionnel)

---

### API Routes CRUD

```
apps/admin/app/api/admin/[nom]/
├── route.ts                    # GET(liste),POST(créer)
├── [id]/
│   └── route.ts                # GET(détail),PUT(màj),DELETE
└── stats/route.ts              # Statistiques(optionnel)
```

---

### Exemple : Tool Products (CRUD)

typescript

```typescript
// tools/products/src/index.tsx
'use client'
importtype{ToolProps}from'@repo/admin-shell/types'
import{ProductsList}from'./pages/ProductsList'
import{ProductForm}from'./pages/ProductForm'

export{ productsToolConfig }from'./config'

exportdefaultfunctionProductsTool({ route, services }:ToolProps){
if(!route || route.length===0){
return<ProductsList services={services}/>
}
  
if(route[0]==='new'){
return<ProductForm mode="create" services={services}/>
}
  
return<ProductForm mode="edit" id={route[0]} services={services}/>
}
```

typescript

```typescript
// tools/products/src/pages/ProductsList.tsx
'use client'
import{ useState, useEffect }from'react'
import{Button}from'@repo/ui/button'
import{Table}from'@repo/ui/table'

exportfunctionProductsList({ services }){
const[products, setProducts]=useState([])
const[loading, setLoading]=useState(true)
const[filters, setFilters]=useState({ search:'', category:'all'})
  
useEffect(()=>{
loadProducts()
},[filters])
  
asyncfunctionloadProducts(){
// Chargement avec filtres
}
  
return(
<div>
<h1>Produits</h1>
<Button onClick={()=> services.navigate(['new'])}>
Nouveau produit
</Button>
    
{/* Filtres */}
{/* Table */}
</div>
)
}
```

---

## Pattern Dashboard

### 📊 Pour : Analytics, Social Networks

**Cas d'usage :** Visualiser des métriques, graphiques, tableaux de bord avec filtres temporels.

---

### Structure Spécifique Dashboard

```
tools/[nom]/src/
├── index.tsx                 # ⭐ UNIVERSEL
├── config.ts                 # ⭐ UNIVERSEL
│
├── pages/                    # 🎨 SPÉCIFIQUEDASHBOARD
│   └── [Nom]Dashboard.tsx    # Dashboardprincipal(souvent la seule page)
│
├── components/               # 🎨 SPÉCIFIQUEDASHBOARD
│   ├── widgets/              # Widgets de métriques
│   │   ├── VisitorsWidget.tsx
│   │   ├── RevenueWidget.tsx
│   │   └── ConversionWidget.tsx
│   │
│   ├── charts/               # Graphiques
│   │   ├── LineChart.tsx
│   │   ├── BarChart.tsx
│   │   └── PieChart.tsx
│   │
│   └── filters/              # Filtres temporels
│       └── DateRangeFilter.tsx
│
└── lib/
    ├── data-fetchers.ts      # Fonctions de chargement data
    └── formatters.ts         # Formatage nombres, dates
```

---

### Routing Dashboard (Simple)

typescript

```typescript
// tools/analytics/src/index.tsx
exportdefaultfunctionAnalyticsTool({ route, services }:ToolProps){
// Dashboard principal par défaut
// Pas de routing complexe nécessaire
return<AnalyticsDashboard services={services}/>
}
```

**Routes typiques Dashboard :**

- `/admin/[nom]` → Dashboard principal (souvent unique)

**Pas de création/édition, donc routing très simple.**

---

### API Routes Dashboard

```
apps/admin/app/api/admin/[nom]/
├── metrics/route.ts            # Métriques agrégées
├── chart-data/route.ts         # Données pour graphiques
└── export/route.ts             # ExportCSV/PDF(optionnel)
```

---

### Exemple : Tool Analytics (Dashboard)

typescript

```typescript
// tools/analytics/src/index.tsx
'use client'
importtype{ToolProps}from'@repo/admin-shell/types'
import{AnalyticsDashboard}from'./pages/AnalyticsDashboard'

export{ analyticsToolConfig }from'./config'

exportdefaultfunctionAnalyticsTool({ route, services }:ToolProps){
// Pas de routing complexe
return<AnalyticsDashboard services={services}/>
}
```

typescript

```typescript
// tools/analytics/src/pages/AnalyticsDashboard.tsx
'use client'
import{ useState, useEffect }from'react'
import{Card}from'@repo/ui/card'
import{DateRangeFilter}from'../components/filters/DateRangeFilter'
import{VisitorsWidget}from'../components/widgets/VisitorsWidget'
import{RevenueWidget}from'../components/widgets/RevenueWidget'
import{LineChart}from'../components/charts/LineChart'

exportfunctionAnalyticsDashboard({ services }){
const[dateRange, setDateRange]=useState({from:'2024-01-01', to:'2024-12-31'})
const[metrics, setMetrics]=useState(null)
const[loading, setLoading]=useState(true)
  
useEffect(()=>{
loadMetrics()
},[dateRange])
  
asyncfunctionloadMetrics(){
const response =awaitfetch(`/api/admin/analytics/metrics?from=${dateRange.from}&to=${dateRange.to}`)
const data =await response.json()
setMetrics(data.metrics)
setLoading(false)
}
  
if(loading)return<div>Chargement...</div>
  
return(
<div className="space-y-6">
<h1 className="text-3xl font-bold">Analytics</h1>
    
{/* Filtres temporels */}
<DateRangeFilter value={dateRange} onChange={setDateRange}/>
    
{/* Widgets de métriques */}
<div className="grid grid-cols-3 gap-4">
<VisitorsWidget data={metrics.visitors}/>
<RevenueWidget data={metrics.revenue}/>
<ConversionWidget data={metrics.conversion}/>
</div>
    
{/* Graphiques */}
<Card>
<LineChart data={metrics.visitsOverTime}/>
</Card>
</div>
)
}
```

---

## Pattern Configuration

### ⚙️ Pour : SEO, Shipping, Email Settings

**Cas d'usage :** Gérer des paramètres globaux avec formulaire et preview.

---

### Structure Spécifique Configuration

```
tools/[nom]/src/
├── index.tsx                 # ⭐ UNIVERSEL
├── config.ts                 # ⭐ UNIVERSEL
│
├── pages/                    # 🎨 SPÉCIFIQUECONFIGURATION
│   └── [Nom]Settings.tsx     # Page unique de paramètres
│
├── components/               # 🎨 SPÉCIFIQUECONFIGURATION
│   ├── [Nom]Form.tsx         # Formulaire de config
│   ├── [Nom]Preview.tsx      # Preview des changements
│   └── [Nom]Test.tsx         # Tests(ex: tester SEO)
│
└── lib/
    └── validators.ts         # Validation des paramètres
```

---

### Routing Configuration (Simple)

typescript

```typescript
// tools/seo/src/index.tsx
exportdefaultfunctionSeoTool({ route, services }:ToolProps){
// Page unique de paramètres
return<SeoSettings services={services}/>
}
```

**Routes typiques Configuration :**

- `/admin/[nom]` → Page de paramètres unique

**Pas de liste/détail, juste un formulaire de config.**

---

### API Routes Configuration

```
apps/admin/app/api/admin/[nom]/
├── settings/route.ts           # GET(lire),PUT(sauvegarder)
└── test/route.ts               # Tester la config(optionnel)
```

---

### Exemple : Tool SEO (Configuration)

typescript

```typescript
// tools/seo/src/index.tsx
'use client'
importtype{ToolProps}from'@repo/admin-shell/types'
import{SeoSettings}from'./pages/SeoSettings'

export{ seoToolConfig }from'./config'

exportdefaultfunctionSeoTool({ route, services }:ToolProps){
// Page unique
return<SeoSettings services={services}/>
}
```

typescript

```typescript
// tools/seo/src/pages/SeoSettings.tsx
'use client'
import{ useState, useEffect }from'react'
import{Button}from'@repo/ui/button'
import{Card}from'@repo/ui/card'
import{SeoForm}from'../components/SeoForm'
import{SeoPreview}from'../components/SeoPreview'

exportfunctionSeoSettings({ services }){
const[settings, setSettings]=useState(null)
const[loading, setLoading]=useState(true)
  
useEffect(()=>{
loadSettings()
},[])
  
asyncfunctionloadSettings(){
const response =awaitfetch('/api/admin/seo/settings')
const data =await response.json()
setSettings(data.settings)
setLoading(false)
}
  
asyncfunctionhandleSave(){
const response =awaitfetch('/api/admin/seo/settings',{
      method:'PUT',
      headers:{'Content-Type':'application/json'},
      body:JSON.stringify(settings),
})
  
if(response.ok){
      services.notify('Paramètres SEO sauvegardés','success')
}
}
  
if(loading)return<div>Chargement...</div>
  
return(
<div className="space-y-6">
<h1 className="text-3xl font-bold">ConfigurationSEO</h1>
    
<div className="grid grid-cols-2 gap-6">
{/* Formulaire */}
<Card>
<SeoForm 
            value={settings} 
            onChange={setSettings} 
/>
</Card>
      
{/* Preview */}
<Card>
<SeoPreview settings={settings}/>
</Card>
</div>
    
<Button onClick={handleSave}>
Sauvegarder
</Button>
</div>
)
}
```

---

## Pattern Hybrid

### 🔀 Pour : Newsletter, Media

**Cas d'usage :** Mix de plusieurs patterns (liste + dashboard + config).

---

### Structure Spécifique Hybrid

```
tools/[nom]/src/
├── index.tsx                 # ⭐ UNIVERSEL
├── config.ts                 # ⭐ UNIVERSEL
│
├── pages/                    # 🎨 SPÉCIFIQUEHYBRID
│   ├── [Nom]Dashboard.tsx    # Vue d'ensemble(métriques)
│   ├── [Nom]List.tsx         # Liste des items
│   ├── [Nom]Form.tsx         # Formulaire
│   └── [Nom]Settings.tsx     # Paramètres(optionnel)
│
├── components/               # 🎨 Mix de plusieurs types
│   ├── widgets/              # Widgets dashboard
│   ├── cards/                # Cards liste
│   └── forms/                # Composants formulaire
│
└── lib/
    └── [nom]-helpers.ts
```

---

### Routing Hybrid (Complexe)

typescript

```typescript
// tools/newsletter/src/index.tsx
exportdefaultfunctionNewsletterTool({ route, services }:ToolProps){
// Route: /admin/newsletter (dashboard par défaut)
if(!route || route.length===0){
return<NewsletterDashboard services={services}/>
}
  
// Route: /admin/newsletter/campaigns (liste)
if(route[0]==='campaigns'){
return<CampaignsList services={services}/>
}
  
// Route: /admin/newsletter/campaigns/new (création)
if(route.length===2&& route[0]==='campaigns'&& route[1]==='new'){
return<CampaignForm mode="create" services={services}/>
}
  
// Route: /admin/newsletter/campaigns/123 (édition)
if(route.length===2&& route[0]==='campaigns'){
return<CampaignForm mode="edit" id={route[1]} services={services}/>
}
  
// Route: /admin/newsletter/subscribers (liste abonnés)
if(route[0]==='subscribers'){
return<SubscribersList services={services}/>
}
  
// Route: /admin/newsletter/settings (config)
if(route[0]==='settings'){
return<NewsletterSettings services={services}/>
}
  
return<div>Route non gérée</div>
}
```

**Routes typiques Hybrid :**

* `/admin/[nom]` → Dashboard
* `/admin/[nom]/[section]` → Liste section
* `/admin/[nom]/[section]/new` → Création
* `/admin/[nom]/[section]/[id]` → Édition
* `/admin/[nom]/settings` → Configuration

---

### Exemple : Tool Newsletter (Hybrid)

typescript

```typescript
// tools/newsletter/src/index.tsx
'use client'
importtype{ToolProps}from'@repo/admin-shell/types'
import{NewsletterDashboard}from'./pages/NewsletterDashboard'
import{CampaignsList}from'./pages/CampaignsList'
import{CampaignForm}from'./pages/CampaignForm'
import{SubscribersList}from'./pages/SubscribersList'
import{NewsletterSettings}from'./pages/NewsletterSettings'

export{ newsletterToolConfig }from'./config'

exportdefaultfunctionNewsletterTool({ route, services }:ToolProps){
// Dashboard par défaut
if(!route || route.length===0){
return<NewsletterDashboard services={services}/>
}
  
// Section campagnes
if(route[0]==='campaigns'){
if(route.length===1){
return<CampaignsList services={services}/>
}
if(route[1]==='new'){
return<CampaignForm mode="create" services={services}/>
}
return<CampaignForm mode="edit" id={route[1]} services={services}/>
}
  
// Section abonnés
if(route[0]==='subscribers'){
return<SubscribersList services={services}/>
}
  
// Configuration
if(route[0]==='settings'){
return<NewsletterSettings services={services}/>
}
  
return<div>Route non gérée</div>
}
```

---

## Checklist Universelle

### ✅ Avant de Commit (Tous les Tools)

* [ ] **Structure Universelle**
  * [ ] `package.json` créé avec bon nom `@tools/[nom]`
  * [ ] `tsconfig.json` créé
  * [ ] `README.md` rédigé avec type de tool
  * [ ] `src/config.ts` créé avec toutes les infos obligatoires
  * [ ] `src/index.tsx` créé avec routing approprié
* [ ] **Configuration**
  * [ ] Icône choisie et importée depuis lucide-react
  * [ ] Description claire du tool
  * [ ] Permissions définies (si applicable)
  * [ ] basePath cohérent avec l'id
* [ ] **Code Spécifique au Type**
  * [ ] Structure de dossiers adaptée au type (CRUD/Dashboard/Config/Hybrid)
  * [ ] Pages nécessaires créées
  * [ ] Composants spécifiques créés
  * [ ] Routing interne implémenté selon le type
* [ ] **Intégration**
  * [ ] Tool exporté dans `src/index.tsx`
  * [ ] Tool enregistré dans `apps/admin/admin.config.ts`
  * [ ] API Routes créées (si nécessaire)
* [ ] **Tests**
  * [ ] `pnpm install` réussi
  * [ ] `pnpm type-check` passe sans erreur
  * [ ] Serveur dev démarre
  * [ ] Tool accessible à `/admin/[nom]`
  * [ ] Navigation interne fonctionne
  * [ ] Actions principales testées

---

## 📊 Tableau Récapitulatif

<pre class="font-ui border-border-100/50 overflow-x-scroll w-full rounded border-[0.5px] shadow-[0_2px_12px_hsl(var(--always-black)/5%)]"><table class="bg-bg-100 min-w-full border-separate border-spacing-0 text-sm leading-[1.88888] whitespace-normal"><thead class="border-b-border-100/50 border-b-[0.5px] text-left"><tr class="[tbody>&]:odd:bg-bg-500/10"><th class="text-text-000 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] px-2 [&:not(:first-child)]:border-l-[0.5px]">Élément</th><th class="text-text-000 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] px-2 [&:not(:first-child)]:border-l-[0.5px]">CRUD</th><th class="text-text-000 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] px-2 [&:not(:first-child)]:border-l-[0.5px]">Dashboard</th><th class="text-text-000 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] px-2 [&:not(:first-child)]:border-l-[0.5px]">Configuration</th><th class="text-text-000 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] px-2 [&:not(:first-child)]:border-l-[0.5px]">Hybrid</th></tr></thead><tbody><tr class="[tbody>&]:odd:bg-bg-500/10"><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]"><strong>package.json</strong></td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">✅ Identique</td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">✅ Identique</td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">✅ Identique</td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">✅ Identique</td></tr><tr class="[tbody>&]:odd:bg-bg-500/10"><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]"><strong>tsconfig.json</strong></td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">✅ Identique</td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">✅ Identique</td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">✅ Identique</td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">✅ Identique</td></tr><tr class="[tbody>&]:odd:bg-bg-500/10"><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]"><strong>config.ts</strong></td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">✅ Identique</td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">✅ Identique</td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">✅ Identique</td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">✅ Identique</td></tr><tr class="[tbody>&]:odd:bg-bg-500/10"><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]"><strong>index.tsx structure</strong></td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">✅ Identique</td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">✅ Identique</td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">✅ Identique</td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">✅ Identique</td></tr><tr class="[tbody>&]:odd:bg-bg-500/10"><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]"><strong>Routing complexité</strong></td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">🔴 Complexe</td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">🟢 Simple</td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">🟢 Simple</td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">🔴 Très complexe</td></tr><tr class="[tbody>&]:odd:bg-bg-500/10"><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]"><strong>Pages principales</strong></td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">List + Form</td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">Dashboard</td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">Settings</td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">Mix multiple</td></tr><tr class="[tbody>&]:odd:bg-bg-500/10"><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]"><strong>Composants</strong></td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">Cards, Filters, Actions</td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">Widgets, Charts</td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">Form, Preview</td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">Mix multiple</td></tr><tr class="[tbody>&]:odd:bg-bg-500/10"><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]"><strong>API Routes</strong></td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">CRUD complet</td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">Metrics, Export</td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">Settings GET/PUT</td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">Mix multiple</td></tr><tr class="[tbody>&]:odd:bg-bg-500/10"><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]"><strong>Exemples</strong></td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">Products, Orders</td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">Analytics, Social</td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">SEO, Shipping</td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">Newsletter, Media</td></tr></tbody></table></pre>

---

## 🎯 Conclusion

**Ce qui est TOUJOURS pareil :**

* ✅ package.json
* ✅ tsconfig.json
* ✅ config.ts (structure)
* ✅ index.tsx (structure de base)
* ✅ Enregistrement dans admin.config.ts

**Ce qui VARIE selon le type :**

* 🎨 Structure des dossiers (pages, components)
* 🎨 Routing interne (simple vs complexe)
* 🎨 Nombre de pages
* 🎨 Types de composants
* 🎨 API Routes

**Règle d'or :** Identifie d'abord le TYPE de ton tool, puis suis le pattern correspondant.

---

**Dernière mise à jour :** 28 octobre 2025

**Version :** 2.0

**Auteur :** Thomas (Blanche Renaudin)
