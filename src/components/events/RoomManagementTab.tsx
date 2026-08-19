import { useState, useEffect } from "react";
import supabase from "@/lib/supabase";
import { 
  Bed, 
  Plus, 
  Trash2, 
  Edit, 
  UserX, 
  UserCheck,
  Loader2,
  Users,
  Search
} from "lucide-react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Badge } from "@/components/ui/badge";
import { 
  Dialog, 
  DialogContent, 
  DialogHeader, 
  DialogTitle, 
  DialogDescription,
  DialogFooter
} from "@/components/ui/dialog";
import { Field, FieldLabel } from "@/components/ui/field";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { toast } from "sonner";
import type { Database } from "@/lib/database.types";
import type { RegistrationWithDetails } from "./RegistrationDetailDialog";

export type RetreatRoom = Database["public"]["Tables"]["retreat_rooms"]["Row"];

interface RoomManagementTabProps {
  retreatId: string;
  registrations: RegistrationWithDetails[];
  onRefreshRegistrations: () => void;
}

export function RoomManagementTab({
  retreatId,
  registrations,
  onRefreshRegistrations,
}: RoomManagementTabProps) {
  const [rooms, setRooms] = useState<RetreatRoom[]>([]);
  const [loadingRooms, setLoadingRooms] = useState(true);

  // Modal State for Create/Edit Room
  const [isRoomDialogOpen, setIsRoomDialogOpen] = useState(false);
  const [editingRoom, setEditingRoom] = useState<RetreatRoom | null>(null);
  const [roomName, setRoomName] = useState("");
  const [genderType, setGenderType] = useState<string>("masculino");
  const [capacity, setCapacity] = useState<number>(4);
  const [roomNotes, setRoomNotes] = useState("");
  const [submittingRoom, setSubmittingRoom] = useState(false);

  // Modal State for Room Occupancy & Allocation Details
  const [selectedRoomForAllocation, setSelectedRoomForAllocation] = useState<RetreatRoom | null>(null);
  const [allocationSearchTerm, setAllocationSearchTerm] = useState("");

  useEffect(() => {
    if (retreatId) {
      fetchRooms();
    }
  }, [retreatId]);

  async function fetchRooms() {
    setLoadingRooms(true);
    try {
      const { data, error } = await supabase
        .from("retreat_rooms")
        .select("*")
        .eq("retreat_id", retreatId)
        .order("name", { ascending: true });

      if (error) throw error;
      setRooms(data || []);
    } catch (err: any) {
      console.error("Erro ao buscar quartos:", err);
      toast.error("Erro ao carregar quartos do evento.");
    } finally {
      setLoadingRooms(false);
    }
  }

  const handleOpenCreateRoom = () => {
    setEditingRoom(null);
    setRoomName("");
    setGenderType("masculino");
    setCapacity(4);
    setRoomNotes("");
    setIsRoomDialogOpen(true);
  };

  const handleOpenEditRoom = (room: RetreatRoom) => {
    setEditingRoom(room);
    setRoomName(room.name);
    setGenderType(room.gender_type || "masculino");
    setCapacity(room.capacity || 4);
    setRoomNotes(room.notes || "");
    setIsRoomDialogOpen(true);
  };

  const handleSaveRoom = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!roomName.trim()) {
      toast.error("O nome do quarto é obrigatório.");
      return;
    }

    setSubmittingRoom(true);
    const payload = {
      retreat_id: retreatId,
      name: roomName.trim(),
      gender_type: genderType,
      capacity: Number(capacity),
      notes: roomNotes.trim() || null,
    };

    try {
      if (editingRoom) {
        const { error } = await supabase
          .from("retreat_rooms")
          .update(payload)
          .eq("id", editingRoom.id);
        if (error) throw error;
        toast.success("Quarto atualizado com sucesso!");
      } else {
        const { error } = await supabase
          .from("retreat_rooms")
          .insert([payload]);
        if (error) throw error;
        toast.success("Quarto adicionado com sucesso!");
      }
      setIsRoomDialogOpen(false);
      fetchRooms();
    } catch (err: any) {
      toast.error("Erro ao salvar quarto: " + err.message);
    } finally {
      setSubmittingRoom(false);
    }
  };

  const handleDeleteRoom = async (roomId: string) => {
    if (!confirm("Tem certeza que deseja excluir este quarto? Os participantes alocados ficarão sem quarto.")) return;
    try {
      const { error } = await supabase
        .from("retreat_rooms")
        .delete()
        .eq("id", roomId);
      if (error) throw error;
      toast.success("Quarto excluído!");
      if (selectedRoomForAllocation?.id === roomId) {
        setSelectedRoomForAllocation(null);
      }
      fetchRooms();
      onRefreshRegistrations();
    } catch (err: any) {
      toast.error("Erro ao excluir quarto: " + err.message);
    }
  };

  const handleAssignParticipant = async (regId: string, roomId: string | null) => {
    try {
      const targetRoom = rooms.find(r => r.id === roomId);
      const { error } = await supabase
        .from("registrations")
        .update({ 
          room_id: roomId,
          room_allocation: targetRoom ? targetRoom.name : null
        })
        .eq("id", regId);

      if (error) throw error;
      toast.success("Alocação de quarto atualizada!");
      onRefreshRegistrations();
    } catch (err: any) {
      toast.error("Erro ao alocar quarto: " + err.message);
    }
  };

  // Helper to extract gender from registration (profile or custom_responses or guest_data)
  const getParticipantGender = (reg: RegistrationWithDetails): string => {
    const customResps = reg.custom_responses as Record<string, any> | null;
    const guestData = reg.guest_data as Record<string, any> | null;

    if (customResps) {
      for (const [key, val] of Object.entries(customResps)) {
        if (key.toLowerCase().includes("gênero") || key.toLowerCase().includes("genero") || key.toLowerCase().includes("sexo")) {
          const valStr = String(val).toLowerCase();
          if (valStr.includes("masculino") || valStr === "m") return "masculino";
          if (valStr.includes("feminino") || valStr === "f") return "feminino";
        }
      }
    }
    if (guestData?.gender) {
      const gStr = String(guestData.gender).toLowerCase();
      if (gStr.includes("masculino") || gStr === "m") return "masculino";
      if (gStr.includes("feminino") || gStr === "f") return "feminino";
    }
    return "indefinido";
  };

  // Unassigned registrations overall
  const unassignedRegistrations = registrations.filter(r => !r.room_id && !r.room_allocation);

  const genderBadgeColor = (type: string | null) => {
    switch (type) {
      case "masculino":
        return "bg-blue-500/15 text-blue-500 border-blue-500/30";
      case "feminino":
        return "bg-pink-500/15 text-pink-500 border-pink-500/30";
      case "suite":
        return "bg-amber-500/15 text-amber-500 border-amber-500/30";
      default:
        return "bg-zinc-500/15 text-zinc-500 border-zinc-500/30";
    }
  };

  const genderBadgeLabel = (type: string | null) => {
    switch (type) {
      case "masculino":
        return "Masculino";
      case "feminino":
        return "Feminino";
      case "suite":
        return "Suíte (Casais / Família)";
      default:
        return "Masculino";
    }
  };

  // Filter unallocated participants for the open room allocation modal
  const getEligibleUnallocatedForRoom = (room: RetreatRoom) => {
    return unassignedRegistrations.filter((reg) => {
      const name = reg.profiles?.full_name || (reg.guest_data as any)?.full_name || "";
      const searchMatch = name.toLowerCase().includes(allocationSearchTerm.toLowerCase());
      if (!searchMatch) return false;

      if (room.gender_type === "suite") return true; // Suíte accepts any unallocated
      
      const gender = getParticipantGender(reg);
      if (gender === "indefinido") return true; // Include if unspecified
      return gender === room.gender_type;
    });
  };

  return (
    <div className="space-y-6">
      {/* Top Header Controls */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 border-b border-border/40 pb-4">
        <div>
          <h3 className="text-lg font-bold text-foreground flex items-center gap-2">
            <Bed className="w-5 h-5 text-primary" />
            Divisão e Gestão de Quartos / Alojamentos
          </h3>
          <p className="text-xs text-muted-foreground mt-0.5">
            Cadastre os quartos deste evento e distribua os discípulos por gênero ou suíte.
          </p>
        </div>
        <Button 
          onClick={handleOpenCreateRoom}
          className="rounded-xl flex items-center gap-2 self-start sm:self-auto cursor-pointer"
        >
          <Plus className="w-4 h-4" /> Novo Quarto
        </Button>
      </div>

      {loadingRooms ? (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          {[1, 2, 3].map(i => (
            <div key={i} className="h-44 w-full rounded-2xl bg-muted animate-pulse" />
          ))}
        </div>
      ) : (
        <>
          {/* Unassigned Participants Banner */}
          {unassignedRegistrations.length > 0 && (
            <Card className="border border-amber-500/30 bg-amber-500/5">
              <CardContent className="p-4 flex flex-col md:flex-row items-start md:items-center justify-between gap-4">
                <div className="flex items-center gap-3">
                  <div className="h-10 w-10 rounded-full bg-amber-500/20 text-amber-600 dark:text-amber-400 flex items-center justify-center shrink-0">
                    <UserX className="w-5 h-5" />
                  </div>
                  <div>
                    <span className="font-bold text-foreground text-sm block">
                      {unassignedRegistrations.length} participante(s) sem quarto designado
                    </span>
                    <span className="text-xs text-muted-foreground block">
                      Clique em um dos quartos abaixo para gerenciar a ocupação e alocar inscritos por gênero.
                    </span>
                  </div>
                </div>
              </CardContent>
            </Card>
          )}

          {/* Rooms Grid */}
          {rooms.length === 0 ? (
            <Card className="border-dashed border-border/80 bg-card/20 py-12 text-center">
              <CardContent className="space-y-3">
                <Bed className="w-12 h-12 text-muted-foreground mx-auto" />
                <h4 className="font-bold text-foreground">Nenhum quarto cadastrado para este evento</h4>
                <p className="text-xs text-muted-foreground max-w-sm mx-auto">
                  Clique no botão "Novo Quarto" acima para definir a estrutura de alojamento (quartos masculinos, femininos ou suítes).
                </p>
              </CardContent>
            </Card>
          ) : (
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
              {rooms.map((room) => {
                const occupantRegs = registrations.filter(
                  r => r.room_id === room.id || r.room_allocation === room.name
                );
                const count = occupantRegs.length;
                const isFull = count >= room.capacity;
                const pct = Math.round((count / room.capacity) * 100);

                return (
                  <Card key={room.id} className="border border-border/60 bg-card/50 shadow-sm rounded-2xl overflow-hidden flex flex-col justify-between hover:border-primary/40 transition-all">
                    <CardHeader className="p-5 border-b border-border/30 bg-muted/20">
                      <div className="flex items-center justify-between gap-2">
                        <CardTitle className="text-base font-bold text-foreground truncate">
                          {room.name}
                        </CardTitle>
                        <div className="flex items-center gap-1 shrink-0">
                          <Button
                            variant="ghost"
                            size="sm"
                            className="h-8 w-8 p-0 cursor-pointer text-muted-foreground hover:text-foreground"
                            onClick={() => handleOpenEditRoom(room)}
                            title="Editar quarto"
                          >
                            <Edit className="w-3.5 h-3.5" />
                          </Button>
                          <Button
                            variant="ghost"
                            size="sm"
                            className="h-8 w-8 p-0 cursor-pointer text-red-500 hover:bg-red-500/10"
                            onClick={() => handleDeleteRoom(room.id)}
                            title="Excluir quarto"
                          >
                            <Trash2 className="w-3.5 h-3.5" />
                          </Button>
                        </div>
                      </div>

                      <div className="flex items-center justify-between gap-2 mt-2">
                        <Badge variant="outline" className={`text-[10px] uppercase font-bold px-2 py-0.5 rounded-full ${genderBadgeColor(room.gender_type)}`}>
                          {genderBadgeLabel(room.gender_type)}
                        </Badge>
                        <span className={`text-xs font-bold ${isFull ? "text-red-500" : "text-emerald-500"}`}>
                          {count} / {room.capacity} camas ({pct}%)
                        </span>
                      </div>

                      {/* Progress Bar */}
                      <div className="h-1.5 w-full bg-muted rounded-full overflow-hidden mt-2">
                        <div 
                          className={`h-full rounded-full transition-all duration-300 ${isFull ? "bg-red-500" : "bg-primary"}`}
                          style={{ width: `${Math.min(pct, 100)}%` }}
                        />
                      </div>
                    </CardHeader>

                    <CardContent className="p-5 space-y-3 flex-1 flex flex-col justify-between">
                      {/* Occupants Preview */}
                      <div className="space-y-2">
                        <span className="text-[11px] font-bold uppercase tracking-wider text-muted-foreground block">
                          Ocupantes ({count})
                        </span>
                        {occupantRegs.length === 0 ? (
                          <p className="text-xs italic text-muted-foreground py-2">Nenhum integrante alocado.</p>
                        ) : (
                          <div className="space-y-1.5 max-h-[120px] overflow-y-auto pr-1">
                            {occupantRegs.map(reg => {
                              const name = reg.profiles?.full_name || (reg.guest_data as any)?.full_name || "Sem nome";
                              return (
                                <div key={reg.id} className="flex items-center justify-between text-xs bg-muted/30 p-2 rounded-lg border border-border/30">
                                  <span className="font-semibold text-foreground truncate max-w-[160px]">
                                    {name}
                                  </span>
                                  <Button
                                    variant="ghost"
                                    size="sm"
                                    className="h-6 text-[10px] text-red-400 hover:text-red-600 hover:bg-transparent p-0 cursor-pointer"
                                    onClick={() => handleAssignParticipant(reg.id, null)}
                                  >
                                    Remover
                                  </Button>
                                </div>
                              );
                            })}
                          </div>
                        )}
                      </div>

                      {/* Manage & Allocate Button */}
                      <div className="pt-2 border-t border-border/20">
                        <Button
                          variant="secondary"
                          size="sm"
                          onClick={() => {
                            setSelectedRoomForAllocation(room);
                            setAllocationSearchTerm("");
                          }}
                          className="w-full text-xs font-bold rounded-lg flex items-center justify-center gap-1.5 cursor-pointer"
                        >
                          <Users className="w-3.5 h-3.5 text-primary" /> Gerenciar Alocação do Quarto
                        </Button>
                      </div>
                    </CardContent>
                  </Card>
                );
              })}
            </div>
          )}
        </>
      )}

      {/* Dialog para Gerenciar Alocação do Quarto (Lista de Ocupantes + Filtro por Gênero) */}
      {selectedRoomForAllocation && (
        <Dialog open={!!selectedRoomForAllocation} onOpenChange={(open) => !open && setSelectedRoomForAllocation(null)}>
          <DialogContent className="sm:max-w-2xl max-w-full rounded-2xl border border-border bg-card p-6 md:p-8 max-h-[90vh] overflow-y-auto custom-scrollbar">
            <DialogHeader className="border-b border-border/40 pb-4">
              <div className="flex items-center justify-between gap-2 flex-wrap">
                <DialogTitle className="text-xl font-bold text-foreground flex items-center gap-2">
                  <Bed className="w-5 h-5 text-primary" />
                  {selectedRoomForAllocation.name}
                </DialogTitle>
                <Badge variant="outline" className={`text-xs uppercase font-bold px-2.5 py-1 rounded-full ${genderBadgeColor(selectedRoomForAllocation.gender_type)}`}>
                  {genderBadgeLabel(selectedRoomForAllocation.gender_type)}
                </Badge>
              </div>
              <DialogDescription className="text-xs text-muted-foreground mt-1">
                Capacidade: {registrations.filter(r => r.room_id === selectedRoomForAllocation.id || r.room_allocation === selectedRoomForAllocation.name).length} / {selectedRoomForAllocation.capacity} vagas ocupadas.
              </DialogDescription>
            </DialogHeader>

            <div className="space-y-6 py-4">
              {/* Ocupantes Atuais */}
              <div className="space-y-3">
                <h4 className="text-xs font-bold uppercase tracking-wider text-muted-foreground flex items-center gap-1.5">
                  <UserCheck className="w-4 h-4 text-emerald-500" /> Integrantes Atualmente no Quarto
                </h4>
                {registrations.filter(r => r.room_id === selectedRoomForAllocation.id || r.room_allocation === selectedRoomForAllocation.name).length === 0 ? (
                  <p className="text-xs italic text-muted-foreground bg-muted/20 p-3 rounded-xl">Nenhum participante alocado neste quarto ainda.</p>
                ) : (
                  <div className="space-y-2 max-h-[160px] overflow-y-auto pr-1">
                    {registrations.filter(r => r.room_id === selectedRoomForAllocation.id || r.room_allocation === selectedRoomForAllocation.name).map(reg => {
                      const name = reg.profiles?.full_name || (reg.guest_data as any)?.full_name || "Sem nome";
                      const phone = reg.profiles?.phone || (reg.guest_data as any)?.phone || "S/T";
                      return (
                        <div key={reg.id} className="flex items-center justify-between text-xs bg-muted/30 border border-border/40 p-3 rounded-xl">
                          <div>
                            <span className="font-bold text-foreground block">{name}</span>
                            <span className="text-[11px] text-muted-foreground block">{phone}</span>
                          </div>
                          <Button
                            variant="outline"
                            size="sm"
                            onClick={() => handleAssignParticipant(reg.id, null)}
                            className="h-7 text-xs text-red-500 hover:bg-red-500/10 cursor-pointer"
                          >
                            Remover do Quarto
                          </Button>
                        </div>
                      );
                    })}
                  </div>
                )}
              </div>

              {/* Lista de Não Alocados Filtrada por Gênero */}
              <div className="space-y-3 border-t border-border/40 pt-4">
                <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-2">
                  <h4 className="text-xs font-bold uppercase tracking-wider text-muted-foreground flex items-center gap-1.5">
                    <UserX className="w-4 h-4 text-amber-500" /> Adicionar Participante Não Alocado
                  </h4>
                  <span className="text-[11px] text-muted-foreground italic">
                    Filtrado por: <strong className="text-foreground">{genderBadgeLabel(selectedRoomForAllocation.gender_type)}</strong>
                  </span>
                </div>

                <div className="relative">
                  <Search className="w-4 h-4 absolute left-3 top-2.5 text-muted-foreground" />
                  <Input
                    placeholder="Filtrar participante por nome..."
                    value={allocationSearchTerm}
                    onChange={(e) => setAllocationSearchTerm(e.target.value)}
                    className="pl-9 h-9 text-xs"
                  />
                </div>

                {getEligibleUnallocatedForRoom(selectedRoomForAllocation).length === 0 ? (
                  <p className="text-xs italic text-muted-foreground text-center py-4 bg-muted/10 rounded-xl">
                    Nenhum participante compatível sem quarto encontrado.
                  </p>
                ) : (
                  <div className="space-y-2 max-h-[220px] overflow-y-auto pr-1">
                    {getEligibleUnallocatedForRoom(selectedRoomForAllocation).map(reg => {
                      const name = reg.profiles?.full_name || (reg.guest_data as any)?.full_name || "Sem nome";
                      const phone = reg.profiles?.phone || (reg.guest_data as any)?.phone || "S/T";
                      const isFull = registrations.filter(r => r.room_id === selectedRoomForAllocation.id || r.room_allocation === selectedRoomForAllocation.name).length >= selectedRoomForAllocation.capacity;

                      return (
                        <div key={reg.id} className="flex items-center justify-between text-xs bg-card border border-border/50 p-3 rounded-xl">
                          <div>
                            <span className="font-bold text-foreground block">{name}</span>
                            <span className="text-[11px] text-muted-foreground block">{phone}</span>
                          </div>
                          <Button
                            size="sm"
                            disabled={isFull}
                            onClick={() => handleAssignParticipant(reg.id, selectedRoomForAllocation.id)}
                            className="h-7 text-xs rounded-lg cursor-pointer"
                          >
                            + Alocar Neste Quarto
                          </Button>
                        </div>
                      );
                    })}
                  </div>
                )}
              </div>
            </div>

            <DialogFooter>
              <Button type="button" variant="secondary" onClick={() => setSelectedRoomForAllocation(null)} className="cursor-pointer">
                Fechar
              </Button>
            </DialogFooter>
          </DialogContent>
        </Dialog>
      )}

      {/* Dialog para Criar / Editar Quarto */}
      <Dialog open={isRoomDialogOpen} onOpenChange={setIsRoomDialogOpen}>
        <DialogContent className="sm:max-w-md max-w-full rounded-2xl border border-border bg-card p-6">
          <DialogHeader>
            <DialogTitle className="text-lg font-bold text-foreground">
              {editingRoom ? "Editar Quarto" : "Cadastrar Novo Quarto"}
            </DialogTitle>
            <DialogDescription className="text-xs text-muted-foreground">
              Defina o nome, tipo (masculino, feminino ou suíte) e a capacidade de vagas do alojamento.
            </DialogDescription>
          </DialogHeader>

          <form onSubmit={handleSaveRoom} className="space-y-4 py-2">
            <Field>
              <FieldLabel htmlFor="roomName">Nome / Identificação do Quarto *</FieldLabel>
              <Input
                id="roomName"
                value={roomName}
                onChange={(e) => setRoomName(e.target.value)}
                placeholder="Ex: Chalé 01, Dormitório Masculino, Suíte 02"
                required
              />
            </Field>

            <div className="grid grid-cols-2 gap-4">
              <Field>
                <FieldLabel htmlFor="genderType">Tipo de Alojamento *</FieldLabel>
                <Select value={genderType} onValueChange={setGenderType}>
                  <SelectTrigger id="genderType">
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="masculino">Masculino</SelectItem>
                    <SelectItem value="feminino">Feminino</SelectItem>
                    <SelectItem value="suite">Suíte (Casais / Família)</SelectItem>
                  </SelectContent>
                </Select>
              </Field>

              <Field>
                <FieldLabel htmlFor="capacity">Capacidade (Camas) *</FieldLabel>
                <Input
                  id="capacity"
                  type="number"
                  min="1"
                  value={capacity}
                  onChange={(e) => setCapacity(Number(e.target.value))}
                  required
                />
              </Field>
            </div>

            <Field>
              <FieldLabel htmlFor="roomNotes">Observações (Opcional)</FieldLabel>
              <Input
                id="roomNotes"
                value={roomNotes}
                onChange={(e) => setRoomNotes(e.target.value)}
                placeholder="Ex: Tem banheiro interno, ar condicionado..."
              />
            </Field>

            <DialogFooter className="pt-2">
              <Button type="button" variant="outline" onClick={() => setIsRoomDialogOpen(false)}>
                Cancelar
              </Button>
              <Button type="submit" disabled={submittingRoom} className="cursor-pointer">
                {submittingRoom ? <Loader2 className="w-4 h-4 animate-spin" /> : "Salvar Quarto"}
              </Button>
            </DialogFooter>
          </form>
        </DialogContent>
      </Dialog>
    </div>
  );
}
