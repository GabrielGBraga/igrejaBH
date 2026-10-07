import { PlusIcon, PencilIcon, SparklesIcon } from "lucide-react";
import { Button } from "@/components/ui/button";

interface StudyHeaderProps {
    canAddMaterial: boolean;
    activeTab: string;
    onCreateStudy: () => void;
    onAddResource: () => void;
    onWriteText: () => void;
}

export function StudyHeader({
    canAddMaterial,
    activeTab,
    onCreateStudy,
    onAddResource,
    onWriteText,
}: StudyHeaderProps) {
    return (
        <div className="flex flex-col gap-4 border-b border-border/60 pb-6 md:flex-row md:items-center md:justify-between">
            <div className="space-y-1.5">
                <div className="flex items-center gap-2">
                    <span className="inline-flex items-center gap-1 rounded-full bg-primary/10 px-2.5 py-0.5 text-xs font-semibold text-primary">
                        <SparklesIcon className="h-3 w-3" />
                        Vida no Corpo
                    </span>
                    <span className="text-xs text-muted-foreground">
                        Atos 2:42
                    </span>
                </div>
                <h1 className="text-2xl font-bold tracking-tight text-foreground sm:text-3xl">
                    Edificação e Discipulado
                </h1>
                <p className="max-w-2xl text-xs text-muted-foreground sm:text-sm">
                    Trilhas de aprendizado, acervo bíblico e anotações para o crescimento mútuo no Corpo de Cristo.
                </p>
            </div>

            {canAddMaterial && (
                <div className="flex flex-wrap items-center gap-2.5 pt-2 sm:pt-0">
                    <Button
                        onClick={onCreateStudy}
                        className="min-h-[44px] gap-2 rounded-xl bg-zinc-900 px-4 text-xs font-semibold text-zinc-50 shadow-sm transition-all hover:bg-zinc-800 dark:bg-zinc-50 dark:text-zinc-900 dark:hover:bg-zinc-200 cursor-pointer sm:text-sm"
                    >
                        <PlusIcon className="h-4 w-4" />
                        Nova Trilha
                    </Button>

                    <Button
                        onClick={onAddResource}
                        variant="outline"
                        className="min-h-[44px] gap-2 rounded-xl border-border/80 px-4 text-xs font-semibold transition-all hover:border-primary/40 hover:bg-primary/5 hover:text-primary cursor-pointer sm:text-sm"
                    >
                        <PlusIcon className="h-4 w-4" />
                        Adicionar Recurso
                    </Button>

                    {activeTab === "textos" && (
                        <Button
                            onClick={onWriteText}
                            className="min-h-[44px] gap-2 rounded-xl bg-amber-600 px-4 text-xs font-semibold text-white shadow-sm transition-all hover:bg-amber-700 cursor-pointer sm:text-sm"
                        >
                            <PencilIcon className="h-4 w-4" />
                            Escrever Texto
                        </Button>
                    )}
                </div>
            )}
        </div>
    );
}
