import { useState } from "react"
import { useForm } from "react-hook-form"
import { zodResolver } from "@hookform/resolvers/zod"
import * as z from "zod"
import {
  Clock,
  CheckCircle2,
  Plane,
  Loader2,
  HeartHandshake,
  User,
  Mail,
  Phone,
  MapPin,
  FileText,
} from "lucide-react"
import { toast } from "sonner"
import supabase from "@/lib/supabase"
import { formatValue, isValidCPF, isValidPhone } from "@/lib/forms"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Textarea } from "@/components/ui/textarea"
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select"
import { Field, FieldLabel, FieldError, FieldDescription } from "@/components/ui/field"
import { THEME_CLASSES } from "@/constants/colors"

export const TRAVEL_MODES = [
  "Já comprei passagem",
  "Carro próprio",
  "Carona",
  "A definir",
] as const

export type TravelMode = (typeof TRAVEL_MODES)[number]

const waitlistSchema = z.object({
  full_name: z
    .string()
    .min(3, "Nome completo é obrigatório (mínimo de 3 caracteres)."),
  email: z
    .string()
    .min(1, "E-mail é obrigatório.")
    .email("E-mail inválido."),
  phone: z
    .string()
    .min(10, "Telefone ou celular é obrigatório.")
    .refine((val) => isValidPhone(val), {
      message: "Celular inválido (Ex: (31) 98888-7777).",
    }),
  cpf: z
    .string()
    .optional()
    .refine((val) => !val || isValidCPF(val), {
      message: "CPF inválido.",
    }),
  city_state: z.string().optional(),
  travel_mode: z.enum(TRAVEL_MODES, {
    message: "Selecione uma opção de deslocamento.",
  }),
  notes: z.string().optional(),
})

export type WaitlistFormData = z.infer<typeof waitlistSchema>

interface EventWaitlistFormProps {
  retreat: {
    id: string
    title: string
    location_text?: string | null
    [key: string]: unknown
  }
  initialData?: {
    fullName?: string
    email?: string
    phone?: string
    cpf?: string
    cityState?: string
  }
  onSuccess?: (waitlistEntry: unknown) => void
  onCancel?: () => void
  className?: string
}

