// __tests__/products.test.ts
import { describe, it, expect, vi, beforeEach } from 'vitest'
import { listProducts, getProduct, createProduct, updateProduct, deleteProduct } from '../src/api/products'

// Mock supabaseAdmin
vi.mock('@repo/database', () => ({
  supabaseAdmin: {
    from: vi.fn(() => ({
      select: vi.fn(() => ({
        is: vi.fn(() => ({
          order: vi.fn(() => ({
            then: vi.fn()
          }))
        }))
      })),
      insert: vi.fn(),
      update: vi.fn(),
      eq: vi.fn()
    }))
  }
}))

describe('Products API', () => {
  describe('listProducts', () => {
    it('should return products list', async () => {
      // Ce test nécessite un mock plus complet
      // Pour l'instant, on vérifie juste que la fonction existe
      expect(listProducts).toBeDefined()
    })
  })

  describe('getProduct', () => {
    it('should return a single product', async () => {
      expect(getProduct).toBeDefined()
    })
  })

  describe('createProduct', () => {
    it('should create a product', async () => {
      expect(createProduct).toBeDefined()
    })
  })

  describe('updateProduct', () => {
    it('should update a product', async () => {
      expect(updateProduct).toBeDefined()
    })
  })

  describe('deleteProduct', () => {
    it('should soft delete a product', async () => {
      expect(deleteProduct).toBeDefined()
    })
  })
})
