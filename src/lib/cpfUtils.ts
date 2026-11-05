/**
 * Utilitários para formatação e validação de CPF (Cadastro de Pessoas Físicas).
 */

/**
 * Remove qualquer caractere não numérico do CPF.
 */
export function cleanCPF(value?: string | null): string {
  if (!value) return ""
  return value.replace(/\D/g, "")
}

/**
 * Formata um CPF no padrão brasileiro (000.000.000-00) de forma progressiva.
 */
export function formatCPF(value?: string | null): string {
  if (!value) return ""
  const digits = cleanCPF(value).slice(0, 11)
  if (digits.length <= 3) return digits
  if (digits.length <= 6) return `${digits.slice(0, 3)}.${digits.slice(3)}`
  if (digits.length <= 9) return `${digits.slice(0, 3)}.${digits.slice(3, 6)}.${digits.slice(6)}`
  return `${digits.slice(0, 3)}.${digits.slice(3, 6)}.${digits.slice(6, 9)}-${digits.slice(9)}`
}

/**
 * Valida se um CPF é matematicamente válido segundo o algoritmo oficial dos dígitos verificadores.
 */
export function isValidCPF(cpf?: string | null): boolean {
  if (!cpf) return false
  const clean = cleanCPF(cpf)
  if (clean.length !== 11) return false

  // Rejeita sequências com todos os dígitos iguais (ex: 000.000.000-00, 111.111.111-11)
  if (/^(\d)\1{10}$/.test(clean)) return false

  // Validação do primeiro dígito verificador
  let sum = 0
  for (let i = 0; i < 9; i++) {
    sum += parseInt(clean.charAt(i), 10) * (10 - i)
  }
  let firstDigit = 11 - (sum % 11)
  if (firstDigit >= 10) firstDigit = 0
  if (parseInt(clean.charAt(9), 10) !== firstDigit) return false

  // Validação do segundo dígito verificador
  sum = 0
  for (let i = 0; i < 10; i++) {
    sum += parseInt(clean.charAt(i), 10) * (11 - i)
  }
  let secondDigit = 11 - (sum % 11)
  if (secondDigit >= 10) secondDigit = 0
  if (parseInt(clean.charAt(10), 10) !== secondDigit) return false

  return true
}
