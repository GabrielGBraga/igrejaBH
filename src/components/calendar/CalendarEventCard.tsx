import React from "react"
import { MapPin, ArrowRight } from "lucide-react"
import { Badge } from "@/components/ui/badge"
import { Link } from "react-router-dom"
import type { CalendarEventItem } from "@/hooks/useChurchCalendar"

export interface CalendarEventCardProps {
  event: CalendarEventItem
  onSelectEvent?: (event: CalendarEventItem) => void
  showTypeBadge?: boolean
  className?: string
}

export function CalendarEventCard({
  event,
  onSelectEvent,
  showTypeBadge = true,
  className = "",
}: CalendarEventCardProps) {
  const dateString = event.dayEnd
    ? `Dias ${event.day} a ${event.dayEnd}`
    : `Dia ${event.day}`

  const handleClick = (e: React.MouseEvent) => {
    if (onSelectEvent) {
      e.preventDefault()
      onSelectEvent(event)
    }
  }

  const cardContent = (
    <div
      onClick={onSelectEvent ? handleClick : undefined}
      className={`flex items-start gap-3 rounded-xl border border-border/50 bg-background/60 p-3.5 transition-all hover:border-primary/50 hover:bg-background hover:shadow-xs group cursor-pointer ${className}`}
      role="button"
      tabIndex={0}
      aria-label={`Ver detalhes de ${event.title}`}
    >
      {/* Square Date Badge */}
      <div className="flex h-10 w-10 shrink-0 flex-col items-center justify-center rounded-lg bg-primary/10 text-primary font-bold group-hover:bg-primary group-hover:text-primary-foreground transition-colors">
        <span className="text-xs uppercase leading-none font-bold">
          {event.dayEnd ? `${event.day}-${event.dayEnd}` : event.day}
        </span>
      </div>

      {/* Main Details */}
      <div className="flex-1 min-w-0">
        <div className="flex items-center gap-2 flex-wrap">
          <span className="text-xs font-semibold text-amber-600 dark:text-amber-400">
            {dateString}:
          </span>
          <h4 className="text-xs sm:text-sm font-bold text-foreground truncate group-hover:text-primary transition-colors">
            {event.title}
          </h4>
          {showTypeBadge && (
            <Badge
              variant="outline"
              className={`text-[10px] px-1.5 py-0 rounded-md font-semibold ${
                event.type === "retiro"
                  ? "border-emerald-500/30 bg-emerald-500/10 text-emerald-700 dark:text-emerald-300"
                  : "border-primary/30 bg-primary/10 text-primary"
              }`}
            >
              {event.type === "retiro" ? "Retiro" : "Encontro na Cidade"}
            </Badge>
          )}
        </div>

        {event.location && (
          <p className="mt-1 text-[11px] text-muted-foreground flex items-center gap-1 truncate">
            <MapPin className="h-3 w-3 shrink-0 text-muted-foreground" />
            <span className="truncate">{event.location}</span>
          </p>
        )}
      </div>

      <ArrowRight className="h-4 w-4 text-muted-foreground/50 self-center shrink-0 group-hover:text-primary group-hover:translate-x-0.5 transition-all" />
    </div>
  )

  if (onSelectEvent) {
    return cardContent
  }

  return (
    <Link to="/#contato">
      {cardContent}
    </Link>
  )
}
