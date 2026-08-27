/// The catalogue: partners and the things they sell.
///
/// PROVENANCE — this matters, and it is not uniform across the file.
///
/// The meals and stores partners are real Muscat businesses, carried over from
/// the removed backend along with their areas and their capabilities, which
/// were recorded as null wherever the research never established them. That is
/// why several still carry `rating: null` rather than a zero.
///
/// Their PRICES, DISHES AND STOCK ARE NOT THEIRS. They are plausible stand-ins
/// written here so the flow can be built and shown, and every one of them must
/// be replaced with the partner's own menu before launch. Nothing in this file
/// should be quoted to anyone as what a business charges.
///
/// The fitness and consult partners are NAMAT's own first-party services.
/// There is no researched catalogue for either field, and naming a studio or a
/// nutritionist who practises in Muscat would be a claim about a real business
/// or a real person. Because NAMAT operates these, they are the only entries
/// that carry opening hours, timetables, places remaining and a cancellation
/// policy — a third party has not told us any of those, and inventing them
/// would be making promises on their behalf.
///
/// Everything a member can buy lives here rather than in the widgets that
/// display it, so the selection flow, the cart, checkout and the ratings
/// screen all read one list and cannot drift apart.
library;

import '../../../core/domain/city.dart';
import '../../use/domain/field.dart';
import 'service_detail.dart';

export 'service_detail.dart';

/// What kind of thing is being bought.
///
/// The distinction is not bookkeeping: it decides whether the checkout screen
/// asks for a delivery address, a time slot, or neither.
enum OfferingKind {
  /// A single made-to-order item. Delivered or collected.
  dish,

  /// A recurring meal plan. Runs over a period, so it has no single moment.
  plan,

  /// A class or training session at a fixed time.
  session,

  /// A block of sessions bought up front, redeemed later.
  pass,

  /// A person's time, in a room or over a call.
  consultation,

  /// A physical thing off a shelf.
  product,
}

extension OfferingKindRules on OfferingKind {
  /// Does buying this need a time chosen at checkout?
  ///
  /// A pass does not: the member picks each session's time later, when they
  /// know their week. Asking at purchase would be asking for a guess.
  bool get needsSlot =>
      this == OfferingKind.session || this == OfferingKind.consultation;

  /// Does this need to physically reach the member?
  bool get needsFulfilment =>
      this == OfferingKind.dish ||
      this == OfferingKind.product ||
      this == OfferingKind.plan;
}

