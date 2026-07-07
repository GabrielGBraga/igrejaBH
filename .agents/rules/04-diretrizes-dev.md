# Padrões de Código e Desenvolvimento

## 1. Componentes Funcionais (React)
- Use exportações padrão para páginas (`export default function Page()`) e exportações nomeadas para componentes (`export function Component()`).
- Evite `any` a todo custo. Tipagem estrita é obrigatória.
- Hooks de dados (busca no Supabase) devem ser encapsulados ou tratados com `useEffect`/React Query (se adicionado futuramente). Atualmente, trate o loading state de forma explícita com `Skeleton` do shadcn.

## 2. Formulários e Validação
- Para qualquer entrada de dados de usuário, utilize OBRIGATORIAMENTE `react-hook-form` integrado ao `zod` via `@hookform/resolvers`.
- Exemplo de import: `import { useForm } from "react-hook-form"` e `import * as z from "zod"`.
- Use os componentes `<Form>`, `<FormField>`, `<FormItem>`, `<FormMessage>` já existentes na UI.

## 3. Mapas
- Ao renderizar mapas (Grupos Caseiros), utilize OBRIGATORIAMENTE `react-leaflet`.
- Lembre-se de importar o CSS do leaflet para evitar quebra de renderização: `import 'leaflet/dist/leaflet.css'`.

## 4. MCP e Servidores
- Ao ser instruído a alterar o banco de dados (backend), o agente deve propor a migração `.sql` ou utilizar os servidores MCP configurados, nunca alterar arquivos não relacionados.

## 5. Manutenção do Contexto (Regra de Ouro do Agente)
- O agente DEVE ser proativo quanto à integridade e atualização das regras desta pasta (`.agents/rules/`).
- Sempre que uma ação durante o desenvolvimento alterar o contexto geral do projeto (exemplo: instalar uma nova biblioteca principal, criar uma nova tabela no Supabase ou alterar a arquitetura de pastas), o agente DEVE parar e emitir o seguinte aviso explícito ao usuário:
  👉 **"Atenção: A ação que acabamos de realizar mudou a arquitetura do projeto. Por favor, atualize os arquivos de regras na pasta `.agents/rules/` para que eu (e outros agentes) não percamos esse contexto no futuro."**
