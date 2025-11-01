# Phase 3 : Migration Newsletter vers Architecture Tools

## 📋 Vue d'ensemble

Ce document détaille la migration complète du système newsletter depuis le monolithe `site-v1-next` vers l'architecture modulaire du monorepo `blancherenaudin-monorepo` en suivant les patterns de l'architecture cible.

### État actuel (dans `site-v1-next`)

```
src/
├── app/
│   ├── newsletter/confirmed/page.tsx     # ✅ Page confirmation
│   └── api/
│       ├── newsletter/
│       │   ├── subscribe/route.ts        # ✅ API souscription
│       │   └── confirm/route.ts          # ✅ API confirmation
└── components/
    └── newsletter/
        └── NewsletterSubscribe.tsx       # ✅ Formulaire

Base de données Supabase:
├── newsletter_subscribers (table)        # ✅ Existante
└── confirmation_tokens (fonction?)       # À vérifier
```

### État cible (dans `blancherenaudin-monorepo`)

```
packages/tools/newsletter/              # 🆕 NOUVEAU PACKAGE
├── src/
│   ├── api/                           # 💎 Logique pure
│   │   ├── subscribers.ts             # CRUD abonnés
│   │   ├── campaigns.ts               # Gestion campagnes
│   │   └── analytics.ts               # Statistiques
│   ├── routes/                        # Écrans admin RSC
│   │   ├── SubscribersList.tsx       # Liste abonnés
│   │   ├── CampaignsList.tsx         # Liste campagnes
│   │   └── Analytics.tsx             # Dashboard stats
│   ├── components/                    # UI spécifiques
│   │   ├── SubscriberCard.tsx
│   │   ├── CampaignEditor.tsx
│   │   └── NewsletterStats.tsx
│   ├── types.ts                       # Types métier
│   ├── constants.ts                   # Constantes
│   └── index.ts                       # Exports publics
├── __tests__/
│   ├── api/
│   │   └── subscribers.test.ts
│   └── components/
├── package.json
└── tsconfig.json

apps/admin/app/(tools)/newsletter/      # Pages minces
├── page.tsx                            # Liste (≤50 lignes)
├── campaigns/
│   ├── page.tsx                       # Liste campagnes
│   ├── [id]/
│   │   └── page.tsx                   # Détail/édition
│   └── new/
│       └── page.tsx                   # Nouvelle campagne
├── analytics/
│   └── page.tsx                       # Dashboard analytics
├── layout.tsx                         # Layout local
└── loading.tsx                        # Loading state

apps/storefront/                        # ✅ Reste tel quel
├── app/
│   ├── newsletter/confirmed/page.tsx  # Page publique confirmation
│   └── api/newsletter/                # API routes publiques
│       ├── subscribe/route.ts         # Souscription publique
│       └── confirm/route.ts           # Confirmation token
└── components/newsletter/
    └── NewsletterSubscribe.tsx        # Formulaire publique
```

---

## 🎯 Objectifs

1. ✅ Créer le package `@repo/tools-newsletter` avec toute la logique admin
2. ✅ Préserver le fonctionnement du storefront (souscription publique)
3. ✅ Ajouter des fonctionnalités avancées (campagnes, analytics)
4. ✅ Intégrer au shell admin avec RBAC
5. ✅ Configurer les tests unitaires et E2E
6. ✅ Documenter l'architecture et l'usage

---

## 📐 Architecture détaillée

### Séparation des responsabilités

typescript

```typescript
┌─────────────────────────────────────────────────────────────┐
│  @repo/tools-newsletter(packages/tools/newsletter)        │
│  ──────────────────────────────────────────────────────────  │
│  📦 ADMINUNIQUEMENT                                         │
│  ├── api/subscribers.ts                                     │
│  │   ├── listSubscribers() → Liste avec filtres/pagination │
│  │   ├── getSubscriber(id) → Détail                        │
│  │   ├── updateSubscriberStatus() → Confirmer/Désinscrire  │
│  │   ├── deleteSubscriber() → SuppressionRGPD             │
│  │   └── exportSubscribers() → ExportCSV                  │
│  │                                                            │
│  ├── api/campaigns.ts                                       │
│  │   ├── listCampaigns() → Liste campagnes                 │
│  │   ├── createCampaign() → Créer campagne                 │
│  │   ├── sendCampaign() → Envoyer via Resend               │
│  │   └── getCampaignStats() → Statistiques envoi           │
│  │                                                            │
│  └── api/analytics.ts                                       │
│      ├── getSubscribersStats() → Croissance, taux confirm   │
│      ├── getCampaignsPerformance() → Taux ouverture/clic    │
│      └── getSegmentationData() → Répartition par source     │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│  apps/storefront(PUBLIC)                                   │
│  ──────────────────────────────────────────────────────────  │
│  🌐 FONCTIONNALITÉSPUBLIQUES                               │
│  ├── components/newsletter/                                 │
│  │   └── NewsletterSubscribe.tsx → Formulaire footer       │
│  │                                                            │
│  ├── app/newsletter/confirmed/page.tsx → Page confirmation  │
│  │                                                            │
│  └── app/api/newsletter/                                    │
│      ├── subscribe/route.ts                                 │
│      │   ├── Valide email                                   │
│      │   ├── Créesubscriber(status: pending)             │
│      │   ├── Génère token confirmation                     │
│      │   └── Envoie email confirmation                     │
│      │                                                        │
│      └── confirm/route.ts                                   │
│          ├── Valide token                                   │
│          ├── Update status → confirmed                      │
│          └── Redirect/newsletter/confirmed                 │
└─────────────────────────────────────────────────────────────┘
```

### Flux de données

