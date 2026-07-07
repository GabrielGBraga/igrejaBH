import { useEffect, useState } from "react"
import supabase from "@/lib/supabase"
import {
  Calendar,
  MapPin,
  Clock,
  DollarSign,
  Loader2,
  CheckCircle2,
  ArrowLeft,
  ChevronRight,
  Info,
  HelpCircle,
  CreditCard,
  Smartphone,
  QrCode,
  Lock,
} from "lucide-react"
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
  CardFooter,
} from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Textarea } from "@/components/ui/textarea"
import { Badge } from "@/components/ui/badge"
import { Tooltip, TooltipContent, TooltipProvider, TooltipTrigger } from "@/components/ui/tooltip"
import { Progress } from "@/components/ui/progress"
import { Field, FieldLabel, FieldError } from "@/components/ui/field"
import { RadioGroup, RadioGroupItem } from "@/components/ui/radio-group"
import { Checkbox } from "@/components/ui/checkbox"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { toast } from "sonner"
import {
  isFieldVisible,
  formatValue,
  isValidCPF,
  isValidPhone,
  fetchAddressFromCep,
  calculateTotalPrice,
} from "@/lib/forms"
import type { FormField } from "@/lib/forms"
import type { Database } from "@/lib/database.types"

type Retreat = Database["public"]["Tables"]["retreats"]["Row"]

type Registration = Database["public"]["Tables"]["registrations"]["Row"] & {
  retreats: Retreat | null
}

interface Profile {
  id: string
  full_name: string
  email: string | null
  phone: string | null
  cpf: string | null
  birth_date: string | null
}

