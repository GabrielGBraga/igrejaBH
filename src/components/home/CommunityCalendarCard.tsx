import { useState, useMemo } from "react"
import { Calendar as CalendarIcon, Clock, Sparkles, ChevronRight, Info, CalendarDays, ListFilter } from "lucide-react"
import { Card, CardContent, CardHeader, CardTitle, CardDescription, CardFooter } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { Calendar } from "@/components/ui/calendar"
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog"
import { format, parseISO, isSameDay, isAfter, startOfDay } from "date-fns"
import { ptBR } from "date-fns/locale"
import type { Database } from "@/lib/database.types"

export type CommunityEvent = Database["public"]["Tables"]["posts"]["Row"]

interface CommunityCalendarCardProps {
  events: CommunityEvent[]
  loading?: boolean
}

export function CommunityCalendarCard({
  events,
  loading = false,
}: CommunityCalendarCardProps) {
  const [selectedDate, setSelectedDate] = useState<Date | undefined>(new Date())
  const [activeView, setActiveView] = useState<"agenda" | "calendario">("agenda")
  const [selectedEvent, setSelectedEvent] = useState<CommunityEvent | null>(null)

  // Filtra apenas eventos futuros ou de hoje
  const upcomingEvents = useMemo(() => {
    const today = startOfDay(new Date())
    return events
      .filter((e) => {
        if (!e.event_start_date) return false
        try {
          return isAfter(parseISO(e.event_start_date), today) || isSameDay(parseISO(e.event_start_date), today)
        } catch {
          return false
        }
      })
      .sort((a, b) => {
        if (!a.event_start_date || !b.event_start_date) return 0
        return new Date(a.event_start_date).getTime() - new Date(b.event_start_date).getTime()
      })
  }, [events])

  // Próximo encontro mais imediato
  const nextEvent = upcomingEvents[0] || null

  // Datas que possuem eventos para marcar no calendário
  const eventDates = useMemo(() => {
    return upcomingEvents
      .map((e) => {
        try {
          return parseISO(e.event_start_date!)
        } catch {
          return null
        }
      })
      .filter((d): d is Date => d !== null)
  }, [upcomingEvents])

  // Eventos do dia selecionado no calendário
  const eventsOnSelectedDate = useMemo(() => {
    if (!selectedDate) return []
    return upcomingEvents.filter((e) => {
      try {
        return isSameDay(parseISO(e.event_start_date!), selectedDate)
      } catch {
        return false
      }
    })
  }, [upcomingEvents, selectedDate])

  const formatEventDate = (startDate?: string | null, endDate?: string | null) => {
    if (!startDate) return "Data a confirmar"
    try {
      const s = parseISO(startDate)
      const dayWeek = format(s, "EEEE, dd/MM", { locale: ptBR })
      const time = format(s, "HH:mm'h'")

      if (!endDate) return `${dayWeek} às ${time}`

      const e = parseISO(endDate)
      if (format(s, "dd/MM") === format(e, "dd/MM")) {
        return `${dayWeek} das ${time} às ${format(e, "HH:mm'h'")}`
      }
      return `${format(s, "dd/MM")} a ${format(e, "dd/MM/yyyy")}`
    } catch {
      return startDate
    }
  }

  if (loading) {
    return (
      <Card className="rounded-xl border-border bg-card/60 shadow-xs">
        <CardHeader className="space-y-2 pb-3">
          <div className="h-5 w-40 animate-pulse rounded bg-muted" />
          <div className="h-4 w-52 animate-pulse rounded bg-muted" />
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="h-20 w-full animate-pulse rounded-lg bg-muted" />
          <div className="h-12 w-full animate-pulse rounded-lg bg-muted" />
        </CardContent>
      </Card>
    )
  }

  return (
    <>
      <Card className="flex flex-col justify-between rounded-xl border-border/80 bg-card/70 shadow-xs backdrop-blur-xs transition-colors hover:border-primary/30">
        <CardHeader className="space-y-2 pb-3">
          <div className="flex items-start justify-between gap-2">
            <div className="space-y-1">
              <CardTitle className="flex items-center gap-2 text-base font-bold sm:text-lg">
                <CalendarIcon className="h-5 w-5 text-primary shrink-0" />
                <span>Encontros da Cidade</span>
              </CardTitle>
              <CardDescription className="text-xs font-medium text-primary">
                Reuniões casuais e vida comum nos lares e na cidade
              </CardDescription>
            </div>

            <Badge
              variant="outline"
              className="shrink-0 gap-1 rounded-full border-primary/30 bg-primary/10 px-2.5 py-1 text-[11px] font-semibold text-primary"
            >
              <Sparkles className="h-3 w-3 text-amber-600 dark:text-amber-400" />
              Livre & Aberto
            </Badge>
          </div>

          {/* Alternador de Visualização: Agenda vs Calendário */}
          <div className="flex items-center gap-1 rounded-lg border border-border/50 bg-background/50 p-1">
            <button
              type="button"
              onClick={() => setActiveView("agenda")}
              className={`flex min-h-[36px] flex-1 items-center justify-center gap-1.5 rounded-md px-3 text-xs font-semibold transition-all ${
                activeView === "agenda"
                  ? "bg-primary text-primary-foreground shadow-2xs"
                  : "text-muted-foreground hover:text-foreground"
              }`}
            >
              <ListFilter className="h-3.5 w-3.5" />
              Próximos Encontros
            </button>
            <button
              type="button"
              onClick={() => setActiveView("calendario")}
              className={`flex min-h-[36px] flex-1 items-center justify-center gap-1.5 rounded-md px-3 text-xs font-semibold transition-all ${
                activeView === "calendario"
                  ? "bg-primary text-primary-foreground shadow-2xs"
                  : "text-muted-foreground hover:text-foreground"
              }`}
            >
              <CalendarDays className="h-3.5 w-3.5" />
              Ver no Calendário
            </button>
          </div>
        </CardHeader>

        <CardContent className="space-y-3 py-1">
          {activeView === "agenda" ? (
            /* VISUALIZAÇÃO DE AGENDA */
            upcomingEvents.length === 0 ? (
              <div className="rounded-lg border border-border/60 bg-muted/30 p-4 text-center text-xs text-muted-foreground">
                <p>Nenhum encontro geral programado para os próximos dias.</p>
                <p className="mt-1 text-[11px] text-foreground font-medium">
                  A vida do Corpo continua normalmente nos lares através dos Grupos Caseiros!
                </p>
              </div>
            ) : (
              <div className="space-y-3">
                {/* 1. Destaque do Próximo Encontro */}
                {nextEvent && (
                  <div
                    onClick={() => setSelectedEvent(nextEvent)}
                    className="cursor-pointer rounded-xl border border-primary/25 bg-primary/5 p-3 transition-colors hover:border-primary/50 hover:bg-primary/10"
                    role="button"
                    tabIndex={0}
                    aria-label={`Ver detalhes de ${nextEvent.title}`}
                  >
                    <div className="flex items-center justify-between gap-2">
                      <span className="text-[10px] font-bold uppercase tracking-wider text-primary">
                        Próxima Reunião
                      </span>
                      <span className="text-[11px] font-medium text-emerald-600 dark:text-emerald-400">
                        Sem inscrição • Basta chegar
                      </span>
                    </div>

                    <h4 className="mt-1 text-sm font-bold text-foreground leading-snug">
                      {nextEvent.title}
                    </h4>

                    <div className="mt-2 space-y-1 text-xs text-muted-foreground">
                      <div className="flex items-center gap-2">
                        <Clock className="h-3.5 w-3.5 text-primary shrink-0" />
                        <span className="font-semibold text-foreground">
                          {formatEventDate(nextEvent.event_start_date, nextEvent.event_end_date)}
                        </span>
                      </div>
                      <p className="line-clamp-2 text-[11px] text-muted-foreground pt-0.5">
                        {nextEvent.content}
                      </p>
                    </div>
                  </div>
                )}

                {/* 2. Demais Encontros Programados */}
                {upcomingEvents.length > 1 && (
                  <div className="space-y-1.5 pt-1">
                    <span className="text-[11px] font-semibold uppercase tracking-wide text-muted-foreground block">
                      Outros Encontros Agendados
                    </span>
                    <div className="space-y-1.5">
                      {upcomingEvents.slice(1, 3).map((event) => (
                        <div
                          key={event.id}
                          onClick={() => setSelectedEvent(event)}
                          className="flex cursor-pointer items-center justify-between rounded-lg border border-border/50 bg-background/50 p-2.5 transition-colors hover:bg-muted/40"
                          role="button"
                          tabIndex={0}
                        >
                          <div className="min-w-0 pr-2">
                            <p className="text-xs font-semibold text-foreground truncate">
                              {event.title}
                            </p>
                            <p className="text-[11px] text-muted-foreground">
                              {formatEventDate(event.event_start_date, event.event_end_date)}
                            </p>
                          </div>
                          <ChevronRight className="h-4 w-4 text-muted-foreground shrink-0" />
                        </div>
                      ))}
                    </div>
                  </div>
                )}
              </div>
            )
          ) : (
            /* VISUALIZAÇÃO EM CALENDÁRIO */
            <div className="space-y-3">
              <div className="flex justify-center rounded-lg border border-border/50 bg-background/40 p-2">
                <Calendar
                  mode="single"
                  selected={selectedDate}
                  onSelect={setSelectedDate}
                  locale={ptBR}
                  modifiers={{
                    hasEvent: eventDates,
                  }}
                  modifiersClassNames={{
                    hasEvent:
                      "font-extrabold text-primary underline decoration-primary decoration-2 underline-offset-4",
                  }}
                  className="rounded-md border-0 p-1"
                />
              </div>

              {/* Lista dos eventos na data selecionada */}
              {selectedDate && (
                <div className="rounded-lg border border-border/60 bg-background/60 p-2.5">
                  <span className="text-[11px] font-semibold text-muted-foreground block mb-1">
                    Encontros em {format(selectedDate, "dd 'de' MMMM", { locale: ptBR })}:
                  </span>
                  {eventsOnSelectedDate.length === 0 ? (
                    <p className="text-xs text-muted-foreground italic">
                      Nenhum encontro geral neste dia. Reuniões de oração e comunhão ocorrem nos lares.
                    </p>
                  ) : (
                    <div className="space-y-1.5">
                      {eventsOnSelectedDate.map((ev) => (
                        <div
                          key={ev.id}
                          onClick={() => setSelectedEvent(ev)}
                          className="flex cursor-pointer items-center justify-between rounded border border-border/40 p-1.5 hover:bg-muted/30"
                          role="button"
                          tabIndex={0}
                        >
                          <span className="text-xs font-semibold text-foreground truncate">
                            {ev.title}
                          </span>
                          <ChevronRight className="h-3.5 w-3.5 text-muted-foreground shrink-0" />
                        </div>
                      ))}
                    </div>
                  )}
                </div>
              )}
            </div>
          )}
        </CardContent>

        <CardFooter className="pt-2">
          <div className="flex w-full items-center justify-between text-[11px] text-muted-foreground">
            <span className="flex items-center gap-1">
              <Info className="h-3.5 w-3.5 text-primary" />
              Partilhar o pão e orar de casa em casa
            </span>
            <a href="#mural" className="font-medium text-primary hover:underline">
              Ver avisos
            </a>
          </div>
        </CardFooter>
      </Card>

      {/* Modal de Detalhes do Encontro */}
      <Dialog open={!!selectedEvent} onOpenChange={(open) => !open && setSelectedEvent(null)}>
        {selectedEvent && (
          <DialogContent className="max-w-md p-6">
            <DialogHeader className="text-left space-y-1.5">
              <div className="inline-flex items-center gap-1.5 text-xs font-semibold text-primary">
                <Sparkles className="h-3.5 w-3.5 text-amber-600 dark:text-amber-400" />
                Encontro da Igreja na Cidade
              </div>
              <DialogTitle className="text-lg font-bold leading-tight">
                {selectedEvent.title}
              </DialogTitle>
              <DialogDescription className="text-xs text-muted-foreground">
                Comunhão fraterna aberta • Não requer inscrição nem pagamento
              </DialogDescription>
            </DialogHeader>

            <div className="space-y-3.5 pt-2">
              <div className="rounded-lg border border-border/60 bg-muted/30 p-3 space-y-2 text-xs">
                <div className="flex items-center gap-2 text-foreground font-semibold">
                  <Clock className="h-4 w-4 text-primary shrink-0" />
                  <span>
                    {formatEventDate(selectedEvent.event_start_date, selectedEvent.event_end_date)}
                  </span>
                </div>
              </div>

              <div className="text-xs leading-relaxed text-foreground whitespace-pre-wrap">
                {selectedEvent.content}
              </div>

              {selectedEvent.image_urls && selectedEvent.image_urls.length > 0 && (
                <div className="overflow-hidden rounded-lg border border-border">
                  <img
                    src={selectedEvent.image_urls[0]}
                    alt={selectedEvent.title}
                    className="h-44 w-full object-cover"
                  />
                </div>
              )}
            </div>
          </DialogContent>
        )}
      </Dialog>
    </>
  )
}
