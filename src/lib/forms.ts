export interface FormField {
  id: string
  type:
    | "text"
    | "textarea"
    | "number"
    | "select"
    | "checkbox"
    | "radio"
    | "date"
  label: string
  placeholder: string
  required: boolean
  helpText: string
  options: string[] // for select, checkbox, radio

  // Conditional Display Logic
  dependsOnFieldId?: string
  dependsOnValue?: string

  // Validation Rules
  validationPreset?: "none" | "phone" | "cpf" | "cep" | "email"
  minNumber?: number
  maxNumber?: number

  // Character limits for text and textarea
  minLength?: number
  maxLength?: number

  // CEP Auto fill mappings (stored on the CEP field itself)
  cepMapping?: {
    streetFieldId?: string
    neighborhoodFieldId?: string
    cityFieldId?: string
    stateFieldId?: string
  }

  // Layout Options
  halfWidth?: boolean

  // Price Modifiers (for conditional pricing)
  priceModifiers?: Record<string, number>
}

export interface FormTemplate {
  id: string
  name: string
  description: string
  fields: FormField[]
  createdAt: string
  isPublic?: boolean
  isActive?: boolean
}

export interface FormSubmission {
  id: string
  formId: string
  submittedAt: string
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  data: Record<string, any>
}

// Helper to evaluate field visibility recursively based on current answers
export const isFieldVisible = (
  field: FormField,
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  data: Record<string, any>,
  fieldsList: FormField[]
): boolean => {
  if (!field.dependsOnFieldId) return true

  const parentField = fieldsList.find((f) => f.id === field.dependsOnFieldId)
  if (!parentField) return true

  // Check parent's visibility recursively
  if (!isFieldVisible(parentField, data, fieldsList)) return false

  const parentValue = data[field.dependsOnFieldId]
  if (parentValue === undefined || parentValue === null) return false

  const targetValue = field.dependsOnValue
  if (!targetValue) return true

  if (Array.isArray(parentValue)) {
    return parentValue.includes(targetValue)
  }

  return String(parentValue) === String(targetValue)
}

/**
 * Validates a CPF using the standard mathematical digit-verification algorithm.
 */
export function isValidCPF(cpf: string): boolean {
  const clean = cpf.replace(/\D/g, "")
  if (clean.length !== 11) return false

  // Reject known invalid patterns
  if (/^(\d)\1{10}$/.test(clean)) return false

  // Validate first digit
  let sum = 0
  for (let i = 0; i < 9; i++) {
    sum += parseInt(clean.charAt(i)) * (10 - i)
  }
  let rev = 11 - (sum % 11)
  if (rev === 10 || rev === 11) rev = 0
  if (rev !== parseInt(clean.charAt(9))) return false

  // Validate second digit
  sum = 0
  for (let i = 0; i < 10; i++) {
    sum += parseInt(clean.charAt(i)) * (11 - i)
  }
  rev = 11 - (sum % 11)
  if (rev === 10 || rev === 11) rev = 0
  if (rev !== parseInt(clean.charAt(10))) return false

  return true
}

/**
 * Validates a Brazilian mobile phone number (DDD + 9 + 8 digits).
 */
export function isValidPhone(phone: string): boolean {
  const clean = phone.replace(/\D/g, "")
  if (clean.length !== 11) return false

  const ddd = parseInt(clean.substring(0, 2), 10)
  const VALID_DDDS = new Set([
    11, 12, 13, 14, 15, 16, 17, 18, 19, 21, 22, 24, 27, 28, 31, 32, 33, 34, 35,
    37, 38, 41, 42, 43, 44, 45, 46, 47, 48, 49, 51, 53, 54, 55, 61, 62, 63, 64,
    65, 66, 67, 68, 69, 71, 73, 74, 75, 77, 79, 81, 82, 83, 84, 85, 86, 87, 88,
    89, 91, 92, 93, 94, 95, 96, 97, 98, 99,
  ])

  if (!VALID_DDDS.has(ddd)) return false
  if (clean.charAt(2) !== "9") return false

  return true
}

/**
 * Automatically applies masks to Phone, CPF, and CEP inputs in real-time.
 */
