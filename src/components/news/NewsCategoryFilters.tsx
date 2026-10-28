import {
  Bell,
  HeartHandshake,
  Globe,
  MapPin,
  BookOpen,
  ClipboardList,
  CalendarDays,
  Layers,
} from "lucide-react"
import { cn } from "@/lib/utils"
import type { PostCategory } from "@/hooks/useNewsFeed"

export interface CategoryFilterItem {
  id: PostCategory | "todos"
  label: string
  icon: React.ComponentType<{ className?: string }>
}

export const CATEGORY_FILTERS: CategoryFilterItem[] = [
  { id: "todos", label: "Todos", icon: Layers },
  { id: "geral", label: "Avisos Gerais", icon: Bell },
  { id: "encontro", label: "Encontros na Cidade", icon: MapPin },
  { id: "evento", label: "Eventos & Retiros", icon: CalendarDays },
  { id: "estudo", label: "Estudos & Ensinos", icon: BookOpen },
  { id: "oracao", label: "Orações", icon: HeartHandshake },
  { id: "missoes", label: "Missões", icon: Globe },
  { id: "formulario", label: "Formulários", icon: ClipboardList },
]

interface NewsCategoryFiltersProps {
  activeCategory: PostCategory | "todos"
  onSelectCategory: (category: PostCategory | "todos") => void
  className?: string
}

export function NewsCategoryFilters({
  activeCategory,
  onSelectCategory,
  className,
}: NewsCategoryFiltersProps) {
  return (
    <div
      className={cn(
        "flex w-full items-center gap-2 overflow-x-auto pb-2 scrollbar-none sm:flex-wrap sm:pb-0",
        className
      )}
      role="tablist"
      aria-label="Filtro de categorias de notícias"
    >
      {CATEGORY_FILTERS.map((cat) => {
        const Icon = cat.icon
        const isActive = activeCategory === cat.id

        return (
          <button
            key={cat.id}
            type="button"
            role="tab"
            aria-selected={isActive}
            onClick={() => onSelectCategory(cat.id)}
            className={cn(
              "flex min-h-[44px] shrink-0 items-center gap-2 rounded-full px-4 text-xs font-semibold transition-all select-none active:scale-95",
              isActive
                ? "bg-primary text-primary-foreground shadow-xs"
                : "border border-border/70 bg-card/60 text-muted-foreground hover:border-primary/40 hover:bg-muted/60 hover:text-foreground"
            )}
          >
            <Icon className={cn("h-4 w-4 shrink-0", isActive ? "text-primary-foreground" : "text-primary")} />
            <span>{cat.label}</span>
          </button>
        )
      })}
    </div>
  )
}
