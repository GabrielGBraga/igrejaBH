# 🗺️ Mapa de Páginas e Features: Igreja em Belo Horizonte

Este documento serve como um guia estrutural para o desenvolvimento do portal. Antes de iniciar qualquer componente, os desenvolvedores devem consultar a estrutura abaixo e instruir a IA a ler a pasta `.agents/rules/` para garantir a consistência do código (Tailwind v4, shadcn/ui, tipagens do Supabase).

---

## 1. Área Pública (A Vitrine)
**Objetivo:** Recepcionar visitantes e fornecer informações básicas sem expor a rede interna da comunidade.
*   **`/` (Landing Page):** Visão orgânica (Atos 2). Componentes visuais focados em tipografia.
*   **`/entrar`:** Tela de autenticação e login da comunidade.

## 2. A Fundação: Segurança "Invite-Only" e Perfis
**Objetivo:** O sistema é estritamente restrito. NINGUÉM pode criar uma conta sem a pré-aprovação (convite) da liderança.
*   **`/cadastro` (Setup de Conta & Claim):** 
    *   **Regra Arquitetural de Segurança:** O cadastro é um processo de "reivindicação" de conta. O usuário só se cadastra no Supabase Auth se o seu e-mail/telefone existir previamente na tabela `profiles` como um "Perfil Fantasma" (`is_claimed: false`).
*   **`/perfil` (Gestão de Dados):**
    *   Formulários modulares (Pessoais, Socioeconômicos, Vínculos Familiares). Um middleware de bloqueio exige que o perfil seja completamente preenchido após o primeiro acesso.

## 3. Vida Comum (A Intranet do Discípulo)
**Objetivo:** O espaço de interação diária, focando em economia interna, comunicação e apoio mútuo.
*   **`/dashboard`:** Mural de início com resumo das atualizações.
*   **`/noticias/nova`:** Criação de novas postagens para o mural (notícias, avisos, orações).
*   **`/mensagens`:** Central de mensagens privadas entre membros. (Placeholder)
*   **`/ajustes`:** Preferências de conta e notificação. (Placeholder)

## 4. Árvore de Discipulado & Gestão de Relacionamentos (Presbitério)
**Objetivo:** Visão administrativa e de prestação de contas baseada em vínculos. Restrito por permissões RLS.
*   **`/gestao/grafo`:** Visão analítica em formato de grafo interativo (`RedeRelacionamentos.tsx`), mapeando conexões de discipulado, companheirismo e grupos. Inclui gerenciamento tabular avançado de membros (`MemberManagement.tsx` embutido) e listagem de Setores.
*   **`/grupos-caseiros`:** Interface administrativa (`AddHomeGroup.tsx`) para criar e configurar os locais de encontro geográficos (Oikos), definir líderes e alocá-los em setores.

## 5. Módulo de Formulários Dinâmicos
**Objetivo:** Criação flexível de enquetes, pesquisas de opinião, avaliações e fichas personalizadas.
*   **`/gestao/formularios`:** Construtor avançado de formulários com interface drag-and-drop (`FormBuilder.tsx` utilizando `@dnd-kit`).
*   **`/formularios/responder/:formId`:** Interface amigável e step-by-step (`FormResponder.tsx`) para preenchimento dos formulários dinâmicos.

## 6. Eventos e Retiros
**Objetivo:** Gerenciar logística.
*   **`/eventos` (Visão do Usuário):** Visualização e stepper para inscrição em eventos. Lida com `registrations`, seleções de quarto e pagamento.
*   **`/gestao/eventos` (Visão Administrativa):** Dashboard administrativo (`ManageEvents.tsx`) com controle de lotação de alojamentos, alocação de quartos e conciliação financeira do retiro.

## 7. Módulo Educacional
**Objetivo:** Nivelamento e ensino.
*   **`/ensinos`:** Portal para consumo de aulas em vídeo, palestras e leitura de PDFs de catequese vinculados à tabela `media_resources`.
