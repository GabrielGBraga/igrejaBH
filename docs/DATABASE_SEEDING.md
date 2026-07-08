# Seeding do Banco de Dados de Desenvolvimento (`igrejaBH-DEV`)

Este documento descreve o funcionamento, a estrutura e a lógica de geração dos dados de teste para o portal da Igreja em Belo Horizonte.

---

## 1. Visão Geral
O objetivo deste seeding é fornecer um banco de dados de desenvolvimento completo, coerente e com grande volumetria de dados para simulações e apresentações de demonstração (demos). 

O script de seeding é capaz de repopular o banco do zero em uma única execução, limpando dados antigos e recriando um grafo de **528 discípulos/perfis** distribuídos por **24 Grupos Caseiros (GCs)** e **6 regiões/setores**.

---

## 2. Como Executar
O seeding pode ser executado a qualquer momento rodando o seguinte comando no terminal do projeto:

```bash
npm run db:seed
```

### O que o comando faz nos bastidores:
1. Carrega as variáveis de ambiente a partir de `.env` e `.env.local` (procurando pela senha `DEV_DB_PASSWORD` e pela URL `VITE_SUPABASE_URL` para extrair o ID do projeto).
2. Lê o arquivo SQL completo de [seed.sql](file:///c:/Users/ggoes/Documents/igrejaBH/supabase/seed.sql).
3. Conecta-se diretamente ao banco de dados remoto do Supabase usando a porta padrão do PostgreSQL (5432) com SSL.
4. Limpa todas as tabelas públicas (`TRUNCATE ... CASCADE`) e de autenticação (`DELETE FROM auth.users`).
5. Executa todas as inserções e associações relacionais de forma transacional e atômica.

---

## 3. Estrutura Territorial e Volumetria dos Dados
Os dados de teste são divididos em:
*   **6 Setores (Regiões):** `Barreiro/Oeste`, `Pampulha/São Gabriel`, `Santa Luzia`, `Venda Nova`, `Betim` e `Contagem`.
*   **24 Grupos Caseiros (GCs):** 4 em cada setor, nomeados de acordo com os bairros da respectiva região.
*   **Coordenadas Geográficas (Lat/Lng):** Geradas programaticamente a partir de um desvio aleatório em torno do centro de cada região. Isso garante que a visualização de mapas no frontend exiba marcações espalhadas de forma correta e sem sobreposições perfeitas.

### Distribuição Interna por GC (22 membros em cada GC):
Para garantir diversidade de testes, cada grupo caseiro possui exatamente:
*   **2 Líderes (Homens Casados):** 48 no total. Adultos que também exercem funções no discipulado e no companheirismo comunitário.
*   **2 Esposas dos Líderes (Mulheres Casadas):** 48 no total.
*   **2 Maridos de Família Comum (Homens Casados):** 48 no total.
*   **2 Esposas da Família (Mulheres Casadas):** 48 no total.
*   **2 Filhos Pequenos (Menores de idade, Não Batizados):** 48 no total. Cadastrados em `public.profiles` com `user_id = NULL` (perfis fantasmas) e vinculados aos pais por `father_id` e `mother_id`.
*   **2 Filhos Adolescentes/Jovens Adultos (Batizados, Solteiros):** 48 no total. Possuem conta de acesso em `auth.users` e data de batismo, mas continuam vinculados aos perfis dos pais.
*   **3 Idosos (Membros Seniores, Perfis Fantasmas):** 72 no total. Membros acima de 70 anos sem conta de autenticação (`user_id = NULL`).
*   **7 Solteiros Ordinários (Adultos):** 168 no total. Jovens/adultos sem laços de casamento e sem vínculo de moradia com as famílias locais do GC.

**Totais Gerais do Banco:**
*   **Contas de Acesso (`auth.users`):** 408 usuários (todos com a senha inicial `senha123`).
*   **Perfis de Discípulos (`public.profiles`):** 528 perfis (408 com conta ativa + 120 perfis fantasmas).

---

## 4. Regras Estruturais de Relacionamentos (Juntas e Ligamentos)
O pós-processamento do script de seeding aplica regras restritas para refletir o modelo relacional orgânico descrito no projeto:

### Gênero e Casamento
*   **Segregação:** O discipulado e os laços de companheirismo ocorrem estritamente entre pessoas do mesmo gênero (homem discipula/é companheiro de homem; mulher discipula/é companheira de mulher).
*   **Casamento:** Os casamentos são estritamente heterossexuais, ligados bidirecionalmente na tabela `profiles` através do campo `spouse_id`.
*   **Juntas de Casados:** Para simular redes de casais, cada pessoa casada possui juntas de companheirismo (`fellowships`) com **exatamente 2 outros casados** do mesmo gênero e com maturidade semelhante.

### Maturidade Espiritual (Data de Batismo)
*   **Maturidade Cronológica no Discipulado:** A data de batismo (`baptism_date`) é utilizada como indexador de maturidade espiritual. Um discipulador (`discipler_id`) deve obrigatoriamente ter uma data de batismo mais antiga do que a de seu discipulando (`discipler.baptism_date < disciple.baptism_date`).
*   **Proximidade no Companheirismo:** Os companheiros de junta (`fellowships`) devem ter datas de batismo próximas, com no máximo 6 anos de diferença (10 anos para membros idosos).

### Hierarquia e Juntas Especiais
*   **Cargos do Presbitério e Diaconato:**
    *   Exatamente **4 Presbíteros** são designados a partir dos líderes. Eles possuem uma malha fechada e completa de companheirismo entre si (todos conectados a todos os outros presbíteros).
    *   Exatamente **6 Diáconos** (incluindo `Gabriel Góes Braga`) são definidos. Eles não possuem malha completa entre si, mas todos os 6 são obrigatoriamente discipulados por um dos 4 presbíteros.
*   **Líderes:** Todos os 48 líderes de GC devem ser discipulados por outros líderes (que podem ser presbíteros, diáconos ou líderes mais antigos).
*   **Membros Comuns:** Casados, solteiros e adolescentes são discipulados por líderes do mesmo gênero com batismo mais antigo, ou por outros membros comuns experientes de mesmo gênero (simulando juntas onde nenhum dos participantes é líder).

---

## 5. Como Customizar os Dados
Se você precisar alterar a volumetria, os nomes ou adicionar novas regras, modifique o bloco transacional em `supabase/seed.sql`:
*   Para mudar os nomes comuns gerados, altere os arrays `s_names` (nomes masculinos), `s_fnames` (nomes femininos) e `s_surnames` (sobrenomes) declarados no topo do script.
*   Para ajustar o tamanho dos grupos caseiros ou a proporção de famílias/solteiros, altere os laços internos de repetição no script.
