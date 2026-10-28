import React, { useState, useRef, useMemo, useEffect, useCallback } from "react"
import {
  ZoomIn,
  ZoomOut,
  Maximize2,
  Minimize2,
  X,
  GitBranch,
  Home,
  HeartHandshake,
  Search,
  Focus,
  RotateCcw,
  Users,
  AlertCircle,
  MessageSquare,
  Edit,
  ChevronRight,
  Filter,
  Eye,
  UserCheck,
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
  SearchableSelect,
  type SearchableSelectOption,
} from "@/components/ui/searchable-select"
import type { Database } from "@/lib/database.types"
import {
  RELATIONSHIP_NODE_COLORS,
  GRAPH_LINK_COLORS,
  GRAPH_CANVAS_COLORS,
  GRAPH_UI_CLASSES,
  THEME_CLASSES,
  type RelationshipNodeRole,
} from "@/constants/colors"
import { getHomeGroupDisplayName } from "@/lib/homeGroupUtils"

type Profile = Database["public"]["Tables"]["profiles"]["Row"]
type HomeGroup = Database["public"]["Tables"]["home_groups"]["Row"]
type Fellowship = Database["public"]["Tables"]["fellowships"]["Row"]
type Sector = Database["public"]["Tables"]["sectors"]["Row"]

export type GraphLayoutMode = "hierarchy" | "groups" | "fellowships"
export type DiagnosticFilter =
  | "all"
  | "no_discipler"
  | "no_fellowship"
  | "overloaded"
  | "potential_disciplers"

interface GraphNode {
  id: string
  name: string
  shortName: string
  initials: string
  avatarUrl: string | null
  role: RelationshipNodeRole
  gender: string | null
  homeGroupId: string | null
  homeGroupName: string | null
  sectorId: string | null
  sector: string
  neighborhood: string | null
  phone: string | null
  email: string | null
  baptismDate: string | null
  disciplerId: string | null
  spouseId: string | null
  fatherId: string | null
  motherId: string | null
  isPresbyter: boolean
  isPresbyterSpouse: boolean
  isDeacon: boolean
  isLeader: boolean
  isChild: boolean
  directDisciplesCount: number
  totalLineageCount: number
  fellowshipsCount: number
  fellowshipPartnerIds: string[]
  hasNoDisciplerAlert: boolean
  hasNoFellowshipAlert: boolean
  isOverloaded: boolean
  isPotentialDiscipler: boolean
  level: number
  x: number
  y: number
}

interface GraphLink {
  source: string
  target: string
  type: "discipler" | "fellowship" | "marriage" | "parent"
}

interface ClusterZone {
  id: string
  title: string
  subtitle: string
  x: number
  y: number
  width: number
  height: number
  shape: "rect" | "circle"
  radius?: number
  isWarning?: boolean
}

interface LayoutResult {
  nodes: GraphNode[]
  zones: ClusterZone[]
}

interface TidyTreeNode {
  id: string
  graphNode: GraphNode
  parent: TidyTreeNode | null
  children: TidyTreeNode[]
  depth: number
  subtreeWidth: number
  maxSubtreeHeight: number
  x: number
  y: number
}

function formatShortName(fullName: string): string {
  const parts = fullName.trim().split(/\s+/).filter(Boolean)
  if (parts.length === 0) return "Irmão"
  if (parts.length === 1) return parts[0]
  const first = parts[0]
  const lastInitial = parts[parts.length - 1][0]?.toUpperCase() || ""
  return `${first} ${lastInitial}.`
}

function formatInitials(fullName: string): string {
  const parts = fullName.trim().split(/\s+/).filter(Boolean)
  if (parts.length === 0) return "?"
  if (parts.length === 1) return parts[0].slice(0, 2).toUpperCase()
  return `${parts[0][0] || ""}${parts[parts.length - 1][0] || ""}`.toUpperCase()
}

function createsTreeCycle(parent: TidyTreeNode, candidateChild: TidyTreeNode): boolean {
  let curr: TidyTreeNode | null = parent
  while (curr !== null) {
    if (curr.id === candidateChild.id) return true
    curr = curr.parent
  }
  return false
}

/**
 * 1. LAYOUT HIERÁRQUICO (Árvore de Discipulado - Tidy Tree Bottom-Up + Top-Down com Compactação de Folhas)
 * Garante espaçamento horizontal real por largura de subárvore (zero sobreposição),
 * empilha grupos de folhas verticalmente em 2 colunas para reduzir a largura extrema
 * e organiza múltiplas árvores raízes em grade balanceada com zonas identificadas.
 */
function computeTidyHierarchyLayout(nodes: GraphNode[]): LayoutResult {
  if (nodes.length === 0) return { nodes: [], zones: [] }

  const NODE_SPACING_X = 88
  const SIBLING_GAP = 14
  const LEVEL_HEIGHT = 122
  const LEAF_COL_GAP = 86
  const LEAF_ROW_GAP = 66

  const nodeMap = new Map<string, GraphNode>(nodes.map((n) => [n.id, n]))
  const treeNodeMap = new Map<string, TidyTreeNode>()

  nodes.forEach((n) => {
    treeNodeMap.set(n.id, {
      id: n.id,
      graphNode: n,
      parent: null,
      children: [],
      depth: 0,
      subtreeWidth: NODE_SPACING_X,
      maxSubtreeHeight: 0,
      x: 0,
      y: 0,
    })
  })

  // Conectar vínculos de discipulado (e pais para crianças não batizadas)
  nodes.forEach((n) => {
    const childTN = treeNodeMap.get(n.id)
    if (!childTN) return

    let parentId = n.disciplerId
    if (!parentId && n.isChild) {
      parentId =
        (n.fatherId && nodeMap.has(n.fatherId) ? n.fatherId : null) ||
        (n.motherId && nodeMap.has(n.motherId) ? n.motherId : null)
    }

    if (parentId && parentId !== n.id) {
      const parentTN = treeNodeMap.get(parentId)
      if (parentTN && childTN.parent === null && !createsTreeCycle(parentTN, childTN)) {
        childTN.parent = parentTN
        parentTN.children.push(childTN)
      }
    }
  })

  // Ordenar filhos de cada nó por papel e nome para leitura consistente
  const roleWeight = (r: RelationshipNodeRole) => {
    if (r === "presbyter") return 0
    if (r === "deacon") return 1
    if (r === "leader") return 2
    if (r === "discipler") return 3
    if (r === "disciple") return 4
    return 5
  }

  treeNodeMap.forEach((tn) => {
    tn.children.sort((a, b) => {
      const rw = roleWeight(a.graphNode.role) - roleWeight(b.graphNode.role)
      if (rw !== 0) return rw
      return b.children.length - a.children.length || a.graphNode.name.localeCompare(b.graphNode.name)
    })
  })

  const allRoots = Array.from(treeNodeMap.values()).filter((tn) => tn.parent === null)

  // Separar raízes que possuem subárvore (ou são presbíteros/liderança) de nós soltos
  const activeTreeRoots: TidyTreeNode[] = []
  const standaloneNoDiscipler: TidyTreeNode[] = []
  const standaloneCoveredOutsideView: TidyTreeNode[] = []

  allRoots.forEach((r) => {
    if (
      r.children.length > 0 ||
      r.graphNode.isPresbyter ||
      r.graphNode.isPresbyterSpouse
    ) {
      activeTreeRoots.push(r)
    } else if (r.graphNode.hasNoDisciplerAlert) {
      standaloneNoDiscipler.push(r)
    } else {
      standaloneCoveredOutsideView.push(r)
    }
  })

  const countDescendants = (tn: TidyTreeNode): number =>
    1 + tn.children.reduce((acc, c) => acc + countDescendants(c), 0)

  activeTreeRoots.sort((a, b) => {
    const rw = roleWeight(a.graphNode.role) - roleWeight(b.graphNode.role)
    if (rw !== 0) return rw
    if (a.graphNode.gender !== b.graphNode.gender) {
      return (a.graphNode.gender || "").localeCompare(b.graphNode.gender || "")
    }
    return countDescendants(b) - countDescendants(a)
  })

  // Passo 1: Cálculo Bottom-Up da largura e altura real de cada subárvore
  // Quando todos os filhos de um nó são folhas (>= 2), empilhamos em 2 colunas compactas
  const isCompactLeafGroup = (tn: TidyTreeNode): boolean =>
    tn.children.length >= 2 && tn.children.every((c) => c.children.length === 0)

  const computeMetrics = (
    tn: TidyTreeNode,
    depth: number
  ): { width: number; maxDepth: number; maxYOffset: number } => {
    tn.depth = depth
    const selfYOffset = depth * LEVEL_HEIGHT

    if (tn.children.length === 0) {
      tn.subtreeWidth = NODE_SPACING_X
      tn.maxSubtreeHeight = selfYOffset
      return { width: NODE_SPACING_X, maxDepth: depth, maxYOffset: selfYOffset }
    }

    if (isCompactLeafGroup(tn)) {
      const cols = Math.min(2, tn.children.length)
      const rows = Math.ceil(tn.children.length / cols)
      tn.children.forEach((c) => {
        c.depth = depth + 1
        c.subtreeWidth = NODE_SPACING_X
        c.maxSubtreeHeight = (depth + 1) * LEVEL_HEIGHT
      })
      tn.subtreeWidth = Math.max(
        NODE_SPACING_X,
        cols * LEAF_COL_GAP + 14
      )
      const maxLeafY =
        (depth + 1) * LEVEL_HEIGHT + Math.max(0, rows - 1) * LEAF_ROW_GAP
      tn.maxSubtreeHeight = maxLeafY
      return {
        width: tn.subtreeWidth,
        maxDepth: depth + 1,
        maxYOffset: maxLeafY,
      }
    }

    let totalW = 0
    let maxD = depth
    let maxY = selfYOffset
    tn.children.forEach((c, idx) => {
      const childStats = computeMetrics(c, depth + 1)
      totalW += childStats.width
      if (idx > 0) totalW += SIBLING_GAP
      if (childStats.maxDepth > maxD) maxD = childStats.maxDepth
      if (childStats.maxYOffset > maxY) maxY = childStats.maxYOffset
    })
    tn.subtreeWidth = Math.max(NODE_SPACING_X, totalW)
    tn.maxSubtreeHeight = maxY
    return { width: tn.subtreeWidth, maxDepth: maxD, maxYOffset: maxY }
  }

  // Passo 2: Posicionamento Top-Down sem sobreposição
  const assignCoords = (tn: TidyTreeNode, leftX: number, topY: number) => {
    tn.y = topY + tn.depth * LEVEL_HEIGHT
    if (tn.children.length === 0) {
      tn.x = leftX + tn.subtreeWidth / 2
      return
    }

    if (isCompactLeafGroup(tn)) {
      const centerX = leftX + tn.subtreeWidth / 2
      tn.x = centerX
      const cols = Math.min(2, tn.children.length)
      const baseChildY = topY + (tn.depth + 1) * LEVEL_HEIGHT
      tn.children.forEach((c, idx) => {
        const col = idx % cols
        const row = Math.floor(idx / cols)
        const isSingleInLastRow =
          idx === tn.children.length - 1 && tn.children.length % 2 === 1
        const offsetX = isSingleInLastRow
          ? 0
          : (col - (cols - 1) / 2) * LEAF_COL_GAP
        c.x = centerX + offsetX
        c.y = baseChildY + row * LEAF_ROW_GAP
      })
      return
    }

    let cursorX = leftX
    tn.children.forEach((c) => {
      assignCoords(c, cursorX, topY)
      cursorX += c.subtreeWidth + SIBLING_GAP
    })
    const firstChild = tn.children[0]
    const lastChild = tn.children[tn.children.length - 1]
    tn.x = (firstChild.x + lastChild.x) / 2
  }

  const zones: ClusterZone[] = []
  const resultNodes: GraphNode[] = []

  // Empacotar árvores em linhas balanceadas para um aspect-ratio próximo de 16:9
  const treeMetrics = activeTreeRoots.map((root) => {
    const stats = computeMetrics(root, 0)
    const totalCount = countDescendants(root)
    return {
      root,
      width: stats.width,
      levels: stats.maxDepth + 1,
      height: stats.maxYOffset + 145,
      totalCount,
    }
  })

  const maxSingleTreeWidth = treeMetrics.reduce(
    (maxW, m) => Math.max(maxW, m.width + 80),
    1500
  )
  const totalTreesWidth = treeMetrics.reduce((acc, m) => acc + m.width + 72, 0)
  const targetRowMaxWidth = Math.max(
    maxSingleTreeWidth,
    Math.min(3600, Math.sqrt(totalTreesWidth * 2100))
  )

  let currentX = 80
  let currentY = 80
  let currentRowMaxHeight = 0

  const flattenTree = (tn: TidyTreeNode) => {
    resultNodes.push({
      ...tn.graphNode,
      level: tn.depth,
      x: tn.x,
      y: tn.y,
    })
    tn.children.forEach(flattenTree)
  }

  treeMetrics.forEach((tm) => {
    if (currentX > 80 && currentX + tm.width + 72 > targetRowMaxWidth) {
      currentX = 80
      currentY += currentRowMaxHeight + 90
      currentRowMaxHeight = 0
    }

    const treePaddingX = 34
    const treeSlotWidth = Math.max(200, tm.width + treePaddingX * 2)
    const treeHeight = tm.height

    const treeStartLeft = currentX + (treeSlotWidth - tm.width) / 2
    assignCoords(tm.root, treeStartLeft, currentY + 24)
    flattenTree(tm.root)

    currentX += treeSlotWidth + 54
    if (treeHeight > currentRowMaxHeight) {
      currentRowMaxHeight = treeHeight
    }
  })

  // Posicionar irmãos cujo discipulador está fora do filtro atual (ex: em outro GC)
  let nextSectionY =
    treeMetrics.length > 0 ? currentY + currentRowMaxHeight + 90 : 80

  if (standaloneCoveredOutsideView.length > 0) {
    const cols = Math.min(10, Math.max(4, Math.ceil(Math.sqrt(standaloneCoveredOutsideView.length * 2))))
    const rows = Math.ceil(standaloneCoveredOutsideView.length / cols)
    const cellW = 115
    const cellH = 95
    const boxW = Math.max(320, cols * cellW + 64)
    const boxH = rows * cellH + 90

    zones.push({
      id: "zone_covered_outside",
      title: "Discipulador em Outro Grupo / Setor",
      subtitle: `${standaloneCoveredOutsideView.length} ${
        standaloneCoveredOutsideView.length === 1 ? "irmão acompanhado" : "irmãos acompanhados"
      } fora deste recorte`,
      x: 80,
      y: nextSectionY,
      width: boxW,
      height: boxH,
      shape: "rect",
    })

    standaloneCoveredOutsideView.forEach((tn, idx) => {
      const col = idx % cols
      const row = Math.floor(idx / cols)
      resultNodes.push({
        ...tn.graphNode,
        level: 0,
        x: 80 + 32 + col * cellW + cellW / 2,
        y: nextSectionY + 78 + row * cellH,
      })
    })

    nextSectionY += boxH + 80
  }

  // Posicionar irmãos SEM DISCIPULADOR em zona de alerta pastoral destacada
  if (standaloneNoDiscipler.length > 0) {
    const cols = Math.min(10, Math.max(4, Math.ceil(Math.sqrt(standaloneNoDiscipler.length * 2))))
    const rows = Math.ceil(standaloneNoDiscipler.length / cols)
    const cellW = 115
    const cellH = 95
    const boxW = Math.max(340, cols * cellW + 64)
    const boxH = rows * cellH + 90

    zones.push({
      id: "zone_no_discipler",
      title: "Atenção Pastoral: Sem Discipulador Definido",
      subtitle: `${standaloneNoDiscipler.length} ${
        standaloneNoDiscipler.length === 1
          ? "irmão aguardando vínculo"
          : "irmãos aguardando vínculo de cuidado"
      }`,
      x: 80,
      y: nextSectionY,
      width: boxW,
      height: boxH,
      shape: "rect",
      isWarning: true,
    })

    standaloneNoDiscipler.forEach((tn, idx) => {
      const col = idx % cols
      const row = Math.floor(idx / cols)
      resultNodes.push({
        ...tn.graphNode,
        level: 0,
        x: 80 + 32 + col * cellW + cellW / 2,
        y: nextSectionY + 78 + row * cellH,
      })
    })
  }

  return { nodes: resultNodes, zones }
}

