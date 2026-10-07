import React, { useState, useRef } from "react";
import { useForm, Controller } from "react-hook-form";
import * as z from "zod";
import { zodResolver } from "@hookform/resolvers/zod";
import { 
    YoutubeIcon, 
    FileTextIcon, 
    BookOpenIcon, 
    UploadCloudIcon, 
    PlayIcon
} from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import { Field, FieldLabel, FieldError } from "@/components/ui/field";
import {
    Dialog,
    DialogContent,
    DialogHeader,
    DialogTitle,
    DialogDescription,
    DialogFooter,
} from "@/components/ui/dialog";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Spinner } from "@/components/ui/spinner";
import { toast } from "sonner";

const resourceSchema = z.object({
    title: z.string().min(3, "O título deve ter pelo menos 3 caracteres"),
    description: z.string().optional(),
    type: z.enum(["video", "pdf", "markdown"]),
    url: z.string().optional(),
});

export type ResourceFormValues = z.infer<typeof resourceSchema>;

interface AddResourceModalProps {
    isOpen: boolean;
    onClose: () => void;
    onSubmit: (values: ResourceFormValues, file: File | null) => Promise<void>;
}

const getYouTubeId = (url: string) => {
    const regExp = /^.*(youtu.be\/|v\/|u\/\w\/|embed\/|watch\?v=|&v=)([^#&?]*).*/;
    const match = url.match(regExp);
    return match && match[2].length === 11 ? match[2] : null;
};

export function AddResourceModal({
    isOpen,
    onClose,
    onSubmit,
}: AddResourceModalProps) {
    const [selectedFile, setSelectedFile] = useState<File | null>(null);
    const [uploading, setUploading] = useState(false);
    const fileInputRef = useRef<HTMLInputElement>(null);

    const {
        control,
        handleSubmit,
        watch,
        reset,
    } = useForm<ResourceFormValues>({
        resolver: zodResolver(resourceSchema),
        defaultValues: {
            title: "",
            description: "",
            type: "video",
            url: "",
        },
    });

    const resourceType = watch("type");
    const videoUrl = watch("url") || "";
    const ytId = resourceType === "video" ? getYouTubeId(videoUrl) : null;

    React.useEffect(() => {
        if (isOpen) {
            reset({
                title: "",
                description: "",
                type: "video",
                url: "",
            });
            setSelectedFile(null);
            if (fileInputRef.current) fileInputRef.current.value = "";
        }
    }, [isOpen, reset]);

    const handleFormSubmit = async (values: ResourceFormValues) => {
        if (values.type !== "video" && !selectedFile) {
            toast.error("Por favor, selecione um arquivo para upload.");
            return;
        }

        if (values.type === "video" && !values.url) {
            toast.error("Por favor, informe a URL do vídeo do YouTube.");
            return;
        }

        try {
            setUploading(true);
            await onSubmit(values, selectedFile);
            onClose();
        } finally {
            setUploading(false);
        }
    };

    return (
        <Dialog open={isOpen} onOpenChange={(open) => !open && onClose()}>
            <DialogContent className="max-h-[92vh] w-[95vw] sm:max-w-lg bg-card border-border/60 shadow-2xl rounded-3xl p-0 overflow-hidden flex flex-col">
                <DialogHeader className="p-5 sm:p-6 pb-4 border-b border-border/50 shrink-0">
                    <DialogTitle className="text-lg sm:text-xl font-bold text-foreground">
                        Adicionar Novo Recurso
                    </DialogTitle>
                    <DialogDescription className="text-xs sm:text-sm text-muted-foreground">
                        Disponibilize ministrações em vídeo, apostilas em PDF ou leituras bíblicas no acervo.
                    </DialogDescription>
                </DialogHeader>

                <form onSubmit={handleSubmit(handleFormSubmit)} className="flex-1 flex flex-col min-h-0 overflow-hidden">
                    <div className="flex-1 overflow-y-auto p-5 sm:p-6 space-y-4">
                        <Controller
                            control={control}
                            name="title"
                            render={({ field, fieldState }) => (
                                <Field data-invalid={fieldState.invalid}>
                                    <FieldLabel htmlFor="res-title" className="text-xs font-semibold">
                                        Título do Recurso*
                                    </FieldLabel>
                                    <Input
                                        id="res-title"
                                        placeholder="Ex: O Sacerdócio Universal de Todos os Santos"
                                        className="rounded-xl min-h-[44px]"
                                        {...field}
                                    />
                                    <FieldError errors={[fieldState.error]} />
                                </Field>
                            )}
                        />

                        <Controller
                            control={control}
                            name="description"
                            render={({ field, fieldState }) => (
                                <Field data-invalid={fieldState.invalid}>
                                    <FieldLabel htmlFor="res-desc" className="text-xs font-semibold">
                                        Descrição / Resumo
                                    </FieldLabel>
                                    <Textarea
                                        id="res-desc"
                                        placeholder="Breve resumo sobre o conteúdo e objetivo deste material..."
                                        className="rounded-xl min-h-[70px]"
                                        {...field}
                                    />
                                    <FieldError errors={[fieldState.error]} />
                                </Field>
                            )}
                        />

                        <Controller
                            control={control}
                            name="type"
                            render={({ field, fieldState }) => (
                                <Field data-invalid={fieldState.invalid}>
                                    <FieldLabel className="text-xs font-semibold">Tipo de Recurso</FieldLabel>
                                    <Select value={field.value} onValueChange={field.onChange}>
                                        <SelectTrigger className="rounded-xl bg-background/50 min-h-[44px] border border-input">
                                            <SelectValue placeholder="Selecione o formato" />
                                        </SelectTrigger>
                                        <SelectContent className="rounded-2xl shadow-xl">
                                            <SelectItem value="video">
                                                <div className="flex items-center gap-2">
                                                    <YoutubeIcon className="h-4 w-4 text-destructive" />
                                                    <span>Vídeo (YouTube)</span>
                                                </div>
                                            </SelectItem>
                                            <SelectItem value="pdf">
                                                <div className="flex items-center gap-2">
                                                    <FileTextIcon className="h-4 w-4 text-red-500" />
                                                    <span>Apostila (Documento PDF)</span>
                                                </div>
                                            </SelectItem>
                                            <SelectItem value="markdown">
                                                <div className="flex items-center gap-2">
                                                    <BookOpenIcon className="h-4 w-4 text-amber-500" />
                                                    <span>Texto / Leitura (Markdown .md)</span>
                                                </div>
                                            </SelectItem>
                                        </SelectContent>
                                    </Select>
                                    <FieldError errors={[fieldState.error]} />
                                </Field>
                            )}
                        />

                        {/* YouTube URL & Live Preview */}
                        {resourceType === "video" ? (
                            <div className="space-y-3">
                                <Controller
                                    control={control}
                                    name="url"
                                    render={({ field, fieldState }) => (
                                        <Field data-invalid={fieldState.invalid}>
                                            <FieldLabel htmlFor="res-url" className="text-xs font-semibold">
                                                Link do Vídeo no YouTube*
                                            </FieldLabel>
                                            <Input
                                                id="res-url"
                                                placeholder="https://www.youtube.com/watch?v=..."
                                                className="rounded-xl min-h-[44px]"
                                                {...field}
                                            />
                                            <FieldError errors={[fieldState.error]} />
                                        </Field>
                                    )}
                                />

                                {ytId && (
                                    <div className="rounded-2xl border border-border/60 bg-muted/20 p-3 space-y-2">
                                        <span className="text-[11px] font-bold uppercase tracking-wider text-muted-foreground flex items-center gap-1.5">
                                            <PlayIcon className="h-3.5 w-3.5 text-primary fill-primary" />
                                            Pré-visualização do Vídeo
                                        </span>
                                        <div className="aspect-video w-full rounded-xl overflow-hidden bg-black/80 relative">
                                            <img
                                                src={`https://img.youtube.com/vi/${ytId}/mqdefault.jpg`}
                                                alt="Pré-visualização do YouTube"
                                                className="w-full h-full object-cover"
                                            />
                                        </div>
                                    </div>
                                )}
                            </div>
                        ) : (
                            <Field>
                                <FieldLabel htmlFor="res-file" className="text-xs font-semibold">
                                    Arquivo para Upload*
                                </FieldLabel>
                                <div className="border border-dashed border-border/80 hover:border-primary/50 bg-muted/15 rounded-2xl p-4 text-center transition-colors">
                                    <UploadCloudIcon className="h-8 w-8 text-muted-foreground mx-auto mb-2" />
                                    <p className="text-xs text-muted-foreground mb-3">
                                        {resourceType === "pdf"
                                            ? "Selecione um arquivo PDF para anexar à plataforma."
                                            : "Selecione um arquivo Markdown (.md) com a leitura estruturada."}
                                    </p>
                                    <Input
                                        id="res-file"
                                        type="file"
                                        ref={fileInputRef}
                                        accept={resourceType === "pdf" ? ".pdf" : ".md,.markdown"}
                                        onChange={(e) => {
                                            const files = e.target.files;
                                            if (files && files.length > 0) {
                                                setSelectedFile(files[0]);
                                            }
                                        }}
                                        className="rounded-xl file:bg-zinc-900 file:text-zinc-50 dark:file:bg-zinc-50 dark:file:text-zinc-900 file:border-0 file:rounded-lg file:px-3 file:py-1.5 file:mr-3 file:text-xs file:font-semibold file:cursor-pointer cursor-pointer text-xs"
                                    />
                                    {selectedFile && (
                                        <p className="mt-2 text-xs font-bold text-primary truncate">
                                            Arquivo selecionado: {selectedFile.name} ({(selectedFile.size / 1024).toFixed(1)} KB)
                                        </p>
                                    )}
                                </div>
                            </Field>
                        )}
                    </div>

                    <DialogFooter className="p-4 sm:p-5 border-t border-border/50 shrink-0 flex flex-col-reverse sm:flex-row items-stretch sm:items-center justify-between gap-2.5">
                        <Button
                            type="button"
                            variant="ghost"
                            onClick={onClose}
                            className="min-h-[44px] rounded-xl px-5 text-xs font-semibold cursor-pointer"
                        >
                            Cancelar
                        </Button>

                        <Button
                            type="submit"
                            disabled={uploading}
                            className="min-h-[44px] rounded-xl px-6 bg-zinc-900 text-zinc-50 hover:bg-zinc-800 dark:bg-zinc-50 dark:text-zinc-900 dark:hover:bg-zinc-200 text-xs sm:text-sm font-semibold shadow-sm cursor-pointer"
                        >
                            {uploading ? (
                                <>
                                    <Spinner className="mr-2" />
                                    Enviando...
                                </>
                            ) : (
                                "Salvar Recurso"
                            )}
                        </Button>
                    </DialogFooter>
                </form>
            </DialogContent>
        </Dialog>
    );
}
