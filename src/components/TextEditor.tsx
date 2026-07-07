import React, { useState, useEffect, useRef } from "react";
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
    AlignLeft,
    AlignCenter,
    AlignJustify
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

interface TextEditorProps {
    isOpen: boolean;
    onClose: () => void;
    onSave: (data: { title: string; description: string; markdownContent: string }) => Promise<void>;
    initialData?: {
        id?: string;
        title: string;
        description: string;
        url?: string;
    } | null;
}

export function TextEditor({ isOpen, onClose, onSave, initialData }: TextEditorProps) {
    const [title, setTitle] = useState("");
    const [description, setDescription] = useState("");
    const [loadingContent, setLoadingContent] = useState(false);
    const [saving, setSaving] = useState(false);
    const editorRef = useRef<HTMLDivElement>(null);

    // Reset fields or fetch content on open/change of initialData
    useEffect(() => {
        if (!isOpen) return;

        if (initialData) {
            setTitle(initialData.title);
            setDescription(initialData.description || "");
            
            if (initialData.url) {
                setLoadingContent(true);
                fetch(initialData.url)
                    .then(res => {
                        if (!res.ok) throw new Error("Failed to load text content");
                        return res.text();
                    })
                    .then(mdText => {
                        const html = markdownToHtml(mdText);
                        if (editorRef.current) {
                            editorRef.current.innerHTML = html;
                        }
                    })
                    .catch(err => {
                        console.error("Error loading markdown:", err);
                        toast.error("Não foi possível carregar o conteúdo do texto.");
                        if (editorRef.current) {
                            editorRef.current.innerHTML = "<p><br></p>";
                        }
                    })
                    .finally(() => {
                        setLoadingContent(false);
                    });
            } else {
                if (editorRef.current) {
                    editorRef.current.innerHTML = "<p><br></p>";
                }
            }
        } else {
            setTitle("");
            setDescription("");
            if (editorRef.current) {
                editorRef.current.innerHTML = "<p><br></p>";
            }
        }
    }, [isOpen, initialData]);

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

    // Paste event handler to strip all formatting styles that mess with layout/themes (like background-color: white)
    const handlePaste = (e: React.ClipboardEvent<HTMLDivElement>) => {
        e.preventDefault();
        const html = e.clipboardData.getData("text/html");
        const text = e.clipboardData.getData("text/plain");

        if (html) {
            const tempDiv = document.createElement("div");
            tempDiv.innerHTML = html;

            // Strip style, colors, background-color, fonts, font-sizes, keeping structures (bold, links, lists)
            const cleanNode = (node: Node) => {
                if (node.nodeType === Node.ELEMENT_NODE) {
                    const element = node as HTMLElement;
                    element.removeAttribute("style");
                    element.removeAttribute("class");
                    element.removeAttribute("face");
                    element.removeAttribute("size");
                    element.removeAttribute("color");

                    // Recursively clean children
                    for (let i = 0; i < element.childNodes.length; i++) {
                        cleanNode(element.childNodes[i]);
                    }
                }
            };

            for (let i = 0; i < tempDiv.childNodes.length; i++) {
                cleanNode(tempDiv.childNodes[i]);
            }

            // Insert cleaned HTML at cursor
            const selection = window.getSelection();
            if (selection && selection.rangeCount > 0) {
                const range = selection.getRangeAt(0);
                range.deleteContents();

                const fragment = range.createContextualFragment(tempDiv.innerHTML);
                range.insertNode(fragment);

                // Collapse range to end and select
                range.collapse(false);
                selection.removeAllRanges();
                selection.addRange(range);
            }
        } else if (text) {
            // Paste as plain text
            document.execCommand("insertText", false, text);
        }
    };

    const handleSave = async () => {
        if (!title.trim()) {
            toast.error("O título é obrigatório.");
            return;
        }

        const editorHTML = editorRef.current?.innerHTML || "";
        const markdown = htmlToMarkdown(editorHTML);

        try {
            setSaving(true);
            await onSave({
                title: title.trim(),
                description: description.trim(),
                markdownContent: markdown
            });
            onClose();
        } catch (err: any) {
            console.error("Error saving text in editor:", err);
            toast.error(err.message || "Erro ao salvar o texto.");
        } finally {
            setSaving(false);
        }
    };

    return (
        <Dialog open={isOpen} onOpenChange={(open) => { if (!open) onClose(); }}>
            <DialogContent className="sm:max-w-5xl md:max-w-6xl w-[95vw] h-[90vh] bg-card border-border shadow-2xl rounded-3xl flex flex-col p-6 overflow-hidden">
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
                    .prose-editor blockquote .blockquote-badge svg {
                        stroke: var(--primary);
                    }
                    .prose-editor ul { list-style-type: disc; padding-left: 1.5rem; margin-bottom: 0.75rem; }
                    .prose-editor ol { list-style-type: decimal; padding-left: 1.5rem; margin-bottom: 0.75rem; }
                    .prose-editor li { font-size: 0.875rem; color: inherit; opacity: 0.9; margin-top: 0.25rem; }
                    .prose-editor a { color: var(--primary); text-decoration: underline; font-weight: 500; }
                    .prose-editor code { font-family: monospace; font-size: 0.825rem; background-color: var(--muted); padding: 0.125rem 0.25rem; border-radius: 0.25rem; border: 1px solid var(--border); }
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
                    .prose-editor .editor-properties-block .yaml-line {
                        margin-bottom: 0.25rem;
                    }
                    .prose-editor:empty::before {
                        content: attr(placeholder);
                        color: inherit;
                        opacity: 0.4;
                        cursor: text;
                    }
                `}</style>

                <DialogHeader className="flex flex-row justify-between items-center pr-6 pb-2 border-b border-border/40">
                    <div>
                        <DialogTitle className="text-xl font-bold text-foreground">
                            {initialData ? "Editar Texto" : "Escrever Novo Texto"}
                        </DialogTitle>
                        <DialogDescription className="text-xs text-muted-foreground">
                            Escreva e formate seu texto. Ele será salvo automaticamente no formato Markdown.
                        </DialogDescription>
                    </div>
                </DialogHeader>

                <div className="flex-1 flex flex-col gap-4 py-4 overflow-hidden relative">
                    {loadingContent && (
                        <div className="absolute inset-0 bg-background/80 backdrop-blur-[2px] z-[100] flex flex-col justify-center items-center gap-3 rounded-2xl">
                            <Loader2 className="h-8 w-8 animate-spin text-primary" />
                            <span className="text-sm text-muted-foreground">Carregando conteúdo...</span>
                        </div>
                    )}
                        {/* Title & Description Fields */}
                        <div className="grid grid-cols-1 md:grid-cols-3 gap-3">
                            <div className="md:col-span-1">
                                <Field>
                                    <FieldLabel htmlFor="editor-title" className="text-xs font-semibold">Título do Texto*</FieldLabel>
                                    <Input 
                                        id="editor-title" 
                                        placeholder="Ex: Guia de Oração Semanal" 
                                        value={title} 
                                        onChange={(e) => setTitle(e.target.value)}
                                        className="rounded-md h-10 border-border bg-background focus-visible:ring-2 focus-visible:ring-primary/20 focus-visible:border-primary/60"
                                        maxLength={100}
                                    />
                                </Field>
                            </div>
                            <div className="md:col-span-2">
                                <Field>
                                    <FieldLabel htmlFor="editor-desc" className="text-xs font-semibold">Breve Descrição / Resumo</FieldLabel>
                                    <Input 
                                        id="editor-desc" 
                                        placeholder="Sobre o que fala este texto?" 
                                        value={description} 
                                        onChange={(e) => setDescription(e.target.value)}
                                        className="rounded-md h-10 border-border bg-background focus-visible:ring-2 focus-visible:ring-primary/20 focus-visible:border-primary/60"
                                        maxLength={250}
                                    />
                                </Field>
                            </div>
                        </div>

                        {/* Formatting Toolbar */}
                        <div className="flex flex-wrap items-center gap-1 p-1 bg-muted/30 border border-border/60 rounded-xl">
                            {/* Inline Formats */}
                            <Button 
                                type="button" 
                                variant="ghost" 
                                size="icon" 
                                className="h-8 w-8 rounded-lg hover:bg-muted text-foreground cursor-pointer"
                                onClick={() => executeCommand("bold")}
                                title="Negrito"
                            >
                                <Bold className="h-4 w-4" />
                            </Button>
                            <Button 
                                type="button" 
                                variant="ghost" 
                                size="icon" 
                                className="h-8 w-8 rounded-lg hover:bg-muted text-foreground cursor-pointer"
                                onClick={() => executeCommand("italic")}
                                title="Itálico"
                            >
                                <Italic className="h-4 w-4" />
                            </Button>
                            <Button 
                                type="button" 
                                variant="ghost" 
                                size="icon" 
                                className="h-8 w-8 rounded-lg hover:bg-muted text-foreground cursor-pointer"
                                onClick={() => executeCommand("underline")}
                                title="Sublinhado"
                            >
                                <Underline className="h-4 w-4" />
                            </Button>

                            <div className="h-4 w-[1px] bg-border mx-1" />

                            {/* Headings */}
                            <Button 
                                type="button" 
                                variant="ghost" 
                                size="icon" 
                                className="h-8 w-8 rounded-lg hover:bg-muted text-foreground cursor-pointer"
                                onClick={() => executeCommand("formatBlock", "<h1>")}
                                title="Título 1"
                            >
                                <Heading1 className="h-4 w-4" />
                            </Button>
                            <Button 
                                type="button" 
                                variant="ghost" 
                                size="icon" 
                                className="h-8 w-8 rounded-lg hover:bg-muted text-foreground cursor-pointer"
                                onClick={() => executeCommand("formatBlock", "<h2>")}
                                title="Título 2"
                            >
                                <Heading2 className="h-4 w-4" />
                            </Button>
                            <Button 
                                type="button" 
                                variant="ghost" 
                                size="icon" 
                                className="h-8 w-8 rounded-lg hover:bg-muted text-foreground cursor-pointer"
                                onClick={() => executeCommand("formatBlock", "<h3>")}
                                title="Título 3"
                            >
                                <Heading3 className="h-4 w-4" />
                            </Button>
                            <Button 
                                type="button" 
                                variant="ghost" 
                                size="icon" 
                                className="h-8 w-8 rounded-lg hover:bg-muted text-foreground cursor-pointer"
                                onClick={() => executeCommand("formatBlock", "<h4>")}
                                title="Subtítulo"
                            >
                                <Heading4 className="h-4 w-4 text-muted-foreground" />
                            </Button>
                            <Button 
                                type="button" 
                                variant="ghost" 
                                className="h-8 px-2 text-xs font-semibold rounded-lg hover:bg-muted text-foreground cursor-pointer"
                                onClick={() => executeCommand("formatBlock", "<p>")}
                                title="Texto Normal"
                            >
                                Normal
                            </Button>

                            <div className="h-4 w-[1px] bg-border mx-1" />

                            {/* Alignments */}
                            <Button 
                                type="button" 
                                variant="ghost" 
                                size="icon" 
                                className="h-8 w-8 rounded-lg hover:bg-muted text-foreground cursor-pointer"
                                onClick={() => executeCommand("justifyLeft")}
                                title="Alinhar à Esquerda"
                            >
                                <AlignLeft className="h-4 w-4" />
                            </Button>
                            <Button 
                                type="button" 
                                variant="ghost" 
                                size="icon" 
                                className="h-8 w-8 rounded-lg hover:bg-muted text-foreground cursor-pointer"
                                onClick={() => executeCommand("justifyCenter")}
                                title="Centralizar"
                            >
                                <AlignCenter className="h-4 w-4" />
                            </Button>
                            <Button 
                                type="button" 
                                variant="ghost" 
                                size="icon" 
                                className="h-8 w-8 rounded-lg hover:bg-muted text-foreground cursor-pointer"
                                onClick={() => executeCommand("justifyFull")}
                                title="Justificar"
                            >
                                <AlignJustify className="h-4 w-4" />
                            </Button>

                            <div className="h-4 w-[1px] bg-border mx-1" />

                            {/* Blocks & Lists */}
                            <Button 
                                type="button" 
                                variant="ghost" 
                                size="icon" 
                                className="h-8 w-8 rounded-lg hover:bg-muted text-foreground cursor-pointer"
                                onClick={() => executeCommand("formatBlock", "<blockquote>")}
                                title="Citação"
                            >
                                <Quote className="h-4 w-4" />
                            </Button>
                            <Button 
                                type="button" 
                                variant="ghost" 
                                size="icon" 
                                className="h-8 w-8 rounded-lg hover:bg-muted text-foreground cursor-pointer"
                                onClick={() => executeCommand("insertUnorderedList")}
                                title="Lista com Marcadores"
                            >
                                <List className="h-4 w-4" />
                            </Button>
                            <Button 
                                type="button" 
                                variant="ghost" 
                                size="icon" 
                                className="h-8 w-8 rounded-lg hover:bg-muted text-foreground cursor-pointer"
                                onClick={() => executeCommand("insertOrderedList")}
                                title="Lista Numerada"
                            >
                                <ListOrdered className="h-4 w-4" />
                            </Button>

                            <div className="h-4 w-[1px] bg-border mx-1" />

                            {/* Actions & Links */}
                            <Button 
                                type="button" 
                                variant="ghost" 
                                size="icon" 
                                className="h-8 w-8 rounded-lg hover:bg-muted text-foreground cursor-pointer"
                                onClick={handleAddLink}
                                title="Inserir Link"
                            >
                                <LinkIcon className="h-4 w-4" />
                            </Button>
                            <Button 
                                type="button" 
                                variant="ghost" 
                                size="icon" 
                                className="h-8 w-8 rounded-lg hover:bg-muted text-foreground cursor-pointer"
                                onClick={() => executeCommand("removeFormat")}
                                title="Limpar Formatação"
                            >
                                <Eraser className="h-4 w-4" />
                            </Button>

                            <div className="h-4 w-[1px] bg-border mx-1" />

                            {/* Undo / Redo */}
                            <Button 
                                type="button" 
                                variant="ghost" 
                                size="icon" 
                                className="h-8 w-8 rounded-lg hover:bg-muted text-foreground cursor-pointer"
                                onClick={() => executeCommand("undo")}
                                title="Desfazer"
                            >
                                <Undo className="h-4 w-4" />
                            </Button>
                            <Button 
                                type="button" 
                                variant="ghost" 
                                size="icon" 
                                className="h-8 w-8 rounded-lg hover:bg-muted text-foreground cursor-pointer"
                                onClick={() => executeCommand("redo")}
                                title="Refazer"
                            >
                                <Redo className="h-4 w-4" />
                            </Button>
                        </div>

                        {/* Editor Workspace */}
                        <div className="flex-1 flex flex-col min-h-0 relative">
                            <div 
                                ref={editorRef}
                                contentEditable
                                onPaste={handlePaste}
                                className="flex-1 overflow-y-auto border border-border/80 rounded-2xl p-6 bg-card/60 focus:outline-none focus:ring-2 focus:ring-primary/20 text-foreground dark:text-zinc-100 prose-editor scrollbar-thin"
                                {...{ placeholder: "Escreva seu texto aqui..." } as any}
                                style={{ outline: "none" }}
                            />
                        </div>
                    </div>

                {/* Footer Controls */}
                <div className="flex justify-end gap-2 pt-4 border-t border-border/40">
                    <Button 
                        type="button" 
                        variant="ghost" 
                        onClick={onClose}
                        className="rounded-full px-5 h-10 text-sm font-medium"
                        disabled={saving}
                    >
                        Cancelar
                    </Button>
                    <Button 
                        type="button" 
                        onClick={handleSave}
                        className="rounded-full px-6 h-10 text-sm font-semibold gap-2 shadow-md"
                        disabled={saving || loadingContent}
                    >
                        {saving ? (
                            <>
                                <Loader2 className="h-4 w-4 animate-spin" />
                                Salvando...
                            </>
                        ) : (
                            <>
                                <Save className="h-4 w-4" />
                                Salvar Texto
                            </>
                        )}
                    </Button>
                </div>
            </DialogContent>
        </Dialog>
    );
}

/**
 * Bidirectional parsing helpers: Markdown <-> HTML
 */

function escapeHtml(text: string): string {
    return text
        .replace(/&/g, "&amp;")
        .replace(/</g, "&lt;")
        .replace(/>/g, "&gt;")
        .replace(/"/g, "&quot;")
        .replace(/'/g, "&#039;");
}

function parseInlineMarkdownToHtml(text: string): string {
    const tokenRegex = /(\*\*.*?\*\*|`.*?`|\[.*?\]\(.*?\))/g;
    const parts = text.split(tokenRegex);
    return parts.map(part => {
        if (part.startsWith("**") && part.endsWith("**")) {
            return `<strong>${escapeHtml(part.slice(2, -2))}</strong>`;
        }
        if (part.startsWith("`") && part.endsWith("`")) {
            return `<code class="px-1.5 py-0.5 rounded bg-muted font-mono text-xs border border-border">${escapeHtml(part.slice(1, -1))}</code>`;
        }
        if (part.startsWith("[") && part.includes("](")) {
            const closeBracket = part.indexOf("]");
            const label = part.slice(1, closeBracket);
            const url = part.slice(closeBracket + 2, -1);
            return `<a href="${escapeHtml(url)}" target="_blank" rel="noopener noreferrer" class="text-primary hover:underline font-medium">${escapeHtml(label)}</a>`;
        }
        return escapeHtml(part);
    }).join("");
}

export function markdownToHtml(markdown: string): string {
    let html = "";
    let markdownBody = markdown;
    let frontmatterContent = "";

    // Normalize line endings
    const normalizedMarkdown = markdown.replace(/\r\n/g, "\n");

    // Check if markdown starts with YAML frontmatter
    if (normalizedMarkdown.startsWith("---")) {
        const secondDashIndex = normalizedMarkdown.indexOf("\n---", 3);
        if (secondDashIndex !== -1) {
            frontmatterContent = normalizedMarkdown.slice(0, secondDashIndex + 4);
            markdownBody = normalizedMarkdown.slice(secondDashIndex + 4);
        }
    }

    if (frontmatterContent) {
        // Extract the raw lines of frontmatter between the dashes
        const yamlLines = frontmatterContent.split("\n")
            .filter((_, idx, arr) => idx > 0 && idx < arr.length - 1);
        
        html += `<div class="editor-properties-block" contenteditable="false">`;
        html += `<div class="properties-header">`;
        html += `<span class="properties-title">Propriedades / Metadados</span>`;
        html += `</div>`;
        html += `<div class="properties-body" contenteditable="true">`;
        
        for (const line of yamlLines) {
            html += `<div class="yaml-line">${escapeHtml(line)}</div>`;
        }
        
        html += `</div>`;
        html += `</div>`;
    }

    const lines = markdownBody.split("\n");
    let insideList = false;
    let listType = ""; // "ul" or "ol"
    let insideCode = false;
    let insideBlockquote = false;
    let blockquoteHasContent = false;

    for (let i = 0; i < lines.length; i++) {
        const line = lines[i];
        const trimmed = line.trim();

        // Code block toggle
        if (trimmed.startsWith("```")) {
            if (insideCode) {
                html += "</pre>";
                insideCode = false;
            } else {
                html += "<pre>";
                insideCode = true;
            }
            continue;
        }

        if (insideCode) {
            html += escapeHtml(line) + "\n";
            continue;
        }

        // Check for HTML aligned tags
        const centerMatch = trimmed.match(/^<p align="center">(.*)<\/p>$/i);
        const justifyMatch = trimmed.match(/^<p align="justify">(.*)<\/p>$/i);
        const headingAlignMatch = trimmed.match(/^<h([1-4]) align="(center|justify)">(.*)<\/h\d>$/i);

        if (centerMatch) {
            html += `<p style="text-align: center;">${parseInlineMarkdownToHtml(centerMatch[1])}</p>`;
            continue;
        }
        if (justifyMatch) {
            html += `<p style="text-align: justify;">${parseInlineMarkdownToHtml(justifyMatch[1])}</p>`;
            continue;
        }
        if (headingAlignMatch) {
            const level = headingAlignMatch[1];
            const align = headingAlignMatch[2];
            const content = headingAlignMatch[3];
            html += `<h${level} style="text-align: ${align};">${parseInlineMarkdownToHtml(content)}</h${level}>`;
            continue;
        }

        // Blockquote item handling
        const isQuote = trimmed.startsWith(">");

        if (isQuote) {
            if (insideList) {
                html += `</${listType}>`;
                insideList = false;
            }
            
            const content = trimmed.startsWith("> ") 
                ? trimmed.slice(2) 
                : (trimmed === ">" ? "" : trimmed.slice(1));
            
            const contentTrimmed = content.trim();
            const lowerContent = contentTrimmed.toLowerCase();
            const isBibleMarker = lowerContent.startsWith("!bible") || lowerContent.startsWith("!bíblia");
            
            if (isBibleMarker) {
                const markerLength = lowerContent.startsWith("!bible") ? 6 : 7;
                if (!insideBlockquote) {
                    html += "<blockquote>";
                    insideBlockquote = true;
                    blockquoteHasContent = false;
                }
                html += `<div class="blockquote-badge font-sans flex items-center gap-1 text-primary font-semibold text-xs mb-2 select-none" contenteditable="false">`;
                html += `<svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" class="lucide lucide-book-open"><path d="M2 3h6a4 4 0 0 1 4 4v14a3 3 0 0 0-3-3H2z"/><path d="M22 3h-6a4 4 0 0 0-4 4v14a3 3 0 0 1 3-3h7z"/></svg>`;
                html += `<span>Bíblia</span>`;
                html += `</div>`;
                
                const rest = contentTrimmed.slice(markerLength).trim();
                if (rest) {
                    html += parseInlineMarkdownToHtml(rest);
                    blockquoteHasContent = true;
                }
                continue;
            }

            if (!insideBlockquote) {
                html += "<blockquote>";
                insideBlockquote = true;
                blockquoteHasContent = false;
            }

            if (blockquoteHasContent) {
                html += "<br />";
            }
            
            html += parseInlineMarkdownToHtml(content);
            blockquoteHasContent = true;
            continue;
        } else if (insideBlockquote) {
            html += "</blockquote>";
            insideBlockquote = false;
        }

        // List item handling
        const isBullet = trimmed.startsWith("- ") || trimmed.startsWith("* ");
        const isNumbered = /^\d+\.\s/.test(trimmed);

        if (isBullet || isNumbered) {
            const currentListType = isBullet ? "ul" : "ol";
            if (!insideList || listType !== currentListType) {
                if (insideList) {
                    html += `</${listType}>`;
                }
                html += `<${currentListType}>`;
                insideList = true;
                listType = currentListType;
            }

            const content = isBullet 
                ? trimmed.slice(2) 
                : trimmed.slice(trimmed.indexOf(".") + 1).trim();

            html += `<li>${parseInlineMarkdownToHtml(content)}</li>`;
            continue;
        } else if (insideList) {
            html += `</${listType}>`;
            insideList = false;
        }

        // Headings
        if (trimmed.startsWith("# ")) {
            html += `<h1>${parseInlineMarkdownToHtml(trimmed.slice(2))}</h1>`;
        } else if (trimmed.startsWith("## ")) {
            html += `<h2>${parseInlineMarkdownToHtml(trimmed.slice(3))}</h2>`;
        } else if (trimmed.startsWith("### ")) {
            html += `<h3>${parseInlineMarkdownToHtml(trimmed.slice(4))}</h3>`;
        } else if (trimmed.startsWith("#### ")) {
            html += `<h4>${parseInlineMarkdownToHtml(trimmed.slice(5))}</h4>`;
        } else if (trimmed === "---" || trimmed === "***") {
            html += "<hr />";
        } else if (trimmed === "") {
            html += "<p><br></p>";
        } else {
            html += `<p>${parseInlineMarkdownToHtml(line)}</p>`;
        }
    }

    if (insideList) {
        html += `</${listType}>`;
    }
    if (insideBlockquote) {
        html += "</blockquote>";
    }

    return html;
}

