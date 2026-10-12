# Ciclo de Vida de Inscrições em Eventos e Retiros

Este documento descreve a arquitetura, regras de negócio e fluxos de interface referentes ao ciclo de vida das inscrições em eventos e retiros da Igreja em Belo Horizonte, conforme implementado na Issue #80.

---

## 1. Visão Geral e Princípios
O módulo de eventos (`retreats`) gerencia conferências, retiros e encontros comunitários da igreja local. As inscrições (`registrations`) registram os discípulos e convidados participantes, seus alojamentos/quartos e histórico financeiro.

### Princípios Chave:
1. **Preservação Histórica e Auditoria**: O cancelamento de uma inscrição **nunca realiza exclusão física (`DELETE`)** do registro. Preservam-se os dados preenchidos, histórico financeiro (comprovantes PIX, cupons de desconto, referências) e registros de submissão.
2. **Liberação Dinâmica de Vagas**: Ao marcar uma inscrição como `cancelado`, a vaga ocupada é **imediatamente liberada** no cálculo de lotação do evento (`max_participants`), tanto na visão pública quanto na visão administrativa.
3. **Autonomia com Cuidado Fraterno**: O próprio discípulo pode cancelar sua inscrição em sua área pessoal ("Minhas Inscrições"), liberando a vaga para outro irmão de forma amigável, com campo opcional de motivo.
4. **Proteção contra Sobrelotação**: Ao reverter uma inscrição cancelada de volta para `confirmado` ou `presente`, o sistema valida rigorosamente se há vagas disponíveis (`availableSpots > 0`).

---

## 2. Status de Inscrição

O ciclo de vida da inscrição é representado pela coluna `status` na tabela `public.registrations`:

| Status | Descrição | Impacto em Lotação | Badge na UI |
|---|---|---|---|
| `confirmado` | Inscrição ativa padrão após conclusão de formulário / pagamento / cupom. | Conta como vaga ocupada | Verde (`badgeRegistrationConfirmed`) |
| `presente` | Check-in confirmado no local do evento pela liderança/diaconato. | Conta como vaga ocupada | Azul (`badgeRegistrationPresent`) |
| `cancelado` | Inscrição cancelada (pelo discípulo ou pela liderança). | **Vaga liberada** (não consome capacidade) | Vermelho (`badgeRegistrationCancelled`) |

---

## 3. Estrutura do Banco de Dados

### Colunas em `public.registrations`
```sql
ALTER TABLE public.registrations
  ADD COLUMN status text NOT NULL DEFAULT 'confirmado' 
    CHECK (status IN ('confirmado', 'presente', 'cancelado')),
  ADD COLUMN cancellation_reason text NULL,
  ADD COLUMN cancelled_at timestamptz NULL;
```

### Índices de Performance
```sql
CREATE INDEX idx_registrations_retreat_status 
  ON public.registrations(retreat_id, status);
```

### Políticas de Segurança (Row Level Security - RLS)
* **Visualização pelo Discípulo**: Discípulos autenticados podem visualizar suas próprias inscrições vinculadas ao seu `profile_id`.
* **Cancelamento pelo Discípulo**: Discípulos podem atualizar o status de sua inscrição para `cancelado` acompanhado de `cancellation_reason` e `cancelled_at`.
* **Liderança / Administradores**: Acesso completo para gerenciar status, reverter cancelamentos e realizar check-in.

---

## 4. Regras de Negócio e Implementação

### 4.1. Cálculo de Lotação e Bloqueio de Vagas
Em todas as consultas e verificações de capacidade, apenas os status ativos são contabilizados:
```sql
WHERE retreat_id = :retreatId AND status IN ('confirmado', 'presente')
```
* **`FormResponder.tsx`**: Na verificação de lotação máxima (`max_participants`), ignora inscrições `cancelado`. Se o limite não foi atingido, o formulário permanece aberto para novas respostas.
* **Validação de Duplicidade**: Discípulos que cancelaram sua inscrição anterior não são bloqueados pela validação de duplicidade por CPF ou e-mail, podendo se inscrever novamente se houver vagas.
* **`ManageEvents.tsx`**: A contagem de inscritos (`registrations_count`) e a barra de progresso dos cards refletem estritamente inscrições ativas.
* **`kpiAggregator.ts`**: As métricas de lotação percentual e vagas disponíveis calculam apenas inscrições ativas.

### 4.2. Alojamentos e Quartos (`RoomManagementTab.tsx`)
* Participantes cancelados não são contabilizados como ocupantes das camas dos quartos.
* Participantes cancelados não figuram na lista de pendências de alocação de quarto.

### 4.3. Painel Administrativo (`ManageEventDetail.tsx`)
* **Tabela de Inscrições (`EventDataTable.tsx`)**:
  * Badges visuais para cada status com suporte a tema claro e escuro.
  * Filtro rápido por status (`Todos`, `Confirmado`, `Presente`, `Cancelado`).
  * Botão de ação rápida na linha para marcar presença (check-in).
* **Modal de Detalhes (`RegistrationDetailDialog.tsx`)**:
  * Exibe banner informativo quando cancelada, indicando motivo e data.
  * Ação "Cancelar Inscrição" com motivo opcional.
  * Ação "Reverter Cancelamento" (bloqueada com aviso amigável caso o evento já tenha atingido a lotação máxima).
* **Exportação CSV**: Inclui colunas `Status` e `Motivo de Cancelamento` formatadas com compatibilidade Excel pt-BR (BOM UTF-8).

### 4.4. Visão do Discípulo (`Events.tsx` - "Minhas Inscrições")
* Exibe o status atualizado com clareza (`Confirmada`, `Presente`, `Cancelada`, `Aguardando Pagamento`).
* Se ativa, oferece o botão **"Cancelar Inscrição"** com touch target acessível (mínimo 44x44px).
* Diálogo amigável de confirmação explica que a vaga será imediatamente liberada para que outro irmão participe, preservando o histórico.
* Em "Próximos Eventos Disponíveis", se o discípulo tiver cancelado uma inscrição prévia, o botão volta a exibir "Inscrever-se", permitindo nova participação se houver vagas abertas.
