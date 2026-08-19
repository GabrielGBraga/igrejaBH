-- ============================================================================
-- MIGRAÇÃO: ATUALIZAÇÃO DAS CONSTRAINTS DE GÊNERO E CATEGORIAS DE DESPESAS
-- Permite o tipo de quarto 'suite' e categorias flexíveis de gastos
-- ============================================================================

ALTER TABLE public.retreat_rooms
  DROP CONSTRAINT IF EXISTS retreat_rooms_gender_type_check;

ALTER TABLE public.retreat_rooms
  ADD CONSTRAINT retreat_rooms_gender_type_check
  CHECK (gender_type IN ('masculino', 'feminino', 'suite', 'misto', 'familia'));

ALTER TABLE public.retreat_expenses
  DROP CONSTRAINT IF EXISTS retreat_expenses_category_check;

ALTER TABLE public.retreat_expenses
  ADD CONSTRAINT retreat_expenses_category_check
  CHECK (lower(category) IN ('aluguel', 'local', 'alimentacao', 'transporte', 'material', 'som', 'som_multimidia', 'outros'));
