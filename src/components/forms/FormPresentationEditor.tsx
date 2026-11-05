import { useState, useRef } from "react";
import {
  LayoutTemplate,
  Plus,
  Trash2,
  Clock,
  MapPin,
  Backpack,
  Utensils,
  Bed,
  AlertCircle,
  Info,
  Heart,
  Eye,
  Settings2,
  Calendar,
  UploadCloud,
  Image as ImageIcon,
  Loader2,
  X,
  Link2,
  CircleDollarSign,
  CreditCard,
} from "lucide-react";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import { Button } from "@/components/ui/button";
import { Card } from "@/components/ui/card";
import { Field, FieldLabel } from "@/components/ui/field";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import type {
  FormTemplate,
  FormPresentationPage,
  FormPresentationInfoItem,
  FormPresentationCostItem,
  FormPresentationCostSection,
} from "@/lib/forms";
import supabase from "@/lib/supabase";
import { toast } from "sonner";
import { FormPresentationView } from "./FormPresentationView";

interface FormPresentationEditorProps {
  form: FormTemplate | null;
  retreat?: {
    title?: string | null;
    start_date?: string | null;
    end_date?: string | null;
    location_text?: string | null;
    max_participants?: number | null;
    price?: number | null;
    has_payment?: boolean | null;
  } | null;
  onChange: (presentationPage: FormPresentationPage) => void;
}

const AVAILABLE_ICONS = [
  { id: "backpack", label: "O que levar / Bagagem", icon: Backpack },
  { id: "clock", label: "Horários / Cronograma", icon: Clock },
  { id: "map-pin", label: "Local / Endereço", icon: MapPin },
  { id: "utensils", label: "Alimentação / Refeições", icon: Utensils },
  { id: "bed", label: "Acomodações / Quartos", icon: Bed },
  { id: "info", label: "Informativo Geral", icon: Info },
  { id: "alert", label: "Avisos Importantes", icon: AlertCircle },
  { id: "heart", label: "Comunhão / Cuidados", icon: Heart },
  { id: "calendar", label: "Datas / Período", icon: Calendar },
];

