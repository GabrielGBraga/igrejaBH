import { useState, useEffect } from "react";
import { Spinner } from "@/components/ui/spinner";
import { isHtmlContent, sanitizeHtmlContent, markdownToHtml } from "@/lib/markdownUtils";

interface MarkdownViewerProps {
    url?: string;
    content?: string;
}

export function MarkdownViewer({ url, content: directContent }: MarkdownViewerProps) {
    const [content, setContent] = useState(directContent || "");
    const [loading, setLoading] = useState(Boolean(url && !directContent));

    useEffect(() => {
        if (!url || directContent !== undefined) {
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

    const htmlContent = isHtmlContent(markdownBody)
        ? sanitizeHtmlContent(markdownBody)
        : markdownToHtml(markdownBody);

    return (
        <div className="space-y-4 text-foreground leading-relaxed font-sans max-h-[65vh] overflow-y-auto pr-3 scrollbar-thin">
            <style>{`
                .prose-study h1 { font-size: 1.5rem; font-weight: 800; color: inherit; margin-top: 1.5rem; margin-bottom: 0.75rem; border-bottom: 1px solid var(--border); padding-bottom: 0.375rem; }
                .prose-study h2 { font-size: 1.25rem; font-weight: 700; color: inherit; margin-top: 1.35rem; margin-bottom: 0.5rem; }
                .prose-study h3 { font-size: 1.1rem; font-weight: 600; color: inherit; margin-top: 1.15rem; margin-bottom: 0.35rem; }
                .prose-study h4, .prose-study h5, .prose-study h6 { font-size: 0.95rem; font-weight: 600; color: inherit; opacity: 0.85; margin-top: 1rem; margin-bottom: 0.25rem; }
                .prose-study p { font-size: 0.875rem; line-height: 1.65; color: inherit; opacity: 0.9; margin-bottom: 0.85rem; }
                .prose-study strong { font-weight: 700; color: inherit; }
                .prose-study em { font-style: italic; }
                .prose-study del, .prose-study s { text-decoration: line-through; opacity: 0.75; }
                .prose-study hr { border: none; border-top: 1px solid var(--border); margin: 1.5rem 0; }
                .prose-study blockquote { border-left: 4px solid var(--primary); padding-left: 1rem; padding-top: 0.5rem; padding-bottom: 0.5rem; margin: 1rem 0; font-style: italic; color: inherit; opacity: 0.85; background-color: color-mix(in srgb, var(--muted) 25%, transparent); border-radius: 0 0.5rem 0.5rem 0; }
                .prose-study ul { list-style-type: disc; padding-left: 1.5rem; margin-bottom: 0.85rem; }
                .prose-study ol { list-style-type: decimal; padding-left: 1.5rem; margin-bottom: 0.85rem; }
                .prose-study li { font-size: 0.875rem; color: inherit; opacity: 0.9; margin-top: 0.25rem; }
                .prose-study input[type="checkbox"] { margin-right: 0.5rem; vertical-align: middle; }
                .prose-study table { width: 100%; border-collapse: collapse; margin: 1rem 0; font-size: 0.875rem; }
                .prose-study th { background-color: var(--muted); border: 1px solid var(--border); padding: 0.5rem 0.75rem; font-weight: 600; text-align: left; }
                .prose-study td { border: 1px solid var(--border); padding: 0.5rem 0.75rem; opacity: 0.9; }
                .prose-study pre { background-color: var(--muted); padding: 0.875rem 1rem; border-radius: 0.75rem; font-family: monospace; font-size: 0.825rem; overflow-x: auto; border: 1px solid var(--border); margin: 1rem 0; }
                .prose-study pre code { background: transparent; padding: 0; border: none; font-size: inherit; }
                .prose-study code { font-family: monospace; font-size: 0.825rem; background-color: var(--muted); padding: 0.125rem 0.35rem; border-radius: 0.25rem; border: 1px solid var(--border); }
                .prose-study img { max-width: 100%; height: auto; border-radius: 0.375rem; display: inline-block; vertical-align: middle; margin: 0.25rem 0.25rem 0.25rem 0; }
                .prose-study a { color: var(--primary); text-decoration: underline; font-weight: 500; }
                .prose-study a img { vertical-align: middle; }
                .prose-study .blockquote-badge { display: inline-flex; align-items: center; gap: 0.375rem; color: var(--primary); font-weight: 600; font-size: 0.75rem; margin-bottom: 0.5rem; user-select: none; font-style: normal; }
                .prose-study [align="center"] { text-align: center; }
                .prose-study [align="justify"] { text-align: justify; }
                .prose-study [align="right"] { text-align: right; }
            `}</style>
            <div 
                className="prose-study"
                dangerouslySetInnerHTML={{ __html: htmlContent }}
            />
        </div>
    );
}
