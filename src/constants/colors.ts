/**
 * @file colors.ts
 * @description Centralized color constants for the website.
 *
 * ⚠️ REGRAS OBRIGATÓRIAS:
 * 1. USO: Qualquer cor em runtime JS/TS (Canvas, SVGs, Leaflet, gráficos, estilos inline ou classes utilitárias)
 *    DEVE ser importada deste arquivo. É proibido usar cores hexadecimais soltas ou hardcoded nos componentes.
 * 2. ATUALIZAÇÃO: Qualquer nova cor, variação de tom ou token de design introduzido no projeto DEVE ser
 *    registrado e documentado aqui primeiro.
 * 3. ACESSIBILIDADE: Toda combinação de cores deve ser validada contra as diretrizes WCAG AA/AAA
 *    utilizando o MCP `accessibility` (`are-colors-accessible`, `get-color-contrast`, `use-light-or-dark`).
 */

// ==========================================
// 1. PALETA BASE (Zinc + Neutrals)
// ==========================================
export const PALETTE = {
  zinc: {
    50: "#fafafa",
    100: "#f4f4f5",
    200: "#e4e4e7",
    300: "#d4d4d8",
    400: "#a1a1aa",
    500: "#71717a",
    600: "#52525b",
    700: "#3f3f46",
    800: "#27272a",
    900: "#18181b",
    950: "#09090b",
  },
  white: "#ffffff",
  black: "#000000",
} as const;

// ==========================================
// 2. CORES DA MARCA / PRIMÁRIA (OKLCH + Hex)
// ==========================================
export const BRAND_COLORS = {
  primary: {
    light: {
      oklch: "oklch(0.35 0.08 155)",
      hex: "#1b4332", // Deep Forest Olive
    },
    dark: {
      oklch: "oklch(0.88 0.15 145)",
      hex: "#86efac", // Sage / Mint
    },
  },
  accent: {
    light: {
      oklch: "oklch(0.55 0.16 65)",
      hex: "#b45309", // Warm Amber
    },
    dark: {
      oklch: "oklch(0.82 0.16 80)",
      hex: "#fbbf24", // Golden Amber
    },
  },
} as const;

// ==========================================
// 3. TOKENS SEMÂNTICOS POR TEMA (Light / Dark)
// ==========================================
export const THEME_TOKENS = {
  light: {
    background: "#faf9f6",
    foreground: "#18181b",
    card: "#ffffff",
    cardForeground: "#18181b",
    popover: "#ffffff",
    popoverForeground: "#18181b",
    primary: "#1b4332",
    primaryForeground: "#fafafa",
    secondary: "#f4efe6",
    secondaryForeground: "#1b4332",
    muted: "#f4efe6",
    mutedForeground: "#52525b",
    accent: "#f4efe6",
    accentForeground: "#92400e",
    destructive: "#dc2626",
    destructiveForeground: "#fafafa",
    border: "#e5e7eb",
    input: "#e5e7eb",
    ring: "#1b4332",
  },
  dark: {
    background: "#09090b",
    foreground: "#fafafa",
    card: "#18181b",
    cardForeground: "#fafafa",
    popover: "#18181b",
    popoverForeground: "#fafafa",
    primary: "#86efac",
    primaryForeground: "#09090b",
    secondary: "#162e24",
    secondaryForeground: "#86efac",
    muted: "#162e24",
    mutedForeground: "#a1a1aa",
    accent: "#162e24",
    accentForeground: "#fbbf24",
    destructive: "#ef4444",
    destructiveForeground: "#fafafa",
    border: "#27272a",
    input: "#27272a",
    ring: "#86efac",
  },
} as const;

// ==========================================
// 4. CORES DE FEEDBACK / STATUS
// ==========================================
export const STATUS_COLORS = {
  success: {
    light: "#16a34a",
    dark: "#22c55e",
    bgLight: "rgba(22, 163, 74, 0.1)",
    bgDark: "rgba(34, 197, 94, 0.15)",
    borderLight: "rgba(22, 163, 74, 0.2)",
    borderDark: "rgba(34, 197, 94, 0.25)",
  },
  warning: {
    light: "#d97706",
    dark: "#f59e0b",
    bgLight: "rgba(217, 119, 6, 0.1)",
    bgDark: "rgba(245, 158, 11, 0.15)",
    borderLight: "rgba(217, 119, 6, 0.2)",
    borderDark: "rgba(245, 158, 11, 0.25)",
  },
  destructive: {
    light: "#dc2626",
    dark: "#ef4444",
    bgLight: "rgba(220, 38, 38, 0.1)",
    bgDark: "rgba(239, 68, 68, 0.15)",
    borderLight: "rgba(220, 38, 38, 0.2)",
    borderDark: "rgba(239, 68, 68, 0.25)",
  },
  info: {
    light: "#2563eb",
    dark: "#38bdf8",
    bgLight: "rgba(37, 99, 235, 0.1)",
    bgDark: "rgba(56, 189, 248, 0.15)",
    borderLight: "rgba(37, 99, 235, 0.2)",
    borderDark: "rgba(56, 189, 248, 0.25)",
  },
} as const;

