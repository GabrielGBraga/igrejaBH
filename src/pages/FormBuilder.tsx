import { useState, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import { isFieldVisible, formatValue, isValidCPF, isValidPhone, fetchAddressFromCep } from "@/lib/forms";
import type { FormField, FormTemplate, FormSubmission } from "@/lib/forms";
import { 
  Plus, 
  Trash2, 
  ClipboardList, 
  Edit, 
  Copy, 
  Eye, 
  EyeOff, 
  X, 
  Save, 
  CheckCircle, 
  ArrowLeft, 
  FileText, 
  ChevronsUpDown, 
  AlignLeft, 
  Type, 
  Hash, 
  CheckSquare, 
  Radio, 
  Calendar,
  Layers,
  Download,
  Upload,
  Share2,
  GripVertical
} from "lucide-react";
import { Card, CardContent, CardDescription, CardHeader, CardTitle, CardFooter } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import { Textarea } from "@/components/ui/textarea";
import { toast } from "sonner";
import supabase from "@/lib/supabase";
import { Skeleton } from "@/components/ui/skeleton";
import {
  DndContext,
  closestCenter,
  KeyboardSensor,
  PointerSensor,
  useSensor,
  useSensors
} from '@dnd-kit/core';
import type { DragEndEvent } from '@dnd-kit/core';
import {
  arrayMove,
  SortableContext,
  sortableKeyboardCoordinates,
  verticalListSortingStrategy,
  useSortable
} from '@dnd-kit/sortable';
import { CSS } from '@dnd-kit/utilities';
import {
  Popover,
  PopoverTrigger,
  PopoverContent
} from "@/components/ui/popover";







// Unique ID generators defined outside the component for React rendering purity
const generateFormId = () => `form-${Math.random().toString(36).substring(7)}`;
const generateFieldId = () => `field-${Math.random().toString(36).substring(7)}`;
const generateSubId = () => `sub-${Math.random().toString(36).substring(7)}`;

// Map Supabase public.forms Row to FormTemplate
// eslint-disable-next-line @typescript-eslint/no-explicit-any
const mapDbFormToTemplate = (dbForm: any): FormTemplate => {
  return {
    id: dbForm.id,
    name: dbForm.name,
    description: dbForm.description || "",
    fields: (dbForm.fields as FormField[]) || [],
    createdAt: dbForm.created_at,
    isPublic: dbForm.is_public
  };
};

// Map Supabase public.form_submissions Row to FormSubmission
// eslint-disable-next-line @typescript-eslint/no-explicit-any
const mapDbSubmission = (dbSub: any): FormSubmission => {
  return {
    id: dbSub.id,
    formId: dbSub.form_id,
    submittedAt: dbSub.submitted_at,
    data: dbSub.data as Record<string, any>
  };
};

export default function FormBuilder() {
  const navigate = useNavigate();

  // Page core states
  const [forms, setForms] = useState<FormTemplate[]>([]);
  const [submissions, setSubmissions] = useState<Record<string, FormSubmission[]>>({});
  const [loading, setLoading] = useState(true);
  
  // Navigation and active view states
  const [currentView, setCurrentView] = useState<'list' | 'builder'>('list');
  const [selectedForm, setSelectedForm] = useState<FormTemplate | null>(null);
  
  // Builder panel states
  const [editingFieldId, setEditingFieldId] = useState<string | null>(null);
  const [builderTab, setBuilderTab] = useState<'edit' | 'preview' | 'json'>('edit');
  const [newOptionTexts, setNewOptionTexts] = useState<Record<string, string>>({});
  const [showPreview, setShowPreview] = useState(true);

  // Load forms and submissions from Supabase on mount
  useEffect(() => {
    async function loadData() {
      try {
        setLoading(true);
        // Fetch forms from database
        const { data: dbForms, error: formsError } = await supabase
          .from("forms")
          .select("*")
          .order("created_at", { ascending: false });

        if (formsError) throw formsError;

        const mappedForms = (dbForms || []).map(mapDbFormToTemplate);
        setForms(mappedForms);

        // Fetch submissions from database
        const { data: dbSubs, error: subsError } = await supabase
          .from("form_submissions")
          .select("*")
          .order("submitted_at", { ascending: false });

        if (subsError) {
          console.error("Error loading submissions from Supabase:", subsError);
        }

        const subsGrouped: Record<string, FormSubmission[]> = {};
        if (dbSubs) {
          dbSubs.forEach(sub => {
            const mapped = mapDbSubmission(sub);
            if (!subsGrouped[mapped.formId]) {
              subsGrouped[mapped.formId] = [];
            }
            subsGrouped[mapped.formId].push(mapped);
          });
        }
        setSubmissions(subsGrouped);
      } catch (err) {
        console.error("Error loading forms from Supabase:", err);
        toast.error("Erro ao carregar formulários do banco de dados.");
      } finally {
        setLoading(false);
      }
    }

    loadData();
  }, []);

  // Notion-style Click Outside to collapse active editor card
  useEffect(() => {
    function handleClickOutside(event: MouseEvent) {
      const target = event.target as HTMLElement;
      if (editingFieldId) {
        const activeElement = document.getElementById(`editor-card-${editingFieldId}`);
        const isPopoverOrDropdown = target.closest('[data-slot="popover-content"]') || 
                                    target.closest('[data-radix-popper-content-wrapper]') ||
                                    target.closest('[role="menu"]') ||
                                    target.closest('[role="listbox"]') ||
                                    target.closest('.toast') ||
                                    target.closest('.sonner-toast');
        if (activeElement && !activeElement.contains(target) && !isPopoverOrDropdown) {
          setEditingFieldId(null);
        }
      }
    }

    document.addEventListener("mousedown", handleClickOutside);
    return () => {
      document.removeEventListener("mousedown", handleClickOutside);
    };
  }, [editingFieldId]);

  // Submissions list modal states
  const [viewingSubmissionsFormId, setViewingSubmissionsFormId] = useState<string | null>(null);

  // Live preview form submission state
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  const [previewFormData, setPreviewFormData] = useState<Record<string, any>>({});
  const [previewFormErrors, setPreviewFormErrors] = useState<Record<string, string>>({});

  const sensors = useSensors(
    useSensor(PointerSensor),
    useSensor(KeyboardSensor, {
      coordinateGetter: sortableKeyboardCoordinates,
    })
  );

  // Share link copy function
  const handleShareLink = (form: FormTemplate, e: React.MouseEvent) => {
    e.stopPropagation();
    const shareUrl = `${window.location.origin}/formularios/responder/${form.id}`;
    navigator.clipboard.writeText(shareUrl);
    toast.success("Link do formulário copiado para a área de transferência!");
  };

  // Create a new empty form
  const handleCreateNewForm = () => {
    const newForm: FormTemplate = {
      id: generateFormId(),
      name: "Novo Formulário",
      description: "Descreva a finalidade deste formulário para os irmãos e discípulos.",
      createdAt: new Date().toISOString(),
      isPublic: false,
      fields: [
        {
          id: generateFieldId(),
          type: "text",
          label: "Nome Completo",
          placeholder: "Digite seu nome",
          required: true,
          helpText: "",
          options: []
        }
      ]
    };

    setSelectedForm(newForm);
    setEditingFieldId(newForm.fields[0].id);
    setCurrentView('builder');
    setBuilderTab('edit');
    setPreviewFormData({});
    setPreviewFormErrors({});
  };

  // Edit existing form
  const handleEditForm = (form: FormTemplate) => {
    // Clone deep to avoid mutating local state until saved
    setSelectedForm(JSON.parse(JSON.stringify(form)));
    setCurrentView('builder');
    setBuilderTab('edit');
    setEditingFieldId(form.fields.length > 0 ? form.fields[0].id : null);
    setPreviewFormData({});
    setPreviewFormErrors({});
  };

  // Save the form template
  const handleSaveForm = async () => {
    if (!selectedForm) return;

    if (!selectedForm.name.trim()) {
      toast.error("O nome do formulário é obrigatório.");
      return;
    }

    if (selectedForm.fields.length === 0) {
      toast.error("Adicione pelo menos um campo ao formulário.");
      return;
    }

    // Verify fields have labels
    const emptyLabelField = selectedForm.fields.find(f => !f.label.trim());
    if (emptyLabelField) {
      toast.error("Todos os campos devem ter um título (Label) definido.");
      setEditingFieldId(emptyLabelField.id);
      setBuilderTab('edit');
      return;
    }

    // Verify option fields have options
    const optionFieldWithNoOptions = selectedForm.fields.find(
      f => ['select', 'checkbox', 'radio'].includes(f.type) && f.options.length === 0
    );
    if (optionFieldWithNoOptions) {
      toast.error(`O campo "${optionFieldWithNoOptions.label}" precisa de pelo menos uma opção.`);
      setEditingFieldId(optionFieldWithNoOptions.id);
      setBuilderTab('edit');
      return;
    }

    try {
      const savingToastId = toast.loading("Salvando formulário no banco de dados...");
      const { data: { session } } = await supabase.auth.getSession();
      
      const { error } = await supabase
        .from("forms")
        .upsert({
          id: selectedForm.id,
          name: selectedForm.name,
          description: selectedForm.description || null,
          fields: selectedForm.fields as any,
          is_public: !!selectedForm.isPublic,
          created_by: session?.user?.id || null
        });

      if (error) throw error;
      toast.dismiss(savingToastId);

      const index = forms.findIndex(f => f.id === selectedForm.id);
      let updated: FormTemplate[];

      if (index >= 0) {
        // Update existing
        updated = [...forms];
        updated[index] = selectedForm;
        toast.success("Formulário atualizado com sucesso!");
      } else {
        // Add new
        updated = [selectedForm, ...forms];
        toast.success("Novo formulário criado com sucesso!");
      }

      setForms(updated);
      setCurrentView('list');
      setSelectedForm(null);
    } catch (err: any) {
      console.error("Error saving form to Supabase:", err);
      toast.error(`Falha ao salvar formulário: ${err.message || "Erro desconhecido"}`);
    }
  };

  // Duplicate a form
  const handleDuplicateForm = async (form: FormTemplate, e: React.MouseEvent) => {
    e.stopPropagation();
    const duplicated: FormTemplate = {
      ...form,
      id: generateFormId(),
      name: `${form.name} (Cópia)`,
      createdAt: new Date().toISOString()
    };
    
    try {
      const savingToastId = toast.loading("Duplicando formulário...");
      const { data: { session } } = await supabase.auth.getSession();
      
      const { error } = await supabase
        .from("forms")
        .insert({
          id: duplicated.id,
          name: duplicated.name,
          description: duplicated.description || null,
          fields: duplicated.fields as any,
          is_public: !!duplicated.isPublic,
          created_by: session?.user?.id || null
        });

      if (error) throw error;
      toast.dismiss(savingToastId);
      
      const updated = [duplicated, ...forms];
      setForms(updated);
      toast.success("Formulário duplicado!");
    } catch (err: any) {
      console.error("Error duplicating form:", err);
      toast.error(`Falha ao duplicar formulário: ${err.message}`);
    }
  };

  // Delete a form
  const handleDeleteForm = async (formId: string, e: React.MouseEvent) => {
    e.stopPropagation();
    if (confirm("Tem certeza que deseja excluir este formulário? Isso também apagará todas as respostas salvas.")) {
      try {
        const deletingToastId = toast.loading("Excluindo formulário...");
        const { error } = await supabase
          .from("forms")
          .delete()
          .eq("id", formId);

        if (error) throw error;
        toast.dismiss(deletingToastId);

        const updatedForms = forms.filter(f => f.id !== formId);
        setForms(updatedForms);
        
        const updatedSubmissions = { ...submissions };
        delete updatedSubmissions[formId];
        setSubmissions(updatedSubmissions);

        toast.success("Formulário excluído.");
      } catch (err: any) {
        console.error("Error deleting form:", err);
        toast.error(`Falha ao excluir formulário: ${err.message}`);
      }
    }
  };

  // Export form schema as JSON file/clipboard
  const handleExportJSON = (form: FormTemplate, e: React.MouseEvent) => {
    e.stopPropagation();
    const schema = JSON.stringify(form, null, 2);
    navigator.clipboard.writeText(schema);
    toast.success("Esquema do formulário copiado como JSON!");
  };

  // Import form schema from clipboard JSON
  const handleImportJSON = async () => {
    const input = prompt("Cole o JSON do esquema do formulário aqui:");
    if (!input) return;

    try {
      const parsed = JSON.parse(input);
      if (!parsed.name || !Array.isArray(parsed.fields)) {
        toast.error("JSON inválido: Estrutura do formulário incompleta.");
        return;
      }

      const imported: FormTemplate = {
        id: generateFormId(),
        name: parsed.name + " (Importado)",
        description: parsed.description || "",
        createdAt: new Date().toISOString(),
        isPublic: !!parsed.isPublic,
        fields: parsed.fields.map((f: { id?: string; type?: FormField['type']; label?: string; placeholder?: string; required?: boolean; helpText?: string; options?: string[] }) => ({
          id: f.id || generateFieldId(),
          type: f.type || "text",
          label: f.label || "Campo sem nome",
          placeholder: f.placeholder || "",
          required: !!f.required,
          helpText: f.helpText || "",
          options: Array.isArray(f.options) ? f.options : []
        }))
      };

      const savingToastId = toast.loading("Importando formulário...");
      const { data: { session } } = await supabase.auth.getSession();
      
      const { error } = await supabase
        .from("forms")
        .insert({
          id: imported.id,
          name: imported.name,
          description: imported.description || null,
          fields: imported.fields as any,
          is_public: !!imported.isPublic,
          created_by: session?.user?.id || null
        });

      if (error) throw error;
      toast.dismiss(savingToastId);

      const updated = [imported, ...forms];
      setForms(updated);
      toast.success("Formulário importado com sucesso!");
    } catch (err: any) {
      console.error("Error importing JSON:", err);
      toast.error(`Falha ao importar JSON: ${err.message || "Verifique a formatação do JSON."}`);
    }
  };

  // Add field to the template editor
  const handleAddField = (type: FormField['type'], insertIndex?: number) => {
    if (!selectedForm) return;

    const newField: FormField = {
      id: generateFieldId(),
      type,
      label: `Novo Campo de ${
        type === 'text' ? 'Texto' :
        type === 'textarea' ? 'Texto Longo' :
        type === 'number' ? 'Número' :
        type === 'select' ? 'Seleção' :
        type === 'checkbox' ? 'Múltipla Escolha' :
        type === 'radio' ? 'Escolha Única' : 'Data'
      }`,
      placeholder: type === 'date' ? '' : 'Digite sua resposta...',
      required: false,
      helpText: "",
      options: ['select', 'checkbox', 'radio'].includes(type) ? ['Opção 1', 'Opção 2'] : []
    };

    const updatedFields = [...selectedForm.fields];
    if (typeof insertIndex === 'number') {
      updatedFields.splice(insertIndex, 0, newField);
    } else {
      updatedFields.push(newField);
    }

    setSelectedForm({
      ...selectedForm,
      fields: updatedFields
    });
    setEditingFieldId(newField.id);
    toast.success("Campo adicionado!");
  };

  // Remove field from the template editor
  const handleRemoveField = (fieldId: string) => {
    if (!selectedForm) return;
    const updatedFields = selectedForm.fields.filter(f => f.id !== fieldId);
    setSelectedForm({
      ...selectedForm,
      fields: updatedFields
    });
    if (editingFieldId === fieldId) {
      setEditingFieldId(updatedFields.length > 0 ? updatedFields[0].id : null);
    }
    toast.info("Campo removido.");
  };


  // Drag and drop end event handler
  const handleDragEnd = (event: DragEndEvent) => {
    const { active, over } = event;
    if (!selectedForm || !over || active.id === over.id) return;

    const oldIndex = selectedForm.fields.findIndex((f) => f.id === active.id);
    const newIndex = selectedForm.fields.findIndex((f) => f.id === over.id);

    if (oldIndex !== -1 && newIndex !== -1) {
      const newFields = arrayMove(selectedForm.fields, oldIndex, newIndex);
      setSelectedForm({ ...selectedForm, fields: newFields });
    }
  };

  // Duplicate a field inside the builder canvas
  const handleDuplicateField = (fieldId: string) => {
    if (!selectedForm) return;
    const fieldIndex = selectedForm.fields.findIndex(f => f.id === fieldId);
    if (fieldIndex === -1) return;
    const originalField = selectedForm.fields[fieldIndex];
    const duplicatedField: FormField = {
      ...originalField,
      id: generateFieldId(),
      label: originalField.label ? `${originalField.label} (Cópia)` : "Campo sem nome (Cópia)"
    };
    const fields = [...selectedForm.fields];
    fields.splice(fieldIndex + 1, 0, duplicatedField);
    setSelectedForm({ ...selectedForm, fields });
    toast.success("Campo duplicado com sucesso!");
  };

  // Update field property
  const handleUpdateField = (fieldId: string, updates: Partial<FormField>) => {
    if (!selectedForm) return;
    const fields = selectedForm.fields.map(f => {
      if (f.id === fieldId) {
        return { ...f, ...updates };
      }
      return f;
    });
    setSelectedForm({ ...selectedForm, fields });
  };

  // Add option to choice field (select, checkbox, radio)
  const handleAddOption = (fieldId: string, text: string) => {
    if (!text || !text.trim()) {
      toast.error("Escreva o texto da opção.");
      return;
    }

    const trimmed = text.trim();

    if (!selectedForm) return;
    const fields = selectedForm.fields.map(f => {
      if (f.id === fieldId) {
        if (f.options.includes(trimmed)) {
          toast.error("Essa opção já existe.");
          return f;
        }
        return { ...f, options: [...f.options, trimmed] };
      }
      return f;
    });

    setSelectedForm({ ...selectedForm, fields });
    setNewOptionTexts(prev => ({ ...prev, [fieldId]: "" }));
    toast.success("Opção adicionada!");
  };

  // Remove option from choice field
  const handleRemoveOption = (fieldId: string, optionIndex: number) => {
    if (!selectedForm) return;
    const fields = selectedForm.fields.map(f => {
      if (f.id === fieldId) {
        const options = f.options.filter((_, i) => i !== optionIndex);
        return { ...f, options };
      }
      return f;
    });
    setSelectedForm({ ...selectedForm, fields });
    toast.info("Opção removida.");
  };

  // Handle preview form value inputs
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  const handlePreviewInputChange = async (fieldId: string, val: any) => {
    if (!selectedForm) return;
    const targetField = selectedForm.fields.find(f => f.id === fieldId);
    let formattedVal = val;
    if (targetField && targetField.type === 'text') {
      formattedVal = formatValue(val, targetField.validationPreset);
    }

    setPreviewFormData(prev => ({
      ...prev,
      [fieldId]: formattedVal
    }));
    
    // Clear error once answered
    if (previewFormErrors[fieldId]) {
      setPreviewFormErrors(prev => {
        const copy = { ...prev };
        delete copy[fieldId];
        return copy;
      });
    }

    // Trigger CEP Lookup in preview mode
    if (targetField && targetField.type === 'text' && targetField.validationPreset === 'cep') {
      const cleanCep = formattedVal.replace(/\D/g, "");
      if (cleanCep.length === 8) {
        try {
          const toastId = toast.loading("Buscando CEP (Simulação)...");
          const address = await fetchAddressFromCep(cleanCep);
          toast.dismiss(toastId);

          if (address) {
            if (address.error) {
              toast.error("CEP não encontrado.");
              setPreviewFormErrors(prev => ({
                ...prev,
                [fieldId]: "CEP não encontrado."
              }));
              return;
            }

            toast.success(`CEP encontrado: ${address.logradouro || ""}, ${address.bairro || ""} - ${address.localidade}/${address.uf}`);
            
            const hasExplicitMapping = !!(
              targetField.cepMapping?.streetFieldId ||
              targetField.cepMapping?.neighborhoodFieldId ||
              targetField.cepMapping?.cityFieldId ||
              targetField.cepMapping?.stateFieldId
            );

            setPreviewFormData(prev => {
              const nextFormData = { ...prev };
              selectedForm.fields.forEach(f => {
                if (f.id === fieldId) return;
                if (f.type !== 'text' && f.type !== 'textarea') return;

                if (hasExplicitMapping) {
                  if (targetField.cepMapping?.streetFieldId === f.id) {
                    nextFormData[f.id] = address.logradouro || "";
                  } else if (targetField.cepMapping?.neighborhoodFieldId === f.id) {
                    nextFormData[f.id] = address.bairro || "";
                  } else if (targetField.cepMapping?.cityFieldId === f.id) {
                    nextFormData[f.id] = address.localidade || "";
                  } else if (targetField.cepMapping?.stateFieldId === f.id) {
                    nextFormData[f.id] = address.uf || "";
                  }
                } else {
                  const label = (f.label || "").toLowerCase();
                  if (label.includes("rua") || label.includes("logradouro") || label.includes("endereço") || label.includes("endereco")) {
                    if (!nextFormData[f.id]) nextFormData[f.id] = address.logradouro || "";
                  } else if (label.includes("bairro")) {
                    if (!nextFormData[f.id]) nextFormData[f.id] = address.bairro || "";
                  } else if (label.includes("cidade") || label.includes("município") || label.includes("municipio")) {
                    if (!nextFormData[f.id]) nextFormData[f.id] = address.localidade || "";
                  } else if (label.includes("estado") || label.includes("uf")) {
                    if (!nextFormData[f.id]) nextFormData[f.id] = address.uf || "";
                  }
                }
              });
              return nextFormData;
            });
          } else {
            toast.error("Não foi possível validar o CEP (serviço indisponível).");
          }
        } catch (err) {
          console.error("CEP lookup failed in preview", err);
        }
      }
    }
  };

  // Handle multi-checkbox previews
  const handlePreviewCheckboxChange = (fieldId: string, option: string, isChecked: boolean) => {
    const currentList = previewFormData[fieldId] || [];
    let updatedList;
    if (isChecked) {
      updatedList = [...currentList, option];
    } else {
      updatedList = currentList.filter((x: string) => x !== option);
    }
    
    handlePreviewInputChange(fieldId, updatedList);
  };

  // Submit the preview form response locally
  const handlePreviewSubmit = (e: React.FormEvent, formTemplate: FormTemplate) => {
    e.preventDefault();
    
    // Validate inputs
    const errors: Record<string, string> = {};
    formTemplate.fields.forEach(field => {
      // Only validate if field is visible
      if (!isFieldVisible(field, previewFormData, formTemplate.fields)) return;

      const val = previewFormData[field.id];
      
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
        const strVal = String(val).trim();

        if (['text', 'textarea'].includes(field.type)) {
          // Character range check
          if (field.minLength !== undefined && strVal.length < field.minLength) {
            errors[field.id] = `O texto deve ter no mínimo ${field.minLength} caracteres.`;
          }
          if (field.maxLength !== undefined && strVal.length > field.maxLength) {
            errors[field.id] = `O texto deve ter no máximo ${field.maxLength} caracteres.`;
          }

          // Preset validation
          if (field.validationPreset && field.validationPreset !== 'none') {
            if (field.validationPreset === 'phone') {
              if (!isValidPhone(strVal)) {
                errors[field.id] = "Telefone celular inválido. Digite um DDD válido e o dígito 9 antes do número.";
              }
            } else if (field.validationPreset === 'cpf') {
              if (!isValidCPF(strVal)) {
                errors[field.id] = "CPF inválido. Insira um número de CPF válido.";
              }
            } else if (field.validationPreset === 'cep') {
              const cepRegex = /^\d{5}-?\d{3}$/;
              if (!cepRegex.test(strVal)) {
                errors[field.id] = "CEP inválido. Formato esperado: 30123-456";
              } else if (previewFormErrors[field.id] === "CEP não encontrado.") {
                errors[field.id] = "CEP não encontrado.";
              }
            } else if (field.validationPreset === 'email') {
              const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
              if (!emailRegex.test(strVal)) {
                errors[field.id] = "E-mail inválido. Formato esperado: exemplo@email.com";
              }
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
      setPreviewFormErrors(errors);
      toast.error("Por favor, corrija os erros de validação antes de enviar.");
      return;
    }

    // Filter values for invisible fields to avoid sending trash data
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const filteredData: Record<string, any> = {};
    formTemplate.fields.forEach(field => {
      if (isFieldVisible(field, previewFormData, formTemplate.fields) && previewFormData[field.id] !== undefined) {
        filteredData[field.id] = previewFormData[field.id];
      }
    });

    // Process submission
    const newSubmission: FormSubmission = {
      id: generateSubId(),
      formId: formTemplate.id,
      submittedAt: new Date().toISOString(),
      data: filteredData
    };

    const currentFormSubs = submissions[formTemplate.id] || [];
    const updatedSubmissions = {
      ...submissions,
      [formTemplate.id]: [newSubmission, ...currentFormSubs]
    };

    setSubmissions(updatedSubmissions);
    toast.success("Resposta enviada e registrada com sucesso (Simulação)!");
    
    // Clear preview fields
    setPreviewFormData({});
    setPreviewFormErrors({});
  };

  // Clear all submissions for a form
  const handleClearSubmissions = async (formId: string) => {
    if (confirm("Tem certeza que deseja apagar TODAS as respostas registradas para este formulário?")) {
      try {
        const clearingToastId = toast.loading("Apagando respostas do banco de dados...");
        const { error } = await supabase
          .from("form_submissions")
          .delete()
          .eq("form_id", formId);

        if (error) throw error;
        toast.dismiss(clearingToastId);

        const updated = { ...submissions };
        delete updated[formId];
        setSubmissions(updated);
        toast.success("Respostas apagadas.");
      } catch (err: any) {
        console.error("Error clearing submissions:", err);
        toast.error(`Falha ao apagar respostas: ${err.message}`);
      }
    }
  };

  // Helper to format timestamps
  const formatDate = (isoString: string) => {
    return new Date(isoString).toLocaleDateString("pt-BR", {
      day: "2-digit",
      month: "2-digit",
      year: "numeric",
      hour: "2-digit",
      minute: "2-digit"
    });
  };

  return (
    <div className="space-y-8 animate-in fade-in slide-in-from-bottom-4 duration-500 pb-12">
      
      {/* VIEW A: LIST / DASHBOARD */}
      {currentView === 'list' && (
        <>
          <header className="flex flex-col md:flex-row md:items-center justify-between gap-6 pb-6 border-b border-border">
            <div>
              <h1 className="text-3xl font-bold tracking-tight text-foreground flex items-center gap-3">
                <ClipboardList className="w-8 h-8 text-primary" />
                Gerenciador de Formulários
              </h1>
              <p className="text-muted-foreground mt-1">
                Crie e configure formulários dinâmicos para a vida comunitária, pesquisas e registros de PG.
              </p>
            </div>
            
            <div className="flex gap-3">
              <Button 
                onClick={handleImportJSON}
                variant="outline"
                className="h-11 rounded-md border-border/80 hover:bg-accent cursor-pointer active:scale-95 transition-all"
              >
                <Upload className="w-4 h-4 mr-2" />
                Importar JSON
              </Button>
              
              <Button 
                onClick={handleCreateNewForm}
                className="bg-primary hover:bg-primary/90 text-primary-foreground font-bold h-11 px-5 rounded-md cursor-pointer shadow-sm active:scale-95 transition-all"
              >
                <Plus className="w-5 h-5 mr-2" />
                Novo Formulário
              </Button>
            </div>
          </header>

          {/* Grid of Forms */}
          {loading ? (
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
              {[1, 2, 3].map((n) => (
                <Card key={n} className="border-border/50 bg-card/30 backdrop-blur-sm shadow-sm rounded-xl overflow-hidden h-[220px] flex flex-col justify-between p-6">
                  <div className="space-y-3">
                    <Skeleton className="h-6 w-2/3" />
                    <Skeleton className="h-4 w-1/3" />
                    <Skeleton className="h-4 w-full mt-4" />
                    <Skeleton className="h-4 w-5/6" />
                  </div>
                  <div className="flex justify-between items-center mt-6">
                    <div className="flex gap-2">
                      <Skeleton className="h-8 w-8 rounded-md" />
                      <Skeleton className="h-8 w-8 rounded-md" />
                      <Skeleton className="h-8 w-8 rounded-md" />
                    </div>
                    <Skeleton className="h-8 w-16 rounded-md" />
                  </div>
                </Card>
              ))}
            </div>
          ) : forms.length === 0 ? (
            <div className="flex flex-col items-center justify-center py-24 text-center space-y-4 bg-muted/10 rounded-2xl border border-dashed border-border/50">
              <div className="w-16 h-16 rounded-full bg-muted/40 flex items-center justify-center">
                <ClipboardList className="w-8 h-8 text-muted-foreground/40" />
              </div>
              <div>
                <h3 className="text-lg font-bold text-foreground">Nenhum formulário cadastrado</h3>
                <p className="text-muted-foreground mt-1 max-w-sm mx-auto">
                  Comece importando um modelo ou criando um novo formulário do zero.
                </p>
              </div>
              <Button onClick={handleCreateNewForm} className="mt-4">
                Criar Primeiro Formulário
              </Button>
            </div>
          ) : (
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
              {forms.map((form) => {
                const subCount = submissions[form.id]?.length || 0;
                return (
                  <Card key={form.id} className="border-border/50 bg-card/30 backdrop-blur-sm shadow-sm hover:shadow-md hover:border-primary/20 transition-all duration-300 flex flex-col justify-between rounded-xl overflow-hidden group">
                    <CardHeader className="p-6 pb-4">
                      <div className="flex items-start justify-between gap-4">
                        <div className="space-y-1 min-w-0">
                          <CardTitle className="text-lg font-bold truncate text-foreground group-hover:text-primary transition-colors">
                            {form.name}
                          </CardTitle>
                          <span className="text-[10px] text-muted-foreground font-bold uppercase tracking-widest block">
                            Criado em {new Date(form.createdAt).toLocaleDateString()}
                          </span>
                        </div>
                        <div className="w-9 h-9 rounded-lg bg-primary/10 flex items-center justify-center shrink-0">
                          <FileText className="w-4 h-4 text-primary" />
                        </div>
                      </div>
                      <CardDescription className="line-clamp-2 mt-2 text-sm text-muted-foreground">
                        {form.description || "Sem descrição definida."}
                      </CardDescription>
                    </CardHeader>
                    
                    <CardContent className="px-6 py-2 flex items-center gap-3">
                      <span className="inline-flex items-center px-2 py-0.5 rounded-full text-xs font-medium bg-muted text-muted-foreground">
                        <Layers className="w-3.5 h-3.5 mr-1" />
                        {form.fields.length} {form.fields.length === 1 ? 'campo' : 'campos'}
                      </span>
                      
                      <span className={`inline-flex items-center px-2 py-0.5 rounded-full text-xs font-semibold ${subCount > 0 ? 'bg-emerald-500/10 text-emerald-500 border border-emerald-500/20' : 'bg-muted text-muted-foreground'}`}>
                        <CheckCircle className="w-3.5 h-3.5 mr-1" />
                        {subCount} {subCount === 1 ? 'resposta' : 'respostas'}
                      </span>

                      {form.isPublic && (
                        <span className="inline-flex items-center px-2 py-0.5 rounded-full text-xs font-semibold bg-emerald-500/10 text-emerald-600 dark:text-emerald-400 border border-emerald-500/20">
                          Público
                        </span>
                      )}
                    </CardContent>

                    <CardFooter className="p-6 pt-4 border-t border-border/40 bg-muted/20 flex items-center justify-between gap-2">
                      <div className="flex items-center gap-1.5">
                        <Button 
                          size="icon" 
                          variant="ghost" 
                          className="h-10 w-10 text-muted-foreground hover:text-primary hover:bg-primary/10 rounded-md cursor-pointer shrink-0"
                          onClick={() => handleEditForm(form)}
                          title="Editar Formulário"
                        >
                          <Edit className="w-4.5 h-4.5" />
                        </Button>

                        <Button 
                          size="icon" 
                          variant="ghost" 
                          className="h-10 w-10 text-muted-foreground hover:text-primary hover:bg-primary/10 rounded-md cursor-pointer shrink-0"
                          onClick={() => navigate(`/formularios/responder/${form.id}`)}
                          title="Testar Formulário"
                        >
                          <Eye className="w-4.5 h-4.5" />
                        </Button>

                        <Button 
                          size="icon" 
                          variant="ghost" 
                          className="h-10 w-10 text-muted-foreground hover:text-primary hover:bg-primary/10 rounded-md cursor-pointer shrink-0"
                          onClick={(e) => handleDuplicateForm(form, e)}
                          title="Duplicar Formulário"
                        >
                          <Copy className="w-4.5 h-4.5" />
                        </Button>

                        <Button 
                          size="icon" 
                          variant="ghost" 
                          className="h-10 w-10 text-muted-foreground hover:text-primary hover:bg-primary/10 rounded-md cursor-pointer shrink-0"
                          onClick={(e) => handleExportJSON(form, e)}
                          title="Copiar JSON"
                        >
                          <Download className="w-4.5 h-4.5" />
                        </Button>

                        <Button 
                          size="icon" 
                          variant="ghost" 
                          className="h-10 w-10 text-muted-foreground hover:text-primary hover:bg-primary/10 rounded-md cursor-pointer shrink-0"
                          onClick={(e) => handleShareLink(form, e)}
                          title="Compartilhar Link"
                        >
                          <Share2 className="w-4.5 h-4.5" />
                        </Button>
                      </div>

                      <div className="flex items-center gap-2">
                        {subCount > 0 && (
                          <Button 
                            variant="link" 
                            className="text-xs text-primary font-bold cursor-pointer px-1 py-1"
                            onClick={() => setViewingSubmissionsFormId(form.id)}
                          >
                            Respostas
                          </Button>
                        )}

                        <Button 
                          size="icon" 
                          variant="ghost" 
                          className="h-10 w-10 text-muted-foreground hover:text-destructive hover:bg-destructive/10 rounded-md cursor-pointer shrink-0"
                          onClick={(e) => handleDeleteForm(form.id, e)}
                          title="Excluir Formulário"
                        >
                          <Trash2 className="w-4.5 h-4.5" />
                        </Button>
                      </div>
                    </CardFooter>
                  </Card>
                );
              })}
            </div>
          )}
        </>
      )}

      {/* VIEW B: ACTIVE BUILDER / EDITOR */}
      {currentView === 'builder' && selectedForm && (
        <div className="space-y-6">
          
          {/* Header Panel */}
          <div className="flex flex-col lg:flex-row lg:items-center justify-between pb-6 border-b border-border gap-6">
            <div className="flex items-center gap-4">
              <Button 
                variant="ghost" 
                size="icon"
                onClick={() => {
                  if (confirm("Tem certeza que deseja sair sem salvar? Alterações não salvas serão perdidas.")) {
                    setCurrentView('list');
                    setSelectedForm(null);
                  }
                }}
                className="h-11 w-11 rounded-full border border-border bg-background cursor-pointer hover:bg-accent shrink-0 active:scale-95"
              >
                <ArrowLeft className="w-5 h-5 text-foreground" />
              </Button>
              <div className="space-y-1 flex-1 min-w-0">
                <Input 
                  value={selectedForm.name} 
                  onChange={(e) => setSelectedForm({ ...selectedForm, name: e.target.value })}
                  placeholder="Nome do Formulário" 
                  className="text-2xl font-bold bg-transparent border-none py-2 px-0 focus-visible:ring-0 focus-visible:border-b focus-visible:border-primary/50 rounded-none h-auto w-full text-foreground"
                />
                <Input 
                  value={selectedForm.description} 
                  onChange={(e) => setSelectedForm({ ...selectedForm, description: e.target.value })}
                  placeholder="Insira uma descrição explicativa curta..." 
                  className="text-sm bg-transparent border-none py-1.5 px-0 text-muted-foreground focus-visible:ring-0 focus-visible:border-b focus-visible:border-primary/30 rounded-none h-auto w-full"
                />
                <div className="flex items-center gap-2 pt-1">
                  <input
                    type="checkbox"
                    id="form-is-public"
                    checked={!!selectedForm.isPublic}
                    onChange={(e) => setSelectedForm({ ...selectedForm, isPublic: e.target.checked })}
                    className="h-4 w-4 rounded border-zinc-300 dark:border-zinc-700 text-primary focus:ring-primary/20 cursor-pointer"
                  />
                  <label htmlFor="form-is-public" className="text-xs text-muted-foreground select-none cursor-pointer hover:text-foreground transition-colors font-medium">
                    Disponibilizar como Formulário Público (não exige login para responder)
                  </label>
                </div>
              </div>
            </div>

            <div className="flex items-center gap-3 shrink-0">
              <Button
                variant="outline"
                className="h-11 rounded-md text-sm border-border cursor-pointer active:scale-95 transition-all hidden lg:flex"
                onClick={() => setShowPreview(!showPreview)}
              >
                {showPreview ? <EyeOff className="w-4 h-4 mr-2" /> : <Eye className="w-4 h-4 mr-2" />}
                {showPreview ? "Ocultar Preview" : "Mostrar Preview"}
              </Button>
              <Button
                variant="outline"
                className="h-11 rounded-md text-sm border-border cursor-pointer active:scale-95 transition-all"
                onClick={(e) => handleExportJSON(selectedForm, e)}
              >
                <Copy className="w-4 h-4 mr-2" />
                Copiar JSON
              </Button>
              <Button
                onClick={handleSaveForm}
                className="bg-primary hover:bg-primary/90 text-primary-foreground font-bold h-11 px-6 rounded-md cursor-pointer shadow-md active:scale-95 transition-all"
              >
                <Save className="w-4 h-4 mr-2" />
                Salvar Formulário
              </Button>
            </div>
          </div>

          {/* Builder Workspace Layout */}
          <div className="grid grid-cols-1 lg:grid-cols-12 gap-8 items-start">
            
            {/* Mobile Tab Control */}
            <div className="lg:hidden col-span-1 flex border border-border rounded-xl overflow-hidden bg-card/30 p-1">
              <button
                onClick={() => setBuilderTab('edit')}
                className={`flex-1 py-3 text-xs font-bold uppercase tracking-widest rounded-lg transition-all ${builderTab === 'edit' ? 'bg-primary text-primary-foreground shadow-sm' : 'text-muted-foreground'}`}
              >
                Editar Campos
              </button>
              <button
                onClick={() => setBuilderTab('preview')}
                className={`flex-1 py-3 text-xs font-bold uppercase tracking-widest rounded-lg transition-all ${builderTab === 'preview' ? 'bg-primary text-primary-foreground shadow-sm' : 'text-muted-foreground'}`}
              >
                Testar Preview
              </button>
              <button
                onClick={() => setBuilderTab('json')}
                className={`flex-1 py-3 text-xs font-bold uppercase tracking-widest rounded-lg transition-all ${builderTab === 'json' ? 'bg-primary text-primary-foreground shadow-sm' : 'text-muted-foreground'}`}
              >
                Esquema JSON
              </button>
            </div>

            {/* COLUMN 1: FIELD EDITOR PANEL (Show on desktop or when active tab is 'edit') */}
            <div className={`col-span-1 ${showPreview ? 'lg:col-span-7' : 'lg:col-span-12'} space-y-6 ${builderTab === 'edit' ? 'block' : 'hidden lg:block'}`}>
              
              {/* Header Text Block */}
              <div className="bg-card/20 dark:bg-zinc-900/10 p-5 rounded-xl border border-border/40">
                <h3 className="text-lg font-bold text-foreground">Desenho do Formulário</h3>
                <p className="text-xs text-muted-foreground mt-1 leading-relaxed">
                  Monte as perguntas do seu formulário no estilo Notion. Clique em qualquer pergunta para editá-la em tempo real e insira novos campos clicando nos botões flutuantes <code className="bg-muted px-1 py-0.5 rounded text-[10px]">+</code>.
                </p>
              </div>

              {/* Fields List (Canvas) */}
              <div className="space-y-4">
                <h3 className="text-sm font-bold uppercase tracking-wider text-muted-foreground px-1 flex items-center justify-between">
                  <span>Estrutura do Formulário</span>
                  <span className="text-xs normal-case font-normal text-muted-foreground">
                    {selectedForm.fields.length} {selectedForm.fields.length === 1 ? 'campo adicionado' : 'campos adicionados'}
                  </span>
                </h3>

                {selectedForm.fields.length === 0 ? (
                  <div className="p-12 text-center border-2 border-dashed border-border rounded-xl bg-card/10 text-muted-foreground text-sm flex flex-col items-center justify-center gap-3">
                    <span>Nenhum campo adicionado. Comece clicando abaixo para inserir seu primeiro campo.</span>
                    <FloatingAddBlockButton onAdd={(type) => handleAddField(type, 0)} />
                  </div>
                ) : (
                  <DndContext
                    sensors={sensors}
                    collisionDetection={closestCenter}
                    onDragEnd={handleDragEnd}
                  >
                    <SortableContext
                      items={selectedForm.fields.map(f => f.id)}
                      strategy={verticalListSortingStrategy}
                    >
                      <div className="space-y-2">
                        {/* Initial FAB before the first element */}
                        <FloatingAddBlockButton onAdd={(type) => handleAddField(type, 0)} />

                        {selectedForm.fields.map((field, idx) => {
                          const isChoiceType = ['select', 'checkbox', 'radio'].includes(field.type);
                          return (
                            <div key={field.id} className="space-y-2">
                              <SortableFieldCard
                                field={field}
                                idx={idx}
                                isEditing={editingFieldId === field.id}
                                onStartEdit={() => setEditingFieldId(field.id)}
                                onRemove={() => handleRemoveField(field.id)}
                                onDuplicate={() => handleDuplicateField(field.id)}
                                onUpdate={(updates) => handleUpdateField(field.id, updates)}
                                isChoiceType={isChoiceType}
                                onRemoveOption={(optIdx) => handleRemoveOption(field.id, optIdx)}
                                onAddOption={(text) => handleAddOption(field.id, text)}
                                newOptionText={newOptionTexts[field.id] || ""}
                                onNewOptionTextChange={(text) => setNewOptionTexts(prev => ({ ...prev, [field.id]: text }))}
                                fieldsList={selectedForm.fields}
                                selectedForm={selectedForm}
                              />
                              
                              {/* FAB after this field */}
                              <FloatingAddBlockButton onAdd={(type) => handleAddField(type, idx + 1)} />
                            </div>
                          );
                        })}
                      </div>
                    </SortableContext>
                  </DndContext>
                )}
              </div>
            </div>
                        {/* COLUMN 2: INTERACTIVE LIVE PREVIEW PANEL (Show on desktop or when active tab is 'preview') */}
            <div className={`col-span-1 lg:col-span-5 space-y-6 ${builderTab === 'preview' ? 'block' : 'hidden lg:block'} ${showPreview ? '' : 'lg:hidden'}`}>
              
              <Card className="border-border bg-card/40 backdrop-blur-xl rounded-xl shadow-lg overflow-hidden sticky top-24">
                <CardHeader className="p-6 border-b border-border/40 flex flex-row items-center justify-between">
                  <div>
                    <CardTitle className="text-lg font-bold flex items-center gap-2 text-foreground">
                      <Eye className="w-5 h-5 text-primary shrink-0" />
                      Visualização ao Vivo
                    </CardTitle>
                    <CardDescription className="text-xs text-muted-foreground">
                      Teste o comportamento do formulário e validações em tempo real.
                    </CardDescription>
                  </div>
                  
                  <span className="inline-flex items-center px-2 py-0.5 rounded-full text-[9px] font-bold uppercase bg-primary/10 text-primary border border-primary/20 shrink-0">
                    Preview
                  </span>
                </CardHeader>
                
                <CardContent className="p-6">
                  <form onSubmit={(e) => handlePreviewSubmit(e, selectedForm)} className="space-y-6">
                    <div>
                      <h2 className="text-xl font-bold tracking-tight text-foreground">{selectedForm.name}</h2>
                      {selectedForm.description && (
                        <p className="text-muted-foreground text-xs mt-1 leading-relaxed">{selectedForm.description}</p>
                      )}
                      <hr className="border-border/50 my-4" />
                    </div>

                    {selectedForm.fields.length === 0 ? (
                      <div className="text-center py-12 text-sm text-muted-foreground italic">
                        Adicione campos no editor à esquerda para visualizá-los aqui.
                      </div>
                    ) : (
                      <div className="grid grid-cols-1 md:grid-cols-2 gap-x-6 gap-y-8">
                        {(() => {
                          const visibleFields = selectedForm.fields.filter(field => 
                            isFieldVisible(field, previewFormData, selectedForm.fields)
                          );

                          return visibleFields.map((field, idx) => {
                            const hasError = !!previewFormErrors[field.id];
                            const errorMsg = previewFormErrors[field.id];

                            return (
                              <div key={field.id} className={`${field.halfWidth ? 'col-span-1' : 'col-span-1 md:col-span-2'} space-y-3`}>
                                <label className="text-sm md:text-base font-semibold text-foreground flex items-start gap-3">
                                  <span className="flex-shrink-0 flex items-center justify-center w-6 h-6 rounded-full bg-primary/5 text-primary border border-primary/10 text-[10px] font-bold mt-0.5">
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
                                    value={previewFormData[field.id] || ""}
                                    onChange={(e) => handlePreviewInputChange(field.id, e.target.value)}
                                    placeholder={field.placeholder}
                                    className={`h-12 text-base px-4 rounded-md bg-muted/30 focus-visible:ring-primary/20 ${hasError ? 'border-destructive focus-visible:ring-destructive/20' : 'border-border/60'}`}
                                  />
                                )}

                                {/* TEXTAREA INPUT */}
                                {field.type === 'textarea' && (
                                  <Textarea
                                    value={previewFormData[field.id] || ""}
                                    onChange={(e) => handlePreviewInputChange(field.id, e.target.value)}
                                    placeholder={field.placeholder}
                                    className={`min-h-[120px] text-base px-4 py-3 rounded-md bg-muted/30 focus-visible:ring-primary/20 ${hasError ? 'border-destructive focus-visible:ring-destructive/20' : 'border-border/60'}`}
                                  />
                                )}

                                {/* NUMBER INPUT */}
                                {field.type === 'number' && (
                                  <Input
                                    type="number"
                                    value={previewFormData[field.id] || ""}
                                    onChange={(e) => handlePreviewInputChange(field.id, e.target.value)}
                                    placeholder={field.placeholder}
                                    className={`h-12 text-base px-4 rounded-md bg-muted/30 focus-visible:ring-primary/20 ${hasError ? 'border-destructive focus-visible:ring-destructive/20' : 'border-border/60'}`}
                                  />
                                )}

                                {/* SELECT INPUT */}
                                {field.type === 'select' && (
                                  <div className="relative">
                                    <select
                                      value={previewFormData[field.id] || ""}
                                      onChange={(e) => handlePreviewInputChange(field.id, e.target.value)}
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
                                      const isChecked = (previewFormData[field.id] || []).includes(opt);
                                      return (
                                        <label 
                                          key={oIdx} 
                                          className="flex items-center gap-3 p-3 rounded-lg border border-border/40 hover:bg-muted/30 cursor-pointer transition-all select-none min-h-[46px]"
                                        >
                                          <input
                                            type="checkbox"
                                            id={`opt-${field.id}-${oIdx}`}
                                            checked={isChecked}
                                            onChange={(e) => handlePreviewCheckboxChange(field.id, opt, e.target.checked)}
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
                                      const isSelected = previewFormData[field.id] === opt;
                                      return (
                                        <label 
                                          key={oIdx} 
                                          className="flex items-center gap-3 p-3 rounded-lg border border-border/40 hover:bg-muted/30 cursor-pointer transition-all select-none min-h-[46px]"
                                        >
                                          <input
                                            type="radio"
                                            name={`radio-group-${field.id}`}
                                            id={`opt-${field.id}-${oIdx}`}
                                            checked={isSelected}
                                            onChange={() => handlePreviewInputChange(field.id, opt)}
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
                                    value={previewFormData[field.id] || ""}
                                    onChange={(e) => handlePreviewInputChange(field.id, e.target.value)}
                                    className={`h-12 text-base px-4 rounded-md bg-muted/30 focus-visible:ring-primary/20 ${hasError ? 'border-destructive focus-visible:ring-destructive/20' : 'border-border/60'}`}
                                  />
                                )}

                                {field.helpText && !hasError && (
                                  <p className="text-xs text-muted-foreground/80 pl-9 leading-normal">{field.helpText}</p>
                                )}

                                {hasError && (
                                  <p className="text-xs font-semibold text-destructive animate-in fade-in duration-200 pl-9">{errorMsg}</p>
                                )}
                              </div>
                            );
                          });
                        })()}
                      </div>
                    )}
                                        <div className="pt-4">
                      <Button
                        type="submit"
                        disabled={selectedForm.fields.length === 0}
                        className="w-full bg-primary hover:bg-primary/90 text-primary-foreground font-bold h-12 rounded-md transition-all shadow-md active:scale-98 cursor-pointer"
                      >
                        Enviar Resposta (Simulação)
                      </Button>
                    </div>

                  </form>
                </CardContent>
              </Card>

            </div>

            {/* COLUMN 3: RAW JSON SCHEMATIC VIEW (Show on mobile active tab 'json') */}
            <div className={`col-span-1 space-y-4 ${builderTab === 'json' ? 'block' : 'hidden'}`}>
              <Card className="border-border bg-card/40 backdrop-blur-xl rounded-xl shadow-lg p-5">
                <div className="flex items-center justify-between mb-4 border-b border-border/50 pb-3">
                  <h3 className="font-bold text-sm text-foreground">Esquema Estrutural JSON</h3>
                  <Button 
                    size="sm" 
                    variant="outline"
                    onClick={(e) => handleExportJSON(selectedForm, e)}
                    className="h-8 rounded-md cursor-pointer"
                  >
                    Copiar JSON
                  </Button>
                </div>
                <pre className="text-[10px] leading-normal font-mono bg-background p-4 border border-border/60 rounded-lg overflow-x-auto text-muted-foreground max-h-[450px]">
                  {JSON.stringify(selectedForm, null, 2)}
                </pre>
              </Card>
            </div>

          </div>

        </div>
      )}

      {/* VIEW SUBMISSIONS MODAL */}
      {viewingSubmissionsFormId && (() => {
        const formTemplate = forms.find(f => f.id === viewingSubmissionsFormId);
        const formSubs = submissions[viewingSubmissionsFormId] || [];
        if (!formTemplate) return null;

        return (
          <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/80 backdrop-blur-xs animate-in fade-in duration-200">
            <div className="bg-background border border-border/80 w-full max-w-4xl max-h-[85vh] rounded-xl shadow-2xl flex flex-col overflow-hidden animate-in zoom-in-95 duration-200">
              
              {/* Header */}
              <div className="p-6 border-b border-border flex items-center justify-between">
                <div>
                  <h2 className="text-xl font-bold text-foreground">Respostas Recebidas</h2>
                  <p className="text-xs text-muted-foreground mt-0.5">
                    Formulário: <span className="font-semibold text-primary">{formTemplate.name}</span> • {formSubs.length} submissões
                  </p>
                </div>
                
                <Button 
                  size="icon" 
                  variant="ghost" 
                  onClick={() => setViewingSubmissionsFormId(null)}
                  className="h-10 w-10 rounded-md cursor-pointer hover:bg-accent"
                >
                  <X className="w-5 h-5 text-muted-foreground" />
                </Button>
              </div>

              {/* Content area */}
              <div className="flex-1 overflow-y-auto p-6 min-h-[250px] max-h-[calc(85vh-160px)]">
                {formSubs.length === 0 ? (
                  <div className="flex flex-col items-center justify-center py-16 text-center text-muted-foreground italic">
                    Nenhuma resposta enviada ainda. Use o preview para testar o envio de dados.
                  </div>
                ) : (
                  <div className="border border-border/50 rounded-lg overflow-hidden bg-card/25 shadow-sm">
                    <div className="overflow-x-auto">
                      <table className="w-full text-left border-collapse text-xs">
                        <thead>
                          <tr className="bg-muted/70 text-muted-foreground uppercase font-bold border-b border-border/80 tracking-wider">
                            <th className="p-3.5 font-bold">Data de Envio</th>
                            {formTemplate.fields.map(f => (
                              <th key={f.id} className="p-3.5 font-bold whitespace-nowrap max-w-[150px] truncate" title={f.label}>
                                {f.label}
                              </th>
                            ))}
                          </tr>
                        </thead>
                        <tbody className="divide-y divide-border/40 text-foreground font-medium">
                          {formSubs.map((sub) => (
                            <tr key={sub.id} className="hover:bg-muted/10 transition-colors">
                              <td className="p-3.5 whitespace-nowrap text-muted-foreground font-normal">
                                {formatDate(sub.submittedAt)}
                              </td>
                              {formTemplate.fields.map(f => {
                                const val = sub.data[f.id];
                                let displayVal = "-";
                                
                                if (val !== undefined && val !== null) {
                                  if (Array.isArray(val)) {
                                    displayVal = val.join(", ");
                                  } else if (typeof val === "boolean") {
                                    displayVal = val ? "Sim" : "Não";
                                  } else {
                                    displayVal = String(val);
                                  }
                                }
                                
                                return (
                                  <td key={f.id} className="p-3.5 max-w-[200px] truncate" title={displayVal}>
                                    {displayVal}
                                  </td>
                                );
                              })}
                            </tr>
                          ))}
                        </tbody>
                      </table>
                    </div>
                  </div>
                )}
              </div>

              {/* Footer */}
              <div className="p-6 border-t border-border bg-muted/20 flex items-center justify-between">
                <Button
                  variant="destructive"
                  onClick={() => {
                    handleClearSubmissions(formTemplate.id);
                    setViewingSubmissionsFormId(null);
                  }}
                  disabled={formSubs.length === 0}
                  className="h-10 rounded-md cursor-pointer text-xs font-bold"
                >
                  <Trash2 className="w-4 h-4 mr-2" />
                  Apagar Respostas
                </Button>
                
                <Button 
                  onClick={() => setViewingSubmissionsFormId(null)}
                  className="bg-primary hover:bg-primary/90 text-primary-foreground font-bold h-10 px-5 rounded-md cursor-pointer"
                >
                  Fechar
                </Button>
              </div>

            </div>
          </div>
        );
      })()}


    </div>
  );
}

// ==========================================
// SORTABLE FIELD CARD COMPONENT
// ==========================================
interface SortableFieldCardProps {
  field: FormField;
  idx: number;
  isEditing: boolean;
  onStartEdit: () => void;
  onRemove: () => void;
  onDuplicate: () => void;
  onUpdate: (updates: Partial<FormField>) => void;
  isChoiceType: boolean;
  onRemoveOption: (optIdx: number) => void;
  onAddOption: (text: string) => void;
  newOptionText: string;
  onNewOptionTextChange: (text: string) => void;
  fieldsList: FormField[];
  selectedForm: FormTemplate;
}

function SortableFieldCard({
  field,
  idx,
  isEditing,
  onRemove,
  onDuplicate,
  onUpdate,
  isChoiceType,
  onRemoveOption,
  onAddOption,
  newOptionText,
  onNewOptionTextChange,
  fieldsList,
  onStartEdit
}: SortableFieldCardProps) {
  const {
    attributes,
    listeners,
    setNodeRef,
    transform,
    transition,
    isDragging
  } = useSortable({ id: field.id });

  const style = {
    transform: CSS.Transform.toString(transform),
    transition,
  };

  const depth = getFieldDepth(field, fieldsList);

  return (
    <div 
      ref={setNodeRef} 
      style={style}
      className={`flex items-stretch select-none ${isDragging ? 'opacity-40' : ''}`}
    >
      {/* Connector lines per depth level */}
      {Array.from({ length: depth }).map((_, i) => (
        <div key={i} className="border-l-2 border-primary/25 dark:border-primary/15 w-5 ml-1 shrink-0 self-stretch pointer-events-none" />
      ))}

      <div className="flex-1 min-w-0">
        {isEditing ? (
          <div 
            id={`editor-card-${field.id}`}
            className="relative border border-primary/30 ring-1 ring-primary/10 shadow-md bg-card p-5 rounded-xl space-y-4"
          >
            {/* Drag Handle in Edit Mode */}
            <div 
              {...attributes} 
              {...listeners} 
              className="absolute -left-7 top-6 cursor-grab active:cursor-grabbing text-primary/40 hover:text-primary transition-colors p-1"
              title="Arrastar para reordenar"
            >
              <GripVertical className="w-4 h-4" />
            </div>

            {/* In-place Editable Text Fields */}
            <div className="space-y-1">
              <div className="flex items-center gap-2">
                <span className="flex-shrink-0 flex items-center justify-center w-6 h-6 rounded-full bg-primary/10 text-primary text-[10px] font-bold">
                  {idx + 1}
                </span>
                <Input
                  value={field.label}
                  onChange={(e) => onUpdate({ label: e.target.value })}
                  placeholder="Título da Pergunta"
                  className="text-sm font-semibold bg-background border border-border/80 focus-visible:border-primary/50 focus-visible:ring-2 focus-visible:ring-primary/10 h-10 px-3 rounded-md w-full text-foreground placeholder:text-muted-foreground/45"
                  autoFocus
                />
              </div>

              {/* Placeholder Editor (if applicable) */}
              {['text', 'textarea', 'number', 'select', 'date'].includes(field.type) && (
                <div className="pl-8">
                  <Input
                    value={field.placeholder}
                    onChange={(e) => onUpdate({ placeholder: e.target.value })}
                    placeholder="Placeholder (Dica dentro do campo...)"
                    className="text-xs bg-background/50 border border-border/60 focus-visible:border-primary/50 focus-visible:ring-2 focus-visible:ring-primary/10 h-9 px-3 rounded-md w-full placeholder:text-muted-foreground/40"
                  />
                </div>
              )}

              {/* Help Text Editor */}
              <div className="pl-8">
                <Input
                  value={field.helpText}
                  onChange={(e) => onUpdate({ helpText: e.target.value })}
                  placeholder="Texto de ajuda (Subtexto explicativo...)"
                  className="text-[11px] bg-background/50 border border-border/60 focus-visible:border-primary/50 focus-visible:ring-2 focus-visible:ring-primary/10 h-9 px-3 rounded-md w-full placeholder:text-muted-foreground/40"
                />
              </div>
            </div>

            {/* Options list for choice types */}
            {isChoiceType && (
              <div className="pl-8 space-y-2 pt-2 border-t border-border/30">
                <label className="text-[10px] font-bold uppercase tracking-wider text-muted-foreground">Opções de Resposta</label>
                <div className="space-y-1 max-w-md">
                  {field.options.map((opt, optIdx) => (
                    <div key={optIdx} className="flex items-center gap-2 group/opt">
                      {field.type === 'radio' && <Radio className="w-3.5 h-3.5 text-muted-foreground/50 shrink-0" />}
                      {field.type === 'checkbox' && <CheckSquare className="w-3.5 h-3.5 text-muted-foreground/50 shrink-0" />}
                      {field.type === 'select' && <span className="text-xs text-muted-foreground/40 shrink-0 w-3 font-mono">{optIdx + 1}.</span>}
                      <Input
                        value={opt}
                        onChange={(e) => {
                          const updatedOptions = [...field.options];
                          updatedOptions[optIdx] = e.target.value;
                          onUpdate({ options: updatedOptions });
                        }}
                        className="h-9 text-xs bg-background border border-border/60 focus-visible:border-primary/50 focus-visible:ring-2 focus-visible:ring-primary/10 px-3 rounded-md w-full"
                      />
                      <Button
                        size="icon"
                        variant="ghost"
                        onClick={() => onRemoveOption(optIdx)}
                        disabled={field.options.length <= 1}
                        className="h-8 w-8 hover:bg-destructive/10 hover:text-destructive rounded-md cursor-pointer shrink-0 opacity-0 group-hover/opt:opacity-100 transition-opacity"
                      >
                        <X className="w-3.5 h-3.5" />
                      </Button>
                    </div>
                  ))}
                  
                  <div className="flex items-center gap-2 pl-5 pt-1">
                    <Plus className="w-3.5 h-3.5 text-muted-foreground/40 shrink-0" />
                    <Input
                      placeholder="Adicionar opção..."
                      value={newOptionText}
                      onChange={(e) => onNewOptionTextChange(e.target.value)}
                      onKeyDown={(e) => {
                        if (e.key === 'Enter') {
                          e.preventDefault();
                          if (newOptionText.trim()) {
                            onAddOption(newOptionText.trim());
                          }
                        }
                      }}
                      className="h-9 text-xs bg-background/20 border border-dashed border-border/60 focus-visible:border-primary/50 focus-visible:ring-2 focus-visible:ring-primary/10 px-3 rounded-md text-muted-foreground/80 placeholder:text-muted-foreground/40 w-full"
                    />
                  </div>
                </div>
              </div>
            )}

            {/* Contextual Settings Toolbar */}
            <div className="flex flex-wrap items-center justify-between gap-4 pt-3 border-t border-border/40 text-xs text-muted-foreground">
              <div className="flex items-center gap-3">
                {/* Field Type Select */}
                <select
                  value={field.type}
                  onChange={(e) => {
                    const newType = e.target.value as FormField['type'];
                    const needsOptions = ['select', 'checkbox', 'radio'].includes(newType);
                    const currentOptions = field.options.length > 0 ? field.options : ['Opção 1', 'Opção 2'];
                    onUpdate({ 
                      type: newType,
                      options: needsOptions ? currentOptions : []
                    });
                  }}
                  className="bg-transparent border border-border/70 rounded px-2 py-1 focus:outline-none focus:ring-1 focus:ring-primary/20 text-xs font-semibold text-foreground cursor-pointer"
                >
                  <option value="text">Texto</option>
                  <option value="textarea">Texto Longo</option>
                  <option value="number">Número</option>
                  <option value="select">Dropdown</option>
                  <option value="checkbox">Multi-Escolha</option>
                  <option value="radio">Escolha Única</option>
                  <option value="date">Data</option>
                </select>

                {/* Required Toggle */}
                <label className="flex items-center gap-2 cursor-pointer font-medium">
                  <input
                    type="checkbox"
                    checked={field.required}
                    onChange={(e) => onUpdate({ required: e.target.checked })}
                    className="h-4 w-4 rounded border-border text-primary focus:ring-primary/20 cursor-pointer"
                  />
                  <span>Obrigatório</span>
                </label>

                {/* Half Width Toggle */}
                <label className="flex items-center gap-2 cursor-pointer font-medium ml-4">
                  <input
                    type="checkbox"
                    checked={!!field.halfWidth}
                    onChange={(e) => onUpdate({ halfWidth: e.target.checked })}
                    className="h-4 w-4 rounded border-border text-primary focus:ring-primary/20 cursor-pointer"
                  />
                  <span>Lado a Lado (50%)</span>
                </label>
              </div>

              <div className="flex items-center gap-2">
                {/* Logic Rules Popover */}
                <Popover>
                  <PopoverTrigger asChild>
                    <Button variant="outline" size="sm" className="h-8 text-xs gap-1.5 cursor-pointer font-medium">
                      <Layers className="w-3.5 h-3.5 text-muted-foreground" />
                      Lógica & Regras
                    </Button>
                  </PopoverTrigger>
                  <PopoverContent className="w-80 p-4 border border-zinc-200 dark:border-zinc-800 bg-white dark:bg-zinc-950 shadow-md">
                    <div className="space-y-4">
                      <h4 className="font-bold text-sm text-foreground">Regras do Campo</h4>
                      
                      {/* Conditional Display Logic */}
                      {idx > 0 && (
                        <div className="space-y-2">
                          <label className="text-[10px] font-bold uppercase tracking-wider text-muted-foreground block">Lógica Condicional (Exibição)</label>
                          <div className="space-y-2">
                            <div>
                              <label className="text-[10px] text-muted-foreground block mb-1">Depende da pergunta:</label>
                              <select
                                value={field.dependsOnFieldId || ""}
                                onChange={(e) => onUpdate({ 
                                  dependsOnFieldId: e.target.value || undefined,
                                  dependsOnValue: undefined 
                                })}
                                className="flex h-10 w-full rounded-md border border-border/60 bg-background px-3 py-1.5 text-xs focus:ring-2 focus:ring-primary/20 transition-all outline-none"
                              >
                                <option value="">-- Sem Dependência (Sempre Exibir) --</option>
                                {fieldsList.slice(0, idx).map(prevField => (
                                  <option key={prevField.id} value={prevField.id}>
                                    {prevField.label || `Sem título (${prevField.type})`}
                                  </option>
                                ))}
                              </select>
                            </div>

                            {field.dependsOnFieldId && (() => {
                              const parentField = fieldsList.find(f => f.id === field.dependsOnFieldId);
                              if (!parentField) return null;
                              const isParentChoice = ['select', 'radio', 'checkbox'].includes(parentField.type);

                              return (
                                <div>
                                  <label className="text-[10px] text-muted-foreground block mb-1">Quando a resposta for:</label>
                                  {isParentChoice && parentField.options.length > 0 ? (
                                    <select
                                      value={field.dependsOnValue || ""}
                                      onChange={(e) => onUpdate({ dependsOnValue: e.target.value })}
                                      className="flex h-10 w-full rounded-md border border-border/60 bg-background px-3 py-1.5 text-xs focus:ring-2 focus:ring-primary/20 transition-all outline-none"
                                    >
                                      <option value="">-- Selecione uma opção --</option>
                                      {parentField.options.map((opt, oIdx) => (
                                        <option key={oIdx} value={opt}>{opt}</option>
                                      ))}
                                    </select>
                                  ) : (
                                    <Input
                                      value={field.dependsOnValue || ""}
                                      onChange={(e) => onUpdate({ dependsOnValue: e.target.value })}
                                      placeholder="Digite o valor de ativação..."
                                      className="h-10 rounded-md bg-background focus-visible:ring-primary/20 border-border/60 text-xs px-3"
                                    />
                                  )}
                                </div>
                              );
                            })()}
                          </div>
                        </div>
                      )}

                      {/* Validation Rules */}
                      <div className="space-y-2 pt-2 border-t border-border/30">
                        <label className="text-[10px] font-bold uppercase tracking-wider text-muted-foreground block">Regras de Validação</label>
                        
                        {field.type === 'textarea' && (
                          <div className="grid grid-cols-2 gap-2">
                            <div>
                              <label className="text-[10px] text-muted-foreground block">Qtd. Mínima Caracteres:</label>
                              <Input
                                type="number"
                                value={field.minLength ?? ""}
                                onChange={(e) => onUpdate({ 
                                  minLength: e.target.value !== "" ? Number(e.target.value) : undefined 
                                })}
                                placeholder="Nenhuma"
                                className="h-10 rounded-md bg-background focus-visible:ring-primary/20 border-border/60 text-xs px-3"
                              />
                            </div>
                            <div>
                              <label className="text-[10px] text-muted-foreground block">Qtd. Máxima Caracteres:</label>
                              <Input
                                type="number"
                                value={field.maxLength ?? ""}
                                onChange={(e) => onUpdate({ 
                                  maxLength: e.target.value !== "" ? Number(e.target.value) : undefined 
                                })}
                                placeholder="Nenhuma"
                                className="h-10 rounded-md bg-background focus-visible:ring-primary/20 border-border/60 text-xs px-3"
                              />
                            </div>
                          </div>
                        )}

                        {field.type === 'text' && (
                          <div className="space-y-2">
                            <div className="space-y-1">
                              <label className="text-[10px] text-muted-foreground block">Formato Requerido (Preset):</label>
                              <select
                                value={field.validationPreset || "none"}
                                onChange={(e) => onUpdate({ 
                                  validationPreset: e.target.value as FormField['validationPreset'],
                                  // Clear mapping if changed from cep
                                  cepMapping: e.target.value === 'cep' ? field.cepMapping || {} : undefined
                                })}
                                className="flex h-10 w-full rounded-md border border-border/60 bg-background px-3 py-1.5 text-xs focus:ring-2 focus:ring-primary/20 transition-all outline-none"
                              >
                                <option value="none">Nenhum (Qualquer texto)</option>
                                <option value="phone">Telefone (Brasil)</option>
                                <option value="cpf">CPF (Cadastro de Pessoa Física)</option>
                                <option value="cep">CEP (Localidade/Código Postal)</option>
                                <option value="email">Endereço de E-mail</option>
                              </select>
                            </div>

                            {field.validationPreset === 'cep' && (() => {
                              const otherTextFields = fieldsList.filter(
                                f => f.id !== field.id && ['text', 'textarea'].includes(f.type)
                              );
                              return (
                                <div className="space-y-2 mt-2 border-t border-zinc-200 dark:border-zinc-800 pt-2">
                                  <label className="text-[10px] font-bold text-foreground block">Mapeamento de Endereço (CEP)</label>
                                  <p className="text-[10px] text-muted-foreground leading-normal">
                                    Ao digitar um CEP válido, os dados de endereço serão copiados para os campos selecionados abaixo:
                                  </p>
                                  
                                  <div className="space-y-1">
                                    <label className="text-[9px] text-muted-foreground block">Rua / Logradouro:</label>
                                    <select
                                      value={field.cepMapping?.streetFieldId || ""}
                                      onChange={(e) => onUpdate({
                                        cepMapping: {
                                          ...field.cepMapping,
                                          streetFieldId: e.target.value || undefined
                                        }
                                      })}
                                      className="flex h-9 w-full rounded-md border border-border/60 bg-background px-3 py-1 text-xs focus:ring-1 focus:ring-primary/20 transition-all outline-none"
                                    >
                                      <option value="">-- Não Preencher --</option>
                                      {otherTextFields.map(f => (
                                        <option key={f.id} value={f.id}>{f.label || `Campo (${f.type})`}</option>
                                      ))}
                                    </select>
                                  </div>

                                  <div className="space-y-1">
                                    <label className="text-[9px] text-muted-foreground block">Bairro:</label>
                                    <select
                                      value={field.cepMapping?.neighborhoodFieldId || ""}
                                      onChange={(e) => onUpdate({
                                        cepMapping: {
                                          ...field.cepMapping,
                                          neighborhoodFieldId: e.target.value || undefined
                                        }
                                      })}
                                      className="flex h-9 w-full rounded-md border border-border/60 bg-background px-3 py-1 text-xs focus:ring-1 focus:ring-primary/20 transition-all outline-none"
                                    >
                                      <option value="">-- Não Preencher --</option>
                                      {otherTextFields.map(f => (
                                        <option key={f.id} value={f.id}>{f.label || `Campo (${f.type})`}</option>
                                      ))}
                                    </select>
                                  </div>

                                  <div className="space-y-1">
                                    <label className="text-[9px] text-muted-foreground block">Cidade:</label>
                                    <select
                                      value={field.cepMapping?.cityFieldId || ""}
                                      onChange={(e) => onUpdate({
                                        cepMapping: {
                                          ...field.cepMapping,
                                          cityFieldId: e.target.value || undefined
                                        }
                                      })}
                                      className="flex h-9 w-full rounded-md border border-border/60 bg-background px-3 py-1 text-xs focus:ring-1 focus:ring-primary/20 transition-all outline-none"
                                    >
                                      <option value="">-- Não Preencher --</option>
                                      {otherTextFields.map(f => (
                                        <option key={f.id} value={f.id}>{f.label || `Campo (${f.type})`}</option>
                                      ))}
                                    </select>
                                  </div>

                                  <div className="space-y-1">
                                    <label className="text-[9px] text-muted-foreground block">Estado / UF:</label>
                                    <select
                                      value={field.cepMapping?.stateFieldId || ""}
                                      onChange={(e) => onUpdate({
                                        cepMapping: {
                                          ...field.cepMapping,
                                          stateFieldId: e.target.value || undefined
                                        }
                                      })}
                                      className="flex h-9 w-full rounded-md border border-border/60 bg-background px-3 py-1 text-xs focus:ring-1 focus:ring-primary/20 transition-all outline-none"
                                    >
                                      <option value="">-- Não Preencher --</option>
                                      {otherTextFields.map(f => (
                                        <option key={f.id} value={f.id}>{f.label || `Campo (${f.type})`}</option>
                                      ))}
                                    </select>
                                  </div>
                                </div>
                              );
                            })()}
                          </div>
                        )}

                        {field.type === 'number' && (
                          <div className="grid grid-cols-2 gap-2">
                            <div>
                              <label className="text-[10px] text-muted-foreground block">Mínimo:</label>
                              <Input
                                type="number"
                                value={field.minNumber ?? ""}
                                onChange={(e) => onUpdate({ 
                                  minNumber: e.target.value !== "" ? Number(e.target.value) : undefined 
                                })}
                                placeholder="Nenhum"
                                className="h-10 rounded-md bg-background focus-visible:ring-primary/20 border-border/60 text-xs px-3"
                              />
                            </div>
                            <div>
                              <label className="text-[10px] text-muted-foreground block">Máximo:</label>
                              <Input
                                type="number"
                                value={field.maxNumber ?? ""}
                                onChange={(e) => onUpdate({ 
                                  maxNumber: e.target.value !== "" ? Number(e.target.value) : undefined 
                                })}
                                placeholder="Nenhum"
                                className="h-10 rounded-md bg-background focus-visible:ring-primary/20 border-border/60 text-xs px-3"
                              />
                            </div>
                          </div>
                        )}
                        
                        {!['text', 'textarea', 'number'].includes(field.type) && (
                          <p className="text-[11px] text-muted-foreground italic">Este tipo de campo não requer validações customizadas.</p>
                        )}
                      </div>
                    </div>
                  </PopoverContent>
                </Popover>

                {/* Duplicate Button */}
                <Button 
                  variant="outline" 
                  size="sm" 
                  onClick={(e) => {
                    e.stopPropagation();
                    onDuplicate();
                  }}
                  className="h-8 text-xs gap-1.5 cursor-pointer font-medium"
                >
                  <Copy className="w-3.5 h-3.5 text-muted-foreground" />
                  Duplicar
                </Button>

                {/* Delete Button */}
                <Button 
                  variant="outline" 
                  size="sm" 
                  onClick={(e) => {
                    e.stopPropagation();
                    onRemove();
                  }}
                  className="h-8 text-xs text-destructive hover:text-destructive hover:bg-destructive/10 border-border/60 cursor-pointer gap-1.5 font-medium"
                >
                  <Trash2 className="w-3.5 h-3.5" />
                  Excluir
                </Button>
              </div>
            </div>

          </div>
        ) : (
          <div 
            onClick={onStartEdit}
            className="relative group p-5 border border-transparent hover:border-border/60 hover:bg-muted/10 rounded-xl transition-all duration-200 cursor-pointer space-y-3"
          >
            {/* Drag Handle in Preview Mode */}
            <div 
              {...attributes} 
              {...listeners} 
              className="absolute -left-7 top-6 opacity-0 group-hover:opacity-100 transition-opacity cursor-grab active:cursor-grabbing text-muted-foreground/35 hover:text-muted-foreground transition-colors p-1"
              title="Arrastar para reordenar"
              onClick={(e) => e.stopPropagation()} // Prevent triggering edit mode when dragging
            >
              <GripVertical className="w-4 h-4" />
            </div>

            {/* Edit Indicator Icon */}
            <div className="absolute right-4 top-4 opacity-0 group-hover:opacity-100 transition-opacity text-muted-foreground/60">
              <Edit className="w-4 h-4" />
            </div>

            {/* Field Label exactly like responder */}
            <label className="text-sm md:text-base font-semibold text-foreground flex items-start gap-3 pointer-events-none">
              <span className="flex-shrink-0 flex items-center justify-center w-6 h-6 rounded-full bg-primary/5 text-primary border border-primary/10 text-[10px] font-bold mt-0.5">
                {idx + 1}
              </span>
              <div className="pt-0.5 flex-1">
                <span>{field.label || "Campo sem nome"}</span>
                {field.required && <span className="text-destructive font-bold text-xs ml-1">*</span>}
                {field.halfWidth && (
                  <span className="inline-flex items-center ml-2 px-1.5 py-0.5 rounded text-[9px] font-bold uppercase bg-amber-500/10 text-amber-600 dark:text-amber-400 border border-amber-500/20">
                    50%
                  </span>
                )}
              </div>
            </label>

            {/* Field Control exactly like responder */}
            <div className="space-y-3 pointer-events-none">
              {/* TEXT INPUT */}
              {field.type === 'text' && (
                <Input
                  disabled
                  placeholder={field.placeholder}
                  className="h-12 text-base px-4 rounded-md bg-muted/30 border-border/60 w-full"
                />
              )}

              {/* TEXTAREA INPUT */}
              {field.type === 'textarea' && (
                <Textarea
                  disabled
                  placeholder={field.placeholder}
                  className="min-h-[120px] text-base px-4 py-3 rounded-md bg-muted/30 border-border/60 w-full"
                />
              )}

              {/* NUMBER INPUT */}
              {field.type === 'number' && (
                <Input
                  type="number"
                  disabled
                  placeholder={field.placeholder}
                  className="h-12 text-base px-4 rounded-md bg-muted/30 border-border/60 w-full"
                />
              )}

              {/* SELECT INPUT */}
              {field.type === 'select' && (
                <div className="relative">
                  <div className="flex h-12 w-full items-center justify-between rounded-md border border-border/60 bg-muted/30 px-4 text-base text-muted-foreground">
                    <span>{field.placeholder || "Selecione uma opção..."}</span>
                    <ChevronsUpDown className="w-4 h-4 text-muted-foreground" />
                  </div>
                </div>
              )}

              {/* CHECKBOX */}
              {field.type === 'checkbox' && (
                <div className="space-y-3 pt-1">
                  {field.options.map((opt, oIdx) => (
                    <label 
                      key={oIdx} 
                      className="flex items-center gap-3 p-3 rounded-lg border border-border/40 bg-muted/10 min-h-[46px]"
                    >
                      <input
                        type="checkbox"
                        disabled
                        className="h-5 w-5 rounded border-zinc-300 dark:border-zinc-700 text-primary shrink-0"
                      />
                      <span className="text-base font-medium text-muted-foreground">
                        {opt}
                      </span>
                    </label>
                  ))}
                </div>
              )}

              {/* RADIO */}
              {field.type === 'radio' && (
                <div className="space-y-3 pt-1">
                  {field.options.map((opt, oIdx) => (
                    <label 
                      key={oIdx} 
                      className="flex items-center gap-3 p-3 rounded-lg border border-border/40 bg-muted/10 min-h-[46px]"
                    >
                      <input
                        type="radio"
                        disabled
                        className="h-5 w-5 border-zinc-300 dark:border-zinc-700 text-primary shrink-0"
                      />
                      <span className="text-base font-medium text-muted-foreground">
                        {opt}
                      </span>
                    </label>
                  ))}
                </div>
              )}

              {/* DATE INPUT */}
              {field.type === 'date' && (
                <Input
                  type="date"
                  disabled
                  className="h-12 text-base px-4 rounded-md bg-muted/30 border-border/60 w-full"
                />
              )}

              {field.helpText && (
                <p className="text-xs text-muted-foreground/80 pl-9 leading-normal">{field.helpText}</p>
              )}
            </div>
          </div>
        )}
      </div>
    </div>
  );
}

// ==========================================
// HELPER FUNCTIONS & COMPLEMENTARY COMPONENTS
// ==========================================

const getFieldDepth = (field: FormField, fieldsList: FormField[]): number => {
  let depth = 0;
  let current = field;
  const visited = new Set<string>();
  while (current.dependsOnFieldId) {
    if (visited.has(current.id)) break;
    visited.add(current.id);
    const parent = fieldsList.find(f => f.id === current.dependsOnFieldId);
    if (!parent) break;
    depth += 1;
    current = parent;
  }
  return depth;
};

interface FloatingAddBlockButtonProps {
  onAdd: (type: FormField['type']) => void;
}

function FloatingAddBlockButton({ onAdd }: FloatingAddBlockButtonProps) {
  return (
    <div className="relative flex items-center justify-center my-1 group/fab h-6">
      <div className="absolute inset-x-0 h-[1px] bg-primary/10 group-hover/fab:bg-primary/25 transition-colors pointer-events-none" />
      
      <Popover>
        <PopoverTrigger asChild>
          <Button
            size="icon"
            variant="outline"
            className="w-7 h-7 rounded-full bg-background border-border hover:border-primary hover:text-primary hover:scale-110 shadow-sm opacity-25 group-hover/fab:opacity-100 hover:opacity-100 focus:opacity-100 transition-all z-10 cursor-pointer"
            title="Inserir campo aqui"
          >
            <Plus className="w-4 h-4" />
          </Button>
        </PopoverTrigger>
        <PopoverContent align="center" className="w-56 p-2 border border-zinc-200 dark:border-zinc-800 bg-white dark:bg-zinc-950 shadow-md">
          <div className="space-y-1">
            <h4 className="text-[10px] font-bold uppercase tracking-wider text-muted-foreground px-2 py-1">Inserir Bloco</h4>
            <div className="grid grid-cols-1 gap-0.5">
              <Button
                variant="ghost"
                onClick={() => onAdd('text')}
                className="justify-start text-left h-8 px-2 text-xs hover:bg-primary/5 hover:text-primary rounded cursor-pointer w-full font-medium"
              >
                <Type className="w-3.5 h-3.5 mr-2 text-muted-foreground shrink-0" />
                Texto Simples
              </Button>
              <Button
                variant="ghost"
                onClick={() => onAdd('textarea')}
                className="justify-start text-left h-8 px-2 text-xs hover:bg-primary/5 hover:text-primary rounded cursor-pointer w-full font-medium"
              >
                <AlignLeft className="w-3.5 h-3.5 mr-2 text-muted-foreground shrink-0" />
                Texto Longo
              </Button>
              <Button
                variant="ghost"
                onClick={() => onAdd('number')}
                className="justify-start text-left h-8 px-2 text-xs hover:bg-primary/5 hover:text-primary rounded cursor-pointer w-full font-medium"
              >
                <Hash className="w-3.5 h-3.5 mr-2 text-muted-foreground shrink-0" />
                Número
              </Button>
              <Button
                variant="ghost"
                onClick={() => onAdd('select')}
                className="justify-start text-left h-8 px-2 text-xs hover:bg-primary/5 hover:text-primary rounded cursor-pointer w-full font-medium"
              >
                <ChevronsUpDown className="w-3.5 h-3.5 mr-2 text-muted-foreground shrink-0" />
                Dropdown
              </Button>
              <Button
                variant="ghost"
                onClick={() => onAdd('checkbox')}
                className="justify-start text-left h-8 px-2 text-xs hover:bg-primary/5 hover:text-primary rounded cursor-pointer w-full font-medium"
              >
                <CheckSquare className="w-3.5 h-3.5 mr-2 text-muted-foreground shrink-0" />
                Multi-Escolha
              </Button>
              <Button
                variant="ghost"
                onClick={() => onAdd('radio')}
                className="justify-start text-left h-8 px-2 text-xs hover:bg-primary/5 hover:text-primary rounded cursor-pointer w-full font-medium"
              >
                <Radio className="w-3.5 h-3.5 mr-2 text-muted-foreground shrink-0" />
                Escolha Única
              </Button>
              <Button
                variant="ghost"
                onClick={() => onAdd('date')}
                className="justify-start text-left h-8 px-2 text-xs hover:bg-primary/5 hover:text-primary rounded cursor-pointer w-full font-medium"
              >
                <Calendar className="w-3.5 h-3.5 mr-2 text-muted-foreground shrink-0" />
                Data
              </Button>
            </div>
          </div>
        </PopoverContent>
      </Popover>
    </div>
  );
}