```
1. SOUSCRIPTION PUBLIQUE
   User remplit formulaire → POST /api/newsletter/subscribe
   → Insert dans newsletter_subscribers (status: pending)
   → Génère token unique
   → Envoie email avec lien confirmation
   → Redirige vers page "Vérifiez votre email"

2. CONFIRMATION
   User clique lien email → GET /api/newsletter/confirm?token=xxx
   → Valide token
   → Update subscriber.status = 'confirmed'
   → Redirige vers /newsletter/confirmed

3. ADMIN - GESTION ABONNÉS
   Admin → /newsletter → ToolLoader
   → Vérifie permissions 'newsletter:read'
   → Charge @repo/tools-newsletter/SubscribersList
   → Affiche liste avec filtres (pending, confirmed, unsubscribed)
   → Actions: exporter CSV, supprimer, changer statut

4. ADMIN - CAMPAGNES
   Admin → /newsletter/campaigns/new
   → CampaignEditor avec rich text
   → Sélection segment (tous, confirmés only, etc.)
   → Preview email
   → Envoi via Resend API (batch)
   → Tracking opens/clicks (webhooks Resend)
```

---

## 🛠️ Plan d'exécution étape par étape

### ÉTAPE 1 : Créer la structure du package (30 min)

bash

```bash
cd packages/tools
mkdir -p newsletter/src/{api,routes,components,hooks,__tests__/{api,components}}
cd newsletter
```

**1.1 Créer `package.json`**

json

```json
{
"name":"@repo/tools-newsletter",
"version":"0.1.0",
"private":true,
"type":"module",
"main":"./src/index.ts",
"types":"./src/index.ts",
"scripts":{
"type-check":"tsc --noEmit",
"test":"vitest run",
"test:watch":"vitest"
},
"dependencies":{
"@repo/ui":"workspace:*",
"@repo/database":"workspace:*",
"@repo/email":"workspace:*",
"@repo/utils":"workspace:*",
"react":"^19.0.0",
"zod":"^3.22.0"
},
"devDependencies":{
"@repo/typescript-config":"workspace:*",
"@types/react":"^19.0.0",
"typescript":"^5.3.0",
"vitest":"^1.0.0"
}
}
```

**1.2 Créer `tsconfig.json`**

json

```json
{
"extends":"@repo/typescript-config/react-library.json",
"compilerOptions":{
"composite":true,
"declaration":true,
"declarationMap":true,
"outDir":"./dist",
"rootDir":"./src"
},
"include":["src/**/*"],
"exclude":["node_modules","dist","__tests__"]
}
```

---

### ÉTAPE 2 : Créer les types et constantes (20 min)

**2.1 `src/types.ts`**

typescript

```typescript
importtype{Database}from'@repo/database'

// Types issus de Supabase
exporttypeSubscriber=Database['public']['Tables']['newsletter_subscribers']['Row']
exporttypeSubscriberInsert=Database['public']['Tables']['newsletter_subscribers']['Insert']
exporttypeSubscriberUpdate=Database['public']['Tables']['newsletter_subscribers']['Update']

exporttypeSubscriberStatus='pending'|'confirmed'|'unsubscribed'

// Types campagnes (à créer dans la DB)
exportinterfaceCampaign{
  id:string
  title:string
  subject:string
  content:string// HTML
  status:'draft'|'scheduled'|'sent'
  scheduled_at?:string
  sent_at?:string
  segment:'all'|'confirmed'|'custom'
  recipient_count:number
  stats?:CampaignStats
  created_at:string
  updated_at:string
}

exportinterfaceCampaignStats{
  sent:number
  delivered:number
  opens:number
  clicks:number
  bounces:number
  unsubscribes:number
}

// Types analytics
exportinterfaceSubscribersAnalytics{
  total:number
  pending:number
  confirmed:number
  unsubscribed:number
  growth_rate:number// % vs mois précédent
  confirmation_rate:number// % pending → confirmed
  sources:Array<{
    source:string
    count:number
}>
}

// Filtres et pagination
exportinterfaceSubscriberFilters{
  status?:SubscriberStatus
  search?:string
  source?:string
  date_from?:string
  date_to?:string
}

exportinterfacePaginationParams{
  page?:number
  limit?:number
  sort_by?:'created_at'|'email'
  sort_order?:'asc'|'desc'
}

exportinterfacePaginatedResult<T>{
  data:T[]
  pagination:{
    page:number
    limit:number
    total:number
    total_pages:number
}
}
```

**2.2 `src/constants.ts`**

typescript

```typescript
exportconstSUBSCRIBER_STATUS={
PENDING:'pending',
CONFIRMED:'confirmed',
UNSUBSCRIBED:'unsubscribed',
}asconst

exportconstCAMPAIGN_STATUS={
DRAFT:'draft',
SCHEDULED:'scheduled',
SENT:'sent',
}asconst

exportconstDEFAULT_PAGINATION={
PAGE:1,
LIMIT:50,
MAX_LIMIT:100,
}asconst

exportconstSUBSCRIBER_SOURCES={
FOOTER:'footer',
POPUP:'popup',
CHECKOUT:'checkout',
ADMIN:'admin',
}asconst

// Permissions RBAC
exportconstPERMISSIONS={
READ:'newsletter:read',
WRITE:'newsletter:write',
SEND:'newsletter:send',
DELETE:'newsletter:delete',
}asconst
```

---

### ÉTAPE 3 : Créer l'API subscribers (1h)

**3.1 `src/api/subscribers.ts`**

typescript

