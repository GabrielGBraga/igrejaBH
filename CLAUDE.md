# Diretrizes e Regras do Projeto — Igreja em Belo Horizonte

Este arquivo é a referência central e mandatória para todos os agentes de IA que operam neste repositório.

---

## 📌 Regras Obrigatórias de Inicialização do Agente
1. **Leitura Proativa de Regras:** O agente deve SEMPRE proativamente ler, verificar e seguir todas as regras definidas neste arquivo (`CLAUDE.md`), em `.claude/agents/` e na pasta `.agents/rules/`.
2. **Leitura Proativa de Documentação:** O agente deve SEMPRE proativamente ler e utilizar os arquivos dentro da pasta `docs/` (ex: `docs/DIRETRIZES_CONTEUDO_DESIGN.md` e `docs/DATABASE_SEEDING.md`) para compreender funcionalidades, arquitetura e requisitos do sistema.
3. **Mobile-First & UI/UX Responsivo:**
   - Estilização mobile-first obrigatória.
   - Layouts fluidos (Flexbox / CSS Grid).
   - Touch targets mínimos de 44x44px em botões, links e controles interativos.
   - NUNCA permitir overflow horizontal não intencional (`overflow-x`).
   - Verificação em telas estreitas (largura mínima de 320px).

---

## 🏛️ Diretrizes de Conteúdo e Design de UI/UX (Site da Igreja)

Você é um agente encarregado de criar componentes (React, Tailwind, shadcn/ui) e textos (copywriting) para o site desta igreja. Todo o design, a arquitetura de informação e a linguagem devem refletir estritamente os princípios teológicos abaixo. Evite qualquer modelo tradicional, corporativo ou genérico de sites evangélicos.

### 1. O Propósito Eterno (Visão Central)
* **Conceito:** O propósito de Deus, desenhado antes da fundação do mundo, é ter uma família de muitos filhos semelhantes a Jesus. A salvação é o meio para alcançar isso, e não o fim em si mesma.
* **Aplicação no Site:** O tom dos textos não deve ser "humanista" (o homem e suas necessidades no centro), mas teocêntrico. Ao gerar chamadas de ação (CTAs) ou cabeçalhos, foque em "vida em família", "semelhança com Cristo" e "propósito eterno".

### 2. Sacerdócio Universal (Sem Divisão Clero/Leigo)
* **Conceito:** Todos os membros da igreja são sacerdotes e ministros chamados para desempenhar um serviço. O corpo de Cristo edifica o corpo de Cristo; líderes existem apenas para equipar e ordenar os santos para que *os santos* façam a obra.
* **Aplicação no Design/UI:** O site não deve ter componentes que destaquem "super astros do púlpito" ou hiperfoco em uma hierarquia pastoral. O design de páginas "Sobre Nós" ou "Liderança" deve refletir horizontalidade e serviço mútuo.

### 3. Edificação por Relacionamentos (Juntas e Ligamentos)
* **Conceito:** A estrutura da igreja é mantida por "juntas e ligamentos", que são relacionamentos fortes de discipulado (vida na vida, modelando o caráter de Cristo) e companheirismo (compromisso horizontal de prestação de contas, oração e serviço).
* **Aplicação no Site:** Em vez de focar apenas em descrições de "cultos", crie componentes de interface que estimulem o visitante a se conectar a um relacionamento real de discipulado.

### 4. A Dinâmica da Igreja nas Casas e nas Ruas
* **Conceito:** A igreja não é "templista". Ela deve se reunir nas casas, não apenas para reuniões passivas, mas como equipes de trabalho e centros de treinamento para limpar as armas e planejar o evangelismo prático. A "rua" é o ambiente principal para o contato com o mundo.
* **Aplicação no Design/UI:** A igreja são as pessoas, não um endereço. Na arquitetura de informação, não crie páginas, galerias ou destaques voltados para um "prédio principal" ou "salão de cultos". Ao gerar os *cards* da interface, priorize ilustrar pequenos grupos e o convívio nas casas. O destaque do sistema de mapas/localização deve ser a funcionalidade de encontrar a "Igreja na Casa" mais próxima, e não as coordenadas de um templo central.

### 5. Evangelismo e Frutificação
* **Conceito:** Dar fruto é obrigatório e significa a reprodução da vida de Cristo em outros (fazer novos discípulos). O contato inicial com as pessoas deve ser simples, natural, "jogando o anzol" para testar a fome espiritual, compartilhando o testemunho pessoal e ensinando as ordens de Cristo.
* **Aplicação no Site:** Páginas destinadas a visitantes devem ser simples, claras e focar no testemunho da transformação de vida e na proclamação do Evangelho do Reino (arrependimento e novo nascimento).

### 6. Identidade Não-Denominacional (Corpo Único)
* **Conceito:** A congregação local não é a totalidade da Igreja do Senhor, mas apenas uma parte dela na cidade. Por isso, não adota nomenclaturas denominacionais, reconhecendo que Cristo não dividiu a Sua igreja e que o Seu Corpo é um só.
* **Aplicação no Design/UI:** O agente nunca deve gerar textos, logos ou seções que sugiram uma "marca" religiosa, franquia ou rede denominacional. Ao gerar cabeçalhos (navbars), rodapés ou *hero sections*, utilize apenas identificações geográficas neutras (ex: "Igreja em [Nome da Cidade]") e reforce visualmente o conceito de unidade do Corpo de Cristo.

### 7. Vocabulário: Discípulos em vez de Membros
* **Conceito:** A igreja não é um clube ou instituição associativa; portanto, não possui "membros" estáticos, mas sim discípulos em constante processo de formação e aprendizado prático.
* **Aplicação no Design/UI:** O agente está terminantemente proibido de usar jargões institucionais. Ao gerar botões, formulários de contato ou seções de engajamento, substitua frases institucionais como "Torne-se um membro", "Seja membro" ou "Cadastre-se" por convites relacionais, como "Caminhe conosco", "Inicie seu discipulado" ou "Junte-se a nós".

---

## 🛠️ Stack e Padrões Técnicos
- **Frontend:** React 19, TypeScript, Vite, Tailwind CSS v4, shadcn/ui.
- **Backend / Database:** Supabase (PostgreSQL, Auth, RLS, Storage).
- **Cores & Tokens:** Todas as cores DEVEM vir de `src/constants/colors.ts`. Nunca use valores hex/cores hardcoded.
- **Acessibilidade:** WCAG AA (mínimo 4.5:1) e AAA (7.0:1) com suporte a `prefers-reduced-motion`.
- **Formulários:** `react-hook-form` + `zod`.
- **Mapas:** `react-leaflet`.
- **Tabelas:** `@tanstack/react-table`.

---

## 📂 Organização das Regras (.agents/rules/)
- `01-contexto-projeto.md`: Visão geral e vocabulário base.
- `02-ui-ux-system.md`: Design tokens, layout e ferramentas MCP (Stitch / Accessibility).
- `03-banco-de-dados.md`: Schema, tabelas, RLS e dados sensíveis.
- `04-diretrizes-dev.md`: Padrões React, TypeScript, formulários e convenções.
- `05-git-workflow.md`: Branches, PRs, worktrees e automações.
- `06-diretrizes-conteudo-design.md`: Princípios teológicos, arquitetura da informação e copywriting.
