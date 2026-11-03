import type { Database } from "@/lib/database.types"

export type Profile = Database["public"]["Tables"]["profiles"]["Row"]

export type FamilyRole = "chefe" | "esposa" | "marido" | "filho" | "individual"

export interface FamilyMemberInfo<T extends Profile = Profile> {
  profile: T
  role: FamilyRole
  roleLabel: string
}

export interface FamilyGroup<T extends Profile = Profile> {
  id: string // Identificador único da família: 'fam_' + head.id
  head: T
  name: string // Ex: "Família de Fernando Gomes Braga" ou "Ana Clara (Família individual)"
  isIndividual: boolean
  members: T[]
  membersWithRole: FamilyMemberInfo<T>[]
  spouse?: T
  children: T[]
  size: number
}

/**
 * Constrói as famílias a partir de uma lista de perfis de um Grupo Caseiro
 * utilizando conexões matrimoniais (spouse_id) e de parentesco (father_id, mother_id).
 *
 * REGRA ESSENCIAL DE CASAMENTO ("Deixa o homem pai e mãe"):
 * Quando um filho se casa (spouse_id preenchido ou status 'casado'), ele sai automaticamente
 * da família dos pais e funda uma nova família com seu cônjuge. Vínculos ascendentes de filiação
 * são considerados para o lar somente se o filho for solteiro.
 */
export function buildFamiliesForProfiles<T extends Profile>(profiles: T[]): FamilyGroup<T>[] {
  if (!profiles || profiles.length === 0) return []

  const profileMap = new Map<string, T>()
  const profileIds = new Set<string>()

  profiles.forEach((p) => {
    profileMap.set(p.id, p)
    profileIds.add(p.id)
  })

  // Grafo de adjacência de vínculos familiares no grupo
  const adj = new Map<string, Set<string>>()
  profiles.forEach((p) => adj.set(p.id, new Set()))

  profiles.forEach((p) => {
    // 1. Vínculo matrimonial (liga marido e esposa)
    if (p.spouse_id && profileIds.has(p.spouse_id)) {
      adj.get(p.id)?.add(p.spouse_id)
      adj.get(p.spouse_id)?.add(p.id)
    }

    // 2. Vínculo de filiação: SÓ conecta aos pais se o filho NÃO for casado!
    // Se o filho for casado, ele deixa a família dos pais e funda seu próprio lar.
    const isMarried = p.marital_status === "casado" || Boolean(p.spouse_id)
    if (!isMarried) {
      if (p.father_id && profileIds.has(p.father_id)) {
        adj.get(p.id)?.add(p.father_id)
        adj.get(p.father_id)?.add(p.id)
      }
      if (p.mother_id && profileIds.has(p.mother_id)) {
        adj.get(p.id)?.add(p.mother_id)
        adj.get(p.mother_id)?.add(p.id)
      }
    }
  })

  // Componentes conexos (cada componente é uma família)
  const visited = new Set<string>()
  const families: FamilyGroup<T>[] = []

  profiles.forEach((p) => {
    if (visited.has(p.id)) return

    const familyMembers: T[] = []
    const queue: string[] = [p.id]
    visited.add(p.id)

    while (queue.length > 0) {
      const currId = queue.shift()!
      const currProf = profileMap.get(currId)
      if (currProf) familyMembers.push(currProf)

      const neighbors = adj.get(currId) || new Set()
      neighbors.forEach((nId) => {
        if (!visited.has(nId)) {
          visited.add(nId)
          queue.push(nId)
        }
      })
    }

    // Identificação do Chefe da Família:
    // "Toda família é identificada por meio de um chefe, o qual é sempre o marido/pai."
    // 1. Homem que é pai de alguém na família
    const fathers = familyMembers.filter(
      (m) => m.gender === "M" && familyMembers.some((child) => child.father_id === m.id)
    )

    // 2. Homem casado (marido)
    const husbands = familyMembers.filter(
      (m) => m.gender === "M" && m.spouse_id && familyMembers.some((s) => s.id === m.spouse_id)
    )

    let head: T
    if (fathers.length > 0) {
      head = fathers[0]
    } else if (husbands.length > 0) {
      head = husbands[0]
    } else {
      // 3. Família monoparental feminina (mãe com filhos, pai não cadastrado no grupo)
      const mothers = familyMembers.filter(
        (m) => m.gender === "F" && familyMembers.some((child) => child.mother_id === m.id)
      )
      if (mothers.length > 0) {
        head = mothers[0]
      } else {
        // 4. Família individual ou sem vínculos diretos de parentesco
        const adultMen = familyMembers.filter(
          (m) => m.gender === "M" && (!m.father_id || m.is_baptized || !!m.baptism_date)
        )
        head = adultMen.length > 0 ? adultMen[0] : familyMembers[0]
      }
    }

    const isIndividual = familyMembers.length === 1
    const spouse = head.spouse_id ? profileMap.get(head.spouse_id) : undefined

    // Filhos da família: membros que apontam para o chefe ou para o cônjuge como pais
    const children = familyMembers.filter(
      (m) =>
        m.id !== head.id &&
        (!spouse || m.id !== spouse.id) &&
        (m.father_id === head.id ||
          m.mother_id === head.id ||
          (spouse && (m.father_id === spouse.id || m.mother_id === spouse.id)))
    )

    // Montar papéis dos membros
    const membersWithRole: FamilyMemberInfo<T>[] = familyMembers.map((m) => {
      let role: FamilyRole = "individual"
      let roleLabel = "Própria família"

      if (isIndividual) {
        role = "individual"
        roleLabel = "Própria família"
      } else if (m.id === head.id) {
        role = "chefe"
        roleLabel = head.gender === "F" ? "Responsável do Lar" : "Chefe da Família"
      } else if (spouse && m.id === spouse.id) {
        role = m.gender === "M" ? "marido" : "esposa"
        roleLabel = m.gender === "M" ? "Esposo" : "Esposa"
      } else if (children.some((c) => c.id === m.id)) {
        role = "filho"
        roleLabel = m.gender === "F" ? "Filha" : "Filho"
      } else {
        role = "individual"
        roleLabel = "Familiar"
      }

      return { profile: m, role, roleLabel }
    })

    const familyName = isIndividual
      ? `${head.full_name} (Família própria)`
      : `Família de ${head.full_name}`

    families.push({
      id: `fam_${head.id}`,
      head,
      name: familyName,
      isIndividual,
      members: familyMembers,
      membersWithRole,
      spouse,
      children,
      size: familyMembers.length,
    })
  })

  // Ordenação alfabética pelo nome do chefe da família
  families.sort((a, b) => a.head.full_name.localeCompare(b.head.full_name, "pt-BR"))
  return families
}

/**
 * Encontra a família de um perfil específico dentro da lista de famílias calculada.
 */
export function getFamilyForProfile<T extends Profile>(
  profileId: string,
  families: FamilyGroup<T>[]
): FamilyGroup<T> | null {
  for (const family of families) {
    if (family.members.some((m) => m.id === profileId)) {
      return family
    }
  }
  return null
}
