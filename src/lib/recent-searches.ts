/**
 * Recent searches, backed by localStorage and exposed as an external store.
 *
 * A store rather than component state for two reasons: reading localStorage
 * during render would break hydration, and mirroring it into an effect means a
 * second render on every mount. `useSyncExternalStore` handles both, and
 * subscribing to the `storage` event means a search in one tab shows up in the
 * others without a reload.
 *
 * Recents are a local convenience, not a profile signal — they stay on the
 * device and are never sent anywhere.
 */

const KEY = 'namat.recent-searches';
const MAX = 6;
const EMPTY: readonly string[] = Object.freeze([]);

// getSnapshot must return a referentially stable value or React re-renders
// forever, so the parsed array is cached against the raw string it came from.
let cachedRaw: string | null = null;
let cachedValue: readonly string[] = EMPTY;

const listeners = new Set<() => void>();

function emit() {
  for (const listener of listeners) listener();
}

function read(): string | null {
  try {
    return localStorage.getItem(KEY);
  } catch {
    // Private mode or blocked storage — recents are optional.
    return null;
  }
}

function write(next: readonly string[]) {
  try {
    localStorage.setItem(KEY, JSON.stringify(next));
  } catch {
    /* quota or private mode — the in-memory value still updates */
  }
  emit();
}

export function subscribe(onChange: () => void) {
  listeners.add(onChange);
  window.addEventListener('storage', onChange);
  return () => {
    listeners.delete(onChange);
    window.removeEventListener('storage', onChange);
  };
}

export function getSnapshot(): readonly string[] {
  const raw = read();
  if (raw === cachedRaw) return cachedValue;

  cachedRaw = raw;
  try {
    const parsed: unknown = raw ? JSON.parse(raw) : null;
    cachedValue = Array.isArray(parsed)
      ? parsed.filter((entry): entry is string => typeof entry === 'string').slice(0, MAX)
      : EMPTY;
  } catch {
    // Corrupted value — drop it rather than let it break the screen.
    cachedValue = EMPTY;
  }
  return cachedValue;
}

/** The server has no localStorage, and an empty list is what it renders. */
export function getServerSnapshot(): readonly string[] {
  return EMPTY;
}

export function remember(query: string) {
  const current = getSnapshot();
  write([query, ...current.filter((entry) => entry !== query)].slice(0, MAX));
}

export function clearRecent() {
  try {
    localStorage.removeItem(KEY);
  } catch {
    /* ignore */
  }
  emit();
}
