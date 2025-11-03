# **Document 1 — Architecture générale & fonctionnement du routage**

---

## 🎯 Objectifs

Cette architecture monorepo a pour but de :

* Centraliser plusieurs **tools indépendants** (ex :  *Évaluation* ,  *Coaching* ,  *Admin* ,  *Analytics* …)
* Partager un  **design system** , une **authentification commune (Supabase)** et une **base de données unique**
* Garantir une **expérience fluide et cohérente** via un **shell applicatif unique** (Next.js App Router)

---

## 🧩 Structure générale du monorepo

Le projet suit une organisation **modulaire** sous Turborepo + pnpm :

<pre class="overflow-visible!" data-start="845" data-end="1844"><div class="contain-inline-size rounded-2xl relative bg-token-sidebar-surface-primary"><div class="sticky top-9"><div class="absolute end-0 bottom-0 flex h-9 items-center pe-2"><div class="bg-token-bg-elevated-secondary text-token-text-secondary flex items-center gap-4 rounded-sm px-2 font-sans text-xs"></div></div></div><div class="overflow-y-auto p-4" dir="ltr"><code class="whitespace-pre!"><span><span>.
├─ apps/
│  └─ web/                     </span><span># App Next.js "Shell"</span><span>
│     ├─ app/
│     │  ├─ (shell)/           </span><span># Layout global, auth, navigation, etc.</span><span>
│     │  ├─ (tools)/           </span><span># Montage dynamique des tools</span><span>
│     │  └─ api/               </span><span># Routes API locales (si besoin)</span><span>
│     ├─ middleware.ts         </span><span># RBAC et protection d'accès</span><span>
│     ├─ </span><span>next</span><span>.config.mjs
│     └─ env.mjs               </span><span># Validation typée des variables d'env</span><span>
│
├─ packages/
│  ├─ ui/                      </span><span># @acme</span><span>/ui (Design System MUI)
│  ├─ supabase/                </span><span># @acme</span><span>/supabase (client, hooks, RLS)
│  ├─ types/                   </span><span># @acme</span><span>/types (modèles, schémas Zod)
│  ├─ utils/                   </span><span># @acme</span><span>/utils (helpers, flags, formatters)
│  ├─ config/                  </span><span># @acme</span><span>/config (ESLint, TS, Prettier)
│  └─ tools/
│     ├─ tool-a/               </span><span># @acme</span><span>/tool-a
│     ├─ tool-b/               </span><span># @acme</span><span>/tool-b
│     └─ tool-c/               </span><span># @acme</span><span>/tool-c
│
├─ turbo.json
├─ pnpm-workspace.yaml
└─ package.json
</span></span></code></div></div></pre>

---

## 🧱 Rôle du Shell (apps/web)

Le **shell** est  **le cœur de l’application Next.js** .

C’est lui qui :

1. **Héberge l’App Router global** (layout principal, navigation, routes, modales, etc.)
2. **Fournit le Design System** à tous les tools (`ThemeProvider`, `CssBaseline`, etc.)
3. **Gère l’authentification** (Supabase Auth, RBAC)
4. **Charge dynamiquement** les tools installés (grâce à un registre ou à des Route Groups)
5. **Définit les politiques de sécurité** (middleware, redirections)
6. **Centralise la navigation principale** : sidebar / topbar / breadcrumbs
7. **Coordonne les transitions** entre tools pour une UX fluide

> 💡 Le shell joue donc le rôle d’un **“système d’exploitation interne”** :
>
> il ne contient pas la logique métier, mais  **héberge et orchestre les tools** .

---

## 🎨 Partage du Design System (UI)

Le package `@acme/ui` contient :

* Le **thème MUI** (`theme.ts`)
* Les **composants communs** (AppShell, Drawer, Buttons, Cards…)
* Les **tokens** (couleurs, typographies, espacements)

Le shell applique ce thème globalement :

<pre class="overflow-visible!" data-start="2918" data-end="3509"><div class="contain-inline-size rounded-2xl relative bg-token-sidebar-surface-primary"><div class="sticky top-9"><div class="absolute end-0 bottom-0 flex h-9 items-center pe-2"><div class="bg-token-bg-elevated-secondary text-token-text-secondary flex items-center gap-4 rounded-sm px-2 font-sans text-xs"></div></div></div><div class="overflow-y-auto p-4" dir="ltr"><code class="whitespace-pre! language-tsx"><span><span>// apps/web/app/(shell)/layout.tsx</span><span>
</span><span>'use client'</span><span>;

