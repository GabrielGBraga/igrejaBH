# Esquema de Dados (Supabase) e RLS

## 1. Tabelas Principais
- `profiles`: Armazena dados pessoais, papéis (is_presbyter, is_deacon) e relacionamentos (discipler_id, home_group_id, spouse, etc).
- `home_groups`: Define os locais de reunião, dia e líderes. Tem `lat` e `lng` para mapas.
- `posts`: Unifica notícias, pedidos de oração, avisos e diaconato através do ENUM `post_category`.
- `media_resources`: Central de vídeos (YouTube) e PDFs de estudo (Catequese).
- `registrations` & `retreats`: Gestão de eventos e pagamentos.

## 2. Tratamento de Dados Sensíveis
- Dados como `cpf`, `household_income` (renda familiar), etc., só podem ser manipulados se o agente for instruído a criar interfaces administrativas de Diaconato.
- A aplicação roda sob **Row Level Security (RLS)**. O frontend DEVE assumir que consultas podem retornar vazio se o usuário não tiver permissão. Não escreva código que quebre se o array retornar vazio.

## 3. Tipagem
Sempre importar os tipos diretamente gerados pelo Supabase:
`import { Database } from '@/lib/database.types'`
Nunca reescreva ou crie interfaces "soltas" (como `interface Profile { ... }`). Estenda a tipagem do Supabase usando helpers utilitários quando necessário (ex: `type Profile = Database['public']['Tables']['profiles']['Row']`).
