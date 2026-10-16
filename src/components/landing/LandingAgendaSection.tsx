import { useState, useEffect } from "react"
import { Link } from "react-router-dom"
import {
  Calendar as CalendarIcon,
  ChevronLeft,
  ChevronRight,
  ArrowRight,
  HeartHandshake,
  MapPin,
} from "lucide-react"
import supabase from "@/lib/supabase"
import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import { ChurchLogo } from "@/components/icons/ChurchLogo"
import { DEFAULT_MONTHLY_EVENTS, type AgendaEvent } from "@/data/landingData"

interface LandingAgendaSectionProps {
  onOpenWelcomeDialog?: () => void
}

export function LandingAgendaSection({ onOpenWelcomeDialog }: LandingAgendaSectionProps) {
  const [currentDate, setCurrentDate] = useState(() => new Date(2026, 9, 1)) // Outubro 2026 por padrão (alinhado ao mockup)
  const [events, setEvents] = useState<AgendaEvent[]>(DEFAULT_MONTHLY_EVENTS)
  const [selectedDay, setSelectedDay] = useState<number | null>(null)

  const currentMonth = currentDate.getMonth() + 1 // 1-12
  const currentYear = currentDate.getFullYear()

  const monthNames = [
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

  // Carrega eventos/retiros ativos do Supabase
  useEffect(() => {
    async function fetchRetreats() {
      try {
        const { data } = await supabase
          .from("retreats")
          .select("id, title, start_date, end_date, location_text, status")
          .eq("status", "ativo")

        if (data && data.length > 0) {
          const mappedFromDb: AgendaEvent[] = data
            .filter((r) => r.start_date !== null)
            .map((r) => {
              const startDate = new Date(r.start_date!)
              const endDate = r.end_date ? new Date(r.end_date) : null
              return {
                id: r.id,
                day: startDate.getDate(),
                dayEnd: endDate ? endDate.getDate() : undefined,
                month: startDate.getMonth() + 1,
                year: startDate.getFullYear(),
                title: r.title,
                type: "retiro" as const,
                location: r.location_text || undefined,
                isHighlight: true,
              }
            })
            .filter((e) => e.month === currentMonth && e.year === currentYear)

          // Se encontrar eventos no banco para este mês, combina com a agenda
          if (mappedFromDb.length > 0) {
            setEvents((prev) => {
              const ids = new Set(mappedFromDb.map((m) => m.id))
              const remaining = prev.filter((p) => !ids.has(p.id))
              return [...remaining, ...mappedFromDb]
            })
          }
        }
      } catch (err) {
        console.warn("Erro ao carregar eventos da agenda:", err)
      }
    }

    fetchRetreats()
  }, [currentMonth, currentYear])

  // Navegação de mês
  const handlePrevMonth = () => {
    setCurrentDate((prev) => new Date(prev.getFullYear(), prev.getMonth() - 1, 1))
    setSelectedDay(null)
  }

  const handleNextMonth = () => {
    setCurrentDate((prev) => new Date(prev.getFullYear(), prev.getMonth() + 1, 1))
    setSelectedDay(null)
  }

  // Dias no mês e primeiro dia da semana
  const daysInMonth = new Date(currentYear, currentMonth, 0).getDate()
  const firstDayOfWeek = new Date(currentYear, currentMonth - 1, 1).getDay()

  // Mapeamento de dias que possuem eventos
  const eventDaysMap = new Map<number, AgendaEvent[]>()
  events
    .filter((e) => e.month === currentMonth && e.year === currentYear)
    .forEach((e) => {
      const start = e.day
      const end = e.dayEnd || e.day
      for (let d = start; d <= end; d++) {
        const list = eventDaysMap.get(d) || []
        list.push(e)
        eventDaysMap.set(d, list)
      }
    })

  // Eventos filtrados pelo dia selecionado ou todos do mês
  const filteredEvents = selectedDay
    ? events.filter(
        (e) =>
          e.month === currentMonth &&
          e.year === currentYear &&
          e.day <= selectedDay &&
          (e.dayEnd || e.day) >= selectedDay
      )
    : events.filter((e) => e.month === currentMonth && e.year === currentYear)

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
              {/* Month Header & Controls */}
              <div className="flex items-center justify-between mb-4">
                <span className="text-sm sm:text-base font-extrabold tracking-wider text-foreground uppercase">
                  {monthNames[currentMonth - 1]} {currentYear}
                </span>
                <div className="flex items-center gap-1">
                  <Button
                    type="button"
                    variant="ghost"
                    size="icon"
                    onClick={handlePrevMonth}
                    className="h-8 w-8 rounded-full"
                    aria-label="Mês anterior"
                  >
                    <ChevronLeft className="h-4 w-4" />
                  </Button>
                  <Button
                    type="button"
                    variant="ghost"
                    size="icon"
                    onClick={handleNextMonth}
                    className="h-8 w-8 rounded-full"
                    aria-label="Próximo mês"
                  >
                    <ChevronRight className="h-4 w-4" />
                  </Button>
                </div>
              </div>

              {/* Days of Week Header */}
              <div className="grid grid-cols-7 gap-1 text-center mb-2">
                {["D", "S", "T", "Q", "Q", "S", "S"].map((col, idx) => (
                  <span
                    key={`${col}-${idx}`}
                    className="text-[11px] font-bold text-muted-foreground uppercase"
                  >
                    {col}
                  </span>
                ))}
              </div>

              {/* Calendar Days Matrix */}
              <div className="grid grid-cols-7 gap-1 text-center">
                {/* Empty slots for month start offset */}
                {Array.from({ length: firstDayOfWeek }).map((_, idx) => (
                  <div key={`empty-${idx}`} className="h-9 w-full" />
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
                      onClick={() =>
                        setSelectedDay(selectedDay === dayNumber ? null : dayNumber)
                      }
                      className={`relative flex h-9 w-full items-center justify-center rounded-lg text-xs font-medium transition-all ${
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

              {/* Active selection helper */}
              {selectedDay && (
                <div className="mt-4 flex items-center justify-between text-xs text-muted-foreground bg-muted/40 p-2 rounded-lg">
                  <span>Filtrando dia {selectedDay}</span>
                  <button
                    type="button"
                    onClick={() => setSelectedDay(null)}
                    className="text-primary hover:underline font-semibold"
                  >
                    Ver todos
                  </button>
                </div>
              )}
            </div>

            {/* Right Column: Event List */}
            <div className="md:col-span-6 flex flex-col justify-between space-y-4">
              <div className="space-y-3">
                <span className="text-xs font-bold uppercase tracking-wider text-muted-foreground">
                  Programação do Mês
                </span>

                {filteredEvents.length === 0 ? (
                  <div className="rounded-xl border border-dashed border-border/60 p-6 text-center text-xs text-muted-foreground">
                    Nenhum evento agendado para este dia.
                  </div>
                ) : (
                  <div className="space-y-2.5">
                    {filteredEvents.map((evt) => {
                      const dateString = evt.dayEnd
                        ? `Dias ${evt.day} e ${evt.dayEnd}`
                        : `Dia ${evt.day}`

                      return (
                        <Link
                          key={evt.id}
                          to={evt.type === "retiro" ? "/eventos" : "/quero-saber-mais"}
                          className="flex items-start gap-3 rounded-xl border border-border/50 bg-background/60 p-3.5 transition-all hover:border-primary/50 hover:bg-background hover:shadow-xs group cursor-pointer"
                        >
                          <div className="flex h-10 w-10 shrink-0 flex-col items-center justify-center rounded-lg bg-primary/10 text-primary font-bold group-hover:bg-primary group-hover:text-primary-foreground transition-colors">
                            <span className="text-xs uppercase leading-none">
                              {evt.dayEnd ? `${evt.day}-${evt.dayEnd}` : evt.day}
                            </span>
                          </div>

                          <div className="flex-1 min-w-0">
                            <div className="flex items-center gap-2">
                              <span className="text-xs font-semibold text-amber-600 dark:text-amber-400">
                                {dateString}:
                              </span>
                              <h4 className="text-sm font-bold text-foreground truncate group-hover:text-primary transition-colors">
                                {evt.title}
                              </h4>
                            </div>
                            {evt.location && (
                              <p className="mt-0.5 text-[11px] text-muted-foreground flex items-center gap-1">
                                <MapPin className="h-3 w-3 shrink-0" />
                                {evt.location}
                              </p>
                            )}
                          </div>

                          <ArrowRight className="h-4 w-4 text-muted-foreground/50 self-center shrink-0 group-hover:text-primary group-hover:translate-x-0.5 transition-all" />
                        </Link>
                      )
                    })}
                  </div>
                )}
              </div>

              {/* CTAs matching mockup */}
              <div className="pt-4 flex flex-col sm:flex-row gap-3 border-t border-border/40">
                <Button
                  asChild
                  className="min-h-[44px] flex-1 justify-center text-xs sm:text-sm font-semibold rounded-full bg-primary text-primary-foreground hover:bg-primary/90"
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
                    className="min-h-[44px] flex-1 justify-center text-xs sm:text-sm font-semibold rounded-full border-border hover:bg-muted"
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
            <span>{monthNames[currentMonth - 1]} {currentYear}</span>
          </div>
        </div>
      </div>
    </section>
  )
}
