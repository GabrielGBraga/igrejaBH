import { useState, useRef, useMemo, useEffect, useCallback } from "react"
import {
  ZoomIn,
  ZoomOut,
  Maximize2,
  X,
} from "lucide-react"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import type { Database } from "@/lib/database.types"
import {
  GRAPH_LINK_COLORS,
  STATUS_COLORS,
  PALETTE,
} from "@/constants/colors"

type Profile = Database["public"]["Tables"]["profiles"]["Row"]
type HomeGroup = Database["public"]["Tables"]["home_groups"]["Row"]
type Fellowship = Database["public"]["Tables"]["fellowships"]["Row"]
type Sector = Database["public"]["Tables"]["sectors"]["Row"]

interface GraphNode {
  id: string
  name: string
  avatarUrl: string | null
  role: "presbyter" | "deacon" | "leader" | "discipler" | "disciple" | "child"
  gender: string | null
  homeGroupId: string | null
  homeGroupName: string | null
  sector: string
  neighborhood: string | null
  phone: string | null
  email: string | null
  disciplerId: string | null
  spouseId: string | null
  level?: number
  x: number
  y: number
}

interface GraphLink {
  source: string
  target: string
  type: "discipler" | "fellowship" | "group_leader" | "marriage"
}

interface TreeNode {
  id: string
  nodes: GraphNode[]
  parent: TreeNode | null
  children: TreeNode[]
  level: number
  prelimX: number
  x: number
  y: number
  width: number
  leftContour: Map<number, number>
  rightContour: Map<number, number>
}

function wouldCreateCycle(parent: TreeNode, child: TreeNode): boolean {
  let current: TreeNode | null = parent
  while (current !== null) {
    if (current.id === child.id) return true
    current = current.parent
  }
  return false
}

function computeStaticHierarchyLayout(
  nodes: GraphNode[],
  links: GraphLink[],
  _width: number,
  _height: number,
  options?: {
    levelSpacing?: number
    nodeWidth?: number
    spouseGap?: number
  }
): GraphNode[] {
  const {
    levelSpacing = 140,
    nodeWidth = 36,
    spouseGap = 16,
  } = options || {}

  if (nodes.length === 0) return []

  const nodeMap = new Map<string, GraphNode>(nodes.map((n) => [n.id, n]))
  const spouseMap = new Map<string, string>()
  nodes.forEach((n) => {
    if (n.spouseId && nodeMap.has(n.spouseId)) {
      spouseMap.set(n.id, n.spouseId)
    }
  })

  const treeNodes: TreeNode[] = []
  const nodeToTreeNodeMap = new Map<string, TreeNode>()
  const processedNodes = new Set<string>()

  nodes.forEach((n) => {
    if (processedNodes.has(n.id)) return

    const spouseId = spouseMap.get(n.id)
    const nodesInGroup: GraphNode[] = [n]
    processedNodes.add(n.id)

    if (spouseId && !processedNodes.has(spouseId)) {
      const spouseNode = nodeMap.get(spouseId)
      if (spouseNode) {
        nodesInGroup.push(spouseNode)
        processedNodes.add(spouseId)
      }
    }

    const treeNodeId = nodesInGroup
      .map((x) => x.id)
      .sort()
      .join("_")

    const tn: TreeNode = {
      id: treeNodeId,
      nodes: nodesInGroup,
      parent: null,
      children: [],
      level: 0,
      prelimX: 0,
      x: 0,
      y: 0,
      width:
        nodesInGroup.length > 1 ? nodeWidth * 2 + spouseGap : nodeWidth,
      leftContour: new Map(),
      rightContour: new Map(),
    }

    treeNodes.push(tn)
    nodesInGroup.forEach((node) => nodeToTreeNodeMap.set(node.id, tn))
  })

  links.forEach((link) => {
    if (link.type !== "discipler") return
    const parentTN = nodeToTreeNodeMap.get(link.source)
    const childTN = nodeToTreeNodeMap.get(link.target)

    if (
      parentTN &&
      childTN &&
      parentTN !== childTN &&
      childTN.parent === null
    ) {
      if (!wouldCreateCycle(parentTN, childTN)) {
        childTN.parent = parentTN
        parentTN.children.push(childTN)
      }
    }
  })

  const roots = treeNodes.filter((tn) => tn.parent === null)

  const assignLevels = (node: TreeNode, lvl: number) => {
    node.level = lvl
    node.y = 80 + lvl * levelSpacing
    node.children.forEach((c) => assignLevels(c, lvl + 1))
  }
  roots.forEach((r) => assignLevels(r, 0))

  const bottomUpPositioning = (node: TreeNode) => {
    node.children.forEach(bottomUpPositioning)

    if (node.children.length === 0) {
      node.prelimX = 0
    } else if (node.children.length === 1) {
      node.prelimX = node.children[0].prelimX
    } else {
      const first = node.children[0]
      const last = node.children[node.children.length - 1]
      node.prelimX = (first.prelimX + last.prelimX) / 2
    }
  }

  roots.forEach(bottomUpPositioning)

  let currentRootX = 100
  roots.forEach((root) => {
    const shiftSubtree = (node: TreeNode, shift: number) => {
      node.x = node.prelimX + shift
      node.children.forEach((c) => shiftSubtree(c, shift))
    }
    shiftSubtree(root, currentRootX)
    currentRootX += 280 + root.children.length * 60
  })

  const resultNodes: GraphNode[] = []
  treeNodes.forEach((tn) => {
    if (tn.nodes.length === 1) {
      const n = tn.nodes[0]
      resultNodes.push({ ...n, x: tn.x, y: tn.y })
    } else {
      const n1 = tn.nodes[0]
      const n2 = tn.nodes[1]
      const offset = (nodeWidth + spouseGap) / 2
      resultNodes.push({ ...n1, x: tn.x - offset, y: tn.y })
      resultNodes.push({ ...n2, x: tn.x + offset, y: tn.y })
    }
  })

  return resultNodes
}

