import { useState, useEffect, useRef } from "react"
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogDescription,
  DialogFooter,
} from "@/components/ui/dialog"
import { Button } from "@/components/ui/button"
import {
  Loader2,
  UserIcon,
  PhoneIcon,
  MapPinIcon,
  ShieldIcon,
  CheckCircle2Icon,
  ArrowRightIcon,
  ArrowLeftIcon,
  CheckIcon,
} from "lucide-react"
import supabase from "@/lib/supabase"
import { isValidBrazilianPhone } from "@/lib/phoneUtils"
import { isValidCPF, formatCPF } from "@/lib/cpfUtils"
import { invalidateCurrentUserProfileCache } from "@/hooks/useCurrentUserProfile"
import {
  normalizeGender,
  normalizeMaritalStatus,
  normalizeEducationLevel,
  normalizeEmploymentStatus,
  normalizeHouseholdIncome,
  normalizeHousingStatus,
  normalizeDriversLicense,
} from "@/lib/profileNormalization"
import {
  type ProfileSectionKey,
  isSectionComplete,
} from "@/lib/profile-config"
import {
  PersonalFormSection,
  ContactFormSection,
  AddressFormSection,
  SocioEconomicFormSection,
} from "./forms"
import { toast } from "sonner"
import { cn } from "@/lib/utils"

interface StepConfig {
  key: ProfileSectionKey
  label: string
  shortLabel: string
  description: string
  icon: typeof UserIcon
}

const STEPS: StepConfig[] = [
  {
    key: "personal",
    label: "Dados Pessoais",
    shortLabel: "Pessoal",
    description: "Nome completo, CPF, data de nascimento, gênero e estado civil.",
    icon: UserIcon,
  },
  {
    key: "contact",
    label: "Informações de Contato",
    shortLabel: "Contato",
    description: "Telefone celular / WhatsApp para comunhão e avisos.",
    icon: PhoneIcon,
  },
  {
    key: "address",
    label: "Endereço Residencial",
    shortLabel: "Endereço",
    description: "Localização de moradia para visitas e integração nos grupos.",
    icon: MapPinIcon,
  },
  {
    key: "socio",
    label: "Informações Socioeconômicas",
    shortLabel: "Socioeconômico",
    description: "Profissão, escolaridade, moradia e perfil de apoio mútuo.",
    icon: ShieldIcon,
  },
]

export interface CompleteProfileDialogProps {
  open: boolean
  onOpenChange: (open: boolean) => void
  profile: any
  singleSection?: ProfileSectionKey
  onSuccess: () => Promise<void>
}

