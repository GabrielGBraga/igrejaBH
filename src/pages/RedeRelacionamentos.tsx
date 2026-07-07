import { useEffect, useState, useRef, useMemo, useCallback } from "react";
import supabase from "@/lib/supabase";
import type { Database } from "@/lib/database.types";
import { toast } from "sonner";
import { ChurchMap } from "@/components/home/ChurchMap";
import { 
  Network, 
  Search, 
  ZoomIn, 
  ZoomOut, 
  Maximize2, 
  User, 
  Users, 
  Phone, 
  Mail, 
  Heart, 
  MapPin, 
  Info,
  SlidersHorizontal,
  Shield,
  Plus,
  Trash2,
  Edit
} from "lucide-react";
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { Separator } from "@/components/ui/separator";
import { Skeleton } from "@/components/ui/skeleton";
import { Checkbox } from "@/components/ui/checkbox";
import { Label } from "@/components/ui/label";
import MemberManagement from "./MemberManagement";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";

type Profile = Database["public"]["Tables"]["profiles"]["Row"];
type HomeGroup = Database["public"]["Tables"]["home_groups"]["Row"];
type Fellowship = Database["public"]["Tables"]["fellowships"]["Row"];
type Sector = Database["public"]["Tables"]["sectors"]["Row"];

interface GraphNode {
  id: string;
  name: string;
  avatarUrl: string | null;
  role: "presbyter" | "deacon" | "leader" | "discipler" | "disciple" | "child";
  gender: string | null;
  homeGroupId: string | null;
  homeGroupName: string | null;
  sector: string;
  neighborhood: string | null;
  phone: string | null;
  email: string | null;
  disciplerId: string | null;
  
  // Physics properties
  x: number;
  y: number;
  vx: number;
  vy: number;
  fx?: number;
  fy?: number;
}

interface GraphLink {
  source: string;
  target: string;
  type: "discipler" | "fellowship" | "group_leader";
}