```typescript
import{ createServerClient }from'@repo/database/client-server'
importtype{
Subscriber,
SubscriberFilters,
PaginationParams,
PaginatedResult,
SubscriberStatus,
}from'../types'
import{DEFAULT_PAGINATION}from'../constants'

/**
 * Liste les abonnés avec filtres et pagination
 */
exportasyncfunctionlistSubscribers(
  filters:SubscriberFilters={},
  pagination:PaginationParams={}
):Promise<{ data:PaginatedResult<Subscriber>|null; error:Error|null}>{
try{
const supabase =createServerClient()

const{
      status,
      search,
      source,
      date_from,
      date_to,
}= filters

const{
      page =DEFAULT_PAGINATION.PAGE,
      limit =DEFAULT_PAGINATION.LIMIT,
      sort_by ='created_at',
      sort_order ='desc',
}= pagination

// Limiter la pagination
const safeLimit =Math.min(limit,DEFAULT_PAGINATION.MAX_LIMIT)
const offset =(page -1)* safeLimit

// Query de base
let query = supabase
.from('newsletter_subscribers')
.select('*',{ count:'exact'})

// Filtres
if(status){
      query = query.eq('status', status)
}

if(search){
      query = query.ilike('email',`%${search}%`)
}

if(source){
      query = query.eq('source', source)
}

if(date_from){
      query = query.gte('created_at', date_from)
}

if(date_to){
      query = query.lte('created_at', date_to)
}

// Pagination et tri
    query = query
.order(sort_by,{ ascending: sort_order ==='asc'})
.range(offset, offset + safeLimit -1)

const{ data, error, count }=await query

if(error)throw error

return{
      data:{
        data: data ||[],
        pagination:{
          page,
          limit: safeLimit,
          total: count ||0,
          total_pages:Math.ceil((count ||0)/ safeLimit),
},
},
      error:null,
}
}catch(error){
console.error('[listSubscribers] Error:', error)
return{
      data:null,
      error: error instanceofError? error :newError('Unknown error'),
}
}
}

/**
 * Récupère un abonné par ID
 */
exportasyncfunctiongetSubscriber(
  id:string
):Promise<{ data:Subscriber|null; error:Error|null}>{
try{
const supabase =createServerClient()

const{ data, error }=await supabase
.from('newsletter_subscribers')
.select('*')
.eq('id', id)
.single()

if(error)throw error

return{ data, error:null}
}catch(error){
console.error('[getSubscriber] Error:', error)
return{
      data:null,
      error: error instanceofError? error :newError('Unknown error'),
}
}
}

/**
 * Met à jour le statut d'un abonné
 */
exportasyncfunctionupdateSubscriberStatus(
  id:string,
  status:SubscriberStatus
):Promise<{ error:Error|null}>{
try{
const supabase =createServerClient()

const{ error }=await supabase
.from('newsletter_subscribers')
.update({ status, updated_at:newDate().toISOString()})
.eq('id', id)

if(error)throw error

return{ error:null}
}catch(error){
console.error('[updateSubscriberStatus] Error:', error)
return{
      error: error instanceofError? error :newError('Unknown error'),
}
}
}

/**
 * Supprime un abonné (RGPD)
 */
exportasyncfunctiondeleteSubscriber(
  id:string
):Promise<{ error:Error|null}>{
try{
const supabase =createServerClient()

const{ error }=await supabase
.from('newsletter_subscribers')
.delete()
.eq('id', id)

if(error)throw error

return{ error:null}
}catch(error){
console.error('[deleteSubscriber] Error:', error)
return{
      error: error instanceofError? error :newError('Unknown error'),
}
}
}

/**
 * Exporte les abonnés en CSV
 */
exportasyncfunctionexportSubscribers(
  filters:SubscriberFilters={}
):Promise<{ data:string|null; error:Error|null}>{
try{
// Récupérer tous les abonnés sans pagination
const{ data: result, error }=awaitlistSubscribers(filters,{
      limit:DEFAULT_PAGINATION.MAX_LIMIT*10,// Max 1000
})

if(error ||!result)throw error

const subscribers = result.data

// Générer le CSV
const headers =['Email','Status','Source','Created At','Confirmed At']
const rows = subscribers.map((s)=>[
      s.email,
      s.status,
      s.source||'',
newDate(s.created_at).toLocaleDateString(),
      s.confirmed_at?newDate(s.confirmed_at).toLocaleDateString():'',
])

const csv =[
      headers.join(','),
...rows.map((row)=> row.join(',')),
].join('\n')

return{ data: csv, error:null}
}catch(error){
console.error('[exportSubscribers] Error:', error)
return{
      data:null,
      error: error instanceofError? error :newError('Unknown error'),
}
}
}
```

---

### ÉTAPE 4 : Créer l'API analytics (45 min)

**4.1 `src/api/analytics.ts`**

typescript

