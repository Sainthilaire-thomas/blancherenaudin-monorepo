// next.config.ts
import type { NextConfig } from 'next'

const nextConfig: NextConfig = {
  reactStrictMode: true,
  
  // Transpiler les packages du monorepo
  transpilePackages: [
    '@repo/admin-shell',
    '@repo/ui',
    '@repo/database',
    '@repo/auth',
  ],

  // Configuration images Supabase
  images: {
    remotePatterns: [
      {
        protocol: 'https',
        hostname: '*.supabase.co',
      },
    ],
  },
}

export default nextConfig
