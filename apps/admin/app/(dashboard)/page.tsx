// app/(dashboard)/page.tsx
import { Package, ShoppingCart, Users, TrendingUp } from 'lucide-react'

export default function DashboardPage() {
  // TODO: Récupérer les vraies stats depuis Supabase
  const stats = [
    {
      name: 'Produits',
      value: '24',
      icon: Package,
      change: '+3 ce mois',
      color: 'text-blue-600',
    },
    {
      name: 'Commandes',
      value: '12',
      icon: ShoppingCart,
      change: "+2 aujourd'hui",
      color: 'text-green-600',
    },
    {
      name: 'Clients',
      value: '89',
      icon: Users,
      change: '+5 cette semaine',
      color: 'text-violet',
    },
    {
      name: 'Revenus',
      value: '2,450€',
      icon: TrendingUp,
      change: '+12% ce mois',
      color: 'text-orange-600',
    },
  ]

  return (
    <div className="space-y-6">
      {/* Header */}
      <div>
        <h1 className="text-3xl font-bold">Dashboard</h1>
        <p className="mt-1 text-sm text-gray-600">
          Vue d&apos;ensemble de votre boutique
        </p>
      </div>

      {/* Stats Grid */}
      <div className="grid gap-6 sm:grid-cols-2 lg:grid-cols-4">
        {stats.map((stat) => {
          const Icon = stat.icon
          return (
            <div
              key={stat.name}
              className="rounded-lg border bg-white p-6 shadow-sm"
            >
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-sm font-medium text-gray-600">
                    {stat.name}
                  </p>
                  <p className="mt-2 text-3xl font-semibold">{stat.value}</p>
                  <p className="mt-1 text-xs text-gray-500">{stat.change}</p>
                </div>
                <Icon className={`h-8 w-8 ${stat.color}`} />
              </div>
            </div>
          )
        })}
      </div>

      {/* Message d'accueil */}
      <div className="rounded-lg border border-violet/20 bg-violet/5 p-6">
        <h2 className="font-display text-xl uppercase tracking-wide">
          Bienvenue sur votre admin modulaire 🎉
        </h2>
        <p className="mt-2 text-sm text-gray-700">
          L&apos;infrastructure admin est prête. Les modules seront ajoutés progressivement :
        </p>
        <ul className="mt-4 space-y-2 text-sm text-gray-600">
          <li>⏳ Module Products - À venir</li>
          <li>⏳ Module Orders - À venir</li>
          <li>⏳ Module Customers - À venir</li>
          <li>⏳ Module Categories - À venir</li>
          <li>⏳ Module Media - À venir</li>
          <li>⏳ Module Newsletter - À venir</li>
          <li>⏳ Module Analytics - À venir</li>
          <li>⏳ Module Social - À venir</li>
        </ul>
      </div>
    </div>
  )
}
