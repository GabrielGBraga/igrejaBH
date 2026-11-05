import React, { useState, useEffect, useRef, useCallback } from "react";
import { 
    Bold, 
    Italic, 
    Underline, 
    Quote, 
    List, 
    ListOrdered, 
    Link as LinkIcon, 
    Eraser, 
    Undo, 
    Redo,
    Loader2, 
    Save, 
    Trash2, 
    AlignLeft, 
    AlignCenter, 
    AlignJustify, 
    X, 
    StickyNote,
    Code2,
    Code,
    Pencil
} from "lucide-react";
import { 
    Dialog, 
    DialogContent, 
    DialogHeader, 
    DialogTitle, 
    DialogDescription 
} from "@/components/ui/dialog";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Field, FieldLabel } from "@/components/ui/field";
import { toast } from "sonner";
import { cn } from "@/lib/utils";
import { 
    markdownToHtml, 
    htmlToMarkdown, 
    isHtmlContent, 
    sanitizeHtmlContent, 
    formatHtmlForEditor 
} from "@/lib/markdownUtils";

export interface TextEditorProps {
    isOpen: boolean;
    onClose: () => void;
    onSave: (data: { title: string; description: string; markdownContent: string }) => Promise<void>;
    onDelete?: () => Promise<void>;
    initialData?: {
        id?: string;
        title: string;
        description?: string;
        url?: string;
        content?: string;
    } | null;
    mode?: "resource" | "note";
    modalTitle?: string;
    modalDescription?: string;
    hideDescription?: boolean;
    titleLabel?: string;
    titlePlaceholder?: string;
    saveButtonText?: string;
    inline?: boolean;
    className?: string;
}

