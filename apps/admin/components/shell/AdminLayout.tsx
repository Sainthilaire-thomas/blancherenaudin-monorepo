'use client'
import React from 'react'
import { usePathname } from 'next/navigation'
import Link from 'next/link'
import { cn } from '@repo/ui'
import * as Icons from 'lucide-react'
import type { LucideIcon } from 'lucide-react'
import type { ToolDefinition } from '../../lib/types/tool'
import { ThemeToggle } from './ThemeToggle'

interface AdminLayoutProps {
  children: React.ReactNode
  modules: ToolDefinition[]
}

export function AdminLayout({ children, modules }: AdminLayoutProps) {
  const pathname = usePathname()
  const [sidebarOpen, setSidebarOpen] = React.useState(true)

  const enabledTools = modules
    .filter(m => m.enabled)
    .sort((a, b) => (a.order || 0) - (b.order || 0))

  return (
    <div className="flex h-screen bg-gray-50 dark:bg-gray-900">
      {/* Sidebar */}
      <aside
        className={cn(
          "bg-white dark:bg-gray-950 border-r border-gray-200 dark:border-gray-800 transition-all duration-300",
          sidebarOpen ? "w-64" : "w-20"
        )}
      >
        <div className="h-full flex flex-col">
          {/* Logo + ThemeToggle */}
          <div className="h-16 flex items-center justify-between px-4 border-b border-gray-200 dark:border-gray-800">
            {sidebarOpen && (
              <span className="font-bold text-lg dark:text-white">Admin</span>
            )}
            <div className="flex items-center gap-2">
              <ThemeToggle />
              <button
                onClick={() => setSidebarOpen(!sidebarOpen)}
                className="p-2 hover:bg-gray-100 dark:hover:bg-gray-800 rounded-lg transition-colors"
              >
                {sidebarOpen ? '◀' : '▶'}
              </button>
            </div>
          </div>

          {/* Navigation */}
          <nav className="flex-1 overflow-y-auto py-4">
            <ul className="space-y-1 px-2">
              {enabledTools.map((tool) => {
                // ✅ FIX: Cast vers LucideIcon pour TypeScript
                const Icon = Icons[tool.icon as keyof typeof Icons] as LucideIcon
                const isActive = pathname.startsWith(tool.path)

                return (
                  <li key={tool.id}>
                    <Link
                      href={tool.path}
                      className={cn(
                        "flex items-center gap-3 px-3 py-2 rounded-lg transition-colors",
                        isActive
                          ? "bg-violet-50 dark:bg-violet-900/20 text-violet-600 dark:text-violet-400"
                          : "text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-800"
                      )}
                    >
                      {Icon && <Icon className="w-5 h-5 flex-shrink-0" />}
                      {sidebarOpen && (
                        <span className="text-sm font-medium">{tool.name}</span>
                      )}
                    </Link>
                  </li>
                )
              })}
            </ul>
          </nav>
        </div>
      </aside>

      {/* Main content */}
      <main className="flex-1 overflow-auto bg-gray-50 dark:bg-gray-900">
        <div className="container mx-auto p-8">
          {children}
        </div>
      </main>
    </div>
  )
}