```typescript
import{ createServerClient }from'@repo/database/client-server'
importtype{SubscribersAnalytics}from'../types'

/**
 * Récupère les statistiques des abonnés
 */
exportasyncfunctiongetSubscribersStats():Promise<{
  data:SubscribersAnalytics|null
  error:Error|null
}>{
try{
const supabase =createServerClient()

// Compter par statut
const{ data: stats, error: statsError }=await supabase
.from('newsletter_subscribers')
.select('status')

if(statsError)throw statsError

const total = stats?.length ||0
const pending = stats?.filter((s)=> s.status==='pending').length||0
const confirmed = stats?.filter((s)=> s.status==='confirmed').length||0
const unsubscribed =
      stats?.filter((s)=> s.status==='unsubscribed').length||0

// Taux de confirmation
const confirmation_rate = pending >0?(confirmed /(pending + confirmed))*100:0

// Croissance vs mois précédent
const lastMonth =newDate()
    lastMonth.setMonth(lastMonth.getMonth()-1)

const{ data: lastMonthStats, error: lastMonthError }=await supabase
.from('newsletter_subscribers')
.select('id')
.gte('created_at', lastMonth.toISOString())

if(lastMonthError)throw lastMonthError

const growth_rate = total >0?((lastMonthStats?.length ||0)/ total)*100:0

// Répartition par source
const{ data: sources, error: sourcesError }=await supabase
.from('newsletter_subscribers')
.select('source')

if(sourcesError)throw sourcesError

const sourcesCounts = sources?.reduce((acc, s)=>{
const source = s.source||'unknown'
      acc[source]=(acc[source]||0)+1
return acc
},{}asRecord<string,number>)

const sourcesArray =Object.entries(sourcesCounts ||{}).map(
([source, count])=>({ source, count })
)

return{
      data:{
        total,
        pending,
        confirmed,
        unsubscribed,
        growth_rate,
        confirmation_rate,
        sources: sourcesArray,
},
      error:null,
}
}catch(error){
console.error('[getSubscribersStats] Error:', error)
return{
      data:null,
      error: error instanceofError? error :newError('Unknown error'),
}
}
}
```

---

### ÉTAPE 5 : Créer les composants routes (1h30)

**5.1 `src/routes/SubscribersList.tsx`** (Server Component)

typescript

```typescript
import{ listSubscribers, getSubscribersStats }from'../api/subscribers'
import{SubscriberCard}from'../components/SubscriberCard'
import{SubscribersStats}from'../components/SubscribersStats'
import{SubscribersFilter}from'../components/SubscribersFilter'
importtype{SubscriberFilters,PaginationParams}from'../types'

interfaceProps{
  searchParams?:{
    status?:string
    search?:string
    page?:string
}
}

exportasyncfunctionSubscribersList({ searchParams }:Props){
const filters:SubscriberFilters={
    status: searchParams?.status asany,
    search: searchParams?.search,
}

const pagination:PaginationParams={
    page: searchParams?.page ?parseInt(searchParams.page):1,
}

// Récupérer les données en parallèle
const[subscribersResult, statsResult]=awaitPromise.all([
listSubscribers(filters, pagination),
getSubscribersStats(),
])

if(subscribersResult.error){
return(
<div className="p-4">
<div className="rounded-lg border border-red-200 bg-red-50 p-4 text-red-800">
Erreur:{subscribersResult.error.message}
</div>
</div>
)
}

if(statsResult.error){
console.error('Stats error:', statsResult.error)
}

const{ data: subscribers, pagination: paginationInfo }=
    subscribersResult.data!

return(
<div className="space-y-6 p-6">
{/* En-tête */}
<div className="flex items-center justify-between">
<h1 className="text-2xl font-bold">Newsletter-Abonnés</h1>
<div className="flex gap-2">
<button className="btn-secondary">ExporterCSV</button>
<button className="btn-primary">Nouvelle campagne</button>
</div>
</div>

{/* Stats */}
{statsResult.data&&<SubscribersStats stats={statsResult.data}/>}

{/* Filtres */}
<SubscribersFilter/>

{/* Liste */}
{subscribers.length===0?(
<div className="rounded-lg border border-gray-200 bg-gray-50 p-8 text-center">
<p className="text-gray-600">Aucun abonné trouvé</p>
</div>
):(
<div className="space-y-2">
{subscribers.map((subscriber)=>(
<SubscriberCard key={subscriber.id} subscriber={subscriber}/>
))}
</div>
)}

{/* Pagination */}
{paginationInfo.total_pages>1&&(
<div className="flex justify-center gap-2">
{Array.from({ length: paginationInfo.total_pages},(_, i)=>(
<a
              key={i}
              href={`?page=${i +1}`}
              className={`rounded px-4 py-2 ${
                i +1=== paginationInfo.page
?'bg-violet text-white'
:'bg-gray-100 hover:bg-gray-200'
}`}
>
{i +1}
</a>
))}
</div>
)}
</div>
)
}
```

**5.2 `src/components/SubscriberCard.tsx`** (Client Component)

typescript

```typescript
'use client'

import{ useState }from'react'
import{Badge}from'@repo/ui/components/badge'
import{Button}from'@repo/ui/components/button'
importtype{Subscriber}from'../types'

interfaceProps{
  subscriber:Subscriber
}

exportfunctionSubscriberCard({ subscriber }:Props){
const[status, setStatus]=useState(subscriber.status)
const[isUpdating, setIsUpdating]=useState(false)

consthandleStatusChange=async(newStatus:string)=>{
setIsUpdating(true)
try{
const response =awaitfetch('/api/admin/newsletter/subscribers',{
        method:'PATCH',
        headers:{'Content-Type':'application/json'},
        body:JSON.stringify({
          id: subscriber.id,
          status: newStatus,
}),
})

if(!response.ok)thrownewError('Failed to update')

setStatus(newStatus asany)
}catch(error){
console.error('Error updating subscriber:', error)
alert('Erreur lors de la mise à jour')
}finally{
setIsUpdating(false)
}
}

const statusColors ={
    pending:'bg-yellow-100 text-yellow-800',
    confirmed:'bg-green-100 text-green-800',
    unsubscribed:'bg-gray-100 text-gray-800',
}

return(
<div className="flex items-center justify-between rounded-lg border border-gray-200 bg-white p-4 hover:border-gray-300">
<div className="flex-1">
<p className="font-medium">{subscriber.email}</p>
<p className="text-sm text-gray-600">
Inscrit le {newDate(subscriber.created_at).toLocaleDateString()}
{subscriber.source&&` • Source: ${subscriber.source}`}
</p>
</div>

<div className="flex items-center gap-4">
<Badge className={statusColors[status]}>{status}</Badge>

<div className="flex gap-2">
{status ==='pending'&&(
<Button
              size="sm"
              variant="ghost"
              onClick={()=>handleStatusChange('confirmed')}
              disabled={isUpdating}
>
Confirmer
</Button>
)}

{status !=='unsubscribed'&&(
<Button
              size="sm"
              variant="ghost"
              onClick={()=>handleStatusChange('unsubscribed')}
              disabled={isUpdating}
>
Désinscrire
</Button>
)}

<Button
            size="sm"
            variant="ghost"
            className="text-red-600 hover:text-red-700"
            disabled={isUpdating}
>
Supprimer
</Button>
</div>
</div>
</div>
)
}
```

