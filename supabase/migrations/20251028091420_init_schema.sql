-- ENUMS
CREATE TYPE outage_status       AS ENUM ('unverified', 'verified', 'being_resolved', 'resolved');
CREATE TYPE outage_type         AS ENUM ('unscheduled', 'scheduled', 'emergency');
CREATE TYPE report_status       AS ENUM ('unprocessed', 'processed_as_new_outage', 'processed_as_duplicate', 'archived_as_isolated');
CREATE TYPE roles               AS ENUM ('user', 'crew', 'admin');
CREATE TYPE themes              AS ENUM ('light', 'dark', 'system');
CREATE TYPE crew_type           AS ENUM ('team', 'individual');
CREATE TYPE assignment_status   AS ENUM ('assigned', 'en_route', 'on_site', 'paused', 'completed', 'cancelled');

-- TABLES
CREATE TABLE public.profiles (
    id              BIGSERIAL PRIMARY KEY,
    public_id       UUID UNIQUE DEFAULT extensions.gen_random_uuid() NOT NULL,
    user_id         UUID UNIQUE REFERENCES auth.users (id) ON DELETE CASCADE ON UPDATE CASCADE NOT NULL,
    first_name      VARCHAR(100) NOT NULL,
    last_name       VARCHAR(100) NOT NULL,
    role            roles DEFAULT 'user' NOT NULL,
    phone_number    VARCHAR(20),
    created_at      TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_at      TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE public.provinces (
    id              BIGSERIAL PRIMARY KEY,
    public_id       UUID DEFAULT extensions.gen_random_uuid() UNIQUE NOT NULL,
    name            VARCHAR(255) UNIQUE NOT NULL,
    boundary        geometry(Polygon, 4326) UNIQUE NOT NULL,
    population      INTEGER CHECK (population >= 0),
    population_year SMALLINT CHECK (population_year >= 1900),
    created_at      TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_at      TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE public.cities (
    id              BIGSERIAL PRIMARY KEY,
    public_id       UUID DEFAULT extensions.gen_random_uuid() UNIQUE NOT NULL,
    name            VARCHAR(255) UNIQUE NOT NULL,
    province_id     BIGINT NOT NULL REFERENCES public.provinces (id) ON DELETE CASCADE ON UPDATE CASCADE,
    boundary        geometry(Polygon, 4326) UNIQUE NOT NULL,
    population      INTEGER CHECK (population >= 0),
    population_year SMALLINT CHECK (population_year >= 1900),
    created_at      TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_at      TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE public.feeders (
    id             BIGSERIAL PRIMARY KEY,
    public_id      UUID DEFAULT extensions.gen_random_uuid() UNIQUE NOT NULL,
    feeder_number  BIGINT UNIQUE NOT NULL,         -- official number (1,2,3…)
    boundary       geometry(Polygon, 4326) UNIQUE NOT NULL,
    created_at     TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_at     TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE public.barangays (
    id              BIGSERIAL PRIMARY KEY,
    public_id       UUID DEFAULT extensions.gen_random_uuid() UNIQUE NOT NULL,
    name            VARCHAR(255) NOT NULL,
    city_id         BIGINT NOT NULL REFERENCES public.cities (id) ON DELETE CASCADE ON UPDATE CASCADE,
    feeder_id       BIGINT REFERENCES public.feeders (id) ON DELETE SET NULL ON UPDATE CASCADE,
    boundary        geometry(Polygon, 4326) UNIQUE NOT NULL,
    population      INTEGER CHECK (population >= 0),
    population_year SMALLINT CHECK (population_year >= 1900),
    created_at      TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_at      TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE public.outages (
    id                         BIGSERIAL PRIMARY KEY,
    public_id                  UUID DEFAULT extensions.gen_random_uuid() UNIQUE NOT NULL,
    outage_type                outage_type DEFAULT 'unscheduled' NOT NULL,
    status                     outage_status DEFAULT 'unverified' NOT NULL,
    confidence_percentage      DOUBLE PRECISION DEFAULT 50.0,
    title                      VARCHAR(255),
    description                TEXT,
    number_of_reports          INTEGER CHECK(number_of_reports >= 0),
    estimated_affected_population INTEGER CHECK (estimated_affected_population >= 0),
    start_time                 TIMESTAMPTZ,
    estimated_restoration_time TIMESTAMPTZ,
    actual_restoration_time    TIMESTAMPTZ,
    confirmed_by               BIGINT REFERENCES public.profiles (id) ON DELETE SET NULL,
    resolved_by                BIGINT REFERENCES public.profiles (id) ON DELETE SET NULL,
    created_at                 TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_at                 TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE public.outage_updates (
    id              BIGSERIAL PRIMARY KEY,
    public_id       UUID DEFAULT extensions.gen_random_uuid() UNIQUE NOT NULL,
    outage_id       BIGINT NOT NULL REFERENCES public.outages (id) ON DELETE CASCADE,
    user_id         BIGINT NOT NULL REFERENCES public.profiles (id) ON DELETE CASCADE,
    old_status      outage_status NOT NULL,
    new_status      outage_status NOT NULL,
    description     TEXT,
    created_at      TIMESTAMPTZ DEFAULT now() NOT NULL
);

CREATE TABLE public.outage_reports (
    id              BIGSERIAL PRIMARY KEY,
    public_id       UUID DEFAULT extensions.gen_random_uuid() UNIQUE NOT NULL,
    reported_by     BIGINT REFERENCES public.profiles (id) ON DELETE SET NULL,
    linked_outage_id BIGINT REFERENCES public.outages (id) ON DELETE SET NULL,
    description     TEXT,
    image_url       TEXT,
    location        geometry(Point, 4326) NOT NULL,
    reported_at     TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_at      TIMESTAMPTZ DEFAULT now(),
    status          report_status DEFAULT 'unprocessed' NOT NULL
);

CREATE TABLE public.affected_areas (
    id              BIGSERIAL PRIMARY KEY,
    outage_id       BIGINT NOT NULL REFERENCES public.outages (id) ON DELETE CASCADE,
    barangay_id     BIGINT NOT NULL REFERENCES public.barangays (id) ON DELETE CASCADE,
    created_at      TIMESTAMPTZ DEFAULT now() NOT NULL,
    UNIQUE (outage_id, barangay_id)
);

CREATE TABLE public.weather_data (
    id                      BIGSERIAL PRIMARY KEY,
    public_id               UUID DEFAULT extensions.gen_random_uuid() UNIQUE NOT NULL,
    city_id                 BIGINT NOT NULL REFERENCES public.cities (id) ON DELETE CASCADE ON UPDATE CASCADE,
    temperature             NUMERIC(4,1),
    feels_like              NUMERIC(4,1),
    humidity                INTEGER,
    atmospheric_pressure    INTEGER,
    wind_speed              NUMERIC(5,2),
    precipitation           NUMERIC(5,2),
    condition_main          VARCHAR(50),
    condition_description   TEXT,
    recorded_at             TIMESTAMPTZ NOT NULL,
    created_at              TIMESTAMPTZ DEFAULT now() NOT NULL
);

CREATE TABLE public.system_config (
    id          BIGSERIAL PRIMARY KEY,
    public_id   UUID DEFAULT extensions.gen_random_uuid() UNIQUE NOT NULL,
    key         VARCHAR(255) UNIQUE NOT NULL,
    value       TEXT NOT NULL,
    description TEXT,
    updated_by  BIGINT REFERENCES public.profiles (id) ON DELETE SET NULL,
    updated_at  TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE public.api_keys (
     id                    BIGSERIAL PRIMARY KEY,
     public_id             UUID DEFAULT extensions.gen_random_uuid() UNIQUE NOT NULL,
     name                  VARCHAR(255) UNIQUE NOT NULL,
     api_key               VARCHAR(255) UNIQUE NOT NULL,
     secret_key            VARCHAR(255),
     service_name          VARCHAR(100),
     is_active             BOOLEAN DEFAULT TRUE NOT NULL,
     rate_limit_per_minute INTEGER DEFAULT 60 CHECK (rate_limit_per_minute > 0),
     created_by            BIGINT REFERENCES public.profiles (id) ON DELETE CASCADE,
     created_at            TIMESTAMPTZ DEFAULT now() NOT NULL,
     expires_at            TIMESTAMPTZ
);

CREATE TABLE public.profile_settings (
    id              BIGSERIAL PRIMARY KEY,
    profile_id      BIGINT UNIQUE REFERENCES public.profiles (id) ON DELETE CASCADE,

    theme           themes DEFAULT 'system' NOT NULL,
    dynamic_color   BOOLEAN DEFAULT true NOT NULL,
    font_scale      NUMERIC(3,2) DEFAULT 1.0 CHECK (font_scale BETWEEN 0.75 AND 1.50) NOT NULL,
    reduce_motion   BOOLEAN DEFAULT false NOT NULL,
    language        VARCHAR(10) DEFAULT 'en' NOT NULL,
    extra_settings  JSONB DEFAULT '{}'::jsonb NOT NULL,

    created_at      TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_at      TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE public.crews (
    id          BIGSERIAL PRIMARY KEY,
    public_id   UUID DEFAULT extensions.gen_random_uuid() UNIQUE NOT NULL,
    name        VARCHAR(255) NOT NULL,
    crew_type   crew_type DEFAULT 'team' NOT NULL,
    description TEXT,
    created_at  TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_at  TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE public.assignments (
    id               BIGSERIAL PRIMARY KEY,
    outage_id        BIGINT NOT NULL REFERENCES public.outages (id) ON DELETE CASCADE,
    crew_id          BIGINT NOT NULL REFERENCES public.crews (id) ON DELETE CASCADE,
    status           assignment_status DEFAULT 'assigned' NOT NULL,
    notes            TEXT,
    assigned_at      TIMESTAMPTZ DEFAULT now() NOT NULL,
    updated_at       TIMESTAMPTZ DEFAULT now(),
    UNIQUE (outage_id, crew_id)
);

-- VIEWS
CREATE OR REPLACE VIEW public.outage_summary AS
SELECT
    o.id,
    o.public_id,
    o.status,
    COUNT(aa.barangay_id) AS affected_barangay_count,
    COALESCE(SUM(b.population), 0) AS estimated_population_affected
FROM public.outages o
    LEFT JOIN public.affected_areas aa ON o.id = aa.outage_id
    LEFT JOIN public.barangays b ON aa.barangay_id = b.id
GROUP BY o.id;

-- INDEXES
CREATE INDEX idx_outages_status        ON public.outages (status);
CREATE INDEX idx_outages_start_time    ON public.outages (start_time);

CREATE INDEX idx_outage_reports_status   ON public.outage_reports (status);
CREATE INDEX idx_outage_reports_location ON public.outage_reports USING GIST (location);

CREATE INDEX idx_affected_areas_outage_id   ON public.affected_areas (outage_id);
CREATE INDEX idx_affected_areas_barangay_id ON public.affected_areas (barangay_id);

CREATE INDEX idx_barangays_city_id     ON public.barangays (city_id);
CREATE INDEX idx_cities_province_id    ON public.cities (province_id);
CREATE INDEX idx_weather_city_id       ON public.weather_data (city_id);

CREATE INDEX idx_outage_updates_outage_id ON public.outage_updates (outage_id);
CREATE INDEX idx_outage_updates_user_id   ON public.outage_updates (user_id);
CREATE INDEX idx_outage_reports_reported_by ON public.outage_reports (reported_by);
CREATE INDEX idx_outage_reports_linked_outage_id ON public.outage_reports (linked_outage_id);
CREATE INDEX idx_assignments_outage_id    ON public.assignments (outage_id);
CREATE INDEX idx_assignments_crew_id      ON public.assignments (crew_id);
CREATE INDEX idx_crews_name               ON public.crews (name);

CREATE INDEX idx_outages_confirmed_by ON public.outages (confirmed_by);
CREATE INDEX idx_outages_resolved_by  ON public.outages (resolved_by);
CREATE INDEX idx_barangays_feeder_id  ON public.barangays (feeder_id);
CREATE INDEX idx_assignments_status   ON public.assignments (status);

-- FUNCTIONS
CREATE OR REPLACE FUNCTION public.update_timestamp_on_modify()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.updated_at := now();
    RETURN NEW;
END;
$$;

-- TRIGGERS
CREATE TRIGGER trg_provinces_updated
    BEFORE UPDATE ON public.provinces
    FOR EACH ROW EXECUTE PROCEDURE public.update_timestamp_on_modify();

CREATE TRIGGER trg_cities_updated
    BEFORE UPDATE ON public.cities
    FOR EACH ROW EXECUTE PROCEDURE public.update_timestamp_on_modify();

CREATE TRIGGER trg_feeders_updated
    BEFORE UPDATE ON public.feeders
    FOR EACH ROW EXECUTE PROCEDURE public.update_timestamp_on_modify();

CREATE TRIGGER trg_barangays_updated
    BEFORE UPDATE ON public.barangays
    FOR EACH ROW EXECUTE PROCEDURE public.update_timestamp_on_modify();

CREATE TRIGGER trg_outages_updated
    BEFORE UPDATE ON public.outages
    FOR EACH ROW EXECUTE PROCEDURE public.update_timestamp_on_modify();

CREATE TRIGGER trg_outage_reports_updated
    BEFORE UPDATE ON public.outage_reports
    FOR EACH ROW EXECUTE PROCEDURE public.update_timestamp_on_modify();

CREATE TRIGGER trg_system_config_updated
    BEFORE UPDATE ON public.system_config
    FOR EACH ROW EXECUTE PROCEDURE public.update_timestamp_on_modify();

CREATE TRIGGER trg_profile_settings_updated
    BEFORE UPDATE ON public.profile_settings
    FOR EACH ROW EXECUTE PROCEDURE public.update_timestamp_on_modify();

CREATE TRIGGER trg_crews_updated
    BEFORE UPDATE ON public.crews
    FOR EACH ROW EXECUTE PROCEDURE public.update_timestamp_on_modify();

CREATE TRIGGER trg_assignments_updated
    BEFORE UPDATE ON public.assignments
    FOR EACH ROW EXECUTE PROCEDURE public.update_timestamp_on_modify();