</span><span>import</span><span> { </span><span>ThemeProvider</span><span>, </span><span>CssBaseline</span><span> } </span><span>from</span><span></span><span>'@mui/material'</span><span>;
</span><span>import</span><span> { theme, </span><span>AppShell</span><span> } </span><span>from</span><span></span><span>'@acme/ui'</span><span>;
</span><span>import</span><span> { </span><span>ToolNav</span><span> } </span><span>from</span><span></span><span>'./tool-nav'</span><span>;
</span><span>import</span><span> { </span><span>Suspense</span><span> } </span><span>from</span><span></span><span>'react'</span><span>;

</span><span>export</span><span></span><span>default</span><span></span><span>function</span><span></span><span>RootLayout</span><span>(</span><span>{ children }: { children: React.ReactNode }</span><span>) {
  </span><span>return</span><span> (
    </span><span><span class="language-xml"><html</span></span><span></span><span>lang</span><span>=</span><span>"fr"</span><span>>
      </span><span><body</span><span>>
        </span><span><ThemeProvider</span><span></span><span>theme</span><span>=</span><span>{theme}</span><span>>
          </span><span><CssBaseline</span><span> />
          </span><span><AppShell</span><span></span><span>nav</span><span>=</span><span>{</span><span><</span><span>ToolNav</span><span> />}>
            </span><span><Suspense</span><span>>{children}</span><span></Suspense</span><span>>
          </span><span></AppShell</span><span>>
        </span><span></ThemeProvider</span><span>>
      </span><span></body</span><span>>
    </span><span></html</span><span>>
  );
}
</span></span></code></div></div></pre>

Tous les tools héritent ainsi automatiquement du même look & feel.

---

## 🔑 Partage de Supabase

Le package `@acme/supabase` expose un client commun :

<pre class="overflow-visible!" data-start="3665" data-end="4154"><div class="contain-inline-size rounded-2xl relative bg-token-sidebar-surface-primary"><div class="sticky top-9"><div class="absolute end-0 bottom-0 flex h-9 items-center pe-2"><div class="bg-token-bg-elevated-secondary text-token-text-secondary flex items-center gap-4 rounded-sm px-2 font-sans text-xs"></div></div></div><div class="overflow-y-auto p-4" dir="ltr"><code class="whitespace-pre! language-ts"><span><span>// packages/supabase/src/client.ts</span><span>
</span><span>import</span><span> { createBrowserClient, createServerClient } </span><span>from</span><span></span><span>'@supabase/ssr'</span><span>;

</span><span>export</span><span></span><span>const</span><span></span><span>createBrowserSupabase</span><span> = (</span><span></span><span>) =>
  </span><span>createBrowserClient</span><span>(
    process.</span><span>env</span><span>.</span><span>NEXT_PUBLIC_SUPABASE_URL</span><span>!,
    process.</span><span>env</span><span>.</span><span>NEXT_PUBLIC_SUPABASE_ANON_KEY</span><span>!
  );

</span><span>export</span><span></span><span>const</span><span></span><span>createServerSupabase</span><span> = (</span><span>cookies: () => Record<string</span><span>, </span><span>string</span><span>>) =>
  </span><span>createServerClient</span><span>(
    process.</span><span>env</span><span>.</span><span>NEXT_PUBLIC_SUPABASE_URL</span><span>!,
    process.</span><span>env</span><span>.</span><span>SUPABASE_SERVICE_ROLE_KEY</span><span>!,
    { cookies }
  );
</span></span></code></div></div></pre>

### Avantages :

* Auth partagée entre tous les tools
* Connexion unique (session persistée)
* Sécurité via **RLS par `org_id` ou `user_id`**
* Hooks réutilisables (`useSupabase`, `useSession`, etc.)

---

## 🧭 Fonctionnement du routage global

Next.js (App Router) gère tout le routage du shell et des tools :

