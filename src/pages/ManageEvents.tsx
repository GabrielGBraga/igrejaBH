import { useEffect, useState } from "react";
import supabase from "@/lib/supabase";
import { calculateTotalPrice, ensureMandatoryEventFields } from "@/lib/forms";
import { 
  Calendar, 
  Edit, 
  Plus, 
  Trash2, 
  Loader2, 
  DollarSign, 
  Users, 
  Bed, 
  Check, 
  X, 
  Download, 
  FileText, 
  AlertTriangle,
  MapPin,
  Clock,
  BarChart3,
  Eye,
  Info,
  PieChart,
  TrendingUp,
  TrendingDown
} from "lucide-react";
import { Card, CardContent } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import { Textarea } from "@/components/ui/textarea";
import { 
  Dialog, 
  DialogContent, 
  DialogHeader, 
  DialogTitle, 
  DialogDescription,
  DialogFooter
} from "@/components/ui/dialog";
import { Field, FieldLabel, FieldError } from "@/components/ui/field";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Badge } from "@/components/ui/badge";
import { Tooltip, TooltipContent, TooltipProvider, TooltipTrigger } from "@/components/ui/tooltip";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { useForm, Controller } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import * as z from "zod";
import { toast } from "sonner";
import type { Database } from "@/lib/database.types";
import { RegistrationDetailDialog, type RegistrationWithDetails } from "@/components/events/RegistrationDetailDialog";
import { RoomManagementTab, type RetreatRoom } from "@/components/events/RoomManagementTab";
import { EventFinanceTab } from "@/components/events/EventFinanceTab";

type Retreat = Database["public"]["Tables"]["retreats"]["Row"] & {
  forms?: {
    name: string;
  } | null;
};

interface FormOption {
  id: string;
  name: string;
}

// Zod Schema para cadastrar/editar Retiro
const retreatFormSchema = z.object({
  title: z.string().min(3, { message: "O título deve ter pelo menos 3 caracteres." }),
  description: z.string().default(""),
  price: z.preprocess((val) => (val === "" || val === undefined ? 0 : Number(val)), z.number().min(0, { message: "O preço deve ser igual ou maior que zero." })),
  location_text: z.string().default(""),
  start_date: z
    .string()
    .min(1, { message: "A data de início é obrigatória." })
    .regex(/^\d{4}-\d{2}-\d{2}$/, { message: "Formato de data inválido (AAAA-MM-DD)." }),
  end_date: z
    .string()
    .min(1, { message: "A data de término é obrigatória." })
    .regex(/^\d{4}-\d{2}-\d{2}$/, { message: "Formato de data inválido (AAAA-MM-DD)." }),
  max_participants: z.preprocess((val) => (val === "" || val === undefined ? 100 : Number(val)), z.number().min(1, { message: "Deve ter capacidade para pelo menos 1 participante." })),
  status: z.enum(["ativo", "rascunho", "encerrado"] as const),
  form_id: z.string().optional().nullable(),
  registration_deadline: z.string().optional().nullable(),
});

type RetreatFormValues = z.infer<typeof retreatFormSchema>;

