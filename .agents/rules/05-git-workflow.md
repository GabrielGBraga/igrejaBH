# Fluxo de Trabalho Git e CI/CD

## 1. Padrão de Commits (Conventional Commits)
Os agentes DEVEM gerar mensagens de commit claras e estruturadas usando o padrão Conventional Commits.
- `feat:` Para novas funcionalidades (ex: telas, componentes novos).
- `fix:` Para correção de bugs.
- `chore:` Para atualizações de dependências, regras de agentes ou ferramentas.
- `refactor:` Para reestruturação de código que não altera comportamento.
- `db:` Para migrações do Supabase ou alterações de schema.

## 2. Estratégia de Branches e Pull Requests (GitFlow Simplificado)
- A branch `main` é sagrada e reflete exclusivamente o ambiente de produção.
- A branch `dev` (ou `develop`) é a base de integração contínua e espelha o ambiente de homologação/teste.
- Todo novo desenvolvimento gerado pelo agente deve ocorrer em uma branch separada (ex: `feat/banco-profissionais`), criada obrigatoriamente a partir da branch `dev`.
- NUNCA instrua um push direto para a `main` ou para a `dev`.
- **REGRA ESTRITA DE PR:** NUNCA crie ou proponha um Pull Request de uma branch de feature diretamente para a `main`. O fluxo obrigatório é unidirecional: 
  1. `feature` -> PR para `dev`.
  2. Testes e validações ocorrem na `dev`.
  3. `dev` -> PR para `main` (Release).

## 3. Pull Requests e Automações (GitHub Actions)
O projeto possui fluxos de trabalho configurados no `.github/workflows/`.
- Ao criar um PR envolvendo banco de dados, o repositório executará o `pr-db-preview.yml`.
- O agente deve garantir que qualquer alteração de banco no PR esteja acompanhada do seu respectivo arquivo `.sql` gerado corretamente na pasta `supabase/migrations/`.
- NUNCA ignore avisos do ESLint ou do TypeScript (typecheck) antes de preparar um PR, pois isso causará falha na pipeline.

## 4. Deploy de Banco de Dados
- O arquivo `deploy-migrations.yml` cuida das atualizações em produção quando ocorre o merge na branch principal.
- Se o agente alterar funções, tabelas ou políticas RLS, ele deve criar UMA MIGRAÇÃO, e não alterar diretamente pelo painel do Supabase, para que o GitHub Actions possa aplicar a mudança via código de forma segura.

## 5. Preparação de Worktrees e Limpeza Pós-PR
- **Prontidão do Ambiente de Teste (Worktrees):** Ao criar ou trabalhar em uma *worktree* do Git, o agente DEVE OBRIGATORIAMENTE garantir que a pasta esteja 100% pronta para execução e teste:
  1. **Configurações (`.env`):** Copiar os dados e variáveis de ambiente do arquivo `.env` (e `.env.local`, se aplicável) do repositório principal/raiz para a nova worktree.
  2. **Dependências (`node_modules`):** Verificar se a pasta `node_modules` existe na worktree. Se não existir ou estiver desatualizada, o agente deve garantir a existência executando a instalação de dependências ou ajustando o ambiente para que o usuário/agente possa rodar e testar a aplicação imediatamente.
- **Limpeza Pós-PR:** Sempre delete a *worktree* e/ou a *branch* correspondente após a conclusão/merge do Pull Request, tanto localmente quanto na `origin` (repositório remoto).
  - *Exceção:* Isso não se aplica à branch `dev`. A branch `dev` **nunca** deve ser deletada.