export function htmlToMarkdown(html: string): string {
    const tempDiv = document.createElement("div");
    tempDiv.innerHTML = html;
    
    const markdown = serializeElementToMarkdown(tempDiv);
    return markdown.replace(/\n{3,}/g, "\n\n").trim();
}

function serializeElementToMarkdown(node: Node): string {
    if (node.nodeType === Node.TEXT_NODE) {
        return node.nodeValue || "";
    }
    if (node.nodeType !== Node.ELEMENT_NODE) {
        return "";
    }

    const element = node as HTMLElement;
    
    if (element.classList.contains("blockquote-badge")) {
        return "!bible\n";
    }
    
    // Check alignment attributes or styles
    const align = element.getAttribute("align") || element.style.textAlign;
    let alignAttr = "";
    if (align === "center" || align === "justify") {
        alignAttr = ` align="${align}"`;
    }

    let childrenMarkdown = "";
    for (let i = 0; i < element.childNodes.length; i++) {
        childrenMarkdown += serializeElementToMarkdown(element.childNodes[i]);
    }

    switch (element.tagName) {
        case "H1":
            if (alignAttr) return `\n<h1${alignAttr}>${childrenMarkdown.trim()}</h1>\n`;
            return `\n# ${childrenMarkdown.trim()}\n`;
        case "H2":
            if (alignAttr) return `\n<h2${alignAttr}>${childrenMarkdown.trim()}</h2>\n`;
            return `\n## ${childrenMarkdown.trim()}\n`;
        case "H3":
            if (alignAttr) return `\n<h3${alignAttr}>${childrenMarkdown.trim()}</h3>\n`;
            return `\n### ${childrenMarkdown.trim()}\n`;
        case "H4":
            if (alignAttr) return `\n<h4${alignAttr}>${childrenMarkdown.trim()}</h4>\n`;
            return `\n#### ${childrenMarkdown.trim()}\n`;
        case "P":
            if (alignAttr) return `\n<p${alignAttr}>${childrenMarkdown.trim()}</p>\n`;
            return `\n${childrenMarkdown.trim()}\n`;
        case "STRONG":
        case "B":
            return `**${childrenMarkdown}**`;
        case "EM":
        case "I":
            return `*${childrenMarkdown}*`;
        case "U":
            return `<u>${childrenMarkdown}</u>`;
        case "A":
            const href = element.getAttribute("href") || "";
            return `[${childrenMarkdown}](${href})`;
        case "BLOCKQUOTE":
            return `\n> ${childrenMarkdown.trim().split("\n").join("\n> ")}\n`;
        case "UL":
            return `\n${childrenMarkdown.trim()}\n`;
        case "OL":
            return `\n${childrenMarkdown.trim()}\n`;
        case "LI":
            const parent = element.parentElement;
            if (parent && parent.tagName === "OL") {
                const items = Array.from(parent.children);
                const index = items.indexOf(element) + 1;
                return `${index}. ${childrenMarkdown.trim()}\n`;
            }
            return `- ${childrenMarkdown.trim()}\n`;
        case "BR":
            return "\n";
        case "DIV":
            if (element.classList.contains("editor-blockquote")) {
                return `\n> ${childrenMarkdown.trim().split("\n").join("\n> ")}\n`;
            }
            if (element.classList.contains("editor-properties-block")) {
                const bodyEl = element.querySelector(".properties-body") as HTMLElement;
                if (bodyEl) {
                    const linesText = bodyEl.innerText || bodyEl.textContent || "";
                    const rawLines = linesText.split("\n").map(l => l.trimEnd());
                    return `---\n${rawLines.join("\n")}\n---\n`;
                }
                return "";
            }
            if (alignAttr) {
                return `\n<p${alignAttr}>${childrenMarkdown.trim()}</p>\n`;
            }
            return `\n${childrenMarkdown.trim()}\n`;
        default:
            return childrenMarkdown;
    }
}
