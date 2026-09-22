/**
 * @file kpiAggregator.ts
 * @description Dynamic client-side KPI aggregation engine accepting filtered datasets and recalculating metrics reactively.
 */

import type { KPIConfig, ComputedKPICard } from "@/types/eventsFilter";
import type { RegistrationWithDetails } from "@/components/events/RegistrationDetailDialog";
import type { RetreatRoom } from "@/components/events/RoomManagementTab";
import { extractRegistrationGender } from "./eventsQueryBuilder";

export interface ContextMeta {
  rawTotalCount: number;
  basePrice: number;
  maxParticipants: number;
  totalBeds: number;
  rooms?: RetreatRoom[];
  calculatePrice?: (reg: RegistrationWithDetails) => number;
}

export const formatCurrency = (val: number): string =>
  new Intl.NumberFormat("pt-BR", {
    style: "currency",
    currency: "BRL",
  }).format(val);

export const formatPercent = (val: number): string => `${Math.round(val)}%`;

/**
 * Default KPI configurations representing the primary event management dimensions.
 */
export const DEFAULT_KPI_CONFIGS: KPIConfig[] = [
  {
    id: "kpi-registrations",
    title: "Inscrições & Lotação",
    type: "count",
    totalBase: "maxParticipants",
    format: "number",
    iconName: "users",
    colorTheme: "default",
    subtitle: "vagas preenchidas",
  },
  {
    id: "kpi-payments",
    title: "Pagamentos",
    type: "count",
    condition: {
      field: "paid",
      operator: "eq",
      value: true,
    },
    totalBase: "totalFiltered",
    format: "number",
    iconName: "check",
    colorTheme: "emerald",
    subtitle: "inscrições pagas",
  },
  {
    id: "kpi-revenue",
    title: "Faturamento Confirmado",
    type: "sum",
    field: "price",
    condition: {
      field: "paid",
      operator: "eq",
      value: true,
    },
    format: "currency",
    iconName: "dollar",
    colorTheme: "default",
    subtitle: "arrecadação realizada",
  },
  {
    id: "kpi-rooms",
    title: "Alojamentos & Quartos",
    type: "count",
    condition: {
      field: "room_id",
      operator: "truthy",
    },
    totalBase: "totalBeds",
    format: "number",
    iconName: "bed",
    colorTheme: "blue",
    subtitle: "camas ocupadas",
  },
];

/**
 * Filter items according to a KPI condition.
 */
export function applyKpiCondition(
  items: RegistrationWithDetails[],
  config: KPIConfig
): RegistrationWithDetails[] {
  if (!config.condition) return items;

  const { field, operator, value } = config.condition;

  return items.filter((item) => {
    if (field === "paid") {
      const boolVal = Boolean(item.paid);
      if (operator === "eq") return boolVal === Boolean(value);
      if (operator === "neq") return boolVal !== Boolean(value);
      if (operator === "truthy") return boolVal;
      if (operator === "falsy") return !boolVal;
    }

    if (field === "room_id") {
      const hasRoom = Boolean(
        item.room_id ||
          (item.room_allocation && item.room_allocation !== "Não alocado")
      );
      if (operator === "truthy") return hasRoom;
      if (operator === "falsy") return !hasRoom;
      if (operator === "eq") return item.room_id === value;
      if (operator === "neq") return item.room_id !== value;
    }

    if (field === "gender") {
      const g = extractRegistrationGender(item);
      if (operator === "eq") return g === String(value).toLowerCase();
      if (operator === "neq") return g !== String(value).toLowerCase();
    }

    if (field === "payment_method") {
      const m = (item.payment_method || "").toLowerCase();
      if (operator === "eq") return m === String(value).toLowerCase();
      if (operator === "neq") return m !== String(value).toLowerCase();
    }

    return true;
  });
}

/**
 * Computes a single KPI card based on the filtered data and context metadata.
 */
