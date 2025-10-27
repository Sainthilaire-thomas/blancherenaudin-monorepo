// tailwind.config.ts
import type { Config } from 'tailwindcss'

const config: Config = {
  darkMode: 'class',
  content: [
    './pages/**/*.{js,ts,jsx,tsx,mdx}',
    './components/**/*.{js,ts,jsx,tsx,mdx}',
    './app/**/*.{js,ts,jsx,tsx,mdx}',
    // Inclure les composants des packages
    '../../packages/ui/src/**/*.{js,ts,jsx,tsx}',
    '../../packages/admin-shell/src/**/*.{js,ts,jsx,tsx}',
  ],
  theme: {
    extend: {
      colors: {
        // Couleurs Blanche Renaudin
        violet: 'hsl(271, 74%, 37%)',
        'violet-light': 'hsl(271, 74%, 50%)',
        'violet-dark': 'hsl(271, 74%, 25%)',
      },
      fontFamily: {
        sans: ['Archivo Narrow', 'sans-serif'],
        display: ['Archivo Black', 'sans-serif'],
      },
    },
  },
  plugins: [require('tailwindcss-animate')],
}

export default config
