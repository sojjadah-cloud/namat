import Image from 'next/image';
import { getTranslations } from 'next-intl/server';
import { Users, Check } from 'lucide-react';
import { Link } from '@/i18n/routing';
import { Badge } from '@/components/ui/chip';
import { ProgressTrack } from '@/components/ui/ring';
import { CHALLENGE_META } from '@/lib/challenge-meta';
import { formatNumber } from '@/lib/format';
import type { ChallengeKind, ChallengeLevel } from '@prisma/client';

/**
 * One challenge in a list.
 *
 * The image is a band across the top rather than a full-bleed background: the
 * card carries five pieces of metadata, and white text over a photograph makes
 * all five harder to read for the sake of one that is prettier.
 */
export async function ChallengeCard({
  challenge,
  locale,
}: {
  locale: string;
  challenge: {
    slug: string;
    title: string;
    summary: string;
    image: string;
    kind: ChallengeKind;
    level: ChallengeLevel;
    durationDays: number;
    rewardPoints: number;
    participants: number;
    joined: boolean;
    /** 0–100 when enrolled, otherwise null. */
    percent?: number | null;
  };
}) {
  const t = await getTranslations('Challenges');
  const meta = CHALLENGE_META[challenge.kind];
  const Icon = meta.icon;

  return (
    <Link
      href={`/app/challenges/${challenge.slug}`}
      className="group block overflow-hidden rounded-xl bg-surface shadow-[var(--shadow-sm)] transition-shadow hover:shadow-[var(--shadow-md)]"
    >
      <div className="relative aspect-[16/7] overflow-hidden">
        <Image
          src={challenge.image}
          alt=""
          fill
          sizes="(max-width: 430px) 100vw, 400px"
          className="object-cover transition-transform duration-500 group-hover:scale-[1.04]"
        />
        <span
          className={`absolute top-3 grid size-9 place-items-center rounded-full bg-white/95 start-3 ${meta.fg}`}
        >
          <Icon className="size-[18px]" strokeWidth={2} aria-hidden />
        </span>
        {challenge.joined ? (
          <span className="absolute top-3 end-3">
            <Badge tone="goal" size="sm">
              <Check aria-hidden />
              {t('joined')}
            </Badge>
          </span>
        ) : null}
      </div>

      <div className="p-4">
        <div className="flex items-center gap-2 text-[12px] text-ink-soft">
          <span className={`rounded-full px-2 py-0.5 font-medium ${meta.bg} ${meta.fg}`}>
            {t(`kind${challenge.kind}`)}
          </span>
          <span>·</span>
          <span>{t('duration', { days: formatNumber(challenge.durationDays, locale) })}</span>
          <span>·</span>
          <span>{t(`level${challenge.level}`)}</span>
        </div>

        <h3 className="mt-2.5 text-[17px] font-semibold text-ink">{challenge.title}</h3>
        <p className="mt-1 line-clamp-2 text-[14px] leading-snug text-ink-soft">
          {challenge.summary}
        </p>

        {challenge.joined && typeof challenge.percent === 'number' ? (
          <div className="mt-3.5">
            <ProgressTrack value={challenge.percent} />
          </div>
        ) : null}

        <div className="mt-3.5 flex items-center justify-between text-[13px]">
          <span className="inline-flex items-center gap-1.5 text-ink-soft">
            <Users className="size-3.5" aria-hidden />
            {t('participants', { count: formatNumber(challenge.participants, locale) })}
          </span>
          <span className="font-medium text-green-accent">
            {t('reward', { points: formatNumber(challenge.rewardPoints, locale) })}
          </span>
        </div>
      </div>
    </Link>
  );
}
