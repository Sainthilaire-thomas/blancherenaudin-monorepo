# setup-monorepo.ps1
Write-Host "🚀 Configuration du monorepo Blanche Renaudin..." -ForegroundColor Green

# Créer la structure de dossiers
Write-Host "`n📁 Création de la structure de dossiers..." -ForegroundColor Cyan

$folders = @(
    "apps/storefront",
    "apps/admin",
    "modules/analytics",
    "modules/categories",
    "modules/customers",
    "modules/media",
    "modules/newsletter",
    "modules/orders",
    "modules/products",
    "modules/social",
    "packages/ui",
    "packages/database",
    "packages/email",
    "packages/auth",
    "packages/analytics",
    "packages/newsletter",
    "packages/shipping",
    "packages/admin-shell",
    "packages/config",
    "shared/sanity",
    "shared/docs",
    "shared/scripts",
    "tests/e2e/storefront",
    "tests/e2e/admin"
)

foreach ($folder in $folders) {
    New-Item -ItemType Directory -Force -Path $folder | Out-Null
    Write-Host "  ✓ $folder" -ForegroundColor Gray
}

Write-Host "`n📦 Création des fichiers de configuration..." -ForegroundColor Cyan

# package.json
'{"name":"blancherenaudin-monorepo","version":"0.0.0","private":true,"scripts":{"dev":"turbo run dev","dev:storefront":"turbo run dev --filter=storefront","dev:admin":"turbo run dev --filter=admin","build":"turbo run build","build:storefront":"turbo run build --filter=storefront","build:admin":"turbo run build --filter=admin","type-check":"turbo run type-check","lint":"turbo run lint","test":"turbo run test","test:e2e":"playwright test","clean":"turbo run clean && rm -rf node_modules","format":"prettier --write \"**/*.{ts,tsx,md,json}\"","changeset":"changeset","changeset:version":"changeset version","changeset:publish":"changeset publish"},"devDependencies":{"@changesets/cli":"^2.27.1","@playwright/test":"^1.40.0","prettier":"^3.1.0","turbo":"^1.11.0","typescript":"^5.3.0"},"packageManager":"pnpm@8.15.0","engines":{"node":">=18.0.0","pnpm":">=8.0.0"}}' | Out-File -FilePath "package.json" -Encoding utf8

# pnpm-workspace.yaml
@"
packages:
  - 'apps/*'
  - 'packages/*'
  - 'modules/*'
"@ | Out-File -FilePath "pnpm-workspace.yaml" -Encoding utf8

# turbo.json
'{"$schema":"https://turbo.build/schema.json","globalDependencies":["**/.env.*local",".env","tsconfig.json"],"pipeline":{"build":{"dependsOn":["^build"],"outputs":[".next/**","!.next/cache/**","dist/**",".turbo/**"],"env":["NEXT_PUBLIC_SUPABASE_URL","NEXT_PUBLIC_SUPABASE_ANON_KEY","SUPABASE_SERVICE_ROLE_KEY","NEXT_PUBLIC_SANITY_PROJECT_ID","NEXT_PUBLIC_SANITY_DATASET"]},"type-check":{"dependsOn":["^build"],"outputs":[]},"lint":{"dependsOn":["^type-check"],"outputs":[]},"test":{"dependsOn":["^build","type-check"],"outputs":["coverage/**"],"cache":true},"dev":{"cache":false,"persistent":true},"clean":{"cache":false}}}' | Out-File -FilePath "turbo.json" -Encoding utf8

# tsconfig.base.json
'{"compilerOptions":{"target":"ES2020","lib":["ES2020","DOM","DOM.Iterable"],"jsx":"preserve","module":"ESNext","moduleResolution":"bundler","resolveJsonModule":true,"allowJs":true,"strict":true,"noEmit":true,"esModuleInterop":true,"skipLibCheck":true,"forceConsistentCasingInFileNames":true,"incremental":true,"composite":true,"declaration":true,"declarationMap":true,"paths":{"@repo/*":["./packages/*/src"],"@modules/*":["./modules/*/src"]}},"exclude":["node_modules","dist",".next",".turbo"]}' | Out-File -FilePath "tsconfig.base.json" -Encoding utf8

# .gitignore
@"
node_modules
.pnp
.pnp.js
coverage
.nyc_output
.next
out
build
dist
*.log
*.pid
*.seed
*.pid.lock
.env
.env.local
.env.*.local
.turbo
.DS_Store
*.swp
*.swo
*~
.vscode/*
!.vscode/extensions.json
.idea
*.tsbuildinfo
"@ | Out-File -FilePath ".gitignore" -Encoding utf8

# .env.example
@"
NEXT_PUBLIC_SUPABASE_URL=
NEXT_PUBLIC_SUPABASE_ANON_KEY=
SUPABASE_SERVICE_ROLE_KEY=
NEXT_PUBLIC_SANITY_PROJECT_ID=
NEXT_PUBLIC_SANITY_DATASET=production
STRIPE_SECRET_KEY=
STRIPE_WEBHOOK_SECRET=
NEXT_PUBLIC_STRIPE_PUBLIC_KEY=
RESEND_API_KEY=
NEXT_PUBLIC_STOREFRONT_URL=http://localhost:3000
NEXT_PUBLIC_ADMIN_URL=http://localhost:3001
"@ | Out-File -FilePath ".env.example" -Encoding utf8

# README.md
@"
# Blanche Renaudin - Monorepo

Architecture modulaire pour le site e-commerce Blanche Renaudin.

## Structure

- apps/storefront - Site public Next.js
- apps/admin - Admin shell Next.js
- modules/* - 8 modules admin isolés
- packages/* - Code partagé réutilisable
- shared/* - Sanity, docs, scripts

## Getting Started

\`\`\`bash
pnpm install
pnpm dev:storefront
pnpm dev:admin
\`\`\`
"@ | Out-File -FilePath "README.md" -Encoding utf8

Write-Host "`n✅ Structure du monorepo créée avec succès!" -ForegroundColor Green
Write-Host "`nProchaines étapes:" -ForegroundColor Yellow
Write-Host "  1. pnpm install" -ForegroundColor White
Write-Host "  2. pnpm changeset init" -ForegroundColor White
Write-Host "  3. git add ." -ForegroundColor White
Write-Host "  4. git commit -m 'chore: setup monorepo structure'" -ForegroundColor White
