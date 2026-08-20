/**
 * NAMAT demo catalogue — Muscat.
 *
 * Everything is bilingual and plausible rather than lorem: the app is judged on
 * whether the content reads like a real Omani wellness ecosystem, so partner
 * names, neighbourhoods and service copy are written as a curator would write
 * them. Photography points at Unsplash until the partner CDN exists.
 */

import 'dotenv/config';
import { PrismaClient, Category, MembershipStatus, BookingStatus } from '@prisma/client';
import { Pool } from 'pg';
import { PrismaPg } from '@prisma/adapter-pg';
import bcrypt from 'bcryptjs';

const pool = new Pool({ connectionString: process.env.DATABASE_URL });
const prisma = new PrismaClient({ adapter: new PrismaPg(pool) });

const img = (id: string) =>
  `https://images.unsplash.com/photo-${id}?auto=format&fit=crop&w=1200&q=70`;

/* ------------------------------------------------------------------ Time --- */

const DAY = 86_400_000;
const at = (dayOffset: number, hour: number, minute = 0) => {
  const d = new Date();
  d.setHours(hour, minute, 0, 0);
  return new Date(d.getTime() + dayOffset * DAY);
};

/* ---------------------------------------------------------------- Cities --- */

const CITIES = [
  { slug: 'muscat', nameEn: 'Muscat', nameAr: 'مسقط', latitude: 23.588, longitude: 58.3829 },
  { slug: 'sohar', nameEn: 'Sohar', nameAr: 'صحار', latitude: 24.3417, longitude: 56.7094 },
  { slug: 'salalah', nameEn: 'Salalah', nameAr: 'صلالة', latitude: 17.0151, longitude: 54.0924 },
  { slug: 'nizwa', nameEn: 'Nizwa', nameAr: 'نزوى', latitude: 22.9333, longitude: 57.5333 },
];

/* ------------------------------------------------------------- Providers --- */

type SeedService = {
  nameEn: string;
  nameAr: string;
  descEn?: string;
  descAr?: string;
  duration?: number;
  price: number;
  includedIn?: string[];
};

type SeedProvider = {
  slug: string;
  nameEn: string;
  nameAr: string;
  category: Category;
  aboutEn: string;
  aboutAr: string;
  image: string;
  gallery: string[];
  addressEn: string;
  addressAr: string;
  latitude: number;
  longitude: number;
  rating: number;
  reviewCount: number;
  tagsEn: string[];
  tagsAr: string[];
  womenOnly?: boolean;
  hoursEn?: string;
  hoursAr?: string;
  phone?: string;
  citySlug: string;
  services: SeedService[];
};