interface RelationshipGraphCanvasProps {
  nodes: GraphNode[]
  links: GraphLink[]
  searchName: string
  selectedNodeId: string | null
  onSelectNode: (id: string | null) => void
}

function RelationshipGraphCanvas({
  nodes,
  links,
  searchName,
  selectedNodeId,
  onSelectNode,
}: RelationshipGraphCanvasProps) {
  const canvasRef = useRef<HTMLCanvasElement>(null)
  const canvasWidth = 1400
  const canvasHeight = 800

  const zoomRef = useRef(1)
  const panRef = useRef({ x: 0, y: 0 })
  const isPanningRef = useRef(false)
  const startPanRef = useRef({ x: 0, y: 0 })
  const prevNodeRef = useRef<HTMLCanvasElement | null>(null)
  const mouseDownPosRef = useRef<{ x: number; y: number } | null>(null)
  const hasDraggedRef = useRef(false)
  const hoveredNodeRef = useRef<GraphNode | null>(null)

  const simNodesRef = useRef<GraphNode[]>([])
  const simLinksRef = useRef<GraphLink[]>([])

  const layoutNodes = useMemo(() => {
    const disciplerLinks = links.filter((l) => l.type === "discipler")
    return computeStaticHierarchyLayout(nodes, disciplerLinks, canvasWidth, canvasHeight)
  }, [nodes, links])

  useEffect(() => {
    simNodesRef.current = layoutNodes
    simLinksRef.current = links
  }, [layoutNodes, links])

  const connectedNodeIds = useMemo(() => {
    if (!selectedNodeId) return null
    const set = new Set<string>()
    set.add(selectedNodeId)
    links.forEach((l) => {
      if (l.source === selectedNodeId) set.add(l.target)
      if (l.target === selectedNodeId) set.add(l.source)
    })
    return set
  }, [selectedNodeId, links])

  const drawCanvas = useCallback(() => {
    const canvas = canvasRef.current
    if (!canvas) return
    const ctx = canvas.getContext("2d")
    if (!ctx) return

    const dpr = window.devicePixelRatio || 1
    const rect = canvas.getBoundingClientRect()
    const displayW = Math.round(rect.width)
    const displayH = Math.round(rect.height)
    if (canvas.width !== displayW * dpr || canvas.height !== displayH * dpr) {
      canvas.width = displayW * dpr
      canvas.height = displayH * dpr
    }

    ctx.clearRect(0, 0, canvas.width, canvas.height)
    ctx.save()
    ctx.scale(dpr, dpr)
    ctx.translate(panRef.current.x, panRef.current.y)
    ctx.scale(zoomRef.current, zoomRef.current)

    const activeNodes = simNodesRef.current
    const activeNodesMap = new Map(activeNodes.map((n) => [n.id, n]))
    const isDark = document.documentElement.classList.contains("dark")

    // Draw Links
    simLinksRef.current.forEach((link) => {
      const s = activeNodesMap.get(link.source)
      const t = activeNodesMap.get(link.target)
      if (!s || !t) return

      const isHighlighted =
        connectedNodeIds && (connectedNodeIds.has(s.id) && connectedNodeIds.has(t.id))

      ctx.beginPath()
      ctx.moveTo(s.x, s.y)
      ctx.lineTo(t.x, t.y)

      if (link.type === "marriage") {
        ctx.strokeStyle = isHighlighted ? "#ec4899" : isDark ? "#831843" : "#fbcfe8"
        ctx.lineWidth = 2.5
        ctx.setLineDash([3, 3])
      } else if (link.type === "fellowship") {
        ctx.strokeStyle = isHighlighted ? "#a855f7" : isDark ? "#3b0764" : "#e9d5ff"
        ctx.lineWidth = 2
        ctx.setLineDash([4, 4])
      } else {
        ctx.strokeStyle = isHighlighted
          ? isDark ? STATUS_COLORS.success.dark : STATUS_COLORS.success.light
          : isDark ? GRAPH_LINK_COLORS.default.dark : GRAPH_LINK_COLORS.default.light
        ctx.lineWidth = isHighlighted ? 2.5 : 1.5
        ctx.setLineDash([])
      }

      ctx.stroke()
      ctx.setLineDash([])
    })

    // Draw Nodes
    activeNodes.forEach((node) => {
      const isSelected = selectedNodeId === node.id
      const isHovered = hoveredNodeRef.current?.id === node.id
      const isMatchSearch =
        searchName.trim().length > 0 &&
        node.name.toLowerCase().includes(searchName.toLowerCase())

      const radius = node.role === "presbyter" ? 20 : node.role === "deacon" ? 18 : 15

      ctx.beginPath()
      ctx.arc(node.x, node.y, radius, 0, Math.PI * 2)

      // Cor de preenchimento padronizada
      if (node.role === "presbyter") {
        ctx.fillStyle = isDark ? "#a78bfa" : "#7c3aed"
      } else if (node.role === "deacon") {
        ctx.fillStyle = isDark ? STATUS_COLORS.warning.dark : STATUS_COLORS.warning.light
      } else if (node.role === "leader") {
        ctx.fillStyle = isDark ? STATUS_COLORS.success.dark : STATUS_COLORS.success.light
      } else {
        ctx.fillStyle = isDark ? PALETTE.zinc[700] : PALETTE.zinc[200]
      }
      ctx.fill()

      // Borda
      ctx.lineWidth = isSelected ? 4 : isHovered || isMatchSearch ? 3 : 1.5
      ctx.strokeStyle = isSelected
        ? isDark ? "#60a5fa" : "#2563eb"
        : isMatchSearch
        ? isDark ? STATUS_COLORS.warning.dark : STATUS_COLORS.warning.light
        : isDark
        ? PALETTE.zinc[600]
        : PALETTE.zinc[400]
      ctx.stroke()

      // Nome do irmão abaixo do nó
      ctx.font = "11px Geist, sans-serif"
      ctx.fillStyle = isDark ? PALETTE.zinc[100] : PALETTE.zinc[900]
      ctx.textAlign = "center"
      const firstName = node.name.split(" ")[0]
      ctx.fillText(firstName, node.x, node.y + radius + 13)
    })

    ctx.restore()
  }, [connectedNodeIds, searchName, selectedNodeId])

  useEffect(() => {
    drawCanvas()
  }, [drawCanvas, layoutNodes])

  // Wheel zoom
  const handleWheel = useCallback(
    (e: WheelEvent) => {
      e.preventDefault()
      const factor = e.deltaY < 0 ? 1.05 : 0.95
      const canvas = canvasRef.current
      if (!canvas) return
      const rect = canvas.getBoundingClientRect()
      const mouseX = e.clientX - rect.left
      const mouseY = e.clientY - rect.top
      const currentZoom = zoomRef.current
      const newZoom = Math.max(0.1, Math.min(currentZoom * factor, 4))
      panRef.current = {
        x: mouseX - (mouseX - panRef.current.x) * (newZoom / currentZoom),
        y: mouseY - (mouseY - panRef.current.y) * (newZoom / currentZoom),
      }
      zoomRef.current = newZoom
      drawCanvas()
    },
    [drawCanvas]
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
      drawCanvas()
    },
    [handleWheel, drawCanvas]
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
      drawCanvas()
    }
  }

  const handleMouseUp = (e: React.MouseEvent<HTMLCanvasElement>) => {
    isPanningRef.current = false
    if (!hasDraggedRef.current && canvasRef.current) {
      const rect = canvasRef.current.getBoundingClientRect()
      const clickX = (e.clientX - rect.left - panRef.current.x) / zoomRef.current
      const clickY = (e.clientY - rect.top - panRef.current.y) / zoomRef.current

      const clicked = simNodesRef.current.find((n) => {
        const dist = Math.hypot(n.x - clickX, n.y - clickY)
        return dist <= 22
      })

      onSelectNode(clicked ? clicked.id : null)
    }
  }

  return (
    <div className="relative h-[650px] w-full overflow-hidden rounded-2xl border border-border bg-card">
      <canvas
        ref={canvasCallback}
        onMouseDown={handleMouseDown}
        onMouseMove={handleMouseMove}
        onMouseUp={handleMouseUp}
        className="h-full w-full cursor-grab active:cursor-grabbing"
      />
      <div className="absolute bottom-4 right-4 flex items-center gap-1.5 rounded-xl border border-border/80 bg-background/90 p-1.5 shadow-md backdrop-blur-sm">
        <Button
          size="icon"
          variant="ghost"
          onClick={() => {
            zoomRef.current = Math.min(zoomRef.current * 1.2, 4)
            drawCanvas()
          }}
          className="h-11 w-11 min-h-[44px] min-w-[44px] rounded-xl"
        >
          <ZoomIn className="h-5 w-5" />
        </Button>
        <Button
          size="icon"
          variant="ghost"
          onClick={() => {
            zoomRef.current = Math.max(zoomRef.current * 0.8, 0.2)
            drawCanvas()
          }}
          className="h-11 w-11 min-h-[44px] min-w-[44px] rounded-xl"
        >
          <ZoomOut className="h-5 w-5" />
        </Button>
        <Button
          size="icon"
          variant="ghost"
          onClick={() => {
            zoomRef.current = 1
            panRef.current = { x: 0, y: 0 }
            drawCanvas()
          }}
          className="h-11 w-11 min-h-[44px] min-w-[44px] rounded-xl"
        >
          <Maximize2 className="h-5 w-5" />
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
  onSelectDisciple?: (profile: Profile) => void
  onClose?: () => void
}

