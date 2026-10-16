import { useState } from "react"
import { Link } from "react-router-dom"
import { useForm, Controller } from "react-hook-form"
import * as z from "zod"
import { zodResolver } from "@hookform/resolvers/zod"
import { toast } from "sonner"
import { Loader2, HeartHandshake, Send, CheckCircle2, ArrowRight } from "lucide-react"
import supabase from "@/lib/supabase"
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
import { Field, FieldLabel, FieldError } from "@/components/ui/field"

const quickContactSchema = z.object({
  fullName: z.string().min(3, "Por favor, informe seu nome completo"),
  phone: z
    .string()
    .min(10, "Informe seu WhatsApp com DDD")
    .regex(/^\(?\d{2}\)?\s?\d{4,5}-?\d{4}$/, "Formato: (31) 9XXXX-XXXX"),
  region: z.string().min(1, "Selecione sua região de Belo Horizonte"),
  message: z.string().optional(),
})

type QuickContactValues = z.infer<typeof quickContactSchema>

const regionsBH = [
  "Barreiro / Oeste",
  "Betim",
  "Centro / Sul",
  "Contagem",
  "Leste / Nordeste",
  "Noroeste",
  "Pampulha / São Gabriel",
  "Santa Luzia / Ribeirão das Neves",
  "Venda Nova",
  "Outra Região da RMBH",
]

interface LandingContactSectionProps {
  onOpenDialog?: () => void
}