export default function ManageEvents() {
  const [retreats, setRetreats] = useState<Retreat[]>([]);
  const [forms, setForms] = useState<FormOption[]>([]);
  const [selectedRetreat, setSelectedRetreat] = useState<Retreat | null>(null);
  const [registrations, setRegistrations] = useState<RegistrationWithDetails[]>([]);
  const [selectedFormTemplate, setSelectedFormTemplate] = useState<any>(null);
  
  // Detail Modal State
  const [selectedRegistrationForDetail, setSelectedRegistrationForDetail] = useState<RegistrationWithDetails | null>(null);

  // Room Modal State for Specific Participant
  const [selectedRegistrationForRoomModal, setSelectedRegistrationForRoomModal] = useState<RegistrationWithDetails | null>(null);
  const [retreatRooms, setRetreatRooms] = useState<RetreatRoom[]>([]);
  const [retreatExpenses, setRetreatExpenses] = useState<any[]>([]);
  const [loadingRooms, setLoadingRooms] = useState(false);

  // Loading states
  const [loadingRetreats, setLoadingRetreats] = useState(true);
  const [loadingRegistrations, setLoadingRegistrations] = useState(false);
  const [submitting, setSubmitting] = useState(false);
  
  // Dialog states
  const [isEventDialogOpen, setIsEventDialogOpen] = useState(false);
  const [editingRetreat, setEditingRetreat] = useState<Retreat | null>(null);
  
  // Active Tab
  const [activeTab, setActiveTab] = useState<"registrations" | "rooms" | "finance" | "dashboard">("registrations");
  
  // Search state
  const [searchTerm, setSearchTerm] = useState("");
  
  // Form Config
  const { control, handleSubmit, reset, setValue } = useForm<RetreatFormValues>({
    resolver: zodResolver(retreatFormSchema) as any,
    defaultValues: {
      title: "",
      description: "",
      price: "" as any,
      location_text: "",
      start_date: "",
      end_date: "",
      max_participants: "" as any,
      status: "ativo",
      form_id: "",
      registration_deadline: "",
    }
  });

  // Fetch initial data
  useEffect(() => {
    fetchRetreats();
    fetchForms();
  }, []);

  // Fetch registrations when selectedRetreat or activeTab changes
  useEffect(() => {
    if (selectedRetreat) {
      fetchRegistrations(selectedRetreat.id);
      fetchRetreatRooms(selectedRetreat.id);
      fetchRetreatExpenses(selectedRetreat.id);
      if (selectedRetreat.form_id) {
        fetchFormTemplate(selectedRetreat.form_id);
      } else {
        setSelectedFormTemplate(null);
      }
    } else {
      setRegistrations([]);
      setRetreatRooms([]);
      setRetreatExpenses([]);
      setSelectedFormTemplate(null);
    }
  }, [selectedRetreat, activeTab]);

  async function fetchRetreatExpenses(retreatId: string) {
    try {
      const { data, error } = await supabase
        .from("retreat_expenses")
        .select("*")
        .eq("retreat_id", retreatId);
      if (error) throw error;
      setRetreatExpenses(data || []);
    } catch (err: any) {
      console.error("Erro ao buscar despesas do retiro:", err);
      setRetreatExpenses([]);
    }
  }

  async function fetchRetreatRooms(retreatId: string) {
    setLoadingRooms(true);
    try {
      const { data, error } = await supabase
        .from("retreat_rooms")
        .select("*")
        .eq("retreat_id", retreatId)
        .order("name", { ascending: true });
      if (error) throw error;
      setRetreatRooms(data || []);
    } catch (err: any) {
      console.error("Erro ao buscar quartos:", err);
    } finally {
      setLoadingRooms(false);
    }
  }

  async function fetchFormTemplate(formId: string) {
    try {
      const { data, error } = await supabase
        .from("forms")
        .select("*")
        .eq("id", formId)
        .single();
      if (error) throw error;
      setSelectedFormTemplate(data);
    } catch (err: any) {
      console.error("Erro ao carregar template do formulário:", err);
      setSelectedFormTemplate(null);
    }
  }

  async function fetchRetreats() {
    setLoadingRetreats(true);
    try {
      const { data, error } = await supabase
        .from("retreats")
        .select(`
          *,
          forms (
            name
          )
        `)
        .order("start_date", { ascending: true });

      if (error) throw error;
      setRetreats(data || []);
      
      if (data && data.length > 0 && !selectedRetreat) {
        setSelectedRetreat(data[0]);
      }
    } catch (err: any) {
      toast.error("Erro ao carregar eventos: " + err.message);
    } finally {
      setLoadingRetreats(false);
    }
  }

  async function fetchForms() {
    try {
      const { data, error } = await supabase
        .from("forms")
        .select("id, name")
        .order("name", { ascending: true });
      if (error) throw error;
      setForms(data || []);
    } catch (err: any) {
      console.error("Erro ao buscar formulários:", err);
    }
  }

  async function fetchRegistrations(retreatId: string) {
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
        .eq("retreat_id", retreatId)
        .order("created_at", { ascending: false });

      if (error) throw error;
      setRegistrations(data || []);
    } catch (err: any) {
      toast.error("Erro ao carregar inscrições: " + err.message);
    } finally {
      setLoadingRegistrations(false);
    }
  }

  // Handle Event submit (Create / Edit)
  const onSubmitEvent = async (data: RetreatFormValues) => {
    setSubmitting(true);
    const payload = {
      title: data.title,
      description: data.description || null,
      price: data.price,
      location_text: data.location_text || null,
      start_date: data.start_date,
      end_date: data.end_date,
      max_participants: data.max_participants,
      status: data.status,
      form_id: data.form_id === "" ? null : data.form_id,
      registration_deadline: data.registration_deadline === "" ? null : data.registration_deadline,
    };

    // Garantir que a ficha selecionada contenha os 6 campos obrigatórios de eventos
    if (payload.form_id) {
      try {
        const { data: dbForm } = await supabase
          .from("forms")
          .select("id, fields")
          .eq("id", payload.form_id)
          .single();

        if (dbForm && dbForm.fields) {
          const updatedFields = ensureMandatoryEventFields(dbForm.fields as any);
          await supabase
            .from("forms")
            .update({ fields: updatedFields as any })
            .eq("id", payload.form_id);
        }
      } catch (fErr) {
        console.error("Erro ao verificar campos obrigatórios no formulário:", fErr);
      }
    }

    try {
      if (editingRetreat) {
        const { error } = await supabase
          .from("retreats")
          .update(payload)
          .eq("id", editingRetreat.id);
        
        if (error) throw error;
        toast.success("Evento atualizado com sucesso!");
      } else {
        const { error } = await supabase
          .from("retreats")
          .insert([payload]);

        if (error) throw error;
        toast.success("Evento criado com sucesso!");
      }
      
      setIsEventDialogOpen(false);
      setEditingRetreat(null);
      reset();
      fetchRetreats();
    } catch (err: any) {
      toast.error("Erro ao salvar evento: " + err.message);
    } finally {
      setSubmitting(false);
    }
  };

  const handleEditEventClick = (retreat: Retreat) => {
    setEditingRetreat(retreat);
    setValue("title", retreat.title);
    setValue("description", retreat.description || "");
    setValue("price", retreat.price || 0);
    setValue("location_text", retreat.location_text || "");
    setValue("start_date", retreat.start_date || "");
    setValue("end_date", retreat.end_date || "");
    setValue("max_participants", retreat.max_participants || 100);
    setValue("status", (retreat.status as any) || "ativo");
    setValue("form_id", retreat.form_id || "");
    setValue("registration_deadline", retreat.registration_deadline || "");
    setIsEventDialogOpen(true);
  };

  const handleCreateEventClick = () => {
    setEditingRetreat(null);
    reset({
      title: "",
      description: "",
      price: "" as any,
      location_text: "",
      start_date: "",
      end_date: "",
      max_participants: "" as any,
      status: "ativo",
      form_id: "",
      registration_deadline: "",
    });
    setIsEventDialogOpen(true);
  };

  const handleDeleteEventClick = async (retreatId: string) => {
    if (!confirm("Tem certeza que deseja excluir permanentemente este evento e todas as inscrições dele?")) return;

    try {
      const { error } = await supabase
        .from("retreats")
        .delete()
        .eq("id", retreatId);

      if (error) throw error;
      toast.success("Evento excluído com sucesso!");
      
      if (selectedRetreat?.id === retreatId) {
        setSelectedRetreat(null);
      }
      fetchRetreats();
    } catch (err: any) {
      toast.error("Erro ao excluir evento: " + err.message);
    }
  };

  const handleActivateEvent = async (retreatId: string) => {
    try {
      const { error } = await supabase
        .from("retreats")
        .update({ status: "ativo" })
        .eq("id", retreatId);

      if (error) throw error;

      toast.success("Evento ativado e publicado com sucesso!");
      setSelectedRetreat((prev) => (prev ? { ...prev, status: "ativo" } : null));
      fetchRetreats();
    } catch (err: any) {
      toast.error("Erro ao ativar evento: " + err.message);
    }
  };

  // Toggle Payment Status
  const handleTogglePayment = async (reg: RegistrationWithDetails) => {
    const nextPaid = !reg.paid;
    try {
      const { error } = await supabase
        .from("registrations")
        .update({ 
          paid: nextPaid,
          payment_method: nextPaid ? reg.payment_method || 'pix' : null,
          payment_reference: nextPaid ? reg.payment_reference || 'Confirmado pela liderança' : null
        })
        .eq("id", reg.id);

      if (error) throw error;
      
      setRegistrations(prev => prev.map(item => item.id === reg.id ? { 
        ...item, 
        paid: nextPaid,
        payment_method: nextPaid ? reg.payment_method || 'pix' : null,
        payment_reference: nextPaid ? reg.payment_reference || 'Confirmado pela liderança' : null
      } : item));
      
      if (selectedRegistrationForDetail?.id === reg.id) {
        setSelectedRegistrationForDetail(prev => prev ? {
          ...prev,
          paid: nextPaid,
          payment_method: nextPaid ? reg.payment_method || 'pix' : null,
          payment_reference: nextPaid ? reg.payment_reference || 'Confirmado pela liderança' : null
        } : null);
      }

      toast.success(`Inscrição marcada como ${nextPaid ? 'paga' : 'pendente'}!`);
    } catch (err: any) {
      toast.error("Erro ao atualizar pagamento: " + err.message);
    }
  };

  // Assign room to a specific registration
  const handleAssignRoom = async (regId: string, roomId: string | null) => {
    try {
      const targetRoom = retreatRooms.find(r => r.id === roomId);
      const { error } = await supabase
        .from("registrations")
        .update({ 
          room_id: roomId,
          room_allocation: targetRoom ? targetRoom.name : null
        })
        .eq("id", regId);

      if (error) throw error;

      toast.success("Quarto atualizado com sucesso!");
      if (selectedRetreat) {
        fetchRegistrations(selectedRetreat.id);
        fetchRetreatRooms(selectedRetreat.id);
      }
      setSelectedRegistrationForRoomModal(null);
    } catch (err: any) {
      toast.error("Erro ao atribuir quarto: " + err.message);
    }
  };

  // Delete a registration
  const handleDeleteRegistration = async (reg: RegistrationWithDetails) => {
    if (!confirm("Tem certeza que deseja excluir permanentemente esta inscrição?")) return;

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
      
      setRegistrations(prev => prev.filter(item => item.id !== reg.id));
      if (selectedRegistrationForDetail?.id === reg.id) {
        setSelectedRegistrationForDetail(null);
      }
    } catch (err: any) {
      toast.error("Erro ao excluir inscrição: " + err.message);
    }
  };

  // Helper to extract gender from registration
  const getParticipantGender = (reg: RegistrationWithDetails): string => {
    const customResps = reg.custom_responses as Record<string, any> | null;
    const guestData = reg.guest_data as Record<string, any> | null;

    if (customResps) {
      for (const [key, val] of Object.entries(customResps)) {
        if (key.toLowerCase().includes("gênero") || key.toLowerCase().includes("genero") || key.toLowerCase().includes("sexo")) {
          const valStr = String(val).toLowerCase();
          if (valStr.includes("masculino") || valStr === "m" || valStr.includes("homem")) return "masculino";
          if (valStr.includes("feminino") || valStr === "f" || valStr.includes("mulher")) return "feminino";
        }
      }
    }
    if (guestData?.gender) {
      const gStr = String(guestData.gender).toLowerCase();
      if (gStr.includes("masculino") || gStr === "m" || gStr.includes("homem")) return "masculino";
      if (gStr.includes("feminino") || gStr === "f" || gStr.includes("mulher")) return "feminino";
    }
    return "indefinido";
  };

  // Export registrations data to JSON
  const handleExportData = () => {
    if (!selectedRetreat || registrations.length === 0) {
      toast.error("Não há dados para exportar.");
      return;
    }

    const dataToExport = registrations.map(reg => ({
      Participante: reg.profiles?.full_name || (reg.guest_data as any)?.full_name || "Desconhecido",
      Email: reg.profiles?.email || (reg.guest_data as any)?.email || "",
      Telefone: reg.profiles?.phone || (reg.guest_data as any)?.phone || "",
      CPF: reg.profiles?.cpf || (reg.guest_data as any)?.cpf || "",
      Pago: reg.paid ? "Sim" : "Não",
      MetodoPagamento: reg.payment_method || "",
      ReferenciaPagamento: reg.payment_reference || "",
      Alojamento: reg.retreat_rooms?.name || reg.room_allocation || "Não alocado",
      ComprovanteNotas: reg.notes || "",
      CustomResponses: reg.custom_responses || {},
      DataInscricao: reg.created_at
    }));

    const blob = new Blob([JSON.stringify(dataToExport, null, 2)], { type: "application/json" });
    const url = URL.createObjectURL(blob);
    const link = document.createElement("a");
    link.href = url;
    link.download = `inscricoes_${selectedRetreat.title.toLowerCase().replace(/\s+/g, "_")}.json`;
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
    URL.revokeObjectURL(url);
    toast.success("Dados exportados com sucesso!");
  };

  // Filter registrations by search term
  const filteredRegistrations = registrations.filter(reg => {
    const name = reg.profiles?.full_name || (reg.guest_data as any)?.full_name || "";
    const email = reg.profiles?.email || (reg.guest_data as any)?.email || "";
    const cpf = reg.profiles?.cpf || (reg.guest_data as any)?.cpf || "";
    const room = reg.retreat_rooms?.name || reg.room_allocation || "";
    const search = searchTerm.toLowerCase();
    
    return name.toLowerCase().includes(search) || 
           email.toLowerCase().includes(search) || 
           cpf.toLowerCase().includes(search) ||
           room.toLowerCase().includes(search);
  });

  // Calculate statistics
  const totalInscritos = registrations.length;

  let valorTotalArrecadado = 0;
  let valorPendente = 0;

  registrations.forEach((reg) => {
    let price = selectedRetreat?.price || 0;
    if (selectedRetreat?.form_id && selectedFormTemplate) {
      const customResps = reg.custom_responses as Record<string, any> | null;
      if (customResps) {
        const idResponses: Record<string, any> = {};
        selectedFormTemplate.fields?.forEach((field: any) => {
          const val = customResps[field.label];
          if (val !== undefined) idResponses[field.id] = val;
        });
        price = calculateTotalPrice(selectedRetreat.price || 0, selectedFormTemplate.fields, idResponses);
      }
    }

    if (reg.paid) {
      valorTotalArrecadado += price;
    } else {
      valorPendente += price;
    }
  });

  const formFields = selectedFormTemplate?.fields || [];

  return (
    <TooltipProvider>
      <div className="space-y-6 max-w-[1600px] mx-auto px-4 md:px-6 lg:px-8 py-6 pb-16 w-full">
        {/* Header */}
        <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 border-b border-border/60 pb-5">
          <div>
            <h1 className="text-2xl sm:text-3xl font-extrabold tracking-tight text-foreground">
              Gestão de Eventos e Retiros
            </h1>
            <p className="text-sm text-muted-foreground mt-1">
              Administração de inscrições, alocações de quartos e controle financeiro de encontros.
            </p>
          </div>
          <Button 
            onClick={handleCreateEventClick}
            className="rounded-xl flex items-center gap-2 self-start md:self-auto cursor-pointer shadow-md text-xs font-bold h-10 px-4"
          >
            <Plus className="w-4 h-4" /> Novo Retiro
          </Button>
        </div>

        {/* Main Flex Layout */}
        <div className="flex flex-col lg:flex-row items-start gap-6 w-full">
          
          {/* Left column: Event Selector */}
          <div className="w-full lg:w-72 xl:w-80 shrink-0 space-y-3">
            <div className="flex items-center justify-between">
              <h2 className="text-xs font-bold uppercase tracking-wider text-muted-foreground">
                Selecione o Encontro
              </h2>
              <span className="text-[11px] font-semibold text-muted-foreground bg-muted px-2 py-0.5 rounded-full">
                {retreats.length} {retreats.length === 1 ? 'evento' : 'eventos'}
              </span>
            </div>

            {loadingRetreats ? (
              <div className="space-y-2.5">
                {[1, 2].map(i => (
                  <div key={i} className="h-20 w-full rounded-xl bg-muted animate-pulse" />
                ))}
              </div>
            ) : retreats.length === 0 ? (
              <Card className="border-dashed border-border/80 bg-card/20">
                <CardContent className="p-5 text-center">
                  <AlertTriangle className="w-7 h-7 text-muted-foreground mx-auto mb-2" />
                  <p className="text-xs font-semibold text-muted-foreground">Nenhum evento cadastrado.</p>
                </CardContent>
              </Card>
            ) : (
              <div className="flex flex-col gap-2 max-h-[calc(100vh-220px)] overflow-y-auto pr-1 custom-scrollbar">
                {retreats.map(retreat => {
                  const isSelected = selectedRetreat?.id === retreat.id;
                  return (
                    <button
                      key={retreat.id}
                      onClick={() => setSelectedRetreat(retreat)}
                      className={`w-full text-left p-3.5 rounded-xl border transition-all duration-200 cursor-pointer ${
                        isSelected 
                          ? "bg-primary text-primary-foreground border-primary shadow-md shadow-primary/20 scale-[1.01]" 
                          : "bg-card/50 hover:bg-muted/50 text-foreground border-border/50"
                      }`}
                    >
                      <div className="font-bold truncate text-sm leading-snug">
                        {retreat.title}
                      </div>
                      <div className={`text-[11px] mt-1.5 flex items-center gap-1.5 ${isSelected ? "text-primary-foreground/80" : "text-muted-foreground"}`}>
                        <Calendar className="w-3.5 h-3.5 shrink-0" />
                        <span>
                          {retreat.start_date ? new Date(retreat.start_date).toLocaleDateString("pt-BR") : "S/D"}
                        </span>
                      </div>
                      <div className="flex justify-between items-center mt-2.5 pt-2 border-t border-border/10">
                        <span className={`text-[10px] font-bold px-2 py-0.5 rounded-full uppercase ${
                          retreat.status === 'ativo' 
                            ? isSelected ? 'bg-white/20 text-white' : 'bg-emerald-500/10 text-emerald-500 border border-emerald-500/25'
                            : retreat.status === 'rascunho'
                            ? isSelected ? 'bg-white/20 text-white' : 'bg-amber-500/10 text-amber-500 border border-amber-500/25'
                            : isSelected ? 'bg-white/20 text-white' : 'bg-red-500/10 text-red-500 border border-red-500/25'
                        }`}>
                          {retreat.status}
                        </span>
                        <span className="text-xs font-black">
                          {retreat.price && retreat.price > 0 ? `R$ ${Number(retreat.price).toFixed(2)}` : 'Grátis'}
                        </span>
                      </div>
                    </button>
                  );
                })}
              </div>
            )}
          </div>

          {/* Right column: Event Details & Tabs */}
          <div className="flex-1 min-w-0 w-full space-y-5">
            {selectedRetreat ? (
              <>
                {/* Event Quick Info Header Banner */}
                <div className="bg-card/50 border border-border/60 rounded-2xl p-4 sm:p-5 backdrop-blur-sm flex flex-col md:flex-row md:items-center justify-between gap-4 shadow-sm">
                  <div className="space-y-1.5 min-w-0">
                    <div className="flex items-center gap-2.5 flex-wrap">
                      <h2 className="text-xl sm:text-2xl font-bold text-foreground truncate">{selectedRetreat.title}</h2>
                      <span className={`px-2.5 py-0.5 rounded-full text-[10px] font-extrabold uppercase tracking-wide ${
                        selectedRetreat.status === 'ativo' 
                          ? 'bg-emerald-500/15 text-emerald-500 border border-emerald-500/30' 
                          : selectedRetreat.status === 'rascunho'
                          ? 'bg-amber-500/15 text-amber-500 border border-amber-500/30'
                          : 'bg-red-500/15 text-red-500 border border-red-500/30'
                      }`}>
                        {selectedRetreat.status}
                      </span>
                    </div>
                    {selectedRetreat.description && (
                      <p className="text-muted-foreground text-xs line-clamp-1">
                        {selectedRetreat.description}
                      </p>
                    )}
                    <div className="flex flex-wrap gap-4 text-xs text-muted-foreground pt-1">
                      <div className="flex items-center gap-1.5">
                        <MapPin className="w-3.5 h-3.5 shrink-0 text-primary" />
                        <span className="truncate max-w-[200px]">{selectedRetreat.location_text || "Local não informado"}</span>
                      </div>
                      <div className="flex items-center gap-1.5">
                        <Clock className="w-3.5 h-3.5 shrink-0 text-primary" />
                        <span>
                          {selectedRetreat.start_date && new Date(selectedRetreat.start_date).toLocaleDateString("pt-BR")} até {selectedRetreat.end_date && new Date(selectedRetreat.end_date).toLocaleDateString("pt-BR")}
                        </span>
                      </div>
                      {selectedRetreat.forms?.name && (
                        <div className="flex items-center gap-1.5">
                          <FileText className="w-3.5 h-3.5 shrink-0 text-primary" />
                          <span className="font-semibold text-primary truncate max-w-[250px]">Formulário: {selectedRetreat.forms.name}</span>
                        </div>
                      )}
                    </div>
                  </div>

                  <div className="flex items-center gap-2 shrink-0 self-start md:self-auto">
                    <Button 
                      variant="outline" 
                      size="sm"
                      className="h-8 rounded-lg hover:bg-muted cursor-pointer text-xs font-semibold flex items-center gap-1.5"
                      onClick={() => handleEditEventClick(selectedRetreat)}
                    >
                      <Edit className="w-3.5 h-3.5" /> Editar
                    </Button>
                    <Button 
                      variant="ghost" 
                      size="sm"
                      className="h-8 rounded-lg text-red-500 hover:bg-red-500/10 cursor-pointer text-xs font-semibold flex items-center gap-1.5"
                      onClick={() => handleDeleteEventClick(selectedRetreat.id)}
                    >
                      <Trash2 className="w-3.5 h-3.5" /> Excluir
                    </Button>
                  </div>
                </div>

                {selectedRetreat.status === "rascunho" ? (
                  <Card className="border border-border bg-card/45 shadow-sm rounded-2xl p-6 md:p-8 backdrop-blur-sm">
                    <div className="flex flex-col items-center text-center max-w-xl mx-auto py-4">
                      <div className="h-16 w-16 bg-amber-500/10 text-amber-500 rounded-full flex items-center justify-center mb-4">
                        <AlertTriangle className="h-8 w-8" />
                      </div>
                      <h3 className="text-xl font-bold text-foreground mb-2">
                        Retiro em Modo Rascunho
                      </h3>
                      <p className="text-sm text-muted-foreground mb-6 leading-relaxed">
                        Este evento está salvo como rascunho. Para liberar as inscrições e torná-lo ativo, ative-o abaixo.
                      </p>
                      <Button
                        onClick={() => handleActivateEvent(selectedRetreat.id)}
                        className="bg-primary hover:bg-primary/90 text-primary-foreground font-bold cursor-pointer transition-all active:scale-95 py-2.5 px-6 rounded-lg flex items-center justify-center gap-2"
                      >
                        <Check className="h-4 w-4" /> Ativar e Publicar Retiro
                      </Button>
                    </div>
                  </Card>
                ) : (
                  <>
                    {/* Navigation Tabs */}
                    <div className="flex border-b border-border/60 overflow-x-auto gap-2">
                      <button
                        onClick={() => setActiveTab("registrations")}
                        className={`px-4 py-2.5 text-xs font-bold transition-all border-b-2 whitespace-nowrap cursor-pointer flex items-center gap-2 ${
                          activeTab === "registrations" 
                            ? "border-primary text-primary" 
                            : "border-transparent text-muted-foreground hover:text-foreground"
                        }`}
                      >
                        <Users className="w-4 h-4" />
                        Inscrições ({registrations.length})
                      </button>

                      <button
                        onClick={() => setActiveTab("rooms")}
                        className={`px-4 py-2.5 text-xs font-bold transition-all border-b-2 whitespace-nowrap cursor-pointer flex items-center gap-2 ${
                          activeTab === "rooms" 
                            ? "border-primary text-primary" 
                            : "border-transparent text-muted-foreground hover:text-foreground"
                        }`}
                      >
                        <Bed className="w-4 h-4" />
                        Divisão de Quartos
                      </button>

                      <button
                        onClick={() => setActiveTab("finance")}
                        className={`px-4 py-2.5 text-xs font-bold transition-all border-b-2 whitespace-nowrap cursor-pointer flex items-center gap-2 ${
                          activeTab === "finance" 
                            ? "border-primary text-primary" 
                            : "border-transparent text-muted-foreground hover:text-foreground"
                        }`}
                      >
                        <DollarSign className="w-4 h-4" />
                        Controle Financeiro & Gastos
                      </button>

                      <button
                        onClick={() => setActiveTab("dashboard")}
                        className={`px-4 py-2.5 text-xs font-bold transition-all border-b-2 whitespace-nowrap cursor-pointer flex items-center gap-2 ${
                          activeTab === "dashboard" 
                            ? "border-primary text-primary" 
                            : "border-transparent text-muted-foreground hover:text-foreground"
                        }`}
                      >
                        <BarChart3 className="w-4 h-4" />
                        Dashboard Analítico
                      </button>
                    </div>

                    {/* TAB 1: TABELA SIMPLES DE INSCRIÇÕES */}
                    {activeTab === "registrations" && (
                      <div className="space-y-4">
                        {/* Search Bar & Export Controls */}
                        <div className="flex flex-col sm:flex-row items-stretch sm:items-center justify-between gap-3 bg-card/30 p-4 rounded-xl border border-border/40">
                          <Input
                            placeholder="Pesquisar por nome, CPF, e-mail ou quarto..."
                            value={searchTerm}
                            onChange={(e) => setSearchTerm(e.target.value)}
                            className="max-w-md h-9 text-xs"
                          />
                          <Button
                            variant="outline"
                            size="sm"
                            onClick={handleExportData}
                            className="rounded-lg text-xs flex items-center gap-1.5 cursor-pointer shrink-0"
                          >
                            <Download className="w-3.5 h-3.5" /> Exportar (JSON)
                          </Button>
                        </div>

                        {/* Tabela com Scroll Fixo na Viewport + Colunas Sticky + Todas as Perguntas */}
                        <div className="border border-border/60 bg-card/40 rounded-2xl overflow-hidden shadow-sm max-h-[calc(100vh-270px)] overflow-auto relative custom-scrollbar scrollbar-thin scrollbar-thumb-zinc-300 dark:scrollbar-thumb-zinc-700 scrollbar-track-transparent">
                          {loadingRegistrations ? (
                            <div className="p-12 text-center text-xs text-muted-foreground flex items-center justify-center gap-2">
                              <Loader2 className="w-4 h-4 animate-spin" /> Carregando inscrições...
                            </div>
                          ) : filteredRegistrations.length === 0 ? (
                            <div className="p-12 text-center space-y-2">
                              <Users className="w-10 h-10 text-muted-foreground mx-auto" />
                              <p className="font-semibold text-sm text-foreground">Nenhuma inscrição encontrada</p>
                            </div>
                          ) : (
                            <Table className="relative w-full">
                              <TableHeader className="sticky top-0 z-20 bg-muted/90 backdrop-blur-md border-b border-border/60 shadow-sm">
                                <TableRow>
                                  <TableHead className="font-bold text-foreground text-xs min-w-[180px] sticky left-0 z-30 bg-muted/90 backdrop-blur-md">
                                    Participante
                                  </TableHead>
                                  <TableHead className="font-bold text-foreground text-xs min-w-[120px]">
                                    Contato / CPF
                                  </TableHead>
                                  <TableHead className="font-bold text-foreground text-xs min-w-[110px]">
                                    Sexo / Gênero
                                  </TableHead>
                                  <TableHead className="font-bold text-foreground text-xs min-w-[130px]">
                                    Cidade / Estado
                                  </TableHead>
                                  
                                  {/* TODAS as colunas dinâmicas do formulário */}
                                  {formFields.map((field: any) => (
                                    <TableHead key={field.id} className="font-bold text-foreground text-xs min-w-[150px] whitespace-nowrap">
                                      {field.label}
                                    </TableHead>
                                  ))}

                                  <TableHead className="font-bold text-foreground text-xs min-w-[130px]">
                                    Tipo de Pagamento
                                  </TableHead>
                                  <TableHead className="font-bold text-foreground text-xs min-w-[160px]">
                                    Quarto Designado
                                  </TableHead>
                                  <TableHead className="font-bold text-foreground text-xs text-right min-w-[140px] sticky right-0 z-30 bg-muted/90 backdrop-blur-md">
                                    Ações
                                  </TableHead>
                                </TableRow>
                              </TableHeader>
                              <TableBody className="divide-y divide-border/40">
                                {filteredRegistrations.map((reg) => {
                                  const name = reg.profiles?.full_name || (reg.guest_data as any)?.full_name || "Desconhecido";
                                  const phone = reg.profiles?.phone || (reg.guest_data as any)?.phone || "S/T";
                                  const cpf = reg.profiles?.cpf || (reg.guest_data as any)?.cpf || "S/C";
                                  const gender = getParticipantGender(reg);
                                  const cityState = (reg.guest_data as any)?.cityState || (reg.guest_data as any)?.city_state || (reg.profiles as any)?.address_city || "Belo Horizonte / MG";
                                  const customResps = reg.custom_responses as Record<string, any> | null;
                                  const roomName = reg.retreat_rooms?.name || reg.room_allocation || "Não alocado";

                                  return (
                                    <TableRow key={reg.id} className="hover:bg-muted/15 transition-colors group">
                                      <TableCell className="font-bold text-xs text-foreground sticky left-0 z-10 bg-card/95 backdrop-blur-md group-hover:bg-muted/30">
                                        {name}
                                      </TableCell>
                                      <TableCell className="text-xs text-muted-foreground">
                                        <div>{phone}</div>
                                        <div className="text-[11px] opacity-80">{cpf}</div>
                                      </TableCell>
                                      <TableCell className="text-xs font-semibold capitalize text-foreground">
                                        <Badge variant="outline" className={`text-[10px] ${gender === "masculino" ? "bg-blue-500/10 text-blue-500 border-blue-500/30" : "bg-pink-500/10 text-pink-500 border-pink-500/30"}`}>
                                          {gender}
                                        </Badge>
                                      </TableCell>
                                      <TableCell className="text-xs text-muted-foreground whitespace-nowrap">
                                        {cityState}
                                      </TableCell>

                                      {/* Respostas de TODAS as perguntas do formulário */}
                                      {formFields.map((field: any) => {
                                        const val = customResps ? customResps[field.label] : undefined;
                                        const displayVal = Array.isArray(val) ? val.join(", ") : val !== undefined ? String(val) : "—";
                                        return (
                                          <TableCell key={field.id} className="text-xs text-foreground min-w-[150px]">
                                            {displayVal}
                                          </TableCell>
                                        );
                                      })}

                                      {/* Tipo de Pagamento */}
                                      <TableCell className="text-xs">
                                        <Badge 
                                          variant="outline"
                                          className={`text-[10px] uppercase font-bold px-2 py-0.5 rounded-full ${
                                            reg.paid 
                                              ? "bg-emerald-500/10 text-emerald-500 border-emerald-500/30" 
                                              : "bg-amber-500/10 text-amber-500 border-amber-500/30"
                                          }`}
                                        >
                                          {reg.payment_method || (reg.paid ? "Pix" : "Pendente")}
                                        </Badge>
                                      </TableCell>

                                      {/* Quarto Designado (Botão Clicável) */}
                                      <TableCell className="text-xs">
                                        <Tooltip>
                                          <TooltipTrigger asChild>
                                            <Button
                                              variant="outline"
                                              size="sm"
                                              onClick={() => setSelectedRegistrationForRoomModal(reg)}
                                              className="h-8 text-xs font-semibold rounded-lg flex items-center gap-1.5 cursor-pointer hover:bg-primary/10 hover:border-primary/40"
                                            >
                                              <Bed className="w-3.5 h-3.5 text-primary shrink-0" />
                                              <span className={roomName === "Não alocado" ? "text-muted-foreground italic font-normal" : "font-bold text-foreground"}>
                                                {roomName}
                                              </span>
                                            </Button>
                                          </TooltipTrigger>
                                          <TooltipContent>
                                            <p className="text-xs">Clique para selecionar ou alterar o quarto deste inscrito</p>
                                          </TooltipContent>
                                        </Tooltip>
                                      </TableCell>

                                      {/* Ações com Tooltips Explicativos */}
                                      <TableCell className="text-right sticky right-0 z-10 bg-card/95 backdrop-blur-md group-hover:bg-muted/30">
                                        <div className="flex items-center justify-end gap-1.5">
                                          {/* Ver Detalhes */}
                                          <Tooltip>
                                            <TooltipTrigger asChild>
                                              <Button
                                                variant="ghost"
                                                size="sm"
                                                onClick={() => setSelectedRegistrationForDetail(reg)}
                                                className="h-8 px-2 text-xs font-semibold text-primary hover:bg-primary/10 rounded-md cursor-pointer flex items-center gap-1"
                                              >
                                                <Eye className="w-3.5 h-3.5" /> Detalhes
                                              </Button>
                                            </TooltipTrigger>
                                            <TooltipContent>
                                              <p className="text-xs">Visualizar ficha completa e respostas do participante</p>
                                            </TooltipContent>
                                          </Tooltip>

                                          {/* Toggle Pagamento */}
                                          <Tooltip>
                                            <TooltipTrigger asChild>
                                              <Button
                                                variant="ghost"
                                                size="sm"
                                                onClick={() => handleTogglePayment(reg)}
                                                className={`h-8 px-2 text-xs font-semibold rounded-md cursor-pointer ${
                                                  reg.paid ? "text-emerald-500 hover:bg-emerald-500/10" : "text-amber-500 hover:bg-amber-500/10"
                                                }`}
                                              >
                                                {reg.paid ? <Check className="w-3.5 h-3.5" /> : <X className="w-3.5 h-3.5" />}
                                              </Button>
                                            </TooltipTrigger>
                                            <TooltipContent>
                                              <p className="text-xs">
                                                {reg.paid ? "Estornar e marcar pagamento como Pendente" : "Confirmar e aprovar pagamento da inscrição"}
                                              </p>
                                            </TooltipContent>
                                          </Tooltip>

                                          {/* Excluir */}
                                          <Tooltip>
                                            <TooltipTrigger asChild>
                                              <Button
                                                variant="ghost"
                                                size="sm"
                                                onClick={() => handleDeleteRegistration(reg)}
                                                className="h-8 w-8 p-0 text-red-500 hover:bg-red-500/10 rounded-md cursor-pointer"
                                              >
                                                <Trash2 className="w-3.5 h-3.5" />
                                              </Button>
                                            </TooltipTrigger>
                                            <TooltipContent>
                                              <p className="text-xs">Excluir inscrição permanentemente</p>
                                            </TooltipContent>
                                          </Tooltip>
                                        </div>
                                      </TableCell>
                                    </TableRow>
                                  );
                                })}
                              </TableBody>
                            </Table>
                          )}
                        </div>
                      </div>
                    )}

                    {/* TAB 2: DIVISÃO DE QUARTOS POR EVENTO */}
                    {activeTab === "rooms" && (
                      <RoomManagementTab 
                        retreatId={selectedRetreat.id}
                        registrations={registrations}
                        onRefreshRegistrations={() => fetchRegistrations(selectedRetreat.id)}
                      />
                    )}

                    {/* TAB 3: CONTROLE FINANCEIRO & GASTOS */}
                    {activeTab === "finance" && (
                      <EventFinanceTab 
                        retreatId={selectedRetreat.id}
                        totalIncome={valorTotalArrecadado}
                        pendingIncome={valorPendente}
                      />
                    )}

                    {/* TAB 4: DASHBOARD ANALÍTICO (DESIGN STITCH COMPATÍVEL) */}
                    {activeTab === "dashboard" && (() => {
                      const maxCapacity = selectedRetreat.max_participants || 150;
                      const occupancyPct = Math.min(100, Math.round((totalInscritos / maxCapacity) * 100));
                      
                      const paidCount = registrations.filter(r => r.paid).length;
                      const pendingCount = registrations.filter(r => !r.paid).length;
                      const paidPct = totalInscritos > 0 ? Math.round((paidCount / totalInscritos) * 100) : 0;
                      
                      const totalExpenses = retreatExpenses.reduce((sum, e) => sum + (Number(e.amount) || 0), 0);
                      const faturamentoEstimado = valorTotalArrecadado + valorPendente;
                      const resultadoLiquido = faturamentoEstimado - totalExpenses;

                      const maleCount = registrations.filter(r => getParticipantGender(r) === "masculino").length;
                      const femaleCount = registrations.filter(r => getParticipantGender(r) === "feminino").length;
                      const malePct = totalInscritos > 0 ? Math.round((maleCount / totalInscritos) * 100) : 0;
                      const femalePct = totalInscritos > 0 ? Math.round((femaleCount / totalInscritos) * 100) : 0;

                      const roomAllocatedCount = registrations.filter(r => r.room_id || (r.room_allocation && r.room_allocation !== "Não alocado")).length;
                      const totalBeds = retreatRooms.reduce((acc, r) => acc + (r.capacity || 0), 0);
                      const unallocatedCount = totalInscritos - roomAllocatedCount;

                      return (
                        <div className="space-y-6">
                          {/* LINHA 1: 5 CARDS KPIS COM VISUAL FIDEDIGNO AO STITCH */}
                          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-5 gap-4">
                            
                            {/* Card 1: Gauge Circular de Inscrições / Vagas */}
                            <div className="rounded-2xl border border-border/70 bg-card/60 p-4 shadow-sm text-left flex flex-col justify-between items-center relative overflow-hidden">
                              <span className="text-[10px] font-extrabold tracking-wider text-muted-foreground uppercase self-start">
                                Inscrições / Vagas
                              </span>
                              
                              <div className="relative w-24 h-24 my-2 flex items-center justify-center">
                                {/* SVG Circular Gauge */}
                                <svg className="w-full h-full transform -rotate-90" viewBox="0 0 36 36">
                                  <path
                                    className="text-muted/40 stroke-current"
                                    strokeWidth="3.5"
                                    fill="none"
                                    d="M18 2.0845 a 15.9155 15.9155 0 0 1 0 31.831 a 15.9155 15.9155 0 0 1 0 -31.831"
                                  />
                                  <path
                                    className="text-primary stroke-current transition-all duration-700 ease-out"
                                    strokeDasharray={`${occupancyPct}, 100`}
                                    strokeLinecap="round"
                                    strokeWidth="3.5"
                                    fill="none"
                                    d="M18 2.0845 a 15.9155 15.9155 0 0 1 0 31.831 a 15.9155 15.9155 0 0 1 0 -31.831"
                                  />
                                </svg>
                                <div className="absolute flex flex-col items-center justify-center text-center">
                                  <span className="text-sm font-black text-foreground">{totalInscritos} / {maxCapacity}</span>
                                  <span className="text-[9px] font-bold text-muted-foreground">{occupancyPct}%</span>
                                </div>
                              </div>

                              <span className="text-[10px] font-bold text-muted-foreground block">
                                {occupancyPct}% das vagas ocupadas
                              </span>
                            </div>

                            {/* Card 2: Status de Pagamento (Quitação) estilo Stitch */}
                            <div className="rounded-2xl border border-border/70 bg-card/60 p-4 shadow-sm text-left flex flex-col justify-between min-w-0">
                              <div>
                                <span className="text-[10px] font-extrabold tracking-wider text-muted-foreground uppercase">
                                  Status do Pagamento
                                </span>
                                <div className="mt-2">
                                  <div className="text-2xl font-black text-primary flex items-baseline gap-1.5">
                                    {paidCount} <span className="text-xs font-semibold text-foreground">Pagos</span>
                                  </div>
                                  <Badge variant="outline" className="mt-1 text-[9px] font-extrabold bg-primary/10 text-primary border-primary/30">
                                    {paidPct}% Quitados
                                  </Badge>
                                </div>
                              </div>

                              <div className="mt-3 pt-2 border-t border-border/20">
                                <div className="flex justify-between items-center text-xs font-bold text-amber-500">
                                  <span>{pendingCount} pendentes</span>
                                </div>
                              </div>
                            </div>

                            {/* Card 3: Faturamento Estimado (Verde Neon) */}
                            <div className="rounded-2xl border border-border/70 bg-card/60 p-4 shadow-sm text-left flex flex-col justify-between min-w-0">
                              <div>
                                <div className="flex items-center justify-between">
                                  <span className="text-[10px] font-extrabold tracking-wider text-muted-foreground uppercase flex items-center gap-1">
                                    Faturamento Est.
                                  </span>
                                  <Tooltip>
                                    <TooltipTrigger asChild>
                                      <Info className="w-3.5 h-3.5 text-muted-foreground cursor-help" />
                                    </TooltipTrigger>
                                    <TooltipContent className="max-w-xs text-xs">
                                      <p><strong>Cálculo do Faturamento Estimado:</strong></p>
                                      <p className="mt-1">Soma do (Preço Base + Adicionais) de todas as inscrições.</p>
                                    </TooltipContent>
                                  </Tooltip>
                                </div>
                                <div className="mt-2 text-xl font-black text-emerald-400 truncate" title={new Intl.NumberFormat("pt-BR", { style: "currency", currency: "BRL" }).format(faturamentoEstimado)}>
                                  {new Intl.NumberFormat("pt-BR", { style: "currency", currency: "BRL" }).format(faturamentoEstimado)}
                                </div>
                              </div>

                              <span className="text-[10px] font-semibold text-muted-foreground mt-3 block truncate border-t border-border/20 pt-2">
                                Confirmado: <strong className="text-foreground">{new Intl.NumberFormat("pt-BR", { style: "currency", currency: "BRL" }).format(valorTotalArrecadado)}</strong>
                              </span>
                            </div>

                            {/* Card 4: Total de Gastos */}
                            <div className="rounded-2xl border border-border/70 bg-card/60 p-4 shadow-sm text-left flex flex-col justify-between min-w-0">
                              <div>
                                <div className="flex items-center justify-between">
                                  <span className="text-[10px] font-extrabold tracking-wider text-muted-foreground uppercase">
                                    Total de Gastos
                                  </span>
                                  <DollarSign className="w-4 h-4 text-red-500 shrink-0" />
                                </div>
                                <div className="mt-2 text-xl font-black text-foreground truncate" title={new Intl.NumberFormat("pt-BR", { style: "currency", currency: "BRL" }).format(totalExpenses)}>
                                  {new Intl.NumberFormat("pt-BR", { style: "currency", currency: "BRL" }).format(totalExpenses)}
                                </div>
                              </div>

                              <span className="text-[10px] font-semibold text-muted-foreground mt-3 block border-t border-border/20 pt-2">
                                {retreatExpenses.length} despesas cadastradas
                              </span>
                            </div>

                            {/* Card 5: Resultado Líquido */}
                            <div className="rounded-2xl border border-border/70 bg-card/60 p-4 shadow-sm text-left flex flex-col justify-between min-w-0">
                              <div>
                                <div className="flex items-center justify-between">
                                  <span className="text-[10px] font-extrabold tracking-wider text-muted-foreground uppercase">
                                    Resultado Líquido
                                  </span>
                                  {resultadoLiquido >= 0 ? (
                                    <TrendingUp className="w-4 h-4 text-emerald-400 shrink-0" />
                                  ) : (
                                    <TrendingDown className="w-4 h-4 text-red-400 shrink-0" />
                                  )}
                                </div>
                                <div className={`mt-2 text-xl font-black truncate ${resultadoLiquido >= 0 ? "text-emerald-400" : "text-red-400"}`} title={new Intl.NumberFormat("pt-BR", { style: "currency", currency: "BRL" }).format(resultadoLiquido)}>
                                  {new Intl.NumberFormat("pt-BR", { style: "currency", currency: "BRL" }).format(resultadoLiquido)}
                                </div>
                              </div>

                              <div className="mt-3 border-t border-border/20 pt-2">
                                <Badge variant="outline" className={`text-[9px] font-extrabold ${resultadoLiquido >= 0 ? "bg-emerald-500/10 text-emerald-400 border-emerald-500/30" : "bg-red-500/10 text-red-400 border-red-500/30"}`}>
                                  {resultadoLiquido >= 0 ? "Superávit Estimado" : "Déficit Estimado"}
                                </Badge>
                              </div>
                            </div>

                          </div>

                          {/* LINHA 2: GRÁFICOS E INDICADORES ESTILO STITCH */}
                          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                            
                            {/* Card: Distribuição por Gênero */}
                            <Card className="border border-border/70 bg-card/60 p-5 rounded-2xl shadow-sm">
                              <h4 className="text-sm font-bold text-foreground mb-5 flex items-center gap-2">
                                <PieChart className="w-4 h-4 text-primary" /> Distribuição por Gênero
                              </h4>

                              <div className="space-y-5">
                                <div>
                                  <div className="flex justify-between text-xs font-semibold mb-1.5">
                                    <span className="text-foreground">Homens (Masculino)</span>
                                    <span className="text-muted-foreground font-extrabold">{maleCount} ({malePct}%)</span>
                                  </div>
                                  <div className="w-full bg-muted/50 rounded-full h-3 overflow-hidden p-0.5 border border-border/30">
                                    <div className="bg-primary h-full rounded-full transition-all duration-500" style={{ width: `${malePct}%` }} />
                                  </div>
                                </div>

                                <div>
                                  <div className="flex justify-between text-xs font-semibold mb-1.5">
                                    <span className="text-foreground">Mulheres (Feminino)</span>
                                    <span className="text-muted-foreground font-extrabold">{femaleCount} ({femalePct}%)</span>
                                  </div>
                                  <div className="w-full bg-muted/50 rounded-full h-3 overflow-hidden p-0.5 border border-border/30">
                                    <div className="bg-primary/80 h-full rounded-full transition-all duration-500" style={{ width: `${femalePct}%` }} />
                                  </div>
                                </div>
                              </div>
                            </Card>

                            {/* Card: Status dos Alojamentos */}
                            <Card className="border border-border/70 bg-card/60 p-5 rounded-2xl shadow-sm">
                              <h4 className="text-sm font-bold text-foreground mb-5 flex items-center justify-between">
                                <span className="flex items-center gap-2">
                                  <Bed className="w-4 h-4 text-primary" /> Status dos Alojamentos
                                </span>
                                <span className="text-xs font-bold text-muted-foreground">
                                  {roomAllocatedCount} / {totalBeds} Camas ({unallocatedCount} sem quarto)
                                </span>
                              </h4>

                              <div className="space-y-3.5 max-h-52 overflow-y-auto pr-1 custom-scrollbar">
                                {retreatRooms.length === 0 ? (
                                  <p className="text-xs text-muted-foreground italic text-center py-6">Nenhum quarto cadastrado neste retiro.</p>
                                ) : (
                                  retreatRooms.map((room) => {
                                    const occupants = registrations.filter(r => r.room_id === room.id || r.room_allocation === room.name).length;
                                    const roomPct = Math.min(100, Math.round((occupants / room.capacity) * 100));
                                    const isFull = occupants >= room.capacity;

                                    return (
                                      <div key={room.id} className="space-y-1.5 bg-card/80 p-3 rounded-xl border border-border/40">
                                        <div className="flex justify-between items-center text-xs">
                                          <span className="font-bold text-foreground flex items-center gap-2">
                                            {room.name}
                                            <Badge variant="outline" className={`text-[9px] font-black uppercase px-1.5 py-0 ${room.gender_type === 'masculino' ? 'bg-primary/10 text-primary border-primary/30' : room.gender_type === 'feminino' ? 'bg-purple-500/10 text-purple-400 border-purple-500/30' : 'bg-indigo-500/10 text-indigo-400 border-indigo-500/30'}`}>
                                              {room.gender_type}
                                            </Badge>
                                          </span>
                                          <span className={`text-[11px] font-extrabold ${isFull ? 'text-emerald-400' : 'text-muted-foreground'}`}>
                                            {occupants} / {room.capacity} camas {isFull && '(Lotado)'}
                                          </span>
                                        </div>
                                        <div className="w-full bg-muted/60 rounded-full h-2 overflow-hidden">
                                          <div className={`h-full rounded-full transition-all duration-500 ${isFull ? 'bg-emerald-500' : 'bg-primary'}`} style={{ width: `${roomPct}%` }} />
                                        </div>
                                      </div>
                                    );
                                  })
                                )}
                              </div>
                            </Card>

                          </div>
                        </div>
                      );
                    })()}
                  </>
                )}
              </>
            ) : (
              <Card className="border-dashed border-border/80 bg-card/10 py-16 text-center">
                <CardContent className="space-y-4">
                  <Calendar className="w-16 h-16 text-muted-foreground mx-auto" />
                  <h3 className="text-xl font-bold text-foreground">Nenhum evento selecionado</h3>
                  <p className="text-muted-foreground text-sm max-w-sm mx-auto">
                    Crie um novo retiro ou selecione um existente na barra lateral esquerda.
                  </p>
                </CardContent>
              </Card>
            )}
          </div>

        </div>

        {/* Modal de Alocar Quarto para Inscrito Específico */}
        {selectedRegistrationForRoomModal && (() => {
          const participantGender = getParticipantGender(selectedRegistrationForRoomModal);
          const eligibleRoomsForParticipant = retreatRooms.filter(room => {
            if (room.gender_type === "suite") return true;
            if (participantGender === "indefinido") return true;
            return room.gender_type === participantGender;
          });

          return (
            <Dialog open={!!selectedRegistrationForRoomModal} onOpenChange={(open) => !open && setSelectedRegistrationForRoomModal(null)}>
              <DialogContent className="sm:max-w-md max-w-full rounded-2xl border border-border bg-card p-6">
                <DialogHeader>
                  <DialogTitle className="text-lg font-bold text-foreground flex items-center gap-2">
                    <Bed className="w-5 h-5 text-primary" />
                    Alocar Quarto para Participante
                  </DialogTitle>
                  <DialogDescription className="text-xs text-muted-foreground">
                    Selecione o alojamento desejado para <strong>{selectedRegistrationForRoomModal.profiles?.full_name || (selectedRegistrationForRoomModal.guest_data as any)?.full_name || "Participante"}</strong>.
                  </DialogDescription>
                </DialogHeader>

                <div className="space-y-4 py-2">
                  <div className="bg-muted/20 border border-border/40 p-3 rounded-xl text-xs space-y-1.5">
                    <div className="flex justify-between items-center">
                      <span className="text-muted-foreground font-semibold">Quarto Atual:</span>
                      <span className="font-bold text-foreground flex items-center gap-1.5">
                        <Bed className="w-3.5 h-3.5 text-primary" />
                        {selectedRegistrationForRoomModal.retreat_rooms?.name || selectedRegistrationForRoomModal.room_allocation || "Não alocado"}
                      </span>
                    </div>
                    {participantGender !== "indefinido" && (
                      <div className="flex justify-between items-center border-t border-border/30 pt-1.5 text-[11px]">
                        <span className="text-muted-foreground">Filtro de Gênero:</span>
                        <span className="font-bold text-foreground capitalize">Quartos {participantGender}s ou Suítes</span>
                      </div>
                    )}
                  </div>

                  {loadingRooms ? (
                    <div className="text-center py-4 text-xs text-muted-foreground flex items-center justify-center gap-2">
                      <Loader2 className="w-4 h-4 animate-spin" /> Carregando quartos do evento...
                    </div>
                  ) : eligibleRoomsForParticipant.length === 0 ? (
                    <div className="text-center py-4 text-xs text-muted-foreground italic bg-amber-500/10 border border-amber-500/20 p-3 rounded-xl">
                      Nenhum quarto compatível ({participantGender}) com vagas cadastrado neste evento. Crie quartos novos na aba "Divisão de Quartos".
                    </div>
                  ) : (
                    <div className="space-y-2 max-h-[240px] overflow-y-auto pr-1">
                      {eligibleRoomsForParticipant.map((room) => {
                        const occupantsCount = registrations.filter(r => r.room_id === room.id || r.room_allocation === room.name).length;
                        const isFull = occupantsCount >= room.capacity;
                        const isCurrentRoom = selectedRegistrationForRoomModal.room_id === room.id || selectedRegistrationForRoomModal.room_allocation === room.name;

                        return (
                          <div key={room.id} className="flex items-center justify-between text-xs bg-muted/30 border border-border/40 p-3 rounded-xl">
                            <div>
                              <span className="font-bold text-foreground block">{room.name}</span>
                              <span className="text-[11px] text-muted-foreground block capitalize">
                                {room.gender_type === "suite" ? "Suíte (Casais / Família)" : room.gender_type} • {occupantsCount}/{room.capacity} camas
                              </span>
                            </div>
                            {isCurrentRoom ? (
                              <Badge variant="outline" className="bg-emerald-500/10 text-emerald-500 border-emerald-500/30 text-[10px] uppercase font-bold">
                                Alocado Aqui
                              </Badge>
                            ) : (
                              <Button
                                size="sm"
                                disabled={isFull}
                                onClick={() => handleAssignRoom(selectedRegistrationForRoomModal.id, room.id)}
                                className="h-7 text-xs rounded-lg cursor-pointer"
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
                  {selectedRegistrationForRoomModal.room_id || selectedRegistrationForRoomModal.room_allocation ? (
                    <Button
                      type="button"
                      variant="outline"
                      onClick={() => handleAssignRoom(selectedRegistrationForRoomModal.id, null)}
                      className="text-red-500 hover:bg-red-500/10 border-red-500/30 text-xs cursor-pointer"
                    >
                      Remover do Quarto
                    </Button>
                  ) : (
                    <div />
                  )}
                  <Button type="button" variant="secondary" onClick={() => setSelectedRegistrationForRoomModal(null)} className="cursor-pointer">
                    Cancelar
                  </Button>
                </DialogFooter>
              </DialogContent>
            </Dialog>
          );
        })()}

        {/* Modal de Detalhes da Inscrição */}
        <RegistrationDetailDialog
          registration={selectedRegistrationForDetail}
          isOpen={!!selectedRegistrationForDetail}
          onClose={() => setSelectedRegistrationForDetail(null)}
          onTogglePayment={handleTogglePayment}
        />

        {/* Dialog para Criar / Editar Retiro */}
        <Dialog open={isEventDialogOpen} onOpenChange={setIsEventDialogOpen}>
          <DialogContent className="sm:max-w-3xl max-w-full rounded-2xl border border-border bg-card p-6 md:p-8 max-h-[90vh] overflow-y-auto custom-scrollbar">
            <DialogHeader>
              <DialogTitle className="text-xl font-bold text-foreground">
                {editingRetreat ? "Editar Encontro/Retiro" : "Criar Novo Encontro/Retiro"}
              </DialogTitle>
              <DialogDescription className="text-muted-foreground">
                Preencha os detalhes logísticos do evento.
              </DialogDescription>
            </DialogHeader>

            <form onSubmit={handleSubmit(onSubmitEvent)} className="space-y-4 py-2">
              <Field>
                <FieldLabel htmlFor="title">Título do Retiro *</FieldLabel>
                <Controller
                  name="title"
                  control={control}
                  render={({ field, fieldState }) => (
                    <>
                      <Input {...field} id="title" placeholder="Ex: Retiro de Jovens 2026" className="rounded-md" />
                      {fieldState.error && <FieldError>{fieldState.error.message}</FieldError>}
                    </>
                  )}
                />
              </Field>

              <Field>
                <FieldLabel htmlFor="description">Descrição</FieldLabel>
                <Controller
                  name="description"
                  control={control}
                  render={({ field }) => (
                    <Textarea {...field} value={field.value || ""} id="description" placeholder="Informações detalhadas..." className="rounded-md min-h-[80px]" />
                  )}
                />
              </Field>

              <div className="grid grid-cols-2 gap-4">
                <Field>
                  <FieldLabel htmlFor="price">Preço por Pessoa (R$) *</FieldLabel>
                  <Controller
                    name="price"
                    control={control}
                    render={({ field, fieldState }) => (
                      <>
                        <Input {...field} id="price" type="number" step="0.01" min="0" placeholder="Ex: 150.00" className="rounded-md" />
                        {fieldState.error && <FieldError>{fieldState.error.message}</FieldError>}
                      </>
                    )}
                  />
                </Field>

                <Field>
                  <FieldLabel htmlFor="max_participants">Capacidade Máxima *</FieldLabel>
                  <Controller
                    name="max_participants"
                    control={control}
                    render={({ field, fieldState }) => (
                      <>
                        <Input {...field} id="max_participants" type="number" min="1" placeholder="Ex: 120" className="rounded-md" />
                        {fieldState.error && <FieldError>{fieldState.error.message}</FieldError>}
                      </>
                    )}
                  />
                </Field>
              </div>

              <Field>
                <FieldLabel htmlFor="location_text">Local do Evento</FieldLabel>
                <Controller
                  name="location_text"
                  control={control}
                  render={({ field }) => (
                    <Input {...field} value={field.value || ""} id="location_text" placeholder="Ex: Sítio Ebenézer, Esmeraldas - MG" className="rounded-md" />
                  )}
                />
              </Field>

              <div className="grid grid-cols-2 gap-4">
                <Field>
                  <FieldLabel htmlFor="start_date">Data de Início *</FieldLabel>
                  <Controller
                    name="start_date"
                    control={control}
                    render={({ field, fieldState }) => (
                      <>
                        <Input {...field} id="start_date" type="date" className="rounded-md" />
                        {fieldState.error && <FieldError>{fieldState.error.message}</FieldError>}
                      </>
                    )}
                  />
                </Field>

                <Field>
                  <FieldLabel htmlFor="end_date">Data de Término *</FieldLabel>
                  <Controller
                    name="end_date"
                    control={control}
                    render={({ field, fieldState }) => (
                      <>
                        <Input {...field} id="end_date" type="date" className="rounded-md" />
                        {fieldState.error && <FieldError>{fieldState.error.message}</FieldError>}
                      </>
                    )}
                  />
                </Field>
              </div>

              <div className="grid grid-cols-2 gap-4">
                <Field>
                  <FieldLabel htmlFor="status">Status *</FieldLabel>
                  <Controller
                    name="status"
                    control={control}
                    render={({ field }) => (
                      <Select onValueChange={field.onChange} value={field.value}>
                        <SelectTrigger id="status" className="w-full">
                          <SelectValue placeholder="Selecione o status" />
                        </SelectTrigger>
                        <SelectContent>
                          <SelectItem value="ativo">Ativo</SelectItem>
                          <SelectItem value="rascunho">Rascunho</SelectItem>
                          <SelectItem value="encerrado">Encerrado</SelectItem>
                        </SelectContent>
                      </Select>
                    )}
                  />
                </Field>

                <Field>
                  <FieldLabel htmlFor="form_id">Ficha de Inscrição Customizada</FieldLabel>
                  <Controller
                    name="form_id"
                    control={control}
                    render={({ field }) => (
                      <Select 
                        onValueChange={(val) => field.onChange(val === "none" ? null : val)} 
                        value={field.value || "none"}
                      >
                        <SelectTrigger id="form_id" className="w-full">
                          <SelectValue placeholder="Nenhum (Formulário Geral)" />
                        </SelectTrigger>
                        <SelectContent>
                          <SelectItem value="none">Nenhum (Formulário Geral)</SelectItem>
                          {forms.map(f => (
                            <SelectItem key={f.id} value={f.id}>{f.name}</SelectItem>
                          ))}
                        </SelectContent>
                      </Select>
                    )}
                  />
                </Field>
              </div>

              <DialogFooter className="pt-2">
                <Button type="button" variant="outline" onClick={() => setIsEventDialogOpen(false)}>
                  Cancelar
                </Button>
                <Button type="submit" disabled={submitting} className="cursor-pointer">
                  {submitting ? <Loader2 className="w-4 h-4 animate-spin" /> : "Salvar Retiro"}
                </Button>
              </DialogFooter>
            </form>
          </DialogContent>
        </Dialog>
      </div>
    </TooltipProvider>
  );
}
