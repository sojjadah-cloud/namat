import { getTranslations } from 'next-intl/server';
import { Link } from '@/i18n/routing';
import { Logo } from '@/components/brand/Logo';

/**
 * Deep green close. The footer is where the brand gets to be a colour rather
 * than a set of components, so it carries the dark bloom and the full lockup.
 */
export async function Footer() {
  const t = await getTranslations('Landing.footer');
  const tb = await getTranslations('Brand');

  const columns = [
    {
      title: t('namat'),
      links: [
        { href: '/about', label: t('about') },
        { href: '/services', label: t('services') },
        { href: '/packages', label: t('howItWorks') },
      ],
    },
    {
      title: t('services'),
      links: [
        { href: '/partners', label: t('partners') },
        { href: '/partners', label: t('join') },
      ],
    },
    {
      title: t('support'),
      links: [
        { href: '/about', label: t('faq') },
        { href: '/about', label: t('contact') },
        { href: '/about', label: t('help') },
      ],
    },
  ];

  return (
    <footer className="bloom-dark relative bg-green-deep text-white">
      <div className="mx-auto max-w-[1240px] px-5 py-16 md:px-8 md:py-20">
        <div className="grid gap-12 md:grid-cols-[1.4fr_repeat(3,1fr)]">
          <div>
            <Logo size="md" tone="mono" tagline={tb('taglineShort')} className="text-white" />
            <p className="mt-6 max-w-[34ch] text-[15px] leading-relaxed text-white/60">
              {t('brandLine')}
            </p>
          </div>

          {columns.map((col) => (
            <div key={col.title}>
              <p className="text-[11px] font-medium uppercase tracking-[0.16em] text-white/45">
                {col.title}
              </p>
              <ul className="mt-4 space-y-3">
                {col.links.map((link) => (
                  <li key={link.label}>
                    <Link
                      href={link.href}
                      className="text-[15px] text-white/75 underline-offset-4 transition-colors hover:text-white hover:underline"
                    >
                      {link.label}
                    </Link>
                  </li>
                ))}
              </ul>
            </div>
          ))}
        </div>

        <div className="mt-14 flex flex-col gap-4 border-t border-white/12 pt-8 md:flex-row md:items-center md:justify-between">
          <p className="text-[13px] text-white/50">{t('madeIn')}</p>
          <div className="flex flex-wrap items-center gap-x-6 gap-y-2 text-[13px] text-white/50">
            <Link href="/about" className="transition-colors hover:text-white">
              {t('terms')}
            </Link>
            <Link href="/about" className="transition-colors hover:text-white">
              {t('privacy')}
            </Link>
            <span>© {new Date().getFullYear()} {t('rights')}</span>
          </div>
        </div>
      </div>
    </footer>
  );
}
