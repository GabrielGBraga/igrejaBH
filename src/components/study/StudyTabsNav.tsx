import { 
    SearchIcon, 
    XIcon,
    GraduationCapIcon, 
    YoutubeIcon, 
    FileTextIcon, 
    BookOpenIcon, 
    StickyNoteIcon 
} from "lucide-react";
import { cn } from "@/lib/utils";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";

export type TabType = "estudos" | "videos" | "pdfs" | "textos" | "anotacoes";

interface TabCount {
    estudos: number;
    videos: number;
    pdfs: number;
    textos: number;
    anotacoes: number;
}

interface StudyTabsNavProps {
    activeTab: TabType;
    onTabChange: (tab: TabType) => void;
    searchQuery: string;
    onSearchChange: (query: string) => void;
    counts: TabCount;
    selectedCategory?: string;
    onCategoryChange?: (category: string) => void;
}

const CATEGORY_CHIPS = [
    { id: "todos", label: "Todos" },
    { id: "fundamentos", label: "Fundamentos" },
    { id: "casas", label: "Vida nas Casas" },
    { id: "oracao", label: "Oração" },
    { id: "sacerdocio", label: "Sacerdócio" },
    { id: "evangelho", label: "Evangelho do Reino" },
];

export function StudyTabsNav({
    activeTab,
    onTabChange,
    searchQuery,
    onSearchChange,
    counts,
    selectedCategory = "todos",
    onCategoryChange,
}: StudyTabsNavProps) {
    const tabs = [
        { id: "estudos" as TabType, label: "Trilhas de Estudo", icon: GraduationCapIcon, count: counts.estudos },
        { id: "videos" as TabType, label: "Vídeos", icon: YoutubeIcon, count: counts.videos },
        { id: "pdfs" as TabType, label: "Apostilas PDF", icon: FileTextIcon, count: counts.pdfs },
        { id: "textos" as TabType, label: "Textos/MD", icon: BookOpenIcon, count: counts.textos },
        { id: "anotacoes" as TabType, label: "Minhas Anotações", icon: StickyNoteIcon, count: counts.anotacoes },
    ];

    const getPlaceholder = () => {
        switch (activeTab) {
            case "estudos": return "Buscar trilhas ou temas...";
            case "videos": return "Buscar ministrações em vídeo...";
            case "pdfs": return "Buscar apostilas e guias...";
            case "textos": return "Buscar leituras e textos...";
            case "anotacoes": return "Buscar em minhas anotações...";
        }
    };

    return (
        <div className="space-y-4">
            {/* Top Row: Segmented Tab Bar + Search Input */}
            <div className="flex flex-col gap-3 lg:flex-row lg:items-center lg:justify-between">
                {/* Horizontal Segmented Tabs */}
                <div className="flex w-full overflow-x-auto rounded-2xl border border-border/60 bg-muted/30 p-1.5 backdrop-blur-sm no-scrollbar lg:w-fit">
                    {tabs.map((tab) => {
                        const Icon = tab.icon;
                        const isActive = activeTab === tab.id;
                        return (
                            <button
                                key={tab.id}
                                onClick={() => onTabChange(tab.id)}
                                className={cn(
                                    "flex min-h-[44px] flex-1 items-center justify-center gap-2 rounded-xl px-3.5 py-2 text-xs font-semibold whitespace-nowrap transition-all cursor-pointer lg:flex-none sm:text-sm",
                                    isActive
                                        ? "bg-background text-foreground shadow-xs border border-border/50"
                                        : "text-muted-foreground hover:bg-muted/60 hover:text-foreground"
                                )}
                            >
                                <Icon className={cn("h-4 w-4", isActive ? "text-primary" : "text-muted-foreground")} />
                                <span>{tab.label}</span>
                                <span
                                    className={cn(
                                        "rounded-full px-1.5 py-0.5 text-[10px] font-bold",
                                        isActive
                                            ? "bg-primary/10 text-primary"
                                            : "bg-muted text-muted-foreground"
                                    )}
                                >
                                    {tab.count}
                                </span>
                            </button>
                        );
                    })}
                </div>

                {/* Search Bar */}
                <div className="relative w-full lg:max-w-xs group">
                    <SearchIcon className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground transition-colors group-focus-within:text-primary" />
                    <Input
                        value={searchQuery}
                        onChange={(e) => onSearchChange(e.target.value)}
                        placeholder={getPlaceholder()}
                        className="min-h-[44px] rounded-xl border-border/60 bg-card/40 pl-9 pr-9 text-xs transition-all placeholder:text-muted-foreground/70 focus-visible:border-primary/50 focus-visible:ring-2 focus-visible:ring-primary/20 sm:text-sm"
                    />
                    {searchQuery && (
                        <Button
                            variant="ghost"
                            size="icon"
                            onClick={() => onSearchChange("")}
                            className="absolute right-1.5 top-1/2 -translate-y-1/2 h-7 w-7 text-muted-foreground hover:text-foreground rounded-lg cursor-pointer"
                        >
                            <XIcon className="h-3.5 w-3.5" />
                        </Button>
                    )}
                </div>
            </div>

            {/* Category Filter Chips (Only for studies tab) */}
            {activeTab === "estudos" && onCategoryChange && (
                <div className="flex items-center gap-2 overflow-x-auto pb-1 no-scrollbar">
                    <span className="text-[11px] font-bold uppercase tracking-wider text-muted-foreground shrink-0 select-none mr-1">
                        Temas:
                    </span>
                    {CATEGORY_CHIPS.map((chip) => {
                        const isSelected = selectedCategory === chip.id;
                        return (
                            <button
                                key={chip.id}
                                onClick={() => onCategoryChange(chip.id)}
                                className={cn(
                                    "flex min-h-[36px] items-center rounded-full px-3.5 text-xs font-medium whitespace-nowrap transition-all cursor-pointer border",
                                    isSelected
                                        ? "bg-zinc-900 text-zinc-50 border-zinc-900 dark:bg-zinc-50 dark:text-zinc-900 dark:border-zinc-50 shadow-xs"
                                        : "bg-card/50 text-muted-foreground border-border/50 hover:bg-muted/60 hover:text-foreground"
                                )}
                            >
                                {chip.label}
                            </button>
                        );
                    })}
                </div>
            )}
        </div>
    );
}
