import { useState, useEffect, useCallback, useMemo } from "react"
import supabase from "@/lib/supabase"
import type { Database } from "@/lib/database.types"
import { format, parseISO, isAfter, isSameDay, startOfDay } from "date-fns"
import { ptBR } from "date-fns/locale"

export type RetreatRow = Database["public"]["Tables"]["retreats"]["Row"]
export type PostRow = Database["public"]["Tables"]["posts"]["Row"]

export interface CalendarEventItem {
  id: string
  day: number
  dayEnd?: number
  month: number // 1-12
  year: number
  title: string
  description?: string | null
  type: "retiro" | "encontro" | "geral"
  typeLabel: string
  location?: string | null
  startDateStr: string
  endDateStr?: string | null
  status?: string | null
  isHighlight?: boolean
  isPublic: boolean
  link?: string
  rawPost?: PostRow
  rawRetreat?: RetreatRow
}

interface UseChurchCalendarOptions {
  publicOnly?: boolean
  initialMonth?: number // 1-12
  initialYear?: number
}

/**
 * Extrai dia, mês e ano de forma segura sem risco de desvio de timezone (UTC midnight -> dia anterior)
 */
export function parseDateSafe(dateStr?: string | null): { year: number; month: number; day: number } | null {
  if (!dateStr) return null

  // Se formato YYYY-MM-DD
  if (/^\d{4}-\d{2}-\d{2}$/.test(dateStr)) {
    const [y, m, d] = dateStr.split("-").map(Number)
    return { year: y, month: m, day: d }
  }

  // Se formato ISO com horário
  try {
    const d = new Date(dateStr)
    return {
      year: d.getFullYear(),
      month: d.getMonth() + 1,
      day: d.getDate(),
    }
  } catch {
    return null
  }
}

/**
 * Formata horário de forma limpa, arredondando pequenas variações de segundos de seeds (ex: 19:59 -> 20:00)
 */
export function formatTimeClean(date: Date): string {
  const mins = date.getMinutes()
  if (mins === 59 || mins === 58) {
    const rounded = new Date(date.getTime() + (60 - mins) * 60000)
    return format(rounded, "HH:00'h'")
  }
  if (mins === 1 || mins === 2) {
    const rounded = new Date(date.getTime() - mins * 60000)
    return format(rounded, "HH:00'h'")
  }
  return format(date, "HH:mm'h'")
}

export function formatEventSchedule(startDateStr: string, endDateStr?: string | null): string {
  const startParsed = parseDateSafe(startDateStr)
  if (!startParsed) return "Data a confirmar"

  // Se for apenas data sem horário (YYYY-MM-DD)
  if (/^\d{4}-\d{2}-\d{2}$/.test(startDateStr)) {
    if (endDateStr && /^\d{4}-\d{2}-\d{2}$/.test(endDateStr)) {
      const endParsed = parseDateSafe(endDateStr)
      if (endParsed) {
        if (startParsed.month === endParsed.month) {
          return `Dias ${startParsed.day} a ${endParsed.day} de ${format(new Date(startParsed.year, startParsed.month - 1, 1), "MMMM", { locale: ptBR })}`
        }
        return `${startParsed.day}/${startParsed.month} a ${endParsed.day}/${endParsed.month}/${endParsed.year}`
      }
    }
    return `Dia ${startParsed.day} de ${format(new Date(startParsed.year, startParsed.month - 1, 1), "MMMM", { locale: ptBR })}`
  }

  // Se for com timestamp
  try {
    const s = parseISO(startDateStr)
    const dayWeek = format(s, "EEEE, dd/MM", { locale: ptBR })
    const time = formatTimeClean(s)

    if (!endDateStr) {
      return `${dayWeek} às ${time}`
    }

    const e = parseISO(endDateStr)
    const sDay = format(s, "dd/MM")
    const eDay = format(e, "dd/MM")

    if (sDay === eDay) {
      return `${dayWeek} das ${time} às ${formatTimeClean(e)}`
    }
    return `${sDay} a ${eDay} (${formatTimeClean(s)})`
  } catch {
    return startDateStr
  }
}

