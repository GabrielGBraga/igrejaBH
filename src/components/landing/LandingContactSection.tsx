import { useState } from "react"
import { useForm, Controller } from "react-hook-form"
import * as z from "zod"
import { zodResolver } from "@hookform/resolvers/zod"
import { toast } from "sonner"
import { Loader2, Send, CheckCircle2 } from "lucide-react"
import supabase from "@/lib/supabase"
import { REGIONS_BH } from "@/data/landingData"
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

export function LandingContactSection() {
  const [showForm, setShowForm] = useState(false)
  const [submitting, setSubmitting] = useState(false)
  const [submitted, setSubmitted] = useState(false)

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
      const submissionId = `sub-quick-${Date.now()}`
      const payload = {
        id: submissionId,
        form_id: "form-apoio-diaconal",
        data: {
          mandatory_full_name: values.fullName.trim(),
          mandatory_phone: values.phone.trim(),
          grupo_caseiro: `Acolhimento - ${values.region}`,
          tipo_necessidade: "Acolhimento / Conhecer Grupo Caseiro",
          urgencia: "Média (Nesta semana)",
          detalhes: values.message?.trim() || "Deseja conhecer a comunhão nos lares em BH.",
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
        description: "Um cooperador vai entrar em contato com você em breve.",
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

        {/* Content Paragraphs matching mockup */}
        <div className="mt-4 space-y-3 text-sm sm:text-base leading-relaxed text-foreground/90 max-w-2xl mx-auto">
          <p>
            Se você acessou o conteúdo desse site e quer saber mais sobre nós, não achamos que é suficiente te convidar para uma reunião. Gostaríamos de entrar em contato com você e marcar uma conversa.
          </p>
          <p>
            Preencha o formulário abaixo e algum cooperador vai entrar em contato com você em breve.
          </p>
        </div>

        {/* Action Button */}
        {!submitted && (
          <div className="mt-6 flex justify-center">
            <Button
              type="button"
              variant="outline"
              size="lg"
              onClick={() => setShowForm((prev) => !prev)}
              className="min-h-[44px] rounded-lg border-border/80 px-8 text-sm font-semibold hover:bg-muted/40 cursor-pointer shadow-2xs"
            >
              {showForm ? "Ocultar Formulário" : "Quero Conhecer"}
            </Button>
          </div>
        )}

        {/* Confirmation State */}
        {submitted ? (
          <div className="mt-8 rounded-xl border border-emerald-500/30 bg-emerald-500/10 p-6 text-center shadow-xs max-w-xl mx-auto">
            <div className="flex h-12 w-12 mx-auto items-center justify-center rounded-full bg-emerald-500/20 text-emerald-600 dark:text-emerald-400 mb-3">
              <CheckCircle2 className="h-6 w-6" />
            </div>
            <h3 className="text-base sm:text-lg font-bold text-foreground">
              Mensagem enviada com sucesso!
            </h3>
            <p className="mt-1 text-xs sm:text-sm text-muted-foreground max-w-md mx-auto">
              Em breve algum cooperador vai entrar em contato com você para conversarmos.
            </p>
            <Button
              type="button"
              variant="outline"
              size="sm"
              onClick={() => {
                setSubmitted(false)
                setShowForm(false)
              }}
              className="mt-4 min-h-[44px] rounded-lg px-5"
            >
              Enviar outra mensagem
            </Button>
          </div>
        ) : (
          showForm && (
            <div className="mt-8 rounded-xl border border-border/70 bg-card p-6 sm:p-8 shadow-xs text-left max-w-xl mx-auto animate-in fade-in duration-200">
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
                      className="min-h-[44px] rounded-md mt-1"
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
                          className="min-h-[44px] rounded-md mt-1"
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
                    Sua Região ou Bairro na Grande BH *
                  </FieldLabel>
                  <Controller
                    name="region"
                    control={control}
                    render={({ field }) => (
                      <Select value={field.value} onValueChange={field.onChange}>
                        <SelectTrigger id="region" className="min-h-[44px] rounded-md mt-1">
                          <SelectValue placeholder="Selecione sua região mais próxima" />
                        </SelectTrigger>
                        <SelectContent>
                          {REGIONS_BH.map((reg) => (
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
                    placeholder="Conte um pouco sobre você ou o que gostaria de conversar..."
                    {...register("message")}
                    className="rounded-md mt-1 resize-none"
                  />
                </Field>

                <div className="pt-2 flex flex-col sm:flex-row items-center justify-end gap-3">
                  <Button
                    type="submit"
                    disabled={submitting}
                    className="min-h-[44px] w-full sm:w-auto px-8 rounded-lg font-semibold bg-primary text-primary-foreground hover:bg-primary/90"
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
          )
        )}
      </div>
    </section>
  )
}
