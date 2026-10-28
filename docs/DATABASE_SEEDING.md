# Seeding do Banco de Dados de Desenvolvimento (`igrejaBH-DEV`)

Este documento descreve o funcionamento, a estrutura e a lógica de geração dos dados oficiais e territoriais para o portal da Igreja em Belo Horizonte.

---

## 1. Visão Geral

O novo seeding foi construído a partir do levantamento cadastral real contido em `Igreja em BH - Grupos.csv`, substituindo integralmente a antiga massa de dados sintética.

O script recria um ecossistema 100% autêntico e limpo em menos de 1 segundo:
- **6 Setores Geográficos Oficiais:**
  1. `São Gabriel/Pampulha` (5 Grupos Caseiros)
  2. `Venda Nova/Neves` (7 Grupos Caseiros)
  3. `Santa Luzia` (6 Grupos Caseiros)
  4. `Oeste` (7 Grupos Caseiros)
  5. `Betim/Contagem` (8 Grupos Caseiros)
  6. `Fora da Localidade` (2 Grupos Caseiros)
- **35 Grupos Caseiros (GCs):**
  - Mapeados com coordenadas geográficas exatas (`lat`, `lng`), logradouros, bairros e cidades da Região Metropolitana de Belo Horizonte e municípios adjacentes.
  - Horário padrão de reunião às 19:30 às quartas-feiras (`meeting_day: 3`).
- **Liderança e Núcleos Reais (~89 Perfis Cadastrados):**
  - Todos os perfis representam os irmãos líderes e cooperadores de núcleo identificados no CSV.
  - Todos cadastrados com vínculo com a igreja (`is_church_linked = true`).
  - **Inclusão Progressiva de Acessos:** Todos os perfis (exceto o dev) possuem `email = NULL` e `user_id = NULL`. E-mails reais e convites serão adicionados pela liderança posteriormente.
- **Perfil do Desenvolvedor (Gabriel Góes Braga):**
  - Vinculado ao grupo de **Fernando e Samuel (GC 102 - Heliópolis - BH)**.
  - E-mail oficial: `ggoesbraga@gmail.com`.
  - Credenciais de autenticação em `auth.users` com senha padrão `senha123`.
  - Atribuições estritas: `is_dev = true`, `is_presbyter = false`, `is_deacon = false`, `can_post = true`.
- **Catálogo de Ensinos & Formulários:**
  - Preservadas as 3 Trilhas de estudo (`studies`), 8 etapas (`study_steps`) e recursos multimídia (`media_resources`).
  - Preservados os 5 modelos de formulários oficiais (`forms`).
  - 100% limpas as tabelas de movimentação de teste (`posts`, `retreats`, `registrations`, `retreat_rooms`, `retreat_expenses`, `fellowships`, `form_submissions`, `user_study_progress`, `study_notes`, `event_coupons`, `event_waitlist`).

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
4. Limpa todas as tabelas públicas (`TRUNCATE ... CASCADE`) e de autenticação (`DELETE FROM auth.users`).
5. Insere os 6 setores, 35 grupos caseiros, perfis da liderança/núcleo, dev e catálogo base de forma atômica e transacional.

---

## 3. Como Verificar a Consistência dos Dados

Você pode executar o script de diagnóstico a qualquer momento:

```bash
node scripts/verify_seed.js
```

O script valida automaticamente:
1. Contagem exata de setores (6) e grupos caseiros (35).
2. Latitude e Longitude válidas em todos os 35 grupos.
3. Existência do perfil de Gabriel Góes Braga no GC 102 com `is_dev = true` e perfil de acesso em `auth.users`.
4. Ausência de e-mails em perfis de outros membros (zero e-mails artificiais).
5. Limpeza total de posts, retiros e inscrições de teste.
6. Integridade do acervo de Ensinos e Formulários.

---

## 4. Estrutura dos 35 Grupos Caseiros

