import { useState } from "react"
import { Link } from "react-router-dom"
import { Home, Users, MapPin, Calendar, Clock, ArrowRight, MessageCircle, Phone, Sparkles } from "lucide-react"
import { Card, CardContent, CardHeader, CardTitle, CardDescription, CardFooter } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Badge } from "@/components/ui/badge"
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog"
import type { Database } from "@/lib/database.types"

type HomeGroup = Database["public"]["Tables"]["home_groups"]["Row"] & {
  sectors?: Database["public"]["Tables"]["sectors"]["Row"] | null
  leader_1?: Database["public"]["Tables"]["profiles"]["Row"] | null
  leader_2?: Database["public"]["Tables"]["profiles"]["Row"] | null
}

type GroupMember = Pick<
  Database["public"]["Tables"]["profiles"]["Row"],
  "id" | "full_name" | "avatar_url" | "phone"
>

interface HomeGroupCardProps {
  homeGroup: HomeGroup | null
  members: GroupMember[]
  loading?: boolean
}

const dayNames = [
  "Domingo",
  "Segunda-feira",
  "Terça-feira",
  "Quarta-feira",
  "Quinta-feira",
  "Sexta-feira",
  "Sábado",
]

export function HomeGroupCard({ homeGroup, members, loading = false }: HomeGroupCardProps) {
  const [isMemberListOpen, setIsMemberListOpen] = useState(false)

  if (loading) {
    return (
      <Card className="rounded-xl border-border bg-card/60 shadow-xs">
        <CardHeader className="space-y-2 pb-3">
          <div className="h-5 w-32 animate-pulse rounded bg-muted" />
          <div className="h-4 w-48 animate-pulse rounded bg-muted" />
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="h-10 w-full animate-pulse rounded-lg bg-muted" />
          <div className="h-12 w-full animate-pulse rounded-lg bg-muted" />
        </CardContent>
      </Card>
    )
  }

  if (!homeGroup) {
    return (
      <Card className="flex flex-col justify-between rounded-xl border-border bg-card/60 shadow-xs">
        <CardHeader className="space-y-1 pb-3">
          <div className="flex items-center justify-between gap-2">
            <CardTitle className="flex items-center gap-2 text-lg font-bold text-foreground">
              <Home className="h-5 w-5 text-primary" />
              Meu Grupo Caseiro (Oikos)
            </CardTitle>
            <Badge variant="outline" className="border-amber-500/30 text-amber-600 dark:text-amber-400 text-xs">
              Acolhimento
            </Badge>
          </div>
          <CardDescription className="text-xs">
            Comunhão e cuidado semanal de casa em casa
          </CardDescription>
        </CardHeader>
        <CardContent className="space-y-3 py-2 text-sm text-muted-foreground">
          <p>
            Você ainda não está vinculado a um Grupo Caseiro nesta região. Caminhar junto e perseverar nas casas é essencial para a vida em família!
          </p>
          <div className="rounded-lg border border-border/60 bg-muted/30 p-3 text-xs">
            <span className="font-semibold text-foreground">Dica fraterna:</span> Converse com seu discipulador ou consulte o mapa de regiões para encontrar irmãos perto de você.
          </div>
        </CardContent>
        <CardFooter className="pt-2">
          <Button asChild variant="outline" size="sm" className="min-h-[44px] w-full gap-2">
            <Link to="/grupos-caseiros">
              <MapPin className="h-4 w-4 text-primary" />
              Ver Mapa de Grupos Caseiros
            </Link>
          </Button>
        </CardFooter>
      </Card>
    )
  }

  const meetingDayText =
    homeGroup.meeting_day !== null && homeGroup.meeting_day !== undefined
      ? dayNames[homeGroup.meeting_day] || "Dia a combinar"
      : "Dia a combinar"

  const leaders = [homeGroup.leader_1, homeGroup.leader_2].filter(Boolean)
  const maxVisibleAvatars = 5
  const visibleMembers = members.slice(0, maxVisibleAvatars)
  const remainingCount = Math.max(0, members.length - maxVisibleAvatars)

  return (
    <>
      <Card className="flex flex-col justify-between rounded-xl border-border/80 bg-card/70 shadow-xs backdrop-blur-xs transition-colors hover:border-primary/30">
        <CardHeader className="space-y-1.5 pb-3">
          <div className="flex items-start justify-between gap-2">
            <div className="space-y-1">
              <CardTitle className="flex items-center gap-2 text-base font-bold sm:text-lg">
                <Home className="h-5 w-5 text-primary shrink-0" />
                <span className="line-clamp-1">
                  {homeGroup.location_text?.split("—")[0]?.trim() || "Grupo Caseiro"}
                </span>
              </CardTitle>
              <CardDescription className="text-xs font-medium text-primary">
                {homeGroup.sectors?.name || "Região Metropolitana de BH"}
              </CardDescription>
            </div>
            <Badge
              variant="secondary"
              className="shrink-0 gap-1 rounded-full border border-primary/20 bg-primary/10 px-2.5 py-1 text-[11px] font-semibold text-primary"
            >
              <Sparkles className="h-3 w-3" />
              Oikos
            </Badge>
          </div>
        </CardHeader>

        <CardContent className="space-y-4 py-2">
          {/* Informações de Reunião */}
          <div className="grid grid-cols-1 gap-2.5 rounded-lg border border-border/50 bg-background/60 p-3 sm:grid-cols-2">
            <div className="flex items-center gap-2 text-xs text-muted-foreground">
              <Calendar className="h-4 w-4 text-primary shrink-0" />
              <span className="font-medium text-foreground">{meetingDayText}</span>
            </div>
            <div className="flex items-center gap-2 text-xs text-muted-foreground">
              <Clock className="h-4 w-4 text-primary shrink-0" />
              <span>
                {homeGroup.start_time
                  ? `${homeGroup.start_time.substring(0, 5)}h`
                  : "20:00h"}
              </span>
            </div>
            {homeGroup.location_text && (
              <div className="col-span-1 sm:col-span-2 flex items-start gap-2 text-xs text-muted-foreground pt-1 border-t border-border/30">
                <MapPin className="h-4 w-4 text-primary shrink-0 mt-0.5" />
                <span className="line-clamp-2 leading-relaxed">
                  {homeGroup.location_text}
                </span>
              </div>
            )}
          </div>

          {/* Anfitriões / Responsáveis */}
          {leaders.length > 0 && (
            <div className="text-xs text-muted-foreground">
              <span className="font-semibold text-foreground">Servindo no grupo: </span>
              {leaders.map((l) => l?.full_name).join(" e ")}
            </div>
          )}

          {/* Avatares dos Irmãos do Grupo */}
          <div className="space-y-1.5 pt-1">
            <div className="flex items-center justify-between text-xs">
              <span className="font-semibold text-foreground flex items-center gap-1.5">
                <Users className="h-3.5 w-3.5 text-primary" />
                Vida em Família ({members.length} {members.length === 1 ? "irmão" : "irmãos"})
              </span>
              {members.length > 0 && (
                <button
                  type="button"
                  onClick={() => setIsMemberListOpen(true)}
                  className="min-h-[32px] text-xs font-medium text-primary hover:underline"
                >
                  Ver todos
                </button>
              )}
            </div>

            <div className="flex items-center -space-x-2 overflow-hidden py-1">
              {visibleMembers.map((member) => (
                <Avatar
                  key={member.id}
                  className="h-8 w-8 border-2 border-background ring-1 ring-border/40 transition-transform hover:scale-110"
                  title={member.full_name}
                >
                  <AvatarImage src={member.avatar_url || undefined} alt={member.full_name} />
                  <AvatarFallback className="text-[10px] font-bold">
                    {member.full_name.substring(0, 2).toUpperCase()}
                  </AvatarFallback>
                </Avatar>
              ))}

              {remainingCount > 0 && (
                <button
                  type="button"
                  onClick={() => setIsMemberListOpen(true)}
                  className="flex h-8 w-8 items-center justify-center rounded-full border-2 border-background bg-muted text-[11px] font-semibold text-muted-foreground ring-1 ring-border/40 hover:bg-muted/80"
                  title="Ver mais irmãos"
                >
                  +{remainingCount}
                </button>
              )}
            </div>
          </div>
        </CardContent>

        <CardFooter className="pt-3">
          <Button
            asChild
            variant="outline"
            size="sm"
            className="btn-tactile min-h-[44px] w-full justify-center gap-1.5 text-xs font-semibold"
          >
            <Link to="/grupos-caseiros">
              Ver Detalhes do Grupo no Mapa
              <ArrowRight className="h-3.5 w-3.5" />
            </Link>
          </Button>
        </CardFooter>
      </Card>

      {/* Modal de Lista de Irmãos do Grupo */}
      <Dialog open={isMemberListOpen} onOpenChange={setIsMemberListOpen}>
        <DialogContent className="max-w-md p-6">
          <DialogHeader className="text-left space-y-1">
            <DialogTitle className="flex items-center gap-2 text-lg font-bold">
              <Users className="h-5 w-5 text-primary" />
              Irmãos do Grupo Caseiro
            </DialogTitle>
            <DialogDescription className="text-xs">
              {members.length} discípulos caminhando juntos no partir do pão e oração.
            </DialogDescription>
          </DialogHeader>

          <div className="max-h-[60vh] space-y-2.5 overflow-y-auto pr-1">
            {members.map((m) => (
              <div
                key={m.id}
                className="flex items-center justify-between rounded-lg border border-border/50 bg-background/50 p-2.5 transition-colors hover:bg-muted/30"
              >
                <div className="flex items-center gap-3">
                  <Avatar className="h-9 w-9 border border-border">
                    <AvatarImage src={m.avatar_url || undefined} alt={m.full_name} />
                    <AvatarFallback className="text-xs font-bold">
                      {m.full_name.substring(0, 2).toUpperCase()}
                    </AvatarFallback>
                  </Avatar>
                  <div>
                    <p className="text-sm font-semibold text-foreground leading-tight">
                      {m.full_name}
                    </p>
                    {m.phone && (
                      <p className="text-xs text-muted-foreground flex items-center gap-1 mt-0.5">
                        <Phone className="h-3 w-3 text-primary/70" />
                        {m.phone}
                      </p>
                    )}
                  </div>
                </div>

                {m.phone && (
                  <Button
                    asChild
                    variant="ghost"
                    size="icon"
                    className="min-h-[44px] min-w-[44px] text-muted-foreground hover:text-primary"
                    aria-label={`Conversar no WhatsApp com ${m.full_name}`}
                  >
                    <a
                      href={`https://wa.me/55${m.phone.replace(/\D/g, "")}`}
                      target="_blank"
                      rel="noopener noreferrer"
                    >
                      <MessageCircle className="h-4 w-4" />
                    </a>
                  </Button>
                )}
              </div>
            ))}
          </div>
        </DialogContent>
      </Dialog>
    </>
  )
}