export function RelationshipGraphView({
  profiles,
  homeGroups,
  fellowships,
  sectors,
  leaderIds,
  onSelectDisciple,
  onClose,
}: RelationshipGraphViewProps) {
  const [searchName, setSearchName] = useState<string>("")
  const [selectedNodeId, setSelectedNodeId] = useState<string | null>(null)

  // Montar nós e links
  const { nodes, links } = useMemo(() => {
    const groupMap = new Map(homeGroups.map((g) => [g.id, g]))
    const sectorMap = new Map(sectors.map((s) => [s.id, s]))

    const gNodes: GraphNode[] = profiles.map((p) => {
      const hg = p.home_group_id ? groupMap.get(p.home_group_id) : null
      const sector = hg?.sector_id ? sectorMap.get(hg.sector_id)?.name : "Geral"

      let role: GraphNode["role"] = "disciple"
      if (p.is_presbyter) role = "presbyter"
      else if (p.is_deacon) role = "deacon"
      else if (leaderIds.has(p.id)) role = "leader"
      else if (!p.baptism_date && (p.father_id || p.mother_id)) role = "child"

      return {
        id: p.id,
        name: p.full_name,
        avatarUrl: p.avatar_url,
        role,
        gender: p.gender,
        homeGroupId: p.home_group_id,
        homeGroupName: hg?.location_text || null,
        sector: sector || "Geral",
        neighborhood: p.address_neighborhood,
        phone: p.phone,
        email: p.email,
        disciplerId: p.discipler_id,
        spouseId: p.spouse_id,
        x: 0,
        y: 0,
      }
    })

    const gLinks: GraphLink[] = []

    // Discipulado
    profiles.forEach((p) => {
      if (p.discipler_id) {
        gLinks.push({
          source: p.discipler_id,
          target: p.id,
          type: "discipler",
        })
      }
      if (p.spouse_id && p.id < p.spouse_id) {
        gLinks.push({
          source: p.id,
          target: p.spouse_id,
          type: "marriage",
        })
      }
    })

    // Comunhões
    fellowships.forEach((f) => {
      gLinks.push({
        source: f.member_a_id,
        target: f.member_b_id,
        type: "fellowship",
      })
    })

    return { nodes: gNodes, links: gLinks }
  }, [profiles, homeGroups, fellowships, sectors, leaderIds])

  const selectedProfile = useMemo(() => {
    if (!selectedNodeId) return null
    return profiles.find((p) => p.id === selectedNodeId) || null
  }, [selectedNodeId, profiles])

  return (
    <div className="space-y-4">
      {/* Barra Superior do Grafo */}
      <div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
        <div className="flex items-center gap-2 w-full sm:w-auto">
          <Input
            value={searchName}
            onChange={(e) => setSearchName(e.target.value)}
            placeholder="Destacar irmão no grafo..."
            className="h-11 min-h-[44px] w-full sm:w-64 rounded-xl text-xs"
          />
        </div>

        {onClose && (
          <Button
            variant="outline"
            size="sm"
            onClick={onClose}
            className="h-11 min-h-[44px] gap-1.5 rounded-xl text-xs"
          >
            <X className="h-4 w-4" />
            <span>Fechar Visualização em Grafo</span>
          </Button>
        )}
      </div>

      {/* Canvas */}
      <RelationshipGraphCanvas
        nodes={nodes}
        links={links}
        searchName={searchName}
        selectedNodeId={selectedNodeId}
        onSelectNode={setSelectedNodeId}
      />

      {/* Painel do Irmão Selecionado */}
      {selectedProfile && (
        <div className="flex items-center justify-between rounded-xl border border-border bg-card p-4 shadow-sm">
          <div>
            <h4 className="font-semibold text-foreground text-sm">
              {selectedProfile.full_name}
            </h4>
            <p className="text-xs text-muted-foreground">
              {selectedProfile.phone || "Sem telefone cadastrado"}
            </p>
          </div>
          {onSelectDisciple && (
            <Button
              size="sm"
              onClick={() => onSelectDisciple(selectedProfile)}
              className="h-11 min-h-[44px] text-xs font-medium rounded-xl px-4"
            >
              Ver e Editar Dados
            </Button>
          )}
        </div>
      )}
    </div>
  )
}
