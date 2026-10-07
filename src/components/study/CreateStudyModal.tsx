import React, { useState } from "react";
import { useForm, Controller } from "react-hook-form";
import * as z from "zod";
import { zodResolver } from "@hookform/resolvers/zod";
import { 
    PlusIcon, 
    ArrowUpIcon, 
    ArrowDownIcon, 
    Trash2Icon, 
    YoutubeIcon, 
    FileTextIcon, 
    BookOpenIcon, 
    SearchIcon,
    LayersIcon
} from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import { Badge } from "@/components/ui/badge";
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
import type { Database } from "@/lib/database.types";
import type { YouTubeVideo } from "@/lib/youtube";

type MediaResource = Database["public"]["Tables"]["media_resources"]["Row"];
type Study = Database["public"]["Tables"]["studies"]["Row"];

const studySchema = z.object({
    title: z.string().min(3, "O título deve ter pelo menos 3 caracteres"),
    description: z.string().optional(),
});

export type StudyFormValues = z.infer<typeof studySchema>;

interface CreateStudyModalProps {
    isOpen: boolean;
    editingStudy: Study | null;
    resources: MediaResource[];
    youtubeVideos: YouTubeVideo[];
    initialSelectedResources?: MediaResource[];
    onClose: () => void;
    onSubmit: (values: StudyFormValues, selectedResources: MediaResource[]) => Promise<void>;
    onImportYouTubeVideo?: (video: YouTubeVideo) => Promise<MediaResource | null>;
}

