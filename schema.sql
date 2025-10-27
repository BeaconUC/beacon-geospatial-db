CREATE
EXTENSION IF NOT EXISTS postgis;
CREATE
EXTENSION IF NOT EXISTS postgis_topology;
CREATE
EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TYPE outage_status AS ENUM ('unverified', 'verified', 'being_resolved', 'resolved');
CREATE TYPE roles AS ENUM ('user', 'crew', 'admin');
CREATE TYPE outage_kind AS ENUM ('unscheduled', 'scheduled');

CREATE TABLE profiles
(
    id           UUID PRIMARY KEY REFERENCES auth.users (id) ON DELETE CASCADE,
    first_name   VARCHAR(100) NOT NULL,
    last_name    VARCHAR(100) NOT NULL,
    role         roles        NOT NULL DEFAULT 'user',
    phone_number VARCHAR(20),
    created_at   TIMESTAMPTZ           DEFAULT NOW(),
    updated_at   TIMESTAMPTZ           DEFAULT NOW()
);

CREATE TABLE outages
(
    id                    UUID PRIMARY KEY       DEFAULT uuid_generate_v4(),
    status                outage_status NOT NULL DEFAULT 'unverified',
    confidence_percentage FLOAT         NOT NULL DEFAULT 50.0 CHECK (confidence_percentage >= 0.0 AND confidence_percentage <= 100.0),
    title                 VARCHAR(255)  NOT NULL,
    description           TEXT,
    location              GEOMETRY(Point, 4326) NOT NULL,
    address               TEXT,
    barangay              VARCHAR(100),
    city                  VARCHAR(100)           DEFAULT 'Baguio',
    province              VARCHAR(100)           DEFAULT 'Benguet',
    affected_customers    INTEGER                DEFAULT 0,
    estimated_restoration TIMESTAMPTZ,
    actual_restoration    TIMESTAMPTZ,

    reported_by           UUID REFERENCES profiles (id),
    reported_at           TIMESTAMPTZ            DEFAULT NOW(),
    confirmed_by          UUID REFERENCES profiles (id),
    confirmed_at          TIMESTAMPTZ,
    resolved_by           UUID REFERENCES profiles (id),
    resolved_at           TIMESTAMPTZ,

    external_id           VARCHAR(255),
    external_source       VARCHAR(100),
    created_at            TIMESTAMPTZ            DEFAULT NOW(),
    updated_at            TIMESTAMPTZ            DEFAULT NOW()
);

CREATE TABLE outage_updates
(
    id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    outage_id   UUID NOT NULL REFERENCES outages (id) ON DELETE CASCADE,
    user_id     UUID REFERENCES profiles (id),
    old_status  outage_status,
    new_status  outage_status,
    description TEXT NOT NULL,
    created_at  TIMESTAMPTZ      DEFAULT NOW()
);

CREATE TABLE weather_data
(
    id                    UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    location              GEOMETRY(Point, 4326) NOT NULL,
    temperature           DECIMAL(4, 1),
    feels_like            DECIMAL(4, 1),
    humidity              INTEGER,
    atmospheric_pressure  INTEGER,
    dew_point             DECIMAL(4, 1),
    visibility            DECIMAL(5, 1),
    wind_speed            DECIMAL(5, 2),
    wind_direction        INTEGER,
    wind_gust             DECIMAL(5, 2),
    precipitation         DECIMAL(5, 2),
    cloud_coverage        INTEGER,
    condition_main        VARCHAR(50),
    condition_description TEXT,
    weather_icon          VARCHAR(10),
    uv_index              DECIMAL(3, 2),
    sunrise               TIMESTAMPTZ,
    sunset                TIMESTAMPTZ,
    recorded_at           TIMESTAMPTZ NOT NULL,
    created_at            TIMESTAMPTZ      DEFAULT NOW()
);