export function FormPresentationEditor({
  form,
  retreat,
  onChange,
}: FormPresentationEditorProps) {
  const [activeTab, setActiveTab] = useState<"edit" | "preview">("edit");
  const [isUploadingBanner, setIsUploadingBanner] = useState(false);
  const [showManualBannerUrl, setShowManualBannerUrl] = useState(false);
  const fileInputRef = useRef<HTMLInputElement>(null);

  if (!form) return null;

  const current: FormPresentationPage = form.presentationPage || {
    enabled: false,
    title: form.name || "",
    subtitle: "Leia as informações importantes antes de prosseguir com sua inscrição.",
    bannerUrl: "",
    description: form.description || "",
    infoItems: [
      {
        id: "item-1",
        title: "O que levar",
        description: "Bíblia, caderno para anotações, roupa de cama e banho, e itens de higiene pessoal.",
        icon: "backpack",
      },
      {
        id: "item-2",
        title: "Horários",
        description: "Chegada na sexta-feira a partir das 18h30. Encerramento no domingo às 15h.",
        icon: "clock",
      },
    ],
    ctaButtonText: "Avançar para Inscrição",
    costs: {
      enabled: false,
      title: "Custos e Investimento",
      description: "",
      items: [],
      paymentInfo: "",
    },
  };

  const updateState = (updates: Partial<FormPresentationPage>) => {
    onChange({
      ...current,
      ...updates,
    });
  };

  // Banner File Upload Handler
  const handleBannerFileChange = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;

    const isImage =
      file.type.startsWith("image/") ||
      /\.(jpg|jpeg|png|webp|gif|avif)$/i.test(file.name);

    if (!isImage) {
      toast.error("Por favor, selecione um arquivo de imagem válido (JPG, PNG ou WebP).");
      return;
    }

    // 5MB limit
    if (file.size > 5 * 1024 * 1024) {
      toast.error("A imagem selecionada excede o limite máximo de 5MB.");
      return;
    }

    setIsUploadingBanner(true);
    const toastId = toast.loading("Enviando imagem do banner...");

    try {
      const { data: sessionData } = await supabase.auth.getSession();
      const userId = sessionData?.session?.user?.id || "banners";
      const fileExt = (file.name.split(".").pop() || "jpg")
        .toLowerCase()
        .replace(/[^a-z0-9]/g, "");
      const fileName = `banner-${Date.now()}-${Math.random().toString(36).substring(2, 9)}.${fileExt}`;
      const filePath = `${userId}/${fileName}`;

      const { error: uploadError } = await supabase.storage
        .from("post-images")
        .upload(filePath, file, { cacheControl: "3600", upsert: true });

      if (uploadError) throw uploadError;

      const {
        data: { publicUrl },
      } = supabase.storage.from("post-images").getPublicUrl(filePath);

      updateState({ bannerUrl: publicUrl });
      toast.success("Banner atualizado com sucesso!", { id: toastId });
    } catch (err: unknown) {
      console.error("Erro no upload do banner:", err);
      const errorMsg =
        err && typeof err === "object" && "message" in err
          ? String((err as { message?: unknown }).message)
          : "Não foi possível enviar a imagem. Tente novamente ou use uma URL externa.";
      toast.error(`Falha no upload: ${errorMsg}`, {
        id: toastId,
      });
    } finally {
      setIsUploadingBanner(false);
      if (fileInputRef.current) {
        fileInputRef.current.value = "";
      }
    }
  };

  const handleRemoveBanner = () => {
    updateState({ bannerUrl: "" });
    toast.info("Banner removido. O gradiente padrão será utilizado.");
  };

  // Highlights handlers
  const handleAddItem = () => {
    const newItem: FormPresentationInfoItem = {
      id: `item-${Date.now()}`,
      title: "Novo Destaque",
      description: "Descreva uma orientação importante para este encontro.",
      icon: "info",
    };
    updateState({
      infoItems: [...(current.infoItems || []), newItem],
    });
  };

  const handleUpdateItem = (
    id: string,
    field: keyof FormPresentationInfoItem,
    val: string
  ) => {
    const updated = (current.infoItems || []).map((item) =>
      item.id === id ? { ...item, [field]: val } : item
    );
    updateState({ infoItems: updated });
  };

  const handleRemoveItem = (id: string) => {
    updateState({
      infoItems: (current.infoItems || []).filter((item) => item.id !== id),
    });
  };

  // Cost Section handlers
  const currentCosts: FormPresentationCostSection = current.costs || {
    enabled: false,
    title: "Custos e Investimento",
    description: "",
    items: [],
    paymentInfo: "",
  };

  const updateCosts = (updates: Partial<FormPresentationCostSection>) => {
    updateState({
      costs: {
        ...currentCosts,
        ...updates,
      },
    });
  };

  const formatCurrencyInput = (val: string): string => {
    const digits = val.replace(/\D/g, "");
    if (!digits || digits.replace(/^0+/, "") === "") return "";
    const cents = parseInt(digits, 10);
    return (cents / 100).toLocaleString("pt-BR", {
      style: "currency",
      currency: "BRL",
    });
  };

  const handleAddCostItem = () => {
    const newItem: FormPresentationCostItem = {
      id: `cost-${Date.now()}`,
      title: "",
      amount: "",
      description: "",
    };
    updateCosts({
      items: [...(currentCosts.items || []), newItem],
    });
  };

  const handleUpdateCostItem = (
    id: string,
    field: keyof FormPresentationCostItem,
    val: string
  ) => {
    const updated = (currentCosts.items || []).map((item) =>
      item.id === id ? { ...item, [field]: val } : item
    );
    updateCosts({ items: updated });
  };

  const handleRemoveCostItem = (id: string) => {
    updateCosts({
      items: (currentCosts.items || []).filter((item) => item.id !== id),
    });
  };

  return (
    <div className="space-y-6">
      {/* Top Toggle Bar */}
      <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4 rounded-xl border border-border bg-card p-4 shadow-sm">
        <div className="space-y-0.5">
          <div className="flex items-center gap-2">
            <LayoutTemplate className="w-5 h-5 text-primary" />
            <h3 className="text-sm font-bold text-foreground">
              Página de Apresentação Prévia do Evento
            </h3>
            {current.enabled ? (
              <span className="text-[10px] font-bold text-emerald-600 bg-emerald-500/10 border border-emerald-500/20 px-2 py-0.5 rounded-full">
                Ativada
              </span>
            ) : (
              <span className="text-[10px] font-bold text-zinc-500 bg-zinc-100 dark:bg-zinc-800 px-2 py-0.5 rounded-full">
                Desativada
              </span>
            )}
          </div>
          <p className="text-xs text-muted-foreground">
            Exibe uma página de apresentação com orientações e destaques antes de abrir as perguntas do formulário.
          </p>
        </div>

        <div className="flex items-center gap-3 w-full sm:w-auto justify-between sm:justify-end">
          <button
            type="button"
            onClick={() => updateState({ enabled: !current.enabled })}
            className={`min-h-[44px] px-4 py-2 rounded-lg text-xs font-bold transition-all cursor-pointer flex items-center gap-2 ${
              current.enabled
                ? "bg-emerald-600 hover:bg-emerald-700 text-white shadow-sm"
                : "bg-muted text-muted-foreground hover:text-foreground"
            }`}
          >
            {current.enabled ? "Página Ativada (Desativar)" : "Ativar Página de Apresentação"}
          </button>
        </div>
      </div>

      {current.enabled && (
        <div className="space-y-5 animate-in fade-in duration-200">
          {/* Sub Tab: Edit vs Live Preview */}
          <div className="flex items-center justify-between border-b border-border/60 pb-2">
            <div className="flex gap-2">
              <button
                type="button"
                onClick={() => setActiveTab("edit")}
                className={`min-h-[44px] px-3.5 py-1.5 rounded-lg text-xs font-bold transition-all cursor-pointer flex items-center gap-1.5 ${
                  activeTab === "edit"
                    ? "bg-primary text-primary-foreground shadow-sm"
                    : "text-muted-foreground hover:bg-muted/40"
                }`}
              >
                <Settings2 className="w-3.5 h-3.5" />
                <span>Configurar Conteúdo</span>
              </button>
              <button
                type="button"
                onClick={() => setActiveTab("preview")}
                className={`min-h-[44px] px-3.5 py-1.5 rounded-lg text-xs font-bold transition-all cursor-pointer flex items-center gap-1.5 ${
                  activeTab === "preview"
                    ? "bg-primary text-primary-foreground shadow-sm"
                    : "text-muted-foreground hover:bg-muted/40"
                }`}
              >
                <Eye className="w-3.5 h-3.5" />
                <span>Pré-visualização em Tempo Real</span>
              </button>
            </div>
          </div>

          {activeTab === "edit" ? (
            <div className="grid grid-cols-1 lg:grid-cols-12 gap-6 items-start">
              {/* Form Config Left */}
              <div className="lg:col-span-7 space-y-5">
                {/* 1. Header & Banner Card */}
                <Card className="rounded-xl border-border bg-card p-5 shadow-sm space-y-4">
                  <h4 className="text-xs font-bold text-muted-foreground uppercase tracking-wider">
                    Cabeçalho e Banner do Evento
                  </h4>

                  <Field>
                    <FieldLabel htmlFor="pres-title">Título do Encontro / Evento *</FieldLabel>
                    <Input
                      id="pres-title"
                      value={current.title || ""}
                      onChange={(e) => updateState({ title: e.target.value })}
                      placeholder="Ex: Encontro Metropolitano de Casais 2026"
                      className="min-h-[44px] rounded-lg"
                    />
                  </Field>

                  <Field>
                    <FieldLabel htmlFor="pres-subtitle">Subtítulo / Chamada Curta</FieldLabel>
                    <Input
                      id="pres-subtitle"
                      value={current.subtitle || ""}
                      onChange={(e) => updateState({ subtitle: e.target.value })}
                      placeholder="Ex: Orientações para o encontro de fortalecimento dos lares"
                      className="min-h-[44px] rounded-lg"
                    />
                  </Field>

                  {/* Banner Image Upload & Preview */}
                  <Field>
                    <FieldLabel>Imagem de Capa (Banner Opcional)</FieldLabel>

                    {/* Hidden Native File Input */}
                    <input
                      type="file"
                      ref={fileInputRef}
                      onChange={handleBannerFileChange}
                      accept="image/*,image/png,image/jpeg,image/webp,image/jpg"
                      className="hidden"
                    />

                    {current.bannerUrl ? (
                      <div className="space-y-3">
                        <div className="relative rounded-xl border border-border/80 overflow-hidden bg-zinc-950 group">
                          <img
                            src={current.bannerUrl}
                            alt="Preview do Banner"
                            className="w-full h-36 object-cover object-center"
                            onError={(e) => {
                              (e.target as HTMLElement).style.display = "none";
                            }}
                          />
                          <div className="absolute inset-0 bg-black/40 opacity-0 group-hover:opacity-100 transition-opacity flex items-center justify-center gap-2 p-3">
                            <Button
                              type="button"
                              size="sm"
                              variant="secondary"
                              onClick={() => fileInputRef.current?.click()}
                              disabled={isUploadingBanner}
                              className="min-h-[44px] cursor-pointer text-xs font-semibold"
                            >
                              {isUploadingBanner ? (
                                <Loader2 className="w-4 h-4 animate-spin mr-1" />
                              ) : (
                                <UploadCloud className="w-4 h-4 mr-1" />
                              )}
                              Substituir Imagem
                            </Button>
                            <Button
                              type="button"
                              size="sm"
                              variant="destructive"
                              onClick={handleRemoveBanner}
                              disabled={isUploadingBanner}
                              className="min-h-[44px] cursor-pointer text-xs font-semibold"
                            >
                              <Trash2 className="w-4 h-4 mr-1" />
                              Remover
                            </Button>
                          </div>
                        </div>

                        <div className="flex flex-wrap items-center justify-between gap-2 pt-1 text-xs">
                          <div className="flex items-center gap-2">
                            <Button
                              type="button"
                              variant="outline"
                              size="sm"
                              onClick={() => fileInputRef.current?.click()}
                              disabled={isUploadingBanner}
                              className="min-h-[44px] cursor-pointer text-xs"
                            >
                              {isUploadingBanner ? (
                                <Loader2 className="w-3.5 h-3.5 animate-spin mr-1.5" />
                              ) : (
                                <UploadCloud className="w-3.5 h-3.5 mr-1.5 text-primary" />
                              )}
                              Alterar Imagem
                            </Button>
                            <Button
                              type="button"
                              variant="ghost"
                              size="sm"
                              onClick={handleRemoveBanner}
                              disabled={isUploadingBanner}
                              className="min-h-[44px] cursor-pointer text-xs text-red-500 hover:text-red-600 hover:bg-red-50 dark:hover:bg-red-950/20"
                            >
                              <X className="w-3.5 h-3.5 mr-1" />
                              Remover Banner
                            </Button>
                          </div>

                          <button
                            type="button"
                            onClick={() => setShowManualBannerUrl(!showManualBannerUrl)}
                            className="text-[11px] text-muted-foreground hover:text-foreground cursor-pointer underline flex items-center gap-1"
                          >
                            <Link2 className="w-3 h-3" />
                            {showManualBannerUrl ? "Ocultar URL direta" : "Ver / Editar URL direta"}
                          </button>
                        </div>
                      </div>
                    ) : (
                      /* Upload Dropzone Box */
                      <div className="space-y-2">
                        <div
                          onClick={() => !isUploadingBanner && fileInputRef.current?.click()}
                          onDragOver={(e) => e.preventDefault()}
                          onDrop={(e) => {
                            e.preventDefault();
                            if (e.dataTransfer.files && e.dataTransfer.files[0]) {
                              const syntheticEvent = {
                                target: { files: e.dataTransfer.files },
                              } as unknown as React.ChangeEvent<HTMLInputElement>;
                              handleBannerFileChange(syntheticEvent);
                            }
                          }}
                          className={`flex flex-col items-center justify-center p-6 border-2 border-dashed rounded-xl cursor-pointer transition-colors text-center ${
                            isUploadingBanner
                              ? "border-primary/50 bg-primary/5 cursor-wait"
                              : "border-border hover:border-primary/60 hover:bg-muted/30"
                          }`}
                        >
                          {isUploadingBanner ? (
                            <div className="space-y-2 flex flex-col items-center pointer-events-none">
                              <Loader2 className="w-8 h-8 text-primary animate-spin" />
                              <p className="text-xs font-semibold text-foreground">
                                Enviando imagem para o servidor...
                              </p>
                              <p className="text-[11px] text-muted-foreground">
                                Aguarde a conclusão do upload.
                              </p>
                            </div>
                          ) : (
                            <div className="space-y-2 flex flex-col items-center pointer-events-none">
                              <div className="w-10 h-10 rounded-full bg-primary/10 flex items-center justify-center text-primary">
                                <UploadCloud className="w-5 h-5" />
                              </div>
                              <div className="space-y-0.5">
                                <p className="text-xs font-bold text-foreground">
                                  Clique para fazer upload da imagem de capa
                                </p>
                                <p className="text-[11px] text-muted-foreground">
                                  ou arraste a foto até aqui (PNG, JPG ou WebP até 5MB)
                                </p>
                              </div>
                              <div className="min-h-[44px] mt-2 px-4 py-2 rounded-lg border border-border bg-background shadow-xs text-xs font-semibold flex items-center gap-2">
                                <ImageIcon className="w-3.5 h-3.5 text-primary" />
                                <span>Selecionar Arquivo do Computador</span>
                              </div>
                            </div>
                          )}
                        </div>

                        <div className="flex justify-end">
                          <button
                            type="button"
                            onClick={() => setShowManualBannerUrl(!showManualBannerUrl)}
                            className="text-[11px] text-muted-foreground hover:text-foreground cursor-pointer underline flex items-center gap-1"
                          >
                            <Link2 className="w-3 h-3" />
                            {showManualBannerUrl ? "Ocultar campo de link" : "Ou informar URL da imagem manualmente"}
                          </button>
                        </div>
                      </div>
                    )}

                    {showManualBannerUrl && (
                      <div className="pt-2 animate-in fade-in duration-150">
                        <Input
                          id="pres-banner"
                          value={current.bannerUrl || ""}
                          onChange={(e) => updateState({ bannerUrl: e.target.value })}
                          placeholder="https://exemplo.com/imagem-do-evento.jpg"
                          className="min-h-[44px] rounded-lg text-xs"
                        />
                        <p className="text-[11px] text-muted-foreground mt-1">
                          Cole o link direto da imagem hospedada em outro serviço.
                        </p>
                      </div>
                    )}
                  </Field>

                  <Field>
                    <FieldLabel htmlFor="pres-desc">Texto de Apresentação e Boas-Vindas</FieldLabel>
                    <Textarea
                      id="pres-desc"
                      value={current.description || ""}
                      onChange={(e) => updateState({ description: e.target.value })}
                      placeholder="Escreva sobre o propósito do encontro, recomendações fraternais e o que esperar desses dias..."
                      className="min-h-[100px] text-xs leading-relaxed rounded-lg"
                    />
                  </Field>

                  <Field>
                    <FieldLabel htmlFor="pres-cta">Texto do Botão de Inscrição</FieldLabel>
                    <Input
                      id="pres-cta"
                      value={current.ctaButtonText || "Avançar para Inscrição"}
                      onChange={(e) => updateState({ ctaButtonText: e.target.value })}
                      placeholder="Ex: Avançar para Inscrição"
                      className="min-h-[44px] rounded-lg"
                    />
                  </Field>
                </Card>

                {/* 2. Optional Cost / Pricing Section Card */}
                <Card className="rounded-xl border-border bg-card p-5 shadow-sm space-y-4">
                  <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3">
                    <div className="space-y-0.5">
                      <div className="flex items-center gap-2">
                        <CircleDollarSign className="w-4 h-4 text-primary" />
                        <h4 className="text-xs font-bold text-muted-foreground uppercase tracking-wider">
                          Seção de Custos do Evento
                        </h4>
                        <span className="text-[10px] uppercase font-bold px-2 py-0.5 rounded-full bg-muted text-muted-foreground">
                          Opcional
                        </span>
                      </div>
                      <p className="text-[11px] text-muted-foreground">
                        Informe o valor da inscrição ou taxa, o que está incluso e instruções de pagamento.
                      </p>
                    </div>

                    <button
                      type="button"
                      onClick={() => updateCosts({ enabled: !currentCosts.enabled })}
                      className={`min-h-[44px] px-3.5 py-1.5 rounded-lg text-xs font-bold transition-all cursor-pointer flex items-center justify-center gap-2 shrink-0 ${
                        currentCosts.enabled
                          ? "bg-emerald-600 hover:bg-emerald-700 text-white"
                          : "bg-muted text-muted-foreground hover:text-foreground"
                      }`}
                    >
                      {currentCosts.enabled ? "Seção Ativada" : "Ativar Seção de Custos"}
                    </button>
                  </div>

                  {currentCosts.enabled && (
                    <div className="space-y-4 pt-2 border-t border-border/60 animate-in fade-in duration-200">
                      <Field>
                        <FieldLabel htmlFor="cost-title">Título da Seção de Custos</FieldLabel>
                        <Input
                          id="cost-title"
                          value={currentCosts.title || ""}
                          onChange={(e) => updateCosts({ title: e.target.value })}
                          placeholder="Ex: Custos e Investimento"
                          className="min-h-[44px] rounded-lg text-xs"
                        />
                      </Field>

                      <Field>
                        <FieldLabel htmlFor="cost-desc">Descrição / O que está incluso no valor</FieldLabel>
                        <Textarea
                          id="cost-desc"
                          value={currentCosts.description || ""}
                          onChange={(e) => updateCosts({ description: e.target.value })}
                          placeholder="Descreva o que o valor contempla: alimentação completa, hospedagem, materiais e custos operacionais..."
                          className="min-h-[80px] text-xs leading-relaxed rounded-lg"
                        />
                      </Field>

                      {/* Cost Items List */}
                      <div className="space-y-3 pt-1">
                        <div className="flex items-center justify-between">
                          <label className="text-[10px] font-bold text-muted-foreground uppercase">
                            Tabela de Valores / Categorias (Opcional)
                          </label>
                          <Button
                            type="button"
                            size="sm"
                            variant="outline"
                            onClick={handleAddCostItem}
                            className="min-h-[44px] px-3 rounded-lg text-xs font-semibold cursor-pointer"
                          >
                            <Plus className="w-3.5 h-3.5 mr-1 text-primary" />
                            Adicionar Valor
                          </Button>
                        </div>

                        {(currentCosts.items || []).length === 0 ? (
                          <div className="p-3.5 rounded-lg border border-dashed border-border text-center text-xs text-muted-foreground">
                            {retreat?.price !== undefined && retreat?.price !== null ? (
                              <p>
                                O evento possui o valor base de{" "}
                                <strong className="text-foreground">
                                  {retreat.price === 0
                                    ? "Gratuito"
                                    : `R$ ${retreat.price.toLocaleString("pt-BR", { minimumFractionDigits: 2 })}`}
                                </strong>
                                . Você pode adicionar categorias personalizadas acima ou manter o valor automático.
                              </p>
                            ) : (
                              <p>Nenhuma categoria de valor adicionada. Clique em "+ Adicionar Valor" se desejar detalhar valores por categoria (ex: Individual, Casal, Criança).</p>
                            )}
                          </div>
                        ) : (
                          <div className="space-y-2.5">
                            {currentCosts.items!.map((item, idx) => (
                              <div
                                key={item.id}
                                className="p-3 rounded-xl border border-border/70 bg-muted/20 space-y-2.5"
                              >
                                <div className="flex items-center justify-between">
                                  <span className="text-[10px] font-extrabold uppercase text-muted-foreground">
                                    Valor #{idx + 1}
                                  </span>
                                  <button
                                    type="button"
                                    onClick={() => handleRemoveCostItem(item.id)}
                                    className="text-red-500 hover:text-red-600 p-2 rounded cursor-pointer min-h-[44px] min-w-[44px] flex items-center justify-center"
                                    title="Remover valor"
                                  >
                                    <Trash2 className="w-4 h-4" />
                                  </button>
                                </div>

                                <div className="grid grid-cols-1 sm:grid-cols-2 gap-2.5">
                                  <div>
                                    <label className="text-[10px] font-bold text-muted-foreground uppercase">
                                      Categoria / Identificação
                                    </label>
                                    <Input
                                      value={item.title || ""}
                                      onChange={(e) =>
                                        handleUpdateCostItem(item.id, "title", e.target.value)
                                      }
                                      placeholder="Ex: Inscrição Individual, Casal"
                                      className="h-9 text-xs rounded-md mt-1"
                                    />
                                  </div>

                                  <div>
                                    <label className="text-[10px] font-bold text-muted-foreground uppercase">
                                      Valor (R$)
                                    </label>
                                    <Input
                                      value={item.amount || ""}
                                      onChange={(e) => {
                                        const formatted = formatCurrencyInput(e.target.value);
                                        handleUpdateCostItem(item.id, "amount", formatted);
                                      }}
                                      inputMode="numeric"
                                      placeholder="R$ 0,00"
                                      className="h-9 text-xs rounded-md mt-1 font-medium"
                                    />
                                  </div>
                                </div>

                                <div>
                                  <label className="text-[10px] font-bold text-muted-foreground uppercase">
                                    Observação / O que inclui (Opcional)
                                  </label>
                                  <Input
                                    value={item.description || ""}
                                    onChange={(e) =>
                                      handleUpdateCostItem(item.id, "description", e.target.value)
                                    }
                                    placeholder="Ex: Estadia completa e alimentação inclusa"
                                    className="h-9 text-xs rounded-md mt-1"
                                  />
                                </div>
                              </div>
                            ))}
                          </div>
                        )}
                      </div>

                      {/* Payment Instructions */}
                      <Field>
                        <FieldLabel htmlFor="cost-payment" className="flex items-center gap-1.5">
                          <CreditCard className="w-3.5 h-3.5 text-primary" />
                          <span>Instruções de Pagamento (PIX, prazos, etc.)</span>
                        </FieldLabel>
                        <Textarea
                          id="cost-payment"
                          value={currentCosts.paymentInfo || ""}
                          onChange={(e) => updateCosts({ paymentInfo: e.target.value })}
                          placeholder="Ex: Chave PIX: financeiro@igreja.org. Favor enviar o comprovante para o responsável ou anexar na etapa seguinte."
                          className="min-h-[70px] text-xs leading-relaxed rounded-lg"
                        />
                      </Field>
                    </div>
                  )}
                </Card>

                {/* 3. Highlights / Practical Info Cards */}
                <Card className="rounded-xl border-border bg-card p-5 shadow-sm space-y-4">
                  <div className="flex items-center justify-between">
                    <div>
                      <h4 className="text-xs font-bold text-muted-foreground uppercase tracking-wider">
                        Cartões de Destaques e Orientações
                      </h4>
                      <p className="text-[11px] text-muted-foreground mt-0.5">
                        Adicione pontos essenciais como bagagem, horários, local e avisos.
                      </p>
                    </div>

                    <Button
                      type="button"
                      size="sm"
                      onClick={handleAddItem}
                      className="min-h-[44px] px-3 rounded-lg text-xs font-semibold cursor-pointer bg-primary text-primary-foreground"
                    >
                      <Plus className="w-4 h-4 mr-1" />
                      Adicionar Item
                    </Button>
                  </div>

                  <div className="space-y-3 pt-1">
                    {(current.infoItems || []).length === 0 ? (
                      <p className="text-xs text-muted-foreground italic text-center py-4">
                        Nenhum cartão de destaque adicionado. Use o botão acima para adicionar.
                      </p>
                    ) : (
                      current.infoItems!.map((item, idx) => (
                        <div
                          key={item.id}
                          className="p-3.5 rounded-xl border border-border/70 bg-muted/20 space-y-3 relative group"
                        >
                          <div className="flex items-center justify-between gap-2">
                            <span className="text-[10px] font-extrabold uppercase tracking-wider text-muted-foreground">
                              Destaque #{idx + 1}
                            </span>
                            <button
                              type="button"
                              onClick={() => handleRemoveItem(item.id)}
                              className="text-red-500 hover:text-red-600 p-2 rounded cursor-pointer min-h-[44px] min-w-[44px] flex items-center justify-center"
                              title="Remover destaque"
                            >
                              <Trash2 className="w-4 h-4" />
                            </button>
                          </div>

                          <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
                            <div className="sm:col-span-2">
                              <label className="text-[10px] font-bold text-muted-foreground uppercase">
                                Título do Destaque
                              </label>
                              <Input
                                value={item.title}
                                onChange={(e) => handleUpdateItem(item.id, "title", e.target.value)}
                                placeholder="Ex: O que levar"
                                className="h-9 text-xs rounded-md mt-1"
                              />
                            </div>

                            <div>
                              <label className="text-[10px] font-bold text-muted-foreground uppercase">
                                Ícone Representativo
                              </label>
                              <Select
                                value={item.icon || "info"}
                                onValueChange={(val) => handleUpdateItem(item.id, "icon", val)}
                              >
                                <SelectTrigger className="h-9 text-xs rounded-md mt-1">
                                  <SelectValue />
                                </SelectTrigger>
                                <SelectContent>
                                  {AVAILABLE_ICONS.map((ic) => (
                                    <SelectItem key={ic.id} value={ic.id} className="text-xs flex items-center gap-2">
                                      {ic.label}
                                    </SelectItem>
                                  ))}
                                </SelectContent>
                              </Select>
                            </div>
                          </div>

                          <div>
                            <label className="text-[10px] font-bold text-muted-foreground uppercase">
                              Descrição / Detalhes
                            </label>
                            <Textarea
                              value={item.description}
                              onChange={(e) => handleUpdateItem(item.id, "description", e.target.value)}
                              placeholder="Descreva as orientações práticas deste item..."
                              className="min-h-[60px] text-xs rounded-md mt-1"
                            />
                          </div>
                        </div>
                      ))
                    )}
                  </div>
                </Card>
              </div>

              {/* Side Live Mini-Preview */}
              <div className="lg:col-span-5 sticky top-6 space-y-3">
                <div className="flex items-center justify-between text-xs text-muted-foreground font-semibold px-1">
                  <span>Prévia do Participante</span>
                  <span className="text-[10px] uppercase tracking-wider bg-muted px-2 py-0.5 rounded">
                    Tempo Real
                  </span>
                </div>
                <div className="rounded-2xl border border-border/80 shadow-md bg-card overflow-hidden max-h-[700px] overflow-y-auto custom-scrollbar">
                  <FormPresentationView
                    presentation={current}
                    retreat={retreat}
                    onStart={() => setActiveTab("preview")}
                    isPreviewMode
                  />
                </div>
              </div>
            </div>
          ) : (
            /* Full Preview Mode */
            <div className="max-w-2xl mx-auto rounded-2xl border border-border bg-card shadow-lg overflow-hidden">
              <FormPresentationView
                presentation={current}
                retreat={retreat}
                onStart={() => alert("Simulação: Ao clicar aqui no formulário público, o participante é direcionado imediatamente para as perguntas de inscrição.")}
              />
            </div>
          )}
        </div>
      )}
    </div>
  );
}
