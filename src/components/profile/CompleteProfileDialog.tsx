import { useState, useEffect } from "react"
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogDescription,
  DialogFooter,
} from "@/components/ui/dialog"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Field, FieldLabel, FieldError } from "@/components/ui/field"
import {
  InputGroup,
  InputGroupAddon,
  InputGroupInput,
} from "@/components/ui/input-group"
import { CardSelector, CardSelectorItem } from "@/components/ui/card-selector"
import {
  Loader2,
  SearchIcon,
  UserIcon,
  PhoneIcon,
  MapPinIcon,
  ShieldIcon,
  CheckCircle2Icon,
} from "lucide-react"
import supabase from "@/lib/supabase"
import { formatPhone, isValidBrazilianPhone } from "@/lib/phoneUtils"
import {
  normalizeGender,
  normalizeMaritalStatus,
  normalizeEducationLevel,
  normalizeEmploymentStatus,
  normalizeHouseholdIncome,
  normalizeHousingStatus,
  normalizeDriversLicense,
} from "@/lib/profileNormalization"
import { getMissingProfileFields } from "@/lib/profile-config"
import { toast } from "sonner"

export interface CompleteProfileDialogProps {
  open: boolean
  onOpenChange: (open: boolean) => void
  profile: Record<string, unknown>
  onSuccess: () => Promise<void>
}

