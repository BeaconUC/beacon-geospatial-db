ALTER POLICY "Users can create their own outage reports"
    ON public.outage_reports
    WITH CHECK (
        reported_by IS NULL
            OR EXISTS (
            SELECT 1
            FROM public.profiles p
            WHERE p.user_id = (SELECT auth.uid())
              AND p.id = outage_reports.reported_by
        )
    );

ALTER POLICY "Crew and admin can read crews"
    ON public.crews
    USING (
        EXISTS (
            SELECT 1 FROM public.profiles p
            WHERE p.user_id = (SELECT auth.uid())
              AND p.role IN ('crew', 'admin')
        )
    );

ALTER POLICY "Crew and admin can read assignments"
    ON public.assignments
    USING (
        EXISTS (
            SELECT 1 FROM public.profiles p
            WHERE p.user_id = (SELECT auth.uid())
              AND p.role IN ('crew', 'admin')
        )
    );

ALTER POLICY "Users can read their own API keys"
    ON public.api_keys
    USING (
        EXISTS (
            SELECT 1
            FROM public.profiles p
            WHERE p.user_id = (SELECT auth.uid())
              AND p.id = api_keys.created_by
        )
    );

ALTER POLICY "Users can create their own API keys"
    ON public.api_keys
    WITH CHECK (
        EXISTS (
            SELECT 1
            FROM public.profiles p
            WHERE p.user_id = (SELECT auth.uid())
              AND p.id = api_keys.created_by
        )
    );

ALTER POLICY "Users can update their own API keys"
    ON public.api_keys
    USING (
        EXISTS (
            SELECT 1
            FROM public.profiles p
            WHERE p.user_id = (SELECT auth.uid())
              AND p.id = api_keys.created_by
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1
            FROM public.profiles p
            WHERE p.user_id = (SELECT auth.uid())
              AND p.id = api_keys.created_by
        )
    );