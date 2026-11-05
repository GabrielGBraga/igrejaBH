import { useState, useMemo } from "react";
import {
  BookOpen,
  Calendar,
  Copy,
  Check,
  Quote,
} from "lucide-react";
import { Card, CardHeader, CardTitle, CardContent } from "@/components/ui/card";
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
  /** @deprecated O componente é exibido sempre expandido */
  defaultExpanded?: boolean;
  /** Estilo visual: "default" ou "blended" integrado à página */
  variant?: "default" | "blended";
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
  variant = "default",
}: CatequeseDiariaProps) {
  const [isCopied, setIsCopied] = useState<boolean>(false);

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
        "w-full rounded-2xl overflow-hidden transition-all duration-300",
        variant === "blended"
          ? "border border-border/40 bg-card/30 backdrop-blur-xs shadow-none hover:bg-card/50 hover:border-border/60"
          : "border border-border/70 bg-card/70 shadow-2xs backdrop-blur-xs card-hover-elevation",
        compact ? "shadow-none" : "",
        className
      )}
    >
      {/* Top Header Row with Title */}
      <CardHeader className="p-4 sm:p-5 pb-3 sm:pb-4 border-b border-border/40">
        <div className="flex flex-wrap items-center gap-2 min-w-0">
          {/* Badge & Metadata */}
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
      </CardHeader>

      {/* Content Area: Responsive 2-Column Split on Desktop */}
      <CardContent className="p-4 sm:p-6">
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
            <blockquote className={cn("rounded-2xl border-l-4 border-primary p-5 sm:p-6 text-foreground/95 transition-colors hover:border-primary/80", variant === "blended" ? "bg-muted/15 shadow-none" : "bg-muted/30 shadow-2xs")}>
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
    </Card>
  );
}

export { CatequeseDiaria as DailyCatechismCard };
