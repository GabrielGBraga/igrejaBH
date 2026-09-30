import { useState } from "react"
import { Link } from "react-router-dom"
import { Heart, ArrowRight, Sparkles, MessageCircle, Users, Phone } from "lucide-react"
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

interface DiscipleshipCardProps {
  discipler: ProfileSummary | null
  disciples: ProfileSummary[]
  fellows: ProfileSummary[]
  loading?: boolean
}

export function DiscipleshipCard({
  discipler,
  disciples,
  fellows,
  loading = false,
}: DiscipleshipCardProps) {
  const [isDisciplesModalOpen, setIsDisciplesModalOpen] = useState(false)

  if (loading) {
    return (
      <Card className="rounded-xl border-border bg-card/60 shadow-xs">
        <CardHeader className="space-y-2 pb-3">
          <div className="h-5 w-40 animate-pulse rounded bg-muted" />
          <div className="h-4 w-56 animate-pulse rounded bg-muted" />
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="h-14 w-full animate-pulse rounded-lg bg-muted" />
          <div className="h-14 w-full animate-pulse rounded-lg bg-muted" />
        </CardContent>
      </Card>
    )
  }

  const hasAnyRelationship = !!discipler || disciples.length > 0 || fellows.length > 0

  const getWhatsAppUrl = (phone?: string | null) => {
    if (!phone) return null
    const cleanPhone = phone.replace(/\D/g, "")
    return `https://wa.me/55${cleanPhone}`
  }

  return (
    <>
      <Card className="flex flex-col justify-between rounded-xl border-border/80 bg-card/70 shadow-xs backdrop-blur-xs transition-colors hover:border-primary/30">
        <CardHeader className="space-y-1.5 pb-3">
          <div className="flex items-start justify-between gap-2">
            <div className="space-y-1">
              <CardTitle className="flex items-center gap-2 text-base font-bold sm:text-lg">
                <Heart className="h-5 w-5 text-amber-600 dark:text-amber-400 shrink-0" />
                <span>Juntas e Ligamentos</span>
              </CardTitle>
              <CardDescription className="text-xs font-medium text-amber-600 dark:text-amber-400">
                Discipulado e edificação mútua no Corpo
              </CardDescription>
            </div>
            <Badge
              variant="outline"
              className="shrink-0 gap-1 rounded-full border-amber-600/30 dark:border-amber-400/30 bg-amber-500/10 px-2.5 py-1 text-[11px] font-semibold text-amber-700 dark:text-amber-300"
            >
              <Sparkles className="h-3 w-3" />
              Efésios 4:16
            </Badge>
          </div>
        </CardHeader>

        <CardContent className="space-y-3.5 py-2">
          {!hasAnyRelationship ? (
            <div className="rounded-lg border border-border/60 bg-muted/30 p-3.5 text-xs text-muted-foreground">
              <p className="leading-relaxed">
                Nenhum discípulo caminha sozinho. Fale com os irmãos do seu Grupo Caseiro para iniciar um vínculo intencional de companheirismo e discipulado vida na vida!
              </p>
            </div>
          ) : (
            <div className="space-y-3">
              {/* 1. Meu Discipulador / Quem me acompanha */}
              {discipler && (
                <div className="flex items-center justify-between rounded-lg border border-border/60 bg-background/60 p-2.5">
                  <div className="flex items-center gap-3 min-w-0 pr-2">
                    <Avatar className="h-9 w-9 shrink-0 border border-primary/20">
                      <AvatarImage src={discipler.avatar_url || undefined} alt={discipler.full_name} />
                      <AvatarFallback className="text-xs font-bold text-primary">
                        {discipler.full_name.substring(0, 2).toUpperCase()}
                      </AvatarFallback>
                    </Avatar>
                    <div className="min-w-0">
                      <span className="text-[10px] font-semibold uppercase tracking-wider text-muted-foreground block">
                        Discipulador(a)
                      </span>
                      <p className="text-sm font-semibold text-foreground truncate leading-tight">
                        {discipler.full_name}
                      </p>
                    </div>
                  </div>

                  {discipler.phone && (
                    <Button
                      asChild
                      variant="ghost"
                      size="icon"
                      className="min-h-[44px] min-w-[44px] shrink-0 text-muted-foreground hover:text-emerald-600 dark:hover:text-emerald-400"
                      title={`Conversar com ${discipler.full_name}`}
                      aria-label={`Conversar com ${discipler.full_name}`}
                    >
                      <a
                        href={getWhatsAppUrl(discipler.phone) || "#"}
                        target="_blank"
                        rel="noopener noreferrer"
                      >
                        <MessageCircle className="h-4 w-4" />
                      </a>
                    </Button>
                  )}
                </div>
              )}

              {/* 2. Juntas de Companheirismo Mútuo */}
              {fellows.length > 0 && (
                <div className="space-y-1.5 pt-0.5">
                  <div className="flex items-center justify-between text-xs">
                    <span className="text-[11px] font-semibold uppercase tracking-wide text-muted-foreground">
                      Companheiros de Caminhada ({fellows.length})
                    </span>
                  </div>

                  <div className="grid grid-cols-1 gap-2 sm:grid-cols-2">
                    {fellows.map((fellow) => (
                      <div
                        key={fellow.id}
                        className="flex items-center justify-between gap-2 rounded-lg border border-border/50 bg-background/50 p-2"
                      >
                        <div className="flex items-center gap-2 min-w-0">
                          <Avatar className="h-7 w-7 shrink-0 border border-border">
                            <AvatarImage src={fellow.avatar_url || undefined} alt={fellow.full_name} />
                            <AvatarFallback className="text-[10px] font-bold">
                              {fellow.full_name.substring(0, 2).toUpperCase()}
                            </AvatarFallback>
                          </Avatar>
                          <span className="text-xs font-medium text-foreground truncate" title={fellow.full_name}>
                            {fellow.full_name.split(" ")[0]}
                          </span>
                        </div>

                        {fellow.phone && (
                          <Button
                            asChild
                            variant="ghost"
                            size="icon"
                            className="min-h-[44px] min-w-[44px] shrink-0 text-muted-foreground hover:text-emerald-600 dark:hover:text-emerald-400"
                            title={`Conversar com ${fellow.full_name}`}
                            aria-label={`Conversar com ${fellow.full_name}`}
                          >
                            <a
                              href={getWhatsAppUrl(fellow.phone) || "#"}
                              target="_blank"
                              rel="noopener noreferrer"
                            >
                              <MessageCircle className="h-3.5 w-3.5" />
                            </a>
                          </Button>
                        )}
                      </div>
                    ))}
                  </div>
                </div>
              )}

              {/* 3. Discípulos que Acompanho (Irmãos que o usuário serve) */}
              {disciples.length > 0 && (
                <div className="space-y-1.5 pt-0.5">
                  <div className="flex items-center justify-between text-xs">
                    <span className="text-[11px] font-semibold uppercase tracking-wide text-muted-foreground">
                      A Quem Estou Servindo ({disciples.length})
                    </span>
                    {disciples.length > 2 && (
                      <button
                        type="button"
                        onClick={() => setIsDisciplesModalOpen(true)}
                        className="min-h-[32px] text-xs font-medium text-primary hover:underline"
                      >
                        Ver todos
                      </button>
                    )}
                  </div>

                  <div className="space-y-1.5">
                    {disciples.slice(0, 2).map((d) => (
                      <div
                        key={d.id}
                        className="flex items-center justify-between rounded-lg border border-border/40 bg-background/50 p-2"
                      >
                        <div className="flex items-center gap-2.5 min-w-0">
                          <Avatar className="h-7 w-7 shrink-0 border border-border">
                            <AvatarImage src={d.avatar_url || undefined} alt={d.full_name} />
                            <AvatarFallback className="text-[10px] font-bold">
                              {d.full_name.substring(0, 2).toUpperCase()}
                            </AvatarFallback>
                          </Avatar>
                          <span className="text-xs font-semibold text-foreground truncate" title={d.full_name}>
                            {d.full_name}
                          </span>
                        </div>

                        {d.phone && (
                          <Button
                            asChild
                            variant="ghost"
                            size="icon"
                            className="min-h-[44px] min-w-[44px] shrink-0 text-muted-foreground hover:text-emerald-600 dark:hover:text-emerald-400"
                            title={`Conversar com ${d.full_name}`}
                            aria-label={`Conversar com ${d.full_name}`}
                          >
                            <a
                              href={getWhatsAppUrl(d.phone) || "#"}
                              target="_blank"
                              rel="noopener noreferrer"
                            >
                              <MessageCircle className="h-3.5 w-3.5" />
                            </a>
                          </Button>
                        )}
                      </div>
                    ))}
                  </div>
                </div>
              )}
            </div>
          )}
        </CardContent>

        <CardFooter className="pt-3">
          <Button
            asChild
            variant="outline"
            size="sm"
            className="btn-tactile min-h-[44px] w-full justify-center gap-1.5 text-xs font-semibold"
          >
            <Link to="/perfil">
              Ver Rede Completa de Relacionamentos
              <ArrowRight className="h-3.5 w-3.5" />
            </Link>
          </Button>
        </CardFooter>
      </Card>

      {/* Modal de Lista de Discípulos Acompanhados */}
      <Dialog open={isDisciplesModalOpen} onOpenChange={setIsDisciplesModalOpen}>
        <DialogContent className="max-w-md p-6">
          <DialogHeader className="text-left space-y-1">
            <DialogTitle className="flex items-center gap-2 text-lg font-bold">
              <Users className="h-5 w-5 text-primary" />
              Irmãos que Você Acompanha
            </DialogTitle>
            <DialogDescription className="text-xs">
              {disciples.length} discípulos sob seu cuidado no discipulado vida na vida.
            </DialogDescription>
          </DialogHeader>

          <div className="max-h-[60vh] space-y-2.5 overflow-y-auto pr-1">
            {disciples.map((d) => (
              <div
                key={d.id}
                className="flex items-center justify-between rounded-lg border border-border/50 bg-background/50 p-2.5 transition-colors hover:bg-muted/30"
              >
                <div className="flex items-center gap-3 min-w-0 pr-2">
                  <Avatar className="h-9 w-9 shrink-0 border border-border">
                    <AvatarImage src={d.avatar_url || undefined} alt={d.full_name} />
                    <AvatarFallback className="text-xs font-bold">
                      {d.full_name.substring(0, 2).toUpperCase()}
                    </AvatarFallback>
                  </Avatar>
                  <div className="min-w-0">
                    <p className="text-sm font-semibold text-foreground truncate leading-tight">
                      {d.full_name}
                    </p>
                    {d.phone && (
                      <p className="text-xs text-muted-foreground flex items-center gap-1 mt-0.5">
                        <Phone className="h-3 w-3 text-primary/70 shrink-0" />
                        {d.phone}
                      </p>
                    )}
                  </div>
                </div>

                {d.phone && (
                  <Button
                    asChild
                    variant="ghost"
                    size="icon"
                    className="min-h-[44px] min-w-[44px] shrink-0 text-muted-foreground hover:text-emerald-600 dark:hover:text-emerald-400"
                    aria-label={`Conversar no WhatsApp com ${d.full_name}`}
                  >
                    <a
                      href={getWhatsAppUrl(d.phone) || "#"}
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
