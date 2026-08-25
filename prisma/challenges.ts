import type { PrismaClient } from '@prisma/client';

/**
 * Challenge seed data, kept out of seed.ts so that file stays readable.
 *
 * Seven challenges, one per kind, so every filter chip has something behind
 * it. Durations stay short — a 7-day challenge is finishable, and finishing is
 * the habit being trained, not the step count.
 */

const img = (id: string) =>
  `https://images.unsplash.com/photo-${id}?auto=format&fit=crop&w=1000&q=70`;

type Kind =
  | 'MOVEMENT'
  | 'NUTRITION'
  | 'HYDRATION'
  | 'SLEEP'
  | 'MIND'
  | 'CONSISTENCY'
  | 'COMMUNITY';

type SeedChallenge = {
  slug: string;
  kind: Kind;
  level: 'EASY' | 'INTERMEDIATE' | 'ADVANCED';
  titleEn: string;
  titleAr: string;
  summaryEn: string;
  summaryAr: string;
  rulesEn: string[];
  rulesAr: string[];
  image: string;
  durationDays: number;
  rewardPoints: number;
  dayPoints: number;
  baseParticipants: number;
  featured: boolean;
  sortOrder: number;
  task: {
    kind: 'COUNT' | 'CHECK';
    titleEn: string;
    titleAr: string;
    target: number;
    unitEn: string;
    unitAr: string;
  };
};

