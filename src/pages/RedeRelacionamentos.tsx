import React, { useEffect, useState, useCallback, useMemo } from "react"
import { Navigate, useSearchParams, useNavigate } from "react-router-dom"
import supabase from "@/lib/supabase"
import type { Database } from "@/lib/database.types"
import { toast } from "sonner"
import {
  Users,
  MapPin,
  Calendar,
  Plus,
  Edit,
  Search,
  Network,
  List,
  Layers,
  Loader2,
  Filter,
  Link2,
  ShieldAlert,
} from "lucide-react"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Badge } from "@/components/ui/badge"
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select"
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogDescription,
} from "@/components/ui/dialog"

// Componentes modulares simplificados
import { DiscipleCard } from "@/components/gestao/DiscipleCard"
import { DiscipleEditorDialog } from "@/components/gestao/DiscipleEditorDialog"
import { HomeGroupEditorDialog } from "@/components/gestao/HomeGroupEditorDialog"
import { GroupsDirectoryAndMap } from "@/components/gestao/GroupsDirectoryAndMap"
import { RelationshipGraphView } from "@/components/gestao/RelationshipGraphView"
import { RestrictedGroupLinkDialog } from "@/components/gestao/RestrictedGroupLinkDialog"
import { disableRestrictedGroupMode } from "@/lib/restrictedMode"

type Profile = Database["public"]["Tables"]["profiles"]["Row"]
type HomeGroup = Database["public"]["Tables"]["home_groups"]["Row"]
type Fellowship = Database["public"]["Tables"]["fellowships"]["Row"]
type Sector = Database["public"]["Tables"]["sectors"]["Row"]

const DAYS_OF_WEEK = [
  "Domingo",
  "Segunda-feira",
  "Terça-feira",
  "Quarta-feira",
  "Quinta-feira",
  "Sexta-feira",
  "Sábado",
]

const checkIsChild = (p: Profile) => {
  return !p.baptism_date && !!(p.father_id || p.mother_id)
}

interface RedeRelacionamentosProps {
  singleGroupMode?: boolean
}

