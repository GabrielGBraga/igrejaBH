import { Input } from "@/components/ui/input"
import { Field, FieldLabel, FieldError } from "@/components/ui/field"
import { CardSelector, CardSelectorItem } from "@/components/ui/card-selector"
import {
  normalizeGender,
  normalizeMaritalStatus,
} from "@/lib/profileNormalization"
import { formatCPF } from "@/lib/cpfUtils"

export interface PersonalFormValues {
  full_name?: string | null
  cpf?: string | null
  birth_date?: string | null
  gender?: string | null
  marital_status?: string | null
}

export interface PersonalFormSectionProps {
  values: PersonalFormValues
  onChange: (field: keyof PersonalFormValues, value: string) => void
  errors?: Record<string, string>
  disabled?: boolean
  showRequiredMarks?: boolean
}

export function PersonalFormSection({
  values,
  onChange,
  errors = {},
  disabled = false,
  showRequiredMarks = false,
}: PersonalFormSectionProps) {
  const req = showRequiredMarks ? "*" : ""

  return (
    <div className="space-y-4 py-1">
      {/* Nome Completo */}
      <Field data-invalid={!!errors.full_name}>
        <FieldLabel htmlFor="personal-fullname" className="text-sm font-semibold text-foreground/90">
          Nome Completo{req}
        </FieldLabel>
        <Input
          id="personal-fullname"
          type="text"
          autoComplete="name"
          placeholder="Ex: João da Silva"
          value={values.full_name || ""}
          onChange={(e) => onChange("full_name", e.target.value)}
          disabled={disabled}
          className="min-h-[44px] rounded-xl border-border/60 bg-muted/20 text-sm focus-visible:ring-primary/20"
        />
        {errors.full_name && <FieldError>{errors.full_name}</FieldError>}
      </Field>

      {/* Grid responsivo: CPF e Data de Nascimento lado a lado no desktop, empilhado no mobile */}
      <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
        <Field data-invalid={!!errors.cpf}>
          <FieldLabel htmlFor="personal-cpf" className="text-sm font-semibold text-foreground/90">
            CPF{req}
          </FieldLabel>
          <Input
            id="personal-cpf"
            type="text"
            inputMode="numeric"
            placeholder="000.000.000-00"
            maxLength={14}
            value={values.cpf || ""}
            onChange={(e) => onChange("cpf", formatCPF(e.target.value))}
            disabled={disabled}
            className="min-h-[44px] rounded-xl border-border/60 bg-muted/20 font-mono text-sm focus-visible:ring-primary/20"
          />
          {errors.cpf && <FieldError>{errors.cpf}</FieldError>}
        </Field>

        <Field data-invalid={!!errors.birth_date}>
          <FieldLabel htmlFor="personal-birthdate" className="text-sm font-semibold text-foreground/90">
            Data de Nascimento{req}
          </FieldLabel>
          <Input
            id="personal-birthdate"
            type="date"
            value={values.birth_date || ""}
            onChange={(e) => onChange("birth_date", e.target.value)}
            disabled={disabled}
            className="min-h-[44px] rounded-xl border-border/60 bg-muted/20 text-sm focus-visible:ring-primary/20"
          />
          {errors.birth_date && <FieldError>{errors.birth_date}</FieldError>}
        </Field>
      </div>

      {/* Gênero */}
      <div className="space-y-2">
        <FieldLabel className="text-sm font-semibold text-foreground/90">
          Gênero{req}
        </FieldLabel>
        <CardSelector
          value={normalizeGender(values.gender || "masculino")}
          onValueChange={(val) => onChange("gender", normalizeGender(val))}
          columns={2}
          disabled={disabled}
        >
          <CardSelectorItem value="masculino" label="Masculino" />
          <CardSelectorItem value="feminino" label="Feminino" />
        </CardSelector>
        {errors.gender && <FieldError>{errors.gender}</FieldError>}
      </div>

      {/* Estado Civil */}
      <div className="space-y-2">
        <FieldLabel className="text-sm font-semibold text-foreground/90">
          Estado Civil{req}
        </FieldLabel>
        <CardSelector
          value={normalizeMaritalStatus(values.marital_status || "solteiro")}
          onValueChange={(val) => onChange("marital_status", normalizeMaritalStatus(val))}
          columns={2}
          className="sm:grid-cols-4"
          disabled={disabled}
        >
          <CardSelectorItem value="solteiro" label="Solteiro(a)" />
          <CardSelectorItem value="casado" label="Casado(a)" />
          <CardSelectorItem value="divorciado" label="Divorciado(a)" />
          <CardSelectorItem value="viuvo" label="Viúvo(a)" />
        </CardSelector>
        {errors.marital_status && <FieldError>{errors.marital_status}</FieldError>}
      </div>
    </div>
  )
}
