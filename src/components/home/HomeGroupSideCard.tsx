import { useState } from "react"
import { Link } from "react-router-dom"
import { Home, MapPin, Calendar, Clock, ArrowRight, MessageCircle, Phone, Users } from "lucide-react"
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

interface HomeGroupSideCardProps {
  homeGroup: HomeGroup | null
  members: GroupMember[]
  loading?: boolean
  isChurchLinked?: boolean
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

export function HomeGroupSideCard({
  homeGroup,
  members,
  loading = false,
  isChurchLinked = true,
}: HomeGroupSideCardProps) {
  const [isMemberListOpen, setIsMemberListOpen] = useState(false)

  if (loading) {
    return (
      <Card className="rounded-xl border-border bg-card/60 shadow-xs">
        <CardHeader className="space-y-2 pb-3">
          <div className="h-5 w-32 animate-pulse rounded bg-muted" />
          <div className="h-4 w-44 animate-pulse rounded bg-muted" />
        </CardHeader>
        <CardContent className="space-y-3">
          <div className="h-10 w-full animate-pulse rounded-lg bg-muted" />
          <div className="h-10 w-full animate-pulse rounded-lg bg-muted" />
        </CardContent>
      </Card>
    )
  }

  if (!homeGroup || !isChurchLinked) {
    return (
      <Card className="rounded-xl border-border/80 bg-card/70 shadow-xs backdrop-blur-xs">
        <CardHeader className="space-y-1.5 pb-2">
          <div className="flex items-center justify-between gap-2">
            <CardTitle className="flex items-center gap-2 text-sm font-bold text-foreground">
              <Home className="h-4 w-4 text-primary shrink-0" />
              <span>Meu Grupo Caseiro</span>
            </CardTitle>
            <Badge variant="outline" className="border-primary/30 text-[10px] font-semibold text-primary">
              Oikos
            </Badge>
          </div>
          <CardDescription className="text-xs text-muted-foreground">
            A comunhão e o convívio nas casas
          </CardDescription>
        </CardHeader>
        <CardContent className="space-y-2.5 py-2 text-xs text-muted-foreground">
          <p className="leading-relaxed">
            A igreja em Belo Horizonte se reúne nos lares para oração, partir do pão e cuidado mútuo.
          </p>
          <div className="rounded-lg border border-border/60 bg-muted/30 p-2.5 text-[11px] leading-relaxed">
            <span className="font-semibold text-foreground">Deseja caminhar junto?</span> Fale com os irmãos ou veja as informações no seu perfil para se conectar a um Grupo Caseiro.
          </div>
        </CardContent>
        <CardFooter className="pt-2">
          <Button asChild variant="outline" size="sm" className="min-h-[44px] w-full justify-center gap-1.5 text-xs font-medium">
            <Link to="/perfil">
              <MapPin className="h-3.5 w-3.5 text-primary" />
              Ver Minhas Informações
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
  const maxVisibleAvatars = 4
  const visibleMembers = members.slice(0, maxVisibleAvatars)
  const remainingCount = Math.max(0, members.length - maxVisibleAvatars)

  return (
    <>
      <Card className="rounded-xl border-border/80 bg-card/70 shadow-xs backdrop-blur-xs transition-colors hover:border-primary/30">
        <CardHeader className="space-y-1 pb-2">
          <div className="flex items-start justify-between gap-2">
            <div className="space-y-0.5">
              <CardTitle className="flex items-center gap-2 text-sm font-bold text-foreground">
                <Home className="h-4 w-4 text-primary shrink-0" />
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
              className="shrink-0 gap-1 rounded-full border border-primary/20 bg-primary/10 px-2 py-0.5 text-[10px] font-semibold text-primary"
            >
              Oikos
            </Badge>
          </div>
        </CardHeader>

        <CardContent className="space-y-3 py-2 text-xs">
          {/* Horário & Encontro */}
          <div className="flex flex-col gap-1.5 rounded-lg border border-border/50 bg-background/50 p-2.5">
            <div className="flex items-center justify-between text-xs">
              <span className="flex items-center gap-1.5 text-muted-foreground">
                <Calendar className="h-3.5 w-3.5 text-primary shrink-0" />
                <span className="font-medium text-foreground">{meetingDayText}</span>
              </span>
              <span className="flex items-center gap-1 text-muted-foreground">
                <Clock className="h-3.5 w-3.5 text-primary shrink-0" />
                <span>
                  {homeGroup.start_time
                    ? `${homeGroup.start_time.substring(0, 5)}h`
                    : "20:00h"}
                </span>
              </span>
            </div>

            {homeGroup.location_text && (
              <div className="flex items-start gap-1.5 border-t border-border/30 pt-1.5 text-[11px] text-muted-foreground">
                <MapPin className="h-3.5 w-3.5 text-primary shrink-0 mt-0.5" />
                <span className="line-clamp-2 leading-snug">
                  {homeGroup.location_text}
                </span>
              </div>
            )}
          </div>

          {/* Líderes / Anfitriões */}
          {leaders.length > 0 && (
            <div className="space-y-1.5">
              <span className="text-[10px] font-semibold uppercase tracking-wider text-muted-foreground">
                Líderes & Anfitriões
              </span>
              <div className="flex flex-wrap gap-2">
                {leaders.map((leader) => (
                  <div
                    key={leader!.id}
                    className="flex items-center gap-1.5 rounded-md bg-muted/40 px-2 py-1"
                  >
                    <Avatar className="h-5 w-5 border border-border/60">
                      <AvatarImage src={leader!.avatar_url || undefined} alt={leader!.full_name} />
                      <AvatarFallback className="text-[9px] bg-primary/10 text-primary">
                        {leader!.full_name
                          .split(" ")
                          .map((n) => n[0])
                          .slice(0, 2)
                          .join("")}
                      </AvatarFallback>
                    </Avatar>
                    <span className="text-[11px] font-medium text-foreground">
                      {leader!.full_name.split(" ")[0]}
                    </span>
                  </div>
                ))}
              </div>
            </div>
          )}

          {/* Membros do Grupo (Resumo Rápido) */}
          <div className="space-y-1.5 border-t border-border/30 pt-2">
            <div className="flex items-center justify-between text-[11px]">
              <span className="font-semibold text-muted-foreground">
                Irmãos do Grupo ({members.length})
              </span>
              {members.length > 0 && (
                <button
                  type="button"
                  onClick={() => setIsMemberListOpen(true)}
                  className="font-medium text-primary hover:underline cursor-pointer"
                >
                  Ver lista
                </button>
              )}
            </div>

            {members.length > 0 && (
              <div className="flex items-center gap-2">
                <div className="flex -space-x-1.5 overflow-hidden">
                  {visibleMembers.map((member) => (
                    <Avatar
                      key={member.id}
                      className="h-6 w-6 border-2 border-background ring-1 ring-border/50"
                    >
                      <AvatarImage src={member.avatar_url || undefined} alt={member.full_name} />
                      <AvatarFallback className="text-[9px] bg-primary/10 text-primary">
                        {member.full_name
                          .split(" ")
                          .map((n) => n[0])
                          .slice(0, 2)
                          .join("")}
                      </AvatarFallback>
                    </Avatar>
                  ))}
                </div>
                {remainingCount > 0 && (
                  <span className="text-[11px] text-muted-foreground font-medium">
                    +{remainingCount} irmãos
                  </span>
                )}
              </div>
            )}
          </div>
        </CardContent>

        <CardFooter className="pt-2">
          <Button
            asChild
            variant="outline"
            size="sm"
            className="btn-tactile min-h-[44px] w-full justify-center gap-1.5 text-xs font-medium"
          >
            <Link to="/perfil">
              <MapPin className="h-3.5 w-3.5 text-primary" />
              Ver Detalhes do Grupo no Perfil
              <ArrowRight className="h-3 w-3" />
            </Link>
          </Button>
        </CardFooter>
      </Card>

      {/* Modal de Lista de Membros */}
      <Dialog open={isMemberListOpen} onOpenChange={setIsMemberListOpen}>
        <DialogContent className="max-w-md rounded-xl">
          <DialogHeader>
            <DialogTitle className="flex items-center gap-2 text-base font-bold">
              <Users className="h-5 w-5 text-primary" />
              Discípulos do Grupo Caseiro
            </DialogTitle>
            <DialogDescription className="text-xs">
              Irmãos que caminham juntos no {homeGroup.location_text?.split("—")[0]?.trim() || "Grupo Caseiro"}
            </DialogDescription>
          </DialogHeader>

          <div className="max-h-[340px] space-y-2 overflow-y-auto pr-1">
            {members.map((member) => {
              const cleanPhone = member.phone?.replace(/\D/g, "")
              return (
                <div
                  key={member.id}
                  className="flex items-center justify-between rounded-lg border border-border/40 p-2.5 transition-colors hover:bg-muted/30"
                >
                  <div className="flex items-center gap-2.5 min-w-0">
                    <Avatar className="h-8 w-8 border border-border/60 shrink-0">
                      <AvatarImage src={member.avatar_url || undefined} alt={member.full_name} />
                      <AvatarFallback className="text-xs bg-primary/10 text-primary">
                        {member.full_name
                          .split(" ")
                          .map((n) => n[0])
                          .slice(0, 2)
                          .join("")}
                      </AvatarFallback>
                    </Avatar>
                    <span className="truncate text-xs font-semibold text-foreground">
                      {member.full_name}
                    </span>
                  </div>

                  {cleanPhone && (
                    <div className="flex items-center gap-1 shrink-0">
                      <Button asChild variant="ghost" size="icon" className="h-8 w-8 rounded-full" title="WhatsApp">
                        <a
                          href={`https://wa.me/55${cleanPhone}`}
                          target="_blank"
                          rel="noopener noreferrer"
                          aria-label={`Conversar no WhatsApp com ${member.full_name}`}
                        >
                          <MessageCircle className="h-4 w-4 text-emerald-600 dark:text-emerald-400" />
                        </a>
                      </Button>
                      <Button asChild variant="ghost" size="icon" className="h-8 w-8 rounded-full" title="Ligar">
                        <a href={`tel:${cleanPhone}`} aria-label={`Ligar para ${member.full_name}`}>
                          <Phone className="h-4 w-4 text-primary" />
                        </a>
                      </Button>
                    </div>
                  )}
                </div>
              )
            })}
          </div>
        </DialogContent>
      </Dialog>
    </>
  )
}