export function computeKpiCard(
  data: RegistrationWithDetails[],
  config: KPIConfig,
  meta: ContextMeta
): ComputedKPICard {
  const filteredSubset = applyKpiCondition(data, config);
  const count = filteredSubset.length;
  const totalInFilter = data.length;

  let computedValue: string | number = count;
  let secondaryValue = "";
  let badgeText = "";
  let badgeVariant: ComputedKPICard["badgeVariant"] = "outline";
  let progress: number | undefined = undefined;
  let description = config.subtitle || "";

  // 1. Determine Total Base for Percentage / Progress
  let baseValue = totalInFilter;
  if (config.totalBase === "maxParticipants") {
    baseValue = meta.maxParticipants || 100;
  } else if (config.totalBase === "totalBeds") {
    baseValue = meta.totalBeds || 1;
  } else if (config.totalBase === "totalRaw") {
    baseValue = meta.rawTotalCount || 1;
  }

  // 2. Count Type
  if (config.type === "count") {
    computedValue = count;

    if (config.id === "kpi-registrations") {
      const rate = baseValue > 0 ? Math.min(100, Math.round((count / baseValue) * 100)) : 0;
      progress = rate;
      badgeText = `${rate}% Lotação`;
      badgeVariant = rate >= 90 ? "warning" : "outline";
      secondaryValue = `/ ${baseValue} vagas`;
      description = `${Math.max(0, baseValue - count)} vagas disponíveis`;
    } else if (config.id === "kpi-payments") {
      const rate = totalInFilter > 0 ? Math.min(100, Math.round((count / totalInFilter) * 100)) : 0;
      badgeText = `${rate}% Quitados`;
      badgeVariant = "success";
      secondaryValue = "pagos";
      const pendingCount = totalInFilter - count;
      description = `${pendingCount} pendente${pendingCount === 1 ? "" : "s"} (${totalInFilter} no filtro)`;
    } else if (config.id === "kpi-rooms") {
      const rate = meta.totalBeds > 0 ? Math.min(100, Math.round((count / meta.totalBeds) * 100)) : 0;
      badgeText = `${rate}% Ocupado`;
      badgeVariant = "outline";
      secondaryValue = `/ ${meta.totalBeds} camas`;
      const unallocated = totalInFilter - count;
      description =
        unallocated > 0
          ? `${unallocated} sem quarto`
          : "Todos alocados";
    } else {
      const rate = baseValue > 0 ? Math.min(100, Math.round((count / baseValue) * 100)) : 0;
      progress = config.totalBase ? rate : undefined;
      badgeText = config.totalBase ? `${rate}%` : `${count} ${count === 1 ? "inscrito" : "inscritos"}`;
      badgeVariant =
        config.colorTheme === "emerald"
          ? "success"
          : config.colorTheme === "amber"
          ? "warning"
          : "outline";
      secondaryValue = config.totalBase ? `/ ${baseValue}` : "inscritos";
      if (!description) {
        description = `${count} de ${totalInFilter} no filtro atual`;
      }
    }
  }

  // 3. Sum Type (e.g. Revenue)
  if (config.type === "sum") {
    // Calculate total revenue from filtered subset
    const sumAmount = filteredSubset.reduce((acc, reg) => {
      const price = meta.calculatePrice ? meta.calculatePrice(reg) : meta.basePrice;
      return acc + price;
    }, 0);

    const totalEstimated = data.reduce((acc, reg) => {
      const price = meta.calculatePrice ? meta.calculatePrice(reg) : meta.basePrice;
      return acc + price;
    }, 0);

    computedValue = formatCurrency(sumAmount);

    if (config.id === "kpi-revenue") {
      badgeText = `Estimado: ${formatCurrency(totalEstimated)}`;
      badgeVariant = "outline";
      const pendingAmount = Math.max(0, totalEstimated - sumAmount);
      description = `A receber: ${formatCurrency(pendingAmount)}`;
    } else {
      badgeText = `${filteredSubset.length} pagantes`;
      badgeVariant =
        config.colorTheme === "emerald"
          ? "success"
          : config.colorTheme === "amber"
          ? "warning"
          : "outline";
      if (!description) {
        description = `Valor consolidado dos itens`;
      }
    }
  }

  // 4. Percentage Type
  if (config.type === "percentage") {
    const rate = baseValue > 0 ? (count / baseValue) * 100 : 0;
    computedValue = formatPercent(rate);
    progress = Math.min(100, Math.round(rate));
    badgeText = `${count} de ${baseValue}`;
    badgeVariant =
      config.colorTheme === "emerald"
        ? "success"
        : config.colorTheme === "amber"
        ? "warning"
        : "outline";
    secondaryValue = "do total";
  }

  // 5. Average Type
  if (config.type === "average") {
    const sumAmount = filteredSubset.reduce((acc, reg) => {
      const price = meta.calculatePrice ? meta.calculatePrice(reg) : meta.basePrice;
      return acc + price;
    }, 0);
    const avg = count > 0 ? sumAmount / count : 0;
    computedValue = formatCurrency(avg);
    secondaryValue = "por inscrito";
    badgeText = `${count} registros`;
    badgeVariant =
      config.colorTheme === "emerald"
        ? "success"
        : config.colorTheme === "amber"
        ? "warning"
        : "outline";
  }

  // Generate human-readable synthesized formula for transparency
  let formulaText = "";
  if (config.type === "count") {
    if (config.condition && config.condition.field && config.condition.field !== "none") {
      formulaText = `=COUNTIFS(Inscrições[${config.condition.field}]; "${config.condition.value ?? "ativo"}")`;
    } else {
      formulaText = `=COUNTA(Inscrições[ID])`;
    }
  } else if (config.type === "sum") {
    if (config.condition && config.condition.field && config.condition.field !== "none") {
      formulaText = `=SUMIFS(Inscrições[Preço]; Inscrições[${config.condition.field}]; "${config.condition.value ?? "ativo"}")`;
    } else {
      formulaText = `=SUM(Inscrições[Preço_Total])`;
    }
  } else if (config.type === "percentage") {
    formulaText = `=(${config.condition ? "COUNTIFS(...)" : "Contagem"} / Base[${config.totalBase || "Total"}]) * 100%`;
  } else if (config.type === "average") {
    formulaText = `=AVERAGE(Inscrições[Preço_Inscrição])`;
  }

  const targetText = config.target ? `Alvo: ${config.target}` : undefined;

  return {
    id: config.id,
    title: config.title,
    value: computedValue,
    secondaryValue,
    badgeText,
    badgeVariant,
    progress,
    iconName: config.iconName || "users",
    colorTheme: config.colorTheme || "default",
    description,
    targetText,
    formulaText,
  };
}

/**
 * Computes all configured KPI cards for the given filtered dataset.
 */
export function aggregateKpis(
  data: RegistrationWithDetails[],
  configs: KPIConfig[],
  meta: ContextMeta
): ComputedKPICard[] {
  return configs.map((cfg) => computeKpiCard(data, cfg, meta));
}
