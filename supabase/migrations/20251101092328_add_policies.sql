-- PUBLIC READ
CREATE POLICY "Public can read geographic and weather data"
    ON public.provinces FOR SELECT USING (true);

CREATE POLICY "Public can read cities"
    ON public.cities FOR SELECT USING (true);

CREATE POLICY "Public can read barangays"
    ON public.barangays FOR SELECT USING (true);

CREATE POLICY "Public can read feeders"
    ON public.feeders FOR SELECT USING (true);

CREATE POLICY "Public can read weather_data"
    ON public.weather_data FOR SELECT USING (true);

CREATE POLICY "Public can read outages"
    ON public.outages FOR SELECT USING (true);

CREATE POLICY "Public can read outage_reports"
    ON public.outage_reports FOR SELECT USING (true);

CREATE POLICY "Public can read affected_areas"
    ON public.affected_areas FOR SELECT USING (true);

CREATE POLICY "Public can read outage_updates"
    ON public.outage_updates FOR SELECT USING (true);

-- AUTHENTICATED WRITE
CREATE POLICY "Users can create their own outage reports"
    ON public.outage_reports
    FOR INSERT
    TO authenticated
    WITH CHECK (
    reported_by IS NULL
        OR EXISTS (
        SELECT 1
        FROM public.profiles p
        WHERE p.user_id = auth.uid()
          AND p.id = outage_reports.reported_by
    )
    );

-- CREW/ADMIN READ
CREATE POLICY "Crew and admin can read crews"
    ON public.crews
    FOR SELECT
    TO authenticated
    USING (
    EXISTS (
        SELECT 1 FROM public.profiles p
        WHERE p.user_id = auth.uid() AND p.role IN ('crew', 'admin')
    )
    );

CREATE POLICY "Crew and admin can read assignments"
    ON public.assignments
    FOR SELECT
    TO authenticated
    USING (
    EXISTS (
        SELECT 1 FROM public.profiles p
        WHERE p.user_id = auth.uid() AND p.role IN ('crew', 'admin')
    )
    );

-- API_KEYS
CREATE POLICY "Users can read their own API keys"
    ON public.api_keys
    FOR SELECT
    TO authenticated
    USING (
    EXISTS (
        SELECT 1 FROM public.profiles p
        WHERE p.user_id = auth.uid()
          AND p.id = api_keys.created_by
    )
    );

CREATE POLICY "Users can create their own API keys"
    ON public.api_keys
    FOR INSERT
    TO authenticated
    WITH CHECK (
    EXISTS (
        SELECT 1 FROM public.profiles p
        WHERE p.user_id = auth.uid()
          AND p.id = api_keys.created_by
    )
    );

CREATE POLICY "Users can update their own API keys"
    ON public.api_keys
    FOR UPDATE
    TO authenticated
    USING (
    EXISTS (
        SELECT 1 FROM public.profiles p
        WHERE p.user_id = auth.uid()
          AND p.id = api_keys.created_by
    )
    )
    WITH CHECK (
    EXISTS (
        SELECT 1 FROM public.profiles p
        WHERE p.user_id = auth.uid()
          AND p.id = api_keys.created_by
    )
    );