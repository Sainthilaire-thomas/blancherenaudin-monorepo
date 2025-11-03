// packages/tools/categories/src/routes/CategoriesListSync.tsx
import { CategoriesClient } from './CategoriesClient'

export function CategoriesListSync() {
  // Version synchrone pour test - pas d'appel API
  return <CategoriesClient initialCategories={[]} />
}