# Sistema de Design (UI/UX) e Padronização Visual

## 1. Stack Visual
- **Framework:** React 19 + Tailwind CSS v4.
- **Biblioteca de Componentes:** shadcn/ui (radix-ui).
- **Tipografia:** Geist Variable (font-sans).

## 2. Design Tokens (Light / Dark Mode) & Arquivo de Constantes de Cores
O sistema DEVE suportar `next-themes`. Todas as classes Tailwind geradas devem prever o estado dark.

### 2.1. Arquivo de Constantes Centralizado (`src/constants/colors.ts`) — REGRA OBRIGATÓRIA
- **Fonte Única da Verdade:** Todas as definições de cores, tokens semânticos, paletas de gráficos/canvas e classes Tailwind padrão estão centralizadas em `src/constants/colors.ts` (re-exportado em `src/lib/colors.ts`).
- **Regra de Uso:** Em qualquer contexto de código (especialmente HTML5 Canvas, mapas Leaflet, gráficos, SVGs, ou estilos dinâmicos), **NUNCA** use códigos hexadecimais ou strings de cores soltas/hardcoded. Importe as cores diretamente de `@/constants/colors`.
- **Regra de Atualização:** Qualquer nova cor, tonalidade de status, token de tema ou variante visual introduzida no projeto **DEVE ser obrigatoriamente adicionada e documentada em `src/constants/colors.ts`**. É terminantemente proibido introduzir cores no código sem atualizar o arquivo de constantes.

### 2.2. Cores Primárias (Monocromático/Clean)
- **Fundo Principal (Background):**
  - Light: `bg-zinc-50` ou `bg-white` (`#fafafa` / `#ffffff`)
  - Dark: `dark:bg-zinc-950` (`#09090b`)
- **Superfícies (Cards, Modais):**
  - Light: `bg-white border-zinc-200`
  - Dark: `dark:bg-zinc-900 dark:border-zinc-800`
- **Textos:**
  - Light: `text-zinc-900` (títulos) e `text-zinc-500` (corpo)
  - Dark: `dark:text-zinc-50` (títulos) e `dark:text-zinc-400` (corpo)
- **Ações Primárias (Botões):**
  - Light: `bg-zinc-900 text-zinc-50 hover:bg-zinc-800`
  - Dark: `dark:bg-zinc-50 dark:text-zinc-900 dark:hover:bg-zinc-200`

## 3. Padrões de Layout
- **Bordas (Radius):** Sempre usar `rounded-xl` para Cards/Modais e `rounded-md` para Inputs/Buttons.
- **Espaçamento (Padding/Margin):** Usar a escala de 4 do Tailwind (ex: `p-4`, `p-6`, `gap-4`).
- **Navegação:**
  - Desktop: Sidebar lateral fixa (`w-64`, border right).
  - Mobile: Bottom Tab Bar fixa com ícones Lucide React.
  - O header principal deve SEMPRE conter o `ThemeToggle` e o `UserAvatar`.

## 4. Ferramentas MCP de UI/UX (Stitch & Acessibilidade)

### 4.1. Accessibility MCP (`accessibility`) — Validação WCAG
- **Ferramentas Disponíveis:** `are-colors-accessible`, `get-color-contrast`, `use-light-or-dark`.
- **Quando Usar:**
  - Sempre que novas cores ou combinações de cores forem propostas ou adicionadas a `src/constants/colors.ts`.
  - Ao criar novos botões, badges, alertas ou elementos com contraste entre texto e fundo.
  - O agente deve validar se o par de cores atinge o padrão **WCAG AA** (mínimo de 4.5:1 para texto normal e 3:1 para texto grande/componentes) tanto para o tema **Light** quanto para o tema **Dark**.
  - **Validação Estrita de Contraste:** Textos normais e componentes interativos primários (ex: botões de ação e links principais) DEVEM alcançar conformidade com **WCAG AAA** (mínimo 7.0:1) no modo Light e no modo Dark sempre que viável, e NUNCA menos que **WCAG AA** (mínimo 4.5:1).
  - Em caso de dúvida sobre texto claro ou escuro sobre fundos customizados, execute `use-light-or-dark` para selecionar a combinação ideal de contraste.

### 4.2. Stitch MCP (`StitchMCP`) — Prototipagem e Design Systems
- **Ferramentas Disponíveis:** `generate_screen_from_text`, `generate_variants`, `edit_screens`, `get_screen`, `list_screens`, `upload_design_md`, `create_design_system_from_design_md`, `apply_design_system`.
- **Quando Usar:**
  - **Geração de Novas Telas/Layouts:** Ao ser solicitado a criar novas páginas, fluxos complexos ou reformulações visuais completas, utilize o Stitch MCP (`generate_screen_from_text` ou `generate_variants`) para conceber protótipos de tela e explorar alternativas de layout antes de codificar os componentes React.
  - **Sincronização com o Design System:** Ao atualizar a identidade ou documentação de design, utilize as ferramentas de sincronização (`upload_design_md`, `apply_design_system`) para manter os protótipos alinhados ao sistema de design do projeto.
  - **Edição e Variações Visuais:** Utilize `edit_screens` e `generate_variants` para iterar layouts de forma assistida quando o usuário desejar comparar propostas de interface.

### 4.3. Animações e Acessibilidade Vestibular (`prefers-reduced-motion`)
- **Regra de Ouro:** Qualquer animação CSS, transição com `transform`/`scale` ou efeito de translação implementado DEVE obrigatoriamente respeitar a media query `@media (prefers-reduced-motion: reduce)`.
- Quando o usuário tiver ativado o movimento reduzido no sistema operacional ou navegador, as durações devem ser colapsadas (`animation-duration: 0.001ms !important`, `transition-duration: 0.001ms !important`) e os deslocamentos táteis anulados (`transform: none !important`).

## 5. Geração de Telas e Edição de UI
Sempre que o agente for instruído a criar ou editar elementos de UI, ele deve:
1. Compor a página/componente priorizando o uso de peças existentes na pasta `src/components/ui/` (shadcn/ui).
2. Consultar e importar valores de cor e classes do arquivo centralizado `src/constants/colors.ts`.
3. Validar a acessibilidade visual e contraste (WCAG AA/AAA) com o MCP `accessibility`.
4. Para telas novas complexas, considerar prototipação prévia com o `StitchMCP`.
5. Adicionar o wrapper do Layout (Desktop/Mobile) correspondente.
6. Nunca usar cores fixas (como `text-black` ou `bg-white`) sem a contraparte `dark:`.
7. **Verificação Pós-Edição:** Após qualquer alteração que envolva UI, verificar se não há componentes nativos ou customizados sendo implementados/mantidos que poderiam (e deveriam) ser substituídos por componentes do `shadcn/ui` já instalados ou disponíveis para instalação.
8. **Acessibilidade Vestibular:** Garantir que novas animações ou transições incluam suporte a `prefers-reduced-motion`.
