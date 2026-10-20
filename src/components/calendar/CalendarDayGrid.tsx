import { ChevronLeft, ChevronRight } from "lucide-react"
import { Button } from "@/components/ui/button"
import type { CalendarEventItem } from "@/hooks/useChurchCalendar"

const MONTH_NAMES = [
  "JANEIRO",
  "FEVEREIRO",
  "MARÇO",
  "ABRIL",
  "MAIO",
  "JUNHO",
  "JULHO",
  "AGOSTO",
  "SETEMBRO",
  "OUTUBRO",
  "NOVEMBRO",
  "DEZEMBRO",
]

export interface CalendarDayGridProps {
  currentMonth: number // 1-12
  currentYear: number
  daysInMonth: number
  firstDayOfWeek: number
  selectedDay: number | null
  eventDaysMap: Map<number, CalendarEventItem[]>
  onSelectDay: (day: number | null) => void
  onPrevMonth: () => void
  onNextMonth: () => void
  className?: string
}

export function CalendarDayGrid({
  currentMonth,
  currentYear,
  daysInMonth,
  firstDayOfWeek,
  selectedDay,
  eventDaysMap,
  onSelectDay,
  onPrevMonth,
  onNextMonth,
  className = "",
}: CalendarDayGridProps) {
  return (
    <div className={`space-y-3 ${className}`}>
      {/* Month Header & Controls */}
      <div className="flex items-center justify-between mb-3">
        <span className="text-xs sm:text-sm font-extrabold tracking-wider text-foreground uppercase">
          {MONTH_NAMES[currentMonth - 1]} {currentYear}
        </span>
        <div className="flex items-center gap-1">
          <Button
            type="button"
            variant="ghost"
            size="icon"
            onClick={onPrevMonth}
            className="h-8 w-8 rounded-full"
            aria-label="Mês anterior"
          >
            <ChevronLeft className="h-4 w-4" />
          </Button>
          <Button
            type="button"
            variant="ghost"
            size="icon"
            onClick={onNextMonth}
            className="h-8 w-8 rounded-full"
            aria-label="Próximo mês"
          >
            <ChevronRight className="h-4 w-4" />
          </Button>
        </div>
      </div>

      {/* Days of Week Header */}
      <div className="grid grid-cols-7 gap-1 text-center mb-1.5">
        {["D", "S", "T", "Q", "Q", "S", "S"].map((col, idx) => (
          <span
            key={`${col}-${idx}`}
            className="text-[10px] font-bold text-muted-foreground uppercase"
          >
            {col}
          </span>
        ))}
      </div>

      {/* Calendar Days Matrix */}
      <div className="grid grid-cols-7 gap-1 text-center">
        {/* Empty slots for month start offset */}
        {Array.from({ length: firstDayOfWeek }).map((_, idx) => (
          <div key={`empty-${idx}`} className="h-8 sm:h-9 w-full" />
        ))}

        {/* Real Days */}
        {Array.from({ length: daysInMonth }).map((_, idx) => {
          const dayNumber = idx + 1
          const hasEvents = eventDaysMap.has(dayNumber)
          const isSelected = selectedDay === dayNumber

          return (
            <button
              key={`day-${dayNumber}`}
              type="button"
              onClick={() => onSelectDay(selectedDay === dayNumber ? null : dayNumber)}
              className={`relative flex h-8 sm:h-9 w-full items-center justify-center rounded-lg text-xs font-medium transition-all cursor-pointer ${
                isSelected
                  ? "bg-primary text-primary-foreground font-bold shadow-xs scale-105"
                  : hasEvents
                  ? "bg-primary/10 text-primary font-bold hover:bg-primary/20 ring-1 ring-primary/30"
                  : "text-muted-foreground hover:bg-muted/50 hover:text-foreground"
              }`}
              aria-label={`Dia ${dayNumber}${hasEvents ? " com evento" : ""}`}
            >
              <span>{dayNumber}</span>
              {hasEvents && !isSelected && (
                <span className="absolute bottom-1 h-1 w-1 rounded-full bg-amber-600 dark:bg-amber-400" />
              )}
            </button>
          )
        })}
      </div>

      {/* Selection Filter Indicator */}
      {selectedDay && (
        <div className="mt-2.5 flex items-center justify-between text-xs text-muted-foreground bg-muted/40 px-3 py-1.5 rounded-lg">
          <span>Filtrando dia {selectedDay}</span>
          <button
            type="button"
            onClick={() => onSelectDay(null)}
            className="text-primary hover:underline font-semibold cursor-pointer"
          >
            Ver todos
          </button>
        </div>
      )}
    </div>
  )
}
