import { useState, useMemo } from "react"
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select"
import { Badge } from "@/components/ui/badge"
import {
  Link2,
  Copy,
  Check,
  MessageSquare,
  Users,
  MapPin,
  Calendar,
} from "lucide-react"
import { toast } from "sonner"
import type { Database } from "@/lib/database.types"

type HomeGroup = Database["public"]["Tables"]["home_groups"]["Row"]
type Sector = Database["public"]["Tables"]["sectors"]["Row"]
type Profile = Database["public"]["Tables"]["profiles"]["Row"]

export interface RestrictedGroupLinkDialogProps {
  open: boolean
  onOpenChange: (open: boolean) => void
  homeGroups: HomeGroup[]
  allProfiles: Profile[]
  sectors: Sector[]
  initialGroupId?: string | null
}

const DAYS_OF_WEEK = [
  "Domingo",
  "Segunda-feira",
  "Terça-feira",
  "Quarta-feira",
  "Quinta-feira",
  "Sexta-feira",
  "Sábado",
]

export function RestrictedGroupLinkDialog({
  open,
  onOpenChange,
  homeGroups,
  allProfiles,
  sectors,
  initialGroupId,
}: RestrictedGroupLinkDialogProps) {
  const [userSelectedGroupId, setUserSelectedGroupId] = useState<string | null>(null)
  const [copied, setCopied] = useState<boolean>(false)

  // Mapas auxiliares
  const profileMap = useMemo(() => {
    const map = new Map<string, Profile>()
    allProfiles.forEach((p) => map.set(p.id, p))
    return map
  }, [allProfiles])

  const sectorMap = useMemo(() => {
    const map = new Map<string, Sector>()
    sectors.forEach((s) => map.set(s.id, s))
    return map
  }, [sectors])

  // Grupo ativo derivado das props ou da seleção do usuário
  const activeGroupId = useMemo(() => {
    if (userSelectedGroupId && homeGroups.some((g) => g.id === userSelectedGroupId)) {
      return userSelectedGroupId
    }
    if (initialGroupId && homeGroups.some((g) => g.id === initialGroupId)) {
      return initialGroupId
    }
    return homeGroups[0]?.id || ""
  }, [userSelectedGroupId, initialGroupId, homeGroups])

  const currentGroup = useMemo(() => {
    return homeGroups.find((g) => g.id === activeGroupId) || null
  }, [homeGroups, activeGroupId])

  // Identificação do líder e contatos
  const leader1 = currentGroup?.leader_1_id ? profileMap.get(currentGroup.leader_1_id) : null
  const leader2 = currentGroup?.leader_2_id ? profileMap.get(currentGroup.leader_2_id) : null

  const leadersName = [leader1?.full_name, leader2?.full_name].filter(Boolean).join(" & ") || "Liderança a definir"

  // Telefone para envio no WhatsApp (prioriza líder 1, senão líder 2)
  const targetLeaderForWa = leader1?.phone ? leader1 : leader2?.phone ? leader2 : null
  const cleanPhone = targetLeaderForWa?.phone?.replace(/\D/g, "") || ""

  // Construção do Link Direto
  const origin = typeof window !== "undefined" ? window.location.origin : ""
  const directLink = currentGroup
    ? `${origin}/meu-grupo?grupo=${encodeURIComponent(currentGroup.id)}`
    : ""

  const handleCopy = async () => {
    if (!directLink) return
    try {
      await navigator.clipboard.writeText(directLink)
      setCopied(true)
      toast.success("Link exclusivo copiado com sucesso!")
      setTimeout(() => setCopied(false), 2500)
    } catch (e) {
      console.error("Erro ao copiar link:", e)
      toast.error("Não foi possível copiar o link.")
    }
  }

  // Mensagem e URL do WhatsApp
  const groupLabel = currentGroup?.location_text || `Grupo Caseiro (${currentGroup?.id.slice(0, 5)})`
  const leaderFirstName = targetLeaderForWa?.full_name?.split(" ")[0] || "Irmão(ã)"

  const whatsappMessage = `Olá ${leaderFirstName}! Segue o link de acesso exclusivo para a gestão do seu Grupo Caseiro (${groupLabel}):\n\n${directLink}\n\nAo abrir o link, basta entrar com sua conta para gerenciar os irmãos, contatos e informações do grupo.`
  const whatsappUrl = cleanPhone
    ? `https://wa.me/55${cleanPhone}?text=${encodeURIComponent(whatsappMessage)}`
    : null

  const sector = currentGroup?.sector_id ? sectorMap.get(currentGroup.sector_id) : null

  return (
    <Dialog
      open={open}
      onOpenChange={(nextOpen) => {
        if (!nextOpen) {
          setUserSelectedGroupId(null)
          setCopied(false)
        }
        onOpenChange(nextOpen)
      }}
    >
      <DialogContent className="flex flex-col max-h-[85vh] sm:max-h-[88vh] w-[calc(100vw-2rem)] sm:max-w-lg md:max-w-xl p-0 overflow-hidden rounded-2xl gap-0 shadow-2xl border border-border/70">
        <DialogHeader className="px-5 py-4 sm:px-6 border-b border-border/60 shrink-0 bg-background/95 backdrop-blur-xs">
          <div className="flex items-center gap-2">
            <Badge
              variant="outline"
              className="border-primary/30 bg-primary/10 text-primary text-[11px] font-semibold"
            >
              Exclusivo Desenvolvedor
            </Badge>
          </div>
          <DialogTitle className="text-xl sm:text-2xl font-bold tracking-tight text-foreground mt-1">
            Gerar Link de Acesso Restrito
          </DialogTitle>
          <DialogDescription className="text-xs sm:text-sm text-muted-foreground mt-0.5">
            Crie um link especial que permite ao líder gerenciar exclusivamente o seu Grupo Caseiro, sem acesso ao restante do portal.
          </DialogDescription>
        </DialogHeader>

        <div className="flex-1 min-h-0 overflow-y-auto overflow-x-hidden px-4 py-4 sm:px-6 space-y-4 min-w-0">
          {/* 1. Seletor de Grupo Caseiro */}
          <div className="space-y-1.5 min-w-0">
            <Label className="text-xs font-semibold text-foreground uppercase tracking-wider">
              Selecione o Grupo Caseiro:
            </Label>
            <Select
              value={activeGroupId}
              onValueChange={(val) => {
                setUserSelectedGroupId(val)
                setCopied(false)
              }}
            >
              <SelectTrigger className="w-full min-w-0 max-w-full h-11 min-h-[44px] rounded-xl text-xs sm:text-sm overflow-hidden text-left [&>span]:truncate [&>span]:block [&>span]:min-w-0">
                <SelectValue placeholder="Selecione um grupo">
                  {currentGroup ? (
                    <span className="truncate block max-w-[calc(100vw-9rem)] sm:max-w-[360px] text-foreground">
                      {currentGroup.location_text || `Grupo (${currentGroup.id.slice(0, 5)})`}
                      {leadersName !== "Liderança a definir" ? ` — ${leadersName}` : ""}
                    </span>
                  ) : (
                    "Selecione um grupo"
                  )}
                </SelectValue>
              </SelectTrigger>
              <SelectContent className="max-h-64 max-w-[calc(100vw-3rem)] sm:max-w-lg">
                {homeGroups.map((hg) => {
                  const l1 = hg.leader_1_id ? profileMap.get(hg.leader_1_id)?.full_name : null
                  const l2 = hg.leader_2_id ? profileMap.get(hg.leader_2_id)?.full_name : null
                  const leaders = [l1, l2].filter(Boolean).join(" & ")
                  return (
                    <SelectItem key={hg.id} value={hg.id} className="text-xs">
                      <span className="truncate block max-w-full">
                        {hg.location_text || `Grupo (${hg.id.slice(0, 5)})`}
                        {leaders ? ` — ${leaders}` : ""}
                      </span>
                    </SelectItem>
                  )
                })}
              </SelectContent>
            </Select>
          </div>

          {/* 2. Card de Resumo do Grupo Selecionado */}
          {currentGroup && (
            <div className="rounded-xl border border-border/80 bg-muted/30 p-3.5 sm:p-4 space-y-2.5 min-w-0">
              <div className="flex items-center justify-between gap-2 min-w-0">
                <span className="font-semibold text-foreground text-sm truncate flex-1 min-w-0">
                  {currentGroup.location_text || "Grupo Caseiro"}
                </span>
                {sector && (
                  <Badge variant="outline" className="text-[11px] border-primary/30 text-primary shrink-0">
                    {sector.name}
                  </Badge>
                )}
              </div>

              <div className="space-y-1.5 text-xs text-muted-foreground min-w-0">
                <div className="flex items-center gap-2 min-w-0">
                  <Users className="h-3.5 w-3.5 text-primary shrink-0" />
                  <span className="truncate flex-1 min-w-0">
                    Líder(es): <strong className="text-foreground font-medium">{leadersName}</strong>
                  </span>
                </div>

                <div className="flex items-center gap-2 min-w-0">
                  <Calendar className="h-3.5 w-3.5 text-primary shrink-0" />
                  <span className="truncate">
                    {currentGroup.meeting_day !== null && currentGroup.meeting_day !== undefined
                      ? DAYS_OF_WEEK[currentGroup.meeting_day]
                      : "Dia a definir"}{" "}
                    {currentGroup.start_time ? `às ${currentGroup.start_time.slice(0, 5)}` : ""}
                  </span>
                </div>

                <div className="flex items-start gap-2 min-w-0">
                  <MapPin className="h-3.5 w-3.5 text-muted-foreground shrink-0 mt-0.5" />
                  <span className="line-clamp-2 break-words flex-1 min-w-0">
                    {currentGroup.location_text || "Endereço não cadastrado"}
                  </span>
                </div>
              </div>
            </div>
          )}

          {/* 3. Campo com o Link Gerado e Ação de Copiar */}
          <div className="space-y-2 min-w-0">
            <Label className="text-xs font-semibold text-foreground">
              Link de Acesso Exclusivo:
            </Label>
            <div className="flex flex-col gap-2 sm:flex-row min-w-0">
              <div className="relative flex-1 min-w-0">
                <Link2 className="absolute left-3.5 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground shrink-0" />
                <Input
                  readOnly
                  value={directLink}
                  className="h-11 min-h-[44px] w-full min-w-0 rounded-xl pl-10 pr-3 text-xs sm:text-sm font-mono bg-background select-all truncate"
                  onClick={(e) => (e.target as HTMLInputElement).select()}
                />
              </div>
              <Button
                type="button"
                onClick={handleCopy}
                disabled={!directLink}
                className="h-11 min-h-[44px] gap-2 rounded-xl text-xs font-semibold shrink-0 px-4"
              >
                {copied ? <Check className="h-4 w-4 text-primary" /> : <Copy className="h-4 w-4" />}
                <span>{copied ? "Copiado!" : "Copiar Link"}</span>
              </Button>
            </div>
          </div>

          {/* 4. Compartilhar via WhatsApp com o Líder */}
          <div className="rounded-xl border border-border/80 bg-card p-3.5 space-y-2 min-w-0">
            <div className="flex items-center justify-between gap-2 min-w-0">
              <span className="text-xs font-semibold text-foreground truncate">Enviar direto para o Líder:</span>
              {targetLeaderForWa?.phone ? (
                <span className="text-[11px] text-muted-foreground shrink-0">{targetLeaderForWa.phone}</span>
              ) : (
                <span className="text-[11px] text-muted-foreground shrink-0 italic">Sem telefone cadastrado</span>
              )}
            </div>

            {whatsappUrl ? (
              <Button
                asChild
                className="h-11 min-h-[44px] w-full gap-2 rounded-xl font-semibold text-xs shadow-xs"
              >
                <a href={whatsappUrl} target="_blank" rel="noopener noreferrer">
                  <MessageSquare className="h-4 w-4 shrink-0" />
                  <span className="truncate">Enviar Convite via WhatsApp</span>
                </a>
              </Button>
            ) : (
              <p className="text-[11px] text-muted-foreground">
                Cadastre o celular do líder para habilitar o envio direto via WhatsApp. Você ainda pode copiar o link acima e enviar manualmente.
              </p>
            )}
          </div>
        </div>

        {/* Rodapé Fixo */}
        <div className="px-4 py-3 sm:px-6 border-t border-border/60 shrink-0 bg-muted/20 flex justify-end">
          <Button
            type="button"
            variant="outline"
            onClick={() => onOpenChange(false)}
            className="h-11 min-h-[44px] rounded-xl text-xs px-5 font-medium"
          >
            Fechar
          </Button>
        </div>
      </DialogContent>
    </Dialog>
  )
}
