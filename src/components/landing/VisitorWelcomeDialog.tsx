import { useState } from "react"
import { useForm, Controller } from "react-hook-form"
import * as z from "zod"
import { zodResolver } from "@hookform/resolvers/zod"
import { toast } from "sonner"
import { Loader2, Sparkles, MapPin, Send } from "lucide-react"
import supabase from "@/lib/supabase"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Textarea } from "@/components/ui/textarea"
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogDescription,
  DialogFooter,
} from "@/components/ui/dialog"
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select"
import { Field, FieldLabel, FieldError } from "@/components/ui/field"

const visitorSchema = z.object({
  fullName: z.string().min(3, "Por favor, informe seu nome completo"),
  phone: z
    .string()
    .min(10, "Informe um telefone/WhatsApp válido com DDD")
    .regex(
      /^\(?\d{2}\)?\s?\d{4,5}-?\d{4}$/,
      "Formato inválido. Use (31) 9XXXX-XXXX"
    ),
  region: z.string().min(1, "Selecione uma região de Belo Horizonte"),
  message: z.string().optional(),
})

type VisitorFormValues = z.infer<typeof visitorSchema>

const regionsBH = [
  "Barreiro / Oeste",
  "Betim",
  "Centro / Sul",
  "Contagem",
  "Pampulha / São Gabriel",
  "Santa Luzia",
  "Venda Nova",
  "Outra Região da RMBH",
]

interface VisitorWelcomeDialogProps {
  open: boolean
  onOpenChange: (open: boolean) => void
}

