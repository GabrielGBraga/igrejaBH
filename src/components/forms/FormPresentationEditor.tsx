import { useState } from "react";
import {
  Sparkles,
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
} from "@/lib/forms";
import { FormPresentationView } from "./FormPresentationView";

interface FormPresentationEditorProps {
  form: FormTemplate | null;
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
  onChange,
}: FormPresentationEditorProps) {
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
  };

  const [activeTab, setActiveTab] = useState<"edit" | "preview">("edit");

  const updateState = (updates: Partial<FormPresentationPage>) => {
    onChange({
      ...current,
      ...updates,
    });
  };

  // Add highlight item
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

  // Update highlight item
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

  // Remove highlight item
  const handleRemoveItem = (id: string) => {
    updateState({
      infoItems: (current.infoItems || []).filter((item) => item.id !== id),
    });
  };

  return (
    <div className="space-y-6">
      {/* Top Toggle Bar */}
      <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4 rounded-xl border border-border bg-card p-4 shadow-sm">
        <div className="space-y-0.5">
          <div className="flex items-center gap-2">
            <Sparkles className="w-5 h-5 text-primary" />
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
            {current.enabled ? "Página Ativada (Clique para Desativar)" : "Ativar Página de Apresentação"}
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
                <Card className="rounded-xl border-border bg-card p-5 shadow-sm space-y-4">
                  <h4 className="text-xs font-bold text-muted-foreground uppercase tracking-wider">
                    Cabeçalho e Textos Principais
                  </h4>

                  <Field>
                    <FieldLabel htmlFor="pres-title">Título do Encontro / Evento *</FieldLabel>
                    <Input
                      id="pres-title"
                      value={current.title || ""}
                      onChange={(e) => updateState({ title: e.target.value })}
                      placeholder="Ex: Retiro de Jovens 2026 — O Propósito Eterno"
                      className="min-h-[44px] rounded-lg"
                    />
                  </Field>

                  <Field>
                    <FieldLabel htmlFor="pres-subtitle">Subtítulo / Chamada Curta</FieldLabel>
                    <Input
                      id="pres-subtitle"
                      value={current.subtitle || ""}
                      onChange={(e) => updateState({ subtitle: e.target.value })}
                      placeholder="Ex: Informações importantes e orientações antes de se inscrever"
                      className="min-h-[44px] rounded-lg"
                    />
                  </Field>

                  <Field>
                    <FieldLabel htmlFor="pres-banner">URL da Imagem de Capa (Banner Opcional)</FieldLabel>
                    <Input
                      id="pres-banner"
                      value={current.bannerUrl || ""}
                      onChange={(e) => updateState({ bannerUrl: e.target.value })}
                      placeholder="https://exemplo.com/imagem-do-retiro.jpg"
                      className="min-h-[44px] rounded-lg text-xs"
                    />
                    <p className="text-[11px] text-muted-foreground mt-1">
                      Se não informada, um gradiente moderno e suave será utilizado no cabeçalho.
                    </p>
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

                {/* Highlights / Info Cards */}
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
                        Nenhum cartão de destaque adicionado. Clique no botão acima para adicionar.
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
                              className="text-red-500 hover:text-red-600 p-1.5 rounded cursor-pointer min-h-[36px] min-w-[36px] flex items-center justify-center"
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
                <div className="rounded-2xl border border-border/80 shadow-md bg-card overflow-hidden max-h-[700px] overflow-y-auto">
                  <FormPresentationView
                    presentation={current}
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
                onStart={() => alert("Simulação: Ao clicar aqui no formulário público, o usuário é direcionado imediatamente para as perguntas de inscrição.")}
              />
            </div>
          )}
        </div>
      )}
    </div>
  );
}
