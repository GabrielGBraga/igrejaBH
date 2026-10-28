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
  Cake,
  AlertCircle,
  HeartHandshake,
  Baby,
} from "lucide-react"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Badge } from "@/components/ui/badge"
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
import { THEME_CLASSES } from "@/constants/colors"
import { SearchableSelect, type SearchableSelectOption } from "@/components/ui/searchable-select"
import {
  getHomeGroupLeadersName,
  getHomeGroupDisplayName,
} from "@/lib/homeGroupUtils"

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

const isBirthdayThisMonth = (birthDateStr?: string | null) => {
  if (!birthDateStr) return false
  const parts = birthDateStr.split("-")
  if (parts.length < 3) return false
  const birthMonth = parseInt(parts[1], 10)
  const currentMonth = new Date().getMonth() + 1
  return birthMonth === currentMonth
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
  const [filterCategory, setFilterCategory] = useState<
    "all" | "without_discipler" | "birthdays" | "children" | "adults"
  >("all")

  // Modais de Edição
  const [editingDisciple, setEditingDisciple] = useState<Profile | null>(null)
  const [isDiscipleDialogOpen, setIsDiscipleDialogOpen] = useState<boolean>(false)
  const [transformToBaptizedOnOpen, setTransformToBaptizedOnOpen] = useState<boolean>(false)
  const [transformToLinkedOnOpen, setTransformToLinkedOnOpen] = useState<boolean>(false)

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
        if (requestedGroupId && primaryGroup) {
          setSelectedGroupFilter(primaryGroup.id)
        } else if (isUserLeader && primaryGroup) {
          // Se o usuário também for líder de grupo, abre primeiro só no grupo dele
          setSelectedGroupFilter(primaryGroup.id)
        } else if (tier3) {
          // Usuários com visão geral que não lideram GC específico abrem com a visão geral
          setSelectedGroupFilter("all")
        } else if (primaryGroup) {
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
      return homeGroups.find((g) => g.id === selectedGroupFilter) || null
    }
    return null
  }, [singleGroupMode, selectedGroupFilter, homeGroups, myHomeGroup])

  const presbyterIds = useMemo(
    () => new Set(profiles.filter((p) => p.is_presbyter).map((p) => p.id)),
    [profiles]
  )

  // KPIs consolidados da igreja para quando "Todos da Igreja" estiver selecionado
  const churchKpis = useMemo(() => {
    // Apenas discípulos vinculados à igreja (usuários de estudo não entram na contagem do Corpo)
    const churchProfiles = profiles.filter((p) => p.is_church_linked !== false)
    const totalDisciples = churchProfiles.length
    const adultDisciples = churchProfiles.filter((p) => !checkIsChild(p))
    const adultCount = adultDisciples.length
    const childrenCount = churchProfiles.filter((p) => checkIsChild(p)).length

    // Presbíteros e esposas de presbíteros (raízes do discipulado feminino) possuem cobertura mútua no Presbitério
    const isCoveredRoot = (p: Profile) =>
      !!p.is_presbyter || !!(p.spouse_id && presbyterIds.has(p.spouse_id))

    const withDiscipler = adultDisciples.filter(
      (p) => !!p.discipler_id || isCoveredRoot(p)
    ).length
    const withoutDiscipler = adultDisciples.filter(
      (p) => !p.discipler_id && !isCoveredRoot(p)
    ).length
    const discipleshipRate = adultCount > 0 ? Math.round((withDiscipler / adultCount) * 100) : 0

    // Quantos discipuladores existem no Corpo
    const activeDisciplerIds = new Set(
      churchProfiles
        .map((p) => p.discipler_id)
        .filter((id): id is string => Boolean(id))
    )
    const totalDisciplers = activeDisciplerIds.size

    const totalGroups = homeGroups.length
    const totalSectors = sectors.length

    // Companheiros de obra
    const profilesWithCompanion = new Set<string>()
    fellowships.forEach((f) => {
      profilesWithCompanion.add(f.member_a_id)
      profilesWithCompanion.add(f.member_b_id)
    })
    const brothersWithCompanions = profilesWithCompanion.size
    const totalFellowships = fellowships.length

    const birthdaysCount = churchProfiles.filter((p) => isBirthdayThisMonth(p.birth_date)).length

    return {
      totalDisciples,
      adultCount,
      childrenCount,
      withDiscipler,
      withoutDiscipler,
      discipleshipRate,
      totalDisciplers,
      totalGroups,
      totalSectors,
      totalFellowships,
      brothersWithCompanions,
      birthdaysCount,
    }
  }, [profiles, homeGroups, sectors, fellowships, presbyterIds])

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
        } else {
          // Quando "Todos da Igreja", não incluir usuários de estudo
          if (p.is_church_linked === false) return false
        }
      }

      // 2. Busca por Nome
      if (searchName.trim()) {
        const term = searchName.toLowerCase()
        const matchesName = p.full_name?.toLowerCase().includes(term)
        const matchesPhone = p.phone?.includes(term)
        if (!matchesName && !matchesPhone) return false
      }

      // 3. Filtro por Categoria
      const isChild = checkIsChild(p)
      const isCoveredRoot =
        !!p.is_presbyter || !!(p.spouse_id && presbyterIds.has(p.spouse_id))
      if (filterCategory === "without_discipler") {
        if (isChild || p.discipler_id || isCoveredRoot) return false
      } else if (filterCategory === "birthdays") {
        if (!isBirthdayThisMonth(p.birth_date)) return false
      } else if (filterCategory === "children") {
        if (!isChild) return false
      } else if (filterCategory === "adults") {
        if (isChild) return false
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
    filterCategory,
    presbyterIds,
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
      // Quando "Todos da Igreja", não incluir usuários de estudo
      return p.is_church_linked !== false
    })

    const isCoveredRoot = (p: Profile) =>
      !!p.is_presbyter || !!(p.spouse_id && presbyterIds.has(p.spouse_id))
    const total = baseList.length
    const withDiscipler = baseList.filter(
      (p) => !checkIsChild(p) && (!!p.discipler_id || isCoveredRoot(p))
    ).length
    const withoutDiscipler = baseList.filter(
      (p) => !checkIsChild(p) && !p.discipler_id && !isCoveredRoot(p)
    ).length
    const birthdays = baseList.filter((p) => isBirthdayThisMonth(p.birth_date)).length
    const children = baseList.filter((p) => checkIsChild(p)).length
    const adults = baseList.filter((p) => !checkIsChild(p)).length

    return { total, withDiscipler, withoutDiscipler, birthdays, children, adults }
  }, [profiles, singleGroupMode, isTier3, myHomeGroup, selectedGroupFilter, presbyterIds])

  // Opções para o seletor com pesquisa de Grupo Caseiro
  const groupFilterOptions: SearchableSelectOption[] = useMemo(() => {
    const linkedCount = profiles.filter((p) => p.is_church_linked !== false).length
    const unlinkedCount = profiles.filter((p) => p.is_church_linked === false).length

    const list: SearchableSelectOption[] = [
      {
        value: "all",
        label: `Todos da Igreja (${linkedCount})`,
        description: "Panorama geral de todos os discípulos vinculados",
        keywords: "todos geral igreja corpo",
      },
      {
        value: "unlinked",
        label: `Visitantes nos Estudos (${unlinkedCount})`,
        description: "Pessoas em acolhimento nos estudos bíblicos",
        keywords: "visitantes estudos bíblicos acolhimento",
      },
    ]

    homeGroups.forEach((hg) => {
      const count = profiles.filter((p) => p.home_group_id === hg.id).length
      const leaders = getHomeGroupLeadersName(hg, profileMap)
      const displayName = getHomeGroupDisplayName(hg, profileMap)
      const loc = hg.location_text ? hg.location_text.split("-")[0].trim() : ""
      const sector = hg.sector_id ? sectorMap.get(hg.sector_id)?.name : undefined

      list.push({
        value: hg.id,
        label: `${displayName} (${count})`,
        description: loc
          ? `${loc} • ${count} ${count === 1 ? "discípulo" : "discípulos"}`
          : `${count} ${count === 1 ? "discípulo" : "discípulos"}`,
        badge: sector,
        keywords: `${leaders} ${hg.location_text || ""} ${sector || ""}`,
      })
    })

    return list
  }, [profiles, homeGroups, profileMap, sectorMap])

  // Abertura dos modais
  const handleOpenAddDisciple = () => {
    setEditingDisciple(null)
    setTransformToBaptizedOnOpen(false)
    setTransformToLinkedOnOpen(false)
    setIsDiscipleDialogOpen(true)
  }

  const handleOpenEditDisciple = (disciple: Profile) => {
    setEditingDisciple(disciple)
    setTransformToBaptizedOnOpen(false)
    setTransformToLinkedOnOpen(false)
    setIsDiscipleDialogOpen(true)
  }

  const handleOpenTransformBaptism = (disciple: Profile) => {
    setEditingDisciple(disciple)
    setTransformToBaptizedOnOpen(true)
    setTransformToLinkedOnOpen(false)
    setIsDiscipleDialogOpen(true)
  }

  const handleOpenTransformToLinked = (disciple: Profile) => {
    setEditingDisciple(disciple)
    setTransformToBaptizedOnOpen(false)
    setTransformToLinkedOnOpen(true)
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
              {singleGroupMode
                ? "Acesso Exclusivo do Grupo"
                : isTier3
                ? "Visão Geral do Corpo"
                : myHomeGroup
                ? getHomeGroupDisplayName(myHomeGroup, profileMap)
                : "Seu Grupo Caseiro"}
            </Badge>
          </div>
          <h1 className="mt-1 text-2xl font-bold tracking-tight text-foreground sm:text-3xl">
            Gestão do Corpo e Cuidado Mútuo
          </h1>
          <p className="text-xs sm:text-sm text-muted-foreground">
            {isTier3
              ? "Acompanhamento fraternal dos irmãos, grupos caseiros e cuidado com cada vida na cidade."
              : "Cuidado dos irmãos do Grupo Caseiro e fortalecimento da comunhão no dia a dia."}
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
                  <Network className="h-4 w-4 text-primary" />
                  <span>Mapa Visual da Rede</span>
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
          initialGroupId={
            requestedGroupId ||
            (activeTab === "meu_grupo"
              ? myHomeGroup?.id
              : selectedGroupFilter !== "all" &&
                selectedGroupFilter !== "unlinked" &&
                selectedGroupFilter !== "my_or_all"
              ? selectedGroupFilter
              : undefined)
          }
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
                    <span className="text-xs font-semibold text-foreground">
                      Filtrar por Grupo Caseiro:
                    </span>
                  </div>
                  <div className="w-full sm:w-80">
                    <SearchableSelect
                      options={groupFilterOptions}
                      value={selectedGroupFilter}
                      onValueChange={setSelectedGroupFilter}
                      placeholder="Buscar grupo por líder ou bairro..."
                      clearable={false}
                    />
                  </div>
                </div>
              )}

              {/* Card de Informações: KPIs da Igreja (quando "Todos da Igreja") OU Visitantes OU Grupo Caseiro Focado */}
              {selectedGroupFilter === "all" ? (
                <div className="space-y-3">
                  <div className="flex flex-col gap-1 sm:flex-row sm:items-center sm:justify-between px-1">
                    <div className="flex items-center gap-2">
                      <Badge
                        variant="outline"
                        className="border-primary/30 bg-primary/10 text-primary text-[11px] font-medium"
                      >
                        Igreja em Belo Horizonte
                      </Badge>
                      <span className="text-xs text-muted-foreground">
                        Panorama da Comunhão
                      </span>
                    </div>
                    <span className="text-xs font-semibold text-foreground">
                      {churchKpis.totalDisciples} vidas cadastradas
                    </span>
                  </div>

                  <div className="grid grid-cols-1 min-[420px]:grid-cols-2 lg:grid-cols-4 gap-3">
                    {/* KPI 1: Discípulos */}
                    <button
                      type="button"
                      onClick={() => setFilterCategory("all")}
                      className={`text-left rounded-2xl border p-4 shadow-2xs flex flex-col justify-between transition-all hover:border-primary/50 cursor-pointer ${
                        filterCategory === "all"
                          ? "border-primary bg-primary/5 ring-1 ring-primary/30"
                          : "border-border/80 bg-card hover:bg-muted/40"
                      }`}
                    >
                      <div className="flex items-center justify-between">
                        <span className="text-xs font-semibold text-foreground flex items-center gap-1.5">
                          <Users className="h-3.5 w-3.5 text-primary" />
                          Irmãos no Corpo
                        </span>
                        <Badge variant="outline" className="text-[10px] px-1.5 py-0 font-medium border-border/60">
                          Total
                        </Badge>
                      </div>
                      <div className="mt-2.5">
                        <div className="text-2xl font-bold tracking-tight text-foreground">
                          {churchKpis.totalDisciples}
                        </div>
                        <p className="mt-0.5 text-[11px] text-muted-foreground truncate">
                          {churchKpis.adultCount} adultos • {churchKpis.childrenCount} crianças
                        </p>
                      </div>
                    </button>

                    {/* KPI 2: Grupos Caseiros */}
                    <button
                      type="button"
                      onClick={() => setActiveTab("outros_grupos")}
                      className="text-left rounded-2xl border border-border/80 bg-card p-4 shadow-2xs flex flex-col justify-between transition-all hover:border-primary/50 hover:bg-muted/40 cursor-pointer"
                    >
                      <div className="flex items-center justify-between">
                        <span className="text-xs font-semibold text-foreground flex items-center gap-1.5">
                          <MapPin className="h-3.5 w-3.5 text-primary" />
                          Grupos Caseiros
                        </span>
                        <Badge variant="outline" className="text-[10px] px-1.5 py-0 font-medium border-border/60">
                          {churchKpis.totalSectors} setores
                        </Badge>
                      </div>
                      <div className="mt-2.5">
                        <div className="text-2xl font-bold tracking-tight text-foreground">
                          {churchKpis.totalGroups}
                        </div>
                        <p className="mt-0.5 text-[11px] text-muted-foreground truncate">
                          Ver no mapa e diretório →
                        </p>
                      </div>
                    </button>

                    {/* KPI 3: Precisam de Discipulador */}
                    <button
                      type="button"
                      onClick={() => setFilterCategory("without_discipler")}
                      className={`text-left rounded-2xl border p-4 shadow-2xs flex flex-col justify-between transition-all hover:border-amber-500/60 cursor-pointer ${
                        filterCategory === "without_discipler"
                          ? "border-amber-500 bg-amber-500/10 ring-1 ring-amber-500/40"
                          : "border-amber-500/30 bg-amber-500/5 hover:bg-amber-500/10"
                      }`}
                    >
                      <div className="flex items-center justify-between">
                        <span className="text-xs font-semibold text-amber-900 dark:text-amber-200 flex items-center gap-1.5">
                          <HeartHandshake className="h-3.5 w-3.5 text-amber-600 dark:text-amber-400" />
                          Sem Discipulador
                        </span>
                        <Badge
                          variant="outline"
                          className="text-[10px] px-1.5 py-0 font-semibold border-amber-500/40 bg-amber-500/20 text-amber-800 dark:text-amber-300"
                        >
                          Atenção
                        </Badge>
                      </div>
                      <div className="mt-2.5">
                        <div className="text-2xl font-bold tracking-tight text-amber-900 dark:text-amber-200">
                          {churchKpis.withoutDiscipler}
                        </div>
                        <p className="mt-0.5 text-[11px] text-amber-700/80 dark:text-amber-300/80 truncate">
                          {churchKpis.discipleshipRate}% acompanhados • clique para filtrar
                        </p>
                      </div>
                    </button>

                    {/* KPI 4: Aniversariantes do Mês */}
                    <button
                      type="button"
                      onClick={() => setFilterCategory("birthdays")}
                      className={`text-left rounded-2xl border p-4 shadow-2xs flex flex-col justify-between transition-all hover:border-primary/50 cursor-pointer ${
                        filterCategory === "birthdays"
                          ? "border-primary bg-primary/10 ring-1 ring-primary/40"
                          : "border-border/80 bg-card hover:bg-muted/40"
                      }`}
                    >
                      <div className="flex items-center justify-between">
                        <span className="text-xs font-semibold text-foreground flex items-center gap-1.5">
                          <Cake className="h-3.5 w-3.5 text-primary" />
                          Aniversariantes
                        </span>
                        <Badge variant="outline" className="text-[10px] px-1.5 py-0 font-medium border-border/60">
                          Este mês
                        </Badge>
                      </div>
                      <div className="mt-2.5">
                        <div className="text-2xl font-bold tracking-tight text-foreground">
                          {churchKpis.birthdaysCount}
                        </div>
                        <p className="mt-0.5 text-[11px] text-muted-foreground truncate">
                          Para parabenizar e orar juntos
                        </p>
                      </div>
                    </button>
                  </div>
                </div>
              ) : selectedGroupFilter === "unlinked" ? (
                <div className="rounded-2xl border border-border/80 bg-card p-4 sm:p-5 shadow-2xs">
                  <div className="flex items-center gap-2">
                    <Badge
                      variant="outline"
                      className={`${THEME_CLASSES.badgePriority} text-[11px] font-medium`}
                    >
                      Estudos Bíblicos
                    </Badge>
                    <span className="text-xs text-muted-foreground">
                      {counts.total} pessoa(s) em acolhimento
                    </span>
                  </div>
                  <h2 className="mt-1 text-lg font-bold text-foreground sm:text-xl">
                    Visitantes nos Estudos
                  </h2>
                  <p className="mt-1 text-xs text-muted-foreground">
                    Pessoas que estão participando das reuniões nas casas e conhecendo a palavra antes do vínculo pleno.
                  </p>
                </div>
              ) : currentFocusedGroup ? (
                <div className="rounded-2xl border border-border/80 bg-card p-4 sm:p-5 shadow-sm space-y-3">
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
                        {getHomeGroupDisplayName(currentFocusedGroup, profileMap)}
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

                  {/* 3 mini cards rápidos do grupo */}
                  <div className="grid grid-cols-3 gap-2 pt-1 border-t border-border/50">
                    <button
                      type="button"
                      onClick={() => setFilterCategory("all")}
                      className={`rounded-xl p-2.5 text-center border transition-all cursor-pointer ${
                        filterCategory === "all"
                          ? "border-primary bg-primary/10 text-primary"
                          : "border-border/60 bg-muted/30 text-muted-foreground hover:bg-muted/60"
                      }`}
                    >
                      <div className="text-lg font-bold text-foreground">{counts.total}</div>
                      <div className="text-[11px]">Irmãos no Grupo</div>
                    </button>

                    <button
                      type="button"
                      onClick={() => setFilterCategory("without_discipler")}
                      className={`rounded-xl p-2.5 text-center border transition-all cursor-pointer ${
                        filterCategory === "without_discipler"
                          ? "border-amber-500 bg-amber-500/15 text-amber-800 dark:text-amber-300 font-semibold"
                          : "border-border/60 bg-muted/30 text-muted-foreground hover:bg-muted/60"
                      }`}
                    >
                      <div className="text-lg font-bold text-amber-700 dark:text-amber-400">{counts.withoutDiscipler}</div>
                      <div className="text-[11px]">Sem Discipulador</div>
                    </button>

                    <button
                      type="button"
                      onClick={() => setFilterCategory("birthdays")}
                      className={`rounded-xl p-2.5 text-center border transition-all cursor-pointer ${
                        filterCategory === "birthdays"
                          ? "border-primary bg-primary/15 text-primary font-semibold"
                          : "border-border/60 bg-muted/30 text-muted-foreground hover:bg-muted/60"
                      }`}
                    >
                      <div className="text-lg font-bold text-foreground">{counts.birthdays}</div>
                      <div className="text-[11px]">Aniversariantes</div>
                    </button>
                  </div>
                </div>
              ) : null}

              {/* Botão Grande "+ Cadastrar Novo Irmão" (Min Height 48px) */}
              <Button
                type="button"
                onClick={handleOpenAddDisciple}
                className="h-12 min-h-[48px] w-full gap-2 rounded-xl text-sm font-semibold shadow-xs"
              >
                <Plus className="h-5 w-5" />
                <span>
                  {currentFocusedGroup ? "Cadastrar Novo Irmão no Grupo" : "Cadastrar Novo Irmão"}
                </span>
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

                {/* Chips de Filtro Simples e Diretos (Touch targets >= 44px) */}
                <div className="no-scrollbar flex items-center gap-2 overflow-x-auto pb-1">
                  <button
                    type="button"
                    onClick={() => setFilterCategory("all")}
                    className={`min-h-[44px] shrink-0 rounded-full px-4 py-2 text-xs font-semibold transition-all cursor-pointer ${
                      filterCategory === "all"
                        ? "bg-foreground text-background shadow-xs"
                        : "border border-border/80 bg-card text-muted-foreground hover:bg-muted/60"
                    }`}
                  >
                    Todos ({counts.total})
                  </button>

                  <button
                    type="button"
                    onClick={() => setFilterCategory("without_discipler")}
                    className={`min-h-[44px] shrink-0 rounded-full px-4 py-2 text-xs font-semibold transition-all inline-flex items-center gap-1.5 cursor-pointer ${
                      filterCategory === "without_discipler"
                        ? "bg-amber-600 text-white shadow-xs"
                        : "border border-amber-500/30 bg-amber-500/10 text-amber-800 dark:text-amber-300 hover:bg-amber-500/20"
                    }`}
                  >
                    <AlertCircle className="h-3.5 w-3.5" />
                    <span>Sem Discipulador ({counts.withoutDiscipler})</span>
                  </button>

                  <button
                    type="button"
                    onClick={() => setFilterCategory("birthdays")}
                    className={`min-h-[44px] shrink-0 rounded-full px-4 py-2 text-xs font-semibold transition-all inline-flex items-center gap-1.5 cursor-pointer ${
                      filterCategory === "birthdays"
                        ? "bg-primary text-primary-foreground shadow-xs"
                        : "border border-primary/20 bg-primary/10 text-primary hover:bg-primary/20"
                    }`}
                  >
                    <Cake className="h-3.5 w-3.5" />
                    <span>Aniversariantes do Mês ({counts.birthdays})</span>
                  </button>

                  <button
                    type="button"
                    onClick={() => setFilterCategory("children")}
                    className={`min-h-[44px] shrink-0 rounded-full px-4 py-2 text-xs font-semibold transition-all inline-flex items-center gap-1.5 cursor-pointer ${
                      filterCategory === "children"
                        ? "bg-foreground text-background shadow-xs"
                        : "border border-border/80 bg-card text-muted-foreground hover:bg-muted/60"
                    }`}
                  >
                    <Baby className="h-3.5 w-3.5" />
                    <span>Crianças ({counts.children})</span>
                  </button>

                  <button
                    type="button"
                    onClick={() => setFilterCategory("adults")}
                    className={`min-h-[44px] shrink-0 rounded-full px-4 py-2 text-xs font-semibold transition-all cursor-pointer ${
                      filterCategory === "adults"
                        ? "bg-foreground text-background shadow-xs"
                        : "border border-border/80 bg-card text-muted-foreground hover:bg-muted/60"
                    }`}
                  >
                    Adultos ({counts.adults})
                  </button>
                </div>
              </div>

              {/* Lista de Cards dos Irmãos */}
              {filteredDisciples.length === 0 ? (
                <div className="rounded-2xl border border-dashed border-border p-8 text-center space-y-3">
                  <Users className="mx-auto h-10 w-10 text-muted-foreground/50" />
                  <div>
                    <h3 className="text-sm font-semibold text-foreground">
                      Nenhum irmão encontrado
                    </h3>
                    <p className="mt-1 text-xs text-muted-foreground">
                      {searchName || filterCategory !== "all"
                        ? "Nenhum irmão corresponde aos filtros aplicados."
                        : "Cadastre o primeiro irmão para iniciar o acompanhamento deste grupo."}
                    </p>
                  </div>
                  {(searchName || filterCategory !== "all") && (
                    <Button
                      type="button"
                      variant="outline"
                      onClick={() => {
                        setSearchName("")
                        setFilterCategory("all")
                      }}
                      className="h-11 min-h-[44px] text-xs font-semibold rounded-xl"
                    >
                      Limpar Filtros e Ver Todos
                    </Button>
                  )}
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
                    const discipleGroup = disciple.home_group_id
                      ? homeGroups.find((g) => g.id === disciple.home_group_id)
                      : null
                    const groupName =
                      selectedGroupFilter === "all" && discipleGroup
                        ? getHomeGroupDisplayName(discipleGroup, profileMap)
                        : null

                    const isCoveredRoot =
                      !!disciple.is_presbyter || !!(disciple.spouse_id && presbyterIds.has(disciple.spouse_id))

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
                        groupName={groupName}
                        isCoveredRoot={isCoveredRoot}
                        onEdit={handleOpenEditDisciple}
                        onTransformChild={handleOpenTransformBaptism}
                        onTransformToLinked={handleOpenTransformToLinked}
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
                    className="h-11 min-h-[44px] gap-1.5 rounded-xl text-xs font-medium"
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
          if (!open) {
            setTransformToBaptizedOnOpen(false)
            setTransformToLinkedOnOpen(false)
          }
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
        initialTransformToLinked={transformToLinkedOnOpen}
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