**5.3 `src/components/SubscribersStats.tsx`**

typescript

```typescript
'use client'

importtype{SubscribersAnalytics}from'../types'

interfaceProps{
  stats:SubscribersAnalytics
}

exportfunctionSubscribersStats({ stats }:Props){
return(
<div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">
{/* Total */}
<div className="rounded-lg border border-gray-200 bg-white p-6">
<div className="text-sm font-medium text-gray-600">Total abonnés</div>
<div className="mt-2 text-3xl font-bold">{stats.total}</div>
{stats.growth_rate>0&&(
<div className="mt-2 text-sm text-green-600">
+{stats.growth_rate.toFixed(1)}% ce mois
</div>
)}
</div>

{/* Confirmés */}
<div className="rounded-lg border border-gray-200 bg-white p-6">
<div className="text-sm font-medium text-gray-600">Confirmés</div>
<div className="mt-2 text-3xl font-bold">{stats.confirmed}</div>
<div className="mt-2 text-sm text-gray-600">
{((stats.confirmed/ stats.total)*100).toFixed(1)}% du total
</div>
</div>

{/* En attente */}
<div className="rounded-lg border border-gray-200 bg-white p-6">
<div className="text-sm font-medium text-gray-600">En attente</div>
<div className="mt-2 text-3xl font-bold">{stats.pending}</div>
<div className="mt-2 text-sm text-gray-600">
{stats.confirmation_rate.toFixed(1)}% de taux de confirmation
</div>
</div>

{/* Désinscrits */}
<div className="rounded-lg border border-gray-200 bg-white p-6">
<div className="text-sm font-medium text-gray-600">Désinscrits</div>
<div className="mt-2 text-3xl font-bold">{stats.unsubscribed}</div>
<div className="mt-2 text-sm text-gray-600">
{((stats.unsubscribed/ stats.total)*100).toFixed(1)}% du total
</div>
</div>
</div>
)
}
```

---

### ÉTAPE 6 : Exporter depuis index.ts (10 min)

**6.1 `src/index.ts`**

typescript

```typescript
// API
export*from'./api/subscribers'
export*from'./api/analytics'

// Routes (Server Components)
export{SubscribersList}from'./routes/SubscribersList'

// Components (Client Components)
export{SubscriberCard}from'./components/SubscriberCard'
export{SubscribersStats}from'./components/SubscribersStats'

// Types
exporttype*from'./types'

// Constants
export*from'./constants'
```

---

### ÉTAPE 7 : Intégrer dans le registry (20 min)

**7.1 Mettre à jour `apps/admin/lib/registry/registry.ts`**

typescript

```typescript
import{Mail}from'lucide-react'
importtype{ToolDefinition}from'./types'

exportconst toolsRegistry:Record<string,ToolDefinition>={
// ... autres tools

  newsletter:{
    id:'newsletter',
    name:'Newsletter',
    icon:Mail,
    route:'/newsletter',
    permissions:['newsletter:read'],
loader:()=>import('@repo/tools-newsletter'),
    enabled:true,
    description:'Gestion des abonnés et campagnes email',
},
}
```

**7.2 Créer la page admin `apps/admin/app/(tools)/newsletter/page.tsx`**

typescript

```typescript
import{ToolLoader}from'@/lib/registry/ToolLoader'
import{SubscribersList}from'@repo/tools-newsletter'

exportconst metadata ={
  title:'Newsletter | Admin',
}

interfaceProps{
  searchParams?:{
    status?:string
    search?:string
    page?:string
}
}

exportdefaultfunctionNewsletterPage({ searchParams }:Props){
return(
<ToolLoader toolId="newsletter">
<SubscribersList searchParams={searchParams}/>
</ToolLoader>
)
}
```

**7.3 Créer le layout `apps/admin/app/(tools)/newsletter/layout.tsx`**

typescript

```typescript
exportdefaultfunctionNewsletterLayout({
  children,
}:{
  children:React.ReactNode
}){
return<div className="newsletter-tool">{children}</div>
}
```

**7.4 Créer le loading `apps/admin/app/(tools)/newsletter/loading.tsx`**

typescript

```typescript
import{Skeleton}from'@repo/ui/components/skeleton'

exportdefaultfunctionNewsletterLoading(){
return(
<div className="space-y-6 p-6">
<div className="flex items-center justify-between">
<Skeleton className="h-8 w-48"/>
<Skeleton className="h-10 w-32"/>
</div>

<div className="grid grid-cols-4 gap-4">
{[1,2,3,4].map((i)=>(
<Skeleton key={i} className="h-32 w-full"/>
))}
</div>

<div className="space-y-2">
{[1,2,3,4,5].map((i)=>(
<Skeleton key={i} className="h-20 w-full"/>
))}
</div>
</div>
)
}
```

---

### ÉTAPE 8 : Mettre à jour next.config.ts (5 min)

**8.1 `apps/admin/next.config.ts`**