export default function RedeRelacionamentos() {
  const [loading, setLoading] = useState(true);
  const [profiles, setProfiles] = useState<Profile[]>([]);
  const [homeGroups, setHomeGroups] = useState<HomeGroup[]>([]);
  const [fellowships, setFellowships] = useState<Fellowship[]>([]);
  const [sectors, setSectors] = useState<Sector[]>([]);
  const [leaderIds, setLeaderIds] = useState<Set<string>>(new Set());
  const [activeTab, setActiveTab] = useState<"grafo" | "membros">("grafo");

  // Filters State
  const [selectedSector, setSelectedSector] = useState<string>("all");
  const [selectedGroup, setSelectedGroup] = useState<string>("all");
  const [selectedRole, setSelectedRole] = useState<string>("all");
  const [selectedGender, setSelectedGender] = useState<string>("all");
  const [searchName, setSearchName] = useState<string>("");
  
  // Connection types to show
  const [showDiscipler, setShowDiscipler] = useState(true);
  const [showFellowship, setShowFellowship] = useState(true);
  const [showGroupLeader, setShowGroupLeader] = useState(true);

  // Zoom & Pan
  const [pan, setPan] = useState({ x: 0, y: 0 });
  const [zoom, setZoom] = useState(1);
  const [isPanning, setIsPanning] = useState(false);

  // Selected disciple details
  const [selectedNodeId, setSelectedNodeId] = useState<string | null>(null);

  // Refs
  const svgRef = useRef<SVGSVGElement>(null);
  const draggedNodeRef = useRef<string | null>(null);
  const startPanRef = useRef({ x: 0, y: 0 });
  const alphaRef = useRef(1.0);
  const [isAnimating, setIsAnimating] = useState(false);

  const canvasWidth = 800;
  const canvasHeight = 600;

  // Sectors States
  const [isSectorDialogOpen, setIsSectorDialogOpen] = useState(false);
  const [newSectorName, setNewSectorName] = useState("");
  const [savingSector, setSavingSector] = useState(false);

  // Connection Manager States
  const [newConnectionType, setNewConnectionType] = useState<"is_discipler" | "is_disciple" | "fellowship" | "">("");
  const [newConnectionTargetId, setNewConnectionTargetId] = useState<string>("");
  const [connecting, setConnecting] = useState(false);

  // Sectors Tab States
  const [newSectorTabName, setNewSectorTabName] = useState("");
  const [savingSectorTab, setSavingSectorTab] = useState(false);
  const [selectedGroupToAdd, setSelectedGroupToAdd] = useState<Record<string, string>>({});

  // View/Edit Home Group Modal States
  const [selectedHomeGroupToEdit, setSelectedHomeGroupToEdit] = useState<HomeGroup | null>(null);
  const [editHomeGroupMeetingDay, setEditHomeGroupMeetingDay] = useState<number>(1);
  const [editHomeGroupStartTime, setEditHomeGroupStartTime] = useState<string>("20:00");
  const [editHomeGroupLocationText, setEditHomeGroupLocationText] = useState<string>("");
  const [editHomeGroupLeader1Id, setEditHomeGroupLeader1Id] = useState<string>("");
  const [editHomeGroupLeader2Id, setEditHomeGroupLeader2Id] = useState<string | null>(null);
  const [editHomeGroupLat, setEditHomeGroupLat] = useState<number | null>(null);
  const [editHomeGroupLng, setEditHomeGroupLng] = useState<number | null>(null);
  const [editHomeGroupSectorId, setEditHomeGroupSectorId] = useState<string | null>(null);
  const [savingHomeGroup, setSavingHomeGroup] = useState<boolean>(false);
  const [geocodingEdit, setGeocodingEdit] = useState<boolean>(false);

  const loadData = useCallback(async () => {
    try {
      setLoading(true);
      
      // Fetch profiles
      const { data: profilesData, error: profilesError } = await supabase
        .from("profiles")
        .select("*")
        .order("full_name");
      if (profilesError) throw profilesError;

      // Fetch home groups
      const { data: groupsData, error: groupsError } = await supabase
        .from("home_groups")
        .select("*");
      if (groupsError) throw groupsError;

      // Fetch fellowships
      const { data: fellowshipsData, error: fellowshipsError } = await supabase
        .from("fellowships")
        .select("*");
      if (fellowshipsError) {
        console.warn("Could not fetch fellowships (check RLS):", fellowshipsError);
      }

      // Fetch sectors
      const { data: sectorsData, error: sectorsError } = await supabase
        .from("sectors")
        .select("*");
      if (sectorsError) throw sectorsError;

      setProfiles(profilesData || []);
      setHomeGroups(groupsData || []);
      setFellowships(fellowshipsData || []);
      setSectors(sectorsData || []);

      // Compute leaders set
      const leaders = new Set<string>();
      groupsData?.forEach(g => {
        if (g.leader_1_id) leaders.add(g.leader_1_id);
        if (g.leader_2_id) leaders.add(g.leader_2_id);
      });
      setLeaderIds(leaders);

    } catch (err) {
      console.error("Erro ao carregar dados do grafo:", err);
      toast.error("Erro ao carregar os dados de relacionamentos.");
    } finally {
      setLoading(false);
    }
  }, []);

  const fetchSectors = useCallback(async () => {
    try {
      const { data, error } = await supabase
        .from("sectors")
        .select("*")
        .order("name");
      if (error) throw error;
      setSectors(data || []);
    } catch (err) {
      console.error("Error fetching sectors:", err);
    }
  }, []);

  useEffect(() => {
    loadData();
  }, [loadData]);

  // Keep refs of zoom and pan so handleWheelEvent never becomes stale
  const zoomRef = useRef(zoom);
  const panRef = useRef(pan);
  const prevNodeRef = useRef<SVGSVGElement | null>(null);

  useEffect(() => {
    zoomRef.current = zoom;
  }, [zoom]);

  useEffect(() => {
    panRef.current = pan;
  }, [pan]);

  const handleWheelEvent = useCallback((e: WheelEvent) => {
    e.preventDefault();
    
    const zoomFactor = e.deltaY < 0 ? 1.08 : 0.92;
    const currentZoom = zoomRef.current;
    const newZoom = Math.max(0.1, Math.min(currentZoom * zoomFactor, 5));
    
    const svgEl = e.currentTarget as SVGSVGElement;
    if (!svgEl) return;
    
    const rect = svgEl.getBoundingClientRect();
    const mouseX = e.clientX - rect.left;
    const mouseY = e.clientY - rect.top;
    
    setPan(prev => ({
      x: mouseX - (mouseX - prev.x) * (newZoom / currentZoom),
      y: mouseY - (mouseY - prev.y) * (newZoom / currentZoom),
    }));
    setZoom(newZoom);
  }, []);

  const svgRefCallback = useCallback((node: SVGSVGElement | null) => {
    const ref = svgRef as React.MutableRefObject<SVGSVGElement | null>;
    ref.current = node;

    if (prevNodeRef.current) {
      prevNodeRef.current.removeEventListener("wheel", handleWheelEvent);
    }
    if (node) {
      node.addEventListener("wheel", handleWheelEvent, { passive: false });
    }
    prevNodeRef.current = node;
  }, [handleWheelEvent]);

  const handleOpenEditHomeGroup = (hg: HomeGroup) => {
    setSelectedHomeGroupToEdit(hg);
    setEditHomeGroupMeetingDay(hg.meeting_day);
    setEditHomeGroupStartTime(hg.start_time || "20:00");
    setEditHomeGroupLocationText(hg.location_text || "");
    setEditHomeGroupLeader1Id(hg.leader_1_id || "");
    setEditHomeGroupLeader2Id(hg.leader_2_id || null);
    setEditHomeGroupLat(hg.lat);
    setEditHomeGroupLng(hg.lng);
    setEditHomeGroupSectorId(hg.sector_id || null);
  };

  const handleGeocodeEditAddress = async () => {
    if (!editHomeGroupLocationText.trim()) return;
    setGeocodingEdit(true);
    try {
      const baseAddress = editHomeGroupLocationText.trim();
      const queries = [
        baseAddress.toLowerCase().includes("belo horizonte") ? baseAddress : `${baseAddress}, Belo Horizonte, MG`,
        baseAddress.replace(/\s+(de|da|do|das|dos)\s+/gi, " ") + ", Belo Horizonte, MG",
        baseAddress.replace(/\d+/, "").trim() + ", Belo Horizonte, MG",
      ];

      let found = false;
      for (const query of queries) {
        if (found) break;

        const response = await fetch(
          `https://nominatim.openstreetmap.org/search?format=json&q=${encodeURIComponent(query)}&limit=1`,
          { headers: { "User-Agent": "igrejaBH-app" } }
        );
        const data = await response.json();

        if (data && data.length > 0) {
          setEditHomeGroupLat(parseFloat(data[0].lat));
          setEditHomeGroupLng(parseFloat(data[0].lon));
          toast.success("Coordenadas encontradas com sucesso!");
          found = true;
        }
      }
      if (!found) {
        toast.error("Não foi possível encontrar a localização. Por favor, ajuste o endereço.");
      }
    } catch (error) {
      console.error("Geocoding error:", error);
      toast.error("Erro ao buscar coordenadas.");
    } finally {
      setGeocodingEdit(false);
    }
  };

  const handleSaveHomeGroup = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!selectedHomeGroupToEdit) return;
    if (!editHomeGroupLeader1Id) {
      toast.error("Por favor, selecione pelo menos o Líder 1.");
      return;
    }
    setSavingHomeGroup(true);
    try {
      const { error } = await supabase
        .from("home_groups")
        .update({
          meeting_day: editHomeGroupMeetingDay,
          start_time: editHomeGroupStartTime,
          location_text: editHomeGroupLocationText,
          leader_1_id: editHomeGroupLeader1Id,
          leader_2_id: editHomeGroupLeader2Id || null,
          lat: editHomeGroupLat,
          lng: editHomeGroupLng,
          sector_id: editHomeGroupSectorId || null,
        })
        .eq("id", selectedHomeGroupToEdit.id);

      if (error) throw error;
      
      toast.success("Grupo caseiro atualizado com sucesso!");
      setSelectedHomeGroupToEdit(null);
      loadData();
    } catch (err) {
      console.error("Error saving home group:", err);
      toast.error("Erro ao atualizar grupo caseiro.");
    } finally {
      setSavingHomeGroup(false);
    }
  };

  const handleCreateSector = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!newSectorName.trim()) return;
    setSavingSector(true);
    try {
      const { error } = await supabase
        .from("sectors")
        .insert({ name: newSectorName.trim() });
      if (error) throw error;
      toast.success("Setor criado com sucesso!");
      setNewSectorName("");
      fetchSectors();
    } catch (error) {
      console.error("Error creating sector:", error);
      if (error && typeof error === "object" && "code" in error && error.code === "23505") {
        toast.error("Este setor já existe.");
      } else {
        toast.error("Erro ao criar setor.");
      }
    } finally {
      setSavingSector(false);
    }
  };

  const handleDeleteSector = async (sectorId: string) => {
    try {
      const { error } = await supabase
        .from("sectors")
        .delete()
        .eq("id", sectorId);
      if (error) throw error;
      toast.success("Setor removido com sucesso!");
      fetchSectors();
    } catch (error) {
      console.error("Error deleting sector:", error);
      toast.error("Erro ao remover setor. Verifique se ele está em uso.");
    }
  };

  const handleCreateSectorTab = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!newSectorTabName.trim()) return;
    setSavingSectorTab(true);
    try {
      const { error } = await supabase
        .from("sectors")
        .insert({ name: newSectorTabName.trim() });
      if (error) throw error;
      toast.success("Setor criado com sucesso!");
      setNewSectorTabName("");
      loadData();
    } catch (error) {
      console.error("Error creating sector:", error);
      if (error && typeof error === "object" && "code" in error && error.code === "23505") {
        toast.error("Este setor já existe.");
      } else {
        toast.error("Erro ao criar setor.");
      }
    } finally {
      setSavingSectorTab(false);
    }
  };

  const handleRemoveGroupFromSector = async (groupId: string) => {
    try {
      const { error } = await supabase
        .from("home_groups")
        .update({ sector_id: null })
        .eq("id", groupId);
      if (error) throw error;
      toast.success("Grupo removido do setor!");
      loadData();
    } catch (err) {
      console.error("Error removing group from sector:", err);
      toast.error("Erro ao remover grupo do setor.");
    }
  };

  const handleAddGroupToSector = async (sectorId: string) => {
    const groupId = selectedGroupToAdd[sectorId];
    if (!groupId) return;
    try {
      const { error } = await supabase
        .from("home_groups")
        .update({ sector_id: sectorId })
        .eq("id", groupId);
      if (error) throw error;
      toast.success("Grupo adicionado ao setor!");
      setSelectedGroupToAdd(prev => ({ ...prev, [sectorId]: "" }));
      loadData();
    } catch (err) {
      console.error("Error adding group to sector:", err);
      toast.error("Erro ao adicionar grupo ao setor.");
    }
  };

  const wouldCreateCycle = (discipleId: string, disciplerId: string): boolean => {
    let current = disciplerId;
    const visited = new Set<string>();
    
    while (current) {
      if (current === discipleId) {
        return true;
      }
      if (visited.has(current)) {
        break;
      }
      visited.add(current);
      
      const currentProfile = profiles.find(p => p.id === current);
      current = currentProfile?.discipler_id || "";
    }
    return false;
  };

  const handleConnect = async () => {
    if (!selectedNodeId || !newConnectionType || !newConnectionTargetId) return;
    setConnecting(true);
    try {
      if (newConnectionType === "is_disciple") {
        if (wouldCreateCycle(selectedNodeId, newConnectionTargetId)) {
          toast.error("Erro: Esta conexão criaria um ciclo de discipulado!");
          setConnecting(false);
          return;
        }

        // SelectedNode (A) is discipled by Target (B) => set A's discipler_id to B
        const { error } = await supabase
          .from("profiles")
          .update({ discipler_id: newConnectionTargetId })
          .eq("id", selectedNodeId);
        if (error) throw error;
        toast.success("Conexão de discipulado criada!");
      } else if (newConnectionType === "is_discipler") {
        if (wouldCreateCycle(newConnectionTargetId, selectedNodeId)) {
          toast.error("Erro: Esta conexão criaria um ciclo de discipulado!");
          setConnecting(false);
          return;
        }

        // SelectedNode (A) is the discipler of Target (B) => set B's discipler_id to A
        const { error } = await supabase
          .from("profiles")
          .update({ discipler_id: selectedNodeId })
          .eq("id", newConnectionTargetId);
        if (error) throw error;
        toast.success("Conexão de discipulado criada!");
      } else if (newConnectionType === "fellowship") {
        const alreadyExists = fellowships.some(f => 
          (f.member_a_id === selectedNodeId && f.member_b_id === newConnectionTargetId) ||
          (f.member_a_id === newConnectionTargetId && f.member_b_id === selectedNodeId)
        );

        if (alreadyExists) {
          toast.error("Erro: Esta comunhão já existe!");
          setConnecting(false);
          return;
        }

        // Fellowship between A and B
        const { error } = await supabase
          .from("fellowships")
          .insert({
            member_a_id: selectedNodeId,
            member_b_id: newConnectionTargetId
          });
        if (error) throw error;
        toast.success("Conexão de comunhão criada!");
      }
      
      setNewConnectionType("");
      setNewConnectionTargetId("");
      loadData();
    } catch (err) {
      console.error("Error creating connection:", err);
      toast.error("Erro ao criar conexão.");
    } finally {
      setConnecting(false);
    }
  };

  const handleDisconnect = async (targetId: string, typeName: string) => {
    if (!selectedNodeId) return;
    const confirm = window.confirm("Deseja realmente remover esta conexão?");
    if (!confirm) return;
    
    try {
      if (typeName === "Discipulador") {
        // targetId is the discipler of selectedNodeId. Set selectedNodeId's discipler_id to null
        const { error } = await supabase
          .from("profiles")
          .update({ discipler_id: null })
          .eq("id", selectedNodeId);
        if (error) throw error;
        toast.success("Conexão de discipulado removida.");
      } else if (typeName === "Discípulo") {
        // targetId is the disciple of selectedNodeId. Set targetId's discipler_id to null
        const { error } = await supabase
          .from("profiles")
          .update({ discipler_id: null })
          .eq("id", targetId);
        if (error) throw error;
        toast.success("Conexão de discipulado removida.");
      } else if (typeName === "Companheiro") {
        // Fellowship
        const { error } = await supabase
          .from("fellowships")
          .delete()
          .or(`and(member_a_id.eq.${selectedNodeId},member_b_id.eq.${targetId}),and(member_a_id.eq.${targetId},member_b_id.eq.${selectedNodeId})`);
        if (error) throw error;
        toast.success("Conexão de comunhão removida.");
      }
      
      loadData();
    } catch (err) {
      console.error("Error removing connection:", err);
      toast.error("Erro ao remover conexão.");
    }
  };

  // Helper: Extract Sector from Home Group location
  const getSectorFromLocation = (location: string | null): string => {
    if (!location) return "Sem Setor";
    const neighborhoodMatch = location.match(/bairro:\s*([^,;]+)/i);
    if (neighborhoodMatch) return neighborhoodMatch[1].trim();
    
    const parts = location.split(",");
    if (parts.length > 1) {
      return parts[1].trim();
    }
    return location.trim();
  };

  // Profile Map for quick lookup
  const profileMap = useMemo(() => {
    return new Map(profiles.map(p => [p.id, p]));
  }, [profiles]);

  // Helper: Get Group Leaders name
  const getGroupLeadersName = useCallback((hg: HomeGroup) => {
    const leader1 = hg.leader_1_id ? profileMap.get(hg.leader_1_id)?.full_name : null;
    const leader2 = hg.leader_2_id ? profileMap.get(hg.leader_2_id)?.full_name : null;
    
    if (leader1 && leader2) {
      const name1 = leader1.split(" ")[0];
      const name2 = leader2.split(" ")[0];
      return `${name1} & ${name2}`;
    }
    if (leader1) return leader1.split(" ")[0];
    if (leader2) return leader2.split(" ")[0];
    return "Sem Líder";
  }, [profileMap]);

  // Group Map for quick lookup
  const groupMap = useMemo(() => {
    return new Map(homeGroups.map(g => [g.id, g]));
  }, [homeGroups]);

  // Sector Map for quick lookup
  const sectorMap = useMemo(() => {
    return new Map(sectors.map(s => [s.id, s]));
  }, [sectors]);

  // Unique list of sectors for filtering (merging DB sectors + legacy parsed sectors)
  const sectorsList = useMemo(() => {
    const dbSectors = sectors.map(s => s.name);
    const parsedSectors = homeGroups
      .filter(g => !g.sector_id)
      .map(g => getSectorFromLocation(g.location_text));
    return Array.from(new Set([...dbSectors, ...parsedSectors])).filter(Boolean).sort();
  }, [sectors, homeGroups]);

  // Build the complete graph (nodes & links) from raw data
  const rawGraph = useMemo(() => {
    if (profiles.length === 0) return { nodes: [], links: [] };

    const uniqueDisciplers = new Set(profiles.map(p => p.discipler_id).filter((id): id is string => !!id));

    // Create Nodes
    const nodes: GraphNode[] = profiles.map((p, idx) => {
      const hg = p.home_group_id ? groupMap.get(p.home_group_id) : null;
      const hgName = hg ? `GC - ${getGroupLeadersName(hg)}` : null;
      
      const hgSector = hg && hg.sector_id && sectorMap.has(hg.sector_id)
        ? sectorMap.get(hg.sector_id)!.name
        : hg ? getSectorFromLocation(hg.location_text) : "Sem Setor";

      let role: GraphNode["role"] = "disciple";
      if (p.is_presbyter) role = "presbyter";
      else if (p.is_deacon) role = "deacon";
      else if (leaderIds.has(p.id)) role = "leader";
      else if (uniqueDisciplers.has(p.id)) role = "discipler";
      else if (!!(p.father_id || p.mother_id) && !p.baptism_date) role = "child";

      // Circular initial layout to distribute clusters nicely
      const angle = (idx / profiles.length) * 2 * Math.PI;
      const radius = role === "presbyter" ? 80 
        : role === "deacon" ? 120 
        : role === "leader" ? 170 
        : role === "discipler" ? 210 
        : role === "child" ? 300 
        : 260;
      
      return {
        id: p.id,
        name: p.full_name,
        avatarUrl: p.avatar_url,
        role,
        gender: p.gender,
        homeGroupId: p.home_group_id,
        homeGroupName: hgName,
        sector: hgSector,
        neighborhood: p.address_neighborhood,
        phone: p.phone,
        email: p.email,
        disciplerId: p.discipler_id,
        x: canvasWidth / 2 + Math.cos(angle) * radius + (Math.random() - 0.5) * 40,
        y: canvasHeight / 2 + Math.sin(angle) * radius + (Math.random() - 0.5) * 40,
        vx: 0,
        vy: 0
      };
    });

    const nodeMap = new Map(nodes.map(n => [n.id, n]));

    // Adjust child nodes close to their disciplers or home group leaders for better visual clustering
    nodes.forEach(n => {
      if (n.role === "disciple") {
        let parent: GraphNode | undefined;
        if (n.disciplerId) {
          parent = nodeMap.get(n.disciplerId);
        } else if (n.homeGroupId) {
          const hg = groupMap.get(n.homeGroupId);
          if (hg?.leader_1_id) {
            parent = nodeMap.get(hg.leader_1_id);
          }
        }
        if (parent) {
          n.x = parent.x + (Math.random() - 0.5) * 60;
          n.y = parent.y + (Math.random() - 0.5) * 60;
        }
      }
    });

    // Create Links
    const links: GraphLink[] = [];

    // 1. Discipler links (directed)
    profiles.forEach(p => {
      if (p.discipler_id && nodeMap.has(p.discipler_id)) {
        links.push({
          source: p.discipler_id, // Discipler is the source
          target: p.id,           // Disciple is the target
          type: "discipler"
        });
      }
    });

    // 2. Fellowship links (undirected, draw as dashed lines)
    fellowships.forEach(f => {
      if (nodeMap.has(f.member_a_id) && nodeMap.has(f.member_b_id)) {
        links.push({
          source: f.member_a_id,
          target: f.member_b_id,
          type: "fellowship"
        });
      }
    });

    // 3. Home Group leader links (dotted lines connecting members to leaders)
    profiles.forEach(p => {
      if (p.home_group_id) {
        const hg = groupMap.get(p.home_group_id);
        if (hg) {
          const leaders = [hg.leader_1_id, hg.leader_2_id].filter((id): id is string => !!id && id !== p.id);
          leaders.forEach(leaderId => {
            if (nodeMap.has(leaderId)) {
              links.push({
                source: leaderId,
                target: p.id,
                type: "group_leader"
              });
            }
          });
        }
      }
    });

    return { nodes, links };
  }, [profiles, fellowships, leaderIds, groupMap, getGroupLeadersName, sectorMap]);

  // 2. Filter Graph based on filter values
  const filteredData = useMemo(() => {
    const { nodes, links } = rawGraph;
    if (nodes.length === 0) return { nodes: [], links: [] };

    // Clone nodes so simulation does not affect rawGraph
    const nodesCloned: GraphNode[] = nodes.map(n => ({ ...n }));

    // Determine which nodes match the filters
    const matchingNodeIds = new Set<string>();

    nodesCloned.forEach(n => {
      // Filter by Sector
      if (selectedSector !== "all" && n.sector !== selectedSector) return;

      // Filter by GC
      if (selectedGroup !== "all" && n.homeGroupId !== selectedGroup) return;

      // Filter by Role
      if (selectedRole !== "all" && n.role !== selectedRole) return;

      // Filter by Gender
      if (selectedGender !== "all" && n.gender !== selectedGender) return;

      matchingNodeIds.add(n.id);
    });

    // Handle connection filters (which link types are we showing)
    const activeLinkTypes = new Set<string>();
    if (showDiscipler) activeLinkTypes.add("discipler");
    if (showFellowship) activeLinkTypes.add("fellowship");
    if (showGroupLeader) activeLinkTypes.add("group_leader");

    // Filter links
    const filteredLinks = links.filter(link => {
      // Link type must be checked
      if (!activeLinkTypes.has(link.type)) return false;
      
      // Both ends must be currently matching/visible nodes
      return matchingNodeIds.has(link.source) && matchingNodeIds.has(link.target);
    });

    // Nodes that are visible: matching nodes
    const filteredNodes = nodesCloned.filter(n => matchingNodeIds.has(n.id));

    return { nodes: filteredNodes, links: filteredLinks };
  }, [rawGraph, selectedSector, selectedGroup, selectedRole, selectedGender, showDiscipler, showFellowship, showGroupLeader]);

  // Nodes & Links currently active in the physics simulation
  const [graphNodes, setGraphNodes] = useState<GraphNode[]>([]);
  const [graphLinks, setGraphLinks] = useState<GraphLink[]>([]);

  // Sync state and run layout simulation on filter changes
  useEffect(() => {
    setGraphNodes(filteredData.nodes);
    setGraphLinks(filteredData.links);
    
    // Wake up the simulation
    alphaRef.current = 1.0;
    setIsAnimating(true);
  }, [filteredData]);

  // Single step of the physics simulation (Verlet integration)
  const runSimulationStep = (
    nodes: GraphNode[],
    links: GraphLink[],
    width: number,
    height: number,
    alpha: number
  ) => {
    const kRepulsion = 1500;
    const kAttraction = 0.06;
    const kGravity = 0.02;
    const linkRestLength = 65;
    const damping = 0.75;

    const nodeMap = new Map<string, GraphNode>();
    nodes.forEach(n => nodeMap.set(n.id, n));

    const centerX = width / 2;
    const centerY = height / 2;

    // 1. Repulsion force between all nodes (prevent overlap)
    for (let i = 0; i < nodes.length; i++) {
      const nodeA = nodes[i];
      for (let j = i + 1; j < nodes.length; j++) {
        const nodeB = nodes[j];
        const dx = nodeB.x - nodeA.x;
        const dy = nodeB.y - nodeA.y;
        const distSq = dx * dx + dy * dy + 1;
        const dist = Math.sqrt(distSq);
        
        if (dist < 250) {
          const force = (kRepulsion / distSq) * (1 - dist / 250) * alpha;
          const fx = dx * force;
          const fy = dy * force;
          
          if (nodeA.fx === undefined) {
            nodeA.vx -= fx;
            nodeA.vy -= fy;
          }
          if (nodeB.fx === undefined) {
            nodeB.vx += fx;
            nodeB.vy += fy;
          }
        }
      }
    }

    // 2. Attraction force along links (pull connected nodes closer)
    links.forEach(link => {
      const sourceNode = nodeMap.get(link.source);
      const targetNode = nodeMap.get(link.target);
      
      if (sourceNode && targetNode) {
        const dx = targetNode.x - sourceNode.x;
        const dy = targetNode.y - sourceNode.y;
        const dist = Math.sqrt(dx * dx + dy * dy) || 1;
        const force = (dist - linkRestLength) * kAttraction * alpha;
        
        const fx = (dx / dist) * force;
        const fy = (dy / dist) * force;
        
        if (sourceNode.fx === undefined) {
          sourceNode.vx += fx;
          sourceNode.vy += fy;
        }
        if (targetNode.fx === undefined) {
          targetNode.vx -= fx;
          targetNode.vy -= fy;
        }
      }
    });

    // 3. Gravity pulling nodes toward the center and apply velocities
    nodes.forEach(node => {
      if (node.fx !== undefined) {
        node.x = node.fx;
        node.y = node.fy;
        node.vx = 0;
        node.vy = 0;
        return;
      }
      
      node.vx += (centerX - node.x) * kGravity * alpha;
      node.vy += (centerY - node.y) * kGravity * alpha;

      // Update positions
      node.x += node.vx;
      node.y += node.vy;
      
      // Apply damping friction
      node.vx *= damping;
      node.vy *= damping;

      // Boundary check to keep nodes inside canvas bounds
      const padding = 20;
      node.x = Math.max(padding, Math.min(width - padding, node.x));
      node.y = Math.max(padding, Math.min(height - padding, node.y));
    });
  };

  // Live simulation tick animation loop
  useEffect(() => {
    if (!isAnimating || graphNodes.length === 0) return;

    let frameId: number;
    const tick = () => {
      // Run 3 steps per frame for faster stabilization
      for (let i = 0; i < 3; i++) {
        runSimulationStep(graphNodes, graphLinks, canvasWidth, canvasHeight, alphaRef.current);
      }
      
      // Force React state update
      setGraphNodes([...graphNodes]);
      
      // Cooling factor
      alphaRef.current *= 0.985;
      
      // Stop loop when cooled down and not dragging
      if (alphaRef.current < 0.005 && !draggedNodeRef.current) {
        setIsAnimating(false);
      } else {
        frameId = requestAnimationFrame(tick);
      }
    };

    frameId = requestAnimationFrame(tick);
    return () => cancelAnimationFrame(frameId);
  }, [isAnimating, graphNodes, graphLinks]);

  // Reset Zoom & Pan
  const handleResetZoom = () => {
    setPan({ x: 0, y: 0 });
    setZoom(1);
  };

  // Pan controls
  const handleZoom = (factor: number) => {
    setZoom(prev => Math.max(0.1, Math.min(prev * factor, 5)));
  };

  // Mouse pan handlers
  const handleMouseDown = (e: React.MouseEvent<SVGSVGElement>) => {
    if (e.target !== svgRef.current && (e.target as SVGElement).tagName !== "svg") {
      return;
    }
    setIsPanning(true);
    startPanRef.current = { x: e.clientX, y: e.clientY };
  };

  const handleMouseMove = (e: React.MouseEvent<SVGSVGElement>) => {
    if (draggedNodeRef.current && svgRef.current) {
      // Dragging node
      const node = graphNodes.find(n => n.id === draggedNodeRef.current);
      if (node) {
        const rect = svgRef.current.getBoundingClientRect();
        const mouseX = e.clientX - rect.left;
        const mouseY = e.clientY - rect.top;
        
        node.fx = (mouseX - pan.x) / zoom;
        node.fy = (mouseY - pan.y) / zoom;
        node.x = node.fx;
        node.y = node.fy;
        
        // Re-heat simulation
        alphaRef.current = 1.0;
        setIsAnimating(true);
      }
    } else if (isPanning) {
      // Panning background
      setPan(prev => ({
        x: prev.x + (e.clientX - startPanRef.current.x),
        y: prev.y + (e.clientY - startPanRef.current.y),
      }));
      startPanRef.current = { x: e.clientX, y: e.clientY };
    }
  };

  const handleMouseUpOrLeave = () => {
    if (draggedNodeRef.current) {
      const node = graphNodes.find(n => n.id === draggedNodeRef.current);
      if (node) {
        node.fx = undefined;
        node.fy = undefined;
      }
      draggedNodeRef.current = null;
      
      alphaRef.current = 0.5;
      setIsAnimating(true);
    }
    setIsPanning(false);
  };

  // Node drag handlers
  const handleNodeMouseDown = (node: GraphNode, e: React.MouseEvent) => {
    e.stopPropagation();
    draggedNodeRef.current = node.id;
    
    const rect = svgRef.current?.getBoundingClientRect();
    if (!rect) return;
    
    const mouseX = e.clientX - rect.left;
    const mouseY = e.clientY - rect.top;
    
    node.fx = (mouseX - pan.x) / zoom;
    node.fy = (mouseY - pan.y) / zoom;
    
    alphaRef.current = 1.0;
    setIsAnimating(true);
  };

  // Node Selection (Focus in detail panel)
  const handleNodeClick = (node: GraphNode, e: React.MouseEvent) => {
    e.stopPropagation();
    setSelectedNodeId(node.id);
  };

  const selectedNode = useMemo(() => {
    if (!selectedNodeId) return null;
    return graphNodes.find(n => n.id === selectedNodeId) || null;
  }, [selectedNodeId, graphNodes]);

  // Highlight matches based on searchName (dim non-matching nodes)
  const highlightedNodeIds = useMemo(() => {
    if (!searchName.trim()) return null;
    const term = searchName.toLowerCase();
    
    // Find matching nodes
    const matches = graphNodes.filter(n => n.name.toLowerCase().includes(term));
    const ids = new Set(matches.map(n => n.id));
    
    // Include their immediate neighbors to keep context
    graphLinks.forEach(link => {
      if (ids.has(link.source)) ids.add(link.target);
      if (ids.has(link.target)) ids.add(link.source);
    });

    return ids;
  }, [searchName, graphNodes, graphLinks]);

  // Statistics calculations
  const stats = useMemo(() => {
    const totalDisciples = graphNodes.length;
    const totalGcs = new Set(graphNodes.map(n => n.homeGroupId).filter(Boolean)).size;
    const totalLeaders = graphNodes.filter(n => leaderIds.has(n.id)).length;
    
    const disciplesWithDiscipler = graphNodes.filter(n => n.disciplerId);
    const uniqueDisciplers = new Set(disciplesWithDiscipler.map(n => n.disciplerId));
    const avgDisciplesPerDiscipler = uniqueDisciplers.size > 0 
      ? (disciplesWithDiscipler.length / uniqueDisciplers.size).toFixed(1) 
      : "0.0";
    
    return {
      totalDisciples,
      totalGcs,
      totalLeaders,
      avgDisciplesPerDiscipler
    };
  }, [graphNodes, leaderIds]);

  // Helpers for selected node connections list
  const selectedNodeRelationships = useMemo(() => {
    if (!selectedNode) return [];
    
    const relations: { nodeId: string; name: string; typeName: string; icon: string }[] = [];
    const nodeMap = new Map(graphNodes.map(n => [n.id, n]));

    // 1. Discipler
    if (selectedNode.disciplerId) {
      const d = nodeMap.get(selectedNode.disciplerId);
      if (d) {
        relations.push({
          nodeId: d.id,
          name: d.name,
          typeName: "Discipulador",
          icon: "Shield"
        });
      }
    }

    // 2. Disciples (who they disciple)
    graphNodes.forEach(n => {
      if (n.disciplerId === selectedNode.id) {
        relations.push({
          nodeId: n.id,
          name: n.name,
          typeName: "Discípulo",
          icon: "User"
        });
      }
    });

    // 3. Fellowships
    graphLinks.forEach(link => {
      if (link.type === "fellowship") {
        if (link.source === selectedNode.id && nodeMap.has(link.target)) {
          const n = nodeMap.get(link.target)!;
          relations.push({
            nodeId: n.id,
            name: n.name,
            typeName: "Companheiro",
            icon: "Heart"
          });
        } else if (link.target === selectedNode.id && nodeMap.has(link.source)) {
          const n = nodeMap.get(link.source)!;
          relations.push({
            nodeId: n.id,
            name: n.name,
            typeName: "Companheiro",
            icon: "Heart"
          });
        }
      }
    });

    const seen = new Set<string>();
    return relations.filter(r => {
      const key = `${r.nodeId}-${r.typeName}`;
      if (seen.has(key)) return false;
      seen.add(key);
      return true;
    });
  }, [selectedNode, graphNodes, graphLinks]);

  // Node Color Helper
  const getNodeColorClass = (role: GraphNode["role"], gender: string | null) => {
    switch (role) {
      case "presbyter":
        return {
          stroke: "#a78bfa", // Violet
          fill: "rgba(167, 139, 250, 0.15)",
          text: "text-violet-500",
          border: "border-violet-500",
          color: "Violet"
        };
      case "deacon":
        return {
          stroke: "#22d3ee", // Cyan
          fill: "rgba(34, 211, 238, 0.15)",
          text: "text-cyan-500",
          border: "border-cyan-500",
          color: "Cyan"
        };
      case "leader":
        return {
          stroke: "#34d399", // Emerald
          fill: "rgba(52, 211, 153, 0.15)",
          text: "text-emerald-500",
          border: "border-emerald-500",
          color: "Emerald"
        };
      case "discipler":
        return {
          stroke: "#6366f1", // Indigo
          fill: "rgba(99, 102, 241, 0.15)",
          text: "text-indigo-500",
          border: "border-indigo-500",
          color: "Indigo"
        };
      case "child":
        return {
          stroke: "#f97316", // Orange
          fill: "rgba(249, 115, 22, 0.15)",
          text: "text-orange-500",
          border: "border-orange-500",
          color: "Orange"
        };
      default:
        if (gender === "feminino") {
          return {
            stroke: "#f472b6", // Pink
            fill: "rgba(244, 114, 182, 0.15)",
            text: "text-pink-400",
            border: "border-pink-400",
            color: "Pink"
          };
        } else if (gender === "masculino") {
          return {
            stroke: "#60a5fa", // Blue
            fill: "rgba(96, 165, 250, 0.15)",
            text: "text-blue-400",
            border: "border-blue-400",
            color: "Blue"
          };
        }
        return {
          stroke: "#a1a1aa", // Zinc/Gray
          fill: "rgba(161, 161, 170, 0.15)",
          text: "text-zinc-500 dark:text-zinc-400",
          border: "border-zinc-400 dark:border-zinc-500",
          color: "Zinc"
        };
    }
  };

  const getRoleBadgeLabel = (role: GraphNode["role"]) => {
    switch (role) {
      case "presbyter": return "Presbitério";
      case "deacon": return "Diaconato";
      case "leader": return "Líder de GC";
      case "discipler": return "Discipulador";
      case "child": return "Criança";
      default: return "Discípulo";
    }
  };

  const focusNode = (nodeId: string) => {
    const node = graphNodes.find(n => n.id === nodeId);
    if (node) {
      setPan({
        x: canvasWidth / 2 - node.x * zoom,
        y: canvasHeight / 2 - node.y * zoom
      });
      setSelectedNodeId(nodeId);
    }
  };

  if (loading) {
    return (
      <div className="space-y-6">
        <div className="flex flex-col gap-2">
          <Skeleton className="h-10 w-64" />
          <Skeleton className="h-4 w-96" />
        </div>
        <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
          <Skeleton className="h-24 col-span-1" />
          <Skeleton className="h-24 col-span-1" />
          <Skeleton className="h-24 col-span-1" />
          <Skeleton className="h-24 col-span-1" />
        </div>
        <div className="grid grid-cols-1 lg:grid-cols-4 gap-6">
          <Skeleton className="h-[500px] lg:col-span-3 rounded-2xl" />
          <Skeleton className="h-[500px] lg:col-span-1 rounded-2xl" />
        </div>
      </div>
    );
  }

  return (
    <div className="space-y-6 animate-in fade-in slide-in-from-bottom-4 duration-500">
      {/* Header */}
      <header className="flex flex-col md:flex-row md:items-center justify-between pb-6 border-b border-border/50 gap-4">
        <div>
          <h1 className="text-3xl font-bold tracking-tight text-foreground flex items-center gap-2">
            <Network className="h-8 w-8 text-primary animate-pulse" />
            Rede de Relacionamentos
          </h1>
          <p className="text-muted-foreground mt-1 text-sm md:text-base">
            Visualize e filtre as juntas e ligamentos (Atos 2) do Corpo de discípulos na cidade.
          </p>
        </div>
      </header>

      {/* Tabs */}
      <div className="flex border-b border-border/50 gap-2 mb-2">
        <button
          type="button"
          onClick={() => setActiveTab("grafo")}
          className={`px-4 py-2 text-sm font-semibold border-b-2 transition-all ${
            activeTab === "grafo"
              ? "border-primary text-primary"
              : "border-transparent text-muted-foreground hover:text-foreground"
          }`}
        >
          Visualização em Grafo
        </button>
        <button
          type="button"
          onClick={() => setActiveTab("membros")}
          className={`px-4 py-2 text-sm font-semibold border-b-2 transition-all ${
            activeTab === "membros"
              ? "border-primary text-primary"
              : "border-transparent text-muted-foreground hover:text-foreground"
          }`}
        >
          Gestão de Membros
        </button>
        <button
          type="button"
          onClick={() => setActiveTab("setores")}
          className={`px-4 py-2 text-sm font-semibold border-b-2 transition-all ${
            activeTab === "setores"
              ? "border-primary text-primary"
              : "border-transparent text-muted-foreground hover:text-foreground"
          }`}
        >
          Gestão de Setores
        </button>
      </div>

      {activeTab === "grafo" ? (
        <>
          {/* Stats Board */}
      <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
        <Card className="bg-card/20 backdrop-blur-sm border-border/50 shadow-sm">
          <CardContent className="p-4 flex items-center gap-3">
            <div className="p-2.5 bg-primary/10 text-primary rounded-xl">
              <User className="h-5 w-5" />
            </div>
            <div>
              <p className="text-xs text-muted-foreground font-medium uppercase tracking-wider">Discípulos</p>
              <h3 className="text-xl font-bold text-foreground">{stats.totalDisciples}</h3>
            </div>
          </CardContent>
        </Card>

        <Card className="bg-card/20 backdrop-blur-sm border-border/50 shadow-sm">
          <CardContent className="p-4 flex items-center gap-3">
            <div className="p-2.5 bg-primary/10 text-primary rounded-xl">
              <Users className="h-5 w-5" />
            </div>
            <div>
              <p className="text-xs text-muted-foreground font-medium uppercase tracking-wider">Grupos Caseiros</p>
              <h3 className="text-xl font-bold text-foreground">{stats.totalGcs}</h3>
            </div>
          </CardContent>
        </Card>

        <Card className="bg-card/20 backdrop-blur-sm border-border/50 shadow-sm">
          <CardContent className="p-4 flex items-center gap-3">
            <div className="p-2.5 bg-primary/10 text-primary rounded-xl">
              <Shield className="h-5 w-5" />
            </div>
            <div>
              <p className="text-xs text-muted-foreground font-medium uppercase tracking-wider">Líderes de GC</p>
              <h3 className="text-xl font-bold text-foreground">{stats.totalLeaders}</h3>
            </div>
          </CardContent>
        </Card>

        <Card className="bg-card/20 backdrop-blur-sm border-border/50 shadow-sm">
          <CardContent className="p-4 flex items-center gap-3">
            <div className="p-2.5 bg-primary/10 text-primary rounded-xl">
              <Heart className="h-5 w-5" />
            </div>
            <div>
              <p className="text-xs text-muted-foreground font-medium uppercase tracking-wider">Média p/ Discipulador</p>
              <h3 className="text-xl font-bold text-foreground">{stats.avgDisciplesPerDiscipler}</h3>
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Main Grid: Graph + Panel */}
      <div className="grid grid-cols-1 lg:grid-cols-4 gap-6 items-stretch">
        
        {/* Canvas Graph View */}
        <div className="lg:col-span-3 flex flex-col space-y-4">
          <div className="border border-zinc-200 dark:border-zinc-800 rounded-2xl bg-white dark:bg-zinc-900/60 backdrop-blur-sm shadow-md dark:shadow-[0_4px_20px_rgba(0,0,0,0.5)] overflow-hidden relative min-h-[500px] h-[600px] flex flex-col">
            
            {/* Legend / Overlay info */}
            <div className="absolute top-4 left-4 z-10 flex flex-wrap gap-2 max-w-[80%] pointer-events-none">
              <div className="bg-background/90 dark:bg-zinc-900/90 border border-border/50 backdrop-blur px-3 py-1.5 rounded-xl text-xs flex items-center gap-4 shadow-sm pointer-events-auto">
                <span className="font-semibold text-muted-foreground">Linhas:</span>
                <span className="flex items-center gap-1.5"><span className="w-4 h-0.5 bg-indigo-500 inline-block"></span> Discipulado</span>
                <span className="flex items-center gap-1.5"><span className="w-4 h-0.5 border-t border-dashed border-teal-500 inline-block"></span> Companheiros</span>
                <span className="flex items-center gap-1.5"><span className="w-4 h-0.5 border-t border-dotted border-amber-500 inline-block"></span> Membros do GC</span>
              </div>
            </div>

            {/* Canvas Actions Control */}
            <div className="absolute bottom-4 right-4 z-10 flex flex-col gap-2 pointer-events-auto">
              <Button size="icon" variant="secondary" onClick={() => handleZoom(1.2)} title="Aproximar">
                <ZoomIn className="h-4 w-4" />
              </Button>
              <Button size="icon" variant="secondary" onClick={() => handleZoom(0.8)} title="Afastar">
                <ZoomOut className="h-4 w-4" />
              </Button>
              <Button size="icon" variant="secondary" onClick={handleResetZoom} title="Centralizar e Redefinir">
                <Maximize2 className="h-4 w-4" />
              </Button>
            </div>

            {/* Empty graph message */}
            {graphNodes.length === 0 && (
              <div className="absolute inset-0 flex flex-col items-center justify-center text-center p-8 bg-zinc-950/5">
                <Network className="h-12 w-12 text-zinc-400 mb-2" />
                <h4 className="text-lg font-semibold text-foreground">Nenhum discípulo coincide com os filtros</h4>
                <p className="text-sm text-muted-foreground mt-1">Ajuste os filtros de setor, GC ou papéis na barra lateral.</p>
              </div>
            )}

            {/* SVG Renderer */}
            <svg
              ref={svgRefCallback}
              className="w-full h-full cursor-grab active:cursor-grabbing select-none"
              onMouseDown={handleMouseDown}
              onMouseMove={handleMouseMove}
              onMouseUp={handleMouseUpOrLeave}
              onMouseLeave={handleMouseUpOrLeave}
            >
              {/* Directed Link Arrow Marker */}
              <defs>
                <marker
                  id="arrow-marker"
                  viewBox="0 0 10 10"
                  refX="9" 
                  refY="5"
                  markerWidth="6"
                  markerHeight="6"
                  orient="auto-start-reverse"
                >
                  <path d="M 0 0 L 10 5 L 0 10 z" fill="#6366f1" />
                </marker>
              </defs>

              {/* Wrapped translation group for Zoom & Pan */}
              <g transform={`translate(${pan.x}, ${pan.y}) scale(${zoom})`}>
                
                {/* Edges (Links) */}
                <g>
                  {graphLinks.map((link, idx) => {
                    const nodeMap = new Map(graphNodes.map(n => [n.id, n]));
                    const sourceNode = nodeMap.get(link.source);
                    const targetNode = nodeMap.get(link.target);

                    if (!sourceNode || !targetNode) return null;

                    let color = "#6366f1"; // Indigo default for discipler
                    let strokeDash: string | undefined = undefined;
                    let marker: string | undefined = undefined;

                    if (link.type === "fellowship") {
                      color = "#14b8a6"; // Teal for fellowship
                      strokeDash = "4,4";
                    } else if (link.type === "group_leader") {
                      color = "#f59e0b"; // Amber for group members
                      strokeDash = "2,2";
                    } else {
                      marker = "url(#arrow-marker)";
                    }

                    const isHighlighted = highlightedNodeIds === null || 
                      (highlightedNodeIds.has(link.source) && highlightedNodeIds.has(link.target));

                    const sourceRadius = sourceNode.role === "presbyter" ? 22 
                      : sourceNode.role === "deacon" ? 20 
                      : sourceNode.role === "leader" ? 18 
                      : sourceNode.role === "discipler" ? 18 
                      : sourceNode.role === "child" ? 12 
                      : 16;

                    const targetRadius = targetNode.role === "presbyter" ? 22 
                      : targetNode.role === "deacon" ? 20 
                      : targetNode.role === "leader" ? 18 
                      : targetNode.role === "discipler" ? 18 
                      : targetNode.role === "child" ? 12 
                      : 16;

                    const dx = targetNode.x - sourceNode.x;
                    const dy = targetNode.y - sourceNode.y;
                    const distance = Math.sqrt(dx * dx + dy * dy);

                    const sourceOffset = sourceRadius;
                    const targetOffset = targetRadius + (marker ? 2 : 0);

                    const x1 = distance > 0 ? sourceNode.x + (dx / distance) * sourceOffset : sourceNode.x;
                    const y1 = distance > 0 ? sourceNode.y + (dy / distance) * sourceOffset : sourceNode.y;

                    const x2 = distance > 0 ? targetNode.x - (dx / distance) * targetOffset : targetNode.x;
                    const y2 = distance > 0 ? targetNode.y - (dy / distance) * targetOffset : targetNode.y;

                    return (
                      <line
                        key={`link-${idx}`}
                        x1={x1}
                        y1={y1}
                        x2={x2}
                        y2={y2}
                        stroke={color}
                        strokeWidth={link.type === "discipler" ? 2.5 : 1.8}
                        strokeDasharray={strokeDash}
                        markerEnd={marker}
                        opacity={isHighlighted ? 0.75 : 0.15}
                        className="transition-opacity duration-200"
                      />
                    );
                  })}
                </g>

                {/* Nodes (Disciples) */}
                <g>
                  {graphNodes.map(node => {
                    const styles = getNodeColorClass(node.role, node.gender);
                    const isSelected = selectedNodeId === node.id;
                    const isDimmed = highlightedNodeIds !== null && !highlightedNodeIds.has(node.id);
                    const nodeRadius = node.role === "presbyter" ? 22 : node.role === "deacon" ? 20 : node.role === "leader" ? 18 : node.role === "discipler" ? 18 : node.role === "child" ? 12 : 16;
                    
                    const nameInitials = node.name
                      .split(" ")
                      .filter(Boolean)
                      .map(n => n[0])
                      .join("")
                      .toUpperCase()
                      .substring(0, 2);

                    return (
                      <g
                        key={`node-${node.id}`}
                        transform={`translate(${node.x}, ${node.y})`}
                        onMouseDown={(e) => handleNodeMouseDown(node, e)}
                        onClick={(e) => handleNodeClick(node, e)}
                        className="cursor-pointer"
                        opacity={isDimmed ? 0.2 : 1.0}
                        style={{ transition: "opacity 0.2s" }}
                      >
                        {isSelected && (
                          <circle
                            r={nodeRadius + 6}
                            fill="none"
                            stroke={styles.stroke}
                            strokeWidth={3}
                            strokeDasharray="4,2"
                            className="animate-spin"
                            style={{ animationDuration: "12s" }}
                          />
                        )}

                        <circle
                          r={nodeRadius}
                          fill={styles.fill}
                          stroke={styles.stroke}
                          strokeWidth={isSelected ? 3.5 : 2}
                          className="transition-colors duration-200"
                        />

                        {node.avatarUrl ? (
                          <g>
                            <clipPath id={`clip-${node.id}`}>
                              <circle r={nodeRadius - 1.5} />
                            </clipPath>
                            <image
                              href={node.avatarUrl}
                              x={-nodeRadius}
                              y={-nodeRadius}
                              width={nodeRadius * 2}
                              height={nodeRadius * 2}
                              clipPath={`url(#clip-${node.id})`}
                              preserveAspectRatio="xMidYMid slice"
                            />
                          </g>
                        ) : (
                          <text
                            textAnchor="middle"
                            dy=".3em"
                            fontSize={nodeRadius * 0.75}
                            fontWeight="bold"
                            fill={styles.stroke}
                            pointerEvents="none"
                          >
                            {nameInitials}
                          </text>
                        )}

                        <text
                          textAnchor="middle"
                          y={nodeRadius + 14}
                          fontSize="10"
                          fontWeight={node.role !== "disciple" ? "bold" : "normal"}
                          fill="currentColor"
                          className="text-foreground dark:text-zinc-200 select-none bg-background/50 pointer-events-none drop-shadow-sm"
                        >
                          {node.name.split(" ")[0]}
                        </text>
                      </g>
                    );
                  })}
                </g>
              </g>
            </svg>
          </div>
        </div>

        {/* Side Panel: Filters and Details */}
        <div className="lg:col-span-1 flex flex-col space-y-6">
          
          {/* Filters Card */}
          <Card className="bg-card/20 backdrop-blur-sm border-border/50 shadow-sm flex flex-col">
            <CardHeader className="p-4 pb-2">
              <CardTitle className="text-base font-semibold flex items-center gap-2">
                <SlidersHorizontal className="h-4 w-4 text-muted-foreground" />
                Filtros e Visualização
              </CardTitle>
              <CardDescription className="text-xs">
                Ajuste os filtros para explorar relações.
              </CardDescription>
            </CardHeader>
            <CardContent className="p-4 pt-2 space-y-4 text-sm">
              
              {/* Name Search */}
              <div className="space-y-1.5">
                <Label htmlFor="search-name" className="text-xs font-semibold text-muted-foreground">Destacar Irmão</Label>
                <div className="relative">
                  <Search className="absolute left-2.5 top-2.5 h-4 w-4 text-muted-foreground" />
                  <Input
                    id="search-name"
                    placeholder="Digitar nome completo..."
                    value={searchName}
                    onChange={(e) => setSearchName(e.target.value)}
                    className="pl-8 h-9 text-xs"
                  />
                </div>
              </div>

              {/* Sector Filter */}
              <div className="space-y-1.5">
                <Label className="text-xs font-semibold text-muted-foreground">Setor</Label>
                <Select 
                  value={selectedSector} 
                  onValueChange={(val) => {
                    if (val === "create_new") {
                      setIsSectorDialogOpen(true);
                    } else {
                      setSelectedSector(val);
                    }
                  }}
                >
                  <SelectTrigger className="h-9 text-xs">
                    <SelectValue placeholder="Todos os setores" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="all">Todos os setores</SelectItem>
                    {sectorsList.map(sec => (
                      <SelectItem key={sec} value={sec}>{sec}</SelectItem>
                    ))}
                    <SelectItem value="create_new" className="text-primary font-semibold border-t border-border/50 mt-1.5 pt-2 hover:bg-primary/5 focus:bg-primary/5 cursor-pointer">
                      <span className="flex items-center gap-1.5">
                        <Plus className="h-3.5 w-3.5" />
                        Criar Novo Setor...
                      </span>
                    </SelectItem>
                  </SelectContent>
                </Select>
              </div>

              {/* Home Group Filter */}
              <div className="space-y-1.5">
                <Label className="text-xs font-semibold text-muted-foreground">Grupo Caseiro</Label>
                <Select value={selectedGroup} onValueChange={setSelectedGroup}>
                  <SelectTrigger className="h-9 text-xs">
                    <SelectValue placeholder="Todos os grupos" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="all">Todos os grupos</SelectItem>
                    {homeGroups.map(hg => {
                      const labelName = getGroupLeadersName(hg);
                      return (
                        <SelectItem key={hg.id} value={hg.id}>GC - {labelName}</SelectItem>
                      );
                    })}
                  </SelectContent>
                </Select>
              </div>

              {/* Role Filter */}
              <div className="grid grid-cols-2 gap-2">
                <div className="space-y-1.5">
                  <Label className="text-xs font-semibold text-muted-foreground">Papel/Cargo</Label>
                  <Select value={selectedRole} onValueChange={setSelectedRole}>
                    <SelectTrigger className="h-9 text-xs">
                      <SelectValue placeholder="Todos" />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="all">Todos</SelectItem>
                      <SelectItem value="presbyter">Presbitério</SelectItem>
                      <SelectItem value="deacon">Diaconato</SelectItem>
                      <SelectItem value="leader">Líderes de GC</SelectItem>
                      <SelectItem value="discipler">Discipuladores</SelectItem>
                      <SelectItem value="disciple">Discípulos</SelectItem>
                      <SelectItem value="child">Crianças</SelectItem>
                    </SelectContent>
                  </Select>
                </div>

                <div className="space-y-1.5">
                  <Label className="text-xs font-semibold text-muted-foreground">Gênero</Label>
                  <Select value={selectedGender} onValueChange={setSelectedGender}>
                    <SelectTrigger className="h-9 text-xs">
                      <SelectValue placeholder="Todos" />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="all">Todos</SelectItem>
                      <SelectItem value="masculino">Masculino</SelectItem>
                      <SelectItem value="feminino">Feminino</SelectItem>
                    </SelectContent>
                  </Select>
                </div>
              </div>

              <Separator className="my-2" />

              {/* Connections types to render */}
              <div className="space-y-2">
                <Label className="text-xs font-semibold text-muted-foreground">Tipos de Conexões</Label>
                
                <div className="flex items-center space-x-2">
                  <Checkbox 
                    id="link-discipler" 
                    checked={showDiscipler} 
                    onCheckedChange={(checked) => {
                      setShowDiscipler(!!checked);
                    }} 
                  />
                  <Label htmlFor="link-discipler" className="text-xs font-medium cursor-pointer flex items-center gap-1.5">
                    <span className="w-2.5 h-2.5 rounded-full bg-indigo-500 inline-block"></span> Discipulado
                  </Label>
                </div>

                <div className="flex items-center space-x-2">
                  <Checkbox 
                    id="link-fellowship" 
                    checked={showFellowship} 
                    onCheckedChange={(checked) => {
                      setShowFellowship(!!checked);
                    }} 
                  />
                  <Label htmlFor="link-fellowship" className="text-xs font-medium cursor-pointer flex items-center gap-1.5">
                    <span className="w-2.5 h-2.5 rounded-full bg-teal-500 inline-block"></span> Comunhão / Companheiros
                  </Label>
                </div>

                <div className="flex items-center space-x-2">
                  <Checkbox 
                    id="link-groupleader" 
                    checked={showGroupLeader} 
                    onCheckedChange={(checked) => {
                      setShowGroupLeader(!!checked);
                    }} 
                  />
                  <Label htmlFor="link-groupleader" className="text-xs font-medium cursor-pointer flex items-center gap-1.5">
                    <span className="w-2.5 h-2.5 rounded-full bg-amber-500 inline-block"></span> Liderança do GC
                  </Label>
                </div>
              </div>
            </CardContent>
          </Card>

          {/* Details Card */}
          {selectedNode ? (
            <Card className="bg-card/20 backdrop-blur-sm border-border/50 shadow-sm animate-in fade-in duration-200">
              <CardHeader className="p-4 pb-2 flex flex-row items-center gap-3">
                <Avatar className="h-10 w-10 border border-zinc-200 dark:border-zinc-800">
                  <AvatarImage src={selectedNode.avatarUrl || undefined} />
                  <AvatarFallback className="bg-primary/5 text-primary text-xs font-bold">
                    {selectedNode.name.split(" ").filter(Boolean).map(n => n[0]).join("").toUpperCase().substring(0, 2)}
                  </AvatarFallback>
                </Avatar>
                <div className="overflow-hidden">
                  <CardTitle className="text-sm font-bold truncate leading-tight">{selectedNode.name}</CardTitle>
                  <span className="inline-block mt-1 text-[10px] font-semibold bg-primary/10 text-primary px-2 py-0.5 rounded-md uppercase tracking-wide">
                    {getRoleBadgeLabel(selectedNode.role)}
                  </span>
                </div>
              </CardHeader>
              <CardContent className="p-4 pt-2 space-y-4 text-xs">
                
                {/* Details list */}
                <div className="space-y-2">
                  {selectedNode.homeGroupName && (
                    <div className="flex items-center gap-2 text-muted-foreground">
                      <Users className="h-3.5 w-3.5" />
                      <span>Pertence ao <strong className="text-foreground">{selectedNode.homeGroupName}</strong></span>
                    </div>
                  )}
                  {selectedNode.neighborhood && (
                    <div className="flex items-center gap-2 text-muted-foreground">
                      <MapPin className="h-3.5 w-3.5" />
                      <span>Bairro: <strong className="text-foreground">{selectedNode.neighborhood}</strong></span>
                    </div>
                  )}
                  {selectedNode.phone && (
                    <div className="flex items-center gap-2 text-muted-foreground">
                      <Phone className="h-3.5 w-3.5" />
                      <span className="text-foreground select-all">{selectedNode.phone}</span>
                    </div>
                  )}
                  {selectedNode.email && (
                    <div className="flex items-center gap-2 text-muted-foreground">
                      <Mail className="h-3.5 w-3.5" />
                      <span className="text-foreground select-all truncate">{selectedNode.email}</span>
                    </div>
                  )}
                </div>

                <Separator className="my-2" />

                {/* Connections section */}
                <div>
                  <h4 className="font-bold text-xs uppercase tracking-wider text-muted-foreground mb-2">Relacionamentos Diretos</h4>
                  {selectedNodeRelationships.length === 0 ? (
                    <p className="text-muted-foreground italic text-xs">Nenhum relacionamento mapeado para os filtros atuais.</p>
                  ) : (
                    <div className="space-y-1.5 max-h-[160px] overflow-y-auto pr-1">
                      {selectedNodeRelationships.map((rel, idx) => (
                        <div
                          key={`rel-${idx}`}
                          onClick={() => focusNode(rel.nodeId)}
                          className="w-full flex items-center justify-between p-1.5 rounded-lg border border-border/20 bg-background/5 hover:bg-primary/5 hover:border-primary/25 transition-all text-left group cursor-pointer"
                        >
                          <span className="truncate pr-1 flex-1">
                            <span className="font-semibold text-foreground group-hover:text-primary transition-colors">{rel.name.split(" ")[0]}</span>{" "}
                            <span className="text-[10px] text-muted-foreground">({rel.name})</span>
                          </span>
                          <div className="flex items-center gap-1.5 shrink-0">
                            <span className="text-[9px] font-semibold text-muted-foreground bg-zinc-100 dark:bg-zinc-800 px-1.5 py-0.5 rounded uppercase tracking-wider group-hover:bg-primary/10 group-hover:text-primary transition-colors">
                              {rel.typeName}
                            </span>
                            {/* Disconnect button */}
                            {rel.typeName !== "GC" && rel.typeName !== "Líder" && (
                              <Button
                                type="button"
                                variant="ghost"
                                size="icon"
                                onClick={(e) => {
                                  e.stopPropagation();
                                  handleDisconnect(rel.nodeId, rel.typeName);
                                }}
                                className="h-6 w-6 text-destructive hover:bg-destructive/10 rounded-md transition-all opacity-0 group-hover:opacity-100"
                              >
                                <Trash2 className="h-3 w-3" />
                              </Button>
                            )}
                          </div>
                        </div>
                      ))}
                    </div>
                  )}
                </div>

                <Separator className="my-2" />

                {/* Add connection section */}
                <div className="space-y-3 pt-1">
                  <h4 className="font-bold text-[10px] uppercase tracking-wider text-muted-foreground">Adicionar Relacionamento</h4>
                  <div className="space-y-2">
                    <div>
                      <Label className="text-[10px] text-muted-foreground font-medium">Tipo de Conexão</Label>
                      <Select 
                        value={newConnectionType} 
                        onValueChange={(val) => setNewConnectionType(val as "is_discipler" | "is_disciple" | "fellowship" | "")}
                      >
                        <SelectTrigger className="h-8 text-[11px] mt-0.5">
                          <SelectValue placeholder="Selecione o tipo..." />
                        </SelectTrigger>
                        <SelectContent>
                          <SelectItem value="is_disciple">Discipulado por...</SelectItem>
                          <SelectItem value="is_discipler">Discipulador de...</SelectItem>
                          <SelectItem value="fellowship">Companheiro (Comunhão)</SelectItem>
                        </SelectContent>
                      </Select>
                    </div>

                    <div>
                      <Label className="text-[10px] text-muted-foreground font-medium">Outro Discípulo</Label>
                      <Select 
                        value={newConnectionTargetId} 
                        onValueChange={setNewConnectionTargetId}
                      >
                        <SelectTrigger className="h-8 text-[11px] mt-0.5">
                          <SelectValue placeholder="Selecione o irmão..." />
                        </SelectTrigger>
                        <SelectContent>
                          {profiles
                            .filter(p => p.id !== selectedNode.id)
                            .map(p => (
                              <SelectItem key={p.id} value={p.id}>
                                {p.full_name}
                              </SelectItem>
                            ))}
                        </SelectContent>
                      </Select>
                    </div>

                    <Button
                      type="button"
                      size="sm"
                      onClick={handleConnect}
                      disabled={connecting || !newConnectionType || !newConnectionTargetId}
                      className="w-full h-8 text-[11px] rounded-lg font-semibold bg-primary/95 hover:bg-primary"
                    >
                      {connecting ? "Conectando..." : "Criar Conexão"}
                    </Button>
                  </div>
                </div>
              </CardContent>
            </Card>
          ) : (
            <Card className="bg-card/10 backdrop-blur-sm border-dashed border-border/50 shadow-sm flex flex-col justify-center items-center p-6 text-center text-muted-foreground min-h-[180px]">
              <Info className="h-8 w-8 mb-2 opacity-55 text-muted-foreground" />
              <h4 className="text-xs font-bold uppercase tracking-wider">Nenhum Discípulo Selecionado</h4>
              <p className="text-[11px] mt-1">Clique em um círculo no grafo para ver suas informações detalhadas e seus relacionamentos.</p>
            </Card>
          )}

        </div>
      </div>
      </>
    ) : activeTab === "membros" ? (
      <MemberManagement hideHeader />
    ) : (
      <div className="space-y-6">
        <Card className="bg-card/20 backdrop-blur-sm border-border/50 shadow-sm">
          <CardContent className="p-4 flex flex-col sm:flex-row gap-4 items-end">
            <form onSubmit={handleCreateSectorTab} className="flex-1 flex flex-col sm:flex-row gap-4 items-end w-full">
              <div className="flex-1 space-y-1.5 w-full">
                <Label className="text-xs font-semibold text-muted-foreground">Nome do Novo Setor</Label>
                <Input 
                  placeholder="Ex: Setor Norte, Setor Central..." 
                  value={newSectorTabName} 
                  onChange={(e) => setNewSectorTabName(e.target.value)} 
                  className="bg-background rounded-xl h-11 text-sm"
                  required
                  disabled={savingSectorTab}
                />
              </div>
              <Button 
                type="submit" 
                disabled={savingSectorTab || !newSectorTabName.trim()}
                className="bg-primary hover:bg-primary/90 text-primary-foreground h-11 rounded-xl font-bold px-6 shrink-0"
              >
                {savingSectorTab ? "Criando..." : "Criar Setor"}
              </Button>
            </form>
          </CardContent>
        </Card>

        {/* Map of Home Groups with Color Labeling */}
        <Card className="bg-card/25 backdrop-blur-sm border-border/50 shadow-sm overflow-hidden flex flex-col h-[450px]">
          <CardHeader className="p-4 pb-2">
            <CardTitle className="text-sm font-bold flex items-center gap-2">
              <MapPin className="h-4 w-4 text-primary" />
              Mapa de Grupos Caseiros por Setor
            </CardTitle>
            <CardDescription className="text-xs">
              Os marcadores representam os Grupos Caseiros e suas cores indicam o setor correspondente.
            </CardDescription>
          </CardHeader>
          <CardContent className="p-4 pt-0 flex-1 relative min-h-[300px]">
            <ChurchMap 
              homeGroups={homeGroups}
              sectors={sectors}
              colorLabelingBySector
              getGroupLeadersName={getGroupLeadersName}
              hideHeader
            />
          </CardContent>
        </Card>

        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {sectors.map(sec => {
            const secGroups = homeGroups.filter(g => g.sector_id === sec.id);
            const availableGroups = homeGroups.filter(g => g.sector_id !== sec.id);
            
            return (
              <Card key={sec.id} className="bg-card/20 backdrop-blur-sm border-border/50 shadow-sm flex flex-col min-h-[300px]">
                <CardHeader className="p-4 pb-2 border-b border-border/40 flex flex-row items-center justify-between shrink-0">
                  <div>
                    <CardTitle className="text-sm font-bold text-foreground">{sec.name}</CardTitle>
                    <CardDescription className="text-[10px]">
                      {secGroups.length} {secGroups.length === 1 ? 'grupo' : 'grupos'}
                    </CardDescription>
                  </div>
                  <Button 
                    variant="ghost" 
                    size="icon" 
                    onClick={() => handleDeleteSector(sec.id)}
                    className="text-destructive hover:bg-destructive/10 h-7 w-7 rounded-md"
                    title="Excluir Setor"
                  >
                    <Trash2 className="h-4 w-4" />
                  </Button>
                </CardHeader>
                <CardContent className="p-4 flex-1 flex flex-col justify-between gap-4 overflow-hidden">
                  <div className="space-y-2 flex-1 overflow-y-auto pr-1 min-h-[120px] max-h-[220px]">
                    {secGroups.length === 0 ? (
                      <p className="text-[11px] text-muted-foreground italic text-center py-8">Nenhum grupo neste setor.</p>
                    ) : (
                      secGroups.map(group => {
                        const leaders = getGroupLeadersName(group);
                        return (
                          <div key={group.id} className="flex items-center justify-between p-2 rounded-lg bg-zinc-50 dark:bg-zinc-950 border border-border/30">
                            <div className="overflow-hidden pr-2 flex-1">
                              <p className="text-xs font-semibold text-foreground truncate">GC - {leaders}</p>
                              <p className="text-[10px] text-muted-foreground truncate">{group.location_text || "Sem endereço"}</p>
                            </div>
                            <div className="flex items-center gap-1 shrink-0">
                              <Button 
                                variant="ghost" 
                                size="icon"
                                onClick={() => handleOpenEditHomeGroup(group)}
                                className="text-muted-foreground hover:text-primary hover:bg-primary/10 h-6 w-6 rounded"
                                title="Visualizar / Editar"
                              >
                                <Edit className="h-3.5 w-3.5" />
                              </Button>
                              <Button 
                                variant="ghost" 
                                size="icon"
                                onClick={() => handleRemoveGroupFromSector(group.id)}
                                className="text-muted-foreground hover:text-destructive hover:bg-destructive/10 h-6 w-6 rounded"
                                title="Remover do Setor"
                              >
                                <Trash2 className="h-3.5 w-3.5" />
                              </Button>
                            </div>
                          </div>
                        );
                      })
                    )}
                  </div>

                  <div className="border-t border-border/40 pt-3 flex gap-2 shrink-0">
                    <Select 
                      value={selectedGroupToAdd[sec.id] || ""} 
                      onValueChange={(val) => setSelectedGroupToAdd(prev => ({ ...prev, [sec.id]: val }))}
                    >
                      <SelectTrigger className="h-9 text-xs flex-1">
                        <SelectValue placeholder="Adicionar GC..." />
                      </SelectTrigger>
                      <SelectContent>
                        {availableGroups.map(g => {
                          const leaders = getGroupLeadersName(g);
                          const currentSecName = g.sector_id && sectors.find(s => s.id === g.sector_id)?.name;
                          const label = currentSecName ? `GC - ${leaders} (de: ${currentSecName})` : `GC - ${leaders}`;
                          return (
                            <SelectItem key={g.id} value={g.id}>{label}</SelectItem>
                          );
                        })}
                      </SelectContent>
                    </Select>
                    <Button 
                      type="button" 
                      onClick={() => handleAddGroupToSector(sec.id)}
                      disabled={!selectedGroupToAdd[sec.id]}
                      size="sm"
                      className="h-9 px-3 rounded-lg text-xs"
                    >
                      Adicionar
                    </Button>
                  </div>
                </CardContent>
              </Card>
            );
          })}
        </div>
      </div>
    )}

    {/* Setores Dialog Manager */}
    <Dialog open={isSectorDialogOpen} onOpenChange={setIsSectorDialogOpen}>
      <DialogContent className="sm:max-w-md">
        <DialogHeader>
          <DialogTitle className="text-base font-bold">Gerenciar Setores</DialogTitle>
          <DialogDescription className="text-xs">
            Adicione novos setores ou remova setores existentes.
          </DialogDescription>
        </DialogHeader>
        
        <form onSubmit={handleCreateSector} className="space-y-4 pt-2">
          <div className="flex gap-2">
            <Input
              placeholder="Nome do novo setor..."
              value={newSectorName}
              onChange={(e) => setNewSectorName(e.target.value)}
              className="bg-background h-10 rounded-lg text-xs"
              required
              disabled={savingSector}
            />
            <Button type="submit" disabled={savingSector} size="sm" className="h-10 px-4 rounded-lg text-xs">
              {savingSector ? "Criando..." : "Criar"}
            </Button>
          </div>
        </form>

        <div className="border-t border-border/50 pt-4 mt-4">
          <h4 className="text-xs font-semibold text-muted-foreground mb-2">Setores Cadastrados</h4>
          {sectors.length === 0 ? (
            <p className="text-xs text-muted-foreground py-2 italic text-center">Nenhum setor cadastrado ainda.</p>
          ) : (
            <div className="max-h-48 overflow-y-auto space-y-1.5 pr-1">
              {sectors.map((sec) => (
                <div key={sec.id} className="flex items-center justify-between p-2 rounded-lg bg-zinc-50 dark:bg-zinc-900 border border-border/30 hover:border-border/60 transition-colors">
                  <span className="text-xs font-medium text-foreground">{sec.name}</span>
                  <Button
                    type="button"
                    variant="ghost"
                    size="icon-sm"
                    onClick={() => handleDeleteSector(sec.id)}
                    className="text-destructive hover:bg-destructive/10 h-7 w-7 rounded-md"
                  >
                    <Trash2 className="h-3.5 w-3.5" />
                  </Button>
                </div>
              ))}
            </div>
          )}
        </div>
      </DialogContent>
    </Dialog>

    {/* Edit Home Group Dialog */}
    <Dialog open={!!selectedHomeGroupToEdit} onOpenChange={(open) => !open && setSelectedHomeGroupToEdit(null)}>
      <DialogContent className="sm:max-w-lg">
        <DialogHeader>
          <DialogTitle className="text-base font-bold flex items-center gap-2">
            <Edit className="h-4 w-4 text-primary" />
            Visualizar e Editar Grupo Caseiro
          </DialogTitle>
          <DialogDescription className="text-xs">
            Visualize as informações do Grupo Caseiro ou altere suas configurações, líderes e localização.
          </DialogDescription>
        </DialogHeader>

        <form onSubmit={handleSaveHomeGroup} className="space-y-4 pt-2">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            
            {/* Dia de Reunião */}
            <div className="space-y-1">
              <Label className="text-xs font-semibold text-muted-foreground">Dia de Reunião</Label>
              <Select
                value={String(editHomeGroupMeetingDay)}
                onValueChange={(val) => setEditHomeGroupMeetingDay(Number(val))}
              >
                <SelectTrigger className="w-full h-10 text-xs bg-background/50">
                  <SelectValue placeholder="Selecione o dia..." />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="0">Domingo</SelectItem>
                  <SelectItem value="1">Segunda-feira</SelectItem>
                  <SelectItem value="2">Terça-feira</SelectItem>
                  <SelectItem value="3">Quarta-feira</SelectItem>
                  <SelectItem value="4">Quinta-feira</SelectItem>
                  <SelectItem value="5">Sexta-feira</SelectItem>
                  <SelectItem value="6">Sábado</SelectItem>
                </SelectContent>
              </Select>
            </div>

            {/* Horário de Início */}
            <div className="space-y-1">
              <Label className="text-xs font-semibold text-muted-foreground">Horário de Início</Label>
              <Input
                type="time"
                value={editHomeGroupStartTime || ""}
                onChange={(e) => setEditHomeGroupStartTime(e.target.value)}
                className="bg-background h-10 rounded-lg text-xs"
                required
              />
            </div>

            {/* Líder 1 */}
            <div className="space-y-1">
              <Label className="text-xs font-semibold text-muted-foreground">Líder 1</Label>
              <Select
                value={editHomeGroupLeader1Id}
                onValueChange={setEditHomeGroupLeader1Id}
              >
                <SelectTrigger className="w-full h-10 text-xs bg-background/50">
                  <SelectValue placeholder="Selecione o Líder 1..." />
                </SelectTrigger>
                <SelectContent>
                  {profiles.map(p => (
                    <SelectItem key={p.id} value={p.id}>{p.full_name}</SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>

            {/* Líder 2 */}
            <div className="space-y-1">
              <Label className="text-xs font-semibold text-muted-foreground">Líder 2 (Opcional)</Label>
              <Select
                value={editHomeGroupLeader2Id || "none"}
                onValueChange={(val) => setEditHomeGroupLeader2Id(val === "none" ? null : val)}
              >
                <SelectTrigger className="w-full h-10 text-xs bg-background/50">
                  <SelectValue placeholder="Nenhum" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="none">Nenhum</SelectItem>
                  {profiles
                    .filter(p => p.id !== editHomeGroupLeader1Id)
                    .map(p => (
                      <SelectItem key={p.id} value={p.id}>{p.full_name}</SelectItem>
                    ))}
                </SelectContent>
              </Select>
            </div>

            {/* Setor */}
            <div className="space-y-1 md:col-span-2">
              <Label className="text-xs font-semibold text-muted-foreground">Setor</Label>
              <Select
                value={editHomeGroupSectorId || "none"}
                onValueChange={(val) => setEditHomeGroupSectorId(val === "none" ? null : val)}
              >
                <SelectTrigger className="w-full h-10 text-xs bg-background/50">
                  <SelectValue placeholder="Sem Setor" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="none">Sem Setor</SelectItem>
                  {sectors.map(sec => (
                    <SelectItem key={sec.id} value={sec.id}>{sec.name}</SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>

            {/* Endereço / Localização */}
            <div className="space-y-1 md:col-span-2">
              <Label className="text-xs font-semibold text-muted-foreground">Endereço</Label>
              <div className="flex gap-2">
                <Input
                  placeholder="Rua, Número, Bairro, Belo Horizonte - MG"
                  value={editHomeGroupLocationText}
                  onChange={(e) => setEditHomeGroupLocationText(e.target.value)}
                  className="bg-background h-10 rounded-lg text-xs flex-1"
                  required
                />
                <Button
                  type="button"
                  onClick={handleGeocodeEditAddress}
                  disabled={geocodingEdit || !editHomeGroupLocationText.trim()}
                  variant="secondary"
                  size="sm"
                  className="h-10 px-3 text-xs"
                >
                  {geocodingEdit ? "Buscando..." : "Buscar Coord."}
                </Button>
              </div>
            </div>

            {/* Coordenadas */}
            <div className="space-y-1">
              <Label className="text-xs font-semibold text-muted-foreground">Latitude</Label>
              <Input
                type="number"
                step="any"
                value={editHomeGroupLat !== null ? editHomeGroupLat : ""}
                onChange={(e) => setEditHomeGroupLat(e.target.value ? parseFloat(e.target.value) : null)}
                className="bg-background h-10 rounded-lg text-xs"
                placeholder="Ex: -19.9226"
              />
            </div>
            <div className="space-y-1">
              <Label className="text-xs font-semibold text-muted-foreground">Longitude</Label>
              <Input
                type="number"
                step="any"
                value={editHomeGroupLng !== null ? editHomeGroupLng : ""}
                onChange={(e) => setEditHomeGroupLng(e.target.value ? parseFloat(e.target.value) : null)}
                className="bg-background h-10 rounded-lg text-xs"
                placeholder="Ex: -43.9450"
              />
            </div>

          </div>

          <div className="border-t border-border/50 pt-4 flex justify-end gap-2 mt-4">
            <Button
              type="button"
              variant="outline"
              size="sm"
              onClick={() => setSelectedHomeGroupToEdit(null)}
              className="h-9 px-4 rounded-lg text-xs"
            >
              Cancelar
            </Button>
            <Button
              type="submit"
              disabled={savingHomeGroup}
              size="sm"
              className="h-9 px-4 rounded-lg text-xs bg-primary text-primary-foreground hover:bg-primary/95"
            >
              {savingHomeGroup ? "Salvando..." : "Salvar Alterações"}
            </Button>
          </div>
        </form>
      </DialogContent>
    </Dialog>
    </div>
  );
}
