/**
 * Bidirectional parsing helpers: Markdown <-> HTML
 * Supports semantic HTML imported from external converters as well as standard Markdown.
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
 * Checks whether the given string is primarily structured HTML content
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

    // Check for typical HTML opening or block tags
    const htmlTagPattern = /<\s*(p|div|h[1-6]|table|thead|tbody|tr|td|th|ul|ol|li|blockquote|section|article|span|pre|code|hr|figure|figcaption)[^>]*>/i;
    return htmlTagPattern.test(trimmed);
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

        // 1. Remove dangerous or non-content tags
        const unsafeTags = [
            "script", "style", "iframe", "object", "embed", "applet", 
            "meta", "link", "form", "input", "button", "textarea", "select"
        ];
        unsafeTags.forEach(tag => {
            const elements = doc.querySelectorAll(tag);
            elements.forEach(el => el.remove());
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

            // Secure links
            if (el.tagName === "A") {
                el.setAttribute("target", "_blank");
                el.setAttribute("rel", "noopener noreferrer");
                el.classList.add("text-primary", "hover:underline", "font-medium");
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
        .replace(/\n{3,}/g, "\n\n")
        .trim();

    return formatted;
}

export function parseInlineMarkdownToHtml(text: string): string {
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

    let html = frontmatterHtml;
    const lines = markdownBody.split("\n");
    let insideBlockquote = false;

    for (let i = 0; i < lines.length; i++) {
        const rawLine = lines[i];
        const trimmed = rawLine.trim();

        // Handle blockquote grouping
        if (trimmed.startsWith(">")) {
            if (!insideBlockquote) {
                insideBlockquote = true;
                html += "<blockquote>";
            }
            
            const contentText = trimmed.startsWith("> ") ? trimmed.slice(2) : (trimmed === ">" ? "" : trimmed.slice(1));
            const contentTrimmed = contentText.trim();
            const lowerContent = contentTrimmed.toLowerCase();
            const isBibleMarker = lowerContent.startsWith("!bible") || lowerContent.startsWith("!bíblia");

            if (isBibleMarker) {
                html += `<div class="blockquote-badge">📖 Bíblia</div>`;
                const markerLength = lowerContent.startsWith("!bible") ? 6 : 7;
                const rest = contentTrimmed.slice(markerLength).trim();
                if (rest) {
                    html += `<div>${parseInlineMarkdownToHtml(rest)}</div>`;
                }
            } else {
                html += `<div>${parseInlineMarkdownToHtml(contentText)}</div>`;
            }
            continue;
        } else {
            if (insideBlockquote) {
                insideBlockquote = false;
                html += "</blockquote>";
            }
        }

        // HTML styled lines with align
        const headingAlignMatch = trimmed.match(/^<h([1-4]) align="(center|justify)">(.*)<\/h\d>$/i);
        if (headingAlignMatch) {
            const level = headingAlignMatch[1];
            const align = headingAlignMatch[2];
            const content = headingAlignMatch[3];
            html += `<h${level} align="${align}">${parseInlineMarkdownToHtml(content)}</h${level}>`;
            continue;
        }

        const pAlignMatch = trimmed.match(/^<p align="(center|justify)">(.*)<\/p>$/i);
        if (pAlignMatch) {
            const align = pAlignMatch[1];
            const content = pAlignMatch[2];
            html += `<p align="${align}">${parseInlineMarkdownToHtml(content)}</p>`;
            continue;
        }

        // Headings
        if (trimmed.startsWith("# ")) {
            html += `<h1>${parseInlineMarkdownToHtml(trimmed.slice(2))}</h1>`;
            continue;
        }
        if (trimmed.startsWith("## ")) {
            html += `<h2>${parseInlineMarkdownToHtml(trimmed.slice(3))}</h2>`;
            continue;
        }
        if (trimmed.startsWith("### ")) {
            html += `<h3>${parseInlineMarkdownToHtml(trimmed.slice(4))}</h3>`;
            continue;
        }
        if (trimmed.startsWith("#### ")) {
            html += `<h4>${parseInlineMarkdownToHtml(trimmed.slice(5))}</h4>`;
            continue;
        }

        // Unordered lists
        if (trimmed.startsWith("- ") || trimmed.startsWith("* ")) {
            html += `<ul><li>${parseInlineMarkdownToHtml(trimmed.slice(2))}</li></ul>`;
            continue;
        }

        // Ordered lists
        if (/^\d+\.\s/.test(trimmed)) {
            const dotIndex = trimmed.indexOf(".");
            html += `<ol><li>${parseInlineMarkdownToHtml(trimmed.slice(dotIndex + 1).trim())}</li></ol>`;
            continue;
        }

        // Empty line
        if (trimmed === "") {
            html += "<p><br></p>";
            continue;
        }

        // Normal paragraph
        html += `<p>${parseInlineMarkdownToHtml(rawLine)}</p>`;
    }

    if (insideBlockquote) {
        html += "</blockquote>";
    }

    return html;
}

export function htmlToMarkdown(html: string): string {
    if (!html) return "";
    const tempDiv = document.createElement("div");
    tempDiv.innerHTML = html;
    
    // If the HTML contains tables, preserve clean HTML blocks
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