const CHALLENGES: SeedChallenge[] = [
  {
    slug: 'ten-thousand-steps',
    kind: 'MOVEMENT',
    level: 'INTERMEDIATE',
    titleEn: '10,000 Steps',
    titleAr: '١٠٬٠٠٠ خطوة',
    summaryEn: 'Seven days of walking further than yesterday asked you to.',
    summaryAr: 'سبعة أيام تمشي فيها أبعد مما طلب منك الأمس.',
    rulesEn: [
      'Reach 10,000 steps before midnight.',
      'Any walking counts — the corniche, the mall, the stairs at work.',
      'Miss a day and the streak resets, but the challenge continues.',
    ],
    rulesAr: [
      'وصّل ١٠٬٠٠٠ خطوة قبل منتصف الليل.',
      'أي مشي يحتسب — الكورنيش، المجمّع، درج الدوام.',
      'لو فاتك يوم ينكسر التتابع، بس التحدي يكمل.',
    ],
    image: img('1476480862126-209bfaa8edc8'),
    durationDays: 7,
    rewardPoints: 350,
    dayPoints: 20,
    baseParticipants: 1240,
    featured: true,
    sortOrder: 1,
    task: {
      kind: 'COUNT',
      titleEn: 'Walk 10,000 steps',
      titleAr: 'امشِ ١٠٬٠٠٠ خطوة',
      target: 10000,
      unitEn: 'steps',
      unitAr: 'خطوة',
    },
  },
  {
    slug: 'no-added-sugar',
    kind: 'NUTRITION',
    level: 'INTERMEDIATE',
    titleEn: 'No Added Sugar',
    titleAr: 'بدون سكر مضاف',
    summaryEn: 'A week without the sugar you did not choose to eat.',
    summaryAr: 'أسبوع بدون السكر اللي ما اخترت تاكله.',
    rulesEn: [
      'No added sugar in drinks, snacks or sauces.',
      'Fruit is fine. Dates are fine. Karak with three spoons is not.',
      'Read one label a day — that is where the sugar hides.',
    ],
    rulesAr: [
      'لا سكر مضاف في المشروبات ولا السناكس ولا الصوصات.',
      'الفواكه عادي. التمر عادي. الكرك بثلاث ملاعق لا.',
      'اقرأ ملصق وحد كل يوم — هناك يختبئ السكر.',
    ],
    image: img('1490474418585-ba9bad8fd0ea'),
    durationDays: 7,
    rewardPoints: 350,
    dayPoints: 20,
    baseParticipants: 860,
    featured: true,
    sortOrder: 2,
    task: {
      kind: 'CHECK',
      titleEn: 'Stay off added sugar today',
      titleAr: 'اليوم بدون سكر مضاف',
      target: 1,
      unitEn: '',
      unitAr: '',
    },
  },
  {
    slug: 'eight-glasses',
    kind: 'HYDRATION',
    level: 'EASY',
    titleEn: 'Eight Glasses',
    titleAr: 'ثمانية أكواب',
    summaryEn: 'The easiest habit to start and the first one everyone drops.',
    summaryAr: 'أسهل عادة تبدأها، وأول وحدة يتركها الكل.',
    rulesEn: [
      'Eight glasses of water across the day.',
      'Coffee and tea do not count toward the eight.',
      'Log as you go rather than guessing at night.',
    ],
    rulesAr: [
      'ثمانية أكواب ماء على مدار اليوم.',
      'القهوة والشاي ما تحتسب ضمن الثمانية.',
      'سجّل أول بأول بدل ما تخمّن بالليل.',
    ],
    image: img('1548839140-29a749e1cf4d'),
    durationDays: 14,
    rewardPoints: 400,
    dayPoints: 15,
    baseParticipants: 2130,
    featured: false,
    sortOrder: 3,
    task: {
      kind: 'COUNT',
      titleEn: 'Drink 8 glasses of water',
      titleAr: 'اشرب ٨ أكواب ماء',
      target: 8,
      unitEn: 'glasses',
      unitAr: 'كوب',
    },
  },
  {
    slug: 'lights-out',
    kind: 'SLEEP',
    level: 'INTERMEDIATE',
    titleEn: 'Lights Out by 11',
    titleAr: 'النوم قبل ١١',
    summaryEn: 'Ten nights of ending the day on purpose instead of by accident.',
    summaryAr: 'عشر ليالٍ تنهي فيها يومك بقرار، مو بالصدفة.',
    rulesEn: [
      'Phone down and lights out before 11:00 PM.',
      'No screens for the last thirty minutes.',
      'Tick it honestly — nobody else sees this.',
    ],
    rulesAr: [
      'الجوال جانباً والنور مطفي قبل ١١:٠٠ مساءً.',
      'لا شاشات في آخر نص ساعة.',
      'علّمها بصدق — ما أحد غيرك يشوفها.',
    ],
    image: img('1541781774459-bb2af2f05b55'),
    durationDays: 10,
    rewardPoints: 450,
    dayPoints: 20,
    baseParticipants: 540,
    featured: false,
    sortOrder: 4,
    task: {
      kind: 'CHECK',
      titleEn: 'Lights out before 11:00 PM',
      titleAr: 'أطفئ النور قبل ١١:٠٠ مساءً',
      target: 1,
      unitEn: '',
      unitAr: '',
    },
  },
  {
    slug: 'ten-quiet-minutes',
    kind: 'MIND',
    level: 'EASY',
    titleEn: 'Ten Quiet Minutes',
    titleAr: 'عشر دقائق هدوء',
    summaryEn: 'Ten minutes a day with nothing asking anything of you.',
    summaryAr: 'عشر دقائق يومياً ما فيها شي يطلب منك شي.',
    rulesEn: [
      'Ten uninterrupted minutes — breathing, sitting, or walking without a podcast.',
      'The same time each day works better than whenever you remember.',
      'Restlessness is normal for the first few days.',
    ],
    rulesAr: [
      'عشر دقائق متواصلة — تنفّس، جلوس، أو مشي بدون بودكاست.',
      'نفس الوقت كل يوم أفضل من «متى ما تذكرت».',
      'التململ طبيعي أول كم يوم.',
    ],
    image: img('1506126613408-eca07ce68773'),
    durationDays: 7,
    rewardPoints: 300,
    dayPoints: 15,
    baseParticipants: 720,
    featured: false,
    sortOrder: 5,
    task: {
      kind: 'COUNT',
      titleEn: 'Sit quietly for 10 minutes',
      titleAr: 'اجلس بهدوء ١٠ دقائق',
      target: 10,
      unitEn: 'minutes',
      unitAr: 'دقيقة',
    },
  },
  {
    slug: 'thirty-day-journey',
    kind: 'CONSISTENCY',
    level: 'ADVANCED',
    titleEn: '30-Day Journey',
    titleAr: 'رحلة ٣٠ يوم',
    summaryEn: 'One NAMAT activity a day for a month. The long one.',
    summaryAr: 'نشاط واحد من نمط كل يوم لمدة شهر. الطويلة.',
    rulesEn: [
      'One booked session, meal or wellness activity each day.',
      'Rest days count if you log them deliberately.',
      'This is the one that changes the shape of a month.',
    ],
    rulesAr: [
      'جلسة محجوزة أو وجبة أو نشاط عافية كل يوم.',
      'أيام الراحة تحتسب لو سجّلتها بقصد.',
      'هذي اللي تغيّر شكل الشهر.',
    ],
    image: img('1517836357463-d25dfeac3438'),
    durationDays: 30,
    rewardPoints: 1500,
    dayPoints: 25,
    baseParticipants: 310,
    featured: true,
    sortOrder: 6,
    task: {
      kind: 'CHECK',
      titleEn: 'Complete one NAMAT activity',
      titleAr: 'أكمل نشاط واحد من نمط',
      target: 1,
      unitEn: '',
      unitAr: '',
    },
  },
  {
    slug: 'muscat-moves',
    kind: 'COMMUNITY',
    level: 'EASY',
    titleEn: 'Muscat Moves',
    titleAr: 'مسقط تتحرك',
    summaryEn: 'A shared week — everyone walking the same corniche, separately.',
    summaryAr: 'أسبوع مشترك — الكل يمشي نفس الكورنيش، كلٌّ لحاله.',
    rulesEn: [
      'Thirty minutes of outdoor movement a day.',
      'Anywhere outdoors counts, not only the corniche.',
      'Progress is shared as a total, never as a leaderboard.',
    ],
    rulesAr: [
      'ثلاثون دقيقة حركة في الهواء الطلق يومياً.',
      'أي مكان خارجي يحتسب، مو بس الكورنيش.',
      'التقدّم يُعرض كمجموع، ما فيه لوحة ترتيب.',
    ],
    image: img('1552674605-db6ffd4facb5'),
    durationDays: 7,
    rewardPoints: 300,
    dayPoints: 15,
    baseParticipants: 1890,
    featured: false,
    sortOrder: 7,
    task: {
      kind: 'COUNT',
      titleEn: 'Move outdoors for 30 minutes',
      titleAr: 'تحرّك في الهواء الطلق ٣٠ دقيقة',
      target: 30,
      unitEn: 'minutes',
      unitAr: 'دقيقة',
    },
  },
];

