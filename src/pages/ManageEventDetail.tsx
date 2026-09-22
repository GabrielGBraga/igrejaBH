import { useEffect, useState, useCallback, useMemo } from "react";
import { useParams, useNavigate } from "react-router-dom";
import {
  ArrowLeft,
  Calendar,
  MapPin,
  FileText,
  Edit,
  Trash2,
  CheckCircle2,
  Users,
  Bed,
  DollarSign,
  BarChart3,
  Loader2,
  AlertTriangle,
  PieChart,
} from "lucide-react";
import { toast } from "sonner";
import supabase from "@/lib/supabase";
import { calculateTotalPrice, type FormField } from "@/lib/forms";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Card } from "@/components/ui/card";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogDescription,
  DialogFooter,
} from "@/components/ui/dialog";
import { KPIBoard } from "@/components/events/KPIBoard";
import { FilterBuilder } from "@/components/events/FilterBuilder";
import { EventDataTable } from "@/components/events/EventDataTable";
import { CreateEditEventDialog } from "@/components/events/CreateEditEventDialog";
import {
  RegistrationDetailDialog,
  type RegistrationWithDetails,
} from "@/components/events/RegistrationDetailDialog";
import {
  RoomManagementTab,
  type RetreatRoom,
} from "@/components/events/RoomManagementTab";
import {
  EventFinanceTab,
} from "@/components/events/EventFinanceTab";
import type { Database } from "@/lib/database.types";
import type { FilterRule, FilterLogic } from "@/types/eventsFilter";
import {
  DEFAULT_KPI_CONFIGS,
  aggregateKpis,
  type ContextMeta,
} from "@/lib/kpiAggregator";
import {
  filterRegistrationsClientSide,
  buildSupabaseRegistrationsQuery,
} from "@/lib/eventsQueryBuilder";

type Retreat = Database["public"]["Tables"]["retreats"]["Row"] & {
  forms?: {
    name: string;
  } | null;
};

interface FormOption {
  id: string;
  name: string;
}

interface FormTemplateShape {
  id: string;
  name: string;
  fields?: FormField[];
}

interface GuestDataShape {
  full_name?: string;
  email?: string;
  phone?: string;
  cpf?: string;
  gender?: string;
}

