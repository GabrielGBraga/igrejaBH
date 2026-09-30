-- Migration: Allow public read of retreats for public forms and clean coupon RPCs
-- 1. Ensure public/anon users can read retreats so public form responders can resolve associated event details
DROP POLICY IF EXISTS "Usuários autenticados podem ver retiros" ON public.retreats;
DROP POLICY IF EXISTS "Permitir leitura de retiros para todos" ON public.retreats;

CREATE POLICY "Permitir leitura de retiros para todos"
ON public.retreats
FOR SELECT
TO public
USING (true);

-- 2. Drop obsolete function overloads without p_cpf to prevent PostgREST ambiguity
DROP FUNCTION IF EXISTS public.redeem_coupon(text, text, text, text, text);
DROP FUNCTION IF EXISTS public.validate_coupon(text, text, text);

-- 3. Grant execute on coupon RPCs to public
GRANT EXECUTE ON FUNCTION public.redeem_coupon(text, text, text, text, text, text) TO anon, authenticated, public;
GRANT EXECUTE ON FUNCTION public.validate_coupon(text, text, text, text) TO anon, authenticated, public;
