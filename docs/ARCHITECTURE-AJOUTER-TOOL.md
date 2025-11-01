# **Document 2 — Création d’un nouveau Tool compatible avec le Shell**

---

## 🎯 Objectif

Ce guide explique comment :

* Créer un **nouveau tool** modulaire dans `packages/tools/`
* L’intégrer dans le **shell Next.js** (`apps/web`)
* Le rendre compatible avec :
  * Le **Design System partagé** (`@acme/ui`)
  * Le **client Supabase partagé** (`@acme/supabase`)
  * Le **système de routage App Router**
  * Le **registre des tools** (manifest & permissions)
  * Le **middleware RBAC**

---

## 🧱 Étape 1 — Structure de base du tool

Chaque tool est un **package indépendant** dans le dossier `packages/tools/`.

Exemple :

➡️ Création du tool `tool-c`

<pre class="overflow-visible!" data-start="835" data-end="906"><div class="contain-inline-size rounded-2xl relative bg-token-sidebar-surface-primary"><div class="sticky top-9"><div class="absolute end-0 bottom-0 flex h-9 items-center pe-2"><div class="bg-token-bg-elevated-secondary text-token-text-secondary flex items-center gap-4 rounded-sm px-2 font-sans text-xs"></div></div></div><div class="overflow-y-auto p-4" dir="ltr"><code class="whitespace-pre! language-bash"><span><span>mkdir</span><span> -p packages/tools/tool-c/src/{routes,components,data}
</span></span></code></div></div></pre>

**Fichier `package.json` :**

<pre class="overflow-visible!" data-start="938" data-end="1185"><div class="contain-inline-size rounded-2xl relative bg-token-sidebar-surface-primary"><div class="sticky top-9"><div class="absolute end-0 bottom-0 flex h-9 items-center pe-2"><div class="bg-token-bg-elevated-secondary text-token-text-secondary flex items-center gap-4 rounded-sm px-2 font-sans text-xs"></div></div></div><div class="overflow-y-auto p-4" dir="ltr"><code class="whitespace-pre! language-json"><span><span>{</span><span>
  </span><span>"name"</span><span>:</span><span></span><span>"@acme/tool-c"</span><span>,</span><span>
  </span><span>"version"</span><span>:</span><span></span><span>"0.1.0"</span><span>,</span><span>
  </span><span>"private"</span><span>:</span><span></span><span>true</span><span></span><span>,</span><span>
  </span><span>"type"</span><span>:</span><span></span><span>"module"</span><span>,</span><span>
  </span><span>"main"</span><span>:</span><span></span><span>"src/index.ts"</span><span>,</span><span>
  </span><span>"dependencies"</span><span>:</span><span></span><span>{</span><span>
    </span><span>"@acme/ui"</span><span>:</span><span></span><span>"*"</span><span>,</span><span>
    </span><span>"@acme/supabase"</span><span>:</span><span></span><span>"*"</span><span>,</span><span>
    </span><span>"@acme/types"</span><span>:</span><span></span><span>"*"</span><span>,</span><span>
    </span><span>"react"</span><span>:</span><span></span><span>"^18.3.0"</span><span>
  </span><span>}</span><span>
</span><span>}</span><span>
</span></span></code></div></div></pre>

---

## 🪪 Étape 2 — Créer le manifest du tool

Le manifest sert à enregistrer le tool dans le  **registre global du shell** .

<pre class="overflow-visible!" data-start="1313" data-end="1529"><div class="contain-inline-size rounded-2xl relative bg-token-sidebar-surface-primary"><div class="sticky top-9"><div class="absolute end-0 bottom-0 flex h-9 items-center pe-2"><div class="bg-token-bg-elevated-secondary text-token-text-secondary flex items-center gap-4 rounded-sm px-2 font-sans text-xs"></div></div></div><div class="overflow-y-auto p-4" dir="ltr"><code class="whitespace-pre! language-ts"><span><span>// packages/tools/tool-c/src/manifest.ts</span><span>
</span><span>export</span><span></span><span>default</span><span> {
  </span><span>id</span><span>: </span><span>'tool-c'</span><span>,
  </span><span>name</span><span>: </span><span>'Tool C'</span><span>,
  </span><span>icon</span><span>: </span><span>'Puzzle'</span><span>,
  </span><span>route</span><span>: </span><span>'/tool-c'</span><span>,
  </span><span>permissions</span><span>: [</span><span>'tool_c:read'</span><span>, </span><span>'tool_c:write'</span><span>],
  </span><span>enabled</span><span>: </span><span>true</span><span>,
} </span><span>as</span><span></span><span>const</span><span>;
</span></span></code></div></div></pre>