| ID | Setor | Líder(es) | Bairro / Cidade | Coordenadas |
|---|---|---|---|---|
| **101** | São Gabriel/Pampulha | Flávio | Solimões - BH | -19.8392, -43.9185 |
| **102** | São Gabriel/Pampulha | Fernando e Samuel | Heliópolis - BH | -19.8425, -43.9482 |
| **103** | São Gabriel/Pampulha | Carlos Eduardo e Guilherme | São Gabriel - BH | -19.8580, -43.9160 |
| **104** | São Gabriel/Pampulha | Eduardo Lopes | Santa Amélia - BH | -19.8361, -43.9724 |
| **105** | São Gabriel/Pampulha | Ademir | Jardim Vitória - BH | -19.8456, -43.8891 |
| **201** | Venda Nova/Neves | Helder | Santa Branca - BH | -19.8268, -43.9685 |
| **202** | Venda Nova/Neves | Juarez | Santa Branca - BH | -19.8245, -43.9660 |
| **203** | Venda Nova/Neves | Marinho | Maria Helena - Neves | -19.7985, -44.0092 |
| **204** | Venda Nova/Neves | Luís | Maria Helena - Neves | -19.7992, -44.0105 |
| **205** | Venda Nova/Neves | Cleber | Leblon - BH | -19.8115, -43.9880 |
| **206** | Venda Nova/Neves | Douglas e Dimas | Sevilha B - Neves | -19.7695, -44.0812 |
| **207** | Venda Nova/Neves | Jaime e Wagner | Areias - Neves | -19.7820, -43.9850 |
| **301** | Santa Luzia | Davi Cunha | Santa Matilde - Santa Luzia | -19.7668, -43.8582 |
| **302** | Santa Luzia | Neto | Lagoa Santa | -19.6328, -43.8906 |
| **303** | Santa Luzia | Fernando | São Benedito - Santa Luzia | -19.7825, -43.9145 |
| **304** | Santa Luzia | Ricardo e Jesus | Fazendinha do Baú - Santa Luzia | -19.7755, -43.8720 |
| **305** | Santa Luzia | Roberto, Álvaro e Rodrigo | Córrego das Calçadas - Santa Luzia | -19.7590, -43.8510 |
| **306** | Santa Luzia | Maurício e Diogo | Cristina B - Santa Luzia | -19.7762, -43.9248 |
| **401** | Oeste | Júlio | Novo Tirol - BH | -19.9985, -44.0315 |
| **402** | Oeste | Rafael e Shibas | Milionários - BH | -19.9810, -43.9965 |
| **403** | Oeste | Claudio, Davi e Lúcio | Tropical / Jacuba - Contagem | -19.9265, -44.1150 |
| **404** | Oeste | Willian Batista | Novo Progresso - Contagem | -19.8980, -44.0390 |
| **405** | Oeste | José Alfredo | Bela Vista / Barreiro - Ibirité | -20.0080, -44.0520 |
| **406** | Oeste | João Pedro e Thiago | Salgado Filho - BH | -19.9412, -43.9825 |
| **407** | Oeste | Jardir | Nova Suíça - BH | -19.9445, -43.9734 |
| **501** | Betim/Contagem | Emerson | São José - Esmeraldas | -19.7615, -44.3140 |
| **502** | Betim/Contagem | Juan e Alexandre | Jardim Riacho - Contagem | -19.9565, -44.0410 |
| **503** | Betim/Contagem | Jairo | Marimbá - Betim | -19.9320, -44.2750 |
| **504** | Betim/Contagem | Wiliam Pereira | Resplendor - Igarapé | -20.0680, -44.2980 |
| **505** | Betim/Contagem | Cléber, Caio e Marcelo | Jardim Alterosa - Betim | -19.9610, -44.1720 |
| **506** | Betim/Contagem | Marilson | Três Barras - Contagem | -19.9145, -44.0885 |
| **507** | Betim/Contagem | Artur | Eldorado - Contagem | -19.9380, -44.0395 |
| **508** | Betim/Contagem | Lucas Augusto Santos | Ponte Alta - Betim | -19.8960, -44.2030 |
| **901** | Fora da Localidade | Douglas Martins e Cláudio Lopes | Interlagos - Sete Lagoas | -19.4752, -44.2368 |
| **902** | Fora da Localidade | José Antônio | Santa Bárbara | -19.9595, -43.4150 |
