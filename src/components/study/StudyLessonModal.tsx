import { useState, useEffect, useRef } from "react";
import { 
    CheckIcon, 
    CheckCircle2Icon,
    ChevronLeftIcon,
    ChevronRightIcon, 
    YoutubeIcon, 
    FileTextIcon, 
    DownloadIcon, 
    EyeIcon, 
    PencilIcon, 
    StickyNoteIcon,
    PlayIcon,
    XIcon
} from "lucide-react";
import { cn } from "@/lib/utils";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Dialog, DialogContent, DialogTitle, DialogDescription } from "@/components/ui/dialog";
import { MarkdownViewer } from "./MarkdownViewer";
import { TextEditor } from "@/components/TextEditor";
import type { Database } from "@/lib/database.types";

type MediaResource = Database["public"]["Tables"]["media_resources"]["Row"];
type StudyStep = Database["public"]["Tables"]["study_steps"]["Row"] & {
    media_resource: MediaResource;
};
type UserProgress = Database["public"]["Tables"]["user_study_progress"]["Row"];
type StudyNote = Database["public"]["Tables"]["study_notes"]["Row"];

interface StudyLessonModalProps {
    step: StudyStep | null;
    allStudySteps?: StudyStep[];
    studyTitle?: string;
    initialNotesOpen?: boolean;
    userProgress: UserProgress[];
    existingNote?: StudyNote | null;
    canAddMaterial: boolean;
    onClose: () => void;
    onToggleComplete: (step: StudyStep) => Promise<void>;
    onNavigateStep: (step: StudyStep) => void;
    onSaveNote: (data: { title: string; description: string; markdownContent: string }) => Promise<void>;
    onDeleteNote?: (noteId?: string) => Promise<void>;
    onEditTextResource?: (resource: MediaResource) => void;
}

