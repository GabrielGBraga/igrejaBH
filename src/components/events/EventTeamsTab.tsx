import { useState, useMemo } from "react";
import {
  Users,
  Copy,
  Check,
  Share2,
  Search,
  Plus,
  UserCheck,
  Bed,
  Phone,
  Eye,
  Filter,
} from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Badge } from "@/components/ui/badge";
import { Card } from "@/components/ui/card";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogDescription,
  DialogFooter,
} from "@/components/ui/dialog";
import {
  Tooltip,
  TooltipContent,
  TooltipProvider,
  TooltipTrigger,
} from "@/components/ui/tooltip";
import { toast } from "sonner";
import {
  SERVICE_TEAMS,
  getServiceTeam,
  type ServiceTeamDefinition,
} from "@/constants/serviceTeams";
import { getServiceTeamColorConfig } from "@/constants/colors";
import type { RegistrationWithDetails } from "./RegistrationDetailDialog";
import type { Database } from "@/lib/database.types";

type Retreat = Database["public"]["Tables"]["retreats"]["Row"];

interface EventTeamsTabProps {
  retreat: Retreat;
  registrations: RegistrationWithDetails[];
  onUpdateServiceTeam: (
    registrationId: string,
    serviceTeam: string | null
  ) => Promise<void>;
  onViewDetails: (reg: RegistrationWithDetails) => void;
  onAssignRoomClick?: (reg: RegistrationWithDetails) => void;
}

interface VolunteerItem {
  id: string;
  name: string;
  phone: string;
  email: string;
  roomName: string;
  isRoomAllocated: boolean;
  serviceTeam: string | null;
  paid: boolean | null;
  paymentMethod: string | null;
  rawRegistration: RegistrationWithDetails;
}