/**
 * 2. LAYOUT POR GRUPOS CASEIROS (Clusters de Oikos)
 * Agrupa irmãos por Grupo Caseiro em círculos comunitários organizados,
 * reservando folga vertical superior para o título e intercalando anéis.
 */
function computeGroupsClusterLayout(nodes: GraphNode[]): LayoutResult {
  if (nodes.length === 0) return { nodes: [], zones: [] }

  const groupBuckets = new Map<
    string,
    { id: string; name: string; sector: string; members: GraphNode[] }
  >()

  nodes.forEach((n) => {
    const key = n.homeGroupId || "sem_grupo"
    const existing = groupBuckets.get(key)
    if (existing) {
      existing.members.push(n)
    } else {
      groupBuckets.set(key, {
        id: key,
        name: n.homeGroupName || "Sem Grupo Caseiro",
        sector: n.sector || "Geral",
        members: [n],
      })
    }
  })

  const clusters = Array.from(groupBuckets.values()).sort((a, b) => {
    if (a.id === "sem_grupo") return 1
    if (b.id === "sem_grupo") return -1
    const secCmp = a.sector.localeCompare(b.sector)
    if (secCmp !== 0) return secCmp
    return a.name.localeCompare(b.name)
  })

  const cols = Math.max(1, Math.ceil(Math.sqrt(clusters.length * 1.45)))
  const zones: ClusterZone[] = []
  const resultNodes: GraphNode[] = []

  // Calcular anéis concêntricos de cada cluster garantindo distância mínima de arco >= 56px
  // e folga superior suficiente para o cabeçalho do círculo não colidir com o nó das 12h.
  const clusterRingPlans = clusters.map((c) => {
    const count = c.members.length
    if (count <= 1) {
      return { outerRadius: 130, rings: [0] }
    }
    if (count <= 10) {
      const r = Math.max(82, count * 11)
      return { outerRadius: r + 64, rings: [r] }
    }
    const rings: number[] = []
    let remaining = count
    let currentR = 76
    while (remaining > 0) {
      const cap = Math.max(6, Math.floor((2 * Math.PI * currentR) / 56))
      rings.push(currentR)
      remaining -= cap
      if (remaining > 0) currentR += 72
    }
    return { outerRadius: currentR + 68, rings }
  })

  const maxRadius = Math.max(...clusterRingPlans.map((p) => p.outerRadius), 160)
  const cellSpacingX = maxRadius * 2 + 64
  const cellSpacingY = maxRadius * 2 + 72

  clusters.forEach((cluster, cIdx) => {
    const col = cIdx % cols
    const row = Math.floor(cIdx / cols)
    const plan = clusterRingPlans[cIdx]
    const radius = plan.outerRadius
    const centerX = 90 + radius + col * cellSpacingX
    const centerY = 100 + radius + row * cellSpacingY

    const cleanGroupTitle =
      clusters.length > 4
        ? cluster.name.replace(/^Grupo de\s+/i, "GC ")
        : cluster.name

    zones.push({
      id: `gc_${cluster.id}`,
      title: cleanGroupTitle,
      subtitle: `${cluster.sector} • ${cluster.members.length} ${
        cluster.members.length === 1 ? "irmão" : "irmãos"
      }`,
      x: centerX,
      y: centerY,
      width: radius * 2,
      height: radius * 2,
      shape: "circle",
      radius,
      isWarning: cluster.id === "sem_grupo",
    })

    // Ordenar membros para que casais fiquem adjacentes e líderes no topo
    const ordered: GraphNode[] = []
    const visited = new Set<string>()
    const memberMap = new Map(cluster.members.map((m) => [m.id, m]))

    const sortedSeeds = [...cluster.members].sort((a, b) => {
      const isLeadA = a.isPresbyter || a.isDeacon || a.isLeader ? 0 : 1
      const isLeadB = b.isPresbyter || b.isDeacon || b.isLeader ? 0 : 1
      if (isLeadA !== isLeadB) return isLeadA - isLeadB
      return a.name.localeCompare(b.name)
    })

    sortedSeeds.forEach((m) => {
      if (visited.has(m.id)) return
      visited.add(m.id)
      ordered.push(m)
      if (m.spouseId && memberMap.has(m.spouseId) && !visited.has(m.spouseId)) {
        visited.add(m.spouseId)
        ordered.push(memberMap.get(m.spouseId)!)
      }
    })

    const ringCenterY = centerY + 22
    const count = ordered.length
    if (count === 1) {
      resultNodes.push({ ...ordered[0], x: centerX, y: ringCenterY })
    } else if (plan.rings.length === 1) {
      const ringR = plan.rings[0]
      ordered.forEach((node, idx) => {
        const angle = -Math.PI / 2 + (idx * 2 * Math.PI) / count
        resultNodes.push({
          ...node,
          x: centerX + Math.cos(angle) * ringR,
          y: ringCenterY + Math.sin(angle) * ringR,
        })
      })
    } else {
      let cursor = 0
      plan.rings.forEach((ringR, rIdx) => {
        const isLastRing = rIdx === plan.rings.length - 1
        const cap = Math.max(6, Math.floor((2 * Math.PI * ringR) / 56))
        const sliceCount = isLastRing
          ? ordered.length - cursor
          : Math.min(cap, ordered.length - cursor)
        const slice = ordered.slice(cursor, cursor + sliceCount)
        cursor += sliceCount

        // Intercalar ângulo inicial entre anéis pares e ímpares para evitar colisão de rótulos
        const phaseOffset = rIdx % 2 === 1 ? Math.PI / Math.max(1, slice.length) : 0
        slice.forEach((node, idx) => {
          const angle = -Math.PI / 2 + phaseOffset + (idx * 2 * Math.PI) / slice.length
          resultNodes.push({
            ...node,
            x: centerX + Math.cos(angle) * ringR,
            y: ringCenterY + Math.sin(angle) * ringR,
          })
        })
      })
    }
  })

  return { nodes: resultNodes, zones }
}

/**
 * Ordena nós por adjacência de companheirismo (Greedy Neighbor Walk) para que
 * companheiros de obra fiquem lado a lado no anel e formem arcos curtos locais.
 */
function orderByFellowshipAdjacency(bandNodes: GraphNode[]): GraphNode[] {
  const byId = new Map(bandNodes.map((n) => [n.id, n]))
  const visited = new Set<string>()
  const ordered: GraphNode[] = []

  const seeds = [...bandNodes].sort(
    (a, b) =>
      a.sector.localeCompare(b.sector) ||
      (a.homeGroupName || "").localeCompare(b.homeGroupName || "") ||
      b.fellowshipsCount - a.fellowshipsCount ||
      a.name.localeCompare(b.name)
  )

  seeds.forEach((seed) => {
    if (visited.has(seed.id)) return
    const queue: GraphNode[] = [seed]
    visited.add(seed.id)
    while (queue.length > 0) {
      const curr = queue.shift()!
      ordered.push(curr)
      curr.fellowshipPartnerIds.forEach((pid) => {
        const partner = byId.get(pid)
        if (partner && !visited.has(partner.id)) {
          visited.add(partner.id)
          queue.push(partner)
        }
      })
    }
  })

  return ordered
}

/**
 * 3. LAYOUT REDE DE COMPANHEIRISMO (Rodas de Aliança Horizontal Conectadas)
 * Agrupa irmãos em Rodas de Companheirismo de anel único (10–16 irmãos conectados
 * por vínculos reais de companheirismo via busca em largura), eliminando teias cruzadas
 * e destacando duplas, trios e quartetos de cuidado mútuo.
 */
function computeFellowshipNetworkLayout(nodes: GraphNode[]): LayoutResult {
  if (nodes.length === 0) return { nodes: [], zones: [] }

  const resultNodes: GraphNode[] = []
  const zones: ClusterZone[] = []

  const byId = new Map(nodes.map((n) => [n.id, n]))
  const visited = new Set<string>()
  const MAX_WHEEL_SIZE = 14
  const MIN_WHEEL_MERGE = 6

  const roleSortWeight = (n: GraphNode) =>
    n.isPresbyter ? 0 : n.isPresbyterSpouse ? 1 : n.isDeacon ? 2 : n.isLeader ? 3 : 4

  const seeds = [...nodes].sort(
    (a, b) =>
      (a.gender || "").localeCompare(b.gender || "") ||
      roleSortWeight(a) - roleSortWeight(b) ||
      b.fellowshipsCount - a.fellowshipsCount ||
      a.name.localeCompare(b.name)
  )

  const rawGroups: { gender: string; members: GraphNode[] }[] = []

  seeds.forEach((seed) => {
    if (visited.has(seed.id)) return
    const group: GraphNode[] = []
    const queue: GraphNode[] = [seed]
    visited.add(seed.id)

    while (queue.length > 0 && group.length < MAX_WHEEL_SIZE) {
      const curr = queue.shift()!
      group.push(curr)
      curr.fellowshipPartnerIds.forEach((pid) => {
        if (group.length + queue.length >= MAX_WHEEL_SIZE) return
        const partner = byId.get(pid)
        if (
          partner &&
          !visited.has(partner.id) &&
          partner.gender === seed.gender
        ) {
          visited.add(partner.id)
          queue.push(partner)
        }
      })
    }

    rawGroups.push({ gender: seed.gender || "M", members: group })
  })

  // Consolidar micro-grupos do mesmo gênero para manter rodas equilibradas (8–15 irmãos)
  const wheels: { gender: string; members: GraphNode[] }[] = []
  rawGroups.forEach((g) => {
    const target = wheels.find(
      (w) =>
        w.gender === g.gender &&
        w.members.length < MIN_WHEEL_MERGE &&
        w.members.length + g.members.length <= MAX_WHEEL_SIZE
    )
    if (target) {
      target.members.push(...g.members)
    } else {
      wheels.push({ gender: g.gender, members: [...g.members] })
    }
  })

  const cols = Math.max(1, Math.ceil(Math.sqrt(wheels.length * 1.45)))

  const wheelRadii = wheels.map((w) => {
    const count = w.members.length
    const ringR = count <= 1 ? 0 : Math.max(78, count * 9.8)
    return { ringR, outerRadius: Math.max(132, ringR + 62) }
  })

  const maxRadius = Math.max(...wheelRadii.map((r) => r.outerRadius), 155)
  const cellSpacingX = maxRadius * 2 + 64
  const cellSpacingY = maxRadius * 2 + 72

  wheels.forEach((wheel, wIdx) => {
    const col = wIdx % cols
    const row = Math.floor(wIdx / cols)
    const { ringR, outerRadius } = wheelRadii[wIdx]
    const cx = 90 + outerRadius + col * cellSpacingX
    const cy = 100 + outerRadius + row * cellSpacingY

    const ordered = orderByFellowshipAdjacency(wheel.members)
    const anchor = ordered[0]
    const genderTag = wheel.gender === "F" ? "Irmãs (F)" : "Irmãos (M)"

    // Contar vínculos internos reais dentro desta roda
    const memberSet = new Set(ordered.map((m) => m.id))
    let internalBonds = 0
    ordered.forEach((m) => {
      m.fellowshipPartnerIds.forEach((pid) => {
        if (m.id < pid && memberSet.has(pid)) internalBonds++
      })
    })

    zones.push({
      id: `fellowship_wheel_${wIdx}`,
      title: anchor ? `Roda: ${anchor.shortName} & Pares` : `Roda #${wIdx + 1}`,
      subtitle: `${genderTag} • ${ordered.length} irmãos • ${internalBonds} alianças`,
      x: cx,
      y: cy,
      width: outerRadius * 2,
      height: outerRadius * 2,
      shape: "circle",
      radius: outerRadius,
    })

    const ringCenterY = cy + 20
    if (ordered.length === 1) {
      resultNodes.push({ ...ordered[0], x: cx, y: ringCenterY })
    } else {
      ordered.forEach((n, idx) => {
        const angle = -Math.PI / 2 + (idx * 2 * Math.PI) / ordered.length
        resultNodes.push({
          ...n,
          x: cx + Math.cos(angle) * ringR,
          y: ringCenterY + Math.sin(angle) * ringR,
        })
      })
    }
  })

  return { nodes: resultNodes, zones }
}

/**
 * 4. LAYOUT DE ISOLAMENTO DE JUNTA (Ego-Network / Raio-X Completo de 1 Irmão)
 * Posiciona a cadeia ascendente (quem discipula), o irmão ao centro com cônjuge e
 * companheiros de obra ao lado, e a árvore descendente abaixo.
 */
