import { useState, useMemo } from "react";
import {
  BookOpen,
  Calendar,
  Copy,
  Check,
  Quote,
  ChevronDown,
} from "lucide-react";
import { Card, CardHeader, CardTitle, CardDescription, CardContent } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { toast } from "sonner";
import { cn } from "@/lib/utils";
import {
  CATEQUESE_ITEMS,
  getDailyCatequeseIndex,
  type CatequeseItem,
  type CatequeseVerse,
} from "@/data/catequese";

export interface CatequeseDiariaProps {
  /** ID de uma lição específica para exibir inicialmente (opcional) */
  initialItemId?: string;
  /** Data de referência para calcular a catequese do dia (padrão: hoje) */
  initialDate?: Date;
  /** Classes CSS adicionais para o container do Card */
  className?: string;
  /** Se true, ativa o modo compacto ideal para painéis e barras laterais */
  compact?: boolean;
  /** Se inicia expandido por padrão (padrão: true) */
  defaultExpanded?: boolean;
}

interface DailyVerseEntry {
  item: CatequeseItem;
  verse: CatequeseVerse;
}

const ALL_ASSIGNED_VERSES: DailyVerseEntry[] = CATEQUESE_ITEMS.flatMap((item) =>
  item.verses.map((verse) => ({
    item,
    verse,
  }))
);

