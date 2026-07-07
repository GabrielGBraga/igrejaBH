import { useState, useEffect } from "react"
import { useNavigate } from "react-router-dom"
import {
  isFieldVisible,
  formatValue,
  isValidCPF,
  isValidPhone,
  fetchAddressFromCep,
  calculateTotalPrice,
} from "@/lib/forms"
import type { FormField, FormTemplate, FormSubmission } from "@/lib/forms"
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
  GripVertical,
  AlertTriangle,
  Users,
  Table,
  BarChart3,
} from "lucide-react"
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
  CardFooter,
} from "@/components/ui/card"
import { Input } from "@/components/ui/input"
import { Button } from "@/components/ui/button"
import { Textarea } from "@/components/ui/textarea"
import { toast } from "sonner"
import supabase from "@/lib/supabase"
import { Skeleton } from "@/components/ui/skeleton"
import {
  DndContext,
  closestCenter,
  KeyboardSensor,
  PointerSensor,
  useSensor,
  useSensors,
} from "@dnd-kit/core"
import type { DragEndEvent } from "@dnd-kit/core"
import {
  arrayMove,
  SortableContext,
  sortableKeyboardCoordinates,
  verticalListSortingStrategy,
  useSortable,
} from "@dnd-kit/sortable"
import { CSS } from "@dnd-kit/utilities"
import {
  Popover,
  PopoverTrigger,
  PopoverContent,
} from "@/components/ui/popover"
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select"

// Unique ID generators defined outside the component for React rendering purity
const generateFormId = () => `form-${Math.random().toString(36).substring(7)}`
const generateFieldId = () => `field-${Math.random().toString(36).substring(7)}`
const generateSubId = () => `sub-${Math.random().toString(36).substring(7)}`

// Map Supabase public.forms Row to FormTemplate
// eslint-disable-next-line @typescript-eslint/no-explicit-any
const mapDbFormToTemplate = (dbForm: any): FormTemplate => {
  return {
    id: dbForm.id,
    name: dbForm.name,
    description: dbForm.description || "",
    fields: (dbForm.fields as FormField[]) || [],
    createdAt: dbForm.created_at,
    isPublic: dbForm.is_public,
    isActive: dbForm.is_active,
  }
}

// Map Supabase public.form_submissions Row to FormSubmission
// eslint-disable-next-line @typescript-eslint/no-explicit-any
const mapDbSubmission = (dbSub: any): FormSubmission => {
  return {
    id: dbSub.id,
    formId: dbSub.form_id,
    submittedAt: dbSub.submitted_at,
    data: dbSub.data as Record<string, any>,
  }
}

