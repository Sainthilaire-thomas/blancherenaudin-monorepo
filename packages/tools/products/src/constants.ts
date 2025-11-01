// packages/tools/products/src/constants.ts

export const PRODUCT_STATUS = {
  DRAFT: 'draft',
  PUBLISHED: 'published',
  ARCHIVED: 'archived',
} as const

export const PRODUCT_SORT_OPTIONS = [
  { label: 'Plus récents', value: 'created_at_desc' },
  { label: 'Plus anciens', value: 'created_at_asc' },
  { label: 'Prix croissant', value: 'price_asc' },
  { label: 'Prix décroissant', value: 'price_desc' },
  { label: 'Nom A-Z', value: 'name_asc' },
  { label: 'Nom Z-A', value: 'name_desc' },
] as const

export const DEFAULT_PAGE_SIZE = 20
