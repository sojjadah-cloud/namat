-- Fix an off-by-one in the search-key character mapping.
--
-- `translate` pairs the two argument strings by position. The source listed
-- four alef carriers (أ إ آ ٱ) but the destination supplied only three alefs,
-- so every mapping after the third shifted by one place: ة became ي, ى became
-- و, ؤ became ي, and ئ became the digit 0.
--
-- The damage was invisible in the data — the generated column simply held the
-- wrong key, and searches for "عافيه" returned nothing while looking entirely
-- healthy. What caught it was comparing the SQL output against the TypeScript
-- implementation row by row over the seeded catalogue.
--
-- The columns are dropped and recreated rather than backfilled: they are
-- GENERATED ALWAYS, so recreating them re-derives every row from its source.

ALTER TABLE "Provider" DROP COLUMN IF EXISTS "searchKey";
ALTER TABLE "Service" DROP COLUMN IF EXISTS "searchKey";

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
      -- 4 alef carriers, ة, ى, ؤ, ئ, 10 digits, then 9 diacritics and the
      -- tatweel, which have no counterpart below and are therefore deleted.
      'أإآٱةىؤئ٠١٢٣٤٥٦٧٨٩ًٌٍَُِّْٰـ',
      'ااااهيوي0123456789'
    ),
    '\s+', ' ', 'g'
  )
$$;

ALTER TABLE "Provider"
  ADD COLUMN "searchKey" text
  GENERATED ALWAYS AS (
    namat_search_key(
      coalesce("nameAr", '') || ' ' || coalesce("nameEn", '') || ' ' ||
      coalesce("addressAr", '') || ' ' || coalesce("addressEn", '')
    )
  ) STORED;

ALTER TABLE "Service"
  ADD COLUMN "searchKey" text
  GENERATED ALWAYS AS (
    namat_search_key(
      coalesce("nameAr", '') || ' ' || coalesce("nameEn", '')
    )
  ) STORED;

CREATE INDEX "Provider_searchKey_trgm_idx" ON "Provider" USING gin ("searchKey" gin_trgm_ops);
CREATE INDEX "Service_searchKey_trgm_idx" ON "Service" USING gin ("searchKey" gin_trgm_ops);
