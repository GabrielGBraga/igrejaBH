import { useState } from "react"
import { Link } from "react-router-dom"
import { Heart, ArrowRight, MessageCircle, Phone, Users, UserCheck } from "lucide-react"
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

type ProfileSummary = Pick<
  Database["public"]["Tables"]["profiles"]["Row"],
  "id" | "full_name" | "avatar_url" | "phone"
>

interface DiscipleshipSideCardProps {
  discipler: ProfileSummary | null
  disciples: ProfileSummary[]
  fellows: ProfileSummary[]
  loading?: boolean
  isChurchLinked?: boolean
}

export function DiscipleshipSideCard({
  discipler,
  disciples,
  fellows,
  loading = false,
  isChurchLinked = true,
}: DiscipleshipSideCardProps) {
  const [isDisciplesModalOpen, setIsDisciplesModalOpen] = useState(false)

  if (loading) {
    return (
      <Card className="rounded-xl border-border bg-card/60 shadow-xs">
        <CardHeader className="space-y-2 pb-3">
          <div className="h-5 w-36 animate-pulse rounded bg-muted" />
          <div className="h-4 w-48 animate-pulse rounded bg-muted" />
        </CardHeader>
        <CardContent className="space-y-3">
          <div className="h-10 w-full animate-pulse rounded-lg bg-muted" />
          <div className="h-10 w-full animate-pulse rounded-lg bg-muted" />
        </CardContent>
      </Card>
    )
  }

  if (!isChurchLinked) {
    return (
      <Card className="rounded-xl border-border/80 bg-card/70 shadow-xs backdrop-blur-xs">
        <CardHeader className="space-y-1.5 pb-2">
          <div className="flex items-center justify-between gap-2">
            <CardTitle className="flex items-center gap-2 text-sm font-bold text-foreground">
              <Heart className="h-4 w-4 text-amber-600 dark:text-amber-400 shrink-0" />
              <span>Juntas e Ligamentos</span>
            </CardTitle>
            <Badge variant="outline" className="border-amber-600/30 text-[10px] font-semibold text-amber-700 dark:text-amber-300">
              Discipulado
            </Badge>
          </div>
          <CardDescription className="text-xs text-muted-foreground">
            Vida na vida e edificação mútua
          </CardDescription>
        </CardHeader>
        <CardContent className="space-y-2.5 py-2 text-xs text-muted-foreground">
          <p className="leading-relaxed">
            No Corpo de Cristo, a edificação ocorre através de relacionamentos de cuidado pessoal e aprendizado mútuo.
          </p>
          <div className="rounded-lg border border-border/60 bg-muted/30 p-2.5 text-[11px] leading-relaxed">
            <span className="font-semibold text-foreground">Caminhe conosco:</span> Ao se conectar à vida da igreja na cidade, você é acolhido em discipulado e companheirismo.
          </div>
        </CardContent>
        <CardFooter className="pt-2">
          <Button asChild variant="outline" size="sm" className="min-h-[44px] w-full justify-center gap-1.5 text-xs font-medium">
            <Link to="/ensinos">
              Explorar Trilhas de Estudo
              <ArrowRight className="h-3 w-3" />
            </Link>
          </Button>
        </CardFooter>
      </Card>
    )
  }

  const disciplerCleanPhone = discipler?.phone?.replace(/\D/g, "")

  return (
    <>
      <Card className="rounded-xl border-border/80 bg-card/70 shadow-xs backdrop-blur-xs transition-colors hover:border-primary/30">
        <CardHeader className="space-y-1 pb-2">
          <div className="flex items-start justify-between gap-2">
            <div className="space-y-0.5">
              <CardTitle className="flex items-center gap-2 text-sm font-bold text-foreground">
                <Heart className="h-4 w-4 text-amber-600 dark:text-amber-400 shrink-0" />
                <span>Juntas &amp; Ligamentos</span>
              </CardTitle>
              <CardDescription className="text-xs font-medium text-amber-700 dark:text-amber-300">
                Discipulado e cuidado 1-a-1
              </CardDescription>
            </div>
            <Badge
              variant="outline"
              className="shrink-0 gap-1 rounded-full border-amber-600/30 bg-amber-500/10 px-2 py-0.5 text-[10px] font-semibold text-amber-700 dark:text-amber-300"
            >
              Efésios 4:16
            </Badge>
          </div>
        </CardHeader>

        <CardContent className="space-y-3 py-2 text-xs">
          {/* Meu Discipulador */}
          <div className="space-y-1.5">
            <span className="text-[10px] font-semibold uppercase tracking-wider text-muted-foreground">
              Meu Discipulador
            </span>
            {discipler ? (
              <div className="flex items-center justify-between rounded-lg border border-border/50 bg-background/50 p-2.5">
                <div className="flex items-center gap-2.5 min-w-0">
                  <Avatar className="h-8 w-8 border border-border/60 shrink-0">
                    <AvatarImage src={discipler.avatar_url || undefined} alt={discipler.full_name} />
                    <AvatarFallback className="text-xs bg-amber-500/10 text-amber-700 dark:text-amber-300">
                      {discipler.full_name
                        .split(" ")
                        .map((n) => n[0])
                        .slice(0, 2)
                        .join("")}
                    </AvatarFallback>
                  </Avatar>
                  <div className="min-w-0">
                    <span className="block truncate text-xs font-semibold text-foreground">
                      {discipler.full_name}
                    </span>
                    <span className="text-[10px] text-muted-foreground">
                      Cuidado &amp; Acompanhamento
                    </span>
                  </div>
                </div>

                {disciplerCleanPhone && (
                  <div className="flex items-center gap-0.5 shrink-0">
                    <Button asChild variant="ghost" size="icon" className="h-8 w-8 rounded-full" title="WhatsApp">
                      <a
                        href={`https://wa.me/55${disciplerCleanPhone}`}
                        target="_blank"
                        rel="noopener noreferrer"
                        aria-label={`WhatsApp com ${discipler.full_name}`}
                      >
                        <MessageCircle className="h-3.5 w-3.5 text-emerald-600 dark:text-emerald-400" />
                      </a>
                    </Button>
                    <Button asChild variant="ghost" size="icon" className="h-8 w-8 rounded-full" title="Ligar">
                      <a href={`tel:${disciplerCleanPhone}`} aria-label={`Ligar para ${discipler.full_name}`}>
                        <Phone className="h-3.5 w-3.5 text-primary" />
                      </a>
                    </Button>
                  </div>
                )}
              </div>
            ) : (
              <div className="rounded-lg border border-dashed border-border/70 p-2.5 text-[11px] text-muted-foreground">
                Discipulador em processo de alinhamento no Grupo Caseiro.
              </div>
            )}
          </div>

          {/* Discípulos que eu acompanho */}
          <div className="space-y-1.5 border-t border-border/30 pt-2">
            <div className="flex items-center justify-between text-[11px]">
              <span className="font-semibold text-muted-foreground">
                Discípulos sob meu cuidado ({disciples.length})
              </span>
              {disciples.length > 0 && (
                <button
                  type="button"
                  onClick={() => setIsDisciplesModalOpen(true)}
                  className="font-medium text-primary hover:underline cursor-pointer"
                >
                  Ver todos
                </button>
              )}
            </div>

            {disciples.length > 0 ? (
              <div className="flex items-center gap-2">
                <div className="flex -space-x-1.5 overflow-hidden">
                  {disciples.slice(0, 4).map((d) => (
                    <Avatar
                      key={d.id}
                      className="h-6 w-6 border-2 border-background ring-1 ring-border/50"
                      title={d.full_name}
                    >
                      <AvatarImage src={d.avatar_url || undefined} alt={d.full_name} />
                      <AvatarFallback className="text-[9px] bg-primary/10 text-primary">
                        {d.full_name
                          .split(" ")
                          .map((n) => n[0])
                          .slice(0, 2)
                          .join("")}
                      </AvatarFallback>
                    </Avatar>
                  ))}
                </div>
                <span className="text-[11px] text-muted-foreground font-medium truncate">
                  {disciples.map((d) => d.full_name.split(" ")[0]).slice(0, 2).join(", ")}
                  {disciples.length > 2 && ` e +${disciples.length - 2}`}
                </span>
              </div>
            ) : (
              <p className="text-[11px] text-muted-foreground">
                Nenhum discípulo sob cuidado direto no momento.
              </p>
            )}
          </div>

          {/* Companheiros de Caminhada */}
          {fellows.length > 0 && (
            <div className="space-y-1.5 border-t border-border/30 pt-2">
              <span className="text-[10px] font-semibold uppercase tracking-wider text-muted-foreground">
                Companheiros de Obra ({fellows.length})
              </span>
              <div className="flex items-center gap-2">
                <div className="flex -space-x-1.5 overflow-hidden">
                  {fellows.slice(0, 3).map((f) => (
                    <Avatar
                      key={f.id}
                      className="h-6 w-6 border-2 border-background ring-1 ring-border/50"
                      title={f.full_name}
                    >
                      <AvatarImage src={f.avatar_url || undefined} alt={f.full_name} />
                      <AvatarFallback className="text-[9px] bg-secondary text-secondary-foreground">
                        {f.full_name
                          .split(" ")
                          .map((n) => n[0])
                          .slice(0, 2)
                          .join("")}
                      </AvatarFallback>
                    </Avatar>
                  ))}
                </div>
                <span className="text-[11px] text-muted-foreground font-medium truncate">
                  {fellows.map((f) => f.full_name.split(" ")[0]).slice(0, 2).join(", ")}
                </span>
              </div>
            </div>
          )}
        </CardContent>

        <CardFooter className="pt-2">
          <Button
            asChild
            variant="outline"
            size="sm"
            className="btn-tactile min-h-[44px] w-full justify-center gap-1.5 text-xs font-medium"
          >
            <Link to="/perfil">
              <UserCheck className="h-3.5 w-3.5 text-primary" />
              Ver Minhas Juntas &amp; Vínculos
              <ArrowRight className="h-3 w-3" />
            </Link>
          </Button>
        </CardFooter>
      </Card>

      {/* Modal de Detalhes dos Discípulos */}
      <Dialog open={isDisciplesModalOpen} onOpenChange={setIsDisciplesModalOpen}>
        <DialogContent className="max-w-md rounded-xl">
          <DialogHeader>
            <DialogTitle className="flex items-center gap-2 text-base font-bold">
              <Users className="h-5 w-5 text-primary" />
              Discípulos Acompanhados
            </DialogTitle>
            <DialogDescription className="text-xs">
              Irmãos que você cuida e acompanha no discipulado pessoal
            </DialogDescription>
          </DialogHeader>

          <div className="max-h-[340px] space-y-2 overflow-y-auto pr-1">
            {disciples.map((disciple) => {
              const cleanPhone = disciple.phone?.replace(/\D/g, "")
              return (
                <div
                  key={disciple.id}
                  className="flex items-center justify-between rounded-lg border border-border/40 p-2.5 transition-colors hover:bg-muted/30"
                >
                  <div className="flex items-center gap-2.5 min-w-0">
                    <Avatar className="h-8 w-8 border border-border/60 shrink-0">
                      <AvatarImage src={disciple.avatar_url || undefined} alt={disciple.full_name} />
                      <AvatarFallback className="text-xs bg-primary/10 text-primary">
                        {disciple.full_name
                          .split(" ")
                          .map((n) => n[0])
                          .slice(0, 2)
                          .join("")}
                      </AvatarFallback>
                    </Avatar>
                    <span className="truncate text-xs font-semibold text-foreground">
                      {disciple.full_name}
                    </span>
                  </div>

                  {cleanPhone && (
                    <div className="flex items-center gap-1 shrink-0">
                      <Button asChild variant="ghost" size="icon" className="h-8 w-8 rounded-full" title="WhatsApp">
                        <a
                          href={`https://wa.me/55${cleanPhone}`}
                          target="_blank"
                          rel="noopener noreferrer"
                          aria-label={`WhatsApp com ${disciple.full_name}`}
                        >
                          <MessageCircle className="h-4 w-4 text-emerald-600 dark:text-emerald-400" />
                        </a>
                      </Button>
                      <Button asChild variant="ghost" size="icon" className="h-8 w-8 rounded-full" title="Ligar">
                        <a href={`tel:${cleanPhone}`} aria-label={`Ligar para ${disciple.full_name}`}>
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
