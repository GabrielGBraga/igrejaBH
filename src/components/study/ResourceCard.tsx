import React from "react";
import { 
    YoutubeIcon, 
    FileTextIcon, 
    BookOpenIcon, 
    PlayIcon, 
    Trash2Icon, 
    StickyNoteIcon, 
    PlusIcon, 
    EyeIcon,
    PencilIcon
} from "lucide-react";
import { cn } from "@/lib/utils";
import { Button } from "@/components/ui/button";
import { Card, CardHeader, CardTitle, CardDescription } from "@/components/ui/card";
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
            className="group flex flex-col justify-between overflow-hidden rounded-2xl border-border/60 bg-card/40 backdrop-blur-sm shadow-xs transition-all duration-300 hover:border-primary/40 hover:shadow-lg hover:shadow-primary/5 cursor-pointer relative"
        >
            {/* Thumbnail Header for Videos */}
            {resource.type === "video" && (
                <div className="aspect-video bg-muted relative flex items-center justify-center overflow-hidden shrink-0">
                    {thumb ? (
                        <img
                            src={thumb}
                            alt={resource.title}
                            className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-500"
                        />
                    ) : (
                        <div className="w-full h-full flex items-center justify-center bg-black/80">
                            <YoutubeIcon className="h-12 w-12 text-destructive" />
                        </div>
                    )}
                    <div className="absolute inset-0 bg-black/35 group-hover:bg-black/20 transition-colors flex items-center justify-center">
                        <div className="w-12 h-12 rounded-full bg-primary/95 flex items-center justify-center opacity-0 group-hover:opacity-100 transform scale-75 group-hover:scale-100 transition-all duration-300 shadow-xl">
                            <PlayIcon className="h-5 w-5 text-primary-foreground fill-primary-foreground ml-0.5" />
                        </div>
                    </div>
                </div>
            )}

            <CardHeader className="p-5 pb-3 flex-1">
                <div className="flex items-start justify-between gap-3">
                    {resource.type !== "video" && (
                        <div
                            className={cn(
                                "w-10 h-10 rounded-xl flex items-center justify-center shrink-0 group-hover:scale-105 transition-transform",
                                resource.type === "pdf" ? "bg-red-500/10 text-red-500" : "bg-amber-500/10 text-amber-500"
                            )}
                        >
                            {resource.type === "pdf" ? <FileTextIcon className="h-5 w-5" /> : <BookOpenIcon className="h-5 w-5" />}
                        </div>
                    )}

                    <div className="min-w-0 flex-1">
                        <Badge variant="secondary" className="text-[10px] uppercase font-bold tracking-wider px-2 py-0.5 mb-1">
                            {resource.type === "video" ? "Vídeo" : resource.type === "pdf" ? "Apostila PDF" : "Leitura"}
                        </Badge>
                        <CardTitle
                            className="text-sm sm:text-base font-bold text-foreground group-hover:text-primary transition-colors line-clamp-2 leading-snug"
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
                                "min-h-[44px] min-w-[44px] rounded-xl cursor-pointer transition-all",
                                note
                                    ? "text-primary bg-primary/10 hover:bg-primary/20"
                                    : "text-muted-foreground hover:text-primary hover:bg-primary/10"
                            )}
                            title={note ? "Ver reflexões deste recurso" : "Anotar neste recurso"}
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
                                        className="min-h-[44px] min-w-[44px] rounded-xl text-muted-foreground hover:text-amber-600 hover:bg-amber-500/10 transition-colors cursor-pointer"
                                        title="Editar Texto"
                                    >
                                        <PencilIcon className="h-4 w-4" />
                                    </Button>
                                )}
                                {onDelete && (
                                    <Button
                                        variant="ghost"
                                        size="icon"
                                        onClick={onDelete}
                                        className="min-h-[44px] min-w-[44px] rounded-xl text-muted-foreground hover:text-destructive hover:bg-destructive/10 transition-colors cursor-pointer"
                                        title="Excluir Recurso"
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

            {/* Quick Action Footer for non-video resources */}
            {resource.type !== "video" && (
                <div className="p-5 pt-0 mt-auto flex items-center justify-between gap-2 border-t border-border/40 pt-3">
                    <span className="text-[11px] text-muted-foreground">
                        {resource.type === "pdf" ? "Documento baixável" : "Artigo formatado"}
                    </span>
                    <Button variant="ghost" size="sm" className="min-h-[44px] gap-1.5 text-xs font-semibold rounded-xl hover:bg-primary hover:text-primary-foreground transition-all">
                        <EyeIcon className="h-3.5 w-3.5" />
                        <span>Acessar</span>
                    </Button>
                </div>
            )}
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
            className="group flex flex-col justify-between overflow-hidden rounded-2xl border-border/60 bg-card/40 backdrop-blur-sm shadow-xs transition-all duration-300 hover:border-primary/40 hover:shadow-lg hover:shadow-primary/5 cursor-pointer relative"
        >
            <div className="aspect-video bg-muted relative flex items-center justify-center overflow-hidden shrink-0">
                <img
                    src={video.thumbnailUrl}
                    alt={video.title}
                    className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-500"
                />
                <div className="absolute inset-0 bg-black/35 group-hover:bg-black/20 transition-colors flex items-center justify-center">
                    <div className="w-12 h-12 rounded-full bg-primary/95 flex items-center justify-center opacity-0 group-hover:opacity-100 transform scale-75 group-hover:scale-100 transition-all duration-300 shadow-xl">
                        <PlayIcon className="h-5 w-5 text-primary-foreground fill-primary-foreground ml-0.5" />
                    </div>
                </div>
            </div>

            <CardHeader className="p-5 pb-3 flex-1">
                <div className="flex items-start justify-between gap-3">
                    <CardTitle
                        className="text-sm sm:text-base font-bold text-foreground group-hover:text-primary transition-colors line-clamp-2 leading-snug"
                        title={video.title}
                    >
                        {video.title}
                    </CardTitle>

                    {canAddMaterial && (
                        <Button
                            variant="outline"
                            size="sm"
                            onClick={onImport}
                            className="min-h-[44px] rounded-xl gap-1 border-primary/30 text-primary hover:bg-primary/5 shrink-0 text-xs font-semibold px-3"
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
