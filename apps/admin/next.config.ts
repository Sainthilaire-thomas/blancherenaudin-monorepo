import type { NextConfig } from 'next'

const nextConfig: NextConfig = {
  reactStrictMode: true,
  
  transpilePackages: [
    '@repo/ui',
    '@repo/database',
    '@repo/auth',
    '@repo/tools-categories',
    '@repo/tools-newsletter',
    '@repo/tools-products',
  ],
  
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
