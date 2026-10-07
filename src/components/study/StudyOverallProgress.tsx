import { GraduationCapIcon, StickyNoteIcon, CheckCircle2Icon, BookOpenIcon } from "lucide-react";
import { Card, CardContent } from "@/components/ui/card";
import { Progress } from "@/components/ui/progress";

interface StudyOverallProgressProps {
    totalStudies: number;
    completedStudies: number;
    activeStudies: number;
    totalNotes: number;
    percent: number;
}

export function StudyOverallProgress({
    totalStudies,
    completedStudies,
    activeStudies,
    totalNotes,
    percent,
}: StudyOverallProgressProps) {
    if (totalStudies === 0) return null;

    return (
        <Card className="overflow-hidden rounded-2xl border-border/60 bg-card/40 backdrop-blur-sm shadow-xs transition-all">
            <CardContent className="p-4 sm:p-6">
                <div className="grid grid-cols-1 gap-6 lg:grid-cols-12 lg:items-center">
                    {/* Main Progress Indicator */}
                    <div className="space-y-3 lg:col-span-7">
                        <div className="flex items-center justify-between">
                            <div className="flex items-center gap-2">
                                <div className="flex h-9 w-9 items-center justify-center rounded-xl bg-primary/10 text-primary">
                                    <GraduationCapIcon className="h-5 w-5" />
                                </div>
                                <div>
                                    <h3 className="text-sm font-bold text-foreground sm:text-base">
                                        Progresso Geral nas Trilhas
                                    </h3>
                                    <p className="text-xs text-muted-foreground">
                                        Crescimento pessoal através das ministrações estruturadas
                                    </p>
                                </div>
                            </div>
                            <span className="rounded-full bg-primary/10 px-2.5 py-1 text-xs font-bold text-primary">
                                {percent}%
                            </span>
                        </div>

                        <div className="space-y-1.5">
                            <Progress value={percent} className="h-2.5 bg-muted/80" />
                            <div className="flex justify-between text-[11px] font-medium text-muted-foreground">
                                <span>{completedStudies} de {totalStudies} {totalStudies === 1 ? "trilha concluída" : "trilhas concluídas"}</span>
                                <span>{totalStudies - completedStudies} {totalStudies - completedStudies === 1 ? "restante" : "restantes"}</span>
                            </div>
                        </div>
                    </div>

                    {/* Quick KPI stats */}
                    <div className="grid grid-cols-2 gap-3 border-t border-border/50 pt-4 sm:grid-cols-3 sm:pt-0 lg:col-span-5 lg:border-t-0 lg:border-l lg:pl-6">
                        <div className="rounded-xl border border-border/40 bg-muted/20 p-3">
                            <div className="flex items-center gap-1.5 text-xs text-muted-foreground">
                                <BookOpenIcon className="h-3.5 w-3.5 text-primary" />
                                <span>Em Andamento</span>
                            </div>
                            <p className="mt-1 text-lg font-bold text-foreground sm:text-xl">
                                {activeStudies}
                            </p>
                            <span className="text-[10px] text-muted-foreground">
                                {activeStudies === 1 ? "Trilha ativa" : "Trilhas ativas"}
                            </span>
                        </div>

                        <div className="rounded-xl border border-border/40 bg-muted/20 p-3">
                            <div className="flex items-center gap-1.5 text-xs text-muted-foreground">
                                <CheckCircle2Icon className="h-3.5 w-3.5 text-green-600 dark:text-green-400" />
                                <span>Concluídas</span>
                            </div>
                            <p className="mt-1 text-lg font-bold text-foreground sm:text-xl">
                                {completedStudies}
                            </p>
                            <span className="text-[10px] text-muted-foreground">
                                {completedStudies === 1 ? "Trilha finalizada" : "Trilhas finalizadas"}
                            </span>
                        </div>

                        <div className="col-span-2 rounded-xl border border-border/40 bg-muted/20 p-3 sm:col-span-1">
                            <div className="flex items-center gap-1.5 text-xs text-muted-foreground">
                                <StickyNoteIcon className="h-3.5 w-3.5 text-amber-600 dark:text-amber-400" />
                                <span>Anotações</span>
                            </div>
                            <p className="mt-1 text-lg font-bold text-foreground sm:text-xl">
                                {totalNotes}
                            </p>
                            <span className="text-[10px] text-muted-foreground">
                                {totalNotes === 1 ? "Reflexão salva" : "Reflexões salvas"}
                            </span>
                        </div>
                    </div>
                </div>
            </CardContent>
        </Card>
    );
}
