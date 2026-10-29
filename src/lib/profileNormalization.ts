/**
 * Utilitários de normalização para dados do perfil dos discípulos.
 * Compatibiliza valores herdados do banco de dados (legacy seed/pré-cadastros)
 * com os seletores e schemas da aplicação.
 */

export type Gender = "masculino" | "feminino" | "outro"

export type MaritalStatus = "solteiro" | "casado" | "divorciado" | "viuvo"

export type EducationLevel =
  | "Fundamental Incompleto"
  | "Fundamental Completo"
  | "Médio Incompleto"
  | "Médio Completo"
  | "Superior Incompleto"
  | "Superior Completo"
  | "Pós-graduação"

export type EmploymentStatus =
  | "CLT"
  | "Autônomo/PJ"
  | "Empreendedor"
  | "Desempregado"
  | "Aposentado"
  | "Estudante"

export type HouseholdIncome =
  | "Até 1 SM"
  | "1 a 3 SM"
  | "3 a 5 SM"
  | "Acima de 5 SM"
  | "Prefiro não informar"

export type HousingStatus = "Própria" | "Alugada" | "Cedida/Parentes" | "Financiada"

export type DriversLicense = "Não possui" | "A" | "B" | "AB" | "C" | "D" | "E"

export function normalizeGender(val?: string | null): Gender {
  if (!val) return "masculino"
  const lower = val.toLowerCase().trim()
  if (lower === "m" || lower === "masculino" || lower === "homem") return "masculino"
  if (lower === "f" || lower === "feminino" || lower === "mulher") return "feminino"
  if (lower === "outro") return "outro"
  return "masculino"
}

export function normalizeMaritalStatus(val?: string | null): MaritalStatus {
  if (!val) return "solteiro"
  const lower = val.toLowerCase().trim()
  if (lower.includes("casad")) return "casado"
  if (lower.includes("solteir")) return "solteiro"
  if (lower.includes("divorciad")) return "divorciado"
  if (lower.includes("viuv") || lower.includes("viúv")) return "viuvo"
  return "solteiro"
}

export function normalizeEducationLevel(val?: string | null): EducationLevel {
  if (!val) return "Médio Completo"
  const lower = val.toLowerCase().trim()
  if (
    lower.includes("pós") ||
    lower.includes("pos") ||
    lower.includes("mestrado") ||
    lower.includes("doutorado")
  )
    return "Pós-graduação"
  if (lower.includes("superior incompleto")) return "Superior Incompleto"
  if (
    lower.includes("superior") ||
    lower.includes("graduação") ||
    lower.includes("graduacao")
  )
    return "Superior Completo"
  if (
    lower.includes("médio incompleto") ||
    lower.includes("medio incompleto")
  )
    return "Médio Incompleto"
  if (
    lower.includes("médio") ||
    lower.includes("medio") ||
    lower.includes("colegial")
  )
    return "Médio Completo"
  if (
    lower.includes("fundamental incompleto") ||
    lower.includes("infantil")
  )
    return "Fundamental Incompleto"
  if (
    lower.includes("fundamental") ||
    lower.includes("primeiro grau")
  )
    return "Fundamental Completo"
  return "Médio Completo"
}

export function normalizeEmploymentStatus(val?: string | null): EmploymentStatus {
  if (!val) return "CLT"
  const lower = val.toLowerCase().trim()
  if (
    lower.includes("clt") ||
    lower.includes("servidor") ||
    lower.includes("estável") ||
    lower.includes("estavel") ||
    lower.includes("carteira assinada")
  )
    return "CLT"
  if (
    lower.includes("autônomo") ||
    lower.includes("autonomo") ||
    lower.includes("pj") ||
    lower.includes("freelancer")
  )
    return "Autônomo/PJ"
  if (
    lower.includes("empres") ||
    lower.includes("empreendedor") ||
    lower.includes("sócio") ||
    lower.includes("socio")
  )
    return "Empreendedor"
  if (lower.includes("aposentad")) return "Aposentado"
  if (lower.includes("estudante") || lower.includes("estagi")) return "Estudante"
  if (
    lower.includes("desempregad") ||
    lower.includes("não se aplica") ||
    lower.includes("nao se aplica")
  )
    return "Desempregado"
  return "CLT"
}

export function normalizeHouseholdIncome(val?: string | null): HouseholdIncome {
  if (!val) return "1 a 3 SM"
  const lower = val.toLowerCase().trim()
  if (
    lower.includes("até 1") ||
    lower.includes("ate 1") ||
    lower.includes("menos de 1")
  )
    return "Até 1 SM"
  if (
    lower.includes("1 a 2") ||
    lower.includes("1 a 3") ||
    lower.includes("1 a 3 sm")
  )
    return "1 a 3 SM"
  if (
    lower.includes("2 a 5") ||
    lower.includes("3 a 5") ||
    lower.includes("3 a 5 sm")
  )
    return "3 a 5 SM"
  if (lower.includes("acima de 5") || lower.includes("mais de 5"))
    return "Acima de 5 SM"
  if (lower.includes("prefiro não") || lower.includes("prefiro nao"))
    return "Prefiro não informar"
  return "1 a 3 SM"
}

export function normalizeHousingStatus(val?: string | null): HousingStatus {
  if (!val) return "Própria"
  const lower = val.toLowerCase().trim()
  if (lower.includes("própria") || lower.includes("propria")) return "Própria"
  if (lower.includes("alugad")) return "Alugada"
  if (lower.includes("cedid") || lower.includes("parente"))
    return "Cedida/Parentes"
  if (lower.includes("financ")) return "Financiada"
  return "Própria"
}

export function normalizeDriversLicense(val?: string | null): DriversLicense {
  if (!val) return "Não possui"
  const upper = val.toUpperCase().trim()
  if (upper === "AB") return "AB"
  if (upper.includes("B")) return "B"
  if (upper.includes("A")) return "A"
  if (upper.includes("C")) return "C"
  if (upper.includes("D")) return "D"
  if (upper.includes("E")) return "E"
  return "Não possui"
}

export function formatDisplayGender(val?: string | null): string {
  if (!val) return "Não informado"
  const norm = normalizeGender(val)
  if (norm === "masculino") return "Masculino"
  if (norm === "feminino") return "Feminino"
  return "Outro"
}

export function formatDisplayMaritalStatus(val?: string | null): string {
  if (!val) return "Não informado"
  const norm = normalizeMaritalStatus(val)
  if (norm === "solteiro") return "Solteiro(a)"
  if (norm === "casado") return "Casado(a)"
  if (norm === "divorciado") return "Divorciado(a)"
  if (norm === "viuvo") return "Viúvo(a)"
  return "Não informado"
}
