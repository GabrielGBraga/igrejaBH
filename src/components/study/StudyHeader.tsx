import { PlusIcon, PencilIcon } from "lucide-react";
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
            <div className="space-y-1">
                <h1 className="text-2xl font-bold tracking-tight text-foreground sm:text-3xl">
                    Ensinos
                </h1>
                <p className="max-w-2xl text-xs text-muted-foreground sm:text-sm">
                    Estudos, ministrações e materiais para a edificação da igreja.
                </p>
            </div>

            {canAddMaterial && (
                <div className="flex flex-wrap items-center gap-2.5 pt-2 sm:pt-0">
                    <Button
                        onClick={onCreateStudy}
                        className="btn-tactile min-h-[44px] gap-2 rounded-xl px-4 text-xs font-semibold sm:text-sm"
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
                            variant="secondary"
                            className="min-h-[44px] gap-2 rounded-xl px-4 text-xs font-semibold shadow-xs transition-all cursor-pointer sm:text-sm"
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