export function TextEditor({ 
    isOpen, 
    onClose, 
    onSave, 
    onDelete,
    initialData,
    mode = "resource",
    modalTitle,
    modalDescription,
    hideDescription = mode === "note",
    titleLabel = mode === "note" ? "Título da Anotação*" : "Título do Texto*",
    titlePlaceholder = mode === "note" ? "Ex: Anotações da Mensagem" : "Ex: Guia de Oração Semanal",
    saveButtonText = mode === "note" ? "Salvar Anotações" : "Salvar Texto",
    inline = false,
    className,
}: TextEditorProps) {
    const [title, setTitle] = useState("");
    const [description, setDescription] = useState("");
    const [loadingContent, setLoadingContent] = useState(false);
    const [saving, setSaving] = useState(false);
    const [deleting, setDeleting] = useState(false);
    
    // Editor Modes: "visual" (WYSIWYG) vs "html" (Raw HTML Source Code)
    const [editorMode, setEditorMode] = useState<"visual" | "html">("visual");
    const [htmlSource, setHtmlSource] = useState<string>("");

    const editorRef = useRef<HTMLDivElement | null>(null);
    const [editorElement, setEditorElement] = useState<HTMLDivElement | null>(null);
    const loadedContentKeyRef = useRef<string | null>(null);

    const dataIdentity = initialData
        ? `${initialData.id || "new"}::${initialData.title || ""}::${initialData.url || ""}::${initialData.content ?? ""}`
        : "empty";

    // Callback ref to capture DOM element mounting inside Radix Dialog portals or inline
    const setEditorRef = useCallback((node: HTMLDivElement | null) => {
        editorRef.current = node;
        setEditorElement(node);
        if (node && initialData?.content !== undefined && loadedContentKeyRef.current !== dataIdentity) {
            const html = markdownToHtml(initialData.content || "");
            node.innerHTML = html || "<p><br></p>";
            setHtmlSource(formatHtmlForEditor(html));
            loadedContentKeyRef.current = dataIdentity;
        }
    }, [initialData?.content, dataIdentity]);

    // Reset fields or fetch content on open/change of initialData
    useEffect(() => {
        if (!isOpen) {
            loadedContentKeyRef.current = null;
            setEditorMode("visual");
            return;
        }

        // When opening or switching to a new dataIdentity, sync title and description
        if (loadedContentKeyRef.current !== dataIdentity) {
            setTitle(initialData?.title || "");
            setDescription(initialData?.description || "");
            setEditorMode("visual");
        }

        if (!editorElement) {
            return;
        }

        if (loadedContentKeyRef.current === dataIdentity) {
            return;
        }

        if (initialData) {
            if (initialData.content !== undefined) {
                // Direct markdown or html content provided
                const html = markdownToHtml(initialData.content || "");
                editorElement.innerHTML = html || "<p><br></p>";
                setHtmlSource(formatHtmlForEditor(html));
                loadedContentKeyRef.current = dataIdentity;
            } else if (initialData.url) {
                setLoadingContent(true);
                fetch(initialData.url)
                    .then(res => {
                        if (!res.ok) throw new Error("Failed to load text content");
                        return res.text();
                    })
                    .then(rawText => {
                        const html = markdownToHtml(rawText);
                        if (editorRef.current) {
                            editorRef.current.innerHTML = html;
                        }
                        setHtmlSource(formatHtmlForEditor(html));
                        loadedContentKeyRef.current = dataIdentity;
                    })
                    .catch(err => {
                        console.error("Error loading text resource:", err);
                        toast.error("Não foi possível carregar o conteúdo do texto.");
                        if (editorRef.current) {
                            editorRef.current.innerHTML = "<p><br></p>";
                        }
                        setHtmlSource("<p><br></p>");
                    })
                    .finally(() => {
                        setLoadingContent(false);
                    });
            } else {
                editorElement.innerHTML = "<p><br></p>";
                setHtmlSource("<p><br></p>");
                loadedContentKeyRef.current = dataIdentity;
            }
        } else {
            editorElement.innerHTML = "<p><br></p>";
            setHtmlSource("<p><br></p>");
            loadedContentKeyRef.current = dataIdentity;
        }
    }, [isOpen, editorElement, dataIdentity, initialData]);

    // Mode Switch Handlers
    const handleSwitchToHtml = () => {
        const currentHtml = editorRef.current?.innerHTML || "";
        const formatted = formatHtmlForEditor(currentHtml);
        setHtmlSource(formatted);
        setEditorMode("html");
    };

    const handleSwitchToVisual = () => {
        const cleanHtml = sanitizeHtmlContent(htmlSource);
        if (editorRef.current) {
            editorRef.current.innerHTML = cleanHtml || "<p><br></p>";
        }
        setEditorMode("visual");
    };

    const handleFormatHtmlCode = () => {
        setHtmlSource(formatHtmlForEditor(htmlSource));
        toast.success("Código HTML organizado!");
    };

    const executeCommand = (command: string, value: string = "") => {
        document.execCommand(command, false, value);
        if (editorRef.current) {
            editorRef.current.focus();
        }
    };

    const handleAddLink = () => {
        const url = prompt("Digite a URL do link (ex: https://exemplo.com):");
        if (url) {
            let normalizedUrl = url.trim();
            if (!/^https?:\/\//i.test(normalizedUrl) && !/^mailto:/i.test(normalizedUrl)) {
                normalizedUrl = "https://" + normalizedUrl;
            }
            executeCommand("createLink", normalizedUrl);
        }
    };

    const handleInsertBibleQuote = () => {
        executeCommand("formatBlock", "<blockquote>");
        const sel = window.getSelection();
        if (sel && sel.anchorNode) {
            let el = sel.anchorNode as HTMLElement;
            while (el && el.tagName !== "BLOCKQUOTE" && el !== editorRef.current) {
                el = el.parentElement as HTMLElement;
            }
            if (el && el.tagName === "BLOCKQUOTE") {
                if (!el.querySelector(".blockquote-badge")) {
                    const badge = document.createElement("div");
                    badge.className = "blockquote-badge";
                    badge.contentEditable = "false";
                    badge.innerHTML = "📖 Bíblia";
                    el.insertBefore(badge, el.firstChild);
                }
            }
        }
    };

    // Paste event handler in Visual mode to strip disruptive inline styles
    const handlePaste = (e: React.ClipboardEvent<HTMLDivElement>) => {
        e.preventDefault();
        const html = e.clipboardData.getData("text/html");
        const text = e.clipboardData.getData("text/plain");

        if (html) {
            const cleanHtml = sanitizeHtmlContent(html);
            const selection = window.getSelection();
            if (selection && selection.rangeCount > 0) {
                const range = selection.getRangeAt(0);
                range.deleteContents();

                const tempDiv = document.createElement("div");
                tempDiv.innerHTML = cleanHtml;
                const fragment = range.createContextualFragment(tempDiv.innerHTML);
                range.insertNode(fragment);

                range.collapse(false);
                selection.removeAllRanges();
                selection.addRange(range);
            }
        } else if (text) {
            document.execCommand("insertText", false, text);
        }
    };

    const handleSave = async () => {
        const finalTitle = title.trim() || (mode === "note" ? (initialData?.title || "Minhas Anotações") : "");
        if (!finalTitle) {
            toast.error("O título é obrigatório.");
            return;
        }

        let contentToSave: string;
        if (editorMode === "html") {
            contentToSave = sanitizeHtmlContent(htmlSource);
        } else {
            const editorHTML = editorRef.current?.innerHTML || "";
            // If the content is rich HTML (tables, custom sections), preserve clean HTML; otherwise markdown
            if (isHtmlContent(editorHTML) && (editorHTML.includes("<table") || editorHTML.includes("<section") || editorHTML.includes("<div"))) {
                contentToSave = sanitizeHtmlContent(editorHTML);
            } else {
                contentToSave = htmlToMarkdown(editorHTML);
            }
        }

        try {
            setSaving(true);
            await onSave({
                title: finalTitle,
                description: description.trim(),
                markdownContent: contentToSave
            });
            loadedContentKeyRef.current = `${initialData?.id || "new"}::${finalTitle}::${initialData?.url || ""}::${contentToSave}`;
            if (!inline) {
                onClose();
            }
        } catch (err: unknown) {
            const error = err as Error;
            console.error("Error saving text in editor:", error);
            toast.error(error.message || (mode === "note" ? "Erro ao salvar anotações." : "Erro ao salvar o texto."));
        } finally {
            setSaving(false);
        }
    };

    const handleDelete = async () => {
        if (!onDelete) return;
        if (!confirm("Deseja realmente excluir esta anotação? Esta ação não pode ser desfeita.")) return;
        try {
            setDeleting(true);
            await onDelete();
            onClose();
        } catch (err: unknown) {
            const error = err as Error;
            console.error("Error deleting note:", error);
            toast.error(error.message || "Erro ao excluir.");
        } finally {
            setDeleting(false);
        }
    };

    const editorStyles = (
        <style>{`
            .prose-editor h1 { font-size: 1.35rem; font-weight: 700; color: inherit; margin-top: 1.25rem; margin-bottom: 0.5rem; border-bottom: 1px solid var(--border); padding-bottom: 0.25rem; }
            .prose-editor h2 { font-size: 1.15rem; font-weight: 600; color: inherit; margin-top: 1rem; margin-bottom: 0.5rem; }
            .prose-editor h3 { font-size: 1.05rem; font-weight: 600; color: inherit; margin-top: 0.75rem; margin-bottom: 0.25rem; }
            .prose-editor p { font-size: 0.925rem; line-height: 1.65; color: inherit; opacity: 0.95; margin-bottom: 0.75rem; }
            .prose-editor blockquote { border-left: 3px solid var(--primary); padding-left: 0.875rem; margin: 0.875rem 0; font-style: italic; color: inherit; opacity: 0.9; background-color: color-mix(in srgb, var(--primary) 8%, transparent); border-radius: 0 0.5rem 0.5rem 0; padding-top: 0.5rem; padding-bottom: 0.5rem; }
            .prose-editor blockquote .blockquote-badge {
                display: inline-flex;
                align-items: center;
                gap: 0.375rem;
                color: var(--primary);
                font-weight: 600;
                font-size: 0.75rem;
                margin-bottom: 0.375rem;
                user-select: none;
                font-style: normal;
            }
            .prose-editor ul { list-style-type: disc; padding-left: 1.25rem; margin-bottom: 0.75rem; }
            .prose-editor ol { list-style-type: decimal; padding-left: 1.25rem; margin-bottom: 0.75rem; }
            .prose-editor li { font-size: 0.925rem; color: inherit; opacity: 0.95; margin-top: 0.25rem; }
            .prose-editor a { color: var(--primary); text-decoration: underline; font-weight: 500; }
            .prose-editor code { font-family: monospace; font-size: 0.825rem; background-color: var(--muted); padding: 0.125rem 0.25rem; border-radius: 0.25rem; border: 1px solid var(--border); }
            .prose-editor table { width: 100%; border-collapse: collapse; margin: 0.75rem 0; border: 1px solid var(--border); font-size: 0.875rem; border-radius: 0.5rem; overflow: hidden; }
            .prose-editor th { background-color: var(--muted); border: 1px solid var(--border); padding: 0.5rem 0.75rem; font-weight: 600; text-align: left; }
            .prose-editor td { border: 1px solid var(--border); padding: 0.5rem 0.75rem; opacity: 0.9; }
            .prose-editor:empty::before,
            .prose-editor > p:only-child:has(br:only-child)::before {
                content: attr(data-placeholder);
                color: var(--muted-foreground);
                opacity: 0.6;
                cursor: text;
                pointer-events: none;
                display: inline-block;
            }
        `}</style>
    );

    // =========================================================================
    // RENDER: INLINE SIDE-BY-SIDE MODE (Clean, distraction-free Study Panel)
    // =========================================================================
    if (inline) {
        if (!isOpen) return null;
        return (
            <div className={cn(
                "flex flex-col h-full w-full bg-card border border-border/70 rounded-2xl overflow-hidden shadow-xs relative min-h-0",
                className
            )}>
                {editorStyles}

                {/* Loading Overlay */}
                {loadingContent && (
                    <div className="absolute inset-0 bg-background/80 backdrop-blur-[2px] z-50 flex flex-col justify-center items-center gap-2 rounded-2xl">
                        <Loader2 className="h-6 w-6 animate-spin text-primary" />
                        <span className="text-xs text-muted-foreground font-medium">Carregando anotações...</span>
                    </div>
                )}

                {/* 1. Integrated Header: Title Input + Scope Badge + Close */}
                <div className="px-3.5 py-2.5 border-b border-border/50 bg-muted/20 flex items-center justify-between gap-2.5 shrink-0 select-none">
                    <div className="flex items-center gap-2 flex-1 min-w-0">
                        <div className="w-7 h-7 rounded-lg bg-primary/10 flex items-center justify-center shrink-0 text-primary">
                            <StickyNote className="w-3.5 h-3.5" />
                        </div>
                        <input
                            type="text"
                            value={title}
                            onChange={(e) => setTitle(e.target.value)}
                            placeholder="Título da anotação..."
                            className="bg-transparent border-0 border-b border-transparent hover:border-border focus:border-primary focus:ring-0 px-1 py-0.5 text-xs sm:text-sm font-semibold text-foreground placeholder:text-muted-foreground/60 focus:outline-none w-full transition-colors truncate"
                            maxLength={100}
                            title="Editar título da anotação"
                        />
                    </div>

                    <div className="flex items-center gap-1.5 shrink-0">
                        <Button
                            type="button"
                            variant="ghost"
                            size="icon"
                            onClick={onClose}
                            className="h-7 w-7 rounded-lg text-muted-foreground hover:text-foreground cursor-pointer shrink-0"
                            title="Ocultar painel de anotações"
                        >
                            <X className="w-3.5 h-3.5" />
                        </Button>
                    </div>
                </div>

                {/* 2. Streamlined Single-Row Toolbar */}
                <div className="px-3 py-1.5 border-b border-border/40 bg-muted/10 flex items-center justify-between gap-1 overflow-x-auto scrollbar-none shrink-0 select-none">
                    <div className="flex items-center gap-0.5 shrink-0">
                        {/* Text Styles */}
                        <Button 
                            type="button" 
                            variant="ghost" 
                            size="icon" 
                            className="h-7 w-7 rounded-md hover:bg-muted text-foreground cursor-pointer shrink-0 flex items-center justify-center"
                            onClick={() => executeCommand("bold")}
                            title="Negrito (Ctrl+B)"
                        >
                            <Bold className="h-3.5 w-3.5" />
                        </Button>
                        <Button 
                            type="button" 
                            variant="ghost" 
                            size="icon" 
                            className="h-7 w-7 rounded-md hover:bg-muted text-foreground cursor-pointer shrink-0 flex items-center justify-center"
                            onClick={() => executeCommand("italic")}
                            title="Itálico (Ctrl+I)"
                        >
                            <Italic className="h-3.5 w-3.5" />
                        </Button>
                        <Button 
                            type="button" 
                            variant="ghost" 
                            size="icon" 
                            className="h-7 w-7 rounded-md hover:bg-muted text-foreground cursor-pointer shrink-0 flex items-center justify-center"
                            onClick={() => executeCommand("underline")}
                            title="Sublinhado (Ctrl+U)"
                        >
                            <Underline className="h-3.5 w-3.5" />
                        </Button>

                        <div className="h-3.5 w-[1px] bg-border/60 mx-1 shrink-0" />

                        {/* Headings */}
                        <Button 
                            type="button" 
                            variant="ghost" 
                            className="h-7 px-1.5 text-xs font-semibold rounded-md hover:bg-muted text-foreground cursor-pointer shrink-0"
                            onClick={() => executeCommand("formatBlock", "<h1>")}
                            title="Título 1"
                        >
                            H1
                        </Button>
                        <Button 
                            type="button" 
                            variant="ghost" 
                            className="h-7 px-1.5 text-xs font-semibold rounded-md hover:bg-muted text-foreground cursor-pointer shrink-0"
                            onClick={() => executeCommand("formatBlock", "<h2>")}
                            title="Título 2"
                        >
                            H2
                        </Button>
                        <Button 
                            type="button" 
                            variant="ghost" 
                            className="h-7 px-1.5 text-xs font-medium rounded-md hover:bg-muted text-muted-foreground hover:text-foreground cursor-pointer shrink-0"
                            onClick={() => executeCommand("formatBlock", "<p>")}
                            title="Texto Normal"
                        >
                            P
                        </Button>

                        <div className="h-3.5 w-[1px] bg-border/60 mx-1 shrink-0" />

                        {/* Lists & Quotes */}
                        <Button 
                            type="button" 
                            variant="ghost" 
                            size="icon" 
                            className="h-7 w-7 rounded-md hover:bg-muted text-primary cursor-pointer shrink-0 flex items-center justify-center"
                            onClick={handleInsertBibleQuote}
                            title="Citação Bíblica (📖)"
                        >
                            <Quote className="h-3.5 w-3.5" />
                        </Button>
                        <Button 
                            type="button" 
                            variant="ghost" 
                            size="icon" 
                            className="h-7 w-7 rounded-md hover:bg-muted text-foreground cursor-pointer shrink-0 flex items-center justify-center"
                            onClick={() => executeCommand("insertUnorderedList")}
                            title="Lista com Marcadores"
                        >
                            <List className="h-3.5 w-3.5" />
                        </Button>
                        <Button 
                            type="button" 
                            variant="ghost" 
                            size="icon" 
                            className="h-7 w-7 rounded-md hover:bg-muted text-foreground cursor-pointer shrink-0 flex items-center justify-center"
                            onClick={() => executeCommand("insertOrderedList")}
                            title="Lista Numerada"
                        >
                            <ListOrdered className="h-3.5 w-3.5" />
                        </Button>

                        <div className="h-3.5 w-[1px] bg-border/60 mx-1 shrink-0" />

                        {/* Link & Eraser */}
                        <Button 
                            type="button" 
                            variant="ghost" 
                            size="icon" 
                            className="h-7 w-7 rounded-md hover:bg-muted text-foreground cursor-pointer shrink-0 flex items-center justify-center"
                            onClick={handleAddLink}
                            title="Inserir Link"
                        >
                            <LinkIcon className="h-3.5 w-3.5" />
                        </Button>
                        <Button 
                            type="button" 
                            variant="ghost" 
                            size="icon" 
                            className="h-7 w-7 rounded-md hover:bg-muted text-foreground cursor-pointer shrink-0 flex items-center justify-center"
                            onClick={() => executeCommand("removeFormat")}
                            title="Limpar Formatação"
                        >
                            <Eraser className="h-3.5 w-3.5" />
                        </Button>

                        <div className="h-3.5 w-[1px] bg-border/60 mx-1 shrink-0" />

                        {/* Undo / Redo */}
                        <Button 
                            type="button" 
                            variant="ghost" 
                            size="icon" 
                            className="h-7 w-7 rounded-md hover:bg-muted text-muted-foreground hover:text-foreground cursor-pointer shrink-0 flex items-center justify-center"
                            onClick={() => executeCommand("undo")}
                            title="Desfazer"
                        >
                            <Undo className="h-3.5 w-3.5" />
                        </Button>
                        <Button 
                            type="button" 
                            variant="ghost" 
                            size="icon" 
                            className="h-7 w-7 rounded-md hover:bg-muted text-muted-foreground hover:text-foreground cursor-pointer shrink-0 flex items-center justify-center"
                            onClick={() => executeCommand("redo")}
                            title="Refazer"
                        >
                            <Redo className="h-3.5 w-3.5" />
                        </Button>
                    </div>

                    {/* Right side: HTML mode toggle */}
                    <div className="flex items-center gap-1 shrink-0 pl-1">
                        {editorMode === "html" && (
                            <Button
                                type="button"
                                variant="ghost"
                                size="sm"
                                onClick={handleFormatHtmlCode}
                                className="h-7 px-1.5 text-[11px] font-mono rounded-md hover:bg-muted text-muted-foreground hover:text-foreground cursor-pointer"
                                title="Formatar HTML"
                            >
                                <Code className="h-3 w-3" />
                            </Button>
                        )}
                        <Button
                            type="button"
                            variant="ghost"
                            size="sm"
                            onClick={editorMode === "visual" ? handleSwitchToHtml : handleSwitchToVisual}
                            className={cn(
                                "h-7 px-2 text-[11px] font-mono rounded-md transition-colors gap-1 cursor-pointer",
                                editorMode === "html" 
                                    ? "bg-primary/10 text-primary font-semibold" 
                                    : "text-muted-foreground hover:text-foreground hover:bg-muted"
                            )}
                            title={editorMode === "visual" ? "Alternar para código HTML" : "Voltar para editor visual"}
                        >
                            {editorMode === "visual" ? (
                                <>
                                    <Code2 className="h-3 w-3" />
                                    <span className="hidden sm:inline">HTML</span>
                                </>
                            ) : (
                                <>
                                    <Pencil className="h-3 w-3" />
                                    <span className="hidden sm:inline">Visual</span>
                                </>
                            )}
                        </Button>
                    </div>
                </div>

                {/* 3. Expansive Note Writing Canvas */}
                <div className="flex-1 min-h-0 flex flex-col relative bg-card">
                    {editorMode === "visual" ? (
                        <div 
                            ref={setEditorRef}
                            contentEditable
                            onPaste={handlePaste}
                            className="flex-1 min-h-0 w-full overflow-y-auto p-4 sm:p-5 text-foreground bg-card focus:outline-none prose-editor custom-scrollbar leading-relaxed text-sm sm:text-base select-text"
                            data-placeholder="Comece a registrar suas anotações e reflexões desta aula..."
                            style={{ outline: "none" }}
                        />
                    ) : (
                        <textarea
                            value={htmlSource}
                            onChange={(e) => setHtmlSource(e.target.value)}
                            placeholder="Cole ou digite código HTML aqui..."
                            spellCheck={false}
                            className="flex-1 min-h-0 w-full p-4 sm:p-5 font-mono text-xs sm:text-sm bg-card text-foreground border-0 focus:outline-none resize-none leading-relaxed custom-scrollbar placeholder:text-muted-foreground/50"
                        />
                    )}
                </div>

                {/* 4. Streamlined Footer */}
                <div className="px-3.5 py-2.5 border-t border-border/40 bg-muted/10 flex items-center justify-between gap-2 shrink-0">
                    <div className="flex items-center gap-2">
                        {onDelete && (
                            <Button 
                                type="button" 
                                variant="ghost" 
                                size="sm"
                                onClick={handleDelete}
                                className="h-8 px-2.5 rounded-xl text-xs text-destructive hover:bg-destructive/10 hover:text-destructive gap-1.5 cursor-pointer"
                                disabled={saving || deleting}
                                title="Excluir anotações"
                            >
                                <Trash2 className="h-3.5 w-3.5" />
                                <span className="hidden sm:inline">Excluir</span>
                            </Button>
                        )}
                        {!onDelete && (
                            <span className="text-[11px] text-muted-foreground hidden sm:inline select-none">
                                Anotações privadas sincronizadas
                            </span>
                        )}
                    </div>

                    <div className="flex items-center gap-2">
                        <Button 
                            type="button" 
                            variant="ghost" 
                            size="sm"
                            onClick={onClose}
                            className="h-8 px-3 rounded-xl text-xs font-medium cursor-pointer text-muted-foreground hover:text-foreground"
                            disabled={saving || deleting}
                        >
                            Ocultar
                        </Button>
                        <Button 
                            type="button" 
                            size="sm"
                            onClick={handleSave}
                            className="h-8 px-3.5 rounded-xl text-xs font-semibold gap-1.5 shadow-2xs btn-tactile cursor-pointer bg-primary text-primary-foreground hover:bg-primary/90"
                            disabled={saving || deleting || loadingContent}
                        >
                            {saving ? (
                                <>
                                    <Loader2 className="h-3.5 w-3.5 animate-spin" />
                                    <span>Salvando...</span>
                                </>
                            ) : (
                                <>
                                    <Save className="h-3.5 w-3.5" />
                                    <span>{saveButtonText}</span>
                                </>
                            )}
                        </Button>
                    </div>
                </div>
            </div>
        );
    }

    // =========================================================================
    // RENDER: MODAL DIALOG MODE (Writing text resource or standalone note)
    // =========================================================================
    return (
        <Dialog open={isOpen} onOpenChange={(open) => { if (!open) onClose(); }}>
            <DialogContent size="2xl" className="sm:max-w-5xl md:max-w-6xl w-[95vw] h-[90dvh] bg-card border-border shadow-2xl rounded-3xl flex flex-col p-6 overflow-hidden gap-0">
                {editorStyles}
                
                {/* Header */}
                <DialogHeader className="flex flex-row justify-between items-center pr-6 pb-3 border-b border-border/40 shrink-0">
                    <div>
                        <DialogTitle className="text-lg sm:text-xl font-bold text-foreground">
                            {modalTitle || (mode === "note" ? "Minhas Anotações" : (initialData ? "Editar Texto" : "Escrever Novo Texto"))}
                        </DialogTitle>
                        <DialogDescription className="text-xs text-muted-foreground mt-0.5">
                            {modalDescription || (mode === "note" 
                                ? "Suas reflexões privadas de estudo bíblico." 
                                : "Escreva e formate seu material didático ou cole código formatado.")}
                        </DialogDescription>
                    </div>
                </DialogHeader>

                {/* Body */}
                <div className="flex-1 flex flex-col gap-3 py-3 overflow-hidden relative min-h-0">
                    {loadingContent && (
                        <div className="absolute inset-0 bg-background/80 backdrop-blur-[2px] z-50 flex flex-col justify-center items-center gap-3 rounded-2xl">
                            <Loader2 className="h-8 w-8 animate-spin text-primary" />
                            <span className="text-sm text-muted-foreground">Carregando conteúdo...</span>
                        </div>
                    )}
                    
                    {/* Title & Description Fields */}
                    <div className={cn("grid gap-2.5 sm:gap-3 shrink-0", hideDescription ? "grid-cols-1" : "grid-cols-1 md:grid-cols-3")}>
                        <div className={hideDescription ? "w-full" : "md:col-span-1"}>
                            <Field>
                                <FieldLabel htmlFor="editor-modal-title" className="text-xs font-semibold">{titleLabel}</FieldLabel>
                                <Input 
                                    id="editor-modal-title" 
                                    placeholder={titlePlaceholder} 
                                    value={title} 
                                    onChange={(e) => setTitle(e.target.value)}
                                    className="rounded-xl h-9 sm:h-10 border-border bg-background focus-visible:ring-2 focus-visible:ring-primary/20 text-sm"
                                    maxLength={100}
                                />
                            </Field>
                        </div>
                        {!hideDescription && (
                            <div className="md:col-span-2">
                                <Field>
                                    <FieldLabel htmlFor="editor-modal-desc" className="text-xs font-semibold">Breve Descrição / Resumo</FieldLabel>
                                    <Input 
                                        id="editor-modal-desc" 
                                        placeholder="Sobre o que fala este texto?" 
                                        value={description} 
                                        onChange={(e) => setDescription(e.target.value)}
                                        className="rounded-xl h-9 sm:h-10 border-border bg-background focus-visible:ring-2 focus-visible:ring-primary/20 text-sm"
                                        maxLength={250}
                                    />
                                </Field>
                            </div>
                        )}
                    </div>

                    {/* Streamlined Toolbar */}
                    <div className="flex items-center justify-between gap-1 p-1 bg-muted/30 border border-border/60 rounded-xl shrink-0 overflow-x-auto scrollbar-none">
                        <div className="flex items-center gap-0.5 shrink-0">
                            <Button 
                                type="button" 
                                variant="ghost" 
                                size="icon" 
                                className="h-8 w-8 rounded-lg hover:bg-muted text-foreground cursor-pointer shrink-0 flex items-center justify-center"
                                onClick={() => executeCommand("bold")}
                                title="Negrito (Ctrl+B)"
                            >
                                <Bold className="h-4 w-4" />
                            </Button>
                            <Button 
                                type="button" 
                                variant="ghost" 
                                size="icon" 
                                className="h-8 w-8 rounded-lg hover:bg-muted text-foreground cursor-pointer shrink-0 flex items-center justify-center"
                                onClick={() => executeCommand("italic")}
                                title="Itálico (Ctrl+I)"
                            >
                                <Italic className="h-4 w-4" />
                            </Button>
                            <Button 
                                type="button" 
                                variant="ghost" 
                                size="icon" 
                                className="h-8 w-8 rounded-lg hover:bg-muted text-foreground cursor-pointer shrink-0 flex items-center justify-center"
                                onClick={() => executeCommand("underline")}
                                title="Sublinhado (Ctrl+U)"
                            >
                                <Underline className="h-4 w-4" />
                            </Button>

                            <div className="h-4 w-[1px] bg-border mx-1 shrink-0" />

                            <Button 
                                type="button" 
                                variant="ghost" 
                                className="h-8 px-2 text-xs font-semibold rounded-lg hover:bg-muted text-foreground cursor-pointer shrink-0"
                                onClick={() => executeCommand("formatBlock", "<h1>")}
                                title="Título 1"
                            >
                                H1
                            </Button>
                            <Button 
                                type="button" 
                                variant="ghost" 
                                className="h-8 px-2 text-xs font-semibold rounded-lg hover:bg-muted text-foreground cursor-pointer shrink-0"
                                onClick={() => executeCommand("formatBlock", "<h2>")}
                                title="Título 2"
                            >
                                H2
                            </Button>
                            <Button 
                                type="button" 
                                variant="ghost" 
                                className="h-8 px-2 text-xs font-medium rounded-lg hover:bg-muted text-muted-foreground hover:text-foreground cursor-pointer shrink-0"
                                onClick={() => executeCommand("formatBlock", "<p>")}
                                title="Texto Normal"
                            >
                                Normal
                            </Button>

                            <div className="h-4 w-[1px] bg-border mx-1 shrink-0" />

                            <Button 
                                type="button" 
                                variant="ghost" 
                                size="icon" 
                                className="h-8 w-8 rounded-lg hover:bg-muted text-foreground cursor-pointer shrink-0 flex items-center justify-center"
                                onClick={() => executeCommand("justifyLeft")}
                                title="Alinhar à Esquerda"
                            >
                                <AlignLeft className="h-4 w-4" />
                            </Button>
                            <Button 
                                type="button" 
                                variant="ghost" 
                                size="icon" 
                                className="h-8 w-8 rounded-lg hover:bg-muted text-foreground cursor-pointer shrink-0 flex items-center justify-center"
                                onClick={() => executeCommand("justifyCenter")}
                                title="Centralizar"
                            >
                                <AlignCenter className="h-4 w-4" />
                            </Button>
                            <Button 
                                type="button" 
                                variant="ghost" 
                                size="icon" 
                                className="h-8 w-8 rounded-lg hover:bg-muted text-foreground cursor-pointer shrink-0 flex items-center justify-center"
                                onClick={() => executeCommand("justifyFull")}
                                title="Justificar"
                            >
                                <AlignJustify className="h-4 w-4" />
                            </Button>

                            <div className="h-4 w-[1px] bg-border mx-1 shrink-0" />

                            <Button 
                                type="button" 
                                variant="ghost" 
                                size="icon" 
                                className="h-8 w-8 rounded-lg hover:bg-muted text-primary cursor-pointer shrink-0 flex items-center justify-center"
                                onClick={handleInsertBibleQuote}
                                title="Citação Bíblica"
                            >
                                <Quote className="h-4 w-4" />
                            </Button>
                            <Button 
                                type="button" 
                                variant="ghost" 
                                size="icon" 
                                className="h-8 w-8 rounded-lg hover:bg-muted text-foreground cursor-pointer shrink-0 flex items-center justify-center"
                                onClick={() => executeCommand("insertUnorderedList")}
                                title="Lista com Marcadores"
                            >
                                <List className="h-4 w-4" />
                            </Button>
                            <Button 
                                type="button" 
                                variant="ghost" 
                                size="icon" 
                                className="h-8 w-8 rounded-lg hover:bg-muted text-foreground cursor-pointer shrink-0 flex items-center justify-center"
                                onClick={() => executeCommand("insertOrderedList")}
                                title="Lista Numerada"
                            >
                                <ListOrdered className="h-4 w-4" />
                            </Button>

                            <div className="h-4 w-[1px] bg-border mx-1 shrink-0" />

                            <Button 
                                type="button" 
                                variant="ghost" 
                                size="icon" 
                                className="h-8 w-8 rounded-lg hover:bg-muted text-foreground cursor-pointer shrink-0 flex items-center justify-center"
                                onClick={handleAddLink}
                                title="Inserir Link"
                            >
                                <LinkIcon className="h-4 w-4" />
                            </Button>
                            <Button 
                                type="button" 
                                variant="ghost" 
                                size="icon" 
                                className="h-8 w-8 rounded-lg hover:bg-muted text-foreground cursor-pointer shrink-0 flex items-center justify-center"
                                onClick={() => executeCommand("removeFormat")}
                                title="Limpar Formatação"
                            >
                                <Eraser className="h-4 w-4" />
                            </Button>

                            <div className="h-4 w-[1px] bg-border mx-1 shrink-0" />

                            <Button 
                                type="button" 
                                variant="ghost" 
                                size="icon" 
                                className="h-8 w-8 rounded-lg hover:bg-muted text-foreground cursor-pointer shrink-0 flex items-center justify-center"
                                onClick={() => executeCommand("undo")}
                                title="Desfazer"
                            >
                                <Undo className="h-4 w-4" />
                            </Button>
                            <Button 
                                type="button" 
                                variant="ghost" 
                                size="icon" 
                                className="h-8 w-8 rounded-lg hover:bg-muted text-foreground cursor-pointer shrink-0 flex items-center justify-center"
                                onClick={() => executeCommand("redo")}
                                title="Refazer"
                            >
                                <Redo className="h-4 w-4" />
                            </Button>
                        </div>

                        {/* Mode Switcher */}
                        <div className="flex items-center gap-1 shrink-0 pl-2">
                            {editorMode === "html" && (
                                <Button
                                    type="button"
                                    variant="outline"
                                    size="sm"
                                    onClick={handleFormatHtmlCode}
                                    className="h-8 px-2.5 rounded-lg text-xs font-medium border-border/70 cursor-pointer gap-1"
                                    title="Organizar indentação"
                                >
                                    <Code className="h-3.5 w-3.5" />
                                    <span>Formatar</span>
                                </Button>
                            )}
                            <Button
                                type="button"
                                variant="ghost"
                                size="sm"
                                onClick={editorMode === "visual" ? handleSwitchToHtml : handleSwitchToVisual}
                                className={cn(
                                    "h-8 px-2.5 rounded-lg text-xs font-semibold transition-all flex items-center gap-1.5 cursor-pointer",
                                    editorMode === "html"
                                        ? "bg-primary/10 text-primary"
                                        : "hover:bg-muted text-muted-foreground hover:text-foreground"
                                )}
                            >
                                {editorMode === "visual" ? (
                                    <>
                                        <Code2 className="h-3.5 w-3.5" />
                                        <span>HTML</span>
                                    </>
                                ) : (
                                    <>
                                        <Pencil className="h-3.5 w-3.5" />
                                        <span>Visual</span>
                                    </>
                                )}
                            </Button>
                        </div>
                    </div>

                    {/* Workspace */}
                    <div className="flex-1 flex flex-col min-h-0 relative">
                        {editorMode === "visual" ? (
                            <div 
                                ref={setEditorRef}
                                contentEditable
                                onPaste={handlePaste}
                                className="flex-1 overflow-y-auto border border-border/80 rounded-2xl p-4 sm:p-6 bg-card focus:outline-none focus:ring-2 focus:ring-primary/20 text-foreground prose-editor custom-scrollbar"
                                data-placeholder="Escreva suas anotações ou textos aqui..."
                                style={{ outline: "none" }}
                            />
                        ) : (
                            <textarea
                                value={htmlSource}
                                onChange={(e) => setHtmlSource(e.target.value)}
                                placeholder="Cole seu código HTML aqui..."
                                spellCheck={false}
                                className="flex-1 w-full h-full p-4 sm:p-6 font-mono text-xs sm:text-sm bg-card border border-border/80 rounded-2xl focus:outline-none focus:ring-2 focus:ring-primary/20 text-foreground resize-none leading-relaxed custom-scrollbar placeholder:text-muted-foreground/45"
                            />
                        )}
                    </div>
                </div>

                {/* Footer */}
                <div className="flex flex-col-reverse sm:flex-row sm:items-center justify-between gap-2.5 sm:gap-3 pt-3 border-t border-border/40 shrink-0">
                    <div>
                        {onDelete && (
                            <Button 
                                type="button" 
                                variant="ghost" 
                                onClick={handleDelete}
                                className="rounded-xl px-4 min-h-[40px] text-xs font-medium text-destructive hover:bg-destructive/10 hover:text-destructive gap-1.5 cursor-pointer w-full sm:w-auto"
                                disabled={saving || deleting}
                            >
                                <Trash2 className="h-4 w-4" />
                                <span>Excluir</span>
                            </Button>
                        )}
                    </div>
                    <div className="flex items-center justify-end gap-2 w-full sm:w-auto">
                        <Button 
                            type="button" 
                            variant="ghost" 
                            onClick={onClose}
                            className="rounded-xl px-4 min-h-[40px] text-xs font-medium cursor-pointer"
                            disabled={saving || deleting}
                        >
                            Cancelar
                        </Button>
                        <Button 
                            type="button" 
                            onClick={handleSave}
                            className="rounded-xl px-5 min-h-[40px] text-xs font-semibold gap-2 shadow-2xs btn-tactile cursor-pointer bg-primary text-primary-foreground hover:bg-primary/90 flex-1 sm:flex-initial"
                            disabled={saving || deleting || loadingContent}
                        >
                            {saving ? (
                                <>
                                    <Loader2 className="h-4 w-4 animate-spin" />
                                    <span>Salvando...</span>
                                </>
                            ) : (
                                <>
                                    <Save className="h-4 w-4" />
                                    <span>{saveButtonText}</span>
                                </>
                            )}
                        </Button>
                    </div>
                </div>
            </DialogContent>
        </Dialog>
    );
}
