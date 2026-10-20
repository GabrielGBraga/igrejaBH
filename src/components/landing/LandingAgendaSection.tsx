import { useState } from "react"
import { Link } from "react-router-dom"
import {
  Calendar as CalendarIcon,
  ArrowRight,
  HeartHandshake,
} from "lucide-react"
import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import { ChurchLogo } from "@/components/icons/ChurchLogo"
import { useChurchCalendar, type CalendarEventItem } from "@/hooks/useChurchCalendar"
import { CalendarDayGrid } from "@/components/calendar/CalendarDayGrid"
import { CalendarEventCard } from "@/components/calendar/CalendarEventCard"
import { CalendarEventDetailDialog } from "@/components/calendar/CalendarEventDetailDialog"

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

interface LandingAgendaSectionProps {
  onOpenWelcomeDialog?: () => void
}

export function LandingAgendaSection({ onOpenWelcomeDialog }: LandingAgendaSectionProps) {
  const [detailEvent, setDetailEvent] = useState<CalendarEventItem | null>(null)
  const [isDetailOpen, setIsDetailOpen] = useState(false)

  // Hook centralizado com sincronia de dados e timezone-safe
  const {
    filteredEvents,
    eventDaysMap,
    currentMonth,
    currentYear,
    daysInMonth,
    firstDayOfWeek,
    selectedDay,
    setSelectedDay,
    handlePrevMonth,
    handleNextMonth,
  } = useChurchCalendar({
    publicOnly: true,
    initialMonth: 10,
    initialYear: 2026,
  })

  const handleOpenDetail = (event: CalendarEventItem) => {
    setDetailEvent(event)
    setIsDetailOpen(true)
  }

  return (
    <section id="agenda" className="scroll-mt-20 py-16 sm:py-20 border-b border-border/40 bg-muted/15">
      <div className="mx-auto max-w-5xl px-4 sm:px-6 lg:px-8">
        {/* Section Title */}
        <div className="text-center mb-10 sm:mb-12">
          <h2 className="text-2xl sm:text-3xl md:text-4xl font-extrabold tracking-tight text-foreground">
            Agenda
          </h2>
          <p className="mt-2 text-xs sm:text-sm text-muted-foreground">
            Fique atento às datas dos nossos próximos eventos e encontros!
          </p>
        </div>

        {/* The Stylized Calendar Card (Exact match to design mockup) */}
        <div className="relative overflow-hidden rounded-3xl border border-border/70 bg-card shadow-sm">
          {/* Card Top Bar with Logo & Action */}
          <div className="flex flex-wrap items-center justify-between gap-3 border-b border-border/40 px-5 sm:px-8 py-4 bg-muted/20">
            <ChurchLogo size="sm" />
            <div className="flex items-center gap-2">
              <Badge
                variant="outline"
                className="gap-1 border-primary/30 bg-primary/5 text-primary text-[11px] font-semibold px-2.5 py-1"
              >
                <CalendarIcon className="h-3 w-3" />
                Ver Programação
              </Badge>
            </div>
          </div>

          {/* Calendar Body: 2 Columns on Desktop */}
          <div className="grid grid-cols-1 md:grid-cols-12 gap-6 p-5 sm:p-8">
            {/* Left Column: Mini Calendar Grid */}
            <div className="md:col-span-6 border-b md:border-b-0 md:border-r border-border/40 pb-6 md:pb-0 md:pr-6">
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

            {/* Right Column: Event List */}
            <div className="md:col-span-6 flex flex-col justify-between space-y-4">
              <div className="space-y-3">
                <span className="text-xs font-bold uppercase tracking-wider text-muted-foreground">
                  {selectedDay
                    ? `Programação do Dia ${selectedDay}`
                    : `Programação de ${MONTH_NAMES[currentMonth - 1]}`}
                </span>

                {filteredEvents.length === 0 ? (
                  <div className="rounded-xl border border-dashed border-border/60 p-6 text-center text-xs text-muted-foreground">
                    Nenhum evento agendado para este dia.
                  </div>
                ) : (
                  <div className="space-y-2.5">
                    {filteredEvents.map((evt) => (
                      <CalendarEventCard
                        key={evt.id}
                        event={evt}
                        onSelectEvent={handleOpenDetail}
                      />
                    ))}
                  </div>
                )}
              </div>

              {/* CTAs matching mockup */}
              <div className="pt-4 flex flex-col sm:flex-row gap-3 border-t border-border/40">
                <Button
                  asChild
                  className="min-h-[44px] flex-1 justify-center text-xs sm:text-sm font-semibold rounded-full bg-primary text-primary-foreground hover:bg-primary/90 cursor-pointer"
                >
                  <Link to="/eventos">
                    Acessar o Portal de Eventos
                    <ArrowRight className="ml-1.5 h-4 w-4" />
                  </Link>
                </Button>

                {onOpenWelcomeDialog ? (
                  <Button
                    type="button"
                    variant="outline"
                    onClick={onOpenWelcomeDialog}
                    className="min-h-[44px] flex-1 justify-center text-xs sm:text-sm font-semibold rounded-full border-border hover:bg-muted cursor-pointer"
                  >
                    <HeartHandshake className="mr-1.5 h-4 w-4 text-primary" />
                    Quero Conhecer um Grupo Caseiro
                  </Button>
                ) : (
                  <Button
                    asChild
                    variant="outline"
                    className="min-h-[44px] flex-1 justify-center text-xs sm:text-sm font-semibold rounded-full border-border hover:bg-muted cursor-pointer"
                  >
                    <Link to="/quero-saber-mais">
                      <HeartHandshake className="mr-1.5 h-4 w-4 text-primary" />
                      Quero Conhecer um Grupo Caseiro
                    </Link>
                  </Button>
                )}
              </div>
            </div>
          </div>

          {/* Footer Bar of the Agenda Card */}
          <div className="border-t border-border/40 bg-muted/20 px-5 sm:px-8 py-3 text-[11px] font-semibold text-muted-foreground uppercase tracking-widest flex items-center justify-between">
            <span>+ IGREJA EM BH</span>
            <span>PROGRAMAÇÃO</span>
            <span>{MONTH_NAMES[currentMonth - 1]} {currentYear}</span>
          </div>
        </div>
      </div>

      {/* Modal de Detalhes do Evento */}
      <CalendarEventDetailDialog
        event={detailEvent}
        open={isDetailOpen}
        onOpenChange={setIsDetailOpen}
      />
    </section>
  )
}
