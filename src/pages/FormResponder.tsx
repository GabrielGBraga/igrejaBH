import { useState, useEffect } from "react";
import { useParams, Link } from "react-router-dom";
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
import { isFieldVisible } from "./FormBuilder";
import type { FormTemplate, FormSubmission } from "./FormBuilder";

export default function FormResponder() {
  const { formId } = useParams<{ formId: string }>();
  
  const [formTemplate, setFormTemplate] = useState<FormTemplate | null>(null);
  const [loading, setLoading] = useState(true);
  const [formData, setFormData] = useState<Record<string, any>>({});
  const [formErrors, setFormErrors] = useState<Record<string, string>>({});
  const [submitted, setSubmitted] = useState(false);
  const [canPost, setCanPost] = useState(false);

  // Check user permission on load
  useEffect(() => {
    async function checkPermission() {
      try {
        const { data: { session } } = await supabase.auth.getSession();
        if (session?.user) {
          const { data: profileData } = await supabase
            .from("profiles")
            .select("is_dev, is_presbyter, can_post")
            .eq("user_id", session.user.id)
            .single();
          
          if (profileData) {
            setCanPost(!!(profileData.is_dev || profileData.is_presbyter || profileData.can_post));
          }
        }
      } catch (err) {
        console.error("Error checking permissions", err);
      }
    }
    checkPermission();
  }, []);

  // Load the specific form template from LocalStorage
  useEffect(() => {
    setLoading(true);
    const savedForms = localStorage.getItem("church-forms");
    if (savedForms && formId) {
      try {
        const parsed: FormTemplate[] = JSON.parse(savedForms);
        const found = parsed.find(f => f.id === formId);
        if (found) {
          setFormTemplate(found);
        }
      } catch (e) {
        console.error("Error loading shared form template", e);
      }
    }
    setLoading(false);
  }, [formId]);

  // Handle standard input updates
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
    
    // Validate inputs
    const errors: Record<string, string> = {};
    formTemplate.fields.forEach(field => {
      // Only validate if field is visible
      if (!isFieldVisible(field, formData, formTemplate.fields)) return;

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
    const filteredData: Record<string, any> = {};
    formTemplate.fields.forEach(field => {
      if (isFieldVisible(field, formData, formTemplate.fields) && formData[field.id] !== undefined) {
        filteredData[field.id] = formData[field.id];
      }
    });

    // Save submission locally
    try {
      const savedSubmissions = localStorage.getItem("church-form-submissions") || "{}";
      const submissionsDict: Record<string, FormSubmission[]> = JSON.parse(savedSubmissions);
      
      const newSubmission: FormSubmission = {
        id: `sub-${Math.random().toString(36).substring(7)}`,
        formId: formTemplate.id,
        submittedAt: new Date().toISOString(),
        data: filteredData
      };

      const currentFormSubs = submissionsDict[formTemplate.id] || [];
      submissionsDict[formTemplate.id] = [newSubmission, ...currentFormSubs];

      localStorage.setItem("church-form-submissions", JSON.stringify(submissionsDict));
      
      setSubmitted(true);
      toast.success("Resposta enviada com sucesso!");
    } catch (e) {
      console.error("Error saving form response", e);
      toast.error("Ocorreu um erro ao enviar suas respostas. Tente novamente.");
    }
  };

  const handleReset = () => {
    setFormData({});
    setFormErrors({});
    setSubmitted(false);
  };

  if (loading) {
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

  return (
    <div className="max-w-2xl mx-auto py-8 px-4 animate-in fade-in slide-in-from-bottom-4 duration-500">
      
      {/* HEADER NAVIGATION */}
      <div className="mb-8">
        <Button asChild variant="ghost" className="text-muted-foreground hover:text-foreground cursor-pointer -ml-4">
          <Link to={canPost ? "/gestao/formularios" : "/"} className="flex items-center gap-2">
            <ArrowLeft className="w-4 h-4" />
            {canPost ? "Voltar para Formulários" : "Voltar para o Início"}
          </Link>
        </Button>
      </div>

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
            <Button asChild className="w-full h-11 bg-primary hover:bg-primary/90 text-primary-foreground font-bold rounded-md cursor-pointer text-sm">
              <Link to={canPost ? "/gestao/formularios" : "/"}>Concluir</Link>
            </Button>
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
                  Formulário de Vida Comum
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
}
