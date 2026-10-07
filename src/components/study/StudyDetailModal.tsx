import { 
    CheckIcon, 
    LockIcon, 
    ChevronRightIcon, 
    PencilIcon, 
    StickyNoteIcon, 
    YoutubeIcon, 
    FileTextIcon, 
    BookOpenIcon, 
    PlayIcon
} from "lucide-react";
import { cn } from "@/lib/utils";
import { Button } from "@/components/ui/button";
import { Progress } from "@/components/ui/progress";
import { Badge } from "@/components/ui/badge";
import {
    Dialog,
    DialogContent,
    DialogHeader,
    DialogTitle,
    DialogDescription,
    DialogFooter,
} from "@/components/ui/dialog";
import type { Database } from "@/lib/database.types";

type MediaResource = Database["public"]["Tables"]["media_resources"]["Row"];
type Study = Database["public"]["Tables"]["studies"]["Row"];
type StudyStep = Database["public"]["Tables"]["study_steps"]["Row"] & {
    media_resource: MediaResource;
};
type UserProgress = Database["public"]["Tables"]["user_study_progress"]["Row"];
type StudyNote = Database["public"]["Tables"]["study_notes"]["Row"];

interface StudyDetailModalProps {
    study: Study | null;
    steps: StudyStep[];
    userProgress: UserProgress[];
    notes: StudyNote[];
    canAddMaterial: boolean;
    onClose: () => void;
    onSelectStep: (step: StudyStep) => void;
    onOpenStudyNote: (study: Study) => void;
    onOpenStepNote: (resource: MediaResource, studyId: string) => void;
    onEditStudy: (study: Study) => void;
}

