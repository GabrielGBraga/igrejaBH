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
  spouseId: string | null;
  level?: number;
  
  // Coordenadas
  x: number;
  y: number;
}

interface GraphLink {
  source: string;
  target: string;
  type: "discipler" | "fellowship" | "group_leader" | "marriage";
}

export default function RedeRelacionamentos() {
  const [loading, setLoading] = useState(true);
  const [profiles, setProfiles] = useState<Profile[]>([]);
  const [homeGroups, setHomeGroups] = useState<HomeGroup[]>([]);
  const [fellowships, setFellowships] = useState<Fellowship[]>([]);
  const [sectors, setSectors] = useState<Sector[]>([]);
  const [leaderIds, setLeaderIds] = useState<Set<string>>(new Set());
  const [activeTab, setActiveTab] = useState<"grafo" | "membros" | "setores">("grafo");

  // Filters State
  const [selectedSector, setSelectedSector] = useState<string>("all");
  const [selectedGroup, setSelectedGroup] = useState<string>("all");
  const [selectedRole, setSelectedRole] = useState<string>("all");
  const [selectedGender, setSelectedGender] = useState<string>("all");
  const [searchName, setSearchName] = useState<string>("");
  
  // Connection type to show (only one at a time)
  const [activeConnectionType, setActiveConnectionType] = useState<"discipler" | "fellowship" | "group_leader">("discipler");

  // Zoom & Pan
  const [isolateSelectedConnections, setIsolateSelectedConnections] = useState(false);
  const nodePositionsRef = useRef<Map<string, { x: number; y: number }>>(new Map());

  // Selected disciple details
  const [selectedNodeId, setSelectedNodeId] = useState<string | null>(null);

  const canvasWidth = 1400;
  const canvasHeight = 800;

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



  const handleOpenEditHomeGroup = (hg: HomeGroup) => {
    setSelectedHomeGroupToEdit(hg);
    setEditHomeGroupMeetingDay(hg.meeting_day ?? 1);
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
    if (profiles.length === 0) return { nodes: [], links: [], maxLevel: 1 };

    const uniqueDisciplers = new Set(profiles.map(p => p.discipler_id).filter((id): id is string => !!id));

    // Calculate level of discipleship for each profile recursively
    const profileMap = new Map(profiles.map(p => [p.id, p]));
    const nodeLevels = new Map<string, number>();

    profiles.forEach(p => {
      let currentId = p.id;
      let distance = 0;
      const visited = new Set<string>();
      let computedLevel = 1;

      while (currentId) {
        if (visited.has(currentId)) break;
        visited.add(currentId);

        const currentProfile = profileMap.get(currentId);
        if (!currentProfile) {
          computedLevel = 1 + distance;
          break;
        }

        if (currentProfile.is_presbyter) {
          computedLevel = 1 + distance;
          break;
        }

        if (!currentProfile.discipler_id || !profileMap.has(currentProfile.discipler_id)) {
          let baseLevel = 1;
          const isLeader = leaderIds.has(currentProfile.id);
          const isDiscipler = uniqueDisciplers.has(currentProfile.id);
          const isChild = !!(currentProfile.father_id || currentProfile.mother_id) && !currentProfile.baptism_date;

          if (currentProfile.is_presbyter) baseLevel = 1;
          else if (currentProfile.is_deacon) baseLevel = 2;
          else if (isLeader || isDiscipler) baseLevel = 3;
          else if (isChild) baseLevel = 5;
          else baseLevel = 4; // standard disciple

          computedLevel = baseLevel + distance;
          break;
        }
        currentId = currentProfile.discipler_id;
        distance++;
      }

      nodeLevels.set(p.id, computedLevel);
    });

    // Align levels for married couples to avoid vertical layout conflicts
    profiles.forEach(p => {
      if (p.spouse_id) {
        const spouseLevel = nodeLevels.get(p.spouse_id);
        const myLevel = nodeLevels.get(p.id);
        if (myLevel && spouseLevel && myLevel !== spouseLevel) {
          const minLevel = Math.min(myLevel, spouseLevel);
          nodeLevels.set(p.id, minLevel);
          nodeLevels.set(p.spouse_id, minLevel);
        }
      }
    });

    const maxLevelGlobal = Math.max(...Array.from(nodeLevels.values()), 1);

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

      const level = nodeLevels.get(p.id) || 1;

      // Circular initial layout to distribute clusters nicely
      const angle = (idx / profiles.length) * 2 * Math.PI;
      const radius = role === "presbyter" ? 80 
        : role === "deacon" ? 120 
        : role === "leader" ? 170 
        : role === "discipler" ? 210 
        : role === "child" ? 300 
        : 260;
      
      const existingPos = nodePositionsRef.current.get(p.id);
      
      const genderMapped = p.gender === "F" || p.gender === "feminino" ? "feminino" : p.gender === "M" || p.gender === "masculino" ? "masculino" : p.gender;

      const targetY = level * (canvasHeight / (maxLevelGlobal + 1));

      return {
        id: p.id,
        name: p.full_name,
        avatarUrl: p.avatar_url,
        role,
        gender: genderMapped,
        homeGroupId: p.home_group_id,
        homeGroupName: hgName,
        sector: hgSector,
        neighborhood: p.address_neighborhood,
        phone: p.phone,
        email: p.email,
        disciplerId: p.discipler_id,
        spouseId: p.spouse_id,
        level,
        x: existingPos ? existingPos.x : (canvasWidth / 2 + Math.cos(angle) * radius * 3 + (Math.random() - 0.5) * 80),
        y: existingPos ? existingPos.y : (targetY + (Math.random() - 0.5) * 40)
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
          const existingPos = nodePositionsRef.current.get(n.id);
          if (!existingPos) {
            n.x = parent.x + (Math.random() - 0.5) * 60;
            n.y = parent.y + (Math.random() - 0.5) * 60;
          }
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

    // 4. Marriage links (undirected, rose-colored solid lines)
    profiles.forEach(p => {
      if (p.spouse_id && nodeMap.has(p.spouse_id)) {
        if (p.id < p.spouse_id) {
          links.push({
            source: p.id,
            target: p.spouse_id,
            type: "marriage"
          });
        }
      }
    });

    return { nodes, links, maxLevel: maxLevelGlobal };
  }, [profiles, fellowships, leaderIds, groupMap, getGroupLeadersName, sectorMap]);

  // 2. Filter Graph based on filter values
  const filteredData = useMemo(() => {
    const { nodes, links } = rawGraph;
    if (nodes.length === 0) return { nodes: [], links: [], maxLevel: 1 };

    // Clone nodes so simulation does not affect rawGraph
    const nodesCloned: GraphNode[] = nodes.map(n => ({ ...n }));

    // Determine which nodes match the filters
    const matchingNodeIds = new Set<string>();

    const shouldHideChildren = activeConnectionType === "discipler" || activeConnectionType === "fellowship";

    nodesCloned.forEach(n => {
      // REGRA 3: Ocultar crianças em visões de discipulado ("discipler") ou comunhão ("fellowship")
      if (shouldHideChildren && n.role === "child") return;

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

    // Filter links by active connection type OR marriage connection
    const filteredLinks = links.filter(link => {
      const isTypeMatch = link.type === activeConnectionType || link.type === "marriage";
      if (!isTypeMatch) return false;
      
      // Both ends must be currently matching/visible nodes
      return matchingNodeIds.has(link.source) && matchingNodeIds.has(link.target);
    });

    // Nodes that are visible: matching nodes
    let filteredNodes = nodesCloned.filter(n => matchingNodeIds.has(n.id));

    // If "All groups" is selected and no sector is filtered, filter out isolated nodes to prevent massive clutter
    if (selectedGroup === "all" && selectedSector === "all") {
      const connectedNodeIds = new Set<string>();
      filteredLinks.forEach(link => {
        // Only count active connection type (not marriage) for isolation filter to prevent cluttering
        if (link.type === activeConnectionType) {
          connectedNodeIds.add(link.source);
          connectedNodeIds.add(link.target);
        }
      });
      filteredNodes = filteredNodes.filter(n => connectedNodeIds.has(n.id));
    }

    return { nodes: filteredNodes, links: filteredLinks, maxLevel: rawGraph.maxLevel };
  }, [rawGraph, selectedSector, selectedGroup, selectedRole, selectedGender, activeConnectionType]);

  // Selected disciple details
  const selectedNode = useMemo(() => {
    if (!selectedNodeId) return null;
    return rawGraph.nodes.find(n => n.id === selectedNodeId) || null;
  }, [selectedNodeId, rawGraph.nodes]);

  // Statistics calculations
  const stats = useMemo(() => {
    const totalDisciples = filteredData.nodes.length;
    const totalGcs = new Set(filteredData.nodes.map(n => n.homeGroupId).filter(Boolean)).size;
    const totalLeaders = filteredData.nodes.filter(n => leaderIds.has(n.id)).length;
    
    const disciplesWithDiscipler = filteredData.nodes.filter(n => n.disciplerId);
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
  }, [filteredData.nodes, leaderIds]);

  // Helpers for selected node connections list
  const selectedNodeRelationships = useMemo(() => {
    if (!selectedNode) return [];
    
    const relations: { nodeId: string; name: string; typeName: string; icon: string }[] = [];
    const nodeMap = new Map(rawGraph.nodes.map(n => [n.id, n]));

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
    rawGraph.nodes.forEach(n => {
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
    rawGraph.links.forEach(link => {
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
  }, [selectedNode, rawGraph]);

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
          <RelationshipGraph
            nodes={filteredData.nodes}
            links={filteredData.links}
            searchName={searchName}
            selectedNodeId={selectedNodeId}
            onSelectNode={setSelectedNodeId}
            isolateSelectedConnections={isolateSelectedConnections}
            nodePositionsRef={nodePositionsRef}
            connectionType={activeConnectionType}
            maxLevel={filteredData.maxLevel}
          />
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

              {/* Connection Type Filter (Mutually Exclusive) */}
              <div className="space-y-2">
                <Label className="text-xs font-semibold text-muted-foreground">Tipo de Conexão (Ver uma por vez)</Label>
                <div className="grid grid-cols-1 gap-1 bg-zinc-100/50 dark:bg-zinc-800/30 p-1 rounded-xl border border-border/30">
                  <button
                    type="button"
                    onClick={() => setActiveConnectionType("discipler")}
                    className={`px-3 py-1.5 rounded-lg text-left text-xs font-medium transition-all flex items-center gap-2 ${
                      activeConnectionType === "discipler"
                        ? "bg-indigo-500 text-white shadow-sm"
                        : "text-zinc-600 dark:text-zinc-400 hover:bg-zinc-200/50 dark:hover:bg-zinc-800/50"
                    }`}
                  >
                    <span className={`w-2 h-2 rounded-full ${activeConnectionType === "discipler" ? "bg-white" : "bg-indigo-500"}`}></span>
                    Discipulado
                  </button>
                  <button
                    type="button"
                    onClick={() => setActiveConnectionType("fellowship")}
                    className={`px-3 py-1.5 rounded-lg text-left text-xs font-medium transition-all flex items-center gap-2 ${
                      activeConnectionType === "fellowship"
                        ? "bg-teal-500 text-white shadow-sm"
                        : "text-zinc-600 dark:text-zinc-400 hover:bg-zinc-200/50 dark:hover:bg-zinc-800/50"
                    }`}
                  >
                    <span className={`w-2 h-2 rounded-full ${activeConnectionType === "fellowship" ? "bg-white" : "bg-teal-500"}`}></span>
                    Companheiros / Comunhão
                  </button>
                  <button
                    type="button"
                    onClick={() => setActiveConnectionType("group_leader")}
                    className={`px-3 py-1.5 rounded-lg text-left text-xs font-medium transition-all flex items-center gap-2 ${
                      activeConnectionType === "group_leader"
                        ? "bg-amber-500 text-white shadow-sm"
                        : "text-zinc-600 dark:text-zinc-400 hover:bg-zinc-200/50 dark:hover:bg-zinc-800/50"
                    }`}
                  >
                    <span className={`w-2 h-2 rounded-full ${activeConnectionType === "group_leader" ? "bg-white" : "bg-amber-500"}`}></span>
                    Liderança do GC
                  </button>
                </div>

                <div className="flex items-center space-x-2 pt-2 border-t border-border/30 mt-2">
                  <Checkbox 
                    id="isolate-connections" 
                    checked={isolateSelectedConnections} 
                    onCheckedChange={(checked) => {
                      setIsolateSelectedConnections(!!checked);
                    }} 
                    disabled={!selectedNodeId}
                  />
                  <Label 
                    htmlFor="isolate-connections" 
                    className={`text-xs font-semibold cursor-pointer flex items-center gap-1.5 ${!selectedNodeId ? "opacity-50 cursor-not-allowed" : "text-foreground"}`}
                  >
                    Isolar relações do selecionado
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
                  <div className="flex flex-wrap gap-1.5 mt-1">
                    <span className="inline-block text-[10px] font-semibold bg-primary/10 text-primary px-2 py-0.5 rounded-md uppercase tracking-wide">
                      {getRoleBadgeLabel(selectedNode.role)}
                    </span>
                    {selectedNode.level !== undefined && (
                      <span className="inline-block text-[10px] font-semibold bg-indigo-500/10 text-indigo-500 px-2 py-0.5 rounded-md uppercase tracking-wide">
                        Nível {selectedNode.level}
                      </span>
                    )}
                  </div>
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
                          onClick={() => setSelectedNodeId(rel.nodeId)}
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

interface RelationshipGraphProps {
  nodes: GraphNode[];
  links: GraphLink[];
  searchName: string;
  selectedNodeId: string | null;
  onSelectNode: (id: string | null) => void;
  isolateSelectedConnections: boolean;
  nodePositionsRef: React.MutableRefObject<Map<string, { x: number; y: number }>>;
  connectionType: "discipler" | "fellowship" | "group_leader";
  maxLevel?: number;
}

interface TreeNode {
  id: string;
  nodes: GraphNode[];
  parent: TreeNode | null;
  children: TreeNode[];
  level: number;
  prelimX: number;
  x: number;
  y: number;
  width: number;
  leftContour: Map<number, number>;
  rightContour: Map<number, number>;
}

/**
 * Verifica se a inserção da aresta criaria um ciclo na árvore de discipulado (DAG)
 */
function wouldCreateCycle(parent: TreeNode, child: TreeNode): boolean {
  let current: TreeNode | null = parent;
  while (current !== null) {
    if (current.id === child.id) {
      return true;
    }
    current = current.parent;
  }
  return false;
}

/**
 * Calcula o posicionamento de árvore estática perfeitamente alinhada e compacta
 */
export function computeStaticHierarchyLayout(
  nodes: GraphNode[],
  links: GraphLink[],
  width: number,
  height: number,
  options?: {
    levelSpacing?: number;
    minSiblingSpacing?: number;
    nodeWidth?: number;
    spouseGap?: number;
  }
): GraphNode[] {
  const {
    levelSpacing = 140,
    minSiblingSpacing = 80,
    nodeWidth = 36,
    spouseGap = 16
  } = options || {};

  if (nodes.length === 0) return [];

  const nodeMap = new Map<string, GraphNode>(nodes.map(n => [n.id, n]));

  // 1. Agrupamento de casais em Super Nós
  const spouseMap = new Map<string, string>();
  nodes.forEach(n => {
    if (n.spouseId && nodeMap.has(n.spouseId)) {
      spouseMap.set(n.id, n.spouseId);
    }
  });

  const treeNodes: TreeNode[] = [];
  const nodeToTreeNodeMap = new Map<string, TreeNode>();
  const processedNodes = new Set<string>();

  nodes.forEach(n => {
    if (processedNodes.has(n.id)) return;

    const spouseId = spouseMap.get(n.id);
    const nodesInGroup: GraphNode[] = [n];
    processedNodes.add(n.id);

    if (spouseId && !processedNodes.has(spouseId)) {
      const spouseNode = nodeMap.get(spouseId);
      if (spouseNode) {
        nodesInGroup.push(spouseNode);
        processedNodes.add(spouseId);
      }
    }

    const treeNodeId = nodesInGroup
      .map(x => x.id)
      .sort()
      .join("_");

    const tn: TreeNode = {
      id: treeNodeId,
      nodes: nodesInGroup,
      parent: null,
      children: [],
      // REGRA 1: Inicializa o nível com o valor semântico real vindo do banco de dados
      level: nodesInGroup[0].level || 1,
      prelimX: 0,
      x: 0,
      y: 0,
      width: nodesInGroup.length === 2 ? (nodeWidth * 2 + spouseGap) : nodeWidth,
      leftContour: new Map(),
      rightContour: new Map()
    };

    treeNodes.push(tn);
    nodesInGroup.forEach(x => nodeToTreeNodeMap.set(x.id, tn));
  });

  // 2. Estabelecer fiações de discipulado excluindo ciclos (DAG)
  links.forEach(link => {
    if (link.type === "discipler") {
      const parentTN = nodeToTreeNodeMap.get(link.source);
      const childTN = nodeToTreeNodeMap.get(link.target);

      if (parentTN && childTN && parentTN.id !== childTN.id) {
        if (childTN.parent === null) {
          if (!wouldCreateCycle(parentTN, childTN)) {
            childTN.parent = parentTN;
            parentTN.children.push(childTN);
          }
        }
      }
    }
  });

  // Identifica todas as raízes da visualização
  const roots = treeNodes.filter(tn => tn.parent === null);

  // REGRA 2: Separar raízes conectadas (treeRoots) e nós solitários sem ramificações (orphans)
  const treeRoots: TreeNode[] = [];
  const orphans: TreeNode[] = [];

  roots.forEach(tn => {
    if (tn.children.length > 0) {
      treeRoots.push(tn);
    } else {
      orphans.push(tn);
    }
  });

  // Ordena raízes das árvores principais pelo cargo
  const getRolePriority = (role: string) => {
    switch (role) {
      case "presbyter": return 1;
      case "deacon": return 2;
      case "leader": return 3;
      case "discipler": return 4;
      default: return 5;
    }
  };
  treeRoots.sort((a, b) => getRolePriority(a.nodes[0].role) - getRolePriority(b.nodes[0].role));

  // REGRA 1: Recalcular níveis semânticos herdando caminhos reais, sem achatar com nível 1
  function assignLevels(tn: TreeNode, currentLevel: number) {
    tn.level = Math.max(tn.nodes[0].level || 1, currentLevel);
    tn.children.forEach(child => assignLevels(child, tn.level + 1));
  }
  treeRoots.forEach(root => assignLevels(root, 1));
  
  // Para órfãos, eles já possuem seus níveis semânticos definidos e não se alteram por conexões
  orphans.forEach(o => {
    o.level = o.nodes[0].level || 1;
  });

  // 3. Primeira Passagem (Bottom-Up): prelimX e Contornos (APENAS em treeRoots)
  function calculatePrelimAndContours(tn: TreeNode) {
    tn.children.forEach(child => calculatePrelimAndContours(child));

    // A inicialização do contorno do nó deve usar o seu nível absoluto
    tn.leftContour.set(tn.level, -tn.width / 2);
    tn.rightContour.set(tn.level, tn.width / 2);

    if (tn.children.length === 0) {
      tn.prelimX = 0;
    } else {
      const children = tn.children;
      children[0].prelimX = 0;

      const accumulatedRightContour = new Map<number, number>();
      children[0].rightContour.forEach((val, level) => {
        accumulatedRightContour.set(level, val);
      });

      for (let i = 1; i < children.length; i++) {
        const child = children[i];
        let shift = 0;

        accumulatedRightContour.forEach((leftRightVal, level) => {
          const childLeftVal = child.leftContour.get(level);
          if (childLeftVal !== undefined) {
            const requiredShift = leftRightVal - childLeftVal + minSiblingSpacing;
            shift = Math.max(shift, requiredShift);
          }
        });

        child.prelimX = shift;

        child.rightContour.forEach((rightVal, level) => {
          const currentMax = accumulatedRightContour.get(level);
          const childValDeslocado = child.prelimX + rightVal;
          if (currentMax !== undefined) {
            accumulatedRightContour.set(level, Math.max(currentMax, childValDeslocado));
          } else {
            accumulatedRightContour.set(level, childValDeslocado);
          }
        });
      }

      const firstChild = children[0];
      const lastChild = children[children.length - 1];
      const midPoint = (firstChild.prelimX + lastChild.prelimX) / 2;

      children.forEach(child => {
        child.prelimX -= midPoint;
      });

      // Mesclar contornos dos filhos usando os níveis absolutos diretamente
      children.forEach(child => {
        child.leftContour.forEach((val, absoluteLevel) => {
          const currentMin = tn.leftContour.get(absoluteLevel);
          const valDeslocado = child.prelimX + val;
          tn.leftContour.set(
            absoluteLevel,
            currentMin !== undefined ? Math.min(currentMin, valDeslocado) : valDeslocado
          );
        });

        child.rightContour.forEach((val, absoluteLevel) => {
          const currentMax = tn.rightContour.get(absoluteLevel);
          const valDeslocado = child.prelimX + val;
          tn.rightContour.set(
            absoluteLevel,
            currentMax !== undefined ? Math.max(currentMax, valDeslocado) : valDeslocado
          );
        });
      });
    }
  }

  treeRoots.forEach(root => calculatePrelimAndContours(root));

  // 4. Posicionar raízes da floresta principal sem sobreposição (APENAS em treeRoots)
  if (treeRoots.length > 0) {
    treeRoots[0].prelimX = 0;
    const accumulatedRight = new Map<number, number>();
    treeRoots[0].rightContour.forEach((val, level) => {
      accumulatedRight.set(level, val);
    });

    for (let i = 1; i < treeRoots.length; i++) {
      const root = treeRoots[i];
      let shift = 0;

      accumulatedRight.forEach((leftRightVal, level) => {
        const rootLeftVal = root.leftContour.get(level);
        if (rootLeftVal !== undefined) {
          const requiredShift = leftRightVal - rootLeftVal + minSiblingSpacing * 1.5;
          shift = Math.max(shift, requiredShift);
        }
      });

      root.prelimX = shift;

      root.rightContour.forEach((rightVal, level) => {
        const currentMax = accumulatedRight.get(level);
        const rootValDeslocado = root.prelimX + rightVal;
        if (currentMax !== undefined) {
          accumulatedRight.set(level, Math.max(currentMax, rootValDeslocado));
        } else {
          accumulatedRight.set(level, rootValDeslocado);
        }
      });
    }
  }

  // 5. Segunda Passagem (Top-Down): Resolver X e Y Finais (APENAS em treeRoots)
  function resolveFinalPositions(tn: TreeNode, parentX: number) {
    tn.x = parentX + tn.prelimX;
    tn.y = tn.level * levelSpacing;

    tn.children.forEach(child => {
      resolveFinalPositions(child, tn.x);
    });
  }
  treeRoots.forEach(root => resolveFinalPositions(root, 0));

  // REGRA 2: Nova Fase - Posicionar Órfãos em Grades (Grids) Compactas por Nível
  const orphansByLevel = new Map<number, TreeNode[]>();
  orphans.forEach(o => {
    const lvl = o.level;
    if (!orphansByLevel.has(lvl)) {
      orphansByLevel.set(lvl, []);
    }
    orphansByLevel.get(lvl)!.push(o);
  });

  const cols = 12; // Quebra de linha a cada 12 órfãos
  const columnSpacing = nodeWidth + minSiblingSpacing * 0.8;
  const rowSpacing = 50; // Altura entre linhas do mesmo nível no grid

  orphansByLevel.forEach((levelOrphans, lvl) => {
    // Ordenação estável por nome
    levelOrphans.sort((a, b) => a.nodes[0].name.localeCompare(b.nodes[0].name));

    levelOrphans.forEach((o, index) => {
      const row = Math.floor(index / cols);
      const col = index % cols;
      const numInRow = Math.min(cols, levelOrphans.length - row * cols);

      // prelimX centraliza a linha localmente em relação ao eixo X médio 0
      o.prelimX = (col - (numInRow - 1) / 2) * columnSpacing;
      o.x = o.prelimX;

      // Y final é o nível semântico real multiplicado pelo espaçamento mais o desvio da linha
      o.y = o.level * levelSpacing + row * rowSpacing;
    });
  });

  // 6. Centralização Horizontal do Grafo
  let mainMinX = Infinity;
  let mainMaxX = -Infinity;
  let hasMainNodes = false;

  treeNodes.forEach(tn => {
    const isOrphan = orphans.some(o => o.id === tn.id);
    if (!isOrphan) {
      if (tn.x < mainMinX) mainMinX = tn.x;
      if (tn.x > mainMaxX) mainMaxX = tn.x;
      hasMainNodes = true;
    }
  });

  let mainShiftX = 0;
  if (hasMainNodes) {
    const mainWidth = mainMaxX - mainMinX;
    mainShiftX = (width - mainWidth) / 2 - mainMinX;
  } else {
    mainShiftX = width / 2;
  }

  // Centraliza as subárvores principais
  treeNodes.forEach(tn => {
    const isOrphan = orphans.some(o => o.id === tn.id);
    if (!isOrphan) {
      tn.x += mainShiftX;
    }
  });

  // Centraliza cada grid de órfãos no eixo médio vertical do Canvas (width / 2)
  orphans.forEach(o => {
    o.x = width / 2 + o.prelimX;
  });

  // 7. Desempacotamento de Casais
  const outputNodes: GraphNode[] = [];
  treeNodes.forEach(tn => {
    if (tn.nodes.length === 1) {
      const singleNode = tn.nodes[0];
      singleNode.x = tn.x;
      singleNode.y = tn.y;
      outputNodes.push(singleNode);
    } else {
      const nodeA = tn.nodes[0];
      const nodeB = tn.nodes[1];

      let femaleNode = nodeA;
      let maleNode = nodeB;

      if (nodeB.gender === "feminino" || nodeA.gender === "masculino") {
        femaleNode = nodeB;
        maleNode = nodeA;
      }

      const halfGap = (nodeWidth / 2) + (spouseGap / 2);

      femaleNode.x = tn.x - halfGap;
      femaleNode.y = tn.y;

      maleNode.x = tn.x + halfGap;
      maleNode.y = tn.y;

      outputNodes.push(femaleNode, maleNode);
    }
  });

  return outputNodes;
}

export function RelationshipGraph({
  nodes,
  links,
  searchName,
  selectedNodeId,
  onSelectNode,
  isolateSelectedConnections,
  nodePositionsRef,
  connectionType,
  maxLevel,
}: RelationshipGraphProps) {
  const canvasRef = useRef<HTMLCanvasElement>(null);
  const startPanRef = useRef({ x: 0, y: 0 });

  const canvasWidth = 1400;
  const canvasHeight = 800;

  // Zoom & Pan refs (completely decoupled from React states to prevent high-frequency re-renders)
  const zoomRef = useRef(1);
  const panRef = useRef({ x: 0, y: 0 });
  const isPanningRef = useRef(false);
  const prevNodeRef = useRef<HTMLCanvasElement | null>(null);

  // Mouse interaction tracker for click vs drag detection
  const mouseDownPosRef = useRef<{ x: number; y: number } | null>(null);
  const hasDraggedRef = useRef(false);
  const clickedNodeIdRef = useRef<string | null>(null);
  
  // Hover tracking
  const hoveredNodeRef = useRef<GraphNode | null>(null);

  // Mapear referências de filtros para desenho dinâmico no Canvas
  const connectionTypeRef = useRef(connectionType);
  const selectedNodeIdRef = useRef(selectedNodeId);
  const searchNameRef = useRef(searchName);
  const isolateSelectedConnectionsRef = useRef(isolateSelectedConnections);
  
  // Guardar nós e links calculados
  const simNodesRef = useRef<GraphNode[]>([]);
  const simLinksRef = useRef<GraphLink[]>([]);

  connectionTypeRef.current = connectionType;
  selectedNodeIdRef.current = selectedNodeId;
  searchNameRef.current = searchName;
  isolateSelectedConnectionsRef.current = isolateSelectedConnections;

  // 1. CÁLCULO E ESTABILIZAÇÃO DO LAYOUT ESTÁTICO (useMemo)
  const layoutNodes = useMemo(() => {
    // Para posicionamento coerente de todos os layouts, usamos a árvore de discipulado
    const disciplerLinks = links.filter(l => l.type === "discipler");
    
    const computed = computeStaticHierarchyLayout(nodes, disciplerLinks, canvasWidth, canvasHeight, {
      levelSpacing: 140,
      minSiblingSpacing: 80,
      nodeWidth: 36,
      spouseGap: 16
    });

    // Atualiza o mapa de posições do componente pai
    computed.forEach(node => {
      nodePositionsRef.current.set(node.id, { x: node.x, y: node.y });
    });

    return computed;
  }, [nodes, links]);

  // Atualizar referências
  simNodesRef.current = layoutNodes;
  simLinksRef.current = links;

  const getRoleLabel = (role: GraphNode["role"]) => {
    switch (role) {
      case "presbyter": return "Presbítero";
      case "deacon": return "Diácono";
      case "leader": return "Líder de GC";
      case "discipler": return "Discipulador";
      case "child": return "Criança";
      case "disciple":
      default:
        return "Discípulo";
    }
  };

  // Estilos visuais dos nós
  const getNodeColorClass = (role: GraphNode["role"], gender: string | null) => {
    const isDark = document.documentElement.classList.contains("dark");
    switch (role) {
      case "presbyter":
        return isDark 
          ? { stroke: "#fb7185", fill: "rgba(251, 113, 133, 0.15)" }
          : { stroke: "#e11d48", fill: "rgba(225, 29, 72, 0.12)" };
      case "deacon":
        return isDark 
          ? { stroke: "#c084fc", fill: "rgba(192, 132, 252, 0.15)" }
          : { stroke: "#9333ea", fill: "rgba(147, 51, 234, 0.12)" };
      case "leader":
        return isDark 
          ? { stroke: "#60a5fa", fill: "rgba(96, 165, 250, 0.15)" }
          : { stroke: "#2563eb", fill: "rgba(37, 99, 235, 0.12)" };
      case "discipler":
        return isDark 
          ? { stroke: "#fbbf24", fill: "rgba(251, 191, 36, 0.15)" }
          : { stroke: "#d97706", fill: "rgba(217, 119, 6, 0.12)" };
      case "child":
        return isDark 
          ? { stroke: "#e4e4e7", fill: "rgba(228, 228, 231, 0.1)" }
          : { stroke: "#71717a", fill: "rgba(113, 113, 122, 0.08)" };
      case "disciple":
      default:
        if (gender === "feminino") {
          return isDark 
            ? { stroke: "#f472b6", fill: "rgba(244, 114, 182, 0.15)" }
            : { stroke: "#db2777", fill: "rgba(219, 39, 119, 0.12)" };
        }
        if (gender === "masculino") {
          return isDark 
            ? { stroke: "#60a5fa", fill: "rgba(96, 165, 250, 0.15)" }
            : { stroke: "#2563eb", fill: "rgba(37, 99, 235, 0.12)" };
        }
        return isDark 
          ? { stroke: "#a1a1aa", fill: "rgba(161, 161, 170, 0.15)" }
          : { stroke: "#71717a", fill: "rgba(113, 113, 122, 0.12)" };
    }
  };

  // Destaques e filtros
  const connectedNodeIds = useMemo(() => {
    if (!selectedNodeId) return null;
    const ids = new Set<string>([selectedNodeId]);
    links.forEach(link => {
      if (link.source === selectedNodeId) ids.add(link.target);
      if (link.target === selectedNodeId) ids.add(link.source);
    });
    return ids;
  }, [selectedNodeId, links]);

  const highlightedNodeIds = useMemo(() => {
    if (!searchName.trim()) return null;
    const term = searchName.toLowerCase();
    const matches = nodes.filter(n => n.name.toLowerCase().includes(term));
    const ids = new Set(matches.map(n => n.id));
    links.forEach(link => {
      if (ids.has(link.source)) ids.add(link.target);
      if (ids.has(link.target)) ids.add(link.source);
    });
    return ids;
  }, [searchName, nodes, links]);

  const connectedNodeIdsRef = useRef<Set<string> | null>(null);
  const highlightedNodeIdsRef = useRef<Set<string> | null>(null);

  connectedNodeIdsRef.current = connectedNodeIds;
  highlightedNodeIdsRef.current = highlightedNodeIds;

  // Função principal de desenho
  const drawCanvas = () => {
    const canvas = canvasRef.current;
    if (!canvas) return;
    const ctx = canvas.getContext("2d");
    if (!ctx) return;

    const dpr = window.devicePixelRatio || 1;
    const rect = canvas.getBoundingClientRect();
    const displayW = Math.round(rect.width);
    const displayH = Math.round(rect.height);
    if (canvas.width !== displayW * dpr || canvas.height !== displayH * dpr) {
      canvas.width = displayW * dpr;
      canvas.height = displayH * dpr;
    }

    ctx.clearRect(0, 0, canvas.width, canvas.height);

    ctx.save();
    ctx.scale(dpr, dpr);

    // Pan & Zoom
    ctx.translate(panRef.current.x, panRef.current.y);
    ctx.scale(zoomRef.current, zoomRef.current);

    const activeNodes = simNodesRef.current;
    const activeNodesMap = new Map(activeNodes.map(n => [n.id, n]));
    const visibleNodesCount = nodes.length;
    
    const scaleFactor = visibleNodesCount > 250 ? 0.40 
      : visibleNodesCount > 120 ? 0.60 
      : visibleNodesCount > 60 ? 0.80 
      : 1.0;

    const getNodeRadius = (role: GraphNode["role"]) => {
      let r = 16;
      switch (role) {
        case "presbyter": r = 22; break;
        case "deacon": r = 20; break;
        case "leader": r = 18; break;
        case "discipler": r = 18; break;
        case "child": r = 12; break;
        case "disciple":
        default:
          r = 16; break;
      }
      return r * scaleFactor;
    };

    const isDark = document.documentElement.classList.contains("dark");
    const bgSolidColor = isDark ? "#18181b" : "#ffffff";

    const linksToDraw = (isolateSelectedConnectionsRef.current && selectedNodeIdRef.current)
      ? simLinksRef.current.filter(link => link.source === selectedNodeIdRef.current || link.target === selectedNodeIdRef.current)
      : simLinksRef.current;

    const connNodeIds = connectedNodeIdsRef.current;
    const nodesToDraw = (isolateSelectedConnectionsRef.current && selectedNodeIdRef.current && connNodeIds)
      ? activeNodes.filter(node => connNodeIds.has(node.id))
      : activeNodes;

    // Helpers para desduplicar conexões familiares e centralizar no vão do casal
    const getGroupId = (node: GraphNode) => {
      if (node.spouseId) {
        return node.id < node.spouseId ? node.id : node.spouseId;
      }
      return node.id;
    };

    const getVisualCenter = (node: GraphNode) => {
      if (node.spouseId) {
        const spouse = activeNodesMap.get(node.spouseId);
        if (spouse) {
          return { x: (node.x + spouse.x) / 2, y: node.y };
        }
      }
      return { x: node.x, y: node.y };
    };

    const drawnGroupLinks = new Set<string>();

    // 1. Desenhar Links
    linksToDraw.forEach(link => {
      const sourceNode = activeNodesMap.get(link.source);
      const targetNode = activeNodesMap.get(link.target);
      if (!sourceNode || !targetNode) return;

      // Se não for casamento, aplica a desduplicação por grupo familiar (casais)
      if (link.type !== "marriage") {
        const groupSource = getGroupId(sourceNode);
        const groupTarget = getGroupId(targetNode);
        if (groupSource === groupTarget) return;

        const linkKey = `${groupSource}->${groupTarget}`;
        if (drawnGroupLinks.has(linkKey)) return;
        drawnGroupLinks.add(linkKey);
      }

      // Determinar as posições geométricas do desenho
      const isMarriage = link.type === "marriage";
      const p1 = isMarriage ? { x: sourceNode.x, y: sourceNode.y } : getVisualCenter(sourceNode);
      const p2 = isMarriage ? { x: targetNode.x, y: targetNode.y } : getVisualCenter(targetNode);

      const dx = p2.x - p1.x;
      const dy = p2.y - p1.y;
      const distance = Math.sqrt(dx * dx + dy * dy) || 1;

      let isHighlighted = true;
      if (highlightedNodeIdsRef.current !== null) {
        isHighlighted = highlightedNodeIdsRef.current.has(link.source) && highlightedNodeIdsRef.current.has(link.target);
      } else if (connectedNodeIdsRef.current !== null) {
        isHighlighted = connectedNodeIdsRef.current.has(link.source) && connectedNodeIdsRef.current.has(link.target);
      }

      ctx.save();
      
      const opacity = isHighlighted 
        ? (visibleNodesCount > 250 ? 0.35 : visibleNodesCount > 120 ? 0.55 : 0.85) 
        : 0.02;
      
      ctx.globalAlpha = opacity;

      let color = "#6366f1";
      ctx.setLineDash([]);
      
      if (link.type === "fellowship") {
        color = "#14b8a6";
        ctx.setLineDash([4, 4]);
      } else if (link.type === "group_leader") {
        color = "#f59e0b";
        ctx.setLineDash([2, 2]);
      } else if (link.type === "marriage") {
        color = "#f43f5e";
      }

      ctx.strokeStyle = color;
      ctx.lineWidth = link.type === "discipler"
        ? (visibleNodesCount > 250 ? 0.8 : visibleNodesCount > 120 ? 1.4 : 2.5)
        : (visibleNodesCount > 250 ? 0.5 : visibleNodesCount > 120 ? 1.0 : 1.8);

      const sourceRadius = getNodeRadius(sourceNode.role);
      const targetRadius = getNodeRadius(targetNode.role);
      
      const hasArrow = link.type === "discipler";
      
      // Se a origem/destino for casado (e não for linha de casamento), o ponto é o vão central, reduzindo o offset
      const sourceHasSpouse = !isMarriage && sourceNode.spouseId && activeNodesMap.has(sourceNode.spouseId);
      const targetHasSpouse = !isMarriage && targetNode.spouseId && activeNodesMap.has(targetNode.spouseId);

      const sourceOffset = sourceHasSpouse ? 0 : sourceRadius + 2;
      const targetOffset = targetHasSpouse 
        ? (hasArrow ? 8 : 0) 
        : targetRadius + (hasArrow ? 5 : 2);

      const x1 = p1.x + (dx / distance) * sourceOffset;
      const y1 = p1.y + (dy / distance) * sourceOffset;
      const x2 = p2.x - (dx / distance) * targetOffset;
      const y2 = p2.y - (dy / distance) * targetOffset;

      ctx.beginPath();
      ctx.moveTo(x1, y1);
      ctx.lineTo(x2, y2);
      ctx.stroke();

      if (hasArrow) {
        ctx.beginPath();
        const angle = Math.atan2(dy, dx);
        const arrowLength = visibleNodesCount > 250 ? 5 : visibleNodesCount > 120 ? 6 : 8;
        
        ctx.fillStyle = color;
        ctx.moveTo(x2, y2);
        ctx.lineTo(
          x2 - arrowLength * Math.cos(angle - Math.PI / 6),
          y2 - arrowLength * Math.sin(angle - Math.PI / 6)
        );
        ctx.lineTo(
          x2 - arrowLength * Math.cos(angle + Math.PI / 6),
          y2 - arrowLength * Math.sin(angle + Math.PI / 6)
        );
        ctx.closePath();
        ctx.fill();
      }

      ctx.restore();
    });

    // 2. Desenhar Nós
    nodesToDraw.forEach(node => {
      const isSelected = selectedNodeIdRef.current === node.id;
      const isHovered = hoveredNodeRef.current && hoveredNodeRef.current.id === node.id;

      let isDimmed = false;
      if (highlightedNodeIdsRef.current !== null) {
        isDimmed = !highlightedNodeIdsRef.current.has(node.id);
      } else if (connectedNodeIdsRef.current !== null) {
        isDimmed = !connectedNodeIdsRef.current.has(node.id);
      }

      ctx.save();
      ctx.globalAlpha = isDimmed ? 0.15 : 1.0;

      const radius = getNodeRadius(node.role);
      const styles = getNodeColorClass(node.role, node.gender);

      if (isSelected) {
        ctx.strokeStyle = styles.stroke;
        ctx.lineWidth = 3;
        ctx.setLineDash([4, 2]);
        ctx.lineDashOffset = - (Date.now() / 150) % 6;
        ctx.beginPath();
        ctx.arc(node.x, node.y, radius + 6, 0, 2 * Math.PI);
        ctx.stroke();
      }

      const spouseNode = node.spouseId ? activeNodesMap.get(node.spouseId) : null;
      const isMarriedToPresbyter = spouseNode?.role === "presbyter";
      
      if (connectionTypeRef.current === "discipler" && node.role !== "presbyter" && node.role !== "child" && !isMarriedToPresbyter && !node.disciplerId) {
        ctx.strokeStyle = "#ef4444";
        ctx.lineWidth = 2;
        ctx.setLineDash([3, 2]);
        ctx.beginPath();
        ctx.arc(node.x, node.y, radius + 4, 0, 2 * Math.PI);
        ctx.stroke();
      }

      ctx.fillStyle = bgSolidColor;
      ctx.beginPath();
      ctx.arc(node.x, node.y, radius, 0, 2 * Math.PI);
      ctx.fill();

      ctx.fillStyle = styles.fill;
      ctx.strokeStyle = styles.stroke;
      ctx.lineWidth = isSelected ? 3.5 : 2;
      ctx.beginPath();
      ctx.arc(node.x, node.y, radius, 0, 2 * Math.PI);
      ctx.fill();
      ctx.stroke();

      const nameInitials = node.name
        .split(" ")
        .filter(Boolean)
        .map(n => n[0])
        .join("")
        .toUpperCase()
        .substring(0, 2);

      ctx.fillStyle = styles.stroke;
      ctx.font = `bold ${Math.max(8, radius * 0.75)}px Geist, Outfit, Inter, system-ui, -apple-system, sans-serif`;
      ctx.textAlign = "center";
      ctx.textBaseline = "middle";
      ctx.fillText(nameInitials, node.x, node.y);

      const isHighlighted = isSelected || isHovered || (connectedNodeIdsRef.current && connectedNodeIdsRef.current.has(node.id));
      const showLabel = 
        isHighlighted || 
        (visibleNodesCount <= 120) || 
        (node.role !== "disciple" && node.role !== "child" && visibleNodesCount <= 220);

      if (showLabel) {
        ctx.fillStyle = isSelected 
          ? (isDark ? "#ffffff" : "#000000")
          : (isDark ? "#e4e4e7" : "#3f3f46");
        
        const isBold = isSelected || node.role !== "disciple";
        const fontSize = visibleNodesCount > 150 ? 8 : 10;
        
        ctx.font = `${isBold ? "bold" : "normal"} ${fontSize}px Geist, Outfit, Inter, system-ui, -apple-system, sans-serif`;
        ctx.textAlign = "center";
        ctx.fillText(node.name.split(" ")[0], node.x, node.y + radius + 14);
      }

      ctx.restore();
    });

    // 3. Desenhar Tooltip
    if (hoveredNodeRef.current) {
      const node = hoveredNodeRef.current;
      const radius = getNodeRadius(node.role);
      
      ctx.save();
      
      const tooltipX = node.x;
      const tooltipY = node.y - radius - 12;
      
      const textLine1 = node.name;
      const levelPrefix = connectionTypeRef.current === "discipler" && node.level !== undefined ? `Nível ${node.level} • ` : "";
      const textLine2 = `${levelPrefix}${getRoleLabel(node.role)} • GC: ${node.homeGroupName || "Sem GC"}`;
      
      ctx.font = "11px Geist, Outfit, Inter, system-ui, -apple-system, sans-serif";
      const metrics1 = ctx.measureText(textLine1);
      const metrics2 = ctx.measureText(textLine2);
      const cardWidth = Math.max(metrics1.width, metrics2.width) + 24;
      const cardHeight = 36;
      
      const rx = tooltipX - cardWidth / 2;
      const ry = tooltipY - cardHeight;
      const r = 8;
      
      ctx.fillStyle = isDark 
        ? "rgba(24, 24, 27, 0.95)" 
        : "rgba(255, 255, 255, 0.95)";
      ctx.strokeStyle = isDark
        ? "rgba(63, 63, 70, 0.5)" 
        : "rgba(228, 228, 231, 0.9)";
      ctx.lineWidth = 1;
      
      ctx.beginPath();
      ctx.moveTo(rx + r, ry);
      ctx.lineTo(rx + cardWidth - r, ry);
      ctx.quadraticCurveTo(rx + cardWidth, ry, rx + cardWidth, ry + r);
      ctx.lineTo(rx + cardWidth, ry + cardHeight - r);
      ctx.quadraticCurveTo(rx + cardWidth, ry + cardHeight, rx + cardWidth - r, ry + cardHeight);
      ctx.lineTo(rx + cardWidth / 2 + 5, ry + cardHeight);
      ctx.lineTo(rx + cardWidth / 2, ry + cardHeight + 4);
      ctx.lineTo(rx + cardWidth / 2 - 5, ry + cardHeight);
      ctx.lineTo(rx + r, ry + cardHeight);
      ctx.quadraticCurveTo(rx, ry + cardHeight, rx, ry + cardHeight - r);
      ctx.lineTo(rx, ry + r);
      ctx.quadraticCurveTo(rx, ry, rx + r, ry);
      ctx.closePath();
      
      ctx.shadowColor = "rgba(0, 0, 0, 0.25)";
      ctx.shadowBlur = 10;
      ctx.shadowOffsetY = 4;
      ctx.fill();
      ctx.shadowColor = "transparent";
      ctx.stroke();
      
      ctx.textAlign = "center";
      ctx.textBaseline = "middle";
      
      ctx.fillStyle = isDark ? "#ffffff" : "#09090b";
      ctx.font = "bold 11px Geist, Outfit, Inter, system-ui, -apple-system, sans-serif";
      ctx.fillText(textLine1, tooltipX, ry + 11);
      
      ctx.fillStyle = isDark ? "#a1a1aa" : "#71717a";
      ctx.font = "10px Geist, Outfit, Inter, system-ui, -apple-system, sans-serif";
      ctx.fillText(textLine2, tooltipX, ry + 25);
      
      ctx.restore();
    }

    ctx.restore();
  };

  // Centralização e encaixe de zoom automático ao alterar os nós
  useEffect(() => {
    const canvasEl = canvasRef.current;
    const rect2 = canvasEl ? canvasEl.getBoundingClientRect() : { width: 600, height: 500 };
    const displayWidth = rect2.width;
    const displayHeight = rect2.height;
    const fitZoom = Math.max(0.1, (displayWidth * 0.95) / canvasWidth);

    panRef.current = {
      x: displayWidth / 2 - (canvasWidth / 2) * fitZoom,
      y: displayHeight / 2 - (canvasHeight / 2) * fitZoom,
    };
    zoomRef.current = fitZoom;
    
    drawCanvas();
  }, [layoutNodes]);

  // Centralizar na seleção
  useEffect(() => {
    if (selectedNodeId) {
      const node = simNodesRef.current.find(n => n.id === selectedNodeId);
      if (node) {
        panRef.current = {
          x: canvasWidth / 2 - node.x * zoomRef.current,
          y: canvasHeight / 2 - node.y * zoomRef.current
        };
        drawCanvas();
      }
    }
  }, [selectedNodeId]);

  // Evento do mouse scroll (zoom)
  const handleWheelEvent = useCallback((e: WheelEvent) => {
    e.preventDefault();
    const factor = e.deltaY < 0 ? 1.05 : 0.95;
    const canvas = canvasRef.current;
    if (!canvas) return;

    const rect = canvas.getBoundingClientRect();
    const mouseX = e.clientX - rect.left;
    const mouseY = e.clientY - rect.top;

    const currentZoom = zoomRef.current;
    const newZoom = Math.max(0.1, Math.min(currentZoom * factor, 5));

    panRef.current = {
      x: mouseX - (mouseX - panRef.current.x) * (newZoom / currentZoom),
      y: mouseY - (mouseY - panRef.current.y) * (newZoom / currentZoom),
    };
    zoomRef.current = newZoom;
    drawCanvas();
  }, []);

  const canvasRefCallback = useCallback((node: HTMLCanvasElement | null) => {
    const ref = canvasRef as React.MutableRefObject<HTMLCanvasElement | null>;
    ref.current = node;

    if (prevNodeRef.current) {
      prevNodeRef.current.removeEventListener("wheel", handleWheelEvent);
    }
    if (node) {
      node.addEventListener("wheel", handleWheelEvent, { passive: false });
    }
    prevNodeRef.current = node;
    
    drawCanvas();
  }, [handleWheelEvent]);

  // Controles de Zoom
  const handleResetZoom = () => {
    const canvasEl = canvasRef.current;
    const rect2 = canvasEl ? canvasEl.getBoundingClientRect() : { width: 600, height: 500 };
    const displayWidth = rect2.width;
    const displayHeight = rect2.height;
    const fitZoom = Math.max(0.1, (displayWidth * 0.95) / canvasWidth);
    panRef.current = {
      x: displayWidth / 2 - (canvasWidth / 2) * fitZoom,
      y: displayHeight / 2 - (canvasHeight / 2) * fitZoom,
    };
    zoomRef.current = fitZoom;
    drawCanvas();
  };

  const handleZoom = (factor: number) => {
    zoomRef.current = Math.max(0.1, Math.min(zoomRef.current * factor, 5));
    drawCanvas();
  };

  // Evento Mousedown
  const handleMouseDown = (e: React.MouseEvent<HTMLCanvasElement>) => {
    e.preventDefault();
    const canvas = canvasRef.current;
    if (!canvas) return;
    
    const rect = canvas.getBoundingClientRect();
    const clientX = e.clientX - rect.left;
    const clientY = e.clientY - rect.top;
    
    const worldX = (clientX - panRef.current.x) / zoomRef.current;
    const worldY = (clientY - panRef.current.y) / zoomRef.current;
    
    // Detectar clique sobre nó
    let clickedNode: GraphNode | null = null;
    const activeNodes = simNodesRef.current;
    const visibleNodesCount = nodes.length;
    const scaleFactor = visibleNodesCount > 250 ? 0.40 
      : visibleNodesCount > 120 ? 0.60 
      : visibleNodesCount > 60 ? 0.80 
      : 1.0;
      
    const getNodeRadius = (role: GraphNode["role"]) => {
      let r = 16;
      switch (role) {
        case "presbyter": r = 22; break;
        case "deacon": r = 20; break;
        case "leader": r = 18; break;
        case "discipler": r = 18; break;
        case "child": r = 12; break;
        case "disciple":
        default:
          r = 16; break;
      }
      return r * scaleFactor;
    };

    for (const node of activeNodes) {
      const dx = worldX - node.x;
      const dy = worldY - node.y;
      const dist = Math.sqrt(dx * dx + dy * dy);
      const radius = getNodeRadius(node.role);
      if (dist <= radius + 5) {
        clickedNode = node;
        break;
      }
    }
    
    if (clickedNode) {
      clickedNodeIdRef.current = clickedNode.id;
      mouseDownPosRef.current = { x: e.clientX, y: e.clientY };
      hasDraggedRef.current = false;
    } else {
      isPanningRef.current = true;
      startPanRef.current = { x: e.clientX, y: e.clientY };
      mouseDownPosRef.current = { x: e.clientX, y: e.clientY };
      hasDraggedRef.current = false;
    }
  };

  // Evento Mousemove
  const handleMouseMove = (e: React.MouseEvent<HTMLCanvasElement>) => {
    const canvas = canvasRef.current;
    if (!canvas) return;
    
    const rect = canvas.getBoundingClientRect();
    const clientX = e.clientX - rect.left;
    const clientY = e.clientY - rect.top;
    
    if (mouseDownPosRef.current) {
      const travel = Math.sqrt(
        Math.pow(e.clientX - mouseDownPosRef.current.x, 2) + 
        Math.pow(e.clientY - mouseDownPosRef.current.y, 2)
      );
      if (travel > 4) {
        hasDraggedRef.current = true;
      }
    }
    
    if (isPanningRef.current) {
      panRef.current = {
        x: panRef.current.x + (e.clientX - startPanRef.current.x),
        y: panRef.current.y + (e.clientY - startPanRef.current.y),
      };
      startPanRef.current = { x: e.clientX, y: e.clientY };
      drawCanvas();
    } else {
      // Hover detection
      let newHoveredNode: GraphNode | null = null;
      const activeNodes = simNodesRef.current;
      const visibleNodesCount = nodes.length;
      const scaleFactor = visibleNodesCount > 250 ? 0.40 
        : visibleNodesCount > 120 ? 0.60 
        : visibleNodesCount > 60 ? 0.80 
        : 1.0;
        
      const getNodeRadius = (role: GraphNode["role"]) => {
        let r = 16;
        switch (role) {
          case "presbyter": r = 22; break;
          case "deacon": r = 20; break;
          case "leader": r = 18; break;
          case "discipler": r = 18; break;
          case "child": r = 12; break;
          case "disciple":
          default:
            r = 16; break;
        }
        return r * scaleFactor;
      };

      const worldX = (clientX - panRef.current.x) / zoomRef.current;
      const worldY = (clientY - panRef.current.y) / zoomRef.current;
      
      for (const node of activeNodes) {
        const dx = worldX - node.x;
        const dy = worldY - node.y;
        const dist = Math.sqrt(dx * dx + dy * dy);
        const radius = getNodeRadius(node.role);
        if (dist <= radius + 5) {
          newHoveredNode = node;
          break;
        }
      }
      
      if (newHoveredNode !== hoveredNodeRef.current) {
        hoveredNodeRef.current = newHoveredNode;
        canvas.style.cursor = newHoveredNode ? "pointer" : "grab";
        drawCanvas();
      }
    }
  };

  // Evento Mouseup ou Leave
  const handleMouseUpOrLeave = () => {
    if (clickedNodeIdRef.current) {
      if (!hasDraggedRef.current) {
        onSelectNode(clickedNodeIdRef.current === selectedNodeIdRef.current ? null : clickedNodeIdRef.current);
      }
      clickedNodeIdRef.current = null;
    }
    isPanningRef.current = false;
    mouseDownPosRef.current = null;
  };

  return (
    <div className="border border-zinc-200 dark:border-zinc-800 rounded-2xl bg-white dark:bg-zinc-900/60 backdrop-blur-sm shadow-md dark:shadow-[0_4px_20px_rgba(0,0,0,0.5)] overflow-hidden relative min-h-[500px] h-[600px] flex flex-col">
      {/* Legenda dos links */}
      <div className="absolute top-4 left-4 z-10 flex flex-wrap gap-2 max-w-[80%] pointer-events-none">
        <div className="bg-background/90 dark:bg-zinc-900/90 border border-border/50 backdrop-blur px-3 py-1.5 rounded-xl text-xs flex items-center gap-4 shadow-sm pointer-events-auto">
          <span className="font-semibold text-muted-foreground">Linhas:</span>
          <span className="flex items-center gap-1.5"><span className="w-4 h-0.5 bg-indigo-500 inline-block"></span> Discipulado</span>
          <span className="flex items-center gap-1.5"><span className="w-4 h-0.5 border-t border-dashed border-teal-500 inline-block"></span> Companheiros</span>
          <span className="flex items-center gap-1.5"><span className="w-4 h-0.5 border-t border-dotted border-amber-500 inline-block"></span> Irmãos do GC</span>
          <span className="flex items-center gap-1.5"><span className="w-4 h-0.5 bg-rose-500 inline-block"></span> Casamento</span>
        </div>
      </div>

      {/* Controles de Zoom */}
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

      {nodes.length === 0 && (
        <div className="absolute inset-0 flex flex-col items-center justify-center text-center p-8 bg-zinc-950/5">
          <Network className="h-12 w-12 text-zinc-400 mb-2" />
          <h4 className="text-lg font-semibold text-foreground">Nenhum discípulo coincide com os filtros</h4>
          <p className="text-sm text-muted-foreground mt-1">Ajuste os filtros de setor, GC ou papéis na barra lateral.</p>
        </div>
      )}

      <canvas
        ref={canvasRefCallback}
        className="w-full h-full cursor-grab active:cursor-grabbing select-none"
        onMouseDown={handleMouseDown}
        onMouseMove={handleMouseMove}
        onMouseUp={handleMouseUpOrLeave}
        onMouseLeave={handleMouseUpOrLeave}
      />
    </div>
  );
}
