import { SearchScreen } from '@/features/search/SearchScreen';
import { searchProviders } from '@/server/queries/explore';

export default async function SearchPage({
  searchParams,
}: {
  searchParams: Promise<Record<string, string | undefined>>;
}) {
  const { q } = await searchParams;
  const query = q?.trim() ?? '';

  // "Popular right now" is review volume, not a curated list — it stays honest
  // as the catalogue grows and needs no editorial upkeep.
  const [results, trending] = await Promise.all([
    query ? searchProviders({ q: query }) : Promise.resolve([]),
    searchProviders({ sort: 'recommended' }),
  ]);

  return (
    <SearchScreen query={query} results={results} trending={trending.slice(0, 4)} />
  );
}