const PROVIDERS: SeedProvider[] = [
  {
    slug: 'the-green-table',
    nameEn: 'The Green Table',
    nameAr: 'الطاولة الخضراء',
    category: 'FOOD',
    aboutEn:
      'A small kitchen in Shatti Al Qurum cooking balanced Omani and Levantine plates. Everything is made the morning it is served, and the macros are printed on the box because guessing is not a diet.',
    aboutAr:
      'مطبخ صغير في شاطئ القرم يقدّم أطباقاً عُمانية وشامية متوازنة. كل شيء يُطبخ صباح اليوم نفسه، والقيم الغذائية مطبوعة على العلبة لأن التخمين ليس نظاماً غذائياً.',
    image: img('1512621776951-a57141f2eefd'),
    gallery: [img('1540189549336-e6e99c3679fe'), img('1467003909585-2f8a72700288')],
    addressEn: 'Shatti Al Qurum, Muscat',
    addressAr: 'شاطئ القرم، مسقط',
    latitude: 23.6122,
    longitude: 58.4661,
    rating: 4.8,
    reviewCount: 214,
    tagsEn: ['Calorie-labelled', 'Local produce', 'Delivery'],
    tagsAr: ['سعرات موضّحة', 'منتجات محلية', 'توصيل'],
    hoursEn: 'Sat–Thu 8:00–22:00 · Fri 12:00–22:00',
    hoursAr: 'السبت–الخميس ٨:٠٠–٢٢:٠٠ · الجمعة ١٢:٠٠–٢٢:٠٠',
    phone: '+968 2456 1120',
    citySlug: 'muscat',
    services: [
      {
        nameEn: 'Balanced lunch box',
        nameAr: 'علبة غداء متوازنة',
        descEn: 'Grain, protein and two vegetables. Rotating weekly menu.',
        descAr: 'حبوب وبروتين وخضاران. قائمة تتغيّر أسبوعياً.',
        price: 3.5,
        includedIn: ['balance', 'complete'],
      },
      {
        nameEn: 'Five-day meal plan',
        nameAr: 'خطة وجبات خمسة أيام',
        descEn: 'Lunch and dinner, delivered daily Sunday to Thursday.',
        descAr: 'غداء وعشاء، توصيل يومي من الأحد إلى الخميس.',
        price: 32,
        includedIn: ['complete'],
      },
    ],
  },
  {
    slug: 'nakhal-kitchen',
    nameEn: 'Nakhal Kitchen',
    nameAr: 'مطبخ نخل',
    category: 'FOOD',
    aboutEn:
      'Omani home cooking, lightened. Traditional recipes rebuilt with less oil and more vegetables, without turning them into something your grandmother would not recognise.',
    aboutAr:
      'طبخ عُماني بيتي بنكهة أخف. وصفات تقليدية أُعيدت صياغتها بزيت أقل وخضار أكثر، دون أن تفقد ما تعرفه جدتك.',
    image: img('1504674900247-0877df9cc836'),
    gallery: [img('1498837167922-ddd27525d352')],
    addressEn: 'Al Khuwair, Muscat',
    addressAr: 'الخوير، مسقط',
    latitude: 23.5859,
    longitude: 58.4059,
    rating: 4.6,
    reviewCount: 132,
    tagsEn: ['Omani', 'Family portions'],
    tagsAr: ['عُماني', 'حصص عائلية'],
    hoursEn: 'Daily 11:00–23:00',
    hoursAr: 'يومياً ١١:٠٠–٢٣:٠٠',
    citySlug: 'muscat',
    services: [
      {
        nameEn: 'Light majboos plate',
        nameAr: 'طبق مجبوس خفيف',
        price: 4.2,
        includedIn: ['balance', 'complete'],
      },
      { nameEn: 'Weekly family box', nameAr: 'صندوق العائلة الأسبوعي', price: 24 },
    ],
  },
  {
    slug: 'dana-nutrition',
    nameEn: 'Dana Nutrition Clinic',
    nameAr: 'عيادة دانة للتغذية',
    category: 'NUTRITION',
    aboutEn:
      'Licensed dietitians who build a plan around the way you actually live — the family meals, the work travel, the late dinners — instead of a plan you abandon in week two.',
    aboutAr:
      'أخصائيو تغذية مرخّصون يبنون خطة تناسب حياتك كما هي — وجبات العائلة، سفر العمل، العشاء المتأخر — بدل خطة تتركها في الأسبوع الثاني.',
    image: img('1505576399279-565b52d4ac71'),
    gallery: [img('1576091160550-2173dba999ef')],
    addressEn: 'Qurum Heights, Muscat',
    addressAr: 'مرتفعات القرم، مسقط',
    latitude: 23.6081,
    longitude: 58.4737,
    rating: 4.9,
    reviewCount: 96,
    tagsEn: ['Licensed dietitians', 'Follow-up included'],
    tagsAr: ['أخصائيون مرخّصون', 'متابعة مشمولة'],
    hoursEn: 'Sun–Thu 9:00–18:00',
    hoursAr: 'الأحد–الخميس ٩:٠٠–١٨:٠٠',
    phone: '+968 2456 8890',
    citySlug: 'muscat',
    services: [
      {
        nameEn: 'First consultation',
        nameAr: 'الاستشارة الأولى',
        descEn: 'Full assessment, body composition and a written plan.',
        descAr: 'تقييم شامل وقياس تركيب الجسم وخطة مكتوبة.',
        duration: 60,
        price: 25,
        includedIn: ['balance', 'complete'],
      },
      {
        nameEn: 'Follow-up session',
        nameAr: 'جلسة متابعة',
        duration: 30,
        price: 12,
        includedIn: ['complete'],
      },
    ],
  },
  {
    slug: 'atlas-fitness',
    nameEn: 'Atlas Fitness Club',
    nameAr: 'نادي أطلس للياقة',
    category: 'GYM',
    aboutEn:
      'A serious training floor in Ghubra: full free-weight area, plate-loaded machines and coaches who are on the floor rather than behind a desk.',
    aboutAr:
      'صالة تدريب جادّة في الغبرة: منطقة أوزان حرّة كاملة وأجهزة بأقراص ومدرّبون موجودون على الأرض لا خلف مكتب.',
    image: img('1534438327276-14e5300c3a48'),
    gallery: [img('1571902943202-507ec2618e8f'), img('1517836357463-d25dfeac3438')],
    addressEn: 'Al Ghubra North, Muscat',
    addressAr: 'الغبرة الشمالية، مسقط',
    latitude: 23.5751,
    longitude: 58.3915,
    rating: 4.5,
    reviewCount: 388,
    tagsEn: ['Open late', 'Free weights', 'Coaching'],
    tagsAr: ['يفتح متأخراً', 'أوزان حرّة', 'تدريب'],
    hoursEn: 'Sat–Thu 5:30–23:30 · Fri 14:00–23:00',
    hoursAr: 'السبت–الخميس ٥:٣٠–٢٣:٣٠ · الجمعة ١٤:٠٠–٢٣:٠٠',
    phone: '+968 9123 4455',
    citySlug: 'muscat',
    services: [
      {
        nameEn: 'Day pass',
        nameAr: 'دخول ليوم',
        duration: 90,
        price: 5,
        includedIn: ['active', 'complete'],
      },
      {
        nameEn: 'Personal training session',
        nameAr: 'جلسة تدريب شخصي',
        duration: 60,
        price: 18,
        includedIn: ['complete'],
      },
    ],
  },
  {
    slug: 'harbour-strength',
    nameEn: 'Harbour Strength',
    nameAr: 'هاربر سترنث',
    category: 'GYM',
    aboutEn:
      'Small-group strength training in Al Mouj. Twelve people per session, a coach who knows your name, and a programme that progresses week over week.',
    aboutAr:
      'تدريب قوة لمجموعات صغيرة في الموج. اثنا عشر شخصاً في الجلسة، ومدرّب يعرف اسمك، وبرنامج يتدرّج أسبوعاً بعد أسبوع.',
    image: img('1540497077202-7c8a3999166f'),
    gallery: [img('1526506118085-60ce8714f8c5')],
    addressEn: 'Al Mouj, Muscat',
    addressAr: 'الموج، مسقط',
    latitude: 23.6216,
    longitude: 58.2733,
    rating: 4.7,
    reviewCount: 145,
    tagsEn: ['Small groups', 'Beginner friendly'],
    tagsAr: ['مجموعات صغيرة', 'مناسب للمبتدئين'],
    hoursEn: 'Sat–Thu 6:00–21:00',
    hoursAr: 'السبت–الخميس ٦:٠٠–٢١:٠٠',
    citySlug: 'muscat',
    services: [
      {
        nameEn: 'Group strength class',
        nameAr: 'حصة قوة جماعية',
        duration: 55,
        price: 7,
        includedIn: ['active', 'complete'],
      },
    ],
  },
  {
    slug: 'coast-run-club',
    nameEn: 'Coast Run Club',
    nameAr: 'نادي الجري الساحلي',
    category: 'FITNESS',
    aboutEn:
      'Coached outdoor runs along the Qurum corniche at sunrise, plus a Saturday hill session for anyone training toward a race.',
    aboutAr:
      'جري خارجي بإشراف مدرّب على كورنيش القرم عند الشروق، وجلسة مرتفعات كل سبت لمن يستعد لسباق.',
    image: img('1552674605-db6ffd4facb5'),
    gallery: [img('1461896836934-ffe607ba8211')],
    addressEn: 'Qurum Beach, Muscat',
    addressAr: 'شاطئ القرم، مسقط',
    latitude: 23.6178,
    longitude: 58.4741,
    rating: 4.8,
    reviewCount: 74,
    tagsEn: ['Outdoor', 'All levels', 'Sunrise'],
    tagsAr: ['في الهواء الطلق', 'لكل المستويات', 'عند الشروق'],
    hoursEn: 'Sun, Tue, Thu 5:45 · Sat 6:30',
    hoursAr: 'الأحد والثلاثاء والخميس ٥:٤٥ · السبت ٦:٣٠',
    citySlug: 'muscat',
    services: [
      {
        nameEn: 'Coached morning run',
        nameAr: 'جري صباحي بإشراف مدرّب',
        duration: 60,
        price: 4,
        includedIn: ['active', 'balance', 'complete'],
      },
    ],
  },
  {
    slug: 'reform-pilates-muscat',
    nameEn: 'Reform Pilates Muscat',
    nameAr: 'ريفورم بيلاتس مسقط',
    category: 'PILATES',
    aboutEn:
      'Eight reformers, natural light and instructors trained on the classical repertoire. Sessions cap at eight so nobody trains from the back row.',
    aboutAr:
      'ثمانية أجهزة ريفورمر وإضاءة طبيعية ومدرّبات على المنهج الكلاسيكي. الجلسة لا تتجاوز ثماني متدرّبات حتى لا تتدرّب إحداهن من الصف الأخير.',
    image: img('1518611012118-696072aa579a'),
    gallery: [img('1544367567-0f2fcb009e0b'), img('1506126613408-eca07ce68773')],
    addressEn: 'Madinat Sultan Qaboos, Muscat',
    addressAr: 'مدينة السلطان قابوس، مسقط',
    latitude: 23.5934,
    longitude: 58.4362,
    rating: 4.9,
    reviewCount: 168,
    tagsEn: ['Women only', 'Max 8 per class'],
    tagsAr: ['للنساء فقط', 'حد أقصى ٨ متدربات'],
    womenOnly: true,
    hoursEn: 'Sat–Thu 7:00–20:00',
    hoursAr: 'السبت–الخميس ٧:٠٠–٢٠:٠٠',
    phone: '+968 9922 1188',
    citySlug: 'muscat',
    services: [
      {
        nameEn: 'Reformer class',
        nameAr: 'حصة ريفورمر',
        duration: 50,
        price: 9,
        includedIn: ['balance', 'complete'],
      },
      {
        nameEn: 'Private reformer session',
        nameAr: 'جلسة ريفورمر خاصة',
        duration: 50,
        price: 22,
        includedIn: ['complete'],
      },
    ],
  },
  {
    slug: 'nour-wellness',
    nameEn: 'Nour Wellness Studio',
    nameAr: 'استوديو نور للعافية',
    category: 'WELLNESS',
    aboutEn:
      'Recovery and rest: deep-tissue therapy, guided breathwork and a quiet room that is genuinely quiet. Built for the week you did not sleep enough.',
    aboutAr:
      'تعافٍ وراحة: علاج عميق للأنسجة وتمارين تنفّس موجّهة وغرفة هادئة هدوءاً حقيقياً. مصمّمة للأسبوع الذي لم تنم فيه كفاية.',
    image: img('1540555700478-4be289fbecef'),
    gallery: [img('1544161515-4ab6ce6db874')],
    addressEn: 'Shatti Al Qurum, Muscat',
    addressAr: 'شاطئ القرم، مسقط',
    latitude: 23.6099,
    longitude: 58.4593,
    rating: 4.7,
    reviewCount: 121,
    tagsEn: ['Recovery', 'Quiet room'],
    tagsAr: ['استشفاء', 'غرفة هادئة'],
    hoursEn: 'Daily 10:00–22:00',
    hoursAr: 'يومياً ١٠:٠٠–٢٢:٠٠',
    citySlug: 'muscat',
    services: [
      {
        nameEn: 'Deep tissue therapy',
        nameAr: 'علاج عميق للأنسجة',
        duration: 60,
        price: 20,
        includedIn: ['balance', 'complete'],
      },
      {
        nameEn: 'Breathwork and reset',
        nameAr: 'جلسة تنفّس واستعادة',
        duration: 45,
        price: 12,
        includedIn: ['complete'],
      },
    ],
  },
  {
    slug: 'serene-recovery',
    nameEn: 'Serene Recovery Lounge',
    nameAr: 'صالة سيرين للاستشفاء',
    category: 'WELLNESS',
    aboutEn:
      'Contrast therapy, compression boots and infrared. Thirty minutes here after a heavy training week is the difference between progress and a plateau.',
    aboutAr:
      'علاج التباين الحراري وأحذية الضغط والأشعة تحت الحمراء. ثلاثون دقيقة هنا بعد أسبوع تدريب ثقيل هي الفرق بين التقدّم والثبات.',
    image: img('1571019614242-c5c5dee9f50b'),
    gallery: [img('1600334089648-b0d9d3028eb2')],
    addressEn: 'Al Mouj, Muscat',
    addressAr: 'الموج، مسقط',
    latitude: 23.6231,
    longitude: 58.2789,
    rating: 4.6,
    reviewCount: 58,
    tagsEn: ['Contrast therapy', 'Post-training'],
    tagsAr: ['علاج التباين', 'بعد التدريب'],
    hoursEn: 'Daily 9:00–21:00',
    hoursAr: 'يومياً ٩:٠٠–٢١:٠٠',
    citySlug: 'muscat',
    services: [
      {
        nameEn: 'Contrast therapy session',
        nameAr: 'جلسة علاج التباين',
        duration: 40,
        price: 15,
        includedIn: ['active', 'complete'],
      },
    ],
  },
  {
    slug: 'baraka-organics',
    nameEn: 'Baraka Organics',
    nameAr: 'بركة العضوية',
    category: 'PRODUCTS',
    aboutEn:
      'Omani honey, cold-pressed oils, dates without added sugar and pantry staples from producers we can name. Short shelf, honest labels.',
    aboutAr:
      'عسل عُماني وزيوت معصورة على البارد وتمور بلا سكر مضاف ومؤن من منتجين نعرفهم بالاسم. رفّ قصير وملصقات صادقة.',
    image: img('1550989460-0adf9ea622e2'),
    gallery: [img('1519996529931-28324d5a630e')],
    addressEn: 'Al Khuwair, Muscat',
    addressAr: 'الخوير، مسقط',
    latitude: 23.5891,
    longitude: 58.4123,
    rating: 4.8,
    reviewCount: 203,
    tagsEn: ['Omani producers', 'No added sugar'],
    tagsAr: ['منتجون عُمانيون', 'بلا سكر مضاف'],
    hoursEn: 'Sat–Thu 9:00–21:00',
    hoursAr: 'السبت–الخميس ٩:٠٠–٢١:٠٠',
    citySlug: 'muscat',
    services: [
      { nameEn: 'Sidr honey, 500g', nameAr: 'عسل سدر، ٥٠٠ جم', price: 18 },
      {
        nameEn: 'Cold-pressed olive oil, 750ml',
        nameAr: 'زيت زيتون معصور على البارد، ٧٥٠ مل',
        price: 9.5,
      },
      { nameEn: 'Khalas dates, 1kg', nameAr: 'تمر خلاص، ١ كجم', price: 4.8 },
    ],
  },
  {
    slug: 'salalah-strength',
    nameEn: 'Salalah Strength',
    nameAr: 'صلالة سترنث',
    category: 'GYM',
    aboutEn:
      'Dhofar’s training floor: full equipment, air-conditioned through khareef and back, and a coaching team that competes.',
    aboutAr:
      'صالة ظفار للتدريب: تجهيزات كاملة وتكييف طوال الخريف وبعده، وفريق تدريب يشارك في المنافسات.',
    image: img('1548690312-e3b507d8c110'),
    gallery: [],
    addressEn: 'Al Saada, Salalah',
    addressAr: 'السعادة، صلالة',
    latitude: 17.0194,
    longitude: 54.0897,
    rating: 4.4,
    reviewCount: 61,
    tagsEn: ['Full equipment'],
    tagsAr: ['تجهيزات كاملة'],
    hoursEn: 'Sat–Thu 6:00–23:00',
    hoursAr: 'السبت–الخميس ٦:٠٠–٢٣:٠٠',
    citySlug: 'salalah',
    services: [
      {
        nameEn: 'Day pass',
        nameAr: 'دخول ليوم',
        duration: 90,
        price: 4,
        includedIn: ['active', 'complete'],
      },
    ],
  },
  {
    slug: 'sohar-yoga-house',
    nameEn: 'Sohar Yoga House',
    nameAr: 'بيت صحار لليوغا',
    category: 'FITNESS',
    aboutEn:
      'Mat classes for every level in a converted courtyard house. Evening sessions are candlelit and deliberately slow.',
    aboutAr:
      'حصص يوغا لكل المستويات في بيت بفناء أُعيد ترميمه. جلسات المساء على ضوء الشموع وبإيقاع بطيء مقصود.',
    image: img('1506126613408-eca07ce68773'),
    gallery: [],
    addressEn: 'Al Hambar, Sohar',
    addressAr: 'الحمبار، صحار',
    latitude: 24.3521,
    longitude: 56.7288,
    rating: 4.7,
    reviewCount: 42,
    tagsEn: ['All levels', 'Evening classes'],
    tagsAr: ['لكل المستويات', 'حصص مسائية'],
    hoursEn: 'Sat–Thu 7:00–20:00',
    hoursAr: 'السبت–الخميس ٧:٠٠–٢٠:٠٠',
    citySlug: 'sohar',
    services: [
      {
        nameEn: 'Mat class',
        nameAr: 'حصة يوغا',
        duration: 60,
        price: 5,
        includedIn: ['balance', 'complete'],
      },
    ],
  },
];

