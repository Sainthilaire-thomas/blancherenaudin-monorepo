'use client'
import React from 'react'
import { usePathname } from 'next/navigation'
import Link from 'next/link'
import { cn } from '@repo/ui'
import * as Icons from 'lucide-react'
import type { ToolDefinition } from '../../lib/types/tool'

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
              {enabledTools.map((tool) => {
                const Icon = Icons[tool.icon as keyof typeof Icons] as any
                const isActive = pathname.startsWith(tool.path)
                
                return (
                  <li key={tool.id}>
                    <Link
                      href={tool.path}
                      className={cn(
                        "flex items-center gap-3 px-3 py-2 rounded-lg transition-colors",
                        isActive
                          ? "bg-violet-50 text-violet-600"
                          : "text-gray-700 hover:bg-gray-100"
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
      <main className="flex-1 overflow-auto">
        <div className="container mx-auto p-8">
          {children}
        </div>
      </main>
    </div>
  )
}