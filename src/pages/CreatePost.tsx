import { useForm, Controller } from "react-hook-form";
import { postSchema, type PostValue } from "../lib/schemas";
import { zodResolver } from "@hookform/resolvers/zod";
import { Button } from "@/components/ui/button";
import {
  Card,
  CardContent,
  CardDescription,
  CardFooter,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import {
  Field,
  FieldError,
  FieldGroup,
  FieldLabel,
} from "@/components/ui/field";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import { Loader2, ArrowLeftIcon, CalendarIcon, BellIcon, ImageIcon, XIcon, PlusIcon } from "lucide-react";
import { useState, useRef } from "react";
import supabase from "@/lib/supabase";
import { toast } from "sonner";
import { useNavigate } from "react-router-dom";

export default function CreatePost() {
  const navigate = useNavigate();
  const [submitting, setSubmitting] = useState(false);

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
  });

  const [selectedImages, setSelectedImages] = useState<{ file: File; id: string }[]>([]);
  const fileInputRef = useRef<HTMLInputElement>(null);

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const files = Array.from(e.target.files || []);
    if (selectedImages.length + files.length > 3) {
      toast.error("Você pode adicionar no máximo 3 imagens.");
      return;
    }

    const newImages = files.map(file => ({
      file,
      id: Math.random().toString(36).substring(7)
    }));

    setSelectedImages(prev => [...prev, ...newImages]);
  };

  const removeImage = (id: string) => {
    setSelectedImages(prev => prev.filter(img => img.id !== id));
  };

  async function onSubmit(data: PostValue) {
    setSubmitting(true);
    
    const operation = async () => {
        const { data: { session } } = await supabase.auth.getSession();
        if (!session?.user) throw new Error("Usuário não autenticado");

        // Buscar o profile do usuário logado
        const { data: profile, error: profileError } = await supabase
            .from("profiles")
            .select("id")
            .eq("user_id", session.user.id)
            .single();
        
        if (profileError || !profile) throw new Error("Perfil não encontrado");

        // Upload images one by one
        const uploadedUrls: string[] = [];
        for (const img of selectedImages) {
          const fileExt = img.file.name.split('.').pop();
          const fileName = `${Math.random().toString(36).substring(2)}.${fileExt}`;
          const filePath = `${session.user.id}/${fileName}`;

          const { error: uploadError } = await supabase.storage
            .from('post-images')
            .upload(filePath, img.file);

          if (uploadError) throw uploadError;

          const { data: { publicUrl } } = supabase.storage
            .from('post-images')
            .getPublicUrl(filePath);
          
          uploadedUrls.push(publicUrl);
        }

        const { error: insertError } = await supabase
            .from("posts")
            .insert({
                title: data.title,
                content: data.content,
                category: data.category as any,
                event_start_date: data.eventStartDate ? new Date(data.eventStartDate).toISOString() : null,
                event_end_date: data.eventEndDate ? new Date(data.eventEndDate).toISOString() : null,
                is_published: data.isPublished,
                author_id: profile.id,
                image_urls: uploadedUrls
            });
        
        if (insertError) throw insertError;
    };

    toast.promise(operation(), {
      loading: "Publicando aviso...",
      success: () => {
        navigate("/");
        return "Aviso publicado com sucesso!";
      },
      error: (error: any) => {
        console.error("Error adding post:", error);
        return error.message || "Erro ao publicar aviso.";
      },
      finally: () => {
        setSubmitting(false);
      },
    });
  }

  return (
    <div className="relative min-h-screen flex items-center justify-center py-10 px-4 bg-background overflow-x-hidden">
      {/* Background elements */}
      <div className="fixed inset-0 overflow-hidden pointer-events-none z-0">
        <div className="absolute top-[-10%] left-[-10%] w-[40%] h-[40%] rounded-full bg-primary/20 blur-[120px]" />
        <div className="absolute bottom-[-10%] right-[-10%] w-[40%] h-[40%] rounded-full bg-secondary/20 blur-[120px]" />
      </div>

      <Card className="w-full max-w-2xl border-border bg-card/60 backdrop-blur-xl shadow-2xl relative z-10 animate-in fade-in zoom-in-95 duration-500">
        <CardHeader className="space-y-1">
          <div className="flex items-center justify-between mb-4">
            <Button
              variant="ghost"
              size="sm"
              onClick={() => navigate("/")}
              className="group text-muted-foreground hover:text-foreground"
            >
              <ArrowLeftIcon className="mr-2 h-4 w-4 transition-transform group-hover:-translate-x-1" />
              Voltar
            </Button>
          </div>
          <CardTitle className="text-3xl font-bold tracking-tight text-center flex items-center justify-center gap-2">
            <BellIcon className="w-8 h-8 text-primary" />
            Nova Notícia / Aviso
          </CardTitle>
          <CardDescription className="text-center text-muted-foreground">
            Escreva o conteúdo que aparecerá no mural da página inicial.
          </CardDescription>
        </CardHeader>
        <CardContent>
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
                      className="bg-background/50"
                    />
                    <FieldError errors={[fieldState.error]} />
                  </Field>
                )}
              />

              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                <div className={form.watch("category") === "evento" ? "col-span-1" : "md:col-span-2 lg:col-span-3"}>
                  <Controller
                    name="category"
                    control={form.control}
                    render={({ field, fieldState }) => (
                      <Field data-invalid={fieldState.invalid}>
                        <FieldLabel>Categoria*</FieldLabel>
                        <select
                          {...field}
                          className="flex h-10 w-full rounded-md border border-input bg-background/50 px-3 py-2 text-sm ring-offset-background focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50"
                        >
                          <option value="aviso">Aviso</option>
                          <option value="evento">Evento</option>
                          <option value="noticia">Notícia</option>
                          <option value="oracao">Pedido de Oração</option>
                        </select>
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
                            className="bg-background/50" 
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
                          <FieldLabel className="flex items-center gap-2">
                            Fim
                            <CalendarIcon className="h-3 w-3 text-muted-foreground" />
                          </FieldLabel>
                          <Input 
                            {...field} 
                            type="datetime-local" 
                            className="bg-background/50" 
                            value={field.value || ""}
                            onChange={(e) => field.onChange(e.target.value || null)}
                          />
                          <FieldError errors={[fieldState.error]} />
                        </Field>
                      )}
                    />
                  </>
                )}
              </div>

              <div className="space-y-4">
                <FieldLabel className="flex items-center gap-2">
                  Fotos (Máx 3)
                  <ImageIcon className="h-4 w-4 text-muted-foreground" />
                </FieldLabel>
                
                <div className="grid grid-cols-2 sm:grid-cols-4 gap-4">
                  {selectedImages.map((img) => (
                    <div key={img.id} className="relative group aspect-square rounded-lg overflow-hidden border border-border bg-muted/50">
                      <img 
                        src={URL.createObjectURL(img.file)} 
                        alt="Preview" 
                        className="w-full h-full object-cover"
                      />
                      <button
                        type="button"
                        onClick={() => removeImage(img.id)}
                        className="absolute top-1 right-1 p-1 bg-destructive/80 text-destructive-foreground rounded-full opacity-0 group-hover:opacity-100 transition-opacity"
                      >
                        <XIcon className="h-3 w-3" />
                      </button>
                    </div>
                  ))}
                  
                  {selectedImages.length < 3 && (
                    <button
                      type="button"
                      onClick={() => fileInputRef.current?.click()}
                      className="aspect-square flex flex-col items-center justify-center border-2 border-dashed border-border rounded-lg hover:border-primary/50 hover:bg-primary/5 transition-all text-muted-foreground hover:text-primary bg-background/30"
                    >
                      <PlusIcon className="h-6 w-6 mb-1" />
                      <span className="text-[10px] font-medium uppercase tracking-wider">Foto</span>
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
                    <FieldLabel>Conteúdo*</FieldLabel>
                    <Textarea 
                      {...field} 
                      placeholder="Descreva os detalhes do aviso..." 
                      className="min-h-[150px] bg-background/50"
                    />
                    <FieldError errors={[fieldState.error]} />
                  </Field>
                )}
              />
            </FieldGroup>
          </form>
        </CardContent>
        <CardFooter>
          <Button
            type="submit"
            form="create-post-form"
            className="w-full bg-primary hover:bg-primary/90 text-primary-foreground font-semibold h-12 transition-all active:scale-[0.98]"
            disabled={submitting}
          >
            {submitting ? (
              <>
                <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                Publicando...
              </>
            ) : (
              "Publicar no Mural"
            )}
          </Button>
        </CardFooter>
      </Card>
    </div>
  );
}
