import { useState } from "react"
import { Link } from "react-router-dom"
import { useForm, Controller } from "react-hook-form"
import * as z from "zod"
import { zodResolver } from "@hookform/resolvers/zod"
import { toast } from "sonner"
import {
  ArrowLeft,
  HeartHandshake,
  Coffee,
  Home,
  Send,
  Loader2,
  CheckCircle2,
} from "lucide-react"
import supabase from "@/lib/supabase"
import { REGIONS_BH } from "@/data/landingData"
import { ChurchLogo } from "@/components/icons/ChurchLogo"
import { ThemeToggle } from "@/components/ThemeToggle"
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
import { LandingFooter } from "@/components/landing/LandingFooter"

const contactSchema = z.object({
  fullName: z.string().min(3, "Por favor, informe seu nome completo"),
  phone: z
    .string()
    .min(10, "Informe um WhatsApp válido com DDD")
    .regex(/^\(?\d{2}\)?\s?\d{4,5}-?\d{4}$/, "Formato inválido. Use (31) 9XXXX-XXXX"),
  region: z.string().min(1, "Selecione a sua região ou bairro mais próximo"),
  howDidYouFindUs: z.string().optional(),
  message: z.string().optional(),
})

type ContactFormValues = z.infer<typeof contactSchema>

export default function QueroSaberMais() {
  const [submitting, setSubmitting] = useState(false)
  const [submitted, setSubmitted] = useState(false)

  const {
    register,
    handleSubmit,
    control,
    reset,
    formState: { errors },
  } = useForm<ContactFormValues>({
    resolver: zodResolver(contactSchema),
    defaultValues: {
      fullName: "",
      phone: "",
      region: "",
      howDidYouFindUs: "",
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

  const onSubmit = async (values: ContactFormValues) => {
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
          detalhes: `Como conheceu: ${values.howDidYouFindUs || "Não informado"} | Mensagem: ${values.message?.trim() || "Deseja conversar com os discípulos e conhecer a comunhão nos lares."}`,
          source: "Página Dedicada - Quero Saber Mais",
        },
        submitted_at: new Date().toISOString(),
      }

      const { error } = await supabase.from("form_submissions").insert(payload)

      if (error) {
        console.warn("Aviso na inserção de contato:", error.message)
      }

      setSubmitted(true)
      toast.success("Recebemos sua mensagem com alegria!", {
        description: "Um irmão ou família próxima entrará em contato em breve via WhatsApp.",
        duration: 7000,
      })
      reset()
    } catch (err) {
      console.error("Erro ao enviar pedido de contato:", err)
      toast.error("Ocorreu um erro ao enviar sua mensagem. Tente novamente.")
    } finally {
      setSubmitting(false)
    }
  }

  return (
    <div className="flex min-h-screen w-full flex-col overflow-x-hidden bg-background text-foreground antialiased selection:bg-primary/20 selection:text-primary">
      {/* Top Header */}
      <header className="sticky top-0 z-50 w-full border-b border-border/40 bg-background/90 backdrop-blur-md">
        <div className="mx-auto flex h-16 max-w-5xl items-center justify-between px-4 sm:px-6 lg:px-8">
          <Link to="/" className="flex items-center gap-2">
            <ChurchLogo size="md" />
          </Link>

          <div className="flex items-center gap-3">
            <Button asChild variant="ghost" size="sm" className="min-h-[44px] gap-1.5 text-xs sm:text-sm">
              <Link to="/">
                <ArrowLeft className="h-4 w-4" />
                <span className="hidden sm:inline">Voltar ao início</span>
                <span className="sm:hidden">Início</span>
              </Link>
            </Button>
            <ThemeToggle />
          </div>
        </div>
      </header>

      {/* Main Content */}
      <main className="flex-1 w-full py-12 sm:py-16">
        <div className="mx-auto max-w-4xl px-4 sm:px-6 lg:px-8">
          {/* Hero Welcome */}
          <div className="text-center max-w-2xl mx-auto space-y-3">
            <h1 className="text-3xl sm:text-4xl md:text-5xl font-extrabold tracking-tight text-foreground">
              Caminhe conosco
            </h1>

            <p className="text-xs sm:text-sm md:text-base leading-relaxed text-muted-foreground">
              A Igreja em Belo Horizonte não é uma empresa ou templo de tijolos, mas uma família de discípulos reunida de casa em casa. Não achamos suficiente apenas convidar para uma reunião: queremos ouvir você, tomar um café e conversar com calma.
            </p>
          </div>

          {/* 3 Step Relational Cards */}
          <div className="mt-10 grid grid-cols-1 md:grid-cols-3 gap-5">
            <div className="rounded-xl border border-border/60 bg-card p-5 shadow-2xs">
              <div className="flex h-10 w-10 items-center justify-center rounded-lg bg-primary/10 text-primary mb-3">
                <HeartHandshake className="h-5 w-5" />
              </div>
              <h2 className="text-base font-bold text-foreground">1. Contato Acolhedor</h2>
              <p className="mt-1 text-xs text-muted-foreground leading-relaxed">
                Um irmão, irmã ou casal do seu bairro entrará em contato via WhatsApp para uma conversa acolhedora e sem compromisso.
              </p>
            </div>

            <div className="rounded-xl border border-border/60 bg-card p-5 shadow-2xs">
              <div className="flex h-10 w-10 items-center justify-center rounded-lg bg-primary/10 text-primary mb-3">
                <Coffee className="h-5 w-5" />
              </div>
              <h2 className="text-base font-bold text-foreground">2. Um Café ou Conversa</h2>
              <p className="mt-1 text-xs text-muted-foreground leading-relaxed">
                Marcamos um bate-papo informal para nos conhecermos, tirarmos dúvidas sobre as Escrituras e compartilharmos a vida de Cristo.
              </p>
            </div>

            <div className="rounded-xl border border-border/60 bg-card p-5 shadow-2xs">
              <div className="flex h-10 w-10 items-center justify-center rounded-lg bg-primary/10 text-primary mb-3">
                <Home className="h-5 w-5" />
              </div>
              <h2 className="text-base font-bold text-foreground">3. A Mesa nos Lares</h2>
              <p className="mt-1 text-xs text-muted-foreground leading-relaxed">
                Você é bem-vindo a conhecer um Grupo Caseiro no seu bairro, experimentar a Ceia ao redor da mesa e vivenciar o discipulado mútuo.
              </p>
            </div>
          </div>

          {/* Contact Form Card */}
          <div className="mt-10 rounded-xl border border-border/80 bg-card p-6 sm:p-10 shadow-xs">
            {submitted ? (
              <div className="text-center py-8 space-y-4 animate-section-enter">
                <div className="flex h-14 w-14 mx-auto items-center justify-center rounded-full bg-emerald-500/20 text-emerald-600 dark:text-emerald-400">
                  <CheckCircle2 className="h-8 w-8" />
                </div>
                <h2 className="text-xl sm:text-2xl font-bold text-foreground">
                  Mensagem recebida com alegria!
                </h2>
                <p className="text-xs sm:text-sm text-muted-foreground max-w-md mx-auto leading-relaxed">
                  Agradecemos de coração o seu contato. Um dos cooperadores da sua região entrará em contato com você via WhatsApp em breve.
                </p>
                <div className="pt-4 flex flex-col sm:flex-row justify-center gap-3">
                  <Button asChild className="min-h-[44px] rounded-full px-6">
                    <Link to="/">Voltar à Página Inicial</Link>
                  </Button>
                  <Button
                    type="button"
                    variant="outline"
                    onClick={() => setSubmitted(false)}
                    className="min-h-[44px] rounded-full"
                  >
                    Enviar outra mensagem
                  </Button>
                </div>
              </div>
            ) : (
              <div>
                <div className="border-b border-border/40 pb-5 mb-6">
                  <h2 className="text-xl font-bold text-foreground">
                    Preencha seus dados para conversarmos
                  </h2>
                  <p className="text-xs text-muted-foreground mt-1">
                    Não coletamos dados para listas institucionais. O objetivo é unicamente conectar você a irmãos da congregação perto de onde você mora.
                  </p>
                </div>

                <form onSubmit={handleSubmit(onSubmit)} className="space-y-5">
                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-5">
                    {/* Nome Completo */}
                    <Field>
                      <FieldLabel htmlFor="fullName" className="text-xs font-semibold">
                        Seu Nome Completo *
                      </FieldLabel>
                      <Input
                        id="fullName"
                        placeholder="Ex: Pedro Henrique"
                        {...register("fullName")}
                        className="min-h-[44px] rounded-lg mt-1"
                      />
                      {errors.fullName && (
                        <FieldError className="text-xs text-destructive mt-1">
                          {errors.fullName.message}
                        </FieldError>
                      )}
                    </Field>

                    {/* Telefone / WhatsApp */}
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
                      Sua Região ou Bairro na Grande BH *
                    </FieldLabel>
                    <Controller
                      name="region"
                      control={control}
                      render={({ field }) => (
                        <Select value={field.value} onValueChange={field.onChange}>
                          <SelectTrigger id="region" className="min-h-[44px] rounded-lg mt-1">
                            <SelectValue placeholder="Selecione o setor mais próximo de sua casa" />
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

                  {/* Como nos conheceu */}
                  <Field>
                    <FieldLabel htmlFor="howDidYouFindUs" className="text-xs font-semibold">
                      Como conheceu a Igreja em BH? (Opcional)
                    </FieldLabel>
                    <Input
                      id="howDidYouFindUs"
                      placeholder="Ex: Um amigo/familiar, redes sociais, no trabalho, nas ruas..."
                      {...register("howDidYouFindUs")}
                      className="min-h-[44px] rounded-lg mt-1"
                    />
                  </Field>

                  {/* Mensagem Opcional */}
                  <Field>
                    <FieldLabel htmlFor="message" className="text-xs font-semibold">
                      Mensagem ou Dúvida (Opcional)
                    </FieldLabel>
                    <Textarea
                      id="message"
                      rows={4}
                      placeholder="Fique à vontade para nos contar o que busca ou tirar qualquer dúvida..."
                      {...register("message")}
                      className="rounded-lg mt-1 resize-none"
                    />
                  </Field>

                  <div className="pt-3 flex flex-col sm:flex-row items-center justify-between gap-3">
                    <Button asChild variant="ghost" className="min-h-[44px] text-xs text-muted-foreground">
                      <Link to="/">Voltar à Página Inicial</Link>
                    </Button>

                    <Button
                      type="submit"
                      disabled={submitting}
                      className="min-h-[48px] w-full sm:w-auto px-8 rounded-full font-bold bg-primary text-primary-foreground hover:bg-primary/90 shadow-md"
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
        </div>
      </main>

      {/* Footer */}
      <LandingFooter />
    </div>
  )
}
