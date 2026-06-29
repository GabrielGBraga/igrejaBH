# Sistema de Design (UI/UX) e Padronização Visual

## 1. Stack Visual
- **Framework:** React 19 + Tailwind CSS v4.
- **Biblioteca de Componentes:** shadcn/ui (radix-ui).
- **Tipografia:** Geist Variable (font-sans).

## 2. Design Tokens (Light / Dark Mode)
O sistema DEVE suportar `next-themes`. Todas as classes Tailwind geradas devem prever o estado dark.

### Cores Primárias (Monocromático/Clean)
- **Fundo Principal (Background):**
  - Light: `bg-zinc-50` ou `bg-white`
  - Dark: `dark:bg-zinc-950`
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

## 4. Geração de Telas
Sempre que o agente for instruído a criar uma nova página, ele deve:
1. Compor a página inteiramente usando peças existentes na pasta `src/components/ui/`.
2. Adicionar o wrapper do Layout (Desktop/Mobile).
3. Nunca usar cores fixas (como `text-black` ou `bg-white`) sem a contraparte `dark:`.