CREATE TABLE system_config
(
    id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    key         VARCHAR(255) UNIQUE NOT NULL,
    value       TEXT                NOT NULL,
    description TEXT,
    updated_by  UUID REFERENCES profiles (id),
    updated_at  TIMESTAMPTZ      DEFAULT NOW()
);

CREATE TABLE api_keys
(
    id                    UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name                  VARCHAR(255)        NOT NULL,
    api_key               VARCHAR(255) UNIQUE NOT NULL,
    secret_key            VARCHAR(255),
    service_name          VARCHAR(100)        NOT NULL,
    is_active             BOOLEAN          DEFAULT true,
    rate_limit_per_minute INTEGER          DEFAULT 60,
    created_by            UUID REFERENCES profiles (id),
    created_at            TIMESTAMPTZ      DEFAULT NOW(),
    expires_at            TIMESTAMPTZ
);

CREATE INDEX idx_outages_location ON outages USING GIST (location);
CREATE INDEX idx_outages_status ON outages (status);
CREATE INDEX idx_outages_confidence ON outages (confidence_percentage);
CREATE INDEX idx_outages_reported_at ON outages (reported_at);
CREATE INDEX idx_weather_data_location ON weather_data USING GIST (location);
CREATE INDEX idx_weather_data_recorded_at ON weather_data (recorded_at);
CREATE INDEX idx_outage_updates_outage_id ON outage_updates (outage_id);
CREATE INDEX idx_outages_reported_by ON public.outages (reported_by);
CREATE INDEX idx_outages_confirmed_by ON public.outages (confirmed_by);
CREATE INDEX idx_outages_resolved_by ON public.outages (resolved_by);
CREATE INDEX idx_outage_updates_user_id ON public.outage_updates (user_id);
CREATE INDEX idx_api_keys_created_by ON public.api_keys (created_by);
CREATE INDEX idx_system_config_updated_by ON public.system_config (updated_by);

CREATE
OR REPLACE FUNCTION update_updated_at_column()
    RETURNS TRIGGER
    LANGUAGE plpgsql
    SET search_path = 'public'
AS
$$
BEGIN
    NEW.updated_at
= NOW();
RETURN NEW;
END;
$$;

CREATE TRIGGER update_profiles_updated_at
    BEFORE UPDATE
    ON profiles
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_outages_updated_at
    BEFORE UPDATE
    ON outages
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE
OR REPLACE FUNCTION handle_new_user()
    RETURNS TRIGGER
    LANGUAGE plpgsql
    SECURITY DEFINER
    SET search_path = 'public'
AS
$$
BEGIN
INSERT INTO public.profiles (id, first_name, last_name, phone_number, role)
VALUES (NEW.id,
        COALESCE(NEW.raw_user_meta_data ->> 'first_name', 'New'),
        COALESCE(NEW.raw_user_meta_data ->> 'last_name', 'User'),
        NEW.phone,
        'user');
RETURN NEW;
END;
$$;

CREATE TRIGGER on_auth_user_created
    AFTER INSERT
    ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION handle_new_user();

CREATE
OR REPLACE VIEW active_outages
    WITH (security_invoker = true)
AS
SELECT *
FROM outages
WHERE status IN ('unverified', 'verified', 'being_resolved');

CREATE
OR REPLACE VIEW outage_statistics
    WITH (security_invoker = true)
AS
SELECT COUNT(*)                as total_outages,
       COUNT(*)                   FILTER (WHERE status IN ('unverified', 'verified', 'being_resolved')) as active_outages, COUNT(*) FILTER (WHERE status = 'resolved') as resolved_outages, AVG(EXTRACT(EPOCH FROM (resolved_at - reported_at)) / 3600) FILTER (WHERE status = 'resolved') as avg_resolution_hours, COUNT(DISTINCT barangay) as affected_barangays,
       SUM(affected_customers) as total_affected_customers
FROM outages;

INSERT INTO system_config (key, value, description)
VALUES ('system_name', 'Beacon Outage Monitoring', 'Name of the system'),
       ('city', 'Baguio', 'City being monitored'),
       ('auto_confirm_outages', 'false', 'Automatically confirm new outages'),
       ('notification_enabled', 'true', 'Enable real-time notifications') ON CONFLICT (key) DO NOTHING;

