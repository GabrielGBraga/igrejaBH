# Seeding do Banco de Dados de Desenvolvimento (`igrejaBH-DEV`)

Este documento descreve o funcionamento, a estrutura e a lógica de geração dos dados de teste para o portal da Igreja em Belo Horizonte.

---

## 1. Visão Geral
O objetivo deste seeding é fornecer um banco de dados de desenvolvimento completo, coerente e com grande volumetria de dados para simulações e apresentações de demonstração (demos). 

O script de seeding é capaz de repopular o banco do zero em uma única execução (~7 segundos), limpando dados antigos e recriando um ecossistema completo de:
- **528 discípulos/perfis** distribuídos por **24 Grupos Caseiros (GCs)** e **6 regiões/setores**.
- **Mural de Avisos Comunitário** com 14 posts abrangendo todas as 6 categorias (`noticia`, `oracao`, `diaconato`, `obra`, `aviso`, `evento`), com datas e fotos de capa.
- **Centro de Ensino e Catequese** com 3 trilhas estruturadas, 10 recursos multimídia (YouTube, PDFs, Markdown) e progresso ativo dos usuários.
- **Ciclo Completo de Eventos & Retiros** com 3 retiros (`ativo`, `encerrado`, `rascunho`), 18 alojamentos/quartos, 12 lançamentos financeiros/despesas e 140+ inscrições vinculadas.
- **Sistema de Formulários Dinâmicos** com 3 modelos (`form-solteiros-2026`, `form-censo-dons`, `form-apoio-diaconal`) e quase 150 submissões registradas.

---

## 2. Como Executar
O seeding pode ser executado a qualquer momento rodando o seguinte comando no terminal do projeto:

```bash
npm run db:seed
```

