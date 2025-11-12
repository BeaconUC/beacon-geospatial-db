CREATE TABLE "public"."announcements" (
    "id" BIGSERIAL PRIMARY KEY,
    "public_id" UUID DEFAULT "extensions"."gen_random_uuid"() NOT NULL UNIQUE,
    "title" VARCHAR(255) NOT NULL,
    "content" TEXT NOT NULL,
    "author_id" BIGINT REFERENCES "public"."profiles"("id") ON DELETE SET NULL,
    "is_urgent" BOOLEAN DEFAULT FALSE NOT NULL,
    "created_at" TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    "updated_at" TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX "idx_announcements_author_id" ON "public"."announcements" ("author_id");
CREATE INDEX "idx_announcements_is_urgent" ON "public"."announcements" ("is_urgent");

CREATE TRIGGER "trg_announcements_updated"
    BEFORE UPDATE ON "public"."announcements"
    FOR EACH ROW EXECUTE FUNCTION "public"."update_timestamp_on_modify"();

CREATE TABLE "public"."announcements_scope" (
    "id" BIGSERIAL PRIMARY KEY,
    "announcement_id" BIGINT NOT NULL REFERENCES "public"."announcements"("id") ON DELETE CASCADE,
    "barangay_id" BIGINT REFERENCES "public"."barangays"("id") ON DELETE SET NULL,
    "outage_id" BIGINT REFERENCES "public"."outages"("id") ON DELETE SET NULL,
    "created_at" TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    UNIQUE ("announcement_id", "barangay_id", "outage_id")
);

CREATE INDEX "idx_announcements_scope_announcement_id" ON "public"."announcements_scope" ("announcement_id");
CREATE INDEX "idx_announcements_scope_barangay_id" ON "public"."announcements_scope" ("barangay_id");
CREATE INDEX "idx_announcements_scope_outage_id" ON "public"."announcements_scope" ("outage_id");

ALTER TABLE "public"."announcements" ENABLE ROW LEVEL SECURITY;
ALTER TABLE "public"."announcements_scope" ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public can read announcements"
    ON "public"."announcements" FOR SELECT USING (TRUE);

GRANT SELECT ON "public"."announcements" TO anon, authenticated;
GRANT INSERT, UPDATE, DELETE ON "public"."announcements" TO authenticated;
GRANT USAGE, SELECT ON SEQUENCE "public"."announcements_id_seq" TO authenticated;

GRANT SELECT ON "public"."announcements_scope" TO anon, authenticated;
GRANT INSERT, UPDATE, DELETE ON "public"."announcements_scope" TO authenticated;
GRANT USAGE, SELECT ON SEQUENCE "public"."announcements_scope_id_seq" TO authenticated;

CREATE POLICY "Public can read announcement_scope"
    ON "public"."announcements_scope" FOR SELECT USING (TRUE);

CREATE POLICY "Admin can manage announcements"
    ON "public"."announcements"
    FOR ALL TO "authenticated"
    USING (
        EXISTS (
            SELECT 1 FROM "public"."profiles" p
            WHERE p."user_id" = (SELECT "auth"."uid"())
              AND p."role" = 'admin'::"public"."roles"
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM "public"."profiles" p
            WHERE p."user_id" = (SELECT "auth"."uid"())
              AND p."role" = 'admin'::"public"."roles"
        )
    );