export function CompleteProfileDialog({
  open,
  onOpenChange,
  profile,
  onSuccess,
}: CompleteProfileDialogProps) {
  const [saving, setSaving] = useState(false)
  const [searchingCep, setSearchingCep] = useState(false)
  const [errors, setErrors] = useState<Record<string, string>>({})

  // Form State
  const [formData, setFormData] = useState({
    // Pessoal
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

  // Detect which categories are missing
  const missing = getMissingProfileFields(profile)

  const hasMissingPersonal = missing.some((f) =>
    ["birth_date", "gender", "marital_status"].includes(f)
  )
  const hasMissingContact = missing.includes("phone")
  const hasMissingAddress = missing.some((f) =>
    [
      "address_street",
      "address_number",
      "address_neighborhood",
      "address_city",
      "address_state",
      "address_zip_code",
    ].includes(f)
  )
  const hasMissingSocio = missing.some((f) =>
    [
      "occupation",
      "education_level",
      "employment_status",
      "household_income",
      "dependents_count",
      "housing_status",
      "drivers_license",
    ].includes(f)
  )

  // Initialize form values from profile (using normalizers)
  useEffect(() => {
    if (profile && open) {
      setFormData({
        birth_date: profile.birth_date || "",
        gender: normalizeGender(profile.gender),
        marital_status: normalizeMaritalStatus(profile.marital_status),
        phone: formatPhone(profile.phone || ""),
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
    }
  }, [profile, open])

  // ViaCEP Lookup
  const handleZipChange = async (cepValue: string) => {
    setFormData((prev) => ({ ...prev, address_zip_code: cepValue }))
    const cleanCep = cepValue.replace(/\D/g, "")
    if (cleanCep.length === 8) {
      setSearchingCep(true)
      try {
        const response = await fetch(`https://viacep.com.br/ws/${cleanCep}/json/`)
        const data = await response.json()
        if (!data.erro) {
          setFormData((prev) => ({
            ...prev,
            address_street: data.logradouro || prev.address_street,
            address_neighborhood: data.bairro || prev.address_neighborhood,
            address_city: data.localidade || prev.address_city,
            address_state: data.uf || prev.address_state,
          }))
          toast.success("Endereço preenchido automaticamente!")
        } else {
          toast.error("CEP não encontrado.")
        }
      } catch (err) {
        console.error("Erro ao buscar CEP:", err)
      } finally {
        setSearchingCep(false)
      }
    }
  }

  const validate = () => {
    const errs: Record<string, string> = {}

    if (hasMissingPersonal) {
      if (!formData.birth_date) {
        errs.birth_date = "Data de nascimento é obrigatória."
      }
      if (!formData.gender) {
        errs.gender = "Selecione o gênero."
      }
      if (!formData.marital_status) {
        errs.marital_status = "Selecione o estado civil."
      }
    }

    if (hasMissingContact || formData.phone) {
      if (!formData.phone) {
        errs.phone = "Telefone é obrigatório."
      } else if (!isValidBrazilianPhone(formData.phone)) {
        errs.phone = "Informe um número de telefone celular válido com DDD."
      }
    }

    if (hasMissingAddress) {
      if (!formData.address_street) errs.address_street = "Rua é obrigatória."
      if (!formData.address_number) errs.address_number = "Número é obrigatório."
      if (!formData.address_neighborhood) errs.address_neighborhood = "Bairro é obrigatório."
      if (!formData.address_city) errs.address_city = "Cidade é obrigatória."
      if (!formData.address_state) errs.address_state = "Estado é obrigatório."
      if (!formData.address_zip_code) errs.address_zip_code = "CEP é obrigatório."
    }

    if (hasMissingSocio) {
      if (!formData.occupation || formData.occupation.trim().length < 2) {
        errs.occupation = "Informe sua profissão."
      }
    }

    setErrors(errs)
    return Object.keys(errs).length === 0
  }

  const handleSave = async () => {
    if (!validate()) {
      toast.error("Por favor, preencha todos os campos obrigatórios.")
      return
    }

    try {
      setSaving(true)
      const {
        data: { session },
      } = await supabase.auth.getSession()
      if (!session?.user) throw new Error("Usuário não autenticado.")

      const updates: Record<string, unknown> = {
        // Dados Pessoais
        birth_date: formData.birth_date,
        gender: formData.gender,
        marital_status: formData.marital_status,
        // Contato
        phone: formData.phone,
        // Endereço
        address_zip_code: formData.address_zip_code,
        address_street: formData.address_street,
        address_number: formData.address_number,
        address_neighborhood: formData.address_neighborhood,
        address_city: formData.address_city,
        address_state: formData.address_state,
        address_complement: formData.address_complement,
        // Socioeconômico
        occupation: formData.occupation,
        education_level: formData.education_level,
        employment_status: formData.employment_status,
        household_income: formData.household_income,
        dependents_count: formData.dependents_count,
        housing_status: formData.housing_status,
        drivers_license: formData.drivers_license,
      }

      const { error } = await supabase
        .from("profiles")
        .update(updates)
        .eq("user_id", session.user.id)

      if (error) throw error

      toast.success("Cadastro completado com sucesso! Seja bem-vindo(a).")
      await onSuccess()
      onOpenChange(false)
    } catch (err) {
      console.error("Erro ao salvar cadastro completo:", err)
      toast.error("Erro ao salvar as informações. Tente novamente.")
    } finally {
      setSaving(false)
    }
  }

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="max-h-[90vh] w-full max-w-2xl overflow-y-auto rounded-3xl border-border/60 bg-card/95 p-4 backdrop-blur-xl sm:p-6">
        <DialogHeader className="text-left space-y-1.5 pb-2 border-b border-border/40">
          <div className="flex items-center gap-2 text-primary">
            <CheckCircle2Icon className="size-5 shrink-0" />
            <DialogTitle className="text-xl sm:text-2xl font-bold">
              Completar Informações de Cadastro
            </DialogTitle>
          </div>
          <DialogDescription className="text-xs sm:text-sm text-muted-foreground">
            Para desfrutar plenamente da comunhão e das ferramentas da Igreja em BH, precisamos que você complete os dados obrigatórios pendentes.
          </DialogDescription>
        </DialogHeader>

        <div className="space-y-6 py-4">
          {/* Seção: Dados Pessoais */}
          <div className="space-y-3 rounded-2xl border border-border/50 bg-muted/20 p-4">
            <div className="flex items-center gap-2 text-foreground font-semibold text-sm">
              <UserIcon className="size-4 text-primary" />
              <span>Dados Pessoais</span>
              {hasMissingPersonal && (
                <span className="ml-auto rounded-full bg-amber-500/10 px-2 py-0.5 text-[10px] font-bold text-amber-600 dark:text-amber-400">
                  Pendente
                </span>
              )}
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <Field data-invalid={!!errors.birth_date}>
                <FieldLabel htmlFor="complete-birthdate">Data de Nascimento*</FieldLabel>
                <Input
                  id="complete-birthdate"
                  type="date"
                  value={formData.birth_date}
                  onChange={(e) =>
                    setFormData((prev) => ({ ...prev, birth_date: e.target.value }))
                  }
                  className="min-h-[44px] rounded-xl"
                />
                {errors.birth_date && <FieldError>{errors.birth_date}</FieldError>}
              </Field>

              <Field data-invalid={!!errors.gender}>
                <FieldLabel>Gênero*</FieldLabel>
                <CardSelector
                  value={formData.gender}
                  onValueChange={(val) =>
                    setFormData((prev) => ({ ...prev, gender: normalizeGender(val) }))
                  }
                  columns={2}
                >
                  <CardSelectorItem value="masculino" label="Masculino" />
                  <CardSelectorItem value="feminino" label="Feminino" />
                </CardSelector>
                {errors.gender && <FieldError>{errors.gender}</FieldError>}
              </Field>

              <div className="sm:col-span-2">
                <Field data-invalid={!!errors.marital_status}>
                  <FieldLabel>Estado Civil*</FieldLabel>
                  <CardSelector
                    value={formData.marital_status}
                    onValueChange={(val) =>
                      setFormData((prev) => ({ ...prev, marital_status: normalizeMaritalStatus(val) }))
                    }
                    columns={2}
                    className="sm:grid-cols-4"
                  >
                    <CardSelectorItem value="solteiro" label="Solteiro(a)" />
                    <CardSelectorItem value="casado" label="Casado(a)" />
                    <CardSelectorItem value="divorciado" label="Divorciado(a)" />
                    <CardSelectorItem value="viuvo" label="Viúvo(a)" />
                  </CardSelector>
                  {errors.marital_status && <FieldError>{errors.marital_status}</FieldError>}
                </Field>
              </div>
            </div>
          </div>

          {/* Seção: Contato */}
          <div className="space-y-3 rounded-2xl border border-border/50 bg-muted/20 p-4">
            <div className="flex items-center gap-2 text-foreground font-semibold text-sm">
              <PhoneIcon className="size-4 text-primary" />
              <span>Contato</span>
              {hasMissingContact && (
                <span className="ml-auto rounded-full bg-amber-500/10 px-2 py-0.5 text-[10px] font-bold text-amber-600 dark:text-amber-400">
                  Pendente
                </span>
              )}
            </div>

            <Field data-invalid={!!errors.phone}>
              <FieldLabel htmlFor="complete-phone">Telefone Celular / WhatsApp*</FieldLabel>
              <Input
                id="complete-phone"
                value={formData.phone}
                onChange={(e) =>
                  setFormData((prev) => ({
                    ...prev,
                    phone: formatPhone(e.target.value),
                  }))
                }
                placeholder="(31) 98888-7777"
                maxLength={20}
                className="min-h-[44px] rounded-xl"
              />
              {errors.phone && <FieldError>{errors.phone}</FieldError>}
            </Field>
          </div>

          {/* Seção: Endereço */}
          <div className="space-y-3 rounded-2xl border border-border/50 bg-muted/20 p-4">
            <div className="flex items-center gap-2 text-foreground font-semibold text-sm">
              <MapPinIcon className="size-4 text-primary" />
              <span>Endereço Residencial</span>
              {hasMissingAddress && (
                <span className="ml-auto rounded-full bg-amber-500/10 px-2 py-0.5 text-[10px] font-bold text-amber-600 dark:text-amber-400">
                  Pendente
                </span>
              )}
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
              <Field data-invalid={!!errors.address_zip_code}>
                <FieldLabel htmlFor="complete-cep">CEP*</FieldLabel>
                <InputGroup>
                  <InputGroupInput
                    id="complete-cep"
                    value={formData.address_zip_code}
                    onChange={(e) => handleZipChange(e.target.value)}
                    placeholder="00000-000"
                    maxLength={9}
                    className="min-h-[44px] rounded-xl"
                  />
                  <InputGroupAddon align="inline-end">
                    {searchingCep ? (
                      <Loader2 className="h-4 w-4 animate-spin text-muted-foreground" />
                    ) : (
                      <SearchIcon className="h-4 w-4 text-muted-foreground" />
                    )}
                  </InputGroupAddon>
                </InputGroup>
                {errors.address_zip_code && (
                  <FieldError>{errors.address_zip_code}</FieldError>
                )}
              </Field>

              <div className="sm:col-span-2">
                <Field data-invalid={!!errors.address_street}>
                  <FieldLabel htmlFor="complete-street">Rua / Logradouro*</FieldLabel>
                  <Input
                    id="complete-street"
                    value={formData.address_street}
                    onChange={(e) =>
                      setFormData((prev) => ({
                        ...prev,
                        address_street: e.target.value,
                      }))
                    }
                    placeholder="Rua ou Avenida"
                    className="min-h-[44px] rounded-xl"
                  />
                  {errors.address_street && (
                    <FieldError>{errors.address_street}</FieldError>
                  )}
                </Field>
              </div>

              <Field data-invalid={!!errors.address_number}>
                <FieldLabel htmlFor="complete-number">Número*</FieldLabel>
                <Input
                  id="complete-number"
                  value={formData.address_number}
                  onChange={(e) =>
                    setFormData((prev) => ({
                      ...prev,
                      address_number: e.target.value,
                    }))
                  }
                  placeholder="123"
                  className="min-h-[44px] rounded-xl"
                />
                {errors.address_number && (
                  <FieldError>{errors.address_number}</FieldError>
                )}
              </Field>

              <Field data-invalid={!!errors.address_neighborhood}>
                <FieldLabel htmlFor="complete-neighborhood">Bairro*</FieldLabel>
                <Input
                  id="complete-neighborhood"
                  value={formData.address_neighborhood}
                  onChange={(e) =>
                    setFormData((prev) => ({
                      ...prev,
                      address_neighborhood: e.target.value,
                    }))
                  }
                  placeholder="Bairro"
                  className="min-h-[44px] rounded-xl"
                />
                {errors.address_neighborhood && (
                  <FieldError>{errors.address_neighborhood}</FieldError>
                )}
              </Field>

              <Field>
                <FieldLabel htmlFor="complete-complement">Complemento</FieldLabel>
                <Input
                  id="complete-complement"
                  value={formData.address_complement}
                  onChange={(e) =>
                    setFormData((prev) => ({
                      ...prev,
                      address_complement: e.target.value,
                    }))
                  }
                  placeholder="Apto, Bloco..."
                  className="min-h-[44px] rounded-xl"
                />
              </Field>

              <Field data-invalid={!!errors.address_city}>
                <FieldLabel htmlFor="complete-city">Cidade*</FieldLabel>
                <Input
                  id="complete-city"
                  value={formData.address_city}
                  onChange={(e) =>
                    setFormData((prev) => ({
                      ...prev,
                      address_city: e.target.value,
                    }))
                  }
                  className="min-h-[44px] rounded-xl"
                />
                {errors.address_city && <FieldError>{errors.address_city}</FieldError>}
              </Field>

              <Field data-invalid={!!errors.address_state}>
                <FieldLabel htmlFor="complete-state">Estado*</FieldLabel>
                <Input
                  id="complete-state"
                  value={formData.address_state}
                  onChange={(e) =>
                    setFormData((prev) => ({
                      ...prev,
                      address_state: e.target.value.toUpperCase(),
                    }))
                  }
                  maxLength={2}
                  className="min-h-[44px] rounded-xl"
                />
                {errors.address_state && (
                  <FieldError>{errors.address_state}</FieldError>
                )}
              </Field>
            </div>
          </div>

          {/* Seção: Informações Socioeconômicas */}
          <div className="space-y-4 rounded-2xl border border-border/50 bg-muted/20 p-4">
            <div className="flex items-center gap-2 text-foreground font-semibold text-sm">
              <ShieldIcon className="size-4 text-primary" />
              <span>Informações Socioeconômicas</span>
              {hasMissingSocio && (
                <span className="ml-auto rounded-full bg-amber-500/10 px-2 py-0.5 text-[10px] font-bold text-amber-600 dark:text-amber-400">
                  Pendente
                </span>
              )}
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <Field data-invalid={!!errors.occupation}>
                <FieldLabel htmlFor="complete-occupation">Profissão*</FieldLabel>
                <Input
                  id="complete-occupation"
                  value={formData.occupation}
                  onChange={(e) =>
                    setFormData((prev) => ({
                      ...prev,
                      occupation: e.target.value,
                    }))
                  }
                  placeholder="Sua profissão"
                  className="min-h-[44px] rounded-xl"
                />
                {errors.occupation && <FieldError>{errors.occupation}</FieldError>}
              </Field>

              <Field>
                <FieldLabel htmlFor="complete-dependents">Número de Dependentes*</FieldLabel>
                <Input
                  id="complete-dependents"
                  type="number"
                  min="0"
                  value={formData.dependents_count}
                  onChange={(e) =>
                    setFormData((prev) => ({
                      ...prev,
                      dependents_count: parseInt(e.target.value) || 0,
                    }))
                  }
                  className="min-h-[44px] rounded-xl"
                />
              </Field>

              <div className="sm:col-span-2 space-y-1.5">
                <FieldLabel>Escolaridade*</FieldLabel>
                <CardSelector
                  value={formData.education_level}
                  onValueChange={(val) =>
                    setFormData((prev) => ({ ...prev, education_level: val }))
                  }
                  columns={1}
                >
                  {[
                    "Fundamental Incompleto",
                    "Fundamental Completo",
                    "Médio Incompleto",
                    "Médio Completo",
                    "Superior Incompleto",
                    "Superior Completo",
                    "Pós-graduação",
                  ].map((opt) => (
                    <CardSelectorItem key={opt} value={opt} label={opt} />
                  ))}
                </CardSelector>
              </div>

              <div className="sm:col-span-2 space-y-1.5">
                <FieldLabel>Vínculo Empregatício*</FieldLabel>
                <CardSelector
                  value={formData.employment_status}
                  onValueChange={(val) =>
                    setFormData((prev) => ({ ...prev, employment_status: val }))
                  }
                  columns={1}
                  className="sm:grid-cols-2"
                >
                  {[
                    "CLT",
                    "Autônomo/PJ",
                    "Empreendedor",
                    "Desempregado",
                    "Aposentado",
                    "Estudante",
                  ].map((opt) => (
                    <CardSelectorItem key={opt} value={opt} label={opt} />
                  ))}
                </CardSelector>
              </div>

              <div className="space-y-1.5">
                <FieldLabel>Situação de Moradia*</FieldLabel>
                <CardSelector
                  value={formData.housing_status}
                  onValueChange={(val) =>
                    setFormData((prev) => ({ ...prev, housing_status: val }))
                  }
                  columns={1}
                >
                  {["Própria", "Alugada", "Cedida/Parentes", "Financiada"].map(
                    (opt) => (
                      <CardSelectorItem key={opt} value={opt} label={opt} />
                    )
                  )}
                </CardSelector>
              </div>

              <div className="space-y-1.5">
                <FieldLabel>Renda Familiar*</FieldLabel>
                <CardSelector
                  value={formData.household_income}
                  onValueChange={(val) =>
                    setFormData((prev) => ({ ...prev, household_income: val }))
                  }
                  columns={1}
                >
                  {[
                    "Até 1 SM",
                    "1 a 3 SM",
                    "3 a 5 SM",
                    "Acima de 5 SM",
                    "Prefiro não informar",
                  ].map((opt) => (
                    <CardSelectorItem key={opt} value={opt} label={opt} />
                  ))}
                </CardSelector>
              </div>

              <div className="sm:col-span-2 space-y-1.5">
                <FieldLabel>Categoria CNH*</FieldLabel>
                <CardSelector
                  value={formData.drivers_license}
                  onValueChange={(val) =>
                    setFormData((prev) => ({ ...prev, drivers_license: val }))
                  }
                  columns={2}
                  className="sm:grid-cols-4"
                >
                  {["Não possui", "A", "B", "AB", "C", "D", "E"].map((opt) => (
                    <CardSelectorItem key={opt} value={opt} label={opt} />
                  ))}
                </CardSelector>
              </div>
            </div>
          </div>
        </div>

        <DialogFooter className="gap-2 sm:gap-0 pt-2 border-t border-border/40">
          <Button
            variant="outline"
            onClick={() => onOpenChange(false)}
            disabled={saving}
            className="min-h-[44px] rounded-xl"
          >
            Preencher Mais Tarde
          </Button>
          <Button
            onClick={handleSave}
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
                Salvar Informações
              </>
            )}
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  )
}
