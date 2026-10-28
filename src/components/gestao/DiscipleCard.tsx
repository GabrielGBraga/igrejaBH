import { Phone, Edit, MessageSquare, Shield, Baby, BookOpen, UserCheck, MapPin, AlertCircle, HeartHandshake, Cake } from "lucide-react"
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import type { Database } from "@/lib/database.types"
import { THEME_CLASSES } from "@/constants/colors"

type Profile = Database["public"]["Tables"]["profiles"]["Row"]

export interface DiscipleCardProps {
  disciple: Profile
  isLeader?: boolean
  disciplerName?: string | null
  spouseName?: string | null
  fatherName?: string | null
  motherName?: string | null
  fellowshipNames?: string[]
  groupName?: string | null
  isCoveredRoot?: boolean
  onEdit: (disciple: Profile) => void
  onTransformChild?: (disciple: Profile) => void
  onTransformToLinked?: (disciple: Profile) => void
}

const isBirthdayThisMonth = (birthDateStr?: string | null) => {
  if (!birthDateStr) return false
  const parts = birthDateStr.split("-")
  if (parts.length < 3) return false
  const birthMonth = parseInt(parts[1], 10)
  const currentMonth = new Date().getMonth() + 1
  return birthMonth === currentMonth
}

const formatBirthdayShort = (birthDateStr?: string | null) => {
  if (!birthDateStr) return null
  const parts = birthDateStr.split("-")
  if (parts.length < 3) return null
  return `${parts[2]}/${parts[1]}`
}

