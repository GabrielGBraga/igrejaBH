/**
 * @file serviceTeams.ts
 * @description Definições, metadados e utilitários para as Equipes de Serviço (Voluntariado / Diaconato) dos eventos.
 *
 * Princípio Teológico: Sacerdócio Universal de todos os santos (1 Pe 2:9).
 * Todos os irmãos são ministros e servem no Corpo de Cristo para a edificação mútua.
 */

import {
  UtensilsCrossed,
  Brush,
  HeartHandshake,
  Volume2,
  Baby,
  Flame,
  Wrench,
  Users,
  type LucideIcon,
} from "lucide-react";
import {
  type ServiceTeamId,
  getServiceTeamColorConfig,
} from "./colors";

export type { ServiceTeamId };

export interface ServiceTeamDefinition {
  id: ServiceTeamId;
  label: string;
  shortLabel: string;
  description: string;
  biblicalFocus: string;
  icon: LucideIcon;
}

export const SERVICE_TEAMS: ServiceTeamDefinition[] = [
  {
    id: "cozinha",
    label: "Cozinha & Alimentação",
    shortLabel: "Cozinha",
    description: "Preparo e distribuição das refeições, lanches e café comunitário.",
    biblicalFocus: "Partir do pão e comunhão na mesa (Atos 2:46)",
    icon: UtensilsCrossed,
  },
  {
    id: "limpeza",
    label: "Limpeza & Organização",
    shortLabel: "Limpeza",
    description: "Higienização, zelo e manutenção das áreas comuns e banheiros.",
    biblicalFocus: "Zelo e boa ordem na casa do Senhor (1 Co 14:40)",
    icon: Brush,
  },
  {
    id: "recepcao",
    label: "Recepção & Boas-vindas",
    shortLabel: "Recepção",
    description: "Acolhimento caloroso na chegada, credenciamento e orientações.",
    biblicalFocus: "Hospitalidade mútua sem murmuração (1 Pe 4:9)",
    icon: HeartHandshake,
  },
  {
    id: "multimidia",
    label: "Multimídia & Som",
    shortLabel: "Som & Mídia",
    description: "Operação do sistema de áudio, microfones, projeção e transmissão.",
    biblicalFocus: "Clamor claro da palavra para edificação (Neemias 8:8)",
    icon: Volume2,
  },
  {
    id: "criancas",
    label: "Cuidado com Crianças",
    shortLabel: "Crianças",
    description: "Assistência, atividades edificantes e cuidado com os pequeninos.",
    biblicalFocus: "Deixai vir a mim as crianças (Marcos 10:14)",
    icon: Baby,
  },
  {
    id: "intercessao",
    label: "Intercessão & Oração",
    shortLabel: "Intercessão",
    description: "Vigília contínua e sustentação espiritual em oração durante todo o encontro.",
    biblicalFocus: "Orai uns pelos outros em todo o tempo (Efésios 6:18)",
    icon: Flame,
  },
  {
    id: "apoio",
    label: "Apoio & Logística",
    shortLabel: "Apoio",
    description: "Montagem, carregamento de materiais, sinalização e suporte imediato.",
    biblicalFocus: "Auxílio mútuo e socorro nas necessidades (Romanos 12:13)",
    icon: Wrench,
  },
  {
    id: "geral",
    label: "Serviço Geral",
    shortLabel: "Geral",
    description: "Disponível para qualquer demanda emergencial do corpo durante o evento.",
    biblicalFocus: "Servi uns aos outros pelo amor (Gálatas 5:13)",
    icon: Users,
  },
];

export const SERVICE_TEAM_MAP = new Map<ServiceTeamId, ServiceTeamDefinition>(
  SERVICE_TEAMS.map((team) => [team.id, team])
);

/**
 * Recupera os metadados da equipe de serviço pelo identificador string.
 */
export function getServiceTeam(id?: string | null): ServiceTeamDefinition | null {
  if (!id) return null;
  const normalized = id.toLowerCase().trim() as ServiceTeamId;
  return SERVICE_TEAM_MAP.get(normalized) ?? null;
}

/**
 * Retorna as classes de badge e estilos da equipe a partir de colors.ts.
 */
export function getServiceTeamBadgeStyle(id?: string | null): string {
  const config = getServiceTeamColorConfig(id);
  if (!config) {
    return "bg-zinc-500/10 text-zinc-600 dark:text-zinc-400 border-zinc-500/30";
  }
  return config.badgeClass;
}
