-- Adopt Prisma's own naming for the two trigram indexes.
--
-- They were created by hand as *_trgm_idx before the schema could express
-- them. Now that it can, matching Prisma's convention takes migration drift to
-- zero, so a future `migrate diff` reports genuine changes and nothing else.
ALTER INDEX "Provider_searchKey_trgm_idx" RENAME TO "Provider_searchKey_idx";
ALTER INDEX "Service_searchKey_trgm_idx"  RENAME TO "Service_searchKey_idx";
