import { useState, useEffect } from "react"
import { useParams, Link, Navigate, useNavigate } from "react-router-dom"
import {
  ClipboardList,
  CheckCircle2,
  ArrowLeft,
  AlertCircle,
  AlertTriangle,
  Smartphone,
  CreditCard,
  QrCode,
  Lock,
} from "lucide-react"

import { Input } from "@/components/ui/input"
import { Button } from "@/components/ui/button"
import { Textarea } from "@/components/ui/textarea"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { RadioGroup, RadioGroupItem } from "@/components/ui/radio-group"
import { Checkbox } from "@/components/ui/checkbox"
import { toast } from "sonner"
import supabase from "@/lib/supabase"
import {
  isFieldVisible,
  formatValue,
  isValidCPF,
  isValidPhone,
  fetchAddressFromCep,
  calculateTotalPrice,
} from "@/lib/forms"
import type { FormField, FormTemplate } from "@/lib/forms"
import { Layout } from "@/components/layout/Layout"
import { ThemeToggle } from "@/components/ThemeToggle"
import type { User } from "@supabase/supabase-js"

export default function FormResponder() {
  const navigate = useNavigate()
  const { formId } = useParams<{ formId: string }>()

  const [formTemplate, setFormTemplate] = useState<FormTemplate | null>(null)
  const [loading, setLoading] = useState(true)
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  const [formData, setFormData] = useState<Record<string, any>>({})
  const [formErrors, setFormErrors] = useState<Record<string, string>>({})
  const [submitted, setSubmitted] = useState(false)
  const [canPost, setCanPost] = useState(false)
  const [user, setUser] = useState<User | null>(null)
  const [authLoading, setAuthLoading] = useState(true)
  const [associatedEventTitle, setAssociatedEventTitle] = useState<string | null>(null)
  const [closedReason, setClosedReason] = useState<"draft" | "expired" | "full" | "ended" | "manual" | null>(null)
  const [associatedRetreat, setAssociatedRetreat] = useState<any | null>(null)
  const [profileId, setProfileId] = useState<string | null>(null)

  // Integrated payment states
  const [showCheckout, setShowCheckout] = useState(false)
  const [checkoutPrice, setCheckoutPrice] = useState(0)
  const [paymentType, setPaymentType] = useState<"pix" | "card">("pix")
  const [cardNumber, setCardNumber] = useState("")
  const [cardExpiry, setCardExpiry] = useState("")
  const [cardCvv, setCardCvv] = useState("")
  const [cardName, setCardName] = useState("")
  const [processingPayment, setProcessingPayment] = useState(false)
  const [pendingSubmission, setPendingSubmission] = useState<{
    execute: (paid: boolean, method: string, ref: string) => Promise<void>
  } | null>(null)

  // Initialize auth and listen for changes
  useEffect(() => {
    async function initAuth() {
      try {
        const {
          data: { session },
        } = await supabase.auth.getSession()
        if (session?.user) {
          setUser(session.user)
          const { data: profileData } = await supabase
            .from("profiles")
            .select("id, is_dev, is_presbyter, can_post")
            .eq("user_id", session.user.id)
            .single()

          if (profileData) {
            setProfileId(profileData.id)
            setCanPost(
              !!(
                profileData.is_dev ||
                profileData.is_presbyter ||
                profileData.can_post
              )
            )
          }
        } else {
          setUser(null)
        }
      } catch (err) {
        console.error("Error checking permissions", err)
      } finally {
        setAuthLoading(false)
      }
    }
    initAuth()

    const {
      data: { subscription },
    } = supabase.auth.onAuthStateChange((_event, session) => {
      if (session?.user) {
        setUser(session.user)
      } else {
        setUser(null)
        setCanPost(false)
      }
    })

    return () => {
      subscription.unsubscribe()
    }
  }, [])

  // Load the specific form template from Supabase
  useEffect(() => {
    async function loadTemplate() {
      if (!formId) {
        setLoading(false)
        return
      }

      try {
        setLoading(true)
        const { data: dbForm, error } = await supabase
          .from("forms")
          .select("*")
          .eq("id", formId)
          .single()

        if (error) throw error

        if (dbForm) {
          setFormTemplate({
            id: dbForm.id,
            name: dbForm.name,
            description: dbForm.description || "",
            fields: (dbForm.fields as unknown as FormField[]) || [],
            createdAt: dbForm.created_at,
            isPublic: dbForm.is_public,
            isActive: dbForm.is_active ?? true,
          })

          // Check associated retreat for status, capacity and expiration date
          const { data: associatedRetreats, error: retreatError } = await supabase
            .from("retreats")
            .select("id, title, status, end_date, max_participants, registration_deadline, price")
            .eq("form_id", formId)

          if (retreatError) throw retreatError

          if (associatedRetreats && associatedRetreats.length > 0) {
            const retreat = associatedRetreats[0]
            setAssociatedRetreat(retreat)
            setAssociatedEventTitle(retreat.title)

            if (retreat.status === "rascunho") {
              setClosedReason("draft")
            } else if (retreat.status === "encerrado") {
              setClosedReason("ended")
            } else {
              // Check date expiration
              const today = new Date()
              today.setHours(0, 0, 0, 0)
              if (retreat.registration_deadline) {
                const limitDate = new Date(retreat.registration_deadline)
                limitDate.setHours(23, 59, 59, 999)
                if (today > limitDate) {
                  setClosedReason("expired")
                  return
                }
              } else if (retreat.end_date) {
                const limitDate = new Date(retreat.end_date)
                limitDate.setHours(23, 59, 59, 999)
                if (today > limitDate) {
                  setClosedReason("expired")
                  return
                }
              }

              // Check capacity
              const { count, error: countError } = await supabase
                .from("registrations")
                .select("id", { count: "exact", head: true })
                .eq("retreat_id", retreat.id)

              if (!countError && count !== null && retreat.max_participants) {
                if (count >= retreat.max_participants) {
                  setClosedReason("full")
                  return
                }
              }

              // If event is active, check form's manual switch
              if (!dbForm.is_active) {
                setClosedReason("manual")
              } else {
                setClosedReason(null)
              }
            }
          } else {
            setAssociatedRetreat(null)
            setAssociatedEventTitle(null)
            if (!dbForm.is_active) {
              setClosedReason("manual")
            } else {
              setClosedReason(null)
            }
          }
        } else {
          setFormTemplate(null)
          setAssociatedRetreat(null)
          setAssociatedEventTitle(null)
          setClosedReason(null)
        }
      } catch (e) {
        console.error("Error loading shared form template from Supabase:", e)
        setFormTemplate(null)
        setAssociatedRetreat(null)
        setAssociatedEventTitle(null)
        setClosedReason(null)
      } finally {
        setLoading(false)
      }
    }

    loadTemplate()
  }, [formId])

  // Handle standard input updates
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  const handleInputChange = async (fieldId: string, val: any) => {
    if (!formTemplate) return
    const targetField = formTemplate.fields.find((f) => f.id === fieldId)
    let formattedVal = val
    if (targetField && targetField.type === "text") {
      formattedVal = formatValue(val, targetField.validationPreset)
    }

    setFormData((prev) => ({
      ...prev,
      [fieldId]: formattedVal,
    }))

    // Remove error highlights once answered
    if (formErrors[fieldId]) {
      setFormErrors((prev) => {
        const copy = { ...prev }
        delete copy[fieldId]
        return copy
      })
    }

    // Trigger CEP Lookup
    if (
      targetField &&
      targetField.type === "text" &&
      targetField.validationPreset === "cep"
    ) {
      const cleanCep = formattedVal.replace(/\D/g, "")
      if (cleanCep.length === 8) {
        try {
          const toastId = toast.loading("Buscando CEP...")
          const address = await fetchAddressFromCep(cleanCep)
          toast.dismiss(toastId)

          if (address) {
            if (address.error) {
              toast.error("CEP não encontrado.")
              setFormErrors((prev) => ({
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

            setFormData((prev) => {
              const nextFormData = { ...prev }
              formTemplate.fields.forEach((f) => {
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
          console.error("CEP lookup failed in responder", err)
        }
      }
    }
  }

  // Handle multi-checkbox state changes
  const handleCheckboxChange = (
    fieldId: string,
    option: string,
    isChecked: boolean
  ) => {
    const currentList = formData[fieldId] || []
    let updatedList
    if (isChecked) {
      updatedList = [...currentList, option]
    } else {
      updatedList = currentList.filter((x: string) => x !== option)
    }

    handleInputChange(fieldId, updatedList)
  }

  // Submit response
  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault()
    if (!formTemplate) return
    const template = formTemplate

    // Validate inputs
    const errors: Record<string, string> = {}
    template.fields.forEach((field) => {
      // Only validate if field is visible
      if (!isFieldVisible(field, formData, template.fields)) return

      const val = formData[field.id]

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
              } else if (formErrors[field.id] === "CEP não encontrado.") {
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
      setFormErrors(errors)
      toast.error("Por favor, corrija os erros de validação antes de enviar.")
      return
    }

    // Filter values for invisible fields to avoid sending trash data
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const filteredData: Record<string, any> = {}
    template.fields.forEach((field) => {
      if (
        isFieldVisible(field, formData, template.fields) &&
        formData[field.id] !== undefined
      ) {
        filteredData[field.id] = formData[field.id]
      }
    })

    // Save submission to Supabase
    async function executeSubmission(paid: boolean, method: string, reference: string) {
      try {
        const submissionId = `sub-${Math.random().toString(36).substring(7)}`
        const submitToastId = toast.loading("Enviando sua resposta...")

        // Extract CPF and Email values from current submission
        let emailVal = ""
        let cpfVal = ""
        template.fields.forEach((field) => {
          const val = formData[field.id]
          if (val) {
            const label = field.label.toLowerCase()
            if (label.includes("email") || label.includes("e-mail")) {
              emailVal = String(val).trim().toLowerCase()
            } else if (label.includes("cpf")) {
              cpfVal = String(val).replace(/\D/g, "")
            }
          }
        })

        // Check for duplicates
        if (emailVal || cpfVal) {
          if (associatedRetreat) {
            // Event registration check
            const { data: existingRegs } = await supabase
              .from("registrations")
              .select(`
                id,
                guest_data,
                custom_responses,
                profiles (
                  email,
                  cpf
                )
              `)
              .eq("retreat_id", associatedRetreat.id)

            if (existingRegs) {
              const isDuplicate = existingRegs.some((reg: any) => {
                // Check profiles email/cpf
                if (reg.profiles) {
                  if (emailVal && reg.profiles.email?.toLowerCase() === emailVal) return true
                  if (cpfVal && reg.profiles.cpf?.replace(/\D/g, "") === cpfVal) return true
                }
                // Check guest_data email/cpf
                if (reg.guest_data) {
                  if (emailVal && reg.guest_data.email?.toLowerCase() === emailVal) return true
                  if (cpfVal && reg.guest_data.cpf?.replace(/\D/g, "") === cpfVal) return true
                }
                // Check custom_responses keys/values
                if (reg.custom_responses) {
                  for (const [key, val] of Object.entries(reg.custom_responses)) {
                    const label = key.toLowerCase()
                    if (label.includes("email") || label.includes("e-mail")) {
                      if (emailVal && typeof val === "string" && val.toLowerCase() === emailVal) return true
                    }
                    if (label.includes("cpf")) {
                      if (cpfVal && typeof val === "string" && val.replace(/\D/g, "") === cpfVal) return true
                    }
                  }
                }
                return false
              })

              if (isDuplicate) {
                toast.dismiss(submitToastId)
                toast.error("Este CPF ou E-mail já possui uma inscrição activa para este evento!")
                return
              }
            }
          } else {
            // General form submission check
            const { data: existingSubmissions } = await supabase
              .from("form_submissions")
              .select("data")
              .eq("form_id", template.id)

            if (existingSubmissions) {
              const isDuplicate = existingSubmissions.some((sub: any) => {
                if (sub.data) {
                  for (const [key, val] of Object.entries(sub.data)) {
                    const field = template.fields.find(f => f.id === key)
                    if (field) {
                      const label = field.label.toLowerCase()
                      if (label.includes("email") || label.includes("e-mail")) {
                        if (emailVal && typeof val === "string" && val.toLowerCase() === emailVal) return true
                      }
                      if (label.includes("cpf")) {
                        if (cpfVal && typeof val === "string" && val.replace(/\D/g, "") === cpfVal) return true
                      }
                    }
                  }
                }
                return false
              })

              if (isDuplicate) {
                toast.dismiss(submitToastId)
                toast.error("Uma resposta com este e-mail ou CPF já foi enviada!")
                return
              }
            }
          }
        }

        const { error } = await supabase.from("form_submissions").insert({
          id: submissionId,
          form_id: template.id,
          data: filteredData,
          user_id: user?.id || null,
        })

        if (error) throw error

        // If this form is associated with a retreat, create a registration as well!
        if (associatedRetreat) {
          // Map custom responses field IDs to their labels for easy display in registrations
          const mappedResponses: Record<string, any> = {}
          template.fields.forEach((field) => {
            if (
              isFieldVisible(field, formData, template.fields) &&
              formData[field.id] !== undefined
            ) {
              mappedResponses[field.label] = formData[field.id]
            }
          })

          // Extract basic participant details from form fields to build guest_data
          const guestData: Record<string, any> = {}
          template.fields.forEach((field) => {
            const val = formData[field.id]
            if (val !== undefined && val !== null) {
              const label = field.label.toLowerCase()
              if (label.includes("nome")) {
                guestData.full_name = val
              } else if (label.includes("email") || label.includes("e-mail")) {
                guestData.email = val
              } else if (label.includes("telefone") || label.includes("celular") || label.includes("fone") || label.includes("whatsapp")) {
                guestData.phone = val
              } else if (label.includes("cpf")) {
                guestData.cpf = val
              }
            }
          })

          const { error: regError } = await supabase.from("registrations").insert({
            retreat_id: associatedRetreat.id,
            profile_id: profileId || null,
            guest_data: guestData,
            custom_responses: mappedResponses,
            payment_method: method,
            payment_reference: reference,
            paid: paid,
            form_submission_id: submissionId,
          })

          if (regError) throw regError
        }

        toast.dismiss(submitToastId)
        setSubmitted(true)
        toast.success("Resposta enviada com sucesso!")
      } catch (e: any) {
        console.error("Error saving form response to Supabase:", e)
        toast.error(
          `Ocorreu um erro ao enviar suas respostas: ${e.message || "Erro desconhecido"}`
        )
      }
    }

    const total = calculateTotalPrice(associatedRetreat?.price || 0, template.fields, filteredData)

    if (total > 0 && associatedRetreat) {
      setPendingSubmission({
        execute: async (p: boolean, m: string, r: string) => {
          await executeSubmission(p, m, r)
        }
      })
      setCheckoutPrice(total)
      setShowCheckout(true)
    } else {
      executeSubmission(true, "gratuito", "Isento")
    }
  }

  const handleConfirmIntegratedPayment = async () => {
    if (!pendingSubmission) return
    setProcessingPayment(true)
    setTimeout(async () => {
      try {
        const method = paymentType === "pix" ? "pix" : "credit_card"
        const ref = `Integrado - ${paymentType.toUpperCase()} - Simulado #${Math.floor(100000 + Math.random() * 900000)}`
        await pendingSubmission.execute(true, method, ref)
        setShowCheckout(false)
        setProcessingPayment(false)
        setPendingSubmission(null)
      } catch (err: any) {
        toast.error("Erro ao processar pagamento: " + err.message)
        setProcessingPayment(false)
      }
    }, 2500)
  }

  const handleReset = () => {
    setFormData({})
    setFormErrors({})
    setSubmitted(false)
  }

  if (loading || authLoading) {
    return (
      <div className="flex min-h-[60vh] flex-col items-center justify-center gap-4">
        <div className="h-12 w-12 animate-spin rounded-full border-4 border-primary border-t-transparent"></div>
        <p className="font-semibold text-muted-foreground">
          Carregando formulário...
        </p>
      </div>
    )
  }

  if (!formTemplate) {
    return (
      <div className="mx-auto max-w-md animate-in space-y-6 px-4 py-20 text-center duration-500 fade-in slide-in-from-bottom-4">
        <div className="mx-auto flex h-20 w-20 items-center justify-center rounded-full bg-destructive/10 text-destructive">
          <AlertCircle className="h-10 w-10" />
        </div>
        <div className="space-y-2">
          <h1 className="text-2xl font-bold tracking-tight text-foreground">
            Formulário não encontrado
          </h1>
          <p className="text-sm leading-relaxed text-muted-foreground">
            O link acessado pode estar desatualizado, incorreto ou o formulário
            correspondente foi removido pela gestão.
          </p>
        </div>
        <Button onClick={() => navigate(-1)} className="mt-4 bg-primary hover:bg-primary/90 cursor-pointer">
          <ArrowLeft className="h-4 w-4 mr-2" />
          Voltar para a página anterior
        </Button>
      </div>
    )
  }

  if (closedReason) {
    let title = "Formulário Indisponível"
    let description = "Este formulário não está aceitando respostas no momento."
    let iconColor = "text-amber-500"
    let iconBg = "bg-amber-500/10"

    if (closedReason === "draft") {
      title = "Formulário em Rascunho"
      description = `Este formulário está vinculado ao evento "${associatedEventTitle}", que atualmente está em modo de rascunho (não publicado). O acesso será liberado assim que o evento for publicado.`
    } else if (closedReason === "ended") {
      title = "Inscrições Encerradas"
      description = `As inscrições para o evento "${associatedEventTitle}" foram encerradas pela administração.`
      iconColor = "text-red-500"
      iconBg = "bg-red-500/10"
    } else if (closedReason === "expired") {
      title = "Prazo de Inscrição Expirado"
      description = `O prazo limite para se inscrever no evento "${associatedEventTitle}" já passou.`
      iconColor = "text-red-500"
      iconBg = "bg-red-500/10"
    } else if (closedReason === "full") {
      title = "Vagas Esgotadas"
      description = `O limite de vagas/participantes para o evento "${associatedEventTitle}" foi atingido.`
      iconColor = "text-red-500"
      iconBg = "bg-red-500/10"
    } else if (closedReason === "manual") {
      title = "Formulário Desativado"
      description = "Este formulário foi desativado temporariamente pela administração e não está aceitando novas respostas."
      iconColor = "text-red-500"
      iconBg = "bg-red-500/10"
    }

    return (
      <div className="mx-auto max-w-md animate-in space-y-6 px-4 py-20 text-center duration-500 fade-in slide-in-from-bottom-4">
        <div className={`mx-auto flex h-20 w-20 items-center justify-center rounded-full ${iconBg} ${iconColor}`}>
          <AlertTriangle className="h-10 w-10" />
        </div>
        <div className="space-y-2">
          <h1 className="text-2xl font-bold tracking-tight text-foreground">
            {title}
          </h1>
          <p className="text-sm leading-relaxed text-muted-foreground">
            {description}
          </p>
        </div>
        <Button onClick={() => navigate(-1)} className="mt-4 bg-primary hover:bg-primary/90 cursor-pointer">
          <ArrowLeft className="h-4 w-4 mr-2" />
          Voltar para a página anterior
        </Button>
      </div>
    )
  }

  const isFormPublic = !!formTemplate.isPublic

  if (!isFormPublic && !user) {
    return (
      <Navigate
        to="/entrar"
        state={{ from: `/formularios/responder/${formId}` }}
        replace
      />
    )
  }

  const formContent = (
    <div className="mx-auto max-w-2xl animate-in px-4 py-8 duration-500 fade-in slide-in-from-bottom-4">
      {/* HEADER NAVIGATION */}
      {user && (
        <div className="mb-8">
          <Button
            asChild
            variant="ghost"
            className="-ml-4 cursor-pointer text-muted-foreground hover:text-foreground"
          >
            <Link
              to={canPost ? "/gestao/formularios" : "/"}
              className="flex items-center gap-2"
            >
              <ArrowLeft className="h-4 w-4" />
              {canPost ? "Voltar para Formulários" : "Voltar para o Início"}
            </Link>
          </Button>
        </div>
      )}

      {/* SUCCESS STATE CARD */}
      {submitted ? (
        <div className="mx-auto max-w-md animate-in space-y-6 rounded-2xl border border-border/60 bg-card/25 p-8 text-center shadow-sm duration-300 zoom-in-95">
          <div className="mx-auto flex h-16 w-16 items-center justify-center rounded-full border border-emerald-500/20 bg-emerald-500/10 text-emerald-600">
            <CheckCircle2 className="h-8 w-8" />
          </div>

          <div className="space-y-2">
            <h2 className="text-2xl font-bold text-foreground">
              Resposta Enviada!
            </h2>
            <p className="mx-auto max-w-xs text-sm leading-relaxed text-muted-foreground">
              Obrigado por preencher o formulário **{formTemplate.name}**. Suas
              respostas foram registradas com sucesso.
            </p>
          </div>

          <div className="flex flex-col gap-3 pt-4">
            <Button
              onClick={handleReset}
              variant="outline"
              className="h-11 w-full cursor-pointer rounded-md text-sm font-semibold"
            >
              Enviar outra resposta
            </Button>
            {user && (
              <Button
                asChild
                className="h-11 w-full cursor-pointer rounded-md bg-primary text-sm font-bold text-primary-foreground hover:bg-primary/90"
              >
                <Link to={canPost ? "/gestao/formularios" : "/"}>Concluir</Link>
              </Button>
            )}
          </div>
        </div>
      ) : (
        /* FORM CONTAINER */
        <div className="space-y-10">
          {/* Header */}
          <div className="space-y-3 border-b border-border/40 pb-6">
            <div className="flex items-center gap-3">
              <div className="flex h-11 w-11 shrink-0 items-center justify-center rounded-xl border border-primary/10 bg-primary/5">
                <ClipboardList className="h-5 w-5 text-primary" />
              </div>
              <div className="space-y-0.5">
                <h1 className="text-2xl font-bold tracking-tight text-foreground">
                  {formTemplate.name}
                </h1>
                <p className="text-[10px] font-bold tracking-wider text-muted-foreground/80 uppercase">
                  Formulário {isFormPublic ? "Público" : "de Vida Comum"}
                </p>
              </div>
            </div>
            {formTemplate.description && (
              <p className="pt-2 text-sm leading-relaxed text-muted-foreground">
                {formTemplate.description}
              </p>
            )}
          </div>

          <form onSubmit={handleSubmit} className="space-y-12">
            {(() => {
              const visibleFields = formTemplate.fields.filter((field) =>
                isFieldVisible(field, formData, formTemplate.fields)
              )

              return (
                <div className="grid grid-cols-1 gap-x-6 gap-y-10 md:grid-cols-2">
                  {visibleFields.map((field, idx) => {
                    const hasError = !!formErrors[field.id]
                    const errorMsg = formErrors[field.id]

                    return (
                      <div
                        key={field.id}
                        className={`${field.halfWidth ? "col-span-1" : "col-span-1 md:col-span-2"} space-y-3`}
                      >
                        <label className="flex items-start gap-3 text-base font-semibold text-foreground md:text-lg">
                          <span className="mt-0.5 flex h-7 w-7 flex-shrink-0 items-center justify-center rounded-full border border-primary/10 bg-primary/5 text-xs font-bold text-primary md:mt-1">
                            {idx + 1}
                          </span>
                          <div className="flex-1 pt-0.5">
                            <span>{field.label || "Campo sem nome"}</span>
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
                            value={formData[field.id] || ""}
                            onChange={(e) =>
                              handleInputChange(field.id, e.target.value)
                            }
                            placeholder={field.placeholder}
                            className={`h-12 rounded-md bg-muted/30 px-4 text-base focus-visible:ring-primary/20 ${hasError ? "border-destructive focus-visible:ring-destructive/20" : "border-border/60"}`}
                          />
                        )}

                        {/* TEXTAREA INPUT */}
                        {field.type === "textarea" && (
                          <Textarea
                            value={formData[field.id] || ""}
                            onChange={(e) =>
                              handleInputChange(field.id, e.target.value)
                            }
                            placeholder={field.placeholder}
                            className={`min-h-[120px] rounded-md bg-muted/30 px-4 py-3 text-base focus-visible:ring-primary/20 ${hasError ? "border-destructive focus-visible:ring-destructive/20" : "border-border/60"}`}
                          />
                        )}

                        {/* NUMBER INPUT */}
                        {field.type === "number" && (
                          <Input
                            type="number"
                            value={formData[field.id] || ""}
                            onChange={(e) =>
                              handleInputChange(field.id, e.target.value)
                            }
                            placeholder={field.placeholder}
                            className={`h-12 rounded-md bg-muted/30 px-4 text-base focus-visible:ring-primary/20 ${hasError ? "border-destructive focus-visible:ring-destructive/20" : "border-border/60"}`}
                          />
                        )}

                        {/* SELECT INPUT */}
                        {field.type === "select" && (
                          <Select
                            value={formData[field.id] || "none"}
                            onValueChange={(val) =>
                              handleInputChange(field.id, val === "none" ? "" : val)
                            }
                          >
                            <SelectTrigger id={field.id} className={`w-full h-12 text-base ${hasError ? "border-destructive focus-visible:ring-destructive/20" : "border-border/60 bg-muted/30"}`}>
                              <SelectValue placeholder={field.placeholder || "Selecione uma opção..."} />
                            </SelectTrigger>
                            <SelectContent>
                              <SelectItem value="none">{field.placeholder || "Selecione uma opção..."}</SelectItem>
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
                              const checkedList = formData[field.id] || []
                              const isChecked = checkedList.includes(opt)
                              return (
                                <label
                                  key={oIdx}
                                  htmlFor={`responder-opt-${field.id}-${oIdx}`}
                                  className="flex min-h-[46px] cursor-pointer items-center gap-3 rounded-lg border border-border/40 p-3 transition-all select-none hover:bg-muted/30"
                                >
                                  <Checkbox
                                    id={`responder-opt-${field.id}-${oIdx}`}
                                    checked={isChecked}
                                    onCheckedChange={(checked) =>
                                      handleCheckboxChange(
                                        field.id,
                                        opt,
                                        !!checked
                                      )
                                    }
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
                          <RadioGroup
                            value={formData[field.id] || ""}
                            onValueChange={(val) =>
                              handleInputChange(field.id, val)
                            }
                            className="space-y-3 pt-1"
                          >
                            {field.options.map((opt, oIdx) => {
                              return (
                                <label
                                  key={oIdx}
                                  htmlFor={`responder-opt-${field.id}-${oIdx}`}
                                  className="flex min-h-[46px] cursor-pointer items-center gap-3 rounded-lg border border-border/40 p-3 transition-all select-none hover:bg-muted/30"
                                >
                                  <RadioGroupItem
                                    value={opt}
                                    id={`responder-opt-${field.id}-${oIdx}`}
                                  />
                                  <span className="text-base font-medium text-foreground">
                                    {opt}
                                  </span>
                                </label>
                              )
                            })}
                          </RadioGroup>
                        )}

                        {/* DATE INPUT */}
                        {field.type === "date" && (
                          <Input
                            type="date"
                            value={formData[field.id] || ""}
                            onChange={(e) =>
                              handleInputChange(field.id, e.target.value)
                            }
                            className={`h-12 rounded-md bg-muted/30 px-4 text-base focus-visible:ring-primary/20 ${hasError ? "border-destructive focus-visible:ring-destructive/20" : "border-border/60"}`}
                          />
                        )}

                        {field.helpText && !hasError && (
                          <p className="pl-10 text-xs leading-normal text-muted-foreground/80">
                            {field.helpText}
                          </p>
                        )}

                        {hasError && (
                          <p className="animate-in pl-10 text-xs font-semibold text-destructive duration-200 fade-in">
                            {errorMsg}
                          </p>
                        )}
                      </div>
                    )
                  })}
                </div>
              )
            })()}

            <div className="border-t border-border/40 pt-6">
              <Button
                type="submit"
                className="h-12 w-full cursor-pointer rounded-md bg-primary font-bold text-primary-foreground shadow-md shadow-primary/10 transition-all hover:bg-primary/90 active:scale-[0.98]"
              >
                Enviar Resposta
              </Button>
            </div>
          </form>
        </div>
      )}

      {showCheckout && (
        <div className="fixed inset-0 z-55 flex items-center justify-center bg-black/85 p-4 backdrop-blur-xs">
          <div className="w-full max-w-md animate-in rounded-xl border border-border/80 bg-background p-6 shadow-2xl duration-200 zoom-in-95 text-left">
            {/* Header */}
            <div className="flex items-center justify-between border-b border-border pb-4">
              <div>
                <h3 className="text-lg font-bold text-foreground">Pagamento Seguro</h3>
                <p className="text-xs text-muted-foreground">Inscrição para {associatedRetreat?.title}</p>
              </div>
              <div className="flex items-center gap-1 text-[10px] font-semibold text-emerald-600 bg-emerald-500/10 px-2 py-1 rounded-full dark:bg-emerald-500/5">
                <Lock className="h-3 w-3" />
                <span>SSL Encrypted</span>
              </div>
            </div>

            {/* Price Summary */}
            <div className="my-4 rounded-lg bg-muted/40 p-4 border border-border/30">
              <div className="flex justify-between items-center">
                <span className="text-xs text-muted-foreground font-medium">Valor Total:</span>
                <span className="text-xl font-extrabold text-foreground">
                  {new Intl.NumberFormat("pt-BR", { style: "currency", currency: "BRL" }).format(checkoutPrice)}
                </span>
              </div>
            </div>

            {/* Payment Method Selector */}
            <div className="space-y-2 mb-4">
              <label className="text-[10px] font-bold tracking-wider text-muted-foreground uppercase">
                Método de Pagamento
              </label>
              <div className="grid grid-cols-2 gap-2">
                <button
                  type="button"
                  onClick={() => setPaymentType("pix")}
                  className={`flex h-11 items-center justify-center gap-2 rounded-lg border text-xs font-semibold cursor-pointer transition-all ${
                    paymentType === "pix"
                      ? "border-primary bg-primary/5 text-primary"
                      : "border-border/60 hover:bg-muted/30 text-muted-foreground"
                  }`}
                >
                  <Smartphone className="h-4 w-4" />
                  PIX (Instantâneo)
                </button>
                <button
                  type="button"
                  onClick={() => setPaymentType("card")}
                  className={`flex h-11 items-center justify-center gap-2 rounded-lg border text-xs font-semibold cursor-pointer transition-all ${
                    paymentType === "card"
                      ? "border-primary bg-primary/5 text-primary"
                      : "border-border/60 hover:bg-muted/30 text-muted-foreground"
                  }`}
                >
                  <CreditCard className="h-4 w-4" />
                  Cartão de Crédito
                </button>
              </div>
            </div>

            {/* Payment Details */}
            {paymentType === "pix" ? (
              <div className="space-y-4 animate-in fade-in duration-200">
                <div className="flex flex-col items-center justify-center p-4 bg-muted/20 border border-dashed border-border/50 rounded-lg">
                  {/* Visual simulated QR code */}
                  <div className="h-36 w-36 bg-zinc-200 dark:bg-zinc-800 rounded-lg flex items-center justify-center border border-border shadow-inner relative overflow-hidden">
                    <QrCode className="h-28 w-28 text-foreground" />
                    {processingPayment && (
                      <div className="absolute inset-0 bg-background/80 flex flex-col items-center justify-center gap-2">
                        <div className="h-6 w-6 animate-spin rounded-full border-2 border-primary border-t-transparent" />
                        <span className="text-[10px] font-semibold text-muted-foreground">Verificando...</span>
                      </div>
                    )}
                  </div>
                  <p className="text-[10px] text-muted-foreground mt-3 text-center">
                    Escaneie o QR Code acima usando seu aplicativo de banco para pagar instantaneamente.
                  </p>
                </div>

                <div className="space-y-1 text-left">
                  <label className="text-[10px] font-bold text-muted-foreground uppercase">Código Copia e Cola</label>
                  <div className="flex gap-2">
                    <Input
                      readOnly
                      value="00020101021226830014br.gov.bcb.pix2561pix.igrejabh.com.br/pg/retiro..."
                      className="h-9 text-[10px] font-mono text-muted-foreground bg-muted/40 cursor-default"
                    />
                    <Button
                      size="sm"
                      variant="outline"
                      onClick={() => {
                        navigator.clipboard.writeText("00020101021226830014br.gov.bcb.pix2561pix.igrejabh.com.br/pg/retiro...");
                        toast.success("Código copiado para a área de transferência!");
                      }}
                      className="h-9 text-xs font-semibold cursor-pointer"
                    >
                      Copiar
                    </Button>
                  </div>
                </div>
              </div>
            ) : (
              <div className="space-y-3 animate-in fade-in duration-200 text-left">
                <div className="space-y-1">
                  <label className="text-[10px] font-bold text-muted-foreground uppercase">Nome no Cartão</label>
                  <Input
                    placeholder="JOÃO SILVA"
                    value={cardName}
                    onChange={(e) => setCardName(e.target.value.toUpperCase())}
                    className="h-9 text-xs"
                    disabled={processingPayment}
                  />
                </div>
                <div className="space-y-1">
                  <label className="text-[10px] font-bold text-muted-foreground uppercase">Número do Cartão</label>
                  <Input
                    placeholder="0000 0000 0000 0000"
                    value={cardNumber}
                    onChange={(e) => setCardNumber(e.target.value.replace(/\D/g, "").slice(0, 16))}
                    className="h-9 text-xs"
                    disabled={processingPayment}
                  />
                </div>
                <div className="grid grid-cols-2 gap-2">
                  <div className="space-y-1">
                    <label className="text-[10px] font-bold text-muted-foreground uppercase">Validade</label>
                    <Input
                      placeholder="MM/AA"
                      value={cardExpiry}
                      onChange={(e) => setCardExpiry(e.target.value.replace(/\D/g, "").slice(0, 4))}
                      className="h-9 text-xs"
                      disabled={processingPayment}
                    />
                  </div>
                  <div className="space-y-1">
                    <label className="text-[10px] font-bold text-muted-foreground uppercase">CVV</label>
                    <Input
                      placeholder="000"
                      value={cardCvv}
                      onChange={(e) => setCardCvv(e.target.value.replace(/\D/g, "").slice(0, 3))}
                      className="h-9 text-xs"
                      disabled={processingPayment}
                    />
                  </div>
                </div>
              </div>
            )}

            {/* Actions */}
            <div className="flex gap-2 mt-6 pt-4 border-t border-border">
              <Button
                variant="outline"
                onClick={() => {
                  if (!processingPayment) setShowCheckout(false)
                }}
                disabled={processingPayment}
                className="flex-1 h-10 rounded-md text-xs font-semibold cursor-pointer"
              >
                Cancelar
              </Button>
              <Button
                onClick={handleConfirmIntegratedPayment}
                disabled={processingPayment || (paymentType === "card" && (!cardName || !cardNumber || !cardExpiry || !cardCvv))}
                className="flex-1 h-10 rounded-md bg-primary text-xs font-bold text-primary-foreground hover:bg-primary/90 cursor-pointer flex items-center justify-center gap-1.5"
              >
                {processingPayment ? (
                  <>
                    <div className="h-4 w-4 animate-spin rounded-full border-2 border-primary-foreground border-t-transparent" />
                    Processando...
                  </>
                ) : (
                  <>
                    <span>Confirmar Pagamento</span>
                  </>
                )}
              </Button>
            </div>
          </div>
        </div>
      )}
    </div>
  )

  if (user) {
    return <Layout>{formContent}</Layout>
  }

  return (
    <div className="min-h-screen bg-zinc-50 transition-colors duration-300 dark:bg-zinc-950">
      <header className="sticky top-0 z-50 border-b border-border/40 bg-card/50 backdrop-blur-md">
        <div className="mx-auto flex h-16 max-w-2xl items-center justify-between px-4">
          <div className="flex items-center gap-2 select-none">
            <span className="font-bold tracking-tight text-foreground">
              O Corpo
            </span>
            <span className="rounded-full bg-zinc-200 px-2 py-0.5 text-[10px] font-bold text-zinc-700 uppercase dark:bg-zinc-800 dark:text-zinc-300">
              BH
            </span>
          </div>
          <ThemeToggle />
        </div>
      </header>
      <main className="py-4">{formContent}</main>
    </div>
  )
}
