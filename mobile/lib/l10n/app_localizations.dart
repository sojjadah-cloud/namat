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

  /// No description provided for @notifications.
  ///
  /// In ar, this message translates to:
  /// **'الإشعارات'**
  String get notifications;

  /// No description provided for @markAllRead.
  ///
  /// In ar, this message translates to:
  /// **'علّم الكل كمقروء'**
  String get markAllRead;

  /// No description provided for @noNotifications.
  ///
  /// In ar, this message translates to:
  /// **'ما فيه إشعارات'**
  String get noNotifications;

  /// No description provided for @noNotificationsBody.
  ///
  /// In ar, this message translates to:
  /// **'بننبهك أول ما يصير شي يستاهل.'**
  String get noNotificationsBody;

  /// No description provided for @today.
  ///
  /// In ar, this message translates to:
  /// **'اليوم'**
  String get today;

  /// No description provided for @earlier.
  ///
  /// In ar, this message translates to:
  /// **'سابقاً'**
  String get earlier;

  /// No description provided for @officialChallenges.
  ///
  /// In ar, this message translates to:
  /// **'تحديات نمط'**
  String get officialChallenges;

  /// No description provided for @yourChallenges.
  ///
  /// In ar, this message translates to:
  /// **'تحدياتك الحالية'**
  String get yourChallenges;

  /// No description provided for @joinChallenge.
  ///
  /// In ar, this message translates to:
  /// **'انضم للتحدي'**
  String get joinChallenge;

  /// No description provided for @participants.
  ///
  /// In ar, this message translates to:
  /// **'{count} مشارك'**
  String participants(String count);

  /// No description provided for @rewardPoints.
  ///
  /// In ar, this message translates to:
  /// **'+{points} نقطة'**
  String rewardPoints(String points);

  /// No description provided for @openChallenge.
  ///
  /// In ar, this message translates to:
  /// **'فتح التحدي'**
  String get openChallenge;

  /// No description provided for @journeyTimeline.
  ///
  /// In ar, this message translates to:
  /// **'خط رحلتك'**
  String get journeyTimeline;

  /// No description provided for @timelineToday.
  ///
  /// In ar, this message translates to:
  /// **'اليوم'**
  String get timelineToday;

  /// No description provided for @timelineYesterday.
  ///
  /// In ar, this message translates to:
  /// **'أمس'**
  String get timelineYesterday;

  /// No description provided for @bookAgain.
  ///
  /// In ar, this message translates to:
  /// **'احجز مرة ثانية'**
  String get bookAgain;

  /// No description provided for @callPartner.
  ///
  /// In ar, this message translates to:
  /// **'اتصل'**
  String get callPartner;

  /// No description provided for @directions.
  ///
  /// In ar, this message translates to:
  /// **'الاتجاهات'**
  String get directions;

  /// No description provided for @partnerNoRating.
  ///
  /// In ar, this message translates to:
  /// **'ما فيه تقييمات بعد'**
  String get partnerNoRating;

  /// No description provided for @from.
  ///
  /// In ar, this message translates to:
  /// **'تبدأ من'**
  String get from;

  /// No description provided for @omr.
  ///
  /// In ar, this message translates to:
  /// **'ر.ع'**
  String get omr;

  /// No description provided for @bookingsTitle.
  ///
  /// In ar, this message translates to:
  /// **'حجوزاتي'**
  String get bookingsTitle;

  /// No description provided for @tabUpcoming.
  ///
  /// In ar, this message translates to:
  /// **'القادمة'**
  String get tabUpcoming;

  /// No description provided for @tabSubscriptions.
  ///
  /// In ar, this message translates to:
  /// **'الاشتراكات'**
  String get tabSubscriptions;

  /// No description provided for @tabPast.
  ///
  /// In ar, this message translates to:
  /// **'السابقة'**
  String get tabPast;

  /// No description provided for @noUpcoming.
  ///
  /// In ar, this message translates to:
  /// **'ما عندك حجوزات قادمة'**
  String get noUpcoming;

  /// No description provided for @noUpcomingBody.
  ///
  /// In ar, this message translates to:
  /// **'احجز خدمة وتظهر لك هنا.'**
  String get noUpcomingBody;

  /// No description provided for @noSubscriptions.
  ///
  /// In ar, this message translates to:
  /// **'ما عندك اشتراكات'**
  String get noSubscriptions;

  /// No description provided for @noPast.
  ///
  /// In ar, this message translates to:
  /// **'ما فيه حجوزات سابقة'**
  String get noPast;

  /// No description provided for @daysRemaining.
  ///
  /// In ar, this message translates to:
  /// **'باقي {days} يوم'**
  String daysRemaining(String days);

  /// No description provided for @reschedule.
  ///
  /// In ar, this message translates to:
  /// **'غيّر الموعد'**
  String get reschedule;

  /// No description provided for @cancelBooking.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get cancelBooking;

  /// No description provided for @rateIt.
  ///
  /// In ar, this message translates to:
  /// **'قيّم التجربة'**
  String get rateIt;

  /// No description provided for @cartTitle.
  ///
  /// In ar, this message translates to:
  /// **'السلة'**
  String get cartTitle;

  /// No description provided for @cartEmpty.
  ///
  /// In ar, this message translates to:
  /// **'سلتك فاضية'**
  String get cartEmpty;

  /// No description provided for @cartEmptyBody.
  ///
  /// In ar, this message translates to:
  /// **'ضِف وجبة أو منتج أو استشارة وتلقاها هنا.'**
  String get cartEmptyBody;

  /// No description provided for @cartBrowse.
  ///
  /// In ar, this message translates to:
  /// **'تصفّح نمط'**
  String get cartBrowse;

  /// No description provided for @subtotal.
  ///
  /// In ar, this message translates to:
  /// **'المجموع'**
  String get subtotal;

  /// No description provided for @packageCovers.
  ///
  /// In ar, this message translates to:
  /// **'تغطيه باقتك'**
  String get packageCovers;

  /// No description provided for @youPay.
  ///
  /// In ar, this message translates to:
  /// **'المطلوب'**
  String get youPay;

  /// No description provided for @checkout.
  ///
  /// In ar, this message translates to:
  /// **'إتمام الطلب'**
  String get checkout;

  /// No description provided for @removeItem.
  ///
  /// In ar, this message translates to:
  /// **'حذف'**
  String get removeItem;

  /// No description provided for @itemMeal.
  ///
  /// In ar, this message translates to:
  /// **'وجبة'**
  String get itemMeal;

  /// No description provided for @itemConsult.
  ///
  /// In ar, this message translates to:
  /// **'استشارة'**
  String get itemConsult;

  /// No description provided for @itemProduct.
  ///
  /// In ar, this message translates to:
  /// **'منتج'**
  String get itemProduct;

  /// No description provided for @freeFromPackage.
  ///
  /// In ar, this message translates to:
  /// **'مجاناً من باقتك'**
  String get freeFromPackage;

  /// No description provided for @orderPlaced.
  ///
  /// In ar, this message translates to:
  /// **'تم الطلب'**
  String get orderPlaced;

  /// No description provided for @orderPlacedBody.
  ///
  /// In ar, this message translates to:
  /// **'بتوصلك تفاصيل الطلب في الإشعارات.'**
  String get orderPlacedBody;

  /// No description provided for @backHome.
  ///
  /// In ar, this message translates to:
  /// **'رجوع للرئيسية'**
  String get backHome;

  /// No description provided for @covered.
  ///
  /// In ar, this message translates to:
  /// **'مشمول'**
  String get covered;

  /// No description provided for @signupTitle.
  ///
  /// In ar, this message translates to:
  /// **'أهلاً بك في نمط'**
  String get signupTitle;

  /// No description provided for @signupBody.
  ///
  /// In ar, this message translates to:
  /// **'رقمك يكفي — بدون كلمة مرور.'**
  String get signupBody;

  /// No description provided for @loginTitle.
  ///
  /// In ar, this message translates to:
  /// **'حياك الله من جديد'**
  String get loginTitle;

  /// No description provided for @loginBody.
  ///
  /// In ar, this message translates to:
  /// **'سجّل دخولك وكمّل من وين وقفت.'**
  String get loginBody;

  /// No description provided for @phoneLabel.
  ///
  /// In ar, this message translates to:
  /// **'رقم الجوال'**
  String get phoneLabel;

  /// No description provided for @phoneHint.
  ///
  /// In ar, this message translates to:
  /// **'٩××× ××××'**
  String get phoneHint;

  /// No description provided for @continueCta.
  ///
  /// In ar, this message translates to:
  /// **'متابعة'**
  String get continueCta;

  /// No description provided for @invalidPhone.
  ///
  /// In ar, this message translates to:
  /// **'الرقم ما يبدو صحيحاً. تأكد منه.'**
  String get invalidPhone;

  /// No description provided for @verifyTitle.
  ///
  /// In ar, this message translates to:
  /// **'اكتب الرمز'**
  String get verifyTitle;

  /// No description provided for @verifyBody.
  ///
  /// In ar, this message translates to:
  /// **'أرسلنا رمز من ٦ أرقام إلى {phone}'**
  String verifyBody(String phone);

  /// No description provided for @editNumber.
  ///
  /// In ar, this message translates to:
  /// **'تغيير الرقم'**
  String get editNumber;

  /// No description provided for @demoCode.
  ///
  /// In ar, this message translates to:
  /// **'رمز التجربة'**
  String get demoCode;

  /// No description provided for @verifyCta.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد'**
  String get verifyCta;

  /// No description provided for @wrongCode.
  ///
  /// In ar, this message translates to:
  /// **'الرمز غير صحيح.'**
  String get wrongCode;

  /// No description provided for @resendIn.
  ///
  /// In ar, this message translates to:
  /// **'إعادة الإرسال بعد {seconds} ث'**
  String resendIn(String seconds);

  /// No description provided for @resend.
  ///
  /// In ar, this message translates to:
  /// **'إعادة الإرسال'**
  String get resend;

  /// No description provided for @haveAccount.
  ///
  /// In ar, this message translates to:
  /// **'عندك حساب؟'**
  String get haveAccount;

  /// No description provided for @noAccount.
  ///
  /// In ar, this message translates to:
  /// **'أول مرة في نمط؟'**
  String get noAccount;

  /// No description provided for @goLogin.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول'**
  String get goLogin;

  /// No description provided for @goSignup.
  ///
  /// In ar, this message translates to:
  /// **'سوِّ حساب'**
  String get goSignup;

  /// No description provided for @terms.
  ///
  /// In ar, this message translates to:
  /// **'بمتابعتك أنت توافق على الشروط وسياسة الخصوصية.'**
  String get terms;

  /// No description provided for @stepOf.
  ///
  /// In ar, this message translates to:
  /// **'الخطوة {current} من {total}'**
  String stepOf(String current, String total);

  /// No description provided for @qNameTitle.
  ///
  /// In ar, this message translates to:
  /// **'وش نناديك؟'**
  String get qNameTitle;

  /// No description provided for @qNameHint.
  ///
  /// In ar, this message translates to:
  /// **'اسمك'**
  String get qNameHint;

  /// No description provided for @qGoalTitle.
  ///
  /// In ar, this message translates to:
  /// **'وش هدفك مع نمط؟'**
  String get qGoalTitle;

  /// No description provided for @qGoalBody.
  ///
  /// In ar, this message translates to:
  /// **'نرتّب لك التطبيق على أساسه.'**
  String get qGoalBody;

  /// No description provided for @goalLose.
  ///
  /// In ar, this message translates to:
  /// **'أبي أخفف وزني'**
  String get goalLose;

  /// No description provided for @goalActive.
  ///
  /// In ar, this message translates to:
  /// **'أبي أكون أكثر نشاطاً'**
  String get goalActive;

  /// No description provided for @goalMuscle.
  ///
  /// In ar, this message translates to:
  /// **'أبي أزيد الكتلة العضلية'**
  String get goalMuscle;

  /// No description provided for @goalStart.
  ///
  /// In ar, this message translates to:
  /// **'أبي أبدأ حياة صحية'**
  String get goalStart;

  /// No description provided for @goalMaintain.
  ///
  /// In ar, this message translates to:
  /// **'أبي أحافظ على نمطي'**
  String get goalMaintain;

  /// No description provided for @qActivityTitle.
  ///
  /// In ar, this message translates to:
  /// **'كيف نشاطك حالياً؟'**
  String get qActivityTitle;

  /// No description provided for @activityLow.
  ///
  /// In ar, this message translates to:
  /// **'قليل — أغلب يومي جالس'**
  String get activityLow;

  /// No description provided for @activityModerate.
  ///
  /// In ar, this message translates to:
  /// **'متوسط — أتحرك أحياناً'**
  String get activityModerate;

  /// No description provided for @activityActive.
  ///
  /// In ar, this message translates to:
  /// **'نشِط — أتمرن بانتظام'**
  String get activityActive;

  /// No description provided for @activityVery.
  ///
  /// In ar, this message translates to:
  /// **'عالي — تمرين شبه يومي'**
  String get activityVery;

  /// No description provided for @qCityTitle.
  ///
  /// In ar, this message translates to:
  /// **'وين أنت؟'**
  String get qCityTitle;

  /// No description provided for @qCityBody.
  ///
  /// In ar, this message translates to:
  /// **'نعرض لك الأقرب منك.'**
  String get qCityBody;

  /// No description provided for @cityMuscat.
  ///
  /// In ar, this message translates to:
  /// **'مسقط'**
  String get cityMuscat;

  /// No description provided for @citySohar.
  ///
  /// In ar, this message translates to:
  /// **'صحار'**
  String get citySohar;

  /// No description provided for @citySalalah.
  ///
  /// In ar, this message translates to:
  /// **'صلالة'**
  String get citySalalah;

  /// No description provided for @cityNizwa.
  ///
  /// In ar, this message translates to:
  /// **'نزوى'**
  String get cityNizwa;

  /// No description provided for @qInterestsTitle.
  ///
  /// In ar, this message translates to:
  /// **'وش يهمك؟'**
  String get qInterestsTitle;

  /// No description provided for @qInterestsBody.
  ///
  /// In ar, this message translates to:
  /// **'اختر ما شئت.'**
  String get qInterestsBody;

  /// No description provided for @finishSetup.
  ///
  /// In ar, this message translates to:
  /// **'يلا نبدأ'**
  String get finishSetup;

  /// No description provided for @skipStep.
  ///
  /// In ar, this message translates to:
  /// **'تخطٍ'**
  String get skipStep;

  /// No description provided for @nextStep.
  ///
  /// In ar, this message translates to:
  /// **'التالي'**
  String get nextStep;
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
