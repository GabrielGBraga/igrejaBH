---
name: anti-ai-slop
description: >-
  Audits, refactors, and cleans up web pages and UI components to remove "AI slop",
  generic AI-generated design clichés, misplaced features, competing CTAs, and broken UX flows.
  Use whenever the user asks to review, audit, clean up, or fix a page/component for AI marks,
  unnecessary information, SaaS clichés, or violations of project design hygiene.
---

# Anti-AI Slop Audit & Remediation Runbook

This skill guides the agent through an audit and remediation workflow to identify and eliminate "marks of AI development" (AI slop), visual clichés, information architecture flaws, and copywriting issues across pages and components.

---

## 1. When to Use
- User asks: *"review the page for AI marks"*, *"clean up AI slop"*, *"remove unnecessary stuff and AI cliches"*, *"refactor this page to look human and clean"*.
- When reviewing a newly generated or modified UI to ensure it complies with the project's strict design system and doesn't look like generic automated code.

---

## 2. The 5-Point AI Slop Audit Checklist

Inspect the target page and all its subcomponents against these 5 pillars:

### A. Icon & Visual Clichés
- [ ] **No `Sparkles` (`✨`) for General / Theological / Feature Items:** Check imports of `Sparkles` from `lucide-react`. Replace with sober semantic icons (`BookOpen`, `Calendar`, `HeartHandshake`, `Home`, `Users`) or omit the icon entirely.
- [ ] **No Multi-colored SaaS Bento Grids:** Check for cards with arbitrary multi-colored ambient background gradients (`from-emerald-...`, `from-amber-...`, `from-teal-...`) and rainbow icon boxes.
- [ ] **No Unjustified Levitation / Scaling:** Eliminate `hover:-translate-y-1` or `group-hover:scale-105` unless specifically required by the tactile design system. Adhere strictly to `src/constants/colors.ts` and `THEME_CLASSES`.
- [ ] **No Eyebrow Metadata Stacking:** Check for cards or sections stacking a `<Badge>` + uppercase kicker (`uppercase tracking-wider`) + title + subtitle + `#hashtags`. Simplify into clean, confident hierarchy.

### B. Mockup Artifacts & Poster Chrome
- [ ] **No Graphic-Design Poster Trim Coded as HTML:** Check for inner cards repeating the main church logo, decorative non-clickable badges with action verbs (e.g. `<Badge>Ver Programação</Badge>`), or card footer bars repeating dates/brand names.
- [ ] **No Redundant Echoing:** Ensure dates, titles, or locations are not repeated multiple times within the same card or dialog (e.g., repeating the event time 20px below the title).

### C. Information Architecture & CTA Hygiene
- [ ] **Single-Path CTA per Intent:** Look for competing buttons in the same section that open duplicate forms (e.g., inline form + modal form + separate page link). Consolidate into one clear, direct path.
- [ ] **No Deceptive Buttons:** Ensure buttons do what they promise. (e.g., never label a button *"Ver Grupos por Bairro"* if it merely opens a contact form).
- [ ] **Public vs. Protected Route Verification:** Cross-reference every `<Link to="...">` on public/visitor pages (`Landing`, `QueroSaberMais`, guest `Ensinos`) with `src/App.tsx`. Ensure public CTAs NEVER link to routes wrapped in `<ProtectedRoute>` (e.g. `/eventos`).
- [ ] **No Misplaced Internal Widgets:** Verify that member-only or internal tracking tools (e.g., full daily catechism study modules with curriculum track badges and WhatsApp sharing utilities) are located on internal dashboards (`/dashboard` or `/ensinos`), not cluttering visitor hero sections.

### D. Copywriting & Theological Alignment
- [ ] **No Forbidden Institutional Vocabulary:** Check for words like *"membros"*, *"instituição"*, or phrases like *"nossa existência enquanto instituição"*. Use *"discípulos"*, *"irmãos"*, *"comunhão local"*, or *"presença na cidade"*.
- [ ] **No Leaked Database Schema:** Ensure internal database column states (like `is_public = true`) are not exposed as titles (e.g., avoid *"Últimas Publicações Públicas"* in favor of natural phrasing like *"Comunicados e Estudos Recentes"*).
- [ ] **No Outdated "Clique Aqui":** Avoid hiding core convictions or history behind lazy *"clique aqui"* modal links. Present principles directly on the page in a clean editorial grid.
- [ ] **No Fake/Placeholder URLs:** Ensure social and external links point to real endpoints or are omitted (never use placeholder links like `href="https://youtube.com"`).

### E. Mobile-First & Acessibilidade
- [ ] **Touch Targets:** Verify all interactive buttons, links, calendar navigation controls, and form elements have at least `min-h-[44px]` (or `min-w-[44px]`).
- [ ] **Zero Horizontal Overflow:** Check layouts at 320px width to ensure no horizontal scrollbars occur.
- [ ] **Design Tokens & Colors:** Confirm all colors are imported from `@/constants/colors` and support dark mode natively.

---

## 3. Step-by-Step Remediation Procedure

When auditing and fixing a page:

1. **Scan Target & Subcomponents:**
   Read the main page file and trace every subcomponent imported by it.
2. **Execute Diagnostic:**
   Evaluate each subcomponent against the 5-point checklist above.
3. **Present Diagnosis:**
   List concrete findings organized by category with exact file paths and line numbers.
4. **Apply Surgical Fixes:**
   - Consolidate data constants into data files (`landingData.ts`, etc.) instead of duplicating inline arrays.
   - Refactor UI to remove visual slop, poster chrome, and misleading CTAs.
   - Adjust routes and links to respect route guards (`ProtectedRoute`).
   - Fix copywriting to be relational, teocentric, and non-institutional.
5. **Verify Quality:**
   Run `npx tsc -b` and `npx eslint <touched_files>` to ensure zero errors and maintain Fast Refresh compatibility.
