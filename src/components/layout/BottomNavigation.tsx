'use client';

import * as React from 'react';
import { motion } from 'motion/react';
import { useTranslations } from 'next-intl';
import { House, Compass, Route, CalendarCheck, User } from 'lucide-react';
import { Link, usePathname } from '@/i18n/routing';
import { cn } from '@/lib/utils';

/**
 * Five destinations, never six. Packages are reached from Home, Journey and
 * Profile — putting them here would turn a lifestyle app into a shop.
 *
 * The active pill is a shared layout element, so switching tabs slides it
 * rather than popping it.
 */

const ITEMS = [
  { href: '/app', icon: House, key: 'home' },
  // Discovery starts with the question, not the catalogue: /app/use asks
  // which field you want, and the flat list lives one level down.
  { href: '/app/use', icon: Compass, key: 'use' },
  { href: '/app/journey', icon: Route, key: 'journey' },
  { href: '/app/bookings', icon: CalendarCheck, key: 'bookings' },
  { href: '/app/profile', icon: User, key: 'profile' },
] as const;

export function BottomNavigation() {
  const pathname = usePathname();
  const t = useTranslations('AppNav');

  return (
    <nav
      aria-label={t('home')}
      className={cn(
        'fixed inset-x-0 bottom-0 z-50 border-t border-line/70',
        'bg-canvas/85 backdrop-blur-xl safe-bottom',
        'md:absolute',
      )}
    >
      <ul className="mx-auto flex max-w-md items-stretch justify-between px-2 pt-1.5 pb-1.5">
        {ITEMS.map(({ href, icon: Icon, key }) => {
          // `/app` must not light up for every child route.
          const active = href === '/app' ? pathname === '/app' : pathname.startsWith(href);

          return (
            <li key={href} className="flex-1">
              <Link
                href={href}
                aria-current={active ? 'page' : undefined}
                className="group relative flex flex-col items-center gap-1 rounded-md py-1.5"
              >
                <span className="relative grid size-8 place-items-center">
                  {active ? (
                    <motion.span
                      layoutId="bottom-nav-pill"
                      transition={{ type: 'spring', stiffness: 420, damping: 34 }}
                      className="absolute inset-0 rounded-full bg-green-soft"
                    />
                  ) : null}
                  <Icon
                    className={cn(
                      'relative size-[22px] transition-colors duration-200',
                      active ? 'text-green' : 'text-ink-soft group-hover:text-ink',
                    )}
                    strokeWidth={active ? 2.3 : 1.9}
                    aria-hidden
                  />
                </span>
                <span
                  className={cn(
                    'text-[10px] leading-none transition-colors duration-200',
                    active ? 'font-semibold text-green' : 'font-medium text-ink-soft',
                  )}
                >
                  {t(key)}
                </span>
              </Link>
            </li>
          );
        })}
      </ul>
    </nav>
  );
}
