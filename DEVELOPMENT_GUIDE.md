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
**Objetivo:** Gerenciar logística presencial, inscrições, alojamentos, relatórios de impressão e finanças de retiros/encontros comunitários.
*   **`/eventos` (Visão do Discípulo):** Visualização e stepper para inscrição em eventos (`Events.tsx`).
    *   **"Minhas Inscrições":** Exibe o status atualizado da inscrição (`Confirmada`, `Presente`, `Cancelada`, `Aguardando Pagamento`).
    *   **Cancelamento Amigável:** Permite que o próprio discípulo solicite o cancelamento de sua inscrição através de modal com motivo opcional, liberando imediatamente a vaga para outro irmão enquanto preserva dados e histórico financeiro.
    *   **Re-inscrição:** Caso o participante tenha cancelado e ainda existam vagas abertas no evento, o botão "Inscrever-se" volta a ficar disponível.
*   **`/manage-events` (Dashboard Administrativo):** Painel (`ManageEvents.tsx`) com visão geral dos eventos, filtros por status e criação/edição.
*   **`/manage-events/:eventId` (Gestão Detalhada do Evento):** Painel administrativo (`ManageEventDetail.tsx`):
    *   Controle de lotação em tempo real (`max_participants`), calculando apenas inscrições ativas (`confirmado` e `presente`).
    *   Gestão tabular (`EventDataTable.tsx`) com filtros por status, equipe de serviço e ação rápida de check-in (presença).
    *   Modal de detalhes (`RegistrationDetailDialog.tsx`) para atribuição de equipe de serviço, cancelamento com motivo ou reversão de cancelamento (com trava de segurança caso o evento esteja lotado).
    *   Divisão de quartos (`RoomManagementTab.tsx`), conciliação financeira e exportação para Excel/CSV com status, motivos de cancelamento e equipe de serviço.
    *   Organização de equipes de serviço/voluntariado (`EventTeamsTab.tsx`) com visão geral, contadores, escalas para WhatsApp e alocação dinâmica. Consulte [`docs/EVENT_SERVICE_TEAMS.md`](docs/EVENT_SERVICE_TEAMS.md).
    *   Geração e impressão de listas em PDF (`EventPrintListsDialog.tsx` / `eventPrintUtils.ts`) com 3 relatórios prontos para operação física/offline em A4 (Lista de Presença/Portaria com assinatura, Folhas de Porta dos Quartos e Relatório da Cozinha/Restrições alimentares).
    *   *Documentação detalhada:* Consulte [docs/EVENT_REGISTRATIONS.md](docs/EVENT_REGISTRATIONS.md) e [docs/EVENT_SERVICE_TEAMS.md](docs/EVENT_SERVICE_TEAMS.md).

## 7. Módulo Educacional
**Objetivo:** Nivelamento e ensino.
*   **`/ensinos`:** Portal para consumo de aulas em vídeo, palestras e leitura de PDFs de catequese vinculados à tabela `media_resources`.

