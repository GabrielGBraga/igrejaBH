import { useState } from "react"
import { Input } from "@/components/ui/input"
import { Field, FieldLabel, FieldError } from "@/components/ui/field"
import {
  InputGroup,
  InputGroupAddon,
  InputGroupInput,
} from "@/components/ui/input-group"
import { SearchIcon, Loader2 } from "lucide-react"
import { toast } from "sonner"

export interface AddressFormValues {
  address_zip_code?: string | null
  address_street?: string | null
  address_number?: string | null
  address_complement?: string | null
  address_neighborhood?: string | null
  address_city?: string | null
  address_state?: string | null
}

export interface AddressFormSectionProps {
  values: AddressFormValues
  onChange: (field: keyof AddressFormValues, value: string) => void
  onBulkChange?: (updates: Partial<AddressFormValues>) => void
  errors?: Record<string, string>
  disabled?: boolean
  showRequiredMarks?: boolean
}

export function AddressFormSection({
  values,
  onChange,
  onBulkChange,
  errors = {},
  disabled = false,
  showRequiredMarks = false,
}: AddressFormSectionProps) {
  const [searchingCep, setSearchingCep] = useState(false)
  const req = showRequiredMarks ? "*" : ""

  const handleZipChange = async (cepValue: string) => {
    onChange("address_zip_code", cepValue)
    const cleanCep = cepValue.replace(/\D/g, "")
    if (cleanCep.length === 8) {
      setSearchingCep(true)
      try {
        const response = await fetch(`https://viacep.com.br/ws/${cleanCep}/json/`)
        const data = await response.json()
        if (!data.erro) {
          const updates: Partial<AddressFormValues> = {
            address_street: data.logradouro || values.address_street || "",
            address_neighborhood: data.bairro || values.address_neighborhood || "",
            address_city: data.localidade || values.address_city || "Belo Horizonte",
            address_state: data.uf || values.address_state || "MG",
          }
          if (onBulkChange) {
            onBulkChange(updates)
          } else {
            if (data.logradouro) onChange("address_street", data.logradouro)
            if (data.bairro) onChange("address_neighborhood", data.bairro)
            if (data.localidade) onChange("address_city", data.localidade)
            if (data.uf) onChange("address_state", data.uf)
          }
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

  return (
    <div className="space-y-4 py-1">
      <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
        <Field data-invalid={!!errors.address_zip_code}>
          <FieldLabel htmlFor="address-cep" className="text-sm font-semibold text-foreground/90">
            CEP{req}
          </FieldLabel>
          <InputGroup>
            <InputGroupInput
              id="address-cep"
              value={values.address_zip_code || ""}
              onChange={(e) => handleZipChange(e.target.value)}
              placeholder="00000-000"
              maxLength={9}
              disabled={disabled || searchingCep}
              className="min-h-[44px] rounded-xl border-border/60 bg-muted/20 text-sm focus-visible:ring-primary/20"
            />
            <InputGroupAddon align="inline-end">
              {searchingCep ? (
                <Loader2 className="size-4 animate-spin text-muted-foreground" />
              ) : (
                <SearchIcon className="size-4 text-muted-foreground" />
              )}
            </InputGroupAddon>
          </InputGroup>
          {errors.address_zip_code && (
            <FieldError>{errors.address_zip_code}</FieldError>
          )}
        </Field>

        <div className="sm:col-span-2">
          <Field data-invalid={!!errors.address_street}>
            <FieldLabel htmlFor="address-street" className="text-sm font-semibold text-foreground/90">
              Rua / Logradouro{req}
            </FieldLabel>
            <Input
              id="address-street"
              value={values.address_street || ""}
              onChange={(e) => onChange("address_street", e.target.value)}
              placeholder="Rua ou Avenida"
              disabled={disabled}
              className="min-h-[44px] rounded-xl border-border/60 bg-muted/20 text-sm focus-visible:ring-primary/20"
            />
            {errors.address_street && (
              <FieldError>{errors.address_street}</FieldError>
            )}
          </Field>
        </div>

        <Field data-invalid={!!errors.address_number}>
          <FieldLabel htmlFor="address-number" className="text-sm font-semibold text-foreground/90">
            Número{req}
          </FieldLabel>
          <Input
            id="address-number"
            value={values.address_number || ""}
            onChange={(e) => onChange("address_number", e.target.value)}
            placeholder="123"
            disabled={disabled}
            className="min-h-[44px] rounded-xl border-border/60 bg-muted/20 text-sm focus-visible:ring-primary/20"
          />
          {errors.address_number && (
            <FieldError>{errors.address_number}</FieldError>
          )}
        </Field>

        <Field data-invalid={!!errors.address_neighborhood}>
          <FieldLabel htmlFor="address-neighborhood" className="text-sm font-semibold text-foreground/90">
            Bairro{req}
          </FieldLabel>
          <Input
            id="address-neighborhood"
            value={values.address_neighborhood || ""}
            onChange={(e) => onChange("address_neighborhood", e.target.value)}
            placeholder="Bairro"
            disabled={disabled}
            className="min-h-[44px] rounded-xl border-border/60 bg-muted/20 text-sm focus-visible:ring-primary/20"
          />
          {errors.address_neighborhood && (
            <FieldError>{errors.address_neighborhood}</FieldError>
          )}
        </Field>

        <Field>
          <FieldLabel htmlFor="address-complement" className="text-sm font-semibold text-foreground/90">
            Complemento
          </FieldLabel>
          <Input
            id="address-complement"
            value={values.address_complement || ""}
            onChange={(e) => onChange("address_complement", e.target.value)}
            placeholder="Apto, Bloco..."
            disabled={disabled}
            className="min-h-[44px] rounded-xl border-border/60 bg-muted/20 text-sm focus-visible:ring-primary/20"
          />
        </Field>

        <Field data-invalid={!!errors.address_city} className="sm:col-span-2">
          <FieldLabel htmlFor="address-city" className="text-sm font-semibold text-foreground/90">
            Cidade{req}
          </FieldLabel>
          <Input
            id="address-city"
            value={values.address_city || ""}
            onChange={(e) => onChange("address_city", e.target.value)}
            placeholder="Belo Horizonte"
            disabled={disabled}
            className="min-h-[44px] rounded-xl border-border/60 bg-muted/20 text-sm focus-visible:ring-primary/20"
          />
          {errors.address_city && <FieldError>{errors.address_city}</FieldError>}
        </Field>

        <Field data-invalid={!!errors.address_state}>
          <FieldLabel htmlFor="address-state" className="text-sm font-semibold text-foreground/90">
            Estado{req}
          </FieldLabel>
          <Input
            id="address-state"
            value={values.address_state || ""}
            onChange={(e) => onChange("address_state", e.target.value.toUpperCase())}
            placeholder="MG"
            maxLength={2}
            disabled={disabled}
            className="min-h-[44px] rounded-xl border-border/60 bg-muted/20 text-sm uppercase focus-visible:ring-primary/20"
          />
          {errors.address_state && (
            <FieldError>{errors.address_state}</FieldError>
          )}
        </Field>
      </div>
    </div>
  )
}