/* -------------------------------------------------------------- Packages --- */

const PACKAGES = [
  {
    slug: 'active',
    nameEn: 'Active',
    nameAr: 'نشِط',
    bestForEn: 'For people who train and want the food to keep up',
    bestForAr: 'لمن يتدرّب ويريد للغذاء أن يواكبه',
    descEn: 'Training-led. Eight gym or class sessions a month, plus recovery when you need it.',
    descAr: 'يقوده التدريب. ثماني جلسات نادٍ أو حصص شهرياً، مع استشفاء عند الحاجة.',
    price: 39,
    periodDays: 30,
    benefitsEn: [
      '8 gym or class sessions a month',
      '4 outdoor fitness sessions',
      '2 recovery sessions',
      'Priority booking at partner studios',
      'Pause once per period',
    ],
    benefitsAr: [
      '٨ جلسات نادٍ أو حصص شهرياً',
      '٤ جلسات لياقة في الهواء الطلق',
      'جلستا استشفاء',
      'أولوية في الحجز لدى الشركاء',
      'إيقاف مؤقت مرة كل فترة',
    ],
    featured: false,
    sortOrder: 1,
    allowances: [
      { category: 'GYM' as Category, quantity: 8 },
      { category: 'FITNESS' as Category, quantity: 4 },
      { category: 'WELLNESS' as Category, quantity: 2 },
    ],
  },
  {
    slug: 'balance',
    nameEn: 'Balance',
    nameAr: 'توازن',
    bestForEn: 'For people building healthier habits, one week at a time',
    bestForAr: 'لمن يبني عادات أفضل، أسبوعاً بعد أسبوع',
    descEn: 'Food, movement and rest in the proportions most people actually need.',
    descAr: 'غذاء وحركة وراحة، بالنِّسب التي يحتاجها معظم الناس فعلاً.',
    price: 55,
    periodDays: 30,
    benefitsEn: [
      '12 meals from partner kitchens',
      '4 fitness sessions and 2 pilates classes',
      '1 nutrition consultation',
      '2 wellness visits',
      'Pause once per period',
    ],
    benefitsAr: [
      '١٢ وجبة من مطابخ الشركاء',
      '٤ جلسات لياقة وحصتا بيلاتس',
      'استشارة تغذية واحدة',
      'زيارتا عافية',
      'إيقاف مؤقت مرة كل فترة',
    ],
    featured: true,
    sortOrder: 2,
    allowances: [
      { category: 'FOOD' as Category, quantity: 12 },
      { category: 'FITNESS' as Category, quantity: 4 },
      { category: 'PILATES' as Category, quantity: 2 },
      { category: 'NUTRITION' as Category, quantity: 1 },
      { category: 'WELLNESS' as Category, quantity: 2 },
    ],
  },
  {
    slug: 'complete',
    nameEn: 'Complete',
    nameAr: 'متكامل',
    bestForEn: 'For people who want the whole ecosystem, without counting',
    bestForAr: 'لمن يريد المنظومة كاملة، دون حساب',
    descEn: 'Everything NAMAT offers, with the highest monthly allowance in every category.',
    descAr: 'كل ما تقدّمه نمط، بأعلى حصة شهرية في كل فئة.',
    price: 89,
    periodDays: 30,
    benefitsEn: [
      '20 meals from partner kitchens',
      '12 gym sessions a month',
      '8 fitness and pilates classes',
      '2 nutrition consultations with follow-up',
      '4 wellness and recovery visits',
      'Priority booking everywhere',
    ],
    benefitsAr: [
      '٢٠ وجبة من مطابخ الشركاء',
      '١٢ جلسة نادٍ شهرياً',
      '٨ حصص لياقة وبيلاتس',
      'استشارتا تغذية مع متابعة',
      '٤ زيارات عافية واستشفاء',
      'أولوية في الحجز في كل مكان',
    ],
    featured: false,
    sortOrder: 3,
    allowances: [
      { category: 'FOOD' as Category, quantity: 20 },
      { category: 'GYM' as Category, quantity: 12 },
      { category: 'FITNESS' as Category, quantity: 4 },
      { category: 'PILATES' as Category, quantity: 4 },
      { category: 'NUTRITION' as Category, quantity: 2 },
      { category: 'WELLNESS' as Category, quantity: 4 },
    ],
  },
];

