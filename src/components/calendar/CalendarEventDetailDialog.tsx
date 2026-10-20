import { Link } from "react-router-dom"
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogDescription,
  DialogFooter,
} from "@/components/ui/dialog"
import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import { Calendar, Clock, MapPin, ArrowRight, ExternalLink } from "lucide-react"
import { type CalendarEventItem, formatEventSchedule } from "@/hooks/useChurchCalendar"

interface CalendarEventDetailDialogProps {
  event: CalendarEventItem | null
  open: boolean
  onOpenChange: (open: boolean) => void
}

export function CalendarEventDetailDialog({
  event,
  open,
  onOpenChange,
}: CalendarEventDetailDialogProps) {
  if (!event) return null

  const scheduleText = formatEventSchedule(event.startDateStr, event.endDateStr)
  const isRetreat = event.type === "retiro"

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="max-h-[90vh] w-[95vw] sm:max-w-lg bg-card border-border/70 shadow-2xl rounded-3xl p-0 overflow-hidden flex flex-col">
        <DialogHeader className="p-5 sm:p-6 pb-4 border-b border-border/50 shrink-0">
          <div className="flex items-center gap-2 mb-2 flex-wrap">
            <Badge
              variant="outline"
              className={`text-xs px-2.5 py-0.5 rounded-full font-semibold ${
                isRetreat
                  ? "border-emerald-500/30 bg-emerald-500/10 text-emerald-700 dark:text-emerald-300"
                  : "border-primary/30 bg-primary/10 text-primary"
              }`}
            >
              {isRetreat ? "Retiro Comunitário" : "Encontro na Cidade"}
            </Badge>

            {event.isHighlight && (
              <Badge
                variant="outline"
                className="text-[10px] px-2 py-0.5 rounded-full font-bold border-amber-500/40 bg-amber-500/10 text-amber-700 dark:text-amber-400"
              >
                Destaque
              </Badge>
            )}
          </div>

          <DialogTitle className="text-lg sm:text-xl font-extrabold text-foreground leading-snug">
            {event.title}
          </DialogTitle>
          <DialogDescription className="text-xs text-muted-foreground mt-1 flex items-center gap-1.5">
            <Calendar className="h-3.5 w-3.5 text-primary" />
            <span>{scheduleText}</span>
          </DialogDescription>
        </DialogHeader>

        <div className="flex-1 overflow-y-auto p-5 sm:p-6 space-y-4">
          {/* Card de Data e Local */}
          <div className="rounded-2xl border border-border/60 bg-muted/20 p-4 space-y-3">
            <div className="flex items-start gap-2.5">
              <Clock className="h-4 w-4 text-primary shrink-0 mt-0.5" />
              <div className="text-xs">
                <span className="font-semibold text-foreground block">Data e Horário</span>
                <span className="text-muted-foreground">{scheduleText}</span>
              </div>
            </div>

            {event.location && (
              <div className="flex items-start gap-2.5 pt-2 border-t border-border/40">
                <MapPin className="h-4 w-4 text-primary shrink-0 mt-0.5" />
                <div className="text-xs flex-1">
                  <span className="font-semibold text-foreground block">Local do Encontro</span>
                  <span className="text-muted-foreground">{event.location}</span>
                </div>
                <a
                  href={`https://www.google.com/maps/search/?api=1&query=${encodeURIComponent(event.location)}`}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="text-primary hover:text-primary/80 transition-colors p-1"
                  title="Abrir no Google Maps"
                >
                  <ExternalLink className="h-4 w-4" />
                </a>
              </div>
            )}
          </div>

          {/* Descrição / Conteúdo do Encontro */}
          {event.description && (
            <div className="space-y-1.5">
              <h5 className="text-xs font-bold uppercase tracking-wider text-muted-foreground">
                Sobre este momento
              </h5>
              <p className="text-xs sm:text-sm text-foreground/90 whitespace-pre-line leading-relaxed">
                {event.description}
              </p>
            </div>
          )}

          {/* Dica orgânica / Vida Comum */}
          <div className="rounded-xl border border-primary/20 bg-primary/5 p-3 text-[11px] text-muted-foreground">
            {isRetreat ? (
              <p>
                Os retiros são tempos intensos de edificação e convívio mútuo. As vagas são limitadas aos leitos disponíveis.
              </p>
            ) : (
              <p>
                Reunião aberta da igreja na cidade. Sem necessidade de inscrição prévia — basta chegar com sua família ou Grupo Caseiro.
              </p>
            )}
          </div>
        </div>

        <DialogFooter className="p-4 sm:p-5 border-t border-border/50 shrink-0 flex flex-col-reverse sm:flex-row items-stretch sm:items-center justify-between gap-2.5">
          <Button
            type="button"
            variant="ghost"
            onClick={() => onOpenChange(false)}
            className="min-h-[44px] rounded-xl px-4 text-xs font-semibold cursor-pointer"
          >
            Fechar
          </Button>

          {isRetreat ? (
            <Button
              asChild
              className="min-h-[44px] rounded-xl px-5 bg-primary text-primary-foreground hover:bg-primary/90 text-xs sm:text-sm font-semibold cursor-pointer"
            >
              <Link to="/eventos" onClick={() => onOpenChange(false)}>
                Ver Detalhes do Retiro
                <ArrowRight className="ml-1.5 h-4 w-4" />
              </Link>
            </Button>
          ) : (
            <Button
              asChild
              variant="outline"
              className="min-h-[44px] rounded-xl px-5 border-border text-xs sm:text-sm font-semibold cursor-pointer"
            >
              <Link to="/quero-saber-mais" onClick={() => onOpenChange(false)}>
                Quero Participar
                <ArrowRight className="ml-1.5 h-4 w-4" />
              </Link>
            </Button>
          )}
        </DialogFooter>
      </DialogContent>
    </Dialog>
  )
}