<pre class="overflow-visible!" data-start="4468" data-end="4742"><div class="contain-inline-size rounded-2xl relative bg-token-sidebar-surface-primary"><div class="sticky top-9"><div class="absolute end-0 bottom-0 flex h-9 items-center pe-2"><div class="bg-token-bg-elevated-secondary text-token-text-secondary flex items-center gap-4 rounded-sm px-2 font-sans text-xs"></div></div></div><div class="overflow-y-auto p-4" dir="ltr"><code class="whitespace-pre!"><span><span>apps/web/app/
├─ (shell)/                   </span><span># Layout global</span><span>
│  ├─ layout.tsx
│  └─ page.tsx                </span><span># Page d’accueil</span><span>
├─ (tools)/                   </span><span># Montage des tools</span><span>
│  ├─ tool-a/
│  ├─ tool-b/
│  └─ tool-c/
└─ api/                       </span><span># Routes API locales</span><span>
</span></span></code></div></div></pre>

### Principe

* Chaque **tool** est monté dans `(tools)/tool-x/`
* Ces routes **ne contiennent que des wrappers** qui réexportent les composants du package correspondant
* Chaque tool définit ses propres sous-pages et layouts locaux

---

## 🧩 Exemple de structure d’un tool monté

<pre class="overflow-visible!" data-start="5026" data-end="5354"><div class="contain-inline-size rounded-2xl relative bg-token-sidebar-surface-primary"><div class="sticky top-9"><div class="absolute end-0 bottom-0 flex h-9 items-center pe-2"><div class="bg-token-bg-elevated-secondary text-token-text-secondary flex items-center gap-4 rounded-sm px-2 font-sans text-xs"></div></div></div><div class="overflow-y-auto p-4" dir="ltr"><code class="whitespace-pre!"><span><span>apps/web/app/(tools)/tool-a/
├─ layout.tsx            </span><span># Sous-layout du tool A (onglets, breadcrumb)</span><span>
├─ page.tsx              </span><span># Accueil du tool</span><span>
├─ items/
│  ├─ page.tsx           </span><span># Liste d’items</span><span>
│  └─ [</span><span>id</span><span>]/page.tsx      </span><span># Détail</span><span>
├─ @modal/
│  └─ (.)items/[</span><span>id</span><span>]/page.tsx   </span><span># Vue rapide en modale</span><span>
├─ loading.tsx
└─ error.tsx
</span></span></code></div></div></pre>

### Exemple de page “mince”

<pre class="overflow-visible!" data-start="5384" data-end="5521"><div class="contain-inline-size rounded-2xl relative bg-token-sidebar-surface-primary"><div class="sticky top-9"><div class="absolute end-0 bottom-0 flex h-9 items-center pe-2"><div class="bg-token-bg-elevated-secondary text-token-text-secondary flex items-center gap-4 rounded-sm px-2 font-sans text-xs"></div></div></div><div class="overflow-y-auto p-4" dir="ltr"><code class="whitespace-pre! language-tsx"><span><span>// apps/web/app/(tools)/tool-a/items/page.tsx</span><span>
</span><span>import</span><span> { </span><span>ItemsPage</span><span> } </span><span>from</span><span></span><span>'@acme/tool-a/routes/items'</span><span>;
</span><span>export</span><span></span><span>default</span><span></span><span>ItemsPage</span><span>;
</span></span></code></div></div></pre>

---

## 🧱 Routage interne à un tool

Chaque tool a :

* Son **layout local** (`layout.tsx`) : gère la navigation interne (onglets, breadcrumb)
* Ses **pages** : listes, détails, création, etc.
* Ses **modales** : interceptées avec `@modal` (parallel routes)
* Ses **états de chargement** : `loading.tsx` / `error.tsx`

### Exemple : layout local

<pre class="overflow-visible!" data-start="5869" data-end="6481"><div class="contain-inline-size rounded-2xl relative bg-token-sidebar-surface-primary"><div class="sticky top-9"><div class="absolute end-0 bottom-0 flex h-9 items-center pe-2"><div class="bg-token-bg-elevated-secondary text-token-text-secondary flex items-center gap-4 rounded-sm px-2 font-sans text-xs"></div></div></div><div class="overflow-y-auto p-4" dir="ltr"><code class="whitespace-pre! language-tsx"><span><span>// apps/web/app/(tools)/tool-a/layout.tsx</span><span>
</span><span>import</span><span> { </span><span>Tabs</span><span>, </span><span>Tab</span><span> } </span><span>from</span><span></span><span>'@mui/material'</span><span>;
</span><span>import</span><span></span><span>Link</span><span></span><span>from</span><span></span><span>'next/link'</span><span>;
</span><span>import</span><span> { useSelectedLayoutSegment } </span><span>from</span><span></span><span>'next/navigation'</span><span>;

