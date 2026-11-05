import { marked } from "marked";

/**
 * Bidirectional parsing helpers: Markdown <-> HTML
 * Supports semantic HTML imported from external converters as well as standard CommonMark / GFM.
 */

export function escapeHtml(text: string): string {
    return text
        .replace(/&/g, "&amp;")
        .replace(/</g, "&lt;")
        .replace(/>/g, "&gt;")
        .replace(/"/g, "&quot;")
        .replace(/'/g, "&#039;");
}

/**
 * Checks whether the given string is primarily structured, complete HTML content
 * (e.g. imported from Word, LibreOffice, or an HTML template) rather than Markdown with embedded HTML.
 */
export function isHtmlContent(content: string): boolean {
    if (!content) return false;
    const trimmed = content.trim();
    if (
        trimmed.startsWith("<!DOCTYPE") || 
        trimmed.startsWith("<html") || 
        trimmed.startsWith("<body") ||
        trimmed.startsWith("<?xml")
    ) {
        return true;
    }

    // Only consider it pure HTML if it clearly begins and ends with matching root HTML tags (like <div>...</div> or <article>...</article>)
    // and doesn't contain markdown headers or markdown bullets at line start
    const startsWithHtmlTag = /^<([a-z1-6]+)(?:\s+[^>]*)?>/i.test(trimmed);
    const endsWithHtmlTag = /<\/[a-z1-6]+>$/i.test(trimmed);
    const hasMarkdownStructuralFeatures = /(^|\n)(#{1,6}\s|[-*+]\s|\d+\.\s|>\s|```)/m.test(trimmed);

    if (startsWithHtmlTag && endsWithHtmlTag && !hasMarkdownStructuralFeatures) {
        return true;
    }

    return false;
}

/**
 * Strips dangerous tags/attributes and cleans styles for theme & mobile compatibility
 */
export function sanitizeHtmlContent(html: string): string {
    if (typeof window === "undefined" || !html) {
        return html || "";
    }

    try {
        const parser = new DOMParser();
        const doc = parser.parseFromString(html, "text/html");

        // 1. Remove dangerous or non-content tags (keep input specifically for disabled task checkboxes)
        const unsafeTags = [
            "script", "style", "iframe", "object", "embed", "applet", 
            "meta", "link", "form", "button", "textarea", "select"
        ];
        unsafeTags.forEach(tag => {
            const elements = doc.querySelectorAll(tag);
            elements.forEach(el => el.remove());
        });

        // Retain only disabled task list checkboxes
        const inputs = doc.querySelectorAll("input");
        inputs.forEach(input => {
            if (input.type === "checkbox") {
                input.setAttribute("disabled", "true");
                input.setAttribute("aria-hidden", "true");
            } else {
                input.remove();
            }
        });

        // 2. Clean attributes on all remaining elements
        const allElements = doc.querySelectorAll("*");
        allElements.forEach(el => {
            const attrs = Array.from(el.attributes);
            for (const attr of attrs) {
                const name = attr.name.toLowerCase();
                const value = attr.value.trim().toLowerCase();

                // Remove inline JS event handlers
                if (name.startsWith("on")) {
                    el.removeAttribute(attr.name);
                    continue;
                }

                // Remove javascript: URIs
                if ((name === "href" || name === "src" || name === "action") && value.startsWith("javascript:")) {
                    el.removeAttribute(attr.name);
                    continue;
                }
            }

            // Clean inline styles that clash with dark/light theme (e.g. background: white; color: black)
            if (el.hasAttribute("style")) {
                const style = el.getAttribute("style") || "";
                const cleanedStyle = style
                    .replace(/color\s*:[^;]+;?/gi, "")
                    .replace(/background(-color)?\s*:[^;]+;?/gi, "")
                    .replace(/font-family\s*:[^;]+;?/gi, "")
                    .replace(/font-size\s*:[^;]+;?/gi, "")
                    .trim();

                if (cleanedStyle) {
                    el.setAttribute("style", cleanedStyle);
                } else {
                    el.removeAttribute("style");
                }
            }

            // Secure and style links
            if (el.tagName === "A") {
                el.setAttribute("target", "_blank");
                el.setAttribute("rel", "noopener noreferrer");
                el.classList.add("text-primary", "hover:underline", "font-medium");
            }

            // Responsive images & badges
            if (el.tagName === "IMG") {
                el.classList.add("max-w-full", "h-auto", "rounded-md", "inline-block", "align-middle");
                el.setAttribute("loading", "lazy");
            }
        });

        // 3. Make tables responsive by wrapping them in overflow-x-auto container
        const tables = doc.querySelectorAll("table");
        tables.forEach(table => {
            table.classList.add("w-full", "border-collapse", "text-sm");
            const parent = table.parentElement;
            if (!parent || !parent.classList.contains("overflow-x-auto")) {
                const wrapper = doc.createElement("div");
                wrapper.className = "overflow-x-auto my-4 max-w-full rounded-xl border border-border/70";
                table.parentNode?.insertBefore(wrapper, table);
                wrapper.appendChild(table);
            }
        });

        // 4. Enhance Bible markers in blockquotes if present
        const blockquotes = doc.querySelectorAll("blockquote");
        blockquotes.forEach(bq => {
            const text = bq.textContent || "";
            if (text.includes("!bible") || text.includes("!bíblia")) {
                bq.innerHTML = bq.innerHTML
                    .replace(/!bible/gi, "")
                    .replace(/!bíblia/gi, "");

                const badge = doc.createElement("div");
                badge.className = "blockquote-badge inline-flex items-center gap-1.5 text-primary font-semibold text-xs mb-2 not-italic select-none";
                badge.innerHTML = "<span>📖 Texto Bíblico</span>";
                bq.insertBefore(badge, bq.firstChild);
            }
        });

        return doc.body.innerHTML || "<p><br></p>";
    } catch (e) {
        console.error("Error sanitizing HTML content:", e);
        return html;
    }
}

/**
 * Format HTML with clean indentation and newlines for source-code editing
 */
export function formatHtmlForEditor(html: string): string {
    if (!html) return "";
    const formatted = html
        .replace(/>\s*</g, ">\n<")
        .replace(/(<p[^>]*>)/gi, "\n$1")
        .replace(/(<h[1-6][^>]*>)/gi, "\n\n$1")
        .replace(/(<\/h[1-6]>)/gi, "$1\n")
        .replace(/(<blockquote[^>]*>)/gi, "\n$1")
        .replace(/(<\/blockquote>)/gi, "$1\n")
        .replace(/(<table[^>]*>)/gi, "\n\n$1")
        .replace(/(<\/table>)/gi, "$1\n\n")
        .replace(/(<ul[^>]*>|<ol[^>]*>)/gi, "\n$1")
        .replace(/(<\/ul>|<\/ol>)/gi, "$1\n")
        .replace(/(<pre[^>]*>)/gi, "\n\n$1")
        .replace(/(<\/pre>)/gi, "$1\n\n")
        .replace(/\n{3,}/g, "\n\n")
        .trim();

    return formatted;
}

export function parseInlineMarkdownToHtml(text: string): string {
    if (!text) return "";
    try {
        return marked.parseInline(text, { gfm: true }) as string;
    } catch {
        return escapeHtml(text);
    }
}

export function markdownToHtml(markdown: string): string {
    if (!markdown) return "<p><br></p>";

    let markdownBody = markdown;
    let frontmatterHtml = "";

    // Normalize line endings
    const normalizedMarkdown = markdown.replace(/\r\n/g, "\n");

    // Check if markdown starts with YAML frontmatter
    if (normalizedMarkdown.startsWith("---")) {
        const secondDashIndex = normalizedMarkdown.indexOf("\n---", 3);
        if (secondDashIndex !== -1) {
            const frontmatterContent = normalizedMarkdown.slice(0, secondDashIndex + 4);
            markdownBody = normalizedMarkdown.slice(secondDashIndex + 4);

            const fmLines = frontmatterContent
                .split("\n")
                .filter((_, idx, arr) => idx > 0 && idx < arr.length - 1)
                .map(l => escapeHtml(l.trimEnd()))
                .join("<br>");

            frontmatterHtml = `<div class="editor-properties-block" contenteditable="false">
                <div class="properties-header">Propriedades / Metadados (Não editável)</div>
                <div class="properties-body">${fmLines}</div>
            </div>`;
        }
    }

    // If the body is already rich HTML, sanitize and return directly
    if (isHtmlContent(markdownBody)) {
        return frontmatterHtml + sanitizeHtmlContent(markdownBody);
    }

    try {
        const parsedHtml = marked.parse(markdownBody, {
            gfm: true,
            breaks: false
        }) as string;

        return frontmatterHtml + sanitizeHtmlContent(parsedHtml);
    } catch (e) {
        console.error("Error parsing markdown to HTML:", e);
        return frontmatterHtml + `<p>${escapeHtml(markdownBody)}</p>`;
    }
}

export function htmlToMarkdown(html: string): string {
    if (!html) return "";
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
    if (align === "center" || align === "justify" || align === "right") {
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
        case "H5":
            if (alignAttr) return `\n<h5${alignAttr}>${childrenMarkdown.trim()}</h5>\n`;
            return `\n##### ${childrenMarkdown.trim()}\n`;
        case "H6":
            if (alignAttr) return `\n<h6${alignAttr}>${childrenMarkdown.trim()}</h6>\n`;
            return `\n###### ${childrenMarkdown.trim()}\n`;
        case "P":
            if (alignAttr) return `\n<p${alignAttr}>${childrenMarkdown.trim()}</p>\n`;
            return `\n${childrenMarkdown.trim()}\n`;
        case "STRONG":
        case "B":
            return `**${childrenMarkdown}**`;
        case "EM":
        case "I":
            return `*${childrenMarkdown}*`;
        case "DEL":
        case "S":
        case "STRIKE":
            return `~~${childrenMarkdown}~~`;
        case "U":
            return `<u>${childrenMarkdown}</u>`;
        case "A": {
            const href = element.getAttribute("href") || "";
            return `[${childrenMarkdown}](${href})`;
        }
        case "BLOCKQUOTE":
            return `\n> ${childrenMarkdown.trim().split("\n").join("\n> ")}\n`;
        case "UL":
            return `\n${childrenMarkdown.trim()}\n`;
        case "OL":
            return `\n${childrenMarkdown.trim()}\n`;
        case "LI": {
            const parent = element.parentElement;
            if (parent && parent.tagName === "OL") {
                const items = Array.from(parent.children);
                const index = items.indexOf(element) + 1;
                return `${index}. ${childrenMarkdown.trim()}\n`;
            }
            return `- ${childrenMarkdown.trim()}\n`;
        }
        case "BR":
            return "\n";
        case "HR":
            return "\n\n---\n\n";
        case "TABLE":
            // Preserve table HTML directly as markdown natively supports embedded HTML tables
            return `\n\n${element.outerHTML}\n\n`;
        case "PRE":
            return `\n\n\`\`\`\n${element.textContent || ""}\n\`\`\`\n\n`;
        case "CODE":
            if (element.parentElement?.tagName === "PRE") {
                return element.textContent || "";
            }
            return `\`${element.textContent || ""}\``;
        case "IMG": {
            const alt = element.getAttribute("alt") || "";
            const src = element.getAttribute("src") || "";
            return `![${alt}](${src})`;
        }
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