export function VisitorWelcomeDialog({
  open,
  onOpenChange,
}: VisitorWelcomeDialogProps) {
  const [submitting, setSubmitting] = useState(false)

  const {
    register,
    handleSubmit,
    control,
    reset,
    formState: { errors },
  } = useForm<VisitorFormValues>({
    resolver: zodResolver(visitorSchema),
    defaultValues: {
      fullName: "",
      phone: "",
      region: "",
      message: "",
    },
  })

  const onSubmit = async (values: VisitorFormValues) => {
    setSubmitting(true)
    try {
      const submissionId = `sub-visitor-${Date.now()}`

      const payload = {
        id: submissionId,
        form_id: "form-apoio-diaconal",
        data: {
          mandatory_full_name: values.fullName.trim(),
          mandatory_phone: values.phone.trim(),
          grupo_caseiro: `Acolhimento - ${values.region}`,
          tipo_necessidade: "Acolhimento / Conhecer Grupo Caseiro",
          urgencia: "Média (Nesta semana)",
          detalhes: values.message?.trim() || "Deseja conhecer a comunhão e os Grupos Caseiros nos lares.",
          source: "Landing Page - Visitante",
        },
        submitted_at: new Date().toISOString(),
      }

      const { error } = await supabase.from("form_submissions").insert(payload)

      if (error) {
        console.warn("Aviso na inserção de acolhimento:", error.message)
      }

      toast.success("Recebemos seu contato com alegria!", {
        description:
          "Um irmão da sua região entrará em contato em breve para um café e boas-vindas.",
        duration: 6000,
      })

      reset()
      onOpenChange(false)
    } catch (err) {
      console.error("Erro ao enviar pedido de acolhimento:", err)
      toast.error("Ocorreu um erro ao enviar seu contato. Tente novamente.")
    } finally {
      setSubmitting(false)
    }
  }

  // Formatador de máscara para telefone brasileiro
  const formatPhone = (val: string) => {
    const digits = val.replace(/\D/g, "").slice(0, 11)
    if (digits.length <= 2) return digits
    if (digits.length <= 6) return `(${digits.slice(0, 2)}) ${digits.slice(2)}`
    if (digits.length <= 10) {
      return `(${digits.slice(0, 2)}) ${digits.slice(2, 6)}-${digits.slice(6)}`
    }
    return `(${digits.slice(0, 2)}) ${digits.slice(2, 7)}-${digits.slice(7, 11)}`
  }

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="max-w-md p-6">
        <DialogHeader className="text-left space-y-1.5">
          <div className="inline-flex items-center gap-1.5 text-xs font-semibold text-primary">
            <Sparkles className="h-3.5 w-3.5 text-amber-600 dark:text-amber-400" />
            Portas Abertas nos Lares
          </div>
          <DialogTitle className="text-xl font-bold tracking-tight">
            Conheça um Grupo Caseiro
          </DialogTitle>
          <DialogDescription className="text-xs text-muted-foreground leading-relaxed">
            A igreja são as pessoas, reunidas nas casas e na cidade. Preencha seus dados para indicarmos os irmãos mais próximos da sua residência!
          </DialogDescription>
        </DialogHeader>

        <form onSubmit={handleSubmit(onSubmit)} className="space-y-4 pt-2">
          {/* Nome Completo */}
          <Field className="space-y-1">
            <FieldLabel className="text-xs font-semibold">Seu Nome Completo</FieldLabel>
            <Input
              {...register("fullName")}
              placeholder="Ex: Ana Maria Silva"
              className="min-h-[44px] text-sm"
              disabled={submitting}
            />
            {errors.fullName && <FieldError className="text-xs">{errors.fullName.message}</FieldError>}
          </Field>

          {/* WhatsApp / Telefone */}
          <Field className="space-y-1">
            <FieldLabel className="text-xs font-semibold">WhatsApp com DDD</FieldLabel>
            <Controller
              name="phone"
              control={control}
              render={({ field }) => (
                <Input
                  {...field}
                  onChange={(e) => field.onChange(formatPhone(e.target.value))}
                  placeholder="(31) 99999-9999"
                  className="min-h-[44px] text-sm"
                  disabled={submitting}
                  type="tel"
                />
              )}
            />
            {errors.phone && <FieldError className="text-xs">{errors.phone.message}</FieldError>}
          </Field>

          {/* Região em BH */}
          <Field className="space-y-1">
            <FieldLabel className="text-xs font-semibold">Bairro ou Região de BH</FieldLabel>
            <Controller
              name="region"
              control={control}
              render={({ field }) => (
                <Select
                  value={field.value}
                  onValueChange={field.onChange}
                  disabled={submitting}
                >
                  <SelectTrigger className="min-h-[44px] text-sm">
                    <SelectValue placeholder="Selecione sua região" />
                  </SelectTrigger>
                  <SelectContent>
                    {regionsBH.map((reg) => (
                      <SelectItem key={reg} value={reg} className="min-h-[40px] text-sm">
                        <div className="flex items-center gap-2">
                          <MapPin className="h-3.5 w-3.5 text-primary" />
                          <span>{reg}</span>
                        </div>
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              )}
            />
            {errors.region && <FieldError className="text-xs">{errors.region.message}</FieldError>}
          </Field>

          {/* Mensagem Opcional */}
          <Field className="space-y-1">
            <FieldLabel className="text-xs font-semibold">
              Mensagem <span className="font-normal text-muted-foreground">(opcional)</span>
            </FieldLabel>
            <Textarea
              {...register("message")}
              placeholder="Conte-nos brevemente o que você busca ou como nos conheceu..."
              className="min-h-[80px] text-sm"
              disabled={submitting}
            />
          </Field>

          <DialogFooter className="flex flex-col-reverse gap-2 pt-2 sm:flex-row sm:justify-end">
            <Button
              type="button"
              variant="outline"
              onClick={() => onOpenChange(false)}
              className="min-h-[44px] w-full text-xs font-semibold sm:w-auto"
              disabled={submitting}
            >
              Cancelar
            </Button>
            <Button
              type="submit"
              className="btn-tactile min-h-[44px] w-full gap-2 text-xs font-semibold shadow-xs sm:w-auto"
              disabled={submitting}
            >
              {submitting ? (
                <>
                  <Loader2 className="h-4 w-4 animate-spin" />
                  Enviando...
                </>
              ) : (
                <>
                  <Send className="h-3.5 w-3.5" />
                  Quero ser Acolhido(a)
                </>
              )}
            </Button>
          </DialogFooter>
        </form>
      </DialogContent>
    </Dialog>
  )
}