// ==========================================
// 5. VISUALIZAÇÃO DE GRAFOS / CANVAS (Rede de Relacionamentos)
// ==========================================
export type GraphNodeRole =
  | "discipulador"
  | "lider"
  | "anfitriao"
  | "visitante"
  | "inativo";

export const GRAPH_NODE_COLORS = {
  discipulador: {
    light: { stroke: "#e11d48", fill: "rgba(225, 29, 72, 0.12)" },
    dark: { stroke: "#fb7185", fill: "rgba(251, 113, 133, 0.15)" },
  },
  lider: {
    light: { stroke: "#9333ea", fill: "rgba(147, 51, 234, 0.12)" },
    dark: { stroke: "#c084fc", fill: "rgba(192, 132, 252, 0.15)" },
  },
  anfitriao: {
    light: { stroke: "#2563eb", fill: "rgba(37, 99, 235, 0.12)" },
    dark: { stroke: "#60a5fa", fill: "rgba(96, 165, 250, 0.15)" },
  },
  visitante: {
    light: { stroke: "#d97706", fill: "rgba(217, 119, 6, 0.12)" },
    dark: { stroke: "#fbbf24", fill: "rgba(251, 191, 36, 0.15)" },
  },
  inativo: {
    light: { stroke: "#71717a", fill: "rgba(113, 113, 122, 0.08)" },
    dark: { stroke: "#a1a1aa", fill: "rgba(161, 161, 170, 0.15)" },
  },
} as const;

export const GRAPH_LINK_COLORS = {
  default: { light: "#e4e4e7", dark: "#27272a" },
  active: { light: "#6366f1", dark: "#818cf8" },
  arrow: { light: "#a1a1aa", dark: "#71717a" },
} as const;

export const GRAPH_COLORS = {
  ...GRAPH_NODE_COLORS,
  link: GRAPH_LINK_COLORS,
} as const;

// ==========================================
// 6. CLASSES TAILWIND PADRONIZADAS (Reutilização de UI)
// ==========================================
export const THEME_CLASSES = {
  // Fundo geral da página
  background: "bg-zinc-50 dark:bg-zinc-950",

  // Superfícies e Containers
  surface: "bg-white border-zinc-200 dark:bg-zinc-900 dark:border-zinc-800",
  card: "bg-white border border-zinc-200 dark:bg-zinc-900 dark:border-zinc-800 rounded-xl shadow-sm",
  cardHover: "hover:border-zinc-300 dark:hover:border-zinc-700 transition-colors",

  // Textos
  title: "text-zinc-900 dark:text-zinc-50 font-bold",
  subtitle: "text-zinc-700 dark:text-zinc-300",
  body: "text-zinc-600 dark:text-zinc-400 text-sm",
  muted: "text-zinc-500 dark:text-zinc-500 text-xs",

  // Ações Primárias (Botões)
  buttonPrimary:
    "bg-zinc-900 text-zinc-50 hover:bg-zinc-800 dark:bg-zinc-50 dark:text-zinc-900 dark:hover:bg-zinc-200 rounded-md transition-colors",
  buttonSecondary:
    "bg-zinc-100 text-zinc-900 hover:bg-zinc-200 dark:bg-zinc-800 dark:text-zinc-100 dark:hover:bg-zinc-700 rounded-md transition-colors",
  buttonOutline:
    "border border-zinc-200 bg-transparent text-zinc-900 hover:bg-zinc-100 dark:border-zinc-800 dark:text-zinc-100 dark:hover:bg-zinc-800 rounded-md transition-colors",

  // Inputs e Formulários
  input:
    "border-zinc-200 bg-white text-zinc-900 focus:border-zinc-400 dark:border-zinc-800 dark:bg-zinc-900 dark:text-zinc-100 dark:focus:border-zinc-600 rounded-md",

  // Badges e Tags
  badgeNeutral:
    "inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium bg-zinc-500/10 text-zinc-600 border border-zinc-500/20 dark:bg-zinc-400/10 dark:text-zinc-400 dark:border-zinc-400/20",
  badgePrimary:
    "inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium bg-primary/10 text-primary border border-primary/20",
  badgeSuccess:
    "inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium bg-green-500/10 text-green-600 border border-green-500/20 dark:text-green-400",
  badgeWarning:
    "inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium bg-amber-500/10 text-amber-600 border border-amber-500/20 dark:text-amber-400",
  badgeDestructive:
    "inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium bg-red-500/10 text-red-600 border border-red-500/20 dark:text-red-400",
} as const;

// ==========================================
// 7. FUNÇÕES AUXILIARES DE CORES
// ==========================================
/**
 * Retorna os tokens semânticos baseados no modo dark atual.
 */
export function getThemeTokens(isDark: boolean) {
  return isDark ? THEME_TOKENS.dark : THEME_TOKENS.light;
}

/**
 * Retorna as cores de estilo para nós do grafo de relacionamentos.
 */
export function getGraphNodeColors(role: GraphNodeRole, isDark: boolean) {
  const roleConfig = GRAPH_NODE_COLORS[role] ?? GRAPH_NODE_COLORS.inativo;
  return isDark ? roleConfig.dark : roleConfig.light;
}