export function CreateStudyModal({
    isOpen,
    editingStudy,
    resources,
    youtubeVideos,
    initialSelectedResources = [],
    onClose,
    onSubmit,
    onImportYouTubeVideo,
}: CreateStudyModalProps) {
    const [selectedResources, setSelectedResources] = useState<MediaResource[]>(initialSelectedResources);
    const [resourceSearch, setResourceSearch] = useState("");
    const [selectedResourceVal, setSelectedResourceVal] = useState("");
    const [isSubmitting, setIsSubmitting] = useState(false);

    const {
        control,
        handleSubmit,
        reset,
    } = useForm<StudyFormValues>({
        resolver: zodResolver(studySchema),
        defaultValues: {
            title: editingStudy?.title || "",
            description: editingStudy?.description || "",
        },
    });

    React.useEffect(() => {
        if (isOpen) {
            reset({
                title: editingStudy?.title || "",
                description: editingStudy?.description || "",
            });
            setSelectedResources(initialSelectedResources);
            setResourceSearch("");
            setSelectedResourceVal("");
        }
    }, [isOpen, editingStudy, initialSelectedResources, reset]);

    const handleFormSubmit = async (values: StudyFormValues) => {
        if (selectedResources.length === 0) {
            return;
        }
        try {
            setIsSubmitting(true);
            await onSubmit(values, selectedResources);
            onClose();
        } finally {
            setIsSubmitting(false);
        }
    };

    const moveStep = (index: number, direction: "up" | "down") => {
        const newArr = [...selectedResources];
        const targetIndex = direction === "up" ? index - 1 : index + 1;
        if (targetIndex < 0 || targetIndex >= newArr.length) return;

        const temp = newArr[index];
        newArr[index] = newArr[targetIndex];
        newArr[targetIndex] = temp;
        setSelectedResources(newArr);
    };

    const removeStep = (index: number) => {
        setSelectedResources(selectedResources.filter((_, idx) => idx !== index));
    };

    const handleSelectResource = async (val: string) => {
        if (!val) return;

        if (val.startsWith("yt_")) {
            const ytId = val.substring(3);
            const video = youtubeVideos.find((v) => v.id === ytId);
            if (video && onImportYouTubeVideo) {
                const imported = await onImportYouTubeVideo(video);
                if (imported) {
                    setSelectedResources((prev) => [...prev, imported]);
                }
            }
        } else {
            const res = resources.find((r) => r.id === val);
            if (res && !selectedResources.some((item) => item.id === res.id)) {
                setSelectedResources((prev) => [...prev, res]);
            }
        }
        setSelectedResourceVal("");
    };

    const getResourceIcon = (type: string) => {
        switch (type) {
            case "video": return <YoutubeIcon className="h-3.5 w-3.5 text-destructive" />;
            case "pdf": return <FileTextIcon className="h-3.5 w-3.5 text-red-500" />;
            case "markdown": return <BookOpenIcon className="h-3.5 w-3.5 text-amber-500" />;
            default: return <BookOpenIcon className="h-3.5 w-3.5 text-primary" />;
        }
    };

    return (
        <Dialog open={isOpen} onOpenChange={(open) => !open && onClose()}>
            <DialogContent className="max-h-[92vh] w-[95vw] sm:max-w-2xl bg-card border-border/60 shadow-2xl rounded-3xl p-0 overflow-hidden flex flex-col">
                <DialogHeader className="p-5 sm:p-6 pb-4 border-b border-border/50 shrink-0">
                    <DialogTitle className="text-lg sm:text-xl font-bold text-foreground">
                        {editingStudy ? "Editar Trilha de Estudo" : "Criar Nova Trilha de Estudo"}
                    </DialogTitle>
                    <DialogDescription className="text-xs sm:text-sm text-muted-foreground">
                        {editingStudy
                            ? "Modifique o título, descrição ou a ordem dos recursos desta trilha."
                            : "Estruture um percurso formativo combinando vídeos, apostilas e leituras de forma sequencial."}
                    </DialogDescription>
                </DialogHeader>

                <form onSubmit={handleSubmit(handleFormSubmit)} className="flex-1 flex flex-col min-h-0 overflow-hidden">
                    <div className="flex-1 overflow-y-auto p-5 sm:p-6 space-y-5">
                        <Controller
                            control={control}
                            name="title"
                            render={({ field, fieldState }) => (
                                <Field data-invalid={fieldState.invalid}>
                                    <FieldLabel htmlFor="study-title" className="text-xs font-semibold">
                                        Título da Trilha*
                                    </FieldLabel>
                                    <Input
                                        id="study-title"
                                        placeholder="Ex: Fundamentos da Vida no Reino"
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
                                    <FieldLabel htmlFor="study-desc" className="text-xs font-semibold">
                                        Descrição / Propósito
                                    </FieldLabel>
                                    <Textarea
                                        id="study-desc"
                                        placeholder="Descreva o propósito desta trilha e a quem se destina..."
                                        className="rounded-xl min-h-[80px]"
                                        {...field}
                                    />
                                    <FieldError errors={[fieldState.error]} />
                                </Field>
                            )}
                        />

                        {/* Step Selection Box */}
                        <div className="rounded-2xl border border-border/60 bg-muted/20 p-4 sm:p-5 space-y-3.5">
                            <div className="flex items-center justify-between">
                                <div className="flex items-center gap-2">
                                    <LayersIcon className="h-4 w-4 text-primary" />
                                    <h4 className="text-xs sm:text-sm font-bold text-foreground">
                                        Etapas da Trilha (Em Ordem Sequencial)
                                    </h4>
                                </div>
                                <Badge variant="outline" className="text-[11px] font-semibold bg-background">
                                    {selectedResources.length} {selectedResources.length === 1 ? "recurso" : "recursos"}
                                </Badge>
                            </div>

                            {/* Resource Selector Dropdown */}
                            <div className="flex items-center">
                                <Select
                                    value={selectedResourceVal}
                                    onValueChange={handleSelectResource}
                                    onOpenChange={(open) => {
                                        if (!open) setResourceSearch("");
                                    }}
                                >
                                    <SelectTrigger className="w-full sm:w-auto min-h-[44px] rounded-xl border-dashed border-primary/40 bg-card text-primary hover:bg-primary/5 px-4 font-semibold text-xs sm:text-sm cursor-pointer shadow-2xs">
                                        <div className="flex items-center gap-2">
                                            <PlusIcon className="h-4 w-4" />
                                            <SelectValue placeholder="Adicionar Recurso à Trilha..." />
                                        </div>
                                    </SelectTrigger>
                                    <SelectContent position="popper" className="max-h-[320px] w-[320px] sm:w-[420px] overflow-y-auto rounded-2xl p-1.5 shadow-2xl">
                                        {/* Dropdown Search */}
                                        <div
                                            className="p-1.5 border-b border-border/40 sticky top-0 bg-popover z-10"
                                            onClick={(e) => e.stopPropagation()}
                                            onKeyDown={(e) => e.stopPropagation()}
                                        >
                                            <div className="relative">
                                                <SearchIcon className="absolute left-2.5 top-1/2 -translate-y-1/2 h-3.5 w-3.5 text-muted-foreground" />
                                                <Input
                                                    placeholder="Pesquisar por título..."
                                                    value={resourceSearch}
                                                    onChange={(e) => setResourceSearch(e.target.value)}
                                                    className="h-8 text-xs pl-8 rounded-lg"
                                                />
                                            </div>
                                        </div>

                                        {/* Vídeos do Acervo */}
                                        {(() => {
                                            const dbVideos = resources.filter(
                                                (r) => r.type === "video" && r.title.toLowerCase().includes(resourceSearch.toLowerCase())
                                            );
                                            if (dbVideos.length === 0) return null;
                                            return (
                                                <>
                                                    <div className="px-2 py-1 text-[11px] font-bold text-muted-foreground uppercase tracking-wider mt-1">
                                                        🎥 Vídeos do Acervo
                                                    </div>
                                                    {dbVideos.map((r) => (
                                                        <SelectItem key={r.id} value={r.id} disabled={selectedResources.some((s) => s.id === r.id)}>
                                                            {r.title}
                                                        </SelectItem>
                                                    ))}
                                                </>
                                            );
                                        })()}

                                        {/* PDFs do Acervo */}
                                        {(() => {
                                            const dbPDFs = resources.filter(
                                                (r) => r.type === "pdf" && r.title.toLowerCase().includes(resourceSearch.toLowerCase())
                                            );
                                            if (dbPDFs.length === 0) return null;
                                            return (
                                                <>
                                                    <div className="px-2 py-1 text-[11px] font-bold text-muted-foreground uppercase tracking-wider mt-2 border-t border-border/40 pt-1.5">
                                                        📄 Apostilas PDF
                                                    </div>
                                                    {dbPDFs.map((r) => (
                                                        <SelectItem key={r.id} value={r.id} disabled={selectedResources.some((s) => s.id === r.id)}>
                                                            {r.title}
                                                        </SelectItem>
                                                    ))}
                                                </>
                                            );
                                        })()}

                                        {/* Textos Markdown */}
                                        {(() => {
                                            const dbTextos = resources.filter(
                                                (r) => r.type === "markdown" && r.title.toLowerCase().includes(resourceSearch.toLowerCase())
                                            );
                                            if (dbTextos.length === 0) return null;
                                            return (
                                                <>
                                                    <div className="px-2 py-1 text-[11px] font-bold text-muted-foreground uppercase tracking-wider mt-2 border-t border-border/40 pt-1.5">
                                                        📝 Textos e Leituras
                                                    </div>
                                                    {dbTextos.map((r) => (
                                                        <SelectItem key={r.id} value={r.id} disabled={selectedResources.some((s) => s.id === r.id)}>
                                                            {r.title}
                                                        </SelectItem>
                                                    ))}
                                                </>
                                            );
                                        })()}

                                        {/* Vídeos do YouTube */}
                                        {(() => {
                                            const ytVideos = youtubeVideos.filter((v) =>
                                                v.title.toLowerCase().includes(resourceSearch.toLowerCase())
                                            );
                                            if (ytVideos.length === 0) return null;
                                            return (
                                                <>
                                                    <div className="px-2 py-1 text-[11px] font-bold text-muted-foreground uppercase tracking-wider mt-2 border-t border-border/40 pt-1.5 flex items-center gap-1">
                                                        <YoutubeIcon className="h-3.5 w-3.5 text-destructive" />
                                                        Canal YouTube da Igreja
                                                    </div>
                                                    {ytVideos.map((v) => (
                                                        <SelectItem
                                                            key={v.id}
                                                            value={`yt_${v.id}`}
                                                            disabled={selectedResources.some((s) => s.url.includes(v.id))}
                                                        >
                                                            🔴 {v.title}
                                                        </SelectItem>
                                                    ))}
                                                </>
                                            );
                                        })()}
                                    </SelectContent>
                                </Select>
                            </div>

                            {/* Added Steps Ordered List */}
                            {selectedResources.length > 0 ? (
                                <div className="space-y-2 max-h-[260px] overflow-y-auto pr-1">
                                    {selectedResources.map((res, index) => (
                                        <div
                                            key={`${res.id}-${index}`}
                                            className="flex items-center justify-between p-2.5 sm:p-3 bg-card border border-border/50 rounded-xl text-xs sm:text-sm hover:border-primary/30 transition-all shadow-2xs"
                                        >
                                            <div className="flex items-center gap-2.5 min-w-0 pr-2">
                                                <span className="flex h-6 w-6 shrink-0 items-center justify-center rounded-lg bg-primary/10 text-xs font-bold text-primary">
                                                    {index + 1}
                                                </span>
                                                <div className="flex items-center gap-1.5 truncate">
                                                    {getResourceIcon(res.type)}
                                                    <span className="truncate font-semibold text-foreground" title={res.title}>
                                                        {res.title}
                                                    </span>
                                                </div>
                                            </div>

                                            <div className="flex items-center gap-1 shrink-0">
                                                <Button
                                                    type="button"
                                                    variant="ghost"
                                                    size="icon"
                                                    disabled={index === 0}
                                                    onClick={() => moveStep(index, "up")}
                                                    className="h-8 w-8 text-muted-foreground hover:text-foreground rounded-lg disabled:opacity-30 cursor-pointer min-h-[36px] min-w-[36px]"
                                                    title="Mover para cima"
                                                >
                                                    <ArrowUpIcon className="h-4 w-4" />
                                                </Button>

                                                <Button
                                                    type="button"
                                                    variant="ghost"
                                                    size="icon"
                                                    disabled={index === selectedResources.length - 1}
                                                    onClick={() => moveStep(index, "down")}
                                                    className="h-8 w-8 text-muted-foreground hover:text-foreground rounded-lg disabled:opacity-30 cursor-pointer min-h-[36px] min-w-[36px]"
                                                    title="Mover para baixo"
                                                >
                                                    <ArrowDownIcon className="h-4 w-4" />
                                                </Button>

                                                <Button
                                                    type="button"
                                                    variant="ghost"
                                                    size="icon"
                                                    onClick={() => removeStep(index)}
                                                    className="h-8 w-8 text-muted-foreground hover:text-destructive hover:bg-destructive/10 rounded-lg cursor-pointer min-h-[36px] min-w-[36px]"
                                                    title="Remover etapa"
                                                >
                                                    <Trash2Icon className="h-4 w-4" />
                                                </Button>
                                            </div>
                                        </div>
                                    ))}
                                </div>
                            ) : (
                                <div className="text-center py-6 border border-dashed border-border/50 rounded-xl text-xs text-muted-foreground">
                                    Nenhum recurso adicionado ainda. Adicione ao menos um recurso acima para compor a trilha.
                                </div>
                            )}
                        </div>
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
                            disabled={selectedResources.length === 0 || isSubmitting}
                            className="min-h-[44px] rounded-xl px-6 bg-zinc-900 text-zinc-50 hover:bg-zinc-800 dark:bg-zinc-50 dark:text-zinc-900 dark:hover:bg-zinc-200 text-xs sm:text-sm font-semibold shadow-sm cursor-pointer"
                        >
                            {isSubmitting ? "Salvando Trilha..." : editingStudy ? "Salvar Alterações" : "Criar Trilha de Estudo"}
                        </Button>
                    </DialogFooter>
                </form>
            </DialogContent>
        </Dialog>
    );
}