/* ------------------------------------------------------------- Marketing --- */

const PARTNERS: { nameEn: string; nameAr: string; category: Category }[] = [
  { nameEn: 'The Green Table', nameAr: 'الطاولة الخضراء', category: 'FOOD' },
  { nameEn: 'Nakhal Kitchen', nameAr: 'مطبخ نخل', category: 'FOOD' },
  { nameEn: 'Dana Nutrition Clinic', nameAr: 'عيادة دانة للتغذية', category: 'NUTRITION' },
  { nameEn: 'Atlas Fitness Club', nameAr: 'نادي أطلس للياقة', category: 'GYM' },
  { nameEn: 'Harbour Strength', nameAr: 'هاربر سترنث', category: 'GYM' },
  { nameEn: 'Coast Run Club', nameAr: 'نادي الجري الساحلي', category: 'FITNESS' },
  { nameEn: 'Reform Pilates Muscat', nameAr: 'ريفورم بيلاتس مسقط', category: 'PILATES' },
  { nameEn: 'Nour Wellness Studio', nameAr: 'استوديو نور للعافية', category: 'WELLNESS' },
  { nameEn: 'Serene Recovery Lounge', nameAr: 'صالة سيرين للاستشفاء', category: 'WELLNESS' },
  { nameEn: 'Baraka Organics', nameAr: 'بركة العضوية', category: 'PRODUCTS' },
];

