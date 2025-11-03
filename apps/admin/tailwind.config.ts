// tailwind.config.ts
import type { Config } from 'tailwindcss'

const config: Config = {
  darkMode: 'class',
  content: [
    // App admin (pages minces)
    './app/**/*.{js,ts,jsx,tsx,mdx}',
    './components/**/*.{js,ts,jsx,tsx,mdx}',
    
    // Packages tools (où vit la vraie UI)
    '../../packages/tools/*/src/**/*.{js,ts,jsx,tsx,mdx}',
    
    // Package UI (design system)
    '../../packages/ui/src/**/*.{js,ts,jsx,tsx,mdx}',
    
    // Package admin-shell
    '../../packages/admin-shell/src/**/*.{js,ts,jsx,tsx,mdx}',
  ],
  theme: {
    extend: {
      colors: {
        black: 'hsl(0 0% 0%)',
        white: 'hsl(0 0% 100%)',
        'grey-light': 'hsl(0 0% 95%)',
        'grey-medium': 'hsl(0 0% 60%)',
        'grey-dark': 'hsl(0 0% 30%)',
        violet: {
          DEFAULT: 'hsl(271 74% 37%)',
          soft: 'hsl(271 74% 45%)',
          subtle: 'hsl(271 30% 92%)',
        },
        background: 'var(--background)',
        foreground: 'var(--foreground)',
        border: 'var(--border)',
        muted: {
          DEFAULT: 'var(--muted)',
          foreground: 'var(--muted-foreground)',
        },
      },
      fontFamily: {
        brand: ['var(--font-archivo-black)', 'sans-serif'],
        body: ['var(--font-archivo-narrow)', 'sans-serif'],
      },
    },
  },
  plugins: [require('tailwindcss-animate')],
}

export default config