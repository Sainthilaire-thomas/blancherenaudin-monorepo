// apps/admin/app/(tools)/categories/layout.tsx
export default function CategoriesLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <div className="categories-tool">
      {children}
    </div>
  )
}
