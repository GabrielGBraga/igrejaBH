import { useEffect, useState, useMemo } from "react";
import { Plus, Search, Calendar } from "lucide-react";
import { toast } from "sonner";
import supabase from "@/lib/supabase";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Card, CardContent } from "@/components/ui/card";
import { Skeleton } from "@/components/ui/skeleton";
import { EventCard, type RetreatWithForm } from "@/components/events/EventCard";
import { CreateEditEventDialog } from "@/components/events/CreateEditEventDialog";
import type { Database } from "@/lib/database.types";

type Retreat = Database["public"]["Tables"]["retreats"]["Row"];

type RetreatQueryResult = Retreat & {
  forms: { name: string } | null;
  registrations: { id: string }[] | null;
};

interface FormOption {
  id: string;
  name: string;
}

export default function ManageEvents() {
  const [retreats, setRetreats] = useState<RetreatWithForm[]>([]);
  const [registrationCounts, setRegistrationCounts] = useState<Record<string, number>>({});
  const [forms, setForms] = useState<FormOption[]>([]);
  const [loading, setLoading] = useState(true);

  // Filter & Search states
  const [statusFilter, setStatusFilter] = useState<"todos" | "ativo" | "rascunho" | "encerrado">("todos");
  const [searchQuery, setSearchQuery] = useState("");

  // Dialog states
  const [isDialogOpen, setIsDialogOpen] = useState(false);
  const [editingRetreat, setEditingRetreat] = useState<Retreat | null>(null);

  useEffect(() => {
    fetchData();
  }, []);

  async function fetchData() {
    setLoading(true);
    try {
      // 1. Fetch retreats with associated forms and registrations
      const { data: retreatsData, error: retreatsError } = await supabase
        .from("retreats")
        .select(`
          *,
          forms (
            name
          ),
          registrations (
            id
          )
        `)
        .order("start_date", { ascending: true });

      if (retreatsError) throw retreatsError;

      const rawList = (retreatsData as unknown as RetreatQueryResult[]) || [];
      const counts: Record<string, number> = {};
      const formattedRetreats: RetreatWithForm[] = rawList.map((r) => {
        const count = r.registrations?.length || 0;
        counts[r.id] = count;
        return {
          ...r,
          registrations_count: count,
        };
      });

      setRetreats(formattedRetreats);
      setRegistrationCounts(counts);

      // 2. Fetch available forms for event creation
      const { data: formsData, error: formsError } = await supabase
        .from("forms")
        .select("id, name")
        .order("name", { ascending: true });

      if (formsError) throw formsError;
      setForms(formsData || []);
    } catch (err: unknown) {
      const msg = err instanceof Error ? err.message : "Erro ao carregar retiros";
      toast.error(msg);
    } finally {
      setLoading(false);
    }
  }

  const handleCreateClick = () => {
    setEditingRetreat(null);
    setIsDialogOpen(true);
  };

  const handleEditClick = (retreat: RetreatWithForm) => {
    setEditingRetreat(retreat);
    setIsDialogOpen(true);
  };

  const handleDeleteClick = async (retreatId: string) => {
    if (
      !confirm(
        "Tem certeza que deseja excluir permanentemente este retiro e todas as inscrições associadas?"
      )
    )
      return;

    try {
      const { error } = await supabase.from("retreats").delete().eq("id", retreatId);
      if (error) throw error;

      toast.success("Retiro excluído com sucesso!");
      fetchData();
    } catch (err: unknown) {
      const msg = err instanceof Error ? err.message : "Erro ao excluir retiro";
      toast.error(msg);
    }
  };

  const handleActivateClick = async (retreatId: string) => {
    try {
      const { error } = await supabase
        .from("retreats")
        .update({ status: "ativo" })
        .eq("id", retreatId);

      if (error) throw error;

      toast.success("Retiro ativado e publicado com sucesso!");
      fetchData();
    } catch (err: unknown) {
      const msg = err instanceof Error ? err.message : "Erro ao ativar retiro";
      toast.error(msg);
    }
  };

  // Filtered retreats based on status and search query
  const filteredRetreats = useMemo(() => {
    return retreats.filter((item) => {
      if (statusFilter !== "todos" && item.status !== statusFilter) {
        return false;
      }
      if (searchQuery.trim() !== "") {
        const query = searchQuery.toLowerCase();
        const title = (item.title || "").toLowerCase();
        const location = (item.location_text || "").toLowerCase();
        const desc = (item.description || "").toLowerCase();
        if (!title.includes(query) && !location.includes(query) && !desc.includes(query)) {
          return false;
        }
      }
      return true;
    });
  }, [retreats, statusFilter, searchQuery]);

  // Counts for status pills
  const countsByStatus = useMemo(() => {
    const total = retreats.length;
    const active = retreats.filter((r) => r.status === "ativo").length;
    const draft = retreats.filter((r) => r.status === "rascunho").length;
    const ended = retreats.filter((r) => r.status === "encerrado").length;
    return { total, active, draft, ended };
  }, [retreats]);

  return (
    <div className="space-y-6 max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8 w-full">
      {/* Top Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 border-b border-zinc-200 dark:border-zinc-800 pb-6">
        <div>
          <h1 className="text-2xl sm:text-3xl font-extrabold tracking-tight text-zinc-900 dark:text-zinc-50">
            Gestão de Eventos e Retiros
          </h1>
          <p className="text-sm text-zinc-500 dark:text-zinc-400 mt-1">
            Selecione um evento para gerenciar inscrições, pagamentos e alojamentos, ou cadastre um novo encontro.
          </p>
        </div>

        <Button
          onClick={handleCreateClick}
          className="min-h-[44px] h-11 px-5 rounded-xl bg-zinc-900 hover:bg-zinc-800 text-zinc-50 dark:bg-zinc-50 dark:hover:bg-zinc-200 dark:text-zinc-900 font-bold text-xs flex items-center gap-2 cursor-pointer shadow-sm self-start sm:self-auto shrink-0"
        >
          <Plus className="w-4 h-4" />
          <span>Novo Retiro</span>
        </Button>
      </div>

      {/* Toolbar: Status Tabs & Search */}
      <div className="flex flex-col md:flex-row items-stretch md:items-center justify-between gap-4">
        {/* Status Filter Tabs */}
        <div className="flex items-center gap-1.5 p-1 bg-zinc-100 dark:bg-zinc-800/60 rounded-xl overflow-x-auto">
          <button
            onClick={() => setStatusFilter("todos")}
            className={`min-h-[44px] px-3.5 py-1.5 rounded-lg text-xs font-bold transition-all cursor-pointer whitespace-nowrap ${
              statusFilter === "todos"
                ? "bg-white dark:bg-zinc-900 text-zinc-900 dark:text-zinc-50 shadow-xs"
                : "text-zinc-600 dark:text-zinc-400 hover:text-zinc-900 dark:hover:text-zinc-50"
            }`}
          >
            Todos ({countsByStatus.total})
          </button>
          <button
            onClick={() => setStatusFilter("ativo")}
            className={`min-h-[44px] px-3.5 py-1.5 rounded-lg text-xs font-bold transition-all cursor-pointer whitespace-nowrap ${
              statusFilter === "ativo"
                ? "bg-white dark:bg-zinc-900 text-emerald-600 dark:text-emerald-400 shadow-xs"
                : "text-zinc-600 dark:text-zinc-400 hover:text-zinc-900 dark:hover:text-zinc-50"
            }`}
          >
            Ativos ({countsByStatus.active})
          </button>
          <button
            onClick={() => setStatusFilter("rascunho")}
            className={`min-h-[44px] px-3.5 py-1.5 rounded-lg text-xs font-bold transition-all cursor-pointer whitespace-nowrap ${
              statusFilter === "rascunho"
                ? "bg-white dark:bg-zinc-900 text-amber-600 dark:text-amber-400 shadow-xs"
                : "text-zinc-600 dark:text-zinc-400 hover:text-zinc-900 dark:hover:text-zinc-50"
            }`}
          >
            Rascunhos ({countsByStatus.draft})
          </button>
          <button
            onClick={() => setStatusFilter("encerrado")}
            className={`min-h-[44px] px-3.5 py-1.5 rounded-lg text-xs font-bold transition-all cursor-pointer whitespace-nowrap ${
              statusFilter === "encerrado"
                ? "bg-white dark:bg-zinc-900 text-zinc-900 dark:text-zinc-50 shadow-xs"
                : "text-zinc-600 dark:text-zinc-400 hover:text-zinc-900 dark:hover:text-zinc-50"
            }`}
          >
            Encerrados ({countsByStatus.ended})
          </button>
        </div>

        {/* Search Field */}
        <div className="relative max-w-sm w-full">
          <Search className="absolute left-3.5 top-1/2 -translate-y-1/2 h-4 w-4 text-zinc-400" />
          <Input
            placeholder="Buscar evento por título ou local..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="pl-9 min-h-[44px] h-11 text-xs rounded-xl"
          />
        </div>
      </div>

      {/* Grid-based Content Area */}
      {loading ? (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {[1, 2, 3, 4, 5, 6].map((i) => (
            <Card key={i} className="rounded-xl border border-zinc-200 dark:border-zinc-800 p-5 space-y-4">
              <div className="flex justify-between">
                <Skeleton className="h-5 w-20 rounded-full" />
                <Skeleton className="h-5 w-16 rounded-full" />
              </div>
              <Skeleton className="h-6 w-3/4" />
              <Skeleton className="h-4 w-full" />
              <Skeleton className="h-16 w-full rounded-lg" />
              <Skeleton className="h-11 w-full rounded-lg" />
            </Card>
          ))}
        </div>
      ) : filteredRetreats.length === 0 ? (
        <Card className="border-dashed border-zinc-300 dark:border-zinc-700 bg-zinc-50/50 dark:bg-zinc-900/30 p-12 text-center rounded-2xl">
          <CardContent className="space-y-4 max-w-md mx-auto p-0">
            <div className="w-12 h-12 rounded-full bg-zinc-100 dark:bg-zinc-800 text-zinc-400 flex items-center justify-center mx-auto">
              <Calendar className="w-6 h-6" />
            </div>
            <div>
              <h3 className="text-base font-bold text-zinc-900 dark:text-zinc-50">
                Nenhum evento encontrado
              </h3>
              <p className="text-xs text-zinc-500 dark:text-zinc-400 mt-1">
                {searchQuery || statusFilter !== "todos"
                  ? "Tente ajustar os filtros ou o termo de busca para encontrar o encontro desejado."
                  : "Nenhum retiro cadastrado no momento. Clique no botão acima para criar o primeiro encontro da comunidade."}
              </p>
            </div>
            {!searchQuery && statusFilter === "todos" && (
              <Button
                onClick={handleCreateClick}
                className="min-h-[44px] h-11 px-5 rounded-lg bg-zinc-900 text-zinc-50 hover:bg-zinc-800 dark:bg-zinc-50 dark:text-zinc-900 dark:hover:bg-zinc-200 text-xs font-bold cursor-pointer"
              >
                <Plus className="w-4 h-4 mr-2" />
                Cadastrar Primeiro Retiro
              </Button>
            )}
          </CardContent>
        </Card>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {filteredRetreats.map((retreat) => (
            <EventCard
              key={retreat.id}
              retreat={retreat}
              registeredCount={registrationCounts[retreat.id] || 0}
              onEdit={handleEditClick}
              onDelete={handleDeleteClick}
              onActivate={handleActivateClick}
            />
          ))}
        </div>
      )}

      {/* Create / Edit Dialog */}
      <CreateEditEventDialog
        isOpen={isDialogOpen}
        onOpenChange={setIsDialogOpen}
        retreat={editingRetreat}
        forms={forms}
        onSuccess={fetchData}
      />
    </div>
  );
}
