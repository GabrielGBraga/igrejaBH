import { useState, useMemo, useCallback } from "react"
import { ChurchMap } from "@/components/home/ChurchMap"
import { Badge } from "@/components/ui/badge"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import {
  MapPin,
  Calendar,
  Search,
  Users,
  MessageSquare,
  Edit,
  Plus,
  Link2,
} from "lucide-react"
import type { Database } from "@/lib/database.types"

type HomeGroup = Database["public"]["Tables"]["home_groups"]["Row"]
type Sector = Database["public"]["Tables"]["sectors"]["Row"]
type Profile = Database["public"]["Tables"]["profiles"]["Row"]

export interface GroupsDirectoryAndMapProps {
  homeGroups: HomeGroup[]
  sectors: Sector[]
  allProfiles: Profile[]
  isTier3: boolean
  isDev?: boolean
  myGroupId?: string | null
  onEditGroup: (hg: HomeGroup) => void
  onCreateGroup?: () => void
  onSelectGroupForMembers?: (groupId: string) => void
  onGenerateGroupLink?: (hg: HomeGroup) => void
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

export function GroupsDirectoryAndMap({
  homeGroups,
  sectors,
  allProfiles,
  isTier3,
  isDev = false,
  myGroupId,
  onEditGroup,
  onCreateGroup,
  onSelectGroupForMembers,
  onGenerateGroupLink,
}: GroupsDirectoryAndMapProps) {
  const [searchTerm, setSearchTerm] = useState<string>("")
  const [selectedSectorId, setSelectedSectorId] = useState<string>("all")

  // Map profiles helper
  const profileMap = useMemo(() => {
    const map = new Map<string, Profile>()
    allProfiles.forEach((p) => map.set(p.id, p))
    return map
  }, [allProfiles])

  // Sector map helper
  const sectorMap = useMemo(() => {
    const map = new Map<string, Sector>()
    sectors.forEach((s) => map.set(s.id, s))
    return map
  }, [sectors])

  // Contagem de discípulos por grupo
  const groupMemberCounts = useMemo(() => {
    const counts = new Map<string, number>()
    allProfiles.forEach((p) => {
      if (p.home_group_id) {
        counts.set(p.home_group_id, (counts.get(p.home_group_id) || 0) + 1)
      }
    })
    return counts
  }, [allProfiles])

  const getGroupTitle = useCallback((hg: HomeGroup) => {
    const l1 = hg.leader_1_id ? profileMap.get(hg.leader_1_id)?.full_name : null
    const l2 = hg.leader_2_id ? profileMap.get(hg.leader_2_id)?.full_name : null

    const leadersText = [l1, l2].filter(Boolean).join(" & ")
    if (hg.location_text) {
      const firstPart = hg.location_text.split("-")[0].trim()
      return leadersText ? `${firstPart} — ${leadersText}` : firstPart
    }
    return leadersText ? `Grupo de ${leadersText}` : `Grupo Caseiro (${hg.id.slice(0, 5)})`
  }, [profileMap])

  const getLeadersText = useCallback((hg: HomeGroup) => {
    const l1 = hg.leader_1_id ? profileMap.get(hg.leader_1_id)?.full_name : null
    const l2 = hg.leader_2_id ? profileMap.get(hg.leader_2_id)?.full_name : null
    return [l1, l2].filter(Boolean).join(" & ") || "Liderança a definir"
  }, [profileMap])

  // Filtragem dos grupos
  const filteredGroups = useMemo(() => {
    return homeGroups.filter((hg) => {
      // Filtro de Setor
      if (selectedSectorId !== "all" && hg.sector_id !== selectedSectorId) {
        return false
      }

      // Busca por texto
      if (!searchTerm.trim()) return true
      const term = searchTerm.toLowerCase()

      const title = getGroupTitle(hg).toLowerCase()
      const location = (hg.location_text || "").toLowerCase()
      const l1 = hg.leader_1_id ? (profileMap.get(hg.leader_1_id)?.full_name || "").toLowerCase() : ""
      const l2 = hg.leader_2_id ? (profileMap.get(hg.leader_2_id)?.full_name || "").toLowerCase() : ""
      const sectorName = hg.sector_id ? (sectorMap.get(hg.sector_id)?.name || "").toLowerCase() : ""

      return (
        title.includes(term) ||
        location.includes(term) ||
        l1.includes(term) ||
        l2.includes(term) ||
        sectorName.includes(term)
      )
    })
  }, [homeGroups, selectedSectorId, searchTerm, getGroupTitle, profileMap, sectorMap])

  return (
    <div className="space-y-6">
      {/* 1. Mapa Interativo com Pins de cada GC */}
      <div className="overflow-hidden rounded-2xl border border-border/80 bg-card shadow-sm">
        <ChurchMap
          homeGroups={homeGroups}
          sectors={sectors}
          colorLabelingBySector={true}
          hideHeader={false}
          getGroupLeadersName={(hg) => getGroupTitle(hg)}
          groupMemberCounts={groupMemberCounts}
        />
      </div>

      {/* 2. Barra de Busca e Filtros de Setor */}
      <div className="space-y-3">
        <div className="flex flex-col gap-2.5 sm:flex-row sm:items-center sm:justify-between">
          <div className="relative flex-1">
            <Search className="absolute left-3.5 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
            <Input
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              placeholder="Buscar grupo por bairro, líder ou setor..."
              className="h-11 min-h-[44px] rounded-xl pl-10 text-sm"
            />
          </div>

          {isTier3 && onCreateGroup && (
            <Button
              onClick={onCreateGroup}
              className="h-11 min-h-[44px] gap-2 rounded-xl text-xs font-medium shrink-0"
            >
              <Plus className="h-4 w-4" />
              <span>Novo Grupo Caseiro</span>
            </Button>
          )}
        </div>

        {/* Chips de Setor */}
        <div className="no-scrollbar flex items-center gap-1.5 overflow-x-auto pb-1">
          <button
            type="button"
            onClick={() => setSelectedSectorId("all")}
            className={`min-h-[36px] shrink-0 rounded-full px-3.5 py-1.5 text-xs font-medium transition-all ${
              selectedSectorId === "all"
                ? "bg-foreground text-background shadow-xs"
                : "border border-border/80 bg-card text-muted-foreground hover:bg-muted/60"
            }`}
          >
            Todos os Setores ({homeGroups.length})
          </button>
          {sectors.map((sector) => {
            const count = homeGroups.filter((g) => g.sector_id === sector.id).length
            return (
              <button
                key={sector.id}
                type="button"
                onClick={() => setSelectedSectorId(sector.id)}
                className={`min-h-[36px] shrink-0 rounded-full px-3.5 py-1.5 text-xs font-medium transition-all ${
                  selectedSectorId === sector.id
                    ? "bg-foreground text-background shadow-xs"
                    : "border border-border/80 bg-card text-muted-foreground hover:bg-muted/60"
                }`}
              >
                {sector.name} ({count})
              </button>
            )
          })}
        </div>
      </div>

      {/* 3. Lista de Cards dos Grupos Caseiros */}
      <div>
        <div className="mb-3 flex items-center justify-between text-xs text-muted-foreground">
          <span>
            Exibindo <strong>{filteredGroups.length}</strong> grupo(s) caseiro(s) na cidade
          </span>
        </div>

        <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3">
          {filteredGroups.map((hg) => {
            const isMyGroup = hg.id === myGroupId
            const sector = hg.sector_id ? sectorMap.get(hg.sector_id) : null
            const dayText =
              hg.meeting_day !== null && hg.meeting_day !== undefined
                ? DAYS_OF_WEEK[hg.meeting_day]
                : "Dia a combinar"
            const timeText = hg.start_time ? `às ${hg.start_time.slice(0, 5)}` : ""

            // Líder WhatsApp link
            const leaderProfile = hg.leader_1_id ? profileMap.get(hg.leader_1_id) : null
            const leaderPhone = leaderProfile?.phone?.replace(/\D/g, "")
            const leaderWhatsapp = leaderPhone ? `https://wa.me/55${leaderPhone}` : null

            return (
              <div
                key={hg.id}
                className={`flex flex-col justify-between rounded-xl border bg-card p-4 shadow-sm transition-all hover:border-primary/40 hover:shadow-md ${
                  isMyGroup ? "border-primary/50 bg-primary/5" : "border-border/80"
                }`}
              >
                <div className="space-y-3">
                  {/* Topo do Card: Setor + Badge Meu Grupo */}
                  <div className="flex items-center justify-between gap-2">
                    {sector ? (
                      <Badge
                        variant="outline"
                        className="border-primary/30 bg-primary/10 text-primary text-[11px] font-medium"
                      >
                        {sector.name}
                      </Badge>
                    ) : (
                      <Badge variant="outline" className="text-[11px] text-muted-foreground">
                        Setor Geral
                      </Badge>
                    )}

                    {isMyGroup && (
                      <Badge className="bg-emerald-600 text-white hover:bg-emerald-700 text-[11px]">
                        Meu Grupo
                      </Badge>
                    )}

                    <Badge variant="secondary" className="text-[11px] font-medium gap-1 ml-auto">
                      <Users className="h-3 w-3 text-primary" />
                      <span>{groupMemberCounts.get(hg.id) || 0}</span>
                    </Badge>
                  </div>

                  {/* Nome do Grupo e Líderes */}
                  <div>
                    <h3 className="font-semibold text-foreground text-base tracking-tight">
                      {getGroupTitle(hg)}
                    </h3>
                    <p className="mt-0.5 text-xs text-muted-foreground">
                      Líderes: <strong className="text-foreground/90">{getLeadersText(hg)}</strong>
                    </p>
                  </div>

                  {/* Horário e Endereço */}
                  <div className="space-y-1.5 rounded-lg bg-muted/40 p-2.5 text-xs text-muted-foreground">
                    <div className="flex items-center gap-2 text-foreground/80 font-medium">
                      <Calendar className="h-3.5 w-3.5 text-primary shrink-0" />
                      <span>
                        {dayText} {timeText}
                      </span>
                    </div>

                    <div className="flex items-start gap-2">
                      <MapPin className="h-3.5 w-3.5 text-muted-foreground shrink-0 mt-0.5" />
                      <span className="line-clamp-2">
                        {hg.location_text || "Endereço não informado"}
                      </span>
                    </div>
                  </div>
                </div>

                {/* Botões de Ação (>= 44px min-height) */}
                <div className="mt-4 space-y-2 border-t border-border/60 pt-3">
                  {leaderWhatsapp && (
                    <Button
                      asChild
                      variant="outline"
                      className="h-11 min-h-[44px] w-full gap-2 rounded-xl border-emerald-500/30 text-emerald-700 hover:bg-emerald-50 dark:text-emerald-400 dark:hover:bg-emerald-950/40 text-xs font-medium"
                    >
                      <a href={leaderWhatsapp} target="_blank" rel="noopener noreferrer">
                        <MessageSquare className="h-4 w-4" />
                        <span>Falar com Líder</span>
                      </a>
                    </Button>
                  )}

                  {/* Ações Especiais de Liderança (Tier 3 ou próprio grupo) */}
                  {(isTier3 || isMyGroup) && (
                    <div className="flex items-center gap-2 pt-1">
                      <Button
                        variant="secondary"
                        onClick={() => onEditGroup(hg)}
                        className="h-10 min-h-[40px] flex-1 gap-1.5 rounded-lg text-xs font-medium"
                      >
                        <Edit className="h-3.5 w-3.5" />
                        <span>Editar Grupo</span>
                      </Button>

                      {isTier3 && onSelectGroupForMembers && (
                        <Button
                          variant="outline"
                          onClick={() => onSelectGroupForMembers(hg.id)}
                          className="h-10 min-h-[40px] flex-1 gap-1.5 rounded-lg text-xs font-medium"
                        >
                          <Users className="h-3.5 w-3.5" />
                          <span>Ver Irmãos</span>
                        </Button>
                      )}
                    </div>
                  )}

                  {/* Ação Exclusiva para Dev: Criar/Copiar Link Restrito */}
                  {isDev && onGenerateGroupLink && (
                    <Button
                      type="button"
                      variant="outline"
                      onClick={() => onGenerateGroupLink(hg)}
                      className="h-10 min-h-[40px] w-full gap-1.5 rounded-lg text-xs font-medium border-primary/30 text-primary hover:bg-primary/10 transition-colors"
                    >
                      <Link2 className="h-3.5 w-3.5" />
                      <span>Gerar Link Restrito</span>
                    </Button>
                  )}
                </div>
              </div>
            )
          })}
        </div>
      </div>
    </div>
  )
}
