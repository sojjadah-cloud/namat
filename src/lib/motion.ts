import type { Variants, Transition } from 'motion/react';

/**
 * NAMAT motion: calm, fast, purposeful. 200–350ms on a single easing curve.
 * Nothing bounces, nothing spins.
 */

export const EASE = [0.22, 0.61, 0.36, 1] as const;

export const transition: Transition = { duration: 0.26, ease: EASE };
export const transitionSlow: Transition = { duration: 0.34, ease: EASE };

/** Content arriving: fade with a short lift. */
export const fadeUp: Variants = {
  hidden: { opacity: 0, y: 12 },
  show: { opacity: 1, y: 0, transition },
};

export const fade: Variants = {
  hidden: { opacity: 0 },
  show: { opacity: 1, transition },
};

/** Parent for staggered lists — children use `fadeUp`. */
export const stagger = (delayChildren = 0, staggerChildren = 0.06): Variants => ({
  hidden: {},
  show: { transition: { delayChildren, staggerChildren } },
});

/** Scroll-triggered section reveal. Runs once, never on the way back up. */
export const revealProps = {
  initial: 'hidden' as const,
  whileInView: 'show' as const,
  viewport: { once: true, amount: 0.25 },
  variants: fadeUp,
};

/** Bottom sheet: springs up from the bottom edge, dims behind. */
export const sheet: Variants = {
  hidden: { y: '100%' },
  show: { y: 0, transition: { type: 'spring', stiffness: 380, damping: 38 } },
  exit: { y: '100%', transition: { duration: 0.22, ease: EASE } },
};

export const scrim: Variants = {
  hidden: { opacity: 0 },
  show: { opacity: 1, transition: { duration: 0.2 } },
  exit: { opacity: 0, transition: { duration: 0.18 } },
};

/** Press feedback for cards and buttons. */
export const press = { scale: 0.985 };

/** Step-to-step movement in onboarding and booking, direction aware. */
export const slideStep = (rtl: boolean): Variants => {
  const d = rtl ? -1 : 1;
  return {
    hidden: (back: boolean) => ({ opacity: 0, x: (back ? -1 : 1) * d * 28 }),
    show: { opacity: 1, x: 0, transition },
    exit: (back: boolean) => ({
      opacity: 0,
      x: (back ? 1 : -1) * d * 28,
      transition: { duration: 0.18, ease: EASE },
    }),
  };
};
