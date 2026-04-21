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
import { Loader2, CalendarIcon, BellIcon, ImageIcon, XIcon, PlusIcon } from "lucide-react";
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

        const { data: profile, error: profileError } = await supabase
            .from("profiles")
            .select("id")
            .eq("user_id", session.user.id)
            .single();
        
        if (profileError || !profile) throw new Error("Perfil não encontrado");

        const uploadPromises = selectedImages.map(async (img) => {
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
          
          return publicUrl;
        });

        const uploadedUrls = await Promise.all(uploadPromises);

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
      finally: () => setSubmitting(false),
    });
  }

  return (
    <div className="max-w-3xl mx-auto animate-in fade-in slide-in-from-bottom-4 duration-500">
      <div className="border-b border-border pb-6 mb-8 flex items-center gap-3">
        <div className="w-12 h-12 rounded-2xl bg-primary/10 flex items-center justify-center shadow-sm">
          <BellIcon className="w-6 h-6 text-primary" />
        </div>
        <div>
          <h1 className="text-3xl font-bold tracking-tight">Nova Notícia / Aviso</h1>
          <p className="text-muted-foreground mt-1">Crie um conteúdo para o mural da igreja.</p>
        </div>
      </div>

      <Card className="border-border bg-card/30 backdrop-blur-sm shadow-xl rounded-3xl overflow-hidden">
        <CardHeader className="p-8">
          <CardTitle className="text-2xl font-bold">Conteúdo do Aviso</CardTitle>
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
                      className="bg-background/50 h-11 rounded-xl"
                    />
                    <FieldError errors={[fieldState.error]} />
                  </Field>
                )}
              />

              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 pt-2">
                <div className={form.watch("category") === "evento" ? "col-span-1" : "md:col-span-2 lg:col-span-3"}>
                  <Controller
                    name="category"
                    control={form.control}
                    render={({ field, fieldState }) => (
                      <Field data-invalid={fieldState.invalid}>
                        <FieldLabel>Categoria*</FieldLabel>
                        <select
                          {...field}
                          className="flex h-11 w-full rounded-xl border border-input bg-background/50 px-4 py-2 text-sm focus:ring-2 focus:ring-primary/20 transition-all outline-none"
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
                            className="bg-background/50 h-11 rounded-xl" 
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
                            Término
                            <CalendarIcon className="h-3 w-3 text-muted-foreground" />
                          </FieldLabel>
                          <Input 
                            {...field} 
                            type="datetime-local" 
                            className="bg-background/50 h-11 rounded-xl" 
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

              <div className="space-y-4 pt-2">
                <FieldLabel className="flex items-center gap-2">
                  Imagens (Máximo de 3)
                  <ImageIcon className="h-4 w-4 text-muted-foreground" />
                </FieldLabel>
                
                <div className="grid grid-cols-2 sm:grid-cols-4 gap-4">
                  {selectedImages.map((img) => (
                    <div key={img.id} className="relative group aspect-square rounded-2xl overflow-hidden border border-border/50 bg-muted/30 shadow-sm">
                      <img 
                        src={URL.createObjectURL(img.file)} 
                        alt="Preview" 
                        className="w-full h-full object-cover transition-transform duration-500 group-hover:scale-110"
                      />
                      <button
                        type="button"
                        onClick={() => removeImage(img.id)}
                        className="absolute top-2 right-2 p-1.5 bg-destructive/90 text-destructive-foreground rounded-full opacity-0 group-hover:opacity-100 transition-all hover:scale-110 shadow-lg"
                      >
                        <XIcon className="h-3.5 w-3.5" />
                      </button>
                    </div>
                  ))}
                  
                  {selectedImages.length < 3 && (
                    <button
                      type="button"
                      onClick={() => fileInputRef.current?.click()}
                      className="aspect-square flex flex-col items-center justify-center border-2 border-dashed border-border/50 rounded-2xl hover:border-primary/50 hover:bg-primary/5 transition-all text-muted-foreground hover:text-primary bg-muted/20"
                    >
                      <PlusIcon className="h-8 w-8 mb-2 opacity-50" />
                      <span className="text-[10px] font-bold uppercase tracking-widest">Adicionar</span>
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
                      className="min-h-[180px] bg-background/50 rounded-2xl p-4 transition-all focus:ring-2 focus:ring-primary/20 border-border/50"
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
            className="w-full bg-primary hover:bg-primary/90 text-primary-foreground font-bold h-14 rounded-2xl transition-all shadow-lg shadow-primary/20 active:scale-[0.98]"
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
  );
}
