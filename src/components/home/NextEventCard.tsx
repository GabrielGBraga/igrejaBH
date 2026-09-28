import { Link } from "react-router-dom"
import { Calendar, MapPin, CheckCircle2, ArrowRight, Sparkles, Clock } from "lucide-react"
import { Card, CardContent, CardHeader, CardTitle, CardDescription, CardFooter } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import { format, parseISO } from "date-fns"
import { ptBR } from "date-fns/locale"
import type { Database } from "@/lib/database.types"

type Retreat = Database["public"]["Tables"]["retreats"]["Row"]
type Registration = Database["public"]["Tables"]["registrations"]["Row"]

interface NextEventCardProps {
  retreat: Retreat | null
  registration: Registration | null
  loading?: boolean
}

export function NextEventCard({
  retreat,
  registration,
  loading = false,
}: NextEventCardProps) {
  if (loading) {
    return (
      <Card className="rounded-xl border-border bg-card/60 shadow-xs">
        <CardHeader className="space-y-2 pb-3">
          <div className="h-5 w-36 animate-pulse rounded bg-muted" />
          <div className="h-4 w-48 animate-pulse rounded bg-muted" />
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="h-8 w-full animate-pulse rounded-lg bg-muted" />
          <div className="h-10 w-full animate-pulse rounded-lg bg-muted" />
        </CardContent>
      </Card>
    )
  }

  if (!retreat) {
    return (
      <Card className="flex flex-col justify-between rounded-xl border-border/80 bg-card/70 shadow-xs">
        <CardHeader className="space-y-1.5 pb-3">
          <CardTitle className="flex items-center gap-2 text-base font-bold sm:text-lg">
            <Calendar className="h-5 w-5 text-primary shrink-0" />
            <span>Encontros e Retiros</span>
          </CardTitle>
          <CardDescription className="text-xs">
            Comunhão de toda a igreja na cidade
          </CardDescription>
        </CardHeader>
        <CardContent className="space-y-3 py-2 text-xs text-muted-foreground">
          <p className="leading-relaxed">
            Nenhum retiro com inscrições abertas no momento. Fique atento aos avisos para os próximos encontros da igreja na cidade!
          </p>
        </CardContent>
        <CardFooter className="pt-3">
          <Button asChild variant="outline" size="sm" className="min-h-[44px] w-full text-xs font-semibold">
            <Link to="/eventos">Ver Histórico de Encontros</Link>
          </Button>
        </CardFooter>
      </Card>
    )
  }

  const formatDateRange = (start?: string | null, end?: string | null) => {
    if (!start) return "Data a confirmar"
    try {
      const s = parseISO(start)
      if (!end) return format(s, "dd 'de' MMMM 'de' yyyy", { locale: ptBR })
      const e = parseISO(end)
      if (format(s, "MM/yyyy") === format(e, "MM/yyyy")) {
        return `${format(s, "dd")} a ${format(e, "dd 'de' MMMM 'de' yyyy", { locale: ptBR })}`
      }
      return `${format(s, "dd/MM")} a ${format(e, "dd/MM/yyyy")}`
    } catch {
      return start
    }
  }

  const isRegistered = !!registration

  return (
    <Card className="flex flex-col justify-between rounded-xl border-border/80 bg-card/70 shadow-xs backdrop-blur-xs transition-colors hover:border-primary/30">
      <CardHeader className="space-y-1.5 pb-3">
        <div className="flex items-start justify-between gap-2">
          <div className="space-y-1">
            <CardTitle className="flex items-center gap-2 text-base font-bold sm:text-lg">
              <Calendar className="h-5 w-5 text-primary shrink-0" />
              <span>Próximo Encontro</span>
            </CardTitle>
            <CardDescription className="text-xs font-medium text-primary">
              Comunhão ampla de toda a cidade
            </CardDescription>
          </div>
          {isRegistered ? (
            <Badge className="shrink-0 gap-1 rounded-full border-emerald-500/30 bg-emerald-500/10 px-2.5 py-1 text-[11px] font-semibold text-emerald-700 dark:text-emerald-300">
              <CheckCircle2 className="h-3 w-3" />
              Inscrição Confirmada
            </Badge>
          ) : (
            <Badge variant="outline" className="shrink-0 gap-1 rounded-full border-primary/30 bg-primary/10 px-2.5 py-1 text-[11px] font-semibold text-primary">
              <Sparkles className="h-3 w-3" />
              Inscrições Abertas
            </Badge>
          )}
        </div>
      </CardHeader>

      <CardContent className="space-y-3 py-2">
        <div>
          <h4 className="text-sm font-bold text-foreground leading-snug">
            {retreat.title}
          </h4>
          {retreat.description && (
            <p className="mt-1 text-xs text-muted-foreground line-clamp-2">
              {retreat.description}
            </p>
          )}
        </div>

        <div className="space-y-1.5 rounded-lg border border-border/50 bg-background/60 p-2.5 text-xs text-muted-foreground">
          <div className="flex items-center gap-2">
            <Clock className="h-3.5 w-3.5 text-primary shrink-0" />
            <span className="font-medium text-foreground">
              {formatDateRange(retreat.start_date, retreat.end_date)}
            </span>
          </div>
          {retreat.location_text && (
            <div className="flex items-start gap-2 pt-0.5">
              <MapPin className="h-3.5 w-3.5 text-primary shrink-0 mt-0.5" />
              <span className="line-clamp-1">{retreat.location_text}</span>
            </div>
          )}
        </div>
      </CardContent>

      <CardFooter className="pt-3">
        <Button
          asChild
          variant={isRegistered ? "outline" : "default"}
          size="sm"
          className="btn-tactile min-h-[44px] w-full justify-center gap-1.5 text-xs font-semibold"
        >
          <Link to="/eventos">
            {isRegistered ? "Ver Detalhes do Ingresso" : "Inscrever-se no Encontro"}
            <ArrowRight className="h-3.5 w-3.5" />
          </Link>
        </Button>
      </CardFooter>
    </Card>
  )
}
