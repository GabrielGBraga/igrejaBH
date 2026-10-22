import { Phone, Edit, MessageSquare, Shield, Baby, Users } from "lucide-react"
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import type { Database } from "@/lib/database.types"

type Profile = Database["public"]["Tables"]["profiles"]["Row"]

export interface DiscipleCardProps {
  disciple: Profile
  isLeader?: boolean
  disciplerName?: string | null
  spouseName?: string | null
  fatherName?: string | null
  motherName?: string | null
  fellowshipNames?: string[]
  onEdit: (disciple: Profile) => void
  onTransformChild?: (disciple: Profile) => void
}

export function DiscipleCard({
  disciple,
  isLeader = false,
  disciplerName,
  spouseName,
  fatherName,
  motherName,
  fellowshipNames = [],
  onEdit,
  onTransformChild,
}: DiscipleCardProps) {
  const isChild = !!(disciple.father_id || disciple.mother_id) && !disciple.baptism_date
  const cleanPhone = disciple.phone?.replace(/\D/g, "")
  const hasPhone = !!cleanPhone && cleanPhone.length >= 10
  const whatsappUrl = hasPhone
    ? `https://wa.me/55${cleanPhone}`
    : null

  const getInitials = (name: string) => {
    return name
      .split(" ")
      .filter(Boolean)
      .slice(0, 2)
      .map((n) => n[0])
      .join("")
      .toUpperCase()
  }

  return (
    <div className="flex flex-col justify-between rounded-xl border border-border/80 bg-card p-4 shadow-sm transition-all hover:border-primary/30 hover:shadow-md sm:p-5">
      <div>
        {/* Cabeçalho do Card: Avatar + Nome + Badges */}
        <div className="flex items-start gap-3.5">
          <Avatar className="h-12 w-12 shrink-0 border border-border shadow-inner">
            <AvatarImage
              src={disciple.avatar_url || undefined}
              alt={disciple.full_name}
            />
            <AvatarFallback className="font-semibold text-xs sm:text-sm bg-muted text-foreground">
              {getInitials(disciple.full_name)}
            </AvatarFallback>
          </Avatar>

          <div className="min-w-0 flex-1">
            <div className="flex flex-wrap items-center gap-1.5">
              <h3 className="truncate font-semibold text-foreground text-base tracking-tight">
                {disciple.full_name}
              </h3>
            </div>

            {/* Badges de Papel e Status */}
            <div className="mt-1 flex flex-wrap items-center gap-1.5">
              {isLeader && (
                <Badge
                  variant="outline"
                  className="border-emerald-500/30 bg-emerald-50 text-emerald-700 dark:bg-emerald-950/40 dark:text-emerald-300 text-[11px] font-medium"
                >
                  <Shield className="mr-1 h-3 w-3" />
                  Líder de GC
                </Badge>
              )}
              {disciple.is_presbyter && (
                <Badge
                  variant="outline"
                  className="border-primary/40 bg-primary/10 text-primary text-[11px] font-medium"
                >
                  Presbítero
                </Badge>
              )}
              {disciple.is_deacon && (
                <Badge
                  variant="outline"
                  className="border-amber-500/30 bg-amber-50 text-amber-700 dark:bg-amber-950/40 dark:text-amber-300 text-[11px] font-medium"
                >
                  Diácono
                </Badge>
              )}
              {isChild && (
                <Badge
                  variant="outline"
                  className="border-sky-500/30 bg-sky-50 text-sky-700 dark:bg-sky-950/40 dark:text-sky-300 text-[11px] font-medium"
                >
                  <Baby className="mr-1 h-3 w-3" />
                  Criança
                </Badge>
              )}
              {!disciple.is_church_linked && (
                <Badge
                  variant="outline"
                  className="border-purple-500/30 bg-purple-50 text-purple-700 dark:bg-purple-950/40 dark:text-purple-300 text-[11px] font-medium"
                >
                  Visitante nos Estudos
                </Badge>
              )}
              {disciple.marital_status && (
                <span className="text-[11px] text-muted-foreground capitalize">
                  {disciple.marital_status === "casado"
                    ? "Casado(a)"
                    : disciple.marital_status === "solteiro"
                    ? "Solteiro(a)"
                    : disciple.marital_status === "viuvo"
                    ? "Viúvo(a)"
                    : disciple.marital_status}
                </span>
              )}
            </div>
          </div>
        </div>

        {/* Bloco Juntas e Ligamentos (Vínculos de Cuidado) */}
        <div className="mt-3.5 space-y-2 rounded-lg bg-muted/40 p-3 text-xs text-muted-foreground">
          <div className="flex items-center gap-1.5 font-medium text-foreground/80">
            <Users className="h-3.5 w-3.5 text-primary" />
            <span>Juntas e Ligamentos</span>
          </div>

          {!isChild ? (
            <>
              {/* Discipulador */}
              <div className="flex items-start justify-between gap-2 border-t border-border/40 pt-1.5">
                <span className="shrink-0 text-muted-foreground">Discipulador(a):</span>
                <span className="font-medium text-right text-foreground">
                  {disciplerName ? (
                    disciplerName
                  ) : (
                    <span className="text-amber-600 dark:text-amber-400 font-normal italic">
                      Pendente definir
                    </span>
                  )}
                </span>
              </div>

              {/* Cônjuge */}
              {spouseName && (
                <div className="flex items-start justify-between gap-2 border-t border-border/40 pt-1.5">
                  <span className="shrink-0 text-muted-foreground">Cônjuge:</span>
                  <span className="font-medium text-right text-foreground">{spouseName}</span>
                </div>
              )}

              {/* Companheiros de Obra */}
              {fellowshipNames.length > 0 && (
                <div className="border-t border-border/40 pt-1.5">
                  <span className="text-muted-foreground">Companheiro(s) de obra:</span>
                  <div className="mt-1 flex flex-wrap gap-1">
                    {fellowshipNames.map((name, idx) => (
                      <span
                        key={idx}
                        className="rounded bg-background px-1.5 py-0.5 text-[11px] font-medium text-foreground border border-border/50"
                      >
                        {name}
                      </span>
                    ))}
                  </div>
                </div>
              )}
            </>
          ) : (
            <>
              {/* Vínculo de Criança: Pais */}
              <div className="flex items-start justify-between gap-2 border-t border-border/40 pt-1.5">
                <span className="shrink-0 text-muted-foreground">Pais / Responsáveis:</span>
                <span className="font-medium text-right text-foreground">
                  {[fatherName, motherName].filter(Boolean).join(" & ") || (
                    <span className="italic text-muted-foreground">Não informado</span>
                  )}
                </span>
              </div>
            </>
          )}
        </div>

        {/* Ação rápida para Crianças: Registrar Batismo */}
        {isChild && onTransformChild && (
          <Button
            type="button"
            variant="outline"
            onClick={() => onTransformChild(disciple)}
            className="mt-2.5 h-11 min-h-[44px] w-full rounded-lg border-sky-400/40 bg-sky-50/70 text-sky-800 hover:bg-sky-100 hover:text-sky-900 dark:border-sky-800 dark:bg-sky-950/40 dark:text-sky-200 dark:hover:bg-sky-900/60 text-xs font-semibold shadow-2xs"
          >
            <span>Registrar Batismo</span>
          </Button>
        )}
      </div>

      {/* Ações Diretas: WhatsApp e Editar (Touch targets >= 44px) */}
      <div className="mt-4 flex items-center gap-2 border-t border-border/60 pt-3">
        {whatsappUrl ? (
          <Button
            asChild
            variant="outline"
            className="h-11 min-h-[44px] flex-1 gap-1.5 rounded-lg border-emerald-500/30 text-emerald-700 hover:bg-emerald-50 hover:text-emerald-800 dark:text-emerald-400 dark:hover:bg-emerald-950/40 text-xs font-medium"
          >
            <a href={whatsappUrl} target="_blank" rel="noopener noreferrer">
              <MessageSquare className="h-4 w-4" />
              <span>WhatsApp</span>
            </a>
          </Button>
        ) : (
          <Button
            variant="outline"
            disabled
            className="h-11 min-h-[44px] flex-1 gap-1.5 rounded-lg text-xs opacity-50"
          >
            <Phone className="h-4 w-4" />
            <span>Sem Telefone</span>
          </Button>
        )}

        <Button
          onClick={() => onEdit(disciple)}
          className="h-11 min-h-[44px] flex-1 gap-1.5 rounded-lg text-xs font-medium"
        >
          <Edit className="h-4 w-4" />
          <span>Editar</span>
        </Button>
      </div>
    </div>
  )
}