/* ------------------------------------------------------------------ Seed --- */

async function main() {
  console.log('Resetting…');
  // Children before parents — no cascade assumptions.
  await prisma.usage.deleteMany();
  await prisma.membership.deleteMany();
  await prisma.allowance.deleteMany();
  await prisma.package.deleteMany();
  await prisma.booking.deleteMany();
  await prisma.slot.deleteMany();
  await prisma.service.deleteMany();
  await prisma.review.deleteMany();
  await prisma.favorite.deleteMany();
  await prisma.notification.deleteMany();
  await prisma.provider.deleteMany();
  await prisma.profile.deleteMany();
  await prisma.session.deleteMany();
  await prisma.account.deleteMany();
  await prisma.user.deleteMany();
  await prisma.city.deleteMany();
  await prisma.country.deleteMany();
  await prisma.partner.deleteMany();

  console.log('Geography…');
  const oman = await prisma.country.create({
    data: { code: 'OM', nameEn: 'Oman', nameAr: 'عُمان', currency: 'OMR', isLive: true },
  });
  // Seeded but not live — the GCC rollout is a data change, not a code change.
  await prisma.country.createMany({
    data: [
      { code: 'AE', nameEn: 'United Arab Emirates', nameAr: 'الإمارات', currency: 'AED' },
      { code: 'SA', nameEn: 'Saudi Arabia', nameAr: 'السعودية', currency: 'SAR' },
    ],
  });

  const cities = await Promise.all(
    CITIES.map((c) => prisma.city.create({ data: { ...c, countryId: oman.id } })),
  );
  const cityBySlug = Object.fromEntries(cities.map((c) => [c.slug, c]));

  console.log('Packages…');
  for (const { allowances, ...pkg } of PACKAGES) {
    await prisma.package.create({ data: { ...pkg, allowances: { create: allowances } } });
  }

  console.log('Providers and services…');
  for (const { services, citySlug, womenOnly, ...p } of PROVIDERS) {
    const provider = await prisma.provider.create({
      data: { ...p, womenOnly: womenOnly ?? false, cityId: cityBySlug[citySlug].id },
    });

    for (const s of services) {
      const service = await prisma.service.create({
        data: {
          ...s,
          duration: s.duration ?? null,
          includedIn: s.includedIn ?? [],
          providerId: provider.id,
          category: p.category,
        },
      });

      // Products are not booked against a calendar.
      if (p.category === 'PRODUCTS') continue;

      // Fourteen days of availability, three slots a day.
      const slots: { serviceId: string; startsAt: Date; capacity: number; booked: number }[] = [];
      for (let day = 0; day < 14; day++) {
        for (const [hour, minute] of [
          [7, 0],
          [12, 30],
          [18, 0],
        ] as const) {
          const startsAt = at(day, hour, minute);
          if (startsAt.getTime() < Date.now()) continue;
          const capacity = p.category === 'NUTRITION' ? 1 : 8;
          slots.push({
            serviceId: service.id,
            startsAt,
            capacity,
            // A partly-booked calendar reads as a real business; every fifth is full.
            booked: (day + hour) % 5 === 0 ? capacity : (day + hour) % 3,
          });
        }
      }
      await prisma.slot.createMany({ data: slots });
    }
  }

  console.log('Partner wall…');
  await prisma.partner.createMany({ data: PARTNERS });

  console.log('Demo accounts…');
  const member = await prisma.user.create({
    data: {
      name: 'سارة',
      email: 'sara@namat.om',
      phone: '+96891234567',
      password: await bcrypt.hash('namat1234', 10),
      locale: 'ar',
      profile: {
        create: {
          goals: ['eat_better', 'more_active', 'wellbeing'],
          interests: ['FOOD', 'PILATES', 'WELLNESS'],
          activityLevel: 'MODERATE',
          timePreference: 'MORNING',
          dietary: ['gluten_free'],
          cityId: cityBySlug.muscat.id,
          onboardedAt: new Date(),
        },
      },
    },
  });

  // A second account that never bought a package — the non-member Journey
  // state needs a real user to render against.
  await prisma.user.create({
    data: {
      name: 'خالد',
      email: 'khalid@namat.om',
      phone: '+96899887766',
      password: await bcrypt.hash('namat1234', 10),
      locale: 'ar',
      profile: {
        create: {
          goals: ['more_active'],
          interests: ['GYM', 'FITNESS'],
          activityLevel: 'ACTIVE',
          timePreference: 'EVENING',
          cityId: cityBySlug.muscat.id,
          onboardedAt: new Date(),
        },
      },
    },
  });

  console.log('Membership…');
  const balance = await prisma.package.findUniqueOrThrow({
    where: { slug: 'balance' },
    include: { allowances: true },
  });

  const membership = await prisma.membership.create({
    data: {
      userId: member.id,
      packageId: balance.id,
      status: MembershipStatus.ACTIVE,
      startedAt: new Date(Date.now() - 11 * DAY),
      endsAt: new Date(Date.now() + 19 * DAY),
      renewsAt: new Date(Date.now() + 19 * DAY),
    },
  });

  // Mid-period usage, so the meters mean something on first load.
  const USED: Partial<Record<Category, number>> = {
    FOOD: 5,
    FITNESS: 2,
    PILATES: 1,
    NUTRITION: 1,
    WELLNESS: 0,
  };
  await prisma.usage.createMany({
    data: balance.allowances.map((a) => ({
      membershipId: membership.id,
      category: a.category,
      used: USED[a.category] ?? 0,
    })),
  });

  console.log('Bookings…');
  const pilates = await prisma.service.findFirstOrThrow({
    where: { provider: { slug: 'reform-pilates-muscat' }, nameEn: 'Reformer class' },
  });
  const nutrition = await prisma.service.findFirstOrThrow({
    where: { provider: { slug: 'dana-nutrition' }, nameEn: 'First consultation' },
  });
  const wellness = await prisma.service.findFirstOrThrow({
    where: { provider: { slug: 'nour-wellness' }, nameEn: 'Deep tissue therapy' },
  });

  const ref = (n: number) => `NMT-${100000 + n}`;

  await prisma.booking.createMany({
    data: [
      {
        reference: ref(1),
        userId: member.id,
        serviceId: pilates.id,
        providerId: pilates.providerId,
        startsAt: at(0, 18, 0),
        status: BookingStatus.CONFIRMED,
        price: 0,
        coveredByMembership: true,
      },
      {
        reference: ref(2),
        userId: member.id,
        serviceId: nutrition.id,
        providerId: nutrition.providerId,
        startsAt: at(3, 12, 30),
        status: BookingStatus.CONFIRMED,
        price: 0,
        coveredByMembership: true,
      },
      {
        reference: ref(3),
        userId: member.id,
        serviceId: wellness.id,
        providerId: wellness.providerId,
        startsAt: at(-6, 18, 0),
        status: BookingStatus.COMPLETED,
        price: 20,
        paymentMethod: 'card',
      },
      {
        reference: ref(4),
        userId: member.id,
        serviceId: pilates.id,
        providerId: pilates.providerId,
        startsAt: at(-2, 7, 0),
        status: BookingStatus.CANCELLED,
        price: 0,
        coveredByMembership: true,
        cancelledAt: new Date(Date.now() - 3 * DAY),
      },
    ],
  });

  console.log('Reviews and favourites…');
  const reformer = await prisma.provider.findUniqueOrThrow({
    where: { slug: 'reform-pilates-muscat' },
  });
  const greenTable = await prisma.provider.findUniqueOrThrow({
    where: { slug: 'the-green-table' },
  });

  await prisma.review.create({
    data: {
      userId: member.id,
      providerId: reformer.id,
      rating: 5,
      bodyEn: 'Small classes and the instructor actually corrects your form.',
      bodyAr: 'الحصص صغيرة والمدرّبة تصحّح وضعيتك فعلاً.',
    },
  });
  await prisma.favorite.createMany({
    data: [
      { userId: member.id, providerId: reformer.id },
      { userId: member.id, providerId: greenTable.id },
    ],
  });

  console.log('Notifications…');
  await prisma.notification.createMany({
    data: [
      {
        userId: member.id,
        kind: 'BOOKING',
        titleEn: 'Reformer class today at 6:00 PM',
        titleAr: 'حصة ريفورمر اليوم ٦:٠٠ مساءً',
        bodyEn: 'Reform Pilates Muscat, Madinat Sultan Qaboos.',
        bodyAr: 'ريفورم بيلاتس مسقط، مدينة السلطان قابوس.',
        href: '/app/bookings',
      },
      {
        userId: member.id,
        kind: 'PACKAGE',
        titleEn: '7 meals left this period',
        titleAr: 'بقيت ٧ وجبات هذه الفترة',
        bodyEn: 'Your Balance package renews in 19 days.',
        bodyAr: 'باقة توازن تتجدّد بعد ١٩ يوماً.',
        href: '/app/journey/package',
        readAt: new Date(Date.now() - 2 * DAY),
      },
      {
        userId: member.id,
        kind: 'RECOMMENDATION',
        titleEn: 'A sunrise run near you',
        titleAr: 'جري عند الشروق قريب منك',
        bodyEn: 'Coast Run Club meets Sunday at 5:45 on the Qurum corniche.',
        bodyAr: 'نادي الجري الساحلي يلتقي الأحد ٥:٤٥ على كورنيش القرم.',
        href: '/app/explore/coast-run-club',
      },
    ],
  });

  console.log('Done.', {
    cities: await prisma.city.count(),
    providers: await prisma.provider.count(),
    services: await prisma.service.count(),
    slots: await prisma.slot.count(),
    packages: await prisma.package.count(),
    bookings: await prisma.booking.count(),
  });
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
    await pool.end();
  });