export function StudyDetailModal({
    study,
    steps,
    userProgress,
    notes,
    canAddMaterial,
    onClose,
    onSelectStep,
    onOpenStudyNote,
    onOpenStepNote,
    onEditStudy,
}: StudyDetailModalProps) {
    if (!study) return null;

    const total = steps.length;
    const completed = userProgress.filter((p) => p.study_id === study.id).length;
    const percent = total > 0 ? Math.round((completed / total) * 100) : 0;
    const studyNote = notes.find((n) => n.study_id === study.id && !n.media_resource_id);

    // Find first pending and unlocked step to resume
    let nextStepIndex = steps.findIndex((step, index) => {
        const isStepCompleted = userProgress.some((p) => p.step_id === step.id);
        const isUnlocked = index === 0 || userProgress.some((p) => p.step_id === steps[index - 1].id);
        return !isStepCompleted && isUnlocked;
    });

    if (nextStepIndex === -1 && steps.length > 0) {
        nextStepIndex = 0; // If all completed or none, point to first
    }
    const nextStep = steps[nextStepIndex];

    const getResourceIcon = (type: string) => {
        switch (type) {
            case "video":
                return <YoutubeIcon className="h-4 w-4 text-destructive" />;
            case "pdf":
                return <FileTextIcon className="h-4 w-4 text-red-500" />;
            case "markdown":
                return <BookOpenIcon className="h-4 w-4 text-amber-500" />;
            default:
                return <BookOpenIcon className="h-4 w-4 text-primary" />;
        }
    };

    const getResourceLabel = (type: string) => {
        switch (type) {
            case "video": return "Vídeo";
            case "pdf": return "Apostila PDF";
            case "markdown": return "Leitura";
            default: return "Recurso";
        }
    };

    return (
        <Dialog open={!!study} onOpenChange={(open) => !open && onClose()}>
            <DialogContent className="max-h-[90vh] w-[95vw] sm:max-w-2xl bg-card border-border/60 shadow-2xl rounded-3xl p-0 overflow-hidden flex flex-col">
                {/* Header */}
                <DialogHeader className="p-5 sm:p-6 pb-4 border-b border-border/50 shrink-0">
                    <div className="flex flex-col sm:flex-row sm:items-start justify-between gap-3">
                        <div className="space-y-1 pr-2">
                            <div className="flex items-center gap-2">
                                <Badge variant="outline" className="border-primary/30 bg-primary/10 text-primary text-[10px] font-semibold">
                                    Trilha de Discipulado
                                </Badge>
                                {percent === 100 && (
                                    <Badge variant="outline" className="border-green-500/30 bg-green-500/10 text-green-700 dark:text-green-400 text-[10px] font-semibold">
                                        Concluído
                                    </Badge>
                                )}
                            </div>
                            <DialogTitle className="text-lg sm:text-xl font-bold text-foreground">
                                {study.title}
                            </DialogTitle>
                            <DialogDescription className="text-xs sm:text-sm text-muted-foreground line-clamp-3">
                                {study.description || "Nenhuma descrição fornecida."}
                            </DialogDescription>
                        </div>

                        <div className="flex items-center gap-2 shrink-0 self-end sm:self-start">
                            <Button
                                variant="outline"
                                size="sm"
                                onClick={() => onOpenStudyNote(study)}
                                className={cn(
                                    "min-h-[44px] gap-2 rounded-xl text-xs font-semibold cursor-pointer transition-all",
                                    studyNote
                                        ? "border-primary/40 bg-primary/10 text-primary"
                                        : "border-border/60 text-muted-foreground hover:text-foreground"
                                )}
                                title={studyNote ? "Ver reflexões deste estudo" : "Anotar neste estudo"}
                            >
                                <StickyNoteIcon className="h-4 w-4" />
                                <span>{studyNote ? "Anotações" : "Anotar"}</span>
                            </Button>

                            {canAddMaterial && (
                                <Button
                                    variant="outline"
                                    size="sm"
                                    onClick={() => onEditStudy(study)}
                                    className="min-h-[44px] gap-1.5 rounded-xl border-border/60 text-xs font-semibold text-muted-foreground hover:text-primary hover:border-primary/30 cursor-pointer"
                                >
                                    <PencilIcon className="h-3.5 w-3.5" />
                                    <span>Editar</span>
                                </Button>
                            )}
                        </div>
                    </div>
                </DialogHeader>

                {/* Body Content */}
                <div className="flex-1 overflow-y-auto p-5 sm:p-6 space-y-6">
                    {/* Overall Progress Meter & Primary CTA */}
                    <div className="space-y-3 rounded-2xl border border-border/60 bg-muted/20 p-4 sm:p-5">
                        <div className="flex items-center justify-between text-xs font-semibold">
                            <span className="text-foreground">
                                {completed} de {total} {total === 1 ? "etapa concluída" : "etapas concluídas"}
                            </span>
                            <span className="text-primary font-bold">{percent}%</span>
                        </div>
                        <Progress value={percent} className="h-2.5 bg-muted/80" />

                        {nextStep && percent < 100 && (
                            <div className="pt-2">
                                <Button
                                    onClick={() => onSelectStep(nextStep)}
                                    className="w-full min-h-[44px] gap-2 rounded-xl bg-zinc-900 text-zinc-50 hover:bg-zinc-800 dark:bg-zinc-50 dark:text-zinc-900 dark:hover:bg-zinc-200 text-xs sm:text-sm font-semibold cursor-pointer shadow-sm"
                                >
                                    <PlayIcon className="h-4 w-4 fill-current" />
                                    <span>
                                        Continuar de onde parou: Etapa {nextStepIndex + 1}
                                    </span>
                                </Button>
                            </div>
                        )}
                    </div>

                    {/* Steps Timeline Journey */}
                    <div className="space-y-3">
                        <div className="flex items-center justify-between">
                            <h4 className="text-xs font-bold uppercase tracking-wider text-muted-foreground">
                                Roteiro de Etapas ({total})
                            </h4>
                            <span className="text-[11px] text-muted-foreground">
                                Conclusão sequencial recomendada
                            </span>
                        </div>

                        {steps.length === 0 ? (
                            <div className="rounded-2xl border border-dashed border-border/60 p-8 text-center text-xs text-muted-foreground">
                                Nenhuma etapa cadastrada nesta trilha.
                            </div>
                        ) : (
                            <div className="space-y-2.5">
                                {steps.map((step, index) => {
                                    const isStepCompleted = userProgress.some((p) => p.step_id === step.id);
                                    const isUnlocked =
                                        index === 0 || userProgress.some((p) => p.step_id === steps[index - 1].id);
                                    const stepNote = notes.find((n) => n.media_resource_id === step.media_resource.id);

                                    return (
                                        <div
                                            key={step.id}
                                            onClick={() => isUnlocked && onSelectStep(step)}
                                            className={cn(
                                                "flex items-center justify-between p-3.5 sm:p-4 rounded-2xl border transition-all select-none",
                                                isUnlocked
                                                    ? "bg-card border-border/60 hover:border-primary/40 hover:bg-primary/5 cursor-pointer group shadow-2xs"
                                                    : "bg-muted/10 border-border/30 opacity-60 cursor-not-allowed"
                                            )}
                                        >
                                            <div className="flex items-center gap-3 min-w-0 pr-2">
                                                {/* Step Number Pip / Check */}
                                                <div
                                                    className={cn(
                                                        "flex h-8 w-8 shrink-0 items-center justify-center rounded-xl text-xs font-bold transition-transform",
                                                        isStepCompleted
                                                            ? "bg-green-500 text-white shadow-xs"
                                                            : isUnlocked
                                                            ? "bg-primary/10 text-primary group-hover:scale-105"
                                                            : "bg-muted text-muted-foreground"
                                                    )}
                                                >
                                                    {isStepCompleted ? (
                                                        <CheckIcon className="h-4 w-4 stroke-[3]" />
                                                    ) : (
                                                        index + 1
                                                    )}
                                                </div>

                                                {/* Step Info */}
                                                <div className="min-w-0">
                                                    <div className="flex items-center gap-2">
                                                        <span className="flex items-center gap-1 text-[11px] font-semibold text-muted-foreground">
                                                            {getResourceIcon(step.media_resource.type)}
                                                            {getResourceLabel(step.media_resource.type)}
                                                        </span>
                                                        {!isUnlocked && (
                                                            <span className="flex items-center gap-1 text-[10px] text-muted-foreground bg-muted/60 px-1.5 py-0.5 rounded-md">
                                                                <LockIcon className="h-2.5 w-2.5" /> Bloqueado
                                                            </span>
                                                        )}
                                                        {isStepCompleted && (
                                                            <span className="text-[10px] font-bold text-green-600 dark:text-green-400">
                                                                Concluída
                                                            </span>
                                                        )}
                                                    </div>
                                                    <h5
                                                        className={cn(
                                                            "truncate text-xs sm:text-sm font-semibold mt-0.5",
                                                            isUnlocked
                                                                ? "text-foreground group-hover:text-primary transition-colors"
                                                                : "text-muted-foreground"
                                                        )}
                                                        title={step.media_resource.title}
                                                    >
                                                        {step.media_resource.title}
                                                    </h5>
                                                </div>
                                            </div>

                                            {/* Action Control */}
                                            {isUnlocked && (
                                                <div className="flex items-center gap-1 shrink-0">
                                                    <Button
                                                        type="button"
                                                        variant="ghost"
                                                        size="icon"
                                                        onClick={(e) => {
                                                            e.stopPropagation();
                                                            onOpenStepNote(step.media_resource, study.id);
                                                        }}
                                                        className={cn(
                                                            "min-h-[44px] min-w-[44px] rounded-xl cursor-pointer",
                                                            stepNote
                                                                ? "text-primary bg-primary/10 hover:bg-primary/20"
                                                                : "text-muted-foreground hover:text-primary hover:bg-primary/10"
                                                        )}
                                                        title={stepNote ? "Ver reflexões deste material" : "Fazer anotações"}
                                                    >
                                                        <StickyNoteIcon className="h-4 w-4" />
                                                    </Button>

                                                    <Button
                                                        variant="ghost"
                                                        size="sm"
                                                        className="min-h-[44px] rounded-xl gap-1 text-xs font-semibold group-hover:bg-primary group-hover:text-primary-foreground transition-all"
                                                    >
                                                        <span className="hidden sm:inline">Acessar</span>
                                                        <ChevronRightIcon className="h-3.5 w-3.5" />
                                                    </Button>
                                                </div>
                                            )}
                                        </div>
                                    );
                                })}
                            </div>
                        )}
                    </div>
                </div>

                {/* Footer */}
                <DialogFooter className="p-4 sm:p-5 border-t border-border/50 shrink-0">
                    <Button
                        onClick={onClose}
                        variant="outline"
                        className="min-h-[44px] rounded-xl px-5 text-xs font-semibold cursor-pointer border-border/60"
                    >
                        Fechar
                    </Button>
                </DialogFooter>
            </DialogContent>
        </Dialog>
    );
}
