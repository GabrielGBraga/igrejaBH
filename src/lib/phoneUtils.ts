/**
 * Utilitários robustos para formatação e validação de números de telefone no Brasil.
 */

/**
 * Formata um número de telefone brasileiro de forma robusta e inteligente.
 * Suporta formatos:
 * - Sem DDI: (31) 98888-7777 (11 dígitos) ou (31) 3333-4444 (10 dígitos)
 * - Com DDI: +55 (31) 98888-7777 (13 dígitos) ou +55 (31) 3333-4444 (12 dígitos)
 * Nunca confunde o DDD (ex: 31) com DDI internacional (ex: +31 Holanda)!
 */
export const formatPhone = (value: string): string => {
  if (!value) return ""
  const hasPlus = value.startsWith("+")
  const digits = value.replace(/\D/g, "")

  if (!digits) return ""

  // Se tem '+' inicial ou começa com 55 e possui mais de 11 dígitos, formata com DDI +55
  if (hasPlus || (digits.startsWith("55") && digits.length > 11)) {
    const ddiDigits = digits.startsWith("55") ? digits.slice(2) : digits
    const clean = ddiDigits.slice(0, 11)

    if (clean.length === 0) return "+55"
    if (clean.length <= 2) return `+55 (${clean}`
    if (clean.length <= 6) return `+55 (${clean.slice(0, 2)}) ${clean.slice(2)}`
    if (clean.length <= 10)
      return `+55 (${clean.slice(0, 2)}) ${clean.slice(2, 6)}-${clean.slice(6)}`
    return `+55 (${clean.slice(0, 2)}) ${clean.slice(2, 7)}-${clean.slice(7)}`
  }

  // Formato padrão nacional: (DDD) XXXXX-XXXX ou (DDD) XXXX-XXXX
  const clean = digits.slice(0, 11)
  if (clean.length <= 2) return `(${clean}`
  if (clean.length <= 6) return `(${clean.slice(0, 2)}) ${clean.slice(2)}`
  if (clean.length <= 10)
    return `(${clean.slice(0, 2)}) ${clean.slice(2, 6)}-${clean.slice(6)}`
  return `(${clean.slice(0, 2)}) ${clean.slice(2, 7)}-${clean.slice(7)}`
}

/**
 * Valida se um número de telefone é válido no padrão brasileiro.
 * Aceita números com 10 dígitos (fixo com DDD), 11 dígitos (celular com DDD),
 * ou 12-13 dígitos se prefixados com código do país 55.
 */
export const isValidBrazilianPhone = (val?: string | null): boolean => {
  if (!val) return false
  const digits = val.replace(/\D/g, "")
  if (digits.length === 10 || digits.length === 11) {
    const ddd = parseInt(digits.slice(0, 2), 10)
    return ddd >= 11 && ddd <= 99
  }
  if (digits.length === 12 || digits.length === 13) {
    if (!digits.startsWith("55")) return false
    const ddd = parseInt(digits.slice(2, 4), 10)
    return ddd >= 11 && ddd <= 99
  }
  return false
}
