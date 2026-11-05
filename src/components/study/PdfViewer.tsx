import { useState, useRef, useEffect, useMemo } from "react";
import { 
    FileTextIcon, 
    ExternalLinkIcon, 
    DownloadIcon, 
    Maximize2Icon, 
    Minimize2Icon, 
    RefreshCwIcon,
    AlertCircleIcon,
    ZoomInIcon,
    LayoutTemplateIcon
} from "lucide-react";
import { Button } from "@/components/ui/button";
import { Spinner } from "@/components/ui/spinner";
import { cn } from "@/lib/utils";

export interface PdfViewerProps {
    url: string;
    title?: string;
    className?: string;
    minHeight?: string;
    hideToolbar?: boolean;
}

export function PdfViewer({
    url,
    title = "Documento PDF",
    className,
    minHeight = "min-h-[500px] h-full",
    hideToolbar = false,
}: PdfViewerProps) {
    const [viewMode, setViewMode] = useState<"FitH" | "Fit">("FitH");
    const [isLoading, setIsLoading] = useState(true);
    const [hasError, setHasError] = useState(false);
    const [isFullscreen, setIsFullscreen] = useState(false);
    const [reloadKey, setReloadKey] = useState(0);
    const containerRef = useRef<HTMLDivElement>(null);

    // Build the viewer URL with standard parameters for native browser PDF readers
    // FitH = fits the page to the width of the viewer for comfortable reading
    // Fit = fits the entire page in the viewport
    const viewerUrl = useMemo(() => {
        if (!url) return "";
        const cleanUrl = url.split("#")[0];
        return `${cleanUrl}#toolbar=1&navpanes=0&view=${viewMode}&pagemode=none`;
    }, [url, viewMode]);

    // Timeout fallback for loading state (browsers don't always trigger iframe onLoad reliably for PDF plugins)
    useEffect(() => {
        setIsLoading(true);
        setHasError(false);
        const timer = setTimeout(() => {
            setIsLoading(false);
        }, 1200);

        return () => clearTimeout(timer);
    }, [url, viewMode, reloadKey]);

    const handleToggleFullscreen = () => {
        if (!containerRef.current) return;

        if (!isFullscreen) {
            if (containerRef.current.requestFullscreen) {
                containerRef.current.requestFullscreen().catch(() => {
                    setIsFullscreen(true);
                });
            } else {
                setIsFullscreen(true);
            }
        } else {
            if (document.fullscreenElement && document.exitFullscreen) {
                document.exitFullscreen().catch(() => {
                    setIsFullscreen(false);
                });
            } else {
                setIsFullscreen(false);
            }
        }
    };

    useEffect(() => {
        const handleFullscreenChange = () => {
            setIsFullscreen(Boolean(document.fullscreenElement));
        };

        document.addEventListener("fullscreenchange", handleFullscreenChange);
        return () => {
            document.removeEventListener("fullscreenchange", handleFullscreenChange);
        };
    }, []);

    const handleReload = () => {
        setIsLoading(true);
        setHasError(false);
        setReloadKey((k) => k + 1);
    };

    const toggleViewMode = () => {
        setViewMode((prev) => (prev === "FitH" ? "Fit" : "FitH"));
    };

    return (
        <div
            ref={containerRef}
            className={cn(
                "flex flex-col bg-card border border-border/60 rounded-2xl overflow-hidden shadow-xs transition-all duration-300 w-full h-full",
                isFullscreen ? "fixed inset-0 z-50 rounded-none border-0 h-screen w-screen bg-background" : className
            )}
        >
            {/* Top Toolbar (Rendered only when not embedded in a modal that has its own unified header) */}
            {!hideToolbar && (
                <div className="flex flex-wrap items-center justify-between gap-2.5 p-3 sm:px-4 sm:py-3 border-b border-border/60 bg-muted/25 shrink-0">
                    <div className="flex items-center gap-2.5 min-w-0 flex-1">
                        <div className="w-8 h-8 rounded-lg bg-primary/10 text-primary border border-primary/20 flex items-center justify-center shrink-0">
                            <FileTextIcon className="h-4 w-4" />
                        </div>
                        <div className="min-w-0 flex-1">
                            <p className="text-xs sm:text-sm font-bold text-foreground truncate leading-tight" title={title}>
                                {title}
                            </p>
                            <p className="text-[10px] sm:text-[11px] text-muted-foreground truncate">
                                Apostila Digital • {viewMode === "FitH" ? "Ajustado à Largura" : "Página Inteira"}
                            </p>
                        </div>
                    </div>

                    {/* Actions Bar - Minimum 44x44px touch targets */}
                    <div className="flex items-center gap-1.5 sm:gap-2 shrink-0">
                        <Button
                            type="button"
                            variant="ghost"
                            size="sm"
                            onClick={toggleViewMode}
                            className="min-h-[44px] px-3 rounded-xl text-muted-foreground hover:text-foreground cursor-pointer text-xs font-semibold gap-1.5"
                            title={viewMode === "FitH" ? "Ver Página Inteira" : "Ajustar à Largura"}
                        >
                            {viewMode === "FitH" ? (
                                <>
                                    <LayoutTemplateIcon className="h-4 w-4" />
                                    <span className="hidden md:inline">Página Inteira</span>
                                </>
                            ) : (
                                <>
                                    <ZoomInIcon className="h-4 w-4" />
                                    <span className="hidden md:inline">Ajustar Largura</span>
                                </>
                            )}
                        </Button>

                        <Button
                            type="button"
                            variant="ghost"
                            size="sm"
                            onClick={handleReload}
                            className="min-h-[44px] min-w-[44px] px-2.5 rounded-xl text-muted-foreground hover:text-foreground cursor-pointer"
                            title="Recarregar Leitor"
                        >
                            <RefreshCwIcon className="h-4 w-4" />
                            <span className="sr-only">Recarregar</span>
                        </Button>

                        <Button
                            type="button"
                            variant="ghost"
                            size="sm"
                            onClick={handleToggleFullscreen}
                            className="min-h-[44px] min-w-[44px] px-2.5 rounded-xl text-muted-foreground hover:text-foreground cursor-pointer"
                            title={isFullscreen ? "Sair da Tela Cheia" : "Tela Cheia"}
                        >
                            {isFullscreen ? (
                                <Minimize2Icon className="h-4 w-4" />
                            ) : (
                                <Maximize2Icon className="h-4 w-4" />
                            )}
                            <span className="sr-only">Tela Cheia</span>
                        </Button>

                        <a
                            href={url}
                            target="_blank"
                            rel="noopener noreferrer"
                            className="inline-flex"
                            title="Abrir PDF em outra página (sem baixar)"
                        >
                            <Button
                                type="button"
                                variant="outline"
                                size="sm"
                                className="min-h-[44px] px-3 rounded-xl border-border/70 text-xs font-semibold gap-1.5 cursor-pointer hover:bg-primary/5 hover:text-primary"
                            >
                                <ExternalLinkIcon className="h-3.5 w-3.5" />
                                <span className="hidden sm:inline">Abrir em Outra Página</span>
                            </Button>
                        </a>

                        <a
                            href={url}
                            download
                            className="inline-flex"
                            title="Baixar Arquivo PDF"
                        >
                            <Button
                                type="button"
                                variant="default"
                                size="sm"
                                className="min-h-[44px] px-3.5 rounded-xl text-xs font-semibold gap-1.5 cursor-pointer shadow-2xs"
                            >
                                <DownloadIcon className="h-3.5 w-3.5" />
                                <span>Baixar</span>
                            </Button>
                        </a>
                    </div>
                </div>
            )}

            {/* Viewer Workspace - Full-bleed container that fills 100% of available space */}
            <div className={cn(
                "relative flex-1 w-full h-full min-h-0 bg-zinc-100 dark:bg-zinc-950 overflow-hidden",
                isFullscreen ? "h-[calc(100vh-65px)]" : minHeight
            )}>
                {/* Loading State Overlay */}
                {isLoading && (
                    <div className="absolute inset-0 bg-background/80 backdrop-blur-xs flex flex-col items-center justify-center z-10 p-4 text-center">
                        <Spinner className="h-7 w-7 text-primary mb-3" />
                        <p className="text-xs sm:text-sm font-semibold text-foreground">
                            Carregando apostila...
                        </p>
                        <p className="text-[11px] text-muted-foreground mt-1 max-w-xs">
                            Preparando o material de estudo para leitura fluida.
                        </p>
                    </div>
                )}

                {/* Error Fallback */}
                {hasError ? (
                    <div className="p-6 text-center max-w-md mx-auto space-y-3 flex flex-col items-center justify-center h-full">
                        <div className="w-12 h-12 rounded-2xl bg-destructive/10 text-destructive border border-destructive/20 mx-auto flex items-center justify-center">
                            <AlertCircleIcon className="h-6 w-6" />
                        </div>
                        <h4 className="text-sm sm:text-base font-bold text-foreground">
                            Não foi possível embutir o leitor neste navegador
                        </h4>
                        <p className="text-xs text-muted-foreground leading-relaxed">
                            O documento pode ter restrições ou seu dispositivo não suporta incorporar PDFs. Você pode abrir o documento em outra página diretamente ou fazer o download.
                        </p>
                        <div className="flex flex-col sm:flex-row items-center justify-center gap-2 pt-2">
                            <a href={url} target="_blank" rel="noopener noreferrer" className="w-full sm:w-auto">
                                <Button className="w-full sm:w-auto min-h-[44px] rounded-xl text-xs font-semibold gap-2 cursor-pointer">
                                    <ExternalLinkIcon className="h-4 w-4" />
                                    Abrir em Outra Página
                                </Button>
                            </a>
                            <a href={url} download className="w-full sm:w-auto">
                                <Button variant="outline" className="w-full sm:w-auto min-h-[44px] rounded-xl text-xs font-semibold gap-2 cursor-pointer">
                                    <DownloadIcon className="h-4 w-4" />
                                    Baixar PDF
                                </Button>
                            </a>
                        </div>
                    </div>
                ) : (
                    <iframe
                        key={`${viewMode}-${reloadKey}`}
                        src={viewerUrl}
                        title={title}
                        className="w-full h-full border-0 block bg-zinc-100 dark:bg-zinc-950"
                        onLoad={() => setIsLoading(false)}
                        onError={() => {
                            setIsLoading(false);
                            setHasError(true);
                        }}
                    />
                )}
            </div>

            {/* Mobile / Desktop Helpful Footer Notice (Only rendered when hideToolbar is false) */}
            {!hideToolbar && (
                <div className="p-2 sm:p-2.5 px-3 sm:px-4 bg-muted/30 border-t border-border/50 flex flex-wrap items-center justify-between gap-2 text-[11px] text-muted-foreground shrink-0">
                    <span className="truncate">
                        Dica: Use a barra nativa para busca e navegação de páginas ou abra em outra página para tela cheia.
                    </span>
                    <div className="flex items-center gap-2 shrink-0">
                        <a
                            href={url}
                            target="_blank"
                            rel="noopener noreferrer"
                            className="text-[10px] text-primary hover:underline font-medium inline-flex items-center gap-1 cursor-pointer"
                        >
                            <ExternalLinkIcon className="h-3 w-3" />
                            <span>Abrir em Outra Página</span>
                        </a>
                        <span className="hidden sm:inline font-mono text-[10px] opacity-75">
                            PDF 100% Nativo
                        </span>
                    </div>
                </div>
            )}
        </div>
    );
}