typescript

```typescript
const nextConfig ={
  transpilePackages:[
'@repo/ui',
'@repo/database',
'@repo/email',
'@repo/utils',
'@repo/tools-newsletter',// 🆕 AJOUTER
// ... autres tools
],
}
```

---

### ÉTAPE 9 : Créer l'API route admin (30 min)

**9.1 `apps/admin/app/api/newsletter/subscribers/route.ts`**

typescript

```typescript
import{NextRequest,NextResponse}from'next/server'
import{ updateSubscriberStatus, deleteSubscriber }from'@repo/tools-newsletter'
import{ requireAdmin }from'@repo/auth'

// PATCH - Mettre à jour le statut
exportasyncfunctionPATCH(req:NextRequest){
try{
// Vérifier les permissions
const{ error: authError }=awaitrequireAdmin(['newsletter:write'])
if(authError){
returnNextResponse.json({ error: authError.message},{ status:403})
}

const body =await req.json()
const{ id, status }= body

if(!id ||!status){
returnNextResponse.json(
{ error:'Missing id or status'},
{ status:400}
)
}

const{ error }=awaitupdateSubscriberStatus(id, status)

if(error){
returnNextResponse.json({ error: error.message},{ status:500})
}

returnNextResponse.json({ success:true})
}catch(error){
console.error('[PATCH /api/newsletter/subscribers] Error:', error)
returnNextResponse.json(
{ error:'Internal server error'},
{ status:500}
)
}
}

// DELETE - Supprimer un abonné
exportasyncfunctionDELETE(req:NextRequest){
try{
// Vérifier les permissions
const{ error: authError }=awaitrequireAdmin(['newsletter:delete'])
if(authError){
returnNextResponse.json({ error: authError.message},{ status:403})
}

const{ searchParams }=newURL(req.url)
const id = searchParams.get('id')

if(!id){
returnNextResponse.json({ error:'Missing id'},{ status:400})
}

const{ error }=awaitdeleteSubscriber(id)

if(error){
returnNextResponse.json({ error: error.message},{ status:500})
}

returnNextResponse.json({ success:true})
}catch(error){
console.error('[DELETE /api/newsletter/subscribers] Error:', error)
returnNextResponse.json(
{ error:'Internal server error'},
{ status:500}
)
}
}
```

---

### ÉTAPE 10 : Préserver le fonctionnement storefront (10 min)

**10.1 Vérifier que les fichiers storefront existent et fonctionnent**

bash

```bash
# Vérifier structure
ls -la apps/storefront/app/newsletter/confirmed/
ls -la apps/storefront/app/api/newsletter/subscribe/
ls -la apps/storefront/app/api/newsletter/confirm/
ls -la apps/storefront/components/newsletter/

# Ces fichiers NE DOIVENT PAS être modifiés !
# Ils restent tels quels dans le storefront
```

**10.2 S'assurer que le FooterMinimal utilise bien NewsletterSubscribe**

typescript

```typescript
// apps/storefront/components/layout/FooterMinimal.tsx

import{NewsletterSubscribe}from'../newsletter/NewsletterSubscribe'

// ... dans le JSX
<NewsletterSubscribe/>
```

---

### ÉTAPE 11 : Configurer les tests (1h)

**11.1 `packages/tools/newsletter/vitest.config.ts`**

typescript

```typescript
import{ defineConfig }from'vitest/config'

exportdefaultdefineConfig({
  test:{
    environment:'node',
    globals:true,
    coverage:{
      provider:'v8',
      reporter:['text','json','html'],
      threshold:{
        lines:80,
        functions:80,
        branches:80,
        statements:80,
},
},
},
})
```

**11.2 Tests unitaires `src/api/__tests__/subscribers.test.ts`**

typescript

```typescript
import{ describe, it, expect, vi, beforeEach }from'vitest'
import{ listSubscribers, getSubscriber, updateSubscriberStatus }from'../subscribers'

// Mock Supabase
vi.mock('@repo/database/client-server',()=>({
createServerClient:()=>({
from: vi.fn(()=>({
      select: vi.fn().mockReturnThis(),
      eq: vi.fn().mockReturnThis(),
      update: vi.fn().mockReturnThis(),
      order: vi.fn().mockReturnThis(),
      range: vi.fn().mockResolvedValue({
        data:[
{
            id:'1',
            email:'test@example.com',
            status:'confirmed',
            created_at:'2025-01-01',
},
],
        error:null,
        count:1,
}),
      single: vi.fn().mockResolvedValue({
        data:{
          id:'1',
          email:'test@example.com',
          status:'confirmed',
          created_at:'2025-01-01',
},
        error:null,
}),
})),
}),
}))

describe('subscribers API',()=>{
describe('listSubscribers',()=>{
it('should return paginated subscribers',async()=>{
const{ data, error }=awaitlistSubscribers()

expect(error).toBeNull()
expect(data).toBeDefined()
expect(data?.data).toHaveLength(1)
expect(data?.pagination.total).toBe(1)
})

it('should filter by status',async()=>{
const{ data, error }=awaitlistSubscribers({ status:'confirmed'})

expect(error).toBeNull()
expect(data?.data[0].status).toBe('confirmed')
})
})

describe('getSubscriber',()=>{
it('should return a single subscriber',async()=>{
const{ data, error }=awaitgetSubscriber('1')

expect(error).toBeNull()
expect(data).toBeDefined()
expect(data?.id).toBe('1')
})
})

describe('updateSubscriberStatus',()=>{
it('should update subscriber status',async()=>{
const{ error }=awaitupdateSubscriberStatus('1','confirmed')

expect(error).toBeNull()
})
})
})
```

