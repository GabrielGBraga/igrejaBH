import { useState, useMemo } from "react";
import {
  BookOpen,
  Calendar,
  Copy,
  Check,
  Quote,
} from "lucide-react";
import { Card, CardHeader, CardTitle, CardDescription, CardContent } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { toast } from "sonner";
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
      toast.success("Texto bíblico copiado!", {
        description: "Pronto para compartilhar no discipulado ou grupo caseiro.",
      });

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
      className={`w-full max-w-2xl mx-auto rounded-2xl border border-border/80 bg-card/90 shadow-sm backdrop-blur-xs transition-all ${
        compact ? "shadow-none" : ""
      } ${className}`}
    >
      {/* Cabeçalho do Card */}
      <CardHeader className={compact ? "p-3 sm:p-4 pb-2 space-y-2" : "p-4 sm:p-6 pb-3 space-y-2.5"}>
        <div className="flex flex-wrap items-center justify-between gap-2">
          {/* Badge de Catequese Diária / Trilha */}
          <div className="flex flex-wrap items-center gap-2">
            <Badge
              variant="outline"
              className="gap-1.5 rounded-full border-primary/30 bg-primary/10 px-3 py-1 text-xs font-semibold text-primary"
            >
              <BookOpen className="h-3.5 w-3.5" />
              <span>Catequese Diária</span>
            </Badge>

            <span className="text-[11px] font-medium text-muted-foreground">
              {currentItem.trackTitle}
            </span>
          </div>

          {/* Indicador de Data */}
          <div className="flex items-center gap-1.5 text-xs text-muted-foreground">
            <Calendar className="h-3.5 w-3.5 text-primary" />
            <span className="font-semibold text-foreground">Hoje ({formattedToday})</span>
          </div>
        </div>

        {/* Título do Tema do Dia */}
        <div className="space-y-0.5">
          <CardTitle
            className={
              compact
                ? "text-base sm:text-lg font-bold text-foreground leading-snug"
                : "text-lg sm:text-xl font-bold text-foreground leading-snug"
            }
          >
            {currentVerse.label || currentItem.lessonTitle}
          </CardTitle>
          {currentItem.sectionTitle && currentItem.sectionTitle !== currentItem.lessonTitle && (
            <CardDescription className="text-xs sm:text-sm text-muted-foreground">
              {currentItem.sectionTitle}
            </CardDescription>
          )}
        </div>
      </CardHeader>

      {/* Conteúdo Principal: Texto Bíblico Designado do Dia */}
      <CardContent className={compact ? "p-3 sm:p-4 pt-0" : "p-4 sm:p-6 pt-0"}>
        <blockquote className="rounded-xl border-l-4 border-primary bg-muted/25 p-4 sm:p-5 text-foreground/95 shadow-2xs">
          <div className="flex items-start gap-2.5">
            <Quote className="h-4 w-4 shrink-0 text-primary/70 mt-1" />
            <p className="text-sm sm:text-base italic font-serif leading-relaxed">
              “{currentVerse.text}”
            </p>
          </div>

          <div className="mt-4 flex flex-wrap items-center justify-between gap-2 pt-3 border-t border-border/40">
            <span className="text-xs sm:text-sm font-bold text-primary">
              {currentVerse.reference}
            </span>

            <Button
              type="button"
              variant="ghost"
              size="sm"
              onClick={handleCopy}
              className="min-h-[44px] gap-1.5 rounded-lg px-3 text-xs font-semibold text-muted-foreground hover:text-primary"
              aria-label="Copiar texto bíblico do dia"
            >
              {isCopied ? (
                <>
                  <Check className="h-3.5 w-3.5 text-emerald-600 dark:text-emerald-400" />
                  <span className="text-emerald-600 dark:text-emerald-400 font-bold">Copiado!</span>
                </>
              ) : (
                <>
                  <Copy className="h-3.5 w-3.5" />
                  <span>Copiar</span>
                </>
              )}
            </Button>
          </div>
        </blockquote>
      </CardContent>
    </Card>
  );
}

export { CatequeseDiaria as DailyCatechismCard };
