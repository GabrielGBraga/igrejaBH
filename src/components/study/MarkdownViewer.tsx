import React, { useState, useEffect } from "react";
import { BookOpenIcon } from "lucide-react";
import { Spinner } from "@/components/ui/spinner";
import { isHtmlContent, sanitizeHtmlContent } from "@/lib/markdownUtils";

interface MarkdownViewerProps {
    url?: string;
    content?: string;
}

export function MarkdownViewer({ url, content: directContent }: MarkdownViewerProps) {
    const [content, setContent] = useState(directContent || "");
    const [loading, setLoading] = useState(Boolean(url && !directContent));

    useEffect(() => {
        if (!url || directContent) {
            if (directContent !== undefined) {
                setContent(directContent);
                setLoading(false);
            }
            return;
        }

        let isMounted = true;
        async function fetchMD() {
            try {
                setLoading(true);
                const res = await fetch(url!);
                const text = await res.text();
                if (isMounted) {
                    setContent(text);
                }
            } catch (err) {
                console.error("Error loading markdown / html:", err);
                if (isMounted) {
                    setContent("Não foi possível carregar o conteúdo deste texto.");
                }
            } finally {
                if (isMounted) {
                    setLoading(false);
                }
            }
        }

        fetchMD();

        return () => {
            isMounted = false;
        };
    }, [url, directContent]);

    if (loading) {
        return (
            <div className="flex justify-center items-center py-16">
                <Spinner className="h-6 w-6 text-primary" />
            </div>
        );
    }

    let markdownBody = content;

    const normalizedContent = content.replace(/\r\n/g, "\n");
    // Strip technical YAML frontmatter header if present
    if (normalizedContent.startsWith("---")) {
        const secondDashIndex = normalizedContent.indexOf("\n---", 3);
        if (secondDashIndex !== -1) {
            markdownBody = normalizedContent.slice(secondDashIndex + 4).trimStart();
        }
    }

    // 1. If content is rich HTML (or imported from external converter), render sanitized HTML directly
    if (isHtmlContent(markdownBody)) {
        const cleanHtml = sanitizeHtmlContent(markdownBody);
        return (
            <div className="space-y-4 text-foreground leading-relaxed font-sans max-h-[65vh] overflow-y-auto pr-3 scrollbar-thin">
                <style>{`
                    .prose-study h1 { font-size: 1.5rem; font-weight: 800; color: inherit; margin-top: 1.5rem; margin-bottom: 0.75rem; border-bottom: 1px solid var(--border); padding-bottom: 0.375rem; }
                    .prose-study h2 { font-size: 1.25rem; font-weight: 700; color: inherit; margin-top: 1.35rem; margin-bottom: 0.5rem; }
                    .prose-study h3 { font-size: 1.1rem; font-weight: 600; color: inherit; margin-top: 1.15rem; margin-bottom: 0.35rem; }
                    .prose-study h4, .prose-study h5, .prose-study h6 { font-size: 0.95rem; font-weight: 600; color: inherit; opacity: 0.75; margin-top: 1rem; margin-bottom: 0.25rem; }
                    .prose-study p { font-size: 0.875rem; line-height: 1.65; color: inherit; opacity: 0.9; margin-bottom: 0.85rem; }
                    .prose-study blockquote { border-left: 4px solid var(--primary); padding-left: 1rem; padding-top: 0.5rem; padding-bottom: 0.5rem; margin: 1rem 0; font-style: italic; color: inherit; opacity: 0.85; background-color: color-mix(in srgb, var(--muted) 25%, transparent); border-radius: 0 0.5rem 0.5rem 0; }
                    .prose-study ul { list-style-type: disc; padding-left: 1.5rem; margin-bottom: 0.85rem; }
                    .prose-study ol { list-style-type: decimal; padding-left: 1.5rem; margin-bottom: 0.85rem; }
                    .prose-study li { font-size: 0.875rem; color: inherit; opacity: 0.9; margin-top: 0.25rem; }
                    .prose-study table { width: 100%; border-collapse: collapse; margin: 1rem 0; font-size: 0.875rem; }
                    .prose-study th { background-color: var(--muted); border: 1px solid var(--border); padding: 0.5rem 0.75rem; font-weight: 600; text-align: left; }
                    .prose-study td { border: 1px solid var(--border); padding: 0.5rem 0.75rem; opacity: 0.9; }
                    .prose-study code { font-family: monospace; font-size: 0.825rem; background-color: var(--muted); padding: 0.125rem 0.35rem; border-radius: 0.25rem; border: 1px solid var(--border); }
                    .prose-study a { color: var(--primary); text-decoration: underline; font-weight: 500; }
                    .prose-study .blockquote-badge { display: inline-flex; align-items: center; gap: 0.375rem; color: var(--primary); font-weight: 600; font-size: 0.75rem; margin-bottom: 0.5rem; user-select: none; font-style: normal; }
                `}</style>
                <div 
                    className="prose-study"
                    dangerouslySetInnerHTML={{ __html: cleanHtml }}
                />
            </div>
        );
    }

    // 2. Otherwise, parse as standard line-by-line Markdown
    const lines = markdownBody.split("\n");
    let insideCode = false;

    // Preprocess lines to group consecutive blockquote lines
    const processedLines: Array<
        | { type: "blockquote"; lines: string[] }
        | { type: "normal"; text: string }
    > = [];

    for (let i = 0; i < lines.length; i++) {
        const line = lines[i];
        const trimmed = line.trim();

        if (trimmed.startsWith(">")) {
            const last = processedLines[processedLines.length - 1];
            if (last && last.type === "blockquote") {
                last.lines.push(line);
            } else {
                processedLines.push({ type: "blockquote", lines: [line] });
            }
        } else {
            processedLines.push({ type: "normal", text: line });
        }
    }

    return (
        <div className="space-y-4 text-foreground leading-relaxed font-sans max-h-[65vh] overflow-y-auto pr-3 scrollbar-thin">
            {processedLines.map((item, idx) => {
                if (item.type === "blockquote") {
                    let isBibleQuote = false;
                    const renderedLines: string[] = [];

                    for (const l of item.lines) {
                        const t = l.trim();
                        const contentText = t.startsWith("> ")
                            ? t.slice(2)
                            : t === ">"
                            ? ""
                            : t.slice(1);
                        const contentTrimmed = contentText.trim();
                        const lowerContent = contentTrimmed.toLowerCase();
                        const isBibleMarker =
                            lowerContent.startsWith("!bible") || lowerContent.startsWith("!bíblia");

                        if (isBibleMarker) {
                            isBibleQuote = true;
                            const markerLength = lowerContent.startsWith("!bible") ? 6 : 7;
                            const rest = contentTrimmed.slice(markerLength).trim();
                            if (rest) {
                                renderedLines.push(rest);
                            }
                        } else {
                            renderedLines.push(contentText);
                        }
                    }

                    return (
                        <blockquote
                            key={idx}
                            className="border-l-4 border-primary pl-4 py-3 italic text-muted-foreground bg-muted/20 rounded-r-md my-4"
                        >
                            {isBibleQuote && (
                                <div className="flex items-center gap-1.5 text-primary font-semibold text-xs mb-2 not-italic select-none">
                                    <BookOpenIcon className="h-3.5 w-3.5" />
                                    <span>Texto Bíblico</span>
                                </div>
                            )}
                            <div className="space-y-1">
                                {renderedLines.map((contentStr, lineIdx) => (
                                    <div key={lineIdx}>{parseInlineMarkdown(contentStr)}</div>
                                ))}
                            </div>
                        </blockquote>
                    );
                }

                const line = item.text;
                const trimmed = line.trim();

                // Code block toggle
                if (trimmed.startsWith("```")) {
                    insideCode = !insideCode;
                    return null;
                }

                if (insideCode) {
                    return (
                        <pre
                            key={idx}
                            className="bg-muted p-4 rounded-xl font-mono text-xs overflow-x-auto border border-border/40"
                        >
                            <code>{line}</code>
                        </pre>
                    );
                }

                // Check for HTML aligned tags
                const centerMatch = trimmed.match(/^<p align="center">(.*)<\/p>$/i);
                const justifyMatch = trimmed.match(/^<p align="justify">(.*)<\/p>$/i);
                const headingAlignMatch = trimmed.match(
                    /^<h([1-4]) align="(center|justify)">(.*)<\/h\d>$/i
                );

                if (centerMatch) {
                    return (
                        <p
                            key={idx}
                            className="text-center text-muted-foreground text-sm leading-relaxed"
                        >
                            {parseInlineMarkdown(centerMatch[1])}
                        </p>
                    );
                }
                if (justifyMatch) {
                    return (
                        <p
                            key={idx}
                            className="text-justify text-muted-foreground text-sm leading-relaxed"
                        >
                            {parseInlineMarkdown(justifyMatch[1])}
                        </p>
                    );
                }
                if (headingAlignMatch) {
                    const level = headingAlignMatch[1];
                    const align = headingAlignMatch[2];
                    const contentStr = headingAlignMatch[3];
                    const alignClass = align === "center" ? "text-center" : "text-justify";

                    if (level === "1")
                        return (
                            <h1
                                key={idx}
                                className={`text-xl font-extrabold text-foreground border-b border-border pb-1.5 mt-6 mb-3 ${alignClass}`}
                            >
                                {parseInlineMarkdown(contentStr)}
                            </h1>
                        );
                    if (level === "2")
                        return (
                            <h2
                                key={idx}
                                className={`text-lg font-bold text-foreground mt-5 mb-2 ${alignClass}`}
                            >
                                {parseInlineMarkdown(contentStr)}
                            </h2>
                        );
                    if (level === "3")
                        return (
                            <h3
                                key={idx}
                                className={`text-base font-semibold text-foreground mt-4 mb-1 ${alignClass}`}
                            >
                                {parseInlineMarkdown(contentStr)}
                            </h3>
                        );
                    if (level === "4")
                        return (
                            <h4
                                key={idx}
                                className={`text-sm font-semibold text-muted-foreground mt-3 mb-1 ${alignClass}`}
                            >
                                {parseInlineMarkdown(contentStr)}
                            </h4>
                        );
                }

                // Headings
                if (trimmed.startsWith("# ")) {
                    return (
                        <h1
                            key={idx}
                            className="text-xl font-extrabold text-foreground border-b border-border pb-1.5 mt-6 mb-3"
                        >
                            {parseInlineMarkdown(trimmed.slice(2))}
                        </h1>
                    );
                }
                if (trimmed.startsWith("## ")) {
                    return (
                        <h2
                            key={idx}
                            className="text-lg font-bold text-foreground mt-5 mb-2"
                        >
                            {parseInlineMarkdown(trimmed.slice(3))}
                        </h2>
                    );
                }
                if (trimmed.startsWith("### ")) {
                    return (
                        <h3
                            key={idx}
                            className="text-base font-semibold text-foreground mt-4 mb-1"
                        >
                            {parseInlineMarkdown(trimmed.slice(4))}
                        </h3>
                    );
                }
                if (trimmed.startsWith("#### ")) {
                    return (
                        <h4
                            key={idx}
                            className="text-sm font-semibold text-muted-foreground mt-3 mb-1"
                        >
                            {parseInlineMarkdown(trimmed.slice(5))}
                        </h4>
                    );
                }

                // Horizontal Rule
                if (trimmed === "---" || trimmed === "***") {
                    return <hr key={idx} className="my-6 border-border" />;
                }

                // List Items
                if (trimmed.startsWith("- ") || trimmed.startsWith("* ")) {
                    return (
                        <li key={idx} className="list-disc ml-6 mt-1 text-muted-foreground text-sm">
                            {parseInlineMarkdown(trimmed.slice(2))}
                        </li>
                    );
                }

                // Numbered lists
                if (/^\d+\.\s/.test(trimmed)) {
                    const dotIndex = trimmed.indexOf(".");
                    return (
                        <li key={idx} className="list-decimal ml-6 mt-1 text-muted-foreground text-sm">
                            {parseInlineMarkdown(trimmed.slice(dotIndex + 1).trim())}
                        </li>
                    );
                }

                // Empty line
                if (trimmed === "") {
                    return <div key={idx} className="h-1.5" />;
                }

                // Standard paragraph
                return (
                    <p
                        key={idx}
                        className="text-muted-foreground text-sm leading-relaxed"
                    >
                        {parseInlineMarkdown(line)}
                    </p>
                );
            })}
        </div>
    );
}

function parseInlineMarkdown(text: string): React.ReactNode[] {
    const tokenRegex = /(\*\*.*?\*\*|`.*?`|\[.*?\]\(.*?\))/g;
    const splitParts = text.split(tokenRegex);

    return splitParts.map((part, index) => {
        if (part.startsWith("**") && part.endsWith("**")) {
            return (
                <strong key={index} className="font-bold text-foreground">
                    {part.slice(2, -2)}
                </strong>
            );
        }
        if (part.startsWith("`") && part.endsWith("`")) {
            return (
                <code
                    key={index}
                    className="px-1.5 py-0.5 rounded bg-muted font-mono text-xs border border-border"
                >
                    {part.slice(1, -1)}
                </code>
            );
        }
        if (part.startsWith("[") && part.includes("](")) {
            const closeBracket = part.indexOf("]");
            const label = part.slice(1, closeBracket);
            const url = part.slice(closeBracket + 2, -1);
            return (
                <a
                    key={index}
                    href={url}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="text-primary hover:underline font-medium"
                >
                    {label}
                </a>
            );
        }
        return part;
    });
}
