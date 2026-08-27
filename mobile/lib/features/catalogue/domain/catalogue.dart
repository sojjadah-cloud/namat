/// The catalogue: partners and the things they sell.
///
/// PROVENANCE — this matters, and it is not uniform across the file.
///
/// The meals and stores partners are the researched Muscat ones carried over
/// from the removed backend: real businesses, with capabilities recorded as
/// null where the research never established them. No rating, price or
/// photograph was invented for those, which is why several of them still
/// carry `rating: null` and are priced only at the item level.
///
/// The fitness and consult partners are ILLUSTRATIVE. There is no researched
/// catalogue for either field yet, and inventing named studios or named
/// practitioners would be a claim about businesses and people who exist in
/// Muscat. So those two fields are stocked with NAMAT's own first-party
/// offerings and generically-named venues, and must be replaced with
/// researched partners before launch. Prices there are plausible, not sourced.
///
/// Everything a member can actually buy lives here rather than in the widgets
/// that display it, so the selection flow, the cart, checkout and the ratings
/// screen all read one list and cannot drift apart.
library;

import '../../use/domain/field.dart';

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

  String localisedName(bool arabic) => arabic ? name : nameEn;
  String? localisedNote(bool arabic) => arabic ? note : noteEn;
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
    required this.distanceKm,
    required this.offerings,
    this.rating,
    this.reviewCount,
    this.inPackage = false,
    this.tags = const [],
    this.tagsEn = const [],
    this.firstParty = false,
  });

  final String slug;
  final String name;
  final String nameEn;
  final String area;
  final String areaEn;
  final NamatField field;
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

  String localisedName(bool arabic) => arabic ? name : nameEn;
  String localisedArea(bool arabic) => arabic ? area : areaEn;
  List<String> localisedTags(bool arabic) => arabic ? tags : tagsEn;

  /// The cheapest thing on the list, for the "from …" line.
  double? get fromPrice => offerings.isEmpty
      ? null
      : offerings.map((o) => o.price).reduce((a, b) => a < b ? a : b);
}

abstract final class Catalogue {
  static const List<Partner> all = [
    // ---------------------------------------------------------------- meals
    Partner(
      slug: 'healthy-lab',
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
          id: 'hl-week',
          kind: OfferingKind.plan,
          name: 'اشتراك أسبوعي — ١٢ وجبة',
          nameEn: 'Weekly plan — 12 meals',
          note: 'غداء وعشاء، ستة أيام، يُوصَّل يومياً',
          noteEn: 'Lunch and dinner, six days, delivered daily',
          price: 32.000,
        ),
      ],
    ),
    Partner(
      slug: 'nourish-kitchen',
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
          id: 'nk-week',
          kind: OfferingKind.plan,
          name: 'خطة وجبات أسبوعية',
          nameEn: 'Weekly meal plan',
          price: 38.500,
        ),
      ],
    ),
    Partner(
      slug: 'hilda-keto',
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
    // Illustrative. See the provenance note at the top of this file.
    Partner(
      slug: 'namat-strength',
      name: 'نمط · تمرين القوة',
      nameEn: 'NAMAT · Strength',
      area: 'القرم',
      areaEn: 'Qurum',
      field: NamatField.fitness,
      distanceKm: 2.1,
      inPackage: true,
      firstParty: true,
      tags: ['أوزان حرة', 'مدرب شخصي'],
      tagsEn: ['Free weights', 'Personal training'],
      offerings: [
        Offering(
          id: 'ns-day',
          kind: OfferingKind.session,
          name: 'حصة يوم واحد',
          nameEn: 'Single day pass',
          price: 4.000,
          minutes: 90,
          coveredByPackage: true,
        ),
        Offering(
          id: 'ns-pt',
          kind: OfferingKind.session,
          name: 'جلسة مع مدرب شخصي',
          nameEn: 'Personal training session',
          price: 12.000,
          minutes: 60,
        ),
        Offering(
          id: 'ns-month',
          kind: OfferingKind.pass,
          name: 'اشتراك شهري',
          nameEn: 'Monthly membership',
          note: 'دخول غير محدود، ويشمل الحصص الجماعية',
          noteEn: 'Unlimited access, group classes included',
          price: 35.000,
        ),
      ],
    ),
    Partner(
      slug: 'namat-reformer',
      name: 'نمط · بيلاتس',
      nameEn: 'NAMAT · Pilates',
      area: 'شاطئ القرم',
      areaEn: 'Qurum Beach',
      field: NamatField.fitness,
      distanceKm: 3.4,
      firstParty: true,
      tags: ['ريفورمر', 'حصص جماعية'],
      tagsEn: ['Reformer', 'Group classes'],
      offerings: [
        Offering(
          id: 'nr-class',
          kind: OfferingKind.session,
          name: 'حصة ريفورمر جماعية',
          nameEn: 'Group reformer class',
          price: 8.000,
          minutes: 50,
        ),
        Offering(
          id: 'nr-eight',
          kind: OfferingKind.pass,
          name: 'باقة ٨ حصص',
          nameEn: 'Eight-class pass',
          note: 'صالحة ستة أسابيع',
          noteEn: 'Valid for six weeks',
          price: 55.000,
        ),
      ],
    ),
    Partner(
      slug: 'namat-move',
      name: 'نمط · حركة',
      nameEn: 'NAMAT · Move',
      area: 'المعبيلة',
      areaEn: 'Maabela',
      field: NamatField.fitness,
      distanceKm: 11.2,
      inPackage: true,
      firstParty: true,
      tags: ['يوغا', 'تمارين متقطعة'],
      tagsEn: ['Yoga', 'HIIT'],
      offerings: [
        Offering(
          id: 'nm-yoga',
          kind: OfferingKind.session,
          name: 'حصة يوغا',
          nameEn: 'Yoga class',
          price: 5.000,
          minutes: 60,
          coveredByPackage: true,
        ),
        Offering(
          id: 'nm-hiit',
          kind: OfferingKind.session,
          name: 'حصة تمارين متقطعة',
          nameEn: 'HIIT class',
          price: 5.500,
          minutes: 45,
          coveredByPackage: true,
        ),
      ],
    ),

    // -------------------------------------------------------------- consult
    // First-party on purpose: naming a nutritionist or a therapist who
    // practises in Muscat would be a claim about a real person.
    Partner(
      slug: 'namat-nutrition',
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
        ),
        Offering(
          id: 'nn-follow',
          kind: OfferingKind.consultation,
          name: 'متابعة',
          nameEn: 'Follow-up',
          price: 12.000,
          minutes: 20,
          coveredByPackage: true,
        ),
      ],
    ),
    Partner(
      slug: 'namat-coaching',
      name: 'نمط · إرشاد نمط الحياة',
      nameEn: 'NAMAT · Lifestyle coaching',
      area: 'استشارة عن بُعد',
      areaEn: 'Remote',
      field: NamatField.consult,
      distanceKm: 0,
      firstParty: true,
      tags: ['عادات', 'نوم', 'ضغط'],
      tagsEn: ['Habits', 'Sleep', 'Stress'],
      offerings: [
        Offering(
          id: 'nc-plan',
          kind: OfferingKind.consultation,
          name: 'جلسة تخطيط نمط الحياة',
          nameEn: 'Lifestyle planning session',
          price: 18.000,
          minutes: 40,
        ),
      ],
    ),

    // --------------------------------------------------------------- stores
    Partner(
      slug: 'tree-of-life',
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
      ],
    ),
    Partner(
      slug: 'nefisorganic',
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
      ],
    ),
  ];

  static List<Partner> byField(NamatField field) =>
      all.where((p) => p.field == field).toList();

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
