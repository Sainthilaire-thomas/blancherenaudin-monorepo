// packages/sanity/src/index.ts

export * from './config'
export * from './structure'
export * from './schemas'

// Exports des lib
export * from './lib/client'
export * from './lib/queries'
export * from './lib/image-helpers'

// Exports nommés
export { client, client as sanityClient } from './lib/client'
export { urlFor } from './lib/image-helpers'