export function LandingContactSection({ onOpenDialog }: LandingContactSectionProps) {
  const [submitting, setSubmitting] = useState(false)
  const [submitted, setSubmitted] = useState(false)
  const [showInlineForm, setShowInlineForm] = useState(false)

  const {
    register,
    handleSubmit,
    control,
    reset,
    formState: { errors },
  } = useForm<QuickContactValues>({
    resolver: zodResolver(quickContactSchema),
    defaultValues: {
      fullName: "",
      phone: "",
      region: "",
      message: "",
    },
  })

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

  const onSubmit = async (values: QuickContactValues) => {
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
          detalhes: values.message?.trim() || "Deseja conhecer a congregação e os lares em BH.",
          source: "Landing Page - Quer Saber Mais",
        },
        submitted_at: new Date().toISOString(),
      }

      const { error } = await supabase.from("form_submissions").insert(payload)

      if (error) {
        console.warn("Aviso na inserção de contato:", error.message)
      }

      setSubmitted(true)
      toast.success("Recebemos sua mensagem com alegria!", {
        description: "Um irmão ou família próxima entrará em contato em breve para conversar.",
        duration: 6000,
      })
      reset()
    } catch (err) {
      console.error("Erro ao enviar contato:", err)
      toast.error("Ocorreu um erro ao enviar seu contato. Tente novamente.")
    } finally {
      setSubmitting(false)
    }
  }

  return (
    <section id="contato" className="scroll-mt-20 py-16 sm:py-24 border-b border-border/40">
      <div className="mx-auto max-w-3xl px-4 sm:px-6 lg:px-8 text-center">
        {/* Title */}
        <h2 className="text-2xl sm:text-3xl md:text-4xl font-extrabold tracking-tight text-foreground">
          Quer saber mais?
        </h2>

        {/* Subtitle matching mockup */}
        <p className="mt-4 text-xs sm:text-sm md:text-base leading-relaxed text-muted-foreground max-w-2xl mx-auto">
          Se você acessou o conteúdo desse site e quer saber mais sobre nós, não achamos que é suficiente te convidar para uma reunião, gostaríamos de entrar em contato com você e marcar uma conversa. Venha nos conhecer ou solicite uma conversa com uma família próxima da sua região.
        </p>

        {/* Initial prominent CTA buttons */}
        {!showInlineForm && !submitted && (
          <div className="mt-8 flex flex-col sm:flex-row items-center justify-center gap-4">
            <Button
              asChild
              size="lg"
              className="min-h-[48px] px-8 text-sm sm:text-base font-bold rounded-full bg-primary text-primary-foreground hover:bg-primary/90 shadow-md transition-transform active:scale-[0.98] w-full sm:w-auto"
            >
              <Link to="/quero-saber-mais">
                <HeartHandshake className="mr-2 h-5 w-5" />
                Quero Saber Mais
                <ArrowRight className="ml-2 h-4 w-4" />
              </Link>
            </Button>

            <Button
              type="button"
              variant="outline"
              size="lg"
              onClick={() => setShowInlineForm(true)}
              className="min-h-[48px] px-6 text-sm font-semibold rounded-full border-border hover:bg-muted w-full sm:w-auto"
            >
              Enviar Mensagem Rápida
            </Button>

            {onOpenDialog && (
              <Button
                type="button"
                variant="ghost"
                size="lg"
                onClick={onOpenDialog}
                className="min-h-[48px] px-4 text-xs font-semibold rounded-full hover:bg-muted w-full sm:w-auto cursor-pointer"
              >
                Ver Grupos por Bairro
              </Button>
            )}
          </div>
        )}

        {/* Success Confirmation Card */}
        {submitted && (
          <div className="mt-8 rounded-2xl border border-emerald-500/30 bg-emerald-500/10 p-6 text-center shadow-xs animate-section-enter">
            <div className="flex h-12 w-12 mx-auto items-center justify-center rounded-full bg-emerald-500/20 text-emerald-600 dark:text-emerald-400 mb-3">
              <CheckCircle2 className="h-6 w-6" />
            </div>
            <h3 className="text-base sm:text-lg font-bold text-foreground">
              Mensagem enviada com sucesso!
            </h3>
            <p className="mt-1 text-xs sm:text-sm text-muted-foreground max-w-md mx-auto">
              Muito obrigado pelo seu interesse. Em breve entraremos em contato via WhatsApp para uma conversa acolhedora e sem compromisso.
            </p>
            <Button
              type="button"
              variant="outline"
              size="sm"
              onClick={() => {
                setSubmitted(false)
                setShowInlineForm(false)
              }}
              className="mt-4 min-h-[40px] rounded-full"
            >
              Enviar outra mensagem
            </Button>
          </div>
        )}

        {/* Inline Quick-Contact Form */}
        {showInlineForm && !submitted && (
          <div className="mt-8 rounded-2xl border border-border/70 bg-card p-6 sm:p-8 shadow-sm text-left animate-section-enter">
            <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                {/* Nome Completo */}
                <Field>
                  <FieldLabel htmlFor="fullName" className="text-xs font-semibold">
                    Seu Nome Completo *
                  </FieldLabel>
                  <Input
                    id="fullName"
                    placeholder="Ex: João da Silva"
                    {...register("fullName")}
                    className="min-h-[44px] rounded-lg mt-1"
                  />
                  {errors.fullName && (
                    <FieldError className="text-xs text-destructive mt-1">
                      {errors.fullName.message}
                    </FieldError>
                  )}
                </Field>

                {/* WhatsApp */}
                <Field>
                  <FieldLabel htmlFor="phone" className="text-xs font-semibold">
                    WhatsApp com DDD *
                  </FieldLabel>
                  <Controller
                    name="phone"
                    control={control}
                    render={({ field }) => (
                      <Input
                        id="phone"
                        type="tel"
                        placeholder="(31) 90000-0000"
                        value={field.value}
                        onChange={(e) => field.onChange(formatPhone(e.target.value))}
                        className="min-h-[44px] rounded-lg mt-1"
                      />
                    )}
                  />
                  {errors.phone && (
                    <FieldError className="text-xs text-destructive mt-1">
                      {errors.phone.message}
                    </FieldError>
                  )}
                </Field>
              </div>

              {/* Região de BH */}
              <Field>
                <FieldLabel htmlFor="region" className="text-xs font-semibold">
                  Sua Região / Bairro na Grande BH *
                </FieldLabel>
                <Controller
                  name="region"
                  control={control}
                  render={({ field }) => (
                    <Select value={field.value} onValueChange={field.onChange}>
                      <SelectTrigger id="region" className="min-h-[44px] rounded-lg mt-1">
                        <SelectValue placeholder="Selecione sua região mais próxima" />
                      </SelectTrigger>
                      <SelectContent>
                        {regionsBH.map((reg) => (
                          <SelectItem key={reg} value={reg}>
                            {reg}
                          </SelectItem>
                        ))}
                      </SelectContent>
                    </Select>
                  )}
                />
                {errors.region && (
                  <FieldError className="text-xs text-destructive mt-1">
                    {errors.region.message}
                  </FieldError>
                )}
              </Field>

              {/* Mensagem Opcional */}
              <Field>
                <FieldLabel htmlFor="message" className="text-xs font-semibold">
                  Mensagem ou Dúvida (Opcional)
                </FieldLabel>
                <Textarea
                  id="message"
                  rows={3}
                  placeholder="Conte um pouco sobre você ou o que gostaria de conhecer..."
                  {...register("message")}
                  className="rounded-lg mt-1 resize-none"
                />
              </Field>

              <div className="pt-2 flex flex-col sm:flex-row items-center justify-between gap-3">
                <Button
                  type="button"
                  variant="ghost"
                  onClick={() => setShowInlineForm(false)}
                  className="min-h-[44px] text-xs text-muted-foreground w-full sm:w-auto"
                >
                  Cancelar
                </Button>

                <Button
                  type="submit"
                  disabled={submitting}
                  className="min-h-[44px] w-full sm:w-auto px-6 rounded-full font-bold bg-primary text-primary-foreground hover:bg-primary/90"
                >
                  {submitting ? (
                    <>
                      <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                      Enviando...
                    </>
                  ) : (
                    <>
                      <Send className="mr-2 h-4 w-4" />
                      Enviar Contato
                    </>
                  )}
                </Button>
              </div>
            </form>
          </div>
        )}
      </div>
    </section>
  )
}