const ACHIEVEMENTS = [
  {
    slug: 'first-challenge',
    icon: 'Flag',
    titleEn: 'First Challenge',
    titleAr: 'أول تحدٍ',
    captionEn: 'You joined your first NAMAT challenge.',
    captionAr: 'انضممت لأول تحدٍ في نمط.',
    points: 50,
    sortOrder: 1,
  },
  {
    slug: 'seven-day-streak',
    icon: 'Flame',
    titleEn: '7-Day Streak',
    titleAr: 'تتابع ٧ أيام',
    captionEn: 'Seven days in a row, no gaps.',
    captionAr: 'سبعة أيام متتالية بدون انقطاع.',
    points: 150,
    sortOrder: 2,
  },
  {
    slug: 'challenge-finisher',
    icon: 'Trophy',
    titleEn: 'Finisher',
    titleAr: 'مُكمِل',
    captionEn: 'You finished a challenge end to end.',
    captionAr: 'أنهيت تحدياً من أوله لآخره.',
    points: 200,
    sortOrder: 3,
  },
  {
    slug: 'thirty-day-journey',
    icon: 'Mountain',
    titleEn: '30-Day Journey',
    titleAr: 'رحلة ٣٠ يوم',
    captionEn: 'A full month of showing up.',
    captionAr: 'شهر كامل وأنت حاضر.',
    points: 500,
    sortOrder: 4,
  },
  {
    slug: 'active-explorer',
    icon: 'Compass',
    titleEn: 'Active Explorer',
    titleAr: 'مستكشف نشِط',
    captionEn: 'You booked across five categories.',
    captionAr: 'حجزت من خمس فئات مختلفة.',
    points: 250,
    sortOrder: 5,
  },
  {
    slug: 'healthy-week',
    icon: 'Sparkles',
    titleEn: 'Healthy Week',
    titleAr: 'أسبوع صحي',
    captionEn: 'Every goal met, seven days running.',
    captionAr: 'كل الأهداف مكتملة، سبعة أيام.',
    points: 200,
    sortOrder: 6,
  },
];

export async function seedChallenges(prisma: PrismaClient) {
  for (const { task, ...challenge } of CHALLENGES) {
    await prisma.challenge.create({
      data: {
        ...challenge,
        // A single task row with `day: null` means "the same goal every day",
        // which is what all seven of these are.
        tasks: { create: [{ ...task, day: null }] },
      },
    });
  }

  await prisma.achievement.createMany({ data: ACHIEVEMENTS });
}
