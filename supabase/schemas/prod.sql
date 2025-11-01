


SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;




ALTER SCHEMA "public" OWNER TO "postgres";


CREATE EXTENSION IF NOT EXISTS "hypopg" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "index_advisor" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "pg_graphql" WITH SCHEMA "graphql";






CREATE EXTENSION IF NOT EXISTS "pg_stat_statements" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "postgis" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "supabase_vault" WITH SCHEMA "vault";






CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA "extensions";






CREATE TYPE "public"."assignment_status" AS ENUM (
    'assigned',
    'en_route',
    'on_site',
    'paused',
    'completed',
    'cancelled'
);


ALTER TYPE "public"."assignment_status" OWNER TO "postgres";


CREATE TYPE "public"."crew_type" AS ENUM (
    'team',
    'individual'
);


ALTER TYPE "public"."crew_type" OWNER TO "postgres";


CREATE TYPE "public"."outage_status" AS ENUM (
    'unverified',
    'verified',
    'being_resolved',
    'resolved'
);


ALTER TYPE "public"."outage_status" OWNER TO "postgres";


CREATE TYPE "public"."outage_type" AS ENUM (
    'unscheduled',
    'scheduled',
    'emergency'
);


ALTER TYPE "public"."outage_type" OWNER TO "postgres";


CREATE TYPE "public"."report_status" AS ENUM (
    'unprocessed',
    'processed_as_new_outage',
    'processed_as_duplicate',
    'archived_as_isolated'
);


ALTER TYPE "public"."report_status" OWNER TO "postgres";


CREATE TYPE "public"."roles" AS ENUM (
    'user',
    'crew',
    'admin'
);


ALTER TYPE "public"."roles" OWNER TO "postgres";


CREATE TYPE "public"."themes" AS ENUM (
    'light',
    'dark',
    'system'
);


ALTER TYPE "public"."themes" OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."update_timestamp_on_modify"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    SET "search_path" TO 'pg_catalog', 'public'
    AS $$
BEGIN
    NEW.updated_at := pg_catalog.now();
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."update_timestamp_on_modify"() OWNER TO "postgres";

SET default_tablespace = '';

SET default_table_access_method = "heap";


