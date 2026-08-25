import { LogoMark } from '@/components/brand/Logo';

/**
 * The brand moment, shown only while the first screen is genuinely being
 * fetched — never as a fixed-duration splash. On a warm cache it flashes for a
 * frame or not at all, which is the correct amount of time to look at a logo
 * you have already seen.
 */
export default function AppLoading() {
  return (
    <div className="grid min-h-dvh place-items-center bg-canvas">
      <div className="flex flex-col items-center">
        <LogoMark className="size-14 animate-pulse" />
        <span className="mt-6 h-1 w-24 overflow-hidden rounded-full bg-green/12">
          <span className="block h-full w-1/3 animate-[loading_1.2s_ease-in-out_infinite] rounded-full bg-green" />
        </span>
      </div>
    </div>
  );
}
