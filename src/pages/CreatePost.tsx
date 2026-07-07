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
} from "@/components/ui/field"
import { Input } from "@/components/ui/input"
import { Textarea } from "@/components/ui/textarea"
import {
  Loader2,
  CalendarIcon,
  BellIcon,
  ImageIcon,
  XIcon,
  PlusIcon,
} from "lucide-react"
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select"
import { useState, useRef } from "react"
import supabase from "@/lib/supabase"
import { toast } from "sonner"
import { useNavigate } from "react-router-dom"

export default function CreatePost() {
  const navigate = useNavigate()
  const [submitting, setSubmitting] = useState(false)

  const form = useForm<PostValue>({
    resolver: zodResolver(postSchema),
    defaultValues: {
      title: "",
      content: "",
      category: "noticia",
      eventStartDate: null,
      eventEndDate: null,
      isPublished: true,
      imageUrls: [],
    },
  })

  const [selectedImages, setSelectedImages] = useState<
    { file: File; id: string }[]
  >([])
  const fileInputRef = useRef<HTMLInputElement>(null)

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

      const uploadedUrls = await Promise.all(uploadPromises)

      const { error: insertError } = await supabase.from("posts").insert({
        title: data.title,
        content: data.content,
        category: data.category as any,
        event_start_date: data.eventStartDate
          ? new Date(data.eventStartDate).toISOString()
          : null,
        event_end_date: data.eventEndDate
          ? new Date(data.eventEndDate).toISOString()
          : null,
        is_published: data.isPublished,
        author_id: profile.id,
        image_urls: uploadedUrls,
      })

      if (insertError) throw insertError
    }

    toast.promise(operation(), {
      loading: "Publicando aviso...",
      success: () => {
        navigate("/")
        return "Aviso publicado com sucesso!"
      },
      error: (error: any) => {
        console.error("Error adding post:", error)
        return error.message || "Erro ao publicar aviso."
      },
      finally: () => setSubmitting(false),
    })
  }

  return (
    <div className="mx-auto max-w-3xl animate-in duration-500 fade-in slide-in-from-bottom-4">
      <div className="mb-8 flex items-center gap-3 border-b border-border pb-6">
        <div className="flex h-12 w-12 items-center justify-center rounded-2xl bg-primary/10 shadow-sm">
          <BellIcon className="h-6 w-6 text-primary" />
        </div>
        <div>
          <h1 className="text-3xl font-bold tracking-tight">
            Nova Notícia / Aviso
          </h1>
          <p className="mt-1 text-muted-foreground">
            Crie um conteúdo para o mural da igreja.
          </p>
        </div>
      </div>

      <Card className="overflow-hidden rounded-3xl border-border bg-card/30 shadow-xl backdrop-blur-sm">
        <CardHeader className="p-8">
          <CardTitle className="text-2xl font-bold">
            Conteúdo do Aviso
          </CardTitle>
          <CardDescription>
            Escolha uma categoria e preencha os detalhes para publicar.
          </CardDescription>
        </CardHeader>
        <CardContent className="px-8 pb-8">
          <form
            id="create-post-form"
            onSubmit={form.handleSubmit(onSubmit)}
            className="space-y-8"
          >
            <FieldGroup className="space-y-6">
              <Controller
                name="title"
                control={form.control}
                render={({ field, fieldState }) => (
                  <Field data-invalid={fieldState.invalid}>
                    <FieldLabel>Título do Aviso*</FieldLabel>
                    <Input
                      {...field}
                      placeholder="Ex: Reunião Geral de Oração"
                      autoComplete="off"
                      className="h-11 rounded-xl bg-background/50"
                    />
                    <FieldError errors={[fieldState.error]} />
                  </Field>
                )}
              />

              <div className="grid grid-cols-1 gap-6 pt-2 md:grid-cols-2 lg:grid-cols-3">
                <div
                  className={
                    form.watch("category") === "evento"
                      ? "col-span-1"
                      : "md:col-span-2 lg:col-span-3"
                  }
                >
                  <Controller
                    name="category"
                    control={form.control}
                    render={({ field, fieldState }) => (
                      <Field data-invalid={fieldState.invalid}>
                        <FieldLabel>Categoria*</FieldLabel>
                        <Select
                          value={field.value}
                          onValueChange={field.onChange}
                          disabled={field.disabled}
                        >
                          <SelectTrigger
                            className="h-11 w-full rounded-xl border border-input bg-background/50 px-4 text-sm focus:ring-2 focus:ring-primary/20"
                            size="lg"
                          >
                            <SelectValue placeholder="Selecione uma categoria" />
                          </SelectTrigger>
                          <SelectContent position="popper">
                            <SelectItem value="aviso">Aviso</SelectItem>
                            <SelectItem value="evento">Evento</SelectItem>
                            <SelectItem value="noticia">Notícia</SelectItem>
                            <SelectItem value="oracao">
                              Pedido de Oração
                            </SelectItem>
                          </SelectContent>
                        </Select>
                        <FieldError errors={[fieldState.error]} />
                      </Field>
                    )}
                  />
                </div>

                {form.watch("category") === "evento" && (
                  <>
                    <Controller
                      name="eventStartDate"
                      control={form.control}
                      render={({ field, fieldState }) => (
                        <Field data-invalid={fieldState.invalid}>
                          <FieldLabel className="flex items-center gap-2">
                            Início*
                            <CalendarIcon className="h-3 w-3 text-muted-foreground" />
                          </FieldLabel>
                          <Input
                            {...field}
                            type="datetime-local"
                            className="h-11 rounded-xl bg-background/50"
                            value={field.value || ""}
                            onChange={(e) =>
                              field.onChange(e.target.value || null)
                            }
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
                          <FieldLabel className="flex items-center gap-2">
                            Término
                            <CalendarIcon className="h-3 w-3 text-muted-foreground" />
                          </FieldLabel>
                          <Input
                            {...field}
                            type="datetime-local"
                            className="h-11 rounded-xl bg-background/50"
                            value={field.value || ""}
                            onChange={(e) =>
                              field.onChange(e.target.value || null)
                            }
                          />
                          <FieldError errors={[fieldState.error]} />
                        </Field>
                      )}
                    />
                  </>
                )}
              </div>

              <div className="space-y-4 pt-2">
                <FieldLabel className="flex items-center gap-2">
                  Imagens (Máximo de 3)
                  <ImageIcon className="h-4 w-4 text-muted-foreground" />
                </FieldLabel>

                <div className="grid grid-cols-2 gap-4 sm:grid-cols-4">
                  {selectedImages.map((img) => (
                    <div
                      key={img.id}
                      className="group relative aspect-square overflow-hidden rounded-2xl border border-border/50 bg-muted/30 shadow-sm"
                    >
                      <img
                        src={URL.createObjectURL(img.file)}
                        alt="Preview"
                        className="h-full w-full object-cover transition-transform duration-500 group-hover:scale-110"
                      />
                      <button
                        type="button"
                        onClick={() => removeImage(img.id)}
                        className="text-destructive-foreground absolute top-2 right-2 rounded-full bg-destructive/90 p-1.5 opacity-0 shadow-lg transition-all group-hover:opacity-100 hover:scale-110"
                      >
                        <XIcon className="h-3.5 w-3.5" />
                      </button>
                    </div>
                  ))}

                  {selectedImages.length < 3 && (
                    <button
                      type="button"
                      onClick={() => fileInputRef.current?.click()}
                      className="flex aspect-square flex-col items-center justify-center rounded-2xl border-2 border-dashed border-border/50 bg-muted/20 text-muted-foreground transition-all hover:border-primary/50 hover:bg-primary/5 hover:text-primary"
                    >
                      <PlusIcon className="mb-2 h-8 w-8 opacity-50" />
                      <span className="text-[10px] font-bold tracking-widest uppercase">
                        Adicionar
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

              <Controller
                name="content"
                control={form.control}
                render={({ field, fieldState }) => (
                  <Field data-invalid={fieldState.invalid}>
                    <FieldLabel>Mensagem Detalhada*</FieldLabel>
                    <Textarea
                      {...field}
                      placeholder="Descreva aqui as informações importantes para a igreja..."
                      className="min-h-[180px] rounded-2xl border-border/50 bg-background/50 p-4 transition-all focus:ring-2 focus:ring-primary/20"
                    />
                    <FieldError errors={[fieldState.error]} />
                  </Field>
                )}
              />
            </FieldGroup>
          </form>
        </CardContent>
        <CardFooter className="px-8 pb-8">
          <Button
            type="submit"
            form="create-post-form"
            className="h-14 w-full rounded-2xl bg-primary font-bold text-primary-foreground shadow-lg shadow-primary/20 transition-all hover:bg-primary/90 active:scale-[0.98]"
            disabled={submitting}
          >
            {submitting ? (
              <>
                <Loader2 className="mr-2 h-5 w-5 animate-spin" />
                Publicando Aviso...
              </>
            ) : (
              "Publicar Aviso"
            )}
          </Button>
        </CardFooter>
      </Card>
    </div>
  )
}