### Champs du manifest :

| Champ           | Description                                 |
| --------------- | ------------------------------------------- |
| `id`          | Identifiant unique du tool                  |
| `name`        | Nom affiché dans la navigation             |
| `icon`        | Icône MUI/Lucide affichée dans la sidebar |
| `route`       | Route d’entrée du tool                    |
| `permissions` | Rôles ou scopes autorisés                 |
| `enabled`     | Activation via feature flag                 |

---

## 🧩 Étape 3 — Créer les composants principaux du tool

Chaque tool expose ses routes sous `src/routes/`.

### Exemple minimal

<pre class="overflow-visible!" data-start="2004" data-end="2264"><div class="contain-inline-size rounded-2xl relative bg-token-sidebar-surface-primary"><div class="sticky top-9"><div class="absolute end-0 bottom-0 flex h-9 items-center pe-2"><div class="bg-token-bg-elevated-secondary text-token-text-secondary flex items-center gap-4 rounded-sm px-2 font-sans text-xs"></div></div></div><div class="overflow-y-auto p-4" dir="ltr"><code class="whitespace-pre! language-tsx"><span><span>// packages/tools/tool-c/src/routes/home.tsx</span><span>
</span><span>'use client'</span><span>;
</span><span>import</span><span> { </span><span>Typography</span><span>, </span><span>Box</span><span> } </span><span>from</span><span></span><span>'@mui/material'</span><span>;

</span><span>export</span><span></span><span>function</span><span></span><span>ToolCHome</span><span>(</span><span></span><span>) {
  </span><span>return</span><span> (
    </span><span><span class="language-xml"><Box</span></span><span></span><span>p</span><span>=</span><span>{2}</span><span>>
      </span><span><Typography</span><span></span><span>variant</span><span>=</span><span>"h5"</span><span>>Bienvenue dans Tool C</span><span></Typography</span><span>>
    </span><span></Box</span><span>>
  );
}
</span></span></code></div></div></pre>

<pre class="overflow-visible!" data-start="2266" data-end="2567"><div class="contain-inline-size rounded-2xl relative bg-token-sidebar-surface-primary"><div class="sticky top-9"><div class="absolute end-0 bottom-0 flex h-9 items-center pe-2"><div class="bg-token-bg-elevated-secondary text-token-text-secondary flex items-center gap-4 rounded-sm px-2 font-sans text-xs"></div></div></div><div class="overflow-y-auto p-4" dir="ltr"><code class="whitespace-pre! language-tsx"><span><span>// packages/tools/tool-c/src/routes/list.tsx</span><span>
</span><span>'use client'</span><span>;
</span><span>import</span><span></span><span>Link</span><span></span><span>from</span><span></span><span>'next/link'</span><span>;
</span><span>import</span><span> { </span><span>Box</span><span>, </span><span>Button</span><span> } </span><span>from</span><span></span><span>'@mui/material'</span><span>;

</span><span>export</span><span></span><span>function</span><span></span><span>ToolCList</span><span>(</span><span></span><span>) {
  </span><span>return</span><span> (
    </span><span><span class="language-xml"><Box</span></span><span></span><span>p</span><span>=</span><span>{2}</span><span>>
      </span><span><Button</span><span></span><span>component</span><span>=</span><span>{Link}</span><span></span><span>href</span><span>=</span><span>"/tool-c/items/abc"</span><span>>Voir l’item ABC</span><span></Button</span><span>>
    </span><span></Box</span><span>>
  );
}
</span></span></code></div></div></pre>

