// apps/admin/app/(dashboard)/[module]/[[...slug]]/page.tsx
import { notFound } from 'next/navigation'
import { adminModules } from '@/admin.config'

interface ModulePageProps {
  params: Promise<{
    module: string
    slug?: string[]
  }>
}

export default async function ModulePage({ params }: ModulePageProps) {
  const { module: moduleId, slug = [] } = await params

  // Trouver le module dans l'array
  const moduleDefinition = adminModules.find((m) => m.id === moduleId)

  if (!moduleDefinition) {
    notFound()
  }

  // Pour l'instant, afficher un placeholder
  // Les vrais composants seront chargés quand les modules seront migrés (Phase 9)
  return (
    <div className="flex-1 overflow-auto p-8">
      <div className="max-w-4xl mx-auto">
        <h1 className="text-3xl font-bold mb-4">{moduleDefinition.name}</h1>
        <div className="bg-yellow-50 border border-yellow-200 rounded-lg p-6">
          <p className="text-yellow-800 font-medium mb-2">
            🚧 Module en cours de migration
          </p>
          <p className="text-yellow-700 text-sm">
            Ce module sera disponible après la Phase 9 (Migration des modules existants).
          </p>
          <p className="text-yellow-600 text-xs mt-2">
            Module ID: <code className="bg-yellow-100 px-2 py-1 rounded">{moduleId}</code>
          </p>
          {slug.length > 0 && (
            <p className="text-yellow-600 text-xs mt-1">
              Sub-path: <code className="bg-yellow-100 px-2 py-1 rounded">/{slug.join('/')}</code>
            </p>
          )}
        </div>
      </div>
    </div>
  )
}