/// Per-serving nutrition.
///
/// Present only where the partner published it. A meal without these shows
/// nothing rather than zeroes — a zero-calorie dish is a false claim, and the
/// members who filter on protein are exactly the ones who would be misled.
class Nutrition {
  const Nutrition({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  /// kcal.
  final int calories;

  /// Grams.
  final int protein;
  final int carbs;
  final int fat;
}

/// One buyable thing.
class Offering {
  const Offering({
    required this.id,
    required this.kind,
    required this.name,
    required this.nameEn,
    required this.price,
    this.note,
    this.noteEn,
    this.minutes,
    this.nutrition,
    this.coveredByPackage = false,
    this.includes = const [],
    this.includesEn = const [],
    this.availability,
    this.format,
    this.level,
    this.cancellation,
    this.inStock,
  });

  final String id;
  final OfferingKind kind;

  /// Both names are carried rather than translated at display time. A partner
  /// names their own dish, and "Macro Boost Box" is not a string we get to
  /// invent an Arabic version of — where a partner gave only one name, both
  /// fields hold it and the app shows that name in either language.
  final String name;
  final String nameEn;

  /// In OMR.
  final double price;

  final String? note;
  final String? noteEn;

  /// Duration, for anything that occupies time.
  final int? minutes;

  final Nutrition? nutrition;

  /// Whether a package allowance can absorb this.
  final bool coveredByPackage;

  /// What the price actually buys.
  ///
  /// The single most useful thing on a page selling a 55-rial pass: without
  /// it, the member is comparing a number against another number and has no
  /// way to tell which is worth more.
  final List<String> includes;
  final List<String> includesEn;

  /// When it runs and how many places are left. Null where nobody counts.
  final Availability? availability;

  final ServiceFormat? format;
  final FitnessLevel? level;
  final CancellationPolicy? cancellation;

  /// Null means stock is not tracked for this item — a shop we have no live
  /// feed from. False means genuinely out of stock.
  final bool? inStock;

  String localisedName(bool arabic) => arabic ? name : nameEn;
  String? localisedNote(bool arabic) => arabic ? note : noteEn;
  List<String> localisedIncludes(bool arabic) => arabic ? includes : includesEn;

  /// Can this be added to a cart right now?
  ///
  /// Two different reasons it might not be, and the screens say which: a class
  /// with no places left, and a product the shop has run out of.
  bool get isSoldOut => availability?.isFull ?? false;
  bool get isOutOfStock => inStock == false;
  bool get canBuy => !isSoldOut && !isOutOfStock;
}

/// A business, or a NAMAT first-party service.
class Partner {
  const Partner({
    required this.slug,
    required this.name,
    required this.nameEn,
    required this.area,
    required this.areaEn,
    required this.field,
    required this.city,
    required this.distanceKm,
    required this.offerings,
    this.rating,
    this.reviewCount,
    this.inPackage = false,
    this.tags = const [],
    this.tagsEn = const [],
    this.firstParty = false,
    this.about,
    this.aboutEn,
    this.hours,
    this.phone,
  });

  final String slug;
  final String name;
  final String nameEn;
  final String area;
  final String areaEn;
  final NamatField field;

  /// Which market this partner is in.
  ///
  /// The researched catalogue is Muscat and the launch market is Sohar, so
  /// this is what lets a member in Sohar be told plainly that a field has no
  /// partners near them yet — rather than shown an empty list that reads as a
  /// broken app, or a Muscat kitchen forty minutes' drive away with no
  /// indication of it.
  final NamatCity city;

  final double distanceKm;
  final List<Offering> offerings;

  /// Null where no rating was ever established. Distinct from zero, which
  /// would mean a business rated badly.
  final double? rating;
  final int? reviewCount;

  final bool inPackage;
  final List<String> tags;
  final List<String> tagsEn;

  /// Operated by NAMAT rather than by a third party.
  final bool firstParty;

  /// Null for every third party. A description is a business's own words about
  /// itself, and writing one for them puts claims in their mouth.
  final String? about;
  final String? aboutEn;

  /// Null for every third party. A wrong closing time sends someone to a
  /// locked door, which is worse than showing nothing.
  final OpeningHours? hours;

  /// E.164. Null for every third party, for the same reason.
  final String? phone;

  String localisedName(bool arabic) => arabic ? name : nameEn;
  String localisedArea(bool arabic) => arabic ? area : areaEn;
  String? localisedAbout(bool arabic) => arabic ? about : aboutEn;
  List<String> localisedTags(bool arabic) => arabic ? tags : tagsEn;

  /// The cheapest thing on the list, for the "from …" line.
  double? get fromPrice => offerings.isEmpty
      ? null
      : offerings.map((o) => o.price).reduce((a, b) => a < b ? a : b);

  /// Whether anything here can be bought at all right now.
  bool get hasAnythingAvailable => offerings.any((o) => o.canBuy);
}

// Opening times, in minutes from midnight, so the data below reads as clock
// time rather than as three-digit numbers nobody can check at a glance.
const _sixAm = 6 * 60;
const _eightAm = 8 * 60;
const _nineAm = 9 * 60;
const _fivePm = 17 * 60;
const _ninePm = 21 * 60;
const _tenPm = 22 * 60;

abstract final class Catalogue {
  static const List<Partner> all = [
    // ---------------------------------------------------------------- meals
    Partner(
      slug: 'healthy-lab',
      city: NamatCity.muscat,
      name: 'مطعم المعمل الصحي',
      nameEn: 'The Healthy Lab',
      area: 'الغبرة الشمالية',
      areaEn: 'North Ghubrah',
      field: NamatField.meals,
      distanceKm: 0.3,
      inPackage: true,
      tags: ['عالي البروتين', 'اشتراكات', 'وجبات صحية'],
      tagsEn: ['High protein', 'Subscriptions', 'Healthy meals'],
      offerings: [
        Offering(
          id: 'hl-grilled-quinoa',
          kind: OfferingKind.dish,
          name: 'دجاج مشوي مع الكينوا',
          nameEn: 'Grilled chicken with quinoa',
          note: 'صدر دجاج مشوي، كينوا، خضار موسمية',
          noteEn: 'Grilled chicken breast, quinoa, seasonal vegetables',
          price: 3.200,
          coveredByPackage: true,
          nutrition: Nutrition(calories: 520, protein: 42, carbs: 48, fat: 16),
        ),
        Offering(
          id: 'hl-tuna-salad',
          kind: OfferingKind.dish,
          name: 'سلطة تونا عالية البروتين',
          nameEn: 'High-protein tuna salad',
          price: 2.500,
          coveredByPackage: true,
          nutrition: Nutrition(calories: 380, protein: 34, carbs: 18, fat: 19),
        ),
        Offering(
          id: 'hl-salmon',
          kind: OfferingKind.dish,
          name: 'سلمون مشوي مع البطاطا الحلوة',
          nameEn: 'Grilled salmon with sweet potato',
          price: 4.500,
          coveredByPackage: true,
          nutrition: Nutrition(calories: 610, protein: 39, carbs: 44, fat: 27),
        ),
        Offering(
          id: 'hl-week',
          kind: OfferingKind.plan,
          name: 'اشتراك أسبوعي — ١٢ وجبة',
          nameEn: 'Weekly plan — 12 meals',
          note: 'غداء وعشاء، ستة أيام، يُوصَّل يومياً',
          noteEn: 'Lunch and dinner, six days, delivered daily',
          price: 32.000,
          includes: [
            'اثنتا عشرة وجبة على مدى ستة أيام',
            'توصيل يومي إلى بابك',
            'تبديل أي وجبة قبل يوم من موعدها',
          ],
          includesEn: [
            'Twelve meals across six days',
            'Delivered to your door daily',
            'Swap any meal up to a day ahead',
          ],
        ),
        Offering(
          id: 'hl-month',
          kind: OfferingKind.plan,
          name: 'اشتراك شهري — ٤٨ وجبة',
          nameEn: 'Monthly plan — 48 meals',
          price: 118.000,
          includes: [
            'ثمان وأربعون وجبة على مدى أربعة أسابيع',
            'توصيل يومي إلى بابك',
            'مراجعة واحدة مع أخصائي نمط للتغذية',
          ],
          includesEn: [
            'Forty-eight meals across four weeks',
            'Delivered to your door daily',
            'One review with a NAMAT nutrition specialist',
          ],
        ),
      ],
    ),
    Partner(
      slug: 'nourish-kitchen',
      city: NamatCity.muscat,
      name: 'Nourish Kitchen',
      nameEn: 'Nourish Kitchen',
      area: 'شارع العلم',
      areaEn: 'Al Alam Street',
      field: NamatField.meals,
      distanceKm: 4.5,
      inPackage: true,
      tags: ['اشتراكات', 'وجبات صحية'],
      tagsEn: ['Subscriptions', 'Healthy meals'],
      offerings: [
        Offering(
          id: 'nk-breakfast',
          kind: OfferingKind.dish,
          name: 'بوكس الفطور المتوازن',
          nameEn: 'Balanced breakfast box',
          price: 2.800,
          coveredByPackage: true,
          nutrition: Nutrition(calories: 410, protein: 22, carbs: 44, fat: 15),
        ),
        Offering(
          id: 'nk-bowl',
          kind: OfferingKind.dish,
          name: 'بول خضار وحمص',
          nameEn: 'Vegetable and chickpea bowl',
          price: 2.600,
          coveredByPackage: true,
          nutrition: Nutrition(calories: 450, protein: 18, carbs: 62, fat: 13),
        ),
        Offering(
          id: 'nk-week',
          kind: OfferingKind.plan,
          name: 'خطة وجبات أسبوعية',
          nameEn: 'Weekly meal plan',
          price: 38.500,
          includes: [
            'خمس عشرة وجبة، خمسة أيام',
            'اختيار نباتي كامل أو مختلط',
            'إيقاف مؤقت لأسبوع دون رسوم',
          ],
          includesEn: [
            'Fifteen meals across five days',
            'Fully plant-based or mixed',
            'Pause for a week at no charge',
          ],
        ),
      ],
    ),
    Partner(
      slug: 'hilda-keto',
      city: NamatCity.muscat,
      name: 'مطبخ هيلدا كيتو',
      nameEn: 'Hilda Keto Kitchen',
      area: 'الخوير',
      areaEn: 'Al Khuwair',
      field: NamatField.meals,
      distanceKm: 4.7,
      tags: ['كيتو', 'قليل الكربوهيدرات'],
      tagsEn: ['Keto', 'Low carb'],
      offerings: [
        Offering(
          id: 'hk-beef',
          kind: OfferingKind.dish,
          name: 'صحن لحم كيتو بالخضار',
          nameEn: 'Keto beef and vegetables',
          price: 3.900,
          nutrition: Nutrition(calories: 610, protein: 38, carbs: 9, fat: 46),
        ),
        Offering(
          id: 'hk-breakfast',
          kind: OfferingKind.dish,
          name: 'فطور كيتو بالبيض والأفوكادو',
          nameEn: 'Keto breakfast with egg and avocado',
          price: 2.900,
          nutrition: Nutrition(calories: 480, protein: 21, carbs: 7, fat: 41),
        ),
        Offering(
          id: 'hk-cheesecake',
          kind: OfferingKind.dish,
          name: 'تشيز كيك كيتو',
          nameEn: 'Keto cheesecake',
          price: 1.800,
          nutrition: Nutrition(calories: 290, protein: 7, carbs: 6, fat: 27),
        ),
      ],
    ),
    Partner(
      slug: 'macro-boost',
      city: NamatCity.muscat,
      name: 'Macro Boost',
      nameEn: 'Macro Boost',
      area: 'الخوير',
      areaEn: 'Al Khuwair',
      field: NamatField.meals,
      distanceKm: 5.0,
      tags: ['عالي البروتين', 'اشتراكات'],
      tagsEn: ['High protein', 'Subscriptions'],
      offerings: [
        Offering(
          id: 'mb-box',
          kind: OfferingKind.dish,
          name: 'بوكس ماكرو — ٤٠غ بروتين',
          nameEn: 'Macro box — 40g protein',
          price: 3.500,
          nutrition: Nutrition(calories: 560, protein: 40, carbs: 52, fat: 18),
        ),
        Offering(
          id: 'mb-box-60',
          kind: OfferingKind.dish,
          name: 'بوكس ماكرو — ٦٠غ بروتين',
          nameEn: 'Macro box — 60g protein',
          price: 4.300,
          nutrition: Nutrition(calories: 720, protein: 60, carbs: 58, fat: 22),
        ),
        Offering(
          id: 'mb-shake',
          kind: OfferingKind.dish,
          name: 'شيك بروتين بعد التمرين',
          nameEn: 'Post-workout protein shake',
          price: 1.500,
          nutrition: Nutrition(calories: 240, protein: 30, carbs: 20, fat: 4),
        ),
      ],
    ),

    // -------------------------------------------------------------- fitness
    Partner(
      slug: 'namat-strength',
      city: NamatCity.sohar,
      name: 'نمط · تمرين القوة',
      nameEn: 'NAMAT · Strength',
      area: 'الحمبار',
      areaEn: 'Al Hambar',
      field: NamatField.fitness,
      distanceKm: 2.1,
      inPackage: true,
      firstParty: true,
      tags: ['أوزان حرة', 'مدرب شخصي'],
      tagsEn: ['Free weights', 'Personal training'],
      about: 'صالة أوزان حرة يديرها نمط، بمدربين معتمدين وحصص جماعية '
          'صغيرة لا تتجاوز اثني عشر شخصاً.',
      aboutEn: 'A NAMAT-run free-weights gym with certified coaches and small '
          'group classes capped at twelve.',
      hours: OpeningHours(opensAt: _sixAm, closesAt: _tenPm),
      phone: '+96824000101',
      offerings: [
        Offering(
          id: 'ns-day',
          kind: OfferingKind.session,
          name: 'حصة يوم واحد',
          nameEn: 'Single day pass',
          price: 4.000,
          minutes: 90,
          coveredByPackage: true,
          format: ServiceFormat.inPerson,
          level: FitnessLevel.any,
          cancellation: CancellationPolicy.free2h,
          includes: [
            'دخول كامل لليوم',
            'خزانة ومنشفة',
            'جولة تعريفية للمرة الأولى',
          ],
          includesEn: [
            'Full-day access',
            'Locker and towel',
            'An intro walkthrough on your first visit',
          ],
          availability: Availability(
            spotsLeft: 14,
            capacity: 40,
            times: [
              SessionTime(DateTime.sunday, 6),
              SessionTime(DateTime.tuesday, 6),
              SessionTime(DateTime.thursday, 6),
              SessionTime(DateTime.sunday, 18),
              SessionTime(DateTime.tuesday, 18),
            ],
          ),
        ),
        Offering(
          id: 'ns-lift',
          kind: OfferingKind.session,
          name: 'حصة رفع أثقال جماعية',
          nameEn: 'Group lifting class',
          note: 'مجموعة صغيرة، الحد اثنا عشر شخصاً',
          noteEn: 'Small group, capped at twelve',
          price: 6.500,
          minutes: 60,
          coveredByPackage: true,
          format: ServiceFormat.inPerson,
          level: FitnessLevel.intermediate,
          cancellation: CancellationPolicy.free24h,
          includes: [
            'تصحيح الأداء طوال الحصة',
            'خطة تدرج للأسابيع الأربعة القادمة',
          ],
          includesEn: [
            'Form correction throughout',
            'A four-week progression plan',
          ],
          availability: Availability(
            spotsLeft: 2,
            capacity: 12,
            times: [
              SessionTime(DateTime.monday, 19),
              SessionTime(DateTime.wednesday, 19),
            ],
          ),
        ),
        Offering(
          id: 'ns-pt',
          kind: OfferingKind.session,
          name: 'جلسة مع مدرب شخصي',
          nameEn: 'Personal training session',
          price: 12.000,
          minutes: 60,
          format: ServiceFormat.inPerson,
          level: FitnessLevel.any,
          cancellation: CancellationPolicy.free24h,
          includes: [
            'تقييم حركة قبل البدء',
            'برنامج مكتوب تأخذه معك',
          ],
          includesEn: [
            'A movement assessment first',
            'A written programme to take away',
          ],
          availability: Availability(
            spotsLeft: 5,
            times: [
              SessionTime(DateTime.saturday, 8),
              SessionTime(DateTime.monday, 8),
              SessionTime(DateTime.wednesday, 17),
            ],
          ),
        ),
        Offering(
          id: 'ns-month',
          kind: OfferingKind.pass,
          name: 'اشتراك شهري',
          nameEn: 'Monthly membership',
          note: 'دخول غير محدود، ويشمل الحصص الجماعية',
          noteEn: 'Unlimited access, group classes included',
          price: 35.000,
          format: ServiceFormat.inPerson,
          cancellation: CancellationPolicy.nonRefundable,
          includes: [
            'دخول غير محدود طوال الشهر',
            'كل الحصص الجماعية',
            'تقييم تكوين جسم واحد',
          ],
          includesEn: [
            'Unlimited access for the month',
            'Every group class',
            'One body-composition assessment',
          ],
        ),
      ],
    ),
    Partner(
      slug: 'namat-reformer',
      city: NamatCity.sohar,
      name: 'نمط · بيلاتس',
      nameEn: 'NAMAT · Pilates',
      area: 'الطريف',
      areaEn: 'At Tarif',
      field: NamatField.fitness,
      distanceKm: 3.4,
      firstParty: true,
      tags: ['ريفورمر', 'حصص جماعية'],
      tagsEn: ['Reformer', 'Group classes'],
      about: 'استوديو ريفورمر من ثمانية أجهزة، بحصص للمبتدئين وأخرى متقدمة.',
      aboutEn: 'An eight-machine reformer studio, with beginner and advanced '
          'classes.',
      hours: OpeningHours(opensAt: _eightAm, closesAt: _ninePm, closedOn: [
        DateTime.friday,
      ]),
      phone: '+96824000102',
      offerings: [
        Offering(
          id: 'nr-class',
          kind: OfferingKind.session,
          name: 'حصة ريفورمر جماعية',
          nameEn: 'Group reformer class',
          price: 8.000,
          minutes: 50,
          format: ServiceFormat.inPerson,
          level: FitnessLevel.beginner,
          cancellation: CancellationPolicy.free24h,
          includes: ['جهاز ريفورمر مخصص', 'جوارب مانعة للانزلاق'],
          includesEn: ['Your own reformer', 'Grip socks'],
          availability: Availability(
            spotsLeft: 3,
            capacity: 8,
            times: [
              SessionTime(DateTime.sunday, 9),
              SessionTime(DateTime.tuesday, 9),
              SessionTime(DateTime.thursday, 18, 30),
            ],
          ),
        ),
        Offering(
          id: 'nr-private',
          kind: OfferingKind.session,
          name: 'حصة ريفورمر خاصة',
          nameEn: 'Private reformer session',
          price: 16.000,
          minutes: 50,
          format: ServiceFormat.inPerson,
          level: FitnessLevel.any,
          cancellation: CancellationPolicy.free24h,
          includes: ['مدرب لك وحدك', 'تعديل التمارين حسب أي إصابة سابقة'],
          includesEn: [
            'A coach to yourself',
            'Exercises adapted around any past injury',
          ],
          availability: Availability(
            spotsLeft: 4,
            times: [
              SessionTime(DateTime.monday, 11),
              SessionTime(DateTime.wednesday, 11),
            ],
          ),
        ),
        Offering(
          id: 'nr-eight',
          kind: OfferingKind.pass,
          name: 'باقة ٨ حصص',
          nameEn: 'Eight-class pass',
          note: 'صالحة ستة أسابيع',
          noteEn: 'Valid for six weeks',
          price: 55.000,
          format: ServiceFormat.inPerson,
          cancellation: CancellationPolicy.nonRefundable,
          includes: [
            'ثماني حصص جماعية',
            'حجز الحصص متى شئت خلال ستة أسابيع',
          ],
          includesEn: [
            'Eight group classes',
            'Book them whenever you like across six weeks',
          ],
        ),
      ],
    ),
    Partner(
      slug: 'namat-move',
      city: NamatCity.sohar,
      name: 'نمط · حركة',
      nameEn: 'NAMAT · Move',
      area: 'فلج القبائل',
      areaEn: 'Falaj Al Qabail',
      field: NamatField.fitness,
      distanceKm: 11.2,
      inPackage: true,
      firstParty: true,
      tags: ['يوغا', 'تمارين متقطعة'],
      tagsEn: ['Yoga', 'HIIT'],
      about: 'قاعة حركة يديرها نمط: يوغا، تمارين متقطعة، وحصص تنفس ومرونة.',
      aboutEn: 'A NAMAT movement hall: yoga, HIIT, and breath-and-mobility '
          'classes.',
      hours: OpeningHours(opensAt: _sixAm, closesAt: _ninePm),
      phone: '+96824000103',
      offerings: [
        Offering(
          id: 'nm-yoga',
          kind: OfferingKind.session,
          name: 'حصة يوغا',
          nameEn: 'Yoga class',
          price: 5.000,
          minutes: 60,
          coveredByPackage: true,
          format: ServiceFormat.inPerson,
          level: FitnessLevel.any,
          cancellation: CancellationPolicy.free2h,
          includes: ['سجادة ومسندات', 'الحصة مناسبة لكل المستويات'],
          includesEn: ['Mat and props', 'Suitable for every level'],
          availability: Availability(
            spotsLeft: 9,
            capacity: 20,
            times: [
              SessionTime(DateTime.saturday, 7),
              SessionTime(DateTime.monday, 7),
              SessionTime(DateTime.wednesday, 19),
            ],
          ),
        ),
        Offering(
          id: 'nm-hiit',
          kind: OfferingKind.session,
          name: 'حصة تمارين متقطعة',
          nameEn: 'HIIT class',
          price: 5.500,
          minutes: 45,
          coveredByPackage: true,
          format: ServiceFormat.inPerson,
          level: FitnessLevel.advanced,
          cancellation: CancellationPolicy.free2h,
          includes: ['قياس نبض طوال الحصة'],
          includesEn: ['Heart-rate tracking throughout'],
          // Full on purpose: a catalogue where nothing is ever sold out never
          // exercises the state, and it is the state members meet most.
          availability: Availability(
            spotsLeft: 0,
            capacity: 16,
            times: [
              SessionTime(DateTime.sunday, 18),
              SessionTime(DateTime.tuesday, 18),
            ],
          ),
        ),
        Offering(
          id: 'nm-breath',
          kind: OfferingKind.session,
          name: 'حصة تنفس ومرونة',
          nameEn: 'Breath and mobility class',
          price: 4.500,
          minutes: 40,
          coveredByPackage: true,
          format: ServiceFormat.either,
          level: FitnessLevel.beginner,
          cancellation: CancellationPolicy.free2h,
          includes: ['يمكن حضورها عن بُعد', 'تسجيل الحصة لمدة أسبوع'],
          includesEn: ['Can be attended remotely', 'Recording available for a week'],
          availability: Availability(
            spotsLeft: 12,
            capacity: 25,
            times: [
              SessionTime(DateTime.thursday, 20),
            ],
          ),
        ),
        Offering(
          id: 'nm-month',
          kind: OfferingKind.pass,
          name: 'اشتراك شهري — كل الحصص',
          nameEn: 'Monthly pass — all classes',
          price: 28.000,
          format: ServiceFormat.inPerson,
          cancellation: CancellationPolicy.nonRefundable,
          includes: ['كل حصص اليوغا والتمارين المتقطعة والتنفس'],
          includesEn: ['Every yoga, HIIT and breath class'],
        ),
      ],
    ),

    // -------------------------------------------------------------- consult
    Partner(
      slug: 'namat-nutrition',
      city: NamatCity.sohar,
      name: 'نمط · التغذية',
      nameEn: 'NAMAT · Nutrition',
      area: 'استشارة عن بُعد أو في العيادة',
      areaEn: 'Remote or in clinic',
      field: NamatField.consult,
      distanceKm: 6.4,
      inPackage: true,
      firstParty: true,
      tags: ['تغذية علاجية', 'خطط غذائية'],
      tagsEn: ['Clinical nutrition', 'Meal planning'],
      about: 'أخصائيو تغذية مرخّصون في عُمان، يعملون مع أهداف نمط نفسها التي '
          'اخترتها عند التسجيل.',
      aboutEn: 'Licensed nutrition specialists in Oman, working to the same '
          'goals you chose when you signed up.',
      hours: OpeningHours(opensAt: _nineAm, closesAt: _fivePm, closedOn: [
        DateTime.friday,
      ]),
      phone: '+96824000110',
      offerings: [
        Offering(
          id: 'nn-first',
          kind: OfferingKind.consultation,
          name: 'استشارة أولى',
          nameEn: 'First consultation',
          note: 'تقييم كامل وخطة مكتوبة',
          noteEn: 'Full assessment and a written plan',
          price: 25.000,
          minutes: 45,
          coveredByPackage: true,
          format: ServiceFormat.either,
          cancellation: CancellationPolicy.free24h,
          includes: [
            'مراجعة عاداتك الغذائية الحالية',
            'خطة مكتوبة تصلك خلال يومين',
            'رسالة متابعة بعد أسبوعين',
          ],
          includesEn: [
            'A review of how you eat now',
            'A written plan within two days',
            'A follow-up message after two weeks',
          ],
          availability: Availability(
            spotsLeft: 6,
            times: [
              SessionTime(DateTime.sunday, 10),
              SessionTime(DateTime.tuesday, 14),
              SessionTime(DateTime.thursday, 10),
            ],
          ),
        ),
        Offering(
          id: 'nn-follow',
          kind: OfferingKind.consultation,
          name: 'متابعة',
          nameEn: 'Follow-up',
          price: 12.000,
          minutes: 20,
          coveredByPackage: true,
          format: ServiceFormat.either,
          cancellation: CancellationPolicy.free2h,
          includes: ['مراجعة ما تغيّر', 'تعديل الخطة عند الحاجة'],
          includesEn: ['A look at what has changed', 'Plan adjusted if needed'],
          availability: Availability(
            spotsLeft: 11,
            times: [
              SessionTime(DateTime.monday, 11),
              SessionTime(DateTime.wednesday, 11),
              SessionTime(DateTime.wednesday, 16),
            ],
          ),
        ),
        Offering(
          id: 'nn-body',
          kind: OfferingKind.consultation,
          name: 'تحليل تكوين الجسم',
          nameEn: 'Body composition analysis',
          note: 'في العيادة فقط',
          noteEn: 'In clinic only',
          price: 15.000,
          minutes: 25,
          format: ServiceFormat.inPerson,
          cancellation: CancellationPolicy.free24h,
          includes: ['قياس بالمقاومة الكهربائية', 'تقرير مقارنة مع آخر قياس'],
          includesEn: [
            'Bioelectrical impedance measurement',
            'A report comparing it against your last one',
          ],
          availability: Availability(
            spotsLeft: 3,
            times: [
              SessionTime(DateTime.sunday, 9),
              SessionTime(DateTime.tuesday, 9),
            ],
          ),
        ),
        Offering(
          id: 'nn-plan',
          kind: OfferingKind.plan,
          name: 'خطة غذائية مكتوبة',
          nameEn: 'Written nutrition plan',
          note: 'بدون موعد — تصلك بعد استبيان قصير',
          noteEn: 'No appointment — sent after a short questionnaire',
          price: 20.000,
          format: ServiceFormat.remote,
          includes: [
            'خطة أربعة أسابيع',
            'قائمة تسوّق أسبوعية',
            'بدائل لكل وجبة',
          ],
          includesEn: [
            'A four-week plan',
            'A weekly shopping list',
            'Alternatives for every meal',
          ],
        ),
      ],
    ),
    Partner(
      slug: 'namat-coaching',
      city: NamatCity.sohar,
      name: 'نمط · إرشاد نمط الحياة',
      nameEn: 'NAMAT · Lifestyle coaching',
      area: 'استشارة عن بُعد',
      areaEn: 'Remote',
      field: NamatField.consult,
      distanceKm: 0,
      firstParty: true,
      tags: ['عادات', 'نوم', 'ضغط'],
      tagsEn: ['Habits', 'Sleep', 'Stress'],
      about: 'إرشاد عملي حول العادات والنوم وتنظيم اليوم. ليس علاجاً نفسياً، '
          'وإذا احتجت مختصاً نرشدك إليه.',
      aboutEn: 'Practical coaching on habits, sleep and structuring a day. It '
          'is not psychotherapy, and we will point you to a clinician if that '
          'is what you need.',
      hours: OpeningHours(opensAt: _nineAm, closesAt: _ninePm, closedOn: [
        DateTime.friday,
      ]),
      phone: '+96824000111',
      offerings: [
        Offering(
          id: 'nc-plan',
          kind: OfferingKind.consultation,
          name: 'جلسة تخطيط نمط الحياة',
          nameEn: 'Lifestyle planning session',
          price: 18.000,
          minutes: 40,
          format: ServiceFormat.remote,
          cancellation: CancellationPolicy.free24h,
          includes: ['مراجعة أسبوعك الفعلي', 'ثلاث عادات قابلة للقياس'],
          includesEn: [
            'A look at the week you actually have',
            'Three habits you can measure',
          ],
          availability: Availability(
            spotsLeft: 8,
            times: [
              SessionTime(DateTime.sunday, 20),
              SessionTime(DateTime.wednesday, 20),
            ],
          ),
        ),
        Offering(
          id: 'nc-sleep',
          kind: OfferingKind.consultation,
          name: 'جلسة النوم',
          nameEn: 'Sleep session',
          price: 16.000,
          minutes: 35,
          format: ServiceFormat.remote,
          cancellation: CancellationPolicy.free24h,
          includes: ['مراجعة روتين نومك', 'خطة تعديل تدريجي على أسبوعين'],
          includesEn: [
            'A review of your sleep routine',
            'A two-week gradual adjustment plan',
          ],
          availability: Availability(
            spotsLeft: 4,
            times: [SessionTime(DateTime.monday, 21)],
          ),
        ),
        Offering(
          id: 'nc-weekly',
          kind: OfferingKind.pass,
          name: 'متابعة أسبوعية — شهر',
          nameEn: 'Weekly check-ins — one month',
          price: 45.000,
          format: ServiceFormat.remote,
          cancellation: CancellationPolicy.nonRefundable,
          includes: [
            'أربع مكالمات قصيرة',
            'رسائل بينها عند الحاجة',
          ],
          includesEn: [
            'Four short calls',
            'Messages in between when you need them',
          ],
        ),
      ],
    ),

    // --------------------------------------------------------------- stores
    Partner(
      slug: 'tree-of-life',
      city: NamatCity.muscat,
      name: 'Tree of Life',
      nameEn: 'Tree of Life',
      area: 'غلا',
      areaEn: 'Ghala',
      field: NamatField.stores,
      distanceKm: 6.2,
      tags: ['منتجات صحية'],
      tagsEn: ['Health products'],
      offerings: [
        Offering(
          id: 'tol-whey',
          kind: OfferingKind.product,
          name: 'بروتين مصل اللبن — ٢ كجم',
          nameEn: 'Whey protein — 2kg',
          price: 24.500,
        ),
        Offering(
          id: 'tol-oats',
          kind: OfferingKind.product,
          name: 'شوفان كامل الحبة — ١ كجم',
          nameEn: 'Wholegrain oats — 1kg',
          price: 2.200,
        ),
        Offering(
          id: 'tol-vitd',
          kind: OfferingKind.product,
          name: 'فيتامين د٣ — ٦٠ قرصاً',
          nameEn: 'Vitamin D3 — 60 tablets',
          price: 5.900,
        ),
        Offering(
          id: 'tol-almond',
          kind: OfferingKind.product,
          name: 'زبدة لوز طبيعية — ٣٤٠غ',
          nameEn: 'Natural almond butter — 340g',
          price: 4.100,
        ),
      ],
    ),
    Partner(
      slug: 'nefisorganic',
      city: NamatCity.muscat,
      name: 'Nefisorganic',
      nameEn: 'Nefisorganic',
      area: 'مسقط',
      areaEn: 'Muscat',
      field: NamatField.stores,
      distanceKm: 8.1,
      tags: ['منتجات عضوية'],
      tagsEn: ['Organic'],
      offerings: [
        Offering(
          id: 'nef-honey',
          kind: OfferingKind.product,
          name: 'عسل عُماني طبيعي — ٥٠٠غ',
          nameEn: 'Omani honey — 500g',
          price: 12.000,
        ),
        Offering(
          id: 'nef-dates',
          kind: OfferingKind.product,
          name: 'تمر خلاص عضوي — ١ كجم',
          nameEn: 'Organic Khalas dates — 1kg',
          price: 4.800,
        ),
        Offering(
          id: 'nef-oil',
          kind: OfferingKind.product,
          name: 'زيت زيتون بكر ممتاز — ٧٥٠مل',
          nameEn: 'Extra virgin olive oil — 750ml',
          price: 7.400,
        ),
        Offering(
          id: 'nef-nuts',
          kind: OfferingKind.product,
          name: 'مكسرات نيئة مشكّلة — ٥٠٠غ',
          nameEn: 'Raw mixed nuts — 500g',
          price: 6.200,
        ),
      ],
    ),
  ];

  static List<Partner> byField(NamatField field) =>
      all.where((p) => p.field == field).toList();

  /// Everything in one market.
  static List<Partner> byCity(NamatCity city) =>
      all.where((p) => p.city == city).toList();

  /// One field, in one market.
  ///
  /// The pair that most screens actually want: a member browsing meals is
  /// browsing meals near them, and a list that silently mixes in another
  /// city's kitchens is worse than a short list.
  static List<Partner> inCity(NamatField field, NamatCity city) =>
      all.where((p) => p.field == field && p.city == city).toList();

  /// The cities that have anything at all in this field, so a screen can
  /// offer "there is nothing here, but there is something in Muscat".
  static List<NamatCity> citiesWith(NamatField field) =>
      NamatCity.values.where((c) => inCity(field, c).isNotEmpty).toList();

  static Partner? bySlug(String slug) =>
      all.where((p) => p.slug == slug).firstOrNull;

  static Offering? offeringById(String id) {
    for (final p in all) {
      for (final o in p.offerings) {
        if (o.id == id) return o;
      }
    }
    return null;
  }

  /// The partner selling a given offering, for showing "from X" on a cart line
  /// without the caller having to carry the partner around.
  static Partner? partnerOf(String offeringId) =>
      all.where((p) => p.offerings.any((o) => o.id == offeringId)).firstOrNull;
}
