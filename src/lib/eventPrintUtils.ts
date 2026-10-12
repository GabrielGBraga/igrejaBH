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
  city?: string;
  state?: string;
  address_city?: string;
  address_state?: string;
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
 * Capitaliza palavras, respeitando preposições em português.
 */
function capitalizeCity(text: string): string {
  const lowercaseWords = new Set(["de", "do", "da", "dos", "das", "e"]);
  return text
    .toLowerCase()
    .trim()
    .split(/\s+/)
    .map((word, idx) => {
      if (idx > 0 && lowercaseWords.has(word)) return word;
      return word.charAt(0).toUpperCase() + word.slice(1);
    })
    .join(" ");
}

/**
 * Normaliza uma string de cidade e estado para o formato padrão "Cidade / UF".
 * Exemplos:
 * "Belo Horizonte, MG" -> "Belo Horizonte / MG"
 * "contagem - mg" -> "Contagem / MG"
 * "Belo Horizonte/MG" -> "Belo Horizonte / MG"
 */
export function normalizeCityState(raw: string): string {
  if (!raw || !raw.trim()) return "Belo Horizonte / MG";

  const cleaned = raw.trim();

  let parts: string[] = [];
  if (cleaned.includes("/")) {
    parts = cleaned.split("/").map((p) => p.trim());
  } else if (cleaned.includes("-")) {
    parts = cleaned.split("-").map((p) => p.trim());
  } else if (cleaned.includes(",")) {
    parts = cleaned.split(",").map((p) => p.trim());
  }

  if (parts.length >= 2) {
    const cityPart = capitalizeCity(parts[0]);
    let statePart = parts[1].toUpperCase().replace(/[^A-Z]/g, "").slice(0, 2);
    if (!statePart) statePart = "MG";
    return `${cityPart} / ${statePart}`;
  }

  const cityPart = capitalizeCity(cleaned);
  return `${cityPart} / MG`;
}

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
 * Identifica a Cidade / Estado (UF) do participante para a folha de presença e relatórios.
 * Prioriza dados do perfil (address_city e address_state), ficha de convidado (city_state)
 * ou respostas do formulário de inscrição.
 */
export function getParticipantCityState(reg: RegistrationWithDetails): string {
  let city: string | null = null;
  let state: string | null = null;

  // 1. Perfil cadastrado
  if (reg.profiles?.address_city?.trim()) {
    city = reg.profiles.address_city.trim();
  }
  if (reg.profiles?.address_state?.trim()) {
    state = reg.profiles.address_state.trim().toUpperCase();
  }

  // 2. Dados de convidado (guest_data)
  const guest = reg.guest_data as GuestDataShape | null;
  if (guest) {
    const guestCityState = guest.city_state || guest.cityState;
    if (typeof guestCityState === "string" && guestCityState.trim()) {
      return normalizeCityState(guestCityState.trim());
    }
    if (!city && guest.city && typeof guest.city === "string" && guest.city.trim()) {
      city = guest.city.trim();
    }
    if (!city && guest.address_city && typeof guest.address_city === "string" && guest.address_city.trim()) {
      city = guest.address_city.trim();
    }
    if (!state && guest.state && typeof guest.state === "string" && guest.state.trim()) {
      state = guest.state.trim().toUpperCase();
    }
    if (!state && guest.address_state && typeof guest.address_state === "string" && guest.address_state.trim()) {
      state = guest.address_state.trim().toUpperCase();
    }
  }

  // 3. Respostas do formulário (custom_responses)
  const cr = reg.custom_responses as Record<string, unknown> | null;
  if (cr) {
    for (const [k, v] of Object.entries(cr)) {
      if (typeof v !== "string" || !v.trim()) continue;
      const kLower = k.toLowerCase();

      if (
        kLower === "mandatory_city_state" ||
        kLower.includes("cidade / estado") ||
        kLower.includes("cidade/estado") ||
        kLower.includes("cidade_estado")
      ) {
        return normalizeCityState(v.trim());
      }
      if (!city && (kLower.includes("cidade") || kLower.includes("município") || kLower.includes("municipio"))) {
        city = v.trim();
      }
      if (!state && (kLower === "estado" || kLower === "uf" || kLower.includes("estado"))) {
        state = v.trim().toUpperCase();
      }
    }
  }

  // Combina cidade e estado encontrados
  if (city) {
    if (city.includes("/") || city.includes("-") || city.includes(",")) {
      return normalizeCityState(city);
    }
    const finalState = state && state.length === 2 ? state : "MG";
    return `${capitalizeCity(city)} / ${finalState}`;
  }

  if (state && state.length === 2) {
    return `Belo Horizonte / ${state}`;
  }

  return "Belo Horizonte / MG";
}

/**
 * Alias retrocompatível com a assinatura anterior.
 */
export function getParticipantGcOrCity(
  reg: RegistrationWithDetails,
  _homeGroupsMap?: Map<string, string>
): string {
  return getParticipantCityState(reg);
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
