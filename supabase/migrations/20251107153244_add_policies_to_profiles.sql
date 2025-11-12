CREATE POLICY "Users can read their own profile"
    ON public.profiles
    FOR SELECT
    USING (
        EXISTS (
            SELECT 1
            FROM public.profiles p
            WHERE p.user_id = auth.uid()
              AND p.user_id = profiles.user_id
        )
    );

CREATE POLICY "Users can update their own profile"
    ON public.profiles
    FOR UPDATE
    USING (
        EXISTS (
            SELECT 1
            FROM public.profiles p
            WHERE p.user_id = auth.uid()
              AND p.user_id = profiles.user_id
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1
            FROM public.profiles p
            WHERE p.user_id = auth.uid()
              AND p.user_id = profiles.user_id
        )
    );