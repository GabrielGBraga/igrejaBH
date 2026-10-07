import React, { useState, useEffect } from "react";
import { BookOpenIcon } from "lucide-react";
import { Spinner } from "@/components/ui/spinner";

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
                console.error("Error loading markdown:", err);
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

    let frontmatter: string[] = [];
    let markdownBody = content;

    const normalizedContent = content.replace(/\r\n/g, "\n");
    if (normalizedContent.startsWith("---")) {
        const secondDashIndex = normalizedContent.indexOf("\n---", 3);
        if (secondDashIndex !== -1) {
            const fmPart = normalizedContent.slice(0, secondDashIndex + 4);
            frontmatter = fmPart
                .split("\n")
                .filter((_, idx, arr) => idx > 0 && idx < arr.length - 1)
                .map((line) => line.trimEnd());
            markdownBody = normalizedContent.slice(secondDashIndex + 4);
        }
    }

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
        <div className="space-y-4 text-foreground dark:text-zinc-300 leading-relaxed font-sans max-h-[65vh] overflow-y-auto pr-3 scrollbar-thin">
            {frontmatter.length > 0 && (
                <div className="bg-muted/40 border border-border/80 rounded-2xl p-4 mb-4 text-xs font-mono space-y-1.5 opacity-90">
                    <div className="text-[10px] font-bold text-muted-foreground uppercase tracking-wider border-b border-border/40 pb-1 mb-2 select-none">
                        Propriedades / Metadados
                    </div>
                    {frontmatter.map((line, fIdx) => (
                        <div key={fIdx} className="text-muted-foreground/90 dark:text-zinc-400">
                            {line}
                        </div>
                    ))}
                </div>
            )}

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
                                    <span>Bíblia</span>
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
                            className="text-center text-muted-foreground dark:text-zinc-400 text-sm leading-relaxed"
                        >
                            {parseInlineMarkdown(centerMatch[1])}
                        </p>
                    );
                }
                if (justifyMatch) {
                    return (
                        <p
                            key={idx}
                            className="text-justify text-muted-foreground dark:text-zinc-400 text-sm leading-relaxed"
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
                        className="text-muted-foreground dark:text-zinc-400 text-sm leading-relaxed"
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
