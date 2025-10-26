import { z } from "zod"

/**
 * Schema email
 */
export const emailSchema = z.string().email("Email invalide")

/**
 * Schema telephone francais
 */
export const phoneSchema = z
  .string()
  .regex(/^(?:(?:\+|00)33|0)\s*[1-9](?:[\s.-]*\d{2}){4}$/, "Numero de telephone invalide")

/**
 * Schema code postal francais
 */
export const postalCodeSchema = z
  .string()
  .regex(/^[0-9]{5}$/, "Code postal invalide")

/**
 * Schema prix
 */
export const priceSchema = z
  .number()
  .positive("Le prix doit etre positif")
  .multipleOf(0.01, "Le prix doit avoir au maximum 2 decimales")

/**
 * Helper pour valider une donnee
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