// packages/sanity/src/lib/queries.ts

// === Homepage ===
export const HOMEPAGE_QUERY = `*[_type=="homepage" && _id == "homepage-singleton"][0]{
  hero {
    title,
    subtitle,
    image,
    ctaLabel,
    ctaLink
  },
  zoneHauts {
    image,
    title,
    subtitle,
    link
  },
  zoneBas {
    image,
    title,
    subtitle,
    link
  },
  zoneAccessoires {
    image,
    title,
    subtitle,
    link
  },
  zoneSilhouettes {
    image,
    title,
    subtitle,
    link
  },
   zoneImpact {
    image,
    title,
    subtitle,
    link
  },
  seo
}`

// === Collections éditoriales ===
export const COLLECTIONS_EDITORIALES_QUERY = `*[
  _type == "collectionEditoriale" && coalesce(published, true) == true   
] | order(_createdAt desc) {
  _id,
  name,
  slug,
  coverImage,
  intro,
  gallery,
  seo
}`

export const COLLECTION_EDITORIALE_QUERY = `*[
  _type=="collectionEditoriale" &&
  slug.current == $slug &&
  coalesce(published, true) == true
][0]{
  _id,
  name,
  slug,
  intro,
  gallery,
  seo
}`

// === Lookbooks ===
export const LOOKBOOKS_QUERY = `*[
  _type == "lookbook" && coalesce(published, true) == true
] | order(_createdAt desc) {
  _id,
  title,
  season,
  slug,
  coverImage,
  images,
  seo
}`

export const LOOKBOOK_QUERY = `*[
  _type=="lookbook" &&
  slug.current == $slug &&
  coalesce(published, true) == true
][0]{
  _id,
  title,
  subtitle,
  season,
  slug,
  images,
  seo
}`

// === Pages statiques ===
export const PAGE_QUERY = `*[_type=="page" && slug.current == $slug][0]{
  _id,
  title,
  slug,
  content,
  seo
}`

export const PAGES_QUERY = `*[_type=="page"] | order(_createdAt desc) {
  _id,
  title,
  slug,
  content,
  seo
}`
