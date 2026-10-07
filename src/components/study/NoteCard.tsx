import { 
    GraduationCapIcon, 
    YoutubeIcon, 
    FileTextIcon, 
    BookOpenIcon, 
    PencilIcon, 
    Trash2Icon, 
    EyeIcon, 
    StickyNoteIcon 
} from "lucide-react";
import { cn } from "@/lib/utils";
import { Button } from "@/components/ui/button";
import { Card, CardHeader, CardTitle, CardContent, CardFooter } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import type { Database } from "@/lib/database.types";

type Study = Database["public"]["Tables"]["studies"]["Row"];
type MediaResource = Database["public"]["Tables"]["media_resources"]["Row"];
type StudyNote = Database["public"]["Tables"]["study_notes"]["Row"];

export interface EnrichedNote extends StudyNote {
    study: Study | null;
    resource: MediaResource | null;
    typeLabel: "Estudo" | "Vídeo" | "PDF" | "Texto";
    targetTitle: string;
}

interface NoteCardProps {
    note: EnrichedNote;
    onEdit: () => void;
    onDelete: () => void;
    onOpenMaterial?: () => void;
}

export function NoteCard({
    note,
    onEdit,
    onDelete,
    onOpenMaterial,
}: NoteCardProps) {
    const dateVal = note.updated_at || note.created_at;
    const updatedAt = dateVal
        ? new Date(dateVal).toLocaleDateString("pt-BR", {
              day: "2-digit",
              month: "short",
              year: "numeric",
          })
        : "";

    const cleanPreview = note.content
        .replace(/#+\s/g, "")
        .replace(/[*_`>~-]/g, "")
        .slice(0, 160)
        .trim();

    const getTypeIcon = () => {
        switch (note.typeLabel) {
            case "Estudo": return <GraduationCapIcon className="h-3.5 w-3.5" />;
            case "Vídeo": return <YoutubeIcon className="h-3.5 w-3.5" />;
            case "PDF": return <FileTextIcon className="h-3.5 w-3.5" />;
            case "Texto": return <BookOpenIcon className="h-3.5 w-3.5" />;
        }
    };

    const getTypeBadgeClass = () => {
        switch (note.typeLabel) {
            case "Estudo": return "border-primary/30 text-primary bg-primary/5";
            case "Vídeo": return "border-destructive/30 text-destructive bg-destructive/5";
            case "PDF": return "border-red-500/30 text-red-500 bg-red-500/5";
            case "Texto": return "border-amber-500/30 text-amber-600 dark:text-amber-500 bg-amber-500/5";
        }
    };

    return (
        <Card className="flex flex-col justify-between overflow-hidden rounded-2xl border-border/60 bg-card/40 backdrop-blur-sm shadow-xs transition-all duration-300 hover:border-primary/40 hover:shadow-lg hover:shadow-primary/5">
            <CardHeader className="p-5 pb-3">
                <div className="flex items-start justify-between gap-3 mb-2">
                    <Badge variant="outline" className={cn("gap-1 font-semibold text-xs py-1 px-2.5 rounded-full", getTypeBadgeClass())}>
                        {getTypeIcon()}
                        <span>{note.typeLabel}</span>
                    </Badge>

                    <div className="flex items-center gap-0.5 shrink-0 -mt-1 -mr-2">
                        <Button
                            variant="ghost"
                            size="icon"
                            onClick={onEdit}
                            className="min-h-[44px] min-w-[44px] text-muted-foreground hover:text-primary hover:bg-primary/10 rounded-xl cursor-pointer"
                            title="Editar Anotação"
                        >
                            <PencilIcon className="h-4 w-4" />
                        </Button>
                        <Button
                            variant="ghost"
                            size="icon"
                            onClick={onDelete}
                            className="min-h-[44px] min-w-[44px] text-muted-foreground hover:text-destructive hover:bg-destructive/10 rounded-xl cursor-pointer"
                            title="Excluir Anotação"
                        >
                            <Trash2Icon className="h-4 w-4" />
                        </Button>
                    </div>
                </div>

                <CardTitle className="text-sm sm:text-base text-foreground font-bold leading-snug line-clamp-2">
                    {note.title}
                </CardTitle>

                <div className="text-xs text-muted-foreground pt-1 flex items-center gap-1 truncate" title={note.targetTitle}>
                    <span className="font-semibold text-foreground/80">Referente a:</span>
                    <span className="truncate">{note.targetTitle}</span>
                </div>
            </CardHeader>

            <CardContent className="px-5 py-2">
                <div className="p-3 bg-muted/20 border border-border/40 rounded-xl text-xs text-muted-foreground line-clamp-3 font-sans leading-relaxed min-h-[64px]">
                    {cleanPreview || <span className="italic text-muted-foreground/60">Anotação vazia</span>}
                </div>
            </CardContent>

            <CardFooter className="p-5 pt-3 border-t border-border/40 flex flex-col sm:flex-row items-stretch sm:items-center justify-between gap-2.5">
                <span className="text-[11px] text-muted-foreground">
                    Atualizado em {updatedAt}
                </span>

                <div className="flex items-center gap-2">
                    {(note.resource || note.study) && onOpenMaterial && (
                        <Button
                            variant="ghost"
                            size="sm"
                            onClick={onOpenMaterial}
                            className="min-h-[44px] text-xs gap-1 rounded-xl cursor-pointer hover:bg-primary/5 hover:text-primary"
                        >
                            <EyeIcon className="h-3.5 w-3.5" />
                            <span>Ver Material</span>
                        </Button>
                    )}
                    <Button
                        variant="outline"
                        size="sm"
                        onClick={onEdit}
                        className="min-h-[44px] text-xs gap-1.5 rounded-xl cursor-pointer border-border/60 hover:bg-primary hover:text-primary-foreground transition-all"
                    >
                        <StickyNoteIcon className="h-3.5 w-3.5" />
                        <span>Editar</span>
                    </Button>
                </div>
            </CardFooter>
        </Card>
    );
}