export default function Events() {
  const [retreats, setRetreats] = useState<Retreat[]>([])
  const [myRegistrations, setMyRegistrations] = useState<Registration[]>([])
  const [userProfile, setUserProfile] = useState<Profile | null>(null)

  // Loading states
  const [loading, setLoading] = useState(true)
  const [submitting, setSubmitting] = useState(false)

  // Registration Flow States
  const [registeringRetreat, setRegisteringRetreat] = useState<Retreat | null>(
    null
  )
  const [activeStep, setActiveStep] = useState<1 | 2 | 3>(1)

  // Step 1 Form Data (Guest info)
  const [guestData, setGuestData] = useState({
    fullName: "",
    email: "",
    phone: "",
    cpf: "",
    birthDate: "",
  })
  const [guestErrors, setGuestErrors] = useState<Record<string, string>>({})

  // Step 2 Form Data (Dynamic Form Responses)
  const [customResponses, setCustomResponses] = useState<Record<string, any>>(
    {}
  )
  const [customFormFields, setCustomFormFields] = useState<FormField[]>([])
  const [loadingForm, setLoadingForm] = useState(false)
  const [formErrors, setFormErrors] = useState<Record<string, string>>({})

  // Step 3 Form Data (Payment & Notes)
  const [paymentRef, setPaymentRef] = useState("")
  const [notes, setNotes] = useState("")

  // Integrated Payment States
  const [paymentType, setPaymentType] = useState<"pix" | "card">("pix")
  const [cardNumber, setCardNumber] = useState("")
  const [cardExpiry, setCardExpiry] = useState("")
  const [cardCvv, setCardCvv] = useState("")
  const [cardName, setCardName] = useState("")

  useEffect(() => {
    fetchInitialData()
  }, [])

  // Fetch custom form fields when registeringRetreat changes
  useEffect(() => {
    if (registeringRetreat && registeringRetreat.form_id) {
      fetchCustomForm(registeringRetreat.form_id)
    } else {
      setCustomFormFields([])
      setCustomResponses({})
    }
  }, [registeringRetreat])

  async function fetchInitialData() {
    setLoading(true)
    try {
      const {
        data: { session },
      } = await supabase.auth.getSession()
      if (!session?.user) return

      // 1. Fetch user profile
      const { data: profile } = await supabase
        .from("profiles")
        .select("id, full_name, email, phone, cpf, birth_date")
        .eq("user_id", session.user.id)
        .single()

      if (profile) {
        setUserProfile(profile)
        setGuestData({
          fullName: profile.full_name || "",
          email: profile.email || "",
          phone: profile.phone || "",
          cpf: profile.cpf || "",
          birthDate: profile.birth_date || "",
        })
      }

      // 2. Fetch active retreats
      const { data: eventsData, error: eventsErr } = await supabase
        .from("retreats")
        .select("*")
        .eq("status", "ativo")
        .order("start_date", { ascending: true })
      if (eventsErr) throw eventsErr
      setRetreats(eventsData || [])

      // 3. Fetch user's own registrations
      if (profile) {
        const { data: regsData, error: regsErr } = await supabase
          .from("registrations")
          .select(
            `
            *,
            retreats (
              *
            )
          `
          )
          .eq("profile_id", profile.id)
        if (regsErr) throw regsErr
        setMyRegistrations(regsData || [])
      }
    } catch (err: any) {
      toast.error("Erro ao carregar dados dos eventos: " + err.message)
    } finally {
      setLoading(false)
    }
  }

  async function fetchCustomForm(formId: string) {
    setLoadingForm(true)
    try {
      const { data, error } = await supabase
        .from("forms")
        .select("fields")
        .eq("id", formId)
        .single()

      if (error) throw error
      if (data && data.fields) {
        const fields = data.fields as unknown as FormField[]
        setCustomFormFields(fields)

        // Initialize responses structure
        const initialResponses: Record<string, any> = {}
        fields.forEach((f) => {
          initialResponses[f.id] = f.type === "checkbox" ? [] : ""
        })
        setCustomResponses(initialResponses)
      }
    } catch (err: any) {
      console.error("Erro ao buscar formulário customizado:", err)
      toast.error(
        "Não foi possível carregar a ficha de inscrição complementar."
      )
    } finally {
      setLoadingForm(false)
    }
  }

  // Real-time CEP filler inside the custom form
  const handleCepChange = async (field: FormField, val: string) => {
    const cleanCep = val.replace(/\D/g, "")
    setCustomResponses((prev) => ({ ...prev, [field.id]: val }))

    if (cleanCep.length === 8 && field.cepMapping) {
      const mapping = field.cepMapping
      toast.info("Buscando endereço...")
      const address = await fetchAddressFromCep(cleanCep)

      if (address && !address.error) {
        setCustomResponses((prev) => {
          const updated = { ...prev }
          if (mapping.streetFieldId)
            updated[mapping.streetFieldId] = address.logradouro || ""
          if (mapping.neighborhoodFieldId)
            updated[mapping.neighborhoodFieldId] = address.bairro || ""
          if (mapping.cityFieldId)
            updated[mapping.cityFieldId] = address.localidade || ""
          if (mapping.stateFieldId)
            updated[mapping.stateFieldId] = address.uf || ""
          return updated
        })
        toast.success("Endereço preenchido automaticamente!")
      } else {
        toast.error("CEP não encontrado.")
      }
    }
  }

  // Step 1 Validation
  const validateStep1 = () => {
    const errors: Record<string, string> = {}
    if (!guestData.fullName.trim()) errors.fullName = "Nome é obrigatório."
    if (!guestData.email.trim()) {
      errors.email = "E-mail é obrigatório."
    } else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(guestData.email)) {
      errors.email = "E-mail inválido."
    }
    if (!guestData.phone.trim()) {
      errors.phone = "Telefone é obrigatório."
    } else if (!isValidPhone(guestData.phone)) {
      errors.phone = "Celular inválido (Ex: (31) 98888-7777)."
    }
    if (!guestData.cpf.trim()) {
      errors.cpf = "CPF é obrigatório."
    } else if (!isValidCPF(guestData.cpf)) {
      errors.cpf = "CPF inválido."
    }
    if (!guestData.birthDate)
      errors.birthDate = "Data de nascimento é obrigatória."

    setGuestErrors(errors)
    return Object.keys(errors).length === 0
  }

  // Step 2 Validation (Dynamic Custom Form)
  const validateStep2 = () => {
    const errors: Record<string, string> = {}

    customFormFields.forEach((field) => {
      // Skip validation if field is not currently visible
      if (!isFieldVisible(field, customResponses, customFormFields)) return

      const val = customResponses[field.id]

      // Required check
      if (field.required) {
        if (field.type === "checkbox") {
          if (!val || val.length === 0) {
            errors[field.id] = `${field.label} é obrigatório.`
          }
        } else if (typeof val === "string" && !val.trim()) {
          errors[field.id] = `${field.label} é obrigatório.`
        } else if (val === undefined || val === null) {
          errors[field.id] = `${field.label} é obrigatório.`
        }
      }

      // Format presets check
      if (
        val &&
        typeof val === "string" &&
        field.validationPreset &&
        field.validationPreset !== "none"
      ) {
        if (field.validationPreset === "cpf" && !isValidCPF(val)) {
          errors[field.id] = "CPF inválido."
        }
        if (field.validationPreset === "phone" && !isValidPhone(val)) {
          errors[field.id] = "Telefone inválido."
        }
        if (
          field.validationPreset === "email" &&
          !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(val)
        ) {
          errors[field.id] = "E-mail inválido."
        }
      }
    })

    setFormErrors(errors)
    return Object.keys(errors).length === 0
  }

  const handleNextStep = () => {
    if (activeStep === 1) {
      if (validateStep1()) {
        // Go to Step 2 if custom form exists, otherwise Step 3
        if (customFormFields.length > 0) {
          setActiveStep(2)
        } else {
          setActiveStep(3)
        }
      } else {
        toast.error("Preencha corretamente todos os dados gerais.")
      }
    } else if (activeStep === 2) {
      if (validateStep2()) {
        setActiveStep(3)
      } else {
        toast.error("Preencha corretamente a ficha complementar.")
      }
    }
  }

  const handlePrevStep = () => {
    if (activeStep === 3) {
      if (customFormFields.length > 0) {
        setActiveStep(2)
      } else {
        setActiveStep(1)
      }
    } else if (activeStep === 2) {
      setActiveStep(1)
    }
  }

  // Submit Registration to Database
  const handleConfirmRegistration = async () => {
    if (!registeringRetreat || !userProfile) return
    setSubmitting(true)

    // Map custom responses field IDs to their labels for easy display
    const finalPrice = calculateTotalPrice(registeringRetreat.price || 0, customFormFields, customResponses)

    const performSubmission = async (paid: boolean, method: string, ref: string) => {
      try {
        let formSubmissionId: string | null = null

        if (registeringRetreat.form_id) {
          const { data: { session } } = await supabase.auth.getSession()
          const authUserId = session?.user?.id || null

          formSubmissionId = `sub-${Math.random().toString(36).substring(7)}`

          const filteredData: Record<string, any> = {}
          customFormFields.forEach((field) => {
            if (
              isFieldVisible(field, customResponses, customFormFields) &&
              customResponses[field.id] !== undefined
            ) {
              filteredData[field.id] = customResponses[field.id]
            }
          })

          const { error: subError } = await supabase.from("form_submissions").insert({
            id: formSubmissionId,
            form_id: registeringRetreat.form_id,
            data: filteredData,
            user_id: authUserId,
          })

          if (subError) throw subError
        }

        // Map custom responses field IDs to their labels for easy display
        const mappedResponses: Record<string, any> = {}
        customFormFields.forEach((field) => {
          if (isFieldVisible(field, customResponses, customFormFields)) {
            mappedResponses[field.label] = customResponses[field.id]
          }
        })

        const payload = {
          retreat_id: registeringRetreat.id,
          profile_id: userProfile.id,
          guest_data: guestData,
          custom_responses: mappedResponses,
          payment_method: method,
          payment_reference: ref,
          notes: notes.trim() || null,
          paid: paid,
          form_submission_id: formSubmissionId,
        }

        const { error } = await supabase.from("registrations").insert([payload])

        if (error) throw error

        toast.success(paid ? "Inscrição efetuada e paga com sucesso!" : "Inscrição efetuada com sucesso!")
        setRegisteringRetreat(null)
        setActiveStep(1)
        setPaymentRef("")
        setNotes("")
        // Reset card details
        setCardName("")
        setCardNumber("")
        setCardExpiry("")
        setCardCvv("")
        fetchInitialData()
      } catch (err: any) {
        toast.error("Erro ao efetuar inscrição: " + err.message)
      } finally {
        setSubmitting(false)
      }
    }

    if (finalPrice > 0) {
      // Simulate integrated payment processing
      setTimeout(() => {
        const method = paymentType === "pix" ? "pix" : "credit_card"
        const ref = `Integrado - ${paymentType.toUpperCase()} - Simulado #${Math.floor(100000 + Math.random() * 900000)}`
        performSubmission(true, method, ref)
      }, 2500)
    } else {
      performSubmission(true, "gratuito", "Isento")
    }
  }

  if (loading) {
    return (
      <div className="flex min-h-[50vh] flex-col items-center justify-center gap-3">
        <Loader2 className="h-10 w-10 animate-spin text-primary" />
        <span className="text-sm font-medium text-muted-foreground">
          Carregando retiros e inscrições...
        </span>
      </div>
    )
  }

  // Active registration view (stepper)
  if (registeringRetreat) {
    return (
      <div className="mx-auto max-w-3xl space-y-6 px-4 py-6 pb-24">
        {/* Stepper Header */}
        <div className="flex items-center justify-between border-b border-border/50 pb-4">
          <button
            onClick={() => {
              if (
                confirm(
                  "Deseja cancelar o processo de inscrição? Dados inseridos serão perdidos."
                )
              ) {
                setRegisteringRetreat(null)
              }
            }}
            className="flex cursor-pointer items-center gap-1.5 text-sm font-semibold text-muted-foreground hover:text-foreground"
          >
            <ArrowLeft className="h-4 w-4" /> Cancelar
          </button>
          <div className="text-right">
            <h2 className="text-lg font-extrabold text-foreground">
              {registeringRetreat.title}
            </h2>
            <p className="text-xs text-muted-foreground">
              Inscrição no Encontro
            </p>
          </div>
        </div>

        {/* Visual Steps Indicator */}
        <div className="flex items-center justify-center gap-3 py-2 md:gap-6">
          {[
            { step: 1, label: "Dados Gerais" },
            ...(customFormFields.length > 0
              ? [{ step: 2, label: "Ficha Complementar" }]
              : []),
            { step: 3, label: "Pagamento & Notas" },
          ].map((item, idx, arr) => {
            const isCompleted = activeStep > item.step
            const isActive = activeStep === item.step
            return (
              <div key={item.step} className="flex items-center gap-2">
                <div
                  className={`flex size-8 items-center justify-center rounded-full border text-sm font-bold transition-all duration-300 ${
                    isCompleted
                      ? "border-primary bg-primary text-primary-foreground shadow-md shadow-primary/20"
                      : isActive
                        ? "border-primary bg-card text-primary shadow-sm"
                        : "border-border bg-muted/30 text-muted-foreground"
                  }`}
                >
                  {item.step}
                </div>
                <span
                  className={`hidden text-xs font-bold sm:inline ${isActive ? "text-foreground" : "text-muted-foreground"}`}
                >
                  {item.label}
                </span>
                {idx < arr.length - 1 && (
                  <ChevronRight className="hidden h-4 w-4 text-muted-foreground/60 sm:inline" />
                )}
              </div>
            )
          })}
        </div>

        {/* Stepper Content */}
        <Card className="overflow-hidden rounded-2xl border-border/50 bg-card/35 shadow-xl backdrop-blur-sm">
          <CardContent className="p-6 md:p-8">
            {/* STEP 1: General Info */}
            {activeStep === 1 && (
              <div className="space-y-4">
                <h3 className="mb-4 border-b border-border/30 pb-2 text-lg font-bold text-foreground">
                  Dados Básicos do Inscrito
                </h3>

                <Field>
                  <FieldLabel htmlFor="fullName">Nome Completo *</FieldLabel>
                  <Input
                    id="fullName"
                    value={guestData.fullName}
                    onChange={(e) =>
                      setGuestData((prev) => ({
                        ...prev,
                        fullName: e.target.value,
                      }))
                    }
                    placeholder="Seu nome completo"
                  />
                  {guestErrors.fullName && (
                    <FieldError>{guestErrors.fullName}</FieldError>
                  )}
                </Field>

                <div className="grid grid-cols-1 gap-4 md:grid-cols-2">
                  <Field>
                    <FieldLabel htmlFor="email">E-mail *</FieldLabel>
                    <Input
                      id="email"
                      type="email"
                      value={guestData.email}
                      onChange={(e) =>
                        setGuestData((prev) => ({
                          ...prev,
                          email: e.target.value,
                        }))
                      }
                      placeholder="seuemail@provedor.com"
                    />
                    {guestErrors.email && (
                      <FieldError>{guestErrors.email}</FieldError>
                    )}
                  </Field>

                  <Field>
                    <FieldLabel htmlFor="phone">Celular *</FieldLabel>
                    <Input
                      id="phone"
                      value={guestData.phone}
                      onChange={(e) =>
                        setGuestData((prev) => ({
                          ...prev,
                          phone: formatValue(e.target.value, "phone"),
                        }))
                      }
                      placeholder="(31) 99999-9999"
                    />
                    {guestErrors.phone && (
                      <FieldError>{guestErrors.phone}</FieldError>
                    )}
                  </Field>
                </div>

                <div className="grid grid-cols-1 gap-4 md:grid-cols-2">
                  <Field>
                    <FieldLabel htmlFor="cpf">CPF *</FieldLabel>
                    <Input
                      id="cpf"
                      value={guestData.cpf}
                      onChange={(e) =>
                        setGuestData((prev) => ({
                          ...prev,
                          cpf: formatValue(e.target.value, "cpf"),
                        }))
                      }
                      placeholder="000.000.000-00"
                    />
                    {guestErrors.cpf && (
                      <FieldError>{guestErrors.cpf}</FieldError>
                    )}
                  </Field>

                  <Field>
                    <FieldLabel htmlFor="birthDate">
                      Data de Nascimento *
                    </FieldLabel>
                    <Input
                      id="birthDate"
                      type="date"
                      value={guestData.birthDate}
                      onChange={(e) =>
                        setGuestData((prev) => ({
                          ...prev,
                          birthDate: e.target.value,
                        }))
                      }
                    />
                    {guestErrors.birthDate && (
                      <FieldError>{guestErrors.birthDate}</FieldError>
                    )}
                  </Field>
                </div>
              </div>
            )}

            {/* STEP 2: Custom responses (Formulário Customizado) */}
            {activeStep === 2 && (
              <div className="space-y-4">
                <h3 className="mb-4 border-b border-border/30 pb-2 text-lg font-bold text-foreground">
                  Perguntas Complementares
                </h3>
                {loadingForm ? (
                  <div className="flex justify-center py-6">
                    <Loader2 className="h-8 w-8 animate-spin text-primary" />
                  </div>
                ) : (
                  customFormFields.map((field) => {
                    const isVisible = isFieldVisible(
                      field,
                      customResponses,
                      customFormFields
                    )
                    if (!isVisible) return null

                    const hasError = formErrors[field.id]

                    return (
                      <Field
                        key={field.id}
                        className={
                          field.halfWidth
                            ? "inline-block md:w-1/2 md:pr-2"
                            : "w-full"
                        }
                      >
                        <FieldLabel
                          htmlFor={field.id}
                          className="flex items-center gap-1"
                        >
                          {field.label}{" "}
                          {field.required && (
                            <span className="text-red-500">*</span>
                          )}
                          {field.helpText && (
                            <span
                              className="text-muted-foreground opacity-60"
                              title={field.helpText}
                            >
                              <HelpCircle className="h-3.5 w-3.5" />
                            </span>
                          )}
                        </FieldLabel>

                        {/* Input type renders */}
                        {field.type === "text" && (
                          <Input
                            id={field.id}
                            value={customResponses[field.id] || ""}
                            onChange={(e) => {
                              const val = e.target.value
                              if (field.validationPreset === "cep") {
                                handleCepChange(field, val)
                              } else {
                                setCustomResponses((prev) => ({
                                  ...prev,
                                  [field.id]: formatValue(
                                    val,
                                    field.validationPreset
                                  ),
                                }))
                              }
                            }}
                            placeholder={field.placeholder}
                          />
                        )}

                        {field.type === "textarea" && (
                          <Textarea
                            id={field.id}
                            value={customResponses[field.id] || ""}
                            onChange={(e) =>
                              setCustomResponses((prev) => ({
                                ...prev,
                                [field.id]: e.target.value,
                              }))
                            }
                            placeholder={field.placeholder}
                            className="min-h-[80px]"
                          />
                        )}

                        {field.type === "number" && (
                          <Input
                            id={field.id}
                            type="number"
                            value={customResponses[field.id] || ""}
                            onChange={(e) =>
                              setCustomResponses((prev) => ({
                                ...prev,
                                [field.id]:
                                  e.target.value === ""
                                    ? ""
                                    : Number(e.target.value),
                              }))
                            }
                            placeholder={field.placeholder}
                          />
                        )}

                        {field.type === "date" && (
                          <Input
                            id={field.id}
                            type="date"
                            value={customResponses[field.id] || ""}
                            onChange={(e) =>
                              setCustomResponses((prev) => ({
                                ...prev,
                                [field.id]: e.target.value,
                              }))
                            }
                          />
                        )}

                        {field.type === "select" && (
                          <Select
                            value={customResponses[field.id] || "none"}
                            onValueChange={(val) =>
                              setCustomResponses((prev) => ({
                                ...prev,
                                [field.id]: val === "none" ? "" : val,
                              }))
                            }
                          >
                            <SelectTrigger id={field.id} className="w-full">
                              <SelectValue placeholder="Selecione uma opção" />
                            </SelectTrigger>
                            <SelectContent>
                              <SelectItem value="none">Selecione uma opção</SelectItem>
                              {field.options.map((opt) => (
                                <SelectItem key={opt} value={opt}>
                                  {opt}
                                </SelectItem>
                              ))}
                            </SelectContent>
                          </Select>
                        )}

                        {field.type === "radio" && (
                          <RadioGroup
                            value={customResponses[field.id] || ""}
                            onValueChange={(val) =>
                              setCustomResponses((prev) => ({
                                ...prev,
                                [field.id]: val,
                              }))
                            }
                            className="mt-2 flex flex-col gap-2"
                          >
                            {field.options.map((opt) => (
                              <div key={opt} className="flex items-center gap-2">
                                <RadioGroupItem value={opt} id={`${field.id}-${opt}`} />
                                <label
                                  htmlFor={`${field.id}-${opt}`}
                                  className="text-sm font-semibold text-foreground/80 cursor-pointer"
                                >
                                  {opt}
                                </label>
                              </div>
                            ))}
                          </RadioGroup>
                        )}

                        {field.type === "checkbox" && (
                          <div className="mt-2 flex flex-col gap-2.5">
                            {field.options.map((opt) => {
                              const checkedList =
                                customResponses[field.id] || []
                              const isChecked = checkedList.includes(opt)
                              return (
                                <div key={opt} className="flex items-center gap-2">
                                  <Checkbox
                                    id={`${field.id}-${opt}`}
                                    checked={isChecked}
                                    onCheckedChange={(checked) => {
                                      const next = checked
                                        ? [...checkedList, opt]
                                        : checkedList.filter(
                                            (item: string) => item !== opt
                                          )
                                      setCustomResponses((prev) => ({
                                        ...prev,
                                        [field.id]: next,
                                      }))
                                    }}
                                  />
                                  <label
                                    htmlFor={`${field.id}-${opt}`}
                                    className="text-sm font-semibold text-foreground/80 cursor-pointer"
                                  >
                                    {opt}
                                  </label>
                                </div>
                              )
                            })}
                          </div>
                        )}

                        {hasError && <FieldError>{hasError}</FieldError>}
                      </Field>
                    )
                  })
                )}
              </div>
            )}

            {/* STEP 3: Payment & Notes */}
            {activeStep === 3 && (() => {
              const totalPrice = calculateTotalPrice(registeringRetreat?.price || 0, customFormFields, customResponses)

              return (
                <div className="space-y-5 text-left">
                  <h3 className="mb-2 border-b border-border/30 pb-2 text-lg font-bold text-foreground">
                    Finalizar Inscrição
                  </h3>

                  {/* Price Summary */}
                  <div className="rounded-lg bg-muted/40 p-4 border border-border/30">
                    <div className="flex justify-between items-center">
                      <span className="text-xs text-muted-foreground font-medium">Valor Total da Inscrição:</span>
                      <span className="text-xl font-extrabold text-foreground">
                        {new Intl.NumberFormat("pt-BR", { style: "currency", currency: "BRL" }).format(totalPrice)}
                      </span>
                    </div>
                  </div>

                  {totalPrice > 0 ? (
                    <div className="space-y-4">
                      {/* Payment Method Selector */}
                      <div className="space-y-2">
                        <label className="text-[10px] font-bold tracking-wider text-muted-foreground uppercase">
                          Método de Pagamento Integrado
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
                            <div className="h-32 w-32 bg-zinc-200 dark:bg-zinc-800 rounded-lg flex items-center justify-center border border-border shadow-inner relative overflow-hidden">
                              <QrCode className="h-24 w-24 text-foreground" />
                              {submitting && (
                                <div className="absolute inset-0 bg-background/80 flex flex-col items-center justify-center gap-2">
                                  <Loader2 className="h-6 w-6 animate-spin text-primary" />
                                  <span className="text-[9px] font-semibold text-muted-foreground">Processando PIX...</span>
                                </div>
                              )}
                            </div>
                            <p className="text-[10px] text-muted-foreground mt-3 text-center">
                              Escaneie o QR Code acima usando seu aplicativo de banco para pagar instantaneamente.
                            </p>
                          </div>

                          <div className="space-y-1">
                            <label className="text-[10px] font-bold text-muted-foreground uppercase">Código Copia e Cola</label>
                            <div className="flex gap-2">
                              <Input
                                readOnly
                                value="00020101021226830014br.gov.bcb.pix2561pix.igrejabh.com.br/pg/retiro..."
                                className="h-9 text-[10px] font-mono text-muted-foreground bg-muted/40 cursor-default"
                              />
                              <Button
                                size="sm"
                                type="button"
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
                        <div className="space-y-3 animate-in fade-in duration-200">
                          <div className="space-y-1">
                            <label className="text-[10px] font-bold text-muted-foreground uppercase">Nome no Cartão</label>
                            <Input
                              placeholder="JOÃO SILVA"
                              value={cardName}
                              onChange={(e) => setCardName(e.target.value.toUpperCase())}
                              className="h-9 text-xs"
                              disabled={submitting}
                            />
                          </div>
                          <div className="space-y-1">
                            <label className="text-[10px] font-bold text-muted-foreground uppercase">Número do Cartão</label>
                            <Input
                              placeholder="0000 0000 0000 0000"
                              value={cardNumber}
                              onChange={(e) => setCardNumber(e.target.value.replace(/\D/g, "").slice(0, 16))}
                              className="h-9 text-xs"
                              disabled={submitting}
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
                                disabled={submitting}
                              />
                            </div>
                            <div className="space-y-1">
                              <label className="text-[10px] font-bold text-muted-foreground uppercase">CVV</label>
                              <Input
                                placeholder="000"
                                value={cardCvv}
                                onChange={(e) => setCardCvv(e.target.value.replace(/\D/g, "").slice(0, 3))}
                                className="h-9 text-xs"
                                disabled={submitting}
                              />
                            </div>
                          </div>
                        </div>
                      )}
                    </div>
                  ) : (
                    <div className="rounded-xl border border-emerald-500/25 bg-emerald-500/5 p-4 text-center text-xs font-medium text-emerald-600 dark:bg-emerald-500/5">
                      Este evento é gratuito. Nenhuma taxa de inscrição é necessária.
                    </div>
                  )}

                  <Field>
                    <FieldLabel htmlFor="notes">
                      Notas ou Restrições (Opcional)
                    </FieldLabel>
                    <Textarea
                      id="notes"
                      value={notes}
                      onChange={(e) => setNotes(e.target.value)}
                      placeholder="Ex: Restrições alimentares (alergia a glúten), medicamentos contínuos, ou observações..."
                      className="min-h-[80px]"
                    />
                  </Field>
                </div>
              )
            })()}
          </CardContent>

          {/* Stepper Navigation Actions */}
          <CardFooter className="flex justify-between border-t border-border/40 bg-muted/15 p-6">
            <Button
              variant="outline"
              onClick={handlePrevStep}
              className="cursor-pointer rounded-lg font-bold hover:bg-muted"
              disabled={activeStep === 1 || submitting}
            >
              Voltar
            </Button>

            {activeStep < 3 ? (
              <Button
                onClick={handleNextStep}
                className="flex cursor-pointer items-center gap-1 rounded-lg font-bold"
              >
                Avançar <ChevronRight className="h-4 w-4" />
              </Button>
            ) : (
              <Button
                onClick={handleConfirmRegistration}
                className="cursor-pointer rounded-lg bg-primary font-bold text-primary-foreground shadow-md shadow-primary/20"
                disabled={
                  submitting || 
                  (calculateTotalPrice(registeringRetreat?.price || 0, customFormFields, customResponses) > 0 && 
                   paymentType === "card" && 
                   (!cardName || !cardNumber || !cardExpiry || !cardCvv))
                }
              >
                {submitting && (
                  <Loader2 className="mr-1.5 h-4 w-4 animate-spin" />
                )}
                Confirmar Inscrição
              </Button>
            )}
          </CardFooter>
        </Card>
      </div>
    )
  }

  return (
    <div className="mx-auto max-w-7xl space-y-8 px-4 py-6 pb-24 md:px-6">
      {/* Page Title */}
      <div className="border-b border-border/60 pb-6">
        <h1 className="bg-clip-text text-3xl font-extrabold tracking-tight text-foreground">
          Encontros & Retiros do Corpo
        </h1>
        <p className="mt-1.5 text-muted-foreground">
          Confira e participe dos retiros e encontros organizados para a
          comunhão e edificação mútua.
        </p>
      </div>

      {/* 1. User's Current Registrations Section */}
      {myRegistrations.length > 0 && (
        <div className="space-y-4">
          <h2 className="flex items-center gap-2 text-sm font-bold tracking-wider text-muted-foreground uppercase">
            <CheckCircle2 className="h-4.5 w-4.5 text-emerald-500" /> Minhas
            Inscrições
          </h2>
          <div className="grid grid-cols-1 gap-6 md:grid-cols-2">
            {myRegistrations.map((reg) => {
              const retreat = reg.retreats
              if (!retreat) return null

              return (
                <Card
                  key={reg.id}
                  className="flex flex-col overflow-hidden rounded-2xl border-emerald-500/20 bg-emerald-500/[0.02] shadow-sm dark:border-emerald-500/10 dark:bg-emerald-500/[0.01]"
                >
                  <CardHeader className="p-5 pb-3">
                    <div className="flex items-start justify-between gap-4">
                      <div>
                        <CardTitle className="text-lg font-bold text-foreground">
                          {retreat.title}
                        </CardTitle>
                        <CardDescription className="mt-1 flex items-center gap-1.5 text-xs text-muted-foreground">
                          <MapPin className="h-3.5 w-3.5" />{" "}
                          {retreat.location_text || "Sem local específico"}
                        </CardDescription>
                      </div>
                      <Badge
                        variant="outline"
                        className={`font-bold uppercase ${
                          reg.paid
                            ? "border-emerald-500/30 bg-emerald-500/15 text-emerald-500 dark:border-emerald-500/20 dark:bg-emerald-500/5"
                            : "border-amber-500/30 bg-amber-500/15 text-amber-500 dark:border-amber-500/20 dark:bg-amber-500/5"
                        }`}
                      >
                        {reg.paid ? "Confirmada" : "Aguardando PIX"}
                      </Badge>
                    </div>
                  </CardHeader>
                  <CardContent className="flex-grow space-y-2 p-5 pt-0 text-xs text-muted-foreground">
                    <div className="flex justify-between border-b border-border/10 pb-1.5">
                      <span>Período:</span>
                      <span className="font-bold text-foreground">
                        {retreat.start_date &&
                          new Date(retreat.start_date).toLocaleDateString(
                            "pt-BR"
                          )}{" "}
                        até{" "}
                        {retreat.end_date &&
                          new Date(retreat.end_date).toLocaleDateString(
                            "pt-BR"
                          )}
                      </span>
                    </div>
                    <div className="flex justify-between border-b border-border/10 pb-1.5">
                      <span>Alojamento Alocado:</span>
                      <span
                        className={`font-bold ${reg.room_allocation ? "text-primary" : "text-muted-foreground italic"}`}
                      >
                        {reg.room_allocation || "Pendente de alocação"}
                      </span>
                    </div>
                    {reg.payment_reference && (
                      <div className="flex justify-between text-[11px]">
                        <span>Chave PIX Informada:</span>
                        <span className="font-medium text-foreground select-all">
                          {reg.payment_reference}
                        </span>
                      </div>
                    )}
                  </CardContent>
                  <CardFooter className="flex items-center gap-1.5 bg-emerald-500/[0.04] p-5 pt-2 text-[10px] font-bold text-emerald-600 dark:bg-emerald-500/[0.02] dark:text-emerald-400/90">
                    <Info className="h-3.5 w-3.5" />
                    {reg.paid
                      ? "Tudo pronto! Seu alojamento e comprovante foram confirmados pelo diaconato."
                      : "Aguardando a liderança verificar o pagamento no sistema. Isso pode levar até 24h."}
                  </CardFooter>
                </Card>
              )
            })}
          </div>
        </div>
      )}

      {/* 2. Available Retreats list */}
      <div className="space-y-4">
        <h2 className="flex items-center gap-2 text-sm font-bold tracking-wider text-muted-foreground uppercase">
          <Calendar className="h-4.5 w-4.5" /> Próximos Eventos Disponíveis
        </h2>
        {retreats.length === 0 ? (
          <div className="rounded-2xl border border-dashed border-border/80 bg-muted/10 py-16 text-center">
            <Info className="mx-auto mb-3 h-12 w-12 text-muted-foreground" />
            <h3 className="text-lg font-bold text-foreground">
              Nenhum evento ativo
            </h3>
            <p className="mx-auto mt-1 max-w-sm text-sm text-muted-foreground">
              No momento não há novos encontros ou retiros com inscrições
              abertas. Volte mais tarde!
            </p>
          </div>
        ) : (
          <div className="grid grid-cols-1 gap-6 md:grid-cols-2 lg:grid-cols-3">
            {retreats.map((retreat) => {
              const hasRegistered = myRegistrations.some(
                (reg) => reg.retreat_id === retreat.id
              )

              return (
                <Card
                  key={retreat.id}
                  className="flex flex-col overflow-hidden rounded-2xl border-border/50 bg-card/25 shadow-sm transition-all duration-300 hover:border-primary/20 hover:shadow-lg"
                >
                  {retreat.image_url && (
                    <div className="h-40 w-full shrink-0 overflow-hidden border-b border-border/10">
                      <img
                        src={retreat.image_url}
                        alt={retreat.title}
                        className="h-full w-full object-cover"
                      />
                    </div>
                  )}
                  <CardHeader className="p-5 pb-3">
                    <CardTitle className="text-lg font-extrabold tracking-tight text-foreground">
                      {retreat.title}
                    </CardTitle>
                    <CardDescription className="mt-1 flex items-center gap-1.5 text-xs">
                      <MapPin className="h-3.5 w-3.5 text-muted-foreground" />{" "}
                      {retreat.location_text || "BH e região"}
                    </CardDescription>
                  </CardHeader>
                  <CardContent className="flex-grow space-y-4 p-5 pt-0 text-sm text-muted-foreground">
                    <p className="line-clamp-3 text-xs leading-relaxed">
                      {retreat.description ||
                        "Participe de mais um encontro edificante com toda a igreja local."}
                    </p>

                    <div className="space-y-2 border-t border-border/10 pt-3 text-xs">
                      <div className="flex items-center justify-between">
                        <span className="flex items-center gap-1 text-muted-foreground">
                          <Clock className="h-3.5 w-3.5" /> Período:
                        </span>
                        <span className="font-bold text-foreground">
                          {retreat.start_date &&
                            new Date(retreat.start_date).toLocaleDateString(
                              "pt-BR"
                            )}{" "}
                          até{" "}
                          {retreat.end_date &&
                            new Date(retreat.end_date).toLocaleDateString(
                              "pt-BR"
                            )}
                        </span>
                      </div>
                      <div className="flex items-center justify-between">
                        <span className="flex items-center gap-1 text-muted-foreground">
                          <DollarSign className="h-3.5 w-3.5" /> Valor
                          individual:
                        </span>
                        <span className="text-sm font-extrabold text-foreground">
                          {retreat.price && retreat.price > 0
                            ? `R$ ${Number(retreat.price).toFixed(2)}`
                            : "Grátis"}
                        </span>
                      </div>
                    </div>
                  </CardContent>
                  <CardFooter className="border-t border-border/10 bg-muted/5 p-5 pt-0">
                    {hasRegistered ? (
                      <Button
                        disabled
                        className="mt-3 w-full rounded-xl bg-emerald-500/10 font-semibold text-emerald-600 dark:bg-emerald-500/5 dark:text-emerald-400"
                      >
                        Inscrito <CheckCircle2 className="ml-1.5 h-4 w-4" />
                      </Button>
                    ) : (
                      <Button
                        onClick={() => setRegisteringRetreat(retreat)}
                        className="mt-3 w-full cursor-pointer rounded-xl font-bold"
                      >
                        Inscrever-se
                      </Button>
                    )}
                  </CardFooter>
                </Card>
              )
            })}
          </div>
        )}
      </div>
    </div>
  )
}