**11.3 Créer les tests E2E `tests/e2e/newsletter.spec.ts`** (à la racine)

typescript

```typescript
import{ test, expect }from'@playwright/test'

test.describe('Newsletter Tool',()=>{
  test.beforeEach(async({ page })=>{
// Login admin
await page.goto('/login')
await page.fill('[name="email"]', process.env.TEST_ADMIN_EMAIL!)
await page.fill('[name="password"]', process.env.TEST_ADMIN_PASSWORD!)
await page.click('button[type="submit"]')
await page.waitForURL('/dashboard')
})

test('should display subscribers list',async({ page })=>{
await page.goto('/newsletter')

// Vérifier le chargement
await page.waitForSelector('h1:has-text("Newsletter - Abonnés")')

// Vérifier les stats
awaitexpect(page.locator('text=Total abonnés')).toBeVisible()
awaitexpect(page.locator('text=Confirmés')).toBeVisible()

// Vérifier la liste
const subscribers =await page.locator('[data-testid="subscriber-card"]')
expect(await subscribers.count()).toBeGreaterThan(0)
})

test('should filter subscribers by status',async({ page })=>{
await page.goto('/newsletter')

// Appliquer le filtre
await page.selectOption('select[name="status"]','confirmed')

// Vérifier que la liste se met à jour
await page.waitForURL('/newsletter?status=confirmed')

const badges =await page.locator('.badge')
const count =await badges.count()

for(let i =0; i < count; i++){
awaitexpect(badges.nth(i)).toHaveText('confirmed')
}
})
})
```

---

### ÉTAPE 12 : Documentation (30 min)

**12.1 Créer `packages/tools/newsletter/README.md`**

markdown

```markdown
# @repo/tools-newsletter

Tool de gestion de la newsletter pour l'admin Blanche Renaudin.

## 🎯 Fonctionnalités

- ✅ Gestion des abonnés (liste, filtres, pagination)
- ✅ Statistiques (croissance, taux de confirmation, sources)
- ✅ Actions bulk (export CSV, mise à jour statut)
- ✅ Suppression RGPD
- 🚧 Campagnes email (à venir)
- 🚧 Analytics avancées (à venir)

## 🏗️ Architecture
```

src/
├── api/              # Logique pure (testable)
├── routes/           # Server Components (RSC)
├── components/       # Client Components
├── types.ts          # Types TypeScript
└── constants.ts      # Constantes

```

## 📦 Installation

Ce package est déjà installé dans le monorepo.

## 🚀 Usage

### Dans l'admin
```typescript
import { SubscribersList } from '@repo/tools-newsletter'

export default function NewsletterPage() {
  return <SubscribersList />
}
```

### API

```typescript
import { listSubscribers, updateSubscriberStatus } from '@repo/tools-newsletter'

// Lister les abonnés confirmés
const { data } = await listSubscribers({
  status: 'confirmed',
  page: 1,
  limit: 50,
})

// Confirmer un abonné
await updateSubscriberStatus(subscriberId, 'confirmed')
```

## 🧪 Tests

```bash
# Tests unitaires
pnpm test

# Coverage
pnpm test:coverage

# Watch mode
pnpm test:watch
```

## 📋 Permissions RBAC

| Permission            | Description                   |
| --------------------- | ----------------------------- |
| `newsletter:read`   | Voir les abonnés             |
| `newsletter:write`  | Modifier les abonnés         |
| `newsletter:send`   | Envoyer des campagnes         |
| `newsletter:delete` | Supprimer des abonnés (RGPD) |

## 🔗 Dépendances

- `@repo/ui` - Design System
- `@repo/database` - Client Supabase
- `@repo/email` - Templates email
- `@repo/utils` - Utilitaires

## 📖 Documentation

- [Architecture cible](../../../docs/ARCHITECTURE-CIBLE.md)
- [Guide d&#39;ajout de tool](../../../docs/ARCHITECTURE-AJOUTER-TOOL.md)
- [Bonnes pratiques](../../../docs/ARCHITECTURE-BONNES-PRATIQUES-TOOLS.md)

```




---


## 📋 Checklist de validation


### Infrastructure ✅


* [ ] Package `@repo/tools-newsletter` créé
* [ ] `package.json` configuré avec les dépendances
* [ ] `tsconfig.json` avec `composite: true`
* [ ] Ajouté dans `transpilePackages` de `apps/admin/next.config.ts`
* [ ] Référencé dans le root `tsconfig.json`


### API & Logique ✅


* [ ] `api/subscribers.ts` avec CRUD complet
* [ ] `api/analytics.ts` avec statistiques
* [ ] Tous les types dans `types.ts`
* [ ] Constantes dans `constants.ts`
* [ ] Exports publics dans `index.ts`


### UI & Components ✅


* [ ] `routes/SubscribersList.tsx` (RSC)
* [ ] `components/SubscriberCard.tsx` (Client)
* [ ] `components/SubscribersStats.tsx` (Client)
* [ ] `components/SubscribersFilter.tsx` (Client)


### Intégration Admin ✅


* [ ] Tool ajouté dans `registry.ts`
* [ ] Page `apps/admin/app/(tools)/newsletter/page.tsx`
* [ ] Layout `layout.tsx`
* [ ] Loading state `loading.tsx`
* [ ] API route `/api/newsletter/subscribers/route.ts`


### Storefront (NE PAS TOUCHER) ✅


* [ ] `apps/storefront/app/newsletter/confirmed/page.tsx` fonctionne
* [ ] `apps/storefront/app/api/newsletter/subscribe/route.ts` fonctionne
* [ ] `apps/storefront/app/api/newsletter/confirm/route.ts` fonctionne
* [ ] `apps/storefront/components/newsletter/NewsletterSubscribe.tsx` fonctionne


