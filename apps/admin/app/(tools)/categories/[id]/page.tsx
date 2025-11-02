// apps/admin/app/(tools)/categories/[id]/page.tsx
import { CategoryDetail } from '@repo/tools-categories'

export default async function CategoryDetailPage({
  params,
}: {
  params: { id: string }
}) {
  return <CategoryDetail id={params.id} />
}