CREATE TABLE IF NOT EXISTS "public"."affected_areas" (
    "id" bigint NOT NULL,
    "outage_id" bigint NOT NULL,
    "barangay_id" bigint NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."affected_areas" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."affected_areas_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."affected_areas_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."affected_areas_id_seq" OWNED BY "public"."affected_areas"."id";



CREATE TABLE IF NOT EXISTS "public"."api_keys" (
    "id" bigint NOT NULL,
    "public_id" "uuid" DEFAULT "extensions"."gen_random_uuid"() NOT NULL,
    "name" character varying(255) NOT NULL,
    "api_key" character varying(255) NOT NULL,
    "secret_key" character varying(255),
    "service_name" character varying(100),
    "is_active" boolean DEFAULT true NOT NULL,
    "rate_limit_per_minute" integer DEFAULT 60,
    "created_by" bigint,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "expires_at" timestamp with time zone,
    CONSTRAINT "api_keys_rate_limit_per_minute_check" CHECK (("rate_limit_per_minute" > 0))
);


ALTER TABLE "public"."api_keys" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."api_keys_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."api_keys_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."api_keys_id_seq" OWNED BY "public"."api_keys"."id";



CREATE TABLE IF NOT EXISTS "public"."assignments" (
    "id" bigint NOT NULL,
    "outage_id" bigint NOT NULL,
    "crew_id" bigint NOT NULL,
    "status" "public"."assignment_status" DEFAULT 'assigned'::"public"."assignment_status" NOT NULL,
    "notes" "text",
    "assigned_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "public_id" "uuid" DEFAULT "extensions"."gen_random_uuid"() NOT NULL
);


ALTER TABLE "public"."assignments" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."assignments_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."assignments_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."assignments_id_seq" OWNED BY "public"."assignments"."id";



CREATE TABLE IF NOT EXISTS "public"."barangays" (
    "id" bigint NOT NULL,
    "public_id" "uuid" DEFAULT "extensions"."gen_random_uuid"() NOT NULL,
    "name" character varying(255) NOT NULL,
    "city_id" bigint NOT NULL,
    "feeder_id" bigint,
    "boundary" "extensions"."geometry"(Polygon,4326) NOT NULL,
    "population" integer,
    "population_year" smallint,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "barangays_population_check" CHECK (("population" >= 0)),
    CONSTRAINT "barangays_population_year_check" CHECK (("population_year" >= 1900))
);


ALTER TABLE "public"."barangays" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."barangays_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."barangays_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."barangays_id_seq" OWNED BY "public"."barangays"."id";



CREATE TABLE IF NOT EXISTS "public"."cities" (
    "id" bigint NOT NULL,
    "public_id" "uuid" DEFAULT "extensions"."gen_random_uuid"() NOT NULL,
    "name" character varying(255) NOT NULL,
    "province_id" bigint NOT NULL,
    "boundary" "extensions"."geometry"(Polygon,4326) NOT NULL,
    "population" integer,
    "population_year" smallint,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "cities_population_check" CHECK (("population" >= 0)),
    CONSTRAINT "cities_population_year_check" CHECK (("population_year" >= 1900))
);


ALTER TABLE "public"."cities" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."cities_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."cities_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."cities_id_seq" OWNED BY "public"."cities"."id";



CREATE TABLE IF NOT EXISTS "public"."crews" (
    "id" bigint NOT NULL,
    "public_id" "uuid" DEFAULT "extensions"."gen_random_uuid"() NOT NULL,
    "name" character varying(255) NOT NULL,
    "crew_type" "public"."crew_type" DEFAULT 'team'::"public"."crew_type" NOT NULL,
    "description" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."crews" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."crews_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."crews_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."crews_id_seq" OWNED BY "public"."crews"."id";



CREATE TABLE IF NOT EXISTS "public"."feeders" (
    "id" bigint NOT NULL,
    "public_id" "uuid" DEFAULT "extensions"."gen_random_uuid"() NOT NULL,
    "feeder_number" bigint NOT NULL,
    "boundary" "extensions"."geometry"(Polygon,4326) NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."feeders" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."feeders_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."feeders_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."feeders_id_seq" OWNED BY "public"."feeders"."id";



CREATE TABLE IF NOT EXISTS "public"."outage_reports" (
    "id" bigint NOT NULL,
    "public_id" "uuid" DEFAULT "extensions"."gen_random_uuid"() NOT NULL,
    "reported_by" bigint,
    "linked_outage_id" bigint,
    "description" "text",
    "image_url" "text",
    "location" "extensions"."geometry"(Point,4326) NOT NULL,
    "reported_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"(),
    "status" "public"."report_status" DEFAULT 'unprocessed'::"public"."report_status" NOT NULL
);


ALTER TABLE "public"."outage_reports" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."outage_reports_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."outage_reports_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."outage_reports_id_seq" OWNED BY "public"."outage_reports"."id";



CREATE OR REPLACE VIEW "public"."outage_summary" AS
SELECT
    NULL::bigint AS "id",
    NULL::"uuid" AS "public_id",
    NULL::"public"."outage_status" AS "status",
    NULL::bigint AS "affected_barangay_count",
    NULL::bigint AS "estimated_population_affected";


ALTER VIEW "public"."outage_summary" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."outage_updates" (
    "id" bigint NOT NULL,
    "public_id" "uuid" DEFAULT "extensions"."gen_random_uuid"() NOT NULL,
    "outage_id" bigint NOT NULL,
    "user_id" bigint NOT NULL,
    "old_status" "public"."outage_status" NOT NULL,
    "new_status" "public"."outage_status" NOT NULL,
    "description" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."outage_updates" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."outage_updates_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."outage_updates_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."outage_updates_id_seq" OWNED BY "public"."outage_updates"."id";



CREATE TABLE IF NOT EXISTS "public"."outages" (
    "id" bigint NOT NULL,
    "public_id" "uuid" DEFAULT "extensions"."gen_random_uuid"() NOT NULL,
    "outage_type" "public"."outage_type" DEFAULT 'unscheduled'::"public"."outage_type" NOT NULL,
    "status" "public"."outage_status" DEFAULT 'unverified'::"public"."outage_status" NOT NULL,
    "confidence_percentage" double precision DEFAULT 50.0,
    "title" character varying(255),
    "description" "text",
    "number_of_reports" integer,
    "estimated_affected_population" integer,
    "start_time" timestamp with time zone,
    "estimated_restoration_time" timestamp with time zone,
    "actual_restoration_time" timestamp with time zone,
    "confirmed_by" bigint,
    "resolved_by" bigint,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "outages_estimated_affected_population_check" CHECK (("estimated_affected_population" >= 0)),
    CONSTRAINT "outages_number_of_reports_check" CHECK (("number_of_reports" >= 0))
);


ALTER TABLE "public"."outages" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."outages_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."outages_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."outages_id_seq" OWNED BY "public"."outages"."id";



CREATE TABLE IF NOT EXISTS "public"."profile_settings" (
    "id" bigint NOT NULL,
    "profile_id" bigint,
    "theme" "public"."themes" DEFAULT 'system'::"public"."themes" NOT NULL,
    "dynamic_color" boolean DEFAULT true NOT NULL,
    "font_scale" numeric(3,2) DEFAULT 1.0 NOT NULL,
    "reduce_motion" boolean DEFAULT false NOT NULL,
    "language" character varying(10) DEFAULT 'en'::character varying NOT NULL,
    "extra_settings" "jsonb" DEFAULT '{}'::"jsonb" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "profile_settings_font_scale_check" CHECK ((("font_scale" >= 0.75) AND ("font_scale" <= 1.50)))
);


ALTER TABLE "public"."profile_settings" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."profile_settings_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."profile_settings_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."profile_settings_id_seq" OWNED BY "public"."profile_settings"."id";



CREATE TABLE IF NOT EXISTS "public"."profiles" (
    "id" bigint NOT NULL,
    "public_id" "uuid" DEFAULT "extensions"."gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "first_name" character varying(100) NOT NULL,
    "last_name" character varying(100) NOT NULL,
    "role" "public"."roles" DEFAULT 'user'::"public"."roles" NOT NULL,
    "phone_number" character varying(20),
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."profiles" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."profiles_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."profiles_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."profiles_id_seq" OWNED BY "public"."profiles"."id";



CREATE TABLE IF NOT EXISTS "public"."provinces" (
    "id" bigint NOT NULL,
    "public_id" "uuid" DEFAULT "extensions"."gen_random_uuid"() NOT NULL,
    "name" character varying(255) NOT NULL,
    "boundary" "extensions"."geometry"(Polygon,4326) NOT NULL,
    "population" integer,
    "population_year" smallint,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"(),
    CONSTRAINT "provinces_population_check" CHECK (("population" >= 0)),
    CONSTRAINT "provinces_population_year_check" CHECK (("population_year" >= 1900))
);


ALTER TABLE "public"."provinces" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."provinces_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."provinces_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."provinces_id_seq" OWNED BY "public"."provinces"."id";



CREATE TABLE IF NOT EXISTS "public"."system_config" (
    "id" bigint NOT NULL,
    "public_id" "uuid" DEFAULT "extensions"."gen_random_uuid"() NOT NULL,
    "key" character varying(255) NOT NULL,
    "value" "text" NOT NULL,
    "description" "text",
    "updated_by" bigint,
    "updated_at" timestamp with time zone DEFAULT "now"()
);


ALTER TABLE "public"."system_config" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."system_config_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."system_config_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."system_config_id_seq" OWNED BY "public"."system_config"."id";



CREATE TABLE IF NOT EXISTS "public"."weather_data" (
    "id" bigint NOT NULL,
    "public_id" "uuid" DEFAULT "extensions"."gen_random_uuid"() NOT NULL,
    "city_id" bigint NOT NULL,
    "temperature" numeric(4,1) NOT NULL,
    "feels_like" numeric(4,1),
    "humidity" integer,
    "atmospheric_pressure" integer,
    "wind_speed" numeric(5,2),
    "precipitation" numeric(5,2),
    "condition_main" character varying(50),
    "condition_description" "text",
    "recorded_at" timestamp with time zone NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."weather_data" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."weather_data_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."weather_data_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."weather_data_id_seq" OWNED BY "public"."weather_data"."id";



ALTER TABLE ONLY "public"."affected_areas" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."affected_areas_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."api_keys" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."api_keys_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."assignments" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."assignments_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."barangays" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."barangays_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."cities" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."cities_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."crews" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."crews_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."feeders" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."feeders_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."outage_reports" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."outage_reports_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."outage_updates" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."outage_updates_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."outages" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."outages_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."profile_settings" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."profile_settings_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."profiles" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."profiles_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."provinces" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."provinces_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."system_config" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."system_config_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."weather_data" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."weather_data_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."affected_areas"
    ADD CONSTRAINT "affected_areas_outage_id_barangay_id_key" UNIQUE ("outage_id", "barangay_id");



ALTER TABLE ONLY "public"."affected_areas"
    ADD CONSTRAINT "affected_areas_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."api_keys"
    ADD CONSTRAINT "api_keys_api_key_key" UNIQUE ("api_key");



ALTER TABLE ONLY "public"."api_keys"
    ADD CONSTRAINT "api_keys_name_key" UNIQUE ("name");



ALTER TABLE ONLY "public"."api_keys"
    ADD CONSTRAINT "api_keys_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."api_keys"
    ADD CONSTRAINT "api_keys_public_id_key" UNIQUE ("public_id");



ALTER TABLE ONLY "public"."assignments"
    ADD CONSTRAINT "assignments_outage_id_crew_id_key" UNIQUE ("outage_id", "crew_id");



ALTER TABLE ONLY "public"."assignments"
    ADD CONSTRAINT "assignments_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."assignments"
    ADD CONSTRAINT "assignments_public_id_key" UNIQUE ("public_id");



ALTER TABLE ONLY "public"."barangays"
    ADD CONSTRAINT "barangays_boundary_key" UNIQUE ("boundary");



ALTER TABLE ONLY "public"."barangays"
    ADD CONSTRAINT "barangays_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."barangays"
    ADD CONSTRAINT "barangays_public_id_key" UNIQUE ("public_id");



ALTER TABLE ONLY "public"."cities"
    ADD CONSTRAINT "cities_boundary_key" UNIQUE ("boundary");



ALTER TABLE ONLY "public"."cities"
    ADD CONSTRAINT "cities_name_key" UNIQUE ("name");



ALTER TABLE ONLY "public"."cities"
    ADD CONSTRAINT "cities_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."cities"
    ADD CONSTRAINT "cities_public_id_key" UNIQUE ("public_id");



ALTER TABLE ONLY "public"."crews"
    ADD CONSTRAINT "crews_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."crews"
    ADD CONSTRAINT "crews_public_id_key" UNIQUE ("public_id");



ALTER TABLE ONLY "public"."feeders"
    ADD CONSTRAINT "feeders_boundary_key" UNIQUE ("boundary");



ALTER TABLE ONLY "public"."feeders"
    ADD CONSTRAINT "feeders_feeder_number_key" UNIQUE ("feeder_number");



ALTER TABLE ONLY "public"."feeders"
    ADD CONSTRAINT "feeders_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."feeders"
    ADD CONSTRAINT "feeders_public_id_key" UNIQUE ("public_id");



ALTER TABLE ONLY "public"."outage_reports"
    ADD CONSTRAINT "outage_reports_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."outage_reports"
    ADD CONSTRAINT "outage_reports_public_id_key" UNIQUE ("public_id");



ALTER TABLE ONLY "public"."outage_updates"
    ADD CONSTRAINT "outage_updates_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."outage_updates"
    ADD CONSTRAINT "outage_updates_public_id_key" UNIQUE ("public_id");



ALTER TABLE ONLY "public"."outages"
    ADD CONSTRAINT "outages_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."outages"
    ADD CONSTRAINT "outages_public_id_key" UNIQUE ("public_id");



ALTER TABLE ONLY "public"."profile_settings"
    ADD CONSTRAINT "profile_settings_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."profile_settings"
    ADD CONSTRAINT "profile_settings_profile_id_key" UNIQUE ("profile_id");



ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "profiles_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "profiles_public_id_key" UNIQUE ("public_id");



ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "profiles_user_id_key" UNIQUE ("user_id");



ALTER TABLE ONLY "public"."provinces"
    ADD CONSTRAINT "provinces_boundary_key" UNIQUE ("boundary");



ALTER TABLE ONLY "public"."provinces"
    ADD CONSTRAINT "provinces_name_key" UNIQUE ("name");



ALTER TABLE ONLY "public"."provinces"
    ADD CONSTRAINT "provinces_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."provinces"
    ADD CONSTRAINT "provinces_public_id_key" UNIQUE ("public_id");



ALTER TABLE ONLY "public"."system_config"
    ADD CONSTRAINT "system_config_key_key" UNIQUE ("key");



ALTER TABLE ONLY "public"."system_config"
    ADD CONSTRAINT "system_config_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."system_config"
    ADD CONSTRAINT "system_config_public_id_key" UNIQUE ("public_id");



ALTER TABLE ONLY "public"."weather_data"
    ADD CONSTRAINT "weather_data_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."weather_data"
    ADD CONSTRAINT "weather_data_public_id_key" UNIQUE ("public_id");



CREATE INDEX "idx_affected_areas_barangay_id" ON "public"."affected_areas" USING "btree" ("barangay_id");



CREATE INDEX "idx_affected_areas_outage_id" ON "public"."affected_areas" USING "btree" ("outage_id");



CREATE INDEX "idx_assignments_crew_id" ON "public"."assignments" USING "btree" ("crew_id");



CREATE INDEX "idx_assignments_outage_id" ON "public"."assignments" USING "btree" ("outage_id");



CREATE INDEX "idx_assignments_status" ON "public"."assignments" USING "btree" ("status");



CREATE INDEX "idx_barangays_city_id" ON "public"."barangays" USING "btree" ("city_id");



CREATE INDEX "idx_barangays_feeder_id" ON "public"."barangays" USING "btree" ("feeder_id");



CREATE INDEX "idx_cities_province_id" ON "public"."cities" USING "btree" ("province_id");



CREATE INDEX "idx_crews_name" ON "public"."crews" USING "btree" ("name");



CREATE INDEX "idx_outage_reports_linked_outage_id" ON "public"."outage_reports" USING "btree" ("linked_outage_id");



CREATE INDEX "idx_outage_reports_location" ON "public"."outage_reports" USING "gist" ("location");



CREATE INDEX "idx_outage_reports_reported_by" ON "public"."outage_reports" USING "btree" ("reported_by");



CREATE INDEX "idx_outage_reports_status" ON "public"."outage_reports" USING "btree" ("status");



CREATE INDEX "idx_outage_updates_outage_id" ON "public"."outage_updates" USING "btree" ("outage_id");



CREATE INDEX "idx_outage_updates_user_id" ON "public"."outage_updates" USING "btree" ("user_id");



CREATE INDEX "idx_outages_confirmed_by" ON "public"."outages" USING "btree" ("confirmed_by");



CREATE INDEX "idx_outages_resolved_by" ON "public"."outages" USING "btree" ("resolved_by");



CREATE INDEX "idx_outages_start_time" ON "public"."outages" USING "btree" ("start_time");



CREATE INDEX "idx_outages_status" ON "public"."outages" USING "btree" ("status");



CREATE INDEX "idx_weather_city_id" ON "public"."weather_data" USING "btree" ("city_id");



CREATE OR REPLACE VIEW "public"."outage_summary" AS
 SELECT "o"."id",
    "o"."public_id",
    "o"."status",
    "count"("aa"."barangay_id") AS "affected_barangay_count",
    COALESCE("sum"("b"."population"), (0)::bigint) AS "estimated_population_affected"
   FROM (("public"."outages" "o"
     LEFT JOIN "public"."affected_areas" "aa" ON (("o"."id" = "aa"."outage_id")))
     LEFT JOIN "public"."barangays" "b" ON (("aa"."barangay_id" = "b"."id")))
  GROUP BY "o"."id";



CREATE OR REPLACE TRIGGER "trg_assignments_updated" BEFORE UPDATE ON "public"."assignments" FOR EACH ROW EXECUTE FUNCTION "public"."update_timestamp_on_modify"();



CREATE OR REPLACE TRIGGER "trg_barangays_updated" BEFORE UPDATE ON "public"."barangays" FOR EACH ROW EXECUTE FUNCTION "public"."update_timestamp_on_modify"();



CREATE OR REPLACE TRIGGER "trg_cities_updated" BEFORE UPDATE ON "public"."cities" FOR EACH ROW EXECUTE FUNCTION "public"."update_timestamp_on_modify"();



CREATE OR REPLACE TRIGGER "trg_crews_updated" BEFORE UPDATE ON "public"."crews" FOR EACH ROW EXECUTE FUNCTION "public"."update_timestamp_on_modify"();



CREATE OR REPLACE TRIGGER "trg_feeders_updated" BEFORE UPDATE ON "public"."feeders" FOR EACH ROW EXECUTE FUNCTION "public"."update_timestamp_on_modify"();



CREATE OR REPLACE TRIGGER "trg_outage_reports_updated" BEFORE UPDATE ON "public"."outage_reports" FOR EACH ROW EXECUTE FUNCTION "public"."update_timestamp_on_modify"();



CREATE OR REPLACE TRIGGER "trg_outages_updated" BEFORE UPDATE ON "public"."outages" FOR EACH ROW EXECUTE FUNCTION "public"."update_timestamp_on_modify"();



CREATE OR REPLACE TRIGGER "trg_profile_settings_updated" BEFORE UPDATE ON "public"."profile_settings" FOR EACH ROW EXECUTE FUNCTION "public"."update_timestamp_on_modify"();



CREATE OR REPLACE TRIGGER "trg_provinces_updated" BEFORE UPDATE ON "public"."provinces" FOR EACH ROW EXECUTE FUNCTION "public"."update_timestamp_on_modify"();



CREATE OR REPLACE TRIGGER "trg_system_config_updated" BEFORE UPDATE ON "public"."system_config" FOR EACH ROW EXECUTE FUNCTION "public"."update_timestamp_on_modify"();



ALTER TABLE ONLY "public"."affected_areas"
    ADD CONSTRAINT "affected_areas_barangay_id_fkey" FOREIGN KEY ("barangay_id") REFERENCES "public"."barangays"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."affected_areas"
    ADD CONSTRAINT "affected_areas_outage_id_fkey" FOREIGN KEY ("outage_id") REFERENCES "public"."outages"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."api_keys"
    ADD CONSTRAINT "api_keys_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."assignments"
    ADD CONSTRAINT "assignments_crew_id_fkey" FOREIGN KEY ("crew_id") REFERENCES "public"."crews"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."assignments"
    ADD CONSTRAINT "assignments_outage_id_fkey" FOREIGN KEY ("outage_id") REFERENCES "public"."outages"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."barangays"
    ADD CONSTRAINT "barangays_city_id_fkey" FOREIGN KEY ("city_id") REFERENCES "public"."cities"("id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."barangays"
    ADD CONSTRAINT "barangays_feeder_id_fkey" FOREIGN KEY ("feeder_id") REFERENCES "public"."feeders"("id") ON UPDATE CASCADE ON DELETE SET NULL;



ALTER TABLE ONLY "public"."cities"
    ADD CONSTRAINT "cities_province_id_fkey" FOREIGN KEY ("province_id") REFERENCES "public"."provinces"("id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."outage_reports"
    ADD CONSTRAINT "outage_reports_linked_outage_id_fkey" FOREIGN KEY ("linked_outage_id") REFERENCES "public"."outages"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."outage_reports"
    ADD CONSTRAINT "outage_reports_reported_by_fkey" FOREIGN KEY ("reported_by") REFERENCES "public"."profiles"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."outage_updates"
    ADD CONSTRAINT "outage_updates_outage_id_fkey" FOREIGN KEY ("outage_id") REFERENCES "public"."outages"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."outage_updates"
    ADD CONSTRAINT "outage_updates_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."outages"
    ADD CONSTRAINT "outages_confirmed_by_fkey" FOREIGN KEY ("confirmed_by") REFERENCES "public"."profiles"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."outages"
    ADD CONSTRAINT "outages_resolved_by_fkey" FOREIGN KEY ("resolved_by") REFERENCES "public"."profiles"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."profile_settings"
    ADD CONSTRAINT "profile_settings_profile_id_fkey" FOREIGN KEY ("profile_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "profiles_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON UPDATE CASCADE ON DELETE CASCADE;



ALTER TABLE ONLY "public"."system_config"
    ADD CONSTRAINT "system_config_updated_by_fkey" FOREIGN KEY ("updated_by") REFERENCES "public"."profiles"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."weather_data"
    ADD CONSTRAINT "weather_data_city_id_fkey" FOREIGN KEY ("city_id") REFERENCES "public"."cities"("id") ON UPDATE CASCADE ON DELETE CASCADE;



CREATE POLICY "Crew and admin can read assignments" ON "public"."assignments" FOR SELECT TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."profiles" "p"
  WHERE (("p"."user_id" = ( SELECT "auth"."uid"() AS "uid")) AND ("p"."role" = ANY (ARRAY['crew'::"public"."roles", 'admin'::"public"."roles"]))))));



CREATE POLICY "Crew and admin can read crews" ON "public"."crews" FOR SELECT TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."profiles" "p"
  WHERE (("p"."user_id" = ( SELECT "auth"."uid"() AS "uid")) AND ("p"."role" = ANY (ARRAY['crew'::"public"."roles", 'admin'::"public"."roles"]))))));



CREATE POLICY "Public can read affected_areas" ON "public"."affected_areas" FOR SELECT USING (true);



CREATE POLICY "Public can read barangays" ON "public"."barangays" FOR SELECT USING (true);



CREATE POLICY "Public can read cities" ON "public"."cities" FOR SELECT USING (true);



CREATE POLICY "Public can read feeders" ON "public"."feeders" FOR SELECT USING (true);



CREATE POLICY "Public can read geographic and weather data" ON "public"."provinces" FOR SELECT USING (true);



CREATE POLICY "Public can read outage_reports" ON "public"."outage_reports" FOR SELECT USING (true);



CREATE POLICY "Public can read outage_updates" ON "public"."outage_updates" FOR SELECT USING (true);



CREATE POLICY "Public can read outages" ON "public"."outages" FOR SELECT USING (true);



CREATE POLICY "Public can read weather_data" ON "public"."weather_data" FOR SELECT USING (true);



CREATE POLICY "Users can create their own API keys" ON "public"."api_keys" FOR INSERT TO "authenticated" WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."profiles" "p"
  WHERE (("p"."user_id" = ( SELECT "auth"."uid"() AS "uid")) AND ("p"."id" = "api_keys"."created_by")))));