export default function ManageEventDetail() {
  const { eventId } = useParams<{ eventId: string }>();
  const navigate = useNavigate();

  const [retreat, setRetreat] = useState<Retreat | null>(null);
  const [registrations, setRegistrations] = useState<RegistrationWithDetails[]>([]);
  const [retreatRooms, setRetreatRooms] = useState<RetreatRoom[]>([]);
  const [selectedFormTemplate, setSelectedFormTemplate] = useState<FormTemplateShape | null>(null);
  const [forms, setForms] = useState<FormOption[]>([]);

  // Loading states
  const [loadingRetreat, setLoadingRetreat] = useState(true);
  const [loadingRegistrations, setLoadingRegistrations] = useState(false);
  const [loadingRooms, setLoadingRooms] = useState(false);

  // Active tab state
  const [activeTab, setActiveTab] = useState<
    "registrations" | "rooms" | "finance" | "dashboard"
  >("registrations");

  // Dialog & Modal states
  const [isEditEventOpen, setIsEditEventOpen] = useState(false);
  const [selectedRegistrationForDetail, setSelectedRegistrationForDetail] =
    useState<RegistrationWithDetails | null>(null);
  const [selectedRegistrationForRoomModal, setSelectedRegistrationForRoomModal] =
    useState<RegistrationWithDetails | null>(null);

  // Dynamic Filter Builder states
  const [filterRules, setFilterRules] = useState<FilterRule[]>([]);
  const [filterLogic, setFilterLogic] = useState<FilterLogic>("AND");
  const [loadingFilterQuery, setLoadingFilterQuery] = useState(false);

  // Table-level filtered attendee records
  const [tableFilteredRegistrations, setTableFilteredRegistrations] = useState<
    RegistrationWithDetails[]
  >([]);

  // Apply client-side filters reactively whenever filterRules, filterLogic, or raw registrations change
  const activeFilteredRegistrations = useMemo(() => {
    return filterRegistrationsClientSide(registrations, filterRules, filterLogic);
  }, [registrations, filterRules, filterLogic]);

  // Keep tableFilteredRegistrations in sync with activeFilteredRegistrations
  useEffect(() => {
    setTableFilteredRegistrations(activeFilteredRegistrations);
  }, [activeFilteredRegistrations]);

  const handleApplyFilters = async () => {
    if (!eventId || filterRules.length === 0) {
      return;
    }

    setLoadingFilterQuery(true);
    try {
      // Map to Supabase JavaScript client query modifiers
      const query = buildSupabaseRegistrationsQuery(eventId, filterRules);
      const { data, error } = await query;
      if (error) throw error;
      if (data) {
        toast.success(
          `Filtro aplicado: ${data.length} de ${registrations.length} participantes encontrados.`
        );
      }
    } catch (err: unknown) {
      console.warn("Consulta no Supabase completada com fallback cliente:", err);
    } finally {
      setLoadingFilterQuery(false);
    }
  };

  const handleClearFilters = () => {
    setFilterRules([]);
    toast.info("Filtros limpos");
  };

  const fetchFormTemplate = useCallback(async (formId: string) => {
    try {
      const { data, error } = await supabase
        .from("forms")
        .select("*")
        .eq("id", formId)
        .single();
      if (error) throw error;
      setSelectedFormTemplate(data as unknown as FormTemplateShape);
    } catch (err: unknown) {
      const msg = err instanceof Error ? err.message : "Erro desconhecido";
      console.error("Erro ao carregar template da ficha:", msg);
      setSelectedFormTemplate(null);
    }
  }, []);

  const fetchRetreatDetails = useCallback(async (id: string) => {
    setLoadingRetreat(true);
    try {
      const { data, error } = await supabase
        .from("retreats")
        .select(`
          *,
          forms (
            name
          )
        `)
        .eq("id", id)
        .single();

      if (error) throw error;
      setRetreat(data);

      if (data?.form_id) {
        fetchFormTemplate(data.form_id);
      }
    } catch (err: unknown) {
      const msg = err instanceof Error ? err.message : "Erro ao carregar evento";
      toast.error(msg);
    } finally {
      setLoadingRetreat(false);
    }
  }, [fetchFormTemplate]);

  const fetchForms = useCallback(async () => {
    try {
      const { data, error } = await supabase
        .from("forms")
        .select("id, name")
        .order("name", { ascending: true });
      if (error) throw error;
      setForms(data || []);
    } catch (err: unknown) {
      const msg = err instanceof Error ? err.message : "Erro desconhecido";
      console.error("Erro ao buscar formulários:", msg);
    }
  }, []);

  const fetchRegistrations = useCallback(async (id: string) => {
    setLoadingRegistrations(true);
    try {
      const { data, error } = await supabase
        .from("registrations")
        .select(`
          *,
          profiles (
            full_name,
            email,
            phone,
            cpf
          ),
          retreat_rooms (
            id,
            name,
            gender_type,
            capacity
          )
        `)
        .eq("retreat_id", id)
        .order("created_at", { ascending: false });

      if (error) throw error;
      setRegistrations(data || []);
    } catch (err: unknown) {
      const msg = err instanceof Error ? err.message : "Erro ao carregar inscrições";
      toast.error(msg);
    } finally {
      setLoadingRegistrations(false);
    }
  }, []);

  const fetchRetreatRooms = useCallback(async (id: string) => {
    setLoadingRooms(true);
    try {
      const { data, error } = await supabase
        .from("retreat_rooms")
        .select("*")
        .eq("retreat_id", id)
        .order("name", { ascending: true });

      if (error) throw error;
      setRetreatRooms(data || []);
    } catch (err: unknown) {
      const msg = err instanceof Error ? err.message : "Erro ao carregar quartos";
      console.error(msg);
    } finally {
      setLoadingRooms(false);
    }
  }, []);

  useEffect(() => {
    if (eventId) {
      fetchRetreatDetails(eventId);
      fetchRegistrations(eventId);
      fetchRetreatRooms(eventId);
      fetchForms();
    }
  }, [eventId, fetchRetreatDetails, fetchRegistrations, fetchRetreatRooms, fetchForms]);

  // Toggle Payment Status
  const handleTogglePayment = async (reg: RegistrationWithDetails) => {
    const nextPaid = !reg.paid;
    try {
      const { error } = await supabase
        .from("registrations")
        .update({
          paid: nextPaid,
          payment_method: nextPaid ? reg.payment_method || "pix" : null,
          payment_reference: nextPaid
            ? reg.payment_reference || "Confirmado pela liderança"
            : null,
        })
        .eq("id", reg.id);

      if (error) throw error;

      setRegistrations((prev) =>
        prev.map((item) =>
          item.id === reg.id
            ? {
                ...item,
                paid: nextPaid,
                payment_method: nextPaid ? reg.payment_method || "pix" : null,
                payment_reference: nextPaid
                  ? reg.payment_reference || "Confirmado pela liderança"
                  : null,
              }
            : item
        )
      );

      if (selectedRegistrationForDetail?.id === reg.id) {
        setSelectedRegistrationForDetail((prev) =>
          prev
            ? {
                ...prev,
                paid: nextPaid,
                payment_method: nextPaid ? reg.payment_method || "pix" : null,
                payment_reference: nextPaid
                  ? reg.payment_reference || "Confirmado pela liderança"
                  : null,
              }
            : null
        );
      }

      toast.success(
        `Inscrição marcada como ${nextPaid ? "paga" : "pendente"}!`
      );
    } catch (err: unknown) {
      const msg = err instanceof Error ? err.message : "Erro ao atualizar pagamento";
      toast.error(msg);
    }
  };

  // Assign Room to a Specific Registration
  const handleAssignRoom = async (regId: string, roomId: string | null) => {
    try {
      const targetRoom = retreatRooms.find((r) => r.id === roomId);
      const { error } = await supabase
        .from("registrations")
        .update({
          room_id: roomId,
          room_allocation: targetRoom ? targetRoom.name : null,
        })
        .eq("id", regId);

      if (error) throw error;

      toast.success("Quarto atualizado com sucesso!");
      if (eventId) {
        fetchRegistrations(eventId);
        fetchRetreatRooms(eventId);
      }
      setSelectedRegistrationForRoomModal(null);
    } catch (err: unknown) {
      const msg = err instanceof Error ? err.message : "Erro ao atribuir quarto";
      toast.error(msg);
    }
  };

  // Delete Registration
  const handleDeleteRegistration = async (reg: RegistrationWithDetails) => {
    if (
      !confirm("Tem certeza que deseja excluir permanentemente esta inscrição?")
    )
      return;

    try {
      const deletingToastId = toast.loading("Excluindo inscrição...");

      if (reg.form_submission_id) {
        const { error } = await supabase
          .from("form_submissions")
          .delete()
          .eq("id", reg.form_submission_id);

        if (error) throw error;
      } else {
        const { error } = await supabase
          .from("registrations")
          .delete()
          .eq("id", reg.id);

        if (error) throw error;
      }

      toast.dismiss(deletingToastId);
      toast.success("Inscrição excluída com sucesso!");

      setRegistrations((prev) => prev.filter((item) => item.id !== reg.id));
      if (selectedRegistrationForDetail?.id === reg.id) {
        setSelectedRegistrationForDetail(null);
      }
    } catch (err: unknown) {
      const msg = err instanceof Error ? err.message : "Erro ao excluir inscrição";
      toast.error(msg);
    }
  };

  // Activate Draft Event
  const handleActivateEvent = async () => {
    if (!retreat) return;
    try {
      const { error } = await supabase
        .from("retreats")
        .update({ status: "ativo" })
        .eq("id", retreat.id);

      if (error) throw error;

      toast.success("Evento ativado e publicado com sucesso!");
      setRetreat((prev) => (prev ? { ...prev, status: "ativo" } : null));
    } catch (err: unknown) {
      const msg = err instanceof Error ? err.message : "Erro ao ativar evento";
      toast.error(msg);
    }
  };

  // Delete Event
  const handleDeleteEvent = async () => {
    if (!retreat) return;
    if (
      !confirm(
        "Tem certeza que deseja excluir permanentemente este retiro e todas as inscrições?"
      )
    )
      return;

    try {
      const { error } = await supabase
        .from("retreats")
        .delete()
        .eq("id", retreat.id);

      if (error) throw error;
      toast.success("Evento excluído com sucesso!");
      navigate("/manage-events");
    } catch (err: unknown) {
      const msg = err instanceof Error ? err.message : "Erro ao excluir evento";
      toast.error(msg);
    }
  };

  // Helper to extract gender
  const getParticipantGender = (reg: RegistrationWithDetails): string => {
    const customResps = reg.custom_responses as Record<string, unknown> | null;
    const guestData = reg.guest_data as GuestDataShape | null;

    if (customResps) {
      for (const [key, val] of Object.entries(customResps)) {
        if (
          key.toLowerCase().includes("gênero") ||
          key.toLowerCase().includes("genero") ||
          key.toLowerCase().includes("sexo")
        ) {
          const valStr = String(val).toLowerCase();
          if (valStr.includes("masculino") || valStr === "m" || valStr.includes("homem"))
            return "masculino";
          if (valStr.includes("feminino") || valStr === "f" || valStr.includes("mulher"))
            return "feminino";
        }
      }
    }
    if (guestData?.gender) {
      const gStr = String(guestData.gender).toLowerCase();
      if (gStr.includes("masculino") || gStr === "m" || gStr.includes("homem"))
        return "masculino";
      if (gStr.includes("feminino") || gStr === "f" || gStr.includes("mulher"))
        return "feminino";
    }
    return "indefinido";
  };

  // Export Data to JSON
  const handleExportData = () => {
    if (!retreat || registrations.length === 0) {
      toast.error("Não há dados de inscrições para exportar.");
      return;
    }

    const dataToExport = registrations.map((reg) => {
      const guest = reg.guest_data as GuestDataShape | null;
      return {
        Participante:
          reg.profiles?.full_name || guest?.full_name || "Desconhecido",
        Email: reg.profiles?.email || guest?.email || "",
        Telefone: reg.profiles?.phone || guest?.phone || "",
        CPF: reg.profiles?.cpf || guest?.cpf || "",
        Pago: reg.paid ? "Sim" : "Não",
        MetodoPagamento: reg.payment_method || "",
        ReferenciaPagamento: reg.payment_reference || "",
        Alojamento:
          reg.retreat_rooms?.name || reg.room_allocation || "Não alocado",
        Observacoes: reg.notes || "",
        RespostasCustomizadas: reg.custom_responses || {},
        DataInscricao: reg.created_at,
      };
    });

    const blob = new Blob([JSON.stringify(dataToExport, null, 2)], {
      type: "application/json",
    });
    const url = URL.createObjectURL(blob);
    const link = document.createElement("a");
    link.href = url;
    link.download = `inscricoes_${retreat.title
      .toLowerCase()
      .replace(/\s+/g, "_")}.json`;
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
    URL.revokeObjectURL(url);
    toast.success("Dados exportados com sucesso!");
  };

  // Helper to calculate price of a registration
  const getRegPrice = useCallback(
    (reg: RegistrationWithDetails): number => {
      let price = retreat?.price || 0;
      if (retreat?.form_id && selectedFormTemplate) {
        const customResps = reg.custom_responses as Record<string, unknown> | null;
        if (customResps) {
          const idResponses: Record<string, unknown> = {};
          selectedFormTemplate.fields?.forEach((field) => {
            const val = customResps[field.label];
            if (val !== undefined) idResponses[field.id] = val;
          });
          price = calculateTotalPrice(
            retreat.price || 0,
            selectedFormTemplate.fields || [],
            idResponses
          );
        }
      }
      return price;
    },
    [retreat?.price, retreat?.form_id, selectedFormTemplate]
  );

  const totalBeds = useMemo(
    () => retreatRooms.reduce((acc, r) => acc + (r.capacity || 0), 0),
    [retreatRooms]
  );

  // Dynamic Context Meta for KPI Builder
  const contextMeta: ContextMeta = useMemo(() => {
    return {
      rawTotalCount: registrations.length,
      basePrice: retreat?.price || 0,
      maxParticipants: retreat?.max_participants || 100,
      totalBeds,
      rooms: retreatRooms,
      calculatePrice: getRegPrice,
    };
  }, [
    registrations.length,
    retreat?.price,
    retreat?.max_participants,
    totalBeds,
    retreatRooms,
    getRegPrice,
  ]);

  // Dynamically computed KPI cards based on the active filtered records
  const computedKpiCards = useMemo(() => {
    return aggregateKpis(tableFilteredRegistrations, DEFAULT_KPI_CONFIGS, contextMeta);
  }, [tableFilteredRegistrations, contextMeta]);

  // Financial & Metrics calculations for secondary tabs based on active filtered dataset
  const totalRegistered = tableFilteredRegistrations.length;

  let totalRevenueConfirmed = 0;
  let totalRevenueEstimated = 0;

  tableFilteredRegistrations.forEach((reg) => {
    const price = getRegPrice(reg);
    totalRevenueEstimated += price;
    if (reg.paid) {
      totalRevenueConfirmed += price;
    }
  });

  const allocatedBedsCount = tableFilteredRegistrations.filter(
    (r) =>
      r.room_id ||
      (r.room_allocation && r.room_allocation !== "Não alocado")
  ).length;
  const unallocatedCount = totalRegistered - allocatedBedsCount;

  const maleCount = tableFilteredRegistrations.filter(
    (r) => getParticipantGender(r) === "masculino"
  ).length;
  const femaleCount = tableFilteredRegistrations.filter(
    (r) => getParticipantGender(r) === "feminino"
  ).length;
  const malePct =
    totalRegistered > 0 ? Math.round((maleCount / totalRegistered) * 100) : 0;
  const femalePct =
    totalRegistered > 0 ? Math.round((femaleCount / totalRegistered) * 100) : 0;

  if (loadingRetreat) {
    return (
      <div className="flex flex-col items-center justify-center min-h-[60vh] gap-3 text-zinc-500">
        <Loader2 className="w-8 h-8 animate-spin text-primary" />
        <p className="text-sm font-medium">Carregando detalhes do evento...</p>
      </div>
    );
  }

  if (!retreat) {
    return (
      <div className="max-w-4xl mx-auto px-4 py-16 text-center space-y-4">
        <AlertTriangle className="w-12 h-12 text-amber-500 mx-auto" />
        <h2 className="text-2xl font-bold text-zinc-900 dark:text-zinc-50">
          Evento não encontrado
        </h2>
        <p className="text-sm text-zinc-500 max-w-md mx-auto">
          O evento que você está tentando acessar não existe ou foi removido.
        </p>
        <Button
          onClick={() => navigate("/manage-events")}
          className="min-h-[44px] cursor-pointer"
        >
          <ArrowLeft className="w-4 h-4 mr-2" /> Voltar para Eventos
        </Button>
      </div>
    );
  }

  const participantGenderInModal = selectedRegistrationForRoomModal
    ? getParticipantGender(selectedRegistrationForRoomModal)
    : "indefinido";

  const eligibleRoomsForParticipant = retreatRooms.filter((room) => {
    if (room.gender_type === "suite") return true;
    if (participantGenderInModal === "indefinido") return true;
    return room.gender_type === participantGenderInModal;
  });

  return (
    <div className="w-full max-w-full px-4 sm:px-6 lg:px-8 py-6 space-y-6">
      {/* Top Navigation & Breadcrumb */}
      <div className="flex items-center justify-between">
        <Button
          variant="ghost"
          onClick={() => navigate("/manage-events")}
          className="min-h-[44px] -ml-2.5 px-3 text-xs font-semibold text-zinc-600 hover:text-zinc-900 dark:text-zinc-400 dark:hover:text-zinc-50 flex items-center gap-2 cursor-pointer"
        >
          <ArrowLeft className="w-4 h-4" />
          <span>Voltar para Eventos</span>
        </Button>
      </div>

      {/* Main Header Banner */}
      <div className="bg-white dark:bg-zinc-900 border border-zinc-200 dark:border-zinc-800 rounded-2xl p-5 sm:p-6 shadow-sm flex flex-col md:flex-row md:items-center justify-between gap-5">
        <div className="space-y-2 min-w-0">
          <div className="flex items-center gap-3 flex-wrap">
            <h1 className="text-xl sm:text-2xl lg:text-3xl font-extrabold text-zinc-900 dark:text-zinc-50 tracking-tight truncate">
              {retreat.title}
            </h1>
            <Badge
              variant="outline"
              className={`text-[10px] font-bold uppercase tracking-wide px-2.5 py-0.5 ${
                retreat.status === "ativo"
                  ? "bg-emerald-500/10 text-emerald-600 dark:text-emerald-400 border-emerald-500/30"
                  : retreat.status === "rascunho"
                  ? "bg-amber-500/10 text-amber-600 dark:text-amber-400 border-amber-500/30"
                  : "bg-zinc-500/10 text-zinc-600 dark:text-zinc-400 border-zinc-500/30"
              }`}
            >
              {retreat.status}
            </Badge>
          </div>

          {retreat.description && (
            <p className="text-xs sm:text-sm text-zinc-500 dark:text-zinc-400 line-clamp-2 max-w-4xl leading-relaxed">
              {retreat.description}
            </p>
          )}

          <div className="flex flex-wrap gap-4 text-xs text-zinc-500 dark:text-zinc-400 pt-1">
            <div className="flex items-center gap-1.5">
              <Calendar className="w-3.5 h-3.5 text-zinc-400 shrink-0" />
              <span>
                {retreat.start_date
                  ? new Date(retreat.start_date).toLocaleDateString("pt-BR")
                  : "S/D"}{" "}
                até{" "}
                {retreat.end_date
                  ? new Date(retreat.end_date).toLocaleDateString("pt-BR")
                  : "S/D"}
              </span>
            </div>

            <div className="flex items-center gap-1.5">
              <MapPin className="w-3.5 h-3.5 text-zinc-400 shrink-0" />
              <span className="truncate max-w-[280px]">
                {retreat.location_text || "Local não informado"}
              </span>
            </div>

            {retreat.forms?.name && (
              <div className="flex items-center gap-1.5 text-primary">
                <FileText className="w-3.5 h-3.5 shrink-0" />
                <span className="font-semibold truncate max-w-[260px]">
                  Ficha: {retreat.forms.name}
                </span>
              </div>
            )}
          </div>
        </div>

        {/* Header Action Buttons */}
        <div className="flex items-center gap-2.5 shrink-0 self-start md:self-auto">
          {retreat.status === "rascunho" && (
            <Button
              onClick={handleActivateEvent}
              className="min-h-[44px] h-10 px-4 rounded-xl bg-emerald-600 hover:bg-emerald-700 text-white font-bold text-xs flex items-center gap-1.5 cursor-pointer shadow-sm"
            >
              <CheckCircle2 className="w-4 h-4" />
              <span>Publicar Retiro</span>
            </Button>
          )}

          <Button
            variant="outline"
            onClick={() => setIsEditEventOpen(true)}
            className="min-h-[44px] h-10 px-4 rounded-xl text-xs font-semibold flex items-center gap-1.5 cursor-pointer"
          >
            <Edit className="w-3.5 h-3.5 text-zinc-500" />
            <span>Editar</span>
          </Button>

          <Button
            variant="ghost"
            onClick={handleDeleteEvent}
            className="min-h-[44px] h-10 px-3 text-red-500 hover:bg-red-500/10 dark:hover:bg-red-500/20 rounded-xl text-xs font-semibold flex items-center gap-1.5 cursor-pointer"
          >
            <Trash2 className="w-3.5 h-3.5" />
            <span className="hidden sm:inline">Excluir</span>
          </Button>
        </div>
      </div>

      {/* Dynamic KPI Cards Row */}
      <KPIBoard
        cards={computedKpiCards}
        isFiltered={
          filterRules.length > 0 ||
          tableFilteredRegistrations.length !== registrations.length
        }
      />

      {/* Navigation Tabs */}
      <div className="flex border-b border-zinc-200 dark:border-zinc-800 overflow-x-auto gap-2">
        <button
          onClick={() => setActiveTab("registrations")}
          className={`min-h-[44px] px-4 py-2.5 text-xs font-bold transition-all border-b-2 whitespace-nowrap cursor-pointer flex items-center gap-2 ${
            activeTab === "registrations"
              ? "border-primary text-primary"
              : "border-transparent text-zinc-500 hover:text-zinc-900 dark:hover:text-zinc-50"
          }`}
        >
          <Users className="w-4 h-4" />
          <span>Inscrições ({registrations.length})</span>
        </button>

        <button
          onClick={() => setActiveTab("rooms")}
          className={`min-h-[44px] px-4 py-2.5 text-xs font-bold transition-all border-b-2 whitespace-nowrap cursor-pointer flex items-center gap-2 ${
            activeTab === "rooms"
              ? "border-primary text-primary"
              : "border-transparent text-zinc-500 hover:text-zinc-900 dark:hover:text-zinc-50"
          }`}
        >
          <Bed className="w-4 h-4" />
          <span>Divisão de Quartos</span>
        </button>

        <button
          onClick={() => setActiveTab("finance")}
          className={`min-h-[44px] px-4 py-2.5 text-xs font-bold transition-all border-b-2 whitespace-nowrap cursor-pointer flex items-center gap-2 ${
            activeTab === "finance"
              ? "border-primary text-primary"
              : "border-transparent text-zinc-500 hover:text-zinc-900 dark:hover:text-zinc-50"
          }`}
        >
          <DollarSign className="w-4 h-4" />
          <span>Controle Financeiro</span>
        </button>

        <button
          onClick={() => setActiveTab("dashboard")}
          className={`min-h-[44px] px-4 py-2.5 text-xs font-bold transition-all border-b-2 whitespace-nowrap cursor-pointer flex items-center gap-2 ${
            activeTab === "dashboard"
              ? "border-primary text-primary"
              : "border-transparent text-zinc-500 hover:text-zinc-900 dark:hover:text-zinc-50"
          }`}
        >
          <BarChart3 className="w-4 h-4" />
          <span>Dashboard Analítico</span>
        </button>
      </div>

      {/* Tab 1: Inscrições com Construtor de Filtros e TanStack Data Table */}
      {activeTab === "registrations" && (
        <div className="space-y-4">
          <FilterBuilder
            rules={filterRules}
            logic={filterLogic}
            retreatRooms={retreatRooms}
            totalRawCount={registrations.length}
            filteredCount={activeFilteredRegistrations.length}
            isLoading={loadingFilterQuery}
            onRulesChange={setFilterRules}
            onLogicChange={setFilterLogic}
            onApplyFilters={handleApplyFilters}
            onClearFilters={handleClearFilters}
          />

          <EventDataTable
            data={activeFilteredRegistrations}
            isLoading={loadingRegistrations}
            onViewDetails={(reg) => setSelectedRegistrationForDetail(reg)}
            onTogglePayment={handleTogglePayment}
            onAssignRoomClick={(reg) => setSelectedRegistrationForRoomModal(reg)}
            onDeleteRegistration={handleDeleteRegistration}
            onExportData={handleExportData}
            onFilteredDataChange={setTableFilteredRegistrations}
          />
        </div>
      )}

      {/* Tab 2: Divisão de Quartos */}
      {activeTab === "rooms" && (
        <RoomManagementTab
          retreatId={retreat.id}
          registrations={registrations}
          onRefreshRegistrations={() => {
            fetchRegistrations(retreat.id);
            fetchRetreatRooms(retreat.id);
          }}
        />
      )}

      {/* Tab 3: Controle Financeiro */}
      {activeTab === "finance" && (
        <EventFinanceTab
          retreatId={retreat.id}
          totalIncome={totalRevenueConfirmed}
          pendingIncome={Math.max(0, totalRevenueEstimated - totalRevenueConfirmed)}
        />
      )}

      {/* Tab 4: Dashboard Analítico */}
      {activeTab === "dashboard" && (
        <div className="space-y-6">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            {/* Card: Distribuição por Gênero */}
            <Card className="rounded-xl border border-zinc-200 dark:border-zinc-800 bg-white dark:bg-zinc-900 p-5 shadow-sm">
              <h4 className="text-sm font-bold text-zinc-900 dark:text-zinc-50 mb-5 flex items-center gap-2">
                <PieChart className="w-4 h-4 text-primary" />
                <span>Distribuição por Gênero</span>
              </h4>

              <div className="space-y-5">
                <div>
                  <div className="flex justify-between text-xs font-semibold mb-1.5">
                    <span className="text-zinc-700 dark:text-zinc-300">
                      Homens (Masculino)
                    </span>
                    <span className="font-extrabold text-zinc-900 dark:text-zinc-50">
                      {maleCount} ({malePct}%)
                    </span>
                  </div>
                  <div className="w-full bg-zinc-100 dark:bg-zinc-800 rounded-full h-3 overflow-hidden p-0.5 border border-zinc-200 dark:border-zinc-700">
                    <div
                      className="bg-blue-600 h-full rounded-full transition-all duration-500"
                      style={{ width: `${malePct}%` }}
                    />
                  </div>
                </div>

                <div>
                  <div className="flex justify-between text-xs font-semibold mb-1.5">
                    <span className="text-zinc-700 dark:text-zinc-300">
                      Mulheres (Feminino)
                    </span>
                    <span className="font-extrabold text-zinc-900 dark:text-zinc-50">
                      {femaleCount} ({femalePct}%)
                    </span>
                  </div>
                  <div className="w-full bg-zinc-100 dark:bg-zinc-800 rounded-full h-3 overflow-hidden p-0.5 border border-zinc-200 dark:border-zinc-700">
                    <div
                      className="bg-pink-500 h-full rounded-full transition-all duration-500"
                      style={{ width: `${femalePct}%` }}
                    />
                  </div>
                </div>
              </div>
            </Card>

            {/* Card: Status dos Alojamentos */}
            <Card className="rounded-xl border border-zinc-200 dark:border-zinc-800 bg-white dark:bg-zinc-900 p-5 shadow-sm">
              <h4 className="text-sm font-bold text-zinc-900 dark:text-zinc-50 mb-5 flex items-center justify-between">
                <span className="flex items-center gap-2">
                  <Bed className="w-4 h-4 text-primary" />
                  <span>Status dos Alojamentos</span>
                </span>
                <span className="text-xs font-bold text-zinc-500 dark:text-zinc-400">
                  {allocatedBedsCount} / {totalBeds} Camas ({unallocatedCount} sem quarto)
                </span>
              </h4>

              <div className="space-y-3.5 max-h-56 overflow-y-auto pr-1">
                {retreatRooms.length === 0 ? (
                  <p className="text-xs text-zinc-400 italic text-center py-6">
                    Nenhum quarto cadastrado neste retiro.
                  </p>
                ) : (
                  retreatRooms.map((room) => {
                    const occupants = registrations.filter(
                      (r) =>
                        r.room_id === room.id || r.room_allocation === room.name
                    ).length;
                    const roomPct = Math.min(
                      100,
                      Math.round((occupants / room.capacity) * 100)
                    );
                    const isFull = occupants >= room.capacity;

                    return (
                      <div
                        key={room.id}
                        className="space-y-1.5 bg-zinc-50 dark:bg-zinc-800/50 p-3 rounded-xl border border-zinc-200/60 dark:border-zinc-800"
                      >
                        <div className="flex justify-between items-center text-xs">
                          <span className="font-bold text-zinc-900 dark:text-zinc-50 flex items-center gap-2">
                            {room.name}
                            <Badge
                              variant="outline"
                              className={`text-[9px] font-black uppercase px-1.5 py-0 ${
                                room.gender_type === "masculino"
                                  ? "bg-blue-500/10 text-blue-600 dark:text-blue-400 border-blue-500/30"
                                  : room.gender_type === "feminino"
                                  ? "bg-pink-500/10 text-pink-600 dark:text-pink-400 border-pink-500/30"
                                  : "bg-purple-500/10 text-purple-600 dark:text-purple-400 border-purple-500/30"
                              }`}
                            >
                              {room.gender_type}
                            </Badge>
                          </span>
                          <span
                            className={`text-[11px] font-extrabold ${
                              isFull
                                ? "text-emerald-600 dark:text-emerald-400"
                                : "text-zinc-500 dark:text-zinc-400"
                            }`}
                          >
                            {occupants} / {room.capacity} camas {isFull && "(Lotado)"}
                          </span>
                        </div>
                        <div className="w-full bg-zinc-200 dark:bg-zinc-700 rounded-full h-2 overflow-hidden">
                          <div
                            className={`h-full rounded-full transition-all duration-500 ${
                              isFull ? "bg-emerald-500" : "bg-primary"
                            }`}
                            style={{ width: `${roomPct}%` }}
                          />
                        </div>
                      </div>
                    );
                  })
                )}
              </div>
            </Card>
          </div>
        </div>
      )}

      {/* Modal: Alocar Quarto para Inscrito Específico */}
      {selectedRegistrationForRoomModal && (
        <Dialog
          open={!!selectedRegistrationForRoomModal}
          onOpenChange={(open) => !open && setSelectedRegistrationForRoomModal(null)}
        >
          <DialogContent className="sm:max-w-md max-w-full rounded-2xl border border-zinc-200 dark:border-zinc-800 bg-white dark:bg-zinc-900 p-6">
            <DialogHeader>
              <DialogTitle className="text-lg font-bold text-zinc-900 dark:text-zinc-50 flex items-center gap-2">
                <Bed className="w-5 h-5 text-primary" />
                Alocar Quarto para Participante
              </DialogTitle>
              <DialogDescription className="text-xs text-zinc-500 dark:text-zinc-400">
                Selecione o alojamento desejado para{" "}
                <strong>
                  {selectedRegistrationForRoomModal.profiles?.full_name ||
                    (selectedRegistrationForRoomModal.guest_data as GuestDataShape)?.full_name ||
                    "Participante"}
                </strong>
                .
              </DialogDescription>
            </DialogHeader>

            <div className="space-y-4 py-2">
              <div className="bg-zinc-50 dark:bg-zinc-800/60 border border-zinc-200 dark:border-zinc-700 p-3 rounded-xl text-xs space-y-1.5">
                <div className="flex justify-between items-center">
                  <span className="text-zinc-500">Quarto Atual:</span>
                  <span className="font-bold text-zinc-900 dark:text-zinc-50 flex items-center gap-1.5">
                    <Bed className="w-3.5 h-3.5 text-primary" />
                    {selectedRegistrationForRoomModal.retreat_rooms?.name ||
                      selectedRegistrationForRoomModal.room_allocation ||
                      "Não alocado"}
                  </span>
                </div>
                {participantGenderInModal !== "indefinido" && (
                  <div className="flex justify-between items-center border-t border-zinc-200 dark:border-zinc-700 pt-1.5 text-[11px]">
                    <span className="text-zinc-500">Filtro de Gênero:</span>
                    <span className="font-bold text-zinc-900 dark:text-zinc-100 capitalize">
                      Quartos {participantGenderInModal}s ou Suítes
                    </span>
                  </div>
                )}
              </div>

              {loadingRooms ? (
                <div className="text-center py-4 text-xs text-zinc-500 flex items-center justify-center gap-2">
                  <Loader2 className="w-4 h-4 animate-spin" /> Carregando quartos do evento...
                </div>
              ) : eligibleRoomsForParticipant.length === 0 ? (
                <div className="text-center py-4 text-xs text-amber-600 dark:text-amber-400 bg-amber-500/10 border border-amber-500/20 p-3 rounded-xl">
                  Nenhum quarto compatível ({participantGenderInModal}) com vagas cadastrado
                  neste evento. Crie quartos na aba &quot;Divisão de Quartos&quot;.
                </div>
              ) : (
                <div className="space-y-2 max-h-[240px] overflow-y-auto pr-1">
                  {eligibleRoomsForParticipant.map((room) => {
                    const occupantsCount = registrations.filter(
                      (r) =>
                        r.room_id === room.id || r.room_allocation === room.name
                    ).length;
                    const isFull = occupantsCount >= room.capacity;
                    const isCurrentRoom =
                      selectedRegistrationForRoomModal.room_id === room.id ||
                      selectedRegistrationForRoomModal.room_allocation === room.name;

                    return (
                      <div
                        key={room.id}
                        className="flex items-center justify-between text-xs bg-zinc-50 dark:bg-zinc-800/40 border border-zinc-200 dark:border-zinc-700 p-3 rounded-xl"
                      >
                        <div>
                          <span className="font-bold text-zinc-900 dark:text-zinc-50 block">
                            {room.name}
                          </span>
                          <span className="text-[11px] text-zinc-500 block capitalize">
                            {room.gender_type === "suite"
                              ? "Suíte (Casais / Família)"
                              : room.gender_type}{" "}
                            • {occupantsCount}/{room.capacity} camas
                          </span>
                        </div>
                        {isCurrentRoom ? (
                          <Badge
                            variant="outline"
                            className="bg-emerald-500/10 text-emerald-600 dark:text-emerald-400 border-emerald-500/30 text-[10px] uppercase font-bold"
                          >
                            Alocado Aqui
                          </Badge>
                        ) : (
                          <Button
                            size="sm"
                            disabled={isFull}
                            onClick={() =>
                              handleAssignRoom(
                                selectedRegistrationForRoomModal.id,
                                room.id
                              )
                            }
                            className="min-h-[36px] h-9 text-xs rounded-lg cursor-pointer"
                          >
                            Selecionar
                          </Button>
                        )}
                      </div>
                    );
                  })}
                </div>
              )}
            </div>

            <DialogFooter className="flex justify-between items-center pt-2">
              {selectedRegistrationForRoomModal.room_id ||
              selectedRegistrationForRoomModal.room_allocation ? (
                <Button
                  type="button"
                  variant="outline"
                  onClick={() =>
                    handleAssignRoom(selectedRegistrationForRoomModal.id, null)
                  }
                  className="min-h-[44px] text-red-500 hover:bg-red-500/10 border-red-500/30 text-xs cursor-pointer"
                >
                  Remover do Quarto
                </Button>
              ) : (
                <div />
              )}
              <Button
                type="button"
                variant="secondary"
                onClick={() => setSelectedRegistrationForRoomModal(null)}
                className="min-h-[44px] cursor-pointer"
              >
                Cancelar
              </Button>
            </DialogFooter>
          </DialogContent>
        </Dialog>
      )}

      {/* Modal: Detalhes da Inscrição */}
      <RegistrationDetailDialog
        registration={selectedRegistrationForDetail}
        isOpen={!!selectedRegistrationForDetail}
        onClose={() => setSelectedRegistrationForDetail(null)}
        onTogglePayment={handleTogglePayment}
      />

      {/* Modal: Editar Evento */}
      <CreateEditEventDialog
        isOpen={isEditEventOpen}
        onOpenChange={setIsEditEventOpen}
        retreat={retreat}
        forms={forms}
        onSuccess={() => {
          if (eventId) fetchRetreatDetails(eventId);
        }}
      />
    </div>
  );
}
