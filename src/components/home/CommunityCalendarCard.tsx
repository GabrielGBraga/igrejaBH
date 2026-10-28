import { useState } from "react"
import { Calendar as CalendarIcon, Sparkles, CalendarDays, ListFilter, ArrowRight } from "lucide-react"
import { Card, CardContent, CardHeader, CardTitle, CardDescription, CardFooter } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { Link } from "react-router-dom"
import { useChurchCalendar, type CalendarEventItem } from "@/hooks/useChurchCalendar"
import { CalendarEventCard } from "@/components/calendar/CalendarEventCard"
import { CalendarDayGrid } from "@/components/calendar/CalendarDayGrid"
import { CalendarEventDetailDialog } from "@/components/calendar/CalendarEventDetailDialog"
import type { Database } from "@/lib/database.types"

export type CommunityEvent = Database["public"]["Tables"]["posts"]["Row"]

interface CommunityCalendarCardProps {
  events?: CommunityEvent[]
  loading?: boolean
  isChurchLinked?: boolean
}

export function CommunityCalendarCard({
  loading: parentLoading = false,
  isChurchLinked = true,
}: CommunityCalendarCardProps) {
  const [activeView, setActiveView] = useState<"agenda" | "calendario">("agenda")
  const [detailEvent, setDetailEvent] = useState<CalendarEventItem | null>(null)
  const [isDetailOpen, setIsDetailOpen] = useState(false)

  // Utiliza o hook centralizado e seguro de calendário
  const {
    filteredEvents,
    upcomingEvents,
    eventDaysMap,
    currentMonth,
    currentYear,
    daysInMonth,
    firstDayOfWeek,
    selectedDay,
    setSelectedDay,
    handlePrevMonth,
    handleNextMonth,
    loading: hookLoading,
  } = useChurchCalendar({
    publicOnly: !isChurchLinked,
    initialMonth: 10,
    initialYear: 2026,
  })

  const loading = parentLoading || hookLoading

  const handleOpenDetail = (event: CalendarEventItem) => {
    setDetailEvent(event)
    setIsDetailOpen(true)
  }

  if (loading) {
    return (
      <Card className="rounded-2xl border-border bg-card/60 shadow-xs">
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
      <Card className="rounded-xl border-border/80 bg-card/70 shadow-xs backdrop-blur-xs transition-colors hover:border-primary/30 overflow-hidden">
        <CardHeader className="space-y-2.5 pb-3">
          <div className="flex items-start justify-between gap-2">
            <div className="space-y-1">
              <CardTitle className="flex items-center gap-2 text-base font-bold sm:text-lg">
                <CalendarIcon className="h-5 w-5 text-primary shrink-0" />
                <span>Agenda & Calendário</span>
              </CardTitle>
              <CardDescription className="text-xs font-medium text-muted-foreground">
                Reuniões nos lares, encontros na cidade e retiros comunitários
              </CardDescription>
            </div>

            <Badge
              variant="outline"
              className="shrink-0 gap-1 rounded-full border-primary/30 bg-primary/10 px-2.5 py-1 text-[11px] font-semibold text-primary"
            >
              <CalendarDays className="h-3 w-3 text-primary" />
              Programação
            </Badge>
          </div>

          {/* Alternador de Visualização: Agenda vs Calendário */}
          <div className="flex items-center gap-1 rounded-xl border border-border/50 bg-background/50 p-1">
            <button
              type="button"
              onClick={() => setActiveView("agenda")}
              className={`flex min-h-[38px] flex-1 items-center justify-center gap-1.5 rounded-lg px-3 text-xs font-semibold transition-all cursor-pointer ${
                activeView === "agenda"
                  ? "bg-primary text-primary-foreground shadow-2xs font-bold"
                  : "text-muted-foreground hover:text-foreground"
              }`}
            >
              <ListFilter className="h-3.5 w-3.5" />
              Próximos Encontros
            </button>
            <button
              type="button"
              onClick={() => setActiveView("calendario")}
              className={`flex min-h-[38px] flex-1 items-center justify-center gap-1.5 rounded-lg px-3 text-xs font-semibold transition-all cursor-pointer ${
                activeView === "calendario"
                  ? "bg-primary text-primary-foreground shadow-2xs font-bold"
                  : "text-muted-foreground hover:text-foreground"
              }`}
            >
              <CalendarDays className="h-3.5 w-3.5" />
              Ver no Calendário
            </button>
          </div>
        </CardHeader>

        <CardContent className="space-y-3 py-1 flex-1">
          {activeView === "agenda" ? (
            /* VISUALIZAÇÃO DE AGENDA (LISTA COM MESMO DESIGN DA LANDING PAGE) */
            upcomingEvents.length === 0 ? (
              <div className="rounded-xl border border-dashed border-border/60 bg-muted/20 p-5 text-center text-xs text-muted-foreground">
                <p className="font-semibold text-foreground">Nenhum encontro geral nos próximos dias.</p>
                <p className="mt-1 text-[11px]">
                  A vida do Corpo continua normalmente nos lares através dos Grupos Caseiros!
                </p>
              </div>
            ) : (
              <div className="space-y-2.5">
                {upcomingEvents.slice(0, 3).map((event) => (
                  <CalendarEventCard
                    key={event.id}
                    event={event}
                    onSelectEvent={handleOpenDetail}
                  />
                ))}
              </div>
            )
          ) : (
            /* VISUALIZAÇÃO INTERATIVA EM CALENDÁRIO (EXATAMENTE IGUAL À LANDING PAGE) */
            <div className="space-y-3.5">
              <div className="rounded-xl border border-border/60 bg-background/50 p-3 sm:p-4">
                <CalendarDayGrid
                  currentMonth={currentMonth}
                  currentYear={currentYear}
                  daysInMonth={daysInMonth}
                  firstDayOfWeek={firstDayOfWeek}
                  selectedDay={selectedDay}
                  eventDaysMap={eventDaysMap}
                  onSelectDay={setSelectedDay}
                  onPrevMonth={handlePrevMonth}
                  onNextMonth={handleNextMonth}
                />
              </div>

              {/* Eventos da Data Selecionada ou do Mês */}
              <div className="space-y-2">
                <span className="text-[11px] font-bold uppercase tracking-wider text-muted-foreground block px-1">
                  {selectedDay
                    ? `Programação do Dia ${selectedDay}`
                    : `Programação de ${currentMonth}/${currentYear}`}
                </span>

                {filteredEvents.length === 0 ? (
                  <div className="rounded-xl border border-dashed border-border/60 p-4 text-center text-xs text-muted-foreground">
                    Nenhum encontro geral neste dia. Reuniões de oração e comunhão ocorrem nos lares.
                  </div>
                ) : (
                  <div className="space-y-2">
                    {filteredEvents.map((event) => (
                      <CalendarEventCard
                        key={event.id}
                        event={event}
                        onSelectEvent={handleOpenDetail}
                      />
                    ))}
                  </div>
                )}
              </div>
            </div>
          )}
        </CardContent>

        <CardFooter className="pt-3 border-t border-border/40 mt-3 flex items-center justify-between text-[11px] text-muted-foreground">
          <span className="font-bold tracking-wider uppercase text-[10px]">
            + IGREJA EM BH • PROGRAMAÇÃO
          </span>

          <Link
            to="/eventos"
            className="flex items-center gap-1 font-semibold text-primary hover:underline cursor-pointer"
          >
            <span>Ver eventos & retiros</span>
            <ArrowRight className="h-3.5 w-3.5" />
          </Link>
        </CardFooter>
      </Card>

      {/* Modal de Detalhes do Evento / Encontro */}
      <CalendarEventDetailDialog
        event={detailEvent}
        open={isDetailOpen}
        onOpenChange={setIsDetailOpen}
      />
    </>
  )
}
