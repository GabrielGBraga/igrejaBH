import { useEffect, useState } from "react";
import supabase from "@/lib/supabase";
import { calculateTotalPrice } from "@/lib/forms";
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
  RefreshCw,
  BarChart3
} from "lucide-react";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
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
import { Tabs, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { Badge } from "@/components/ui/badge";
import { Tooltip, TooltipContent, TooltipProvider, TooltipTrigger } from "@/components/ui/tooltip";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { useForm, Controller } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import * as z from "zod";
import { toast } from "sonner";
import type { Database } from "@/lib/database.types";

type Retreat = Database["public"]["Tables"]["retreats"]["Row"] & {
  forms?: {
    name: string;
  } | null;
};

type Registration = Database["public"]["Tables"]["registrations"]["Row"] & {
  profiles?: {
    full_name: string;
    email: string | null;
    phone: string | null;
    cpf: string | null;
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
  const [registrations, setRegistrations] = useState<Registration[]>([]);
  const [selectedFormTemplate, setSelectedFormTemplate] = useState<any>(null);
  const [loadingFormTemplate, setLoadingFormTemplate] = useState(false);
  
  // Loading states
  const [loadingRetreats, setLoadingRetreats] = useState(true);
  const [loadingRegistrations, setLoadingRegistrations] = useState(false);
  const [submitting, setSubmitting] = useState(false);
  
  // Dialog states
  const [isEventDialogOpen, setIsEventDialogOpen] = useState(false);
  const [editingRetreat, setEditingRetreat] = useState<Retreat | null>(null);
  
  // Active Tab
  const [activeTab, setActiveTab] = useState<"events" | "registrations" | "rooms" | "finance" | "dashboard">("events");
  
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
      if (selectedRetreat.form_id) {
        fetchFormTemplate(selectedRetreat.form_id);
      } else {
        setSelectedFormTemplate(null);
      }
    } else {
      setRegistrations([]);
      setSelectedFormTemplate(null);
    }
  }, [selectedRetreat, activeTab]);

  async function fetchFormTemplate(formId: string) {
    setLoadingFormTemplate(true);
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
    } finally {
      setLoadingFormTemplate(false);
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
      
      // Select first retreat by default if none is selected
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

    try {
      if (editingRetreat) {
        // Edit Mode
        const { error } = await supabase
          .from("retreats")
          .update(payload)
          .eq("id", editingRetreat.id);
        
        if (error) throw error;
        toast.success("Evento atualizado com sucesso!");
      } else {
        // Create Mode
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
  const handleTogglePayment = async (reg: Registration) => {
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
      toast.success(`Inscrição marcada como ${nextPaid ? 'paga' : 'pendente'}!`);
    } catch (err: any) {
      toast.error("Erro ao atualizar pagamento: " + err.message);
    }
  };

  // Update room/lodging allocation
  const handleUpdateRoom = async (regId: string, room: string) => {
    try {
      const { error } = await supabase
        .from("registrations")
        .update({ room_allocation: room === "" ? null : room })
        .eq("id", regId);

      if (error) throw error;
      
      setRegistrations(prev => prev.map(item => item.id === regId ? { ...item, room_allocation: room === "" ? null : room } : item));
      toast.success("Alojamento atualizado com sucesso!");
    } catch (err: any) {
      toast.error("Erro ao alocar quarto: " + err.message);
    }
  };

  // Delete a registration
  const handleDeleteRegistration = async (reg: Registration) => {
    if (!confirm("Tem certeza que deseja excluir permanentemente esta inscrição?")) return;

    try {
      const deletingToastId = toast.loading("Excluindo inscrição...");
      
      // If there is a form submission associated, delete that instead
      // (which will cascade delete the registration in the DB).
      // Otherwise, delete the registration directly.
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
    } catch (err: any) {
      toast.error("Erro ao excluir inscrição: " + err.message);
    }
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
      Alojamento: reg.room_allocation || "Não alocado",
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
    const room = reg.room_allocation || "";
    const search = searchTerm.toLowerCase();
    
    return name.toLowerCase().includes(search) || 
           email.toLowerCase().includes(search) || 
           cpf.toLowerCase().includes(search) ||
           room.toLowerCase().includes(search);
  });

  // Helper to map custom responses by field id rather than label
  const getResponsesMappedById = (customResponses: Record<string, any> | null, fields: any[]) => {
    if (!customResponses) return {};
    const mapped: Record<string, any> = {};
    fields.forEach((field) => {
      const val = customResponses[field.label];
      if (val !== undefined) {
        mapped[field.id] = val;
      }
    });
    return mapped;
  };

  // Calculate statistics
  const totalInscritos = registrations.length;
  const totalPagos = registrations.filter(r => r.paid).length;
  const totalPendentes = totalInscritos - totalPagos;

  let valorTotalArrecadado = 0;
  let valorPendente = 0;

  registrations.forEach((reg) => {
    let price = selectedRetreat?.price || 0;
    if (selectedRetreat?.form_id && selectedFormTemplate) {
      const idResponses = getResponsesMappedById(reg.custom_responses as any, selectedFormTemplate.fields);
      price = calculateTotalPrice(selectedRetreat.price || 0, selectedFormTemplate.fields, idResponses);
    }

    if (reg.paid) {
      valorTotalArrecadado += price;
    } else {
      valorPendente += price;
    }
  });

  const percentualLote = selectedRetreat?.max_participants 
    ? Math.round((totalInscritos / selectedRetreat.max_participants) * 100) 
    : 0;

  const getChoiceBreakdown = (field: any, regs: Registration[]) => {
    const counts: Record<string, number> = {};
    if (field.options) {
      field.options.forEach((opt: string) => {
        counts[opt] = 0;
      });
    }

    regs.forEach((reg) => {
      if (!reg.custom_responses) return;
      const val = (reg.custom_responses as Record<string, any>)[field.label];
      if (val === undefined || val === null) return;
      if (Array.isArray(val)) {
        val.forEach((item) => {
          const itemStr = String(item);
          counts[itemStr] = (counts[itemStr] || 0) + 1;
        });
      } else {
        const valStr = String(val);
        counts[valStr] = (counts[valStr] || 0) + 1;
      }
    });

    return counts;
  };

  const getNumberStats = (field: any, regs: Registration[]) => {
    let sum = 0;
    let count = 0;
    let min = Infinity;
    let max = -Infinity;

    regs.forEach((reg) => {
      if (!reg.custom_responses) return;
      const val = (reg.custom_responses as Record<string, any>)[field.label];
      if (val === undefined || val === null || val === "") return;
      const num = Number(val);
      if (!isNaN(num)) {
        sum += num;
        count++;
        if (num < min) min = num;
        if (num > max) max = num;
      }
    });

    return {
      sum,
      count,
      avg: count > 0 ? sum / count : 0,
      min: min === Infinity ? 0 : min,
      max: max === -Infinity ? 0 : max,
    };
  };

  const getDateBreakdown = (field: any, regs: Registration[]) => {
    const counts: Record<string, number> = {};

    regs.forEach((reg) => {
      if (!reg.custom_responses) return;
      const val = (reg.custom_responses as Record<string, any>)[field.label];
      if (!val) return;
      const dateStr = String(val);
      counts[dateStr] = (counts[dateStr] || 0) + 1;
    });

    return Object.entries(counts)
      .sort((a, b) => a[0].localeCompare(b[0]))
      .map(([date, count]) => ({ date, count }));
  };





  return (
    <div className="space-y-6 max-w-7xl mx-auto px-4 md:px-6 py-6 pb-24">
      {/* Header */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 border-b border-border/60 pb-6">
        <div>
          <h1 className="text-3xl font-extrabold tracking-tight text-foreground bg-clip-text">
            Gestão de Eventos e Retiros
          </h1>
          <p className="text-muted-foreground mt-1.5">
            Administração logística, alocações de alojamentos e controle financeiro de encontros.
          </p>
        </div>
        <Button 
          onClick={handleCreateEventClick}
          className="rounded-xl flex items-center gap-2 self-start md:self-auto cursor-pointer shadow-md"
        >
          <Plus className="w-4 h-4" /> Novo Retiro
        </Button>
      </div>

      {/* Main Grid */}
      <div className="grid grid-cols-1 lg:grid-cols-4 gap-8">
        
        {/* Left column: Event Selector */}
        <div className="lg:col-span-1 space-y-4">
          <h2 className="text-sm font-bold uppercase tracking-wider text-muted-foreground">
            Selecione o Encontro
          </h2>
          {loadingRetreats ? (
            <div className="space-y-3">
              {[1, 2].map(i => (
                <div key={i} className="h-20 w-full rounded-xl bg-muted animate-pulse" />
              ))}
            </div>
          ) : retreats.length === 0 ? (
            <Card className="border-dashed border-border/80 bg-card/20">
              <CardContent className="p-6 text-center">
                <AlertTriangle className="w-8 h-8 text-muted-foreground mx-auto mb-2" />
                <p className="text-sm font-semibold text-muted-foreground">Nenhum evento cadastrado.</p>
              </CardContent>
            </Card>
          ) : (
            <div className="flex flex-col gap-2.5">
              {retreats.map(retreat => {
                const isSelected = selectedRetreat?.id === retreat.id;
                return (
                  <button
                    key={retreat.id}
                    onClick={() => setSelectedRetreat(retreat)}
                    className={`w-full text-left p-4 rounded-xl border transition-all duration-300 ${
                      isSelected 
                        ? "bg-primary text-primary-foreground border-primary shadow-lg shadow-primary/20 scale-[1.02]" 
                        : "bg-card/45 hover:bg-muted/40 text-foreground border-border/50"
                    }`}
                  >
                    <div className="font-bold truncate text-base leading-tight">
                      {retreat.title}
                    </div>
                    <div className={`text-xs mt-2 flex items-center gap-1.5 ${isSelected ? "text-primary-foreground/80" : "text-muted-foreground"}`}>
                      <Calendar className="w-3.5 h-3.5" />
                      <span>
                        {retreat.start_date ? new Date(retreat.start_date).toLocaleDateString("pt-BR") : "S/D"}
                      </span>
                    </div>
                    <div className="flex justify-between items-center mt-3 pt-2.5 border-t border-border/10">
                      <span className={`text-xs font-bold px-2 py-0.5 rounded-full uppercase ${
                        retreat.status === 'ativo' 
                          ? 'bg-emerald-500/10 text-emerald-500 border border-emerald-500/25' 
                          : retreat.status === 'rascunho'
                          ? 'bg-zinc-500/10 text-zinc-500 border border-zinc-500/25'
                          : 'bg-red-500/10 text-red-500 border border-red-500/25'
                      }`}>
                        {retreat.status}
                      </span>
                      <span className="text-sm font-extrabold">
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
        <div className="lg:col-span-3 space-y-6">
          {selectedRetreat ? (
            <>
              {/* Event Quick Info & Actions */}
              <div className="bg-card/40 border border-border/50 rounded-2xl p-6 backdrop-blur-sm flex flex-col md:flex-row md:items-center justify-between gap-6">
                <div>
                  <div className="flex items-center gap-3 flex-wrap">
                    <h2 className="text-2xl font-bold text-foreground">{selectedRetreat.title}</h2>
                    <span className={`px-2.5 py-0.5 rounded-full text-xs font-bold uppercase ${
                      selectedRetreat.status === 'ativo' 
                        ? 'bg-emerald-500/15 text-emerald-500' 
                        : selectedRetreat.status === 'rascunho'
                        ? 'bg-amber-500/15 text-amber-500'
                        : 'bg-red-500/15 text-red-500'
                    }`}>
                      {selectedRetreat.status}
                    </span>
                  </div>
                  <p className="text-muted-foreground text-sm mt-1 max-w-xl line-clamp-2">
                    {selectedRetreat.description || "Sem descrição cadastrada."}
                  </p>
                  <div className="flex flex-wrap gap-4 mt-4 text-xs text-muted-foreground">
                    <div className="flex items-center gap-1.5">
                      <MapPin className="w-4 h-4 shrink-0" />
                      <span>{selectedRetreat.location_text || "Local não informado"}</span>
                    </div>
                    <div className="flex items-center gap-1.5">
                      <Clock className="w-4 h-4 shrink-0" />
                      <span>
                        {selectedRetreat.start_date && new Date(selectedRetreat.start_date).toLocaleDateString("pt-BR")} até {selectedRetreat.end_date && new Date(selectedRetreat.end_date).toLocaleDateString("pt-BR")}
                      </span>
                    </div>
                    {selectedRetreat.forms?.name && (
                      <div className="flex items-center gap-1.5">
                        <FileText className="w-4 h-4 shrink-0" />
                        <span className="font-semibold text-primary">Formulário: {selectedRetreat.forms.name}</span>
                      </div>
                    )}
                  </div>
                </div>

                <div className="flex items-center gap-2 shrink-0 self-start md:self-auto">
                  <Button 
                    variant="outline" 
                    size="sm"
                    className="rounded-lg hover:bg-muted cursor-pointer flex items-center gap-1"
                    onClick={() => handleEditEventClick(selectedRetreat)}
                  >
                    <Edit className="w-3.5 h-3.5" /> Editar
                  </Button>
                  <Button 
                    variant="ghost" 
                    size="sm"
                    className="rounded-lg text-red-500 hover:bg-red-500/10 cursor-pointer flex items-center gap-1"
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
                      Este evento está salvo como rascunho. Ele não está visível para os membros da igreja e o formulário de inscrição associado está desativado. Para liberar as inscrições e torná-lo ativo, siga os passos recomendados.
                    </p>

                    <div className="w-full text-left bg-muted/20 border border-border/30 rounded-xl p-5 mb-6 space-y-4">
                      <h4 className="text-xs font-bold uppercase tracking-wider text-muted-foreground">
                        Próximas Ações
                      </h4>
                      <ul className="space-y-4 text-sm text-foreground">
                        <li className="flex items-start gap-3">
                          <Check className="h-4 w-4 text-emerald-500 shrink-0 mt-0.5" />
                          <div>
                            <span className="font-semibold block">Configurar Datas e Preço</span>
                            <span className="text-xs text-muted-foreground block mt-0.5">
                              Preço atual: {selectedRetreat.price && selectedRetreat.price > 0 ? `R$ ${Number(selectedRetreat.price).toFixed(2)}` : "Grátis"}.
                              Capacidade: {selectedRetreat.max_participants || 100} pessoas.
                            </span>
                          </div>
                        </li>
                        <li className="flex items-start gap-3">
                          <Check className="h-4 w-4 text-emerald-500 shrink-0 mt-0.5" />
                          <div>
                            <span className="font-semibold block">Vincular Ficha de Inscrição</span>
                            <span className="text-xs text-muted-foreground block mt-0.5">
                              {selectedRetreat.forms?.name ? (
                                <>Vinculada a: <strong className="text-primary">{selectedRetreat.forms.name}</strong></>
                              ) : (
                                "Usará a ficha geral do sistema (padrão)."
                              )}
                            </span>
                          </div>
                        </li>
                        <li className="flex items-start gap-3">
                          <div className="h-4 w-4 rounded-full border-2 border-primary shrink-0 mt-0.5 flex items-center justify-center text-[10px] font-bold text-primary">3</div>
                          <div>
                            <span className="font-semibold block">Ativar e Publicar o Retiro</span>
                            <span className="text-xs text-muted-foreground block mt-0.5">
                              Clique no botão abaixo para colocar o evento no ar e liberar as inscrições.
                            </span>
                          </div>
                        </li>
                      </ul>
                    </div>

                    <div className="flex flex-col sm:flex-row gap-3 w-full justify-center">
                      <Button
                        onClick={() => handleActivateEvent(selectedRetreat.id)}
                        className="bg-primary hover:bg-primary/90 text-primary-foreground font-bold cursor-pointer transition-all active:scale-95 py-2.5 px-6 rounded-lg flex items-center justify-center gap-2"
                      >
                        <Check className="h-4 w-4" /> Ativar e Publicar Retiro
                      </Button>
                      <Button
                        variant="outline"
                        onClick={() => handleEditEventClick(selectedRetreat)}
                        className="cursor-pointer transition-all active:scale-95 py-2.5 px-6 rounded-lg flex items-center justify-center gap-2"
                      >
                        <Edit className="h-4 w-4" /> Editar Detalhes
                      </Button>
                    </div>
                  </div>
                </Card>
              ) : (
                <>
                  {/* Statistics Row */}
                  <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
                    <Card className="border-border/40 bg-card/15 shadow-sm">
                      <CardHeader className="p-4 pb-2">
                        <CardDescription className="text-xs font-semibold uppercase tracking-wider">Inscritos</CardDescription>
                      </CardHeader>
                      <CardContent className="p-4 pt-0">
                        <div className="flex items-baseline gap-2">
                          <span className="text-2xl font-bold text-foreground">{totalInscritos}</span>
                          <span className="text-xs text-muted-foreground">de {selectedRetreat.max_participants || 100}</span>
                        </div>
                        <div className="w-full bg-muted rounded-full h-1.5 mt-2 overflow-hidden">
                          <div className="bg-primary h-1.5 rounded-full" style={{ width: `${Math.min(percentualLote, 100)}%` }} />
                        </div>
                        <div className="text-[10px] text-muted-foreground mt-1">{percentualLote}% preenchido</div>
                      </CardContent>
                    </Card>

                    <Card className="border-border/40 bg-card/15 shadow-sm">
                      <CardHeader className="p-4 pb-2">
                        <CardDescription className="text-xs font-semibold uppercase tracking-wider">Pagos / Pendentes</CardDescription>
                      </CardHeader>
                      <CardContent className="p-4 pt-0">
                        <div className="flex items-baseline gap-2">
                          <span className="text-2xl font-bold text-emerald-500">{totalPagos}</span>
                          <span className="text-sm text-muted-foreground">/</span>
                          <span className="text-xl font-bold text-amber-500">{totalPendentes}</span>
                        </div>
                        <p className="text-[10px] text-muted-foreground mt-2">Pagamento manual aprovado</p>
                      </CardContent>
                    </Card>

                    <Card className="border-border/40 bg-card/15 shadow-sm">
                      <CardHeader className="p-4 pb-2">
                        <CardDescription className="text-xs font-semibold uppercase tracking-wider">Total Arrecadado</CardDescription>
                      </CardHeader>
                      <CardContent className="p-4 pt-0">
                        <div className="text-2xl font-extrabold text-foreground">
                          R$ {valorTotalArrecadado.toFixed(2)}
                        </div>
                        <p className="text-[10px] text-muted-foreground mt-2">Confirmado em conta</p>
                      </CardContent>
                    </Card>

                    <Card className="border-border/40 bg-card/15 shadow-sm">
                      <CardHeader className="p-4 pb-2">
                        <CardDescription className="text-xs font-semibold uppercase tracking-wider">Valor Pendente</CardDescription>
                      </CardHeader>
                      <CardContent className="p-4 pt-0">
                        <div className="text-2xl font-extrabold text-amber-500">
                          R$ {valorPendente.toFixed(2)}
                        </div>
                        <p className="text-[10px] text-muted-foreground mt-2">Aguardando comprovação</p>
                      </CardContent>
                    </Card>
                  </div>

                  {/* Navigation Tabs */}
                  <Tabs value={activeTab} onValueChange={(val) => setActiveTab(val as any)} className="w-full">
                    <TabsList variant="line" className="border-b border-border/70 bg-transparent p-0 rounded-none w-full justify-start h-auto gap-6 overflow-x-auto no-scrollbar scroll-smooth">
                      <TabsTrigger value="events" className="pb-3 rounded-none text-sm font-bold flex items-center gap-2 cursor-pointer">
                        <Users className="w-4 h-4" /> Geral & Lotação
                      </TabsTrigger>
                      <TabsTrigger value="rooms" className="pb-3 rounded-none text-sm font-bold flex items-center gap-2 cursor-pointer">
                        <Bed className="w-4 h-4" /> Alojamentos / Quartos
                      </TabsTrigger>
                      <TabsTrigger value="finance" className="pb-3 rounded-none text-sm font-bold flex items-center gap-2 cursor-pointer">
                        <DollarSign className="w-4 h-4" /> Controle Financeiro
                      </TabsTrigger>
                      {selectedRetreat.form_id && (
                        <TabsTrigger value="dashboard" className="pb-3 rounded-none text-sm font-bold flex items-center gap-2 cursor-pointer">
                          <BarChart3 className="w-4 h-4" /> Dashboard Analítico
                        </TabsTrigger>
                      )}
                    </TabsList>
                  </Tabs>

                  {/* Tab Contents */}
                  <div className="space-y-4">
                    {/* Search Bar & Export button */}
                    <div className="flex flex-col md:flex-row items-center justify-between gap-4">
                      <div className="relative w-full md:max-w-md">
                        <Input
                          placeholder="Pesquisar por nome, CPF, alojamento..."
                          value={searchTerm}
                          onChange={(e) => setSearchTerm(e.target.value)}
                          className="pl-4 rounded-xl border border-border bg-card/10"
                        />
                      </div>
                      <Button
                        variant="outline"
                        onClick={handleExportData}
                        className="w-full md:w-auto rounded-xl flex items-center justify-center gap-2 cursor-pointer text-xs"
                        disabled={registrations.length === 0}
                      >
                        <Download className="w-4 h-4" /> Exportar Dados (JSON)
                      </Button>
                    </div>

                    {loadingRegistrations ? (
                      <div className="flex flex-col items-center justify-center py-12 gap-2 text-muted-foreground">
                        <Loader2 className="w-8 h-8 animate-spin text-primary" />
                        <p className="text-sm">Carregando inscrições...</p>
                      </div>
                    ) : registrations.length === 0 ? (
                      <div className="text-center py-16 bg-muted/10 rounded-2xl border border-dashed border-border/80">
                        <Users className="w-12 h-12 text-muted-foreground mx-auto mb-3" />
                        <h3 className="text-lg font-bold text-foreground">Nenhuma inscrição realizada</h3>
                        <p className="text-muted-foreground text-sm max-w-sm mx-auto mt-1.5">
                          Os irmãos serão listados aqui assim que se inscreverem neste retiro na área pública.
                        </p>
                      </div>
                    ) : filteredRegistrations.length === 0 ? (
                      <div className="text-center py-12 text-muted-foreground">
                        Nenhum resultado encontrado para a busca "{searchTerm}".
                      </div>
                    ) : (
                      <>
                        {/* General / Lotação Tab */}
                        {activeTab === "events" && (
                          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                            {filteredRegistrations.map((reg) => (
                              <Card key={reg.id} className="border-border/40 bg-card/20 hover:border-primary/20 transition-all duration-300">
                                <CardHeader className="p-4 pb-2">
                                  <div className="flex justify-between items-start gap-4">
                                    <div>
                                      <CardTitle className="text-base font-bold">{reg.profiles?.full_name || (reg.guest_data as any)?.full_name || "Desconhecido"}</CardTitle>
                                      <CardDescription className="text-xs">{reg.profiles?.email || (reg.guest_data as any)?.email || "E-mail não cadastrado"}</CardDescription>
                                    </div>
                                    <Badge 
                                      variant="outline" 
                                      className={`uppercase text-[10px] font-bold shrink-0 ${
                                        reg.paid 
                                          ? "border-emerald-500/30 bg-emerald-500/10 text-emerald-500 dark:border-emerald-500/20 dark:bg-emerald-500/5" 
                                          : "border-amber-500/30 bg-amber-500/10 text-amber-500 dark:border-amber-500/20 dark:bg-amber-500/5"
                                      }`}
                                    >
                                      {reg.paid ? "Pago" : "Pendente"}
                                    </Badge>
                                  </div>
                                </CardHeader>
                                <CardContent className="p-4 pt-0 text-xs text-muted-foreground space-y-2">
                                  <div className="flex justify-between">
                                    <span>Telefone:</span>
                                    <span className="font-semibold text-foreground">{reg.profiles?.phone || (reg.guest_data as any)?.phone || "S/T"}</span>
                                  </div>
                                  <div className="flex justify-between">
                                    <span>CPF:</span>
                                    <span className="font-semibold text-foreground">{reg.profiles?.cpf || (reg.guest_data as any)?.cpf || "S/C"}</span>
                                  </div>
                                  <div className="flex justify-between">
                                    <span>Alojamento:</span>
                                    <span className="font-semibold text-foreground">{reg.room_allocation || "Não alocado"}</span>
                                  </div>
                                  {reg.custom_responses && Object.keys(reg.custom_responses as object).length > 0 && (
                                    <div className="border-t border-border/30 pt-2 mt-2">
                                      <span className="font-bold text-foreground text-[10px] uppercase block mb-1">Respostas do Formulário</span>
                                      <div className="grid grid-cols-2 gap-1.5 text-[10px]">
                                        {Object.entries(reg.custom_responses as Record<string, any>).map(([key, val]) => {
                                          const displayVal = Array.isArray(val) ? val.join(', ') : String(val);
                                          return (
                                            <TooltipProvider key={key}>
                                              <Tooltip>
                                                <TooltipTrigger asChild>
                                                  <div className="truncate cursor-help">
                                                    <span className="opacity-80">{key}: </span>
                                                    <span className="font-medium text-foreground">{displayVal}</span>
                                                  </div>
                                                </TooltipTrigger>
                                                <TooltipContent>
                                                  <p className="text-xs">{key}: {displayVal}</p>
                                                </TooltipContent>
                                              </Tooltip>
                                            </TooltipProvider>
                                          );
                                        })}
                                      </div>
                                    </div>
                                  )}
                                  {reg.notes && (
                                    <div className="bg-amber-500/5 border border-amber-500/10 p-2 rounded-lg mt-2 text-[10px] text-amber-600 dark:text-amber-400">
                                      <strong>Observações:</strong> {reg.notes}
                                    </div>
                                  )}
                                  <div className="flex justify-end gap-2 border-t border-border/30 pt-2.5 mt-2.5">
                                    <Button
                                      variant="ghost"
                                      size="sm"
                                      onClick={() => handleDeleteRegistration(reg)}
                                      className="h-7 px-2.5 text-red-500 hover:bg-red-500/10 hover:text-red-600 rounded-md cursor-pointer flex items-center gap-1.5 text-xs font-semibold"
                                    >
                                      <Trash2 className="h-3.5 w-3.5" />
                                      Excluir Inscrição
                                    </Button>
                                  </div>
                                </CardContent>
                              </Card>
                            ))}
                          </div>
                        )}

                        {/* Room Lodging Allocation Tab */}
                        {activeTab === "rooms" && (
                          <div className="border border-border/60 bg-card/20 rounded-2xl overflow-hidden">
                            <div className="overflow-x-auto">
                              <Table>
                                <TableHeader className="bg-muted/65 border-b border-border/70">
                                  <TableRow>
                                    <TableHead className="p-4 font-semibold text-muted-foreground">Participante</TableHead>
                                    <TableHead className="p-4 font-semibold text-muted-foreground">Contato</TableHead>
                                    <TableHead className="p-4 font-semibold text-muted-foreground">Alojamento Atual</TableHead>
                                    <TableHead className="p-4 font-semibold text-muted-foreground">Alocar / Alterar Quarto</TableHead>
                                  </TableRow>
                                </TableHeader>
                                <TableBody className="divide-y divide-border/40 text-foreground">
                                  {filteredRegistrations.map((reg) => (
                                    <TableRow key={reg.id} className="hover:bg-muted/15 transition-colors">
                                      <TableCell className="p-4 font-bold">{reg.profiles?.full_name || (reg.guest_data as any)?.full_name || "Desconhecido"}</TableCell>
                                      <TableCell className="p-4 text-xs text-muted-foreground">
                                        <div>{reg.profiles?.phone || (reg.guest_data as any)?.phone || "Sem tel"}</div>
                                        <div>{reg.profiles?.email || (reg.guest_data as any)?.email || ""}</div>
                                      </TableCell>
                                      <TableCell className="p-4">
                                        {reg.room_allocation ? (
                                          <Badge variant="secondary" className="bg-primary/10 text-primary hover:bg-primary/15 border-transparent font-bold">
                                            {reg.room_allocation}
                                          </Badge>
                                        ) : (
                                          <span className="text-muted-foreground text-xs italic">Não alocado</span>
                                        )}
                                      </TableCell>
                                      <TableCell className="p-4">
                                        <div className="flex items-center gap-2 max-w-[200px]">
                                          <Input
                                            placeholder="Ex: Quarto 12, Chalé B"
                                            defaultValue={reg.room_allocation || ""}
                                            onBlur={(e) => {
                                              if (e.target.value !== (reg.room_allocation || "")) {
                                                handleUpdateRoom(reg.id, e.target.value);
                                              }
                                            }}
                                            className="h-8 rounded-lg text-xs"
                                          />
                                        </div>
                                      </TableCell>
                                    </TableRow>
                                  ))}
                                </TableBody>
                              </Table>
                            </div>
                          </div>
                        )}

                        {/* Finance Control Tab */}
                        {activeTab === "finance" && (
                          <div className="border border-border/60 bg-card/20 rounded-2xl overflow-hidden">
                            <div className="overflow-x-auto">
                              <Table>
                                <TableHeader className="bg-muted/65 border-b border-border/70">
                                  <TableRow>
                                    <TableHead className="p-4 font-semibold text-muted-foreground">Participante</TableHead>
                                    <TableHead className="p-4 font-semibold text-muted-foreground">Status de Pagamento</TableHead>
                                    <TableHead className="p-4 font-semibold text-muted-foreground">Método / Referência</TableHead>
                                    <TableHead className="p-4 font-semibold text-center text-muted-foreground">Ações Financeiras</TableHead>
                                  </TableRow>
                                </TableHeader>
                                <TableBody className="divide-y divide-border/40 text-foreground">
                                  {filteredRegistrations.map((reg) => (
                                    <TableRow key={reg.id} className="hover:bg-muted/15 transition-colors">
                                      <TableCell className="p-4">
                                        <div className="font-bold">{reg.profiles?.full_name || (reg.guest_data as any)?.full_name || "Desconhecido"}</div>
                                        <div className="text-xs text-muted-foreground">CPF: {reg.profiles?.cpf || (reg.guest_data as any)?.cpf || "Não cadastrado"}</div>
                                      </TableCell>
                                      <TableCell className="p-4">
                                        <Badge 
                                          variant="outline" 
                                          className={`inline-flex items-center gap-1.5 px-3 py-1 font-bold text-xs ${
                                            reg.paid 
                                              ? "border-emerald-500/30 bg-emerald-500/10 text-emerald-500 dark:border-emerald-500/20 dark:bg-emerald-500/5" 
                                              : "border-amber-500/30 bg-amber-500/10 text-amber-500 dark:border-amber-500/20 dark:bg-amber-500/5"
                                          }`}
                                        >
                                          {reg.paid ? <Check className="w-3.5 h-3.5" /> : <X className="w-3.5 h-3.5" />}
                                          {reg.paid ? "Pago" : "Pendente"}
                                        </Badge>
                                      </TableCell>
                                      <TableCell className="p-4 text-xs">
                                        {reg.paid ? (
                                          <div>
                                            <span className="font-semibold text-muted-foreground uppercase text-[10px]">Método:</span> {reg.payment_method || "PIX"}
                                            <TooltipProvider>
                                              <Tooltip>
                                                <TooltipTrigger asChild>
                                                  <div className="mt-0.5 text-muted-foreground truncate max-w-xs cursor-help">
                                                    <span className="font-semibold text-muted-foreground uppercase text-[10px]">Ref:</span> {reg.payment_reference || "N/I"}
                                                  </div>
                                                </TooltipTrigger>
                                                {reg.payment_reference && (
                                                  <TooltipContent>
                                                    <p className="text-xs">{reg.payment_reference}</p>
                                                  </TooltipContent>
                                                )}
                                              </Tooltip>
                                            </TooltipProvider>
                                          </div>
                                        ) : (
                                          <span className="text-muted-foreground italic">Aguardando</span>
                                        )}
                                      </TableCell>
                                      <TableCell className="p-4 text-center">
                                        <Button
                                          variant={reg.paid ? "outline" : "default"}
                                          size="sm"
                                          onClick={() => handleTogglePayment(reg)}
                                          className={`rounded-lg text-xs cursor-pointer ${
                                            reg.paid 
                                              ? "hover:bg-amber-500/10 hover:text-amber-500 hover:border-amber-500/30" 
                                              : "bg-emerald-600 hover:bg-emerald-500 text-white shadow-sm"
                                          }`}
                                        >
                                          {reg.paid ? "Estornar / Pendente" : "Aprovar Pagamento"}
                                        </Button>
                                      </TableCell>
                                    </TableRow>
                                  ))}
                                </TableBody>
                              </Table>
                            </div>
                          </div>
                        )}

                        {/* Dashboard Analítico Tab */}
                        {activeTab === "dashboard" && selectedFormTemplate && (
                          <div className="space-y-6">
                            {/* KPI Cards */}
                            <div className="grid grid-cols-1 gap-4 sm:grid-cols-3">
                              <div className="rounded-xl border border-border/60 bg-card p-4 shadow-sm text-left">
                                <span className="text-[10px] font-bold tracking-wider text-muted-foreground uppercase">
                                  Total de Inscrições
                                </span>
                                <div className="mt-1 text-2xl font-black text-foreground">
                                  {totalInscritos}
                                </div>
                              </div>

                              <div className="rounded-xl border border-border/60 bg-card p-4 shadow-sm text-left">
                                <span className="text-[10px] font-bold tracking-wider text-muted-foreground uppercase">
                                  Faturamento Estimado
                                </span>
                                <div className="mt-1 text-2xl font-black text-emerald-600 dark:text-emerald-500">
                                  {new Intl.NumberFormat("pt-BR", { style: "currency", currency: "BRL" }).format(
                                    valorTotalArrecadado + valorPendente
                                  )}
                                </div>
                                <span className="text-[9px] text-muted-foreground mt-0.5 block">
                                  Arrecadado: {new Intl.NumberFormat("pt-BR", { style: "currency", currency: "BRL" }).format(valorTotalArrecadado)} | Pendente: {new Intl.NumberFormat("pt-BR", { style: "currency", currency: "BRL" }).format(valorPendente)}
                                </span>
                              </div>

                              <div className="rounded-xl border border-border/60 bg-card p-4 shadow-sm text-left">
                                <span className="text-[10px] font-bold tracking-wider text-muted-foreground uppercase">
                                  Ticket Médio por Resposta
                                </span>
                                <div className="mt-1 text-2xl font-black text-foreground">
                                  {new Intl.NumberFormat("pt-BR", { style: "currency", currency: "BRL" }).format(
                                    totalInscritos > 0 ? (valorTotalArrecadado + valorPendente) / totalInscritos : 0
                                  )}
                                </div>
                              </div>
                            </div>

                            {/* Choice Fields Breakdown Section */}
                            <div className="space-y-4 text-left">
                              <h3 className="text-sm font-bold text-foreground border-b border-border pb-2">
                                Distribuição de Respostas de Opção
                              </h3>
                              {loadingFormTemplate ? (
                                <div className="text-center py-6 text-xs text-muted-foreground">
                                  Carregando estatísticas...
                                </div>
                              ) : (
                                <div className="grid grid-cols-1 gap-4 md:grid-cols-2">
                                  {selectedFormTemplate.fields?.map((field: any) => {
                                    const isChoice = ["select", "radio", "checkbox"].includes(field.type);
                                    const isNumber = field.type === "number";
                                    const isDate = field.type === "date";
                                    const isText = ["text", "textarea"].includes(field.type);

                                    // Render Choice distribution
                                    if (isChoice && field.options && field.options.length > 0) {
                                      const breakdown = getChoiceBreakdown(field, registrations);
                                      const totalFieldResponses = Object.values(breakdown).reduce((sum, c) => sum + c, 0);

                                      return (
                                        <div
                                          key={field.id}
                                          className="rounded-xl border border-border/60 bg-card/10 p-5 space-y-3"
                                        >
                                          <div className="flex items-center justify-between border-b border-border/30 pb-1.5">
                                            <span className="text-xs font-bold text-foreground">
                                              {field.label}
                                            </span>
                                            <span className="text-[10px] font-semibold text-muted-foreground bg-muted px-2 py-0.5 rounded-full">
                                              {field.type === "select" ? "Dropdown" : field.type === "radio" ? "Escolha Única" : "Multi-Escolha"}
                                            </span>
                                          </div>

                                          <div className="space-y-3 pt-1">
                                            {field.options?.map((opt: string) => {
                                              const count = breakdown[opt] || 0;
                                              const pct = totalFieldResponses > 0 ? (count / totalFieldResponses) * 100 : 0;
                                              const modifier = field.priceModifiers?.[opt];

                                              return (
                                                <div key={opt} className="space-y-1.5">
                                                  <div className="flex items-center justify-between text-xs">
                                                    <span className="font-medium text-foreground flex items-center gap-1.5">
                                                      {opt}
                                                      {modifier !== undefined && modifier !== 0 && (
                                                        <span className={`text-[9px] font-bold px-1 rounded ${
                                                          modifier > 0 ? "text-emerald-600 bg-emerald-500/10" : "text-destructive bg-destructive/10"
                                                        }`}>
                                                          {modifier > 0 ? `+ R$ ${modifier}` : `- R$ ${Math.abs(modifier)}`}
                                                        </span>
                                                      )}
                                                    </span>
                                                    <span className="font-bold text-muted-foreground">
                                                      {count} ({pct.toFixed(0)}%)
                                                    </span>
                                                  </div>
                                                  <div className="h-2 w-full bg-muted rounded-full overflow-hidden">
                                                    <div
                                                      className="h-full bg-primary rounded-full transition-all duration-300"
                                                      style={{ width: `${pct}%` }}
                                                    />
                                                  </div>
                                                </div>
                                              );
                                            })}
                                          </div>
                                        </div>
                                      );
                                    }

                                    // Render Number statistics
                                    if (isNumber) {
                                      const stats = getNumberStats(field, registrations);
                                      if (stats.count === 0) return null;

                                      return (
                                        <div
                                          key={field.id}
                                          className="rounded-xl border border-border/60 bg-card/10 p-5 space-y-3"
                                        >
                                          <div className="flex items-center justify-between border-b border-border/30 pb-1.5">
                                            <span className="text-xs font-bold text-foreground font-semibold">
                                              {field.label}
                                            </span>
                                            <span className="text-[10px] font-semibold text-muted-foreground bg-muted px-2 py-0.5 rounded-full">
                                              Numérico
                                            </span>
                                          </div>

                                          <div className="grid grid-cols-2 gap-3 pt-2 text-xs">
                                            <div className="bg-muted/30 p-2 rounded-lg text-left">
                                              <span className="text-[9px] text-muted-foreground block font-bold uppercase tracking-wider">Média</span>
                                              <span className="text-base font-black text-foreground">{stats.avg.toFixed(1)}</span>
                                            </div>
                                            <div className="bg-muted/30 p-2 rounded-lg text-left">
                                              <span className="text-[9px] text-muted-foreground block font-bold uppercase tracking-wider">Soma Total</span>
                                              <span className="text-base font-black text-foreground">{stats.sum}</span>
                                            </div>
                                            <div className="bg-muted/30 p-2 rounded-lg text-left">
                                              <span className="text-[9px] text-muted-foreground block font-bold uppercase tracking-wider">Mínimo</span>
                                              <span className="text-base font-black text-foreground">{stats.min}</span>
                                            </div>
                                            <div className="bg-muted/30 p-2 rounded-lg text-left">
                                              <span className="text-[9px] text-muted-foreground block font-bold uppercase tracking-wider">Máximo</span>
                                              <span className="text-base font-black text-foreground">{stats.max}</span>
                                            </div>
                                          </div>
                                        </div>
                                      );
                                    }

                                    // Render Date trends
                                    if (isDate) {
                                      const dateTrends = getDateBreakdown(field, registrations);
                                      if (dateTrends.length === 0) return null;
                                      const maxCount = Math.max(...dateTrends.map(t => t.count));

                                      return (
                                        <div
                                          key={field.id}
                                          className="rounded-xl border border-border/60 bg-card/10 p-5 space-y-3"
                                        >
                                          <div className="flex items-center justify-between border-b border-border/30 pb-1.5">
                                            <span className="text-xs font-bold text-foreground">
                                              {field.label}
                                            </span>
                                            <span className="text-[10px] font-semibold text-muted-foreground bg-muted px-2 py-0.5 rounded-full">
                                              Data (Tendências)
                                            </span>
                                          </div>

                                          <div className="space-y-3 pt-1 max-h-[220px] overflow-y-auto pr-1">
                                            {dateTrends.map(({ date, count }) => {
                                              const pct = maxCount > 0 ? (count / maxCount) * 100 : 0;
                                              const formattedDate = new Date(date + "T00:00:00").toLocaleDateString("pt-BR");

                                              return (
                                                <div key={date} className="space-y-1">
                                                  <div className="flex items-center justify-between text-xs">
                                                    <span className="font-medium text-foreground">{formattedDate}</span>
                                                    <span className="font-bold text-muted-foreground">{count} {count === 1 ? "resposta" : "respostas"}</span>
                                                  </div>
                                                  <div className="h-1.5 w-full bg-muted rounded-full overflow-hidden">
                                                    <div
                                                      className="h-full bg-primary rounded-full transition-all duration-300"
                                                      style={{ width: `${pct}%` }}
                                                    />
                                                  </div>
                                                </div>
                                              );
                                            })}
                                          </div>
                                        </div>
                                      );
                                    }

                                    // Render Text / Textarea insights
                                    if (isText) {
                                      const allTextResponses = registrations
                                        .map((reg) => {
                                          if (!reg.custom_responses) return null;
                                          const val = (reg.custom_responses as Record<string, any>)[field.label];
                                          return val && String(val).trim() !== "" ? String(val).trim() : null;
                                        })
                                        .filter((v): v is string => v !== null);

                                      return (
                                        <div
                                          key={field.id}
                                          className="rounded-xl border border-border/60 bg-card/10 p-5 space-y-3 font-medium"
                                        >
                                          <div className="flex items-center justify-between border-b border-border/30 pb-1.5">
                                            <span className="text-xs font-bold text-foreground">
                                              {field.label}
                                            </span>
                                            <span className="text-[10px] font-semibold text-muted-foreground bg-muted px-2 py-0.5 rounded-full">
                                              {allTextResponses.length} {allTextResponses.length === 1 ? "resposta" : "respostas"}
                                            </span>
                                          </div>

                                          {allTextResponses.length === 0 ? (
                                            <div className="text-xs italic text-muted-foreground py-4 text-center">
                                              Nenhuma resposta preenchida.
                                            </div>
                                          ) : (
                                            <div className="space-y-2 max-h-[180px] overflow-y-auto pr-1">
                                              {allTextResponses.map((item, idx) => (
                                                <div
                                                  key={idx}
                                                  className="bg-muted/30 p-2.5 rounded-lg text-left text-xs border-l-2 border-primary/40 text-foreground break-words leading-relaxed"
                                                >
                                                  "{item}"
                                                </div>
                                              ))}
                                            </div>
                                          )}
                                        </div>
                                      );
                                    }

                                    return null;
                                  })}
                                </div>
                              )}
                            </div>
                          </div>
                        )}
                      </>
                    )}
                  </div>
                </>
              )}
            </>
          ) : (
            <Card className="border-dashed border-border/80 bg-card/10 py-16 text-center">
              <CardContent className="space-y-4">
                <Calendar className="w-16 h-16 text-muted-foreground mx-auto" />
                <h3 className="text-xl font-bold text-foreground">Nenhum evento selecionado</h3>
                <p className="text-muted-foreground text-sm max-w-sm mx-auto">
                  Crie um novo retiro ou selecione um existente na barra lateral esquerda para gerenciar as inscrições e logística.
                </p>
              </CardContent>
            </Card>
          )}
        </div>

      </div>

      {/* dialog para Criar / Editar Retiro */}
      <Dialog open={isEventDialogOpen} onOpenChange={setIsEventDialogOpen}>
        <DialogContent className="sm:max-w-3xl max-w-full rounded-2xl border border-border bg-card p-6 md:p-8 max-h-[90vh] overflow-y-auto custom-scrollbar">
          <DialogHeader>
            <DialogTitle className="text-xl font-bold text-foreground">
              {editingRetreat ? "Editar Encontro/Retiro" : "Criar Novo Encontro/Retiro"}
            </DialogTitle>
            <DialogDescription className="text-muted-foreground">
              Preencha os detalhes logísticos do evento. O retiro pode ser associado a um formulário customizado do sistema.
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
                  <Textarea {...field} value={field.value || ""} id="description" placeholder="Informações detalhadas sobre o retiro (levar bíblia, prato, etc)..." className="rounded-md min-h-[80px]" />
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

            <Field>
              <FieldLabel htmlFor="registration_deadline">Prazo Limite de Inscrição (Opcional)</FieldLabel>
              <Controller
                name="registration_deadline"
                control={control}
                render={({ field, fieldState }) => (
                  <>
                    <Input {...field} value={field.value || ""} id="registration_deadline" type="date" className="rounded-md" />
                    {fieldState.error && <FieldError>{fieldState.error.message}</FieldError>}
                    <span className="text-[11px] text-muted-foreground mt-1 block">
                      Se definido, as inscrições e o formulário serão desativados automaticamente após esta data.
                    </span>
                  </>
                )}
              />
            </Field>

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
                  render={({ field, fieldState }) => (
                    <>
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
                      <div className="flex items-center gap-3 mt-1.5 text-xs">
                        <a
                          href="/gestao/formularios"
                          target="_blank"
                          rel="noopener noreferrer"
                          className="text-primary hover:text-primary/80 font-medium flex items-center gap-1 transition-colors"
                        >
                          <Plus className="h-3.5 w-3.5" />
                          Criar novo formulário
                        </a>
                        <span className="text-border/40">•</span>
                        <TooltipProvider>
                          <Tooltip>
                            <TooltipTrigger asChild>
                              <button
                                type="button"
                                onClick={fetchForms}
                                className="text-muted-foreground hover:text-foreground font-medium flex items-center gap-1 cursor-pointer transition-colors bg-transparent border-0 p-0"
                              >
                                <RefreshCw className="h-3 w-3" />
                                Atualizar lista
                              </button>
                            </TooltipTrigger>
                            <TooltipContent>
                              <p className="text-xs">Recarregar formulários</p>
                            </TooltipContent>
                          </Tooltip>
                        </TooltipProvider>
                      </div>
                      {fieldState.error && <FieldError>{fieldState.error.message}</FieldError>}
                    </>
                  )}
                />
              </Field>
            </div>

            <DialogFooter className="pt-4 border-t border-border/40">
              <Button 
                type="button" 
                variant="outline" 
                onClick={() => setIsEventDialogOpen(false)}
                className="rounded-lg hover:bg-muted cursor-pointer"
                disabled={submitting}
              >
                Cancelar
              </Button>
              <Button 
                type="submit" 
                className="rounded-lg cursor-pointer"
                disabled={submitting}
              >
                {submitting && <Loader2 className="w-4 h-4 animate-spin mr-2" />}
                {editingRetreat ? "Salvar Alterações" : "Criar Retiro"}
              </Button>
            </DialogFooter>
          </form>
        </DialogContent>
      </Dialog>
    </div>
  );
}