</span><span>export</span><span></span><span>default</span><span></span><span>function</span><span></span><span>ToolALayout</span><span>(</span><span>{ children }: { children: React.ReactNode }</span><span>) {
  </span><span>const</span><span> segment = </span><span>useSelectedLayoutSegment</span><span>();
  </span><span>return</span><span> (
    </span><span><span class="language-xml"><></span></span><span>
      </span><span><Tabs</span><span></span><span>value</span><span>=</span><span>{segment</span><span> ?? '</span><span>home</span><span>'}>
        </span><span><Tab</span><span></span><span>value</span><span>=</span><span>"home"</span><span></span><span>label</span><span>=</span><span>"Accueil"</span><span></span><span>component</span><span>=</span><span>{Link}</span><span></span><span>href</span><span>=</span><span>"/tool-a"</span><span> />
        </span><span><Tab</span><span></span><span>value</span><span>=</span><span>"items"</span><span></span><span>label</span><span>=</span><span>"Items"</span><span></span><span>component</span><span>=</span><span>{Link}</span><span></span><span>href</span><span>=</span><span>"/tool-a/items"</span><span> />
      </span><span></Tabs</span><span>>
      </span><span><div</span><span></span><span>style</span><span>=</span><span>{{</span><span></span><span>padding:</span><span></span><span>16</span><span> }}>{children}</span><span></div</span><span>>
    </span><span></></span><span>
  );
}
</span></span></code></div></div></pre>

### Exemple : navigation interne

<pre class="overflow-visible!" data-start="6516" data-end="6853"><div class="contain-inline-size rounded-2xl relative bg-token-sidebar-surface-primary"><div class="sticky top-9"><div class="absolute end-0 bottom-0 flex h-9 items-center pe-2"><div class="bg-token-bg-elevated-secondary text-token-text-secondary flex items-center gap-4 rounded-sm px-2 font-sans text-xs"></div></div></div><div class="overflow-y-auto p-4" dir="ltr"><code class="whitespace-pre! language-tsx"><span><span>'use client'</span><span>;
</span><span>import</span><span> { useRouter } </span><span>from</span><span></span><span>'next/navigation'</span><span>;
</span><span>import</span><span></span><span>Link</span><span></span><span>from</span><span></span><span>'next/link'</span><span>;

</span><span>export</span><span></span><span>function</span><span></span><span>ItemsPage</span><span>(</span><span></span><span>) {
  </span><span>const</span><span> router = </span><span>useRouter</span><span>();
  </span><span>return</span><span> (
    </span><span><span class="language-xml"><></span></span><span>
      </span><span><Link</span><span></span><span>href</span><span>=</span><span>"/tool-a/items/123"</span><span>>Voir item 123</span><span></Link</span><span>>
      </span><span><button</span><span></span><span>onClick</span><span>=</span><span>{()</span><span> => router.push('/tool-a/items/new')}>Créer un item</span><span></button</span><span>>
    </span><span></></span><span>
  );
}
</span></span></code></div></div></pre>

---

## 🔒 Authentification et RBAC

* Auth Supabase (email, magic link, OAuth)
* Table `memberships` : `user_id`, `org_id`, `role`
* Middleware Next protège les routes :

<pre class="overflow-visible!" data-start="7027" data-end="7491"><div class="contain-inline-size rounded-2xl relative bg-token-sidebar-surface-primary"><div class="sticky top-9"><div class="absolute end-0 bottom-0 flex h-9 items-center pe-2"><div class="bg-token-bg-elevated-secondary text-token-text-secondary flex items-center gap-4 rounded-sm px-2 font-sans text-xs"></div></div></div><div class="overflow-y-auto p-4" dir="ltr"><code class="whitespace-pre! language-ts"><span><span>// apps/web/middleware.ts</span><span>
</span><span>import</span><span> { </span><span>NextResponse</span><span> } </span><span>from</span><span></span><span>'next/server'</span><span>;
</span><span>import</span><span> { getSessionFromCookies } </span><span>from</span><span></span><span>'@acme/supabase/auth'</span><span>;

