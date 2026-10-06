/**
 * Bidirectional parsing helpers: Markdown <-> HTML
 */

export function escapeHtml(text: string): string {
    return text
        .replace(/&/g, "&amp;")
        .replace(/</g, "&lt;")
        .replace(/>/g, "&gt;")
        .replace(/"/g, "&quot;")
        .replace(/'/g, "&#039;");
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
        const fmLines = frontmatterContent
            .split("\n")
            .filter((_, idx, arr) => idx > 0 && idx < arr.length - 1)
            .map(l => escapeHtml(l.trimEnd()))
            .join("<br>");
        
        html += `<div class="editor-properties-block" contenteditable="false">
            <div class="properties-header">Propriedades / Metadados (Não editável)</div>
            <div class="properties-body">${fmLines}</div>
        </div>`;
    }

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
