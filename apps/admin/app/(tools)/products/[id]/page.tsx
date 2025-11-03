// apps/admin/app/(tools)/products/[id]/page.tsx
import { ProductEditPage } from '@repo/tools-products'

interface Props {
  params: Promise<{ id: string }>
}

export default async function ProductEdit({ params }: Props) {
  const { id } = await params
  return <ProductEditPage productId={id} />
}