<pre class="overflow-visible!" data-start="2569" data-end="2917"><div class="contain-inline-size rounded-2xl relative bg-token-sidebar-surface-primary"><div class="sticky top-9"><div class="absolute end-0 bottom-0 flex h-9 items-center pe-2"><div class="bg-token-bg-elevated-secondary text-token-text-secondary flex items-center gap-4 rounded-sm px-2 font-sans text-xs"></div></div></div><div class="overflow-y-auto p-4" dir="ltr"><code class="whitespace-pre! language-tsx"><span><span>// packages/tools/tool-c/src/routes/detail.tsx</span><span>
</span><span>'use client'</span><span>;
</span><span>import</span><span> { useParams } </span><span>from</span><span></span><span>'next/navigation'</span><span>;
</span><span>import</span><span> { </span><span>Box</span><span>, </span><span>Typography</span><span> } </span><span>from</span><span></span><span>'@mui/material'</span><span>;

</span><span>export</span><span></span><span>function</span><span></span><span>ToolCDetail</span><span>(</span><span></span><span>) {
  </span><span>const</span><span> { id } = useParams<{ </span><span>id</span><span>: </span><span>string</span><span> }>();
  </span><span>return</span><span> (
    </span><span><span class="language-xml"><Box</span></span><span></span><span>p</span><span>=</span><span>{2}</span><span>>
      </span><span><Typography</span><span></span><span>variant</span><span>=</span><span>"h6"</span><span>>Détail de {id}</span><span></Typography</span><span>>
    </span><span></Box</span><span>>
  );
}
</span></span></code></div></div></pre>

> Ces composants contiennent la logique du tool (UI, data, interactions).
>
> Ils seront **montés dans l’app shell** via des pages minces.

---

## 🧭 Étape 4 — Monter le tool dans le Shell Next.js

Le shell (dans `apps/web/app/(tools)/`) héberge les routes du tool.

<pre class="overflow-visible!" data-start="3187" data-end="3362"><div class="contain-inline-size rounded-2xl relative bg-token-sidebar-surface-primary"><div class="sticky top-9"><div class="absolute end-0 bottom-0 flex h-9 items-center pe-2"><div class="bg-token-bg-elevated-secondary text-token-text-secondary flex items-center gap-4 rounded-sm px-2 font-sans text-xs"></div></div></div><div class="overflow-y-auto p-4" dir="ltr"><code class="whitespace-pre!"><span><span>apps/web/app/(tools)/tool-c/
├─ layout.tsx
├─ page.tsx
├─ items/
│  ├─ page.tsx
│  └─ [</span><span>id</span><span>]/page.tsx
├─ @modal/
│  └─ (.)items/[</span><span>id</span><span>]/page.tsx
├─ loading.tsx
└─ error.tsx
</span></span></code></div></div></pre>

### Pages minces (réexport des routes)

<pre class="overflow-visible!" data-start="3403" data-end="3798"><div class="contain-inline-size rounded-2xl relative bg-token-sidebar-surface-primary"><div class="sticky top-9"><div class="absolute end-0 bottom-0 flex h-9 items-center pe-2"><div class="bg-token-bg-elevated-secondary text-token-text-secondary flex items-center gap-4 rounded-sm px-2 font-sans text-xs"></div></div></div><div class="overflow-y-auto p-4" dir="ltr"><code class="whitespace-pre! language-tsx"><span><span>// apps/web/app/(tools)/tool-c/page.tsx</span><span>
</span><span>import</span><span> { </span><span>ToolCHome</span><span> } </span><span>from</span><span></span><span>'@acme/tool-c/routes/home'</span><span>;
</span><span>export</span><span></span><span>default</span><span></span><span>ToolCHome</span><span>;

</span><span>// apps/web/app/(tools)/tool-c/items/page.tsx</span><span>
</span><span>import</span><span> { </span><span>ToolCList</span><span> } </span><span>from</span><span></span><span>'@acme/tool-c/routes/list'</span><span>;
</span><span>export</span><span></span><span>default</span><span></span><span>ToolCList</span><span>;

