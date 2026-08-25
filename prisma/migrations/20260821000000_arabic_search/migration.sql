-- Arabic-aware search keys.
--
-- Readers treat several Arabic characters as the same letter, and keyboards
-- make one form far easier to reach than the others: someone looking for
-- "أطلس" types "اطلس". A raw LIKE against the stored name finds nothing.
--
-- These are STORED GENERATED columns rather than columns the application
-- maintains. The database derives them from the source column on every write,
-- so they cannot drift out of step with the data, and a row inserted by a
-- migration, a seed script or a psql session is indexed the same as one
-- inserted by the app.
--
-- `translate` maps each character in the second argument to the one at the
-- same position in the third, and DELETES any character with no counterpart —
-- which is how the trailing diacritics and the tatweel are stripped. It is
-- IMMUTABLE, as `lower` and `regexp_replace` are, which is what lets the
-- expression be used in a generated column at all.
--
-- Keep this in step with `normalizeArabic` in src/lib/arabic.ts. The two run
-- in different languages against the same data, and if they disagree the
-- failure is silent: searches quietly return less than they should.

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
      'اااهيوي0123456789'
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

-- Substring search cannot use a btree index, so both tables get a trigram
-- index instead. Without it every query is a sequential scan over the whole
-- catalogue, which is survivable at a dozen providers and not at a thousand.
CREATE EXTENSION IF NOT EXISTS pg_trgm;

CREATE INDEX "Provider_searchKey_trgm_idx" ON "Provider" USING gin ("searchKey" gin_trgm_ops);
CREATE INDEX "Service_searchKey_trgm_idx" ON "Service" USING gin ("searchKey" gin_trgm_ops);
