import { z } from "zod"

/**
 * Schéma email
 */
export const emailSchema = z.string().email("Email invalide")

/**
 * Schéma téléphone français
 */
export const phoneSchema = z
  .string()
  .regex(/^(?:(?:\+|00)33|0)\s*[1-9](?:[\s.-]*\d{2}){4}$/, "Numéro de téléphone invalide")

/**
 * Schéma code postal français
 */
export const postalCodeSchema = z
  .string()
  .regex(/^[0-9]{5}$/, "Code postal invalide")

/**
 * Schéma prix
 */
export const priceSchema = z
  .number()
  .positive("Le prix doit être positif")
  .multipleOf(0.01, "Le prix doit avoir au maximum 2 décimales")

/**
 * Helper pour valider une donnée
 */
export function validate<T>(schema: z.ZodSchema<T>, data: unknown): { success: true; data: T } | { success: false; errors: string[] } {
  const result = schema.safeParse(data)
  if (result.success) {
    return { success: true, data: result.data }
  }
  return {
    success: false,
    errors: result.error.errors.map((e) => e.message),
  }
}
