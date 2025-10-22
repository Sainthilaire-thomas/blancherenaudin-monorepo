import type { Database } from '@repo/database'

// ✅ Tables principales
export type Product = Database['public']['Tables']['products']['Row']
export type Category = Database['public']['Tables']['categories']['Row']
export type Collection = Database['public']['Tables']['collections']['Row']
export type WishlistItem = Database['public']['Tables']['wishlist_items']['Row'] // ✅ CORRIGÉ
export type Order = Database['public']['Tables']['orders']['Row']
export type OrderItem = Database['public']['Tables']['order_items']['Row']
export type ProductVariant = Database['public']['Tables']['product_variants']['Row']
export type ProductImage = Database['public']['Tables']['product_images']['Row']

// Types métier dérivés
export interface ProductWithImages extends Product {
  images: ProductImage[]
}

export interface ProductWithVariants extends Product {
  variants: ProductVariant[]
}

export interface ProductWithImagesAndVariants extends Product {
  images: ProductImage[]
  variants: ProductVariant[]
}

export interface ProductWithRelations extends Product {
  images: ProductImage[]
  variants: ProductVariant[]
  category?: Category
  collections?: Collection[]
}

export interface OrderWithItems extends Order {
  items: OrderItem[]
}

// Types pour le panier
export interface CartItem {
  id: string
  product_id: string
  variant_id?: string
  name: string
  price: number
  quantity: number
  image?: string
  size?: string
  color?: string
}

// Types pour l'adresse
export interface Address {
  id?: string
  type: 'billing' | 'shipping'
  first_name: string
  last_name: string
  company?: string
  address_line1: string
  address_line2?: string
  city: string
  postal_code: string
  country: string
}

// Types pour le checkout
export interface CheckoutFormData {
  email: string
  shipping: Address
  billing?: Address
  sameAsBilling: boolean
  shipping_method: string
}