export function CatequeseDiaria({
  initialItemId,
  initialDate,
  className = "",
  compact = false,
  defaultExpanded = true,
}: CatequeseDiariaProps) {
  const [isCopied, setIsCopied] = useState<boolean>(false);
  const [isExpanded, setIsExpanded] = useState<boolean>(defaultExpanded);

  // Seleciona deterministicamente um dos textos bíblicos designados para o dia
  const dailyEntry = useMemo<DailyVerseEntry>(() => {
    if (initialItemId) {
      const found = ALL_ASSIGNED_VERSES.find((entry) => entry.item.id === initialItemId);
      if (found) return found;
    }
    const targetDate = initialDate || new Date();
    const index = getDailyCatequeseIndex(targetDate, ALL_ASSIGNED_VERSES.length);
    return ALL_ASSIGNED_VERSES[index] || ALL_ASSIGNED_VERSES[0];
  }, [initialItemId, initialDate]);

  const { item: currentItem, verse: currentVerse } = dailyEntry;

  // Data formatada em português para exibição
  const formattedToday = useMemo(() => {
    const d = initialDate || new Date();
    return d.toLocaleDateString("pt-BR", {
      day: "numeric",
      month: "long",
    });
  }, [initialDate]);

  // Copiar o texto bíblico do dia para compartilhamento
  const handleCopy = async () => {
    try {
      const themeTitle = currentVerse.label || currentItem.lessonTitle;
      const textToCopy = `📖 *Catequese Diária — Igreja em Belo Horizonte*\n*${currentItem.trackTitle} • ${themeTitle}*\n\n“${currentVerse.text}”\n— *${currentVerse.reference}*`;

      if (navigator?.clipboard?.writeText) {
        await navigator.clipboard.writeText(textToCopy);
      } else {
        const textArea = document.createElement("textarea");
        textArea.value = textToCopy;
        document.body.appendChild(textArea);
        textArea.select();
        document.execCommand("copy");
        document.body.removeChild(textArea);
      }

      setIsCopied(true);
      toast.success("Texto bíblico copiado para compartilhar com os irmãos.");

      setTimeout(() => {
        setIsCopied(false);
      }, 2500);
    } catch (err) {
      console.error("Falha ao copiar:", err);
      toast.error("Não foi possível copiar o texto automaticamente.");
    }
  };

  return (
    <Card
      className={cn(
        "w-full rounded-2xl border border-border/70 bg-card/70 shadow-2xs backdrop-blur-xs transition-all duration-300 card-hover-elevation overflow-hidden",
        compact ? "shadow-none" : "",
        className
      )}
    >
      {/* Top Header Row with Title & Collapse/Expand Toggle */}
      <CardHeader className="p-4 sm:p-5 pb-3 sm:pb-4 border-b border-border/40">
        <div className="flex items-center justify-between gap-3">
          {/* Badge & Metadata */}
          <div className="flex flex-wrap items-center gap-2 min-w-0">
            <Badge
              variant="outline"
              className="gap-1.5 rounded-full border-primary/30 bg-primary/10 px-3 py-1 text-xs font-semibold text-primary shrink-0"
            >
              <BookOpen className="h-3.5 w-3.5" />
              <span>Catequese Diária</span>
            </Badge>

            <span className="hidden sm:inline-block text-xs font-medium text-muted-foreground truncate">
              {currentItem.trackTitle}
            </span>

            <span className="hidden sm:inline-block text-muted-foreground/60">&middot;</span>

            <div className="flex items-center gap-1.5 text-xs text-muted-foreground shrink-0">
              <Calendar className="h-3.5 w-3.5 text-primary" />
              <span className="font-semibold text-foreground">Hoje ({formattedToday})</span>
            </div>
          </div>

          {/* Expand/Collapse Toggle Button */}
          <Button
            type="button"
            variant="ghost"
            size="sm"
            onClick={() => setIsExpanded((prev) => !prev)}
            className="btn-tactile min-h-[44px] gap-1.5 px-3 rounded-xl text-xs font-semibold text-muted-foreground hover:text-foreground hover:bg-muted/50 cursor-pointer shrink-0"
            aria-label={isExpanded ? "Recolher leitura da catequese" : "Expandir leitura da catequese"}
          >
            <span className="hidden xs:inline">
              {isExpanded ? "Recolher" : "Ver Versículo do Dia"}
            </span>
            <ChevronDown
              className={cn(
                "h-4 w-4 transition-transform duration-300 ease-out",
                isExpanded && "rotate-180"
              )}
            />
          </Button>
        </div>

        {/* Collapsed Preview Line */}
        {!isExpanded && (
          <div className="pt-2 flex flex-wrap items-center justify-between gap-2 animate-in fade-in duration-300">
            <div className="flex items-center gap-2 truncate">
              <span className="text-sm font-bold text-foreground truncate">
                {currentVerse.label || currentItem.lessonTitle}
              </span>
              <span className="text-xs font-semibold text-primary shrink-0">
                ({currentVerse.reference})
              </span>
            </div>
            <button
              type="button"
              onClick={() => setIsExpanded(true)}
              className="text-xs font-semibold text-primary hover:underline cursor-pointer"
            >
              Expandir Leitura &rarr;
            </button>
          </div>
        )}
      </CardHeader>

      {/* Expanded Content Area: Responsive 2-Column Split on Desktop */}
      {isExpanded && (
        <CardContent className="p-4 sm:p-6 animate-in fade-in slide-in-from-top-2 duration-300 ease-out">
          <div className="grid grid-cols-1 lg:grid-cols-12 gap-6 lg:items-center">
            {/* Left Column: Context, Lesson Title and Action */}
            <div className="lg:col-span-5 space-y-3">
              <div className="space-y-1">
                <span className="text-xs font-semibold text-muted-foreground block">
                  {currentItem.sectionTitle || currentItem.trackTitle}
                </span>
                <CardTitle className="text-lg sm:text-xl font-bold text-foreground leading-snug">
                  {currentVerse.label || currentItem.lessonTitle}
                </CardTitle>
                <CardDescription className="text-xs sm:text-sm text-muted-foreground leading-relaxed pt-1">
                  Fundamento apostólico para meditação diária no discipulado e compartilhamento nas casas.
                </CardDescription>
              </div>

              <div className="pt-1">
                <Button
                  type="button"
                  variant="outline"
                  size="sm"
                  onClick={handleCopy}
                  className="btn-tactile min-h-[44px] gap-2 rounded-xl px-4 text-xs font-semibold border-border/70 hover:border-primary/40 hover:bg-primary/5 hover:text-primary cursor-pointer transition-all"
                  aria-label="Copiar texto bíblico do dia"
                >
                  {isCopied ? (
                    <>
                      <Check className="h-4 w-4 text-primary animate-in zoom-in-75 duration-200" />
                      <span className="text-primary font-bold">Versículo Copiado!</span>
                    </>
                  ) : (
                    <>
                      <Copy className="h-4 w-4 text-muted-foreground" />
                      <span>Copiar para Compartilhar</span>
                    </>
                  )}
                </Button>
              </div>
            </div>

            {/* Right Column: Prominent Editorial Scripture Quote */}
            <div className="lg:col-span-7">
              <blockquote className="rounded-2xl border-l-4 border-primary bg-muted/30 p-5 sm:p-6 text-foreground/95 shadow-2xs transition-colors hover:border-primary/80">
                <div className="flex items-start gap-3">
                  <Quote className="h-5 w-5 shrink-0 text-primary/70 mt-0.5" />
                  <p className="text-sm sm:text-base italic font-serif leading-relaxed text-foreground/90">
                    “{currentVerse.text}”
                  </p>
                </div>

                <div className="mt-4 flex items-center justify-between pt-3 border-t border-border/40 text-xs sm:text-sm">
                  <span className="font-bold text-primary">
                    {currentVerse.reference}
                  </span>
                  <span className="text-[11px] text-muted-foreground font-medium">
                    {currentItem.trackTitle}
                  </span>
                </div>
              </blockquote>
            </div>
          </div>
        </CardContent>
      )}
    </Card>
  );
}

export { CatequeseDiaria as DailyCatechismCard };
