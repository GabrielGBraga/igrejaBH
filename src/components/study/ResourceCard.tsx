import React from "react";
import { 
    YoutubeIcon, 
    FileTextIcon, 
    BookOpenIcon, 
    PlayIcon, 
    Trash2Icon, 
    StickyNoteIcon, 
    PlusIcon, 
    PencilIcon,
    ChevronRightIcon
} from "lucide-react";
import { cn } from "@/lib/utils";
import { Button } from "@/components/ui/button";
import { Card, CardHeader, CardTitle, CardDescription, CardFooter } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import type { Database } from "@/lib/database.types";
import type { YouTubeVideo } from "@/lib/youtube";

type MediaResource = Database["public"]["Tables"]["media_resources"]["Row"];
type StudyNote = Database["public"]["Tables"]["study_notes"]["Row"];

const getYouTubeId = (url: string) => {
    const regExp = /^.*(youtu.be\/|v\/|u\/\w\/|embed\/|watch\?v=|&v=)([^#&?]*).*/;
    const match = url.match(regExp);
    return match && match[2].length === 11 ? match[2] : null;
};

interface ResourceCardProps {
    resource: MediaResource;
    note?: StudyNote | null;
    canAddMaterial: boolean;
    onClick: () => void;
    onOpenNote: (e: React.MouseEvent) => void;
    onDelete?: (e: React.MouseEvent) => void;
    onEdit?: (e: React.MouseEvent) => void;
}

export function ResourceCard({
    resource,
    note,
    canAddMaterial,
    onClick,
    onOpenNote,
    onDelete,
    onEdit,
}: ResourceCardProps) {
    const ytId = resource.type === "video" ? getYouTubeId(resource.url) : null;
    const thumb = ytId ? `https://img.youtube.com/vi/${ytId}/mqdefault.jpg` : "";

    return (
        <Card
            onClick={onClick}
            className="group flex flex-col justify-between overflow-hidden rounded-2xl border-border/70 bg-card/60 backdrop-blur-xs shadow-2xs card-hover-elevation transition-all duration-300 hover:border-primary/50 cursor-pointer relative active:scale-[0.99]"
        >
            {/* Thumbnail Header for Videos */}
            {resource.type === "video" && (
                <div className="aspect-video bg-muted relative flex items-center justify-center overflow-hidden shrink-0">
                    {thumb ? (
                        <img
                            src={thumb}
                            alt={resource.title}
                            loading="lazy"
                            decoding="async"
                            className="w-full h-full object-cover transition-opacity duration-300 group-hover:opacity-95"
                        />
                    ) : (
                        <div className="w-full h-full flex items-center justify-center bg-muted/80">
                            <YoutubeIcon className="h-10 w-10 text-muted-foreground" />
                        </div>
                    )}
                    <div className="absolute inset-0 bg-black/25 group-hover:bg-black/15 transition-colors duration-300 flex items-center justify-center">
                        <div className="w-11 h-11 rounded-full bg-primary text-primary-foreground flex items-center justify-center shadow-md transition-transform duration-200 ease-out group-hover:scale-105">
                            <PlayIcon className="h-5 w-5 fill-current ml-0.5" />
                        </div>
                    </div>
                </div>
            )}

            <CardHeader className="p-5 pb-3 flex-1">
                <div className="flex items-start justify-between gap-3">
                    {resource.type !== "video" && (
                        <div className="w-10 h-10 rounded-xl flex items-center justify-center shrink-0 border border-primary/20 bg-primary/10 text-primary transition-transform duration-200 group-hover:scale-105">
                            {resource.type === "pdf" ? <FileTextIcon className="h-5 w-5" /> : <BookOpenIcon className="h-5 w-5" />}
                        </div>
                    )}

                    <div className="min-w-0 flex-1">
                        <Badge variant="secondary" className="text-[10px] font-semibold px-2 py-0.5 mb-1.5 bg-muted text-muted-foreground">
                            {resource.type === "video" ? "Vídeo" : resource.type === "pdf" ? "Apostila PDF" : "Texto Bíblico"}
                        </Badge>
                        <CardTitle
                            className="text-sm sm:text-base font-bold text-foreground group-hover:text-primary transition-colors duration-200 line-clamp-2 leading-snug"
                            title={resource.title}
                        >
                            {resource.title}
                        </CardTitle>
                    </div>

                    <div className="flex items-center gap-0.5 shrink-0 -mt-1 -mr-1">
                        <Button
                            variant="ghost"
                            size="icon"
                            onClick={onOpenNote}
                            className={cn(
                                "btn-tactile min-h-[44px] min-w-[44px] rounded-xl cursor-pointer transition-all active:scale-90",
                                note
                                    ? "text-primary bg-primary/10 hover:bg-primary/20"
                                    : "text-muted-foreground hover:text-primary hover:bg-primary/10"
                            )}
                            title={note ? "Ver reflexões deste recurso" : "Anotar neste recurso"}
                            aria-label={note ? "Ver reflexões deste recurso" : "Anotar neste recurso"}
                        >
                            <StickyNoteIcon className="h-4 w-4" />
                        </Button>

                        {canAddMaterial && (
                            <>
                                {resource.type === "markdown" && onEdit && (
                                    <Button
                                        variant="ghost"
                                        size="icon"
                                        onClick={onEdit}
                                        className="btn-tactile min-h-[44px] min-w-[44px] rounded-xl text-muted-foreground hover:text-primary hover:bg-primary/10 transition-colors cursor-pointer active:scale-90"
                                        title="Editar Texto"
                                        aria-label="Editar Texto"
                                    >
                                        <PencilIcon className="h-4 w-4" />
                                    </Button>
                                )}
                                {onDelete && (
                                    <Button
                                        variant="ghost"
                                        size="icon"
                                        onClick={onDelete}
                                        className="btn-tactile min-h-[44px] min-w-[44px] rounded-xl text-muted-foreground hover:text-destructive hover:bg-destructive/10 transition-colors cursor-pointer active:scale-90"
                                        title="Excluir Recurso"
                                        aria-label="Excluir Recurso"
                                    >
                                        <Trash2Icon className="h-4 w-4" />
                                    </Button>
                                )}
                            </>
                        )}
                    </div>
                </div>

                {resource.description && (
                    <CardDescription className="line-clamp-2 text-xs text-muted-foreground pt-1.5 leading-relaxed">
                        {resource.description}
                    </CardDescription>
                )}
            </CardHeader>

            <CardFooter className="p-5 pt-3 border-t border-border/40 mt-auto">
                <div className="flex w-full items-center justify-between text-xs font-semibold text-primary transition-colors group-hover:text-primary/90">
                    <span>
                        {resource.type === "video" ? "Assistir Ministração" : resource.type === "pdf" ? "Acessar Apostila" : "Ler Texto"}
                    </span>
                    <ChevronRightIcon className="h-4 w-4 transition-transform duration-200 ease-out group-hover:translate-x-1.5" />
                </div>
            </CardFooter>
        </Card>
    );
}

interface YouTubeImportCardProps {
    video: YouTubeVideo;
    canAddMaterial: boolean;
    onClick: () => void;
    onImport: (e: React.MouseEvent) => void;
}

export function YouTubeImportCard({
    video,
    canAddMaterial,
    onClick,
    onImport,
}: YouTubeImportCardProps) {
    return (
        <Card
            onClick={onClick}
            className="group flex flex-col justify-between overflow-hidden rounded-2xl border-border/70 bg-card/60 backdrop-blur-xs shadow-2xs card-hover-elevation transition-all duration-300 hover:border-primary/50 cursor-pointer relative active:scale-[0.99]"
        >
            <div className="aspect-video bg-muted relative flex items-center justify-center overflow-hidden shrink-0">
                <img
                    src={video.thumbnailUrl}
                    alt={video.title}
                    loading="lazy"
                    decoding="async"
                    className="w-full h-full object-cover transition-opacity duration-300 group-hover:opacity-95"
                />
                <div className="absolute inset-0 bg-black/25 group-hover:bg-black/15 transition-colors duration-300 flex items-center justify-center">
                    <div className="w-11 h-11 rounded-full bg-primary text-primary-foreground flex items-center justify-center shadow-md transition-transform duration-200 ease-out group-hover:scale-105">
                        <PlayIcon className="h-5 w-5 fill-current ml-0.5" />
                    </div>
                </div>
            </div>

            <CardHeader className="p-5 pb-3 flex-1">
                <div className="flex items-start justify-between gap-3">
                    <CardTitle
                        className="text-sm sm:text-base font-bold text-foreground group-hover:text-primary transition-colors duration-200 line-clamp-2 leading-snug"
                        title={video.title}
                    >
                        {video.title}
                    </CardTitle>

                    {canAddMaterial && (
                        <Button
                            variant="outline"
                            size="sm"
                            onClick={onImport}
                            className="btn-tactile min-h-[44px] rounded-xl gap-1 border-primary/30 text-primary hover:bg-primary/5 shrink-0 text-xs font-semibold px-3 cursor-pointer active:scale-95"
                            title="Adicionar ao Acervo Oficial"
                        >
                            <PlusIcon className="h-3.5 w-3.5" />
                            <span>Salvar</span>
                        </Button>
                    )}
                </div>

                <CardDescription className="text-xs text-muted-foreground pt-1">
                    Publicado em {new Date(video.publishedAt).toLocaleDateString("pt-BR")}
                </CardDescription>
            </CardHeader>
        </Card>
    );
}
