-- Food catalogue fields, and a change of technique for the search key.
--
-- ── Why searchKey stops being a generated column ──────────────────────────
-- It was GENERATED ALWAYS, which is the right database primitive but the
-- wrong one to pair with Prisma: Prisma cannot express generated columns, so
-- it does not know the column exists, and every `migrate diff` since has
-- wanted to DROP it. That is a trap waiting for whoever runs the next
-- migration without reading the SQL.
--
-- A plain column kept in step by a trigger behaves identically from the
-- outside — still derived, still impossible to drift, still correct for rows
-- written by psql or a seed script — while being an ordinary column that
-- Prisma can hold in its schema and leave alone.

-- CreateEnum
CREATE TYPE "FoodTag" AS ENUM ('MEALS', 'SUBSCRIPTIONS', 'HIGH_PROTEIN', 'KETO', 'LOW_CARB', 'VEGETARIAN', 'SALADS', 'JUICES', 'BAKERY', 'GROCERY');
CREATE TYPE "MenuProfile" AS ENUM ('DEDICATED', 'MOSTLY', 'MIXED');
CREATE TYPE "DataConfidence" AS ENUM ('CONFIRMED', 'LIKELY', 'UNVERIFIED');
CREATE TYPE "PartnerStatus" AS ENUM ('PROSPECT', 'PARTNER', 'BENCHMARK');
CREATE TYPE "PartnerGrade" AS ENUM ('A_PLUS', 'A', 'B_PLUS', 'B', 'C_PLUS', 'C');

-- Replace the generated search columns with ordinary ones.
DROP INDEX IF EXISTS "Provider_searchKey_trgm_idx";
DROP INDEX IF EXISTS "Service_searchKey_trgm_idx";
ALTER TABLE "Provider" DROP COLUMN IF EXISTS "searchKey";
ALTER TABLE "Service"  DROP COLUMN IF EXISTS "searchKey";

ALTER TABLE "Provider" ADD COLUMN "searchKey" text;
ALTER TABLE "Service"  ADD COLUMN "searchKey" text;

-- Coordinates become optional: most researched partners have no confirmed
-- position, and a fabricated one is worse than an absent one.
ALTER TABLE "Provider" ALTER COLUMN "latitude"  DROP NOT NULL;
ALTER TABLE "Provider" ALTER COLUMN "longitude" DROP NOT NULL;

-- Rating becomes optional and loses its zero default. A default of 0 renders
-- as a real score of zero stars against a real business.
ALTER TABLE "Provider" ALTER COLUMN "rating" DROP NOT NULL;
ALTER TABLE "Provider" ALTER COLUMN "rating" DROP DEFAULT;
UPDATE "Provider" SET "rating" = NULL WHERE "rating" = 0;

ALTER TABLE "Provider" ALTER COLUMN "aboutEn" DROP NOT NULL;
ALTER TABLE "Provider" ALTER COLUMN "aboutAr" DROP NOT NULL;
ALTER TABLE "Provider" ALTER COLUMN "image"   DROP NOT NULL;

ALTER TABLE "Provider"
  ADD COLUMN "coordsVerified"   boolean NOT NULL DEFAULT false,
  ADD COLUMN "area"             text,
  ADD COLUMN "foodTags"         "FoodTag"[] DEFAULT ARRAY[]::"FoodTag"[],
  ADD COLUMN "menuProfile"      "MenuProfile",
  ADD COLUMN "dataConfidence"   "DataConfidence" NOT NULL DEFAULT 'UNVERIFIED',
  ADD COLUMN "status"           "PartnerStatus" NOT NULL DEFAULT 'PROSPECT',
  ADD COLUMN "grade"            "PartnerGrade",
  ADD COLUMN "ownDelivery"      boolean,
  ADD COLUMN "platformDelivery" boolean,
  ADD COLUMN "pickup"           boolean,
  ADD COLUMN "weeklyPlan"       boolean,
  ADD COLUMN "monthlyPlan"      boolean,
  ADD COLUMN "caloriesLabelled" boolean,
  ADD COLUMN "proteinLabelled"  boolean,
  ADD COLUMN "fromPrice"        double precision,
  ADD COLUMN "researchNote"     text;

-- The folding function is unchanged; see 20260821010000 for the character map
-- and the off-by-one it corrected.
CREATE OR REPLACE FUNCTION namat_search_key(source text)
RETURNS text
LANGUAGE sql
IMMUTABLE
PARALLEL SAFE
STRICT
AS $$
  SELECT regexp_replace(
    translate(
      lower(source),
      'أإآٱةىؤئ٠١٢٣٤٥٦٧٨٩ًٌٍَُِّْٰـ',
      'ااااهيوي0123456789'
    ),
    '\s+', ' ', 'g'
  )
$$;

CREATE OR REPLACE FUNCTION provider_search_key_trigger()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  NEW."searchKey" := namat_search_key(
    coalesce(NEW."nameAr", '')    || ' ' || coalesce(NEW."nameEn", '') || ' ' ||
    coalesce(NEW."addressAr", '') || ' ' || coalesce(NEW."addressEn", '') || ' ' ||
    coalesce(NEW."area", '')
  );
  RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION service_search_key_trigger()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  NEW."searchKey" := namat_search_key(
    coalesce(NEW."nameAr", '') || ' ' || coalesce(NEW."nameEn", '')
  );
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS provider_search_key ON "Provider";
CREATE TRIGGER provider_search_key
  BEFORE INSERT OR UPDATE ON "Provider"
  FOR EACH ROW EXECUTE FUNCTION provider_search_key_trigger();

DROP TRIGGER IF EXISTS service_search_key ON "Service";
CREATE TRIGGER service_search_key
  BEFORE INSERT OR UPDATE ON "Service"
  FOR EACH ROW EXECUTE FUNCTION service_search_key_trigger();

-- Backfill the rows that existed before the trigger did.
UPDATE "Provider" SET "id" = "id";
UPDATE "Service"  SET "id" = "id";

CREATE INDEX "Provider_searchKey_trgm_idx" ON "Provider" USING gin ("searchKey" gin_trgm_ops);
CREATE INDEX "Service_searchKey_trgm_idx"  ON "Service"  USING gin ("searchKey" gin_trgm_ops);
CREATE INDEX "Provider_status_category_idx" ON "Provider" ("status", "category");
CREATE INDEX "Provider_foodTags_idx" ON "Provider" USING gin ("foodTags");