export function CompleteProfileDialog({
  open,
  onOpenChange,
  profile,
  singleSection,
  onSuccess,
}: CompleteProfileDialogProps) {
  const isSingleSectionMode = !!singleSection
  const [currentStepIndex, setCurrentStepIndex] = useState(0)
  const [saving, setSaving] = useState(false)
  const [errors, setErrors] = useState<Record<string, string>>({})
  const hasInitializedRef = useRef(false)

  // Form State
  const [formData, setFormData] = useState({
    // Pessoal
    full_name: "",
    cpf: "",
    birth_date: "",
    gender: "masculino",
    marital_status: "solteiro",
    // Contato
    phone: "",
    // Endereço
    address_zip_code: "",
    address_street: "",
    address_number: "",
    address_neighborhood: "",
    address_city: "Belo Horizonte",
    address_state: "MG",
    address_complement: "",
    // Socioeconômico
    occupation: "",
    education_level: "Médio Completo",
    employment_status: "CLT",
    household_income: "1 a 3 SM",
    dependents_count: 0,
    housing_status: "Própria",
    drivers_license: "Não possui",
  })

  // Reset initialization flag when dialog closes
  useEffect(() => {
    if (!open) {
      hasInitializedRef.current = false
    }
  }, [open])

  // Initialize form values from profile ONLY ONCE when dialog opens or when singleSection changes
  useEffect(() => {
    if (open && profile && !hasInitializedRef.current) {
      setFormData({
        full_name: profile.full_name || "",
        cpf: profile.cpf ? formatCPF(profile.cpf) : "",
        birth_date: profile.birth_date || "",
        gender: normalizeGender(profile.gender),
        marital_status: normalizeMaritalStatus(profile.marital_status),
        phone: profile.phone || "",
        address_zip_code: profile.address_zip_code || "",
        address_street: profile.address_street || "",
        address_number: profile.address_number || "",
        address_neighborhood: profile.address_neighborhood || "",
        address_city: profile.address_city || "Belo Horizonte",
        address_state: profile.address_state || "MG",
        address_complement: profile.address_complement || "",
        occupation: profile.occupation || "",
        education_level: normalizeEducationLevel(profile.education_level),
        employment_status: normalizeEmploymentStatus(profile.employment_status),
        household_income: normalizeHouseholdIncome(profile.household_income),
        dependents_count: profile.dependents_count || 0,
        housing_status: normalizeHousingStatus(profile.housing_status),
        drivers_license: normalizeDriversLicense(profile.drivers_license),
      })
      setErrors({})

      if (singleSection) {
        const foundIndex = STEPS.findIndex((s) => s.key === singleSection)
        if (foundIndex >= 0) setCurrentStepIndex(foundIndex)
      } else {
        // Modo incremental de completude obrigatória: começa do primeiro passo (passando por todas as informações)
        setCurrentStepIndex(0)
      }

      hasInitializedRef.current = true
    }
  }, [open, profile, singleSection])

  // Field change handlers
  const handleFieldChange = (field: string, value: any) => {
    setFormData((prev) => ({ ...prev, [field]: value }))
    if (errors[field]) {
      setErrors((prev) => {
        const next = { ...prev }
        delete next[field]
        return next
      })
    }
  }

  const handleBulkChange = (updates: Record<string, any>) => {
    setFormData((prev) => ({ ...prev, ...updates }))
  }

  const currentStep = STEPS[currentStepIndex] || STEPS[0]
  const isFirstStep = currentStepIndex === 0
  const isLastStep = currentStepIndex === STEPS.length - 1

  const validateSection = (sectionKey: ProfileSectionKey): boolean => {
    const newErrors: Record<string, string> = {}

    if (sectionKey === "personal") {
      if (!formData.full_name || formData.full_name.trim().length < 3) {
        newErrors.full_name = "Informe seu nome completo."
      }
      if (!formData.cpf || formData.cpf.trim() === "") {
        newErrors.cpf = "CPF é obrigatório."
      } else if (!isValidCPF(formData.cpf)) {
        newErrors.cpf = "Informe um CPF válido."
      }
      if (!formData.birth_date) {
        newErrors.birth_date = "Data de nascimento é obrigatória."
      }
      if (!formData.gender) {
        newErrors.gender = "Selecione o gênero."
      }
      if (!formData.marital_status) {
        newErrors.marital_status = "Selecione o estado civil."
      }
    } else if (sectionKey === "contact") {
      if (!formData.phone || formData.phone.trim() === "") {
        newErrors.phone = "Telefone é obrigatório."
      } else if (!isValidBrazilianPhone(formData.phone)) {
        newErrors.phone = "Informe um celular válido com DDD."
      }
    } else if (sectionKey === "address") {
      if (!formData.address_zip_code || formData.address_zip_code.trim() === "") {
        newErrors.address_zip_code = "CEP é obrigatório."
      }
      if (!formData.address_street || formData.address_street.trim() === "") {
        newErrors.address_street = "Rua é obrigatória."
      }
      if (!formData.address_number || formData.address_number.trim() === "") {
        newErrors.address_number = "Número é obrigatório."
      }
      if (!formData.address_neighborhood || formData.address_neighborhood.trim() === "") {
        newErrors.address_neighborhood = "Bairro é obrigatório."
      }
      if (!formData.address_city || formData.address_city.trim() === "") {
        newErrors.address_city = "Cidade é obrigatória."
      }
      if (!formData.address_state || formData.address_state.trim() === "") {
        newErrors.address_state = "Estado é obrigatório."
      }
    } else if (sectionKey === "socio") {
      if (!formData.occupation || formData.occupation.trim().length < 2) {
        newErrors.occupation = "Informe sua profissão."
      }
    }

    setErrors(newErrors)
    return Object.keys(newErrors).length === 0
  }

  // Obter atualizações para salvar de acordo com a seção atual
  const getSectionUpdates = (sectionKey: ProfileSectionKey): Record<string, unknown> => {
    switch (sectionKey) {
      case "personal":
        return {
          full_name: formData.full_name.trim(),
          cpf: formatCPF(formData.cpf.trim()),
          birth_date: formData.birth_date,
          gender: formData.gender,
          marital_status: formData.marital_status,
        }
      case "contact":
        return {
          phone: formData.phone,
        }
      case "address":
        return {
          address_zip_code: formData.address_zip_code,
          address_street: formData.address_street,
          address_number: formData.address_number,
          address_neighborhood: formData.address_neighborhood,
          address_city: formData.address_city,
          address_state: formData.address_state,
          address_complement: formData.address_complement,
        }
      case "socio":
        return {
          occupation: formData.occupation,
          education_level: formData.education_level,
          employment_status: formData.employment_status,
          household_income: formData.household_income,
          dependents_count: formData.dependents_count,
          housing_status: formData.housing_status,
          drivers_license: formData.drivers_license,
        }
    }
  }

  // Submissão incremental de cada passo
  const handleStepSubmit = async () => {
    const sectionKey = currentStep.key

    if (!validateSection(sectionKey)) {
      toast.error("Por favor, preencha todos os campos obrigatórios deste passo.")
      return
    }

    try {
      setSaving(true)

      let userId = profile?.user_id
      if (!userId) {
        const {
          data: { session },
        } = await supabase.auth.getSession()
        userId = session?.user?.id
      }
      if (!userId) throw new Error("Usuário não autenticado.")

      const updates = getSectionUpdates(sectionKey)

      const { error } = await supabase
        .from("profiles")
        .update(updates)
        .eq("user_id", userId)

      if (error) {
        if (error.code === "23505" || error.message?.toLowerCase().includes("cpf")) {
          setErrors((prev) => ({
            ...prev,
            cpf: "Este CPF já está cadastrado em outra conta.",
          }))
          toast.error("Este CPF já está cadastrado em outra conta.")
          return
        }
        throw error
      }

      if (sectionKey === "personal") {
        invalidateCurrentUserProfileCache()
        if (formData.full_name?.trim()) {
          try {
            await supabase.auth.updateUser({
              data: { full_name: formData.full_name.trim() },
            })
          } catch (authErr) {
            console.warn("Não foi possível sincronizar o nome no auth metadata:", authErr)
          }
        }
      }

      if (isSingleSectionMode) {
        toast.success("Informações atualizadas com sucesso!")
        await onSuccess()
        onOpenChange(false)
        return
      }

      if (isLastStep) {
        toast.success("Cadastro completo concluído com sucesso!")
        await onSuccess()
        onOpenChange(false)
      } else {
        // Transição instantânea e automática para a próxima categoria
        setErrors({})
        setCurrentStepIndex((prev) => prev + 1)
        toast.success(`${currentStep.shortLabel} salvo com sucesso!`)
      }
    } catch (err) {
      console.error("Erro ao salvar seção:", err)
      toast.error("Erro ao salvar as informações. Tente novamente.")
    } finally {
      setSaving(false)
    }
  }

  const handlePrevStep = () => {
    if (currentStepIndex > 0) {
      setErrors({})
      setCurrentStepIndex((prev) => prev - 1)
    }
  }

  const CurrentIcon = currentStep.icon

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent
        size="lg"
        showCloseButton={isSingleSectionMode}
        onPointerDownOutside={(e) => {
          if (!isSingleSectionMode) e.preventDefault()
        }}
        onEscapeKeyDown={(e) => {
          if (!isSingleSectionMode) e.preventDefault()
        }}
        className="max-h-[92dvh] flex flex-col p-0 overflow-hidden rounded-3xl border-border/60 bg-card/95 backdrop-blur-xl"
      >
        {/* Header fixo com Stepper Incremental */}
        <div className="shrink-0 p-5 pb-3 border-b border-border/40 space-y-3">
          <DialogHeader className="text-left space-y-1">
            <div className="flex items-center justify-between gap-2">
              <div className="flex items-center gap-2 text-primary">
                <CheckCircle2Icon className="size-5 shrink-0" />
                <DialogTitle className="text-xl sm:text-2xl font-bold tracking-tight">
                  {isSingleSectionMode ? `Editar ${currentStep.label}` : "Dados Obrigatórios de Cadastro"}
                </DialogTitle>
              </div>

              {!isSingleSectionMode && (
                <div className="inline-flex items-center gap-1.5 rounded-full border border-primary/20 bg-primary/10 px-3 py-1 text-xs font-semibold text-primary">
                  <span>Passo {currentStepIndex + 1} de {STEPS.length}</span>
                </div>
              )}
            </div>

            <DialogDescription className="text-xs sm:text-sm text-muted-foreground">
              {isSingleSectionMode
                ? currentStep.description
                : `Preenchimento incremental obrigatório. Categoria ${currentStepIndex + 1}: ${currentStep.label}.`}
            </DialogDescription>
          </DialogHeader>

          {/* Stepper visual (Passos 1 a 4) - Sem opção de pular */}
          {!isSingleSectionMode && (
            <div className="pt-1">
              <div className="grid grid-cols-4 gap-2">
                {STEPS.map((step, idx) => {
                  const isCompleted = idx < currentStepIndex
                  const isCurrent = idx === currentStepIndex
                  const StepIcon = step.icon

                  return (
                    <div
                      key={step.key}
                      className={cn(
                        "flex flex-col items-center gap-1.5 p-2 rounded-xl text-center transition-all select-none",
                        isCurrent
                          ? "bg-primary/15 text-primary border border-primary/30 font-semibold"
                          : isCompleted
                          ? "bg-emerald-500/10 text-emerald-600 dark:text-emerald-400 border border-emerald-500/20 font-medium"
                          : "bg-muted/30 text-muted-foreground border border-border/30 opacity-60"
                      )}
                    >
                      <div className="flex items-center gap-1 text-xs font-semibold">
                        {isCompleted ? (
                          <CheckIcon className="size-3.5 text-emerald-600 dark:text-emerald-400" />
                        ) : (
                          <StepIcon className="size-3.5 shrink-0" />
                        )}
                        <span className="hidden sm:inline">{step.shortLabel}</span>
                        <span className="sm:hidden">{idx + 1}</span>
                      </div>
                      <div className="w-full h-1 rounded-full bg-border/40 overflow-hidden">
                        <div
                          className={cn(
                            "h-full transition-all duration-300",
                            isCompleted
                              ? "w-full bg-emerald-500"
                              : isCurrent
                              ? "w-full bg-primary"
                              : "w-0"
                          )}
                        />
                      </div>
                    </div>
                  )
                })}
              </div>
            </div>
          )}
        </div>

        {/* Corpo do formulário: Uma categoria de cada vez */}
        <div className="flex-1 overflow-y-auto p-4 sm:p-6 space-y-4">
          <div className="flex items-center justify-between rounded-2xl border border-border/40 bg-muted/20 p-3.5">
            <div className="flex items-center gap-2.5">
              <CurrentIcon className="size-5 text-primary shrink-0" />
              <div>
                <h3 className="font-semibold text-sm text-foreground">
                  {isSingleSectionMode ? currentStep.label : `Passo ${currentStepIndex + 1}: ${currentStep.label}`}
                </h3>
                <p className="text-xs text-muted-foreground">{currentStep.description}</p>
              </div>
            </div>
            {isSectionComplete(formData, currentStep.key) && (
              <span className="inline-flex items-center gap-1 rounded-full bg-emerald-500/10 px-2.5 py-1 text-xs font-bold text-emerald-600 dark:text-emerald-400">
                <CheckIcon className="size-3.5" />
                Preenchido
              </span>
            )}
          </div>

          <div className="rounded-2xl border border-border/50 bg-card p-4 sm:p-5">
            {currentStep.key === "personal" && (
              <PersonalFormSection
                values={{
                  full_name: formData.full_name,
                  cpf: formData.cpf,
                  birth_date: formData.birth_date,
                  gender: formData.gender,
                  marital_status: formData.marital_status,
                }}
                onChange={(field, val) => handleFieldChange(field, val)}
                errors={errors}
                disabled={saving}
                showRequiredMarks
              />
            )}

            {currentStep.key === "contact" && (
              <ContactFormSection
                values={{ phone: formData.phone }}
                onChange={(field, val) => handleFieldChange(field, val)}
                errors={errors}
                disabled={saving}
                showRequiredMarks
              />
            )}

            {currentStep.key === "address" && (
              <AddressFormSection
                values={{
                  address_zip_code: formData.address_zip_code,
                  address_street: formData.address_street,
                  address_number: formData.address_number,
                  address_neighborhood: formData.address_neighborhood,
                  address_complement: formData.address_complement,
                  address_city: formData.address_city,
                  address_state: formData.address_state,
                }}
                onChange={(field, val) => handleFieldChange(field, val)}
                onBulkChange={handleBulkChange}
                errors={errors}
                disabled={saving}
                showRequiredMarks
              />
            )}

            {currentStep.key === "socio" && (
              <SocioEconomicFormSection
                values={{
                  occupation: formData.occupation,
                  education_level: formData.education_level,
                  employment_status: formData.employment_status,
                  housing_status: formData.housing_status,
                  household_income: formData.household_income,
                  dependents_count: formData.dependents_count,
                  drivers_license: formData.drivers_license,
                }}
                onChange={(field, val) => handleFieldChange(field, val)}
                errors={errors}
                disabled={saving}
                showRequiredMarks
              />
            )}
          </div>
        </div>

        {/* Footer com controle estrito: Voltar e Avançar/Concluir (Sem "Preencher mais tarde") */}
        <DialogFooter className="shrink-0 p-4 sm:p-5 border-t border-border/40 flex-row items-center justify-between gap-3 bg-card/60">
          {isSingleSectionMode ? (
            <>
              <Button
                variant="outline"
                onClick={() => onOpenChange(false)}
                disabled={saving}
                className="min-h-[44px] rounded-xl"
              >
                Cancelar
              </Button>
              <Button
                onClick={handleStepSubmit}
                disabled={saving}
                className="min-h-[44px] gap-2 rounded-xl font-bold shadow-lg shadow-primary/20"
              >
                {saving ? (
                  <>
                    <Loader2 className="size-4 animate-spin" />
                    Salvando...
                  </>
                ) : (
                  <>
                    <CheckCircle2Icon className="size-4" />
                    Salvar Alterações
                  </>
                )}
              </Button>
            </>
          ) : (
            <>
              {!isFirstStep ? (
                <Button
                  variant="outline"
                  onClick={handlePrevStep}
                  disabled={saving}
                  className="min-h-[44px] gap-1.5 rounded-xl font-medium"
                >
                  <ArrowLeftIcon className="size-4" />
                  Voltar
                </Button>
              ) : (
                <div className="text-xs text-muted-foreground italic px-2">
                  Passo 1 de 4 obrigatório
                </div>
              )}

              <Button
                onClick={handleStepSubmit}
                disabled={saving}
                className="min-h-[44px] gap-2 rounded-xl font-bold shadow-lg shadow-primary/20 ml-auto"
              >
                {saving ? (
                  <>
                    <Loader2 className="size-4 animate-spin" />
                    Salvando...
                  </>
                ) : isLastStep ? (
                  <>
                    <CheckCircle2Icon className="size-4" />
                    Concluir Cadastro
                  </>
                ) : (
                  <>
                    Salvar e Continuar
                    <ArrowRightIcon className="size-4" />
                  </>
                )}
              </Button>
            </>
          )}
        </DialogFooter>
      </DialogContent>
    </Dialog>
  )
}