### O que o comando faz nos bastidores:
1. Carrega as variáveis de ambiente a partir de `.env` e `.env.local` (procurando pela senha `DEV_DB_PASSWORD` e pela URL `VITE_SUPABASE_URL` para extrair o ID do projeto).
2. Lê o arquivo SQL completo de [seed.sql](file:///c:/Users/ggoes/Documents/igrejaBH/supabase/seed.sql).
3. Conecta-se diretamente ao banco de dados remoto do Supabase usando a porta padrão do PostgreSQL (5432) com SSL (com fallback automático para connection pooler na porta 6543 caso IPv6 esteja indisponível).
4. Limpa todas as 15 tabelas públicas (`TRUNCATE ... CASCADE`) e de autenticação (`DELETE FROM auth.users`).
5. Executa todas as inserções e associações relacionais de forma transacional e atômica.

### Como Verificar a Consistência dos Dados:
Você pode executar o script de diagnóstico a qualquer momento:
```bash
node scripts/verify_seed.js
```

---

## 3. Estrutura Territorial e Volumetria dos Dados

### Setores e Grupos Caseiros
*   **6 Setores (Regiões):** `Barreiro/Oeste`, `Pampulha/São Gabriel`, `Santa Luzia`, `Venda Nova`, `Betim` e `Contagem`.
*   **24 Grupos Caseiros (GCs):** 4 em cada setor, nomeados de acordo com os bairros da respectiva região e localizados em endereços reais (ex: Av. Mário Werneck no Buritis, Av. Fleming no Ouro Preto, Av. José Faria da Rocha no Eldorado, Av. Campos de Ourique em Alterosa).
*   **Coordenadas Geográficas (Lat/Lng):** Geradas programaticamente a partir de centros urbanos reais de cada região, garantindo que o mapa interativo exiba marcações espalhadas sem sobreposições.

### Distribuição Interna por GC (22 discípulos em cada GC):
Para garantir diversidade nos testes e simulações, cada grupo caseiro possui exatamente:
*   **2 Líderes (Homens Casados):** 48 no total. Adultos que também exercem funções no discipulado e no companheirismo comunitário.
*   **2 Esposas dos Líderes (Mulheres Casadas):** 48 no total.
*   **2 Maridos de Família Comum (Homens Casados):** 48 no total.
*   **2 Esposas da Família (Mulheres Casadas):** 48 no total.
*   **2 Filhos Pequenos (Menores de idade, Não Batizados):** 48 no total. Cadastrados em `public.profiles` com `user_id = NULL` (perfis fantasmas) e vinculados aos pais por `father_id` e `mother_id`.
*   **2 Filhos Adolescentes/Jovens Adultos (Batizados, Solteiros):** 48 no total. Possuem conta de acesso em `auth.users` e data de batismo, mas continuam vinculados aos perfis dos pais.
*   **3 Idosos (Membros Seniores, Perfis Fantasmas):** 72 no total. Membros acima de 70 anos sem conta de autenticação (`user_id = NULL`), com nomes limpos (sem prefixos "Seu/Dona").
*   **7 Solteiros Ordinários (Adultos):** 168 no total. Jovens/adultos sem laços de casamento e sem vínculo de moradia com as famílias locais do GC.

**Totais Gerais do Banco:**
*   **Contas de Acesso (`auth.users`):** 408 usuários (todos com a senha inicial `senha123`).
*   **Perfis de Discípulos (`public.profiles`):** 528 perfis (408 com conta ativa + 120 perfis fantasmas).
*   **Fotos de Perfil (`avatar_url`):** 480 avatares em alta resolução (Unsplash Portraits) distribuídos por gênero e idade.
*   **Telefones Válidos:** 100% dos perfis com telefone possuem celulares brasileiros com máscara de 9 dígitos `(31) 9XXXX-XXXX`.

---

## 4. Regras Estruturais de Relacionamentos (Juntas e Ligamentos)

*   **Segregação por Gênero:** O discipulado e os laços de companheirismo ocorrem estritamente entre pessoas do mesmo gênero (homem discipula homem; mulher discipula mulher).
*   **Casamento:** Os casamentos são estritamente heterossexuais, ligados bidirecionalmente na tabela `profiles` através do campo `spouse_id`.
*   **Juntas de Casados:** Para simular redes de casais, cada pessoa casada possui juntas de companheirismo (`fellowships`) com **exatamente 2 outros casados** do mesmo gênero e com maturidade semelhante.
*   **Maturidade Cronológica no Discipulado:** A data de batismo (`baptism_date`) é utilizada como indexador de maturidade espiritual. Um discipulador (`discipler_id`) tem batismo mais antigo do que o discipulando (`discipler.baptism_date < disciple.baptism_date`).
*   **Presbíteros e Diáconos:**
    *   Exatamente **4 Presbíteros** com malha completa de companheirismo mútuo entre si e entre suas esposas.
    *   Exatamente **6 Diáconos** (incluindo `Gabriel Góes Braga`) discipulados por um dos presbíteros.

---

## 5. Plataforma de Ensino & Catequese

O módulo de Ensinos (`public.studies`, `public.media_resources`, `public.study_steps`, `public.user_study_progress`) contém:
*   **Trilha 1: O Propósito Eterno de Deus:** Visão central de Romanos 8 e Efésios 1 (3 etapas: vídeo, caderno de estudo PDF e artigo teológico).
*   **Trilha 2: Juntas e Ligamentos — O Discipulado Prático:** Relacionamentos de transparência e amor fraternal (2 etapas: vídeo e caderno prático PDF).
*   **Trilha 3: O Sacerdócio Universal e a Dinâmica nas Casas:** Todos os santos em serviço e operação dos dons (3 etapas: vídeo, artigo e dinâmica das casas).
*   **Progresso de Gabriel Góes Braga:** Possui 4 etapas concluídas (Trilha 1 100% finalizada e Trilha 2 em andamento), permitindo testar barras de progresso e certificados imediatamente no frontend.

---

## 6. Ciclo de Eventos, Alojamentos & Finanças

*   **Retiro Ativo (`Retiro de Solteiros e Jovens 2026`):** Inscrições abertas, 57 inscritos, 8 quartos (Chalés e Dormitórios), despesas operacionais parciais (sinal de locação, buffet, som).
*   **Retiro Encerrado (`Retiro de Carnaval 2026 — O Propósito Eterno`):** Evento histórico concluído, 85 inscritos 100% quitados, 6 quartos 100% alocados, e 5 despesas fechadas com demonstrativo de superávit financeiro positivo (ideal para testar os dashboards de KPI e resultado líquido em `ManageEventDetail`).
*   **Retiro em Rascunho (`Encontro Metropolitano de Casais nas Casas 2026`):** Evento em planejamento sem inscrições abertas, permitindo testar filtros de status no painel administrativo.

---

## 7. Como Customizar os Dados
Se você precisar alterar a volumetria, os nomes ou adicionar novas regras, modifique o bloco transacional em `supabase/seed.sql`:
*   Para mudar nomes comuns gerados, altere os arrays `s_names`, `s_fnames` e `s_surnames`.
*   Para ajustar o tamanho dos grupos caseiros ou a proporção de famílias/solteiros, altere os laços internos de repetição no script.
*   Execute `npm run db:seed` para reaplicar as alterações a qualquer instante.