export default function FormBuilder() {
  const navigate = useNavigate()

  // Page core states
  const [forms, setForms] = useState<FormTemplate[]>([])
  const [submissions, setSubmissions] = useState<
    Record<string, FormSubmission[]>
  >({})
  const [loading, setLoading] = useState(true)
  const [retreats, setRetreats] = useState<{ id: string; title: string; status: string | null; form_id: string | null; end_date: string | null; max_participants: number | null; registration_deadline: string | null }[]>([])

  // Navigation and active view states
  const [currentView, setCurrentView] = useState<"list" | "builder">("list")
  const [selectedForm, setSelectedForm] = useState<FormTemplate | null>(null)

  // Builder panel states
  const [editingFieldId, setEditingFieldId] = useState<string | null>(null)
  const [builderTab, setBuilderTab] = useState<"edit" | "preview" | "json">(
    "edit"
  )
  const [newOptionTexts, setNewOptionTexts] = useState<Record<string, string>>(
    {}
  )
  const [showPreview, setShowPreview] = useState(true)

  const isFormConnectedToEvent = selectedForm
    ? retreats.some((r) => r.form_id === selectedForm.id)
    : false

  // Load forms and submissions from Supabase on mount
  useEffect(() => {
    async function loadData() {
      try {
        setLoading(true)
        // Fetch forms from database
        const { data: dbForms, error: formsError } = await supabase
          .from("forms")
          .select("*")
          .order("created_at", { ascending: false })

        if (formsError) throw formsError

        const mappedForms = (dbForms || []).map(mapDbFormToTemplate)
        setForms(mappedForms)

        // Fetch submissions from database
        const { data: dbSubs, error: subsError } = await supabase
          .from("form_submissions")
          .select("*")
          .order("submitted_at", { ascending: false })

        if (subsError) {
          console.error("Error loading submissions from Supabase:", subsError)
        }

        const subsGrouped: Record<string, FormSubmission[]> = {}
        if (dbSubs) {
          dbSubs.forEach((sub) => {
            const mapped = mapDbSubmission(sub)
            if (!subsGrouped[mapped.formId]) {
              subsGrouped[mapped.formId] = []
            }
            subsGrouped[mapped.formId].push(mapped)
          })
        }
        setSubmissions(subsGrouped)

        // Fetch retreats to correlate forms
        const { data: dbRetreats, error: retreatsError } = await supabase
          .from("retreats")
          .select("id, title, status, form_id, end_date, max_participants, registration_deadline")

        if (retreatsError) {
          console.error("Error loading retreats in FormBuilder:", retreatsError)
        } else {
          setRetreats(dbRetreats || [])
        }
      } catch (err) {
        console.error("Error loading forms from Supabase:", err)
        toast.error("Erro ao carregar formulários do banco de dados.")
      } finally {
        setLoading(false)
      }
    }

    loadData()
  }, [])

  // Notion-style Click Outside to collapse active editor card
  useEffect(() => {
    function handleClickOutside(event: MouseEvent) {
      const target = event.target as HTMLElement
      if (editingFieldId) {
        const activeElement = document.getElementById(
          `editor-card-${editingFieldId}`
        )
        const isPopoverOrDropdown =
          target.closest('[data-slot="popover-content"]') ||
          target.closest("[data-radix-popper-content-wrapper]") ||
          target.closest('[role="menu"]') ||
          target.closest('[role="listbox"]') ||
          target.closest(".toast") ||
          target.closest(".sonner-toast")
        if (
          activeElement &&
          !activeElement.contains(target) &&
          !isPopoverOrDropdown
        ) {
          setEditingFieldId(null)
        }
      }
    }

    document.addEventListener("mousedown", handleClickOutside)
    return () => {
      document.removeEventListener("mousedown", handleClickOutside)
    }
  }, [editingFieldId])

  // Submissions list modal states
  const [viewingSubmissionsFormId, setViewingSubmissionsFormId] = useState<
    string | null
  >(null)

  // Live preview form submission state
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  const [previewFormData, setPreviewFormData] = useState<Record<string, any>>(
    {}
  )
  const [previewFormErrors, setPreviewFormErrors] = useState<
    Record<string, string>
  >({})

  const sensors = useSensors(
    useSensor(PointerSensor),
    useSensor(KeyboardSensor, {
      coordinateGetter: sortableKeyboardCoordinates,
    })
  )

  // Share link copy function
  const handleShareLink = (form: FormTemplate, e: React.MouseEvent) => {
    e.stopPropagation()
    const shareUrl = `${window.location.origin}/formularios/responder/${form.id}`
    navigator.clipboard.writeText(shareUrl)
    toast.success("Link do formulário copiado para a área de transferência!")
  }

  // Create a new empty form
  const handleCreateNewForm = () => {
    const newForm: FormTemplate = {
      id: generateFormId(),
      name: "Novo Formulário",
      description:
        "Descreva a finalidade deste formulário para os irmãos e discípulos.",
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
          options: [],
        },
      ],
    }

    setSelectedForm(newForm)
    setEditingFieldId(newForm.fields[0].id)
    setCurrentView("builder")
    setBuilderTab("edit")
    setPreviewFormData({})
    setPreviewFormErrors({})
  }

  // Edit existing form
  const handleEditForm = (form: FormTemplate) => {
    // Clone deep to avoid mutating local state until saved
    setSelectedForm(JSON.parse(JSON.stringify(form)))
    setCurrentView("builder")
    setBuilderTab("edit")
    setEditingFieldId(form.fields.length > 0 ? form.fields[0].id : null)
    setPreviewFormData({})
    setPreviewFormErrors({})
  }

  // Save the form template
  const handleSaveForm = async () => {
    if (!selectedForm) return

    if (!selectedForm.name.trim()) {
      toast.error("O nome do formulário é obrigatório.")
      return
    }

    if (selectedForm.fields.length === 0) {
      toast.error("Adicione pelo menos um campo ao formulário.")
      return
    }

    // Verify fields have labels
    const emptyLabelField = selectedForm.fields.find((f) => !f.label.trim())
    if (emptyLabelField) {
      toast.error("Todos os campos devem ter um título (Label) definido.")
      setEditingFieldId(emptyLabelField.id)
      setBuilderTab("edit")
      return
    }

    // Verify option fields have options
    const optionFieldWithNoOptions = selectedForm.fields.find(
      (f) =>
        ["select", "checkbox", "radio"].includes(f.type) &&
        f.options.length === 0
    )
    if (optionFieldWithNoOptions) {
      toast.error(
        `O campo "${optionFieldWithNoOptions.label}" precisa de pelo menos uma opção.`
      )
      setEditingFieldId(optionFieldWithNoOptions.id)
      setBuilderTab("edit")
      return
    }

    try {
      const savingToastId = toast.loading(
        "Salvando formulário no banco de dados..."
      )
      const {
        data: { session },
      } = await supabase.auth.getSession()

      const { error } = await supabase.from("forms").upsert({
        id: selectedForm.id,
        name: selectedForm.name,
        description: selectedForm.description || null,
        fields: selectedForm.fields as any,
        is_public: !!selectedForm.isPublic,
        created_by: session?.user?.id || null,
      })

      if (error) throw error
      toast.dismiss(savingToastId)

      const index = forms.findIndex((f) => f.id === selectedForm.id)
      let updated: FormTemplate[]

      if (index >= 0) {
        // Update existing
        updated = [...forms]
        updated[index] = selectedForm
        toast.success("Formulário atualizado com sucesso!")
      } else {
        // Add new
        updated = [selectedForm, ...forms]
        toast.success("Novo formulário criado com sucesso!")
      }

      setForms(updated)
      setCurrentView("list")
      setSelectedForm(null)
    } catch (err: any) {
      console.error("Error saving form to Supabase:", err)
      toast.error(
        `Falha ao salvar formulário: ${err.message || "Erro desconhecido"}`
      )
    }
  }

  // Duplicate a form
  const handleDuplicateForm = async (
    form: FormTemplate,
    e: React.MouseEvent
  ) => {
    e.stopPropagation()
    const duplicated: FormTemplate = {
      ...form,
      id: generateFormId(),
      name: `${form.name} (Cópia)`,
      createdAt: new Date().toISOString(),
    }

    try {
      const savingToastId = toast.loading("Duplicando formulário...")
      const {
        data: { session },
      } = await supabase.auth.getSession()

      const { error } = await supabase.from("forms").insert({
        id: duplicated.id,
        name: duplicated.name,
        description: duplicated.description || null,
        fields: duplicated.fields as any,
        is_public: !!duplicated.isPublic,
        created_by: session?.user?.id || null,
      })

      if (error) throw error
      toast.dismiss(savingToastId)

      const updated = [duplicated, ...forms]
      setForms(updated)
      toast.success("Formulário duplicado!")
    } catch (err: any) {
      console.error("Error duplicating form:", err)
      toast.error(`Falha ao duplicar formulário: ${err.message}`)
    }
  }

  // Toggle form active/inactive status
  const handleToggleFormActive = async (
    form: FormTemplate,
    e: React.MouseEvent
  ) => {
    e.stopPropagation()
    const nextActive = !form.isActive
    try {
      const { error } = await supabase
        .from("forms")
        .update({ is_active: nextActive })
        .eq("id", form.id)

      if (error) throw error

      setForms((prev) =>
        prev.map((f) => (f.id === form.id ? { ...f, isActive: nextActive } : f))
      )
      toast.success(
        `Formulário ${nextActive ? "ativado" : "desativado"} com sucesso!`
      )
    } catch (err: any) {
      toast.error("Erro ao alterar status do formulário: " + err.message)
    }
  }

  // Delete a form
  const handleDeleteForm = async (formId: string, e: React.MouseEvent) => {
    e.stopPropagation()
    if (
      confirm(
        "Tem certeza que deseja excluir este formulário? Isso também apagará todas as respostas salvas."
      )
    ) {
      try {
        const deletingToastId = toast.loading("Excluindo formulário...")
        const { error } = await supabase.from("forms").delete().eq("id", formId)

        if (error) throw error
        toast.dismiss(deletingToastId)

        const updatedForms = forms.filter((f) => f.id !== formId)
        setForms(updatedForms)

        const updatedSubmissions = { ...submissions }
        delete updatedSubmissions[formId]
        setSubmissions(updatedSubmissions)

        toast.success("Formulário excluído.")
      } catch (err: any) {
        console.error("Error deleting form:", err)
        toast.error(`Falha ao excluir formulário: ${err.message}`)
      }
    }
  }

  // Export form schema as JSON file/clipboard
  const handleExportJSON = (form: FormTemplate, e: React.MouseEvent) => {
    e.stopPropagation()
    const schema = JSON.stringify(form, null, 2)
    navigator.clipboard.writeText(schema)
    toast.success("Esquema do formulário copiado como JSON!")
  }

  // Import form schema from clipboard JSON
  const handleImportJSON = async () => {
    const input = prompt("Cole o JSON do esquema do formulário aqui:")
    if (!input) return

    try {
      const parsed = JSON.parse(input)
      if (!parsed.name || !Array.isArray(parsed.fields)) {
        toast.error("JSON inválido: Estrutura do formulário incompleta.")
        return
      }

      const imported: FormTemplate = {
        id: generateFormId(),
        name: parsed.name + " (Importado)",
        description: parsed.description || "",
        createdAt: new Date().toISOString(),
        isPublic: !!parsed.isPublic,
        fields: parsed.fields.map(
          (f: {
            id?: string
            type?: FormField["type"]
            label?: string
            placeholder?: string
            required?: boolean
            helpText?: string
            options?: string[]
          }) => ({
            id: f.id || generateFieldId(),
            type: f.type || "text",
            label: f.label || "Campo sem nome",
            placeholder: f.placeholder || "",
            required: !!f.required,
            helpText: f.helpText || "",
            options: Array.isArray(f.options) ? f.options : [],
          })
        ),
      }

      const savingToastId = toast.loading("Importando formulário...")
      const {
        data: { session },
      } = await supabase.auth.getSession()

      const { error } = await supabase.from("forms").insert({
        id: imported.id,
        name: imported.name,
        description: imported.description || null,
        fields: imported.fields as any,
        is_public: !!imported.isPublic,
        created_by: session?.user?.id || null,
      })

      if (error) throw error
      toast.dismiss(savingToastId)

      const updated = [imported, ...forms]
      setForms(updated)
      toast.success("Formulário importado com sucesso!")
    } catch (err: any) {
      console.error("Error importing JSON:", err)
      toast.error(
        `Falha ao importar JSON: ${err.message || "Verifique a formatação do JSON."}`
      )
    }
  }

  // Add field to the template editor
  const handleAddField = (type: FormField["type"], insertIndex?: number) => {
    if (!selectedForm) return

    const newField: FormField = {
      id: generateFieldId(),
      type,
      label: `Novo Campo de ${
        type === "text"
          ? "Texto"
          : type === "textarea"
            ? "Texto Longo"
            : type === "number"
              ? "Número"
              : type === "select"
                ? "Seleção"
                : type === "checkbox"
                  ? "Múltipla Escolha"
                  : type === "radio"
                    ? "Escolha Única"
                    : "Data"
      }`,
      placeholder: type === "date" ? "" : "Digite sua resposta...",
      required: false,
      helpText: "",
      options: ["select", "checkbox", "radio"].includes(type)
        ? ["Opção 1", "Opção 2"]
        : [],
    }

    const updatedFields = [...selectedForm.fields]
    if (typeof insertIndex === "number") {
      updatedFields.splice(insertIndex, 0, newField)
    } else {
      updatedFields.push(newField)
    }

    setSelectedForm({
      ...selectedForm,
      fields: updatedFields,
    })
    setEditingFieldId(newField.id)
    toast.success("Campo adicionado!")
  }

  // Remove field from the template editor
  const handleRemoveField = (fieldId: string) => {
    if (!selectedForm) return
    const updatedFields = selectedForm.fields.filter((f) => f.id !== fieldId)
    setSelectedForm({
      ...selectedForm,
      fields: updatedFields,
    })
    if (editingFieldId === fieldId) {
      setEditingFieldId(updatedFields.length > 0 ? updatedFields[0].id : null)
    }
    toast.info("Campo removido.")
  }

  // Drag and drop end event handler
  const handleDragEnd = (event: DragEndEvent) => {
    const { active, over } = event
    if (!selectedForm || !over || active.id === over.id) return

    const oldIndex = selectedForm.fields.findIndex((f) => f.id === active.id)
    const newIndex = selectedForm.fields.findIndex((f) => f.id === over.id)

    if (oldIndex !== -1 && newIndex !== -1) {
      const newFields = arrayMove(selectedForm.fields, oldIndex, newIndex)
      setSelectedForm({ ...selectedForm, fields: newFields })
    }
  }

  // Duplicate a field inside the builder canvas
  const handleDuplicateField = (fieldId: string) => {
    if (!selectedForm) return
    const fieldIndex = selectedForm.fields.findIndex((f) => f.id === fieldId)
    if (fieldIndex === -1) return
    const originalField = selectedForm.fields[fieldIndex]
    const duplicatedField: FormField = {
      ...originalField,
      id: generateFieldId(),
      label: originalField.label
        ? `${originalField.label} (Cópia)`
        : "Campo sem nome (Cópia)",
    }
    const fields = [...selectedForm.fields]
    fields.splice(fieldIndex + 1, 0, duplicatedField)
    setSelectedForm({ ...selectedForm, fields })
    toast.success("Campo duplicado com sucesso!")
  }

  // Update field property
  const handleUpdateField = (fieldId: string, updates: Partial<FormField>) => {
    if (!selectedForm) return
    const fields = selectedForm.fields.map((f) => {
      if (f.id === fieldId) {
        return { ...f, ...updates }
      }
      return f
    })
    setSelectedForm({ ...selectedForm, fields })
  }

  // Make all fields required
  const handleMakeAllFieldsRequired = () => {
    if (!selectedForm) return
    const fields = selectedForm.fields.map((f) => ({
      ...f,
      required: true,
    }))
    setSelectedForm({ ...selectedForm, fields })
    toast.success("Todos os campos agora são obrigatórios!")
  }

  // Add option to choice field (select, checkbox, radio)
  const handleAddOption = (fieldId: string, text: string) => {
    if (!text || !text.trim()) {
      toast.error("Escreva o texto da opção.")
      return
    }

    const trimmed = text.trim()

    if (!selectedForm) return
    const fields = selectedForm.fields.map((f) => {
      if (f.id === fieldId) {
        if (f.options.includes(trimmed)) {
          toast.error("Essa opção já existe.")
          return f
        }
        return { ...f, options: [...f.options, trimmed] }
      }
      return f
    })

    setSelectedForm({ ...selectedForm, fields })
    setNewOptionTexts((prev) => ({ ...prev, [fieldId]: "" }))
    toast.success("Opção adicionada!")
  }

  // Remove option from choice field
  const handleRemoveOption = (fieldId: string, optionIndex: number) => {
    if (!selectedForm) return
    const fields = selectedForm.fields.map((f) => {
      if (f.id === fieldId) {
        const options = f.options.filter((_, i) => i !== optionIndex)
        return { ...f, options }
      }
      return f
    })
    setSelectedForm({ ...selectedForm, fields })
    toast.info("Opção removida.")
  }

  // Handle preview form value inputs
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  const handlePreviewInputChange = async (fieldId: string, val: any) => {
    if (!selectedForm) return
    const targetField = selectedForm.fields.find((f) => f.id === fieldId)
    let formattedVal = val
    if (targetField && targetField.type === "text") {
      formattedVal = formatValue(val, targetField.validationPreset)
    }

    setPreviewFormData((prev) => ({
      ...prev,
      [fieldId]: formattedVal,
    }))

    // Clear error once answered
    if (previewFormErrors[fieldId]) {
      setPreviewFormErrors((prev) => {
        const copy = { ...prev }
        delete copy[fieldId]
        return copy
      })
    }

    // Trigger CEP Lookup in preview mode
    if (
      targetField &&
      targetField.type === "text" &&
      targetField.validationPreset === "cep"
    ) {
      const cleanCep = formattedVal.replace(/\D/g, "")
      if (cleanCep.length === 8) {
        try {
          const toastId = toast.loading("Buscando CEP (Simulação)...")
          const address = await fetchAddressFromCep(cleanCep)
          toast.dismiss(toastId)

          if (address) {
            if (address.error) {
              toast.error("CEP não encontrado.")
              setPreviewFormErrors((prev) => ({
                ...prev,
                [fieldId]: "CEP não encontrado.",
              }))
              return
            }

            toast.success(
              `CEP encontrado: ${address.logradouro || ""}, ${address.bairro || ""} - ${address.localidade}/${address.uf}`
            )

            const hasExplicitMapping = !!(
              targetField.cepMapping?.streetFieldId ||
              targetField.cepMapping?.neighborhoodFieldId ||
              targetField.cepMapping?.cityFieldId ||
              targetField.cepMapping?.stateFieldId
            )

            setPreviewFormData((prev) => {
              const nextFormData = { ...prev }
              selectedForm.fields.forEach((f) => {
                if (f.id === fieldId) return
                if (f.type !== "text" && f.type !== "textarea") return

                if (hasExplicitMapping) {
                  if (targetField.cepMapping?.streetFieldId === f.id) {
                    nextFormData[f.id] = address.logradouro || ""
                  } else if (
                    targetField.cepMapping?.neighborhoodFieldId === f.id
                  ) {
                    nextFormData[f.id] = address.bairro || ""
                  } else if (targetField.cepMapping?.cityFieldId === f.id) {
                    nextFormData[f.id] = address.localidade || ""
                  } else if (targetField.cepMapping?.stateFieldId === f.id) {
                    nextFormData[f.id] = address.uf || ""
                  }
                } else {
                  const label = (f.label || "").toLowerCase()
                  if (
                    label.includes("rua") ||
                    label.includes("logradouro") ||
                    label.includes("endereço") ||
                    label.includes("endereco")
                  ) {
                    if (!nextFormData[f.id])
                      nextFormData[f.id] = address.logradouro || ""
                  } else if (label.includes("bairro")) {
                    if (!nextFormData[f.id])
                      nextFormData[f.id] = address.bairro || ""
                  } else if (
                    label.includes("cidade") ||
                    label.includes("município") ||
                    label.includes("municipio")
                  ) {
                    if (!nextFormData[f.id])
                      nextFormData[f.id] = address.localidade || ""
                  } else if (label.includes("estado") || label.includes("uf")) {
                    if (!nextFormData[f.id])
                      nextFormData[f.id] = address.uf || ""
                  }
                }
              })
              return nextFormData
            })
          } else {
            toast.error(
              "Não foi possível validar o CEP (serviço indisponível)."
            )
          }
        } catch (err) {
          console.error("CEP lookup failed in preview", err)
        }
      }
    }
  }

  // Handle multi-checkbox previews
  const handlePreviewCheckboxChange = (
    fieldId: string,
    option: string,
    isChecked: boolean
  ) => {
    const currentList = previewFormData[fieldId] || []
    let updatedList
    if (isChecked) {
      updatedList = [...currentList, option]
    } else {
      updatedList = currentList.filter((x: string) => x !== option)
    }

    handlePreviewInputChange(fieldId, updatedList)
  }

  // Submit the preview form response locally
  const handlePreviewSubmit = (
    e: React.FormEvent,
    formTemplate: FormTemplate
  ) => {
    e.preventDefault()

    // Validate inputs
    const errors: Record<string, string> = {}
    formTemplate.fields.forEach((field) => {
      // Only validate if field is visible
      if (!isFieldVisible(field, previewFormData, formTemplate.fields)) return

      const val = previewFormData[field.id]

      // 1. Required Check
      if (field.required) {
        if (field.type === "checkbox") {
          if (!val || val.length === 0) {
            errors[field.id] = "Selecione pelo menos uma opção."
          }
        } else if (
          val === undefined ||
          val === null ||
          (typeof val === "string" && val.trim() === "")
        ) {
          errors[field.id] = "Este campo é obrigatório."
        }
      }

      // 2. Custom Validation Presets & Bounds Checks
      if (
        val !== undefined &&
        val !== null &&
        (typeof val !== "string" || val.trim() !== "")
      ) {
        const strVal = String(val).trim()

        if (["text", "textarea"].includes(field.type)) {
          // Character range check
          if (
            field.minLength !== undefined &&
            strVal.length < field.minLength
          ) {
            errors[field.id] =
              `O texto deve ter no mínimo ${field.minLength} caracteres.`
          }
          if (
            field.maxLength !== undefined &&
            strVal.length > field.maxLength
          ) {
            errors[field.id] =
              `O texto deve ter no máximo ${field.maxLength} caracteres.`
          }

          // Preset validation
          if (field.validationPreset && field.validationPreset !== "none") {
            if (field.validationPreset === "phone") {
              if (!isValidPhone(strVal)) {
                errors[field.id] =
                  "Telefone celular inválido. Digite um DDD válido e o dígito 9 antes do número."
              }
            } else if (field.validationPreset === "cpf") {
              if (!isValidCPF(strVal)) {
                errors[field.id] =
                  "CPF inválido. Insira um número de CPF válido."
              }
            } else if (field.validationPreset === "cep") {
              const cepRegex = /^\d{5}-?\d{3}$/
              if (!cepRegex.test(strVal)) {
                errors[field.id] = "CEP inválido. Formato esperado: 30123-456"
              } else if (
                previewFormErrors[field.id] === "CEP não encontrado."
              ) {
                errors[field.id] = "CEP não encontrado."
              }
            } else if (field.validationPreset === "email") {
              const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
              if (!emailRegex.test(strVal)) {
                errors[field.id] =
                  "E-mail inválido. Formato esperado: exemplo@email.com"
              }
            }
          }
        } else if (field.type === "number") {
          const numVal = Number(val)
          if (field.minNumber !== undefined && numVal < field.minNumber) {
            errors[field.id] =
              `O valor deve ser maior ou igual a ${field.minNumber}.`
          }
          if (field.maxNumber !== undefined && numVal > field.maxNumber) {
            errors[field.id] =
              `O valor deve ser menor ou igual a ${field.maxNumber}.`
          }
        }
      }
    })

    if (Object.keys(errors).length > 0) {
      setPreviewFormErrors(errors)
      toast.error("Por favor, corrija os erros de validação antes de enviar.")
      return
    }

    // Filter values for invisible fields to avoid sending trash data
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const filteredData: Record<string, any> = {}
    formTemplate.fields.forEach((field) => {
      if (
        isFieldVisible(field, previewFormData, formTemplate.fields) &&
        previewFormData[field.id] !== undefined
      ) {
        filteredData[field.id] = previewFormData[field.id]
      }
    })

    // Process submission
    const newSubmission: FormSubmission = {
      id: generateSubId(),
      formId: formTemplate.id,
      submittedAt: new Date().toISOString(),
      data: filteredData,
    }

    const currentFormSubs = submissions[formTemplate.id] || []
    const updatedSubmissions = {
      ...submissions,
      [formTemplate.id]: [newSubmission, ...currentFormSubs],
    }

    setSubmissions(updatedSubmissions)
    toast.success("Resposta enviada e registrada com sucesso (Simulação)!")

    // Clear preview fields
    setPreviewFormData({})
    setPreviewFormErrors({})
  }

  // Clear all submissions for a form
  const handleClearSubmissions = async (formId: string) => {
    if (
      confirm(
        "Tem certeza que deseja apagar TODAS as respostas registradas para este formulário?"
      )
    ) {
      try {
        const clearingToastId = toast.loading(
          "Apagando respostas do banco de dados..."
        )
        const { error } = await supabase
          .from("form_submissions")
          .delete()
          .eq("form_id", formId)

        if (error) throw error
        toast.dismiss(clearingToastId)

        const updated = { ...submissions }
        delete updated[formId]
        setSubmissions(updated)
        toast.success("Respostas apagadas.")
      } catch (err: any) {
        console.error("Error clearing submissions:", err)
        toast.error(`Falha ao apagar respostas: ${err.message}`)
      }
    }
  }

  // Delete a single submission
  const handleDeleteSubmission = async (submissionId: string, formId: string) => {
    if (confirm("Tem certeza que deseja apagar esta resposta?")) {
      try {
        const deletingToastId = toast.loading(
          "Apagando resposta do banco de dados..."
        )
        const { error } = await supabase
          .from("form_submissions")
          .delete()
          .eq("id", submissionId)

        if (error) throw error
        toast.dismiss(deletingToastId)

        const updated = { ...submissions }
        if (updated[formId]) {
          updated[formId] = updated[formId].filter((sub) => sub.id !== submissionId)
        }
        setSubmissions(updated)
        toast.success("Resposta apagada.")
      } catch (err: any) {
        console.error("Error deleting submission:", err)
        toast.error(`Falha ao apagar resposta: ${err.message}`)
      }
    }
  }

  // Helper to format timestamps
  const formatDate = (isoString: string) => {
    return new Date(isoString).toLocaleDateString("pt-BR", {
      day: "2-digit",
      month: "2-digit",
      year: "numeric",
      hour: "2-digit",
      minute: "2-digit",
    })
  }

  return (
    <div className="animate-in space-y-8 pb-12 duration-500 fade-in slide-in-from-bottom-4">
      {/* VIEW A: LIST / DASHBOARD */}
      {currentView === "list" && (
        <>
          <header className="flex flex-col justify-between gap-6 border-b border-border pb-6 md:flex-row md:items-center">
            <div>
              <h1 className="flex items-center gap-3 text-3xl font-bold tracking-tight text-foreground">
                <ClipboardList className="h-8 w-8 text-primary" />
                Gerenciador de Formulários
              </h1>
              <p className="mt-1 text-muted-foreground">
                Crie e configure formulários dinâmicos para a vida comunitária,
                pesquisas e registros de PG.
              </p>
            </div>

            <div className="flex w-full flex-col gap-3 sm:flex-row md:w-auto">
              <Button
                onClick={handleImportJSON}
                variant="outline"
                className="h-11 w-full cursor-pointer rounded-md border-border/80 transition-all hover:bg-accent active:scale-95 sm:w-auto"
              >
                <Upload className="mr-2 h-4 w-4" />
                Importar JSON
              </Button>

              <Button
                onClick={handleCreateNewForm}
                className="h-11 w-full cursor-pointer rounded-md bg-primary px-5 font-bold text-primary-foreground shadow-sm transition-all hover:bg-primary/90 active:scale-95 sm:w-auto"
              >
                <Plus className="mr-2 h-5 w-5" />
                Novo Formulário
              </Button>
            </div>
          </header>

          {/* Grid of Forms */}
          {loading ? (
            <div className="grid grid-cols-1 gap-6 md:grid-cols-2 lg:grid-cols-3">
              {[1, 2, 3].map((n) => (
                <Card
                  key={n}
                  className="flex h-[220px] flex-col justify-between overflow-hidden rounded-xl border-border/50 bg-card/30 p-6 shadow-sm backdrop-blur-sm"
                >
                  <div className="space-y-3">
                    <Skeleton className="h-6 w-2/3" />
                    <Skeleton className="h-4 w-1/3" />
                    <Skeleton className="mt-4 h-4 w-full" />
                    <Skeleton className="h-4 w-5/6" />
                  </div>
                  <div className="mt-6 flex items-center justify-between">
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
            <div className="flex flex-col items-center justify-center space-y-4 rounded-2xl border border-dashed border-border/50 bg-muted/10 py-24 text-center">
              <div className="flex h-16 w-16 items-center justify-center rounded-full bg-muted/40">
                <ClipboardList className="h-8 w-8 text-muted-foreground/40" />
              </div>
              <div>
                <h3 className="text-lg font-bold text-foreground">
                  Nenhum formulário cadastrado
                </h3>
                <p className="mx-auto mt-1 max-w-sm text-muted-foreground">
                  Comece importando um modelo ou criando um novo formulário do
                  zero.
                </p>
              </div>
              <Button onClick={handleCreateNewForm} className="mt-4">
                Criar Primeiro Formulário
              </Button>
            </div>
          ) : (
            <div className="grid grid-cols-1 gap-6 md:grid-cols-2 lg:grid-cols-3">
              {forms.map((form) => {
                const subCount = submissions[form.id]?.length || 0
                const connectedRetreats = retreats.filter((r) => r.form_id === form.id)
                
                const hasDraftRetreat = connectedRetreats.some((r) => r.status === "rascunho")
                const hasEndedRetreat = connectedRetreats.some((r) => r.status === "encerrado")
                const hasExpiredRetreat = connectedRetreats.some((r) => {
                  const deadline = r.registration_deadline || r.end_date
                  return deadline && new Date() > new Date(new Date(deadline).setHours(23, 59, 59, 999))
                })
                const hasFullRetreat = connectedRetreats.some((r) => r.max_participants && subCount >= r.max_participants)

                const isFormActive = !!form.isActive && (connectedRetreats.length === 0 || (connectedRetreats.some((r) => r.status === "ativo") && !hasExpiredRetreat && !hasFullRetreat && !hasEndedRetreat))
                const isFormSuspended = !!form.isActive && hasDraftRetreat
                const isFormExpired = !!form.isActive && hasExpiredRetreat
                const isFormFull = !!form.isActive && hasFullRetreat
                const isFormEnded = !!form.isActive && hasEndedRetreat
                return (
                  <Card
                    key={form.id}
                    className="group flex flex-col justify-between overflow-hidden rounded-xl border-border/50 bg-card/30 shadow-sm backdrop-blur-sm transition-all duration-300 hover:border-primary/20 hover:shadow-md"
                  >
                    <CardHeader className="p-6 pb-4">
                      <div className="flex items-start justify-between gap-4">
                        <div className="min-w-0 space-y-1">
                          <CardTitle className="truncate text-lg font-bold text-foreground transition-colors group-hover:text-primary">
                            {form.name}
                          </CardTitle>
                          <span className="block text-[10px] font-bold tracking-widest text-muted-foreground uppercase">
                            Criado em{" "}
                            {new Date(form.createdAt).toLocaleDateString()}
                          </span>
                        </div>
                        <div className="flex h-9 w-9 shrink-0 items-center justify-center rounded-lg bg-primary/10">
                          <FileText className="h-4 w-4 text-primary" />
                        </div>
                      </div>
                      <CardDescription className="mt-2 line-clamp-2 text-sm text-muted-foreground">
                        {form.description || "Sem descrição definida."}
                      </CardDescription>
                    </CardHeader>

                    <CardContent className="flex flex-wrap items-center gap-2 px-6 py-2">
                      <span className="inline-flex items-center rounded-full bg-muted px-2 py-0.5 text-xs font-medium text-muted-foreground">
                        <Layers className="mr-1 h-3.5 w-3.5" />
                        {form.fields.length}{" "}
                        {form.fields.length === 1 ? "campo" : "campos"}
                      </span>

                      <span
                        className={`inline-flex items-center rounded-full px-2 py-0.5 text-xs font-semibold ${subCount > 0 ? "border border-emerald-500/20 bg-emerald-500/10 text-emerald-500" : "bg-muted text-muted-foreground"}`}
                      >
                        <CheckCircle className="mr-1 h-3.5 w-3.5" />
                        {subCount} {subCount === 1 ? "resposta" : "respostas"}
                      </span>

                      {/* Event Connection Indicator */}
                      {connectedRetreats.length > 0 ? (
                        <span className="inline-flex items-center rounded-full border border-primary/20 bg-primary/10 px-2 py-0.5 text-xs font-semibold text-primary truncate max-w-full" title={connectedRetreats.map(r => r.title).join(", ")}>
                          <Calendar className="mr-1 h-3 w-3 shrink-0" />
                          Evento: {connectedRetreats.map(r => r.title).join(", ")}
                        </span>
                      ) : (
                        <span className="inline-flex items-center rounded-full border border-border bg-muted/30 px-2 py-0.5 text-xs font-semibold text-muted-foreground">
                          Sem Evento
                        </span>
                      )}

                      {/* Activity Status Indicator */}
                      {!form.isActive ? (
                        <span className="inline-flex items-center rounded-full border border-zinc-500/20 bg-zinc-500/10 px-2 py-0.5 text-xs font-semibold text-zinc-500 dark:text-zinc-400">
                          <EyeOff className="mr-1 h-3 w-3 shrink-0" />
                          Inativo
                        </span>
                      ) : isFormActive ? (
                        <span className="inline-flex items-center rounded-full border border-emerald-500/20 bg-emerald-500/10 px-2 py-0.5 text-xs font-semibold text-emerald-600 dark:text-emerald-400">
                          <CheckCircle className="mr-1 h-3 w-3 shrink-0" />
                          Ativo
                        </span>
                      ) : isFormSuspended ? (
                        <span className="inline-flex items-center rounded-full border border-amber-500/20 bg-amber-500/10 px-2 py-0.5 text-xs font-semibold text-amber-600 dark:text-amber-400" title={`Bloqueado devido ao evento em rascunho`}>
                          <AlertTriangle className="mr-1 h-3 w-3 shrink-0" />
                          Suspenso (Rascunho)
                        </span>
                      ) : isFormExpired ? (
                        <span className="inline-flex items-center rounded-full border border-red-500/20 bg-red-500/10 px-2 py-0.5 text-xs font-semibold text-red-600 dark:text-red-400" title={`Inscrições encerradas por prazo expirado`}>
                          <AlertTriangle className="mr-1 h-3 w-3 shrink-0" />
                          Prazo Expirado
                        </span>
                      ) : isFormFull ? (
                        <span className="inline-flex items-center rounded-full border border-red-500/20 bg-red-500/10 px-2 py-0.5 text-xs font-semibold text-red-600 dark:text-red-400" title={`Limite de vagas esgotado`}>
                          <Users className="mr-1 h-3 w-3 shrink-0" />
                          Esgotado (Lotação)
                        </span>
                      ) : isFormEnded ? (
                        <span className="inline-flex items-center rounded-full border border-red-500/20 bg-red-500/10 px-2 py-0.5 text-xs font-semibold text-red-600 dark:text-red-400" title={`Evento finalizado/encerrado`}>
                          <EyeOff className="mr-1 h-3 w-3 shrink-0" />
                          Encerrado
                        </span>
                      ) : (
                        <span className="inline-flex items-center rounded-full border border-zinc-500/20 bg-zinc-500/10 px-2 py-0.5 text-xs font-semibold text-zinc-500 dark:text-zinc-400">
                          <EyeOff className="mr-1 h-3 w-3 shrink-0" />
                          Inativo
                        </span>
                      )}
                    </CardContent>

                    <CardFooter className="flex flex-col justify-between gap-3 border-t border-border/40 bg-muted/20 p-6 pt-4 sm:flex-row sm:items-center">
                      <div className="flex flex-wrap items-center gap-1.5">
                        <Button
                          size="icon"
                          variant="ghost"
                          className="h-10 w-10 shrink-0 cursor-pointer rounded-md text-muted-foreground hover:bg-primary/10 hover:text-primary"
                          onClick={() => handleEditForm(form)}
                          title="Editar Formulário"
                        >
                          <Edit className="h-4.5 w-4.5" />
                        </Button>

                        <Button
                          size="icon"
                          variant="ghost"
                          className="h-10 w-10 shrink-0 cursor-pointer rounded-md text-muted-foreground hover:bg-primary/10 hover:text-primary"
                          onClick={() =>
                            navigate(`/formularios/responder/${form.id}`)
                          }
                          title="Testar Formulário"
                        >
                          <Eye className="h-4.5 w-4.5" />
                        </Button>

                        <Button
                          size="icon"
                          variant="ghost"
                          className="h-10 w-10 shrink-0 cursor-pointer rounded-md text-muted-foreground hover:bg-primary/10 hover:text-primary"
                          onClick={(e) => handleDuplicateForm(form, e)}
                          title="Duplicar Formulário"
                        >
                          <Copy className="h-4.5 w-4.5" />
                        </Button>

                        <Button
                          size="icon"
                          variant="ghost"
                          className="h-10 w-10 shrink-0 cursor-pointer rounded-md text-muted-foreground hover:bg-primary/10 hover:text-primary"
                          onClick={(e) => handleExportJSON(form, e)}
                          title="Copiar JSON"
                        >
                          <Download className="h-4.5 w-4.5" />
                        </Button>

                        <Button
                          size="icon"
                          variant="ghost"
                          className="h-10 w-10 shrink-0 cursor-pointer rounded-md text-muted-foreground hover:bg-primary/10 hover:text-primary"
                          onClick={(e) => handleShareLink(form, e)}
                          title="Compartilhar Link"
                        >
                          <Share2 className="h-4.5 w-4.5" />
                        </Button>

                        <Button
                          size="icon"
                          variant="ghost"
                          className={`h-10 w-10 shrink-0 cursor-pointer rounded-md transition-colors ${
                            form.isActive
                              ? "text-emerald-500 hover:bg-emerald-500/10"
                              : "text-muted-foreground hover:bg-primary/10 hover:text-primary"
                          }`}
                          onClick={(e) => handleToggleFormActive(form, e)}
                          title={
                            connectedRetreats.length > 0
                              ? `${form.isActive ? "Desativar" : "Ativar"} Formulário (Vinculado a: ${connectedRetreats.map(r => r.title).join(", ")})`
                              : form.isActive
                              ? "Desativar Formulário"
                              : "Ativar Formulário"
                          }
                        >
                          {form.isActive ? (
                            <CheckCircle className="h-4.5 w-4.5" />
                          ) : (
                            <EyeOff className="h-4.5 w-4.5" />
                          )}
                        </Button>
                      </div>

                      <div className="flex items-center gap-2">
                        {subCount > 0 && (
                          <Button
                            variant="link"
                            className="cursor-pointer px-1 py-1 text-xs font-bold text-primary"
                            onClick={() => setViewingSubmissionsFormId(form.id)}
                          >
                            Respostas
                          </Button>
                        )}

                        <Button
                          size="icon"
                          variant="ghost"
                          className="h-10 w-10 shrink-0 cursor-pointer rounded-md text-muted-foreground hover:bg-destructive/10 hover:text-destructive"
                          onClick={(e) => handleDeleteForm(form.id, e)}
                          title="Excluir Formulário"
                        >
                          <Trash2 className="h-4.5 w-4.5" />
                        </Button>
                      </div>
                    </CardFooter>
                  </Card>
                )
              })}
            </div>
          )}
        </>
      )}

      {/* VIEW B: ACTIVE BUILDER / EDITOR */}
      {currentView === "builder" && selectedForm && (
        <div className="space-y-6">
          {/* Header Panel */}
          <div className="flex flex-col justify-between gap-6 border-b border-border pb-6 lg:flex-row lg:items-center">
            <div className="flex items-center gap-4">
              <Button
                variant="ghost"
                size="icon"
                onClick={() => {
                  if (
                    confirm(
                      "Tem certeza que deseja sair sem salvar? Alterações não salvas serão perdidas."
                    )
                  ) {
                    setCurrentView("list")
                    setSelectedForm(null)
                  }
                }}
                className="h-11 w-11 shrink-0 cursor-pointer rounded-full border border-border bg-background hover:bg-accent active:scale-95"
              >
                <ArrowLeft className="h-5 w-5 text-foreground" />
              </Button>
              <div className="min-w-0 flex-1 space-y-1">
                <Input
                  value={selectedForm.name}
                  onChange={(e) =>
                    setSelectedForm({ ...selectedForm, name: e.target.value })
                  }
                  placeholder="Nome do Formulário"
                  className="h-auto w-full rounded-none border-none bg-transparent px-0 py-2 text-2xl font-bold text-foreground focus-visible:border-b focus-visible:border-primary/50 focus-visible:ring-0"
                />
                <Input
                  value={selectedForm.description}
                  onChange={(e) =>
                    setSelectedForm({
                      ...selectedForm,
                      description: e.target.value,
                    })
                  }
                  placeholder="Insira uma descrição explicativa curta..."
                  className="h-auto w-full rounded-none border-none bg-transparent px-0 py-1.5 text-sm text-muted-foreground focus-visible:border-b focus-visible:border-primary/30 focus-visible:ring-0"
                />
                <div className="flex items-center gap-2 pt-1">
                  <input
                    type="checkbox"
                    id="form-is-public"
                    checked={!!selectedForm.isPublic}
                    onChange={(e) =>
                      setSelectedForm({
                        ...selectedForm,
                        isPublic: e.target.checked,
                      })
                    }
                    className="h-4 w-4 cursor-pointer rounded border-zinc-300 text-primary focus:ring-primary/20 dark:border-zinc-700"
                  />
                  <label
                    htmlFor="form-is-public"
                    className="cursor-pointer text-xs font-medium text-muted-foreground transition-colors select-none hover:text-foreground"
                  >
                    Disponibilizar como Formulário Público (não exige login para
                    responder)
                  </label>
                </div>
              </div>
            </div>

            <div className="flex w-full shrink-0 flex-col items-stretch gap-3 sm:flex-row sm:items-center lg:w-auto">
              <Button
                variant="outline"
                className="hidden h-11 w-full cursor-pointer rounded-md border-border text-sm transition-all active:scale-95 lg:flex lg:w-auto"
                onClick={() => setShowPreview(!showPreview)}
              >
                {showPreview ? (
                  <EyeOff className="mr-2 h-4 w-4" />
                ) : (
                  <Eye className="mr-2 h-4 w-4" />
                )}
                {showPreview ? "Ocultar Preview" : "Mostrar Preview"}
              </Button>
              {selectedForm.fields.length > 0 && (
                <Button
                  variant="outline"
                  className="h-11 w-full cursor-pointer rounded-md border-border text-sm transition-all active:scale-95 sm:w-auto"
                  onClick={handleMakeAllFieldsRequired}
                >
                  <CheckSquare className="mr-2 h-4 w-4 text-primary" />
                  Tornar Todos Obrigatórios
                </Button>
              )}
              <Button
                variant="outline"
                className="h-11 w-full cursor-pointer rounded-md border-border text-sm transition-all active:scale-95 sm:w-auto"
                onClick={(e) => handleExportJSON(selectedForm, e)}
              >
                <Copy className="mr-2 h-4 w-4" />
                Copiar JSON
              </Button>
              <Button
                onClick={handleSaveForm}
                className="h-11 w-full cursor-pointer rounded-md bg-primary px-6 font-bold text-primary-foreground shadow-md transition-all hover:bg-primary/90 active:scale-95 sm:w-auto"
              >
                <Save className="mr-2 h-4 w-4" />
                Salvar Formulário
              </Button>
            </div>
          </div>

          {/* Builder Workspace Layout */}
          <div className="grid grid-cols-1 items-start gap-8 lg:grid-cols-12">
            {/* Mobile Tab Control */}
            <div className="col-span-1 flex overflow-hidden rounded-xl border border-border bg-card/30 p-1 lg:hidden">
              <button
                onClick={() => setBuilderTab("edit")}
                className={`flex-1 rounded-lg py-3 text-[10px] font-bold tracking-normal uppercase transition-all sm:text-xs sm:tracking-widest ${builderTab === "edit" ? "bg-primary text-primary-foreground shadow-sm" : "text-muted-foreground"}`}
              >
                Editar Campos
              </button>
              <button
                onClick={() => setBuilderTab("preview")}
                className={`flex-1 rounded-lg py-3 text-[10px] font-bold tracking-normal uppercase transition-all sm:text-xs sm:tracking-widest ${builderTab === "preview" ? "bg-primary text-primary-foreground shadow-sm" : "text-muted-foreground"}`}
              >
                Testar Preview
              </button>
              <button
                onClick={() => setBuilderTab("json")}
                className={`flex-1 rounded-lg py-3 text-[10px] font-bold tracking-normal uppercase transition-all sm:text-xs sm:tracking-widest ${builderTab === "json" ? "bg-primary text-primary-foreground shadow-sm" : "text-muted-foreground"}`}
              >
                Esquema JSON
              </button>
            </div>

            {/* COLUMN 1: FIELD EDITOR PANEL (Show on desktop or when active tab is 'edit') */}
            <div
              className={`col-span-1 ${showPreview ? "lg:col-span-7" : "lg:col-span-12"} space-y-6 ${builderTab === "edit" ? "block" : "hidden lg:block"}`}
            >
              {/* Header Text Block */}
              <div className="rounded-xl border border-border/40 bg-card/20 p-5 dark:bg-zinc-900/10">
                <h3 className="text-lg font-bold text-foreground">
                  Desenho do Formulário
                </h3>
                <p className="mt-1 text-xs leading-relaxed text-muted-foreground">
                  Monte as perguntas do seu formulário no estilo Notion. Clique
                  em qualquer pergunta para editá-la em tempo real e insira
                  novos campos clicando nos botões flutuantes{" "}
                  <code className="rounded bg-muted px-1 py-0.5 text-[10px]">
                    +
                  </code>
                  .
                </p>
              </div>

              {/* Fields List (Canvas) */}
              <div className="space-y-4">
                <h3 className="flex items-center justify-between px-1 text-sm font-bold tracking-wider text-muted-foreground uppercase">
                  <span>Estrutura do Formulário</span>
                  <span className="text-xs font-normal text-muted-foreground normal-case">
                    {selectedForm.fields.length}{" "}
                    {selectedForm.fields.length === 1
                      ? "campo adicionado"
                      : "campos adicionados"}
                  </span>
                </h3>

                {selectedForm.fields.length === 0 ? (
                  <div className="flex flex-col items-center justify-center gap-3 rounded-xl border-2 border-dashed border-border bg-card/10 p-12 text-center text-sm text-muted-foreground">
                    <span>
                      Nenhum campo adicionado. Comece clicando abaixo para
                      inserir seu primeiro campo.
                    </span>
                    <FloatingAddBlockButton
                      onAdd={(type) => handleAddField(type, 0)}
                    />
                  </div>
                ) : (
                  <DndContext
                    sensors={sensors}
                    collisionDetection={closestCenter}
                    onDragEnd={handleDragEnd}
                  >
                    <SortableContext
                      items={selectedForm.fields.map((f) => f.id)}
                      strategy={verticalListSortingStrategy}
                    >
                      <div className="space-y-2">
                        {/* Initial FAB before the first element */}
                        <FloatingAddBlockButton
                          onAdd={(type) => handleAddField(type, 0)}
                        />

                        {selectedForm.fields.map((field, idx) => {
                          const isChoiceType = [
                            "select",
                            "checkbox",
                            "radio",
                          ].includes(field.type)
                          return (
                            <div key={field.id} className="space-y-2">
                              <SortableFieldCard
                                field={field}
                                idx={idx}
                                isEditing={editingFieldId === field.id}
                                onStartEdit={() => setEditingFieldId(field.id)}
                                onRemove={() => handleRemoveField(field.id)}
                                onDuplicate={() =>
                                  handleDuplicateField(field.id)
                                }
                                onUpdate={(updates) =>
                                  handleUpdateField(field.id, updates)
                                }
                                isChoiceType={isChoiceType}
                                onRemoveOption={(optIdx) =>
                                  handleRemoveOption(field.id, optIdx)
                                }
                                onAddOption={(text) =>
                                  handleAddOption(field.id, text)
                                }
                                newOptionText={newOptionTexts[field.id] || ""}
                                onNewOptionTextChange={(text) =>
                                  setNewOptionTexts((prev) => ({
                                    ...prev,
                                    [field.id]: text,
                                  }))
                                }
                                fieldsList={selectedForm.fields}
                                selectedForm={selectedForm}
                                isFormConnectedToEvent={isFormConnectedToEvent}
                              />

                              {/* FAB after this field */}
                              <FloatingAddBlockButton
                                onAdd={(type) => handleAddField(type, idx + 1)}
                              />
                            </div>
                          )
                        })}
                      </div>
                    </SortableContext>
                  </DndContext>
                )}
              </div>
            </div>
            {/* COLUMN 2: INTERACTIVE LIVE PREVIEW PANEL (Show on desktop or when active tab is 'preview') */}
            <div
              className={`col-span-1 space-y-6 lg:col-span-5 ${builderTab === "preview" ? "block" : "hidden lg:block"} ${showPreview ? "" : "lg:hidden"}`}
            >
              <Card className="sticky top-24 overflow-hidden rounded-xl border-border bg-card/40 shadow-lg backdrop-blur-xl">
                <CardHeader className="flex flex-row items-center justify-between border-b border-border/40 p-6">
                  <div>
                    <CardTitle className="flex items-center gap-2 text-lg font-bold text-foreground">
                      <Eye className="h-5 w-5 shrink-0 text-primary" />
                      Visualização ao Vivo
                    </CardTitle>
                    <CardDescription className="text-xs text-muted-foreground">
                      Teste o comportamento do formulário e validações em tempo
                      real.
                    </CardDescription>
                  </div>

                  <span className="inline-flex shrink-0 items-center rounded-full border border-primary/20 bg-primary/10 px-2 py-0.5 text-[9px] font-bold text-primary uppercase">
                    Preview
                  </span>
                </CardHeader>

                <CardContent className="p-6">
                  <form
                    onSubmit={(e) => handlePreviewSubmit(e, selectedForm)}
                    className="space-y-6"
                  >
                    <div>
                      <h2 className="text-xl font-bold tracking-tight text-foreground">
                        {selectedForm.name}
                      </h2>
                      {selectedForm.description && (
                        <p className="mt-1 text-xs leading-relaxed text-muted-foreground">
                          {selectedForm.description}
                        </p>
                      )}
                      <hr className="my-4 border-border/50" />
                    </div>

                    {selectedForm.fields.length === 0 ? (
                      <div className="py-12 text-center text-sm text-muted-foreground italic">
                        Adicione campos no editor à esquerda para visualizá-los
                        aqui.
                      </div>
                    ) : (
                      <div className="grid grid-cols-1 gap-x-6 gap-y-8 md:grid-cols-2">
                        {(() => {
                          const visibleFields = selectedForm.fields.filter(
                            (field) =>
                              isFieldVisible(
                                field,
                                previewFormData,
                                selectedForm.fields
                              )
                          )

                          return visibleFields.map((field, idx) => {
                            const hasError = !!previewFormErrors[field.id]
                            const errorMsg = previewFormErrors[field.id]

                            return (
                              <div
                                key={field.id}
                                className={`${field.halfWidth ? "col-span-1" : "col-span-1 md:col-span-2"} space-y-3`}
                              >
                                <label className="flex items-start gap-3 text-sm font-semibold text-foreground md:text-base">
                                  <span className="mt-0.5 flex h-6 w-6 flex-shrink-0 items-center justify-center rounded-full border border-primary/10 bg-primary/5 text-[10px] font-bold text-primary">
                                    {idx + 1}
                                  </span>
                                  <div className="flex-1 pt-0.5">
                                    <span>
                                      {field.label || "Campo sem nome"}
                                    </span>
                                    {field.required && (
                                      <span
                                        className="ml-1 text-xs font-bold text-destructive"
                                        title="Obrigatório"
                                      >
                                        *
                                      </span>
                                    )}
                                  </div>
                                </label>

                                {/* TEXT INPUT */}
                                {field.type === "text" && (
                                  <Input
                                    value={previewFormData[field.id] || ""}
                                    onChange={(e) =>
                                      handlePreviewInputChange(
                                        field.id,
                                        e.target.value
                                      )
                                    }
                                    placeholder={field.placeholder}
                                    className={`h-12 rounded-md bg-muted/30 px-4 text-base focus-visible:ring-primary/20 ${hasError ? "border-destructive focus-visible:ring-destructive/20" : "border-border/60"}`}
                                  />
                                )}

                                {/* TEXTAREA INPUT */}
                                {field.type === "textarea" && (
                                  <Textarea
                                    value={previewFormData[field.id] || ""}
                                    onChange={(e) =>
                                      handlePreviewInputChange(
                                        field.id,
                                        e.target.value
                                      )
                                    }
                                    placeholder={field.placeholder}
                                    className={`min-h-[120px] rounded-md bg-muted/30 px-4 py-3 text-base focus-visible:ring-primary/20 ${hasError ? "border-destructive focus-visible:ring-destructive/20" : "border-border/60"}`}
                                  />
                                )}

                                {/* NUMBER INPUT */}
                                {field.type === "number" && (
                                  <Input
                                    type="number"
                                    value={previewFormData[field.id] || ""}
                                    onChange={(e) =>
                                      handlePreviewInputChange(
                                        field.id,
                                        e.target.value
                                      )
                                    }
                                    placeholder={field.placeholder}
                                    className={`h-12 rounded-md bg-muted/30 px-4 text-base focus-visible:ring-primary/20 ${hasError ? "border-destructive focus-visible:ring-destructive/20" : "border-border/60"}`}
                                  />
                                )}

                                {/* SELECT INPUT */}
                                {field.type === "select" && (
                                  <Select
                                    value={previewFormData[field.id] || ""}
                                    onValueChange={(val) =>
                                      handlePreviewInputChange(field.id, val)
                                    }
                                  >
                                    <SelectTrigger
                                      className={`h-12 w-full bg-muted/30 px-4 text-base focus:ring-primary/20 ${
                                        hasError
                                          ? "border-destructive focus:ring-destructive/20"
                                          : "border-border/60"
                                      }`}
                                    >
                                      <SelectValue
                                        placeholder={
                                          field.placeholder ||
                                          "Selecione uma opção..."
                                        }
                                      />
                                    </SelectTrigger>
                                    <SelectContent>
                                      {field.options.map((opt, oIdx) => (
                                        <SelectItem key={oIdx} value={opt}>
                                          {opt}
                                        </SelectItem>
                                      ))}
                                    </SelectContent>
                                  </Select>
                                )}

                                {/* CHECKBOX (MULTI SELECTION) */}
                                {field.type === "checkbox" && (
                                  <div className="space-y-3 pt-1">
                                    {field.options.map((opt, oIdx) => {
                                      const isChecked = (
                                        previewFormData[field.id] || []
                                      ).includes(opt)
                                      return (
                                        <label
                                          key={oIdx}
                                          className="flex min-h-[46px] cursor-pointer items-center gap-3 rounded-lg border border-border/40 p-3 transition-all select-none hover:bg-muted/30"
                                        >
                                          <input
                                            type="checkbox"
                                            id={`opt-${field.id}-${oIdx}`}
                                            checked={isChecked}
                                            onChange={(e) =>
                                              handlePreviewCheckboxChange(
                                                field.id,
                                                opt,
                                                e.target.checked
                                              )
                                            }
                                            className="h-5 w-5 shrink-0 cursor-pointer rounded border-zinc-300 text-primary focus:ring-primary/20 dark:border-zinc-700"
                                          />
                                          <span className="text-base font-medium text-foreground">
                                            {opt}
                                          </span>
                                        </label>
                                      )
                                    })}
                                  </div>
                                )}

                                {/* RADIO (SINGLE SELECTION) */}
                                {field.type === "radio" && (
                                  <div className="space-y-3 pt-1">
                                    {field.options.map((opt, oIdx) => {
                                      const isSelected =
                                        previewFormData[field.id] === opt
                                      return (
                                        <label
                                          key={oIdx}
                                          className="flex min-h-[46px] cursor-pointer items-center gap-3 rounded-lg border border-border/40 p-3 transition-all select-none hover:bg-muted/30"
                                        >
                                          <input
                                            type="radio"
                                            name={`radio-group-${field.id}`}
                                            id={`opt-${field.id}-${oIdx}`}
                                            checked={isSelected}
                                            onChange={() =>
                                              handlePreviewInputChange(
                                                field.id,
                                                opt
                                              )
                                            }
                                            className="h-5 w-5 shrink-0 cursor-pointer border-zinc-300 text-primary focus:ring-primary/20 dark:border-zinc-700"
                                          />
                                          <span className="text-base font-medium text-foreground">
                                            {opt}
                                          </span>
                                        </label>
                                      )
                                    })}
                                  </div>
                                )}

                                {/* DATE INPUT */}
                                {field.type === "date" && (
                                  <Input
                                    type="date"
                                    value={previewFormData[field.id] || ""}
                                    onChange={(e) =>
                                      handlePreviewInputChange(
                                        field.id,
                                        e.target.value
                                      )
                                    }
                                    className={`h-12 rounded-md bg-muted/30 px-4 text-base focus-visible:ring-primary/20 ${hasError ? "border-destructive focus-visible:ring-destructive/20" : "border-border/60"}`}
                                  />
                                )}

                                {field.helpText && !hasError && (
                                  <p className="pl-9 text-xs leading-normal text-muted-foreground/80">
                                    {field.helpText}
                                  </p>
                                )}

                                {hasError && (
                                  <p className="animate-in pl-9 text-xs font-semibold text-destructive duration-200 fade-in">
                                    {errorMsg}
                                  </p>
                                )}
                              </div>
                            )
                          })
                        })()}
                      </div>
                    )}
                    <div className="pt-4">
                      <Button
                        type="submit"
                        disabled={selectedForm.fields.length === 0}
                        className="h-12 w-full cursor-pointer rounded-md bg-primary font-bold text-primary-foreground shadow-md transition-all hover:bg-primary/90 active:scale-98"
                      >
                        Enviar Resposta (Simulação)
                      </Button>
                    </div>
                  </form>
                </CardContent>
              </Card>
            </div>

            {/* COLUMN 3: RAW JSON SCHEMATIC VIEW (Show on mobile active tab 'json') */}
            <div
              className={`col-span-1 space-y-4 ${builderTab === "json" ? "block" : "hidden"}`}
            >
              <Card className="rounded-xl border-border bg-card/40 p-5 shadow-lg backdrop-blur-xl">
                <div className="mb-4 flex items-center justify-between border-b border-border/50 pb-3">
                  <h3 className="text-sm font-bold text-foreground">
                    Esquema Estrutural JSON
                  </h3>
                  <Button
                    size="sm"
                    variant="outline"
                    onClick={(e) => handleExportJSON(selectedForm, e)}
                    className="h-8 cursor-pointer rounded-md"
                  >
                    Copiar JSON
                  </Button>
                </div>
                <pre className="max-h-[450px] overflow-x-auto rounded-lg border border-border/60 bg-background p-4 font-mono text-[10px] leading-normal text-muted-foreground">
                  {JSON.stringify(selectedForm, null, 2)}
                </pre>
              </Card>
            </div>
          </div>
        </div>
      )}

      {/* VIEW SUBMISSIONS MODAL */}
      {viewingSubmissionsFormId &&
        (() => {
          const formTemplate = forms.find(
            (f) => f.id === viewingSubmissionsFormId
          )
          const formSubs = submissions[viewingSubmissionsFormId] || []
          if (!formTemplate) return null

          return (
            <div className="fixed inset-0 z-50 flex animate-in items-center justify-center bg-black/80 p-4 backdrop-blur-xs duration-200 fade-in">
              <div className="flex max-h-[85vh] w-full max-w-4xl animate-in flex-col overflow-hidden rounded-xl border border-border/80 bg-background shadow-2xl duration-200 zoom-in-95">
                {/* Header */}
                <div className="flex items-center justify-between border-b border-border p-6">
                  <div>
                    <h2 className="text-xl font-bold text-foreground">
                      Respostas Recebidas
                    </h2>
                    <p className="mt-0.5 text-xs text-muted-foreground">
                      Formulário:{" "}
                      <span className="font-semibold text-primary">
                        {formTemplate.name}
                      </span>{" "}
                      • {formSubs.length} submissões
                    </p>
                  </div>

                  <Button
                    size="icon"
                    variant="ghost"
                    onClick={() => setViewingSubmissionsFormId(null)}
                    className="h-10 w-10 cursor-pointer rounded-md hover:bg-accent"
                  >
                    <X className="h-5 w-5 text-muted-foreground" />
                  </Button>
                </div>

                {/* Content area */}
                <div className="max-h-[calc(85vh-160px)] min-h-[250px] flex-1 overflow-y-auto p-6">
                  {formSubs.length === 0 ? (
                    <div className="flex flex-col items-center justify-center py-16 text-center text-muted-foreground italic">
                      Nenhuma resposta enviada ainda. Use o preview para testar
                      o envio de dados.
                    </div>
                  ) : (
                    <div className="overflow-hidden rounded-lg border border-border/50 bg-card/25 shadow-sm">
                      <div className="overflow-x-auto">
                        <table className="w-full border-collapse text-left text-xs">
                          <thead>
                            <tr className="border-b border-border/80 bg-muted/70 font-bold tracking-wider text-muted-foreground uppercase">
                              <th className="p-3.5 font-bold">Data de Envio</th>
                              {formTemplate.fields.map((f) => (
                                <th
                                  key={f.id}
                                  className="max-w-[150px] truncate p-3.5 font-bold whitespace-nowrap"
                                  title={f.label}
                                >
                                  {f.label}
                                </th>
                              ))}
                              <th className="p-3.5 font-bold text-center">Ações</th>
                            </tr>
                          </thead>
                          <tbody className="divide-y divide-border/40 font-medium text-foreground">
                            {formSubs.map((sub) => (
                              <tr
                                key={sub.id}
                                className="transition-colors hover:bg-muted/15"
                              >
                                <td className="p-3.5 text-muted-foreground">
                                  {new Date(sub.submittedAt).toLocaleDateString(
                                    "pt-BR",
                                    {
                                      day: "2-digit",
                                      month: "2-digit",
                                      year: "numeric",
                                      hour: "2-digit",
                                      minute: "2-digit",
                                    }
                                  )}
                                </td>
                                {formTemplate.fields.map((f) => (
                                  <td
                                    key={f.id}
                                    className="max-w-[150px] truncate p-3.5 text-muted-foreground"
                                    title={formatValue(sub.data[f.id])}
                                  >
                                    {formatValue(sub.data[f.id]) || "-"}
                                  </td>
                                ))}
                                <td className="p-2 text-center">
                                  <Button
                                    size="icon"
                                    variant="ghost"
                                    onClick={() =>
                                      handleDeleteSubmission(
                                        sub.id,
                                        formTemplate.id
                                      )
                                    }
                                    className="h-8 w-8 cursor-pointer rounded-md text-destructive hover:bg-destructive/10 hover:text-destructive"
                                  >
                                    <Trash2 className="h-4 w-4" />
                                  </Button>
                                </td>
                              </tr>
                            ))}
                          </tbody>
                        </table>
                      </div>
                    </div>
                  )}
                </div>

                {/* Footer */}
                <div className="flex items-center justify-between border-t border-border bg-muted/20 p-6">
                  <Button
                    variant="destructive"
                    onClick={() => {
                      handleClearSubmissions(formTemplate.id)
                      setViewingSubmissionsFormId(null)
                    }}
                    disabled={formSubs.length === 0}
                    className="h-10 cursor-pointer rounded-md text-xs font-bold"
                  >
                    <Trash2 className="mr-2 h-4 w-4" />
                    Apagar Respostas
                  </Button>

                  <Button
                    onClick={() => setViewingSubmissionsFormId(null)}
                    className="h-10 cursor-pointer rounded-md bg-primary px-5 font-bold text-primary-foreground hover:bg-primary/90"
                  >
                    Fechar
                  </Button>
                </div>
              </div>
            </div>
          )
        })()}
    </div>
  )
}

// ==========================================
// SORTABLE FIELD CARD COMPONENT
// ==========================================
interface SortableFieldCardProps {
  field: FormField
  idx: number
  isEditing: boolean
  onStartEdit: () => void
  onRemove: () => void
  onDuplicate: () => void
  onUpdate: (updates: Partial<FormField>) => void
  isChoiceType: boolean
  onRemoveOption: (optIdx: number) => void
  onAddOption: (text: string) => void
  newOptionText: string
  onNewOptionTextChange: (text: string) => void
  fieldsList: FormField[]
  selectedForm: FormTemplate
  isFormConnectedToEvent: boolean
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
  onStartEdit,
  isFormConnectedToEvent,
}: SortableFieldCardProps) {
  const {
    attributes,
    listeners,
    setNodeRef,
    transform,
    transition,
    isDragging,
  } = useSortable({ id: field.id })

  const style = {
    transform: CSS.Transform.toString(transform),
    transition,
  }

  const depth = getFieldDepth(field, fieldsList)

  return (
    <div
      ref={setNodeRef}
      style={style}
      className={`flex items-stretch select-none ${isDragging ? "opacity-40" : ""}`}
    >
      {/* Connector lines per depth level */}
      {Array.from({ length: depth }).map((_, i) => (
        <div
          key={i}
          className="pointer-events-none ml-1 w-5 shrink-0 self-stretch border-l-2 border-primary/25 dark:border-primary/15"
        />
      ))}

      <div className="min-w-0 flex-1">
        {isEditing ? (
          <div
            id={`editor-card-${field.id}`}
            className="relative space-y-4 rounded-xl border border-primary/30 bg-card p-5 pl-9 shadow-md ring-1 ring-primary/10 lg:pl-5"
          >
            {/* Drag Handle in Edit Mode */}
            <div
              {...attributes}
              {...listeners}
              className="absolute top-6 left-3 cursor-grab p-1 text-primary/40 transition-colors hover:text-primary active:cursor-grabbing lg:-left-7"
              title="Arrastar para reordenar"
            >
              <GripVertical className="h-4 w-4" />
            </div>

            {/* In-place Editable Text Fields */}
            <div className="space-y-1">
              <div className="flex items-center gap-2">
                <span className="flex h-6 w-6 flex-shrink-0 items-center justify-center rounded-full bg-primary/10 text-[10px] font-bold text-primary">
                  {idx + 1}
                </span>
                <Input
                  value={field.label}
                  onChange={(e) => onUpdate({ label: e.target.value })}
                  placeholder="Título da Pergunta"
                  className="h-10 w-full rounded-md border border-border/80 bg-background px-3 text-sm font-semibold text-foreground placeholder:text-muted-foreground/45 focus-visible:border-primary/50 focus-visible:ring-2 focus-visible:ring-primary/10"
                  autoFocus
                />
              </div>

              {/* Placeholder Editor (if applicable) */}
              {["text", "textarea", "number", "select", "date"].includes(
                field.type
              ) && (
                <div className="pl-8">
                  <Input
                    value={field.placeholder}
                    onChange={(e) => onUpdate({ placeholder: e.target.value })}
                    placeholder="Placeholder (Dica dentro do campo...)"
                    className="h-9 w-full rounded-md border border-border/60 bg-background/50 px-3 text-xs placeholder:text-muted-foreground/40 focus-visible:border-primary/50 focus-visible:ring-2 focus-visible:ring-primary/10"
                  />
                </div>
              )}

              {/* Help Text Editor */}
              <div className="pl-8">
                <Input
                  value={field.helpText}
                  onChange={(e) => onUpdate({ helpText: e.target.value })}
                  placeholder="Texto de ajuda (Subtexto explicativo...)"
                  className="h-9 w-full rounded-md border border-border/60 bg-background/50 px-3 text-[11px] placeholder:text-muted-foreground/40 focus-visible:border-primary/50 focus-visible:ring-2 focus-visible:ring-primary/10"
                />
              </div>
            </div>

            {/* Options list for choice types */}
            {isChoiceType && (
              <div className="space-y-2 border-t border-border/30 pt-2 pl-8">
                <label className="text-[10px] font-bold tracking-wider text-muted-foreground uppercase">
                  Opções de Resposta
                </label>
                <div className="max-w-md space-y-1">
                  {field.options.map((opt, optIdx) => (
                    <div
                      key={optIdx}
                      className="group/opt flex items-center gap-2"
                    >
                      {field.type === "radio" && (
                        <Radio className="h-3.5 w-3.5 shrink-0 text-muted-foreground/50" />
                      )}
                      {field.type === "checkbox" && (
                        <CheckSquare className="h-3.5 w-3.5 shrink-0 text-muted-foreground/50" />
                      )}
                      {field.type === "select" && (
                        <span className="w-3 shrink-0 font-mono text-xs text-muted-foreground/40">
                          {optIdx + 1}.
                        </span>
                      )}
                      <div className="flex-1 flex gap-2">
                        <Input
                          value={opt}
                          onChange={(e) => {
                            const oldOpt = opt
                            const newOpt = e.target.value
                            const updatedOptions = [...field.options]
                            updatedOptions[optIdx] = newOpt
                            
                            const updatedModifiers = { ...(field.priceModifiers || {}) }
                            if (updatedModifiers[oldOpt] !== undefined) {
                              updatedModifiers[newOpt] = updatedModifiers[oldOpt]
                              delete updatedModifiers[oldOpt]
                            }
                            onUpdate({ options: updatedOptions, priceModifiers: updatedModifiers })
                          }}
                          className="h-9 flex-1 rounded-md border border-border/60 bg-background px-3 text-xs focus-visible:border-primary/50 focus-visible:ring-2 focus-visible:ring-primary/10"
                        />
                        {isFormConnectedToEvent && (
                          <div className="flex items-center gap-1 shrink-0">
                            <span className="text-[10px] text-muted-foreground font-semibold">R$</span>
                            <Input
                              type="number"
                              placeholder="+0"
                              value={field.priceModifiers?.[opt] ?? ""}
                              onChange={(e) => {
                                const val = e.target.value === "" ? undefined : Number(e.target.value)
                                const updatedModifiers = { ...(field.priceModifiers || {}) }
                                if (val === undefined || isNaN(val)) {
                                  delete updatedModifiers[opt]
                                } else {
                                  updatedModifiers[opt] = val
                                }
                                onUpdate({ priceModifiers: updatedModifiers })
                              }}
                              className="h-9 w-20 rounded-md border border-border/60 bg-background px-2 text-xs focus-visible:border-primary/50 focus-visible:ring-2 focus-visible:ring-primary/10 text-right"
                            />
                          </div>
                        )}
                      </div>
                      <Button
                        size="icon"
                        variant="ghost"
                        onClick={() => onRemoveOption(optIdx)}
                        disabled={field.options.length <= 1}
                        className="h-8 w-8 shrink-0 cursor-pointer rounded-md opacity-0 transition-opacity group-hover/opt:opacity-100 hover:bg-destructive/10 hover:text-destructive"
                      >
                        <X className="h-3.5 w-3.5" />
                      </Button>
                    </div>
                  ))}

                  <div className="flex items-center gap-2 pt-1 pl-5">
                    <Plus className="h-3.5 w-3.5 shrink-0 text-muted-foreground/40" />
                    <Input
                      placeholder="Adicionar opção..."
                      value={newOptionText}
                      onChange={(e) => onNewOptionTextChange(e.target.value)}
                      onKeyDown={(e) => {
                        if (e.key === "Enter") {
                          e.preventDefault()
                          if (newOptionText.trim()) {
                            onAddOption(newOptionText.trim())
                          }
                        }
                      }}
                      className="h-9 w-full rounded-md border border-dashed border-border/60 bg-background/20 px-3 text-xs text-muted-foreground/80 placeholder:text-muted-foreground/40 focus-visible:border-primary/50 focus-visible:ring-2 focus-visible:ring-primary/10"
                    />
                  </div>
                </div>
              </div>
            )}

            {/* Contextual Settings Toolbar */}
            <div className="flex flex-wrap items-center justify-between gap-4 border-t border-border/40 pt-3 text-xs text-muted-foreground">
              <div className="flex flex-wrap items-center gap-3">
                {/* Field Type Select */}
                <Select
                  value={field.type}
                  onValueChange={(val) => {
                    const newType = val as FormField["type"]
                    const needsOptions = [
                      "select",
                      "checkbox",
                      "radio",
                    ].includes(newType)
                    const currentOptions =
                      field.options.length > 0
                        ? field.options
                        : ["Opção 1", "Opção 2"]
                    onUpdate({
                      type: newType,
                      options: needsOptions ? currentOptions : [],
                    })
                  }}
                >
                  <SelectTrigger className="h-8 w-28 bg-transparent text-xs font-semibold border-border/70 text-foreground">
                    <SelectValue placeholder="Tipo" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="text">Texto</SelectItem>
                    <SelectItem value="textarea">Texto Longo</SelectItem>
                    <SelectItem value="number">Número</SelectItem>
                    <SelectItem value="select">Dropdown</SelectItem>
                    <SelectItem value="checkbox">Multi-Escolha</SelectItem>
                    <SelectItem value="radio">Escolha Única</SelectItem>
                    <SelectItem value="date">Data</SelectItem>
                  </SelectContent>
                </Select>

                {/* Required Toggle */}
                <label className="flex cursor-pointer items-center gap-2 font-medium">
                  <input
                    type="checkbox"
                    checked={field.required}
                    onChange={(e) => onUpdate({ required: e.target.checked })}
                    className="h-4 w-4 cursor-pointer rounded border-border text-primary focus:ring-primary/20"
                  />
                  <span>Obrigatório</span>
                </label>

                {/* Half Width Toggle */}
                <label className="ml-4 flex cursor-pointer items-center gap-2 font-medium">
                  <input
                    type="checkbox"
                    checked={!!field.halfWidth}
                    onChange={(e) => onUpdate({ halfWidth: e.target.checked })}
                    className="h-4 w-4 cursor-pointer rounded border-border text-primary focus:ring-primary/20"
                  />
                  <span>Lado a Lado (50%)</span>
                </label>
              </div>

              <div className="flex items-center gap-2">
                {/* Logic Rules Popover */}
                <Popover>
                  <PopoverTrigger asChild>
                    <Button
                      variant="outline"
                      size="sm"
                      className="h-8 cursor-pointer gap-1.5 text-xs font-medium"
                    >
                      <Layers className="h-3.5 w-3.5 text-muted-foreground" />
                      Lógica & Regras
                    </Button>
                  </PopoverTrigger>
                  <PopoverContent className="w-80 border border-zinc-200 bg-white p-4 shadow-md dark:border-zinc-800 dark:bg-zinc-950">
                    <div className="space-y-4">
                      <h4 className="text-sm font-bold text-foreground">
                        Regras do Campo
                      </h4>

                      {/* Conditional Display Logic */}
                      {idx > 0 && (
                        <div className="space-y-2">
                          <label className="block text-[10px] font-bold tracking-wider text-muted-foreground uppercase">
                            Lógica Condicional (Exibição)
                          </label>
                          <div className="space-y-2">
                            <div>
                              <label className="mb-1 block text-[10px] text-muted-foreground">
                                Depende da pergunta:
                              </label>
                              <Select
                                value={field.dependsOnFieldId || "none"}
                                onValueChange={(val) =>
                                  onUpdate({
                                    dependsOnFieldId:
                                      val === "none" ? undefined : val,
                                    dependsOnValue: undefined,
                                  })
                                }
                              >
                                <SelectTrigger className="h-10 w-full text-xs">
                                  <SelectValue placeholder="Selecione uma pergunta" />
                                </SelectTrigger>
                                <SelectContent>
                                  <SelectItem value="none">
                                    -- Sem Dependência (Sempre Exibir) --
                                  </SelectItem>
                                  {fieldsList.slice(0, idx).map((prevField) => (
                                    <SelectItem
                                      key={prevField.id}
                                      value={prevField.id}
                                    >
                                      {prevField.label ||
                                        `Sem título (${prevField.type})`}
                                    </SelectItem>
                                  ))}
                                </SelectContent>
                              </Select>
                            </div>

                            {field.dependsOnFieldId &&
                              (() => {
                                const parentField = fieldsList.find(
                                  (f) => f.id === field.dependsOnFieldId
                                )
                                if (!parentField) return null
                                const isParentChoice = [
                                  "select",
                                  "radio",
                                  "checkbox",
                                ].includes(parentField.type)

                                return (
                                  <div>
                                    <label className="mb-1 block text-[10px] text-muted-foreground">
                                      Quando a resposta for:
                                    </label>
                                    {isParentChoice &&
                                    parentField.options.length > 0 ? (
                                      <Select
                                        value={field.dependsOnValue || "none"}
                                        onValueChange={(val) =>
                                          onUpdate({
                                            dependsOnValue:
                                              val === "none" ? undefined : val,
                                          })
                                        }
                                      >
                                        <SelectTrigger className="h-10 w-full text-xs">
                                          <SelectValue placeholder="Selecione uma opção" />
                                        </SelectTrigger>
                                        <SelectContent>
                                          <SelectItem value="none">
                                            -- Selecione uma opção --
                                          </SelectItem>
                                          {parentField.options.map(
                                            (opt, oIdx) => (
                                              <SelectItem key={oIdx} value={opt}>
                                                {opt}
                                              </SelectItem>
                                            )
                                          )}
                                        </SelectContent>
                                      </Select>
                                    ) : (
                                      <Input
                                        value={field.dependsOnValue || ""}
                                        onChange={(e) =>
                                          onUpdate({
                                            dependsOnValue: e.target.value,
                                          })
                                        }
                                        placeholder="Digite o valor de ativação..."
                                        className="h-10 rounded-md border-border/60 bg-background px-3 text-xs focus-visible:ring-primary/20"
                                      />
                                    )}
                                  </div>
                                )
                              })()}
                          </div>
                        </div>
                      )}

                      {/* Validation Rules */}
                      <div className="space-y-2 border-t border-border/30 pt-2">
                        <label className="block text-[10px] font-bold tracking-wider text-muted-foreground uppercase">
                          Regras de Validação
                        </label>

                        {field.type === "textarea" && (
                          <div className="grid grid-cols-2 gap-2">
                            <div>
                              <label className="block text-[10px] text-muted-foreground">
                                Qtd. Mínima Caracteres:
                              </label>
                              <Input
                                type="number"
                                value={field.minLength ?? ""}
                                onChange={(e) =>
                                  onUpdate({
                                    minLength:
                                      e.target.value !== ""
                                        ? Number(e.target.value)
                                        : undefined,
                                  })
                                }
                                placeholder="Nenhuma"
                                className="h-10 rounded-md border-border/60 bg-background px-3 text-xs focus-visible:ring-primary/20"
                              />
                            </div>
                            <div>
                              <label className="block text-[10px] text-muted-foreground">
                                Qtd. Máxima Caracteres:
                              </label>
                              <Input
                                type="number"
                                value={field.maxLength ?? ""}
                                onChange={(e) =>
                                  onUpdate({
                                    maxLength:
                                      e.target.value !== ""
                                        ? Number(e.target.value)
                                        : undefined,
                                  })
                                }
                                placeholder="Nenhuma"
                                className="h-10 rounded-md border-border/60 bg-background px-3 text-xs focus-visible:ring-primary/20"
                              />
                            </div>
                          </div>
                        )}

                        {field.type === "text" && (
                          <div className="space-y-2">
                            <div className="space-y-1">
                              <label className="block text-[10px] text-muted-foreground">
                                Formato Requerido (Preset):
                              </label>
                              <Select
                                value={field.validationPreset || "none"}
                                onValueChange={(val) =>
                                  onUpdate({
                                    validationPreset:
                                      val === "none"
                                        ? undefined
                                        : (val as FormField["validationPreset"]),
                                    // Clear mapping if changed from cep
                                    cepMapping:
                                      val === "cep"
                                        ? field.cepMapping || {}
                                        : undefined,
                                  })
                                }
                              >
                                <SelectTrigger className="h-10 w-full text-xs">
                                  <SelectValue placeholder="Formato" />
                                </SelectTrigger>
                                <SelectContent>
                                  <SelectItem value="none">
                                    Nenhum (Qualquer texto)
                                  </SelectItem>
                                  <SelectItem value="phone">Telefone (Brasil)</SelectItem>
                                  <SelectItem value="cpf">
                                    CPF (Cadastro de Pessoa Física)
                                  </SelectItem>
                                  <SelectItem value="cep">
                                    CEP (Localidade/Código Postal)
                                  </SelectItem>
                                  <SelectItem value="email">
                                    Endereço de E-mail
                                  </SelectItem>
                                </SelectContent>
                              </Select>
                            </div>

                            {field.validationPreset === "cep" &&
                              (() => {
                                const otherTextFields = fieldsList.filter(
                                  (f) =>
                                    f.id !== field.id &&
                                    ["text", "textarea"].includes(f.type)
                                )
                                return (
                                  <div className="mt-2 space-y-2 border-t border-zinc-200 pt-2 dark:border-zinc-800">
                                    <label className="block text-[10px] font-bold text-foreground">
                                      Mapeamento de Endereço (CEP)
                                    </label>
                                    <p className="text-[10px] leading-normal text-muted-foreground">
                                      Ao digitar um CEP válido, os dados de
                                      endereço serão copiados para os campos
                                      selecionados abaixo:
                                    </p>

                                    <div className="space-y-1">
                                      <label className="block text-[9px] text-muted-foreground">
                                        Rua / Logradouro:
                                      </label>
                                      <Select
                                        value={field.cepMapping?.streetFieldId || "none"}
                                        onValueChange={(val) =>
                                          onUpdate({
                                            cepMapping: {
                                              ...field.cepMapping,
                                              streetFieldId:
                                                val === "none" ? undefined : val,
                                            },
                                          })
                                        }
                                      >
                                        <SelectTrigger className="h-8 w-full text-xs">
                                          <SelectValue placeholder="Selecione um campo" />
                                        </SelectTrigger>
                                        <SelectContent>
                                          <SelectItem value="none">
                                            -- Não Preencher --
                                          </SelectItem>
                                          {otherTextFields.map((f) => (
                                            <SelectItem key={f.id} value={f.id}>
                                              {f.label || `Campo (${f.type})`}
                                            </SelectItem>
                                          ))}
                                        </SelectContent>
                                      </Select>
                                    </div>

                                    <div className="space-y-1">
                                      <label className="block text-[9px] text-muted-foreground">
                                        Bairro:
                                      </label>
                                      <Select
                                        value={field.cepMapping?.neighborhoodFieldId || "none"}
                                        onValueChange={(val) =>
                                          onUpdate({
                                            cepMapping: {
                                              ...field.cepMapping,
                                              neighborhoodFieldId:
                                                val === "none" ? undefined : val,
                                            },
                                          })
                                        }
                                      >
                                        <SelectTrigger className="h-8 w-full text-xs">
                                          <SelectValue placeholder="Selecione um campo" />
                                        </SelectTrigger>
                                        <SelectContent>
                                          <SelectItem value="none">
                                            -- Não Preencher --
                                          </SelectItem>
                                          {otherTextFields.map((f) => (
                                            <SelectItem key={f.id} value={f.id}>
                                              {f.label || `Campo (${f.type})`}
                                            </SelectItem>
                                          ))}
                                        </SelectContent>
                                      </Select>
                                    </div>

                                    <div className="space-y-1">
                                      <label className="block text-[9px] text-muted-foreground">
                                        Cidade:
                                      </label>
                                      <Select
                                        value={field.cepMapping?.cityFieldId || "none"}
                                        onValueChange={(val) =>
                                          onUpdate({
                                            cepMapping: {
                                              ...field.cepMapping,
                                              cityFieldId:
                                                val === "none" ? undefined : val,
                                            },
                                          })
                                        }
                                      >
                                        <SelectTrigger className="h-8 w-full text-xs">
                                          <SelectValue placeholder="Selecione um campo" />
                                        </SelectTrigger>
                                        <SelectContent>
                                          <SelectItem value="none">
                                            -- Não Preencher --
                                          </SelectItem>
                                          {otherTextFields.map((f) => (
                                            <SelectItem key={f.id} value={f.id}>
                                              {f.label || `Campo (${f.type})`}
                                            </SelectItem>
                                          ))}
                                        </SelectContent>
                                      </Select>
                                    </div>

                                    <div className="space-y-1">
                                      <label className="block text-[9px] text-muted-foreground">
                                        Estado / UF:
                                      </label>
                                      <Select
                                        value={field.cepMapping?.stateFieldId || "none"}
                                        onValueChange={(val) =>
                                          onUpdate({
                                            cepMapping: {
                                              ...field.cepMapping,
                                              stateFieldId:
                                                val === "none" ? undefined : val,
                                            },
                                          })
                                        }
                                      >
                                        <SelectTrigger className="h-8 w-full text-xs">
                                          <SelectValue placeholder="Selecione um campo" />
                                        </SelectTrigger>
                                        <SelectContent>
                                          <SelectItem value="none">
                                            -- Não Preencher --
                                          </SelectItem>
                                          {otherTextFields.map((f) => (
                                            <SelectItem key={f.id} value={f.id}>
                                              {f.label || `Campo (${f.type})`}
                                            </SelectItem>
                                          ))}
                                        </SelectContent>
                                      </Select>
                                    </div>
                                  </div>
                                )
                              })()}
                          </div>
                        )}

                        {field.type === "number" && (
                          <div className="grid grid-cols-2 gap-2">
                            <div>
                              <label className="block text-[10px] text-muted-foreground">
                                Mínimo:
                              </label>
                              <Input
                                type="number"
                                value={field.minNumber ?? ""}
                                onChange={(e) =>
                                  onUpdate({
                                    minNumber:
                                      e.target.value !== ""
                                        ? Number(e.target.value)
                                        : undefined,
                                  })
                                }
                                placeholder="Nenhum"
                                className="h-10 rounded-md border-border/60 bg-background px-3 text-xs focus-visible:ring-primary/20"
                              />
                            </div>
                            <div>
                              <label className="block text-[10px] text-muted-foreground">
                                Máximo:
                              </label>
                              <Input
                                type="number"
                                value={field.maxNumber ?? ""}
                                onChange={(e) =>
                                  onUpdate({
                                    maxNumber:
                                      e.target.value !== ""
                                        ? Number(e.target.value)
                                        : undefined,
                                  })
                                }
                                placeholder="Nenhum"
                                className="h-10 rounded-md border-border/60 bg-background px-3 text-xs focus-visible:ring-primary/20"
                              />
                            </div>
                          </div>
                        )}

                        {!["text", "textarea", "number"].includes(
                          field.type
                        ) && (
                          <p className="text-[11px] text-muted-foreground italic">
                            Este tipo de campo não requer validações
                            customizadas.
                          </p>
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
                    e.stopPropagation()
                    onDuplicate()
                  }}
                  className="h-8 cursor-pointer gap-1.5 text-xs font-medium"
                >
                  <Copy className="h-3.5 w-3.5 text-muted-foreground" />
                  Duplicar
                </Button>

                {/* Delete Button */}
                <Button
                  variant="outline"
                  size="sm"
                  onClick={(e) => {
                    e.stopPropagation()
                    onRemove()
                  }}
                  className="h-8 cursor-pointer gap-1.5 border-border/60 text-xs font-medium text-destructive hover:bg-destructive/10 hover:text-destructive"
                >
                  <Trash2 className="h-3.5 w-3.5" />
                  Excluir
                </Button>
              </div>
            </div>
          </div>
        ) : (
          <div
            onClick={onStartEdit}
            className="group relative cursor-pointer space-y-3 rounded-xl border border-transparent p-5 pl-9 transition-all duration-200 hover:border-border/60 hover:bg-muted/10 lg:pl-5"
          >
            {/* Drag Handle in Preview Mode */}
            <div
              {...attributes}
              {...listeners}
              className="absolute top-6 left-3 cursor-grab p-1 text-muted-foreground/35 opacity-0 transition-colors transition-opacity group-hover:opacity-100 hover:text-muted-foreground active:cursor-grabbing lg:-left-7"
              title="Arrastar para reordenar"
              onClick={(e) => e.stopPropagation()} // Prevent triggering edit mode when dragging
            >
              <GripVertical className="h-4 w-4" />
            </div>

            {/* Edit Indicator Icon */}
            <div className="absolute top-4 right-4 text-muted-foreground/60 opacity-0 transition-opacity group-hover:opacity-100">
              <Edit className="h-4 w-4" />
            </div>

            {/* Field Label exactly like responder */}
            <label className="pointer-events-none flex items-start gap-3 text-sm font-semibold text-foreground md:text-base">
              <span className="mt-0.5 flex h-6 w-6 flex-shrink-0 items-center justify-center rounded-full border border-primary/10 bg-primary/5 text-[10px] font-bold text-primary">
                {idx + 1}
              </span>
              <div className="flex-1 pt-0.5">
                <span>{field.label || "Campo sem nome"}</span>
                {field.required && (
                  <span className="ml-1 text-xs font-bold text-destructive">
                    *
                  </span>
                )}
                {field.halfWidth && (
                  <span className="ml-2 inline-flex items-center rounded border border-amber-500/20 bg-amber-500/10 px-1.5 py-0.5 text-[9px] font-bold text-amber-600 uppercase dark:text-amber-400">
                    50%
                  </span>
                )}
              </div>
            </label>

            {/* Field Control exactly like responder */}
            <div className="pointer-events-none space-y-3">
              {/* TEXT INPUT */}
              {field.type === "text" && (
                <Input
                  disabled
                  placeholder={field.placeholder}
                  className="h-12 w-full rounded-md border-border/60 bg-muted/30 px-4 text-base"
                />
              )}

              {/* TEXTAREA INPUT */}
              {field.type === "textarea" && (
                <Textarea
                  disabled
                  placeholder={field.placeholder}
                  className="min-h-[120px] w-full rounded-md border-border/60 bg-muted/30 px-4 py-3 text-base"
                />
              )}

              {/* NUMBER INPUT */}
              {field.type === "number" && (
                <Input
                  type="number"
                  disabled
                  placeholder={field.placeholder}
                  className="h-12 w-full rounded-md border-border/60 bg-muted/30 px-4 text-base"
                />
              )}

              {/* SELECT INPUT */}
              {field.type === "select" && (
                <div className="relative">
                  <div className="flex h-12 w-full items-center justify-between rounded-md border border-border/60 bg-muted/30 px-4 text-base text-muted-foreground">
                    <span>{field.placeholder || "Selecione uma opção..."}</span>
                    <ChevronsUpDown className="h-4 w-4 text-muted-foreground" />
                  </div>
                </div>
              )}

              {/* CHECKBOX */}
              {field.type === "checkbox" && (
                <div className="space-y-3 pt-1">
                  {field.options.map((opt, oIdx) => (
                    <label
                      key={oIdx}
                      className="flex min-h-[46px] items-center gap-3 rounded-lg border border-border/40 bg-muted/10 p-3"
                    >
                      <input
                        type="checkbox"
                        disabled
                        className="h-5 w-5 shrink-0 rounded border-zinc-300 text-primary dark:border-zinc-700"
                      />
                      <span className="text-base font-medium text-muted-foreground">
                        {opt}
                      </span>
                    </label>
                  ))}
                </div>
              )}

              {/* RADIO */}
              {field.type === "radio" && (
                <div className="space-y-3 pt-1">
                  {field.options.map((opt, oIdx) => (
                    <label
                      key={oIdx}
                      className="flex min-h-[46px] items-center gap-3 rounded-lg border border-border/40 bg-muted/10 p-3"
                    >
                      <input
                        type="radio"
                        disabled
                        className="h-5 w-5 shrink-0 border-zinc-300 text-primary dark:border-zinc-700"
                      />
                      <span className="text-base font-medium text-muted-foreground">
                        {opt}
                      </span>
                    </label>
                  ))}
                </div>
              )}

              {/* DATE INPUT */}
              {field.type === "date" && (
                <Input
                  type="date"
                  disabled
                  className="h-12 w-full rounded-md border-border/60 bg-muted/30 px-4 text-base"
                />
              )}

              {field.helpText && (
                <p className="pl-9 text-xs leading-normal text-muted-foreground/80">
                  {field.helpText}
                </p>
              )}
            </div>
          </div>
        )}
      </div>
    </div>
  )
}

// ==========================================
// HELPER FUNCTIONS & COMPLEMENTARY COMPONENTS
// ==========================================

const getFieldDepth = (field: FormField, fieldsList: FormField[]): number => {
  let depth = 0
  let current = field
  const visited = new Set<string>()
  while (current.dependsOnFieldId) {
    if (visited.has(current.id)) break
    visited.add(current.id)
    const parent = fieldsList.find((f) => f.id === current.dependsOnFieldId)
    if (!parent) break
    depth += 1
    current = parent
  }
  return depth
}

interface FloatingAddBlockButtonProps {
  onAdd: (type: FormField["type"]) => void
}

function FloatingAddBlockButton({ onAdd }: FloatingAddBlockButtonProps) {
  return (
    <div className="group/fab relative my-1 flex h-6 items-center justify-center">
      <div className="pointer-events-none absolute inset-x-0 h-[1px] bg-primary/10 transition-colors group-hover/fab:bg-primary/25" />

      <Popover>
        <PopoverTrigger asChild>
          <Button
            size="icon"
            variant="outline"
            className="z-10 h-7 w-7 cursor-pointer rounded-full border-border bg-background opacity-25 shadow-sm transition-all group-hover/fab:opacity-100 hover:scale-110 hover:border-primary hover:text-primary hover:opacity-100 focus:opacity-100"
            title="Inserir campo aqui"
          >
            <Plus className="h-4 w-4" />
          </Button>
        </PopoverTrigger>
        <PopoverContent
          align="center"
          className="w-56 border border-zinc-200 bg-white p-2 shadow-md dark:border-zinc-800 dark:bg-zinc-950"
        >
          <div className="space-y-1">
            <h4 className="px-2 py-1 text-[10px] font-bold tracking-wider text-muted-foreground uppercase">
              Inserir Bloco
            </h4>
            <div className="grid grid-cols-1 gap-0.5">
              <Button
                variant="ghost"
                onClick={() => onAdd("text")}
                className="h-8 w-full cursor-pointer justify-start rounded px-2 text-left text-xs font-medium hover:bg-primary/5 hover:text-primary"
              >
                <Type className="mr-2 h-3.5 w-3.5 shrink-0 text-muted-foreground" />
                Texto Simples
              </Button>
              <Button
                variant="ghost"
                onClick={() => onAdd("textarea")}
                className="h-8 w-full cursor-pointer justify-start rounded px-2 text-left text-xs font-medium hover:bg-primary/5 hover:text-primary"
              >
                <AlignLeft className="mr-2 h-3.5 w-3.5 shrink-0 text-muted-foreground" />
                Texto Longo
              </Button>
              <Button
                variant="ghost"
                onClick={() => onAdd("number")}
                className="h-8 w-full cursor-pointer justify-start rounded px-2 text-left text-xs font-medium hover:bg-primary/5 hover:text-primary"
              >
                <Hash className="mr-2 h-3.5 w-3.5 shrink-0 text-muted-foreground" />
                Número
              </Button>
              <Button
                variant="ghost"
                onClick={() => onAdd("select")}
                className="h-8 w-full cursor-pointer justify-start rounded px-2 text-left text-xs font-medium hover:bg-primary/5 hover:text-primary"
              >
                <ChevronsUpDown className="mr-2 h-3.5 w-3.5 shrink-0 text-muted-foreground" />
                Dropdown
              </Button>
              <Button
                variant="ghost"
                onClick={() => onAdd("checkbox")}
                className="h-8 w-full cursor-pointer justify-start rounded px-2 text-left text-xs font-medium hover:bg-primary/5 hover:text-primary"
              >
                <CheckSquare className="mr-2 h-3.5 w-3.5 shrink-0 text-muted-foreground" />
                Multi-Escolha
              </Button>
              <Button
                variant="ghost"
                onClick={() => onAdd("radio")}
                className="h-8 w-full cursor-pointer justify-start rounded px-2 text-left text-xs font-medium hover:bg-primary/5 hover:text-primary"
              >
                <Radio className="mr-2 h-3.5 w-3.5 shrink-0 text-muted-foreground" />
                Escolha Única
              </Button>
              <Button
                variant="ghost"
                onClick={() => onAdd("date")}
                className="h-8 w-full cursor-pointer justify-start rounded px-2 text-left text-xs font-medium hover:bg-primary/5 hover:text-primary"
              >
                <Calendar className="mr-2 h-3.5 w-3.5 shrink-0 text-muted-foreground" />
                Data
              </Button>
            </div>
          </div>
        </PopoverContent>
      </Popover>
    </div>
  )
}