export function EventWaitlistForm({
  retreat,
  initialData,
  onSuccess,
  onCancel,
  className = "",
}: EventWaitlistFormProps) {
  const [submitting, setSubmitting] = useState(false)
  const [submitted, setSubmitted] = useState(false)
  const [submittedData, setSubmittedData] = useState<WaitlistFormData | null>(null)

  const {
    register,
    handleSubmit,
    setValue,
    watch,
    formState: { errors },
  } = useForm<WaitlistFormData>({
    resolver: zodResolver(waitlistSchema),
    defaultValues: {
      full_name: initialData?.fullName || "",
      email: initialData?.email || "",
      phone: initialData?.phone ? formatValue(initialData.phone, "phone") : "",
      cpf: initialData?.cpf ? formatValue(initialData.cpf, "cpf") : "",
      city_state: initialData?.cityState || "",
      travel_mode: "A definir",
      notes: "",
    },
  })

  const selectedTravelMode = watch("travel_mode")

  const onSubmit = async (values: WaitlistFormData) => {
    setSubmitting(true)
    try {
      // 1. Verificar se este e-mail já está na lista de espera deste retiro
      const cleanEmail = values.email.trim().toLowerCase()
      const { data: existing } = await supabase
        .from("event_waitlist")
        .select("id, status")
        .eq("retreat_id", retreat.id)
        .eq("email", cleanEmail)
        .maybeSingle()

      if (existing) {
        toast.info(
          "Você já está cadastrado na lista de espera para este encontro! Nossa liderança entrará em contato se abrir vaga."
        )
        setSubmittedData(values)
        setSubmitted(true)
        onSuccess?.(existing)
        return
      }

      // 2. Inserir na tabela event_waitlist
      const cleanPhone = values.phone.trim()
      const cleanCpf = values.cpf?.trim() || null

      const { data: inserted, error } = await supabase
        .from("event_waitlist")
        .insert({
          retreat_id: retreat.id,
          full_name: values.full_name.trim(),
          cpf: cleanCpf,
          phone: cleanPhone,
          email: cleanEmail,
          city_state: values.city_state?.trim() || null,
          travel_mode: values.travel_mode || "A definir",
          notes: values.notes?.trim() || null,
          status: "aguardando",
        })
        .select()
        .single()

      if (error) throw error

      toast.success(
        "Você entrou na lista de espera! Entraremos em contato assim que surgir uma vaga."
      )
      setSubmittedData(values)
      setSubmitted(true)
      onSuccess?.(inserted)
    } catch (err: unknown) {
      console.error("Erro ao entrar na lista de espera:", err)
      const message = err instanceof Error ? err.message : "Tente novamente."
      toast.error("Erro ao salvar seus dados: " + message)
    } finally {
      setSubmitting(false)
    }
  }

  if (submitted) {
    const hasBoughtTicket = submittedData?.travel_mode === "Já comprei passagem"

    return (
      <div className={`mx-auto w-full max-w-xl animate-in fade-in zoom-95 duration-300 ${className}`}>
        <div className="rounded-2xl border border-emerald-500/30 bg-card p-6 sm:p-8 text-center shadow-lg">
          <div className="mx-auto flex h-16 w-16 items-center justify-center rounded-full border border-emerald-500/20 bg-emerald-500/10 text-emerald-600 dark:text-emerald-400">
            <CheckCircle2 className="h-8 w-8" />
          </div>

          <div className="mt-4 space-y-2">
            <span className={THEME_CLASSES.badgeSuccess}>
              Lista de Espera Confirmada
            </span>
            <h3 className="text-xl sm:text-2xl font-extrabold tracking-tight text-foreground">
              Você está na lista de espera!
            </h3>
            <p className="text-sm leading-relaxed text-muted-foreground">
              Agradecemos de coração a sua disposição para estar conosco no encontro{" "}
              <strong className="text-foreground">{retreat.title}</strong>. Seus dados
              foram registrados com prioridade cronológica de chegada.
            </p>
          </div>

          {hasBoughtTicket && (
            <div className="mt-4 flex items-start gap-3 rounded-xl border border-purple-500/30 bg-purple-500/10 p-3.5 text-left dark:bg-purple-500/15">
              <Plane className="h-5 w-5 shrink-0 text-purple-600 dark:text-purple-300 mt-0.5" />
              <div className="text-xs leading-relaxed text-purple-900 dark:text-purple-200">
                <strong>Passagem Comprada:</strong> Registramos que você já comprou passagem.
                O diaconato e a liderança darão atenção prioritária caso ocorra desistência de vagas.
              </div>
            </div>
          )}

          <div className="mt-6 rounded-xl border border-border/60 bg-muted/30 p-4 text-left text-xs space-y-1.5 text-muted-foreground">
            <div className="font-semibold text-foreground flex items-center gap-1.5">
              <Clock className="h-3.5 w-3.5 text-amber-500" /> Como funciona a chamada:
            </div>
            <p>
              1. As vagas são remanejadas por ordem estrita de chegada na lista.
            </p>
            <p>
              2. Caso surja uma vaga, a liderança entrará em contato via WhatsApp/telefone (
              <span className="font-medium text-foreground">{submittedData?.phone}</span>) ou e-mail (
              <span className="font-medium text-foreground">{submittedData?.email}</span>).
            </p>
            <p>
              3. Você receberá um link ou código exclusivo para concluir sua inscrição.
            </p>
          </div>

          <div className="mt-6 flex flex-col sm:flex-row items-center justify-center gap-3">
            {onCancel && (
              <Button
                variant="outline"
                onClick={onCancel}
                className="w-full sm:w-auto min-h-[44px] cursor-pointer rounded-xl font-bold"
              >
                Voltar
              </Button>
            )}
          </div>
        </div>
      </div>
    )
  }

  return (
    <div className={`mx-auto w-full max-w-xl ${className}`}>
      <div className="rounded-2xl border border-border/80 bg-card/95 backdrop-blur-sm p-6 sm:p-8 shadow-xl">
        {/* Header Acolhedor */}
        <div className="space-y-3 border-b border-border/50 pb-5">
          <div className="flex items-center gap-2.5">
            <div className="flex h-10 w-10 shrink-0 items-center justify-center rounded-xl border border-amber-500/20 bg-amber-500/10 text-amber-600 dark:text-amber-400">
              <HeartHandshake className="h-5 w-5" />
            </div>
            <div>
              <span className="inline-flex items-center gap-1 text-[11px] font-bold uppercase tracking-wider text-amber-600 dark:text-amber-400">
                <Clock className="h-3 w-3" /> Lotação Esgotada
              </span>
              <h2 className="text-lg sm:text-xl font-extrabold tracking-tight text-foreground">
                As vagas para este encontro esgotaram!
              </h2>
            </div>
          </div>
          <p className="text-xs sm:text-sm leading-relaxed text-muted-foreground">
            Deseja entrar na lista de espera para o encontro{" "}
            <strong className="text-foreground">{retreat.title}</strong>? Preencha seus dados
            abaixo. Caso haja desistência ou abertura de novas vagas, a liderança entrará
            em contato em ordem cronológica de chegada.
          </p>
        </div>

        {/* Formulário com react-hook-form + zod */}
        <form onSubmit={handleSubmit(onSubmit)} className="mt-5 space-y-4">
          {/* Nome Completo */}
          <Field>
            <FieldLabel htmlFor="full_name" className="flex items-center gap-1.5 text-xs font-bold text-foreground">
              <User className="h-3.5 w-3.5 text-muted-foreground" />
              Nome Completo *
            </FieldLabel>
            <Input
              id="full_name"
              {...register("full_name")}
              placeholder="Ex: Gabriel Góes Braga"
              className="min-h-[44px] h-11 text-sm bg-background"
            />
            {errors.full_name && <FieldError>{errors.full_name.message}</FieldError>}
          </Field>

          {/* E-mail e Telefone em grid fluido */}
          <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
            <Field>
              <FieldLabel htmlFor="email" className="flex items-center gap-1.5 text-xs font-bold text-foreground">
                <Mail className="h-3.5 w-3.5 text-muted-foreground" />
                E-mail *
              </FieldLabel>
              <Input
                id="email"
                type="email"
                {...register("email")}
                placeholder="seuemail@exemplo.com"
                className="min-h-[44px] h-11 text-sm bg-background"
              />
              {errors.email && <FieldError>{errors.email.message}</FieldError>}
            </Field>

            <Field>
              <FieldLabel htmlFor="phone" className="flex items-center gap-1.5 text-xs font-bold text-foreground">
                <Phone className="h-3.5 w-3.5 text-muted-foreground" />
                Celular / WhatsApp *
              </FieldLabel>
              <Input
                id="phone"
                {...register("phone")}
                onChange={(e) => {
                  setValue("phone", formatValue(e.target.value, "phone"), {
                    shouldValidate: true,
                  })
                }}
                placeholder="(31) 99999-9999"
                className="min-h-[44px] h-11 text-sm bg-background"
              />
              {errors.phone && <FieldError>{errors.phone.message}</FieldError>}
            </Field>
          </div>

          {/* CPF e Cidade/Estado */}
          <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
            <Field>
              <FieldLabel htmlFor="cpf" className="flex items-center gap-1.5 text-xs font-bold text-foreground">
                <FileText className="h-3.5 w-3.5 text-muted-foreground" />
                CPF (Opcional)
              </FieldLabel>
              <Input
                id="cpf"
                {...register("cpf")}
                onChange={(e) => {
                  setValue("cpf", formatValue(e.target.value, "cpf"), {
                    shouldValidate: true,
                  })
                }}
                placeholder="000.000.000-00"
                maxLength={14}
                className="min-h-[44px] h-11 text-sm bg-background"
              />
              {errors.cpf && <FieldError>{errors.cpf.message}</FieldError>}
            </Field>

            <Field>
              <FieldLabel htmlFor="city_state" className="flex items-center gap-1.5 text-xs font-bold text-foreground">
                <MapPin className="h-3.5 w-3.5 text-muted-foreground" />
                Cidade / Estado
              </FieldLabel>
              <Input
                id="city_state"
                {...register("city_state")}
                placeholder="Ex: Belo Horizonte / MG"
                className="min-h-[44px] h-11 text-sm bg-background"
              />
              {errors.city_state && <FieldError>{errors.city_state.message}</FieldError>}
            </Field>
          </div>

          {/* Deslocamento / Modo de Transporte */}
          <Field>
            <FieldLabel htmlFor="travel_mode" className="flex items-center gap-1.5 text-xs font-bold text-foreground">
              <Plane className="h-3.5 w-3.5 text-muted-foreground" />
              Como você planeja se deslocar? *
            </FieldLabel>
            <Select
              value={selectedTravelMode}
              onValueChange={(val: TravelMode) => setValue("travel_mode", val)}
            >
              <SelectTrigger id="travel_mode" className="min-h-[44px] h-11 text-sm bg-background w-full">
                <SelectValue placeholder="Selecione uma opção" />
              </SelectTrigger>
              <SelectContent>
                {TRAVEL_MODES.map((mode) => (
                  <SelectItem key={mode} value={mode}>
                    {mode === "Já comprei passagem" ? "✈️ Já comprei passagem (Aéreo/Ônibus)" : mode}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
            <FieldDescription>
              Irmãos vindos de fora com passagens já emitidas recebem atenção prioritária em caso de vagas remanescentes.
            </FieldDescription>
            {errors.travel_mode && <FieldError>{errors.travel_mode.message}</FieldError>}
          </Field>

          {/* Alerta de destaque se comprou passagem */}
          {selectedTravelMode === "Já comprei passagem" && (
            <div className="flex items-start gap-2.5 rounded-xl border border-purple-500/30 bg-purple-500/10 p-3 text-xs text-purple-900 dark:bg-purple-500/15 dark:text-purple-200">
              <Plane className="h-4 w-4 shrink-0 text-purple-600 dark:text-purple-300 mt-0.5" />
              <div>
                <strong>Atenção prioritária registrada:</strong> Sua inscrição na fila receberá um
                destaque visual para a equipe organizadora devido à compra prévia de passagens.
              </div>
            </div>
          )}

          {/* Observações */}
          <Field>
            <FieldLabel htmlFor="notes" className="text-xs font-bold text-foreground">
              Observações (Opcional)
            </FieldLabel>
            <Textarea
              id="notes"
              {...register("notes")}
              placeholder="Ex: Disponibilidade de datas, restrições ou com quem você viria..."
              className="min-h-[70px] text-sm bg-background resize-none"
            />
          </Field>

          {/* Botões de Ação */}
          <div className="flex flex-col-reverse sm:flex-row items-center justify-end gap-3 pt-3 border-t border-border/40">
            {onCancel && (
              <Button
                type="button"
                variant="outline"
                onClick={onCancel}
                disabled={submitting}
                className="w-full sm:w-auto min-h-[44px] cursor-pointer rounded-xl font-bold"
              >
                Voltar
              </Button>
            )}

            <Button
              type="submit"
              disabled={submitting}
              className="w-full sm:w-auto min-h-[44px] cursor-pointer rounded-xl bg-primary text-primary-foreground font-bold shadow-md shadow-primary/20 hover:bg-primary/90"
            >
              {submitting ? (
                <>
                  <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                  Registrando...
                </>
              ) : (
                "Entrar na Lista de Espera"
              )}
            </Button>
          </div>
        </form>
      </div>
    </div>
  )
}
