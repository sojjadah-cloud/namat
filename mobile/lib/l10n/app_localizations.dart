import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of L
/// returned by `L.of(context)`.
///
/// Applications need to include `L.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: L.localizationsDelegates,
///   supportedLocales: L.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the L.supportedLocales
/// property.
abstract class L {
  L(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static L? of(BuildContext context) {
    return Localizations.of<L>(context, L);
  }

  static const LocalizationsDelegate<L> delegate = _LDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// No description provided for @appName.
  ///
  /// In ar, this message translates to:
  /// **'نمط'**
  String get appName;

  /// No description provided for @tagline.
  ///
  /// In ar, this message translates to:
  /// **'عِش أفضل، كل يوم'**
  String get tagline;

  /// No description provided for @onbTitle1.
  ///
  /// In ar, this message translates to:
  /// **'كل ما تحتاجه لنمط حياة أفضل'**
  String get onbTitle1;

  /// No description provided for @onbTitle2.
  ///
  /// In ar, this message translates to:
  /// **'رحلتك في مكان واحد'**
  String get onbTitle2;

  /// No description provided for @onbTitle3.
  ///
  /// In ar, this message translates to:
  /// **'استمر… وتحدَّ أصدقاءك'**
  String get onbTitle3;

  /// No description provided for @onbStart.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ الآن'**
  String get onbStart;

  /// No description provided for @onbHaveAccount.
  ///
  /// In ar, this message translates to:
  /// **'لدي حساب'**
  String get onbHaveAccount;

  /// No description provided for @onbSkip.
  ///
  /// In ar, this message translates to:
  /// **'تخطٍ'**
  String get onbSkip;

  /// No description provided for @welcomeHeadline.
  ///
  /// In ar, this message translates to:
  /// **'أسلوبك الصحي يبدأ بطريقة أذكى'**
  String get welcomeHeadline;

  /// No description provided for @welcomeSub.
  ///
  /// In ar, this message translates to:
  /// **'نمط يجمع رحلتك الصحية، خدماتك، تحدياتك وإنجازاتك في مكان واحد.'**
  String get welcomeSub;

  /// No description provided for @createAccount.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء حساب'**
  String get createAccount;

  /// No description provided for @login.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول'**
  String get login;

  /// No description provided for @exploreAsGuest.
  ///
  /// In ar, this message translates to:
  /// **'استكشف نمط كزائر'**
  String get exploreAsGuest;

  /// No description provided for @navHome.
  ///
  /// In ar, this message translates to:
  /// **'الرئيسية'**
  String get navHome;

  /// No description provided for @navUse.
  ///
  /// In ar, this message translates to:
  /// **'استخدم نمط'**
  String get navUse;

  /// No description provided for @navChallenges.
  ///
  /// In ar, this message translates to:
  /// **'التحديات'**
  String get navChallenges;

  /// No description provided for @navJourney.
  ///
  /// In ar, this message translates to:
  /// **'رحلتي'**
  String get navJourney;

  /// No description provided for @navProfile.
  ///
  /// In ar, this message translates to:
  /// **'حسابي'**
  String get navProfile;

  /// No description provided for @greetingMorning.
  ///
  /// In ar, this message translates to:
  /// **'صباح الخير، {name}'**
  String greetingMorning(String name);

  /// No description provided for @greetingEvening.
  ///
  /// In ar, this message translates to:
  /// **'مساء الخير، {name}'**
  String greetingEvening(String name);

  /// No description provided for @namatPoints.
  ///
  /// In ar, this message translates to:
  /// **'نقاط نمط'**
  String get namatPoints;

  /// No description provided for @doingGreat.
  ///
  /// In ar, this message translates to:
  /// **'أنت تسير بشكل رائع'**
  String get doingGreat;

  /// No description provided for @arcNutrition.
  ///
  /// In ar, this message translates to:
  /// **'التغذية'**
  String get arcNutrition;

  /// No description provided for @arcMovement.
  ///
  /// In ar, this message translates to:
  /// **'الحركة'**
  String get arcMovement;

  /// No description provided for @arcHydration.
  ///
  /// In ar, this message translates to:
  /// **'الترطيب'**
  String get arcHydration;

  /// No description provided for @quickBookMeal.
  ///
  /// In ar, this message translates to:
  /// **'احجز وجبة'**
  String get quickBookMeal;

  /// No description provided for @quickFindActivity.
  ///
  /// In ar, this message translates to:
  /// **'ابحث عن نشاط'**
  String get quickFindActivity;

  /// No description provided for @quickConsult.
  ///
  /// In ar, this message translates to:
  /// **'استشر مختص'**
  String get quickConsult;

  /// No description provided for @quickStartChallenge.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ تحدياً'**
  String get quickStartChallenge;

  /// No description provided for @useGreeting.
  ///
  /// In ar, this message translates to:
  /// **'كيف تريد أن تستخدم نمط اليوم؟'**
  String get useGreeting;

  /// No description provided for @useSub.
  ///
  /// In ar, this message translates to:
  /// **'اختر المجال، ونساعدك في الوصول إلى الأنسب لك.'**
  String get useSub;

  /// No description provided for @fieldMeals.
  ///
  /// In ar, this message translates to:
  /// **'وجبات صحية'**
  String get fieldMeals;

  /// No description provided for @fieldMealsSub.
  ///
  /// In ar, this message translates to:
  /// **'وجبات ومطاعم تناسب نمطك'**
  String get fieldMealsSub;

  /// No description provided for @fieldFitness.
  ///
  /// In ar, this message translates to:
  /// **'رياضة ولياقة'**
  String get fieldFitness;

  /// No description provided for @fieldFitnessSub.
  ///
  /// In ar, this message translates to:
  /// **'اكتشف النشاط المناسب لك'**
  String get fieldFitnessSub;

  /// No description provided for @fieldConsult.
  ///
  /// In ar, this message translates to:
  /// **'استشارات'**
  String get fieldConsult;

  /// No description provided for @fieldConsultSub.
  ///
  /// In ar, this message translates to:
  /// **'خبراء يساعدونك في رحلتك'**
  String get fieldConsultSub;

  /// No description provided for @fieldStores.
  ///
  /// In ar, this message translates to:
  /// **'متاجر صحية'**
  String get fieldStores;

  /// No description provided for @fieldStoresSub.
  ///
  /// In ar, this message translates to:
  /// **'منتجات تساعدك على الاستمرار'**
  String get fieldStoresSub;

  /// No description provided for @optionCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} خياراً'**
  String optionCount(String count);

  /// No description provided for @noPartnersYet.
  ///
  /// In ar, this message translates to:
  /// **'ما في شركاء بعد'**
  String get noPartnersYet;

  /// No description provided for @explore.
  ///
  /// In ar, this message translates to:
  /// **'استكشف'**
  String get explore;

  /// No description provided for @searchMeals.
  ///
  /// In ar, this message translates to:
  /// **'ابحث عن وجبة أو مطعم'**
  String get searchMeals;

  /// No description provided for @searchFitness.
  ///
  /// In ar, this message translates to:
  /// **'ابحث عن نادي أو نشاط'**
  String get searchFitness;

  /// No description provided for @searchConsult.
  ///
  /// In ar, this message translates to:
  /// **'ابحث عن مختص'**
  String get searchConsult;

  /// No description provided for @searchStores.
  ///
  /// In ar, this message translates to:
  /// **'ابحث عن متجر أو منتج'**
  String get searchStores;

  /// No description provided for @filterNearest.
  ///
  /// In ar, this message translates to:
  /// **'الأقرب'**
  String get filterNearest;

  /// No description provided for @filterTopRated.
  ///
  /// In ar, this message translates to:
  /// **'الأعلى تقييماً'**
  String get filterTopRated;

  /// No description provided for @filterHighProtein.
  ///
  /// In ar, this message translates to:
  /// **'عالي البروتين'**
  String get filterHighProtein;

  /// No description provided for @filterSubscriptions.
  ///
  /// In ar, this message translates to:
  /// **'اشتراكات'**
  String get filterSubscriptions;

  /// No description provided for @filterPickup.
  ///
  /// In ar, this message translates to:
  /// **'استلام'**
  String get filterPickup;

  /// No description provided for @filterDelivery.
  ///
  /// In ar, this message translates to:
  /// **'توصيل'**
  String get filterDelivery;

  /// No description provided for @inYourPackage.
  ///
  /// In ar, this message translates to:
  /// **'متاح ضمن باقتك'**
  String get inYourPackage;

  /// No description provided for @viewDetails.
  ///
  /// In ar, this message translates to:
  /// **'عرض التفاصيل'**
  String get viewDetails;

  /// No description provided for @resultCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} نتيجة'**
  String resultCount(String count);

  /// No description provided for @challengesTitle.
  ///
  /// In ar, this message translates to:
  /// **'التحديات'**
  String get challengesTitle;

  /// No description provided for @challengesHero.
  ///
  /// In ar, this message translates to:
  /// **'نافس. استمر. تطور.'**
  String get challengesHero;

  /// No description provided for @challengeSomeone.
  ///
  /// In ar, this message translates to:
  /// **'تحدَّ شخصاً'**
  String get challengeSomeone;

  /// No description provided for @vs.
  ///
  /// In ar, this message translates to:
  /// **'VS'**
  String get vs;

  /// No description provided for @youLeadBy.
  ///
  /// In ar, this message translates to:
  /// **'أنت متقدم بـ {amount}'**
  String youLeadBy(String amount);

  /// No description provided for @noChallenges.
  ///
  /// In ar, this message translates to:
  /// **'ما عندك تحديات حالياً'**
  String get noChallenges;

  /// No description provided for @findUser.
  ///
  /// In ar, this message translates to:
  /// **'ابحث باسم المستخدم أو @username'**
  String get findUser;

  /// No description provided for @challenge.
  ///
  /// In ar, this message translates to:
  /// **'تحدَّ'**
  String get challenge;

  /// No description provided for @namatLevel.
  ///
  /// In ar, this message translates to:
  /// **'مستوى نمط {level}'**
  String namatLevel(String level);

  /// No description provided for @challengeSent.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال التحدي'**
  String get challengeSent;

  /// No description provided for @journeyTitle.
  ///
  /// In ar, this message translates to:
  /// **'رحلتي'**
  String get journeyTitle;

  /// No description provided for @journeyComplete.
  ///
  /// In ar, this message translates to:
  /// **'من رحلة هذا الشهر'**
  String get journeyComplete;

  /// No description provided for @startYourJourney.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ رحلتك مع نمط'**
  String get startYourJourney;

  /// No description provided for @ifSubscribed.
  ///
  /// In ar, this message translates to:
  /// **'لو كنت مشتركاً هذا الشهر'**
  String get ifSubscribed;

  /// No description provided for @potentialSaving.
  ///
  /// In ar, this message translates to:
  /// **'التوفير المحتمل'**
  String get potentialSaving;

  /// No description provided for @explorePackages.
  ///
  /// In ar, this message translates to:
  /// **'استكشف الباقات'**
  String get explorePackages;

  /// No description provided for @mealsUsed.
  ///
  /// In ar, this message translates to:
  /// **'وجبات'**
  String get mealsUsed;

  /// No description provided for @workoutsUsed.
  ///
  /// In ar, this message translates to:
  /// **'حصص رياضية'**
  String get workoutsUsed;

  /// No description provided for @consultsUsed.
  ///
  /// In ar, this message translates to:
  /// **'استشارات'**
  String get consultsUsed;

  /// No description provided for @profileTitle.
  ///
  /// In ar, this message translates to:
  /// **'حسابي'**
  String get profileTitle;

  /// No description provided for @savedPlaces.
  ///
  /// In ar, this message translates to:
  /// **'الأماكن المحفوظة'**
  String get savedPlaces;

  /// No description provided for @myBookings.
  ///
  /// In ar, this message translates to:
  /// **'حجوزاتي'**
  String get myBookings;

  /// No description provided for @myOrders.
  ///
  /// In ar, this message translates to:
  /// **'طلباتي'**
  String get myOrders;

  /// No description provided for @myPackages.
  ///
  /// In ar, this message translates to:
  /// **'باقاتي'**
  String get myPackages;

  /// No description provided for @settings.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get settings;

  /// No description provided for @privacy.
  ///
  /// In ar, this message translates to:
  /// **'الخصوصية'**
  String get privacy;

  /// No description provided for @language.
  ///
  /// In ar, this message translates to:
  /// **'اللغة'**
  String get language;

  /// No description provided for @retry.
  ///
  /// In ar, this message translates to:
  /// **'إعادة المحاولة'**
  String get retry;

  /// No description provided for @errorTitle.
  ///
  /// In ar, this message translates to:
  /// **'ما قدرنا نحمّل البيانات'**
  String get errorTitle;

  /// No description provided for @errorBody.
  ///
  /// In ar, this message translates to:
  /// **'جرب مرة ثانية.'**
  String get errorBody;

  /// No description provided for @emptyNoBookings.
  ///
  /// In ar, this message translates to:
  /// **'لسه ما حجزت أي خدمة'**
  String get emptyNoBookings;

  /// No description provided for @useNamatCta.
  ///
  /// In ar, this message translates to:
  /// **'استخدم نمط'**
  String get useNamatCta;

  /// No description provided for @pickOpponent.
  ///
  /// In ar, this message translates to:
  /// **'اختر منافسك'**
  String get pickOpponent;

  /// No description provided for @searchUser.
  ///
  /// In ar, this message translates to:
  /// **'ابحث باسم المستخدم أو @username'**
  String get searchUser;

  /// No description provided for @noUserFound.
  ///
  /// In ar, this message translates to:
  /// **'ما لقينا أحداً بهذا الاسم'**
  String get noUserFound;

  /// No description provided for @chooseChallenge.
  ///
  /// In ar, this message translates to:
  /// **'اختر التحدي'**
  String get chooseChallenge;

  /// No description provided for @metricSteps.
  ///
  /// In ar, this message translates to:
  /// **'خطوات'**
  String get metricSteps;

  /// No description provided for @metricStepsSub.
  ///
  /// In ar, this message translates to:
  /// **'من يحقق أكبر عدد من الخطوات؟'**
  String get metricStepsSub;

  /// No description provided for @metricWorkouts.
  ///
  /// In ar, this message translates to:
  /// **'النشاط'**
  String get metricWorkouts;

  /// No description provided for @metricWorkoutsSub.
  ///
  /// In ar, this message translates to:
  /// **'من يسجل أكبر عدد من التمارين؟'**
  String get metricWorkoutsSub;

  /// No description provided for @metricWater.
  ///
  /// In ar, this message translates to:
  /// **'الماء'**
  String get metricWater;

  /// No description provided for @metricWaterSub.
  ///
  /// In ar, this message translates to:
  /// **'ثمانية أكواب يومياً'**
  String get metricWaterSub;

  /// No description provided for @metricStreak.
  ///
  /// In ar, this message translates to:
  /// **'الاستمرارية'**
  String get metricStreak;

  /// No description provided for @metricStreakSub.
  ///
  /// In ar, this message translates to:
  /// **'كل يوم بدون انقطاع'**
  String get metricStreakSub;

  /// No description provided for @duration.
  ///
  /// In ar, this message translates to:
  /// **'المدة'**
  String get duration;

  /// No description provided for @days.
  ///
  /// In ar, this message translates to:
  /// **'{count} أيام'**
  String days(String count);

  /// No description provided for @oneDay.
  ///
  /// In ar, this message translates to:
  /// **'يوم واحد'**
  String get oneDay;

  /// No description provided for @readyToChallenge.
  ///
  /// In ar, this message translates to:
  /// **'جاهز للتحدي؟'**
  String get readyToChallenge;

  /// No description provided for @opponent.
  ///
  /// In ar, this message translates to:
  /// **'المنافس'**
  String get opponent;

  /// No description provided for @startsAfterAccept.
  ///
  /// In ar, this message translates to:
  /// **'يبدأ بعد قبول {name}'**
  String startsAfterAccept(String name);

  /// No description provided for @sendChallenge.
  ///
  /// In ar, this message translates to:
  /// **'إرسال التحدي'**
  String get sendChallenge;

  /// No description provided for @challengeSentBody.
  ///
  /// In ar, this message translates to:
  /// **'بننبهك أول ما يرد.'**
  String get challengeSentBody;

  /// No description provided for @backToChallenges.
  ///
  /// In ar, this message translates to:
  /// **'رجوع للتحديات'**
  String get backToChallenges;

  /// No description provided for @dayOfDuel.
  ///
  /// In ar, this message translates to:
  /// **'اليوم {current} من {total}'**
  String dayOfDuel(String current, String total);

  /// No description provided for @timeLeft.
  ///
  /// In ar, this message translates to:
  /// **'باقي {time}'**
  String timeLeft(String time);

  /// No description provided for @latestActivity.
  ///
  /// In ar, this message translates to:
  /// **'آخر النشاطات'**
  String get latestActivity;

  /// No description provided for @eventProgress.
  ///
  /// In ar, this message translates to:
  /// **'{name} أضاف {amount}'**
  String eventProgress(String name, String amount);

  /// No description provided for @eventTookLead.
  ///
  /// In ar, this message translates to:
  /// **'{name} أصبح في الصدارة'**
  String eventTookLead(String name);

  /// No description provided for @eventGoalMet.
  ///
  /// In ar, this message translates to:
  /// **'{name} أكمل هدف اليوم'**
  String eventGoalMet(String name);

  /// No description provided for @eventAccepted.
  ///
  /// In ar, this message translates to:
  /// **'{name} قبل التحدي'**
  String eventAccepted(String name);

  /// No description provided for @logToday.
  ///
  /// In ar, this message translates to:
  /// **'سجّل اليوم'**
  String get logToday;

  /// No description provided for @drawSoFar.
  ///
  /// In ar, this message translates to:
  /// **'متعادلان'**
  String get drawSoFar;

  /// No description provided for @behindBy.
  ///
  /// In ar, this message translates to:
  /// **'متأخر بـ {amount}'**
  String behindBy(String amount);

  /// No description provided for @packagesTitle.
  ///
  /// In ar, this message translates to:
  /// **'باقات نمط'**
  String get packagesTitle;

  /// No description provided for @packagesSub.
  ///
  /// In ar, this message translates to:
  /// **'اختر ما يناسب إيقاعك.'**
  String get packagesSub;

  /// No description provided for @perMonth.
  ///
  /// In ar, this message translates to:
  /// **'شهرياً'**
  String get perMonth;

  /// No description provided for @choosePackage.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ هذه الباقة'**
  String get choosePackage;

  /// No description provided for @currentPackage.
  ///
  /// In ar, this message translates to:
  /// **'باقتك الحالية'**
  String get currentPackage;

  /// No description provided for @partnerAbout.
  ///
  /// In ar, this message translates to:
  /// **'عن الشريك'**
  String get partnerAbout;

  /// No description provided for @partnerServices.
  ///
  /// In ar, this message translates to:
  /// **'الخدمات'**
  String get partnerServices;

  /// No description provided for @bookNow.
  ///
  /// In ar, this message translates to:
  /// **'احجز الآن'**
  String get bookNow;

  /// No description provided for @useFromPackage.
  ///
  /// In ar, this message translates to:
  /// **'استخدم من باقتك'**
  String get useFromPackage;

  /// No description provided for @noDescription.
  ///
  /// In ar, this message translates to:
  /// **'ما زوّدنا الشريك بوصف بعد.'**
  String get noDescription;
}

class _LDelegate extends LocalizationsDelegate<L> {
  const _LDelegate();

  @override
  Future<L> load(Locale locale) {
    return SynchronousFuture<L>(lookupL(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_LDelegate old) => false;
}

L lookupL(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return LAr();
    case 'en': return LEn();
  }

  throw FlutterError(
    'L.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
