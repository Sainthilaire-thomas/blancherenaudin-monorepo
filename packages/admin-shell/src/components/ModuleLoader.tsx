'use client'

import React from 'react'
import { useRouter } from 'next/navigation'
import { toast } from 'sonner'
import type { ModuleDefinition, ModuleProps, ModuleServices } from '../types'

interface ModuleLoaderProps {
  module: ModuleDefinition
  subPath: string[]
  children: React.ComponentType<ModuleProps>
}

export function ModuleLoader({ module, subPath, children: ModuleComponent }: ModuleLoaderProps) {
  const router = useRouter()

  const services: ModuleServices = React.useMemo(() => ({
    notify: (message: string, type: 'success' | 'error' | 'info' | 'warning' = 'info') => {
      switch (type) {
        case 'success':
          toast.success(message)
          break
        case 'error':
          toast.error(message)
          break
        case 'warning':
          toast.warning(message)
          break
        default:
          toast.info(message)
      }
    },

    confirm: async (message: string): Promise<boolean> => {
      return window.confirm(message)
    },

    navigate: (path: string[]) => {
      const fullPath = [module.basePath, ...path].join('/')
      router.push(fullPath)
    },

    hasPermission: (permission: string): boolean => {
      console.log('Checking permission:', permission)
      return true
    },

    refresh: () => {
      router.refresh()
    },
  }), [module.basePath, router])

  return <ModuleComponent subPath={subPath} services={services} />
}
