/**
 * @file KPIBuilderDialog.tsx
 * @description Redesigned interactive KPI Builder modal based on Stitch prototype design.
 * Features 2-column reactive editor with real-time card preview, live formula synthesis,
 * active metric reordering, and 1-click preset templates.
 */

import { useState, useMemo } from "react";
import {
  SlidersHorizontal,
  Plus,
  Trash2,
  Edit3,
  RotateCcw,
  Users,
  DollarSign,
  Bed,
  CheckCircle2,
  Clock,
  AlertCircle,
  TrendingUp,
  BarChart2,
  Check,
  Sparkles,
  LayoutDashboard,
  ArrowUp,
  ArrowDown,
  Info,
  Percent,
  Pin,
  QrCode,
  Receipt,
  ArrowRight,
} from "lucide-react";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogDescription,
} from "@/components/ui/dialog";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Badge } from "@/components/ui/badge";
import {
  Select,
  SelectContent,
  SelectGroup,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { Tabs, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { Progress } from "@/components/ui/progress";
import type {
  KPIConfig,
  KPIType,
  ComputedKPICard,
  KPICondition,
} from "@/types/eventsFilter";
import type { RegistrationWithDetails } from "./RegistrationDetailDialog";
import {
  computeKpiCard,
  applyKpiCondition,
  type ContextMeta,
} from "@/lib/kpiAggregator";

function generateKpiId(prefix = "kpi"): string {
  if (typeof crypto !== "undefined" && typeof crypto.randomUUID === "function") {
    return `${prefix}-${crypto.randomUUID()}`;
  }
  return `${prefix}-${Math.floor(Math.random() * 1000000)}`;
}

interface KPIBuilderDialogProps {
  isOpen: boolean;
  onClose: () => void;
  configs: KPIConfig[];
  onSaveConfigs: (newConfigs: KPIConfig[]) => void;
  onResetDefaults: () => void;
  data: RegistrationWithDetails[];
  meta: ContextMeta;
}

const ICON_OPTIONS = [
  { id: "users", label: "Pessoas / Inscritos", icon: Users },
  { id: "dollar", label: "Cifrão / Dinheiro", icon: DollarSign },
  { id: "bed", label: "Cama / Quarto", icon: Bed },
  { id: "check", label: "Check / Confirmado", icon: CheckCircle2 },
  { id: "clock", label: "Relógio / Pendente", icon: Clock },
  { id: "alert", label: "Alerta / Atenção", icon: AlertCircle },
  { id: "trending-up", label: "Tendência / Crescimento", icon: TrendingUp },
  { id: "chart", label: "Gráfico / Métricas", icon: BarChart2 },
  { id: "pin", label: "Pin / Localização", icon: Pin },
  { id: "percent", label: "Porcentagem / Taxa", icon: Percent },
  { id: "qr_code", label: "QR Code / PIX", icon: QrCode },
  { id: "receipt", label: "Recibo / Comprovante", icon: Receipt },
];

const COLOR_THEMES: {
  id: NonNullable<KPIConfig["colorTheme"]>;
  label: string;
  bgHex: string;
  accentBar: string;
}[] = [
  { id: "emerald", label: "Esmeralda (Verde)", bgHex: "bg-emerald-500", accentBar: "bg-emerald-500" },
  { id: "blue", label: "Azul (Destaque)", bgHex: "bg-blue-500", accentBar: "bg-blue-500" },
  { id: "amber", label: "Âmbar (Laranja)", bgHex: "bg-amber-500", accentBar: "bg-amber-500" },
  { id: "rose", label: "Rosa (Acento)", bgHex: "bg-rose-500", accentBar: "bg-rose-500" },
  { id: "zinc", label: "Neutro (Zinc)", bgHex: "bg-zinc-800 dark:bg-zinc-200", accentBar: "bg-zinc-900 dark:bg-zinc-100" },
];

const PRESET_TEMPLATES: (KPIConfig & { category: string; description: string })[] = [
  {
    id: "preset-male",
    title: "Público Masculino",
    category: "Gênero",
    description: "Total de irmãos inscritos e proporção sobre as vagas do retiro.",
    type: "count",
    condition: { field: "gender", operator: "eq", value: "masculino" },
    totalBase: "totalFiltered",
    iconName: "users",
    colorTheme: "blue",
    subtitle: "participantes masculinos",
    target: "50%",
  },
  {
    id: "preset-female",
    title: "Público Feminino",
    category: "Gênero",
    description: "Total de irmãs inscritas com monitoramento de acomodação feminina.",
    type: "count",
    condition: { field: "gender", operator: "eq", value: "feminino" },
    totalBase: "totalFiltered",
    iconName: "users",
    colorTheme: "rose",
    subtitle: "participantes femininos",
    target: "50%",
  },
  {
    id: "preset-pix",
    title: "Pagamentos via PIX",
    category: "Mais Usado",
    description: "Inscrições recebidas com liquidação em conta corrente da igreja.",
    type: "count",
    condition: { field: "payment_method", operator: "eq", value: "pix" },
    totalBase: "totalFiltered",
    iconName: "qr_code",
    colorTheme: "emerald",
    subtitle: "compensação imediata",
    target: "80% das quitações",
  },
  {
    id: "preset-unallocated",
    title: "Inscritos Sem Quarto",
    category: "Atenção",
    description: "Pessoas confirmadas que ainda necessitam de alocação nos chalés.",
    type: "count",
    condition: { field: "room_id", operator: "falsy" },
    totalBase: "totalFiltered",
    iconName: "alert",
    colorTheme: "amber",
    subtitle: "necessitam de alocação",
    target: "0 pendências",
  },
  {
    id: "preset-avg-ticket",
    title: "Ticket Médio por Participante",
    category: "Finanças",
    description: "Valor médio arrecadado considerando descontos familiares e lotes.",
    type: "average",
    iconName: "dollar",
    colorTheme: "zinc",
    subtitle: "valor médio por inscrição",
  },
  {
    id: "preset-paid",
    title: "Quitados / 100% Pagos",
    category: "Status",
    description: "Inscrições com pagamento integralmente verificado e liquidado.",
    type: "count",
    condition: { field: "paid", operator: "eq", value: true },
    totalBase: "maxParticipants",
    iconName: "check",
    colorTheme: "emerald",
    subtitle: "inscrições quitadas",
    target: "100% da lotação",
  },
];

export function KPIBuilderDialog({
  isOpen,
  onClose,
  configs,
  onSaveConfigs,
  onResetDefaults,
  data,
  meta,
}: KPIBuilderDialogProps) {
  const [activeTab, setActiveTab] = useState<"editor" | "active" | "templates">("editor");
  const [editingConfigId, setEditingConfigId] = useState<string | null>(null);

  // Form State for Editing/Creating a KPI
  const [title, setTitle] = useState("");
  const [type, setType] = useState<KPIType>("count");
  const [conditionField, setConditionField] = useState<string>("none");
  const [conditionOperator, setConditionOperator] = useState<KPICondition["operator"]>("eq");
  const [conditionValue, setConditionValue] = useState<string>("");
  const [totalBase, setTotalBase] = useState<"totalFiltered" | "maxParticipants" | "totalBeds" | "totalRaw">("totalFiltered");
  const [target, setTarget] = useState("");
  const [iconName, setIconName] = useState<string>("users");
  const [colorTheme, setColorTheme] = useState<NonNullable<KPIConfig["colorTheme"]>>("emerald");
  const [subtitle, setSubtitle] = useState("");

  const resetForm = () => {
    setEditingConfigId(null);
    setTitle("");
    setType("count");
    setConditionField("none");
    setConditionOperator("eq");
    setConditionValue("");
    setTotalBase("totalFiltered");
    setTarget("");
    setIconName("users");
    setColorTheme("emerald");
    setSubtitle("");
  };

  const handleStartCreate = () => {
    resetForm();
    setTitle("Nova Métrica");
    setActiveTab("editor");
  };

  const handleStartEdit = (config: KPIConfig) => {
    setEditingConfigId(config.id);
    setTitle(config.title);
    setType(config.type);
    if (config.condition) {
      setConditionField(config.condition.field);
      setConditionOperator(config.condition.operator);
      setConditionValue(String(config.condition.value ?? ""));
    } else {
      setConditionField("none");
      setConditionOperator("eq");
      setConditionValue("");
    }
    setTotalBase(config.totalBase || "totalFiltered");
    setTarget(config.target || "");
    setIconName(config.iconName || "users");
    setColorTheme(config.colorTheme || "emerald");
    setSubtitle(config.subtitle || "");
    setActiveTab("editor");
  };

  const handleRemoveConfig = (id: string) => {
    const next = configs.filter((c) => c.id !== id);
    onSaveConfigs(next);
  };

  const handleMoveUp = (index: number) => {
    if (index === 0) return;
    const reordered = [...configs];
    const temp = reordered[index - 1];
    reordered[index - 1] = reordered[index];
    reordered[index] = temp;
    onSaveConfigs(reordered);
  };

  const handleMoveDown = (index: number) => {
    if (index === configs.length - 1) return;
    const reordered = [...configs];
    const temp = reordered[index + 1];
    reordered[index + 1] = reordered[index];
    reordered[index] = temp;
    onSaveConfigs(reordered);
  };

  const handleLoadTemplateToEditor = (template: KPIConfig) => {
    setEditingConfigId(null);
    setTitle(template.title);
    setType(template.type);
    if (template.condition) {
      setConditionField(template.condition.field);
      setConditionOperator(template.condition.operator);
      setConditionValue(String(template.condition.value ?? ""));
    } else {
      setConditionField("none");
      setConditionOperator("eq");
      setConditionValue("");
    }
    setTotalBase(template.totalBase || "totalFiltered");
    setTarget(template.target || "");
    setIconName(template.iconName || "users");
    setColorTheme(template.colorTheme || "emerald");
    setSubtitle(template.subtitle || "");
    setActiveTab("editor");
  };

  const handleAddTemplateDirectly = (template: KPIConfig) => {
    const newConfig: KPIConfig = {
      ...template,
      id: generateKpiId("kpi-preset"),
    };
    onSaveConfigs([...configs, newConfig]);
    setActiveTab("active");
  };

  // Build draft config for live preview
  const draftConfig: KPIConfig = useMemo(() => {
    return {
      id: editingConfigId || "draft-preview",
      title: title.trim() || "Título da Métrica",
      type,
      condition:
        conditionField !== "none"
          ? {
              field: conditionField,
              operator: conditionOperator,
              value:
                conditionField === "paid"
                  ? conditionValue === "true"
                  : conditionValue,
            }
          : undefined,
      totalBase,
      target: target.trim() || undefined,
      iconName: (iconName as KPIConfig["iconName"]) || "users",
      colorTheme,
      subtitle: subtitle.trim() || undefined,
    };
  }, [
    editingConfigId,
    title,
    type,
    conditionField,
    conditionOperator,
    conditionValue,
    totalBase,
    target,
    iconName,
    colorTheme,
    subtitle,
  ]);

  const previewCard: ComputedKPICard = useMemo(() => {
    return computeKpiCard(data, draftConfig, meta);
  }, [data, draftConfig, meta]);

  const matchingRecordsCount = useMemo(() => {
    return applyKpiCondition(data, draftConfig).length;
  }, [data, draftConfig]);

  const handleSaveForm = () => {
    if (!title.trim()) return;

    const savedConfig: KPIConfig = {
      id: editingConfigId || generateKpiId("kpi-custom"),
      title: title.trim(),
      type,
      condition:
        conditionField !== "none"
          ? {
              field: conditionField,
              operator: conditionOperator,
              value:
                conditionField === "paid"
                  ? conditionValue === "true"
                  : conditionValue,
            }
          : undefined,
      totalBase: type === "count" || type === "percentage" ? totalBase : undefined,
      target: target.trim() || undefined,
      iconName: (iconName as KPIConfig["iconName"]) || "users",
      colorTheme,
      subtitle: subtitle.trim() || undefined,
    };

    if (editingConfigId) {
      onSaveConfigs(configs.map((c) => (c.id === editingConfigId ? savedConfig : c)));
    } else {
      onSaveConfigs([...configs, savedConfig]);
    }

    resetForm();
    setActiveTab("active");
  };

  const renderIcon = (name: string, className = "w-4 h-4") => {
    const iconObj = ICON_OPTIONS.find((i) => i.id === name) || ICON_OPTIONS[0];
    const IconComp = iconObj.icon;
    return <IconComp className={className} />;
  };

  const getAccentBarStyle = (theme?: string) => {
    switch (theme) {
      case "emerald":
        return "bg-emerald-500";
      case "blue":
        return "bg-blue-500";
      case "amber":
        return "bg-amber-500";
      case "rose":
        return "bg-rose-500";
      case "zinc":
      default:
        return "bg-zinc-900 dark:bg-zinc-100";
    }
  };

  const getThemeTextClass = (theme?: string) => {
    switch (theme) {
      case "emerald":
        return "text-emerald-600 dark:text-emerald-400";
      case "blue":
        return "text-blue-600 dark:text-blue-400";
      case "amber":
        return "text-amber-600 dark:text-amber-400";
      case "rose":
        return "text-rose-600 dark:text-rose-400";
      default:
        return "text-zinc-900 dark:text-zinc-50";
    }
  };

  return (
    <Dialog open={isOpen} onOpenChange={(open) => !open && onClose()}>
      <DialogContent className="w-[96vw] max-w-5xl sm:max-w-4xl lg:max-w-5xl max-h-[90vh] overflow-hidden p-0 rounded-2xl flex flex-col border border-zinc-200 dark:border-zinc-800 shadow-2xl">
        
        {/* DIALOG HEADER */}
        <DialogHeader className="px-5 sm:px-6 py-4 sm:py-5 border-b border-zinc-200/80 dark:border-zinc-800/80 bg-zinc-50/70 dark:bg-zinc-900/50 pr-12 sm:pr-14">
          <div className="flex items-start sm:items-center justify-between gap-3">
            <div className="flex items-start sm:items-center gap-3">
              <div className="p-2.5 bg-zinc-900 dark:bg-zinc-100 text-white dark:text-zinc-900 rounded-xl shadow-xs shrink-0 mt-0.5 sm:mt-0">
                <SlidersHorizontal className="w-5 h-5" />
              </div>
              <div>
                <div className="flex flex-wrap items-center gap-2">
                  <DialogTitle className="text-base sm:text-lg font-bold tracking-tight text-zinc-900 dark:text-zinc-50">
                    Construtor de Indicadores (KPIs)
                  </DialogTitle>
                  <span className="inline-flex items-center px-2 py-0.5 rounded-full text-[11px] font-semibold bg-emerald-100 text-emerald-800 dark:bg-emerald-950/60 dark:text-emerald-300 border border-emerald-200 dark:border-emerald-800/60">
                    <span className="w-1.5 h-1.5 rounded-full bg-emerald-500 mr-1.5 animate-pulse" />
                    Cálculo Reativo
                  </span>
                </div>
                <DialogDescription className="text-xs sm:text-sm text-zinc-500 dark:text-zinc-400 mt-0.5">
                  Personalize os cartões métricos do retiro. Cada indicador recalcula instantaneamente conforme filtros e inscrições são atualizados.
                </DialogDescription>
              </div>
            </div>
          </div>
        </DialogHeader>

        {/* TABS NAVIGATION */}
        <div className="px-4 sm:px-6 pt-2 pb-0 border-b border-zinc-200 dark:border-zinc-800 bg-white dark:bg-zinc-950">
          <Tabs value={activeTab} onValueChange={(val) => setActiveTab(val as typeof activeTab)} className="w-full">
            <TabsList className="grid grid-cols-3 w-full bg-zinc-100 dark:bg-zinc-800/80 p-1 rounded-xl min-h-[44px]">
              <TabsTrigger
                value="editor"
                className="min-h-[38px] text-xs font-semibold rounded-lg flex items-center justify-center gap-1 sm:gap-1.5 cursor-pointer px-1.5 sm:px-3 overflow-hidden"
              >
                <Edit3 className="w-3.5 h-3.5 shrink-0" />
                <span className="sm:hidden truncate">{editingConfigId ? "Editar" : "Editor"}</span>
                <span className="hidden sm:inline truncate">{editingConfigId ? "Editar Métrica" : "Configurar Métrica"}</span>
                <span className="hidden lg:inline-block px-1.5 py-0.2 text-[10px] font-mono rounded bg-zinc-200 dark:bg-zinc-700 text-zinc-700 dark:text-zinc-200 ml-1 shrink-0">
                  Editor
                </span>
              </TabsTrigger>

              <TabsTrigger
                value="active"
                className="min-h-[38px] text-xs font-semibold rounded-lg flex items-center justify-center gap-1 sm:gap-1.5 cursor-pointer px-1 sm:px-3 overflow-hidden"
              >
                <LayoutDashboard className="w-3.5 h-3.5 shrink-0" />
                <span className="sm:hidden truncate">Ativas</span>
                <span className="hidden sm:inline truncate">Métricas Ativas</span>
                <span className="px-1 sm:px-1.5 py-0.2 text-[10px] sm:text-[11px] font-bold rounded-full bg-zinc-900 text-white dark:bg-zinc-100 dark:text-zinc-900 ml-0.5 sm:ml-1 shrink-0">
                  {configs.length}
                </span>
              </TabsTrigger>

              <TabsTrigger
                value="templates"
                className="min-h-[38px] text-xs font-semibold rounded-lg flex items-center justify-center gap-1 sm:gap-1.5 cursor-pointer px-1.5 sm:px-3 overflow-hidden"
              >
                <Sparkles className="w-3.5 h-3.5 shrink-0" />
                <span className="sm:hidden truncate">Modelos</span>
                <span className="hidden sm:inline truncate">Modelos Prontos</span>
                <span className="hidden lg:inline-block px-1.5 py-0.2 text-[10px] font-bold tracking-wide uppercase rounded bg-indigo-100 text-indigo-800 dark:bg-indigo-950/60 dark:text-indigo-300 ml-1 shrink-0">
                  1-Clique
                </span>
              </TabsTrigger>
            </TabsList>
          </Tabs>
        </div>

        {/* SCROLLABLE DIALOG BODY */}
        <div className="flex-1 overflow-y-auto overflow-x-hidden p-4 sm:p-6 bg-zinc-50/50 dark:bg-zinc-950/60 custom-scrollbar">
          
          {/* ======================================================== */}
          {/* TAB 1: CONFIGURAR NOVA MÉTRICA / EDITOR */}
          {/* ======================================================== */}
          {activeTab === "editor" && (
            <div className="space-y-6">
              <div className="grid grid-cols-1 lg:grid-cols-12 gap-6 items-start">
                
                {/* LEFT COLUMN: CONFIGURATION FORM (7 COLS) */}
                <div className="lg:col-span-7 space-y-5 bg-white dark:bg-zinc-900 p-5 rounded-xl border border-zinc-200 dark:border-zinc-800 shadow-xs">
                  
                  {/* Section 1 Header */}
                  <div className="border-b border-zinc-100 dark:border-zinc-800 pb-3 flex justify-between items-center">
                    <div>
                      <h2 className="text-xs font-bold uppercase tracking-wider text-zinc-500 dark:text-zinc-400">
                        1. Definição & Parâmetros
                      </h2>
                      <p className="text-[11px] text-zinc-400 dark:text-zinc-500 mt-0.5">
                        Defina a regra lógica de agregação para a base ({data.length} participantes ativos no filtro)
                      </p>
                    </div>
                    <span className="text-[11px] font-mono text-zinc-500 bg-zinc-100 dark:bg-zinc-800 px-2 py-0.5 rounded">
                      ID: #{editingConfigId || "NOVA-METRICA"}
                    </span>
                  </div>

                  {/* Field: Metric Title */}
                  <div className="space-y-1.5">
                    <label className="block text-xs font-bold uppercase tracking-wider text-zinc-700 dark:text-zinc-300">
                      Título do Indicador *
                    </label>
                    <Input
                      value={title}
                      onChange={(e) => setTitle(e.target.value)}
                      placeholder="Ex: Inscrições Pagas via PIX, Vagas Homens..."
                      className="min-h-[44px] h-11 text-xs sm:text-sm bg-white dark:bg-zinc-950"
                    />
                  </div>

                  {/* Field: Calculation Type Cards */}
                  <div className="space-y-1.5">
                    <label className="block text-xs font-bold uppercase tracking-wider text-zinc-700 dark:text-zinc-300">
                      Tipo de Cálculo (Agregação)
                    </label>
                    <div className="grid grid-cols-2 sm:grid-cols-4 gap-2">
                      {/* Count */}
                      <button
                        type="button"
                        onClick={() => setType("count")}
                        className={`min-h-[44px] p-2.5 border rounded-lg text-left transition-all cursor-pointer ${
                          type === "count"
                            ? "border-zinc-900 bg-zinc-900 text-white dark:border-zinc-100 dark:bg-zinc-100 dark:text-zinc-950 shadow-xs"
                            : "border-zinc-200 dark:border-zinc-800 hover:bg-zinc-50 dark:hover:bg-zinc-800 text-zinc-700 dark:text-zinc-300"
                        }`}
                      >
                        <Pin className="w-4 h-4 mb-1" />
                        <div className="text-xs font-bold leading-tight">Contagem</div>
                        <div className="text-[10px] opacity-75 mt-0.5">Total de pessoas</div>
                      </button>

                      {/* Sum */}
                      <button
                        type="button"
                        onClick={() => setType("sum")}
                        className={`min-h-[44px] p-2.5 border rounded-lg text-left transition-all cursor-pointer ${
                          type === "sum"
                            ? "border-zinc-900 bg-zinc-900 text-white dark:border-zinc-100 dark:bg-zinc-100 dark:text-zinc-950 shadow-xs"
                            : "border-zinc-200 dark:border-zinc-800 hover:bg-zinc-50 dark:hover:bg-zinc-800 text-zinc-700 dark:text-zinc-300"
                        }`}
                      >
                        <DollarSign className="w-4 h-4 mb-1" />
                        <div className="text-xs font-bold leading-tight">Faturamento</div>
                        <div className="text-[10px] opacity-75 mt-0.5">Soma em R$</div>
                      </button>

                      {/* Percentage */}
                      <button
                        type="button"
                        onClick={() => setType("percentage")}
                        className={`min-h-[44px] p-2.5 border rounded-lg text-left transition-all cursor-pointer ${
                          type === "percentage"
                            ? "border-zinc-900 bg-zinc-900 text-white dark:border-zinc-100 dark:bg-zinc-100 dark:text-zinc-950 shadow-xs"
                            : "border-zinc-200 dark:border-zinc-800 hover:bg-zinc-50 dark:hover:bg-zinc-800 text-zinc-700 dark:text-zinc-300"
                        }`}
                      >
                        <Percent className="w-4 h-4 mb-1" />
                        <div className="text-xs font-bold leading-tight">Porcentagem</div>
                        <div className="text-[10px] opacity-75 mt-0.5">Taxa de adesão</div>
                      </button>

                      {/* Average */}
                      <button
                        type="button"
                        onClick={() => setType("average")}
                        className={`min-h-[44px] p-2.5 border rounded-lg text-left transition-all cursor-pointer ${
                          type === "average"
                            ? "border-zinc-900 bg-zinc-900 text-white dark:border-zinc-100 dark:bg-zinc-100 dark:text-zinc-950 shadow-xs"
                            : "border-zinc-200 dark:border-zinc-800 hover:bg-zinc-50 dark:hover:bg-zinc-800 text-zinc-700 dark:text-zinc-300"
                        }`}
                      >
                        <TrendingUp className="w-4 h-4 mb-1" />
                        <div className="text-xs font-bold leading-tight">Média / Ticket</div>
                        <div className="text-[10px] opacity-75 mt-0.5">Valor médio</div>
                      </button>
                    </div>
                  </div>

                  {/* Two Columns: Base / Denominador + Alvo / Meta */}
                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-3.5">
                    <div className="space-y-1.5">
                      <label className="block text-xs font-bold uppercase tracking-wider text-zinc-700 dark:text-zinc-300">
                        Base / Denominador
                      </label>
                      <Select
                        value={totalBase}
                        onValueChange={(val) => setTotalBase(val as typeof totalBase)}
                      >
                        <SelectTrigger className="min-h-[44px] h-11 text-xs bg-white dark:bg-zinc-950">
                          <SelectValue />
                        </SelectTrigger>
                        <SelectContent>
                          <SelectGroup>
                            <SelectItem value="totalFiltered" className="text-xs">
                              Total no Filtro Atual ({data.length} inscritos)
                            </SelectItem>
                            <SelectItem value="maxParticipants" className="text-xs">
                              Capacidade do Evento ({meta.maxParticipants} vagas)
                            </SelectItem>
                            <SelectItem value="totalBeds" className="text-xs">
                              Total de Camas ({meta.totalBeds} camas)
                            </SelectItem>
                            <SelectItem value="totalRaw" className="text-xs">
                              Total Geral de Inscritos ({meta.rawTotalCount} pessoas)
                            </SelectItem>
                          </SelectGroup>
                        </SelectContent>
                      </Select>
                    </div>

                    <div className="space-y-1.5">
                      <label className="block text-xs font-bold uppercase tracking-wider text-zinc-700 dark:text-zinc-300">
                        Alvo / Meta Esperada (Opcional)
                      </label>
                      <Input
                        value={target}
                        onChange={(e) => setTarget(e.target.value)}
                        placeholder="Ex: 120 confirmações, 90%..."
                        className="min-h-[44px] h-11 text-xs bg-white dark:bg-zinc-950"
                      />
                    </div>
                  </div>

                  {/* Section 2: Conditional Filter Rule */}
                  <div className="p-3.5 bg-zinc-50 dark:bg-zinc-950/60 rounded-xl border border-zinc-200 dark:border-zinc-800/80 space-y-3">
                    <div className="flex items-center justify-between flex-wrap gap-2">
                      <span className="text-xs font-bold uppercase tracking-wider text-zinc-700 dark:text-zinc-300 flex items-center gap-1.5">
                        <Pin className="w-3.5 h-3.5 text-zinc-500" />
                        Regra Condicional (Filtro do Indicador)
                      </span>
                      <span className="text-[11px] text-emerald-600 dark:text-emerald-400 font-semibold flex items-center gap-1">
                        <span className="w-1.5 h-1.5 rounded-full bg-emerald-500" />
                        {matchingRecordsCount} participantes atendem à regra
                      </span>
                    </div>

                    <div className="grid grid-cols-1 sm:grid-cols-2 gap-2">
                      <div className="space-y-1">
                        <label className="text-[11px] font-semibold text-zinc-500">Coluna</label>
                        <Select
                          value={conditionField}
                          onValueChange={(val) => {
                            setConditionField(val);
                            if (val === "paid") setConditionValue("true");
                            else if (val === "gender") setConditionValue("masculino");
                            else if (val === "payment_method") setConditionValue("pix");
                            else setConditionValue("");
                          }}
                        >
                          <SelectTrigger className="min-h-[44px] h-10 text-xs bg-white dark:bg-zinc-900">
                            <SelectValue />
                          </SelectTrigger>
                          <SelectContent>
                            <SelectGroup>
                              <SelectItem value="none" className="text-xs">
                                Sem condição (Todos os participantes)
                              </SelectItem>
                              <SelectItem value="paid" className="text-xs">
                                Status do Pagamento
                              </SelectItem>
                              <SelectItem value="gender" className="text-xs">
                                Gênero
                              </SelectItem>
                              <SelectItem value="payment_method" className="text-xs">
                                Método de Pagamento
                              </SelectItem>
                              <SelectItem value="room_id" className="text-xs">
                                Alojamento / Quarto
                              </SelectItem>
                            </SelectGroup>
                          </SelectContent>
                        </Select>
                      </div>

                      {conditionField !== "none" && (
                        <div className="space-y-1">
                          <label className="text-[11px] font-semibold text-zinc-500">Critério / Valor</label>
                          {conditionField === "paid" ? (
                            <Select
                              value={conditionValue}
                              onValueChange={(val) => setConditionValue(val)}
                            >
                              <SelectTrigger className="min-h-[44px] h-10 text-xs bg-white dark:bg-zinc-900">
                                <SelectValue />
                              </SelectTrigger>
                              <SelectContent>
                                <SelectGroup>
                                  <SelectItem value="true" className="text-xs">
                                    Pago / Confirmado
                                  </SelectItem>
                                  <SelectItem value="false" className="text-xs">
                                    Pendente
                                  </SelectItem>
                                </SelectGroup>
                              </SelectContent>
                            </Select>
                          ) : conditionField === "gender" ? (
                            <Select
                              value={conditionValue}
                              onValueChange={(val) => setConditionValue(val)}
                            >
                              <SelectTrigger className="min-h-[44px] h-10 text-xs bg-white dark:bg-zinc-900">
                                <SelectValue />
                              </SelectTrigger>
                              <SelectContent>
                                <SelectGroup>
                                  <SelectItem value="masculino" className="text-xs">
                                    Masculino
                                  </SelectItem>
                                  <SelectItem value="feminino" className="text-xs">
                                    Feminino
                                  </SelectItem>
                                </SelectGroup>
                              </SelectContent>
                            </Select>
                          ) : conditionField === "payment_method" ? (
                            <Select
                              value={conditionValue}
                              onValueChange={(val) => setConditionValue(val)}
                            >
                              <SelectTrigger className="min-h-[44px] h-10 text-xs bg-white dark:bg-zinc-900">
                                <SelectValue />
                              </SelectTrigger>
                              <SelectContent>
                                <SelectGroup>
                                  <SelectItem value="pix" className="text-xs">
                                    PIX Instantâneo
                                  </SelectItem>
                                  <SelectItem value="cartao" className="text-xs">
                                    Cartão de Crédito
                                  </SelectItem>
                                  <SelectItem value="dinheiro" className="text-xs">
                                    Dinheiro
                                  </SelectItem>
                                  <SelectItem value="boleto" className="text-xs">
                                    Boleto Bancário
                                  </SelectItem>
                                </SelectGroup>
                              </SelectContent>
                            </Select>
                          ) : conditionField === "room_id" ? (
                            <Select
                              value={conditionOperator}
                              onValueChange={(val) =>
                                setConditionOperator(val as KPICondition["operator"])
                              }
                            >
                              <SelectTrigger className="min-h-[44px] h-10 text-xs bg-white dark:bg-zinc-900">
                                <SelectValue />
                              </SelectTrigger>
                              <SelectContent>
                                <SelectGroup>
                                  <SelectItem value="truthy" className="text-xs">
                                    Possui Quarto Alocado
                                  </SelectItem>
                                  <SelectItem value="falsy" className="text-xs">
                                    Sem Quarto (Pendente)
                                  </SelectItem>
                                </SelectGroup>
                              </SelectContent>
                            </Select>
                          ) : null}
                        </div>
                      )}
                    </div>
                  </div>

                  {/* Section 3: Visual Appearance & Identity */}
                  <div className="grid grid-cols-1 sm:grid-cols-3 gap-3.5 pt-1">
                    {/* Icon Selection */}
                    <div className="space-y-1.5">
                      <label className="block text-xs font-bold uppercase tracking-wider text-zinc-700 dark:text-zinc-300">
                        Ícone Visual
                      </label>
                      <Select value={iconName} onValueChange={(val) => setIconName(val)}>
                        <SelectTrigger className="min-h-[44px] h-11 text-xs bg-white dark:bg-zinc-950">
                          <SelectValue />
                        </SelectTrigger>
                        <SelectContent>
                          <SelectGroup>
                            {ICON_OPTIONS.map((opt) => (
                              <SelectItem key={opt.id} value={opt.id} className="text-xs">
                                <span className="flex items-center gap-2">
                                  {renderIcon(opt.id, "w-3.5 h-3.5")}
                                  <span>{opt.label}</span>
                                </span>
                              </SelectItem>
                            ))}
                          </SelectGroup>
                        </SelectContent>
                      </Select>
                    </div>

                    {/* Color Swatches */}
                    <div className="space-y-1.5">
                      <label className="block text-xs font-bold uppercase tracking-wider text-zinc-700 dark:text-zinc-300">
                        Cor de Destaque
                      </label>
                      <div className="flex items-center gap-2 pt-2">
                        {COLOR_THEMES.map((theme) => (
                          <button
                            key={theme.id}
                            type="button"
                            onClick={() => setColorTheme(theme.id)}
                            className={`min-h-[44px] min-w-[32px] flex items-center justify-center cursor-pointer`}
                            title={theme.label}
                          >
                            <span
                              className={`w-7 h-7 rounded-full ${theme.bgHex} transition-all ${
                                colorTheme === theme.id
                                  ? "ring-2 ring-offset-2 ring-zinc-900 dark:ring-offset-zinc-900 scale-110"
                                  : "opacity-80 hover:opacity-100 hover:scale-105"
                              }`}
                            />
                          </button>
                        ))}
                      </div>
                    </div>

                    {/* Subtitle / Footnote */}
                    <div className="space-y-1.5">
                      <label className="block text-xs font-bold uppercase tracking-wider text-zinc-700 dark:text-zinc-300">
                        Subtítulo Auxiliar
                      </label>
                      <Input
                        value={subtitle}
                        onChange={(e) => setSubtitle(e.target.value)}
                        placeholder="Ex: compensação imediata..."
                        className="min-h-[44px] h-11 text-xs bg-white dark:bg-zinc-950"
                      />
                    </div>
                  </div>

                </div>

                {/* RIGHT COLUMN: LIVE INTERACTIVE PREVIEW BOX (5 COLS) */}
                <div className="lg:col-span-5 space-y-4">
                  <div className="flex items-center justify-between px-1">
                    <span className="text-xs font-bold uppercase tracking-wider text-zinc-500 dark:text-zinc-400 flex items-center gap-1.5">
                      <Sparkles className="w-3.5 h-3.5 text-emerald-500 animate-spin" style={{ animationDuration: "6s" }} />
                      Pré-visualização ao Vivo
                    </span>
                    <span className="text-[11px] font-mono text-zinc-400">Card no Painel</span>
                  </div>

                  {/* PREVIEW CARD */}
                  <div className="bg-white dark:bg-zinc-900 rounded-xl border border-zinc-200 dark:border-zinc-800 p-5 shadow-sm relative overflow-hidden transition-all duration-200">
                    {/* Top Accent Bar */}
                    <div className={`absolute top-0 left-0 right-0 h-1.5 ${getAccentBarStyle(colorTheme)} transition-colors`} />

                    {/* Header Row: Title & Icon */}
                    <div className="flex items-start justify-between gap-3 pt-1">
                      <div className="space-y-1 pr-1">
                        <span className="inline-flex items-center px-2 py-0.5 rounded text-[11px] font-bold uppercase bg-zinc-100 dark:bg-zinc-800 text-zinc-700 dark:text-zinc-300">
                          {previewCard.badgeText || "Agregação Ativa"}
                        </span>
                        <h3 className="text-sm font-bold text-zinc-900 dark:text-zinc-100 tracking-tight line-clamp-1">
                          {previewCard.title}
                        </h3>
                      </div>
                      <div className="p-2.5 rounded-lg bg-zinc-100 dark:bg-zinc-800 text-zinc-900 dark:text-zinc-100 shrink-0">
                        {renderIcon(previewCard.iconName, "w-5 h-5")}
                      </div>
                    </div>

                    {/* Metric Value */}
                    <div className="mt-4 flex items-baseline gap-2">
                      <span className={`text-3xl sm:text-4xl font-extrabold tracking-tight font-sans ${getThemeTextClass(colorTheme)}`}>
                        {previewCard.value}
                      </span>
                      {previewCard.secondaryValue && (
                        <span className="text-sm font-medium text-zinc-500 dark:text-zinc-400">
                          {previewCard.secondaryValue}
                        </span>
                      )}
                    </div>

                    {/* Progress Bar Representation */}
                    <div className="mt-3.5 space-y-1.5">
                      <Progress
                        value={previewCard.progress ?? 60}
                        className="h-2 bg-zinc-100 dark:bg-zinc-800"
                      />
                      <div className="flex justify-between text-[11px] text-zinc-500 dark:text-zinc-400">
                        <span className={`font-semibold ${getThemeTextClass(colorTheme)}`}>
                          {previewCard.progress !== undefined
                            ? `${previewCard.progress}% da base`
                            : `${matchingRecordsCount} registros`}
                        </span>
                        <span>{target.trim() ? `Alvo: ${target}` : `Base: ${data.length}`}</span>
                      </div>
                    </div>

                    {/* Footer Footnote */}
                    <div className="mt-4 pt-3 border-t border-zinc-100 dark:border-zinc-800/80 flex items-center justify-between text-xs text-zinc-500 dark:text-zinc-400">
                      <div className="flex items-center gap-1.5">
                        <span className="w-1.5 h-1.5 rounded-full bg-emerald-500" />
                        <span className="truncate max-w-[190px]">
                          {previewCard.description || "Recálculo em tempo real"}
                        </span>
                      </div>
                      <span className="text-[10px] font-mono text-zinc-400">Tempo real</span>
                    </div>
                  </div>

                  {/* Synthesized Formula Box */}
                  <div className="bg-zinc-100/70 dark:bg-zinc-900/60 rounded-xl p-4 border border-zinc-200/80 dark:border-zinc-800 text-xs space-y-2">
                    <div className="flex items-center justify-between">
                      <span className="font-bold text-zinc-700 dark:text-zinc-300 flex items-center gap-1">
                        <Info className="w-3.5 h-3.5 text-zinc-500" />
                        Fórmula Sintetizada:
                      </span>
                      <span className="font-mono text-[10px] text-zinc-400">Planilha / SQL</span>
                    </div>
                    <div className="font-mono text-[11px] p-2.5 bg-white dark:bg-zinc-950 rounded-lg border border-zinc-200 dark:border-zinc-800 text-zinc-800 dark:text-zinc-200 overflow-x-auto whitespace-nowrap">
                      {previewCard.formulaText || "=COUNTA(Inscrições[ID])"}
                    </div>
                    <p className="text-[11px] text-zinc-500 dark:text-zinc-400 leading-relaxed">
                      Este indicador atualiza a grade de cards no painel principal e sincroniza com os filtros da lista de inscritos.
                    </p>
                  </div>

                </div>

              </div>
            </div>
          )}

          {/* ======================================================== */}
          {/* TAB 2: MÉTRICAS ATIVAS NO PAINEL */}
          {/* ======================================================== */}
          {activeTab === "active" && (
            <div className="space-y-4">
              <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3 bg-white dark:bg-zinc-900 p-4 rounded-xl border border-zinc-200 dark:border-zinc-800">
                <div>
                  <h2 className="text-sm font-bold text-zinc-900 dark:text-zinc-100">
                    Disposição dos Cartões ({configs.length} métricas ativas)
                  </h2>
                  <p className="text-xs text-zinc-500 dark:text-zinc-400">
                    Reordene a prioridade dos indicadores exibidos no painel do evento.
                  </p>
                </div>
                <div className="flex items-center gap-2">
                  <Button
                    variant="outline"
                    onClick={onResetDefaults}
                    className="min-h-[44px] px-3.5 text-xs font-semibold rounded-lg text-zinc-600 dark:text-zinc-300 flex items-center gap-1.5 cursor-pointer"
                  >
                    <RotateCcw className="w-3.5 h-3.5" />
                    <span>Restaurar 4 Padrões</span>
                  </Button>
                  <Button
                    onClick={handleStartCreate}
                    className="min-h-[44px] px-4 text-xs font-bold rounded-lg bg-zinc-900 text-white hover:bg-zinc-800 dark:bg-zinc-50 dark:text-zinc-900 flex items-center gap-1.5 cursor-pointer"
                  >
                    <Plus className="w-3.5 h-3.5" />
                    <span>Nova Métrica</span>
                  </Button>
                </div>
              </div>

              {/* REORDERABLE ACTIVE KPI LIST */}
              <div className="space-y-2.5">
                {configs.map((cfg, idx) => {
                  const cardComputed = computeKpiCard(data, cfg, meta);
                  return (
                    <div
                      key={cfg.id}
                      className="flex items-center justify-between p-3.5 bg-white dark:bg-zinc-900 rounded-xl border border-zinc-200 dark:border-zinc-800 hover:border-zinc-300 dark:hover:border-zinc-700 transition-all shadow-xs gap-3"
                    >
                      <div className="flex items-center gap-3">
                        {/* Order Reordering Controls */}
                        <div className="flex flex-col gap-0.5">
                          <button
                            type="button"
                            onClick={() => handleMoveUp(idx)}
                            disabled={idx === 0}
                            className="p-1 rounded text-zinc-400 hover:text-zinc-800 dark:hover:text-zinc-100 disabled:opacity-20 cursor-pointer"
                            title="Mover para cima"
                          >
                            <ArrowUp className="w-3.5 h-3.5" />
                          </button>
                          <button
                            type="button"
                            onClick={() => handleMoveDown(idx)}
                            disabled={idx === configs.length - 1}
                            className="p-1 rounded text-zinc-400 hover:text-zinc-800 dark:hover:text-zinc-100 disabled:opacity-20 cursor-pointer"
                            title="Mover para baixo"
                          >
                            <ArrowDown className="w-3.5 h-3.5" />
                          </button>
                        </div>

                        {/* Order Number Badge */}
                        <div className="w-8 h-8 rounded-lg bg-zinc-100 dark:bg-zinc-800 text-zinc-900 dark:text-zinc-100 flex items-center justify-center font-bold text-xs shrink-0">
                          {idx + 1}
                        </div>

                        {/* Icon */}
                        <div className="p-2 rounded-lg bg-zinc-100 dark:bg-zinc-800 text-zinc-800 dark:text-zinc-200 shrink-0">
                          {renderIcon(cfg.iconName || "users", "w-4 h-4")}
                        </div>

                        {/* Title and Badge */}
                        <div>
                          <div className="flex items-center gap-2 flex-wrap">
                            <h3 className="text-xs sm:text-sm font-bold text-zinc-900 dark:text-zinc-100">
                              {cfg.title}
                            </h3>
                            <Badge variant="outline" className="text-[10px] font-mono font-semibold">
                              {cardComputed.value} {cardComputed.secondaryValue}
                            </Badge>
                          </div>
                          <p className="text-[11px] text-zinc-400 truncate max-w-[280px] sm:max-w-md">
                            {cfg.subtitle || (cfg.condition ? `Regra: ${cfg.condition.field} = ${cfg.condition.value}` : "Total geral")}
                          </p>
                        </div>
                      </div>

                      {/* Actions */}
                      <div className="flex items-center gap-1.5 shrink-0">
                        <Button
                          variant="ghost"
                          size="icon"
                          onClick={() => handleStartEdit(cfg)}
                          className="min-h-[44px] min-w-[44px] text-zinc-500 hover:text-zinc-900 dark:hover:text-zinc-50 rounded-lg cursor-pointer"
                          title="Editar métrica"
                        >
                          <Edit3 className="w-4 h-4" />
                        </Button>
                        <Button
                          variant="ghost"
                          size="icon"
                          onClick={() => handleRemoveConfig(cfg.id)}
                          disabled={configs.length <= 1}
                          className="min-h-[44px] min-w-[44px] text-red-500 hover:bg-red-500/10 rounded-lg cursor-pointer disabled:opacity-30"
                          title="Excluir métrica"
                        >
                          <Trash2 className="w-4 h-4" />
                        </Button>
                      </div>
                    </div>
                  );
                })}
              </div>
            </div>
          )}

          {/* ======================================================== */}
          {/* TAB 3: MODELOS PRONTOS (PRESETS 1-CLIQUE) */}
          {/* ======================================================== */}
          {activeTab === "templates" && (
            <div className="space-y-4">
              <div className="bg-white dark:bg-zinc-900 p-4 rounded-xl border border-zinc-200 dark:border-zinc-800">
                <h2 className="text-sm font-bold text-zinc-900 dark:text-zinc-100">
                  Biblioteca de Modelos em 1-Clique
                </h2>
                <p className="text-xs text-zinc-500 dark:text-zinc-400">
                  Selecione uma métrica pré-formatada para carregar no editor ou adicionar imediatamente ao painel.
                </p>
              </div>

              <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-3.5">
                {PRESET_TEMPLATES.map((tmpl) => {
                  const cardComputed = computeKpiCard(data, tmpl, meta);
                  return (
                    <div
                      key={tmpl.id}
                      className="p-4 bg-white dark:bg-zinc-900 rounded-xl border border-zinc-200 dark:border-zinc-800 hover:border-zinc-900 dark:hover:border-zinc-100 hover:shadow-md transition-all flex flex-col justify-between group gap-3"
                    >
                      <div className="space-y-2">
                        <div className="flex items-start justify-between">
                          <div className="p-2 rounded-lg bg-zinc-100 dark:bg-zinc-800 text-zinc-800 dark:text-zinc-200">
                            {renderIcon(tmpl.iconName || "users", "w-5 h-5")}
                          </div>
                          <Badge variant="secondary" className="text-[10px] font-bold uppercase">
                            {tmpl.category}
                          </Badge>
                        </div>
                        <h3 className="text-sm font-bold text-zinc-900 dark:text-zinc-100">
                          {tmpl.title}
                        </h3>
                        <p className="text-xs text-zinc-500 dark:text-zinc-400 line-clamp-2">
                          {tmpl.description}
                        </p>
                      </div>

                      <div className="pt-3 border-t border-zinc-100 dark:border-zinc-800 flex items-center justify-between text-xs gap-2">
                        <span className="font-mono font-bold text-zinc-800 dark:text-zinc-200">
                          {cardComputed.value} {cardComputed.secondaryValue}
                        </span>
                        <div className="flex items-center gap-1.5">
                          <Button
                            variant="ghost"
                            onClick={() => handleLoadTemplateToEditor(tmpl)}
                            className="min-h-[44px] px-2.5 text-xs font-semibold text-zinc-600 dark:text-zinc-400 hover:text-zinc-900 dark:hover:text-zinc-100 flex items-center gap-1 cursor-pointer"
                          >
                            <span>Editar</span>
                            <ArrowRight className="w-3.5 h-3.5" />
                          </Button>
                          <Button
                            onClick={() => handleAddTemplateDirectly(tmpl)}
                            className="min-h-[44px] px-3 text-xs font-bold rounded-lg bg-zinc-900 text-white hover:bg-zinc-800 dark:bg-zinc-50 dark:text-zinc-900 shrink-0 cursor-pointer"
                          >
                            <Plus className="w-3.5 h-3.5 mr-1" />
                            <span>Adicionar</span>
                          </Button>
                        </div>
                      </div>
                    </div>
                  );
                })}
              </div>
            </div>
          )}

        </div>

        {/* DIALOG FOOTER */}
        <footer className="px-5 sm:px-6 py-3.5 sm:py-4 border-t border-zinc-200 dark:border-zinc-800 bg-zinc-50 dark:bg-zinc-900/50 flex flex-col sm:flex-row items-center justify-between gap-3">
          <div className="flex items-center gap-2 text-xs text-zinc-500 dark:text-zinc-400 w-full sm:w-auto">
            <Info className="w-4 h-4 text-zinc-400 shrink-0" />
            <span className="text-[11px] sm:text-xs">
              As alterações afetam os indicadores no topo do retiro para todos os líderes.
            </span>
          </div>

          <div className="flex flex-col-reverse sm:flex-row items-stretch sm:items-center gap-2 sm:gap-2.5 w-full sm:w-auto justify-end">
            <Button
              type="button"
              variant="outline"
              onClick={onResetDefaults}
              className="min-h-[44px] px-3.5 text-xs font-semibold rounded-lg cursor-pointer w-full sm:w-auto"
            >
              Restaurar Padrões
            </Button>

            <Button
              type="button"
              variant="secondary"
              onClick={onClose}
              className="min-h-[44px] px-4 text-xs font-semibold rounded-lg cursor-pointer w-full sm:w-auto"
            >
              Cancelar
            </Button>

            {activeTab === "editor" && (
              <Button
                type="button"
                onClick={handleSaveForm}
                disabled={!title.trim()}
                className="min-h-[44px] px-5 text-xs font-bold rounded-lg bg-zinc-900 text-white hover:bg-zinc-800 dark:bg-zinc-50 dark:text-zinc-900 dark:hover:bg-white shadow-sm flex items-center justify-center gap-1.5 cursor-pointer disabled:opacity-40 w-full sm:w-auto"
              >
                <Check className="w-4 h-4" />
                <span>{editingConfigId ? "Salvar Alterações" : "Salvar Métrica & Atualizar"}</span>
              </Button>
            )}
          </div>
        </footer>

      </DialogContent>
    </Dialog>
  );
}