</span><span>// apps/web/app/(tools)/tool-c/items/[id]/page.tsx</span><span>
</span><span>import</span><span> { </span><span>ToolCDetail</span><span> } </span><span>from</span><span></span><span>'@acme/tool-c/routes/detail'</span><span>;
</span><span>export</span><span></span><span>default</span><span></span><span>ToolCDetail</span><span>;
</span></span></code></div></div></pre>

---

## 🧭 Étape 5 — Créer le layout local du tool

Chaque tool a son propre  **layout interne** , pour la navigation locale.

<pre class="overflow-visible!" data-start="3925" data-end="4539"><div class="contain-inline-size rounded-2xl relative bg-token-sidebar-surface-primary"><div class="sticky top-9"><div class="absolute end-0 bottom-0 flex h-9 items-center pe-2"><div class="bg-token-bg-elevated-secondary text-token-text-secondary flex items-center gap-4 rounded-sm px-2 font-sans text-xs"></div></div></div><div class="overflow-y-auto p-4" dir="ltr"><code class="whitespace-pre! language-tsx"><span><span>// apps/web/app/(tools)/tool-c/layout.tsx</span><span>
</span><span>import</span><span></span><span>Link</span><span></span><span>from</span><span></span><span>'next/link'</span><span>;
</span><span>import</span><span> { </span><span>Tabs</span><span>, </span><span>Tab</span><span> } </span><span>from</span><span></span><span>'@mui/material'</span><span>;
</span><span>import</span><span> { useSelectedLayoutSegment } </span><span>from</span><span></span><span>'next/navigation'</span><span>;

</span><span>export</span><span></span><span>default</span><span></span><span>function</span><span></span><span>ToolCLayout</span><span>(</span><span>{ children }: { children: React.ReactNode }</span><span>) {
  </span><span>const</span><span> segment = </span><span>useSelectedLayoutSegment</span><span>();

  </span><span>return</span><span> (
    </span><span><span class="language-xml"><></span></span><span>
      </span><span><Tabs</span><span></span><span>value</span><span>=</span><span>{segment</span><span> ?? '</span><span>home</span><span>'}>
        </span><span><Tab</span><span></span><span>value</span><span>=</span><span>"home"</span><span></span><span>label</span><span>=</span><span>"Accueil"</span><span></span><span>component</span><span>=</span><span>{Link}</span><span></span><span>href</span><span>=</span><span>"/tool-c"</span><span> />
        </span><span><Tab</span><span></span><span>value</span><span>=</span><span>"items"</span><span></span><span>label</span><span>=</span><span>"Items"</span><span></span><span>component</span><span>=</span><span>{Link}</span><span></span><span>href</span><span>=</span><span>"/tool-c/items"</span><span> />
      </span><span></Tabs</span><span>>

      </span><span><div</span><span></span><span>style</span><span>=</span><span>{{</span><span></span><span>padding:</span><span></span><span>16</span><span> }}>{children}</span><span></div</span><span>>
    </span><span></></span><span>
  );
}
</span></span></code></div></div></pre>

### Bonus : parallel routes pour modales

Exemple : vue rapide d’un item sans quitter la liste

<pre class="overflow-visible!" data-start="4636" data-end="4701"><div class="contain-inline-size rounded-2xl relative bg-token-sidebar-surface-primary"><div class="sticky top-9"><div class="absolute end-0 bottom-0 flex h-9 items-center pe-2"><div class="bg-token-bg-elevated-secondary text-token-text-secondary flex items-center gap-4 rounded-sm px-2 font-sans text-xs"></div></div></div><div class="overflow-y-auto p-4" dir="ltr"><code class="whitespace-pre!"><span><span>apps/web/app/(tools)/tool-c/@modal/(.)items/[</span><span>id</span><span>]/page.tsx
</span></span></code></div></div></pre>

---

## ⚙️ Étape 6 — Ajouter au registre global des tools

Le shell centralise tous les tools dans un fichier commun :

