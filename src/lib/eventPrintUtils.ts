import type { RegistrationWithDetails } from "@/components/events/RegistrationDetailDialog";

interface GuestDataShape {
  full_name?: string;
  fullName?: string;
  email?: string;
  phone?: string;
  cpf?: string;
  gender?: string;
  city_state?: string;
  cityState?: string;
  home_group?: string;
  dietary_restrictions?: string;
  medical_notes?: string;
}

export interface DietaryInfo {
  hasRestriction: boolean;
  categories: string[];
  description: string;
}

export type PrintReportType = "presence" | "rooms" | "kitchen" | "all";

/**
 * Obtém o nome completo do discípulo/participante a partir de perfis, dados de convidado ou respostas customizadas.
 */
export function getParticipantName(reg: RegistrationWithDetails): string {
  if (reg.profiles?.full_name?.trim()) return reg.profiles.full_name.trim();
  const guest = reg.guest_data as GuestDataShape | null;
  if (guest?.full_name && typeof guest.full_name === "string" && guest.full_name.trim()) {
    return guest.full_name.trim();
  }
  if (guest?.fullName && typeof guest.fullName === "string" && guest.fullName.trim()) {
    return guest.fullName.trim();
  }
  const cr = reg.custom_responses as Record<string, unknown> | null;
  if (cr) {
    for (const [k, v] of Object.entries(cr)) {
      const kLower = k.toLowerCase();
      if (
        (kLower.includes("nome") || kLower === "mandatory_full_name") &&
        typeof v === "string" &&
        v.trim()
      ) {
        return v.trim();
      }
    }
  }
  return "Discípulo / Irmão";
}

/**
 * Obtém o telefone de contato do discípulo.
 */
export function getParticipantPhone(reg: RegistrationWithDetails): string {
  if (reg.profiles?.phone?.trim()) return reg.profiles.phone.trim();
  const guest = reg.guest_data as GuestDataShape | null;
  if (guest?.phone && typeof guest.phone === "string" && guest.phone.trim()) {
    return guest.phone.trim();
  }
  const cr = reg.custom_responses as Record<string, unknown> | null;
  if (cr) {
    for (const [k, v] of Object.entries(cr)) {
      const kLower = k.toLowerCase();
      if (
        (kLower.includes("telefone") ||
          kLower.includes("celular") ||
          kLower.includes("whatsapp") ||
          kLower === "mandatory_phone") &&
        typeof v === "string" &&
        v.trim()
      ) {
        return v.trim();
      }
    }
  }
  return "—";
}

/**
 * Identifica o Grupo Caseiro e/ou Cidade do participante para a folha de presença.
 */
export function getParticipantGcOrCity(
  reg: RegistrationWithDetails,
  homeGroupsMap?: Map<string, string>
): string {
  let gc: string | null = null;
  let city: string | null = null;

  // 1. Perfil relacional
  if (reg.profiles?.home_groups?.location_text?.trim()) {
    gc = reg.profiles.home_groups.location_text.trim();
  } else if (reg.profiles?.home_group_id && homeGroupsMap?.has(reg.profiles.home_group_id)) {
    gc = homeGroupsMap.get(reg.profiles.home_group_id)?.trim() || null;
  }

  if (reg.profiles?.address_city?.trim()) {
    city = reg.profiles.address_city.trim();
  }

  // 2. Dados de convidado
  const guest = reg.guest_data as GuestDataShape | null;
  if (guest) {
    if (!city && guest.city_state && typeof guest.city_state === "string") {
      city = guest.city_state.trim();
    }
    if (!city && guest.cityState && typeof guest.cityState === "string") {
      city = guest.cityState.trim();
    }
    if (!gc && guest.home_group && typeof guest.home_group === "string") {
      gc = guest.home_group.trim();
    }
  }

  // 3. Respostas do formulário
  const cr = reg.custom_responses as Record<string, unknown> | null;
  if (cr) {
    for (const [k, v] of Object.entries(cr)) {
      const kLower = k.toLowerCase();
      if (
        !gc &&
        (kLower.includes("grupo caseiro") ||
          kLower === "gc" ||
          kLower.includes("oikos")) &&
        typeof v === "string" &&
        v.trim()
      ) {
        gc = v.trim();
      }
      if (
        !city &&
        (kLower.includes("cidade") || kLower === "mandatory_city_state") &&
        typeof v === "string" &&
        v.trim()
      ) {
        city = v.trim();
      }
    }
  }

  if (gc && city) {
    if (gc.toLowerCase().includes(city.toLowerCase())) return gc;
    return `${gc} • ${city}`;
  }
  if (gc) return gc;
  if (city) return city;
  return "Belo Horizonte / MG";
}

/**
 * Obtém o quarto/alojamento alocado para o participante.
 */
