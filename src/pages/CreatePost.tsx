import { useForm, Controller } from "react-hook-form"
import { postSchema, type PostValue } from "../lib/schemas"
import { zodResolver } from "@hookform/resolvers/zod"
import { Button } from "@/components/ui/button"
import {
  Card,
  CardContent,
  CardDescription,
  CardFooter,
  CardHeader,
  CardTitle,
} from "@/components/ui/card"
import {
  Field,
  FieldError,
  FieldGroup,
  FieldLabel,
  FieldDescription,
} from "@/components/ui/field"
import { Input } from "@/components/ui/input"
import { Textarea } from "@/components/ui/textarea"
import { Switch } from "@/components/ui/switch"
import {
  Loader2,
  CalendarIcon,
  BellIcon,
  ImageIcon,
  XIcon,
  PlusIcon,
  MapPin,
  Globe,
  Lock,
} from "lucide-react"
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select"
import { useState, useRef, useEffect } from "react"
import supabase from "@/lib/supabase"
import { toast } from "sonner"
import { useNavigate, useSearchParams } from "react-router-dom"

interface RetreatOption {
  id: string
  title: string
}

export default function CreatePost() {
  const navigate = useNavigate()
  const [searchParams] = useSearchParams()
  const initialRetreatId = searchParams.get("retreatId") || ""
  const initialLabel = searchParams.get("label") || ""

  const [submitting, setSubmitting] = useState(false)
  const [retreats, setRetreats] = useState<RetreatOption[]>([])

  const form = useForm<PostValue>({
    resolver: zodResolver(postSchema),
    defaultValues: {
      title: "",
      content: "",
      category: initialRetreatId ? "evento" : "geral",
      isPublic: true,
      isPublished: true,
      imageUrls: [],
      eventStartDate: null,
      eventEndDate: null,
      eventLocation: "",
      retreatId: initialRetreatId || null,
      eventLabel: initialLabel || "",
      mediaResourceId: null,
      formId: null,
    },
  })

  const [selectedImages, setSelectedImages] = useState<
    { file: File; id: string }[]
  >([])
  const fileInputRef = useRef<HTMLInputElement>(null)

  const selectedCategory = form.watch("category")

  // Carrega retiros disponíveis para vincular comunicados de eventos
  useEffect(() => {
    async function loadRetreats() {
      const { data } = await supabase
        .from("retreats")
        .select("id, title")
        .order("created_at", { ascending: false })

      if (data) {
        setRetreats(data)
      }
    }

    loadRetreats()
  }, [])

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const files = Array.from(e.target.files || [])
    if (selectedImages.length + files.length > 3) {
      toast.error("Você pode adicionar no máximo 3 imagens.")
      return
    }

    const newImages = files.map((file) => ({
      file,
      id: Math.random().toString(36).substring(7),
    }))

    setSelectedImages((prev) => [...prev, ...newImages])
  }

  const removeImage = (id: string) => {
    setSelectedImages((prev) => prev.filter((img) => img.id !== id))
  }

  async function onSubmit(data: PostValue) {
    setSubmitting(true)

    const operation = async () => {
      const {
        data: { session },
      } = await supabase.auth.getSession()
      if (!session?.user) throw new Error("Usuário não autenticado")

      const { data: profile, error: profileError } = await supabase
        .from("profiles")
        .select("id")
        .eq("user_id", session.user.id)
        .single()

      if (profileError || !profile) throw new Error("Perfil não encontrado")

      let uploadedUrls: string[] = []

      if (selectedImages.length > 0) {
        const uploadPromises = selectedImages.map(async (img) => {
          const fileExt = img.file.name.split(".").pop()
          const fileName = `${Math.random().toString(36).substring(2)}.${fileExt}`
          const filePath = `${session.user.id}/${fileName}`

          const { error: uploadError } = await supabase.storage
            .from("post-images")
            .upload(filePath, img.file)

          if (uploadError) throw uploadError

          const {
            data: { publicUrl },
          } = supabase.storage.from("post-images").getPublicUrl(filePath)

          return publicUrl
        })

        uploadedUrls = await Promise.all(uploadPromises)
      }

      const { error: insertError } = await supabase.from("posts").insert({
        title: data.title,
        content: data.content,
        category: data.category,
        is_public: data.isPublic,
        is_published: data.isPublished,
        author_id: profile.id,
        image_urls: uploadedUrls.length > 0 ? uploadedUrls : null,
        event_start_date:
          data.category === "encontro" && data.eventStartDate
            ? new Date(data.eventStartDate).toISOString()
            : null,
        event_end_date:
          data.category === "encontro" && data.eventEndDate
            ? new Date(data.eventEndDate).toISOString()
            : null,
        event_location:
          data.category === "encontro" && data.eventLocation
            ? data.eventLocation
            : null,
        retreat_id:
          data.category === "evento" && data.retreatId ? data.retreatId : null,
        event_label:
          data.category === "evento" && data.eventLabel
            ? data.eventLabel
            : null,
      })

      if (insertError) throw insertError
    }

    toast.promise(operation(), {
      loading: "Publicando comunicado...",
      success: () => {
        navigate("/dashboard")
        return "Comunicado publicado com sucesso!"
      },
      error: (error: any) => {
        console.error("Erro ao adicionar publicação:", error)
        return error.message || "Erro ao publicar comunicado."
      },
      finally: () => setSubmitting(false),
    })
  }

  // Define se imagens são permitidas (para estudos/formulários o foco é o conteúdo)
  const allowImages = selectedCategory !== "estudo" && selectedCategory !== "formulario"

  return (
    <div className="mx-auto max-w-3xl animate-in duration-500 fade-in slide-in-from-bottom-4 pb-12">
      <div className="mb-8 flex items-center gap-3 border-b border-border pb-6">
        <div className="flex h-12 w-12 items-center justify-center rounded-2xl bg-primary/10 shadow-sm">
          <BellIcon className="h-6 w-6 text-primary" />
        </div>
        <div>
          <h1 className="text-2xl sm:text-3xl font-bold tracking-tight">
            Nova Publicação / Comunicado
          </h1>
          <p className="mt-1 text-xs sm:text-sm text-muted-foreground">
            Crie comunicados, encontros casuais, pedidos de oração ou notícias para a igreja.
          </p>
        </div>
      </div>

      <Card className="overflow-hidden rounded-3xl border-border bg-card/40 shadow-xl backdrop-blur-sm">
        <CardHeader className="p-6 sm:p-8">
          <CardTitle className="text-xl sm:text-2xl font-bold">
            Detalhes do Comunicado
          </CardTitle>
          <CardDescription>
            Escolha o tipo de publicação e preencha as informações necessárias.
          </CardDescription>
        </CardHeader>

        <CardContent className="px-6 pb-8 sm:px-8">
          <form
            id="create-post-form"
            onSubmit={form.handleSubmit(onSubmit)}
            className="space-y-6"
          >
            <FieldGroup className="space-y-6">
              {/* Título */}
              <Controller
                name="title"
                control={form.control}
                render={({ field, fieldState }) => (
                  <Field data-invalid={fieldState.invalid}>
                    <FieldLabel>Título do Comunicado*</FieldLabel>
                    <Input
                      {...field}
                      placeholder="Ex: Mutirão Comunitário no São Gabriel"
                      autoComplete="off"
                      className="h-11 rounded-xl bg-background/50"
                    />
                    <FieldError errors={[fieldState.error]} />
                  </Field>
                )}
              />

              {/* Linha com Categoria e Visibilidade */}
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <Controller
                  name="category"
                  control={form.control}
                  render={({ field, fieldState }) => (
                    <Field data-invalid={fieldState.invalid}>
                      <FieldLabel>Tipo de Publicação*</FieldLabel>
                      <Select
                        value={field.value}
                        onValueChange={(val) => {
                          field.onChange(val)
                          // Se for pedido de oração, default para não-público (sensível)
                          if (val === "oracao") {
                            form.setValue("isPublic", false)
                          }
                        }}
                      >
                        <SelectTrigger className="h-11 w-full rounded-xl bg-background/50">
                          <SelectValue placeholder="Selecione o tipo" />
                        </SelectTrigger>
                        <SelectContent>
                          <SelectItem value="geral">Aviso Geral / Reforma / Diaconato</SelectItem>
                          <SelectItem value="encontro">Encontro Casual na Cidade (Agenda/Calendário)</SelectItem>
                          <SelectItem value="evento">Comunicado de Evento / Retiro Oficial</SelectItem>
                          <SelectItem value="oracao">Pedido de Oração</SelectItem>
                          <SelectItem value="missoes">Missões & Evangelismo</SelectItem>
                          <SelectItem value="estudo">Aviso de Estudo & Catequese</SelectItem>
                          <SelectItem value="formulario">Aviso de Formulário</SelectItem>
                        </SelectContent>
                      </Select>
                      <FieldError errors={[fieldState.error]} />
                    </Field>
                  )}
                />

                {/* Switch de Visibilidade Pública vs Apenas Discípulos */}
                <Controller
                  name="isPublic"
                  control={form.control}
                  render={({ field }) => (
                    <Field className="flex flex-col justify-center rounded-xl border border-border/60 bg-background/40 p-3">
                      <div className="flex items-center justify-between">
                        <FieldLabel className="flex items-center gap-1.5 cursor-pointer text-xs font-semibold">
                          {field.value ? (
                            <>
                              <Globe className="h-4 w-4 text-emerald-600 dark:text-emerald-400" />
                              <span>Público na Landing Page</span>
                            </>
                          ) : (
                            <>
                              <Lock className="h-4 w-4 text-amber-600 dark:text-amber-400" />
                              <span>Apenas Discípulos Vinculados</span>
                            </>
                          )}
                        </FieldLabel>
                        <Switch
                          checked={field.value}
                          onCheckedChange={field.onChange}
                        />
                      </div>
                      <FieldDescription className="text-[11px] mt-1">
                        {field.value
                          ? "Visível para qualquer visitante no site e na landing page."
                          : "Oculto para visitantes. Apenas discípulos logados e vinculados têm acesso."}
                      </FieldDescription>
                    </Field>
                  )}
                />
              </div>

              {/* Campos específicos para Encontro Casual */}
              {selectedCategory === "encontro" && (
                <div className="rounded-2xl border border-primary/20 bg-primary/5 p-4 sm:p-5 space-y-4">
                  <div className="flex items-center gap-2 text-xs font-bold uppercase tracking-wider text-primary">
                    <CalendarIcon className="h-4 w-4" />
                    <span>Dados do Encontro na Cidade (Alimenta o Calendário)</span>
                  </div>

                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                    <Controller
                      name="eventStartDate"
                      control={form.control}
                      render={({ field, fieldState }) => (
                        <Field data-invalid={fieldState.invalid}>
                          <FieldLabel>Data e Horário de Início*</FieldLabel>
                          <Input
                            {...field}
                            type="datetime-local"
                            className="h-11 rounded-xl bg-background"
                            value={field.value || ""}
                            onChange={(e) => field.onChange(e.target.value || null)}
                            required
                          />
                          <FieldError errors={[fieldState.error]} />
                        </Field>
                      )}
                    />

                    <Controller
                      name="eventEndDate"
                      control={form.control}
                      render={({ field, fieldState }) => (
                        <Field data-invalid={fieldState.invalid}>
                          <FieldLabel>Término (Opcional)</FieldLabel>
                          <Input
                            {...field}
                            type="datetime-local"
                            className="h-11 rounded-xl bg-background"
                            value={field.value || ""}
                            onChange={(e) => field.onChange(e.target.value || null)}
                          />
                          <FieldError errors={[fieldState.error]} />
                        </Field>
                      )}
                    />
                  </div>

                  <Controller
                    name="eventLocation"
                    control={form.control}
                    render={({ field }) => (
                      <Field>
                        <FieldLabel className="flex items-center gap-1.5">
                          <MapPin className="h-3.5 w-3.5 text-primary" />
                          <span>Local do Encontro</span>
                        </FieldLabel>
                        <Input
                          {...field}
                          value={field.value || ""}
                          placeholder="Ex: Parque Municipal ou Praça da Liberdade"
                          className="h-11 rounded-xl bg-background"
                        />
                      </Field>
                    )}
                  />
                </div>
              )}

              {/* Campos específicos para Comunicados de Eventos/Retiros */}
              {selectedCategory === "evento" && (
                <div className="rounded-2xl border border-amber-500/20 bg-amber-500/5 p-4 sm:p-5 space-y-4">
                  <div className="flex items-center gap-2 text-xs font-bold uppercase tracking-wider text-amber-700 dark:text-amber-400">
                    <CalendarIcon className="h-4 w-4" />
                    <span>Vínculo ao Evento Oficial</span>
                  </div>

                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                    <Controller
                      name="retreatId"
                      control={form.control}
                      render={({ field }) => (
                        <Field>
                          <FieldLabel>Selecione o Evento/Retiro*</FieldLabel>
                          <Select
                            value={field.value || ""}
                            onValueChange={(val) => field.onChange(val || null)}
                          >
                            <SelectTrigger className="h-11 w-full rounded-xl bg-background">
                              <SelectValue placeholder="Escolha o evento" />
                            </SelectTrigger>
                            <SelectContent>
                              {retreats.map((r) => (
                                <SelectItem key={r.id} value={r.id}>
                                  {r.title}
                                </SelectItem>
                              ))}
                            </SelectContent>
                          </Select>
                        </Field>
                      )}
                    />

                    <Controller
                      name="eventLabel"
                      control={form.control}
                      render={({ field }) => (
                        <Field>
                          <FieldLabel>Etiqueta / Tag do Comunicado</FieldLabel>
                          <Input
                            {...field}
                            value={field.value || ""}
                            placeholder="Ex: Vagas Abertas, Transporte, Oração, Ânimo"
                            className="h-11 rounded-xl bg-background"
                          />
                        </Field>
                      )}
                    />
                  </div>
                </div>
              )}

              {/* Imagens (se categoria permitir) */}
              {allowImages && (
                <div className="space-y-3">
                  <FieldLabel className="flex items-center gap-2">
                    <span>Fotos Ilustrativas (Máximo 3)</span>
                    <ImageIcon className="h-4 w-4 text-muted-foreground" />
                  </FieldLabel>

                  <div className="grid grid-cols-2 gap-3 sm:grid-cols-4">
                    {selectedImages.map((img) => (
                      <div
                        key={img.id}
                        className="group relative aspect-square overflow-hidden rounded-2xl border border-border/50 bg-muted/30 shadow-sm"
                      >
                        <img
                          src={URL.createObjectURL(img.file)}
                          alt="Prévia"
                          className="h-full w-full object-cover transition-opacity duration-300"
                        />
                        <button
                          type="button"
                          onClick={() => removeImage(img.id)}
                          className="text-destructive-foreground absolute top-2 right-2 rounded-full bg-destructive/90 p-1.5 opacity-0 shadow-lg transition-all group-hover:opacity-100 min-h-[32px] min-w-[32px] flex items-center justify-center"
                          aria-label="Remover foto"
                        >
                          <XIcon className="h-3.5 w-3.5" />
                        </button>
                      </div>
                    ))}

                    {selectedImages.length < 3 && (
                      <button
                        type="button"
                        onClick={() => fileInputRef.current?.click()}
                        className="flex aspect-square flex-col items-center justify-center rounded-2xl border-2 border-dashed border-border/50 bg-muted/20 text-muted-foreground transition-all hover:border-primary/50 hover:bg-primary/5 hover:text-primary min-h-[44px]"
                      >
                        <PlusIcon className="mb-2 h-7 w-7 opacity-50" />
                        <span className="text-[10px] font-bold tracking-widest uppercase">
                          Adicionar Foto
                        </span>
                      </button>
                    )}
                  </div>

                  <input
                    type="file"
                    ref={fileInputRef}
                    onChange={handleFileChange}
                    accept="image/*"
                    multiple
                    className="hidden"
                  />
                </div>
              )}

              {/* Conteúdo / Mensagem */}
              <Controller
                name="content"
                control={form.control}
                render={({ field, fieldState }) => (
                  <Field data-invalid={fieldState.invalid}>
                    <FieldLabel>Mensagem Completa*</FieldLabel>
                    <Textarea
                      {...field}
                      placeholder="Descreva aqui as informações importantes para a igreja..."
                      className="min-h-[160px] rounded-2xl border-border/50 bg-background/50 p-4 transition-all focus:ring-2 focus:ring-primary/20"
                    />
                    <FieldError errors={[fieldState.error]} />
                  </Field>
                )}
              />
            </FieldGroup>
          </form>
        </CardContent>

        <CardFooter className="px-6 pb-8 sm:px-8">
          <Button
            type="submit"
            form="create-post-form"
            className="min-h-[48px] h-12 w-full rounded-2xl bg-primary font-bold text-primary-foreground shadow-lg shadow-primary/20 transition-all hover:bg-primary/90 active:scale-[0.98]"
            disabled={submitting}
          >
            {submitting ? (
              <>
                <Loader2 className="mr-2 h-5 w-5 animate-spin" />
                Publicando...
              </>
            ) : (
              "Publicar Comunicado"
            )}
          </Button>
        </CardFooter>
      </Card>
    </div>
  )
}
