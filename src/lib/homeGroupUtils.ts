import type { Database } from "@/lib/database.types"

type Profile = Database["public"]["Tables"]["profiles"]["Row"]
type HomeGroup = Database["public"]["Tables"]["home_groups"]["Row"]

/**
 * Obtém os nomes dos líderes do Grupo Caseiro formatados
 * Ex: "Carlos Silva & Ana Silva" ou "João Silva" ou "Liderança a definir"
 */
export function getHomeGroupLeadersName(
  hg: HomeGroup,
  profileMap: Map<string, Profile> | ((id: string) => Profile | undefined)
): string {
  const getProfile =
    typeof profileMap === "function" ? profileMap : (id: string) => profileMap.get(id)

  const l1 = hg.leader_1_id ? getProfile(hg.leader_1_id)?.full_name : null
  const l2 = hg.leader_2_id ? getProfile(hg.leader_2_id)?.full_name : null

  const names = [l1, l2].filter(Boolean) as string[]
  if (names.length > 0) {
    return names.join(" & ")
  }
  return "Liderança a definir"
}

/**
 * Identificação principal do Grupo Caseiro baseada no nome dos líderes
 * Ex: "Grupo de Carlos Silva & Ana Silva" ou "Grupo de João Silva"
 * Se ainda não tiver líderes cadastrados: "Grupo Caseiro (Castelo)" ou "Grupo Caseiro (Sem líder)"
 */
export function getHomeGroupDisplayName(
  hg: HomeGroup,
  profileMap: Map<string, Profile> | ((id: string) => Profile | undefined)
): string {
  const leaders = getHomeGroupLeadersName(hg, profileMap)
  if (leaders !== "Liderança a definir") {
    return `Grupo de ${leaders}`
  }

  if (hg.location_text) {
    const firstPart = hg.location_text.split("-")[0].trim()
    return `Grupo Caseiro (${firstPart})`
  }

  return `Grupo Caseiro (${hg.id.slice(0, 5)})`
}

/**
 * Identificação do Grupo Caseiro com líderes e localidade para listagens e buscas
 * Ex: "Grupo de Carlos Silva & Ana Silva • Castelo"
 */
export function getHomeGroupFullLabel(
  hg: HomeGroup,
  profileMap: Map<string, Profile> | ((id: string) => Profile | undefined)
): string {
  const displayName = getHomeGroupDisplayName(hg, profileMap)
  if (hg.location_text) {
    const loc = hg.location_text.split("-")[0].trim()
    if (!displayName.includes(loc)) {
      return `${displayName} • ${loc}`
    }
  }
  return displayName
}

/**
 * Palavras-chave completas para o filtro de pesquisa do grupo
 */
export function getHomeGroupSearchKeywords(
  hg: HomeGroup,
  profileMap: Map<string, Profile> | ((id: string) => Profile | undefined),
  extraKeywords?: string
): string {
  const leaders = getHomeGroupLeadersName(hg, profileMap)
  const loc = hg.location_text || ""
  return `${leaders} ${loc} ${extraKeywords || ""}`.toLowerCase()
}
