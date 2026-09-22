/**
 * @file FilterBuilder.tsx
 * @description Dynamic multi-rule filter builder UI for event attendees.
 */

import { useState } from "react";
import {
  Plus,
  Trash2,
  Filter,
  RotateCcw,
  Sparkles,
  ChevronDown,
  ChevronUp,
} from "lucide-react";
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
import type {
  FilterRule,
  FilterLogic,
  FilterFieldOption,
  FilterOperator,
} from "@/types/eventsFilter";
import type { RetreatRoom } from "./RoomManagementTab";

interface FilterBuilderProps {
  rules: FilterRule[];
  logic: FilterLogic;
  retreatRooms?: RetreatRoom[];
  totalRawCount: number;
  filteredCount: number;
  isLoading?: boolean;
  onRulesChange: (rules: FilterRule[]) => void;
  onLogicChange: (logic: FilterLogic) => void;
  onApplyFilters: () => void;
  onClearFilters: () => void;
}

const FIELD_OPTIONS: FilterFieldOption[] = [
  {
    id: "paid",
    label: "Status do Pagamento",
    type: "boolean",
    allowedOperators: ["eq", "neq"],
    options: [
      { label: "Pago / Confirmado", value: "true" },
      { label: "Pendente", value: "false" },
    ],
  },
  {
    id: "room_id",
    label: "Alojamento / Quarto",
    type: "select",
    allowedOperators: ["is", "not_is", "eq", "neq"],
  },
  {
    id: "payment_method",
    label: "Método de Pagamento",
    type: "select",
    allowedOperators: ["eq", "ilike", "neq"],
    options: [
      { label: "PIX", value: "pix" },
      { label: "Cartão de Crédito", value: "cartao" },
      { label: "Boleto Bancário", value: "boleto" },
      { label: "Dinheiro / Espécie", value: "dinheiro" },
    ],
  },
  {
    id: "gender",
    label: "Gênero do Participante",
    type: "select",
    allowedOperators: ["eq", "neq"],
    options: [
      { label: "Masculino", value: "masculino" },
      { label: "Feminino", value: "feminino" },
    ],
  },
  {
    id: "participant_name",
    label: "Nome do Participante",
    type: "text",
    allowedOperators: ["ilike", "eq"],
  },
  {
    id: "created_at",
    label: "Data de Inscrição",
    type: "date",
    allowedOperators: ["gte", "lte"],
  },
];

const OPERATOR_LABELS: Record<FilterOperator, string> = {
  eq: "Igual a (=)",
  neq: "Diferente de (!=)",
  ilike: "Contém texto",
  is: "Está vazio / Não atribuído",
  not_is: "Está preenchido / Atribuído",
  gte: "A partir de (≥)",
  lte: "Até a data (≤)",
};

