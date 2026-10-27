import { useState } from "react"
import { ArrowRight } from "lucide-react"
import { Button } from "@/components/ui/button"
import { useChurchCalendar, type CalendarEventItem } from "@/hooks/useChurchCalendar"
import { CalendarDayGrid } from "@/components/calendar/CalendarDayGrid"
import { CalendarEventCard } from "@/components/calendar/CalendarEventCard"
import { CalendarEventDetailDialog } from "@/components/calendar/CalendarEventDetailDialog"

const MONTH_NAMES = [
  "Janeiro",
  "Fevereiro",
  "Março",
  "Abril",
  "Maio",
  "Junho",
  "Julho",
  "Agosto",
  "Setembro",
  "Outubro",
  "Novembro",
  "Dezembro",
]

export function LandingAgendaSection() {
  const [detailEvent, setDetailEvent] = useState<CalendarEventItem | null>(null)
  const [isDetailOpen, setIsDetailOpen] = useState(false)
  const now = new Date()

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
    initialMonth: now.getMonth() + 1,
    initialYear: now.getFullYear(),
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
            Acompanhe as datas dos próximos encontros na cidade e retiros comunitários.
          </p>
        </div>

        {/* Clean Calendar Card without poster chrome */}
        <div className="overflow-hidden rounded-2xl border border-border/70 bg-card shadow-xs">
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
                <h3 className="text-xs font-semibold uppercase tracking-wider text-muted-foreground">
                  {selectedDay
                    ? `Encontros do dia ${selectedDay} de ${MONTH_NAMES[currentMonth - 1]}`
                    : `Encontros em ${MONTH_NAMES[currentMonth - 1]}`}
                </h3>

                {filteredEvents.length === 0 ? (
                  <div className="rounded-xl border border-dashed border-border/60 p-6 text-center text-xs text-muted-foreground">
                    Nenhum encontro geral agendado para este período.
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

              {/* Clean House-Church Context & Action */}
              <div className="pt-4 border-t border-border/40 flex flex-col sm:flex-row sm:items-center justify-between gap-3">
                <p className="text-xs text-muted-foreground leading-relaxed">
                  Além dos encontros gerais, nos reunimos semanalmente nas casas pela cidade.
                </p>
                <Button
                  asChild
                  variant="outline"
                  size="sm"
                  className="min-h-[44px] shrink-0 rounded-full px-4 text-xs font-semibold"
                >
                  <a href="#contato">
                    Caminhe conosco
                    <ArrowRight className="ml-1.5 h-3.5 w-3.5" />
                  </a>
                </Button>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Modal de Detalhes do Evento */}
      <CalendarEventDetailDialog
        event={detailEvent}
        open={isDetailOpen}
        onOpenChange={setIsDetailOpen}
        isPublicView
      />
    </section>
  )
}
