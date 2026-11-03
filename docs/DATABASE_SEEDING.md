# Seeding do Banco de Dados de Desenvolvimento (`igrejaBH-DEV`)

Este documento descreve o funcionamento, a estrutura e a lógica de geração dos dados de teste e de censo real para o portal da Igreja em Belo Horizonte.

---

## 1. Visão Geral e Duas Opções de Seeding

O projeto oferece **duas opções completas de seeding**, mantendo o ambiente de desenvolvimento flexível tanto para simulações rápidas e demonstrações sintéticas quanto para testes com o censo real da igreja:

| Característica | Opção 1: Mock Sintético (`seed.sql`) | Opção 2: Censo Real das Planilhas (`seed-real.sql`) |
| :--- | :--- | :--- |
| **Comando** | `npm run db:seed` | `npm run db:seed:real` |
| **Origem dos Dados** | Geração algorítmica padronizada | Arquivos CSV oficiais em `supabase/data/` |
| **Volumetria de Perfis** | 537 perfis (531 vinculados + 6 visitantes) | **821 discípulos reais** (3 contas ativas + 818 phantom users / crianças) |
| **Contas de Autenticação (`auth.users`)** | 537 contas simuladas | **Exatamente 3 contas** (Gabriel, Fernando e Clara) |
| **Grupos Caseiros** | 24 GCs (4 por setor, nomes fictícios de bairros) | **35 GCs reais** (endereços e coordenadas GPS reais) |
| **Setores** | 6 setores metropolitanos simulados | **6 setores oficiais** (com Betim/Contagem e Fora da Localidade) |
| **Identificadores (IDs)** | UUIDs v4 | **UUIDs v4 puros** (os IDs numéricos das planilhas são totalmente descartados após o parsing relacional) |
| **Famílias & Casais** | Grade padronizada (2 casais por GC) | **354 famílias reais**, 201 casamentos, 148 filhos |
| **Discipulado & Juntas** | Gerado por maturidade de batismo | **88 vínculos diretos com ID** (`discipler_id`) + **530 discipuladores por nome livre** (`custom_discipler_name` sem adivinhar IDs faltantes) |
| **Gabriel Góes Braga** | Conta de desenvolvedor | Conta de desenvolvedor vinculada à família de Fernando no GC Heliópolis |
| **Retiros, Posts & Ensino** | Completo com 3 retiros, 5 formulários, 13 posts | Completo com 3 retiros, 5 formulários, 13 posts e inscrições reais |

---

## 2. Como Executar

### Executar a Opção 1 (Mock Sintético):
```bash
npm run db:seed
```

### Executar a Opção 2 (Censo Real a partir dos CSVs):
```bash
npm run db:seed:real
```

### Regenerar o SQL do Censo Real caso as planilhas CSV sejam atualizadas:
```bash
npm run db:seed:generate
```

### Como Verificar a Consistência dos Dados:
Você pode executar o script de diagnóstico a qualquer momento (compatível com ambas as opções de seed):
```bash
node scripts/verify_seed.js
```

---

## 3. Estrutura Territorial e Mapeamento dos Dados Reais (Opção 2)

### Setores Oficiais (6 Setores):
1. `São Gabriel/Pampulha` (5 Grupos)
2. `Venda Nova/Neves` (7 Grupos)
3. `Santa Luzia` (6 Grupos)
4. `Oeste` (7 Grupos)
5. `Betim/Contagem` (8 Grupos)
6. `Fora da Localidade` (2 Grupos: Sete Lagoas e Santa Bárbara)

### Coordenadas Geográficas (GPS):
Todas as 35 coordenadas de Latitude e Longitude vêm diretamente da planilha `Grupos.csv` (ex: Solimões `-19.8392, -43.9185`, Milionários `-19.981, -43.9965`), garantindo que o mapa interativo (`/`) exiba os pins nos locais reais de reunião das casas.

### Líderes dos Grupos Caseiros:
Os líderes informados na planilha (ex: "Fernando e Samuel", "Carlos Eduardo e Guilherme", "Davi Cunha", "Júlio", "Artur") foram associados aos seus respectivos perfis e atribuídos como `leader_1_id` e `leader_2_id` na tabela `public.home_groups`.

---

## 4. Tratamento dos Identificadores e Relações (Anti-Vazamento de IDs de Exemplo)

*   **Descarte Absoluto dos IDs Numéricos de Exemplo:** Os números de linha e códigos numéricos gerados nas planilhas (ex: `101`, `102`, `101001`, `102009`) servem **estritamente como chaves transitórias em memória** para reconstruir o grafo relacional durante o parsing. Nenhum desses números é mantido no banco ou exposto na aplicação.
*   **Identificadores no Banco (UUIDs):** Todos os registros em `sectors`, `home_groups`, `profiles` e `auth.users` utilizam UUIDs padrão v4 (`crypto.randomUUID()`).
*   **Fidelidade Estrita ao Censo Real (Sem Invenção de Dados Fictícios):** Na Opção 2 (`seed-real.sql`), nenhum email, telefone, CPF, avatar ou dados socioeconômicos artificiais são inventados para os irmãos das planilhas. Somente dados expressamente constantes do CSV (Nome, Sexo, Bairro, Situação, Família, Companheiro, Discipulador e as 4 datas de nascimento reais) são preservados.
*   **Perfis Fantasmas e Crianças:** 818 registros são inseridos como perfis sem conta autenticada (`user_id = NULL`), divididos em:
    *   148 Crianças (`Situação = 'Filho de discípulo'`) vinculadas a seus pais.
    *   670 Discípulos Adultos (`Situação = 'Vinculado'`), que funcionam como **phantom users**. Quando qualquer um desses irmãos realizar cadastro no aplicativo (Sign Up), a trigger `handle_new_user()` fará a vinculação automática por CPF ou email ao seu perfil existente.