export function EventTeamsTab({
  retreat,
  registrations,
  onUpdateServiceTeam,
  onViewDetails,
  onAssignRoomClick,
}: EventTeamsTabProps) {
  const [searchTerm, setSearchTerm] = useState("");
  const [selectedTeamFilter, setSelectedTeamFilter] = useState<string>("all");
  const [copiedTeamId, setCopiedTeamId] = useState<string | null>(null);
  const [copiedAll, setCopiedAll] = useState(false);
  const [isAssignModalOpen, setIsAssignModalOpen] = useState(false);
  const [selectedAttendeeToAssign, setSelectedAttendeeToAssign] = useState<string>("");
  const [selectedTeamToAssign, setSelectedTeamToAssign] = useState<string>("cozinha");
  const [isSubmittingAssign, setIsSubmittingAssign] = useState(false);

  // Normalize volunteer data from registrations
  const normalizedAttendees = useMemo<VolunteerItem[]>(() => {
    return registrations.map((reg) => {
      const guest = reg.guest_data as Record<string, unknown> | null;
      const guestName = typeof guest?.full_name === "string" ? guest.full_name : null;
      const guestPhone = typeof guest?.phone === "string" ? guest.phone : null;
      const guestEmail = typeof guest?.email === "string" ? guest.email : null;

      const name = reg.profiles?.full_name || guestName || "Irmão sem nome";
      const phone = reg.profiles?.phone || guestPhone || "Não informado";
      const email = reg.profiles?.email || guestEmail || "Não informado";
      const roomName = reg.retreat_rooms?.name || reg.room_allocation || "Não alocado";
      const isRoomAllocated =
        roomName !== "Não alocado" && Boolean(reg.room_id || reg.room_allocation);

      return {
        id: reg.id,
        name,
        phone,
        email,
        roomName,
        isRoomAllocated,
        serviceTeam: reg.service_team?.toLowerCase().trim() || null,
        paid: reg.paid,
        paymentMethod: reg.payment_method,
        rawRegistration: reg,
      };
    });
  }, [registrations]);

  // Aggregate counts per team
  const teamCounts = useMemo(() => {
    const counts: Record<string, number> = {
      unassigned: 0,
      totalVolunteers: 0,
    };

    SERVICE_TEAMS.forEach((team) => {
      counts[team.id] = 0;
    });

    normalizedAttendees.forEach((attendee) => {
      if (attendee.serviceTeam && counts[attendee.serviceTeam] !== undefined) {
        counts[attendee.serviceTeam] += 1;
        counts.totalVolunteers += 1;
      } else {
        counts.unassigned += 1;
      }
    });

    return counts;
  }, [normalizedAttendees]);

  // Attendees without a team for the assignment modal
  const unassignedAttendees = useMemo(() => {
    return normalizedAttendees.filter((a) => !a.serviceTeam);
  }, [normalizedAttendees]);

  // Quick change team handler
  const handleTeamChange = async (
    registrationId: string,
    newTeam: string | null
  ) => {
    try {
      const teamValue = newTeam === "none" ? null : newTeam;
      await onUpdateServiceTeam(registrationId, teamValue);
      const teamDef = getServiceTeam(teamValue);
      if (teamDef) {
        toast.success(`Irmão(ã) transferido para a equipe de ${teamDef.label}!`);
      } else {
        toast.success("Irmão(ã) removido da escala de serviço.");
      }
    } catch (err: unknown) {
      const msg = err instanceof Error ? err.message : "Erro desconhecido";
      console.error("Erro ao alterar equipe de serviço:", err);
      toast.error("Falha ao atualizar equipe: " + msg);
    }
  };

  // Assign attendee via modal
  const handleAssignSubmit = async () => {
    if (!selectedAttendeeToAssign) {
      toast.error("Selecione um discípulo para atribuir.");
      return;
    }
    try {
      setIsSubmittingAssign(true);
      await onUpdateServiceTeam(selectedAttendeeToAssign, selectedTeamToAssign);
      const teamDef = getServiceTeam(selectedTeamToAssign);
      toast.success(
        `Irmão(ã) adicionado com sucesso à equipe de ${teamDef?.label || selectedTeamToAssign}!`
      );
      setIsAssignModalOpen(false);
      setSelectedAttendeeToAssign("");
    } catch (err: unknown) {
      const msg = err instanceof Error ? err.message : "Erro desconhecido";
      toast.error("Erro ao atribuir voluntário: " + msg);
    } finally {
      setIsSubmittingAssign(false);
    }
  };

  // Copy schedule for a single team
  const handleCopyTeamSchedule = (team: ServiceTeamDefinition) => {
    const volunteers = normalizedAttendees.filter(
      (a) => a.serviceTeam === team.id
    );

    if (volunteers.length === 0) {
      toast.info(`A equipe de ${team.label} ainda não possui voluntários.`);
      return;
    }

    let text = `📋 *ESCALA DE SERVIÇO — ${team.label.toUpperCase()}*\n`;
    text += `📍 *Encontro:* ${retreat.title}\n`;
    text += `👥 *Total de Servidores:* ${volunteers.length} irmãos\n`;
    text += `📖 *Foco Bíblico:* ${team.biblicalFocus}\n\n`;
    text += `*INTEGRANTES DA EQUIPE:*\n`;

    volunteers.forEach((v, index) => {
      text += `${index + 1}. *${v.name}*\n`;
      text += `   📞 WhatsApp: ${v.phone}\n`;
      text += `   🏠 Alojamento: ${v.roomName}\n`;
    });

    text += `\n_“Tudo o que fizerdes, fazei-o de todo o coração, como para o Senhor e não para homens.” (Cl 3:23)_`;

    navigator.clipboard.writeText(text);
    setCopiedTeamId(team.id);
    toast.success(`Escala da equipe ${team.shortLabel} copiada para o WhatsApp!`);
    setTimeout(() => setCopiedTeamId(null), 3000);
  };

  // Share team schedule directly to WhatsApp
  const handleShareTeamWhatsApp = (team: ServiceTeamDefinition) => {
    const volunteers = normalizedAttendees.filter(
      (a) => a.serviceTeam === team.id
    );

    if (volunteers.length === 0) {
      toast.info(`A equipe de ${team.label} ainda não possui voluntários.`);
      return;
    }

    let text = `📋 *ESCALA DE SERVIÇO — ${team.label.toUpperCase()}*\n`;
    text += `📍 *Encontro:* ${retreat.title}\n`;
    text += `👥 *Total:* ${volunteers.length} voluntários\n\n`;

    volunteers.forEach((v, index) => {
      text += `${index + 1}. *${v.name}* — ${v.phone} (Quarto: ${v.roomName})\n`;
    });

    text += `\n_Igreja em Belo Horizonte — Sacerdócio Universal de Todos os Santos_`;

    const url = `https://wa.me/?text=${encodeURIComponent(text)}`;
    window.open(url, "_blank");
  };

  // Copy all schedules combined
  const handleCopyAllSchedules = () => {
    const volunteers = normalizedAttendees.filter((a) => Boolean(a.serviceTeam));
    if (volunteers.length === 0) {
      toast.info("Ainda não há voluntários escalados em nenhuma equipe.");
      return;
    }

    let text = `🏛️ *ESCALA GERAL DE SERVIÇO DOS SANTOS*\n`;
    text += `📍 *Encontro:* ${retreat.title}\n`;
    text += `👥 *Total de Voluntários:* ${teamCounts.totalVolunteers} de ${normalizedAttendees.length} inscritos\n`;
    text += `-------------------------------------------\n\n`;

    SERVICE_TEAMS.forEach((team) => {
      const teamVolunteers = normalizedAttendees.filter(
        (a) => a.serviceTeam === team.id
      );

      if (teamVolunteers.length > 0) {
        text += `*▶ ${team.label.toUpperCase()}* (${teamVolunteers.length} irmãos)\n`;
        teamVolunteers.forEach((v, idx) => {
          text += `  ${idx + 1}. ${v.name} — ${v.phone} [${v.roomName}]\n`;
        });
        text += `\n`;
      }
    });

    text += `_“Cada um exerça o dom que recebeu na edificação do Corpo.”_`;

    navigator.clipboard.writeText(text);
    setCopiedAll(true);
    toast.success("Escala geral de todas as equipes copiada com sucesso!");
    setTimeout(() => setCopiedAll(false), 3000);
  };

  // Filter attendees by search and team tab
  const filteredAttendees = useMemo(() => {
    return normalizedAttendees.filter((attendee) => {
      // Team filter
      if (selectedTeamFilter !== "all") {
        if (selectedTeamFilter === "unassigned") {
          if (attendee.serviceTeam) return false;
        } else if (selectedTeamFilter === "assigned") {
          if (!attendee.serviceTeam) return false;
        } else if (attendee.serviceTeam !== selectedTeamFilter) {
          return false;
        }
      }

      // Search term
      if (searchTerm.trim() !== "") {
        const query = searchTerm.toLowerCase();
        const matchesName = attendee.name.toLowerCase().includes(query);
        const matchesPhone = attendee.phone.toLowerCase().includes(query);
        const matchesRoom = attendee.roomName.toLowerCase().includes(query);
        const teamDef = getServiceTeam(attendee.serviceTeam);
        const matchesTeam = teamDef?.label.toLowerCase().includes(query) || false;

        if (!matchesName && !matchesPhone && !matchesRoom && !matchesTeam) {
          return false;
        }
      }

      return true;
    });
  }, [normalizedAttendees, selectedTeamFilter, searchTerm]);

  return (
    <div className="space-y-6 w-full animate-in fade-in duration-300">
      {/* 1. Header & Summary Hero Bar */}
      <div className="bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-xl p-4 sm:p-6 shadow-sm">
        <div className="flex flex-col lg:flex-row lg:items-center justify-between gap-4">
          <div className="space-y-1">
            <div className="flex items-center gap-2.5">
              <div className="p-2.5 rounded-lg bg-primary/10 text-primary">
                <Users className="w-5 h-5" />
              </div>
              <div>
                <h2 className="text-lg sm:text-xl font-bold text-zinc-900 dark:text-zinc-50 leading-tight">
                  Equipes de Serviço & Voluntariado
                </h2>
                <p className="text-xs sm:text-sm text-zinc-500 dark:text-zinc-400">
                  Sacerdócio universal de todos os santos em operação. Cada irmão serve no Corpo de Cristo.
                </p>
              </div>
            </div>
          </div>

          {/* Action Buttons */}
          <div className="flex flex-wrap items-center gap-2.5">
            <Button
              variant="outline"
              onClick={handleCopyAllSchedules}
              className="min-h-[44px] h-11 text-xs font-semibold rounded-lg cursor-pointer flex items-center gap-1.5"
            >
              {copiedAll ? (
                <>
                  <Check className="w-4 h-4 text-emerald-500" />
                  Escala Copiada!
                </>
              ) : (
                <>
                  <Copy className="w-4 h-4 text-zinc-500" />
                  Copiar Escala Geral
                </>
              )}
            </Button>

            <Button
              onClick={() => setIsAssignModalOpen(true)}
              className="min-h-[44px] h-11 text-xs font-bold rounded-lg cursor-pointer flex items-center gap-1.5 bg-primary text-primary-foreground hover:bg-primary/90"
            >
              <Plus className="w-4 h-4" />
              Atribuir Voluntário
            </Button>
          </div>
        </div>

        {/* Quick Stats Badges */}
        <div className="grid grid-cols-2 sm:grid-cols-4 gap-3 mt-5 pt-4 border-t border-zinc-100 dark:border-zinc-800/60">
          <div className="bg-zinc-50 dark:bg-zinc-800/40 p-3 rounded-lg border border-zinc-200/60 dark:border-zinc-800">
            <span className="text-[11px] font-medium text-zinc-500 dark:text-zinc-400 block">
              Total de Inscritos
            </span>
            <span className="text-lg font-bold text-zinc-900 dark:text-zinc-50">
              {normalizedAttendees.length}
            </span>
          </div>

          <div className="bg-emerald-500/10 p-3 rounded-lg border border-emerald-500/20">
            <span className="text-[11px] font-semibold text-emerald-700 dark:text-emerald-300 block">
              Voluntários Servindo
            </span>
            <span className="text-lg font-bold text-emerald-800 dark:text-emerald-200">
              {teamCounts.totalVolunteers}{" "}
              <span className="text-xs font-normal">
                ({normalizedAttendees.length > 0
                  ? Math.round((teamCounts.totalVolunteers / normalizedAttendees.length) * 100)
                  : 0}
                %)
              </span>
            </span>
          </div>

          <div className="bg-amber-500/10 p-3 rounded-lg border border-amber-500/20">
            <span className="text-[11px] font-semibold text-amber-700 dark:text-amber-300 block">
              Participantes sem Equipe
            </span>
            <span className="text-lg font-bold text-amber-800 dark:text-amber-200">
              {teamCounts.unassigned}
            </span>
          </div>

          <div className="bg-primary/10 p-3 rounded-lg border border-primary/20">
            <span className="text-[11px] font-semibold text-primary block">
              Equipes Ativas
            </span>
            <span className="text-lg font-bold text-primary">
              {SERVICE_TEAMS.filter((t) => teamCounts[t.id] > 0).length} de {SERVICE_TEAMS.length}
            </span>
          </div>
        </div>
      </div>

      {/* 2. Team Cards KPI Overview */}
      <div className="space-y-3">
        <div className="flex items-center justify-between">
          <h3 className="text-xs font-bold uppercase tracking-wider text-zinc-600 dark:text-zinc-400">
            Visão Geral das Equipes
          </h3>
          <span className="text-[11px] text-zinc-500">
            Clique em uma equipe para filtrar
          </span>
        </div>

        <div className="grid grid-cols-2 sm:grid-cols-4 lg:grid-cols-4 gap-3">
          {SERVICE_TEAMS.map((team) => {
            const Icon = team.icon;
            const count = teamCounts[team.id] || 0;
            const isSelected = selectedTeamFilter === team.id;
            const colorCfg = getServiceTeamColorConfig(team.id);

            return (
              <Card
                key={team.id}
                onClick={() =>
                  setSelectedTeamFilter(isSelected ? "all" : team.id)
                }
                className={`p-3.5 rounded-xl border transition-all cursor-pointer hover:shadow-md ${
                  isSelected
                    ? "ring-2 ring-primary border-primary bg-primary/5 dark:bg-primary/10"
                    : "bg-white dark:bg-zinc-900 border-zinc-200 dark:border-zinc-800 hover:border-zinc-300 dark:hover:border-zinc-700"
                }`}
              >
                <div className="flex items-start justify-between gap-2">
                  <div
                    className="p-2 rounded-lg"
                    style={{
                      backgroundColor: colorCfg?.bgLight,
                      color: colorCfg?.light,
                    }}
                  >
                    <Icon className="w-4 h-4" />
                  </div>
                  <Badge
                    variant="outline"
                    className={`text-[11px] font-bold px-2 py-0.5 rounded-full ${
                      count > 0
                        ? colorCfg?.badgeClass || "bg-primary/10 text-primary border-primary/30"
                        : "bg-zinc-100 dark:bg-zinc-800 text-zinc-500 border-zinc-300 dark:border-zinc-700"
                    }`}
                  >
                    {count} {count === 1 ? "irmão" : "irmãos"}
                  </Badge>
                </div>

                <div className="mt-2.5">
                  <h4 className="text-xs font-bold text-zinc-900 dark:text-zinc-50 line-clamp-1">
                    {team.label}
                  </h4>
                  <p className="text-[10px] text-zinc-500 dark:text-zinc-400 line-clamp-1 mt-0.5">
                    {team.description}
                  </p>
                </div>

                <div className="mt-2 pt-2 border-t border-zinc-100 dark:border-zinc-800/60 flex items-center justify-between text-[10px]">
                  <span className="text-zinc-400 truncate">
                    {count > 0 ? "Escalados" : "Vazia"}
                  </span>
                  <button
                    type="button"
                    onClick={(e) => {
                      e.stopPropagation();
                      handleCopyTeamSchedule(team);
                    }}
                    className="min-h-[32px] px-1.5 py-1 text-primary hover:underline font-semibold flex items-center gap-1 cursor-pointer"
                  >
                    {copiedTeamId === team.id ? (
                      <Check className="w-3 h-3 text-emerald-500" />
                    ) : (
                      <Copy className="w-3 h-3" />
                    )}
                    Copiar
                  </button>
                </div>
              </Card>
            );
          })}
        </div>
      </div>

      {/* 3. Search and Filtering Controls */}
      <div className="flex flex-col sm:flex-row items-stretch sm:items-center justify-between gap-3 bg-white dark:bg-zinc-900 p-3.5 sm:p-4 rounded-xl border border-zinc-200 dark:border-zinc-800 shadow-sm">
        <div className="relative flex-1 max-w-md">
          <Search className="absolute left-3.5 top-1/2 -translate-y-1/2 h-4 w-4 text-zinc-400" />
          <Input
            placeholder="Buscar voluntário por nome, fone, quarto..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="pl-9 min-h-[44px] h-11 text-xs rounded-lg bg-zinc-50/50 dark:bg-zinc-800/40"
          />
        </div>

        <div className="flex items-center gap-2 flex-wrap">
          <Select
            value={selectedTeamFilter}
            onValueChange={setSelectedTeamFilter}
          >
            <SelectTrigger className="min-h-[44px] h-11 text-xs w-[180px] bg-zinc-50/50 dark:bg-zinc-800/40">
              <Filter className="w-3.5 h-3.5 mr-1.5 text-zinc-500" />
              <SelectValue placeholder="Filtrar por equipe" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="all">Todas as Inscrições ({normalizedAttendees.length})</SelectItem>
              <SelectItem value="assigned">Apenas Voluntários ({teamCounts.totalVolunteers})</SelectItem>
              <SelectItem value="unassigned">Sem Equipe ({teamCounts.unassigned})</SelectItem>
              {SERVICE_TEAMS.map((t) => (
                <SelectItem key={t.id} value={t.id}>
                  {t.shortLabel} ({teamCounts[t.id] || 0})
                </SelectItem>
              ))}
            </SelectContent>
          </Select>

          {selectedTeamFilter !== "all" && (
            <Button
              variant="ghost"
              size="sm"
              onClick={() => setSelectedTeamFilter("all")}
              className="min-h-[44px] h-11 text-xs text-zinc-500 hover:text-zinc-900 dark:hover:text-zinc-100 cursor-pointer"
            >
              Limpar Filtro
            </Button>
          )}
        </div>
      </div>

      {/* 4. Volunteer Listing Grouped or Filtered */}
      <div className="space-y-6">
        {SERVICE_TEAMS.filter((team) => {
          if (selectedTeamFilter === "all" || selectedTeamFilter === "assigned") return true;
          return selectedTeamFilter === team.id;
        }).map((team) => {
          const volunteersInTeam = filteredAttendees.filter(
            (a) => a.serviceTeam === team.id
          );

          // If filtering for a specific team and no match, show message
          if (volunteersInTeam.length === 0 && selectedTeamFilter === team.id) {
            return (
              <div
                key={team.id}
                className="bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-xl p-8 text-center space-y-3"
              >
                <div className="mx-auto w-12 h-12 rounded-full bg-zinc-100 dark:bg-zinc-800 flex items-center justify-center text-zinc-400">
                  <team.icon className="w-6 h-6" />
                </div>
                <h3 className="text-sm font-bold text-zinc-900 dark:text-zinc-50">
                  Nenhum voluntário escalado para {team.label}
                </h3>
                <p className="text-xs text-zinc-500 max-w-sm mx-auto">
                  Atribua participantes a esta equipe para montar a escala de serviço.
                </p>
                <Button
                  onClick={() => {
                    setSelectedTeamToAssign(team.id);
                    setIsAssignModalOpen(true);
                  }}
                  className="min-h-[44px] h-11 text-xs font-semibold rounded-lg cursor-pointer"
                >
                  <Plus className="w-4 h-4 mr-1.5" />
                  Adicionar Voluntário a esta Equipe
                </Button>
              </div>
            );
          }

          if (volunteersInTeam.length === 0) {
            return null;
          }

          const Icon = team.icon;
          const colorCfg = getServiceTeamColorConfig(team.id);

          return (
            <div
              key={team.id}
              className="bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-xl shadow-sm overflow-hidden"
            >
              {/* Team Group Header */}
              <div className="p-4 sm:p-5 border-b border-zinc-200 dark:border-zinc-800 bg-zinc-50/50 dark:bg-zinc-800/30 flex flex-col sm:flex-row sm:items-center justify-between gap-3">
                <div className="flex items-center gap-3">
                  <div
                    className="p-2.5 rounded-lg shrink-0"
                    style={{
                      backgroundColor: colorCfg?.bgLight,
                      color: colorCfg?.light,
                    }}
                  >
                    <Icon className="w-5 h-5" />
                  </div>
                  <div>
                    <div className="flex items-center gap-2 flex-wrap">
                      <h3 className="text-sm sm:text-base font-bold text-zinc-900 dark:text-zinc-50">
                        {team.label}
                      </h3>
                      <Badge
                        variant="outline"
                        className={`text-[10px] font-bold px-2 py-0.5 rounded-full ${
                          colorCfg?.badgeClass || ""
                        }`}
                      >
                        {volunteersInTeam.length}{" "}
                        {volunteersInTeam.length === 1 ? "voluntário" : "voluntários"}
                      </Badge>
                    </div>
                    <p className="text-[11px] text-zinc-500 dark:text-zinc-400 mt-0.5">
                      {team.description} • <span className="italic">{team.biblicalFocus}</span>
                    </p>
                  </div>
                </div>

                {/* Team Group Actions */}
                <div className="flex items-center gap-2 self-end sm:self-auto">
                  <Button
                    variant="outline"
                    size="sm"
                    onClick={() => handleCopyTeamSchedule(team)}
                    className="min-h-[44px] sm:min-h-[36px] h-11 sm:h-9 text-xs font-semibold rounded-lg cursor-pointer flex items-center gap-1.5"
                  >
                    {copiedTeamId === team.id ? (
                      <>
                        <Check className="w-3.5 h-3.5 text-emerald-500" />
                        Copiado!
                      </>
                    ) : (
                      <>
                        <Copy className="w-3.5 h-3.5 text-zinc-500" />
                        Copiar Escala
                      </>
                    )}
                  </Button>

                  <Button
                    variant="outline"
                    size="sm"
                    onClick={() => handleShareTeamWhatsApp(team)}
                    className="min-h-[44px] sm:min-h-[36px] h-11 sm:h-9 text-xs font-semibold rounded-lg cursor-pointer flex items-center gap-1.5 text-emerald-600 hover:text-emerald-700 dark:text-emerald-400 hover:bg-emerald-50 dark:hover:bg-emerald-950/30 border-emerald-500/30"
                  >
                    <Share2 className="w-3.5 h-3.5" />
                    WhatsApp
                  </Button>
                </div>
              </div>

              {/* Volunteers Table / List */}
              <div className="divide-y divide-zinc-100 dark:divide-zinc-800/80">
                {volunteersInTeam.map((volunteer) => (
                  <div
                    key={volunteer.id}
                    className="p-3.5 sm:p-4 hover:bg-zinc-50/60 dark:hover:bg-zinc-800/40 transition-colors flex flex-col md:flex-row md:items-center justify-between gap-3"
                  >
                    {/* Volunteer Identity */}
                    <div className="flex items-start sm:items-center gap-3 min-w-[240px]">
                      <div className="w-9 h-9 rounded-full bg-primary/10 text-primary flex items-center justify-center font-bold text-xs shrink-0">
                        {volunteer.name.charAt(0).toUpperCase()}
                      </div>
                      <div className="space-y-0.5">
                        <div className="font-bold text-xs sm:text-sm text-zinc-900 dark:text-zinc-50 leading-tight">
                          {volunteer.name}
                        </div>
                        <div className="flex items-center gap-2 text-[11px] text-zinc-500 dark:text-zinc-400 flex-wrap">
                          <a
                            href={`https://wa.me/55${volunteer.phone.replace(/\D/g, "")}`}
                            target="_blank"
                            rel="noreferrer"
                            className="flex items-center gap-1 text-emerald-600 dark:text-emerald-400 hover:underline min-h-[24px]"
                          >
                            <Phone className="w-3 h-3" />
                            {volunteer.phone}
                          </a>
                          <span>•</span>
                          <span className="truncate max-w-[180px]">{volunteer.email}</span>
                        </div>
                      </div>
                    </div>

                    {/* Room & Payment Badges */}
                    <div className="flex items-center gap-2 flex-wrap text-xs">
                      {/* Room Allocation */}
                      <TooltipProvider>
                        <Tooltip>
                          <TooltipTrigger asChild>
                            <Button
                              variant="outline"
                              size="sm"
                              onClick={() => onAssignRoomClick?.(volunteer.rawRegistration)}
                              className="min-h-[44px] sm:min-h-[32px] h-11 sm:h-8 text-[11px] font-semibold rounded-md flex items-center gap-1.5 cursor-pointer px-2.5"
                            >
                              <Bed className="w-3.5 h-3.5 text-primary shrink-0" />
                              <span
                                className={
                                  !volunteer.isRoomAllocated
                                    ? "text-zinc-400 italic"
                                    : "text-zinc-800 dark:text-zinc-200"
                                }
                              >
                                {volunteer.roomName}
                              </span>
                            </Button>
                          </TooltipTrigger>
                          <TooltipContent>
                            <p className="text-xs">Clique para alterar alojamento</p>
                          </TooltipContent>
                        </Tooltip>
                      </TooltipProvider>

                      {/* Payment Status */}
                      <Badge
                        variant="outline"
                        className={`text-[10px] uppercase font-bold px-2 py-0.5 rounded-full ${
                          volunteer.paid
                            ? "bg-emerald-500/10 text-emerald-700 dark:text-emerald-300 border-emerald-500/20"
                            : "bg-amber-500/10 text-amber-700 dark:text-amber-300 border-amber-500/20"
                        }`}
                      >
                        {volunteer.paid ? "Confirmado" : "Pendente"}
                      </Badge>
                    </div>

                    {/* Team Selector & Details Modal Button */}
                    <div className="flex items-center gap-2 self-end md:self-auto">
                      <Select
                        value={volunteer.serviceTeam || "none"}
                        onValueChange={(val) => handleTeamChange(volunteer.id, val)}
                      >
                        <SelectTrigger className="min-h-[44px] sm:min-h-[36px] h-11 sm:h-9 text-xs w-[170px] bg-white dark:bg-zinc-800">
                          <SelectValue placeholder="Mudar equipe" />
                        </SelectTrigger>
                        <SelectContent>
                          <SelectItem value="none">Sem equipe (Remover)</SelectItem>
                          {SERVICE_TEAMS.map((st) => (
                            <SelectItem key={st.id} value={st.id}>
                              {st.shortLabel}
                            </SelectItem>
                          ))}
                        </SelectContent>
                      </Select>

                      <Button
                        variant="ghost"
                        size="sm"
                        onClick={() => onViewDetails(volunteer.rawRegistration)}
                        className="min-h-[44px] sm:min-h-[36px] h-11 sm:h-9 px-2.5 text-xs text-primary hover:bg-primary/10 rounded-md cursor-pointer flex items-center gap-1"
                      >
                        <Eye className="w-3.5 h-3.5" />
                        <span className="hidden sm:inline">Ficha</span>
                      </Button>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          );
        })}

        {/* 5. Participants Without Team Section (if unassigned filter or all) */}
        {(selectedTeamFilter === "all" || selectedTeamFilter === "unassigned") && (
          <div className="bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-xl shadow-sm overflow-hidden">
            <div className="p-4 sm:p-5 border-b border-zinc-200 dark:border-zinc-800 bg-amber-500/5 dark:bg-amber-500/10 flex flex-col sm:flex-row sm:items-center justify-between gap-3">
              <div className="flex items-center gap-3">
                <div className="p-2.5 rounded-lg bg-amber-500/15 text-amber-600 dark:text-amber-400 shrink-0">
                  <UserCheck className="w-5 h-5" />
                </div>
                <div>
                  <div className="flex items-center gap-2 flex-wrap">
                    <h3 className="text-sm sm:text-base font-bold text-zinc-900 dark:text-zinc-50">
                      Participantes sem Equipe Atribuída
                    </h3>
                    <Badge
                      variant="outline"
                      className="text-[10px] font-bold px-2 py-0.5 rounded-full bg-amber-500/15 text-amber-700 dark:text-amber-300 border-amber-500/30"
                    >
                      {unassignedAttendees.length} irmãos
                    </Badge>
                  </div>
                  <p className="text-[11px] text-zinc-500 dark:text-zinc-400 mt-0.5">
                    Estes discípulos estão inscritos como participantes gerais. Você pode alocá-los para qualquer equipe de serviço.
                  </p>
                </div>
              </div>
            </div>

            {unassignedAttendees.length === 0 ? (
              <div className="p-8 text-center text-xs text-zinc-500">
                🎉 Glória a Deus! Todos os participantes inscritos possuem uma equipe de serviço designada!
              </div>
            ) : (
              <div className="divide-y divide-zinc-100 dark:divide-zinc-800/80 max-h-[480px] overflow-y-auto">
                {unassignedAttendees.slice(0, 30).map((attendee) => (
                  <div
                    key={attendee.id}
                    className="p-3.5 sm:p-4 hover:bg-zinc-50/60 dark:hover:bg-zinc-800/40 transition-colors flex flex-col md:flex-row md:items-center justify-between gap-3"
                  >
                    <div className="flex items-center gap-3">
                      <div className="w-8 h-8 rounded-full bg-zinc-100 dark:bg-zinc-800 text-zinc-600 dark:text-zinc-400 flex items-center justify-center font-bold text-xs shrink-0">
                        {attendee.name.charAt(0).toUpperCase()}
                      </div>
                      <div>
                        <div className="font-bold text-xs text-zinc-900 dark:text-zinc-50 leading-tight">
                          {attendee.name}
                        </div>
                        <div className="text-[11px] text-zinc-500 dark:text-zinc-400">
                          {attendee.phone} • {attendee.roomName}
                        </div>
                      </div>
                    </div>

                    <div className="flex items-center gap-2 self-end md:self-auto">
                      <Select
                        value="none"
                        onValueChange={(val) => handleTeamChange(attendee.id, val)}
                      >
                        <SelectTrigger className="min-h-[44px] sm:min-h-[36px] h-11 sm:h-9 text-xs w-[180px] bg-white dark:bg-zinc-800">
                          <SelectValue placeholder="Escalar em equipe..." />
                        </SelectTrigger>
                        <SelectContent>
                          {SERVICE_TEAMS.map((st) => (
                            <SelectItem key={st.id} value={st.id}>
                              {st.shortLabel}
                            </SelectItem>
                          ))}
                        </SelectContent>
                      </Select>

                      <Button
                        variant="ghost"
                        size="sm"
                        onClick={() => onViewDetails(attendee.rawRegistration)}
                        className="min-h-[44px] sm:min-h-[36px] h-11 sm:h-9 px-2 text-xs text-primary hover:bg-primary/10 rounded-md cursor-pointer"
                      >
                        <Eye className="w-3.5 h-3.5" />
                      </Button>
                    </div>
                  </div>
                ))}
                {unassignedAttendees.length > 30 && (
                  <div className="p-3 text-center text-xs text-zinc-500 bg-zinc-50 dark:bg-zinc-800/30">
                    Mostrando os primeiros 30 de {unassignedAttendees.length} participantes sem equipe. Utilize a busca acima para filtrar.
                  </div>
                )}
              </div>
            )}
          </div>
        )}
      </div>

      {/* 6. Modal: Atribuir Voluntário */}
      <Dialog open={isAssignModalOpen} onOpenChange={setIsAssignModalOpen}>
        <DialogContent className="max-w-md">
          <DialogHeader>
            <DialogTitle className="text-base font-bold text-zinc-900 dark:text-zinc-50 flex items-center gap-2">
              <Users className="w-4 h-4 text-primary" />
              Atribuir Irmão(ã) a Equipe de Serviço
            </DialogTitle>
            <DialogDescription className="text-xs text-zinc-500">
              Selecione um participante inscrito no encontro para escalar na equipe de serviço.
            </DialogDescription>
          </DialogHeader>

          <div className="space-y-4 py-3">
            <div className="space-y-1.5">
              <label className="text-xs font-semibold text-zinc-700 dark:text-zinc-300">
                Selecione o Discípulo / Participante
              </label>
              <Select
                value={selectedAttendeeToAssign}
                onValueChange={setSelectedAttendeeToAssign}
              >
                <SelectTrigger className="min-h-[44px] h-11 text-xs">
                  <SelectValue placeholder="Escolha um participante..." />
                </SelectTrigger>
                <SelectContent className="max-h-[280px]">
                  {normalizedAttendees.map((attendee) => {
                    const currentTeam = getServiceTeam(attendee.serviceTeam);
                    return (
                      <SelectItem key={attendee.id} value={attendee.id}>
                        {attendee.name} {currentTeam ? `(Atual: ${currentTeam.shortLabel})` : "(Sem equipe)"}
                      </SelectItem>
                    );
                  })}
                </SelectContent>
              </Select>
            </div>

            <div className="space-y-1.5">
              <label className="text-xs font-semibold text-zinc-700 dark:text-zinc-300">
                Equipe de Serviço Designada
              </label>
              <Select
                value={selectedTeamToAssign}
                onValueChange={setSelectedTeamToAssign}
              >
                <SelectTrigger className="min-h-[44px] h-11 text-xs">
                  <SelectValue placeholder="Escolha a equipe..." />
                </SelectTrigger>
                <SelectContent>
                  {SERVICE_TEAMS.map((t) => (
                    <SelectItem key={t.id} value={t.id}>
                      {t.label}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>
          </div>

          <DialogFooter className="gap-2">
            <Button
              variant="outline"
              onClick={() => setIsAssignModalOpen(false)}
              className="min-h-[44px] h-11 text-xs cursor-pointer"
            >
              Cancelar
            </Button>
            <Button
              disabled={isSubmittingAssign || !selectedAttendeeToAssign}
              onClick={handleAssignSubmit}
              className="min-h-[44px] h-11 text-xs font-bold cursor-pointer bg-primary text-primary-foreground hover:bg-primary/90"
            >
              {isSubmittingAssign ? "Salvando..." : "Confirmar Escala"}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}