export default function RedeRelacionamentos({ singleGroupMode = false }: RedeRelacionamentosProps) {
  const [searchParams] = useSearchParams()
  const navigate = useNavigate()
  const requestedGroupId = searchParams.get("grupo")

  const [loading, setLoading] = useState(true)

  // Dados do banco
  const [profiles, setProfiles] = useState<Profile[]>([])
  const [homeGroups, setHomeGroups] = useState<HomeGroup[]>([])
  const [fellowships, setFellowships] = useState<Fellowship[]>([])
  const [sectors, setSectors] = useState<Sector[]>([])
  const [leaderIds, setLeaderIds] = useState<Set<string>>(new Set())

  // Papéis de acesso
  const [isTier3, setIsTier3] = useState<boolean>(false) // Dev, Presbítero, Diácono
  const [isDev, setIsDev] = useState<boolean>(false)
  const [isLeader, setIsLeader] = useState<boolean>(false) // Líder de GC
  const [myHomeGroup, setMyHomeGroup] = useState<HomeGroup | null>(null)
  const [isUnauthorizedForGroup, setIsUnauthorizedForGroup] = useState<boolean>(false)

  // Abas de navegação
  const [activeTab, setActiveTab] = useState<"meu_grupo" | "outros_grupos">("meu_grupo")
  const [showGraphView, setShowGraphView] = useState<boolean>(false) // Apenas Tier 3

  // Filtros da lista de irmãos
  const [selectedGroupFilter, setSelectedGroupFilter] = useState<string>("my_or_all")
  const [searchName, setSearchName] = useState<string>("")
  const [filterDisciplerStatus, setFilterDisciplerStatus] = useState<"all" | "with" | "without">("all")

  // Modais de Edição
  const [editingDisciple, setEditingDisciple] = useState<Profile | null>(null)
  const [isDiscipleDialogOpen, setIsDiscipleDialogOpen] = useState<boolean>(false)
  const [transformToBaptizedOnOpen, setTransformToBaptizedOnOpen] = useState<boolean>(false)

  const [editingHomeGroup, setEditingHomeGroup] = useState<HomeGroup | null>(null)
  const [isHomeGroupDialogOpen, setIsHomeGroupDialogOpen] = useState<boolean>(false)

  // Modal de Setores (Tier 3)
  const [isSectorDialogOpen, setIsSectorDialogOpen] = useState<boolean>(false)
  const [newSectorName, setNewSectorName] = useState<string>("")
  const [savingSector, setSavingSector] = useState<boolean>(false)

  // Modal de Gerador de Links (Dev)
  const [isLinkGenOpen, setIsLinkGenOpen] = useState<boolean>(false)
  const [linkGenSelectedGroupId, setLinkGenSelectedGroupId] = useState<string | null>(null)

  // Carregar dados completos
  const loadData = useCallback(async (isInitial = false) => {
    try {
      if (isInitial) setLoading(true)

      const {
        data: { session },
      } = await supabase.auth.getSession()

      if (!session?.user) {
        setLoading(false)
        return
      }

      // Perfil do usuário logado
      const { data: myProfile, error: profileErr } = await supabase
        .from("profiles")
        .select("*")
        .eq("user_id", session.user.id)
        .single()

      if (profileErr) throw profileErr

      const tier3 = !!(myProfile.is_dev || myProfile.is_presbyter || myProfile.is_deacon)
      const userIsDev = !!myProfile.is_dev
      setIsTier3(tier3)
      setIsDev(userIsDev)

      // Buscar Grupos Caseiros
      const { data: groupsData, error: groupsErr } = await supabase
        .from("home_groups")
        .select("*")
        .order("location_text")
      if (groupsErr) throw groupsErr
      const allGroups = groupsData || []
      setHomeGroups(allGroups)

      // Verificar se o usuário lidera algum grupo
      const ledGroups = allGroups.filter(
        (g) => g.leader_1_id === myProfile.id || g.leader_2_id === myProfile.id
      )
      const isUserLeader = ledGroups.length > 0

      let primaryGroup: HomeGroup | null = null
      let unauthorized = false

      if (requestedGroupId) {
        const found = allGroups.find((g) => g.id === requestedGroupId) || null
        if (found) {
          const canManage =
            tier3 ||
            found.leader_1_id === myProfile.id ||
            found.leader_2_id === myProfile.id

          if (canManage) {
            primaryGroup = found
            setIsLeader(true)
          } else {
            unauthorized = true
          }
        } else {
          unauthorized = true
        }
      } else {
        primaryGroup =
          ledGroups[0] ||
          (myProfile.home_group_id
            ? allGroups.find((g) => g.id === myProfile.home_group_id) || null
            : null)
        setIsLeader(isUserLeader || (tier3 && !!primaryGroup))
      }

      setIsUnauthorizedForGroup(unauthorized)
      setMyHomeGroup(primaryGroup)

      // Buscar Perfis
      const { data: profilesData, error: pErr } = await supabase
        .from("profiles")
        .select("*")
        .order("full_name")
      if (pErr) throw pErr
      setProfiles(profilesData || [])

      // Buscar Comunhões (Fellowships)
      const { data: fellowshipsData } = await supabase
        .from("fellowships")
        .select("*")
      setFellowships(fellowshipsData || [])

      // Buscar Setores
      const { data: sectorsData } = await supabase
        .from("sectors")
        .select("*")
        .order("name")
      setSectors(sectorsData || [])

      // Computar líderes
      const leadersSet = new Set<string>()
      allGroups.forEach((g) => {
        if (g.leader_1_id) leadersSet.add(g.leader_1_id)
        if (g.leader_2_id) leadersSet.add(g.leader_2_id)
      })
      setLeaderIds(leadersSet)

      // Definir filtro padrão de grupo
      if (singleGroupMode) {
        if (primaryGroup) {
          setSelectedGroupFilter(primaryGroup.id)
        }
        setActiveTab("meu_grupo")
        setShowGraphView(false)
      } else if (isInitial) {
        if (isUserLeader && !tier3 && primaryGroup) {
          setSelectedGroupFilter(primaryGroup.id)
        } else {
          setSelectedGroupFilter("all")
        }
      }
    } catch (err) {
      console.error("Erro ao carregar dados de gestão:", err)
      toast.error("Erro ao carregar dados da Gestão do Corpo.")
    } finally {
      if (isInitial) setLoading(false)
    }
  }, [requestedGroupId, singleGroupMode])

  useEffect(() => {
    loadData(true)
  }, [loadData])

  // Mapeamentos rápidos
  const profileMap = useMemo(() => {
    const map = new Map<string, Profile>()
    profiles.forEach((p) => map.set(p.id, p))
    return map
  }, [profiles])

  const sectorMap = useMemo(() => {
    const map = new Map<string, Sector>()
    sectors.forEach((s) => map.set(s.id, s))
    return map
  }, [sectors])

  const fellowshipsByProfile = useMemo(() => {
    const map = new Map<string, string[]>()
    fellowships.forEach((f) => {
      const companionA = profileMap.get(f.member_b_id)?.full_name
      const companionB = profileMap.get(f.member_a_id)?.full_name

      if (companionA) {
        const arr = map.get(f.member_a_id) || []
        arr.push(companionA)
        map.set(f.member_a_id, arr)
      }
      if (companionB) {
        const arr = map.get(f.member_b_id) || []
        arr.push(companionB)
        map.set(f.member_b_id, arr)
      }
    })
    return map
  }, [fellowships, profileMap])

  // Identificar o grupo caseiro exibido na aba "Meu Grupo Caseiro" (ou grupo filtrado)
  const currentFocusedGroup = useMemo(() => {
    if (singleGroupMode) return myHomeGroup
    if (selectedGroupFilter !== "all" && selectedGroupFilter !== "unlinked") {
      return homeGroups.find((g) => g.id === selectedGroupFilter) || myHomeGroup
    }
    return myHomeGroup
  }, [singleGroupMode, selectedGroupFilter, homeGroups, myHomeGroup])

  // Lista de irmãos filtrada
  const filteredDisciples = useMemo(() => {
    return profiles.filter((p) => {
      // 1. Filtro de Grupo Caseiro
      if (singleGroupMode) {
        if (!myHomeGroup || p.home_group_id !== myHomeGroup.id) {
          return false
        }
      } else if (!isTier3) {
        // Líder comum vê apenas os irmãos do seu próprio grupo
        if (!myHomeGroup || p.home_group_id !== myHomeGroup.id) {
          return false
        }
      } else {
        // Nível 3 pode filtrar por grupo, todos ou apenas visitantes em estudos
        if (selectedGroupFilter === "unlinked") {
          if (p.is_church_linked !== false) return false
        } else if (selectedGroupFilter !== "all") {
          if (p.home_group_id !== selectedGroupFilter) return false
        }
      }

      // 2. Busca por Nome
      if (searchName.trim()) {
        const term = searchName.toLowerCase()
        const matchesName = p.full_name?.toLowerCase().includes(term)
        const matchesPhone = p.phone?.includes(term)
        if (!matchesName && !matchesPhone) return false
      }

      // 3. Filtro de Discipulador
      const isChild = checkIsChild(p)
      if (filterDisciplerStatus === "with") {
        if (!p.discipler_id || isChild) return false
      } else if (filterDisciplerStatus === "without") {
        if (p.discipler_id || isChild) return false
      }

      return true
    })
  }, [
    profiles,
    singleGroupMode,
    isTier3,
    myHomeGroup,
    selectedGroupFilter,
    searchName,
    filterDisciplerStatus,
  ])

  // Contadores para chips de status
  const counts = useMemo(() => {
    const baseList = profiles.filter((p) => {
      if (singleGroupMode) {
        return myHomeGroup && p.home_group_id === myHomeGroup.id
      }
      if (!isTier3) {
        return myHomeGroup && p.home_group_id === myHomeGroup.id
      }
      if (selectedGroupFilter === "unlinked") return p.is_church_linked === false
      if (selectedGroupFilter !== "all") return p.home_group_id === selectedGroupFilter
      return true
    })

    const total = baseList.length
    const withDiscipler = baseList.filter((p) => !!p.discipler_id && !checkIsChild(p)).length
    const withoutDiscipler = baseList.filter((p) => !p.discipler_id && !checkIsChild(p)).length

    return { total, withDiscipler, withoutDiscipler }
  }, [profiles, singleGroupMode, isTier3, myHomeGroup, selectedGroupFilter])

  // Abertura dos modais
  const handleOpenAddDisciple = () => {
    setEditingDisciple(null)
    setTransformToBaptizedOnOpen(false)
    setIsDiscipleDialogOpen(true)
  }

  const handleOpenEditDisciple = (disciple: Profile) => {
    setEditingDisciple(disciple)
    setTransformToBaptizedOnOpen(false)
    setIsDiscipleDialogOpen(true)
  }

  const handleOpenTransformBaptism = (disciple: Profile) => {
    setEditingDisciple(disciple)
    setTransformToBaptizedOnOpen(true)
    setIsDiscipleDialogOpen(true)
  }

  const handleOpenEditGroup = (hg: HomeGroup) => {
    setEditingHomeGroup(hg)
    setIsHomeGroupDialogOpen(true)
  }

  const handleOpenCreateGroup = () => {
    setEditingHomeGroup(null)
    setIsHomeGroupDialogOpen(true)
  }

  // Gerenciamento de setores (Tier 3)
  const handleCreateSector = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!newSectorName.trim()) return
    setSavingSector(true)
    try {
      const { error } = await supabase
        .from("sectors")
        .insert({ name: newSectorName.trim() })
      if (error) throw error
      toast.success("Novo setor adicionado com sucesso!")
      setNewSectorName("")
      loadData(false)
    } catch (err: unknown) {
      console.error("Erro ao criar setor:", err)
      const msg = err instanceof Error ? err.message : "Erro desconhecido."
      toast.error(`Não foi possível salvar o setor: ${msg}`)
    } finally {
      setSavingSector(false)
    }
  }

  if (loading) {
    return (
      <div className="flex min-h-[60vh] flex-col items-center justify-center gap-3">
        <Loader2 className="h-8 w-8 animate-spin text-primary" />
        <p className="text-xs text-muted-foreground">Carregando Gestão do Corpo...</p>
      </div>
    )
  }

  // Tratamento de permissão no Modo Restrito (evita loop infinito de redirecionamento)
  if (singleGroupMode && (isUnauthorizedForGroup || !myHomeGroup || (!isTier3 && !isLeader))) {
    return (
      <div className="mx-auto flex min-h-[60vh] max-w-md flex-col items-center justify-center p-4 text-center">
        <div className="flex h-16 w-16 items-center justify-center rounded-2xl bg-destructive/10 text-destructive mb-4">
          <ShieldAlert className="h-8 w-8" />
        </div>
        <h2 className="text-xl font-bold text-foreground">Acesso Restrito ao Grupo</h2>
        <p className="mt-2 text-xs sm:text-sm text-muted-foreground">
          {isUnauthorizedForGroup
            ? "Você não possui permissão para gerenciar este Grupo Caseiro específico ou o grupo informado não existe."
            : "Sua conta atual não possui permissão de liderança de Grupo Caseiro."}
        </p>
        <div className="mt-6 flex flex-col gap-2 w-full">
          <Button
            variant="destructive"
            onClick={async () => {
              disableRestrictedGroupMode()
              await supabase.auth.signOut()
              navigate("/entrar", { replace: true })
            }}
            className="h-11 min-h-[44px] w-full rounded-xl text-xs font-semibold"
          >
            Sair e Trocar de Conta
          </Button>
        </div>
      </div>
    )
  }

  // Escala 1: Usuário comum fora do modo restrito é redirecionado
  if (!isTier3 && !isLeader) {
    return <Navigate to="/dashboard" replace />
  }

  return (
    <div className="mx-auto w-full max-w-6xl space-y-6 pb-12">
      {/* 1. Cabeçalho Principal Mobile-First */}
      <div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between border-b border-border/70 pb-4">
        <div>
          <div className="flex items-center gap-2">
            <Badge
              variant="outline"
              className="border-primary/30 bg-primary/10 text-primary text-[11px] font-medium"
            >
              {isTier3 ? "Presbitério & Diaconato" : "Líder de GC"}
            </Badge>
          </div>
          <h1 className="mt-1 text-2xl font-bold tracking-tight text-foreground sm:text-3xl">
            Gestão do Corpo
          </h1>
          <p className="text-xs sm:text-sm text-muted-foreground">
            {isTier3
              ? "Coordenação dos Grupos Caseiros e cuidado mútuo na vida da igreja."
              : "Cuidado dos irmãos do Grupo Caseiro e fortalecimento das juntas e ligamentos."}
          </p>
        </div>

        {/* Ações de Cabeçalho */}
        <div className="flex flex-wrap items-center gap-2">
          {isDev && (
            <Button
              variant="outline"
              onClick={() => {
                setLinkGenSelectedGroupId(myHomeGroup?.id || null)
                setIsLinkGenOpen(true)
              }}
              className="h-11 min-h-[44px] gap-2 rounded-xl text-xs font-medium"
            >
              <Link2 className="h-4 w-4 text-primary" />
              <span>Gerar Link de GC</span>
            </Button>
          )}

          {/* Botão de Alternância para Grafo (Apenas Nível 3 fora do modo restrito) */}
          {!singleGroupMode && isTier3 && (
            <Button
              variant={showGraphView ? "default" : "outline"}
              onClick={() => setShowGraphView(!showGraphView)}
              className="h-11 min-h-[44px] gap-2 rounded-xl text-xs font-medium"
            >
              {showGraphView ? (
                <>
                  <List className="h-4 w-4" />
                  <span>Ver em Lista</span>
                </>
              ) : (
                <>
                  <Network className="h-4 w-4" />
                  <span>Ver em Grafo</span>
                </>
              )}
            </Button>
          )}
        </div>
      </div>

      {/* Se estiver no modo Grafo (Nível 3) */}
      {showGraphView && isTier3 ? (
        <RelationshipGraphView
          profiles={profiles}
          homeGroups={homeGroups}
          fellowships={fellowships}
          sectors={sectors}
          leaderIds={leaderIds}
          onSelectDisciple={handleOpenEditDisciple}
          onClose={() => setShowGraphView(false)}
        />
      ) : (
        <>
          {/* 2. Barra de Abas Grandes (Apenas no Modo Normal) */}
          {!singleGroupMode && (
            <div className="grid grid-cols-2 gap-2 rounded-2xl bg-muted/60 p-1.5 border border-border/60">
            <Button
              type="button"
              variant={activeTab === "meu_grupo" ? "default" : "ghost"}
              onClick={() => setActiveTab("meu_grupo")}
              className="h-12 min-h-[48px] gap-2 rounded-xl text-xs sm:text-sm font-medium transition-all"
            >
              <Users className="h-4 w-4" />
              <span>{isTier3 ? "Irmãos e Grupos" : "Meu Grupo Caseiro"}</span>
            </Button>

            <Button
              type="button"
              variant={activeTab === "outros_grupos" ? "default" : "ghost"}
              onClick={() => setActiveTab("outros_grupos")}
              className="h-12 min-h-[48px] gap-2 rounded-xl text-xs sm:text-sm font-medium transition-all"
            >
              <MapPin className="h-4 w-4" />
              <span>{isTier3 ? "Diretório de GCs & Mapa" : "Outros Grupos e Mapa"}</span>
            </Button>
          </div>
          )}

          {/* ========================================================= */}
          {/* ABA 1: MEU GRUPO CASEIRO / GESTÃO DE IRMÃOS              */}
          {/* ========================================================= */}
          {activeTab === "meu_grupo" && (
            <div className="space-y-5">
              {/* Seletor de Grupo Caseiro para Nível 3 (apenas fora do modo restrito) */}
              {!singleGroupMode && isTier3 && (
                <div className="flex flex-col gap-2 rounded-xl border border-border/80 bg-card p-3.5 sm:flex-row sm:items-center sm:justify-between shadow-2xs">
                  <div className="flex items-center gap-2">
                    <Filter className="h-4 w-4 text-primary" />
                    <span className="text-xs font-semibold text-foreground uppercase tracking-wider">
                      Filtrar por Grupo Caseiro:
                    </span>
                  </div>
                  <Select
                    value={selectedGroupFilter}
                    onValueChange={setSelectedGroupFilter}
                  >
                    <SelectTrigger className="h-11 min-h-[44px] w-full sm:w-72 rounded-lg text-xs font-medium">
                      <SelectValue placeholder="Selecione um grupo" />
                    </SelectTrigger>
                    <SelectContent className="max-h-64">
                      <SelectItem value="all">
                        Todos da Igreja ({profiles.length})
                      </SelectItem>
                      <SelectItem value="unlinked">
                        Visitantes nos Estudos ({profiles.filter((p) => p.is_church_linked === false).length})
                      </SelectItem>
                      {homeGroups.map((hg) => {
                        const count = profiles.filter((p) => p.home_group_id === hg.id).length
                        return (
                          <SelectItem key={hg.id} value={hg.id}>
                            {hg.location_text || `GC (${hg.id.slice(0, 5)})`} ({count})
                          </SelectItem>
                        )
                      })}
                    </SelectContent>
                  </Select>
                </div>
              )}

              {/* Card de Informações do Grupo Caseiro Focado */}
              {currentFocusedGroup && (
                <div className="rounded-2xl border border-border/80 bg-card p-4 sm:p-5 shadow-sm">
                  <div className="flex flex-col gap-3 sm:flex-row sm:items-start sm:justify-between">
                    <div>
                      <div className="flex items-center gap-2">
                        {currentFocusedGroup.sector_id && sectorMap.has(currentFocusedGroup.sector_id) && (
                          <Badge
                            variant="outline"
                            className="border-primary/30 bg-primary/10 text-primary text-[11px]"
                          >
                            {sectorMap.get(currentFocusedGroup.sector_id)?.name}
                          </Badge>
                        )}
                        <span className="text-xs font-medium text-muted-foreground">
                          {counts.total} irmão(s) vinculados
                        </span>
                      </div>

                      <h2 className="mt-1 text-lg font-bold text-foreground sm:text-xl">
                        {currentFocusedGroup.location_text || "Grupo Caseiro"}
                      </h2>

                      <div className="mt-2 flex flex-wrap items-center gap-x-4 gap-y-1.5 text-xs text-muted-foreground">
                        <div className="flex items-center gap-1.5 text-foreground/90 font-medium">
                          <Calendar className="h-3.5 w-3.5 text-primary" />
                          <span>
                            {currentFocusedGroup.meeting_day !== null && currentFocusedGroup.meeting_day !== undefined
                              ? DAYS_OF_WEEK[currentFocusedGroup.meeting_day]
                              : "Dia a combinar"}{" "}
                            {currentFocusedGroup.start_time ? `às ${currentFocusedGroup.start_time.slice(0, 5)}` : ""}
                          </span>
                        </div>

                        <div className="flex items-center gap-1.5">
                          <MapPin className="h-3.5 w-3.5 text-muted-foreground" />
                          <span>{currentFocusedGroup.location_text || "Endereço não cadastrado"}</span>
                        </div>
                      </div>
                    </div>

                    {/* Botão de Editar Dados do Grupo */}
                    <Button
                      variant="outline"
                      onClick={() => handleOpenEditGroup(currentFocusedGroup)}
                      className="h-11 min-h-[44px] gap-1.5 rounded-xl text-xs font-medium shrink-0"
                    >
                      <Edit className="h-3.5 w-3.5" />
                      <span>Editar Dados do Grupo</span>
                    </Button>
                  </div>
                </div>
              )}

              {/* Botão Grande "+ Adicionar Irmão ao Grupo" (Min Height 48px) */}
              <Button
                type="button"
                onClick={handleOpenAddDisciple}
                className="h-12 min-h-[48px] w-full gap-2 rounded-xl text-sm font-semibold shadow-sm"
              >
                <Plus className="h-5 w-5" />
                <span>Adicionar Irmão ao Grupo</span>
              </Button>

              {/* Barra de Busca e Chips de Status */}
              <div className="space-y-2.5">
                <div className="relative">
                  <Search className="absolute left-3.5 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
                  <Input
                    value={searchName}
                    onChange={(e) => setSearchName(e.target.value)}
                    placeholder="Buscar irmão por nome ou telefone..."
                    className="h-11 min-h-[44px] rounded-xl pl-10 text-sm"
                  />
                </div>

                {/* Chips de Filtro */}
                <div className="flex items-center gap-2 overflow-x-auto pb-1">
                  <button
                    type="button"
                    onClick={() => setFilterDisciplerStatus("all")}
                    className={`min-h-[36px] shrink-0 rounded-full px-3.5 py-1.5 text-xs font-medium transition-all ${
                      filterDisciplerStatus === "all"
                        ? "bg-foreground text-background shadow-xs"
                        : "border border-border/80 bg-card text-muted-foreground hover:bg-muted/60"
                    }`}
                  >
                    Todos ({counts.total})
                  </button>

                  <button
                    type="button"
                    onClick={() => setFilterDisciplerStatus("with")}
                    className={`min-h-[36px] shrink-0 rounded-full px-3.5 py-1.5 text-xs font-medium transition-all ${
                      filterDisciplerStatus === "with"
                        ? "bg-foreground text-background shadow-xs"
                        : "border border-border/80 bg-card text-muted-foreground hover:bg-muted/60"
                    }`}
                  >
                    Com Discipulador ({counts.withDiscipler})
                  </button>

                  <button
                    type="button"
                    onClick={() => setFilterDisciplerStatus("without")}
                    className={`min-h-[36px] shrink-0 rounded-full px-3.5 py-1.5 text-xs font-medium transition-all ${
                      filterDisciplerStatus === "without"
                        ? "bg-foreground text-background shadow-xs"
                        : "border border-border/80 bg-card text-muted-foreground hover:bg-muted/60"
                    }`}
                  >
                    Pendente Discipulador ({counts.withoutDiscipler})
                  </button>
                </div>
              </div>

              {/* Lista de Cards dos Irmãos */}
              {filteredDisciples.length === 0 ? (
                <div className="rounded-2xl border border-dashed border-border p-8 text-center">
                  <Users className="mx-auto h-10 w-10 text-muted-foreground/50" />
                  <h3 className="mt-2 text-sm font-semibold text-foreground">
                    Nenhum irmão encontrado
                  </h3>
                  <p className="mt-1 text-xs text-muted-foreground">
                    {searchName
                      ? "Nenhum irmão corresponde aos termos da busca."
                      : "Clique no botão acima para adicionar o primeiro irmão a este grupo."}
                  </p>
                </div>
              ) : (
                <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3">
                  {filteredDisciples.map((disciple) => {
                    const isGroupLeader = leaderIds.has(disciple.id)
                    const discipler = disciple.discipler_id
                      ? profileMap.get(disciple.discipler_id)?.full_name
                      : null
                    const spouse = disciple.spouse_id
                      ? profileMap.get(disciple.spouse_id)?.full_name
                      : null
                    const father = disciple.father_id
                      ? profileMap.get(disciple.father_id)?.full_name
                      : null
                    const mother = disciple.mother_id
                      ? profileMap.get(disciple.mother_id)?.full_name
                      : null
                    const companions = fellowshipsByProfile.get(disciple.id) || []

                    return (
                      <DiscipleCard
                        key={disciple.id}
                        disciple={disciple}
                        isLeader={isGroupLeader}
                        disciplerName={discipler}
                        spouseName={spouse}
                        fatherName={father}
                        motherName={mother}
                        fellowshipNames={companions}
                        onEdit={handleOpenEditDisciple}
                        onTransformChild={handleOpenTransformBaptism}
                      />
                    )
                  })}
                </div>
              )}
            </div>
          )}

          {/* ========================================================= */}
          {/* ABA 2: OUTROS GRUPOS E MAPA (DIRETÓRIO)                  */}
          {/* ========================================================= */}
          {activeTab === "outros_grupos" && (
            <div className="space-y-4">
              {/* Botão de Gestão de Setores (Tier 3) */}
              {isTier3 && (
                <div className="flex justify-end">
                  <Button
                    variant="outline"
                    onClick={() => setIsSectorDialogOpen(true)}
                    className="h-10 min-h-[40px] gap-1.5 rounded-xl text-xs font-medium"
                  >
                    <Layers className="h-4 w-4" />
                    <span>Gerenciar Setores ({sectors.length})</span>
                  </Button>
                </div>
              )}

              <GroupsDirectoryAndMap
                homeGroups={homeGroups}
                sectors={sectors}
                allProfiles={profiles}
                isTier3={!singleGroupMode && isTier3}
                isDev={isDev}
                myGroupId={myHomeGroup?.id}
                onEditGroup={handleOpenEditGroup}
                onCreateGroup={isTier3 ? handleOpenCreateGroup : undefined}
                onGenerateGroupLink={(hg) => {
                  setLinkGenSelectedGroupId(hg.id)
                  setIsLinkGenOpen(true)
                }}
                onSelectGroupForMembers={
                  isTier3
                    ? (groupId) => {
                        setSelectedGroupFilter(groupId)
                        setActiveTab("meu_grupo")
                      }
                    : undefined
                }
              />
            </div>
          )}
        </>
      )}

      {/* ========================================================= */}
      {/* MODAL 1: ADICIONAR / EDITAR IRMÃO E VÍNCULOS              */}
      {/* ========================================================= */}
      <DiscipleEditorDialog
        open={isDiscipleDialogOpen}
        onOpenChange={(open) => {
          setIsDiscipleDialogOpen(open)
          if (!open) setTransformToBaptizedOnOpen(false)
        }}
        disciple={editingDisciple}
        homeGroups={homeGroups}
        allProfiles={profiles}
        fellowships={fellowships}
        defaultHomeGroupId={
          singleGroupMode
            ? myHomeGroup?.id
            : selectedGroupFilter !== "all" && selectedGroupFilter !== "unlinked"
            ? selectedGroupFilter
            : myHomeGroup?.id
        }
        isTier3={!singleGroupMode && isTier3}
        lockGroupSelectionOnCreate={singleGroupMode}
        initialTransformToBaptized={transformToBaptizedOnOpen}
        onSuccess={() => loadData(false)}
      />

      {/* ========================================================= */}
      {/* MODAL 2: EDITAR / CRIAR GRUPO CASEIRO                     */}
      {/* ========================================================= */}
      <HomeGroupEditorDialog
        open={isHomeGroupDialogOpen}
        onOpenChange={setIsHomeGroupDialogOpen}
        homeGroup={editingHomeGroup}
        isTier3={!singleGroupMode && isTier3}
        allProfiles={profiles}
        sectors={sectors}
        onSuccess={() => loadData(false)}
      />

      {/* ========================================================= */}
      {/* MODAL 3: GERENCIAR SETORES (APENAS TIER 3 FORA DO MODO RESTRITO) */}
      {/* ========================================================= */}
      {!singleGroupMode && isTier3 && (
        <Dialog open={isSectorDialogOpen} onOpenChange={setIsSectorDialogOpen}>
          <DialogContent className="max-w-md rounded-2xl p-5">
            <DialogHeader>
              <DialogTitle className="text-lg font-bold">Setores da Cidade</DialogTitle>
              <DialogDescription className="text-xs">
                Cadastre e visualize os setores geográficos para organizar os Grupos Caseiros.
              </DialogDescription>
            </DialogHeader>

            <form onSubmit={handleCreateSector} className="space-y-3 pt-2">
              <div className="flex gap-2">
                <Input
                  value={newSectorName}
                  onChange={(e) => setNewSectorName(e.target.value)}
                  placeholder="Nome do novo setor (ex: Barreiro)..."
                  className="h-11 min-h-[44px] flex-1 rounded-xl text-xs"
                />
                <Button
                  type="submit"
                  disabled={savingSector || !newSectorName.trim()}
                  className="h-11 min-h-[44px] rounded-xl text-xs font-medium shrink-0"
                >
                  {savingSector ? <Loader2 className="h-4 w-4 animate-spin" /> : "Adicionar"}
                </Button>
              </div>
            </form>

            <div className="mt-3 max-h-56 space-y-1.5 overflow-y-auto">
              {sectors.map((s) => {
                const groupCount = homeGroups.filter((g) => g.sector_id === s.id).length
                return (
                  <div
                    key={s.id}
                    className="flex items-center justify-between rounded-lg border border-border/70 p-2.5 text-xs"
                  >
                    <span className="font-medium text-foreground">{s.name}</span>
                    <Badge variant="outline" className="text-[11px] text-muted-foreground">
                      {groupCount} grupo(s)
                    </Badge>
                  </div>
                )
              })}
            </div>
          </DialogContent>
        </Dialog>
      )}

      {/* ========================================================= */}
      {/* MODAL 4: GERAR LINKS DE ACESSO RESTRITO (DEV)             */}
      {/* ========================================================= */}
      {isDev && (
        <RestrictedGroupLinkDialog
          open={isLinkGenOpen}
          onOpenChange={setIsLinkGenOpen}
          homeGroups={homeGroups}
          allProfiles={profiles}
          sectors={sectors}
          initialGroupId={linkGenSelectedGroupId}
        />
      )}
    </div>
  )
}