const getYouTubeId = (url: string) => {
    const regExp = /^.*(youtu.be\/|v\/|u\/\w\/|embed\/|watch\?v=|&v=)([^#&?]*).*/;
    const match = url.match(regExp);
    return match && match[2].length === 11 ? match[2] : null;
};

export function StudyLessonModal({
    step,
    allStudySteps = [],
    studyTitle,
    initialNotesOpen = false,
    userProgress,
    existingNote,
    canAddMaterial,
    onClose,
    onToggleComplete,
    onNavigateStep,
    onSaveNote,
    onDeleteNote,
    onEditTextResource,
}: StudyLessonModalProps) {
    const [isSideBySideNotesOpen, setIsSideBySideNotesOpen] = useState(initialNotesOpen);
    const [mobileTab, setMobileTab] = useState<"content" | "notes">(initialNotesOpen ? "notes" : "content");
    const [isTogglingComplete, setIsTogglingComplete] = useState(false);
    const prevOpenRef = useRef(false);

    useEffect(() => {
        const isOpen = Boolean(step);
        if (isOpen && !prevOpenRef.current) {
            // First opening of modal: respect initialNotesOpen
            setIsSideBySideNotesOpen(initialNotesOpen);
            setMobileTab(initialNotesOpen ? "notes" : "content");
        } else if (isOpen && initialNotesOpen && !isSideBySideNotesOpen) {
            // Explicit trigger to open notes from parent
            setIsSideBySideNotesOpen(true);
            setMobileTab("notes");
        } else if (!isOpen) {
            setIsSideBySideNotesOpen(false);
            setMobileTab("content");
        }
        prevOpenRef.current = isOpen;
    }, [step, initialNotesOpen, isSideBySideNotesOpen]);

    if (!step) return null;

    const resObj = step.media_resource;
    const isStudyStep = Boolean(step.id); // false if individual media preview
    const isStepCompleted = isStudyStep && userProgress.some((p) => p.step_id === step.id);

    // Current step index and navigation targets
    const currentIndex = allStudySteps.findIndex((s) => s.id === step.id);
    const hasPrevious = currentIndex > 0;
    const hasNext = currentIndex >= 0 && currentIndex < allStudySteps.length - 1;
    const prevStep = hasPrevious ? allStudySteps[currentIndex - 1] : null;
    const nextStep = hasNext ? allStudySteps[currentIndex + 1] : null;

    const handleCompleteStep = async () => {
        try {
            setIsTogglingComplete(true);
            await onToggleComplete(step);
        } finally {
            setIsTogglingComplete(false);
        }
    };

    const renderMediaContent = () => (
        <div className="bg-muted/20 border border-border/50 rounded-2xl overflow-hidden flex flex-col justify-center min-h-[260px] sm:min-h-[340px]">
            {/* Video Rendering */}
            {resObj.type === "video" && (() => {
                const ytId = getYouTubeId(resObj.url);
                if (ytId) {
                    return (
                        <div className="aspect-video w-full bg-black/95">
                            <iframe
                                width="100%"
                                height="100%"
                                src={`https://www.youtube.com/embed/${ytId}?autoplay=1`}
                                title={resObj.title}
                                frameBorder="0"
                                allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
                                allowFullScreen
                                className="w-full h-full"
                            />
                        </div>
                    );
                }
                return (
                    <div className="flex flex-col items-center justify-center p-6 sm:p-8 text-center">
                        <YoutubeIcon className="h-10 w-10 sm:h-12 sm:w-12 text-destructive mb-3" />
                        <h5 className="font-semibold text-sm sm:text-base mb-1">Vídeo Externo</h5>
                        <p className="text-xs text-muted-foreground max-w-sm mb-4">
                            Este vídeo está hospedado externamente.
                        </p>
                        <a href={resObj.url} target="_blank" rel="noopener noreferrer">
                            <Button className="rounded-xl gap-2 min-h-[44px]">
                                <PlayIcon className="h-4 w-4" />
                                Abrir no YouTube
                            </Button>
                        </a>
                    </div>
                );
            })()}

            {/* PDF Rendering */}
            {resObj.type === "pdf" && (
                <div className="flex flex-col items-center justify-center p-6 sm:p-10 text-center min-h-[280px]">
                    <div className="w-16 h-16 rounded-2xl bg-red-500/10 flex items-center justify-center mb-3">
                        <FileTextIcon className="h-8 w-8 text-red-500" />
                    </div>
                    <h5 className="font-bold text-base sm:text-lg mb-1 text-foreground">
                        Apostila / Documento PDF
                    </h5>
                    <p className="text-xs sm:text-sm text-muted-foreground max-w-md mb-5 leading-relaxed">
                        Abra o material de apoio para acompanhar a leitura junto com suas anotações pessoais.
                    </p>
                    <div className="flex flex-col sm:flex-row gap-2.5 w-full sm:w-auto justify-center">
                        <a href={resObj.url} target="_blank" rel="noopener noreferrer" className="w-full sm:w-auto">
                            <Button className="rounded-xl gap-2 w-full px-5 min-h-[44px] shadow-xs cursor-pointer">
                                <EyeIcon className="h-4 w-4" />
                                Visualizar PDF
                            </Button>
                        </a>
                        <a href={resObj.url} download className="w-full sm:w-auto">
                            <Button variant="outline" className="rounded-xl gap-2 w-full px-5 min-h-[44px] border-border/60 cursor-pointer">
                                <DownloadIcon className="h-4 w-4" />
                                Baixar Arquivo
                            </Button>
                        </a>
                    </div>
                </div>
            )}

            {/* Markdown Rendering */}
            {resObj.type === "markdown" && (
                <div className="p-4 sm:p-6 max-h-[520px] overflow-y-auto">
                    <MarkdownViewer url={resObj.url} />
                </div>
            )}
        </div>
    );

    return (
        <Dialog open={Boolean(step)} onOpenChange={(open) => !open && onClose()}>
            <DialogContent
                showCloseButton={false}
                className={cn(
                    "bg-card border-border/60 shadow-2xl rounded-3xl p-0 transition-all duration-300 ease-in-out overflow-hidden flex flex-col",
                    isSideBySideNotesOpen
                        ? "w-[98vw] sm:max-w-6xl md:max-w-7xl max-w-[1550px] h-[94vh]"
                        : (resObj.type === "markdown"
                            ? "sm:max-w-4xl w-[95vw] max-h-[90vh]"
                            : "sm:max-w-3xl w-[95vw] max-h-[90vh]")
                )}
            >
                <DialogDescription className="sr-only">
                    Visualizador da ministração e anotações pessoais de estudo
                </DialogDescription>

                {/* Top Navigation Bar */}
                <div className="p-4 sm:p-5 pb-3 border-b border-border/50 shrink-0 bg-card/80 backdrop-blur-sm flex flex-col gap-3">
                    <div className="flex items-center justify-between gap-3">
                        {/* Breadcrumbs & Title */}
                        <div className="min-w-0 flex-1">
                            <div className="flex flex-wrap items-center gap-1.5 sm:gap-2">
                                <Badge variant="secondary" className="text-[10px] uppercase tracking-wider font-bold px-2 py-0.5">
                                    {resObj.type === "video" ? "Vídeo" : resObj.type === "pdf" ? "Apostila PDF" : "Leitura"}
                                </Badge>
                                {isStudyStep && (
                                    <span className="text-[11px] text-muted-foreground font-medium truncate max-w-[200px] sm:max-w-none">
                                        {studyTitle ? `${studyTitle} • ` : ""}Etapa {currentIndex + 1} de {allStudySteps.length}
                                    </span>
                                )}
                                {isStepCompleted && (
                                    <Badge variant="outline" className="text-[10px] text-green-600 border-green-500/30 bg-green-500/10 font-semibold gap-1">
                                        <CheckIcon className="h-3 w-3 stroke-[3]" /> Concluída
                                    </Badge>
                                )}
                                {isSideBySideNotesOpen && (
                                    <Badge variant="outline" className="hidden sm:inline-flex text-[10px] text-primary border-primary/30 bg-primary/5 font-semibold">
                                        Modo Estudo com Anotações
                                    </Badge>
                                )}
                            </div>
                            <DialogTitle className="text-base sm:text-lg font-bold text-foreground truncate mt-1" title={resObj.title}>
                                {resObj.title}
                            </DialogTitle>
                        </div>

                        {/* Top Action Buttons */}
                        <div className="flex items-center gap-2 shrink-0">
                            {/* Notes Toggle Button */}
                            <Button
                                variant="outline"
                                size="sm"
                                onClick={() => {
                                    const nextState = !isSideBySideNotesOpen;
                                    setIsSideBySideNotesOpen(nextState);
                                    if (nextState) setMobileTab("notes");
                                    else setMobileTab("content");
                                }}
                                className={cn(
                                    "min-h-[44px] gap-2 rounded-xl text-xs font-semibold px-3.5 cursor-pointer transition-all",
                                    isSideBySideNotesOpen || existingNote
                                        ? "border-primary/40 bg-primary/10 text-primary font-semibold shadow-2xs"
                                        : "border-border/60 hover:bg-primary/5 hover:text-primary text-muted-foreground"
                                )}
                                title={isSideBySideNotesOpen ? "Ocultar anotações" : "Anotar neste material"}
                            >
                                <StickyNoteIcon className="h-4 w-4" />
                                <span className="hidden sm:inline">
                                    {isSideBySideNotesOpen ? "Ocultar Anotações" : (existingNote ? "Minhas Anotações" : "Anotar")}
                                </span>
                                <span className="sm:hidden">
                                    {isSideBySideNotesOpen ? "Ocultar" : "Anotar"}
                                </span>
                            </Button>

                            <Button
                                variant="ghost"
                                size="icon"
                                onClick={onClose}
                                className="min-h-[44px] min-w-[44px] rounded-xl text-muted-foreground hover:text-foreground cursor-pointer"
                                title="Fechar Estudo"
                            >
                                <XIcon className="h-5 w-5" />
                            </Button>
                        </div>
                    </div>

                    {/* Mobile Segmented Switcher (Visible on < lg screens only when notes are open) */}
                    {isSideBySideNotesOpen && (
                        <div className="flex lg:hidden rounded-xl border border-border/60 bg-muted/30 p-1">
                            <button
                                type="button"
                                onClick={() => setMobileTab("content")}
                                className={cn(
                                    "flex-1 min-h-[38px] rounded-lg text-xs font-semibold transition-all cursor-pointer",
                                    mobileTab === "content"
                                        ? "bg-background text-foreground shadow-2xs"
                                        : "text-muted-foreground hover:text-foreground"
                                )}
                            >
                                Conteúdo da Aula
                            </button>
                            <button
                                type="button"
                                onClick={() => setMobileTab("notes")}
                                className={cn(
                                    "flex-1 min-h-[38px] rounded-lg text-xs font-semibold transition-all cursor-pointer flex items-center justify-center gap-1.5",
                                    mobileTab === "notes"
                                        ? "bg-background text-foreground shadow-2xs"
                                        : "text-muted-foreground hover:text-foreground"
                                )}
                            >
                                <StickyNoteIcon className="h-3.5 w-3.5" />
                                <span>Minhas Anotações</span>
                                {existingNote && (
                                    <span className="h-1.5 w-1.5 rounded-full bg-primary" />
                                )}
                            </button>
                        </div>
                    )}
                </div>

                {/* Main Content Area */}
                {isSideBySideNotesOpen ? (
                    <div className="flex-1 min-h-0 grid grid-cols-1 lg:grid-cols-12 gap-4 sm:gap-6 p-4 sm:p-6 overflow-y-auto lg:overflow-hidden">
                        {/* Media Column (Left, 7 cols) */}
                        <div className={cn(
                            "flex flex-col h-full min-h-0 overflow-y-auto pr-0 lg:pr-2 space-y-4 lg:col-span-7",
                            mobileTab === "notes" && "hidden lg:flex"
                        )}>
                            {renderMediaContent()}

                            {resObj.description && resObj.type !== "markdown" && (
                                <div className="rounded-xl border border-border/40 bg-muted/15 p-3.5 sm:p-4 text-xs sm:text-sm text-muted-foreground shrink-0">
                                    <p className="font-bold text-foreground mb-1">Sobre esta ministração:</p>
                                    <p className="leading-relaxed">{resObj.description}</p>
                                </div>
                            )}

                            {/* Controls Bar */}
                            <div className="mt-auto pt-3 border-t border-border/50 flex flex-col sm:flex-row items-stretch sm:items-center justify-between gap-3 shrink-0">
                                <div className="flex items-center gap-2">
                                    {isStudyStep && hasPrevious && prevStep && (
                                        <Button
                                            variant="outline"
                                            size="sm"
                                            onClick={() => onNavigateStep(prevStep)}
                                            className="min-h-[44px] gap-1.5 rounded-xl text-xs font-semibold border-border/60 cursor-pointer"
                                        >
                                            <ChevronLeftIcon className="h-4 w-4" />
                                            <span>Anterior</span>
                                        </Button>
                                    )}

                                    {canAddMaterial && resObj.type === "markdown" && onEditTextResource && (
                                        <Button
                                            variant="outline"
                                            size="sm"
                                            onClick={() => onEditTextResource(resObj)}
                                            className="min-h-[44px] gap-1.5 rounded-xl text-xs font-semibold text-amber-600 border-amber-600/20 hover:bg-amber-500/10 cursor-pointer"
                                        >
                                            <PencilIcon className="h-3.5 w-3.5" />
                                            <span>Editar Texto</span>
                                        </Button>
                                    )}

                                    <Button
                                        variant="ghost"
                                        size="sm"
                                        onClick={() => setIsSideBySideNotesOpen(false)}
                                        className="min-h-[44px] rounded-xl text-xs font-medium text-muted-foreground hover:text-foreground cursor-pointer"
                                    >
                                        Ocultar Anotações
                                    </Button>
                                </div>

                                <div className="flex items-center justify-end gap-2">
                                    {isStudyStep ? (
                                        <Button
                                            onClick={handleCompleteStep}
                                            disabled={isTogglingComplete}
                                            className={cn(
                                                "min-h-[44px] px-5 rounded-xl gap-2 text-xs sm:text-sm font-semibold shadow-xs cursor-pointer transition-all flex-1 sm:flex-none",
                                                isStepCompleted
                                                    ? "bg-green-600 hover:bg-green-700 text-white shadow-green-600/15"
                                                    : "bg-zinc-900 text-zinc-50 hover:bg-zinc-800 dark:bg-zinc-50 dark:text-zinc-900 dark:hover:bg-zinc-200"
                                            )}
                                        >
                                            {isStepCompleted ? (
                                                <>
                                                    <CheckIcon className="h-4 w-4 stroke-[3]" />
                                                    Etapa Concluída
                                                </>
                                            ) : (
                                                <>
                                                    <CheckCircle2Icon className="h-4 w-4" />
                                                    Concluir Etapa
                                                </>
                                            )}
                                        </Button>
                                    ) : (
                                        <span className="text-xs text-muted-foreground italic">
                                            Recurso individual do acervo
                                        </span>
                                    )}

                                    {isStudyStep && hasNext && nextStep && (
                                        <Button
                                            variant="outline"
                                            size="sm"
                                            onClick={() => onNavigateStep(nextStep)}
                                            className="min-h-[44px] gap-1.5 rounded-xl text-xs font-semibold border-border/60 cursor-pointer"
                                        >
                                            <span>Próxima</span>
                                            <ChevronRightIcon className="h-4 w-4" />
                                        </Button>
                                    )}
                                </div>
                            </div>
                        </div>

                        {/* Notes Column (Right, 5 cols) */}
                        <div className={cn(
                            "flex flex-col h-full min-h-[450px] lg:col-span-5 min-h-0",
                            mobileTab === "content" && "hidden lg:flex"
                        )}>
                            <TextEditor
                                inline={true}
                                isOpen={true}
                                mode="note"
                                modalTitle={`Anotações: ${resObj.title}`}
                                modalDescription="Suas reflexões privadas sobre esta ministração."
                                initialData={existingNote ? {
                                    id: existingNote.id,
                                    title: existingNote.title,
                                    content: existingNote.content,
                                } : {
                                    title: `Anotações: ${resObj.title}`,
                                    content: "",
                                }}
                                onClose={() => {
                                    setIsSideBySideNotesOpen(false);
                                    setMobileTab("content");
                                }}
                                onSave={onSaveNote}
                                onDelete={existingNote && onDeleteNote ? () => onDeleteNote(existingNote.id) : undefined}
                                className="h-full"
                            />
                        </div>
                    </div>
                ) : (
                    /* Compact Single-Column Layout (Notes Closed) */
                    <div className="flex-1 overflow-y-auto p-4 sm:p-6 space-y-4">
                        {renderMediaContent()}

                        {resObj.description && resObj.type !== "markdown" && (
                            <div className="rounded-xl border border-border/40 bg-muted/15 p-3.5 sm:p-4 text-xs sm:text-sm text-muted-foreground">
                                <p className="font-bold text-foreground mb-1">Sobre esta ministração:</p>
                                <p className="leading-relaxed">{resObj.description}</p>
                            </div>
                        )}

                        {/* Controls Bar */}
                        <div className="pt-3 border-t border-border/50 flex flex-wrap items-center justify-between gap-3">
                            <div className="flex flex-wrap items-center gap-2">
                                <Button
                                    type="button"
                                    variant="ghost"
                                    onClick={onClose}
                                    className="rounded-xl px-4 min-h-[44px] text-xs font-medium cursor-pointer"
                                >
                                    Voltar
                                </Button>

                                <Button
                                    variant="outline"
                                    onClick={() => {
                                        setIsSideBySideNotesOpen(true);
                                        setMobileTab("notes");
                                    }}
                                    className={cn(
                                        "rounded-xl px-4 gap-2 text-xs font-semibold min-h-[44px] cursor-pointer transition-all",
                                        existingNote
                                            ? "border-primary/40 bg-primary/10 text-primary font-semibold shadow-2xs"
                                            : "border-border/60 hover:bg-primary/5 hover:text-primary"
                                    )}
                                >
                                    <StickyNoteIcon className="h-4 w-4" />
                                    <span>{existingNote ? "Minhas Anotações" : "Fazer Anotações"}</span>
                                </Button>

                                {canAddMaterial && resObj.type === "markdown" && onEditTextResource && (
                                    <Button
                                        variant="outline"
                                        size="sm"
                                        onClick={() => onEditTextResource(resObj)}
                                        className="min-h-[44px] gap-1.5 rounded-xl text-xs font-semibold text-amber-600 border-amber-600/20 hover:bg-amber-500/10 cursor-pointer"
                                    >
                                        <PencilIcon className="h-3.5 w-3.5" />
                                        <span>Editar Texto</span>
                                    </Button>
                                )}
                            </div>

                            <div className="flex items-center gap-2">
                                {isStudyStep && hasPrevious && prevStep && (
                                    <Button
                                        variant="outline"
                                        size="sm"
                                        onClick={() => onNavigateStep(prevStep)}
                                        className="min-h-[44px] gap-1.5 rounded-xl text-xs font-semibold border-border/60 cursor-pointer"
                                    >
                                        <ChevronLeftIcon className="h-4 w-4" />
                                        <span>Anterior</span>
                                    </Button>
                                )}

                                {isStudyStep ? (
                                    <Button
                                        onClick={handleCompleteStep}
                                        disabled={isTogglingComplete}
                                        className={cn(
                                            "min-h-[44px] px-5 rounded-xl gap-2 text-xs sm:text-sm font-semibold shadow-xs cursor-pointer transition-all",
                                            isStepCompleted
                                                ? "bg-green-600 hover:bg-green-700 text-white shadow-green-600/15"
                                                : "bg-zinc-900 text-zinc-50 hover:bg-zinc-800 dark:bg-zinc-50 dark:text-zinc-900 dark:hover:bg-zinc-200"
                                        )}
                                    >
                                        {isStepCompleted ? (
                                            <>
                                                <CheckIcon className="h-4 w-4 stroke-[3]" />
                                                Etapa Concluída
                                            </>
                                        ) : (
                                            <>
                                                <CheckCircle2Icon className="h-4 w-4" />
                                                Concluir Etapa
                                            </>
                                        )}
                                    </Button>
                                ) : (
                                    <span className="text-xs text-muted-foreground italic">
                                        Recurso individual do acervo
                                    </span>
                                )}

                                {isStudyStep && hasNext && nextStep && (
                                    <Button
                                        variant="outline"
                                        size="sm"
                                        onClick={() => onNavigateStep(nextStep)}
                                        className="min-h-[44px] gap-1.5 rounded-xl text-xs font-semibold border-border/60 cursor-pointer"
                                    >
                                        <span>Próxima</span>
                                        <ChevronRightIcon className="h-4 w-4" />
                                    </Button>
                                )}
                            </div>
                        </div>
                    </div>
                )}
            </DialogContent>
        </Dialog>
    );
}
