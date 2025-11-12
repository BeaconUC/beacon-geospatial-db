DROP POLICY IF EXISTS "Users can read their own profile" ON public.profiles;
DROP POLICY IF EXISTS "Admins can read all profiles" ON public.profiles;

CREATE POLICY "Profiles-Select-Access"
    ON public.profiles
    FOR SELECT
    USING (
        (auth.jwt() ->> 'role' = 'admin')
            OR (user_id = auth.uid())
    );