-- Parte 1: Tipos e Tabelas Base
CREATE TYPE public.media_type AS ENUM ('video', 'pdf', 'markdown');
CREATE TYPE public.post_category AS ENUM ('noticia', 'oracao', 'diaconato', 'obra', 'aviso', 'evento');
CREATE TYPE public.retreat_form_model AS ENUM ('geral', 'socioeconomico', 'logistica');

CREATE TABLE public.profiles (
    id uuid PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
    user_id uuid UNIQUE,
    full_name text NOT NULL,
    birth_date date,
    baptism_date date,
    phone text,
    is_presbyter boolean DEFAULT false,
    is_deacon boolean DEFAULT false,
    is_dev boolean DEFAULT false,
    can_post boolean DEFAULT false,
    home_group_id uuid,
    discipler_id uuid,
    gender text,
    marital_status text,
    address_street text,
    address_number text,
    address_complement text,
    address_neighborhood text,
    address_city text DEFAULT 'Belo Horizonte',
    address_state text DEFAULT 'MG',
    address_zip_code text,
    cpf text,
    avatar_url text,
    spouse_id uuid REFERENCES public.profiles(id),
    father_id uuid REFERENCES public.profiles(id),
    mother_id uuid REFERENCES public.profiles(id),
    created_at timestamptz DEFAULT now()
);

CREATE TABLE public.home_groups (
    id uuid PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
    meeting_day smallint CHECK (meeting_day >= 0 AND meeting_day <= 6),
    start_time time,
    location_text text,
    leader_1_id uuid REFERENCES public.profiles(id),
    leader_2_id uuid REFERENCES public.profiles(id),
    lat float8,
    lng float8,
    created_at timestamptz DEFAULT now()
);

-- Adicionar FK circular
ALTER TABLE public.profiles ADD CONSTRAINT profiles_home_group_id_fkey FOREIGN KEY (home_group_id) REFERENCES public.home_groups(id);
ALTER TABLE public.profiles ADD CONSTRAINT profiles_discipler_id_fkey FOREIGN KEY (discipler_id) REFERENCES public.profiles(id);

-- Parte 2: ConteÃºdo
CREATE TABLE public.fellowships (
    member_a_id uuid REFERENCES public.profiles(id),
    member_b_id uuid REFERENCES public.profiles(id),
    created_at timestamptz DEFAULT now(),
    PRIMARY KEY (member_a_id, member_b_id)
);

CREATE TABLE public.posts (
    id uuid PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
    author_id uuid REFERENCES public.profiles(id),
    category public.post_category DEFAULT 'noticia',
    title text NOT NULL,
    content text NOT NULL,
    event_start_date timestamptz,
    event_end_date timestamptz,
    is_published boolean DEFAULT true,
    image_urls text[] DEFAULT '{}',
    created_at timestamptz DEFAULT now()
);

CREATE TABLE public.media_resources (
    id uuid PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
    title text NOT NULL,
    description text,
    type public.media_type NOT NULL,
    url text NOT NULL,
    series_name text,
    category text,
    created_at timestamptz DEFAULT now()
);

CREATE TABLE public.retreats (
    id uuid PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
    title text NOT NULL,
    price numeric DEFAULT 0.00,
    form_model public.retreat_form_model DEFAULT 'geral',
    start_date date,
    end_date date,
    created_at timestamptz DEFAULT now()
);

CREATE TABLE public.registrations (
    id uuid PRIMARY KEY DEFAULT extensions.uuid_generate_v4(),
    retreat_id uuid REFERENCES public.retreats(id),
    profile_id uuid REFERENCES public.profiles(id),
    guest_data jsonb,
    custom_responses jsonb,
    paid boolean DEFAULT false,
    created_at timestamptz DEFAULT now()
);

-- Parte 3: RLS e PolÃ­ticas
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.home_groups ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.fellowships ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.media_resources ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.retreats ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.registrations ENABLE ROW LEVEL SECURITY;

-- Profiles
CREATE POLICY "UsuÃ¡rios autenticados podem ver perfis" ON public.profiles FOR SELECT TO authenticated USING (true);
CREATE POLICY "UsuÃ¡rios podem atualizar seus prÃ³prios perfis" ON public.profiles FOR UPDATE TO authenticated USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- Home Groups
CREATE POLICY "UsuÃ¡rios autenticados podem ver grupos caseiros" ON public.home_groups FOR SELECT TO authenticated USING (true);
CREATE POLICY "Devs e presbiteros podem gerenciar grupos caseiros" ON public.home_groups FOR ALL USING (EXISTS (SELECT 1 FROM profiles WHERE profiles.user_id = auth.uid() AND (profiles.is_dev = true OR profiles.is_presbyter = true)));

-- Content
CREATE POLICY "UsuÃ¡rios autenticados podem ver postagens" ON public.posts FOR SELECT TO authenticated USING (is_published = true);
CREATE POLICY "UsuÃ¡rios podem ver suas prÃ³prias comunhÃµes" ON public.fellowships FOR SELECT TO authenticated USING ((auth.uid() = member_a_id) OR (auth.uid() = member_b_id));

-- Media Resources
CREATE POLICY "UsuÃ¡rios autenticados podem ver recursos de mÃ­dia" ON public.media_resources FOR SELECT TO authenticated USING (true);
CREATE POLICY "Permitir leitura para todos autenticados" ON public.media_resources FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Permitir inserÃ§Ã£o para lideranÃ§a" ON public.media_resources FOR INSERT WITH CHECK (EXISTS (SELECT 1 FROM profiles WHERE profiles.user_id = auth.uid() AND (profiles.is_presbyter = true OR profiles.is_deacon = true OR profiles.is_dev = true)));
CREATE POLICY "Permitir delete para lideranÃ§a" ON public.media_resources FOR DELETE USING (EXISTS (SELECT 1 FROM profiles WHERE profiles.user_id = auth.uid() AND (profiles.is_presbyter = true OR profiles.is_deacon = true OR profiles.is_dev = true)));

-- Retreats & Registrations
CREATE POLICY "UsuÃ¡rios autenticados podem ver retiros" ON public.retreats FOR SELECT TO authenticated USING (true);
CREATE POLICY "UsuÃ¡rios podem ver suas prÃ³prias inscriÃ§Ãµes" ON public.registrations FOR SELECT TO authenticated USING (profile_id IN (SELECT id FROM profiles WHERE user_id = auth.uid()));
CREATE POLICY "UsuÃ¡rios podem criar suas prÃ³prias inscriÃ§Ãµes" ON public.registrations FOR INSERT TO authenticated WITH CHECK (profile_id IN (SELECT id FROM profiles WHERE user_id = auth.uid()));
