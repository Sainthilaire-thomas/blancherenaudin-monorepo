'use client'

import React from 'react'
import { usePathname } from 'next/navigation'
import Link from 'next/link'
import { cn } from '@repo/ui'
import type { ModuleDefinition } from '../types'

interface AdminLayoutProps {
  children: React.ReactNode
  modules: ModuleDefinition[]
}

export function AdminLayout({ children, modules }: AdminLayoutProps) {
  const pathname = usePathname()
  const [sidebarOpen, setSidebarOpen] = React.useState(true)

  const enabledModules = modules.filter(m => m.enabled).sort((a, b) => (a.order || 0) - (b.order || 0))

  return (
    <div className="flex h-screen bg-gray-50">
      {/* Sidebar */}
      <aside 
        className={cn(
          "bg-white border-r border-gray-200 transition-all duration-300",
          sidebarOpen ? "w-64" : "w-20"
        )}
      >
        <div className="h-full flex flex-col">
          {/* Logo */}
          <div className="h-16 flex items-center justify-between px-4 border-b border-gray-200">
            {sidebarOpen && (
              <span className="font-bold text-lg">Admin</span>
            )}
            <button
              onClick={() => setSidebarOpen(!sidebarOpen)}
              className="p-2 hover:bg-gray-100 rounded-lg"
            >
              {sidebarOpen ? '←' : '→'}
            </button>
          </div>

          {/* Navigation */}
          <nav className="flex-1 overflow-y-auto py-4">
            <ul className="space-y-1 px-2">
              {enabledModules.map((module) => {
                const Icon = module.icon
                const isActive = pathname.startsWith(module.basePath)

                return (
                  <li key={module.id}>
                    <Link
                      href={module.basePath}
                      className={cn(
                        "flex items-center gap-3 px-3 py-2 rounded-lg transition-colors",
                        isActive 
                          ? "bg-violet-50 text-violet-600" 
                          : "text-gray-700 hover:bg-gray-100"
                      )}
                    >
                      <Icon className="w-5 h-5" />
                      {sidebarOpen && (
                        <span className="font-medium">{module.name}</span>
                      )}
                      {sidebarOpen && module.badge && (
                        <span className="ml-auto text-xs bg-gray-200 px-2 py-0.5 rounded-full">
                          {module.badge}
                        </span>
                      )}
                    </Link>
                  </li>
                )
              })}
            </ul>
          </nav>
        </div>
      </aside>

      {/* Main Content */}
      <main className="flex-1 overflow-y-auto">
        {children}
      </main>
    </div>
  )
}
