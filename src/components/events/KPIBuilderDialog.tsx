/**
 * @file KPIBuilderDialog.tsx
 * @description Interactive KPI Builder modal allowing admins to create, customize, and manage reactive KPI cards.
 */

import { useState } from "react";
import {
  SlidersHorizontal,
  Plus,
  Trash2,
  Edit2,
  RotateCcw,
  Users,
  DollarSign,
  Bed,
  CheckCircle2,
  Clock,
  AlertCircle,
  TrendingUp,
  BarChart2,
  Eye,
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
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { Card, CardContent } from "@/components/ui/card";
import { Progress } from "@/components/ui/progress";
import type { KPIConfig, KPIType, ComputedKPICard, KPICondition } from "@/types/eventsFilter";
import type { RegistrationWithDetails } from "./RegistrationDetailDialog";
import {
  computeKpiCard,
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
];

const COLOR_THEMES: { id: NonNullable<KPIConfig["colorTheme"]>; label: string }[] = [
  { id: "default", label: "Neutro (Zinc)" },
  { id: "emerald", label: "Esmeralda (Verde)" },
  { id: "amber", label: "Âmbar (Amarelo/Laranja)" },
  { id: "blue", label: "Azul (Destaque)" },
  { id: "zinc", label: "Cinza Escuro" },
];

const PRESET_TEMPLATES: KPIConfig[] = [
  {
    id: "preset-male",
    title: "Homens Inscritos",
    type: "count",
    condition: { field: "gender", operator: "eq", value: "masculino" },
    totalBase: "totalFiltered",
    iconName: "users",
    colorTheme: "blue",
    subtitle: "participantes masculinos",
  },
  {
    id: "preset-female",
    title: "Mulheres Inscritas",
    type: "count",
    condition: { field: "gender", operator: "eq", value: "feminino" },
    totalBase: "totalFiltered",
    iconName: "users",
    colorTheme: "amber",
    subtitle: "participantes femininos",
  },
  {
    id: "preset-pix",
    title: "Pagamentos via PIX",
    type: "count",
    condition: { field: "payment_method", operator: "eq", value: "pix" },
    totalBase: "totalFiltered",
    iconName: "check",
    colorTheme: "emerald",
    subtitle: "quitações instantâneas",
  },
  {
    id: "preset-unallocated",
    title: "Sem Alojamento",
    type: "count",
    condition: { field: "room_id", operator: "falsy" },
    totalBase: "totalFiltered",
    iconName: "alert",
    colorTheme: "amber",
    subtitle: "necessitam de alocação",
  },
  {
    id: "preset-avg-ticket",
    title: "Ticket Médio",
    type: "average",
    iconName: "dollar",
    colorTheme: "default",
    subtitle: "valor médio por inscrição",
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
  const [activeTab, setActiveTab] = useState<"active" | "editor" | "templates">("active");
  const [editingConfigId, setEditingConfigId] = useState<string | null>(null);

  // Form State for Editing/Creating a KPI
  const [title, setTitle] = useState("");
  const [type, setType] = useState<KPIType>("count");
  const [conditionField, setConditionField] = useState<string>("none");
  const [conditionOperator, setConditionOperator] = useState<KPICondition["operator"]>("eq");
  const [conditionValue, setConditionValue] = useState<string>("");
  const [totalBase, setTotalBase] = useState<"totalFiltered" | "maxParticipants" | "totalBeds" | "totalRaw">("totalFiltered");
  const [iconName, setIconName] = useState<string>("users");
  const [colorTheme, setColorTheme] = useState<NonNullable<KPIConfig["colorTheme"]>>("default");
  const [subtitle, setSubtitle] = useState("");

  const resetForm = () => {
    setEditingConfigId(null);
    setTitle("");
    setType("count");
    setConditionField("none");
    setConditionOperator("eq");
    setConditionValue("");
    setTotalBase("totalFiltered");
    setIconName("users");
    setColorTheme("default");
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
      setConditionValue(String(config.condition.value || ""));
    } else {
      setConditionField("none");
      setConditionOperator("eq");
      setConditionValue("");
    }
    setTotalBase(config.totalBase || "totalFiltered");
    setIconName(config.iconName || "users");
    setColorTheme(config.colorTheme || "default");
    setSubtitle(config.subtitle || "");
    setActiveTab("editor");
  };

  const handleRemoveConfig = (id: string) => {
    const next = configs.filter((c) => c.id !== id);
    onSaveConfigs(next);
  };

  const handleAddTemplate = (template: KPIConfig) => {
    const newConfig: KPIConfig = {
      ...template,
      id: generateKpiId("kpi-preset"),
    };
    onSaveConfigs([...configs, newConfig]);
    setActiveTab("active");
  };

  // Build draft config for live preview
  const draftConfig: KPIConfig = {
    id: editingConfigId || "draft-preview",
    title: title || "Métrica de Exemplo",
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
    iconName: (iconName as KPIConfig["iconName"]) || "users",
    colorTheme,
    subtitle,
  };

  const previewCard: ComputedKPICard = computeKpiCard(data, draftConfig, meta);

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

  const renderIcon = (name: string) => {
    const iconObj = ICON_OPTIONS.find((i) => i.id === name) || ICON_OPTIONS[0];
    const IconComp = iconObj.icon;
    return <IconComp className="w-4 h-4 text-zinc-700 dark:text-zinc-300" />;
  };

  return (
    <Dialog open={isOpen} onOpenChange={(open) => !open && onClose()}>
      <DialogContent className="max-w-2xl max-h-[90vh] overflow-y-auto p-5 sm:p-6 rounded-2xl">
        <DialogHeader className="border-b border-zinc-100 dark:border-zinc-800 pb-4">
          <div className="flex items-center gap-2.5">
            <div className="size-9 rounded-xl bg-primary/10 text-primary flex items-center justify-center shrink-0">
              <SlidersHorizontal className="w-4 h-4" />
            </div>
            <div>
              <DialogTitle className="text-base sm:text-lg font-bold">
                Construtor de KPIs & Métricas
              </DialogTitle>
              <DialogDescription className="text-xs text-zinc-500">
                Personalize os cartões de indicadores do painel. Eles recalculam em tempo real com base nos filtros da tabela.
              </DialogDescription>
            </div>
          </div>
        </DialogHeader>

        <Tabs value={activeTab} onValueChange={(val) => setActiveTab(val as typeof activeTab)} className="w-full pt-2">
          <TabsList className="grid grid-cols-3 w-full bg-zinc-100 dark:bg-zinc-800/80 p-1 rounded-xl min-h-[44px]">
            <TabsTrigger value="active" className="min-h-[40px] text-xs font-semibold rounded-lg">
              Métricas Ativas ({configs.length})
            </TabsTrigger>
            <TabsTrigger value="editor" className="min-h-[40px] text-xs font-semibold rounded-lg">
              {editingConfigId ? "Editar Métrica" : "+ Criar Métrica"}
            </TabsTrigger>
            <TabsTrigger value="templates" className="min-h-[40px] text-xs font-semibold rounded-lg">
              Sugestões Prontas
            </TabsTrigger>
          </TabsList>

          {/* TAB 1: METRICAS ATIVAS */}
          <TabsContent value="active" className="space-y-4 pt-3">
            <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-2">
              <p className="text-xs text-zinc-500 font-medium">
                Cartões atualmente exibidos no topo do retiro:
              </p>
              <div className="flex items-center gap-2 self-end sm:self-auto">
                <Button
                  variant="outline"
                  onClick={onResetDefaults}
                  className="min-h-[44px] px-3 text-xs font-semibold rounded-lg text-zinc-600 dark:text-zinc-400 hover:text-zinc-900 dark:hover:text-zinc-50 flex items-center gap-1.5 cursor-pointer"
                >
                  <RotateCcw className="w-3.5 h-3.5" />
                  <span className="hidden sm:inline">Restaurar Padrões</span>
                  <span className="sm:hidden">Padrões</span>
                </Button>
                <Button
                  onClick={handleStartCreate}
                  className="min-h-[44px] px-3.5 text-xs font-bold rounded-lg bg-zinc-900 text-white hover:bg-zinc-800 dark:bg-zinc-50 dark:text-zinc-900 flex items-center gap-1.5 cursor-pointer"
                >
                  <Plus className="w-3.5 h-3.5" />
                  <span>Nova Métrica</span>
                </Button>
              </div>
            </div>

            <div className="space-y-2.5">
              {configs.map((cfg) => (
                <div
                  key={cfg.id}
                  className="flex items-center justify-between p-3 rounded-xl border border-zinc-200 dark:border-zinc-800 bg-white dark:bg-zinc-900 shadow-xs"
                >
                  <div className="flex items-center gap-3">
                    <div className="size-8 rounded-lg bg-zinc-100 dark:bg-zinc-800 flex items-center justify-center shrink-0">
                      {renderIcon(cfg.iconName || "users")}
                    </div>
                    <div>
                      <div className="flex items-center gap-2">
                        <span className="font-bold text-xs text-zinc-900 dark:text-zinc-50">
                          {cfg.title}
                        </span>
                        <Badge variant="outline" className="text-[10px] uppercase font-semibold">
                          {cfg.type === "count"
                            ? "Contagem"
                            : cfg.type === "sum"
                            ? "Soma"
                            : cfg.type === "percentage"
                            ? "Porcentagem"
                            : "Média"}
                        </Badge>
                      </div>
                      <p className="text-[11px] text-zinc-500 truncate max-w-[280px]">
                        {cfg.subtitle || (cfg.condition ? `Filtro: ${cfg.condition.field} = ${cfg.condition.value}` : "Geral")}
                      </p>
                    </div>
                  </div>

                  <div className="flex items-center gap-1">
                    <Button
                      variant="ghost"
                      size="icon"
                      onClick={() => handleStartEdit(cfg)}
                      className="min-h-[44px] min-w-[44px] text-zinc-500 hover:text-zinc-900 dark:hover:text-zinc-50 rounded-lg cursor-pointer"
                      title="Editar métrica"
                    >
                      <Edit2 className="w-4 h-4" />
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
              ))}
            </div>
          </TabsContent>

          {/* TAB 2: EDITOR / CONSTRUTOR */}
          <TabsContent value="editor" className="space-y-4 pt-3">
            {/* Live Preview Section */}
            <div className="space-y-1.5 bg-zinc-50 dark:bg-zinc-800/40 p-3.5 rounded-xl border border-zinc-200/80 dark:border-zinc-800">
              <span className="text-[11px] font-bold uppercase tracking-wider text-zinc-400 flex items-center gap-1">
                <Eye className="w-3.5 h-3.5" />
                Pré-visualização do Card em Tempo Real:
              </span>
              <div className="max-w-sm mx-auto pt-1">
                <Card className="rounded-xl border border-zinc-200 bg-white dark:border-zinc-800 dark:bg-zinc-900 shadow-sm p-4">
                  <CardContent className="p-0 space-y-2.5">
                    <div className="flex items-center justify-between gap-2">
                      <span className="text-[11px] font-bold uppercase tracking-wider text-zinc-500 dark:text-zinc-400 flex items-center gap-1.5 truncate">
                        {renderIcon(previewCard.iconName)}
                        <span className="truncate">{previewCard.title}</span>
                      </span>
                      {previewCard.badgeText && (
                        <Badge
                          variant="outline"
                          className={`text-[10px] font-bold uppercase px-2 py-0.5 ${
                            previewCard.badgeVariant === "success"
                              ? "bg-emerald-500/10 text-emerald-600 border-emerald-500/30"
                              : previewCard.badgeVariant === "warning"
                              ? "bg-amber-500/10 text-amber-600 border-amber-500/30"
                              : "bg-zinc-100 text-zinc-700 dark:bg-zinc-800 dark:text-zinc-300"
                          }`}
                        >
                          {previewCard.badgeText}
                        </Badge>
                      )}
                    </div>
                    <div>
                      <div
                        className={`text-2xl font-extrabold tracking-tight truncate ${
                          previewCard.colorTheme === "emerald"
                            ? "text-emerald-600"
                            : "text-zinc-900 dark:text-zinc-50"
                        }`}
                      >
                        {previewCard.value}{" "}
                        {previewCard.secondaryValue && (
                          <span className="text-xs font-semibold text-zinc-500">
                            {previewCard.secondaryValue}
                          </span>
                        )}
                      </div>
                    </div>
                    {previewCard.progress !== undefined && (
                      <Progress value={previewCard.progress} className="h-1.5 bg-zinc-100" />
                    )}
                    {previewCard.description && (
                      <div className="text-[11px] text-zinc-500 pt-1 border-t border-zinc-100 truncate">
                        {previewCard.description}
                      </div>
                    )}
                  </CardContent>
                </Card>
              </div>
            </div>

            {/* Form Fields */}
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-3.5 text-xs">
              {/* Title */}
              <div className="space-y-1 sm:col-span-2">
                <label className="font-bold text-zinc-700 dark:text-zinc-300">
                  Título da Métrica *
                </label>
                <Input
                  value={title}
                  onChange={(e) => setTitle(e.target.value)}
                  placeholder="Ex: Mulheres Confirmadas, Total PIX..."
                  className="min-h-[44px] h-11 text-xs"
                />
              </div>

              {/* Type */}
              <div className="space-y-1">
                <label className="font-bold text-zinc-700 dark:text-zinc-300">
                  Tipo de Cálculo *
                </label>
                <Select value={type} onValueChange={(val) => setType(val as KPIType)}>
                  <SelectTrigger className="min-h-[44px] h-11 text-xs">
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectGroup>
                      <SelectItem value="count" className="text-xs">
                        Contagem (Quantidade de Inscritos)
                      </SelectItem>
                      <SelectItem value="sum" className="text-xs">
                        Soma (Faturamento / Preço)
                      </SelectItem>
                      <SelectItem value="percentage" className="text-xs">
                        Porcentagem (Taxa / Proporção)
                      </SelectItem>
                      <SelectItem value="average" className="text-xs">
                        Média (Ticket Médio por Inscrito)
                      </SelectItem>
                    </SelectGroup>
                  </SelectContent>
                </Select>
              </div>

              {/* Base for Percentage/Count */}
              <div className="space-y-1">
                <label className="font-bold text-zinc-700 dark:text-zinc-300">
                  Base de Comparação
                </label>
                <Select
                  value={totalBase}
                  onValueChange={(val) => setTotalBase(val as typeof totalBase)}
                >
                  <SelectTrigger className="min-h-[44px] h-11 text-xs">
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectGroup>
                      <SelectItem value="totalFiltered" className="text-xs">
                        Total no Filtro Atual ({data.length})
                      </SelectItem>
                      <SelectItem value="maxParticipants" className="text-xs">
                        Capacidade do Evento ({meta.maxParticipants} vagas)
                      </SelectItem>
                      <SelectItem value="totalBeds" className="text-xs">
                        Total de Camas ({meta.totalBeds} camas)
                      </SelectItem>
                      <SelectItem value="totalRaw" className="text-xs">
                        Total Geral de Inscritos ({meta.rawTotalCount})
                      </SelectItem>
                    </SelectGroup>
                  </SelectContent>
                </Select>
              </div>

              {/* Condition Field */}
              <div className="space-y-1 sm:col-span-2">
                <label className="font-bold text-zinc-700 dark:text-zinc-300">
                  Condição / Filtro Específico do KPI
                </label>
                <div className="grid grid-cols-1 sm:grid-cols-2 gap-2">
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
                    <SelectTrigger className="min-h-[44px] h-11 text-xs">
                      <SelectValue placeholder="Selecione o filtro" />
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

                  {conditionField !== "none" && (
                    <>
                      {conditionField === "paid" ? (
                        <Select
                          value={conditionValue}
                          onValueChange={(val) => setConditionValue(val)}
                        >
                          <SelectTrigger className="min-h-[44px] h-11 text-xs">
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
                          <SelectTrigger className="min-h-[44px] h-11 text-xs">
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
                          <SelectTrigger className="min-h-[44px] h-11 text-xs">
                            <SelectValue />
                          </SelectTrigger>
                          <SelectContent>
                            <SelectGroup>
                              <SelectItem value="pix" className="text-xs">
                                PIX
                              </SelectItem>
                              <SelectItem value="cartao" className="text-xs">
                                Cartão
                              </SelectItem>
                              <SelectItem value="dinheiro" className="text-xs">
                                Dinheiro
                              </SelectItem>
                              <SelectItem value="boleto" className="text-xs">
                                Boleto
                              </SelectItem>
                            </SelectGroup>
                          </SelectContent>
                        </Select>
                      ) : conditionField === "room_id" ? (
                        <Select
                          value={conditionOperator}
                          onValueChange={(val) =>
                            setConditionOperator(val as typeof conditionOperator)
                          }
                        >
                          <SelectTrigger className="min-h-[44px] h-11 text-xs">
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
                    </>
                  )}
                </div>
              </div>

              {/* Icon */}
              <div className="space-y-1">
                <label className="font-bold text-zinc-700 dark:text-zinc-300">
                  Ícone Visual
                </label>
                <Select value={iconName} onValueChange={(val) => setIconName(val)}>
                  <SelectTrigger className="min-h-[44px] h-11 text-xs">
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectGroup>
                      {ICON_OPTIONS.map((opt) => (
                        <SelectItem key={opt.id} value={opt.id} className="text-xs">
                          {opt.label}
                        </SelectItem>
                      ))}
                    </SelectGroup>
                  </SelectContent>
                </Select>
              </div>

              {/* Color Theme */}
              <div className="space-y-1">
                <label className="font-bold text-zinc-700 dark:text-zinc-300">
                  Tema de Destaque
                </label>
                <Select
                  value={colorTheme}
                  onValueChange={(val) => setColorTheme(val as typeof colorTheme)}
                >
                  <SelectTrigger className="min-h-[44px] h-11 text-xs">
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectGroup>
                      {COLOR_THEMES.map((theme) => (
                        <SelectItem key={theme.id} value={theme.id} className="text-xs">
                          {theme.label}
                        </SelectItem>
                      ))}
                    </SelectGroup>
                  </SelectContent>
                </Select>
              </div>

              {/* Subtitle / Description */}
              <div className="space-y-1 sm:col-span-2">
                <label className="font-bold text-zinc-700 dark:text-zinc-300">
                  Subtítulo / Descrição da Base
                </label>
                <Input
                  value={subtitle}
                  onChange={(e) => setSubtitle(e.target.value)}
                  placeholder="Ex: confirmadas via PIX, meta do retiro..."
                  className="min-h-[44px] h-11 text-xs"
                />
              </div>
            </div>

            {/* Editor Actions */}
            <div className="flex items-center justify-end gap-2 pt-2 border-t border-zinc-100 dark:border-zinc-800">
              <Button
                variant="ghost"
                onClick={() => {
                  resetForm();
                  setActiveTab("active");
                }}
                className="min-h-[44px] px-4 text-xs font-semibold cursor-pointer"
              >
                Cancelar
              </Button>
              <Button
                onClick={handleSaveForm}
                disabled={!title.trim()}
                className="min-h-[44px] px-4 text-xs font-bold rounded-lg bg-zinc-900 text-white hover:bg-zinc-800 dark:bg-zinc-50 dark:text-zinc-900 cursor-pointer"
              >
                {editingConfigId ? "Salvar Alterações" : "Adicionar ao Painel"}
              </Button>
            </div>
          </TabsContent>

          {/* TAB 3: MODELOS PRONTOS */}
          <TabsContent value="templates" className="space-y-3 pt-3">
            <p className="text-xs text-zinc-500 font-medium">
              Clique para adicionar uma métrica sugerida diretamente ao seu painel:
            </p>

            <div className="grid grid-cols-1 sm:grid-cols-2 gap-2.5">
              {PRESET_TEMPLATES.map((tmpl) => (
                <div
                  key={tmpl.id}
                  className="p-3 rounded-xl border border-zinc-200 dark:border-zinc-800 bg-white dark:bg-zinc-900 flex items-center justify-between gap-2 shadow-xs"
                >
                  <div className="flex items-center gap-2.5">
                    <div className="size-8 rounded-lg bg-zinc-100 dark:bg-zinc-800 flex items-center justify-center shrink-0">
                      {renderIcon(tmpl.iconName || "users")}
                    </div>
                    <div>
                      <div className="font-bold text-xs text-zinc-900 dark:text-zinc-50">
                        {tmpl.title}
                      </div>
                      <div className="text-[11px] text-zinc-500">
                        {tmpl.subtitle}
                      </div>
                    </div>
                  </div>

                  <Button
                    variant="outline"
                    onClick={() => handleAddTemplate(tmpl)}
                    className="min-h-[44px] px-3.5 text-xs font-bold rounded-lg shrink-0 cursor-pointer"
                  >
                    <Plus className="w-3.5 h-3.5 mr-1" />
                    <span>Adicionar</span>
                  </Button>
                </div>
              ))}
            </div>
          </TabsContent>
        </Tabs>
      </DialogContent>
    </Dialog>
  );
}
