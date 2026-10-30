-- Adiciona coluna custom_discipler_name para armazenar o nome em texto livre
-- quando o discipulador não for encontrado ou cadastrado no sistema
ALTER TABLE public.profiles
ADD COLUMN IF NOT EXISTS custom_discipler_name text DEFAULT NULL;

COMMENT ON COLUMN public.profiles.custom_discipler_name IS 
'Nome em texto do discipulador quando ele não possui conta ou cadastro de perfil no sistema (discipler_id é nulo).';
