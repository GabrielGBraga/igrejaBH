/**
 * Lista de todos os campos que devem estar preenchidos para que um perfil seja considerado completo.
 * Se você adicionar uma nova coluna obrigatória no banco, adicione o nome dela aqui.
 */
export const MANDATORY_PROFILE_FIELDS = {
  full_name: "Nome Completo",
  birth_date: "Data de Nascimento",
  gender: "Gênero",
  marital_status: "Estado Civil",
  cpf: "CPF",
  phone: "Telefone",
  address_street: "Rua",
  address_number: "Número",
  address_neighborhood: "Bairro",
  address_city: "Cidade",
  address_state: "Estado",
  address_zip_code: "CEP",
  occupation: "Profissão",
  education_level: "Escolaridade",
  employment_status: "Vínculo Empregatício",
  household_income: "Renda Familiar",
  dependents_count: "Número de Dependentes",
  housing_status: "Situação de Moradia",
  drivers_license: "CNH",
} as const

export type MandatoryProfileField = keyof typeof MANDATORY_PROFILE_FIELDS

export type ProfileSectionKey = "personal" | "contact" | "address" | "socio"

export interface ProfileSectionConfig {
  key: ProfileSectionKey
  label: string
  shortLabel: string
  description: string
  fields: MandatoryProfileField[]
}

export const PROFILE_SECTIONS: ProfileSectionConfig[] = [
  {
    key: "personal",
    label: "Dados Pessoais",
    shortLabel: "Pessoal",
    description: "Nome completo, CPF, data de nascimento, gênero e estado civil.",
    fields: ["full_name", "cpf", "birth_date", "gender", "marital_status"],
  },
  {
    key: "contact",
    label: "Informações de Contato",
    shortLabel: "Contato",
    description: "Telefone celular / WhatsApp para comunhão e avisos.",
    fields: ["phone"],
  },
  {
    key: "address",
    label: "Endereço Residencial",
    shortLabel: "Endereço",
    description: "Localização de moradia para visitas e integração nos grupos.",
    fields: [
      "address_zip_code",
      "address_street",
      "address_number",
      "address_neighborhood",
      "address_city",
      "address_state",
    ],
  },
  {
    key: "socio",
    label: "Informações Socioeconômicas",
    shortLabel: "Socioeconômico",
    description: "Profissão, escolaridade, moradia e perfil de apoio mútuo.",
    fields: [
      "occupation",
      "education_level",
      "employment_status",
      "household_income",
      "dependents_count",
      "housing_status",
      "drivers_license",
    ],
  },
]

/**
 * Verifica se o perfil contém algum valor "sentinela" ou está vazio para campos obrigatórios.
 */
export function isFieldComplete(value: any): boolean {
  if (value === null || value === undefined || value === "") return false
  if (typeof value === "string") {
    const lower = value.toLowerCase()
    return lower !== "não informado" && lower !== "pendente"
  }
  return true
}

export function getMissingProfileFields(
  profile: Record<string, any>
): MandatoryProfileField[] {
  return (
    Object.keys(MANDATORY_PROFILE_FIELDS) as MandatoryProfileField[]
  ).filter((field) => !isFieldComplete(profile[field]))
}

export function getSectionMissingFields(
  profile: Record<string, any>,
  sectionKey: ProfileSectionKey
): MandatoryProfileField[] {
  const section = PROFILE_SECTIONS.find((s) => s.key === sectionKey)
  if (!section) return []
  return section.fields.filter((field) => !isFieldComplete(profile[field]))
}

export function isSectionComplete(
  profile: Record<string, any>,
  sectionKey: ProfileSectionKey
): boolean {
  return getSectionMissingFields(profile, sectionKey).length === 0
}

export function getPendingSections(
  profile: Record<string, any>
): ProfileSectionConfig[] {
  return PROFILE_SECTIONS.filter((s) => !isSectionComplete(profile, s.key))
}

export function getFieldLabel(field: string): string {
  return MANDATORY_PROFILE_FIELDS[field as MandatoryProfileField] || field
}

export function isProfileComplete(profile: Record<string, any>): boolean {
  return getMissingProfileFields(profile).length === 0
}
