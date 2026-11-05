import { Input } from "@/components/ui/input"
import { Field, FieldLabel, FieldError } from "@/components/ui/field"
import { formatPhone } from "@/lib/phoneUtils"

export interface ContactFormValues {
  phone?: string | null
}

export interface ContactFormSectionProps {
  values: ContactFormValues
  onChange: (field: keyof ContactFormValues, value: string) => void
  errors?: Record<string, string>
  disabled?: boolean
  showRequiredMarks?: boolean
}

export function ContactFormSection({
  values,
  onChange,
  errors = {},
  disabled = false,
  showRequiredMarks = false,
}: ContactFormSectionProps) {
  const req = showRequiredMarks ? "*" : ""

  return (
    <div className="space-y-4 py-1">
      <Field data-invalid={!!errors.phone}>
        <FieldLabel htmlFor="contact-phone" className="text-sm font-semibold text-foreground/90">
          Telefone Celular / WhatsApp{req}
        </FieldLabel>
        <Input
          id="contact-phone"
          value={values.phone || ""}
          onChange={(e) => onChange("phone", formatPhone(e.target.value))}
          placeholder="(31) 98888-7777"
          maxLength={20}
          disabled={disabled}
          className="min-h-[44px] rounded-xl border-border/60 bg-muted/20 text-sm focus-visible:ring-primary/20"
        />
        {errors.phone ? (
          <FieldError>{errors.phone}</FieldError>
        ) : (
          <p className="text-xs text-muted-foreground mt-1">
            Utilizado para avisos fraternais, contato do seu discipulador e comunicações da igreja.
          </p>
        )}
      </Field>
    </div>
  )
}
