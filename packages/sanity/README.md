# @repo/sanity

Package Sanity CMS pour le monorepo blancherenaudin.

## Installation

Ce package est automatiquement installé via pnpm workspace.

## Usage

### Client Sanity

```typescript
import { sanityClient } from '@repo/sanity/client'

const data = await sanityClient.fetch(query)
```

### Queries GROQ

```typescript
import { HOMEPAGE_QUERY, LOOKBOOKS_QUERY } from '@repo/sanity/queries'

const homepage = await sanityClient.fetch(HOMEPAGE_QUERY)
```

### Helper d'images

```typescript
import { urlFor } from '@repo/sanity/image'

const imageUrl = urlFor(image).width(800).height(600).url()
```

### Configuration Studio

```typescript
import { sanityConfig } from '@repo/sanity/config'
```

## Structure

```
src/
├── schemas/          # Schémas de contenu
│   ├── types/       # Types de documents
│   └── index.ts     # Export des schémas
├── lib/
│   ├── client.ts    # Client Sanity configuré
│   ├── queries.ts   # Queries GROQ
│   └── image-helpers.ts  # Helper urlFor
├── config.ts        # Configuration Sanity Studio
├── structure.ts     # Structure du Studio
└── index.ts         # Exports principaux
```

## Variables d'environnement

```bash
NEXT_PUBLIC_SANITY_PROJECT_ID=xxx
NEXT_PUBLIC_SANITY_DATASET=production
```
