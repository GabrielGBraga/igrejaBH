import React from "react";
import { 
    CheckCircle2Icon, 
    ChevronRightIcon, 
    PencilIcon, 
    Trash2Icon, 
    StickyNoteIcon, 
    LayersIcon,
    PlayIcon
} from "lucide-react";
import { cn } from "@/lib/utils";
import { Button } from "@/components/ui/button";
import { Card, CardHeader, CardTitle, CardDescription, CardContent, CardFooter } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Progress } from "@/components/ui/progress";
import type { Database } from "@/lib/database.types";

type Study = Database["public"]["Tables"]["studies"]["Row"];
type StudyNote = Database["public"]["Tables"]["study_notes"]["Row"];

interface StudyCardProps {
    study: Study;
    totalSteps: number;
    completedSteps: number;
    percent: number;
    studyNote?: StudyNote | null;
    canAddMaterial: boolean;
    onClick: () => void;
    onOpenNote: (e: React.MouseEvent) => void;
    onEdit: (e: React.MouseEvent) => void;
    onDelete: (e: React.MouseEvent) => void;
}

export function StudyCard({
    study,
    totalSteps,
    completedSteps,
    percent,
    studyNote,
    canAddMaterial,
    onClick,
    onOpenNote,
    onEdit,
    onDelete,
}: StudyCardProps) {
    const isCompleted = percent === 100 && totalSteps > 0;
    const isStarted = percent > 0 && !isCompleted;

    const getStatusBadge = () => {
        if (isCompleted) {
            return (
                <Badge variant="outline" className="gap-1 border-green-500/30 bg-green-500/10 text-green-700 dark:text-green-400 text-[11px] font-semibold">
                    <CheckCircle2Icon className="h-3 w-3" />
                    Concluído
                </Badge>
            );
        }
        if (isStarted) {
            return (
                <Badge variant="outline" className="gap-1 border-primary/30 bg-primary/10 text-primary text-[11px] font-semibold">
                    <PlayIcon className="h-3 w-3 fill-primary" />
                    Em andamento
                </Badge>
            );
        }
        return (
            <Badge variant="outline" className="border-border/60 bg-muted/40 text-muted-foreground text-[11px] font-medium">
                Não iniciado
            </Badge>
        );
    };

    return (
        <Card
            onClick={onClick}
            className="group flex flex-col justify-between overflow-hidden rounded-2xl border-border/60 bg-card/40 backdrop-blur-sm shadow-xs transition-all duration-300 hover:border-primary/40 hover:shadow-lg hover:shadow-primary/5 cursor-pointer relative"
        >
            <CardHeader className="p-5 pb-3">
                <div className="flex items-start justify-between gap-2">
                    <div className="flex flex-wrap items-center gap-1.5">
                        {getStatusBadge()}
                        <Badge variant="secondary" className="gap-1 text-[11px] font-medium bg-muted/50 text-muted-foreground border-transparent">
                            <LayersIcon className="h-3 w-3" />
                            {totalSteps} {totalSteps === 1 ? "etapa" : "etapas"}
                        </Badge>
                    </div>

                    <div className="flex items-center gap-0.5 shrink-0 -mt-1 -mr-1">
                        <Button
                            variant="ghost"
                            size="icon"
                            onClick={onOpenNote}
                            className={cn(
                                "min-h-[44px] min-w-[44px] rounded-xl transition-all cursor-pointer",
                                studyNote
                                    ? "text-primary bg-primary/10 hover:bg-primary/20"
                                    : "text-muted-foreground hover:text-primary hover:bg-primary/10"
                            )}
                            title={studyNote ? "Ver reflexões deste estudo" : "Fazer anotações neste estudo"}
                        >
                            <StickyNoteIcon className="h-4 w-4" />
                        </Button>

                        {canAddMaterial && (
                            <>
                                <Button
                                    variant="ghost"
                                    size="icon"
                                    onClick={onEdit}
                                    className="min-h-[44px] min-w-[44px] rounded-xl text-muted-foreground hover:text-primary hover:bg-primary/10 transition-colors"
                                    title="Editar Trilha"
                                >
                                    <PencilIcon className="h-4 w-4" />
                                </Button>
                                <Button
                                    variant="ghost"
                                    size="icon"
                                    onClick={onDelete}
                                    className="min-h-[44px] min-w-[44px] rounded-xl text-muted-foreground hover:text-destructive hover:bg-destructive/10 transition-colors"
                                    title="Excluir Trilha"
                                >
                                    <Trash2Icon className="h-4 w-4" />
                                </Button>
                            </>
                        )}
                    </div>
                </div>

                <CardTitle className="mt-2 text-base font-bold text-foreground transition-colors group-hover:text-primary sm:text-lg leading-snug">
                    {study.title}
                </CardTitle>

                <CardDescription className="line-clamp-2 text-xs text-muted-foreground pt-1 leading-relaxed">
                    {study.description || "Trilha formativa de ensinos e ministração no Corpo de Cristo."}
                </CardDescription>
            </CardHeader>

            <CardContent className="px-5 py-2">
                <div className="space-y-1.5 rounded-xl border border-border/40 bg-muted/20 p-3">
                    <div className="flex justify-between text-xs">
                        <span className="text-muted-foreground font-medium">
                            {completedSteps} de {totalSteps} {totalSteps === 1 ? "etapa concluída" : "etapas concluídas"}
                        </span>
                        <div className="flex items-center gap-1.5 font-bold">
                            {studyNote && (
                                <span className="text-[10px] text-primary flex items-center gap-0.5">
                                    <StickyNoteIcon className="h-3 w-3" /> Anotado
                                </span>
                            )}
                            <span className="text-foreground">{percent}%</span>
                        </div>
                    </div>
                    <Progress value={percent} className="h-2 bg-muted/70" />
                </div>
            </CardContent>

            <CardFooter className="p-5 pt-3 border-t border-border/40">
                <Button
                    variant={isCompleted ? "outline" : "default"}
                    className={cn(
                        "w-full min-h-[44px] gap-2 rounded-xl text-xs font-semibold transition-all cursor-pointer",
                        isCompleted
                            ? "border-border/60 hover:bg-primary hover:text-primary-foreground"
                            : "bg-zinc-900 text-zinc-50 hover:bg-zinc-800 dark:bg-zinc-50 dark:text-zinc-900 dark:hover:bg-zinc-200"
                    )}
                >
                    <span>
                        {isCompleted ? "Revisar Trilha" : isStarted ? "Continuar Trilha" : "Iniciar Trilha"}
                    </span>
                    <ChevronRightIcon className="h-4 w-4 transition-transform group-hover:translate-x-1" />
                </Button>
            </CardFooter>
        </Card>
    );
}
