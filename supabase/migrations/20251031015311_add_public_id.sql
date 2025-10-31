ALTER TABLE public.assignments
    ADD COLUMN public_id UUID DEFAULT extensions.gen_random_uuid() UNIQUE NOT NULL;