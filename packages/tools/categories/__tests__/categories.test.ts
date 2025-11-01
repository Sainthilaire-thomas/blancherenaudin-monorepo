// __tests__/categories.test.ts
import { describe, it, expect } from 'vitest'
import { 
  listCategories, 
  getCategory, 
  createCategory, 
  updateCategory, 
  deleteCategory 
} from '../src/api/categories'

describe('Categories API', () => {
  describe('listCategories', () => {
    it('should be defined', () => {
      expect(listCategories).toBeDefined()
    })
  })

  describe('getCategory', () => {
    it('should be defined', () => {
      expect(getCategory).toBeDefined()
    })
  })

  describe('createCategory', () => {
    it('should be defined', () => {
      expect(createCategory).toBeDefined()
    })
  })

  describe('updateCategory', () => {
    it('should be defined', () => {
      expect(updateCategory).toBeDefined()
    })
  })

  describe('deleteCategory', () => {
    it('should be defined', () => {
      expect(deleteCategory).toBeDefined()
    })
  })
})