<pre class="overflow-visible!" data-start="4823" data-end="5047"><div class="contain-inline-size rounded-2xl relative bg-token-sidebar-surface-primary"><div class="sticky top-9"><div class="absolute end-0 bottom-0 flex h-9 items-center pe-2"><div class="bg-token-bg-elevated-secondary text-token-text-secondary flex items-center gap-4 rounded-sm px-2 font-sans text-xs"></div></div></div><div class="overflow-y-auto p-4" dir="ltr"><code class="whitespace-pre! language-ts"><span><span>// apps/web/app/(shell)/tool-registry.ts</span><span>
</span><span>import</span><span> toolA </span><span>from</span><span></span><span>'@acme/tool-a/manifest'</span><span>;
</span><span>import</span><span> toolB </span><span>from</span><span></span><span>'@acme/tool-b/manifest'</span><span>;
</span><span>import</span><span> toolC </span><span>from</span><span></span><span>'@acme/tool-c/manifest'</span><span>;

</span><span>export</span><span></span><span>const</span><span></span><span>TOOLS</span><span> = [toolA, toolB, toolC];
</span></span></code></div></div></pre>

Ce registre alimente :

* La **navigation globale** (sidebar, AppBar…)
* Les **autorisations** (permissions par role)
* L’**affichage conditionnel** (feature flags)

---

## 🔒 Étape 7 — Gérer la sécurité & RBAC

Le shell utilise un middleware pour filtrer l’accès aux routes du tool :

<pre class="overflow-visible!" data-start="5335" data-end="5825"><div class="contain-inline-size rounded-2xl relative bg-token-sidebar-surface-primary"><div class="sticky top-9"><div class="absolute end-0 bottom-0 flex h-9 items-center pe-2"><div class="bg-token-bg-elevated-secondary text-token-text-secondary flex items-center gap-4 rounded-sm px-2 font-sans text-xs"></div></div></div><div class="overflow-y-auto p-4" dir="ltr"><code class="whitespace-pre! language-ts"><span><span>// apps/web/middleware.ts</span><span>
</span><span>import</span><span> { </span><span>NextResponse</span><span> } </span><span>from</span><span></span><span>'next/server'</span><span>;
</span><span>import</span><span> { getSessionFromCookies } </span><span>from</span><span></span><span>'@acme/supabase/auth'</span><span>;

</span><span>export</span><span></span><span>async</span><span></span><span>function</span><span></span><span>middleware</span><span>(</span><span>req: Request</span><span>) {
  </span><span>const</span><span> { user, roles } = </span><span>await</span><span></span><span>getSessionFromCookies</span><span>(req);
  </span><span>const</span><span> url = </span><span>new</span><span></span><span>URL</span><span>(req.</span><span>url</span><span>);

  </span><span>// Protection du tool C</span><span>
  </span><span>if</span><span> (url.</span><span>pathname</span><span>.</span><span>startsWith</span><span>(</span><span>'/tool-c'</span><span>) && !roles.</span><span>includes</span><span>(</span><span>'tool_c:read'</span><span>)) {
    </span><span>return</span><span></span><span>NextResponse</span><span>.</span><span>redirect</span><span>(</span><span>new</span><span></span><span>URL</span><span>(</span><span>'/forbidden'</span><span>, req.</span><span>url</span><span>));
  }

  </span><span>return</span><span></span><span>NextResponse</span><span>.</span><span>next</span><span>();
}
</span></span></code></div></div></pre>

---

## 🧮 Étape 8 — Créer le schéma Supabase du tool

Chaque tool peut avoir ses propres tables dans un **schéma dédié** (`tool_c`).

Exemple SQL :

<pre class="overflow-visible!" data-start="5977" data-end="6445"><div class="contain-inline-size rounded-2xl relative bg-token-sidebar-surface-primary"><div class="sticky top-9"><div class="absolute end-0 bottom-0 flex h-9 items-center pe-2"><div class="bg-token-bg-elevated-secondary text-token-text-secondary flex items-center gap-4 rounded-sm px-2 font-sans text-xs"></div></div></div><div class="overflow-y-auto p-4" dir="ltr"><code class="whitespace-pre! language-sql"><span><span>create</span><span> schema if </span><span>not</span><span></span><span>exists</span><span> tool_c;

