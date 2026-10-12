import { useState, useEffect } from "react";
import { 
  Dialog, 
  DialogContent, 
  DialogHeader, 
  DialogTitle, 
  DialogDescription,
  DialogFooter
} from "@/components/ui/dialog";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Separator } from "@/components/ui/separator";
import { Input } from "@/components/ui/input";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { 
  User, 
  Mail, 
  Phone, 
  CreditCard, 
  Bed, 
  FileText, 
  CheckCircle2, 
  XCircle,
  Ticket,
  QrCode,
  Banknote,
  Receipt,
  Gift,
  Wallet,
  Edit2,
  Check,
  Users
} from "lucide-react";
import {
  SERVICE_TEAMS,
  getServiceTeam,
  getServiceTeamBadgeStyle,
} from "@/constants/serviceTeams";
import supabase from "@/lib/supabase";
import { toast } from "sonner";
import type { Database } from "@/lib/database.types";

export type RegistrationWithDetails = Database["public"]["Tables"]["registrations"]["Row"] & {
  profiles?: {
    full_name: string;
    email: string | null;
    phone: string | null;
    cpf: string | null;
  } | null;
  retreat_rooms?: {
    id: string;
    name: string;
    gender_type: string | null;
    capacity: number;
  } | null;
};

interface RegistrationDetailDialogProps {
  registration: RegistrationWithDetails | null;
  isOpen: boolean;
  onClose: () => void;
  onTogglePayment: (reg: RegistrationWithDetails) => void;
  onUpdatePayment?: (
    regId: string,
    updates: { paid: boolean; payment_method: string; payment_reference?: string | null }
  ) => Promise<void>;
  onUpdateServiceTeam?: (
    regId: string,
    serviceTeam: string | null
  ) => Promise<void>;
}

