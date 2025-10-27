'use client'

import React from 'react'
import { useRouter } from 'next/navigation'
import { LogOut, User, Settings } from 'lucide-react'
import { Button } from '@repo/ui'

interface AdminNavProps {
  userName?: string
  userEmail?: string
  onLogout?: () => void
}

export function AdminNav({ userName, userEmail, onLogout }: AdminNavProps) {
  const router = useRouter()

  const handleLogout = () => {
    if (onLogout) {
      onLogout()
    } else {
      router.push('/admin/login')
    }
  }

  return (
    <header className="h-16 bg-white border-b border-gray-200 px-6 flex items-center justify-between">
      <div className="flex items-center gap-4">
        <h1 className="text-xl font-bold">Blanche Renaudin Admin</h1>
      </div>

      <div className="flex items-center gap-4">
        {/* User Info */}
        <div className="flex items-center gap-3">
          <div className="flex flex-col items-end text-sm">
            <span className="font-medium">{userName || 'Admin'}</span>
            <span className="text-gray-500">{userEmail}</span>
          </div>
          <div className="w-10 h-10 bg-violet-100 rounded-full flex items-center justify-center">
            <User className="w-5 h-5 text-violet-600" />
          </div>
        </div>

        {/* Actions */}
        <Button
          variant="ghost"
          size="icon"
          onClick={() => router.push('/admin/settings')}
        >
          <Settings className="w-5 h-5" />
        </Button>

        <Button
          variant="ghost"
          size="icon"
          onClick={handleLogout}
        >
          <LogOut className="w-5 h-5" />
        </Button>
      </div>
    </header>
  )
}
