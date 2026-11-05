import React, { useState, useEffect, useRef, useCallback } from "react";
import { 
    Bold, 
    Italic, 
    Underline, 
    Heading1, 
    Heading2, 
    Heading3, 
    Heading4, 
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
            .prose-editor h1 { font-size: 1.5rem; font-weight: 800; color: inherit; margin-top: 1.25rem; margin-bottom: 0.5rem; border-bottom: 1px solid var(--border); padding-bottom: 0.25rem; }
            .prose-editor h2 { font-size: 1.25rem; font-weight: 700; color: inherit; margin-top: 1.25rem; margin-bottom: 0.5rem; }
            .prose-editor h3 { font-size: 1.125rem; font-weight: 600; color: inherit; margin-top: 1rem; margin-bottom: 0.25rem; }
            .prose-editor h4 { font-size: 0.95rem; font-weight: 600; color: inherit; opacity: 0.7; margin-top: 0.75rem; margin-bottom: 0.25rem; }
            .prose-editor p { font-size: 0.875rem; line-height: 1.6; color: inherit; opacity: 0.9; margin-bottom: 0.75rem; }
            .prose-editor blockquote { border-left: 4px solid var(--primary); padding-left: 1rem; margin: 1rem 0; font-style: italic; color: inherit; opacity: 0.8; background-color: color-mix(in srgb, var(--muted) 20%, transparent); border-radius: 0 0.375rem 0.375rem 0; padding-top: 0.5rem; padding-bottom: 0.5rem; }
            .prose-editor blockquote .blockquote-badge {
                display: inline-flex;
                align-items: center;
                gap: 0.375rem;
                color: var(--primary);
                font-weight: 600;
                font-size: 0.75rem;
                margin-bottom: 0.5rem;
                user-select: none;
                font-style: normal;
            }
            .prose-editor ul { list-style-type: disc; padding-left: 1.5rem; margin-bottom: 0.75rem; }
            .prose-editor ol { list-style-type: decimal; padding-left: 1.5rem; margin-bottom: 0.75rem; }
            .prose-editor li { font-size: 0.875rem; color: inherit; opacity: 0.9; margin-top: 0.25rem; }
            .prose-editor a { color: var(--primary); text-decoration: underline; font-weight: 500; }
            .prose-editor code { font-family: monospace; font-size: 0.825rem; background-color: var(--muted); padding: 0.125rem 0.25rem; border-radius: 0.25rem; border: 1px solid var(--border); }
            .prose-editor table { width: 100%; border-collapse: collapse; margin: 1rem 0; border: 1px solid var(--border); font-size: 0.875rem; border-radius: 0.5rem; overflow: hidden; }
            .prose-editor th { background-color: var(--muted); border: 1px solid var(--border); padding: 0.5rem 0.75rem; font-weight: 600; text-align: left; }
            .prose-editor td { border: 1px solid var(--border); padding: 0.5rem 0.75rem; opacity: 0.9; }
            .prose-editor .editor-properties-block {
                background-color: var(--muted);
                border: 1px solid var(--border);
                border-radius: 0.75rem;
                padding: 1rem;
                margin-bottom: 1.5rem;
                font-family: monospace;
                font-size: 0.8rem;
                color: inherit;
                opacity: 0.95;
            }
            .prose-editor .editor-properties-block .properties-header {
                display: flex;
                align-items: center;
                justify-content: space-between;
                border-bottom: 1px solid var(--border);
                padding-bottom: 0.5rem;
                margin-bottom: 0.5rem;
                color: var(--muted-foreground);
                font-weight: 700;
                text-transform: uppercase;
                letter-spacing: 0.05em;
                font-size: 0.7rem;
                user-select: none;
            }
            .prose-editor .editor-properties-block .properties-body {
                outline: none;
                min-height: 20px;
                line-height: 1.5;
            }
            .prose-editor:empty::before {
                content: attr(placeholder);
                color: inherit;
                opacity: 0.4;
                cursor: text;
            }
        `}</style>
    );

    const editorBody = (
        <div className="flex-1 flex flex-col gap-3 sm:gap-4 py-2 sm:py-3 overflow-hidden relative min-h-0">
            {loadingContent && (
                <div className="absolute inset-0 bg-background/80 backdrop-blur-[2px] z-[100] flex flex-col justify-center items-center gap-3 rounded-2xl">
                    <Loader2 className="h-8 w-8 animate-spin text-primary" />
                    <span className="text-sm text-muted-foreground">Carregando conteúdo...</span>
                </div>
            )}
            
            {/* Title & Description Fields */}
            <div className={cn("grid gap-2 sm:gap-3 shrink-0", hideDescription ? "grid-cols-1" : "grid-cols-1 md:grid-cols-3")}>
                <div className={hideDescription ? "w-full" : "md:col-span-1"}>
                    <Field>
                        <FieldLabel htmlFor="editor-title" className="text-xs font-semibold">{titleLabel}</FieldLabel>
                        <Input 
                            id="editor-title" 
                            placeholder={titlePlaceholder} 
                            value={title} 
                            onChange={(e) => setTitle(e.target.value)}
                            className="rounded-md h-9 sm:h-10 border-border bg-background focus-visible:ring-2 focus-visible:ring-primary/20 focus-visible:border-primary/60 text-sm"
                            maxLength={100}
                        />
                    </Field>
                </div>
                {!hideDescription && (
                    <div className="md:col-span-2">
                        <Field>
                            <FieldLabel htmlFor="editor-desc" className="text-xs font-semibold">Breve Descrição / Resumo</FieldLabel>
                            <Input 
                                id="editor-desc" 
                                placeholder="Sobre o que fala este texto?" 
                                value={description} 
                                onChange={(e) => setDescription(e.target.value)}
                                className="rounded-md h-9 sm:h-10 border-border bg-background focus-visible:ring-2 focus-visible:ring-primary/20 focus-visible:border-primary/60 text-sm"
                                maxLength={250}
                            />
                        </Field>
                    </div>
                )}
            </div>

            {/* Mode Switcher Bar */}
            <div className="flex flex-wrap items-center justify-between gap-2 shrink-0">
                <div className="flex items-center gap-1 bg-muted/40 p-1 rounded-xl border border-border/60">
                    <button
                        type="button"
                        onClick={handleSwitchToVisual}
                        className={cn(
                            "px-3 py-1.5 rounded-lg text-xs font-semibold transition-all flex items-center gap-1.5 cursor-pointer min-h-[38px]",
                            editorMode === "visual"
                                ? "bg-background text-foreground shadow-2xs font-bold"
                                : "text-muted-foreground hover:text-foreground"
                        )}
                    >
                        <Pencil className="h-3.5 w-3.5" />
                        <span>Visual</span>
                    </button>
                    <button
                        type="button"
                        onClick={handleSwitchToHtml}
                        className={cn(
                            "px-3 py-1.5 rounded-lg text-xs font-semibold transition-all flex items-center gap-1.5 cursor-pointer min-h-[38px]",
                            editorMode === "html"
                                ? "bg-background text-foreground shadow-2xs font-bold"
                                : "text-muted-foreground hover:text-foreground"
                        )}
                    >
                        <Code2 className="h-3.5 w-3.5" />
                        <span>Código HTML</span>
                    </button>
                </div>

                {editorMode === "html" && (
                    <div className="flex items-center gap-1.5 sm:gap-2">
                        <Button
                            type="button"
                            variant="outline"
                            size="sm"
                            onClick={handleFormatHtmlCode}
                            className="h-8 px-2.5 rounded-lg text-xs font-medium border-border/70 cursor-pointer gap-1 min-h-[36px]"
                            title="Organizar indentação do HTML"
                        >
                            <Code className="h-3.5 w-3.5" />
                            <span className="hidden sm:inline">Formatar Código</span>
                            <span className="sm:hidden">Formatar</span>
                        </Button>
                        <Button
                            type="button"
                            variant="ghost"
                            size="sm"
                            onClick={() => setHtmlSource("")}
                            className="h-8 px-2.5 rounded-lg text-xs font-medium text-destructive hover:bg-destructive/10 cursor-pointer min-h-[36px]"
                            title="Limpar código"
                        >
                            <span>Limpar</span>
                        </Button>
                    </div>
                )}
            </div>

            {/* Visual Toolbar OR HTML Notice */}
            {editorMode === "visual" ? (
                <div className="flex flex-wrap items-center gap-1 p-1 bg-muted/30 border border-border/60 rounded-xl shrink-0 overflow-x-auto scrollbar-none">
                    {/* Inline Formats */}
                    <Button 
                        type="button" 
                        variant="ghost" 
                        size="icon" 
                        className="min-h-[44px] min-w-[38px] sm:min-h-8 sm:min-w-8 sm:h-8 sm:w-8 rounded-lg hover:bg-muted text-foreground cursor-pointer shrink-0 flex items-center justify-center"
                        onClick={() => executeCommand("bold")}
                        title="Negrito"
                    >
                        <Bold className="h-3.5 w-3.5 sm:h-4 sm:w-4" />
                    </Button>
                    <Button 
                        type="button" 
                        variant="ghost" 
                        size="icon" 
                        className="min-h-[44px] min-w-[38px] sm:min-h-8 sm:min-w-8 sm:h-8 sm:w-8 rounded-lg hover:bg-muted text-foreground cursor-pointer shrink-0 flex items-center justify-center"
                        onClick={() => executeCommand("italic")}
                        title="Itálico"
                    >
                        <Italic className="h-3.5 w-3.5 sm:h-4 sm:w-4" />
                    </Button>
                    <Button 
                        type="button" 
                        variant="ghost" 
                        size="icon" 
                        className="min-h-[44px] min-w-[38px] sm:min-h-8 sm:min-w-8 sm:h-8 sm:w-8 rounded-lg hover:bg-muted text-foreground cursor-pointer shrink-0 flex items-center justify-center"
                        onClick={() => executeCommand("underline")}
                        title="Sublinhado"
                    >
                        <Underline className="h-3.5 w-3.5 sm:h-4 sm:w-4" />
                    </Button>

                    <div className="h-4 w-[1px] bg-border mx-0.5 sm:mx-1 shrink-0" />

                    {/* Headings */}
                    <Button 
                        type="button" 
                        variant="ghost" 
                        size="icon" 
                        className="min-h-[44px] min-w-[38px] sm:min-h-8 sm:min-w-8 sm:h-8 sm:w-8 rounded-lg hover:bg-muted text-foreground cursor-pointer shrink-0 flex items-center justify-center"
                        onClick={() => executeCommand("formatBlock", "<h1>")}
                        title="Título 1"
                    >
                        <Heading1 className="h-3.5 w-3.5 sm:h-4 sm:w-4" />
                    </Button>
                    <Button 
                        type="button" 
                        variant="ghost" 
                        size="icon" 
                        className="min-h-[44px] min-w-[38px] sm:min-h-8 sm:min-w-8 sm:h-8 sm:w-8 rounded-lg hover:bg-muted text-foreground cursor-pointer shrink-0 flex items-center justify-center"
                        onClick={() => executeCommand("formatBlock", "<h2>")}
                        title="Título 2"
                    >
                        <Heading2 className="h-3.5 w-3.5 sm:h-4 sm:w-4" />
                    </Button>
                    <Button 
                        type="button" 
                        variant="ghost" 
                        size="icon" 
                        className="min-h-[44px] min-w-[38px] sm:min-h-8 sm:min-w-8 sm:h-8 sm:w-8 rounded-lg hover:bg-muted text-foreground cursor-pointer shrink-0 flex items-center justify-center"
                        onClick={() => executeCommand("formatBlock", "<h3>")}
                        title="Título 3"
                    >
                        <Heading3 className="h-3.5 w-3.5 sm:h-4 sm:w-4" />
                    </Button>
                    <Button 
                        type="button" 
                        variant="ghost" 
                        size="icon" 
                        className="min-h-[44px] min-w-[38px] sm:min-h-8 sm:min-w-8 sm:h-8 sm:w-8 rounded-lg hover:bg-muted text-foreground cursor-pointer shrink-0 flex items-center justify-center"
                        onClick={() => executeCommand("formatBlock", "<h4>")}
                        title="Subtítulo"
                    >
                        <Heading4 className="h-3.5 w-3.5 sm:h-4 sm:w-4 text-muted-foreground" />
                    </Button>
                    <Button 
                        type="button" 
                        variant="ghost" 
                        className="h-7 sm:h-8 px-1.5 sm:px-2 text-xs font-semibold rounded-lg hover:bg-muted text-foreground cursor-pointer shrink-0"
                        onClick={() => executeCommand("formatBlock", "<p>")}
                        title="Texto Normal"
                    >
                        Normal
                    </Button>

                    <div className="h-4 w-[1px] bg-border mx-0.5 sm:mx-1 shrink-0" />

                    {/* Alignments */}
                    <Button 
                        type="button" 
                        variant="ghost" 
                        size="icon" 
                        className="min-h-[44px] min-w-[38px] sm:min-h-8 sm:min-w-8 sm:h-8 sm:w-8 rounded-lg hover:bg-muted text-foreground cursor-pointer shrink-0 flex items-center justify-center"
                        onClick={() => executeCommand("justifyLeft")}
                        title="Alinhar à Esquerda"
                    >
                        <AlignLeft className="h-3.5 w-3.5 sm:h-4 sm:w-4" />
                    </Button>
                    <Button 
                        type="button" 
                        variant="ghost" 
                        size="icon" 
                        className="min-h-[44px] min-w-[38px] sm:min-h-8 sm:min-w-8 sm:h-8 sm:w-8 rounded-lg hover:bg-muted text-foreground cursor-pointer shrink-0 flex items-center justify-center"
                        onClick={() => executeCommand("justifyCenter")}
                        title="Centralizar"
                    >
                        <AlignCenter className="h-3.5 w-3.5 sm:h-4 sm:w-4" />
                    </Button>
                    <Button 
                        type="button" 
                        variant="ghost" 
                        size="icon" 
                        className="min-h-[44px] min-w-[38px] sm:min-h-8 sm:min-w-8 sm:h-8 sm:w-8 rounded-lg hover:bg-muted text-foreground cursor-pointer shrink-0 flex items-center justify-center"
                        onClick={() => executeCommand("justifyFull")}
                        title="Justificar"
                    >
                        <AlignJustify className="h-3.5 w-3.5 sm:h-4 sm:w-4" />
                    </Button>

                    <div className="h-4 w-[1px] bg-border mx-0.5 sm:mx-1 shrink-0" />

                    {/* Lists & Quotes */}
                    <Button 
                        type="button" 
                        variant="ghost" 
                        size="icon" 
                        className="min-h-[44px] min-w-[38px] sm:min-h-8 sm:min-w-8 sm:h-8 sm:w-8 rounded-lg hover:bg-muted text-foreground cursor-pointer shrink-0 flex items-center justify-center"
                        onClick={() => {
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
                        }}
                        title="Citação Bíblica"
                    >
                        <Quote className="h-3.5 w-3.5 sm:h-4 sm:w-4 text-primary" />
                    </Button>
                    <Button 
                        type="button" 
                        variant="ghost" 
                        size="icon" 
                        className="min-h-[44px] min-w-[38px] sm:min-h-8 sm:min-w-8 sm:h-8 sm:w-8 rounded-lg hover:bg-muted text-foreground cursor-pointer shrink-0 flex items-center justify-center"
                        onClick={() => executeCommand("insertUnorderedList")}
                        title="Lista com Marcadores"
                    >
                        <List className="h-3.5 w-3.5 sm:h-4 sm:w-4" />
                    </Button>
                    <Button 
                        type="button" 
                        variant="ghost" 
                        size="icon" 
                        className="min-h-[44px] min-w-[38px] sm:min-h-8 sm:min-w-8 sm:h-8 sm:w-8 rounded-lg hover:bg-muted text-foreground cursor-pointer shrink-0 flex items-center justify-center"
                        onClick={() => executeCommand("insertOrderedList")}
                        title="Lista Numerada"
                    >
                        <ListOrdered className="h-3.5 w-3.5 sm:h-4 sm:w-4" />
                    </Button>

                    <div className="h-4 w-[1px] bg-border mx-0.5 sm:mx-1 shrink-0" />

                    {/* Actions & Links */}
                    <Button 
                        type="button" 
                        variant="ghost" 
                        size="icon" 
                        className="min-h-[44px] min-w-[38px] sm:min-h-8 sm:min-w-8 sm:h-8 sm:w-8 rounded-lg hover:bg-muted text-foreground cursor-pointer shrink-0 flex items-center justify-center"
                        onClick={handleAddLink}
                        title="Inserir Link"
                    >
                        <LinkIcon className="h-3.5 w-3.5 sm:h-4 sm:w-4" />
                    </Button>
                    <Button 
                        type="button" 
                        variant="ghost" 
                        size="icon" 
                        className="min-h-[44px] min-w-[38px] sm:min-h-8 sm:min-w-8 sm:h-8 sm:w-8 rounded-lg hover:bg-muted text-foreground cursor-pointer shrink-0 flex items-center justify-center"
                        onClick={() => executeCommand("removeFormat")}
                        title="Limpar Formatação"
                    >
                        <Eraser className="h-3.5 w-3.5 sm:h-4 sm:w-4" />
                    </Button>

                    <div className="h-4 w-[1px] bg-border mx-0.5 sm:mx-1 shrink-0" />

                    {/* Undo / Redo */}
                    <Button 
                        type="button" 
                        variant="ghost" 
                        size="icon" 
                        className="min-h-[44px] min-w-[38px] sm:min-h-8 sm:min-w-8 sm:h-8 sm:w-8 rounded-lg hover:bg-muted text-foreground cursor-pointer shrink-0 flex items-center justify-center"
                        onClick={() => executeCommand("undo")}
                        title="Desfazer"
                    >
                        <Undo className="h-3.5 w-3.5 sm:h-4 sm:w-4" />
                    </Button>
                    <Button 
                        type="button" 
                        variant="ghost" 
                        size="icon" 
                        className="min-h-[44px] min-w-[38px] sm:min-h-8 sm:min-w-8 sm:h-8 sm:w-8 rounded-lg hover:bg-muted text-foreground cursor-pointer shrink-0 flex items-center justify-center"
                        onClick={() => executeCommand("redo")}
                        title="Refazer"
                    >
                        <Redo className="h-3.5 w-3.5 sm:h-4 sm:w-4" />
                    </Button>
                </div>
            ) : (
                <div className="p-2.5 px-3 rounded-xl bg-muted/25 border border-border/60 text-xs text-muted-foreground flex items-center justify-between gap-2 shrink-0">
                    <div className="flex items-center gap-2 min-w-0">
                        <Code2 className="h-4 w-4 text-primary shrink-0" />
                        <span className="truncate">
                            Cole aqui o HTML convertido externamente (tabelas, títulos, parágrafos). Ao alternar para "Visual", você verá a prévia formatada.
                        </span>
                    </div>
                    <span className="text-[11px] font-mono opacity-70 shrink-0 hidden sm:inline">
                        HTML Fonte
                    </span>
                </div>
            )}

            {/* Editor Workspace */}
            <div className="flex-1 flex flex-col min-h-0 relative">
                {editorMode === "visual" ? (
                    <div 
                        ref={setEditorRef}
                        contentEditable
                        onPaste={handlePaste}
                        className="flex-1 overflow-y-auto border border-border/80 rounded-2xl p-4 sm:p-5 bg-card/60 focus:outline-none focus:ring-2 focus:ring-primary/20 text-foreground dark:text-zinc-100 prose-editor scrollbar-thin"
                        data-placeholder="Escreva suas anotações ou textos aqui..."
                        style={{ outline: "none" }}
                    />
                ) : (
                    <textarea
                        value={htmlSource}
                        onChange={(e) => setHtmlSource(e.target.value)}
                        placeholder="Cole seu código HTML aqui... (ex: <h2>Introdução</h2>, <p>Parágrafo...</p>, <table>...</table>)"
                        spellCheck={false}
                        className="flex-1 w-full h-full p-4 sm:p-5 font-mono text-xs sm:text-sm bg-card/80 border border-border/80 rounded-2xl focus:outline-none focus:ring-2 focus:ring-primary/20 text-foreground resize-none leading-relaxed custom-scrollbar placeholder:text-muted-foreground/45"
                    />
                )}
            </div>
        </div>
    );

    const editorFooter = (
        <div className="flex flex-col-reverse sm:flex-row sm:items-center justify-between gap-2.5 sm:gap-3 pt-3 border-t border-border/40 shrink-0">
            <div>
                {onDelete && (
                    <Button 
                        type="button" 
                        variant="ghost" 
                        onClick={handleDelete}
                        className="rounded-full px-4 min-h-[44px] h-11 text-sm font-medium text-destructive hover:bg-destructive/10 hover:text-destructive gap-2 cursor-pointer w-full sm:w-auto"
                        disabled={saving || deleting}
                    >
                        <Trash2 className="h-4 w-4" />
                        <span>Excluir Anotação</span>
                    </Button>
                )}
            </div>
            <div className="flex items-center justify-end gap-2 w-full sm:w-auto">
                <Button 
                    type="button" 
                    variant="ghost" 
                    onClick={onClose}
                    className="rounded-full px-4 sm:px-5 min-h-[44px] h-11 text-sm font-medium cursor-pointer"
                    disabled={saving || deleting}
                >
                    {inline ? "Ocultar" : "Cancelar"}
                </Button>
                <Button 
                    type="button" 
                    onClick={handleSave}
                    className="rounded-full px-5 sm:px-6 min-h-[44px] h-11 text-sm font-semibold gap-2 shadow-md cursor-pointer flex-1 sm:flex-initial"
                    disabled={saving || deleting || loadingContent}
                >
                    {saving ? (
                        <>
                            <Loader2 className="h-4 w-4 animate-spin" />
                            Salvando...
                        </>
                    ) : (
                        <>
                            <Save className="h-4 w-4" />
                            {saveButtonText}
                        </>
                    )}
                </Button>
            </div>
        </div>
    );

    if (inline) {
        if (!isOpen) return null;
        return (
            <div className={cn("flex flex-col h-full bg-card/95 backdrop-blur-sm border border-border/70 rounded-2xl sm:rounded-3xl p-4 sm:p-5 overflow-hidden shadow-lg relative min-h-[450px]", className)}>
                {editorStyles}
                <div className="flex items-center justify-between pb-2.5 border-b border-border/40 shrink-0">
                    <div className="flex items-center gap-2.5 min-w-0">
                        <div className="w-8 h-8 rounded-xl bg-primary/10 flex items-center justify-center shrink-0 text-primary">
                            <StickyNote className="w-4 h-4" />
                        </div>
                        <div className="min-w-0">
                            <h4 className="font-bold text-sm sm:text-base text-foreground truncate">
                                {modalTitle || (mode === "note" ? "Minhas Anotações" : "Editor de Texto")}
                            </h4>
                            <p className="text-[11px] sm:text-xs text-muted-foreground truncate">
                                {modalDescription || (mode === "note" ? "Anotações salvas junto ao material." : "Escreva e formate seu texto.")}
                            </p>
                        </div>
                    </div>
                    <Button
                        type="button"
                        variant="ghost"
                        size="icon"
                        onClick={onClose}
                        className="h-8 w-8 rounded-full text-muted-foreground hover:text-foreground shrink-0 cursor-pointer min-h-[44px] min-w-[44px]"
                        title="Fechar anotações"
                    >
                        <X className="w-4 h-4" />
                    </Button>
                </div>
                {editorBody}
                {editorFooter}
            </div>
        );
    }

    return (
        <Dialog open={isOpen} onOpenChange={(open) => { if (!open) onClose(); }}>
            <DialogContent size="2xl" className="sm:max-w-5xl md:max-w-6xl w-[95vw] h-[90dvh] bg-card border-border shadow-2xl rounded-3xl flex flex-col p-6 overflow-hidden">
                {editorStyles}
                <DialogHeader className="flex flex-row justify-between items-center pr-6 pb-2 border-b border-border/40 shrink-0">
                    <div>
                        <DialogTitle className="text-xl font-bold text-foreground">
                            {modalTitle || (mode === "note" ? "Minhas Anotações" : (initialData ? "Editar Texto" : "Escrever Novo Texto"))}
                        </DialogTitle>
                        <DialogDescription className="text-xs text-muted-foreground">
                            {modalDescription || (mode === "note" 
                                ? "Suas anotações pessoais são privadas e salvas no formato Markdown." 
                                : "Escreva e formate seu texto ou cole código HTML exportado por fora.")}
                        </DialogDescription>
                    </div>
                </DialogHeader>
                {editorBody}
                {editorFooter}
            </DialogContent>
        </Dialog>
    );
}