function computeIsolatedJuntaLayout(
  focusId: string,
  allNodes: GraphNode[]
): LayoutResult {
  const nodeMap = new Map(allNodes.map((n) => [n.id, n]))
  const centerNode = nodeMap.get(focusId)
  if (!centerNode) return { nodes: [], zones: [] }

  const includedIds = new Set<string>([focusId])
  const resultNodes: GraphNode[] = []
  const zones: ClusterZone[] = []

  // 1. Subir cadeia de discipuladores (Ancestrais)
  const ancestors: GraphNode[] = []
  let currDisciplerId = centerNode.disciplerId
  const visitedAncestors = new Set<string>([focusId])
  while (currDisciplerId && !visitedAncestors.has(currDisciplerId)) {
    visitedAncestors.add(currDisciplerId)
    const anc = nodeMap.get(currDisciplerId)
    if (anc) {
      ancestors.unshift(anc)
      includedIds.add(anc.id)
      currDisciplerId = anc.disciplerId
    } else {
      break
    }
  }

  // 2. Mapear descendentes diretos primeiro para que um discípulo direto que também seja
  // companheiro não tenha sua subárvore descendente suprimida
  const childrenMap = new Map<string, GraphNode[]>()
  allNodes.forEach((n) => {
    if (n.disciplerId) {
      const list = childrenMap.get(n.disciplerId) || []
      list.push(n)
      childrenMap.set(n.disciplerId, list)
    } else if (n.isChild && (n.fatherId === focusId || n.motherId === focusId)) {
      const list = childrenMap.get(focusId) || []
      list.push(n)
      childrenMap.set(focusId, list)
    }
  })
  const directDiscipleIds = new Set((childrenMap.get(focusId) || []).map((c) => c.id))

  // 3. Cônjuge e Companheiros de Obra (Nível Horizontal)
  const spouseNode =
    centerNode.spouseId && nodeMap.has(centerNode.spouseId)
      ? nodeMap.get(centerNode.spouseId)!
      : null
  if (spouseNode && !directDiscipleIds.has(spouseNode.id)) {
    includedIds.add(spouseNode.id)
  }

  const companions: GraphNode[] = []
  centerNode.fellowshipPartnerIds.forEach((fid) => {
    const comp = nodeMap.get(fid)
    if (comp && !includedIds.has(comp.id) && !directDiscipleIds.has(comp.id)) {
      includedIds.add(comp.id)
      companions.push(comp)
    }
  })

  const ANCESTOR_GAP_Y = 148
  const centerX = 600
  const centerY = 115 + ancestors.length * ANCESTOR_GAP_Y

  // Posicionar ancestrais acima do nó central
  ancestors.forEach((anc, idx) => {
    resultNodes.push({
      ...anc,
      level: idx,
      x: centerX,
      y: 115 + idx * ANCESTOR_GAP_Y,
    })
  })

  // Posicionar nó central
  resultNodes.push({
    ...centerNode,
    level: ancestors.length,
    x: centerX,
    y: centerY,
  })

  // Posicionar Cônjuge à esquerda imediata
  if (spouseNode && !directDiscipleIds.has(spouseNode.id)) {
    resultNodes.push({
      ...spouseNode,
      level: ancestors.length,
      x: centerX - 130,
      y: centerY,
    })
  }

  // Posicionar Companheiros de Obra à direita no mesmo eixo horizontal
  companions.forEach((comp, idx) => {
    resultNodes.push({
      ...comp,
      level: ancestors.length,
      x: centerX + 135 + idx * 115,
      y: centerY,
    })
  })

  const horizontalSpanLeft =
    spouseNode && !directDiscipleIds.has(spouseNode.id) ? centerX - 205 : centerX - 125
  const horizontalSpanRight =
    companions.length > 0
      ? centerX + 135 + (companions.length - 1) * 115 + 115
      : centerX + 125

  zones.push({
    id: "ego_focus_zone",
    title: `Junta Central de ${centerNode.name}`,
    subtitle: `${
      spouseNode ? "Cônjuge + " : ""
    }${companions.length} companheiro(s) no eixo horizontal`,
    x: horizontalSpanLeft,
    y: centerY - 82,
    width: Math.max(320, horizontalSpanRight - horizontalSpanLeft),
    height: 146,
    shape: "rect",
  })

  // Construir subárvore descendente com Tidy Tree e compactação de folhas em 2 colunas
  const LEAF_COL_GAP = 88
  const LEAF_ROW_GAP = 68

  const buildSubtree = (
    node: GraphNode,
    depth: number,
    visited: Set<string>
  ): TidyTreeNode => {
    const tn: TidyTreeNode = {
      id: node.id,
      graphNode: node,
      parent: null,
      children: [],
      depth,
      subtreeWidth: 96,
      maxSubtreeHeight: 0,
      x: 0,
      y: 0,
    }
    const rawChildren = childrenMap.get(node.id) || []
    rawChildren.forEach((c) => {
      if (!visited.has(c.id)) {
        visited.add(c.id)
        includedIds.add(c.id)
        const childTN = buildSubtree(c, depth + 1, visited)
        childTN.parent = tn
        tn.children.push(childTN)
      }
    })
    if (
      tn.children.length >= 2 &&
      tn.children.every((ch) => ch.children.length === 0)
    ) {
      const cols = Math.min(2, tn.children.length)
      tn.subtreeWidth = Math.max(96, cols * LEAF_COL_GAP + 16)
    } else if (tn.children.length > 0) {
      const totalW =
        tn.children.reduce((acc, ch) => acc + ch.subtreeWidth, 0) +
        (tn.children.length - 1) * 18
      tn.subtreeWidth = Math.max(96, totalW)
    }
    return tn
  }

  const rootTN = buildSubtree(centerNode, 0, new Set(includedIds))
  if (rootTN.children.length > 0) {
    const assignDescendantCoords = (tn: TidyTreeNode, leftX: number) => {
      const isCompactLeaves =
        tn.children.length >= 2 &&
        tn.children.every((ch) => ch.children.length === 0)

      if (tn.depth > 0) {
        tn.y = centerY + tn.depth * 138
        if (tn.children.length === 0) {
          tn.x = leftX + tn.subtreeWidth / 2
        } else if (isCompactLeaves) {
          const midX = leftX + tn.subtreeWidth / 2
          tn.x = midX
          const cols = Math.min(2, tn.children.length)
          const baseChildY = centerY + (tn.depth + 1) * 138
          tn.children.forEach((c, idx) => {
            const col = idx % cols
            const row = Math.floor(idx / cols)
            const isSingleLast =
              idx === tn.children.length - 1 && tn.children.length % 2 === 1
            const offsetX = isSingleLast ? 0 : (col - (cols - 1) / 2) * LEAF_COL_GAP
            c.x = midX + offsetX
            c.y = baseChildY + row * LEAF_ROW_GAP
            resultNodes.push({
              ...c.graphNode,
              level: ancestors.length + c.depth,
              x: c.x,
              y: c.y,
            })
          })
        } else {
          let cursor = leftX
          tn.children.forEach((c) => {
            assignDescendantCoords(c, cursor)
            cursor += c.subtreeWidth + 18
          })
          tn.x = (tn.children[0].x + tn.children[tn.children.length - 1].x) / 2
        }
        resultNodes.push({
          ...tn.graphNode,
          level: ancestors.length + tn.depth,
          x: tn.x,
          y: tn.y,
        })
      } else {
        let cursor = centerX - tn.subtreeWidth / 2
        tn.children.forEach((c) => {
          assignDescendantCoords(c, cursor)
          cursor += c.subtreeWidth + 18
        })
      }
    }
    assignDescendantCoords(rootTN, centerX - rootTN.subtreeWidth / 2)
  }

  return { nodes: resultNodes, zones }
}

interface RelationshipGraphCanvasProps {
  nodes: GraphNode[]
  zones: ClusterZone[]
  links: GraphLink[]
  layoutMode: GraphLayoutMode
  layoutKey: string
  searchName: string
  diagnosticFilter: DiagnosticFilter
  selectedNodeId: string | null
  isolatedNodeId: string | null
  focusTargetId: string | null
  onSelectNode: (id: string | null) => void
  onDoubleClickNode: (id: string) => void
  onFocusHandled: () => void
  isFullscreen: boolean
  onToggleFullscreen: () => void
}

