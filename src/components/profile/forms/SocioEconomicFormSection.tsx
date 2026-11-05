import { Input } from "@/components/ui/input"
import { Field, FieldLabel, FieldError } from "@/components/ui/field"
import { CardSelector, CardSelectorItem } from "@/components/ui/card-selector"
import {
  normalizeEducationLevel,
  normalizeEmploymentStatus,
  normalizeHouseholdIncome,
  normalizeHousingStatus,
  normalizeDriversLicense,
} from "@/lib/profileNormalization"

export interface SocioEconomicFormValues {
  occupation?: string | null
  education_level?: string | null
  employment_status?: string | null
  housing_status?: string | null
  household_income?: string | null
  dependents_count?: number | null
  drivers_license?: string | null
}

export interface SocioEconomicFormSectionProps {
  values: SocioEconomicFormValues
  onChange: (field: keyof SocioEconomicFormValues, value: any) => void
  errors?: Record<string, string>
  disabled?: boolean
  showRequiredMarks?: boolean
}

export function SocioEconomicFormSection({
  values,
  onChange,
  errors = {},
  disabled = false,
  showRequiredMarks = false,
}: SocioEconomicFormSectionProps) {
  const req = showRequiredMarks ? "*" : ""

  return (
    <div className="space-y-6 py-1">
      <Field data-invalid={!!errors.occupation}>
        <FieldLabel htmlFor="socio-occupation" className="text-sm font-semibold text-foreground/90">
          Sua Profissão{req}
        </FieldLabel>
        <Input
          id="socio-occupation"
          value={values.occupation || ""}
          onChange={(e) => onChange("occupation", e.target.value)}
          placeholder="Ex: Engenheiro, Professor, Autônomo..."
          disabled={disabled}
          className="min-h-[44px] rounded-xl border-border/60 bg-muted/20 text-sm focus-visible:ring-primary/20"
        />
        {errors.occupation && <FieldError>{errors.occupation}</FieldError>}
      </Field>

      <div className="space-y-2">
        <FieldLabel className="text-sm font-semibold text-foreground/90">
          Qual sua escolaridade?{req}
        </FieldLabel>
        <CardSelector
          value={normalizeEducationLevel(values.education_level || "Médio Completo")}
          onValueChange={(val) => onChange("education_level", normalizeEducationLevel(val))}
          columns={1}
          disabled={disabled}
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
        {errors.education_level && (
          <FieldError>{errors.education_level}</FieldError>
        )}
      </div>

      <div className="space-y-2">
        <FieldLabel className="text-sm font-semibold text-foreground/90">
          Como é seu vínculo empregatício?{req}
        </FieldLabel>
        <CardSelector
          value={normalizeEmploymentStatus(values.employment_status || "CLT")}
          onValueChange={(val) => onChange("employment_status", normalizeEmploymentStatus(val))}
          columns={1}
          className="sm:grid-cols-2"
          disabled={disabled}
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
        {errors.employment_status && (
          <FieldError>{errors.employment_status}</FieldError>
        )}
      </div>

      <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
        <div className="space-y-2">
          <FieldLabel className="text-sm font-semibold text-foreground/90">
            Situação de Moradia{req}
          </FieldLabel>
          <CardSelector
            value={normalizeHousingStatus(values.housing_status || "Própria")}
            onValueChange={(val) => onChange("housing_status", normalizeHousingStatus(val))}
            columns={1}
            disabled={disabled}
          >
            {["Própria", "Alugada", "Cedida/Parentes", "Financiada"].map(
              (opt) => (
                <CardSelectorItem key={opt} value={opt} label={opt} />
              )
            )}
          </CardSelector>
          {errors.housing_status && (
            <FieldError>{errors.housing_status}</FieldError>
          )}
        </div>

        <div className="space-y-2">
          <FieldLabel className="text-sm font-semibold text-foreground/90">
            Renda Familiar{req}
          </FieldLabel>
          <CardSelector
            value={normalizeHouseholdIncome(values.household_income || "1 a 3 SM")}
            onValueChange={(val) => onChange("household_income", normalizeHouseholdIncome(val))}
            columns={1}
            disabled={disabled}
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
          {errors.household_income && (
            <FieldError>{errors.household_income}</FieldError>
          )}
        </div>
      </div>

      <Field data-invalid={!!errors.dependents_count}>
        <FieldLabel htmlFor="socio-dependents" className="text-sm font-semibold text-foreground/90">
          Número de Dependentes{req}
        </FieldLabel>
        <Input
          id="socio-dependents"
          type="number"
          min="0"
          value={values.dependents_count ?? 0}
          onChange={(e) =>
            onChange("dependents_count", parseInt(e.target.value, 10) || 0)
          }
          disabled={disabled}
          className="min-h-[44px] rounded-xl border-border/60 bg-muted/20 text-sm focus-visible:ring-primary/20 max-w-[200px]"
        />
        {errors.dependents_count && (
          <FieldError>{errors.dependents_count}</FieldError>
        )}
      </Field>

      <div className="space-y-2">
        <FieldLabel className="text-sm font-semibold text-foreground/90">
          Categoria CNH{req}
        </FieldLabel>
        <CardSelector
          value={normalizeDriversLicense(values.drivers_license || "Não possui")}
          onValueChange={(val) => onChange("drivers_license", normalizeDriversLicense(val))}
          columns={2}
          className="sm:grid-cols-4"
          disabled={disabled}
        >
          {["Não possui", "A", "B", "AB", "C", "D", "E"].map((opt) => (
            <CardSelectorItem key={opt} value={opt} label={opt} />
          ))}
        </CardSelector>
        {errors.drivers_license && (
          <FieldError>{errors.drivers_license}</FieldError>
        )}
      </div>
    </div>
  )
}
