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
  Ticket,
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
import type { FormField, FormTemplate, FormPresentationPage } from "@/lib/forms"
import { FormPresentationView } from "@/components/forms/FormPresentationView"
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

  // Presentation page & coupon states
  const [showPresentation, setShowPresentation] = useState(false)
  const [couponCode, setCouponCode] = useState<string | null>(() => {
    const params = new URLSearchParams(window.location.search)
    const code = params.get("cupom") || params.get("coupon")
    return code ? code.trim().toUpperCase() : null
  })
  const [couponCpf, setCouponCpf] = useState("")
  const [couponCpfError, setCouponCpfError] = useState<string | null>(null)
  const [couponValidation, setCouponValidation] = useState<{
    checked: boolean
    valid: boolean
    requiresCpf?: boolean
    message?: string
  }>({ checked: false, valid: false })

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
        const rawFormId = decodeURIComponent(formId).trim()
        const hyphenatedId = rawFormId.replace(/\s+/g, "-")

        // 1. Try exact match by id
        let { data: dbForm, error: formError } = await supabase
          .from("forms")
          .select("*")
          .eq("id", rawFormId)
          .maybeSingle()

        // 2. If not found, try hyphenated format (e.g. "form solteiros 2026" -> "form-solteiros-2026")
        if (!dbForm && hyphenatedId !== rawFormId) {
          const { data: hyphenMatch } = await supabase
            .from("forms")
            .select("*")
            .eq("id", hyphenatedId)
            .maybeSingle()
          if (hyphenMatch) {
            dbForm = hyphenMatch
          }
        }

        // 3. If still not found, try matching by name
        if (!dbForm) {
          const { data: nameMatch } = await supabase
            .from("forms")
            .select("*")
            .ilike("name", `%${rawFormId}%`)
            .maybeSingle()
          if (nameMatch) {
            dbForm = nameMatch
          }
        }

        // 4. If still not found, check if it's a retreat ID or retreat title
        if (!dbForm) {
          const { data: retreatMatch } = await supabase
            .from("retreats")
            .select("form_id")
            .or(`id.eq.${rawFormId},title.ilike.%${rawFormId}%`)
            .maybeSingle()

          if (retreatMatch?.form_id) {
            const { data: retreatForm } = await supabase
              .from("forms")
              .select("*")
              .eq("id", retreatMatch.form_id)
              .maybeSingle()
            if (retreatForm) {
              dbForm = retreatForm
            }
          }
        }

        if (!dbForm) {
          throw formError || new Error("Formulário não encontrado")
        }

        if (dbForm) {
          const presentation = (dbForm.presentation_page as unknown as FormPresentationPage) || undefined
          setFormTemplate({
            id: dbForm.id,
            name: dbForm.name,
            description: dbForm.description || "",
            fields: (dbForm.fields as unknown as FormField[]) || [],
            createdAt: dbForm.created_at,
            isPublic: dbForm.is_public,
            isActive: dbForm.is_active ?? true,
            presentationPage: presentation,
          })

          if (presentation?.enabled) {
            setShowPresentation(true)
          }

          // Check associated retreat for status, capacity and expiration date
          const { data: associatedRetreats, error: retreatError } = await supabase
            .from("retreats")
            .select("id, title, status, start_date, end_date, max_participants, registration_deadline, price, has_payment, location_text, description, image_url")
            .eq("form_id", dbForm.id)

          if (retreatError) throw retreatError

          if (associatedRetreats && associatedRetreats.length > 0) {
            // Check if URL specifies a particular retreat
            const urlParams = new URLSearchParams(window.location.search)
            const requestedRetreatId = urlParams.get("retreat_id") || urlParams.get("eventId") || urlParams.get("retreatId")

            let retreat = requestedRetreatId
              ? associatedRetreats.find((r) => r.id === requestedRetreatId)
              : undefined

            if (!retreat) {
              // Prioritize active retreats so a conflict doesn't lock out an active event
              retreat = associatedRetreats.find((r) => r.status === "ativo") ||
                        associatedRetreats.find((r) => r.status === "rascunho") ||
                        associatedRetreats[0]
            }

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
            // Fallback: check if URL specified retreat_id or eventId directly
            const urlParams = new URLSearchParams(window.location.search)
            const directRetreatId = urlParams.get("retreat_id") || urlParams.get("eventId") || urlParams.get("retreatId")
            if (directRetreatId) {
              const { data: directRetreat } = await supabase
                .from("retreats")
                .select("id, title, status, start_date, end_date, max_participants, registration_deadline, price, has_payment, location_text, description, image_url")
                .eq("id", directRetreatId)
                .maybeSingle()
              if (directRetreat) {
                setAssociatedRetreat(directRetreat)
                setAssociatedEventTitle(directRetreat.title)
              } else {
                setAssociatedRetreat(null)
                setAssociatedEventTitle(null)
              }
            } else {
              setAssociatedRetreat(null)
              setAssociatedEventTitle(null)
            }
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

  // Sync coupon code from URL search params
  useEffect(() => {
    const params = new URLSearchParams(window.location.search)
    const code = params.get("cupom") || params.get("coupon")
    if (code) {
      setCouponCode(code.trim().toUpperCase())
    }
  }, [])

  // Validate coupon when code is present
  useEffect(() => {
    if (!couponCode || !formTemplate) return
    async function checkCoupon() {
      try {
        const { data, error } = await supabase.rpc("validate_coupon", {
          p_code: couponCode!,
          p_form_id: formTemplate!.id,
          p_retreat_id: associatedRetreat?.id || undefined,
        })
        if (!error && data) {
          const res = data as { valid: boolean; message?: string; requires_cpf?: boolean }
          setCouponValidation({
            checked: true,
            valid: res.valid,
            requiresCpf: res.requires_cpf,
            message: res.message,
          })
          if (res.valid) {
            toast.success(
              `Código de isenção ${couponCode} ativo! Conclua o formulário para garantir sua vaga gratuita.`,
              {
                id: "coupon-active-toast",
                duration: 5000,
              }
            )
          } else {
            toast.error(
              res.message || "Código de isenção inválido ou já utilizado.",
              {
                id: "coupon-error-toast",
                duration: 5000,
              }
            )
          }
        } else if (error) {
          setCouponValidation({
            checked: true,
            valid: false,
            message: error.message,
          })
        }
      } catch (e) {
        console.error("Error validating coupon on load", e)
      }
    }
    checkCoupon()
  }, [couponCode, formTemplate?.id, associatedRetreat?.id])

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
  const handleSubmit = async (e: React.FormEvent) => {
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

    // Extract CPF, Email, Name and Gender values from current submission
    let emailVal = ""
    let cpfVal = ""
    let nameVal = ""
    let genderVal = ""
    template.fields.forEach((field) => {
      const val = formData[field.id]
      if (val !== undefined && val !== null && String(val).trim() !== "") {
        const label = field.label.toLowerCase()
        const fid = field.id.toLowerCase()
        if (field.validationPreset === "email" || label.includes("email") || label.includes("e-mail") || fid.includes("email")) {
          emailVal = String(val).trim().toLowerCase()
        } else if (field.validationPreset === "cpf" || label.includes("cpf") || fid.includes("cpf")) {
          cpfVal = String(val).replace(/\D/g, "")
        } else if (label.includes("nome") || fid.includes("name")) {
          nameVal = String(val).trim()
        } else if (label.includes("sexo") || label.includes("gênero") || label.includes("genero") || fid.includes("gender") || fid.includes("sexo")) {
          genderVal = String(val).trim()
        }
      }
    })

    if (!cpfVal && couponCpf) {
      cpfVal = couponCpf.replace(/\D/g, "")
    }

    // Strict validation if coupon is active
    if (couponCode) {
      setCouponCpfError(null)
      const cleanCpf = cpfVal || couponCpf.replace(/\D/g, "")

      if (!cleanCpf) {
        setCouponCpfError("Informe o CPF do beneficiário para liberar a isenção.")
        toast.error("Por favor, informe o CPF do beneficiário para validar o código de isenção.")
        return
      }

      if (cleanCpf.length !== 11 || !isValidCPF(cleanCpf)) {
        setCouponCpfError("CPF inválido. Verifique o número digitado.")
        toast.error("CPF do beneficiário inválido. Digite um número de CPF válido.")
        return
      }
    }

    // Save submission to Supabase
    async function executeSubmission(paid: boolean, method: string, reference: string) {
      try {
        const submissionId = `sub-${Math.random().toString(36).substring(7)}`
        const submitToastId = toast.loading("Enviando sua resposta...")

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
              const fid = field.id.toLowerCase()
              if (label.includes("nome") || fid.includes("name")) {
                guestData.full_name = val
              } else if (label.includes("email") || label.includes("e-mail") || fid.includes("email")) {
                guestData.email = val
              } else if (label.includes("telefone") || label.includes("celular") || label.includes("fone") || label.includes("whatsapp") || fid.includes("phone")) {
                guestData.phone = val
              } else if (label.includes("sexo") || label.includes("gênero") || label.includes("genero") || fid.includes("gender") || fid.includes("sexo")) {
                guestData.gender = val
              } else if (label.includes("cpf") || fid.includes("cpf")) {
                guestData.cpf = val
              }
            }
          })

          if (!guestData.full_name && nameVal) guestData.full_name = nameVal
          if (!guestData.email && emailVal) guestData.email = emailVal
          if (!guestData.cpf && (cpfVal || couponCpf)) {
            guestData.cpf = (cpfVal || couponCpf).replace(/\D/g, "")
          }
          if (!guestData.gender) {
            guestData.gender = genderVal || "Não informado"
          }

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

    const isFreeEvent = associatedRetreat
      ? (associatedRetreat.has_payment === false || Number(associatedRetreat.price) === 0)
      : true
    const total = isFreeEvent
      ? 0
      : calculateTotalPrice(Number(associatedRetreat?.price) || 0, template.fields, filteredData)

    // BRANCH 1: Beneficiary with coupon code
    if (couponCode) {
      const redeemToastId = toast.loading("Validando código de isenção...")
      try {
        let resolvedCpf = cpfVal || couponCpf.replace(/\D/g, "")
        let resolvedName = nameVal
        let resolvedEmail = emailVal
        if ((!resolvedCpf || !resolvedName || !resolvedEmail) && user) {
          const { data: prof } = await supabase
            .from("profiles")
            .select("cpf, full_name, email")
            .eq("user_id", user.id)
            .maybeSingle()
          if (!resolvedCpf && prof?.cpf) resolvedCpf = prof.cpf.replace(/\D/g, "")
          if (!resolvedName && prof?.full_name) resolvedName = prof.full_name
          if (!resolvedEmail && prof?.email) resolvedEmail = prof.email
        }

        if (!resolvedCpf || resolvedCpf.length !== 11) {
          toast.dismiss(redeemToastId)
          toast.error("Por favor, preencha um CPF válido para validar o código de isenção.")
          return
        }

        const { data: redeemData, error: redeemError } = await supabase.rpc("redeem_coupon", {
          p_code: couponCode,
          p_cpf: resolvedCpf,
          p_user_name: resolvedName || undefined,
          p_user_email: resolvedEmail || undefined,
          p_retreat_id: associatedRetreat?.id || undefined,
          p_form_id: template.id || undefined,
        })

        toast.dismiss(redeemToastId)

        if (redeemError) {
          toast.error(`Erro ao validar isenção: ${redeemError.message}`)
          return
        }

        const result = redeemData as { success: boolean; message?: string }
        if (!result || !result.success) {
          toast.error(result?.message || "Código de isenção inválido ou CPF divergente.")
          return
        }

        toast.success("Código de isenção validado com sucesso!")
        await executeSubmission(true, "cupom", `Isenção - Cupom: ${couponCode}`)
        return
      } catch (err: any) {
        toast.dismiss(redeemToastId)
        toast.error("Falha ao processar código de isenção: " + err.message)
        return
      }
    }

    // BRANCH 2: Event requiring payment
    if (associatedRetreat && !isFreeEvent && total > 0) {
      setPendingSubmission({
        execute: async (p: boolean, m: string, r: string) => {
          await executeSubmission(p, m, r)
        }
      })
      setCheckoutPrice(total)
      setShowCheckout(true)
      return
    }

    // BRANCH 3: Free event or form without payment
    await executeSubmission(true, "gratuito", isFreeEvent ? "Evento Gratuito" : "Gratuito")
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
          {formTemplate.presentationPage?.enabled && (
            <div className="mb-2">
              <Button
                type="button"
                variant="ghost"
                size="sm"
                onClick={() => setShowPresentation(true)}
                className="h-8 gap-1.5 -ml-2 cursor-pointer text-xs font-semibold text-muted-foreground hover:text-foreground"
              >
                <ArrowLeft className="h-3.5 w-3.5" />
                Ver Apresentação do Evento
              </Button>
            </div>
          )}

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

          {couponCode && (
            couponValidation.checked && !couponValidation.valid ? (
              <div className="rounded-2xl border border-destructive/30 bg-destructive/5 p-4 sm:p-5 space-y-2 shadow-xs">
                <div className="flex items-center gap-2 text-destructive font-bold text-sm">
                  <AlertCircle className="h-4 w-4 shrink-0" />
                  <span>Código de Isenção Inválido ou Já Utilizado: {couponCode}</span>
                </div>
                <p className="text-xs text-muted-foreground leading-relaxed">
                  {couponValidation.message || "Este código de isenção não é válido ou já foi utilizado para este evento."} A inscrição seguirá pelo fluxo normal.
                </p>
              </div>
            ) : (
              <div className="rounded-2xl border border-emerald-500/30 bg-emerald-500/5 p-4 sm:p-5 space-y-3 shadow-xs">
                <div className="flex items-center gap-2 text-emerald-700 dark:text-emerald-400 font-bold text-sm">
                  <Ticket className="h-4 w-4 shrink-0" />
                  <span>Código de Isenção Ativo: {couponCode}</span>
                </div>
                <p className="text-xs text-muted-foreground leading-relaxed">
                  Sua inscrição terá <strong>isenção de 100% no valor do evento</strong>. Para confirmar o benefício com segurança, o sistema validará o seu CPF na finalização.
                </p>
                {!formTemplate.fields.some(
                  (f) => f.validationPreset === "cpf" || f.label.toLowerCase().includes("cpf")
                ) && (
                  <div className="space-y-1.5 pt-1">
                    <label htmlFor="coupon-cpf-field" className="text-xs font-semibold text-foreground block">
                      CPF do Beneficiário: <span className="text-destructive">*</span>
                    </label>
                    <Input
                      id="coupon-cpf-field"
                      value={couponCpf}
                      onChange={(e) => {
                        setCouponCpf(formatValue(e.target.value, "cpf"))
                        if (couponCpfError) setCouponCpfError(null)
                      }}
                      placeholder="000.000.000-00"
                      maxLength={14}
                      className={`max-w-xs min-h-[44px] h-11 text-sm bg-background ${
                        couponCpfError ? "border-destructive focus-visible:ring-destructive" : "border-border"
                      }`}
                    />
                    {couponCpfError ? (
                      <p className="text-xs font-medium text-destructive">{couponCpfError}</p>
                    ) : (
                      <p className="text-[11px] text-muted-foreground">
                        Insira o mesmo CPF informado pelo gestor na criação deste código para liberar a isenção.
                      </p>
                    )}
                  </div>
                )}
              </div>
            )
          )}

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

  const presentationContent = formTemplate.presentationPage ? (
    <div className="mx-auto max-w-4xl animate-in px-4 py-8 duration-500 fade-in slide-in-from-bottom-4">
      {user && (
        <div className="mb-6">
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
      <FormPresentationView
        presentation={formTemplate.presentationPage}
        retreat={associatedRetreat}
        onStart={() => setShowPresentation(false)}
      />
    </div>
  ) : null

  const activeContent =
    showPresentation && formTemplate.presentationPage?.enabled
      ? presentationContent
      : formContent

  if (user) {
    return <Layout>{activeContent}</Layout>
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
      <main className="py-4">{activeContent}</main>
    </div>
  )
}
