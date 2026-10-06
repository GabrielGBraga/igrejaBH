import { useState, useEffect } from "react";
import {
  Ticket,
  Plus,
  Copy,
  Check,
  Trash2,
  Share2,
  ExternalLink,
  RefreshCw,
  Search,
  CheckCircle2,
  Clock,
  Info,
  Sparkles,
  Percent,
} from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Badge } from "@/components/ui/badge";
import { Card } from "@/components/ui/card";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogDescription,
  DialogFooter,
} from "@/components/ui/dialog";
import { Field, FieldLabel } from "@/components/ui/field";
import { Slider } from "@/components/ui/slider";
import { toast } from "sonner";
import supabase from "@/lib/supabase";
import { isValidCPF } from "@/lib/forms";
import type { Database } from "@/lib/database.types";

type Retreat = Database["public"]["Tables"]["retreats"]["Row"];
type EventCoupon = Database["public"]["Tables"]["event_coupons"]["Row"];

interface EventCouponsTabProps {
  retreat: Retreat;
  eventId: string;
  formId?: string | null;
}

export function EventCouponsTab({
  retreat,
  eventId,
  formId,
}: EventCouponsTabProps) {
  const [coupons, setCoupons] = useState<EventCoupon[]>([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState("");
  const [copiedCode, setCopiedCode] = useState<string | null>(null);
  const [copiedLink, setCopiedLink] = useState<string | null>(null);

  // Dialog State
  const [isCreateOpen, setIsCreateOpen] = useState(false);
  const [newCode, setNewCode] = useState("");
  const [newDiscountPercent, setNewDiscountPercent] = useState<number>(100);
  const [newCpf, setNewCpf] = useState("");
  const [newNotes, setNewNotes] = useState("");
  const [creating, setCreating] = useState(false);

  // CPF Formatters
  const formatCpfInput = (val: string) => {
    const digits = val.replace(/\D/g, "").slice(0, 11);
    if (digits.length <= 3) return digits;
    if (digits.length <= 6) return `${digits.slice(0, 3)}.${digits.slice(3)}`;
    if (digits.length <= 9) return `${digits.slice(0, 3)}.${digits.slice(3, 6)}.${digits.slice(6)}`;
    return `${digits.slice(0, 3)}.${digits.slice(3, 6)}.${digits.slice(6, 9)}-${digits.slice(9)}`;
  };

  const formatCpfDisplay = (cpfVal?: string | null) => {
    if (!cpfVal) return "—";
    const digits = cpfVal.replace(/\D/g, "");
    if (digits.length !== 11) return cpfVal;
    return `${digits.slice(0, 3)}.${digits.slice(3, 6)}.${digits.slice(6, 9)}-${digits.slice(9)}`;
  };

  // Random Code Generator (Format: ISENTO-XXXX for 100%, DESC-XXXX for <100%)
  const generateRandomCode = (discount: number = 100) => {
    const chars = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";
    let randomPart = "";
    for (let i = 0; i < 4; i++) {
      randomPart += chars.charAt(Math.floor(Math.random() * chars.length));
    }
    const prefix = discount === 100 ? "ISENTO" : "DESC";
    return `${prefix}-${randomPart}`;
  };

  const openCreateDialog = () => {
    setNewDiscountPercent(100);
    setNewCode(generateRandomCode(100));
    setNewCpf("");
    setNewNotes("");
    setIsCreateOpen(true);
  };

  // Fetch Coupons
  const fetchCoupons = async () => {
    try {
      setLoading(true);
      const { data, error } = await supabase
        .from("event_coupons")
        .select("*")
        .eq("retreat_id", eventId)
        .order("created_at", { ascending: false });

      if (error) throw error;
      setCoupons(data || []);
    } catch (err: any) {
      console.error("Error fetching coupons:", err);
      toast.error("Erro ao carregar códigos de isenção: " + err.message);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchCoupons();
  }, [eventId]);

  // Create Coupon
  const handleCreateCoupon = async () => {
    if (!newCode.trim()) {
      toast.error("O código não pode estar vazio.");
      return;
    }

    if (!newDiscountPercent || newDiscountPercent < 1 || newDiscountPercent > 100) {
      toast.error("O percentual de desconto deve ser entre 1% e 100%.");
      return;
    }

    const cleanCpf = newCpf.replace(/\D/g, "");
    if (!cleanCpf) {
      toast.error("Informe o CPF do beneficiário para vincular ao código.");
      return;
    }
    if (cleanCpf.length !== 11 || !isValidCPF(cleanCpf)) {
      toast.error("CPF do beneficiário inválido. Digite um número de CPF válido com dígitos verificadores corretos.");
      return;
    }

    try {
      setCreating(true);
      const {
        data: { user },
      } = await supabase.auth.getUser();

      const { data, error } = await supabase
        .from("event_coupons")
        .insert({
          code: newCode.trim().toUpperCase(),
          retreat_id: eventId,
          form_id: formId || null,
          cpf: cleanCpf,
          notes: newNotes.trim() || null,
          discount_percent: newDiscountPercent,
          is_used: false,
          created_by: user?.id || null,
        })
        .select()
        .single();

      if (error) {
        if (error.code === "23505") {
          toast.error("Este código já existe. Gere um código diferente.");
          return;
        }
        throw error;
      }

      const discountLabel = data.discount_percent === 100 ? "100% isenção" : `${data.discount_percent}% de desconto`;
      toast.success(`Código ${data.code} (${discountLabel}) vinculado ao CPF com sucesso!`);
      setIsCreateOpen(false);
      fetchCoupons();
    } catch (err: any) {
      console.error("Error creating coupon:", err);
      toast.error("Erro ao gerar código: " + err.message);
    } finally {
      setCreating(false);
    }
  };

  // Delete Coupon
  const handleDeleteCoupon = async (couponId: string, code: string) => {
    if (!window.confirm(`Deseja realmente excluir o código ${code}?`)) return;

    try {
      const { error } = await supabase
        .from("event_coupons")
        .delete()
        .eq("id", couponId);

      if (error) throw error;
      toast.success("Código excluído com sucesso.");
      setCoupons((prev) => prev.filter((c) => c.id !== couponId));
    } catch (err: any) {
      console.error("Error deleting coupon:", err);
      toast.error("Erro ao excluir código: " + err.message);
    }
  };

  // Copy Code to Clipboard
  const handleCopyCode = (code: string) => {
    navigator.clipboard.writeText(code);
    setCopiedCode(code);
    toast.success(`Código ${code} copiado!`);
    setTimeout(() => setCopiedCode(null), 2500);
  };

  // Copy Direct Link to Clipboard
  const getDirectLink = (code: string) => {
    if (!formId) return "";
    return `${window.location.origin}/formularios/responder/${encodeURIComponent(formId)}?cupom=${encodeURIComponent(code)}`;
  };

  const handleCopyLink = (code: string) => {
    const link = getDirectLink(code);
    if (!link) {
      toast.error("Este evento ainda não possui um formulário vinculado.");
      return;
    }
    navigator.clipboard.writeText(link);
    setCopiedLink(code);
    toast.success("Link com código de isenção copiado!");
    setTimeout(() => setCopiedLink(null), 2500);
  };

  // Share via WhatsApp
  const handleShareWhatsApp = (code: string, note?: string | null) => {
    const link = getDirectLink(code);
    const text = `Graça e paz!${note ? ` Irmão(ã) ${note},` : ""} Segue o link com código de isenção para a sua inscrição no encontro *${retreat.title}*:\n\n${link || `Utilize o código: *${code}*`}\n\nDeus te abençoe!`;
    const url = `https://wa.me/?text=${encodeURIComponent(text)}`;
    window.open(url, "_blank");
  };

  // Filtered list
  const filteredCoupons = coupons.filter((c) => {
    const term = searchTerm.toLowerCase();
    return (
      c.code.toLowerCase().includes(term) ||
      (c.notes && c.notes.toLowerCase().includes(term)) ||
      (c.used_by_name && c.used_by_name.toLowerCase().includes(term)) ||
      (c.used_by_email && c.used_by_email.toLowerCase().includes(term))
    );
  });

  const totalCoupons = coupons.length;
  const availableCoupons = coupons.filter((c) => !c.is_used).length;
  const usedCoupons = coupons.filter((c) => c.is_used).length;

  return (
    <div className="space-y-6">
      {/* Free Event Banner Notice */}
      {retreat.has_payment === false && (
        <div className="flex items-start gap-3 rounded-xl border border-emerald-500/20 bg-emerald-500/10 p-4 text-emerald-800 dark:text-emerald-300">
          <Info className="h-5 w-5 shrink-0 mt-0.5 text-emerald-600 dark:text-emerald-400" />
          <div className="text-xs sm:text-sm">
            <p className="font-bold">Este evento está configurado como Gratuito (Sem Cobrança).</p>
            <p className="mt-0.5 text-emerald-700/90 dark:text-emerald-300/80">
              Todos os inscritos já são isentos automaticamente e não visualizam nenhuma etapa de pagamento. Códigos de isenção são necessários apenas para eventos que possuem cobrança de inscrição.
            </p>
          </div>
        </div>
      )}

      {/* Header and Action Bar */}
      <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
        <div>
          <h2 className="text-lg font-bold text-foreground flex items-center gap-2">
            <Ticket className="w-5 h-5 text-primary" />
            Códigos de Isenção de Pagamento
          </h2>
          <p className="text-xs text-muted-foreground mt-0.5">
            Gere códigos exclusivos de uso único para pessoas isentas de pagamento (apoio diaconal, voluntários, convidados).
          </p>
        </div>

        <Button
          onClick={openCreateDialog}
          className="min-h-[44px] px-4 rounded-lg bg-primary text-primary-foreground font-semibold shadow-sm hover:bg-primary/90 cursor-pointer w-full sm:w-auto flex items-center justify-center gap-2"
        >
          <Plus className="w-4 h-4" />
          <span>Gerar Novo Código</span>
        </Button>
      </div>

      {/* KPI Stats */}
      <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
        <Card className="rounded-xl border-border bg-card/60 shadow-sm p-4">
          <div className="flex items-center justify-between">
            <span className="text-xs font-medium text-muted-foreground">Total de Códigos</span>
            <Ticket className="w-4 h-4 text-muted-foreground" />
          </div>
          <p className="text-2xl font-extrabold text-foreground mt-2">{totalCoupons}</p>
        </Card>

        <Card className="rounded-xl border-border bg-card/60 shadow-sm p-4">
          <div className="flex items-center justify-between">
            <span className="text-xs font-medium text-emerald-600 dark:text-emerald-400">Disponíveis</span>
            <CheckCircle2 className="w-4 h-4 text-emerald-500" />
          </div>
          <p className="text-2xl font-extrabold text-emerald-600 dark:text-emerald-400 mt-2">
            {availableCoupons}
          </p>
        </Card>

        <Card className="rounded-xl border-border bg-card/60 shadow-sm p-4">
          <div className="flex items-center justify-between">
            <span className="text-xs font-medium text-zinc-500">Utilizados</span>
            <Clock className="w-4 h-4 text-zinc-400" />
          </div>
          <p className="text-2xl font-extrabold text-zinc-600 dark:text-zinc-400 mt-2">{usedCoupons}</p>
        </Card>
      </div>

      {/* Search and Filters */}
      <div className="flex flex-col sm:flex-row gap-3 items-center justify-between">
        <div className="relative w-full sm:max-w-md">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-muted-foreground" />
          <Input
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            placeholder="Buscar por código, beneficiário ou e-mail..."
            className="pl-9 min-h-[44px] rounded-lg"
          />
        </div>

        <Button
          variant="outline"
          size="sm"
          onClick={fetchCoupons}
          className="min-h-[44px] px-3 rounded-lg border-border text-xs flex items-center gap-1.5 cursor-pointer w-full sm:w-auto"
        >
          <RefreshCw className={`w-3.5 h-3.5 ${loading ? "animate-spin" : ""}`} />
          <span>Atualizar</span>
        </Button>
      </div>

      {/* Coupons List */}
      {loading ? (
        <div className="flex flex-col items-center justify-center p-12 text-center">
          <RefreshCw className="w-8 h-8 animate-spin text-primary mb-3" />
          <p className="text-sm font-medium text-muted-foreground">Carregando códigos...</p>
        </div>
      ) : filteredCoupons.length === 0 ? (
        <Card className="rounded-xl border border-dashed border-border p-12 text-center">
          <Ticket className="w-12 h-12 text-muted-foreground/40 mx-auto mb-3" />
          <h3 className="text-sm font-bold text-foreground">Nenhum código encontrado</h3>
          <p className="text-xs text-muted-foreground mt-1 max-w-sm mx-auto">
            {searchTerm
              ? "Nenhum código corresponde aos termos de busca digitados."
              : "Nenhum código de isenção foi gerado para este encontro ainda."}
          </p>
          {!searchTerm && (
            <Button
              onClick={openCreateDialog}
              variant="outline"
              size="sm"
              className="mt-4 min-h-[44px] rounded-lg cursor-pointer"
            >
              <Plus className="w-4 h-4 mr-1.5" />
              Gerar Primeiro Código
            </Button>
          )}
        </Card>
      ) : (
        <div className="space-y-3">
          {/* Desktop Table View */}
          <div className="hidden md:block overflow-hidden rounded-xl border border-border bg-card shadow-sm">
            <div className="overflow-x-auto">
              <table className="w-full text-left text-xs">
                <thead>
                  <tr className="border-b border-border/80 bg-muted/50 font-bold uppercase tracking-wider text-muted-foreground">
                    <th className="p-3.5">Código</th>
                    <th className="p-3.5">Desconto</th>
                    <th className="p-3.5">CPF Vinculado</th>
                    <th className="p-3.5">Beneficiário / Nota</th>
                    <th className="p-3.5">Status</th>
                    <th className="p-3.5">Utilizado Por</th>
                    <th className="p-3.5">Data Criação</th>
                    <th className="p-3.5 text-right">Ações</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-border/40 font-medium">
                  {filteredCoupons.map((coupon) => (
                    <tr
                      key={coupon.id}
                      className="hover:bg-muted/20 transition-colors"
                    >
                      <td className="p-3.5">
                        <div className="flex items-center gap-2">
                          <code className="rounded bg-muted px-2 py-1 font-mono text-xs font-bold text-foreground tracking-wider">
                            {coupon.code}
                          </code>
                          <button
                            type="button"
                            onClick={() => handleCopyCode(coupon.code)}
                            className="p-1 rounded text-muted-foreground hover:text-foreground cursor-pointer min-h-[32px] min-w-[32px] flex items-center justify-center"
                            title="Copiar código"
                            aria-label={`Copiar código ${coupon.code}`}
                          >
                            {copiedCode === coupon.code ? (
                              <Check className="w-3.5 h-3.5 text-emerald-500" />
                            ) : (
                              <Copy className="w-3.5 h-3.5" />
                            )}
                          </button>
                        </div>
                      </td>

                      <td className="p-3.5">
                        {(coupon.discount_percent ?? 100) === 100 ? (
                          <Badge
                            variant="outline"
                            className="bg-emerald-500/10 text-emerald-600 dark:text-emerald-400 border-emerald-500/30 text-[10px] font-bold"
                          >
                            100% Isenção
                          </Badge>
                        ) : (
                          <Badge
                            variant="outline"
                            className="bg-blue-500/10 text-blue-600 dark:text-blue-400 border-blue-500/30 text-[10px] font-bold"
                          >
                            {coupon.discount_percent}% OFF
                          </Badge>
                        )}
                      </td>

                      <td className="p-3.5">
                        <span className="font-mono text-xs font-semibold text-foreground">
                          {formatCpfDisplay(coupon.cpf)}
                        </span>
                      </td>

                      <td className="p-3.5 text-muted-foreground max-w-[200px] truncate">
                        {coupon.notes || <span className="italic text-muted-foreground/60">—</span>}
                      </td>

                      <td className="p-3.5">
                        {coupon.is_used ? (
                          <Badge
                            variant="outline"
                            className="bg-zinc-500/10 text-zinc-600 dark:text-zinc-400 border-zinc-500/30 text-[10px] font-bold"
                          >
                            Utilizado
                          </Badge>
                        ) : (
                          <Badge
                            variant="outline"
                            className="bg-emerald-500/10 text-emerald-600 dark:text-emerald-400 border-emerald-500/30 text-[10px] font-bold"
                          >
                            Disponível
                          </Badge>
                        )}
                      </td>

                      <td className="p-3.5">
                        {coupon.is_used ? (
                          <div className="space-y-0.5">
                            <p className="font-semibold text-foreground text-xs">
                              {coupon.used_by_name || "Nome não informado"}
                            </p>
                            {coupon.used_by_email && (
                              <p className="text-[11px] text-muted-foreground">
                                {coupon.used_by_email}
                              </p>
                            )}
                            {coupon.used_at && (
                              <p className="text-[10px] text-muted-foreground/70">
                                {new Date(coupon.used_at).toLocaleDateString("pt-BR", {
                                  day: "2-digit",
                                  month: "2-digit",
                                  year: "numeric",
                                  hour: "2-digit",
                                  minute: "2-digit",
                                })}
                              </p>
                            )}
                          </div>
                        ) : (
                          <span className="text-muted-foreground/60 italic">—</span>
                        )}
                      </td>

                      <td className="p-3.5 text-muted-foreground text-[11px]">
                        {new Date(coupon.created_at).toLocaleDateString("pt-BR", {
                          day: "2-digit",
                          month: "2-digit",
                          year: "numeric",
                        })}
                      </td>

                      <td className="p-3.5 text-right">
                        <div className="flex items-center justify-end gap-1.5">
                          {formId && !coupon.is_used && (
                            <>
                              <Button
                                size="sm"
                                variant="ghost"
                                onClick={() => handleCopyLink(coupon.code)}
                                className="min-h-[44px] min-w-[44px] px-2 text-xs cursor-pointer text-muted-foreground hover:text-foreground"
                                title="Copiar link com isenção"
                              >
                                {copiedLink === coupon.code ? (
                                  <Check className="w-4 h-4 text-emerald-500" />
                                ) : (
                                  <ExternalLink className="w-4 h-4" />
                                )}
                              </Button>

                              <Button
                                size="sm"
                                variant="ghost"
                                onClick={() => handleShareWhatsApp(coupon.code, coupon.notes)}
                                className="min-h-[44px] min-w-[44px] px-2 text-xs cursor-pointer text-emerald-600 hover:text-emerald-700 hover:bg-emerald-500/10"
                                title="Compartilhar via WhatsApp"
                              >
                                <Share2 className="w-4 h-4" />
                              </Button>
                            </>
                          )}

                          {!coupon.is_used && (
                            <Button
                              size="sm"
                              variant="ghost"
                              onClick={() => handleDeleteCoupon(coupon.id, coupon.code)}
                              className="min-h-[44px] min-w-[44px] px-2 text-xs cursor-pointer text-red-600 hover:text-red-700 hover:bg-red-500/10"
                              title="Excluir código"
                            >
                              <Trash2 className="w-4 h-4" />
                            </Button>
                          )}
                        </div>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>

          {/* Mobile Card View */}
          <div className="md:hidden space-y-3">
            {filteredCoupons.map((coupon) => (
              <Card
                key={coupon.id}
                className="rounded-xl border-border bg-card p-4 shadow-sm space-y-3"
              >
                <div className="flex items-start justify-between gap-2">
                  <div className="space-y-1">
                    <div className="flex items-center gap-2 flex-wrap">
                      <code className="rounded bg-muted px-2 py-1 font-mono text-sm font-bold text-foreground tracking-wider">
                        {coupon.code}
                      </code>
                      {(coupon.discount_percent ?? 100) === 100 ? (
                        <Badge
                          variant="outline"
                          className="bg-emerald-500/10 text-emerald-600 dark:text-emerald-400 border-emerald-500/30 text-[10px] font-bold"
                        >
                          100% Isenção
                        </Badge>
                      ) : (
                        <Badge
                          variant="outline"
                          className="bg-blue-500/10 text-blue-600 dark:text-blue-400 border-blue-500/30 text-[10px] font-bold"
                        >
                          {coupon.discount_percent}% OFF
                        </Badge>
                      )}
                      <button
                        type="button"
                        onClick={() => handleCopyCode(coupon.code)}
                        className="p-1 rounded text-muted-foreground hover:text-foreground min-h-[44px] min-w-[44px] flex items-center justify-center cursor-pointer"
                        title="Copiar código"
                      >
                        {copiedCode === coupon.code ? (
                          <Check className="w-4 h-4 text-emerald-500" />
                        ) : (
                          <Copy className="w-4 h-4" />
                        )}
                      </button>
                    </div>

                    <p className="text-xs text-muted-foreground">
                      CPF: <span className="font-mono font-bold text-foreground">{formatCpfDisplay(coupon.cpf)}</span>
                    </p>
                    {coupon.notes && (
                      <p className="text-xs text-muted-foreground">{coupon.notes}</p>
                    )}
                  </div>

                  <div>
                    {coupon.is_used ? (
                      <Badge
                        variant="outline"
                        className="bg-zinc-500/10 text-zinc-600 dark:text-zinc-400 border-zinc-500/30 text-[10px] font-bold"
                      >
                        Utilizado
                      </Badge>
                    ) : (
                      <Badge
                        variant="outline"
                        className="bg-emerald-500/10 text-emerald-600 dark:text-emerald-400 border-emerald-500/30 text-[10px] font-bold"
                      >
                        Disponível
                      </Badge>
                    )}
                  </div>
                </div>

                {coupon.is_used && (
                  <div className="rounded-lg bg-muted/40 p-2.5 text-xs space-y-0.5 border border-border/40">
                    <span className="text-[10px] font-bold text-muted-foreground uppercase">
                      Utilizado Por:
                    </span>
                    <p className="font-semibold text-foreground">
                      {coupon.used_by_name || "Nome não informado"}
                    </p>
                    {coupon.used_by_email && (
                      <p className="text-muted-foreground">{coupon.used_by_email}</p>
                    )}
                    {coupon.used_at && (
                      <p className="text-[10px] text-muted-foreground/80">
                        Em: {new Date(coupon.used_at).toLocaleString("pt-BR")}
                      </p>
                    )}
                  </div>
                )}

                <div className="flex items-center justify-between pt-1 border-t border-border/40">
                  <span className="text-[11px] text-muted-foreground">
                    Criado: {new Date(coupon.created_at).toLocaleDateString("pt-BR")}
                  </span>

                  <div className="flex items-center gap-1">
                    {formId && !coupon.is_used && (
                      <>
                        <Button
                          size="sm"
                          variant="ghost"
                          onClick={() => handleCopyLink(coupon.code)}
                          className="min-h-[44px] min-w-[44px] p-2 text-xs cursor-pointer text-muted-foreground"
                          title="Copiar Link"
                        >
                          <ExternalLink className="w-4 h-4" />
                        </Button>

                        <Button
                          size="sm"
                          variant="ghost"
                          onClick={() => handleShareWhatsApp(coupon.code, coupon.notes)}
                          className="min-h-[44px] min-w-[44px] p-2 text-xs cursor-pointer text-emerald-600"
                          title="WhatsApp"
                        >
                          <Share2 className="w-4 h-4" />
                        </Button>
                      </>
                    )}

                    {!coupon.is_used && (
                      <Button
                        size="sm"
                        variant="ghost"
                        onClick={() => handleDeleteCoupon(coupon.id, coupon.code)}
                        className="min-h-[44px] min-w-[44px] p-2 text-xs cursor-pointer text-red-600"
                        title="Excluir"
                      >
                        <Trash2 className="w-4 h-4" />
                      </Button>
                    )}
                  </div>
                </div>
              </Card>
            ))}
          </div>
        </div>
      )}

      {/* CREATE COUPON DIALOG */}
      <Dialog open={isCreateOpen} onOpenChange={setIsCreateOpen}>
        <DialogContent className="sm:max-w-2xl max-w-[calc(100vw-2rem)] rounded-2xl border border-border bg-card p-6 md:p-8 max-h-[90vh] overflow-y-auto">
          <DialogHeader className="space-y-2 pb-2">
            <div className="flex items-start gap-3">
              <div className="w-10 h-10 rounded-xl bg-primary/10 text-primary flex items-center justify-center shrink-0 mt-0.5">
                <Ticket className="w-5 h-5" />
              </div>
              <div className="space-y-1">
                <div className="flex items-center gap-2 flex-wrap">
                  <DialogTitle className="text-lg md:text-xl font-bold">
                    Gerar Código de Desconto / Isenção
                  </DialogTitle>
                  {retreat.title && (
                    <Badge variant="outline" className="hidden sm:inline-flex text-xs font-normal">
                      {retreat.title}
                    </Badge>
                  )}
                </div>
                <DialogDescription className="text-xs text-muted-foreground leading-relaxed">
                  Crie um cupom exclusivo atrelado ao participante para abatimento percentual ou isenção integral da inscrição.
                </DialogDescription>
              </div>
            </div>
          </DialogHeader>

          <div className="space-y-5 py-3">
            {/* SECTION 1: DISCOUNT PERCENTAGE & SLIDER */}
            <Field className="space-y-3">
              <div className="flex items-center justify-between gap-2">
                <FieldLabel htmlFor="coupon-discount" className="text-sm font-semibold flex items-center gap-1">
                  Percentual de Desconto (%) <span className="text-destructive">*</span>
                </FieldLabel>
                <div className="flex items-center gap-1.5 shrink-0">
                  <Input
                    id="coupon-discount"
                    type="number"
                    min={1}
                    max={100}
                    value={newDiscountPercent}
                    onChange={(e) => {
                      const val = Math.min(100, Math.max(1, Number(e.target.value) || 1));
                      setNewDiscountPercent(val);
                      if (newCode.startsWith("ISENTO-") || newCode.startsWith("DESC-")) {
                        setNewCode(generateRandomCode(val));
                      }
                    }}
                    className="w-20 text-center font-bold text-sm min-h-[44px] h-11"
                  />
                  <span className="text-sm font-bold text-muted-foreground">%</span>
                </div>
              </div>

              <div className="space-y-2 pt-1">
                <Slider
                  value={[newDiscountPercent]}
                  min={1}
                  max={100}
                  step={1}
                  onValueChange={(vals) => {
                    const val = vals[0] || 1;
                    setNewDiscountPercent(val);
                    if (newCode.startsWith("ISENTO-") || newCode.startsWith("DESC-")) {
                      setNewCode(generateRandomCode(val));
                    }
                  }}
                  className="w-full py-2 cursor-pointer min-h-[44px]"
                  aria-label="Percentual de desconto"
                />

                {/* Quick Preset Buttons */}
                <div className="grid grid-cols-2 sm:grid-cols-5 gap-2 pt-1">
                  {[
                    { val: 10, label: "10%" },
                    { val: 25, label: "25%" },
                    { val: 50, label: "50% (Meia)" },
                    { val: 75, label: "75%" },
                    { val: 100, label: "100% (Isenção)" },
                  ].map((preset) => {
                    const isActive = newDiscountPercent === preset.val;
                    return (
                      <Button
                        key={preset.val}
                        type="button"
                        variant={isActive ? "default" : "outline"}
                        size="sm"
                        onClick={() => {
                          setNewDiscountPercent(preset.val);
                          if (newCode.startsWith("ISENTO-") || newCode.startsWith("DESC-")) {
                            setNewCode(generateRandomCode(preset.val));
                          }
                        }}
                        className={`min-h-[40px] text-xs font-semibold cursor-pointer transition-all ${
                          isActive
                            ? "bg-primary text-primary-foreground shadow-sm"
                            : "bg-muted/30 hover:bg-muted text-muted-foreground hover:text-foreground"
                        } ${preset.val === 100 ? "col-span-2 sm:col-span-1" : ""}`}
                      >
                        {preset.label}
                      </Button>
                    );
                  })}
                </div>
              </div>
            </Field>

            {/* SECTION 2: DYNAMIC PREVIEW BANNER */}
            {newDiscountPercent === 100 ? (
              <div className="p-4 rounded-xl border border-emerald-500/20 bg-emerald-500/10 text-emerald-950 dark:text-emerald-200 flex items-start gap-3">
                <div className="w-8 h-8 rounded-lg bg-emerald-500/20 text-emerald-600 dark:text-emerald-400 flex items-center justify-center shrink-0 mt-0.5">
                  <Sparkles className="w-4 h-4" />
                </div>
                <div className="space-y-1 text-sm">
                  <div className="flex items-center gap-2 flex-wrap">
                    <Badge className="bg-emerald-600 hover:bg-emerald-600 text-white text-[11px] font-bold uppercase tracking-wider">
                      Isenção Total (100%)
                    </Badge>
                    <span className="text-xs font-semibold text-emerald-700 dark:text-emerald-300">
                      Inscrição Gratuita
                    </span>
                  </div>
                  <p className="text-xs text-emerald-800 dark:text-emerald-200/90 leading-relaxed">
                    O participante não passará pela etapa de pagamento via PIX/Cartão. Ao validar o código no formulário de inscrição, sua confirmação será imediata com custo <strong className="font-bold">R$ 0,00</strong>.
                  </p>
                </div>
              </div>
            ) : (
              <div className="p-4 rounded-xl border border-blue-500/20 bg-blue-500/10 text-foreground dark:text-blue-200 flex items-start gap-3">
                <div className="w-8 h-8 rounded-lg bg-blue-500/20 text-blue-600 dark:text-blue-400 flex items-center justify-center shrink-0 mt-0.5">
                  <Percent className="w-4 h-4" />
                </div>
                <div className="space-y-1 text-sm">
                  <div className="flex items-center gap-2 flex-wrap">
                    <Badge variant="secondary" className="text-[11px] font-bold uppercase tracking-wider">
                      Desconto Parcial ({newDiscountPercent}%)
                    </Badge>
                    {retreat.price && retreat.price > 0 && (
                      <span className="text-xs font-semibold text-muted-foreground">
                        Preço base: R$ {retreat.price.toFixed(2).replace(".", ",")}
                      </span>
                    )}
                  </div>
                  <p className="text-xs text-muted-foreground dark:text-blue-200/90 leading-relaxed">
                    {retreat.price && retreat.price > 0 ? (
                      <>
                        Aplicação de <strong>{newDiscountPercent}% de desconto</strong> sobre o valor do evento. O participante economizará{" "}
                        <strong className="text-emerald-600 dark:text-emerald-400">
                          R$ {((retreat.price * newDiscountPercent) / 100).toFixed(2).replace(".", ",")}
                        </strong>{" "}
                        e pagará apenas{" "}
                        <strong className="text-foreground dark:text-white">
                          R$ {(retreat.price - (retreat.price * newDiscountPercent) / 100).toFixed(2).replace(".", ",")}
                        </strong>{" "}
                        no checkout.
                      </>
                    ) : (
                      <>
                        O participante receberá um abatimento de <strong>{newDiscountPercent}%</strong> sobre o valor da inscrição na etapa de checkout do formulário.
                      </>
                    )}
                  </p>
                </div>
              </div>
            )}

            {/* SECTION 3 & 4: 2-COLUMN GRID ON DESKTOP (Code + CPF) */}
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              {/* Col 1: Código Único */}
              <Field className="space-y-1.5">
                <FieldLabel htmlFor="coupon-code" className="text-sm font-semibold flex items-center gap-1">
                  Código Único <span className="text-destructive">*</span>
                </FieldLabel>
                <div className="flex gap-2">
                  <Input
                    id="coupon-code"
                    value={newCode}
                    onChange={(e) => setNewCode(e.target.value.toUpperCase())}
                    placeholder="Ex: ISENTO-7F2A"
                    className="font-mono text-sm font-bold tracking-wider min-h-[44px] h-11 uppercase"
                  />
                  <Button
                    type="button"
                    variant="outline"
                    onClick={() => setNewCode(generateRandomCode(newDiscountPercent))}
                    className="min-h-[44px] h-11 px-3 shrink-0 cursor-pointer"
                    title="Gerar outro código aleatório"
                  >
                    <RefreshCw className="w-4 h-4" />
                  </Button>
                </div>
                <p className="text-[11px] text-muted-foreground">
                  Sensível a maiúsculas. Você pode personalizar ou sortear.
                </p>
              </Field>

              {/* Col 2: CPF do Beneficiário */}
              <Field className="space-y-1.5">
                <div className="flex items-center justify-between">
                  <FieldLabel htmlFor="coupon-cpf" className="text-sm font-semibold flex items-center gap-1">
                    CPF do Beneficiário <span className="text-destructive">*</span>
                  </FieldLabel>
                  <span className="text-[10px] font-semibold text-emerald-600 dark:text-emerald-400 bg-emerald-500/10 px-1.5 py-0.5 rounded">
                    Dupla Proteção
                  </span>
                </div>
                <Input
                  id="coupon-cpf"
                  value={newCpf}
                  onChange={(e) => setNewCpf(formatCpfInput(e.target.value))}
                  placeholder="000.000.000-00"
                  maxLength={14}
                  className={`font-mono text-sm min-h-[44px] h-11 ${
                    newCpf.replace(/\D/g, "").length === 11 && !isValidCPF(newCpf)
                      ? "border-destructive focus-visible:ring-destructive"
                      : ""
                  }`}
                />
                {newCpf.replace(/\D/g, "").length === 11 && !isValidCPF(newCpf) ? (
                  <p className="text-[11px] font-medium text-destructive">
                    CPF inválido pelos dígitos verificadores. Digite um CPF verdadeiro.
                  </p>
                ) : (
                  <p className="text-[11px] text-muted-foreground">
                    Segurança dupla: o código só poderá ser resgatado na inscrição deste CPF.
                  </p>
                )}
              </Field>
            </div>

            {/* SECTION 5: NOTES / JUSTIFICATION */}
            <Field className="space-y-1.5">
              <FieldLabel htmlFor="coupon-notes" className="text-sm font-semibold">
                Beneficiário / Observações Internas (Opcional)
              </FieldLabel>
              <Input
                id="coupon-notes"
                value={newNotes}
                onChange={(e) => setNewNotes(e.target.value)}
                placeholder="Ex: Apoio diaconal para Maria, Voluntário de som, Equipe de cozinha..."
                className="min-h-[44px] h-11"
              />
              <p className="text-[11px] text-muted-foreground">
                Essa nota é visível apenas para os administradores no painel.
              </p>
            </Field>
          </div>

          <DialogFooter className="gap-2 sm:gap-0 pt-2 border-t border-border/50">
            <Button
              type="button"
              variant="outline"
              onClick={() => setIsCreateOpen(false)}
              className="min-h-[44px] h-11 cursor-pointer"
              disabled={creating}
            >
              Cancelar
            </Button>
            <Button
              type="button"
              onClick={handleCreateCoupon}
              disabled={creating || !newCode.trim()}
              className="min-h-[44px] h-11 cursor-pointer bg-primary text-primary-foreground font-semibold"
            >
              {creating ? (
                <>
                  <RefreshCw className="w-4 h-4 animate-spin mr-1.5" />
                  Gerando...
                </>
              ) : (
                "Confirmar e Gerar Código"
              )}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}