export function RegistrationDetailDialog({
  registration,
  isOpen,
  onClose,
  onTogglePayment,
  onUpdatePayment,
  onUpdateServiceTeam,
}: RegistrationDetailDialogProps) {
  const [isEditingPayment, setIsEditingPayment] = useState(false);
  const [editMethod, setEditMethod] = useState("cupom");
  const [editReference, setEditReference] = useState("");
  const [isSavingPayment, setIsSavingPayment] = useState(false);

  // Service Team state
  const [isEditingTeam, setIsEditingTeam] = useState(false);
  const [selectedTeam, setSelectedTeam] = useState<string>("none");
  const [isSavingTeam, setIsSavingTeam] = useState(false);
  const [currentTeamState, setCurrentTeamState] = useState<string | null>(null);

  useEffect(() => {
    if (registration) {
      setEditMethod(registration.payment_method || "pix");
      setEditReference(registration.payment_reference || "");
      setIsEditingPayment(false);

      const team = registration.service_team || null;
      setCurrentTeamState(team);
      setSelectedTeam(team || "none");
      setIsEditingTeam(false);
    }
  }, [registration]);

  if (!registration) return null;

  const profile = registration.profiles;
  const guestData = registration.guest_data as Record<string, unknown> | null;
  const customResponses = registration.custom_responses as Record<string, unknown> | null;

  const fullName = profile?.full_name || (typeof guestData?.full_name === "string" ? guestData.full_name : null) || "Participante sem nome";
  const email = profile?.email || (typeof guestData?.email === "string" ? guestData.email : null) || "Não informado";
  const phone = profile?.phone || (typeof guestData?.phone === "string" ? guestData.phone : null) || "Não informado";
  const cpf = profile?.cpf || (typeof guestData?.cpf === "string" ? guestData.cpf : null) || "Não informado";
  const roomName = registration.retreat_rooms?.name || registration.room_allocation || "Não alocado";

  const rawMethod = (registration.payment_method || "").toLowerCase();
  const isCoupon = rawMethod === "cupom";
  const isGratuito = rawMethod === "gratuito";

  const handleSavePayment = async () => {
    if (!onUpdatePayment) return;
    setIsSavingPayment(true);
    try {
      await onUpdatePayment(registration.id, {
        paid: Boolean(registration.paid),
        payment_method: editMethod,
        payment_reference: editReference.trim() || null,
      });
      setIsEditingPayment(false);
    } finally {
      setIsSavingPayment(false);
    }
  };

  const handleSaveServiceTeam = async () => {
    if (!registration) return;
    setIsSavingTeam(true);
    try {
      const newTeamValue = selectedTeam === "none" ? null : selectedTeam;
      if (onUpdateServiceTeam) {
        await onUpdateServiceTeam(registration.id, newTeamValue);
      } else {
        const { error } = await supabase
          .from("registrations")
          .update({ service_team: newTeamValue })
          .eq("id", registration.id);
        if (error) throw error;
      }
      setCurrentTeamState(newTeamValue);
      setIsEditingTeam(false);
      toast.success("Equipe de serviço atualizada com sucesso!");
    } catch (err: unknown) {
      const msg = err instanceof Error ? err.message : "Erro desconhecido";
      console.error("Erro ao salvar equipe:", err);
      toast.error("Erro ao salvar equipe: " + msg);
    } finally {
      setIsSavingTeam(false);
    }
  };

  const renderPaymentMethodDisplay = (method: string | null) => {
    const m = (method || "").toLowerCase();
    if (m === "cupom") {
      return (
        <span className="font-bold text-purple-700 dark:text-purple-300 flex items-center gap-1.5 bg-purple-500/10 border border-purple-500/20 px-2.5 py-1 rounded-lg text-xs">
          <Ticket className="w-4 h-4 text-purple-600 dark:text-purple-400 shrink-0" />
          Cupom de Isenção / Desconto
        </span>
      );
    }
    if (m === "cartao" || m === "card" || m === "credit_card") {
      return (
        <span className="font-bold text-blue-700 dark:text-blue-300 flex items-center gap-1.5 bg-blue-500/10 border border-blue-500/20 px-2.5 py-1 rounded-lg text-xs">
          <CreditCard className="w-4 h-4 text-blue-600 dark:text-blue-400 shrink-0" />
          Cartão de Crédito
        </span>
      );
    }
    if (m === "pix") {
      return (
        <span className="font-bold text-emerald-700 dark:text-emerald-300 flex items-center gap-1.5 bg-emerald-500/10 border border-emerald-500/20 px-2.5 py-1 rounded-lg text-xs">
          <QrCode className="w-4 h-4 text-emerald-600 dark:text-emerald-400 shrink-0" />
          PIX Instantâneo
        </span>
      );
    }
    if (m === "dinheiro") {
      return (
        <span className="font-bold text-amber-700 dark:text-amber-300 flex items-center gap-1.5 bg-amber-500/10 border border-amber-500/20 px-2.5 py-1 rounded-lg text-xs">
          <Banknote className="w-4 h-4 text-amber-600 dark:text-amber-400 shrink-0" />
          Dinheiro / Em Espécie
        </span>
      );
    }
    if (m === "boleto") {
      return (
        <span className="font-bold text-orange-700 dark:text-orange-300 flex items-center gap-1.5 bg-orange-500/10 border border-orange-500/20 px-2.5 py-1 rounded-lg text-xs">
          <Receipt className="w-4 h-4 text-orange-600 dark:text-orange-400 shrink-0" />
          Boleto Bancário
        </span>
      );
    }
    if (m === "gratuito") {
      return (
        <span className="font-bold text-teal-700 dark:text-teal-300 flex items-center gap-1.5 bg-teal-500/10 border border-teal-500/20 px-2.5 py-1 rounded-lg text-xs">
          <Gift className="w-4 h-4 text-teal-600 dark:text-teal-400 shrink-0" />
          Inscrição Gratuita
        </span>
      );
    }
    return (
      <span className="font-medium text-foreground flex items-center gap-1.5 bg-muted/40 border border-border/40 px-2.5 py-1 rounded-lg text-xs">
        <Wallet className="w-4 h-4 text-muted-foreground shrink-0" />
        {method || "Não especificado (Pix)"}
      </span>
    );
  };

  return (
    <Dialog open={isOpen} onOpenChange={(open) => !open && onClose()}>
      <DialogContent className="sm:max-w-2xl max-w-full rounded-2xl border border-border bg-card p-6 md:p-8 max-h-[90vh] overflow-y-auto custom-scrollbar">
        <DialogHeader className="border-b border-border/50 pb-4">
          <div className="flex items-center justify-between gap-3 flex-wrap">
            <DialogTitle className="text-xl font-bold text-foreground flex items-center gap-2">
              <User className="h-5 w-5 text-primary" />
              {fullName}
            </DialogTitle>
            <Badge 
              variant="outline"
              className={`px-3 py-1 rounded-full text-xs font-bold uppercase tracking-wide flex items-center gap-1.5 ${
                isCoupon
                  ? (registration.paid 
                      ? "bg-purple-500/15 text-purple-700 dark:text-purple-300 border-purple-500/30" 
                      : "bg-amber-500/15 text-amber-700 dark:text-amber-300 border-amber-500/30")
                  : isGratuito
                  ? "bg-teal-500/15 text-teal-700 dark:text-teal-300 border-teal-500/30"
                  : (registration.paid 
                      ? "bg-emerald-500/15 text-emerald-600 dark:text-emerald-400 border-emerald-500/30" 
                      : "bg-amber-500/15 text-amber-600 dark:text-amber-400 border-amber-500/30")
              }`}
            >
              {isCoupon ? (
                <>
                  <Ticket className="w-3.5 h-3.5" />
                  {registration.paid ? "Isenção Confirmada (Cupom)" : "Cupom Pendente"}
                </>
              ) : isGratuito ? (
                <>
                  <Gift className="w-3.5 h-3.5" />
                  Inscrição Gratuita
                </>
              ) : registration.paid ? (
                <>
                  <CheckCircle2 className="w-3.5 h-3.5" /> Pago
                </>
              ) : (
                <>
                  <XCircle className="w-3.5 h-3.5" /> Pagamento Pendente
                </>
              )}
            </Badge>
          </div>
          <DialogDescription className="text-xs text-muted-foreground mt-1">
            Inscrição realizada em: {registration.created_at ? new Date(registration.created_at).toLocaleString("pt-BR") : "Data não disponível"}
          </DialogDescription>
        </DialogHeader>

        <div className="space-y-6 py-4">
          {/* Seção Dados Pessoais */}
          <div className="space-y-3">
            <h4 className="text-xs font-bold uppercase tracking-wider text-muted-foreground flex items-center gap-1.5">
              <User className="w-3.5 h-3.5 text-primary" /> Informações de Contato
            </h4>
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-3 bg-muted/20 border border-border/40 p-4 rounded-xl text-xs">
              <div>
                <span className="text-muted-foreground block font-semibold">Nome Completo</span>
                <span className="font-bold text-foreground">{fullName}</span>
              </div>
              <div>
                <span className="text-muted-foreground block font-semibold">CPF</span>
                <span className="font-bold text-foreground">{cpf}</span>
              </div>
              <div className="flex items-center gap-1.5 mt-1">
                <Mail className="w-3.5 h-3.5 text-muted-foreground shrink-0" />
                <span className="font-medium text-foreground truncate">{email}</span>
              </div>
              <div className="flex items-center gap-1.5 mt-1">
                <Phone className="w-3.5 h-3.5 text-muted-foreground shrink-0" />
                <span className="font-medium text-foreground">{phone}</span>
              </div>
            </div>
          </div>

          <Separator className="bg-border/50" />

          {/* Seção Logística & Quarto */}
          <div className="space-y-3">
            <h4 className="text-xs font-bold uppercase tracking-wider text-muted-foreground flex items-center gap-1.5">
              <Bed className="w-3.5 h-3.5 text-primary" /> Alojamento & Pagamento
            </h4>
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-3 bg-muted/20 border border-border/40 p-4 rounded-xl text-xs">
              <div>
                <span className="text-muted-foreground block font-semibold">Quarto Designado</span>
                <span className="font-bold text-foreground flex items-center gap-1.5 mt-0.5">
                  <Bed className="w-4 h-4 text-primary" />
                  {roomName}
                </span>
              </div>
              <div>
                <span className="text-muted-foreground block font-semibold">Forma / Tipo de Pagamento</span>
                <div className="flex items-center justify-between gap-2 mt-1">
                  {renderPaymentMethodDisplay(registration.payment_method)}
                  {onUpdatePayment && !isEditingPayment && (
                    <Button
                      variant="ghost"
                      size="sm"
                      onClick={() => setIsEditingPayment(true)}
                      className="h-7 px-2 text-[11px] text-muted-foreground hover:text-foreground gap-1 cursor-pointer"
                    >
                      <Edit2 className="w-3 h-3" /> Alterar
                    </Button>
                  )}
                </div>
              </div>

              {/* Modo de Edição de Pagamento */}
              {isEditingPayment && (
                <div className="sm:col-span-2 space-y-3 bg-muted/40 p-3 rounded-xl border border-border mt-1">
                  <div className="text-xs font-bold text-foreground">Alterar Forma e Comprovante de Pagamento</div>
                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                    <div>
                      <label className="text-[11px] font-semibold text-muted-foreground block mb-1">Forma de Pagamento</label>
                      <Select value={editMethod} onValueChange={setEditMethod}>
                        <SelectTrigger className="min-h-[40px] h-10 text-xs bg-background">
                          <SelectValue />
                        </SelectTrigger>
                        <SelectContent>
                          <SelectItem value="cupom">Cupom de Isenção / Desconto</SelectItem>
                          <SelectItem value="pix">PIX Instantâneo</SelectItem>
                          <SelectItem value="cartao">Cartão de Crédito</SelectItem>
                          <SelectItem value="dinheiro">Dinheiro / Espécie</SelectItem>
                          <SelectItem value="boleto">Boleto Bancário</SelectItem>
                          <SelectItem value="gratuito">Gratuito / Isento</SelectItem>
                        </SelectContent>
                      </Select>
                    </div>
                    <div>
                      <label className="text-[11px] font-semibold text-muted-foreground block mb-1">Referência / Código / Cupom</label>
                      <Input
                        value={editReference}
                        onChange={(e) => setEditReference(e.target.value)}
                        placeholder="Ex: Cupom: CODIGO ou Comprovante"
                        className="min-h-[40px] h-10 text-xs bg-background"
                      />
                    </div>
                  </div>
                  <div className="flex items-center justify-end gap-2 pt-1">
                    <Button
                      variant="ghost"
                      size="sm"
                      type="button"
                      onClick={() => setIsEditingPayment(false)}
                      className="h-8 text-xs cursor-pointer"
                    >
                      Cancelar
                    </Button>
                    <Button
                      size="sm"
                      type="button"
                      disabled={isSavingPayment}
                      onClick={handleSavePayment}
                      className="h-8 text-xs cursor-pointer gap-1"
                    >
                      <Check className="w-3 h-3" />
                      {isSavingPayment ? "Salvando..." : "Salvar Alterações"}
                    </Button>
                  </div>
                </div>
              )}

              {/* Referência / Comprovante Normal */}
              {!isEditingPayment && registration.payment_reference && (
                <div className="sm:col-span-2 mt-1">
                  <span className="text-muted-foreground block font-semibold">
                    {isCoupon ? "Detalhes do Cupom / Isenção" : "Referência / Comprovante"}
                  </span>
                  <span className={`text-xs p-2 rounded-lg flex items-center gap-2 mt-0.5 break-all ${
                    isCoupon
                      ? "font-mono text-purple-700 dark:text-purple-300 bg-purple-500/10 border border-purple-500/20"
                      : "font-mono text-foreground bg-muted/50 border border-border/30"
                  }`}>
                    {isCoupon && <Ticket className="w-4 h-4 text-purple-600 dark:text-purple-400 shrink-0" />}
                    {registration.payment_reference}
                  </span>
                </div>
              )}
            </div>
          </div>

          <Separator className="bg-border/50" />

          {/* Seção Equipe de Serviço & Diaconato */}
          <div className="space-y-3">
            <h4 className="text-xs font-bold uppercase tracking-wider text-muted-foreground flex items-center gap-1.5">
              <Users className="w-3.5 h-3.5 text-primary" /> Equipe de Serviço (Voluntariado)
            </h4>
            <div className="bg-muted/20 border border-border/40 p-4 rounded-xl text-xs space-y-3">
              <div className="flex items-center justify-between gap-2 flex-wrap">
                <div>
                  <span className="text-muted-foreground block font-semibold">Equipe Designada</span>
                  <div className="mt-1 flex items-center gap-2">
                    {(() => {
                      const teamDef = getServiceTeam(currentTeamState);
                      if (!teamDef) {
                        return (
                          <span className="text-muted-foreground italic flex items-center gap-1.5">
                            Participante Comum (Sem equipe atribuída)
                          </span>
                        );
                      }
                      const TeamIcon = teamDef.icon;
                      const badgeStyle = getServiceTeamBadgeStyle(teamDef.id);
                      return (
                        <Badge
                          variant="outline"
                          className={`text-xs font-bold px-2.5 py-1 rounded-full flex items-center gap-1.5 ${badgeStyle}`}
                        >
                          <TeamIcon className="w-3.5 h-3.5" />
                          {teamDef.label}
                        </Badge>
                      );
                    })()}
                  </div>
                </div>

                {!isEditingTeam && (
                  <Button
                    variant="ghost"
                    size="sm"
                    onClick={() => setIsEditingTeam(true)}
                    className="min-h-[44px] sm:min-h-[32px] h-11 sm:h-8 px-2.5 text-xs text-muted-foreground hover:text-foreground gap-1 cursor-pointer"
                  >
                    <Edit2 className="w-3.5 h-3.5" /> Alterar Equipe
                  </Button>
                )}
              </div>

              {/* Modo de Edição de Equipe de Serviço */}
              {isEditingTeam && (
                <div className="space-y-3 bg-muted/40 p-3 rounded-xl border border-border mt-2">
                  <div className="text-xs font-bold text-foreground">
                    Alterar Atribuição de Voluntariado
                  </div>
                  <div className="flex flex-col sm:flex-row items-stretch sm:items-center gap-2">
                    <div className="flex-1">
                      <Select value={selectedTeam} onValueChange={setSelectedTeam}>
                        <SelectTrigger className="min-h-[44px] sm:min-h-[40px] h-11 sm:h-10 text-xs bg-background">
                          <SelectValue placeholder="Selecione a equipe..." />
                        </SelectTrigger>
                        <SelectContent>
                          <SelectItem value="none">Nenhuma (Participante Comum)</SelectItem>
                          {SERVICE_TEAMS.map((t) => (
                            <SelectItem key={t.id} value={t.id}>
                              {t.label}
                            </SelectItem>
                          ))}
                        </SelectContent>
                      </Select>
                    </div>

                    <div className="flex items-center justify-end gap-2">
                      <Button
                        variant="ghost"
                        size="sm"
                        type="button"
                        onClick={() => setIsEditingTeam(false)}
                        className="min-h-[44px] sm:min-h-[36px] h-11 sm:h-9 text-xs cursor-pointer"
                      >
                        Cancelar
                      </Button>
                      <Button
                        size="sm"
                        type="button"
                        disabled={isSavingTeam}
                        onClick={handleSaveServiceTeam}
                        className="min-h-[44px] sm:min-h-[36px] h-11 sm:h-9 text-xs font-bold cursor-pointer gap-1"
                      >
                        <Check className="w-3.5 h-3.5" />
                        {isSavingTeam ? "Salvando..." : "Salvar"}
                      </Button>
                    </div>
                  </div>
                </div>
              )}
            </div>
          </div>

          {/* Seção Respostas do Formulário */}
          {customResponses && Object.keys(customResponses).length > 0 && (
            <>
              <Separator className="bg-border/50" />
              <div className="space-y-3">
                <h4 className="text-xs font-bold uppercase tracking-wider text-muted-foreground flex items-center gap-1.5">
                  <FileText className="w-3.5 h-3.5 text-primary" /> Respostas da Ficha de Inscrição
                </h4>
                <div className="space-y-2 bg-muted/20 border border-border/40 p-4 rounded-xl text-xs">
                  {Object.entries(customResponses).map(([fieldLabel, value]) => {
                    let displayVal = "";
                    if (Array.isArray(value)) {
                      displayVal = value.join(", ");
                    } else if (typeof value === "boolean") {
                      displayVal = value ? "Sim" : "Não";
                    } else {
                      displayVal = String(value || "—");
                    }

                    return (
                      <div key={fieldLabel} className="border-b border-border/20 last:border-0 pb-2 last:pb-0">
                        <span className="text-muted-foreground font-medium block">{fieldLabel}</span>
                        <span className="text-foreground font-bold block mt-0.5">{displayVal}</span>
                      </div>
                    );
                  })}
                </div>
              </div>
            </>
          )}

          {/* Seção Notas / Observações */}
          {registration.notes && (
            <>
              <Separator className="bg-border/50" />
              <div className="space-y-2">
                <h4 className="text-xs font-bold uppercase tracking-wider text-muted-foreground">Observações Internas</h4>
                <p className="text-xs bg-amber-500/10 text-amber-600 dark:text-amber-400 border border-amber-500/20 p-3 rounded-xl leading-relaxed">
                  {registration.notes}
                </p>
              </div>
            </>
          )}
        </div>

        <DialogFooter className="border-t border-border/50 pt-4 flex flex-col sm:flex-row gap-2">
          <Button
            type="button"
            variant={registration.paid ? "outline" : "default"}
            onClick={() => onTogglePayment(registration)}
            className="cursor-pointer min-h-[44px] sm:min-h-[36px]"
          >
            {isCoupon
              ? (registration.paid ? "Revogar Isenção (Pendente)" : "Confirmar Isenção (Cupom)")
              : (registration.paid ? "Marcar como Pendente" : "Confirmar Pagamento")}
          </Button>
          <Button type="button" variant="secondary" onClick={onClose} className="cursor-pointer min-h-[44px] sm:min-h-[36px]">
            Fechar
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}
