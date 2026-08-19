-- Tabela para gestão de quartos/alojamentos específicos por retiro/evento
CREATE TABLE IF NOT EXISTS public.retreat_rooms (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  retreat_id uuid REFERENCES public.retreats(id) ON DELETE CASCADE NOT NULL,
  name text NOT NULL,
  gender_type text DEFAULT 'misto' CHECK (gender_type IN ('masculino', 'feminino', 'misto', 'familia')),
  capacity integer DEFAULT 4 NOT NULL CHECK (capacity > 0),
  notes text,
  created_at timestamptz DEFAULT now()
);

-- Adiciona relacionamento room_id na tabela registrations
ALTER TABLE public.registrations 
ADD COLUMN IF NOT EXISTS room_id uuid REFERENCES public.retreat_rooms(id) ON DELETE SET NULL;

-- Tabela para lançamento de gastos e controle financeiro por retiro/evento
CREATE TABLE IF NOT EXISTS public.retreat_expenses (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  retreat_id uuid REFERENCES public.retreats(id) ON DELETE CASCADE NOT NULL,
  description text NOT NULL,
  category text DEFAULT 'outros' CHECK (category IN ('local', 'alimentacao', 'transporte', 'material', 'som_multimidia', 'outros')),
  amount numeric(10,2) NOT NULL DEFAULT 0.00 CHECK (amount >= 0),
  expense_date date DEFAULT CURRENT_DATE,
  notes text,
  created_by uuid REFERENCES public.profiles(id) ON DELETE SET NULL,
  created_at timestamptz DEFAULT now()
);

-- RLS para retreat_rooms
ALTER TABLE public.retreat_rooms ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Presbíteros, deacons e devs podem gerenciar quartos" ON public.retreat_rooms
FOR ALL TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.profiles 
    WHERE profiles.user_id = auth.uid() 
    AND (profiles.is_dev = true OR profiles.is_presbyter = true OR profiles.is_deacon = true)
  ) OR EXISTS (
    SELECT 1 FROM public.home_groups
    WHERE home_groups.leader_1_id IN (SELECT id FROM public.profiles WHERE user_id = auth.uid())
    OR home_groups.leader_2_id IN (SELECT id FROM public.profiles WHERE user_id = auth.uid())
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.profiles 
    WHERE profiles.user_id = auth.uid() 
    AND (profiles.is_dev = true OR profiles.is_presbyter = true OR profiles.is_deacon = true)
  ) OR EXISTS (
    SELECT 1 FROM public.home_groups
    WHERE home_groups.leader_1_id IN (SELECT id FROM public.profiles WHERE user_id = auth.uid())
    OR home_groups.leader_2_id IN (SELECT id FROM public.profiles WHERE user_id = auth.uid())
  )
);

-- RLS para retreat_expenses
ALTER TABLE public.retreat_expenses ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Presbíteros, deacons e devs podem gerenciar despesas" ON public.retreat_expenses
FOR ALL TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.profiles 
    WHERE profiles.user_id = auth.uid() 
    AND (profiles.is_dev = true OR profiles.is_presbyter = true OR profiles.is_deacon = true)
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.profiles 
    WHERE profiles.user_id = auth.uid() 
    AND (profiles.is_dev = true OR profiles.is_presbyter = true OR profiles.is_deacon = true)
  )
);
