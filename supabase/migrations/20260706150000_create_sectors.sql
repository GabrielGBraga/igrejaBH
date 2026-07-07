-- Create sectors table
CREATE TABLE IF NOT EXISTS public.sectors (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- Enable RLS on sectors
ALTER TABLE public.sectors ENABLE ROW LEVEL SECURITY;

-- Allow select to all authenticated users
CREATE POLICY "Allow read access for all authenticated users" ON public.sectors
    FOR SELECT TO authenticated USING (true);

-- Allow write access to presbyters and devs
CREATE POLICY "Allow write access for presbyters and devs" ON public.sectors
    FOR ALL TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM public.profiles
            WHERE user_id = auth.uid() AND (is_presbyter = true OR is_dev = true)
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.profiles
            WHERE user_id = auth.uid() AND (is_presbyter = true OR is_dev = true)
        )
    );

-- Add sector_id to home_groups table
ALTER TABLE public.home_groups 
    ADD COLUMN IF NOT EXISTS sector_id UUID REFERENCES public.sectors(id) ON DELETE SET NULL;
