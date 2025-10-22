// packages/sanity/src/index.ts

// Re-export du client Sanity
export * from './lib/client'

// Re-export des queries GROQ
export * from './lib/queries'

// Re-export du helper d'images
export { urlFor } from './lib/image-helpers'

// Re-export de la configuration (pour le Studio)
export { default as sanityConfig } from './config'

// Re-export de la structure (pour le Studio)
export { structure } from './structure'

// Re-export des schémas (pour le Studio)
export { schemaTypes } from './schemas'
