# Padrões de Código e Desenvolvimento

## 1. Componentes Funcionais (React)
- Use exportações padrão para páginas (`export default function Page()`) e exportações nomeadas para componentes (`export function Component()`).
- Evite `any` a todo custo. Tipagem estrita é obrigatória.
- Hooks de dados (busca no Supabase) devem ser encapsulados ou tratados com `useEffect`/React Query (se adicionado futuramente). Atualmente, trate o loading state de forma explícita com `Skeleton` do shadcn.

## 2. Formulários, Validação e Drag-and-Drop
- Para qualquer entrada de dados de usuário convencional, utilize OBRIGATORIAMENTE `react-hook-form` integrado ao `zod` via `@hookform/resolvers`.
- Exemplo de import: `import { useForm } from "react-hook-form"` e `import * as z from "zod"`.
- Use os componentes `<Form>`, `<FormField>`, `<FormItem>`, `<FormMessage>` já existentes na UI.
- Para interações de Drag-and-Drop (como a ordenação e construção de formulários), utilize as bibliotecas `@dnd-kit/core`, `@dnd-kit/sortable` e `@dnd-kit/utilities` que já fazem parte da stack do projeto.

## 3. Mapas
- Ao renderizar mapas (Grupos Caseiros), utilize OBRIGATORIAMENTE `react-leaflet`.
- Lembre-se de importar o CSS do leaflet para evitar quebra de renderização: `import 'leaflet/dist/leaflet.css'`.

## 4. Tabelas de Dados Administrativas (TanStack Table v9)
- Para listagens administrativas densas, com necessidade de paginação, ordenação e filtros (como a listagem de inscritos em eventos), utilize `@tanstack/react-table`.
- **Compatibilidade v9 / shadcn:** No TanStack Table v9, importe hooks e fábricas de modelos a partir do módulo legado:
  `import { useLegacyTable as useReactTable, getCoreRowModel, getPaginationRowModel, getSortedRowModel, type LegacyColumnDef as ColumnDef } from "@tanstack/react-table/legacy";`
  e `flexRender` a partir de `@tanstack/react-table`.
- **Boas Práticas:**
  - Suporte a paginação configurável com seletor de tamanho de página (10, 25, 50).
  - Alvos de toque acessíveis (mínimo de 44x44px nos seletores e botões de paginação/ações).
  - Contêiner com rolagem horizontal contida (`overflow-x-auto`) para telas estreitas.

## 5. MCP e Servidores
- **Supabase MCP (`supabase-mcp-server`):** Ao ser instruído a alterar o banco de dados (backend), o agente deve propor a migração `.sql` ou utilizar os servidores MCP configurados, nunca alterar arquivos não relacionados.
- **Accessibility MCP (`accessibility`):** O agente deve obrigatoriamente validar contrastes e conformidade WCAG AA/AAA (`are-colors-accessible`, `get-color-contrast`, `use-light-or-dark`) ao definir ou alterar cores no arquivo `src/constants/colors.ts` ou nos componentes de UI.
- **Stitch MCP (`StitchMCP`):** O agente deve utilizar as ferramentas do Stitch (`generate_screen_from_text`, `generate_variants`, `upload_design_md`, `apply_design_system`) para prototipar telas novas, gerar variações de interface e manter o alinhamento com o design system antes de codificar telas complexas.
- **Constantes de Cores (`src/constants/colors.ts`):** É regra estrita manter todas as cores do projeto registradas em `src/constants/colors.ts`. Qualquer cor nova em tempo de execução ou elemento visual DEVE ser adicionada e importada dessa constante.

## 6. Manutenção do Contexto (Regra de Ouro do Agente)
- O agente DEVE ser proativo quanto à integridade e atualização das regras desta pasta (`.agents/rules/`).
- Sempre que uma ação durante o desenvolvimento alterar o contexto geral do projeto (exemplo: instalar uma nova biblioteca principal, criar uma nova tabela no Supabase ou alterar a arquitetura de pastas), o agente DEVE parar e emitir o seguinte aviso explícito ao usuário:
  👉 **"Atenção: A ação que acabamos de realizar mudou a arquitetura do projeto. Por favor, atualize os arquivos de regras na pasta `.agents/rules/` para que eu (e outros agentes) não percamos esse contexto no futuro."**
