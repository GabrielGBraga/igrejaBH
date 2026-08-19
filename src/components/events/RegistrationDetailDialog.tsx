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
import { 
  User, 
  Mail, 
  Phone, 
  CreditCard, 
  Bed, 
  FileText, 
  CheckCircle2, 
  XCircle
} from "lucide-react";
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
}

export function RegistrationDetailDialog({
  registration,
  isOpen,
  onClose,
  onTogglePayment,
}: RegistrationDetailDialogProps) {
  if (!registration) return null;

  const profile = registration.profiles;
  const guestData = registration.guest_data as Record<string, any> | null;
  const customResponses = registration.custom_responses as Record<string, any> | null;

  const fullName = profile?.full_name || guestData?.full_name || "Participante sem nome";
  const email = profile?.email || guestData?.email || "Não informado";
  const phone = profile?.phone || guestData?.phone || "Não informado";
  const cpf = profile?.cpf || guestData?.cpf || "Não informado";
  const roomName = registration.retreat_rooms?.name || registration.room_allocation || "Não alocado";

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
              variant={registration.paid ? "default" : "outline"}
              className={`px-3 py-1 rounded-full text-xs font-bold uppercase tracking-wide ${
                registration.paid 
                  ? "bg-emerald-500/15 text-emerald-500 border border-emerald-500/30" 
                  : "bg-amber-500/15 text-amber-500 border border-amber-500/30"
              }`}
            >
              {registration.paid ? (
                <span className="flex items-center gap-1">
                  <CheckCircle2 className="w-3.5 h-3.5" /> Pago
                </span>
              ) : (
                <span className="flex items-center gap-1">
                  <XCircle className="w-3.5 h-3.5" /> Pagamento Pendente
                </span>
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
                <span className="font-bold text-foreground flex items-center gap-1.5 mt-0.5 capitalize">
                  <CreditCard className="w-4 h-4 text-emerald-500" />
                  {registration.payment_method || "Não especificado (Pix)"}
                </span>
              </div>
              {registration.payment_reference && (
                <div className="sm:col-span-2 mt-1">
                  <span className="text-muted-foreground block font-semibold">Referência / Comprovante</span>
                  <span className="font-mono text-[11px] text-foreground bg-muted/50 p-1.5 rounded block mt-0.5 break-all">
                    {registration.payment_reference}
                  </span>
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
            className="cursor-pointer"
          >
            {registration.paid ? "Marcar como Pendente" : "Confirmar Pagamento"}
          </Button>
          <Button type="button" variant="secondary" onClick={onClose} className="cursor-pointer">
            Fechar
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}