ALTER TABLE profiles
    ENABLE ROW LEVEL SECURITY;

DROP
POLICY IF EXISTS "Users can view their own profile" ON profiles;
CREATE
POLICY "Users can view their own profile" ON profiles
    FOR
SELECT USING (
    (select auth.uid()) = id
    );

DROP
POLICY IF EXISTS "Users can update their own profile" ON profiles;
CREATE
POLICY "Users can update their own profile" ON profiles
    FOR
UPDATE USING (
    (select auth.uid()) = id
    )
WITH CHECK (
    (select auth.uid()) = id
    );

ALTER TABLE outages ENABLE ROW LEVEL SECURITY;

DROP
POLICY IF EXISTS "Public can view all outages" ON outages;
CREATE
POLICY "Public can view all outages" ON outages
    FOR
SELECT USING (true);

DROP
POLICY IF EXISTS "Authenticated users can report outages" ON outages;
CREATE
POLICY "Authenticated users can report outages" ON outages
    FOR INSERT WITH CHECK (
        (select auth.role()) = 'authenticated'
    );

DROP
POLICY IF EXISTS "Admins or crew can update outages" ON outages;
CREATE
POLICY "Admins or crew can update outages" ON outages
    FOR
UPDATE USING (
    EXISTS (
    SELECT 1
    FROM profiles
    WHERE profiles.id = (select auth.uid())
    AND profiles.role IN ('admin', 'crew')
    )
    );

DROP
POLICY IF EXISTS "Admins can delete outages" ON outages;
CREATE
POLICY "Admins can delete outages" ON outages
    FOR DELETE
USING (
    EXISTS(
            SELECT 1
            FROM profiles
            WHERE profiles.id = (select auth.uid())
              AND profiles.role = 'admin'
        )
    );

ALTER TABLE outage_updates ENABLE ROW LEVEL SECURITY;

DROP
POLICY IF EXISTS "Public can view all outage updates" ON outage_updates;
CREATE
POLICY "Public can view all outage updates" ON outage_updates
    FOR
SELECT USING (true);

DROP
POLICY IF EXISTS "Admins or crew can create outage updates" ON outage_updates;
CREATE
POLICY "Admins or crew can create outage updates" ON outage_updates
    FOR INSERT WITH CHECK (
    EXISTS(
            SELECT 1
            FROM profiles
            WHERE profiles.id = (select auth.uid())
              AND profiles.role IN ('admin', 'crew')
        )
    );

ALTER TABLE public.weather_data ENABLE ROW LEVEL SECURITY;

DROP
POLICY IF EXISTS "Public can view weather data" ON public.weather_data;
CREATE
POLICY "Public can view weather data"
    ON public.weather_data
    FOR
SELECT USING (true);

DROP
POLICY IF EXISTS "Admins can create weather data" ON public.weather_data;
CREATE
POLICY "Admins can create weather data"
    ON public.weather_data
    FOR INSERT WITH CHECK (
    EXISTS(
            SELECT 1
            FROM profiles
            WHERE profiles.id = (select auth.uid())
              AND profiles.role = 'admin'
        )
    );


ALTER TABLE public.system_config ENABLE ROW LEVEL SECURITY;

DROP
POLICY IF EXISTS "Admins can manage system config" ON public.system_config;
CREATE
POLICY "Admins can manage system config"
    ON public.system_config
    FOR ALL USING (
    EXISTS(
            SELECT 1
            FROM profiles
            WHERE profiles.id = (select auth.uid())
              AND profiles.role = 'admin'
        )
    ) WITH CHECK (
    EXISTS(
            SELECT 1
            FROM profiles
            WHERE profiles.id = (select auth.uid())
              AND profiles.role = 'admin'
        )
    );


ALTER TABLE public.api_keys ENABLE ROW LEVEL SECURITY;