function RelationshipGraphCanvas({
  nodes,
  zones,
  links,
  layoutMode,
  layoutKey,
  searchName,
  diagnosticFilter,
  selectedNodeId,
  isolatedNodeId,
  focusTargetId,
  onSelectNode,
  onDoubleClickNode,
  onFocusHandled,
  isFullscreen,
  onToggleFullscreen,
}: RelationshipGraphCanvasProps) {
  const containerRef = useRef<HTMLDivElement>(null)
  const canvasRef = useRef<HTMLCanvasElement | null>(null)
  const prevNodeRef = useRef<HTMLCanvasElement | null>(null)

  const zoomRef = useRef(1)
  const panRef = useRef({ x: 0, y: 0 })
  const isPanningRef = useRef(false)
  const startPanRef = useRef({ x: 0, y: 0 })
  const mouseDownPosRef = useRef<{ x: number; y: number } | null>(null)
  const hasDraggedRef = useRef(false)
  const hoveredNodeIdRef = useRef<string | null>(null)
  const touchPinchDistRef = useRef<number | null>(null)

  const [hoveredNode, setHoveredNode] = useState<GraphNode | null>(null)

  // Conjunto de nós na junta/rede de cuidado do irmão selecionado (ou sob o mouse)
  const activeHighlightId = selectedNodeId || hoveredNode?.id || null

  const { highlightedNodeIds, highlightedLinkSet } = useMemo(() => {
    if (!activeHighlightId) {
      return { highlightedNodeIds: null, highlightedLinkSet: null }
    }
    const nSet = new Set<string>([activeHighlightId])
    const lSet = new Set<string>()
    const nodeMap = new Map(nodes.map((n) => [n.id, n]))

    // 1. Subir cadeia de discipuladores (Ancestrais)
    let curr = nodeMap.get(activeHighlightId)
    const visitedUp = new Set<string>([activeHighlightId])
    while (curr?.disciplerId && !visitedUp.has(curr.disciplerId)) {
      visitedUp.add(curr.disciplerId)
      if (nodeMap.has(curr.disciplerId)) {
        nSet.add(curr.disciplerId)
        lSet.add(`${curr.disciplerId}->${curr.id}:discipler`)
        curr = nodeMap.get(curr.disciplerId)
      } else {
        break
      }
    }

    // 2. Descer árvore de discípulos (Descendentes)
    const childrenByParent = new Map<string, string[]>()
    links.forEach((l) => {
      if (l.type === "discipler" || l.type === "parent") {
        const arr = childrenByParent.get(l.source) || []
        arr.push(l.target)
        childrenByParent.set(l.source, arr)
      }
    })

    const queue = [activeHighlightId]
    const visitedDown = new Set<string>([activeHighlightId])
    while (queue.length > 0) {
      const pid = queue.shift()!
      const ch = childrenByParent.get(pid) || []
      ch.forEach((cid) => {
        if (!visitedDown.has(cid) && nodeMap.has(cid)) {
          visitedDown.add(cid)
          nSet.add(cid)
          lSet.add(`${pid}->${cid}:discipler`)
          lSet.add(`${pid}->${cid}:parent`)
          queue.push(cid)
        }
      })
    }

    // 3. Vínculos diretos (Companheirismo, Casamento, Pais)
    links.forEach((l) => {
      if (l.source === activeHighlightId || l.target === activeHighlightId) {
        nSet.add(l.source)
        nSet.add(l.target)
        lSet.add(`${l.source}->${l.target}:${l.type}`)
      }
    })

    return { highlightedNodeIds: nSet, highlightedLinkSet: lSet }
  }, [activeHighlightId, nodes, links])

  // Verificar se um nó corresponde à busca ou ao filtro de diagnóstico
  const isNodeDiagnosticMatch = useCallback(
    (node: GraphNode): boolean => {
      if (diagnosticFilter === "no_discipler") return node.hasNoDisciplerAlert
      if (diagnosticFilter === "no_fellowship") return node.hasNoFellowshipAlert
      if (diagnosticFilter === "overloaded") return node.isOverloaded
      if (diagnosticFilter === "potential_disciplers") return node.isPotentialDiscipler
      return true
    },
    [diagnosticFilter]
  )

  const isNodeSearchMatch = useCallback(
    (node: GraphNode): boolean => {
      if (!searchName.trim()) return false
      const q = searchName.toLowerCase().trim()
      return (
        node.name.toLowerCase().includes(q) ||
        (node.homeGroupName?.toLowerCase().includes(q) ?? false) ||
        node.sector.toLowerCase().includes(q)
      )
    },
    [searchName]
  )

  const drawCanvas = useCallback(() => {
    const canvas = canvasRef.current
    if (!canvas) return
    const ctx = canvas.getContext("2d")
    if (!ctx) return

    const dpr = window.devicePixelRatio || 1
    const rect = canvas.getBoundingClientRect()
    const displayW = Math.max(1, Math.round(rect.width))
    const displayH = Math.max(1, Math.round(rect.height))
    if (canvas.width !== displayW * dpr || canvas.height !== displayH * dpr) {
      canvas.width = displayW * dpr
      canvas.height = displayH * dpr
    }

    const isDark = document.documentElement.classList.contains("dark")
    const zoom = zoomRef.current
    const pan = panRef.current

    ctx.save()
    ctx.scale(dpr, dpr)

    // 1. Fundo limpo com grade de pontos discreta
    ctx.fillStyle = isDark
      ? GRAPH_CANVAS_COLORS.background.dark
      : GRAPH_CANVAS_COLORS.background.light
    ctx.fillRect(0, 0, displayW, displayH)

    const gridStep = 32 * zoom
    if (gridStep >= 14) {
      ctx.fillStyle = isDark
        ? GRAPH_CANVAS_COLORS.gridDot.dark
        : GRAPH_CANVAS_COLORS.gridDot.light
      const offsetX = ((pan.x % gridStep) + gridStep) % gridStep
      const offsetY = ((pan.y % gridStep) + gridStep) % gridStep
      for (let gx = offsetX; gx < displayW; gx += gridStep) {
        for (let gy = offsetY; gy < displayH; gy += gridStep) {
          ctx.fillRect(gx, gy, 1.5, 1.5)
        }
      }
    }

    ctx.translate(pan.x, pan.y)
    ctx.scale(zoom, zoom)

    // 2. Desenhar Zonas / Clusters (Linhagens ou Grupos Caseiros)
    zones.forEach((zone) => {
      ctx.save()
      ctx.beginPath()
      if (zone.shape === "circle" && zone.radius) {
        ctx.arc(zone.x, zone.y, zone.radius, 0, Math.PI * 2)
      } else {
        ctx.roundRect(zone.x, zone.y, zone.width, zone.height, 20)
      }

      ctx.fillStyle = zone.isWarning
        ? isDark
          ? GRAPH_CANVAS_COLORS.warningZoneFill.dark
          : GRAPH_CANVAS_COLORS.warningZoneFill.light
        : isDark
        ? GRAPH_CANVAS_COLORS.clusterFill.dark
        : GRAPH_CANVAS_COLORS.clusterFill.light
      ctx.fill()

      ctx.lineWidth = zone.isWarning ? 2 : 1.2
      if (zone.isWarning) ctx.setLineDash([6, 4])
      ctx.strokeStyle = zone.isWarning
        ? isDark
          ? GRAPH_CANVAS_COLORS.warningZoneStroke.dark
          : GRAPH_CANVAS_COLORS.warningZoneStroke.light
        : isDark
        ? GRAPH_CANVAS_COLORS.clusterStroke.dark
        : GRAPH_CANVAS_COLORS.clusterStroke.light
      ctx.stroke()
      ctx.setLineDash([])

      // Cabeçalho da Zona com escala adaptativa ao zoom e truncamento seguro
      const titleFontSize = Math.round(
        Math.max(13, Math.min(20, 12.5 / Math.pow(zoom, 0.42)))
      )
      const subFontSize = Math.round(
        Math.max(11, Math.min(15, 10.5 / Math.pow(zoom, 0.42)))
      )
      const headerX = zone.shape === "circle" ? zone.x : zone.x + zone.width / 2
      const headerY =
        zone.shape === "circle" && zone.radius
          ? zone.y - zone.radius + Math.max(26, titleFontSize + 9)
          : zone.y + Math.max(24, titleFontSize + 9)

      const maxHeaderWidth =
        zone.shape === "circle" && zone.radius
          ? Math.max(120, zone.radius * 1.18)
          : Math.max(140, zone.width - 28)

      const fitZoneText = (text: string, maxW: number): string => {
        if (ctx.measureText(text).width <= maxW) return text
        let trimmed = text
        while (trimmed.length > 4 && ctx.measureText(`${trimmed}…`).width > maxW) {
          trimmed = trimmed.slice(0, -1)
        }
        return `${trimmed}…`
      }

      ctx.textAlign = "center"
      ctx.font = `600 ${titleFontSize}px Geist, sans-serif`
      ctx.fillStyle = isDark
        ? GRAPH_CANVAS_COLORS.clusterTitle.dark
        : GRAPH_CANVAS_COLORS.clusterTitle.light
      ctx.fillText(fitZoneText(zone.title, maxHeaderWidth), headerX, headerY)

      ctx.font = `400 ${subFontSize}px Geist, sans-serif`
      ctx.fillStyle = isDark
        ? GRAPH_CANVAS_COLORS.clusterSubtitle.dark
        : GRAPH_CANVAS_COLORS.clusterSubtitle.light
      ctx.fillText(
        fitZoneText(zone.subtitle, maxHeaderWidth + 24),
        headerX,
        headerY + Math.max(16, subFontSize + 4)
      )
      ctx.restore()
    })

    const nodeMap = new Map(nodes.map((n) => [n.id, n]))
    const hasSearchFilter = searchName.trim().length > 0
    const hasDiagFilter = diagnosticFilter !== "all"

    const getNodeRadius = (role: RelationshipNodeRole) =>
      role === "presbyter"
        ? 21
        : role === "deacon"
        ? 19
        : role === "leader"
        ? 18
        : role === "discipler"
        ? 17
        : 15

    // 3. Desenhar Links (Linhas de Conexão)
    links.forEach((link) => {
      const s = nodeMap.get(link.source)
      const t = nodeMap.get(link.target)
      if (!s || !t) return

      const linkKey = `${link.source}->${link.target}:${link.type}`
      const isHighlighted = highlightedLinkSet ? highlightedLinkSet.has(linkKey) : false

      // No modo Grupos Caseiros, links entre grupos diferentes aparecem sob demanda (quando destacados)
      // para evitar que centenas de linhas cruzem sobre todos os círculos de GC simultaneamente.
      const isCrossGroup =
        s.homeGroupId && t.homeGroupId && s.homeGroupId !== t.homeGroupId
      if (
        layoutMode === "groups" &&
        !isolatedNodeId &&
        isCrossGroup &&
        !isHighlighted &&
        nodes.length > 35
      ) {
        return
      }

      // No modo Rede de Companheirismo em visão de Rodas de Companheirismo, ocultar links entre rodas
      // distintas quando não destacados para que as alianças internas de cada roda fiquem nítidas.
      const linkDist = Math.hypot(s.x - t.x, s.y - t.y)
      if (
        layoutMode === "fellowships" &&
        !isolatedNodeId &&
        !isHighlighted &&
        nodes.length > 20 &&
        (linkDist > 340 || link.type === "discipler")
      ) {
        return
      }

      // Se há um irmão focado/selecionado, esmaecer links não pertencentes à junta dele
      let alpha = 1
      if (highlightedLinkSet) {
        alpha = isHighlighted ? 1 : 0.06
      } else if (hasSearchFilter || hasDiagFilter) {
        const sMatch =
          (!hasSearchFilter || isNodeSearchMatch(s)) &&
          (!hasDiagFilter || isNodeDiagnosticMatch(s))
        const tMatch =
          (!hasSearchFilter || isNodeSearchMatch(t)) &&
          (!hasDiagFilter || isNodeDiagnosticMatch(t))
        alpha = sMatch || tMatch ? 0.9 : 0.07
      } else if (
        layoutMode === "hierarchy" &&
        !isolatedNodeId &&
        link.type === "fellowship" &&
        nodes.length > 45
      ) {
        // Na visão macro da Árvore de Discipulado, manter juntas horizontais entre árvores
        // discretas ao fundo até que o usuário passe o mouse ou selecione um irmão
        alpha = s.level === 0 && t.level === 0 ? 0.65 : 0.12
      } else if (layoutMode === "fellowships" && !isolatedNodeId) {
        alpha = link.type === "fellowship" ? 0.85 : 0.18
      }

      ctx.save()
      ctx.globalAlpha = alpha

      // Configurar cor e traço por tipo de vínculo
      if (link.type === "marriage") {
        ctx.strokeStyle = isHighlighted
          ? isDark
            ? GRAPH_LINK_COLORS.marriage.highlighted.dark
            : GRAPH_LINK_COLORS.marriage.highlighted.light
          : isDark
          ? GRAPH_LINK_COLORS.marriage.default.dark
          : GRAPH_LINK_COLORS.marriage.default.light
        ctx.lineWidth = isHighlighted ? 3 : 2
        ctx.setLineDash([3, 3])
      } else if (link.type === "fellowship") {
        ctx.strokeStyle = isHighlighted
          ? isDark
            ? GRAPH_LINK_COLORS.fellowship.highlighted.dark
            : GRAPH_LINK_COLORS.fellowship.highlighted.light
          : isDark
          ? GRAPH_LINK_COLORS.fellowship.default.dark
          : GRAPH_LINK_COLORS.fellowship.default.light
        ctx.lineWidth = isHighlighted ? 2.8 : 1.6
        ctx.setLineDash([5, 4])
      } else if (link.type === "parent") {
        ctx.strokeStyle = isHighlighted
          ? isDark
            ? GRAPH_LINK_COLORS.parent.highlighted.dark
            : GRAPH_LINK_COLORS.parent.highlighted.light
          : isDark
          ? GRAPH_LINK_COLORS.parent.default.dark
          : GRAPH_LINK_COLORS.parent.default.light
        ctx.lineWidth = isHighlighted ? 2.4 : 1.4
        ctx.setLineDash([2, 2])
      } else {
        // Discipulado
        ctx.strokeStyle = isHighlighted
          ? isDark
            ? GRAPH_LINK_COLORS.discipler.highlighted.dark
            : GRAPH_LINK_COLORS.discipler.highlighted.light
          : isDark
          ? GRAPH_LINK_COLORS.discipler.default.dark
          : GRAPH_LINK_COLORS.discipler.default.light
        ctx.lineWidth = isHighlighted ? 3 : 1.7
        ctx.setLineDash([])
      }

      const sourceRadius = getNodeRadius(s.role)
      const targetRadius = getNodeRadius(t.role)
      const useVerticalBezier =
        (layoutMode === "hierarchy" || isolatedNodeId !== null) &&
        (link.type === "discipler" || link.type === "parent") &&
        t.y - s.y > 40

      ctx.beginPath()
      if (useVerticalBezier) {
        const startX = s.x
        const startY = s.y + sourceRadius
        const endX = t.x
        const endY = t.y - targetRadius - 3
        const midY = (startY + endY) / 2
        ctx.moveTo(startX, startY)
        ctx.bezierCurveTo(startX, midY, endX, midY, endX, endY)
        ctx.stroke()
        ctx.setLineDash([])

        // Seta vertical perfeitamente alinhada ao topo do nó de destino
        if (link.type === "discipler" && (isHighlighted || zoom >= 0.4)) {
          const arrowLen = isHighlighted ? 8 : 6
          ctx.beginPath()
          ctx.moveTo(endX, endY + 2)
          ctx.lineTo(endX - arrowLen * 0.55, endY - arrowLen + 2)
          ctx.lineTo(endX + arrowLen * 0.55, endY - arrowLen + 2)
          ctx.closePath()
          ctx.fillStyle = ctx.strokeStyle
          ctx.fill()
        }
      } else if (link.type === "fellowship" && (layoutMode === "hierarchy" || isolatedNodeId !== null)) {
        // Curva suave para juntas horizontais na árvore
        const dx = t.x - s.x
        const dy = t.y - s.y
        const dist = Math.hypot(dx, dy)
        const arcOffset = Math.min(44, dist * 0.16)
        const midX = (s.x + t.x) / 2
        const midY = (s.y + t.y) / 2 - arcOffset
        ctx.moveTo(s.x, s.y)
        ctx.quadraticCurveTo(midX, midY, t.x, t.y)
        ctx.stroke()
        ctx.setLineDash([])
      } else {
        ctx.moveTo(s.x, s.y)
        ctx.lineTo(t.x, t.y)
        ctx.stroke()
        ctx.setLineDash([])

        if (link.type === "discipler" && (isHighlighted || zoom >= 0.45)) {
          const angle = Math.atan2(t.y - s.y, t.x - s.x)
          const tipX = t.x - Math.cos(angle) * (targetRadius + 3)
          const tipY = t.y - Math.sin(angle) * (targetRadius + 3)
          const arrowLen = isHighlighted ? 8 : 6

          ctx.beginPath()
          ctx.moveTo(tipX, tipY)
          ctx.lineTo(
            tipX - arrowLen * Math.cos(angle - Math.PI / 6),
            tipY - arrowLen * Math.sin(angle - Math.PI / 6)
          )
          ctx.lineTo(
            tipX - arrowLen * Math.cos(angle + Math.PI / 6),
            tipY - arrowLen * Math.sin(angle + Math.PI / 6)
          )
          ctx.closePath()
          ctx.fillStyle = ctx.strokeStyle
          ctx.fill()
        }
      }

      ctx.restore()
    })

    // 4. Desenhar Nós (Discípulos)
    nodes.forEach((node) => {
      const isSelected = selectedNodeId === node.id
      const isHovered = hoveredNodeIdRef.current === node.id
      const isSearchHit = isNodeSearchMatch(node)
      const isDiagHit = isNodeDiagnosticMatch(node)

      let nodeAlpha = 1
      if (highlightedNodeIds) {
        nodeAlpha = highlightedNodeIds.has(node.id) ? 1 : 0.14
      } else if (hasSearchFilter || hasDiagFilter) {
        const matchesActive =
          (!hasSearchFilter || isSearchHit) && (!hasDiagFilter || isDiagHit)
        nodeAlpha = matchesActive ? 1 : 0.14
      }

      ctx.save()
      ctx.globalAlpha = nodeAlpha

      const radius =
        node.role === "presbyter"
          ? 21
          : node.role === "deacon"
          ? 19
          : node.role === "leader"
          ? 18
          : node.role === "discipler"
          ? 17
          : 15

      const rolePalette = RELATIONSHIP_NODE_COLORS[node.role]
      const colors = isDark ? rolePalette.dark : rolePalette.light

      // Anel externo de seleção, busca ou alerta de junta
      if (isSelected || isHovered || isSearchHit || (hasDiagFilter && isDiagHit)) {
        ctx.beginPath()
        ctx.arc(node.x, node.y, radius + 5, 0, Math.PI * 2)
        ctx.lineWidth = isSelected ? 3.5 : 2.5
        ctx.strokeStyle = isSelected
          ? isDark
            ? GRAPH_CANVAS_COLORS.selectionRing.dark
            : GRAPH_CANVAS_COLORS.selectionRing.light
          : isDark
          ? GRAPH_CANVAS_COLORS.searchMatchRing.dark
          : GRAPH_CANVAS_COLORS.searchMatchRing.light
        ctx.stroke()
      }

      // Círculo principal do nó
      ctx.beginPath()
      ctx.arc(node.x, node.y, radius, 0, Math.PI * 2)
      ctx.fillStyle = colors.fill
      ctx.fill()

      ctx.lineWidth = isSelected ? 2.5 : 1.8
      ctx.strokeStyle = colors.stroke
      ctx.stroke()

      // Iniciais dentro do círculo
      ctx.font = `600 ${radius >= 19 ? 11 : 10}px Geist, sans-serif`
      ctx.fillStyle = colors.text
      ctx.textAlign = "center"
      ctx.textBaseline = "middle"
      ctx.fillText(node.initials, node.x, node.y + 0.5)

      // Mini-badge superior direito: quantidade de discípulos diretos (se > 0)
      if (node.directDisciplesCount > 0) {
        const bx = node.x + radius * 0.75
        const by = node.y - radius * 0.75
        ctx.beginPath()
        ctx.arc(bx, by, 7.5, 0, Math.PI * 2)
        ctx.fillStyle = isDark
          ? GRAPH_CANVAS_COLORS.countBadgeBg.dark
          : GRAPH_CANVAS_COLORS.countBadgeBg.light
        ctx.fill()
        ctx.font = "700 9px Geist, sans-serif"
        ctx.fillStyle = isDark
          ? GRAPH_CANVAS_COLORS.countBadgeText.dark
          : GRAPH_CANVAS_COLORS.countBadgeText.light
        ctx.fillText(String(node.directDisciplesCount), bx, by + 0.5)
      }

      // Ponto de alerta superior esquerdo se sem discipulador ou sem companheiro
      if (node.hasNoDisciplerAlert || node.hasNoFellowshipAlert) {
        const ax = node.x - radius * 0.75
        const ay = node.y - radius * 0.75
        ctx.beginPath()
        ctx.arc(ax, ay, 5.5, 0, Math.PI * 2)
        ctx.fillStyle = node.hasNoDisciplerAlert
          ? isDark
            ? GRAPH_CANVAS_COLORS.alertNoDiscipler.dark
            : GRAPH_CANVAS_COLORS.alertNoDiscipler.light
          : isDark
          ? GRAPH_CANVAS_COLORS.alertNoFellowship.dark
          : GRAPH_CANVAS_COLORS.alertNoFellowship.light
        ctx.fill()
      }

      // Rótulo de nome abaixo do círculo (com pílula de contraste)
      const shouldShowLabel =
        zoom >= 0.42 || isSelected || isHovered || isSearchHit || node.isPresbyter || node.isDeacon
      if (shouldShowLabel) {
        const labelText =
          isSelected || isHovered || zoom >= 1.35 ? node.name : node.shortName
        ctx.font =
          isSelected || isHovered
            ? "600 11px Geist, sans-serif"
            : "500 10.5px Geist, sans-serif"
        const textWidth = ctx.measureText(labelText).width
        const pillW = textWidth + 10
        const pillH = 16
        const pillX = node.x - pillW / 2
        const pillY = node.y + radius + 5

        ctx.beginPath()
        ctx.roundRect(pillX, pillY, pillW, pillH, 5)
        ctx.fillStyle = isSelected
          ? isDark
            ? GRAPH_CANVAS_COLORS.labelBgSelected.dark
            : GRAPH_CANVAS_COLORS.labelBgSelected.light
          : isDark
          ? GRAPH_CANVAS_COLORS.labelBg.dark
          : GRAPH_CANVAS_COLORS.labelBg.light
        ctx.fill()

        if (!isSelected) {
          ctx.lineWidth = 0.8
          ctx.strokeStyle = isDark
            ? GRAPH_CANVAS_COLORS.labelBorder.dark
            : GRAPH_CANVAS_COLORS.labelBorder.light
          ctx.stroke()
        }

        ctx.fillStyle = isSelected
          ? isDark
            ? GRAPH_CANVAS_COLORS.labelTextSelected.dark
            : GRAPH_CANVAS_COLORS.labelTextSelected.light
          : isDark
          ? GRAPH_CANVAS_COLORS.labelText.dark
          : GRAPH_CANVAS_COLORS.labelText.light
        ctx.textAlign = "center"
        ctx.textBaseline = "middle"
        ctx.fillText(labelText, node.x, pillY + pillH / 2 + 0.5)
      }

      ctx.restore()
    })

    ctx.restore()
  }, [
    nodes,
    zones,
    links,
    layoutMode,
    selectedNodeId,
    isolatedNodeId,
    highlightedNodeIds,
    highlightedLinkSet,
    searchName,
    diagnosticFilter,
    isNodeSearchMatch,
    isNodeDiagnosticMatch,
  ])

  const drawCanvasRef = useRef(drawCanvas)
  useEffect(() => {
    drawCanvasRef.current = drawCanvas
  }, [drawCanvas])

  // Auto-enquadrar todos os nós visíveis na tela (Fit-to-Screen)
  // Desacoplado de drawCanvas para nunca resetar o zoom ao passar o mouse, selecionar ou filtrar diagnóstico
  const fitToScreen = useCallback(() => {
    const canvas = canvasRef.current
    if (!canvas || nodes.length === 0) return

    const rect = canvas.getBoundingClientRect()
    if (rect.width === 0 || rect.height === 0) return

    let minX = Infinity
    let maxX = -Infinity
    let minY = Infinity
    let maxY = -Infinity

    nodes.forEach((n) => {
      if (n.x - 60 < minX) minX = n.x - 60
      if (n.x + 60 > maxX) maxX = n.x + 60
      if (n.y - 60 < minY) minY = n.y - 60
      if (n.y + 60 > maxY) maxY = n.y + 60
    })

    zones.forEach((z) => {
      if (z.shape === "circle" && z.radius) {
        if (z.x - z.radius < minX) minX = z.x - z.radius
        if (z.x + z.radius > maxX) maxX = z.x + z.radius
        if (z.y - z.radius < minY) minY = z.y - z.radius
        if (z.y + z.radius > maxY) maxY = z.y + z.radius
      } else {
        if (z.x < minX) minX = z.x
        if (z.x + z.width > maxX) maxX = z.x + z.width
        if (z.y < minY) minY = z.y
        if (z.y + z.height > maxY) maxY = z.y + z.height
      }
    })

    const contentW = Math.max(200, maxX - minX)
    const contentH = Math.max(200, maxY - minY)
    const padX = 34
    const topInset = 52
    const bottomInset = 58

    const scaleX = Math.max(120, rect.width - padX * 2) / contentW
    const scaleY = Math.max(120, rect.height - topInset - bottomInset) / contentH
    const nextZoom = Math.max(0.05, Math.min(1.35, Math.min(scaleX, scaleY)))

    const centerContentX = (minX + maxX) / 2
    const centerContentY = (minY + maxY) / 2
    const viewportCenterY = topInset + (rect.height - topInset - bottomInset) / 2

    zoomRef.current = nextZoom
    panRef.current = {
      x: rect.width / 2 - centerContentX * nextZoom,
      y: viewportCenterY - centerContentY * nextZoom,
    }
    drawCanvasRef.current()
  }, [nodes, zones])

  const fitToScreenRef = useRef(fitToScreen)
  useEffect(() => {
    fitToScreenRef.current = fitToScreen
  }, [fitToScreen])

  // Re-enquadrar APENAS quando a estrutura de layout (layoutKey) mudar
  useEffect(() => {
    const id = requestAnimationFrame(() => {
      fitToScreenRef.current()
    })
    return () => cancelAnimationFrame(id)
  }, [layoutKey])

  // Centralizar em um irmão específico quando solicitado (executado após eventual mudança de layout)
  useEffect(() => {
    if (!focusTargetId || !canvasRef.current) return
    const id = requestAnimationFrame(() => {
      if (!canvasRef.current) return
      const target = nodes.find((n) => n.id === focusTargetId)
      if (target) {
        const rect = canvasRef.current.getBoundingClientRect()
        const nextZoom = Math.max(zoomRef.current, 1.15)
        zoomRef.current = nextZoom
        panRef.current = {
          x: rect.width / 2 - target.x * nextZoom,
          y: rect.height / 2 - target.y * nextZoom,
        }
        drawCanvasRef.current()
      }
      onFocusHandled()
    })
    return () => cancelAnimationFrame(id)
  }, [focusTargetId, nodes, onFocusHandled])

  useEffect(() => {
    drawCanvas()
  }, [drawCanvas])

  // Observar redimensionamento do container e mudança de tema claro/escuro
  useEffect(() => {
    const container = containerRef.current
    if (!container) return
    const ro = new ResizeObserver(() => {
      drawCanvasRef.current()
    })
    ro.observe(container)

    const mo = new MutationObserver(() => {
      drawCanvasRef.current()
    })
    mo.observe(document.documentElement, {
      attributes: true,
      attributeFilter: ["class"],
    })

    return () => {
      ro.disconnect()
      mo.disconnect()
    }
  }, [])

  const findNodeAtClientPos = (clientX: number, clientY: number): GraphNode | null => {
    const canvas = canvasRef.current
    if (!canvas) return null
    const rect = canvas.getBoundingClientRect()
    const worldX = (clientX - rect.left - panRef.current.x) / zoomRef.current
    const worldY = (clientY - rect.top - panRef.current.y) / zoomRef.current

    for (let i = nodes.length - 1; i >= 0; i--) {
      const n = nodes[i]
      if (Math.hypot(n.x - worldX, n.y - worldY) <= 24) {
        return n
      }
    }
    return null
  }

  // Zoom via roda do mouse
  const handleWheel = useCallback(
    (e: WheelEvent) => {
      e.preventDefault()
      const factor = e.deltaY < 0 ? 1.1 : 0.9
      const canvas = canvasRef.current
      if (!canvas) return
      const rect = canvas.getBoundingClientRect()
      const mouseX = e.clientX - rect.left
      const mouseY = e.clientY - rect.top
      const currentZoom = zoomRef.current
      const newZoom = Math.max(0.05, Math.min(currentZoom * factor, 3.5))
      panRef.current = {
        x: mouseX - (mouseX - panRef.current.x) * (newZoom / currentZoom),
        y: mouseY - (mouseY - panRef.current.y) * (newZoom / currentZoom),
      }
      zoomRef.current = newZoom
      drawCanvasRef.current()
    },
    []
  )

  const canvasCallback = useCallback(
    (node: HTMLCanvasElement | null) => {
      if (prevNodeRef.current) {
        prevNodeRef.current.removeEventListener("wheel", handleWheel)
      }
      if (node) {
        node.addEventListener("wheel", handleWheel, { passive: false })
      }
      prevNodeRef.current = node
      canvasRef.current = node
    },
    [handleWheel]
  )

  const handleMouseDown = (e: React.MouseEvent<HTMLCanvasElement>) => {
    isPanningRef.current = true
    startPanRef.current = {
      x: e.clientX - panRef.current.x,
      y: e.clientY - panRef.current.y,
    }
    mouseDownPosRef.current = { x: e.clientX, y: e.clientY }
    hasDraggedRef.current = false
  }

  const handleMouseMove = (e: React.MouseEvent<HTMLCanvasElement>) => {
    if (isPanningRef.current) {
      if (mouseDownPosRef.current) {
        const dx = Math.abs(e.clientX - mouseDownPosRef.current.x)
        const dy = Math.abs(e.clientY - mouseDownPosRef.current.y)
        if (dx > 4 || dy > 4) hasDraggedRef.current = true
      }
      panRef.current = {
        x: e.clientX - startPanRef.current.x,
        y: e.clientY - startPanRef.current.y,
      }
      drawCanvasRef.current()
      return
    }

    const hit = findNodeAtClientPos(e.clientX, e.clientY)
    const prevId = hoveredNodeIdRef.current
    const nextId = hit ? hit.id : null
    if (prevId !== nextId) {
      hoveredNodeIdRef.current = nextId
      setHoveredNode(hit)
      drawCanvasRef.current()
    }
  }

  const handleMouseUp = (e: React.MouseEvent<HTMLCanvasElement>) => {
    isPanningRef.current = false
    if (!hasDraggedRef.current) {
      const clicked = findNodeAtClientPos(e.clientX, e.clientY)
      onSelectNode(clicked ? clicked.id : null)
    }
  }

  const handleDoubleClick = (e: React.MouseEvent<HTMLCanvasElement>) => {
    const clicked = findNodeAtClientPos(e.clientX, e.clientY)
    if (clicked) {
      onDoubleClickNode(clicked.id)
    }
  }

  // Suporte Mobile Touch (Pan de 1 dedo + Pinch Zoom de 2 dedos + Tap)
  const handleTouchStart = (e: React.TouchEvent<HTMLCanvasElement>) => {
    if (e.touches.length === 1) {
      const t = e.touches[0]
      isPanningRef.current = true
      startPanRef.current = {
        x: t.clientX - panRef.current.x,
        y: t.clientY - panRef.current.y,
      }
      mouseDownPosRef.current = { x: t.clientX, y: t.clientY }
      hasDraggedRef.current = false
      touchPinchDistRef.current = null
    } else if (e.touches.length === 2) {
      isPanningRef.current = false
      hasDraggedRef.current = true
      const dx = e.touches[0].clientX - e.touches[1].clientX
      const dy = e.touches[0].clientY - e.touches[1].clientY
      touchPinchDistRef.current = Math.hypot(dx, dy)
    }
  }

  const handleTouchMove = (e: React.TouchEvent<HTMLCanvasElement>) => {
    if (e.touches.length === 1 && isPanningRef.current) {
      const t = e.touches[0]
      if (mouseDownPosRef.current) {
        const dx = Math.abs(t.clientX - mouseDownPosRef.current.x)
        const dy = Math.abs(t.clientY - mouseDownPosRef.current.y)
        if (dx > 6 || dy > 6) hasDraggedRef.current = true
      }
      panRef.current = {
        x: t.clientX - startPanRef.current.x,
        y: t.clientY - startPanRef.current.y,
      }
      drawCanvasRef.current()
    } else if (e.touches.length === 2 && touchPinchDistRef.current) {
      const dx = e.touches[0].clientX - e.touches[1].clientX
      const dy = e.touches[0].clientY - e.touches[1].clientY
      const dist = Math.hypot(dx, dy)
      const factor = dist / touchPinchDistRef.current
      touchPinchDistRef.current = dist

      const canvas = canvasRef.current
      if (!canvas) return
      const rect = canvas.getBoundingClientRect()
      const midX = (e.touches[0].clientX + e.touches[1].clientX) / 2 - rect.left
      const midY = (e.touches[0].clientY + e.touches[1].clientY) / 2 - rect.top
      const currentZoom = zoomRef.current
      const nextZoom = Math.max(0.05, Math.min(currentZoom * factor, 3.5))
      panRef.current = {
        x: midX - (midX - panRef.current.x) * (nextZoom / currentZoom),
        y: midY - (midY - panRef.current.y) * (nextZoom / currentZoom),
      }
      zoomRef.current = nextZoom
      drawCanvasRef.current()
    }
  }

  const handleTouchEnd = (e: React.TouchEvent<HTMLCanvasElement>) => {
    isPanningRef.current = false
    touchPinchDistRef.current = null
    if (!hasDraggedRef.current && e.changedTouches.length === 1) {
      const t = e.changedTouches[0]
      const tapped = findNodeAtClientPos(t.clientX, t.clientY)
      onSelectNode(tapped ? tapped.id : null)
    }
  }

  return (
    <div
      ref={containerRef}
      className={`relative w-full overflow-hidden rounded-2xl border border-border bg-card shadow-xs ${
        isFullscreen ? "h-[calc(100vh-12rem)] min-h-[520px]" : "h-[540px] sm:h-[640px]"
      }`}
    >
      <canvas
        ref={canvasCallback}
        onMouseDown={handleMouseDown}
        onMouseMove={handleMouseMove}
        onMouseUp={handleMouseUp}
        onDoubleClick={handleDoubleClick}
        onTouchStart={handleTouchStart}
        onTouchMove={handleTouchMove}
        onTouchEnd={handleTouchEnd}
        className={`h-full w-full touch-none ${
          hoveredNode ? "cursor-pointer" : "cursor-grab active:cursor-grabbing"
        }`}
      />

      {/* Dica contextual no topo esquerdo do Canvas */}
      <div className="pointer-events-none absolute top-3 left-3 flex flex-wrap items-center gap-1.5 max-w-[calc(100%-6rem)]">
        <div className="rounded-xl border border-border/80 bg-background/90 px-3 py-1.5 text-[11px] text-muted-foreground shadow-xs backdrop-blur-xs">
          {isolatedNodeId ? (
            <span className="font-medium text-foreground">
              Modo Junta Isolada • Selecione um irmão para inspecionar
            </span>
          ) : (
            <span>
              Toque em um irmão para destacar suas juntas • Toque duplo para isolar a junta
            </span>
          )}
        </div>
      </div>

      {/* Tooltip rápido no hover (Desktop) */}
      {hoveredNode && hoveredNode.id !== selectedNodeId && (
        <div className="pointer-events-none absolute top-14 left-3 z-10 max-w-xs rounded-xl border border-border bg-popover/95 p-3 text-xs text-popover-foreground shadow-lg backdrop-blur-xs">
          <div className="font-semibold text-foreground">{hoveredNode.name}</div>
          <div className="mt-0.5 text-[11px] text-muted-foreground">
            {RELATIONSHIP_NODE_COLORS[hoveredNode.role].label} •{" "}
            {hoveredNode.homeGroupName || "Sem Grupo Caseiro"}
          </div>
          <div className="mt-1.5 flex flex-wrap gap-1.5 text-[10px]">
            <span className="rounded bg-muted px-1.5 py-0.5 font-medium text-foreground">
              {hoveredNode.directDisciplesCount} discípulo(s) direto(s)
            </span>
            <span className="rounded bg-muted px-1.5 py-0.5 font-medium text-foreground">
              {hoveredNode.fellowshipsCount} companheiro(s)
            </span>
          </div>
        </div>
      )}

      {/* Legenda Compacta no Canto Inferior Esquerdo */}
      <div className="pointer-events-none absolute bottom-3 left-3 hidden md:flex flex-wrap items-center gap-3 rounded-xl border border-border/80 bg-background/90 px-3 py-2 text-[11px] text-muted-foreground shadow-xs backdrop-blur-xs">
        {(
          ["presbyter", "deacon", "leader", "discipler", "disciple"] as RelationshipNodeRole[]
        ).map((roleKey) => (
          <span key={roleKey} className="flex items-center gap-1.5">
            <span
              className={`h-2.5 w-2.5 rounded-full ${RELATIONSHIP_NODE_COLORS[roleKey].dotClass}`}
            />
            <span>{RELATIONSHIP_NODE_COLORS[roleKey].label}</span>
          </span>
        ))}
        <span className="h-3 w-px bg-border" />
        <span className="flex items-center gap-1.5">
          <span className={`h-0.5 w-4 ${GRAPH_UI_CLASSES.legendLineDiscipler}`} />
          <span>Discipulado</span>
        </span>
        <span className="flex items-center gap-1.5">
          <span className={`h-0.5 w-4 ${GRAPH_UI_CLASSES.legendLineFellowship}`} />
          <span>Companheirismo</span>
        </span>
        <span className="flex items-center gap-1.5">
          <span className={`h-0.5 w-4 ${GRAPH_UI_CLASSES.legendLineMarriage}`} />
          <span>Casamento</span>
        </span>
      </div>

      {/* Controles de Zoom e Enquadramento no Canto Inferior Direito */}
      <div className="absolute bottom-3 right-3 flex items-center gap-1 rounded-xl border border-border/80 bg-background/95 p-1 shadow-md backdrop-blur-xs">
        <Button
          size="icon"
          variant="ghost"
          title="Aproximar"
          aria-label="Aproximar grafo"
          onClick={() => {
            zoomRef.current = Math.min(zoomRef.current * 1.25, 3.5)
            drawCanvasRef.current()
          }}
          className="h-11 w-11 min-h-[44px] min-w-[44px] rounded-xl"
        >
          <ZoomIn className="h-4 w-4" />
        </Button>
        <Button
          size="icon"
          variant="ghost"
          title="Afastar"
          aria-label="Afastar grafo"
          onClick={() => {
            zoomRef.current = Math.max(zoomRef.current * 0.8, 0.05)
            drawCanvasRef.current()
          }}
          className="h-11 w-11 min-h-[44px] min-w-[44px] rounded-xl"
        >
          <ZoomOut className="h-4 w-4" />
        </Button>
        <Button
          size="icon"
          variant="ghost"
          title="Ajustar tudo na tela"
          aria-label="Ajustar tudo na tela"
          onClick={fitToScreen}
          className="h-11 w-11 min-h-[44px] min-w-[44px] rounded-xl"
        >
          <RotateCcw className="h-4 w-4" />
        </Button>
        <Button
          size="icon"
          variant="ghost"
          title={isFullscreen ? "Reduzir altura" : "Expandir altura"}
          aria-label={isFullscreen ? "Reduzir altura" : "Expandir altura"}
          onClick={onToggleFullscreen}
          className="h-11 w-11 min-h-[44px] min-w-[44px] rounded-xl"
        >
          {isFullscreen ? (
            <Minimize2 className="h-4 w-4" />
          ) : (
            <Maximize2 className="h-4 w-4" />
          )}
        </Button>
      </div>
    </div>
  )
}