### Tests ✅


* [ ] Vitest configuré
* [ ] Tests unitaires API (>80% coverage)
* [ ] Tests E2E Playwright
* [ ] Tests passent en CI


### Documentation ✅


* [ ] `README.md` du package
* [ ] Commentaires JSDoc dans l'API
* [ ] Ce document PHASE-3 à jour


---


## 🎓 Commandes utiles







bash

```bash
# Dev mode admin
cd apps/admin
pnpm dev

# Dev mode storefront (pour tester la souscription publique)
cd apps/storefront
pnpm dev

# Type-check
pnpm --filter @repo/tools-newsletter type-check

# Tests unitaires
pnpm --filter @repo/tools-newsletter test

# Tests E2E
pnpm test:e2e

# Build
pnpm build

# Analyse bundle
pnpm --filter admin analyze
```

---

## 🚦 Validation finale

### Tests de régression

1. **Storefront - Souscription publique**
   * [ ] Formulaire newsletter dans footer s'affiche
   * [ ] Submit → email de confirmation envoyé
   * [ ] Clic lien → redirection vers /newsletter/confirmed
   * [ ] Abonné créé avec status = 'confirmed'
2. **Admin - Liste abonnés**
   * [ ] Route `/newsletter` accessible avec permissions
   * [ ] Liste des abonnés s'affiche
   * [ ] Stats affichées correctement
   * [ ] Filtres fonctionnent
   * [ ] Pagination fonctionne
3. **Admin - Actions**
   * [ ] Confirmer un abonné pending
   * [ ] Désinscrire un abonné
   * [ ] Supprimer un abonné
   * [ ] Exporter en CSV
4. **Performance**
   * [ ] Build < 10s (incrémental)
   * [ ] Type-check < 15s
   * [ ] Lazy loading vérifié (bundle split)
   * [ ] HMR < 1s

---

## 📊 Timeline estimée

<pre class="font-ui border-border-100/50 overflow-x-scroll w-full rounded border-[0.5px] shadow-[0_2px_12px_hsl(var(--always-black)/5%)]"><table class="bg-bg-100 min-w-full border-separate border-spacing-0 text-sm leading-[1.88888] whitespace-normal"><thead class="border-b-border-100/50 border-b-[0.5px] text-left"><tr class="[tbody>&]:odd:bg-bg-500/10"><th class="text-text-000 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] px-2 [&:not(:first-child)]:border-l-[0.5px]">Étape</th><th class="text-text-000 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] px-2 [&:not(:first-child)]:border-l-[0.5px]">Durée estimée</th><th class="text-text-000 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] px-2 [&:not(:first-child)]:border-l-[0.5px]">Priorité</th></tr></thead><tbody><tr class="[tbody>&]:odd:bg-bg-500/10"><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">1. Structure package</td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">30 min</td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">🔴 CRITIQUE</td></tr><tr class="[tbody>&]:odd:bg-bg-500/10"><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">2. Types et constantes</td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">20 min</td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">🔴 CRITIQUE</td></tr><tr class="[tbody>&]:odd:bg-bg-500/10"><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">3. API subscribers</td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">1h</td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">🔴 CRITIQUE</td></tr><tr class="[tbody>&]:odd:bg-bg-500/10"><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">4. API analytics</td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">45 min</td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">🟡 IMPORTANT</td></tr><tr class="[tbody>&]:odd:bg-bg-500/10"><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">5. Components routes</td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">1h30</td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">🔴 CRITIQUE</td></tr><tr class="[tbody>&]:odd:bg-bg-500/10"><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">6. Exports index</td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">10 min</td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">🔴 CRITIQUE</td></tr><tr class="[tbody>&]:odd:bg-bg-500/10"><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">7. Registry integration</td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">20 min</td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">🔴 CRITIQUE</td></tr><tr class="[tbody>&]:odd:bg-bg-500/10"><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">8. next.config.ts</td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">5 min</td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">🔴 CRITIQUE</td></tr><tr class="[tbody>&]:odd:bg-bg-500/10"><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">9. API route admin</td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">30 min</td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">🔴 CRITIQUE</td></tr><tr class="[tbody>&]:odd:bg-bg-500/10"><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">10. Vérif storefront</td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">10 min</td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">🔴 CRITIQUE</td></tr><tr class="[tbody>&]:odd:bg-bg-500/10"><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">11. Tests</td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">1h</td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">🟡 IMPORTANT</td></tr><tr class="[tbody>&]:odd:bg-bg-500/10"><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">12. Documentation</td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">30 min</td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]">🟢 NICE</td></tr><tr class="[tbody>&]:odd:bg-bg-500/10"><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]"><strong>TOTAL</strong></td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]"><strong>~6h30</strong></td><td class="border-t-border-100/50 [&:not(:first-child)]:-x-[hsla(var(--border-100) / 0.5)] border-t-[0.5px] px-2 [&:not(:first-child)]:border-l-[0.5px]"></td></tr></tbody></table></pre>

---

## ✅ Critères de succès

Avant de passer à la migration d'autres tools, on doit avoir :

1. ✅ Newsletter tool fonctionnel dans l'admin
2. ✅ Storefront souscription publique fonctionne
3. ✅ Tests unitaires + E2E passent
4. ✅ Build incrémental < 10s
5. ✅ Aucune régression sur le storefront
6. ✅ Documentation complète

**Quand ces critères sont remplis → GO pour migration `products` ou autres tools** 🚀

---

**Document créé le : 29 octobre 2025**

**Auteur : Assistant Architecture**

**Statut : Plan d'action prêt à exécuter**