export function formatValue(
  value: string,
  preset?: FormField["validationPreset"]
): string {
  if (!preset || preset === "none") return value

  const digits = value.replace(/\D/g, "")

  if (preset === "cpf") {
    const clean = digits.slice(0, 11)
    let formatted = ""
    if (clean.length > 0) {
      formatted += clean.substring(0, 3)
    }
    if (clean.length > 3) {
      formatted += "." + clean.substring(3, 6)
    }
    if (clean.length > 6) {
      formatted += "." + clean.substring(6, 9)
    }
    if (clean.length > 9) {
      formatted += "-" + clean.substring(9, 11)
    }
    return formatted
  }

  if (preset === "cep") {
    const clean = digits.slice(0, 8)
    let formatted = ""
    if (clean.length > 0) {
      formatted += clean.substring(0, Math.min(clean.length, 5))
    }
    if (clean.length > 5) {
      formatted += "-" + clean.substring(5, 8)
    }
    return formatted
  }

  if (preset === "phone") {
    const clean = digits.slice(0, 11)
    let formatted = ""
    if (clean.length > 0) {
      formatted += "(" + clean.substring(0, Math.min(clean.length, 2))
    }
    if (clean.length > 2) {
      formatted += ") " + clean.substring(2, Math.min(clean.length, 7))
    }
    if (clean.length > 7) {
      if (clean.length > 10) {
        formatted = `(${clean.substring(0, 2)}) ${clean.substring(2, 7)}-${clean.substring(7, 11)}`
      } else {
        formatted = `(${clean.substring(0, 2)}) ${clean.substring(2, 6)}-${clean.substring(6, 10)}`
      }
    }
    return formatted
  }

  return value
}

/**
 * Fetches location/address details from ViaCEP API.
 */
export async function fetchAddressFromCep(cep: string) {
  const clean = cep.replace(/\D/g, "")
  if (clean.length !== 8) return null

  try {
    const res = await fetch(`https://viacep.com.br/ws/${clean}/json/`)
    if (!res.ok) return null
    const data = await res.json()
    if (data.erro) return { error: true }
    return data // returns { logradouro, bairro, localidade, uf, ... }
  } catch (err) {
    console.error("Error calling ViaCEP API:", err)
    return null
  }
}

/**
 * Calculates the total price of a registration/submission based on base price and form answers.
 */
export function calculateTotalPrice(
  basePrice: number | null | undefined,
  fields: FormField[],
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  responses: Record<string, any>
): number {
  let total = basePrice || 0
  
  fields.forEach((field) => {
    // Only calculate if the field is visible based on conditional logic
    if (!isFieldVisible(field, responses, fields)) return

    const val = responses[field.id]
    if (val === undefined || val === null) return

    if (field.priceModifiers) {
      if (field.type === "select" || field.type === "radio") {
        const modifier = field.priceModifiers[String(val)]
        if (modifier !== undefined) {
          total += Number(modifier)
        }
      } else if (field.type === "checkbox") {
        if (Array.isArray(val)) {
          val.forEach((item) => {
            const modifier = field.priceModifiers?.[String(item)]
            if (modifier !== undefined) {
              total += Number(modifier)
            }
          })
        }
      }
    }
  })

  return Math.max(0, total)
}

/**
 * Define the 6 mandatory baseline fields that must exist in every event registration form.
 */
export const MANDATORY_EVENT_FIELDS: FormField[] = [
  {
    id: "mandatory_full_name",
    type: "text",
    label: "Nome Completo",
    placeholder: "Digite seu nome completo",
    required: true,
    helpText: "Nome do participante inscritos",
    options: [],
    halfWidth: false
  },
  {
    id: "mandatory_email",
    type: "text",
    label: "E-mail",
    placeholder: "exemplo@email.com",
    required: true,
    helpText: "E-mail para envio da confirmação",
    validationPreset: "email",
    options: [],
    halfWidth: true
  },
  {
    id: "mandatory_phone",
    type: "text",
    label: "Telefone / WhatsApp",
    placeholder: "(31) 99999-9999",
    required: true,
    helpText: "Telefone de contato com DDD",
    validationPreset: "phone",
    options: [],
    halfWidth: true
  },
  {
    id: "mandatory_gender",
    type: "select",
    label: "Sexo / Gênero",
    placeholder: "Selecione o sexo",
    required: true,
    helpText: "Utilizado para alocação de quartos",
    options: ["Masculino", "Feminino"],
    halfWidth: true
  },
  {
    id: "mandatory_city_state",
    type: "text",
    label: "Cidade / Estado",
    placeholder: "Ex: Belo Horizonte / MG",
    required: true,
    helpText: "Cidade e UF de residência",
    options: [],
    halfWidth: true
  },
  {
    id: "mandatory_birth_date",
    type: "date",
    label: "Data de Nascimento / Idade",
    placeholder: "DD/MM/AAAA",
    required: true,
    helpText: "Data de nascimento do participante",
    options: [],
    halfWidth: true
  }
]

