/**
 * @file eventsFilter.ts
 * @description Types and interfaces for the dynamic List Builder and KPI Builder.
 */

export type FilterOperator =
  | "eq"        // Equals
  | "neq"       // Not equals
  | "ilike"     // Contains (case-insensitive text)
  | "is"        // Is null / empty
  | "not_is"    // Is not null / filled
  | "gte"       // Greater than or equal (dates/numbers)
  | "lte";      // Less than or equal (dates/numbers)

export interface FilterRule {
  id: string;
  field: string;
  operator: FilterOperator;
  value: string | boolean | number | null;
}

export type FilterLogic = "AND" | "OR";

export type KPIType = "count" | "sum" | "percentage" | "average";

export interface KPICondition {
  field: string;
  operator: "eq" | "neq" | "truthy" | "falsy" | "gt" | "lt";
  value?: unknown;
}

export interface KPIConfig {
  id: string;
  title: string;
  type: KPIType;
  field?: string;
  condition?: KPICondition;
  totalBase?: "totalFiltered" | "maxParticipants" | "totalBeds" | "totalRaw";
  format?: "number" | "currency" | "percentage";
  iconName?: "users" | "dollar" | "bed" | "check" | "clock" | "alert" | "trending-up" | "chart" | "pin" | "percent" | "qr_code";
  colorTheme?: "default" | "emerald" | "amber" | "blue" | "zinc" | "rose";
  subtitle?: string;
  target?: string;
}

export interface ComputedKPICard {
  id: string;
  title: string;
  value: string | number;
  secondaryValue?: string;
  badgeText?: string;
  badgeVariant?: "default" | "secondary" | "outline" | "success" | "warning";
  progress?: number;
  iconName: string;
  colorTheme: string;
  description?: string;
  targetText?: string;
  formulaText?: string;
}

export interface FilterFieldOption {
  id: string;
  label: string;
  type: "boolean" | "text" | "select" | "date" | "number";
  options?: { label: string; value: string }[];
  allowedOperators: FilterOperator[];
}
