import type { Config } from 'tailwindcss'

const config: Config = {
  darkMode: ['class'],
  content: [
    './app/**/*.{ts,tsx}',
    './components/**/*.{ts,tsx}',
    '../../packages/ui/src/components/**/*.{ts,tsx}',
  ],
  theme: {
    extend: {
      colors: {
        violet: 'hsl(271, 74%, 37%)',
        'violet-soft': 'hsl(271, 74%, 45%)',
        'violet-subtle': 'hsl(271, 30%, 92%)',
        black: 'hsl(0, 0%, 0%)',
        white: 'hsl(0, 0%, 100%)',
        'grey-light': 'hsl(0, 0%, 95%)',
        'grey-medium': 'hsl(0, 0%, 60%)',
        'grey-dark': 'hsl(0, 0%, 30%)',
        border: 'hsl(var(--border))',
        input: 'hsl(var(--input))',
        ring: 'hsl(var(--ring))',
        background: 'hsl(var(--background))',
        foreground: 'hsl(var(--foreground))',
        primary: {
          DEFAULT: 'hsl(var(--primary))',
          foreground: 'hsl(var(--primary-foreground))',
        },
        secondary: {
          DEFAULT: 'hsl(var(--secondary))',
          foreground: 'hsl(var(--secondary-foreground))',
        },
        destructive: {
          DEFAULT: 'hsl(var(--destructive))',
          foreground: 'hsl(var(--destructive-foreground))',
        },
        muted: {
          DEFAULT: 'hsl(var(--muted))',
          foreground: 'hsl(var(--muted-foreground))',
        },
        accent: {
          DEFAULT: 'hsl(var(--accent))',
          foreground: 'hsl(var(--accent-foreground))',
        },
        popover: {
          DEFAULT: 'hsl(var(--popover))',
          foreground: 'hsl(var(--popover-foreground))',
        },
        card: {
          DEFAULT: 'hsl(var(--card))',
          foreground: 'hsl(var(--card-foreground))',
        },
      },
      borderRadius: {
        lg: 'var(--radius)',
        md: 'calc(var(--radius) - 2px)',
        sm: 'calc(var(--radius) - 4px)',
      },
      fontFamily: {
        'archivo-black': ['var(--font-archivo-black)', 'sans-serif'],
        'archivo-narrow': ['var(--font-archivo-narrow)', 'sans-serif'],
        sans: ['var(--font-archivo-narrow)', 'sans-serif'],
        text: ['var(--font-archivo-narrow)', 'sans-serif'],
        title: ['var(--font-archivo-black)', 'sans-serif'],
        body: ['var(--font-archivo-narrow)', 'sans-serif'],
        mono: ['ui-monospace', 'monospace'],
      },
    },
  },
  plugins: [require('tailwindcss-animate')],
}

export default config