export function useChurchCalendar(options: UseChurchCalendarOptions = {}) {
  const { publicOnly = false, initialMonth = 10, initialYear = 2026 } = options

  const [currentDate, setCurrentDate] = useState(() => new Date(initialYear, initialMonth - 1, 1))
  const [selectedDay, setSelectedDay] = useState<number | null>(null)
  const [events, setEvents] = useState<CalendarEventItem[]>([])
  const [loading, setLoading] = useState(true)

  const currentMonth = currentDate.getMonth() + 1
  const currentYear = currentDate.getFullYear()

  const fetchCalendar = useCallback(async () => {
    setLoading(true)
    try {
      // 1. Busca retiros
      let retreatsQuery = supabase
        .from("retreats")
        .select("*")
        .not("start_date", "is", null)

      if (publicOnly) {
        retreatsQuery = retreatsQuery.eq("status", "ativo")
      } else {
        retreatsQuery = retreatsQuery.neq("status", "cancelado")
      }

      // 2. Busca encontros/posts com data
      let postsQuery = supabase
        .from("posts")
        .select("*")
        .eq("is_published", true)
        .not("event_start_date", "is", null)

      if (publicOnly) {
        postsQuery = postsQuery.eq("is_public", true)
      }

      const [retreatsRes, postsRes] = await Promise.all([
        retreatsQuery.order("start_date", { ascending: true }),
        postsQuery.order("event_start_date", { ascending: true }),
      ])

      const combined: CalendarEventItem[] = []

      // Mapeia retiros
      if (retreatsRes.data) {
        retreatsRes.data.forEach((r) => {
          const parsedStart = parseDateSafe(r.start_date)
          const parsedEnd = parseDateSafe(r.end_date)
          if (!parsedStart) return

          combined.push({
            id: r.id,
            title: r.title,
            description: r.description,
            day: parsedStart.day,
            dayEnd: parsedEnd ? parsedEnd.day : undefined,
            month: parsedStart.month,
            year: parsedStart.year,
            type: "retiro",
            typeLabel: "Retiro Comunitário",
            location: r.location_text,
            startDateStr: r.start_date!,
            endDateStr: r.end_date,
            status: r.status,
            isHighlight: true,
            isPublic: true,
            link: "/eventos",
            rawRetreat: r,
          })
        })
      }

      // Mapeia encontros casuais
      if (postsRes.data) {
        postsRes.data.forEach((p) => {
          const parsedStart = parseDateSafe(p.event_start_date)
          const parsedEnd = parseDateSafe(p.event_end_date)
          if (!parsedStart) return

          combined.push({
            id: p.id,
            title: p.title,
            description: p.content,
            day: parsedStart.day,
            dayEnd: parsedEnd ? parsedEnd.day : undefined,
            month: parsedStart.month,
            year: parsedStart.year,
            type: "encontro",
            typeLabel: "Encontro na Cidade",
            location: p.event_location,
            startDateStr: p.event_start_date!,
            endDateStr: p.event_end_date,
            isHighlight: false,
            isPublic: !!p.is_public,
            rawPost: p,
          })
        })
      }

      // Ordena cronologicamente
      combined.sort((a, b) => {
        if (a.year !== b.year) return a.year - b.year
        if (a.month !== b.month) return a.month - b.month
        return a.day - b.day
      })

      setEvents(combined)
    } catch (err) {
      console.error("Erro ao carregar agenda e calendário:", err)
    } finally {
      setLoading(false)
    }
  }, [publicOnly])

  useEffect(() => {
    fetchCalendar()
  }, [fetchCalendar])

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

  // Eventos do mês atual
  const monthEvents = useMemo(() => {
    return events.filter((e) => e.month === currentMonth && e.year === currentYear)
  }, [events, currentMonth, currentYear])

  // Mapeamento de dias que possuem eventos
  const eventDaysMap = useMemo(() => {
    const map = new Map<number, CalendarEventItem[]>()
    monthEvents.forEach((e) => {
      const start = e.day
      const end = e.dayEnd || e.day
      for (let d = start; d <= end; d++) {
        const list = map.get(d) || []
        list.push(e)
        map.set(d, list)
      }
    })
    return map
  }, [monthEvents])

  // Eventos filtrados pelo dia selecionado (ou todos do mês)
  const filteredEvents = useMemo(() => {
    if (!selectedDay) return monthEvents
    return monthEvents.filter((e) => {
      const end = e.dayEnd || e.day
      return e.day <= selectedDay && end >= selectedDay
    })
  }, [monthEvents, selectedDay])

  // Próximos eventos a partir de hoje
  const upcomingEvents = useMemo(() => {
    const today = startOfDay(new Date())
    return events.filter((e) => {
      try {
        const parsed = parseDateSafe(e.startDateStr)
        if (!parsed) return false
        const eventDate = new Date(parsed.year, parsed.month - 1, parsed.day)
        return isAfter(eventDate, today) || isSameDay(eventDate, today)
      } catch {
        return false
      }
    })
  }, [events])

  const nextEvent = upcomingEvents[0] || null

  return {
    events,
    monthEvents,
    filteredEvents,
    upcomingEvents,
    nextEvent,
    eventDaysMap,
    currentDate,
    currentMonth,
    currentYear,
    daysInMonth,
    firstDayOfWeek,
    selectedDay,
    setSelectedDay,
    handlePrevMonth,
    handleNextMonth,
    loading,
    refetch: fetchCalendar,
  }
}
