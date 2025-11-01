# @repo/tools-products

Tool de gestion des produits pour l'admin Blanche Renaudin.

## Structure

- src/api/ - Logique métier pure (testable)
- src/routes/ - Composants Server/Client pour les pages
- src/components/ - Composants UI réutilisables
- src/hooks/ - Hooks personnalisés
- __tests__/ - Tests unitaires

## Usage

Dans apps/admin:
import { ProductsList, ProductDetail } from '@repo/tools-products/routes'
import { listProducts } from '@repo/tools-products/api'