CREATE POLICY "Users can create their own outage reports" ON "public"."outage_reports" FOR INSERT TO "authenticated" WITH CHECK ((("reported_by" IS NULL) OR (EXISTS ( SELECT 1
   FROM "public"."profiles" "p"
  WHERE (("p"."user_id" = ( SELECT "auth"."uid"() AS "uid")) AND ("p"."id" = "outage_reports"."reported_by"))))));



CREATE POLICY "Users can read their own API keys" ON "public"."api_keys" FOR SELECT TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."profiles" "p"
  WHERE (("p"."user_id" = ( SELECT "auth"."uid"() AS "uid")) AND ("p"."id" = "api_keys"."created_by")))));



CREATE POLICY "Users can update their own API keys" ON "public"."api_keys" FOR UPDATE TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM "public"."profiles" "p"
  WHERE (("p"."user_id" = ( SELECT "auth"."uid"() AS "uid")) AND ("p"."id" = "api_keys"."created_by"))))) WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."profiles" "p"
  WHERE (("p"."user_id" = ( SELECT "auth"."uid"() AS "uid")) AND ("p"."id" = "api_keys"."created_by")))));



ALTER TABLE "public"."affected_areas" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."api_keys" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."assignments" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."barangays" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."cities" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."crews" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."feeders" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."outage_reports" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."outage_updates" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."outages" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."profile_settings" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."profiles" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."provinces" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."system_config" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."weather_data" ENABLE ROW LEVEL SECURITY;




ALTER PUBLICATION "supabase_realtime" OWNER TO "postgres";


REVOKE USAGE ON SCHEMA "public" FROM PUBLIC;
GRANT ALL ON SCHEMA "public" TO PUBLIC;









































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































RESET ALL;