export function getParticipantRoom(reg: RegistrationWithDetails): string {
  if (reg.retreat_rooms?.name?.trim()) return reg.retreat_rooms.name.trim();
  if (
    reg.room_allocation &&
    reg.room_allocation.trim() &&
    reg.room_allocation !== "Não alocado"
  ) {
    return reg.room_allocation.trim();
  }
  return "Pendente";
}

/**
 * Mapeia e analisa restrições alimentares declaradas na ficha médica ou respostas livres.
 */
export function getParticipantDietaryInfo(reg: RegistrationWithDetails): DietaryInfo {
  const rawDescriptions: string[] = [];

  // 1. Respostas customizadas
  const cr = reg.custom_responses as Record<string, unknown> | null;
  if (cr) {
    for (const [k, v] of Object.entries(cr)) {
      const kLower = k.toLowerCase();
      if (
        kLower.includes("restriç") ||
        kLower.includes("aliment") ||
        kLower.includes("alerg") ||
        kLower.includes("dieta") ||
        kLower.includes("cardápio") ||
        kLower.includes("cardapio") ||
        kLower.includes("intoler") ||
        kLower.includes("glúten") ||
        kLower.includes("gluten") ||
        kLower.includes("lactose") ||
        kLower.includes("vegetar") ||
        kLower.includes("vegano") ||
        kLower.includes("saúde") ||
        kLower.includes("saude") ||
        kLower.includes("médic") ||
        kLower.includes("medic")
      ) {
        if (typeof v === "string" && v.trim()) {
          rawDescriptions.push(v.trim());
        } else if (Array.isArray(v)) {
          rawDescriptions.push(v.join(", "));
        }
      }
    }
  }

  // 2. Observações gerais da inscrição
  if (reg.notes && reg.notes.trim()) {
    const notesLower = reg.notes.toLowerCase();
    if (
      notesLower.includes("restriç") ||
      notesLower.includes("alerg") ||
      notesLower.includes("aliment") ||
      notesLower.includes("dieta") ||
      notesLower.includes("glúten") ||
      notesLower.includes("gluten") ||
      notesLower.includes("lactose")
    ) {
      rawDescriptions.push(reg.notes.trim());
    }
  }

  // 3. Ficha de convidado
  const guest = reg.guest_data as GuestDataShape | null;
  if (guest) {
    if (typeof guest.dietary_restrictions === "string" && guest.dietary_restrictions.trim()) {
      rawDescriptions.push(guest.dietary_restrictions.trim());
    }
    if (typeof guest.medical_notes === "string" && guest.medical_notes.trim()) {
      rawDescriptions.push(guest.medical_notes.trim());
    }
  }

  const combinedText = rawDescriptions.join("; ").trim();
  if (!combinedText) {
    return { hasRestriction: false, categories: [], description: "Nenhuma restrição informada" };
  }

  const lowerText = combinedText.toLowerCase();

  const isNone =
    lowerText === "nenhuma" ||
    lowerText === "nenhum" ||
    lowerText === "não" ||
    lowerText === "nao" ||
    lowerText === "sem restrições" ||
    lowerText === "sem restricao" ||
    lowerText === "sem restrições alimentares" ||
    lowerText === "nada" ||
    lowerText === "n/a" ||
    lowerText === "nenhuma restrição" ||
    lowerText === "nenhuma restrição alimentar";

  if (isNone) {
    return { hasRestriction: false, categories: [], description: "Nenhuma" };
  }

  const categories: string[] = [];

  if (
    lowerText.includes("glúten") ||
    lowerText.includes("gluten") ||
    lowerText.includes("celíac") ||
    lowerText.includes("celiac") ||
    lowerText.includes("trigo")
  ) {
    categories.push("Celíaco / Glúten");
  }
  if (
    lowerText.includes("lactose") ||
    lowerText.includes("leite") ||
    lowerText.includes("derivados")
  ) {
    categories.push("Intolerante a Lactose");
  }
  if (
    lowerText.includes("diabet") ||
    lowerText.includes("açúcar") ||
    lowerText.includes("acucar") ||
    lowerText.includes("glicem") ||
    lowerText.includes("insulina")
  ) {
    categories.push("Diabético");
  }
  if (
    lowerText.includes("vegetar") ||
    lowerText.includes("vegano") ||
    lowerText.includes("vegan") ||
    lowerText.includes("não come carne")
  ) {
    categories.push("Vegetariano / Vegano");
  }
  if (
    lowerText.includes("alerg") ||
    lowerText.includes("amendoim") ||
    lowerText.includes("frutos do mar") ||
    lowerText.includes("camarão") ||
    lowerText.includes("camarao") ||
    lowerText.includes("peixe") ||
    lowerText.includes("ovo") ||
    lowerText.includes("nozes") ||
    lowerText.includes("castanha")
  ) {
    categories.push("Alergias Alimentares");
  }

  if (categories.length === 0) {
    categories.push("Outras Restrições");
  }

  return {
    hasRestriction: true,
    categories,
    description: combinedText,
  };
}
