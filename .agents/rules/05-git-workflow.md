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
