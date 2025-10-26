import { z } from "zod"

/**
 * Sch�ma email
 */
export const emailSchema = z.string().email("Email invalide")

/**
 * Sch�ma t�l�phone fran�ais
 */
export const phoneSchema = z
  .string()
  .regex(/^(?:(?:\+|00)33|0)\s*[1-9](?:[\s.-]*\d{2}){4}$/, "Num�ro de t�l�phone invalide")

/**
 * Sch�ma code postal fran�ais
 */
export const postalCodeSchema = z
  .string()
  .regex(/^[0-9]{5}$/, "Code postal invalide")

/**
 * Sch�ma prix
 */
export const priceSchema = z
  .number()
  .positive("Le prix doit �tre positif")
  .multipleOf(0.01, "Le prix doit avoir au maximum 2 d�cimales")

/**
 * Helper pour valider une donn�e
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
