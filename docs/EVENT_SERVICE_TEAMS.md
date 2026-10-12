# Equipes de Serviço (Voluntariado / Diaconato) e Cupons de Isenção em Eventos

Este documento descreve a arquitetura, as diretrizes teológicas, a modelagem de dados e as interfaces do módulo de **Equipes de Serviço (Voluntariado)** e **Cupons de Isenção para Servidores** nos eventos e retiros da Igreja em Belo Horizonte.

---

## 1. Princípio Teológico Central: Sacerdócio Universal de Todos os Santos

Na Igreja do Senhor, não há divisão entre clero e leigo. Conforme **1 Pedro 2:9**, **Romanos 12:4-8** e **Efésios 4:11-16**, todos os discípulos são ministros e santos chamados para servir ao Corpo de Cristo para a mútua edificação:

> *"Antes, seguindo a verdade em amor, cresçamos em tudo naquele que é a cabeça, Cristo, de quem todo o corpo, bem ajustado e consolidado pelo auxílio de toda junta, segundo a justa cooperação de cada parte, efetua o seu próprio aumento para a edificação de si mesmo em amor."* (Efésios 4:15-16)

O trabalho nos retiros e encontros comunitários não é terceirizado nem reservado a uma liderança isolada. Cada discípulo que serve na cozinha, na limpeza, no som ou no acolhimento é um cooperador ministerial do Senhor no diaconato prático.

---

## 2. Equipes Canônicas de Serviço

O sistema padroniza 8 equipes de serviço essenciais em `src/constants/serviceTeams.ts`, cada uma com seu foco bíblico, identificador, ícone e paleta de cores acessível (WCAG AA):

| Identificador (`id`) | Nome da Equipe | Foco Bíblico | Descrição |
| :--- | :--- | :--- | :--- |
| `cozinha` | **Cozinha & Alimentação** | *Atos 2:46* ("Partir do pão e comunhão na mesa") | Preparo e distribuição de refeições, lanches e café comunitário. |
| `limpeza` | **Limpeza & Organização** | *1 Coríntios 14:40* ("Boa ordem e zelo na casa") | Higienização, conservação e zelo das áreas comuns e banheiros. |
| `recepcao` | **Recepção & Boas-vindas** | *1 Pedro 4:9* ("Hospitalidade mútua sem murmuração") | Acolhimento na chegada, credenciamento e orientações gerais aos irmãos. |
| `multimidia` | **Multimídia & Som** | *Neemias 8:8* ("Clamor claro da palavra para edificação") | Operação de áudio, microfones, projeção, transmissão e gravação. |
| `criancas` | **Cuidado com Crianças** | *Marcos 10:14* ("Deixai vir a mim as crianças") | Assistência, atividades edificantes e cuidado com os pequeninos. |
| `intercessao` | **Intercessão & Oração** | *Efésios 6:18* ("Orai uns pelos outros em todo o tempo") | Sustentação espiritual contínua e vigília em oração durante todo o retiro. |
| `apoio` | **Apoio & Logística** | *Romanos 12:13* ("Socorro e auxílio mútuo nas necessidades") | Montagem, sinalização, transporte de materiais e suporte emergencial. |
| `geral` | **Serviço Geral** | *Gálatas 5:13* ("Servi uns aos outros pelo amor") | Discípulos à disposição para demandas pontuais e imprevistos do encontro. |

---

## 3. Modelagem de Dados e Banco de Dados (Supabase)

### 3.1. Alterações no Schema
- **`public.registrations`**:
  - Nova coluna `service_team text` (nullable).
  - Índice `idx_registrations_service_team ON registrations(service_team)`.
- **`public.event_coupons`**:
  - Nova coluna `target_service_team text` (nullable).
  - Índice `idx_event_coupons_target_service_team ON event_coupons(target_service_team)`.

### 3.2. RPCs Atualizadas
- **`validate_coupon(p_code, p_cpf, p_retreat_id, p_form_id)`**: Retorna agora o campo `target_service_team text` junto aos dados de validação (`valid`, `requires_cpf`, `discount_percent`).
- **`redeem_coupon(p_code, p_cpf, p_user_name, p_user_email, p_retreat_id, p_form_id)`**: Retorna `target_service_team text` para confirmação no momento do resgate.