/**
 * Checks if a given field list contains a match for a mandatory requirement based on label or preset.
 */
export function matchesMandatoryRequirement(field: FormField, req: FormField): boolean {
  const fLabel = field.label.toLowerCase()

  if (req.id === "mandatory_full_name") {
    return fLabel.includes("nome") || fLabel.includes("participante")
  }
  if (req.id === "mandatory_email") {
    return field.validationPreset === "email" || fLabel.includes("email") || fLabel.includes("e-mail")
  }
  if (req.id === "mandatory_phone") {
    return field.validationPreset === "phone" || fLabel.includes("telefone") || fLabel.includes("whatsapp") || fLabel.includes("celular")
  }
  if (req.id === "mandatory_gender") {
    return fLabel.includes("gênero") || fLabel.includes("genero") || fLabel.includes("sexo")
  }
  if (req.id === "mandatory_city_state") {
    return fLabel.includes("cidade") || fLabel.includes("estado") || fLabel.includes("município")
  }
  if (req.id === "mandatory_birth_date") {
    return fLabel.includes("nascimento") || fLabel.includes("idade") || fLabel.includes("data de nasci") || field.type === "date"
  }
  return false
}

/**
 * Ensures that a list of form fields contains all 6 mandatory baseline event fields.
 * If missing, injects them and sets required = true.
 */
export function ensureMandatoryEventFields(existingFields: FormField[]): FormField[] {
  const result: FormField[] = [...existingFields]

  MANDATORY_EVENT_FIELDS.forEach((req) => {
    const existingIndex = result.findIndex((f) => matchesMandatoryRequirement(f, req))
    if (existingIndex >= 0) {
      // Force required = true on matching existing field
      result[existingIndex] = {
        ...result[existingIndex],
        required: true
      }
    } else {
      // Inject missing mandatory field at the beginning
      result.unshift(req)
    }
  })

  return result
}

/**
 * Validates a set of form submission responses against mandatory event requirements.
 */
export function validateEventRegistrationData(
  responses: Record<string, any>,
  fieldsList?: FormField[]
): { valid: boolean; missingFields: string[] } {
  const missingFields: string[] = []

  MANDATORY_EVENT_FIELDS.forEach((req) => {
    let value: any = undefined

    // Try finding by exact matching field in fieldsList if provided
    if (fieldsList && fieldsList.length > 0) {
      const match = fieldsList.find((f) => matchesMandatoryRequirement(f, req))
      if (match) {
        value = responses[match.id] || responses[match.label]
      }
    }

    // Fallback: check by key in responses object
    if (value === undefined || value === null || String(value).trim() === "") {
      const keys = Object.keys(responses)
      const matchingKey = keys.find((k) => {
        const kLower = k.toLowerCase()
        if (req.id === "mandatory_full_name") return kLower.includes("nome")
        if (req.id === "mandatory_email") return kLower.includes("email") || kLower.includes("e-mail")
        if (req.id === "mandatory_phone") return kLower.includes("telefone") || kLower.includes("phone") || kLower.includes("whatsapp")
        if (req.id === "mandatory_gender") return kLower.includes("gênero") || kLower.includes("genero") || kLower.includes("sexo")
        if (req.id === "mandatory_city_state") return kLower.includes("cidade") || kLower.includes("estado")
        if (req.id === "mandatory_birth_date") return kLower.includes("nascim") || kLower.includes("idade")
        return false
      })

      if (matchingKey) {
        value = responses[matchingKey]
      }
    }

    if (value === undefined || value === null || String(value).trim() === "") {
      missingFields.push(req.label)
    }
  })

  return {
    valid: missingFields.length === 0,
    missingFields
  }
}