</span><span>create</span><span></span><span>table</span><span> tool_c.items (
  id uuid </span><span>primary</span><span> key </span><span>default</span><span> gen_random_uuid(),
  org_id uuid </span><span>references</span><span> public.organizations(id),
  name text,
  created_by uuid </span><span>references</span><span> auth.users(id),
  inserted_at timestamptz </span><span>default</span><span> now()
);

</span><span>alter</span><span></span><span>table</span><span> tool_c.items enable </span><span>row</span><span> level security;

</span><span>create</span><span> policy "Org members can read tool_c.items"
</span><span>on</span><span> tool_c.items
</span><span>for</span><span></span><span>select</span><span>
</span><span>to</span><span> authenticated
</span><span>using</span><span> ( org_id </span><span>=</span><span> auth.jwt() </span><span>-</span><span>>></span><span></span><span>'org_id'</span><span> );
</span></span></code></div></div></pre>

> Chaque requête Supabase utilisera le `client` mutualisé (`@acme/supabase`).

---

## 📡 Étape 9 — Ajouter les hooks de données (optionnel)

Dans `packages/tools/tool-c/src/data/`, tu peux créer des hooks dédiés :

<pre class="overflow-visible!" data-start="6663" data-end="7102"><div class="contain-inline-size rounded-2xl relative bg-token-sidebar-surface-primary"><div class="sticky top-9"><div class="absolute end-0 bottom-0 flex h-9 items-center pe-2"><div class="bg-token-bg-elevated-secondary text-token-text-secondary flex items-center gap-4 rounded-sm px-2 font-sans text-xs"></div></div></div><div class="overflow-y-auto p-4" dir="ltr"><code class="whitespace-pre! language-ts"><span><span>// packages/tools/tool-c/src/data/useItems.ts</span><span>
</span><span>'use client'</span><span>;
</span><span>import</span><span> { createBrowserSupabase } </span><span>from</span><span></span><span>'@acme/supabase'</span><span>;
</span><span>import</span><span> { useEffect, useState } </span><span>from</span><span></span><span>'react'</span><span>;

</span><span>export</span><span></span><span>function</span><span></span><span>useItems</span><span>(</span><span></span><span>) {
  </span><span>const</span><span> [items, setItems] = useState<</span><span>any</span><span>[]>([]);
  </span><span>const</span><span> supabase = </span><span>createBrowserSupabase</span><span>();

  </span><span>useEffect</span><span>(</span><span>() =></span><span> {
    supabase.</span><span>from</span><span>(</span><span>'tool_c.items'</span><span>).</span><span>select</span><span>(</span><span>'*'</span><span>).</span><span>then</span><span>(</span><span>({ data }</span><span>) => </span><span>setItems</span><span>(data ?? []));
  }, [supabase]);

  </span><span>return</span><span> items;
}
</span></span></code></div></div></pre>

> Ces hooks peuvent être réutilisés dans les composants de routes.

---

## 🧪 Étape 10 — Vérifications

Avant de commit :

<pre class="overflow-visible!" data-start="7228" data-end="7284"><div class="contain-inline-size rounded-2xl relative bg-token-sidebar-surface-primary"><div class="sticky top-9"><div class="absolute end-0 bottom-0 flex h-9 items-center pe-2"><div class="bg-token-bg-elevated-secondary text-token-text-secondary flex items-center gap-4 rounded-sm px-2 font-sans text-xs"></div></div></div><div class="overflow-y-auto p-4" dir="ltr"><code class="whitespace-pre! language-bash"><span><span>pnpm -r lint
pnpm -r typecheck
pnpm -r build
</span></span></code></div></div></pre>

Checklist :

* [X] Le tool apparaît dans la navigation du shell
* [X] Les pages fonctionnent (`/tool-c`, `/tool-c/items`)
* [X] La sécurité RBAC redirige les utilisateurs non autorisés
* [X] Les hooks Supabase fonctionnent avec la base partagée
* [X] Le thème MUI du shell est appliqué

