import { useState, useMemo } from "react";
import {
  BookOpen,
  Shuffle,
  Calendar,
  RotateCcw,
  Copy,
  Check,
  ExternalLink,
  Eye,
  EyeOff,
  Quote,
  Sparkles,
  ChevronDown,
  ChevronUp,
} from "lucide-react";
import { Card, CardHeader, CardTitle, CardDescription, CardContent, CardFooter } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { toast } from "sonner";
import {
  getDailyCatequeseItem,
  getRandomCatequeseItem,
  getCatequeseItemById,
  type CatequeseItem,
} from "@/data/catequese";

export interface CatequeseDiariaProps {
  /** ID de uma lição específica para exibir inicialmente (opcional) */
  initialItemId?: string;
  /** Data de referência para calcular a lição do dia (padrão: hoje) */
  initialDate?: Date;
  /** Classes CSS adicionais para o container do Card */
  className?: string;
  /** Se true, ativa o modo compacto ideal para painéis e barras laterais */
  compact?: boolean;
  /** Callback disparado quando uma lição é selecionada ou sorteada */
  onSelectLesson?: (item: CatequeseItem) => void;
}

export function CatequeseDiaria({
  initialItemId,
  initialDate,
  className = "",
  compact = false,
  onSelectLesson,
}: CatequeseDiariaProps) {
  // Lição diária de hoje
  const todayItem = useMemo(() => {
    return getDailyCatequeseItem(initialDate || new Date());
  }, [initialDate]);

  // Lição ativa no momento
  const [currentItem, setCurrentItem] = useState<CatequeseItem>(() => {
    if (initialItemId) {
      const found = getCatequeseItemById(initialItemId);
      if (found) return found;
    }
    return todayItem;
  });

  // Estado de memorização (ocultar respostas)
  const [memorizeMode, setMemorizeMode] = useState<boolean>(false);
  const [revealedIndexMap, setRevealedIndexMap] = useState<Record<number, boolean>>({});

  // Estado de cópia para feedback visual
  const [isCopied, setIsCopied] = useState<boolean>(false);

  // Expansão de versículos bíblicos quando há muitos
  const [showAllVerses, setShowAllVerses] = useState<boolean>(false);

  const isToday = currentItem.id === todayItem.id;

  // Data formatada em português para exibição
  const formattedToday = useMemo(() => {
    const d = initialDate || new Date();
    return d.toLocaleDateString("pt-BR", {
      day: "numeric",
      month: "long",
    });
  }, [initialDate]);

  // Ação: Sortear outra lição aleatória
  const handleShuffle = () => {
    const nextItem = getRandomCatequeseItem(currentItem.id);
    setCurrentItem(nextItem);
    setRevealedIndexMap({});
    setShowAllVerses(false);
    onSelectLesson?.(nextItem);
    toast.info("Nova lição sorteada!", {
      description: `${nextItem.trackTitle} • Lição ${nextItem.lessonNumber}`,
    });
  };

  // Ação: Voltar para a lição de hoje
  const handleResetToToday = () => {
    setCurrentItem(todayItem);
    setRevealedIndexMap({});
    setShowAllVerses(false);
    onSelectLesson?.(todayItem);
    toast.success("Retornou à Catequese de Hoje");
  };

  // Alternar modo de memorização
  const toggleMemorizeMode = () => {
    setMemorizeMode((prev) => !prev);
    setRevealedIndexMap({});
  };

  // Revelar resposta individual no modo de memorização
  const handleRevealAnswer = (index: number) => {
    setRevealedIndexMap((prev) => ({
      ...prev,
      [index]: !prev[index],
    }));
  };

  // Copiar conteúdo da lição para compartilhamento (WhatsApp / discipulado)
  const handleCopy = async () => {
    try {
      const qaFormatted = currentItem.qaList
        .map((qa) => {
          const q = qa.question ? `*P:* ${qa.question}\n` : "";
          const a = `*R:* ${qa.answer}`;
          return `${q}${a}`;
        })
        .join("\n\n");

      const versesFormatted = currentItem.verses
        .map((v) => `"${v.text}" (${v.reference})`)
        .join("\n\n");

      const textToCopy = `📖 *Catequese Diária — Igreja em Belo Horizonte*\n*${currentItem.trackTitle}*\n*Lição ${currentItem.lessonNumber}: ${currentItem.lessonTitle}*\n\n${qaFormatted}${
        versesFormatted ? `\n\n📜 *Fundamento Bíblico:*\n${versesFormatted}` : ""
      }\n\n_Para o aperfeiçoamento dos santos e edificação do corpo de Cristo._`;

      if (navigator?.clipboard?.writeText) {
        await navigator.clipboard.writeText(textToCopy);
      } else {
        // Fallback para navegadores sem suporte direto
        const textArea = document.createElement("textarea");
        textArea.value = textToCopy;
        document.body.appendChild(textArea);
        textArea.select();
        document.execCommand("copy");
        document.body.removeChild(textArea);
      }

      setIsCopied(true);
      toast.success("Lição copiada para a área de transferência!", {
        description: "Pronta para compartilhar no discipulado ou grupo caseiro.",
      });

      setTimeout(() => {
        setIsCopied(false);
      }, 2500);
    } catch (err) {
      console.error("Falha ao copiar:", err);
      toast.error("Não foi possível copiar o texto automaticamente.");
    }
  };

  // Versículos a exibir (se forem mais de 2, limitar inicialmente para economia de espaço em telas pequenas)
  const versesToDisplay =
    showAllVerses || currentItem.verses.length <= 2
      ? currentItem.verses
      : currentItem.verses.slice(0, 2);

  return (
    <Card
      className={`w-full max-w-2xl mx-auto rounded-2xl border border-border/80 bg-card/90 shadow-sm backdrop-blur-xs transition-all ${
        compact ? "shadow-none" : ""
      } ${className}`}
    >
      {/* Cabeçalho do Card */}
      <CardHeader className={compact ? "p-3 sm:p-4 pb-2 space-y-2" : "p-4 sm:p-6 pb-3 sm:pb-4 space-y-3"}>
        <div className="flex flex-wrap items-center justify-between gap-2">
          {/* Badge de Trilha / Módulo */}
          <div className="flex flex-wrap items-center gap-2">
            <Badge
              variant="outline"
              className="gap-1.5 rounded-full border-primary/30 bg-primary/10 px-3 py-1 text-xs font-semibold text-primary transition-colors"
            >
              <BookOpen className="h-3.5 w-3.5" />
              <span>{currentItem.trackTitle}</span>
            </Badge>

            <span className="text-[11px] font-medium text-muted-foreground">
              Lição {currentItem.lessonNumber}
            </span>
          </div>

          {/* Indicador de Data / Status Diário */}
          <div className="flex items-center gap-1.5 text-xs text-muted-foreground">
            <Calendar className="h-3.5 w-3.5 text-primary" />
            {isToday ? (
              <span className="font-semibold text-foreground">Hoje ({formattedToday})</span>
            ) : (
              <Badge
                variant="secondary"
                className="gap-1 rounded-full px-2 py-0.5 text-[10px] font-medium bg-amber-500/10 text-amber-700 dark:text-amber-300 border border-amber-500/20"
              >
                <Sparkles className="h-2.5 w-2.5" />
                Sorteio Aleatório
              </Badge>
            )}
          </div>
        </div>

        {/* Título Principal */}
        <div className="space-y-1">
          <CardTitle
            className={
              compact
                ? "text-base sm:text-lg font-bold text-foreground leading-snug"
                : "text-lg sm:text-xl font-bold text-foreground leading-snug"
            }
          >
            {currentItem.lessonTitle}
          </CardTitle>
          <CardDescription className="text-xs sm:text-sm text-muted-foreground">
            {currentItem.sectionTitle}
          </CardDescription>
        </div>
      </CardHeader>

      {/* Conteúdo Principal (Perguntas e Respostas) */}
      <CardContent className={compact ? "p-3 sm:p-4 pt-0 space-y-3" : "p-4 sm:p-6 pt-0 sm:pt-0 space-y-5"}>
        <div className="space-y-4">
          {currentItem.qaList.map((qa, index) => {
            const isRevealed = !memorizeMode || Boolean(revealedIndexMap[index]);

            return (
              <div
                key={index}
                className="rounded-xl border border-border/70 bg-muted/30 p-3.5 sm:p-4.5 space-y-2.5 transition-colors"
              >
                {/* Pergunta */}
                {qa.question && (
                  <div className="flex items-start gap-2">
                    <span className="mt-0.5 inline-flex shrink-0 items-center justify-center rounded-md bg-primary/15 px-1.5 py-0.5 text-[10px] font-bold text-primary">
                      P
                    </span>
                    <h3 className="text-sm sm:text-base font-semibold text-foreground leading-snug">
                      {qa.question}
                    </h3>
                  </div>
                )}

                {/* Resposta */}
                <div className="flex items-start gap-2 pt-1 border-t border-border/40">
                  <span className="mt-0.5 inline-flex shrink-0 items-center justify-center rounded-md bg-secondary text-secondary-foreground px-1.5 py-0.5 text-[10px] font-bold">
                    R
                  </span>

                  <div className="flex-1">
                    {isRevealed ? (
                      <p className="text-sm sm:text-base text-foreground/90 font-medium leading-relaxed">
                        {qa.answer}
                      </p>
                    ) : (
                      <button
                        type="button"
                        onClick={() => handleRevealAnswer(index)}
                        className="group flex min-h-[44px] w-full items-center justify-between rounded-lg border border-dashed border-primary/40 bg-card/60 px-3 py-2 text-xs text-muted-foreground hover:border-primary hover:text-primary transition-colors"
                        aria-label="Revelar resposta para esta pergunta"
                      >
                        <span className="font-medium flex items-center gap-1.5">
                          <Eye className="h-3.5 w-3.5 text-primary" />
                          Toque para revelar a resposta
                        </span>
                        <span className="text-[10px] uppercase font-semibold text-primary group-hover:underline">
                          Revelar
                        </span>
                      </button>
                    )}
                  </div>
                </div>
              </div>
            );
          })}
        </div>

        {/* Seção de Fundamento Bíblico (Versículos) */}
        {currentItem.verses.length > 0 && (
          <div className="space-y-3 pt-2">
            <div className="flex items-center justify-between border-b border-border/60 pb-1.5">
              <span className="flex items-center gap-1.5 text-xs font-semibold text-primary tracking-wide uppercase">
                <Quote className="h-3.5 w-3.5" />
                Fundamento Bíblico
              </span>
              <span className="text-[11px] text-muted-foreground font-mono">
                {currentItem.verses.length}{" "}
                {currentItem.verses.length === 1 ? "versículo" : "versículos"}
              </span>
            </div>

            <div className="space-y-3">
              {versesToDisplay.map((v, vIdx) => (
                <blockquote
                  key={vIdx}
                  className="rounded-xl border-l-4 border-primary bg-muted/20 p-3.5 sm:p-4 text-xs sm:text-sm text-foreground/90 leading-relaxed shadow-2xs"
                >
                  {v.label && (
                    <div className="text-[11px] font-bold text-primary mb-1 uppercase tracking-wider">
                      {v.label}
                    </div>
                  )}

                  <p className="italic">“{v.text}”</p>

                  <div className="mt-2.5 flex items-center justify-between pt-2 border-t border-border/30 text-xs">
                    <span className="font-semibold text-primary">{v.reference}</span>

                    {v.url && (
                      <a
                        href={v.url}
                        target="_blank"
                        rel="noopener noreferrer"
                        className="inline-flex min-h-[44px] min-w-[44px] items-center gap-1 text-[11px] font-medium text-muted-foreground hover:text-primary hover:underline transition-colors px-2 py-1"
                        aria-label={`Abrir ${v.reference} na Bíblia Online (abre em nova aba)`}
                      >
                        <span>Abrir na Bíblia</span>
                        <ExternalLink className="h-3 w-3" />
                      </a>
                    )}
                  </div>
                </blockquote>
              ))}

              {/* Botão para expandir quando há mais de 2 versículos */}
              {currentItem.verses.length > 2 && (
                <Button
                  type="button"
                  variant="ghost"
                  size="sm"
                  onClick={() => setShowAllVerses((prev) => !prev)}
                  className="w-full min-h-[44px] justify-center gap-1.5 text-xs text-muted-foreground hover:text-primary"
                >
                  {showAllVerses ? (
                    <>
                      <ChevronUp className="h-4 w-4" />
                      Mostrar menos versículos
                    </>
                  ) : (
                    <>
                      <ChevronDown className="h-4 w-4" />
                      Ver todos os {currentItem.verses.length} versículos
                    </>
                  )}
                </Button>
              )}
            </div>
          </div>
        )}
      </CardContent>

      {/* Rodapé e Ações Interativas */}
      <CardFooter className="p-4 sm:p-6 pt-2 sm:pt-2 border-t border-border/60 flex flex-wrap items-center justify-between gap-2.5">
        <div className="flex flex-wrap items-center gap-2">
          {/* Botão de Sortear Lição Aleatória */}
          <Button
            type="button"
            variant="outline"
            size="sm"
            onClick={handleShuffle}
            className="min-h-[44px] gap-2 rounded-xl border-border px-3.5 text-xs font-semibold hover:border-primary/40 hover:text-primary"
            aria-label="Sortear outra pergunta de catequese"
          >
            <Shuffle className="h-4 w-4 text-primary" />
            <span>Sortear Outra</span>
          </Button>

          {/* Botão de Voltar para a Lição de Hoje (se estiver visualizando outra) */}
          {!isToday && (
            <Button
              type="button"
              variant="ghost"
              size="sm"
              onClick={handleResetToToday}
              className="min-h-[44px] gap-1.5 rounded-xl px-3 text-xs text-muted-foreground hover:text-foreground"
              aria-label="Voltar para a lição de hoje"
            >
              <RotateCcw className="h-3.5 w-3.5" />
              <span>Ver de Hoje</span>
            </Button>
          )}

          {/* Botão de Modo de Memorização (Ocultar/Revelar) */}
          <Button
            type="button"
            variant={memorizeMode ? "secondary" : "ghost"}
            size="sm"
            onClick={toggleMemorizeMode}
            className="min-h-[44px] gap-1.5 rounded-xl px-3 text-xs font-medium text-muted-foreground hover:text-foreground"
            aria-label={memorizeMode ? "Desativar modo memorização" : "Ativar modo memorização"}
            title="Oculta as respostas para treinar a memorização pessoal ou no discipulado"
          >
            {memorizeMode ? (
              <>
                <EyeOff className="h-3.5 w-3.5 text-primary" />
                <span>Modo Estudo</span>
              </>
            ) : (
              <>
                <Eye className="h-3.5 w-3.5" />
                <span>Memorizar</span>
              </>
            )}
          </Button>
        </div>

        {/* Botão de Copiar / Compartilhar */}
        <Button
          type="button"
          variant="outline"
          size="sm"
          onClick={handleCopy}
          className="min-h-[44px] gap-1.5 rounded-xl border-border px-3.5 text-xs font-semibold hover:border-primary/40 hover:text-primary"
          aria-label="Copiar lição para compartilhar"
          title="Copiar lição formatada para envio no WhatsApp ou anotações"
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
      </CardFooter>
    </Card>
  );
}

export { CatequeseDiaria as DailyCatechismCard };
