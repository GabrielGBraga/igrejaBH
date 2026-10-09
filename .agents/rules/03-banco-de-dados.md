# Esquema de Dados (Supabase) e RLS

## 1. Tabelas Principais
- `profiles`: Armazena dados pessoais, papéis (is_presbyter, is_deacon) e relacionamentos (discipler_id, home_group_id, spouse, etc).
- `home_groups`: Define os locais de reunião, dia e líderes. Tem `lat` e `lng` para mapas. Relaciona-se com `sectors`.
- `sectors`: Agrupamentos macro geográficos que contêm múltiplos Grupos Caseiros.
- `fellowships`: Registra vínculos intencionais de companheirismo entre dois discípulos (`member_a_id`, `member_b_id`).
- `posts`: Unifica notícias, pedidos de oração, avisos e diaconato através do ENUM `post_category`.
- `media_resources`: Central de vídeos (YouTube), PDFs e textos/leituras em Markdown.
- `studies`, `study_steps` & `user_study_progress`: Trilhas de aprendizado ordenadas (cursos) compostas por recursos e controle de conclusão por discípulo.
- `study_notes`: Anotações individuais e formatadas dos discípulos por estudo (`study_id`) ou por recurso (`media_resource_id`), protegidas via RLS (`profile_id`).
- `forms` & `form_submissions`: Sistema dinâmico de formulários. A tabela `forms` armazena o schema/JSON do template e `form_submissions` guarda as respostas dos usuários.
- `registrations` & `retreats`: Gestão de eventos, fichas de inscrição e controle de retiros.
- `retreat_rooms`: Gestão de quartos/alocação de alojamentos customizáveis por retiro (`retreat_id`, `gender_type`, `capacity`).
- `retreat_expenses`: Lançamento e controle de despesas/gastos por retiro para cálculo de resultado líquido (`retreat_id`, `category`, `amount`, `expense_date`).
- `event_coupons`: Códigos e cupons descartáveis para isenção e desconto em retiros (`retreat_id`, `code`, `cpf`, `discount_percent`).
- `event_waitlist`: Lista de espera automática por evento/retiro após esgotamento de vagas (`retreat_id`, `full_name`, `phone`, `email`, `travel_mode`, `status`).

## 2. Tratamento de Dados Sensíveis
- Dados como `cpf`, `household_income` (renda familiar), etc., só podem ser manipulados se o agente for instruído a criar interfaces administrativas de Diaconato.
- A aplicação roda sob **Row Level Security (RLS)**. O frontend DEVE assumir que consultas podem retornar vazio se o usuário não tiver permissão. Não escreva código que quebre se o array retornar vazio.

## 3. Tipagem
Sempre importar os tipos diretamente gerados pelo Supabase:
`import { Database } from '@/lib/database.types'`
Nunca reescreva ou crie interfaces "soltas" (como `interface Profile { ... }`). Estenda a tipagem do Supabase usando helpers utilitários quando necessário (ex: `type Profile = Database['public']['Tables']['profiles']['Row']`).