export interface RelationshipGraphViewProps {
  profiles: Profile[]
  homeGroups: HomeGroup[]
  fellowships: Fellowship[]
  sectors: Sector[]
  leaderIds: Set<string>
  initialGroupId?: string
  onSelectDisciple?: (profile: Profile) => void
  onClose?: () => void
}

export function RelationshipGraphView({
  profiles,
  homeGroups,
  fellowships,
  sectors,
  leaderIds,
  initialGroupId,
  onSelectDisciple,
  onClose,
}: RelationshipGraphViewProps) {
  const [layoutMode, setLayoutMode] = useState<GraphLayoutMode>("hierarchy")
  const [sectorFilter, setSectorFilter] = useState<string>("all")
  const [groupFilter, setGroupFilter] = useState<string>(
    initialGroupId && initialGroupId !== "unlinked" ? initialGroupId : "all"
  )
  const [genderFilter, setGenderFilter] = useState<"all" | "M" | "F">("all")
  const [diagnosticFilter, setDiagnosticFilter] = useState<DiagnosticFilter>("all")
  const [searchName, setSearchName] = useState<string>("")

  // Camadas de conexões visíveis
  const [showDiscipleshipLinks, setShowDiscipleshipLinks] = useState<boolean>(true)
  const [showFellowshipLinks, setShowFellowshipLinks] = useState<boolean>(true)
  const [showMarriageLinks, setShowMarriageLinks] = useState<boolean>(false)
  const [showChildren, setShowChildren] = useState<boolean>(false)

  // Seleção e isolamento de junta
  const [selectedNodeId, setSelectedNodeId] = useState<string | null>(null)
  const [isolatedNodeId, setIsolatedNodeId] = useState<string | null>(null)
  const [focusTargetId, setFocusTargetId] = useState<string | null>(null)
  const [isFullscreen, setIsFullscreen] = useState<boolean>(false)

  // Construir dados base de todos os discípulos vinculados à igreja
  const { allChurchNodes, profileMap } = useMemo(() => {
    const linkedProfiles = profiles.filter((p) => p.is_church_linked !== false)
    const pMap = new Map(linkedProfiles.map((p) => [p.id, p]))
    const groupMap = new Map(homeGroups.map((g) => [g.id, g]))
    const sectorMap = new Map(sectors.map((s) => [s.id, s]))

    const presbyterIds = new Set(
      linkedProfiles.filter((p) => p.is_presbyter).map((p) => p.id)
    )

    // Contagem de discípulos diretos e árvore de descendentes
    const directChildrenMap = new Map<string, string[]>()
    linkedProfiles.forEach((p) => {
      if (p.discipler_id && pMap.has(p.discipler_id)) {
        const arr = directChildrenMap.get(p.discipler_id) || []
        arr.push(p.id)
        directChildrenMap.set(p.discipler_id, arr)
      }
    })

    const lineageMemo = new Map<string, number>()
    const countLineage = (id: string, visited: Set<string>): number => {
      if (lineageMemo.has(id)) return lineageMemo.get(id)!
      const children = directChildrenMap.get(id) || []
      let total = 0
      children.forEach((cid) => {
        if (!visited.has(cid)) {
          visited.add(cid)
          total += 1 + countLineage(cid, visited)
        }
      })
      lineageMemo.set(id, total)
      return total
    }

    // Mapa de companheiros de obra (fellowships)
    const fellowshipMap = new Map<string, string[]>()
    fellowships.forEach((f) => {
      if (pMap.has(f.member_a_id) && pMap.has(f.member_b_id)) {
        const listA = fellowshipMap.get(f.member_a_id) || []
        if (!listA.includes(f.member_b_id)) listA.push(f.member_b_id)
        fellowshipMap.set(f.member_a_id, listA)

        const listB = fellowshipMap.get(f.member_b_id) || []
        if (!listB.includes(f.member_a_id)) listB.push(f.member_a_id)
        fellowshipMap.set(f.member_b_id, listB)
      }
    })

    const twoYearsAgo = new Date()
    twoYearsAgo.setFullYear(twoYearsAgo.getFullYear() - 2)

    const gNodes: GraphNode[] = linkedProfiles.map((p) => {
      const hg = p.home_group_id ? groupMap.get(p.home_group_id) : null
      const sectorObj = hg?.sector_id ? sectorMap.get(hg.sector_id) : null
      const isChild = !p.baptism_date && !!(p.father_id || p.mother_id)
      const isPresbyter = !!p.is_presbyter
      const isPresbyterSpouse = !!(p.spouse_id && presbyterIds.has(p.spouse_id))
      const isDeacon = !!p.is_deacon
      const isLeader = leaderIds.has(p.id)
      const directDisciplesCount = (directChildrenMap.get(p.id) || []).length
      const totalLineageCount = countLineage(p.id, new Set([p.id]))
      const partnerIds = fellowshipMap.get(p.id) || []
      const fellowshipsCount = partnerIds.length

      let role: RelationshipNodeRole = "disciple"
      if (isPresbyter) role = "presbyter"
      else if (isDeacon) role = "deacon"
      else if (isLeader) role = "leader"
      else if (isChild) role = "child"
      else if (directDisciplesCount > 0) role = "discipler"

      const hasNoDisciplerAlert =
        !isChild && !p.discipler_id && !isPresbyter && !isPresbyterSpouse
      const hasNoFellowshipAlert = !isChild && fellowshipsCount === 0
      const isOverloaded = directDisciplesCount >= 4

      const isMatureBaptized =
        !!p.baptism_date && new Date(p.baptism_date) <= twoYearsAgo
      const isPotentialDiscipler =
        !isChild &&
        isMatureBaptized &&
        directDisciplesCount === 0 &&
        (!!p.discipler_id || isPresbyter || isPresbyterSpouse)

      return {
        id: p.id,
        name: p.full_name,
        shortName: formatShortName(p.full_name),
        initials: formatInitials(p.full_name),
        avatarUrl: p.avatar_url,
        role,
        gender: p.gender,
        homeGroupId: p.home_group_id,
        homeGroupName: hg ? getHomeGroupDisplayName(hg, pMap) : null,
        sectorId: hg?.sector_id || null,
        sector: sectorObj?.name || "Geral",
        neighborhood: p.address_neighborhood,
        phone: p.phone,
        email: p.email,
        baptismDate: p.baptism_date,
        disciplerId: p.discipler_id,
        spouseId: p.spouse_id,
        fatherId: p.father_id,
        motherId: p.mother_id,
        isPresbyter,
        isPresbyterSpouse,
        isDeacon,
        isLeader,
        isChild,
        directDisciplesCount,
        totalLineageCount,
        fellowshipsCount,
        fellowshipPartnerIds: partnerIds,
        hasNoDisciplerAlert,
        hasNoFellowshipAlert,
        isOverloaded,
        isPotentialDiscipler,
        level: 0,
        x: 0,
        y: 0,
      }
    })

    return { allChurchNodes: gNodes, profileMap: pMap }
  }, [profiles, homeGroups, fellowships, sectors, leaderIds])

  // Filtrar nós conforme Escopo (Setor, GC, Gênero, Crianças)
  const scopedNodes = useMemo(() => {
    return allChurchNodes.filter((n) => {
      if (!showChildren && n.isChild) return false
      if (sectorFilter !== "all" && n.sectorId !== sectorFilter) return false
      if (groupFilter !== "all" && n.homeGroupId !== groupFilter) return false
      if (genderFilter !== "all" && n.gender !== genderFilter) return false
      return true
    })
  }, [allChurchNodes, showChildren, sectorFilter, groupFilter, genderFilter])

  // Estatísticas de Saúde das Juntas no Escopo Atual
  const juntaStats = useMemo(() => {
    const adults = scopedNodes.filter((n) => !n.isChild)
    const totalAdults = adults.length
    const withoutDiscipler = adults.filter((n) => n.hasNoDisciplerAlert)
    const withDisciplerCount = totalAdults - withoutDiscipler.length
    const coveragePct =
      totalAdults > 0 ? Math.round((withDisciplerCount / totalAdults) * 100) : 0

    const withoutFellowship = adults.filter((n) => n.hasNoFellowshipAlert)
    const overloaded = adults.filter((n) => n.isOverloaded)
    const potentialDisciplers = adults.filter((n) => n.isPotentialDiscipler)
    const activeDisciplers = adults.filter((n) => n.directDisciplesCount > 0)

    return {
      totalVisible: scopedNodes.length,
      totalAdults,
      withDisciplerCount,
      coveragePct,
      withoutDiscipler,
      withoutFellowship,
      overloaded,
      potentialDisciplers,
      activeDisciplersCount: activeDisciplers.length,
    }
  }, [scopedNodes])

  // Calcular Layout Ativo (Árvore, Grupos, Companheirismo ou Junta Isolada)
  const { layoutNodes, layoutZones } = useMemo(() => {
    if (isolatedNodeId) {
      const res = computeIsolatedJuntaLayout(isolatedNodeId, allChurchNodes)
      return { layoutNodes: res.nodes, layoutZones: res.zones }
    }
    if (layoutMode === "groups") {
      const res = computeGroupsClusterLayout(scopedNodes)
      return { layoutNodes: res.nodes, layoutZones: res.zones }
    }
    if (layoutMode === "fellowships") {
      const res = computeFellowshipNetworkLayout(scopedNodes)
      return { layoutNodes: res.nodes, layoutZones: res.zones }
    }
    const res = computeTidyHierarchyLayout(scopedNodes)
    return { layoutNodes: res.nodes, layoutZones: res.zones }
  }, [
    isolatedNodeId,
    layoutMode,
    scopedNodes,
    allChurchNodes,
  ])

  const layoutKey = `${layoutMode}|${isolatedNodeId || "macro"}|${sectorFilter}|${groupFilter}|${genderFilter}|${showChildren}`

  // Construir Links para os nós presentes no layout
  const activeLinks = useMemo(() => {
    const visibleSet = new Set(layoutNodes.map((n) => n.id))
    const links: GraphLink[] = []

    const showDisc = isolatedNodeId ? true : showDiscipleshipLinks
    const showFell = isolatedNodeId ? true : showFellowshipLinks
    const showMarr = isolatedNodeId ? true : showMarriageLinks || layoutMode === "groups"

    layoutNodes.forEach((n) => {
      const isSelectedSide =
        selectedNodeId !== null &&
        (n.id === selectedNodeId || n.disciplerId === selectedNodeId)
      if ((showDisc || isSelectedSide) && n.disciplerId && visibleSet.has(n.disciplerId)) {
        links.push({
          source: n.disciplerId,
          target: n.id,
          type: "discipler",
        })
      }
      if (n.isChild && (showChildren || isolatedNodeId)) {
        const parentId =
          (n.fatherId && visibleSet.has(n.fatherId) ? n.fatherId : null) ||
          (n.motherId && visibleSet.has(n.motherId) ? n.motherId : null)
        if (parentId) {
          links.push({
            source: parentId,
            target: n.id,
            type: "parent",
          })
        }
      }
      const isSelectedSpouse =
        selectedNodeId !== null &&
        (n.id === selectedNodeId || n.spouseId === selectedNodeId)
      if (
        (showMarr || isSelectedSpouse) &&
        n.spouseId &&
        n.id < n.spouseId &&
        visibleSet.has(n.spouseId)
      ) {
        links.push({
          source: n.id,
          target: n.spouseId,
          type: "marriage",
        })
      }
    })

    fellowships.forEach((f) => {
      const isSelectedFell =
        selectedNodeId !== null &&
        (f.member_a_id === selectedNodeId || f.member_b_id === selectedNodeId)
      if (
        (showFell || isSelectedFell) &&
        visibleSet.has(f.member_a_id) &&
        visibleSet.has(f.member_b_id)
      ) {
        links.push({
          source: f.member_a_id,
          target: f.member_b_id,
          type: "fellowship",
        })
      }
    })

    return links
  }, [
    layoutNodes,
    fellowships,
    isolatedNodeId,
    selectedNodeId,
    layoutMode,
    showDiscipleshipLinks,
    showFellowshipLinks,
    showMarriageLinks,
    showChildren,
  ])

  // Opções de filtro de Grupo Caseiro
  const groupSelectOptions: SearchableSelectOption[] = useMemo(() => {
    const filteredGroups =
      sectorFilter === "all"
        ? homeGroups
        : homeGroups.filter((g) => g.sector_id === sectorFilter)

    const opts: SearchableSelectOption[] = [
      {
        value: "all",
        label: `Todos os Grupos (${filteredGroups.length})`,
        description: "Exibir todos os Grupos Caseiros do recorte",
      },
    ]

    const sectorMap = new Map(sectors.map((s) => [s.id, s.name]))
    filteredGroups.forEach((hg) => {
      const count = allChurchNodes.filter(
        (n) => n.homeGroupId === hg.id && (showChildren || !n.isChild)
      ).length
      const displayName = getHomeGroupDisplayName(hg, profileMap)
      const secName = hg.sector_id ? sectorMap.get(hg.sector_id) : undefined
      opts.push({
        value: hg.id,
        label: `${displayName} (${count})`,
        description: hg.location_text || undefined,
        badge: secName,
        keywords: `${displayName} ${hg.location_text || ""} ${secName || ""}`,
      })
    })

    return opts
  }, [homeGroups, sectors, sectorFilter, allChurchNodes, showChildren, profileMap])

  // Nó atualmente selecionado e seus relacionamentos detalhados para o Painel de Inspeção
  const selectedNodeData = useMemo(() => {
    if (!selectedNodeId) return null
    const node = allChurchNodes.find((n) => n.id === selectedNodeId)
    const rawProfile = profileMap.get(selectedNodeId)
    if (!node || !rawProfile) return null

    const discipler = node.disciplerId
      ? allChurchNodes.find((n) => n.id === node.disciplerId) || null
      : null
    const directDisciples = allChurchNodes
      .filter((n) => n.disciplerId === node.id)
      .sort((a, b) => a.name.localeCompare(b.name))
    const companions = node.fellowshipPartnerIds
      .map((id) => allChurchNodes.find((n) => n.id === id))
      .filter((n): n is GraphNode => Boolean(n))
    const spouse = node.spouseId
      ? allChurchNodes.find((n) => n.id === node.spouseId) || null
      : null
    const parents = [node.fatherId, node.motherId]
      .filter((pid): pid is string => Boolean(pid))
      .map((pid) => allChurchNodes.find((n) => n.id === pid))
      .filter((n): n is GraphNode => Boolean(n))
    const children = allChurchNodes
      .filter((n) => n.fatherId === node.id || n.motherId === node.id)
      .sort((a, b) => a.name.localeCompare(b.name))

    return {
      node,
      rawProfile,
      discipler,
      directDisciples,
      companions,
      spouse,
      parents,
      children,
    }
  }, [selectedNodeId, allChurchNodes, profileMap])

  // Lista rápida de resultados para o filtro de diagnóstico ativo ou busca textual
  const diagnosticMatchedNodes = useMemo(() => {
    if (diagnosticFilter === "no_discipler") return juntaStats.withoutDiscipler
    if (diagnosticFilter === "no_fellowship") return juntaStats.withoutFellowship
    if (diagnosticFilter === "overloaded") return juntaStats.overloaded
    if (diagnosticFilter === "potential_disciplers") return juntaStats.potentialDisciplers
    return []
  }, [diagnosticFilter, juntaStats])

  const searchMatchedNodes = useMemo(() => {
    const q = searchName.trim().toLowerCase()
    if (!q) return []
    return scopedNodes
      .filter(
        (n) =>
          n.name.toLowerCase().includes(q) ||
          (n.homeGroupName?.toLowerCase().includes(q) ?? false) ||
          n.sector.toLowerCase().includes(q)
      )
      .slice(0, 24)
  }, [searchName, scopedNodes])

  const handleJumpToBrother = (id: string) => {
    const target = allChurchNodes.find((n) => n.id === id)
    if (!target) return

    // Se o irmão alvo está oculto pelos filtros atuais, reconciliar filtros automaticamente
    if (target.isChild && !showChildren) {
      setShowChildren(true)
    }
    if (genderFilter !== "all" && target.gender !== genderFilter) {
      setGenderFilter("all")
    }
    if (groupFilter !== "all" && target.homeGroupId !== groupFilter) {
      setGroupFilter("all")
    }
    if (sectorFilter !== "all" && target.sectorId !== sectorFilter) {
      setSectorFilter("all")
    }
    if (isolatedNodeId && !layoutNodes.some((n) => n.id === id)) {
      setIsolatedNodeId(id)
    }

    setSelectedNodeId(id)
    setFocusTargetId(id)
  }

  return (
    <div className="space-y-4">
      {/* 1. Cartões de Diagnóstico Rápido das Juntas (Interativos / Mobile-First 320px Seguro) */}
      <div className="grid grid-cols-1 min-[480px]:grid-cols-2 lg:grid-cols-4 gap-2.5">
        <button
          type="button"
          onClick={() => setDiagnosticFilter("all")}
          className={`flex min-h-[76px] flex-col justify-between rounded-xl border p-3.5 text-left transition-colors cursor-pointer ${
            diagnosticFilter === "all"
              ? "border-primary bg-primary/5"
              : "border-border/80 bg-card hover:border-border"
          }`}
        >
          <div className="flex flex-wrap items-center justify-between gap-1.5">
            <span className="text-xs font-medium text-muted-foreground flex items-center gap-1.5">
              <Users className="h-3.5 w-3.5 shrink-0 text-primary" />
              <span>Irmãos no Grafo</span>
            </span>
            <Badge variant="outline" className="text-[10px] px-1.5 py-0">
              {juntaStats.coveragePct}% cobertos
            </Badge>
          </div>
          <div className="mt-2 flex items-baseline justify-between gap-2">
            <span className="text-xl font-bold text-foreground">
              {juntaStats.totalVisible}
            </span>
            <span className="text-[11px] text-muted-foreground">
              {juntaStats.activeDisciplersCount} discipuladores
            </span>
          </div>
        </button>

        <button
          type="button"
          onClick={() =>
            setDiagnosticFilter(
              diagnosticFilter === "no_discipler" ? "all" : "no_discipler"
            )
          }
          className={`flex min-h-[76px] flex-col justify-between rounded-xl border p-3.5 text-left transition-colors cursor-pointer ${
            diagnosticFilter === "no_discipler"
              ? "border-destructive bg-destructive/10"
              : "border-border/80 bg-card hover:border-border"
          }`}
        >
          <div className="flex flex-wrap items-center justify-between gap-1.5">
            <span className="text-xs font-medium text-muted-foreground flex items-center gap-1.5">
              <AlertCircle className="h-3.5 w-3.5 shrink-0 text-destructive" />
              <span>Sem Discipulador</span>
            </span>
            <Badge
              variant="outline"
              className={
                juntaStats.withoutDiscipler.length > 0
                  ? THEME_CLASSES.badgeDestructive
                  : THEME_CLASSES.badgeSuccess
              }
            >
              {juntaStats.withoutDiscipler.length > 0 ? "Atenção" : "100% Em Dia"}
            </Badge>
          </div>
          <div className="mt-2 flex items-baseline justify-between gap-2">
            <span className="text-xl font-bold text-foreground">
              {juntaStats.withoutDiscipler.length}
            </span>
            <span className="text-[11px] text-muted-foreground">
              Toque para destacar
            </span>
          </div>
        </button>

        <button
          type="button"
          onClick={() =>
            setDiagnosticFilter(
              diagnosticFilter === "no_fellowship" ? "all" : "no_fellowship"
            )
          }
          className={`flex min-h-[76px] flex-col justify-between rounded-xl border p-3.5 text-left transition-colors cursor-pointer ${
            diagnosticFilter === "no_fellowship"
              ? GRAPH_UI_CLASSES.kpiWarningActive
              : "border-border/80 bg-card hover:border-border"
          }`}
        >
          <div className="flex flex-wrap items-center justify-between gap-1.5">
            <span className="text-xs font-medium text-muted-foreground flex items-center gap-1.5">
              <HeartHandshake className={`h-3.5 w-3.5 shrink-0 ${GRAPH_UI_CLASSES.kpiWarningIcon}`} />
              <span>Sem Companheiro</span>
            </span>
            <Badge variant="outline" className={THEME_CLASSES.badgeWarning}>
              Junta Horizontal
            </Badge>
          </div>
          <div className="mt-2 flex items-baseline justify-between gap-2">
            <span className="text-xl font-bold text-foreground">
              {juntaStats.withoutFellowship.length}
            </span>
            <span className="text-[11px] text-muted-foreground">
              Sem vínculo de obra
            </span>
          </div>
        </button>

        <button
          type="button"
          onClick={() =>
            setDiagnosticFilter(
              diagnosticFilter === "overloaded" ? "all" : "overloaded"
            )
          }
          className={`flex min-h-[76px] flex-col justify-between rounded-xl border p-3.5 text-left transition-colors cursor-pointer ${
            diagnosticFilter === "overloaded"
              ? "border-primary bg-primary/10"
              : "border-border/80 bg-card hover:border-border"
          }`}
        >
          <div className="flex flex-wrap items-center justify-between gap-1.5">
            <span className="text-xs font-medium text-muted-foreground flex items-center gap-1.5">
              <GitBranch className="h-3.5 w-3.5 shrink-0 text-primary" />
              <span>Carga ≥ 4 Discípulos</span>
            </span>
            <Badge variant="outline" className="text-[10px] px-1.5 py-0">
              {juntaStats.potentialDisciplers.length} disponíveis
            </Badge>
          </div>
          <div className="mt-2 flex items-baseline justify-between gap-2">
            <span className="text-xl font-bold text-foreground">
              {juntaStats.overloaded.length}
            </span>
            <span className="text-[11px] text-muted-foreground">
              Discipuladores densos
            </span>
          </div>
        </button>
      </div>

      {/* 2. Barra de Modos de Visualização e Filtros das Juntas */}
      <div className="space-y-3 rounded-2xl border border-border/80 bg-card p-3.5 shadow-2xs">
        {/* Linha 1: Seletor de Modo de Grafo + Gênero + Fechar */}
        <div className="flex flex-col gap-2.5 lg:flex-row lg:items-center lg:justify-between">
          {/* Modos de Layout */}
          <div className="flex flex-wrap items-center gap-1.5">
            <Button
              type="button"
              size="sm"
              variant={layoutMode === "hierarchy" && !isolatedNodeId ? "default" : "outline"}
              onClick={() => {
                setIsolatedNodeId(null)
                setLayoutMode("hierarchy")
              }}
              className="h-11 min-h-[44px] gap-1.5 rounded-xl text-xs font-medium"
            >
              <GitBranch className="h-4 w-4" />
              <span>Árvore de Discipulado</span>
            </Button>

            <Button
              type="button"
              size="sm"
              variant={layoutMode === "groups" && !isolatedNodeId ? "default" : "outline"}
              onClick={() => {
                setIsolatedNodeId(null)
                setLayoutMode("groups")
              }}
              className="h-11 min-h-[44px] gap-1.5 rounded-xl text-xs font-medium"
            >
              <Home className="h-4 w-4" />
              <span>Juntas por Grupo Caseiro</span>
            </Button>

            <Button
              type="button"
              size="sm"
              variant={layoutMode === "fellowships" && !isolatedNodeId ? "default" : "outline"}
              onClick={() => {
                setIsolatedNodeId(null)
                setLayoutMode("fellowships")
              }}
              className="h-11 min-h-[44px] gap-1.5 rounded-xl text-xs font-medium"
            >
              <HeartHandshake className="h-4 w-4" />
              <span>Rede de Companheirismo</span>
            </Button>

            {isolatedNodeId && (
              <Button
                type="button"
                size="sm"
                variant="secondary"
                onClick={() => {
                  setIsolatedNodeId(null)
                }}
                className="h-11 min-h-[44px] gap-1.5 rounded-xl text-xs font-semibold border border-primary/30 bg-primary/10 text-primary"
              >
                <RotateCcw className="h-3.5 w-3.5" />
                <span>Sair da Junta Isolada</span>
              </Button>
            )}
          </div>

          {/* Filtro Rápido por Gênero (Essencial pois discipulado e companheirismo são por gênero) + Fechar */}
          <div className="flex flex-wrap items-center gap-2">
            <div className="inline-flex flex-wrap rounded-xl border border-border bg-muted/40 p-1">
              <button
                type="button"
                onClick={() => setGenderFilter("all")}
                className={`h-11 min-h-[44px] px-3 rounded-lg text-xs font-medium transition-colors cursor-pointer ${
                  genderFilter === "all"
                    ? "bg-background text-foreground shadow-2xs"
                    : "text-muted-foreground hover:text-foreground"
                }`}
              >
                Todos
              </button>
              <button
                type="button"
                onClick={() => setGenderFilter("M")}
                className={`h-11 min-h-[44px] px-3 rounded-lg text-xs font-medium transition-colors cursor-pointer ${
                  genderFilter === "M"
                    ? "bg-background text-foreground shadow-2xs"
                    : "text-muted-foreground hover:text-foreground"
                }`}
              >
                Irmãos (M)
              </button>
              <button
                type="button"
                onClick={() => setGenderFilter("F")}
                className={`h-11 min-h-[44px] px-3 rounded-lg text-xs font-medium transition-colors cursor-pointer ${
                  genderFilter === "F"
                    ? "bg-background text-foreground shadow-2xs"
                    : "text-muted-foreground hover:text-foreground"
                }`}
              >
                Irmãs (F)
              </button>
            </div>

            {onClose && (
              <Button
                variant="outline"
                size="sm"
                onClick={onClose}
                className="h-11 min-h-[44px] gap-1.5 rounded-xl text-xs"
              >
                <X className="h-4 w-4" />
                <span>Fechar Grafo</span>
              </Button>
            )}
          </div>
        </div>

        {/* Linha 2: Filtros de Setor, Grupo Caseiro e Busca por Nome */}
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-12 gap-2.5 pt-2 border-t border-border/60">
          {/* Setor via shadcn Select */}
          <div className="lg:col-span-3">
            <Select
              value={sectorFilter}
              onValueChange={(val) => {
                setSectorFilter(val)
                setGroupFilter("all")
              }}
            >
              <SelectTrigger
                aria-label="Filtrar por Setor"
                className="h-11 min-h-[44px] w-full rounded-xl text-xs font-medium"
              >
                <SelectValue placeholder="Filtrar por Setor..." />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="all">
                  Todos os Setores ({sectors.length})
                </SelectItem>
                {sectors.map((s) => (
                  <SelectItem key={s.id} value={s.id}>
                    Setor: {s.name}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>

          {/* Grupo Caseiro */}
          <div className="lg:col-span-4">
            <SearchableSelect
              options={groupSelectOptions}
              value={groupFilter}
              onValueChange={(val) => {
                setGroupFilter(val || "all")
              }}
              placeholder="Filtrar por Grupo Caseiro..."
              clearable={false}
              triggerClassName="h-11 min-h-[44px] rounded-xl text-xs"
            />
          </div>

          {/* Busca de Irmão */}
          <div className="relative lg:col-span-5">
            <Search className="pointer-events-none absolute top-1/2 left-3 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
            <Input
              value={searchName}
              onChange={(e) => setSearchName(e.target.value)}
              placeholder="Buscar irmão por nome para destacar..."
              className="h-11 min-h-[44px] w-full rounded-xl pl-9 pr-12 text-xs"
            />
            {searchName && (
              <button
                type="button"
                onClick={() => setSearchName("")}
                aria-label="Limpar busca"
                className="absolute top-1/2 right-0.5 flex h-11 w-11 min-h-[44px] min-w-[44px] -translate-y-1/2 items-center justify-center rounded-lg text-muted-foreground hover:bg-muted hover:text-foreground cursor-pointer"
              >
                <X className="h-4 w-4" />
              </button>
            )}
          </div>
        </div>

        {/* Linha 3: Camadas Visíveis (Toggles de Juntas) */}
        <div className="flex flex-wrap items-center justify-between gap-2 pt-1 text-xs">
          <div className="flex flex-wrap items-center gap-1.5">
            <span className="mr-1 flex items-center gap-1 font-medium text-muted-foreground">
              <Eye className="h-3.5 w-3.5" />
              Camadas:
            </span>
            <button
              type="button"
              onClick={() => setShowDiscipleshipLinks((v) => !v)}
              className={`min-h-[44px] rounded-xl border px-3 py-1.5 text-xs font-medium transition-colors cursor-pointer ${
                showDiscipleshipLinks
                  ? GRAPH_UI_CLASSES.layerToggleDisciplerActive
                  : GRAPH_UI_CLASSES.layerToggleInactive
              }`}
            >
              Discipulado
            </button>
            <button
              type="button"
              onClick={() => setShowFellowshipLinks((v) => !v)}
              className={`min-h-[44px] rounded-xl border px-3 py-1.5 text-xs font-medium transition-colors cursor-pointer ${
                showFellowshipLinks
                  ? GRAPH_UI_CLASSES.layerToggleFellowshipActive
                  : GRAPH_UI_CLASSES.layerToggleInactive
              }`}
            >
              Companheirismo
            </button>
            <button
              type="button"
              onClick={() => setShowMarriageLinks((v) => !v)}
              className={`min-h-[44px] rounded-xl border px-3 py-1.5 text-xs font-medium transition-colors cursor-pointer ${
                showMarriageLinks || layoutMode === "groups"
                  ? GRAPH_UI_CLASSES.layerToggleMarriageActive
                  : GRAPH_UI_CLASSES.layerToggleInactive
              }`}
            >
              Casais
            </button>
            <button
              type="button"
              onClick={() => setShowChildren((v) => !v)}
              className={`min-h-[44px] rounded-xl border px-3 py-1.5 text-xs font-medium transition-colors cursor-pointer ${
                showChildren
                  ? GRAPH_UI_CLASSES.layerToggleChildActive
                  : GRAPH_UI_CLASSES.layerToggleInactive
              }`}
            >
              Incluir Crianças
            </button>
            <button
              type="button"
              onClick={() =>
                setDiagnosticFilter(
                  diagnosticFilter === "potential_disciplers"
                    ? "all"
                    : "potential_disciplers"
                )
              }
              className={`min-h-[44px] rounded-xl border px-3 py-1.5 text-xs font-medium transition-colors cursor-pointer ${
                diagnosticFilter === "potential_disciplers"
                  ? GRAPH_UI_CLASSES.layerTogglePotentialActive
                  : GRAPH_UI_CLASSES.layerToggleInactive
              }`}
            >
              Potenciais Discipuladores ({juntaStats.potentialDisciplers.length})
            </button>
          </div>

          {(sectorFilter !== "all" ||
            groupFilter !== "all" ||
            genderFilter !== "all" ||
            diagnosticFilter !== "all" ||
            searchName.trim() !== "" ||
            isolatedNodeId !== null) && (
            <Button
              type="button"
              variant="ghost"
              size="sm"
              onClick={() => {
                setSectorFilter("all")
                setGroupFilter("all")
                setGenderFilter("all")
                setDiagnosticFilter("all")
                setSearchName("")
                setIsolatedNodeId(null)
                setSelectedNodeId(null)
              }}
              className="h-11 min-h-[44px] rounded-xl text-xs text-muted-foreground hover:text-foreground"
            >
              <Filter className="mr-1.5 h-3.5 w-3.5" />
              Limpar Filtros
            </Button>
          )}
        </div>

        {/* Barra de resultados rápidos quando um filtro de diagnóstico ou busca textual está ativo */}
        {((diagnosticFilter !== "all" && diagnosticMatchedNodes.length > 0) ||
          (searchName.trim() !== "" && searchMatchedNodes.length > 0)) && (
          <div className="rounded-xl border border-border/80 bg-muted/30 p-2.5">
            <div className="mb-1.5 flex flex-wrap items-center justify-between gap-1 text-xs">
              <span className="font-semibold text-foreground">
                {searchName.trim() !== "" ? (
                  `Resultados para "${searchName.trim()}" (${searchMatchedNodes.length}):`
                ) : (
                  <>
                    {diagnosticFilter === "no_discipler" &&
                      `Irmãos sem Discipulador (${diagnosticMatchedNodes.length}):`}
                    {diagnosticFilter === "no_fellowship" &&
                      `Irmãos sem Companheiro de Obra (${diagnosticMatchedNodes.length}):`}
                    {diagnosticFilter === "overloaded" &&
                      `Discipuladores com 4+ Discípulos Diretos (${diagnosticMatchedNodes.length}):`}
                    {diagnosticFilter === "potential_disciplers" &&
                      `Maduros (≥2 anos de batismo) que ainda não discipulam (${diagnosticMatchedNodes.length}):`}
                  </>
                )}
              </span>
              <span className="text-[11px] text-muted-foreground">
                Selecione um nome para centralizar e inspecionar
              </span>
            </div>
            <div className="flex max-h-32 flex-wrap gap-1.5 overflow-y-auto">
              {(searchName.trim() !== "" ? searchMatchedNodes : diagnosticMatchedNodes).map(
                (n) => (
                  <button
                    key={n.id}
                    type="button"
                    onClick={() => handleJumpToBrother(n.id)}
                    className={`inline-flex min-h-[44px] items-center gap-1.5 rounded-xl border px-3 py-1.5 text-xs font-medium transition-colors cursor-pointer ${
                      selectedNodeId === n.id
                        ? "border-primary bg-primary text-primary-foreground"
                        : "border-border bg-background text-foreground hover:bg-muted"
                    }`}
                  >
                    <span>{n.name}</span>
                    {n.directDisciplesCount > 0 && (
                      <span className="rounded bg-muted px-1.5 py-0.5 text-[10px] text-muted-foreground">
                        {n.directDisciplesCount}
                      </span>
                    )}
                  </button>
                )
              )}
            </div>
          </div>
        )}
      </div>

      {/* 3. Área Principal: Canvas + Painel Lateral/Inferior de Raio-X da Junta */}
      <div className="grid grid-cols-1 lg:grid-cols-12 gap-4 items-start">
        <div className={selectedNodeData ? "lg:col-span-8" : "lg:col-span-12"}>
          <RelationshipGraphCanvas
            nodes={layoutNodes}
            zones={layoutZones}
            links={activeLinks}
            layoutMode={layoutMode}
            layoutKey={layoutKey}
            searchName={searchName}
            diagnosticFilter={diagnosticFilter}
            selectedNodeId={selectedNodeId}
            isolatedNodeId={isolatedNodeId}
            focusTargetId={focusTargetId}
            onSelectNode={setSelectedNodeId}
            onDoubleClickNode={(id) => {
              setSelectedNodeId(id)
              setIsolatedNodeId((prev) => (prev === id ? null : id))
            }}
            onFocusHandled={() => setFocusTargetId(null)}
            isFullscreen={isFullscreen}
            onToggleFullscreen={() => setIsFullscreen((v) => !v)}
          />
        </div>

        {/* Painel de Raio-X das Juntas do Irmão Selecionado */}
        {selectedNodeData && (
          <div className="lg:col-span-4 rounded-2xl border border-border bg-card p-4 shadow-sm space-y-4">
            {/* Cabeçalho do Irmão */}
            <div className="flex items-start justify-between gap-2 border-b border-border/60 pb-3">
              <div className="flex items-center gap-3 min-w-0">
                <div
                  className={`flex h-11 w-11 shrink-0 items-center justify-center rounded-full font-bold text-sm ${
                    RELATIONSHIP_NODE_COLORS[selectedNodeData.node.role].avatarClass
                  }`}
                >
                  {selectedNodeData.node.initials}
                </div>
                <div className="min-w-0">
                  <h4 className="truncate font-bold text-foreground text-base">
                    {selectedNodeData.node.name}
                  </h4>
                  <div className="mt-0.5 flex flex-wrap items-center gap-1.5">
                    <Badge variant="outline" className="text-[11px]">
                      {RELATIONSHIP_NODE_COLORS[selectedNodeData.node.role].label}
                    </Badge>
                    <span className="text-xs text-muted-foreground truncate">
                      {selectedNodeData.node.homeGroupName || "Sem Grupo Caseiro"}
                    </span>
                  </div>
                </div>
              </div>
              <Button
                size="icon"
                variant="ghost"
                aria-label="Fechar painel do irmão"
                onClick={() => setSelectedNodeId(null)}
                className="h-11 w-11 min-h-[44px] min-w-[44px] shrink-0 rounded-xl"
              >
                <X className="h-4 w-4" />
              </Button>
            </div>

            {/* Ações Rápidas de Foco no Grafo */}
            <div className="grid grid-cols-2 gap-2">
              <Button
                type="button"
                variant={
                  isolatedNodeId === selectedNodeData.node.id ? "default" : "outline"
                }
                size="sm"
                onClick={() => {
                  setIsolatedNodeId((prev) =>
                    prev === selectedNodeData.node.id ? null : selectedNodeData.node.id
                  )
                }}
                className="h-11 min-h-[44px] gap-1.5 rounded-xl text-xs font-medium"
              >
                <Focus className="h-4 w-4" />
                <span>
                  {isolatedNodeId === selectedNodeData.node.id
                    ? "Ver Todo o Corpo"
                    : "Isolar Junta"}
                </span>
              </Button>

              <Button
                type="button"
                variant="outline"
                size="sm"
                onClick={() => handleJumpToBrother(selectedNodeData.node.id)}
                className="h-11 min-h-[44px] gap-1.5 rounded-xl text-xs font-medium"
              >
                <UserCheck className="h-4 w-4" />
                <span>Centralizar</span>
              </Button>
            </div>

            {/* Seção 1: Cobertura de Discipulado */}
            <div className="space-y-2 rounded-xl bg-muted/40 p-3 text-xs">
              <div className="font-semibold text-foreground flex items-center justify-between">
                <span>1. Cobertura de Discipulado</span>
                <span className="text-[11px] font-normal text-muted-foreground">
                  Cuidado Vertical
                </span>
              </div>

              {selectedNodeData.discipler ? (
                <button
                  type="button"
                  onClick={() => handleJumpToBrother(selectedNodeData.discipler!.id)}
                  className="flex min-h-[44px] w-full items-center justify-between rounded-xl border border-border/80 bg-background px-3 py-2 text-left transition-colors hover:border-primary cursor-pointer"
                >
                  <div>
                    <div className="text-[10px] text-muted-foreground">
                      Discipulado(a) por:
                    </div>
                    <div className="font-semibold text-foreground">
                      {selectedNodeData.discipler.name}
                    </div>
                  </div>
                  <ChevronRight className="h-4 w-4 text-muted-foreground" />
                </button>
              ) : selectedNodeData.node.isPresbyter ||
                selectedNodeData.node.isPresbyterSpouse ? (
                <div className="rounded-xl border border-primary/30 bg-primary/10 px-3 py-2 text-primary font-medium">
                  Prestação de contas e discipulado mútuo no Presbitério
                </div>
              ) : (
                <div className="rounded-xl border border-destructive/30 bg-destructive/10 px-3 py-2 text-destructive font-medium">
                  Sem discipulador definido — necessita vinculação
                </div>
              )}
            </div>

            {/* Seção 2: Quem este irmão discipula */}
            <div className="space-y-2 rounded-xl bg-muted/40 p-3 text-xs">
              <div className="flex items-center justify-between">
                <span className="font-semibold text-foreground">
                  2. Discípulos Acompanhados ({selectedNodeData.directDisciples.length})
                </span>
                {selectedNodeData.node.totalLineageCount >
                  selectedNodeData.directDisciples.length && (
                  <Badge variant="outline" className="text-[10px]">
                    {selectedNodeData.node.totalLineageCount} descendentes
                  </Badge>
                )}
              </div>

              {selectedNodeData.directDisciples.length > 0 ? (
                <div className="space-y-1.5 max-h-48 overflow-y-auto pr-1">
                  {selectedNodeData.directDisciples.map((disc) => (
                    <button
                      key={disc.id}
                      type="button"
                      onClick={() => handleJumpToBrother(disc.id)}
                      className="flex min-h-[44px] w-full items-center justify-between rounded-xl border border-border/70 bg-background px-3 py-2 text-left transition-colors hover:border-primary cursor-pointer"
                    >
                      <div className="min-w-0">
                        <div className="truncate font-medium text-foreground">
                          {disc.name}
                        </div>
                        <div className="text-[10px] text-muted-foreground">
                          {disc.homeGroupName || "Sem GC"}
                          {disc.directDisciplesCount > 0
                            ? ` • cuida de ${disc.directDisciplesCount}`
                            : ""}
                        </div>
                      </div>
                      <ChevronRight className="h-4 w-4 shrink-0 text-muted-foreground" />
                    </button>
                  ))}
                </div>
              ) : (
                <p className="text-[11px] text-muted-foreground italic">
                  Não acompanha discípulos diretamente no momento.
                </p>
              )}
            </div>

            {/* Seção 3: Juntas de Companheirismo */}
            <div className="space-y-2 rounded-xl bg-muted/40 p-3 text-xs">
              <div className="flex items-center justify-between">
                <span className="font-semibold text-foreground">
                  3. Companheiros de Obra ({selectedNodeData.companions.length})
                </span>
                <span className="text-[11px] text-muted-foreground">
                  Junta Horizontal
                </span>
              </div>

              {selectedNodeData.companions.length > 0 ? (
                <div className="flex flex-wrap gap-1.5">
                  {selectedNodeData.companions.map((comp) => (
                    <button
                      key={comp.id}
                      type="button"
                      onClick={() => handleJumpToBrother(comp.id)}
                      className="inline-flex min-h-[44px] items-center gap-1.5 rounded-xl border border-border/80 bg-background px-3 py-1.5 text-xs font-medium text-foreground hover:border-primary cursor-pointer"
                    >
                      <span>{comp.name}</span>
                      <ChevronRight className="h-3.5 w-3.5 text-muted-foreground" />
                    </button>
                  ))}
                </div>
              ) : (
                <div className={`rounded-xl border px-3 py-2 font-medium ${GRAPH_UI_CLASSES.inspectorWarningBox}`}>
                  Sem companheiro de obra registrado
                </div>
              )}
            </div>

            {/* Seção 4: Vínculo Familiar (Cônjuge, Pais e Filhos) */}
            {(selectedNodeData.spouse ||
              selectedNodeData.parents.length > 0 ||
              selectedNodeData.children.length > 0) && (
              <div className="space-y-2 rounded-xl bg-muted/40 p-3 text-xs">
                <span className="font-semibold text-foreground block">
                  4. Família na Comunhão
                </span>

                {selectedNodeData.spouse && (
                  <button
                    type="button"
                    onClick={() => handleJumpToBrother(selectedNodeData.spouse!.id)}
                    className="flex min-h-[44px] w-full items-center justify-between rounded-xl border border-border/70 bg-background px-3 py-2 text-left hover:border-primary cursor-pointer"
                  >
                    <span>
                      <span className="text-muted-foreground">Cônjuge: </span>
                      <strong className="text-foreground">
                        {selectedNodeData.spouse.name}
                      </strong>
                    </span>
                    <ChevronRight className="h-4 w-4 text-muted-foreground" />
                  </button>
                )}

                {selectedNodeData.parents.map((parent) => (
                  <button
                    key={parent.id}
                    type="button"
                    onClick={() => handleJumpToBrother(parent.id)}
                    className="flex min-h-[44px] w-full items-center justify-between rounded-xl border border-border/70 bg-background px-3 py-2 text-left hover:border-primary cursor-pointer"
                  >
                    <span>
                      <span className="text-muted-foreground">
                        {parent.gender === "F" ? "Mãe: " : "Pai: "}
                      </span>
                      <strong className="text-foreground">{parent.name}</strong>
                    </span>
                    <ChevronRight className="h-4 w-4 text-muted-foreground" />
                  </button>
                ))}

                {selectedNodeData.children.map((child) => (
                  <button
                    key={child.id}
                    type="button"
                    onClick={() => handleJumpToBrother(child.id)}
                    className="flex min-h-[44px] w-full items-center justify-between rounded-xl border border-border/70 bg-background px-3 py-2 text-left hover:border-primary cursor-pointer"
                  >
                    <span>
                      <span className="text-muted-foreground">
                        {child.gender === "F" ? "Filha: " : "Filho: "}
                      </span>
                      <strong className="text-foreground">{child.name}</strong>
                    </span>
                    <ChevronRight className="h-4 w-4 text-muted-foreground" />
                  </button>
                ))}
              </div>
            )}

            {/* Ações Diretas: WhatsApp e Edição de Vínculos */}
            <div className="flex items-center gap-2 pt-2 border-t border-border/60">
              {selectedNodeData.node.phone && (
                <Button
                  asChild
                  variant="outline"
                  className="h-11 min-h-[44px] flex-1 gap-1.5 rounded-xl text-xs font-medium"
                >
                  <a
                    href={`https://wa.me/55${selectedNodeData.node.phone.replace(/\D/g, "")}`}
                    target="_blank"
                    rel="noopener noreferrer"
                  >
                    <MessageSquare className="h-4 w-4 text-primary" />
                    <span>WhatsApp</span>
                  </a>
                </Button>
              )}

              {onSelectDisciple && (
                <Button
                  type="button"
                  onClick={() => onSelectDisciple(selectedNodeData.rawProfile)}
                  className="h-11 min-h-[44px] flex-1 gap-1.5 rounded-xl text-xs font-semibold"
                >
                  <Edit className="h-4 w-4" />
                  <span>Editar Vínculos</span>
                </Button>
              )}
            </div>
          </div>
        )}
      </div>
    </div>
  )
}