---

## ⚙️ Étape 11 — Tests et CI

* Tests unitaires : `vitest` ou `jest` dans le package
* Tests e2e : `playwright` dans `apps/web`
* Pipeline Turborepo :

<pre class="overflow-visible!" data-start="7737" data-end="7974"><div class="contain-inline-size rounded-2xl relative bg-token-sidebar-surface-primary"><div class="sticky top-9"><div class="absolute end-0 bottom-0 flex h-9 items-center pe-2"><div class="bg-token-bg-elevated-secondary text-token-text-secondary flex items-center gap-4 rounded-sm px-2 font-sans text-xs"></div></div></div><div class="overflow-y-auto p-4" dir="ltr"><code class="whitespace-pre! language-json"><span><span>// turbo.json</span><span>
</span><span>{</span><span>
  </span><span>"pipeline"</span><span>:</span><span></span><span>{</span><span>
    </span><span>"build"</span><span>:</span><span></span><span>{</span><span></span><span>"dependsOn"</span><span>:</span><span></span><span>[</span><span>"^build"</span><span>]</span><span>,</span><span></span><span>"outputs"</span><span>:</span><span></span><span>[</span><span>".next/**"</span><span>,</span><span></span><span>"dist/**"</span><span>]</span><span></span><span>}</span><span>,</span><span>
    </span><span>"lint"</span><span>:</span><span></span><span>{</span><span></span><span>"outputs"</span><span>:</span><span></span><span>[</span><span>]</span><span></span><span>}</span><span>,</span><span>
    </span><span>"typecheck"</span><span>:</span><span></span><span>{</span><span></span><span>"outputs"</span><span>:</span><span></span><span>[</span><span>]</span><span></span><span>}</span><span>,</span><span>
    </span><span>"test"</span><span>:</span><span></span><span>{</span><span></span><span>"outputs"</span><span>:</span><span></span><span>[</span><span>"coverage/**"</span><span>]</span><span></span><span>}</span><span>
  </span><span>}</span><span>
</span><span>}</span><span>
</span></span></code></div></div></pre>

---

## 🧠 En résumé

| Étape | Action                                | Fichier clé                     |
| ------ | ------------------------------------- | -------------------------------- |
| 1️⃣  | Créer le package du tool             | `packages/tools/tool-c/`       |
| 2️⃣  | Définir le manifest                  | `src/manifest.ts`              |
| 3️⃣  | Créer les routes et composants       | `src/routes/`                  |
| 4️⃣  | Monter les pages minces dans le shell | `apps/web/app/(tools)/tool-c/` |
| 5️⃣  | Ajouter un layout local               | `layout.tsx`                   |
| 6️⃣  | Enregistrer dans le registre global   | `tool-registry.ts`             |
| 7️⃣  | Gérer le RBAC via middleware         | `middleware.ts`                |
| 8️⃣  | Créer le schéma Supabase (RLS)      | SQL                              |
| 9️⃣  | Ajouter des hooks de data (optionnel) | `src/data/`                    |
| 🔟     | Tester et valider                     | `pnpm -r build`                |

---

## 🧰 Bonus — Outils utiles

| Besoin                                    | Outil recommandé                        |
| ----------------------------------------- | ---------------------------------------- |
| **Scaffold automatique d’un tool** | Script Turborepo custom                  |
| **Validation des envs**             | `zod`+`env.mjs`                      |
| **Typage Supabase**                 | `supabase gen types typescript`        |
| **CI/CD Vercel**                    | Monorepo auto-build apps                 |
| **Tests e2e**                       | Playwright                               |
| **Feature Flags**                   | Table `features`+`@acme/utils/flags` |

---

## 🚀 Résultat attendu

Une fois le tool intégré :

* Il **apparaît automatiquement** dans la navigation globale
* Il **bénéficie du thème, de l’auth et du client Supabase**
* Il **dispose de son propre mini-router interne**
* Il est **isolé et versionné indépendamment**
