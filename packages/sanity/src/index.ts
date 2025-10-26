// packages/sanity/src/index.ts
// ❌ NE PAS EXPORTER LE CONFIG (contient l'éditeur Sanity)
// export { default as sanityConfig } from './config'
// export * from './structure'
// export * from './schemas'

// ✅ Exports des lib uniquement (client léger)
export * from './lib/client'
export * from './lib/queries'
export * from './lib/image-helpers'

// Exports nommés
export { client, client as sanityClient } from './lib/client'
export { urlFor } from './lib/image-helpers'

// ✅ Ré-exports pour les queries
export { PAGE_QUERY } from './lib/queries'