export function FilterBuilder({
  rules,
  logic,
  retreatRooms = [],
  totalRawCount,
  filteredCount,
  isLoading = false,
  onRulesChange,
  onLogicChange,
  onApplyFilters,
  onClearFilters,
}: FilterBuilderProps) {
  const [isExpanded, setIsExpanded] = useState(true);

  // Add new blank rule
  const handleAddRule = () => {
    const newRule: FilterRule = {
      id: `rule-${Date.now()}-${Math.random().toString(36).substring(2, 6)}`,
      field: "paid",
      operator: "eq",
      value: "true",
    };
    onRulesChange([...rules, newRule]);
    setIsExpanded(true);
  };

  // Update rule field
  const handleUpdateRule = (id: string, updates: Partial<FilterRule>) => {
    const nextRules = rules.map((r) => {
      if (r.id !== id) return r;
      const updated = { ...r, ...updates };

      // If field changed, reset operator and value to appropriate defaults
      if (updates.field && updates.field !== r.field) {
        const fieldConfig = FIELD_OPTIONS.find((f) => f.id === updates.field);
        if (fieldConfig) {
          updated.operator = fieldConfig.allowedOperators[0];
          if (fieldConfig.id === "paid") updated.value = "true";
          else if (fieldConfig.id === "gender") updated.value = "masculino";
          else if (fieldConfig.id === "room_id") updated.value = "";
          else updated.value = "";
        }
      }
      return updated;
    });
    onRulesChange(nextRules);
  };

  // Remove rule
  const handleRemoveRule = (id: string) => {
    onRulesChange(rules.filter((r) => r.id !== id));
  };

  // Apply Quick Filter Presets
  const applyQuickFilter = (preset: "all" | "pending" | "unallocated" | "paid" | "male" | "female") => {
    if (preset === "all") {
      onClearFilters();
      return;
    }

    let newRules: FilterRule[] = [];
    if (preset === "pending") {
      newRules = [
        {
          id: `preset-${Date.now()}`,
          field: "paid",
          operator: "eq",
          value: "false",
        },
      ];
    } else if (preset === "paid") {
      newRules = [
        {
          id: `preset-${Date.now()}`,
          field: "paid",
          operator: "eq",
          value: "true",
        },
      ];
    } else if (preset === "unallocated") {
      newRules = [
        {
          id: `preset-${Date.now()}`,
          field: "room_id",
          operator: "is",
          value: null,
        },
      ];
    } else if (preset === "male") {
      newRules = [
        {
          id: `preset-${Date.now()}`,
          field: "gender",
          operator: "eq",
          value: "masculino",
        },
      ];
    } else if (preset === "female") {
      newRules = [
        {
          id: `preset-${Date.now()}`,
          field: "gender",
          operator: "eq",
          value: "feminino",
        },
      ];
    }

    onRulesChange(newRules);
    onApplyFilters();
  };

  const activeRulesCount = rules.length;
  const isFiltered = activeRulesCount > 0;

  return (
    <div className="rounded-xl border border-zinc-200 dark:border-zinc-800 bg-white dark:bg-zinc-900 shadow-sm p-4 sm:p-5 w-full space-y-4">
      {/* Header bar */}
      <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-3 border-b border-zinc-100 dark:border-zinc-800/80 pb-3">
        <div className="flex items-center gap-2.5">
          <div className="size-8 rounded-lg bg-primary/10 dark:bg-primary/20 text-primary flex items-center justify-center shrink-0">
            <Filter className="w-4 h-4" />
          </div>
          <div>
            <div className="flex items-center gap-2">
              <h3 className="font-bold text-sm text-zinc-900 dark:text-zinc-50 tracking-tight">
                Construtor de Filtros Dinâmicos
              </h3>
              {isFiltered && (
                <Badge
                  variant="secondary"
                  className="bg-primary/10 text-primary text-[10px] font-bold px-2 py-0.5"
                >
                  {activeRulesCount} {activeRulesCount === 1 ? "regra ativa" : "regras ativas"}
                </Badge>
              )}
            </div>
            <p className="text-xs text-zinc-500 dark:text-zinc-400">
              Combine regras condicionais para segmentar inscritos e recalcular os KPIs em tempo real.
            </p>
          </div>
        </div>

        {/* Header Right Actions */}
        <div className="flex items-center gap-2 self-end sm:self-auto">
          {/* Toggle Expand/Collapse */}
          <Button
            variant="ghost"
            size="sm"
            onClick={() => setIsExpanded(!isExpanded)}
            className="min-h-[44px] h-11 sm:min-h-[36px] sm:h-9 text-xs text-zinc-500 font-semibold cursor-pointer px-2.5"
          >
            {isExpanded ? (
              <>
                <ChevronUp className="w-3.5 h-3.5 mr-1" />
                <span>Ocultar Construtor</span>
              </>
            ) : (
              <>
                <ChevronDown className="w-3.5 h-3.5 mr-1" />
                <span>Editar Filtros ({activeRulesCount})</span>
              </>
            )}
          </Button>
        </div>
      </div>

      {/* Expandable Filter Rules Body */}
      {isExpanded && (
        <div className="space-y-3 pt-1">
          {/* Logic Match Selector (AND / OR) */}
          {rules.length > 1 && (
            <div className="flex items-center gap-2 bg-zinc-50 dark:bg-zinc-800/50 p-2 rounded-lg text-xs">
              <span className="font-semibold text-zinc-600 dark:text-zinc-400">
                Correspondência:
              </span>
              <div className="flex items-center gap-1">
                <Button
                  variant={logic === "AND" ? "default" : "outline"}
                  size="sm"
                  onClick={() => onLogicChange("AND")}
                  className={`min-h-[44px] h-11 sm:min-h-[32px] sm:h-8 px-3 text-xs font-bold rounded-md cursor-pointer ${
                    logic === "AND"
                      ? "bg-zinc-900 text-white dark:bg-zinc-100 dark:text-zinc-900"
                      : "text-zinc-600"
                  }`}
                >
                  E (Todas as regras)
                </Button>
                <Button
                  variant={logic === "OR" ? "default" : "outline"}
                  size="sm"
                  onClick={() => onLogicChange("OR")}
                  className={`min-h-[44px] h-11 sm:min-h-[32px] sm:h-8 px-3 text-xs font-bold rounded-md cursor-pointer ${
                    logic === "OR"
                      ? "bg-zinc-900 text-white dark:bg-zinc-100 dark:text-zinc-900"
                      : "text-zinc-600"
                  }`}
                >
                  OU (Qualquer regra)
                </Button>
              </div>
            </div>
          )}

          {/* Rules List */}
          <div className="space-y-2.5">
            {rules.map((rule, idx) => {
              const selectedFieldConfig =
                FIELD_OPTIONS.find((f) => f.id === rule.field) || FIELD_OPTIONS[0];
              const isUnary = rule.operator === "is" || rule.operator === "not_is";

              return (
                <div
                  key={rule.id}
                  className="flex flex-col md:flex-row items-stretch md:items-center gap-2.5 p-3 rounded-lg bg-zinc-50/70 dark:bg-zinc-800/40 border border-zinc-200/80 dark:border-zinc-800 transition-colors"
                >
                  {/* Step Label / Logic indicator */}
                  <div className="shrink-0 text-xs font-bold text-zinc-400 w-16">
                    {idx === 0 ? "Onde" : logic === "AND" ? "E também" : "Ou então"}
                  </div>

                  {/* 1. Column / Field Select */}
                  <div className="flex-1 min-w-[180px]">
                    <Select
                      value={rule.field}
                      onValueChange={(val) => handleUpdateRule(rule.id, { field: val })}
                    >
                      <SelectTrigger className="min-h-[44px] h-11 text-xs bg-white dark:bg-zinc-900">
                        <SelectValue placeholder="Selecione a coluna" />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectGroup>
                          {FIELD_OPTIONS.map((field) => (
                            <SelectItem key={field.id} value={field.id} className="text-xs">
                              {field.label}
                            </SelectItem>
                          ))}
                        </SelectGroup>
                      </SelectContent>
                    </Select>
                  </div>

                  {/* 2. Operator Select */}
                  <div className="w-full md:w-[190px] shrink-0">
                    <Select
                      value={rule.operator}
                      onValueChange={(val) =>
                        handleUpdateRule(rule.id, { operator: val as FilterOperator })
                      }
                    >
                      <SelectTrigger className="min-h-[44px] h-11 text-xs bg-white dark:bg-zinc-900">
                        <SelectValue placeholder="Operador" />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectGroup>
                          {selectedFieldConfig.allowedOperators.map((op) => (
                            <SelectItem key={op} value={op} className="text-xs">
                              {OPERATOR_LABELS[op]}
                            </SelectItem>
                          ))}
                        </SelectGroup>
                      </SelectContent>
                    </Select>
                  </div>

                  {/* 3. Value Input (contextual) */}
                  <div className="flex-1 min-w-[160px]">
                    {isUnary ? (
                      <div className="min-h-[44px] h-11 flex items-center px-3 rounded-md border border-dashed border-zinc-200 dark:border-zinc-700 text-xs text-zinc-400 italic bg-zinc-100/50 dark:bg-zinc-800/50">
                        (Não requer valor adicional)
                      </div>
                    ) : rule.field === "paid" ? (
                      <Select
                        value={String(rule.value)}
                        onValueChange={(val) => handleUpdateRule(rule.id, { value: val })}
                      >
                        <SelectTrigger className="min-h-[44px] h-11 text-xs bg-white dark:bg-zinc-900">
                          <SelectValue placeholder="Status" />
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
                    ) : rule.field === "gender" ? (
                      <Select
                        value={String(rule.value)}
                        onValueChange={(val) => handleUpdateRule(rule.id, { value: val })}
                      >
                        <SelectTrigger className="min-h-[44px] h-11 text-xs bg-white dark:bg-zinc-900">
                          <SelectValue placeholder="Gênero" />
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
                    ) : rule.field === "room_id" ? (
                      <Select
                        value={String(rule.value || "")}
                        onValueChange={(val) => handleUpdateRule(rule.id, { value: val })}
                      >
                        <SelectTrigger className="min-h-[44px] h-11 text-xs bg-white dark:bg-zinc-900">
                          <SelectValue placeholder="Selecione o quarto" />
                        </SelectTrigger>
                        <SelectContent>
                          <SelectGroup>
                            {retreatRooms.map((room) => (
                              <SelectItem key={room.id} value={room.id} className="text-xs">
                                {room.name} ({room.gender_type || "Geral"})
                              </SelectItem>
                            ))}
                          </SelectGroup>
                        </SelectContent>
                      </Select>
                    ) : rule.field === "payment_method" ? (
                      <Select
                        value={String(rule.value || "")}
                        onValueChange={(val) => handleUpdateRule(rule.id, { value: val })}
                      >
                        <SelectTrigger className="min-h-[44px] h-11 text-xs bg-white dark:bg-zinc-900">
                          <SelectValue placeholder="Método" />
                        </SelectTrigger>
                        <SelectContent>
                          <SelectGroup>
                            <SelectItem value="pix" className="text-xs">
                              PIX
                            </SelectItem>
                            <SelectItem value="cartao" className="text-xs">
                              Cartão de Crédito
                            </SelectItem>
                            <SelectItem value="boleto" className="text-xs">
                              Boleto
                            </SelectItem>
                            <SelectItem value="dinheiro" className="text-xs">
                              Dinheiro / Espécie
                            </SelectItem>
                          </SelectGroup>
                        </SelectContent>
                      </Select>
                    ) : rule.field === "created_at" ? (
                      <Input
                        type="date"
                        value={String(rule.value || "")}
                        onChange={(e) => handleUpdateRule(rule.id, { value: e.target.value })}
                        className="min-h-[44px] h-11 text-xs bg-white dark:bg-zinc-900"
                      />
                    ) : (
                      <Input
                        placeholder="Valor do filtro..."
                        value={String(rule.value || "")}
                        onChange={(e) => handleUpdateRule(rule.id, { value: e.target.value })}
                        className="min-h-[44px] h-11 text-xs bg-white dark:bg-zinc-900"
                      />
                    )}
                  </div>

                  {/* Remove Rule Button */}
                  <Button
                    variant="ghost"
                    size="icon"
                    onClick={() => handleRemoveRule(rule.id)}
                    className="min-h-[44px] min-w-[44px] h-11 w-11 text-red-500 hover:bg-red-500/10 rounded-md cursor-pointer shrink-0 self-end md:self-auto"
                    aria-label="Excluir regra"
                  >
                    <Trash2 className="w-4 h-4" />
                  </Button>
                </div>
              );
            })}
          </div>

          {/* Builder Controls Bottom Bar */}
          <div className="flex flex-wrap items-center justify-between gap-3 pt-2">
            <div className="flex items-center gap-2">
              <Button
                variant="outline"
                size="sm"
                onClick={handleAddRule}
                className="min-h-[44px] h-11 sm:min-h-[36px] sm:h-9 text-xs font-semibold rounded-lg flex items-center gap-1.5 cursor-pointer hover:bg-zinc-100 dark:hover:bg-zinc-800"
              >
                <Plus className="w-4 h-4" />
                <span>Adicionar Regra</span>
              </Button>

              {isFiltered && (
                <Button
                  variant="ghost"
                  size="sm"
                  onClick={onClearFilters}
                  className="min-h-[44px] h-11 sm:min-h-[36px] sm:h-9 text-xs font-semibold text-zinc-500 hover:text-zinc-900 dark:hover:text-zinc-100 rounded-lg flex items-center gap-1.5 cursor-pointer"
                >
                  <RotateCcw className="w-3.5 h-3.5" />
                  <span>Limpar Tudo</span>
                </Button>
              )}
            </div>

            <Button
              onClick={onApplyFilters}
              disabled={isLoading}
              className="min-h-[44px] h-11 sm:min-h-[36px] sm:h-9 px-4 text-xs font-bold rounded-lg bg-zinc-900 text-white hover:bg-zinc-800 dark:bg-zinc-50 dark:text-zinc-900 dark:hover:bg-zinc-200 cursor-pointer shadow-sm flex items-center gap-2"
            >
              <Sparkles className="w-3.5 h-3.5" />
              <span>Aplicar Filtros ({activeRulesCount})</span>
            </Button>
          </div>
        </div>
      )}

      {/* Quick Filter Presets Chips */}
      <div className="flex flex-wrap items-center gap-1.5 pt-1 border-t border-zinc-100 dark:border-zinc-800/80 text-xs">
        <span className="text-[11px] font-bold uppercase tracking-wider text-zinc-400 mr-1 flex items-center gap-1">
          Filtros Rápidos:
        </span>

        <button
          onClick={() => applyQuickFilter("all")}
          className={`min-h-[32px] px-2.5 py-1 rounded-full text-xs font-medium transition-all cursor-pointer ${
            !isFiltered
              ? "bg-zinc-900 text-white dark:bg-zinc-100 dark:text-zinc-900 font-bold shadow-xs"
              : "bg-zinc-100 hover:bg-zinc-200 text-zinc-700 dark:bg-zinc-800 dark:text-zinc-300"
          }`}
        >
          Todos ({totalRawCount})
        </button>

        <button
          onClick={() => applyQuickFilter("pending")}
          className="min-h-[32px] px-2.5 py-1 rounded-full text-xs font-medium bg-amber-500/10 text-amber-700 dark:text-amber-400 hover:bg-amber-500/20 transition-all cursor-pointer border border-amber-500/20"
        >
          Pagamento Pendente
        </button>

        <button
          onClick={() => applyQuickFilter("paid")}
          className="min-h-[32px] px-2.5 py-1 rounded-full text-xs font-medium bg-emerald-500/10 text-emerald-700 dark:text-emerald-400 hover:bg-emerald-500/20 transition-all cursor-pointer border border-emerald-500/20"
        >
          Quitados / Pagos
        </button>

        <button
          onClick={() => applyQuickFilter("unallocated")}
          className="min-h-[32px] px-2.5 py-1 rounded-full text-xs font-medium bg-blue-500/10 text-blue-700 dark:text-blue-400 hover:bg-blue-500/20 transition-all cursor-pointer border border-blue-500/20"
        >
          Sem Alojamento
        </button>

        <button
          onClick={() => applyQuickFilter("male")}
          className="min-h-[32px] px-2.5 py-1 rounded-full text-xs font-medium bg-zinc-100 hover:bg-zinc-200 text-zinc-700 dark:bg-zinc-800 dark:text-zinc-300 transition-all cursor-pointer"
        >
          Homens
        </button>

        <button
          onClick={() => applyQuickFilter("female")}
          className="min-h-[32px] px-2.5 py-1 rounded-full text-xs font-medium bg-zinc-100 hover:bg-zinc-200 text-zinc-700 dark:bg-zinc-800 dark:text-zinc-300 transition-all cursor-pointer"
        >
          Mulheres
        </button>

        {isFiltered && (
          <span className="ml-auto text-xs text-zinc-500 dark:text-zinc-400">
            Exibindo <strong>{filteredCount}</strong> de <strong>{totalRawCount}</strong> participantes
          </span>
        )}
      </div>
    </div>
  );
}