*   **Exatamente 3 Contas Autenticadas (`auth.users`):**
    *   **Gabriel Góes Braga:** email `ggoesbraga@gmail.com`, telefone `(31) 99888-7777`, CPF `132.507.246-02`, nascimento `08/07/1995`, batismo `15/06/2012`, permissão `is_dev = true` SOMENTE (`is_presbyter = false`, `is_deacon = false`, `can_post = true`). Filho de Fernando e Clara no GC Heliópolis.
    *   **Fernando Gomes Braga:** email `fgb80@yahoo.com`, telefone `(31) 99123-4567`, CPF `103.821.540-52`, nascimento `12/04/1966`, batismo `20/06/1984`, permissão `is_presbyter = true` (`is_dev = false`, `is_deacon = false`, `can_post = true`). Líder do GC Heliópolis, marido de Clara e pai de Gabriel.
    *   **Clara Góes Braga:** email `claradiscipula@gmail.com`, telefone `(31) 99123-4568`, CPF `167.370.473-66`, nascimento `15/09/1968`, batismo `10/11/1986`, sem permissões administrativas (`is_presbyter = false`, `is_deacon = false`, `is_dev = false`, `can_post = false`). Membro do GC Heliópolis, esposa de Fernando e mãe de Gabriel.
*   **Deduplicação de Movimentações:** Registros com situação "Mudou de Grupo" (ex: Brenda e Shibas) são resolvidos para seus grupos ativos vigentes.
*   **Casamentos (`spouse_id`):** 201 casais identificados através do agrupamento por família em cada GC, ligados bidirecionalmente em `profiles`.
*   **Filiação (`father_id`, `mother_id`):** Todos os 148 filhos de discípulo (`Situação = 'Filho de discípulo'`) foram vinculados aos seus pais na família.
*   **Discipulado (`discipler_id` e `custom_discipler_name`):** 
    *   **Com ID explícito (88 discípulos):** Discípulos que possuem `ID Discipulador` preenchido e correspondente a um ID válido no censo (mais a vinculação explícita de Gabriel a Fernando) têm `discipler_id` preenchido e `custom_discipler_name = NULL`.
    *   **Sem ID no censo (530 discípulos):** Onde o ID estava ausente, o sistema **não tenta adivinhar o vínculo**. O nome informado é gravado na coluna `custom_discipler_name` e `discipler_id` permanece `NULL`. A UI do sistema (`DiscipleCard`, `RelationshipGraphView`, `Profile`) reconhece esse estado provisório e alerta para vinculação posterior.
*   **Juntas de Companheirismo (`fellowships`):** Pares mútuos com IDs válidos e juntas do presbitério (sem geração por adivinhação).

---

## 5. Plataforma de Ensino & Catequese

O módulo de Ensinos (`public.studies`, `public.media_resources`, `public.study_steps`, `public.user_study_progress`) contém:
*   **Trilha 1: O Propósito Eterno de Deus:** Visão central de Romanos 8 e Efésios 1 (3 etapas: vídeo, caderno de estudo PDF e artigo teológico).
*   **Trilha 2: Juntas e Ligamentos — O Discipulado Prático:** Relacionamentos de transparência e amor fraternal (2 etapas: vídeo e caderno prático PDF).
*   **Trilha 3: O Sacerdócio Universal e a Dinâmica nas Casas:** Todos os santos em serviço e operação dos dons (3 etapas: vídeo, artigo e dinâmica das casas).
*   **Progresso de Gabriel Góes Braga:** Possui etapas concluídas e anotações ativas.

> [!NOTE]
> Na Opção 1 (`seed.sql`), 6 contas fictícias de estudos (`lucas.estudos@email.com`, etc.) são criadas para demonstração de visitantes externos não vinculados (`is_church_linked = false`). Na Opção 2 (`seed-real.sql`), preserva-se o censo real estrito, sem criação de contas fictícias adicionais.

---

## 6. Ciclo de Eventos, Alojamentos, Finanças & Fichas de Inscrição

*   **Retiro Ativo (`Retiro de Solteiros e Jovens 2026`):** Inscrições abertas, inscritos reais, quartos (Chalés e Dormitórios), despesas operacionais e formulário dedicado `form-solteiros-2026`.
*   **Retiro Encerrado (`Retiro de Carnaval 2026`):** Histórico com fechamento financeiro, prestação de contas e formulário `form-carnaval-2026`.
*   **Retiro em Rascunho (`Encontro Metropolitano de Casais nas Casas 2026`):** Planejamento com formulário `form-casais-2026`.

---

## 7. Mural Centralizado de Notícias, Encontros & Avisos

13 posts abrangendo todas as categorias (`geral`, `oracao`, `missoes`, `encontro`, `estudo`, `formulario`, `evento`), com suporte a visibilidade pública/interna e autores correspondentes a líderes e presbíteros reais.
