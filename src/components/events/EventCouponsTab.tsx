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
import { toast } from "sonner";
import supabase from "@/lib/supabase";
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

  // Random Code Generator (Format: ISENTO-XXXX)
  const generateRandomCode = () => {
    const chars = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";
    let randomPart = "";
    for (let i = 0; i < 4; i++) {
      randomPart += chars.charAt(Math.floor(Math.random() * chars.length));
    }
    return `ISENTO-${randomPart}`;
  };

  const openCreateDialog = () => {
    setNewCode(generateRandomCode());
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

    const cleanCpf = newCpf.replace(/\D/g, "");
    if (!cleanCpf) {
      toast.error("Informe o CPF do beneficiário para vincular ao código.");
      return;
    }
    if (cleanCpf.length !== 11) {
      toast.error("O CPF deve conter exatamente 11 dígitos.");
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

      toast.success(`Código ${data.code} vinculado ao CPF com sucesso!`);
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
                    <div className="flex items-center gap-2">
                      <code className="rounded bg-muted px-2 py-1 font-mono text-sm font-bold text-foreground tracking-wider">
                        {coupon.code}
                      </code>
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
        <DialogContent className="sm:max-w-md">
          <DialogHeader>
            <DialogTitle className="text-base font-bold flex items-center gap-2">
              <Ticket className="w-5 h-5 text-primary" />
              Gerar Código de Isenção
            </DialogTitle>
            <DialogDescription className="text-xs text-muted-foreground">
              O código gerado é aleatório e de uso único. O usuário contemplado poderá utilizá-lo para se inscrever sem custos.
            </DialogDescription>
          </DialogHeader>

          <div className="space-y-4 py-2">
            <Field>
              <FieldLabel htmlFor="coupon-code">Código Único *</FieldLabel>
              <div className="flex gap-2">
                <Input
                  id="coupon-code"
                  value={newCode}
                  onChange={(e) => setNewCode(e.target.value.toUpperCase())}
                  placeholder="Ex: ISENTO-7F2A"
                  className="font-mono text-sm font-bold tracking-wider min-h-[44px]"
                />
                <Button
                  type="button"
                  variant="outline"
                  onClick={() => setNewCode(generateRandomCode())}
                  className="min-h-[44px] px-3 shrink-0 cursor-pointer"
                  title="Gerar outro código aleatório"
                >
                  <RefreshCw className="w-4 h-4" />
                </Button>
              </div>
            </Field>

            <Field>
              <FieldLabel htmlFor="coupon-cpf">CPF do Beneficiário *</FieldLabel>
              <Input
                id="coupon-cpf"
                value={newCpf}
                onChange={(e) => setNewCpf(formatCpfInput(e.target.value))}
                placeholder="000.000.000-00"
                maxLength={14}
                className="font-mono text-sm min-h-[44px]"
              />
              <p className="text-[11px] text-muted-foreground mt-1">
                Segurança dupla: o código de isenção só poderá ser resgatado na inscrição deste CPF.
              </p>
            </Field>

            <Field>
              <FieldLabel htmlFor="coupon-notes">Beneficiário / Observações (Opcional)</FieldLabel>
              <Input
                id="coupon-notes"
                value={newNotes}
                onChange={(e) => setNewNotes(e.target.value)}
                placeholder="Ex: Apoio diaconal para Maria, Voluntário de som..."
                className="min-h-[44px]"
              />
              <p className="text-[11px] text-muted-foreground mt-1">
                Essa nota é visível apenas para os administradores no painel.
              </p>
            </Field>
          </div>

          <DialogFooter className="gap-2 sm:gap-0">
            <Button
              type="button"
              variant="outline"
              onClick={() => setIsCreateOpen(false)}
              className="min-h-[44px] cursor-pointer"
              disabled={creating}
            >
              Cancelar
            </Button>
            <Button
              type="button"
              onClick={handleCreateCoupon}
              disabled={creating || !newCode.trim()}
              className="min-h-[44px] cursor-pointer bg-primary text-primary-foreground font-semibold"
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
