// app/(dashboard)/layout.tsx
'use client'

import { AdminLayout } from '@repo/admin-shell'
import { enabledModules } from '@/admin.config'
import { Toaster } from 'sonner'

export default function DashboardLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <>
      <AdminLayout modules={enabledModules}>
        {children}
      </AdminLayout>
      <Toaster position="top-right" />
    </>
  )
}
