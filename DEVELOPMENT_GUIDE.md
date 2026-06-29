# 🗺️ Mapa de Páginas e Features: Igreja em Belo Horizonte

Este documento serve como um guia estrutural para o desenvolvimento do portal. Antes de iniciar qualquer componente, os desenvolvedores devem consultar a estrutura abaixo e instruir a IA a ler a pasta `.agents/rules/` para garantir a consistência do código (Tailwind v4, shadcn/ui, tipagens do Supabase).

---

## 1. Área Pública (A Vitrine)
**Objetivo:** Recepcionar visitantes e fornecer informações básicas sem expor a rede interna da comunidade.
*   **`/` (Landing Page):** Visão orgânica (Atos 2). Componentes visuais focados em tipografia.
*   **`/calendario`:** Visualização filtrando a tabela `retreats` apenas por eventos marcados como públicos.
*   **`/conectar`:** Formulário "Quero Conhecer". Captura dados de visitantes e alerta a liderança. 

## 2. A Fundação: Segurança "Invite-Only" e Perfis
**Objetivo:** O sistema é estritamente restrito. NINGUÉM pode criar uma conta sem a pré-aprovação (convite) da liderança.
*   **`/cadastro` (Setup de Conta & Claim):** 
    *   **Regra Arquitetural de Segurança:** O cadastro é, na verdade, um processo de "reivindicação" de conta. O usuário só consegue se cadastrar no Supabase Auth se o seu e-mail/telefone já existir previamente na tabela `profiles` como um "Perfil Fantasma" (`is_claimed: false`). Se não existir, o cadastro é bloqueado.
*   **`/perfil` (Gestão de Dados):**
    *   Formulários modulares: Pessoais, Socioeconômicos e Vínculos Familiares. Um middleware de bloqueio impede navegação interna se o perfil não for completamente preenchido após o primeiro acesso.

## 3. Vida Comum (A Intranet do Discípulo)
**Objetivo:** O espaço de interação diária, focando em economia interna, comunicação e apoio mútuo.
*   **`/dashboard`:** Mural em formato de timeline com abas para Notícias, Pedidos de Oração e Missões.
*   **`/profissionais`:** Grid de prestadores de serviço da comunidade. Filtros por "Área" e "Bairro". Requer um Banner de Aviso Legal isentando responsabilidade pastoral.
*   **`/companheirismo`:** Ferramenta para fomentar a "vida comum" (registrar encontros, rodízios de hospitalidade), sugerindo conexões baseadas em proximidade de bairro.

## 4. Árvore de Discipulado & Gestão (Presbitério)
**Objetivo:** Visão administrativa. Restrito por permissões RLS.
*   **`/gestao/discipulos`:** Tabela de administração (`DataTable`). Permite vincular Grupos Caseiros e Discipuladores.
    *   **Criação de Perfis Fantasmas (Shadow Profiles):** A principal feature desta tela é o botão de adicionar um membro manualmente. Isso cria o registro na tabela `profiles` (fornecendo permissão de acesso futuro) e garante que as estatísticas do presbitério estejam 100% corretas mesmo antes de a pessoa baixar o app.
*   **`/gestao/grupos`:** Criação de "Oikos". Visualização em mapa (`react-leaflet`) com base nas coordenadas dos encontros.

## 5. Eventos e Retiros
**Objetivo:** Gerenciar logística.
*   **`/eventos` (Visão do Usuário):** Stepper para inscrição. Lida com `registrations`, seleções de quarto e pagamento.
*   **`/gestao/eventos` (Visão Administrativa):** Dashboard de controle de lotação, alocação e financeiro.

## 6. Diaconato e Módulo Educacional
**Objetivo:** Nivelamento e assistência social.
*   **`/educacional` e `/gestao/conteudo`:** Dashboard de "Trilha de Formação" (aulas concluídas) e área para upload de materiais.
*   **`/gestao/diaconato`:** Interface estritamente confidencial para gerir "Bolsa de Ajuda" utilizando dados socioeconômicos.