</span><span>export</span><span></span><span>async</span><span></span><span>function</span><span></span><span>middleware</span><span>(</span><span>req: Request</span><span>) {
  </span><span>const</span><span> { user, roles } = </span><span>await</span><span></span><span>getSessionFromCookies</span><span>(req);
  </span><span>const</span><span> url = </span><span>new</span><span></span><span>URL</span><span>(req.</span><span>url</span><span>);

  </span><span>if</span><span> (url.</span><span>pathname</span><span>.</span><span>startsWith</span><span>(</span><span>'/tool-a'</span><span>) && !roles.</span><span>includes</span><span>(</span><span>'tool_a_user'</span><span>)) {
    </span><span>return</span><span></span><span>NextResponse</span><span>.</span><span>redirect</span><span>(</span><span>new</span><span></span><span>URL</span><span>(</span><span>'/forbidden'</span><span>, req.</span><span>url</span><span>));
  }

  </span><span>return</span><span></span><span>NextResponse</span><span>.</span><span>next</span><span>();
}
</span></span></code></div></div></pre>

---

## ⚙️ Registre de tools (plugin system)

Chaque tool déclare un `manifest.ts` :

<pre class="overflow-visible!" data-start="7578" data-end="7794"><div class="contain-inline-size rounded-2xl relative bg-token-sidebar-surface-primary"><div class="sticky top-9"><div class="absolute end-0 bottom-0 flex h-9 items-center pe-2"><div class="bg-token-bg-elevated-secondary text-token-text-secondary flex items-center gap-4 rounded-sm px-2 font-sans text-xs"></div></div></div><div class="overflow-y-auto p-4" dir="ltr"><code class="whitespace-pre! language-ts"><span><span>// packages/tools/tool-a/src/manifest.ts</span><span>
</span><span>export</span><span></span><span>default</span><span> {
  </span><span>id</span><span>: </span><span>'tool-a'</span><span>,
  </span><span>name</span><span>: </span><span>'Tool A'</span><span>,
  </span><span>icon</span><span>: </span><span>'Square'</span><span>,
  </span><span>route</span><span>: </span><span>'/tool-a'</span><span>,
  </span><span>permissions</span><span>: [</span><span>'read_tool_a'</span><span>, </span><span>'write_tool_a'</span><span>],
  </span><span>enabled</span><span>: </span><span>true</span><span>,
} </span><span>as</span><span></span><span>const</span><span>;
</span></span></code></div></div></pre>

Le shell les référence dans :

<pre class="overflow-visible!" data-start="7826" data-end="7999"><div class="contain-inline-size rounded-2xl relative bg-token-sidebar-surface-primary"><div class="sticky top-9"><div class="absolute end-0 bottom-0 flex h-9 items-center pe-2"><div class="bg-token-bg-elevated-secondary text-token-text-secondary flex items-center gap-4 rounded-sm px-2 font-sans text-xs"></div></div></div><div class="overflow-y-auto p-4" dir="ltr"><code class="whitespace-pre! language-ts"><span><span>// apps/web/app/(shell)/tool-registry.ts</span><span>
</span><span>import</span><span> toolA </span><span>from</span><span></span><span>'@acme/tool-a/manifest'</span><span>;
</span><span>import</span><span> toolB </span><span>from</span><span></span><span>'@acme/tool-b/manifest'</span><span>;
</span><span>export</span><span></span><span>const</span><span></span><span>TOOLS</span><span> = [toolA, toolB];
</span></span></code></div></div></pre>

Ce registre alimente :

* Le menu de navigation
* Les redirections
* Les permissions d’accès

---

## 🚀 Avantages de cette architecture

| Domaine                       | Bénéfice                                           |
| ----------------------------- | ---------------------------------------------------- |
| **Scalabilité**        | Ajout d’un nouveau tool sans impacter les autres    |
| **Cohérence visuelle** | Design System centralisé                            |
| **Sécurité**          | Auth & RLS mutualisés                               |
| **Performance**         | Code splitting natif (App Router)                    |
| **Maintenance**         | Tools isolés → builds et tests indépendants       |
| **Déploiement**        | Un seul déploiement Next.js (Vercel ou self-hosted) |

---

## 🧠 En résumé

* Le **shell** = cœur applicatif, layout global, navigation, auth, orchestration.
* Les **tools** = modules métiers autonomes, montés sous `(tools)/`.
* Le  **Design System** , la **base Supabase** et les **types** sont partagés.
* Le **routage App Router** gère :
  * Navigation inter-tool (via le shell)
  * Navigation intra-tool (via le layout local)
  * Modales & états (via parallel/intercepting routes)
* L’**authentification** et le **RBAC** sont centralisés, mais appliqués par tool.
