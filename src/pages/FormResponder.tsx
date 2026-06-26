import { useState, useEffect } from "react";
import { useParams, Link, Navigate } from "react-router-dom";
import { 
  ClipboardList, 
  CheckCircle2, 
  ArrowLeft, 
  ChevronsUpDown, 
  AlertCircle
} from "lucide-react";

import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import { Textarea } from "@/components/ui/textarea";
import { toast } from "sonner";
import supabase from "@/lib/supabase";
import { isFieldVisible } from "@/lib/forms";
import type { FormField, FormTemplate } from "@/lib/forms";
import { Layout } from "@/components/layout/Layout";
import { ThemeToggle } from "@/components/ThemeToggle";
import type { User } from "@supabase/supabase-js";

export default function FormResponder() {
  const { formId } = useParams<{ formId: string }>();
  
  const [formTemplate, setFormTemplate] = useState<FormTemplate | null>(null);
  const [loading, setLoading] = useState(true);
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  const [formData, setFormData] = useState<Record<string, any>>({});
  const [formErrors, setFormErrors] = useState<Record<string, string>>({});
  const [submitted, setSubmitted] = useState(false);
  const [canPost, setCanPost] = useState(false);
  const [user, setUser] = useState<User | null>(null);
  const [authLoading, setAuthLoading] = useState(true);

  // Initialize auth and listen for changes
  useEffect(() => {
    async function initAuth() {
      try {
        const { data: { session } } = await supabase.auth.getSession();
        if (session?.user) {
          setUser(session.user);
          const { data: profileData } = await supabase
            .from("profiles")
            .select("is_dev, is_presbyter, can_post")
            .eq("user_id", session.user.id)
            .single();
          
          if (profileData) {
            setCanPost(!!(profileData.is_dev || profileData.is_presbyter || profileData.can_post));
          }
        } else {
          setUser(null);
        }
      } catch (err) {
        console.error("Error checking permissions", err);
      } finally {
        setAuthLoading(false);
      }
    }
    initAuth();

    const { data: { subscription } } = supabase.auth.onAuthStateChange((_event, session) => {
      if (session?.user) {
        setUser(session.user);
      } else {
        setUser(null);
        setCanPost(false);
      }
    });

    return () => {
      subscription.unsubscribe();
    };
  }, []);

  // Load the specific form template from Supabase
  useEffect(() => {
    async function loadTemplate() {
      if (!formId) {
        setLoading(false);
        return;
      }

      try {
        setLoading(true);
        const { data: dbForm, error } = await supabase
          .from("forms")
          .select("*")
          .eq("id", formId)
          .single();

        if (error) throw error;

        if (dbForm) {
          setFormTemplate({
            id: dbForm.id,
            name: dbForm.name,
            description: dbForm.description || "",
            fields: (dbForm.fields as unknown as FormField[]) || [],
            createdAt: dbForm.created_at,
            isPublic: dbForm.is_public
          });
        } else {
          setFormTemplate(null);
        }
      } catch (e) {
        console.error("Error loading shared form template from Supabase:", e);
        setFormTemplate(null);
      } finally {
        setLoading(false);
      }
    }

    loadTemplate();
  }, [formId]);

  // Handle standard input updates
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  const handleInputChange = (fieldId: string, val: any) => {
    setFormData(prev => ({
      ...prev,
      [fieldId]: val
    }));
    // Remove error highlights once answered
    if (formErrors[fieldId]) {
      setFormErrors(prev => {
        const copy = { ...prev };
        delete copy[fieldId];
        return copy;
      });
    }
  };

  // Handle multi-checkbox state changes
  const handleCheckboxChange = (fieldId: string, option: string, isChecked: boolean) => {
    const currentList = formData[fieldId] || [];
    let updatedList;
    if (isChecked) {
      updatedList = [...currentList, option];
    } else {
      updatedList = currentList.filter((x: string) => x !== option);
    }
    
    handleInputChange(fieldId, updatedList);
  };

  // Submit response
  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!formTemplate) return;
    const template = formTemplate;
    
    // Validate inputs
    const errors: Record<string, string> = {};
    template.fields.forEach(field => {
      // Only validate if field is visible
      if (!isFieldVisible(field, formData, template.fields)) return;

      const val = formData[field.id];
      
      // 1. Required Check
      if (field.required) {
        if (field.type === 'checkbox') {
          if (!val || val.length === 0) {
            errors[field.id] = "Selecione pelo menos uma opção.";
          }
        } else if (val === undefined || val === null || (typeof val === 'string' && val.trim() === '')) {
          errors[field.id] = "Este campo é obrigatório.";
        }
      }

      // 2. Custom Validation Presets & Bounds Checks
      if (val !== undefined && val !== null && (typeof val !== 'string' || val.trim() !== '')) {
        if (['text', 'textarea'].includes(field.type) && field.validationPreset && field.validationPreset !== 'none') {
          const strVal = String(val).trim();
          if (field.validationPreset === 'phone') {
            const phoneRegex = /^\(?\d{2}\)?\s?\d{4,5}-?\d{4}$/;
            if (!phoneRegex.test(strVal)) {
              errors[field.id] = "Telefone inválido. Formato esperado: (XX) 99999-9999";
            }
          } else if (field.validationPreset === 'cpf') {
            const cpfRegex = /^\d{3}\.?\d{3}\.?\d{3}-?\d{2}$/;
            if (!cpfRegex.test(strVal)) {
              errors[field.id] = "CPF inválido. Formato esperado: 123.456.789-00";
            }
          } else if (field.validationPreset === 'cep') {
            const cepRegex = /^\d{5}-?\d{3}$/;
            if (!cepRegex.test(strVal)) {
              errors[field.id] = "CEP inválido. Formato esperado: 30123-456";
            }
          } else if (field.validationPreset === 'email') {
            const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            if (!emailRegex.test(strVal)) {
              errors[field.id] = "E-mail inválido. Formato esperado: exemplo@email.com";
            }
          }
        } else if (field.type === 'number') {
          const numVal = Number(val);
          if (field.minNumber !== undefined && numVal < field.minNumber) {
            errors[field.id] = `O valor deve ser maior ou igual a ${field.minNumber}.`;
          }
          if (field.maxNumber !== undefined && numVal > field.maxNumber) {
            errors[field.id] = `O valor deve ser menor ou igual a ${field.maxNumber}.`;
          }
        }
      }
    });

    if (Object.keys(errors).length > 0) {
      setFormErrors(errors);
      toast.error("Por favor, corrija os erros de validação antes de enviar.");
      return;
    }

    // Filter values for invisible fields to avoid sending trash data
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const filteredData: Record<string, any> = {};
    template.fields.forEach(field => {
      if (isFieldVisible(field, formData, template.fields) && formData[field.id] !== undefined) {
        filteredData[field.id] = formData[field.id];
      }
    });

    // Save submission to Supabase
    async function submitResponse() {
      try {
        const submissionId = `sub-${Math.random().toString(36).substring(7)}`;
        const submitToastId = toast.loading("Enviando sua resposta...");

        const { error } = await supabase
          .from("form_submissions")
          .insert({
            id: submissionId,
            form_id: template.id,
            data: filteredData,
            user_id: user?.id || null
          });

        if (error) throw error;
        toast.dismiss(submitToastId);

        setSubmitted(true);
        toast.success("Resposta enviada com sucesso!");
      } catch (e: any) {
        console.error("Error saving form response to Supabase:", e);
        toast.error(`Ocorreu um erro ao enviar suas respostas: ${e.message || "Erro desconhecido"}`);
      }
    }

    submitResponse();
  };

  const handleReset = () => {
    setFormData({});
    setFormErrors({});
    setSubmitted(false);
  };

  if (loading || authLoading) {
    return (
      <div className="flex flex-col items-center justify-center min-h-[60vh] gap-4">
        <div className="w-12 h-12 rounded-full border-4 border-primary border-t-transparent animate-spin"></div>
        <p className="text-muted-foreground font-semibold">Carregando formulário...</p>
      </div>
    );
  }

  if (!formTemplate) {
    return (
      <div className="max-w-md mx-auto text-center py-20 px-4 space-y-6 animate-in fade-in slide-in-from-bottom-4 duration-500">
        <div className="w-20 h-20 rounded-full bg-destructive/10 flex items-center justify-center mx-auto text-destructive">
          <AlertCircle className="w-10 h-10" />
        </div>
        <div className="space-y-2">
          <h1 className="text-2xl font-bold tracking-tight text-foreground">Formulário não encontrado</h1>
          <p className="text-muted-foreground text-sm leading-relaxed">
            O link acessado pode estar desatualizado, incorreto ou o formulário correspondente foi removido pela gestão.
          </p>
        </div>
        <Button asChild className="mt-4 bg-primary hover:bg-primary/90">
          <Link to={canPost ? "/gestao/formularios" : "/"} className="flex items-center gap-2">
            <ArrowLeft className="w-4 h-4" />
            {canPost ? "Voltar para Formulários" : "Voltar para o Início"}
          </Link>
        </Button>
      </div>
    );
  }

  const isFormPublic = !!formTemplate.isPublic;

  if (!isFormPublic && !user) {
    return <Navigate to="/entrar" state={{ from: `/formularios/responder/${formId}` }} replace />;
  }

  const formContent = (
    <div className="max-w-2xl mx-auto py-8 px-4 animate-in fade-in slide-in-from-bottom-4 duration-500">
      
      {/* HEADER NAVIGATION */}
      {user && (
        <div className="mb-8">
          <Button asChild variant="ghost" className="text-muted-foreground hover:text-foreground cursor-pointer -ml-4">
            <Link to={canPost ? "/gestao/formularios" : "/"} className="flex items-center gap-2">
              <ArrowLeft className="w-4 h-4" />
              {canPost ? "Voltar para Formulários" : "Voltar para o Início"}
            </Link>
          </Button>
        </div>
      )}

      {/* SUCCESS STATE CARD */}
      {submitted ? (
        <div className="border border-border/60 bg-card/25 p-8 text-center space-y-6 rounded-2xl shadow-sm animate-in zoom-in-95 duration-300 max-w-md mx-auto">
          <div className="w-16 h-16 rounded-full bg-emerald-500/10 flex items-center justify-center mx-auto text-emerald-600 border border-emerald-500/20">
            <CheckCircle2 className="w-8 h-8" />
          </div>
          
          <div className="space-y-2">
            <h2 className="text-2xl font-bold text-foreground">Resposta Enviada!</h2>
            <p className="text-sm text-muted-foreground max-w-xs mx-auto leading-relaxed">
              Obrigado por preencher o formulário **{formTemplate.name}**. Suas respostas foram registradas com sucesso.
            </p>
          </div>

          <div className="pt-4 flex flex-col gap-3">
            <Button onClick={handleReset} variant="outline" className="w-full h-11 rounded-md cursor-pointer text-sm font-semibold">
              Enviar outra resposta
            </Button>
            {user && (
              <Button asChild className="w-full h-11 bg-primary hover:bg-primary/90 text-primary-foreground font-bold rounded-md cursor-pointer text-sm">
                <Link to={canPost ? "/gestao/formularios" : "/"}>Concluir</Link>
              </Button>
            )}
          </div>
        </div>
      ) : (
        /* FORM CONTAINER */
        <div className="space-y-10">
          {/* Header */}
          <div className="border-b border-border/40 pb-6 space-y-3">
            <div className="flex items-center gap-3">
              <div className="w-11 h-11 rounded-xl bg-primary/5 flex items-center justify-center shrink-0 border border-primary/10">
                <ClipboardList className="w-5 h-5 text-primary" />
              </div>
              <div className="space-y-0.5">
                <h1 className="text-2xl font-bold tracking-tight text-foreground">{formTemplate.name}</h1>
                <p className="text-[10px] uppercase tracking-wider font-bold text-muted-foreground/80">
                  Formulário {isFormPublic ? "Público" : "de Vida Comum"}
                </p>
              </div>
            </div>
            {formTemplate.description && (
              <p className="text-muted-foreground text-sm leading-relaxed pt-2">
                {formTemplate.description}
              </p>
            )}
          </div>
          
          <form onSubmit={handleSubmit} className="space-y-12">
            {(() => {
              const visibleFields = formTemplate.fields.filter(field => 
                isFieldVisible(field, formData, formTemplate.fields)
              );

              return visibleFields.map((field, idx) => {
                const hasError = !!formErrors[field.id];
                const errorMsg = formErrors[field.id];
                
                return (
                  <div key={field.id} className="space-y-3">
                    <label className="text-base md:text-lg font-semibold text-foreground flex items-start gap-3">
                      <span className="flex-shrink-0 flex items-center justify-center w-7 h-7 rounded-full bg-primary/5 text-primary border border-primary/10 text-xs font-bold mt-0.5 md:mt-1">
                        {idx + 1}
                      </span>
                      <div className="pt-0.5 flex-1">
                        <span>{field.label || "Campo sem nome"}</span>
                        {field.required && <span className="text-destructive font-bold text-xs ml-1" title="Obrigatório">*</span>}
                      </div>
                    </label>

                    {/* TEXT INPUT */}
                    {field.type === 'text' && (
                      <Input
                        value={formData[field.id] || ""}
                        onChange={(e) => handleInputChange(field.id, e.target.value)}
                        placeholder={field.placeholder}
                        className={`h-12 text-base px-4 rounded-md bg-muted/30 focus-visible:ring-primary/20 ${hasError ? 'border-destructive focus-visible:ring-destructive/20' : 'border-border/60'}`}
                      />
                    )}

                    {/* TEXTAREA INPUT */}
                    {field.type === 'textarea' && (
                      <Textarea
                        value={formData[field.id] || ""}
                        onChange={(e) => handleInputChange(field.id, e.target.value)}
                        placeholder={field.placeholder}
                        className={`min-h-[120px] text-base px-4 py-3 rounded-md bg-muted/30 focus-visible:ring-primary/20 ${hasError ? 'border-destructive focus-visible:ring-destructive/20' : 'border-border/60'}`}
                      />
                    )}

                    {/* NUMBER INPUT */}
                    {field.type === 'number' && (
                      <Input
                        type="number"
                        value={formData[field.id] || ""}
                        onChange={(e) => handleInputChange(field.id, e.target.value)}
                        placeholder={field.placeholder}
                        className={`h-12 text-base px-4 rounded-md bg-muted/30 focus-visible:ring-primary/20 ${hasError ? 'border-destructive focus-visible:ring-destructive/20' : 'border-border/60'}`}
                      />
                    )}

                    {/* SELECT INPUT */}
                    {field.type === 'select' && (
                      <div className="relative">
                        <select
                          value={formData[field.id] || ""}
                          onChange={(e) => handleInputChange(field.id, e.target.value)}
                          className={`flex h-12 w-full rounded-md border bg-muted/30 px-4 py-2 text-base focus:ring-2 focus:ring-primary/20 focus:border-primary/50 transition-all outline-none appearance-none ${hasError ? 'border-destructive focus-visible:ring-destructive/20' : 'border-border/60'}`}
                        >
                          <option value="" disabled>{field.placeholder || "Selecione uma opção..."}</option>
                          {field.options.map((opt, oIdx) => (
                            <option key={oIdx} value={opt}>{opt}</option>
                          ))}
                        </select>
                        <ChevronsUpDown className="w-4 h-4 text-muted-foreground absolute right-4 top-1/2 -translate-y-1/2 pointer-events-none" />
                      </div>
                    )}

                    {/* CHECKBOX (MULTI SELECTION) */}
                    {field.type === 'checkbox' && (
                      <div className="space-y-3 pt-1">
                        {field.options.map((opt, oIdx) => {
                          const isChecked = (formData[field.id] || []).includes(opt);
                          return (
                            <label 
                              key={oIdx} 
                              className="flex items-center gap-3 p-3 rounded-lg border border-border/40 hover:bg-muted/30 cursor-pointer transition-all select-none min-h-[46px]"
                            >
                              <input
                                type="checkbox"
                                id={`responder-opt-${field.id}-${oIdx}`}
                                checked={isChecked}
                                onChange={(e) => handleCheckboxChange(field.id, opt, e.target.checked)}
                                className="h-5 w-5 rounded border-zinc-300 dark:border-zinc-700 text-primary focus:ring-primary/20 cursor-pointer shrink-0"
                              />
                              <span className="text-base font-medium text-foreground">
                                {opt}
                              </span>
                            </label>
                          );
                        })}
                      </div>
                    )}

                    {/* RADIO (SINGLE SELECTION) */}
                    {field.type === 'radio' && (
                      <div className="space-y-3 pt-1">
                        {field.options.map((opt, oIdx) => {
                          const isSelected = formData[field.id] === opt;
                          return (
                            <label 
                              key={oIdx} 
                              className="flex items-center gap-3 p-3 rounded-lg border border-border/40 hover:bg-muted/30 cursor-pointer transition-all select-none min-h-[46px]"
                            >
                              <input
                                type="radio"
                                name={`responder-radio-group-${field.id}`}
                                id={`responder-opt-${field.id}-${oIdx}`}
                                checked={isSelected}
                                onChange={() => handleInputChange(field.id, opt)}
                                className="h-5 w-5 border-zinc-300 dark:border-zinc-700 text-primary focus:ring-primary/20 cursor-pointer shrink-0"
                              />
                              <span className="text-base font-medium text-foreground">
                                {opt}
                              </span>
                            </label>
                          );
                        })}
                      </div>
                    )}

                    {/* DATE INPUT */}
                    {field.type === 'date' && (
                      <Input
                        type="date"
                        value={formData[field.id] || ""}
                        onChange={(e) => handleInputChange(field.id, e.target.value)}
                        className={`h-12 text-base px-4 rounded-md bg-muted/30 focus-visible:ring-primary/20 ${hasError ? 'border-destructive focus-visible:ring-destructive/20' : 'border-border/60'}`}
                      />
                    )}

                    {field.helpText && !hasError && (
                      <p className="text-xs text-muted-foreground/80 pl-10 leading-normal">{field.helpText}</p>
                    )}

                    {hasError && (
                      <p className="text-xs font-semibold text-destructive animate-in fade-in duration-200 pl-10">{errorMsg}</p>
                    )}
                  </div>
                );
              });
            })()}

            <div className="pt-6 border-t border-border/40">
              <Button
                type="submit"
                className="w-full bg-primary hover:bg-primary/90 text-primary-foreground font-bold h-12 rounded-md transition-all shadow-md shadow-primary/10 active:scale-[0.98] cursor-pointer"
              >
                Enviar Resposta
              </Button>
            </div>
          </form>
        </div>
      )}
    </div>
  );

  if (user) {
    return <Layout>{formContent}</Layout>;
  }

  return (
    <div className="min-h-screen bg-zinc-50 dark:bg-zinc-950 transition-colors duration-300">
      <header className="border-b border-border/40 bg-card/50 backdrop-blur-md sticky top-0 z-50">
        <div className="max-w-2xl mx-auto px-4 h-16 flex items-center justify-between">
          <div className="flex items-center gap-2 select-none">
            <span className="font-bold text-foreground tracking-tight">O Corpo</span>
            <span className="text-[10px] bg-zinc-200 dark:bg-zinc-800 text-zinc-700 dark:text-zinc-300 px-2 py-0.5 rounded-full font-bold uppercase">
              BH
            </span>
          </div>
          <ThemeToggle />
        </div>
      </header>
      <main className="py-4">
        {formContent}
      </main>
    </div>
  );
}