export function DiscipleCard({
  disciple,
  isLeader = false,
  disciplerName,
  spouseName,
  fatherName,
  motherName,
  fellowshipNames = [],
  groupName,
  isCoveredRoot = false,
  onEdit,
  onTransformChild,
  onTransformToLinked,
}: DiscipleCardProps) {
  const isChild = !!(disciple.father_id || disciple.mother_id) && !disciple.baptism_date
  const cleanPhone = disciple.phone?.replace(/\D/g, "")
  const hasPhone = !!cleanPhone && cleanPhone.length >= 10
  const whatsappUrl = hasPhone
    ? `https://wa.me/55${cleanPhone}`
    : null

  const isBdayMonth = isBirthdayThisMonth(disciple.birth_date)
  const bdayDayMonth = formatBirthdayShort(disciple.birth_date)

  const getInitials = (name: string) => {
    return name
      .split(" ")
      .filter(Boolean)
      .slice(0, 2)
      .map((n) => n[0])
      .join("")
      .toUpperCase()
  }

  // Identifica se necessita de discipulador (adultos que não têm discipulador e não são presbíteros/cobertura)
  const needsDiscipler = !isChild && !disciplerName && !disciple.is_presbyter && !isCoveredRoot

  return (
    <div className="flex flex-col justify-between rounded-2xl border border-border/80 bg-card p-4 shadow-xs transition-all hover:border-primary/40 hover:shadow-md sm:p-5">
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
                  className={`${THEME_CLASSES.badgeSuccess} text-[11px] font-medium`}
                >
                  <Shield className="mr-1 h-3 w-3" />
                  Líder de GC
                </Badge>
              )}
              {disciple.is_presbyter && (
                <Badge
                  variant="outline"
                  className={`${THEME_CLASSES.badgePrimary} text-[11px] font-medium`}
                >
                  Presbítero
                </Badge>
              )}
              {disciple.is_deacon && (
                <Badge
                  variant="outline"
                  className={`${THEME_CLASSES.badgeWarning} text-[11px] font-medium`}
                >
                  Diácono
                </Badge>
              )}
              {isChild && (
                <Badge
                  variant="outline"
                  className={`${THEME_CLASSES.badgeInfo} text-[11px] font-medium`}
                >
                  <Baby className="mr-1 h-3 w-3" />
                  Criança
                </Badge>
              )}
              {!disciple.is_church_linked && (
                <Badge
                  variant="outline"
                  className={`${THEME_CLASSES.badgePriority} text-[11px] font-medium`}
                >
                  Visitante nos Estudos
                </Badge>
              )}
              {isBdayMonth && bdayDayMonth && (
                <Badge
                  variant="outline"
                  className="border-amber-500/40 bg-amber-500/10 text-amber-700 dark:text-amber-300 text-[11px] font-medium inline-flex items-center gap-1"
                >
                  <Cake className="h-3 w-3 shrink-0" />
                  Aniversário: {bdayDayMonth}
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

            {groupName && (
              <div className="mt-2 flex items-center gap-1.5 text-xs text-muted-foreground">
                <MapPin className="h-3.5 w-3.5 shrink-0 text-primary" />
                <span className="truncate font-medium text-foreground/90">{groupName}</span>
              </div>
            )}
          </div>
        </div>

        {/* Bloco de Acompanhamento (Linguagem Clara e Humana) */}
        {!disciple.is_church_linked ? (
          <div className="mt-3.5 space-y-1.5 rounded-xl bg-muted/50 border border-border/80 p-3 text-xs">
            <div className="flex items-center gap-1.5 font-medium text-foreground">
              <BookOpen className="h-3.5 w-3.5 text-primary" />
              <span>Irmão em Acolhimento nos Estudos</span>
            </div>
            <p className="text-[11px] leading-relaxed text-muted-foreground">
              Participando das reuniões bíblicas nos lares antes do vínculo pleno com a igreja local.
            </p>
          </div>
        ) : (
          <div className="mt-3.5 space-y-2 rounded-xl bg-muted/40 p-3 text-xs text-muted-foreground border border-border/50">
            <div className="flex items-center gap-1.5 font-semibold text-foreground/90">
              <HeartHandshake className="h-3.5 w-3.5 text-primary" />
              <span>Acompanhamento e Família</span>
            </div>

            {!isChild ? (
              <>
                {/* Discipulador */}
                <div className="flex items-start justify-between gap-2 border-t border-border/40 pt-1.5">
                  <span className="shrink-0 text-muted-foreground">Discipulador(a):</span>
                  <span className="font-medium text-right text-foreground">
                    {disciplerName ? (
                      disciplerName
                    ) : disciple.is_presbyter || isCoveredRoot ? (
                      <span className="text-primary font-medium">
                        Cuidado Mútuo
                      </span>
                    ) : (
                      <span className="inline-flex items-center gap-1 font-semibold text-amber-700 dark:text-amber-400">
                        <AlertCircle className="h-3 w-3 shrink-0" />
                        Precisa de discipulador
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

                {/* Companheiros de Oração e Serviço */}
                {fellowshipNames.length > 0 && (
                  <div className="border-t border-border/40 pt-1.5">
                    <span className="text-muted-foreground">Companheiro(s) de oração/serviço:</span>
                    <div className="mt-1 flex flex-wrap gap-1">
                      {fellowshipNames.map((name, idx) => (
                        <span
                          key={idx}
                          className="rounded-md bg-background px-2 py-0.5 text-[11px] font-medium text-foreground border border-border/60"
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
                {/* Para Crianças: Pais */}
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
        )}

        {/* Alerta de Cuidado para quem não tem discipulador */}
        {needsDiscipler && (
          <div className="mt-2.5 flex items-center gap-1.5 rounded-lg bg-amber-500/10 px-2.5 py-1.5 text-[11px] font-medium text-amber-800 dark:text-amber-300 border border-amber-500/20">
            <AlertCircle className="h-3.5 w-3.5 shrink-0 text-amber-600 dark:text-amber-400" />
            <span>Defina um discipulador para acompanhar e orar com este irmão.</span>
          </div>
        )}

        {/* Ação para Crianças: Registrar Batismo */}
        {isChild && onTransformChild && (
          <Button
            type="button"
            variant="outline"
            onClick={() => onTransformChild(disciple)}
            className="mt-2.5 h-11 min-h-[44px] w-full rounded-xl text-xs font-semibold shadow-2xs"
          >
            <span>Registrar Batismo</span>
          </Button>
        )}
      </div>

      {/* Ações Imediatas: WhatsApp e Editar / Integrar (Touch targets >= 44px) */}
      <div className="mt-4 flex items-center gap-2 border-t border-border/60 pt-3">
        {whatsappUrl ? (
          <Button
            asChild
            variant="outline"
            className="h-11 min-h-[44px] flex-1 gap-1.5 rounded-xl text-xs font-semibold border-emerald-600/30 bg-emerald-50 text-emerald-800 hover:bg-emerald-100 dark:border-emerald-500/30 dark:bg-emerald-950/30 dark:text-emerald-300 dark:hover:bg-emerald-950/50"
          >
            <a href={whatsappUrl} target="_blank" rel="noopener noreferrer">
              <MessageSquare className="h-4 w-4 text-emerald-600 dark:text-emerald-400 shrink-0" />
              <span className="truncate">WhatsApp</span>
            </a>
          </Button>
        ) : (
          <Button
            variant="outline"
            disabled
            className="h-11 min-h-[44px] flex-1 gap-1.5 rounded-xl text-xs opacity-50 cursor-not-allowed"
          >
            <Phone className="h-4 w-4 shrink-0 text-muted-foreground" />
            <span className="truncate">Sem WhatsApp</span>
          </Button>
        )}

        {disciple.is_church_linked !== false ? (
          <Button
            onClick={() => onEdit(disciple)}
            variant="secondary"
            className="h-11 min-h-[44px] flex-1 gap-1.5 rounded-xl text-xs font-semibold cursor-pointer shadow-2xs"
          >
            <Edit className="h-4 w-4 shrink-0" />
            <span className="truncate">Editar</span>
          </Button>
        ) : (
          <Button
            onClick={() => (onTransformToLinked ? onTransformToLinked(disciple) : onEdit(disciple))}
            className="h-11 min-h-[44px] flex-1 gap-1.5 rounded-xl text-xs font-semibold cursor-pointer shadow-xs"
          >
            <UserCheck className="h-4 w-4 shrink-0" />
            <span className="truncate">Integrar</span>
          </Button>
        )}
      </div>
    </div>
  )
}