### 3.3. Trigger de Segurança e Sincronização
- Trigger **`sync_registration_service_team_from_coupon`** na tabela `registrations`:
  - Se a inscrição for criada ou atualizada com uma referência de cupom (ex: `Cupom: ABC123XYZ`) e a inscrição ainda não tiver `service_team` definido, o gatilho consulta o cupom e carimba automaticamente o `target_service_team` correspondente, assegurando integridade mesmo se a chamada for originada de scripts externos ou integrações.

---

## 4. Interfaces e Funcionalidades no Frontend

### 4.1. Aba "Equipes de Serviço" (`EventTeamsTab.tsx`)
Acessível no detalhe do evento em `/gestao/eventos/:eventId`:
- **KPIs & Contadores no Topo**: Cartões de resumo exibindo Total de Inscritos, Voluntários Servindo (com porcentagem), Participantes sem Equipe e Equipes Ativas.
- **Grade de Equipes**: Cards com ícones temáticos e contadores de voluntários por equipe.
- **Exportação para WhatsApp**:
  - Botão individual por equipe para copiar a escala formatada pronta para compartilhamento com o líder responsável (incluindo nome, telefone formatado e quarto/alojamento).
  - Botão de "Copiar Escala Geral" com a listagem completa de todas as frentes de serviço.
- **Gestão & Reatribuição Dinâmica**:
  - Seletor dropdown inline em cada participante para alterar ou remover a equipe de serviço instantaneamente.
  - Links diretos para ligação e WhatsApp nos contatos dos voluntários.
  - Visualização e atalho para o quarto/alojamento alocado.
- **Seção "Participantes sem Equipe"**: Lista retrátil dos inscritos sem equipe com botão de alocação rápida.
- **Modal "Atribuir Voluntário"**: Busca e inclusão de qualquer discípulo inscrito em uma equipe específica.

### 4.2. Modal de Detalhes da Inscrição (`RegistrationDetailDialog.tsx`)
- Seção **"Equipe de Serviço (Voluntariado)"** com badge temático da equipe.
- Botão **"Alterar Equipe"** permitindo que a liderança atribua ou altere a equipe do participante diretamente ao visualizar sua ficha completa.

### 4.3. Tabela Geral de Inscrições (`EventDataTable.tsx`)
- Coluna **"Equipe de Serviço"** com badge e ícone.
- Filtro dedicado na barra de ferramentas: *Todas as Equipes*, *Apenas Voluntários*, *Sem Equipe* e seleção por equipe específica.
- Busca global que também pesquisa pelo nome da equipe.

### 4.4. Construtor de Filtros e Consultas (`FilterBuilder.tsx` & `eventsQueryBuilder.ts`)
- Campo `service_team` integrado como opção de filtro nos relatórios dinâmicos.
- Suporte a operadores:
  - `is`: "Sem Equipe / Não atribuído" (`service_team IS NULL`).
  - `not_is`: "Voluntário atribuído" (`service_team IS NOT NULL`).
  - `eq`: "Equipe igual a...".
  - `neq`: "Equipe diferente de...".

### 4.5. Cupons de Isenção para Servidores (`EventCouponsTab.tsx`)
- Ao gerar um cupom (100% isenção ou percentual parcial), a liderança pode selecionar opcionalmente a **Equipe de Serviço Alvo**.
- O código gerado exibirá a equipe na tabela e a mensagem de compartilhamento no WhatsApp informará o irmão sobre sua escala.

### 4.6. Fluxo de Inscrição Pública (`FormResponder.tsx`)
- Quando o voluntário preenche o formulário informando o cupom recebido, o sistema valida o cupom via RPC, identifica o `target_service_team` e grava automaticamente o campo `service_team` na criação da inscrição em `registrations`.

---

## 5. Diretrizes de UI/UX, Acessibilidade e Nomenclatura

- **Cores & Contraste**: Todas as cores são extraídas estritamente de `src/constants/colors.ts` (`SERVICE_TEAM_COLORS`), testadas para conformidade WCAG AA (mínimo 4.5:1) em tema claro e escuro.
- **Touch Targets**: Botões e triggers de seleção respeitam a área mínima de toque de 44x44px (`min-h-[44px]` ou `h-11`).
- **Nomenclatura Bíblica**: Uso estrito dos termos *"Discípulos"*, *"Irmãos"*, *"Santos"* e *"Diaconato"* (nunca *"Membros"* ou jargões institucionais/corporativos).
