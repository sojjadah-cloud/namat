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
  /// **'خطوتك القادمة'**
  String get nextStep;

  /// No description provided for @km.
  ///
  /// In ar, this message translates to:
  /// **'كم'**
  String get km;

  /// No description provided for @minutesShort.
  ///
  /// In ar, this message translates to:
  /// **'{count} دقيقة'**
  String minutesShort(String count);

  /// No description provided for @fromPrice.
  ///
  /// In ar, this message translates to:
  /// **'يبدأ من {price} {currency}'**
  String fromPrice(String price, String currency);

  /// No description provided for @ratingWithCount.
  ///
  /// In ar, this message translates to:
  /// **'{rating} · {count} تقييم'**
  String ratingWithCount(String rating, String count);

  /// No description provided for @partnerMenu.
  ///
  /// In ar, this message translates to:
  /// **'المتوفر'**
  String get partnerMenu;

  /// No description provided for @firstPartyNote.
  ///
  /// In ar, this message translates to:
  /// **'خدمة من نمط'**
  String get firstPartyNote;

  /// No description provided for @perServing.
  ///
  /// In ar, this message translates to:
  /// **'لكل حصة'**
  String get perServing;

  /// No description provided for @calories.
  ///
  /// In ar, this message translates to:
  /// **'سعرة'**
  String get calories;

  /// No description provided for @protein.
  ///
  /// In ar, this message translates to:
  /// **'بروتين'**
  String get protein;

  /// No description provided for @carbs.
  ///
  /// In ar, this message translates to:
  /// **'كربوهيدرات'**
  String get carbs;

  /// No description provided for @fat.
  ///
  /// In ar, this message translates to:
  /// **'دهون'**
  String get fat;

  /// No description provided for @gramsShort.
  ///
  /// In ar, this message translates to:
  /// **'{value} غ'**
  String gramsShort(String value);

  /// No description provided for @nutritionUnknown.
  ///
  /// In ar, this message translates to:
  /// **'لم يزوّدنا الشريك بالقيم الغذائية'**
  String get nutritionUnknown;

  /// No description provided for @addToCart.
  ///
  /// In ar, this message translates to:
  /// **'أضف إلى السلة'**
  String get addToCart;

  /// No description provided for @addedToCart.
  ///
  /// In ar, this message translates to:
  /// **'أُضيف إلى السلة'**
  String get addedToCart;

  /// No description provided for @viewCart.
  ///
  /// In ar, this message translates to:
  /// **'عرض السلة'**
  String get viewCart;

  /// No description provided for @quantity.
  ///
  /// In ar, this message translates to:
  /// **'الكمية'**
  String get quantity;

  /// No description provided for @checkoutTitle.
  ///
  /// In ar, this message translates to:
  /// **'إتمام الطلب'**
  String get checkoutTitle;

  /// No description provided for @howToReceive.
  ///
  /// In ar, this message translates to:
  /// **'كيف تستلمه؟'**
  String get howToReceive;

  /// No description provided for @fulfilDelivery.
  ///
  /// In ar, this message translates to:
  /// **'توصيل'**
  String get fulfilDelivery;

  /// No description provided for @fulfilPickup.
  ///
  /// In ar, this message translates to:
  /// **'استلام من المتجر'**
  String get fulfilPickup;

  /// No description provided for @fulfilAtPartner.
  ///
  /// In ar, this message translates to:
  /// **'الحضور إلى المكان'**
  String get fulfilAtPartner;

  /// No description provided for @fulfilOnline.
  ///
  /// In ar, this message translates to:
  /// **'عن بُعد'**
  String get fulfilOnline;

  /// No description provided for @deliveryAddress.
  ///
  /// In ar, this message translates to:
  /// **'عنوان التوصيل'**
  String get deliveryAddress;

  /// No description provided for @addressHint.
  ///
  /// In ar, this message translates to:
  /// **'المبنى، الشارع، الولاية'**
  String get addressHint;

  /// No description provided for @addressRequired.
  ///
  /// In ar, this message translates to:
  /// **'نحتاج العنوان قبل التوصيل'**
  String get addressRequired;

  /// No description provided for @chooseTime.
  ///
  /// In ar, this message translates to:
  /// **'اختر الوقت'**
  String get chooseTime;

  /// No description provided for @payWith.
  ///
  /// In ar, this message translates to:
  /// **'طريقة الدفع'**
  String get payWith;

  /// No description provided for @payCard.
  ///
  /// In ar, this message translates to:
  /// **'بطاقة'**
  String get payCard;

  /// No description provided for @payApplePay.
  ///
  /// In ar, this message translates to:
  /// **'Apple Pay'**
  String get payApplePay;

  /// No description provided for @payCash.
  ///
  /// In ar, this message translates to:
  /// **'نقداً عند الاستلام'**
  String get payCash;

  /// No description provided for @payAllowance.
  ///
  /// In ar, this message translates to:
  /// **'من رصيد باقتك'**
  String get payAllowance;

  /// No description provided for @nothingDue.
  ///
  /// In ar, this message translates to:
  /// **'لا مبلغ مستحق — باقتك تغطي الطلب بالكامل'**
  String get nothingDue;

  /// No description provided for @demoPayment.
  ///
  /// In ar, this message translates to:
  /// **'الدفع غير مفعّل بعد. لن يُخصم أي مبلغ.'**
  String get demoPayment;

  /// No description provided for @orderSummary.
  ///
  /// In ar, this message translates to:
  /// **'ملخّص الطلب'**
  String get orderSummary;

  /// No description provided for @payNow.
  ///
  /// In ar, this message translates to:
  /// **'ادفع {amount} {currency}'**
  String payNow(String amount, String currency);

  /// No description provided for @confirmOrder.
  ///
  /// In ar, this message translates to:
  /// **'أكّد الطلب'**
  String get confirmOrder;

  /// No description provided for @orderReference.
  ///
  /// In ar, this message translates to:
  /// **'رقم الطلب'**
  String get orderReference;

  /// No description provided for @rateTitle.
  ///
  /// In ar, this message translates to:
  /// **'كيف كانت التجربة؟'**
  String get rateTitle;

  /// No description provided for @rateBody.
  ///
  /// In ar, this message translates to:
  /// **'تقييمك يظهر للشريك وللأعضاء الآخرين'**
  String get rateBody;

  /// No description provided for @rateOrderLine.
  ///
  /// In ar, this message translates to:
  /// **'{title} · من {partner}'**
  String rateOrderLine(String title, String partner);

  /// No description provided for @rateSubmit.
  ///
  /// In ar, this message translates to:
  /// **'أرسل التقييم'**
  String get rateSubmit;

  /// No description provided for @rateLater.
  ///
  /// In ar, this message translates to:
  /// **'لاحقاً'**
  String get rateLater;

  /// No description provided for @rateThanks.
  ///
  /// In ar, this message translates to:
  /// **'شكراً لك'**
  String get rateThanks;

  /// No description provided for @rateThanksBody.
  ///
  /// In ar, this message translates to:
  /// **'وصل تقييمك، ويساعد غيرك على الاختيار'**
  String get rateThanksBody;

  /// No description provided for @rateThisOrder.
  ///
  /// In ar, this message translates to:
  /// **'قيّم هذا الطلب'**
  String get rateThisOrder;

  /// No description provided for @yourRating.
  ///
  /// In ar, this message translates to:
  /// **'تقييمك'**
  String get yourRating;

  /// No description provided for @star1.
  ///
  /// In ar, this message translates to:
  /// **'سيئة'**
  String get star1;

  /// No description provided for @star2.
  ///
  /// In ar, this message translates to:
  /// **'مقبولة'**
  String get star2;

  /// No description provided for @star3.
  ///
  /// In ar, this message translates to:
  /// **'جيدة'**
  String get star3;

  /// No description provided for @star4.
  ///
  /// In ar, this message translates to:
  /// **'ممتازة'**
  String get star4;

  /// No description provided for @star5.
  ///
  /// In ar, this message translates to:
  /// **'رائعة'**
  String get star5;

  /// No description provided for @rateNoteHint.
  ///
  /// In ar, this message translates to:
  /// **'أضف ملاحظة (اختياري)'**
  String get rateNoteHint;

  /// No description provided for @rateWhatWorked.
  ///
  /// In ar, this message translates to:
  /// **'وش اللي عجبك؟'**
  String get rateWhatWorked;

  /// No description provided for @tagTaste.
  ///
  /// In ar, this message translates to:
  /// **'الطعم'**
  String get tagTaste;

  /// No description provided for @tagPortion.
  ///
  /// In ar, this message translates to:
  /// **'الكمية'**
  String get tagPortion;

  /// No description provided for @tagOnTime.
  ///
  /// In ar, this message translates to:
  /// **'الالتزام بالوقت'**
  String get tagOnTime;

  /// No description provided for @tagStaff.
  ///
  /// In ar, this message translates to:
  /// **'التعامل'**
  String get tagStaff;

  /// No description provided for @tagCleanliness.
  ///
  /// In ar, this message translates to:
  /// **'النظافة'**
  String get tagCleanliness;

  /// No description provided for @tagValue.
  ///
  /// In ar, this message translates to:
  /// **'السعر مقابل القيمة'**
  String get tagValue;

  /// No description provided for @itemsCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} عنصر'**
  String itemsCount(String count);

  /// No description provided for @andMore.
  ///
  /// In ar, this message translates to:
  /// **'و{count} غيره'**
  String andMore(String count);

  /// No description provided for @noOrdersYet.
  ///
  /// In ar, this message translates to:
  /// **'ما عندك طلبات بعد'**
  String get noOrdersYet;

  /// No description provided for @noOrdersYetBody.
  ///
  /// In ar, this message translates to:
  /// **'أول طلب يبدأ من قسم استخدم نمط'**
  String get noOrdersYetBody;

  /// No description provided for @recentOrders.
  ///
  /// In ar, this message translates to:
  /// **'طلباتك'**
  String get recentOrders;

  /// No description provided for @noResults.
  ///
  /// In ar, this message translates to:
  /// **'ما لقينا نتائج'**
  String get noResults;

  /// No description provided for @noResultsBody.
  ///
  /// In ar, this message translates to:
  /// **'جرّب كلمة أقصر، أو شِل الفلاتر'**
  String get noResultsBody;

  /// No description provided for @whatsIncluded.
  ///
  /// In ar, this message translates to:
  /// **'وش يشمل'**
  String get whatsIncluded;

  /// No description provided for @serviceLevel.
  ///
  /// In ar, this message translates to:
  /// **'المستوى'**
  String get serviceLevel;

  /// No description provided for @levelAny.
  ///
  /// In ar, this message translates to:
  /// **'لكل المستويات'**
  String get levelAny;

  /// No description provided for @levelBeginner.
  ///
  /// In ar, this message translates to:
  /// **'مبتدئ'**
  String get levelBeginner;

  /// No description provided for @levelIntermediate.
  ///
  /// In ar, this message translates to:
  /// **'متوسط'**
  String get levelIntermediate;

  /// No description provided for @levelAdvanced.
  ///
  /// In ar, this message translates to:
  /// **'متقدم'**
  String get levelAdvanced;

  /// No description provided for @serviceFormat.
  ///
  /// In ar, this message translates to:
  /// **'طريقة الحضور'**
  String get serviceFormat;

  /// No description provided for @formatInPerson.
  ///
  /// In ar, this message translates to:
  /// **'حضور في المكان'**
  String get formatInPerson;

  /// No description provided for @formatRemote.
  ///
  /// In ar, this message translates to:
  /// **'عن بُعد'**
  String get formatRemote;

  /// No description provided for @formatEither.
  ///
  /// In ar, this message translates to:
  /// **'حضوراً أو عن بُعد'**
  String get formatEither;

  /// No description provided for @cancellationTitle.
  ///
  /// In ar, this message translates to:
  /// **'الإلغاء'**
  String get cancellationTitle;

  /// No description provided for @cancelFree24h.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء مجاني قبل ٢٤ ساعة'**
  String get cancelFree24h;

  /// No description provided for @cancelFree2h.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء مجاني قبل ساعتين'**
  String get cancelFree2h;

  /// No description provided for @cancelNonRefundable.
  ///
  /// In ar, this message translates to:
  /// **'غير قابل للاسترداد'**
  String get cancelNonRefundable;

  /// No description provided for @cancelUnknown.
  ///
  /// In ar, this message translates to:
  /// **'ما زوّدنا الشريك بسياسة الإلغاء'**
  String get cancelUnknown;

  /// No description provided for @spotsLeft.
  ///
  /// In ar, this message translates to:
  /// **'باقي {count} أماكن'**
  String spotsLeft(String count);

  /// No description provided for @lastSpots.
  ///
  /// In ar, this message translates to:
  /// **'باقي {count} فقط'**
  String lastSpots(String count);

  /// No description provided for @soldOut.
  ///
  /// In ar, this message translates to:
  /// **'مكتمل'**
  String get soldOut;

  /// No description provided for @outOfStock.
  ///
  /// In ar, this message translates to:
  /// **'غير متوفر حالياً'**
  String get outOfStock;

  /// No description provided for @soldOutBody.
  ///
  /// In ar, this message translates to:
  /// **'ما فيه أماكن في هذا الموعد. جرّب موعداً ثانياً أو حصة غيرها.'**
  String get soldOutBody;

  /// No description provided for @nextTimes.
  ///
  /// In ar, this message translates to:
  /// **'المواعيد القادمة'**
  String get nextTimes;

  /// No description provided for @noFixedTimes.
  ///
  /// In ar, this message translates to:
  /// **'بدون موعد ثابت — تختار الوقت عند الطلب'**
  String get noFixedTimes;

  /// No description provided for @openNow.
  ///
  /// In ar, this message translates to:
  /// **'مفتوح الآن'**
  String get openNow;

  /// No description provided for @closedNow.
  ///
  /// In ar, this message translates to:
  /// **'مغلق الآن'**
  String get closedNow;

  /// No description provided for @hoursLine.
  ///
  /// In ar, this message translates to:
  /// **'{from} — {to}'**
  String hoursLine(String from, String to);

  /// No description provided for @hoursUnknown.
  ///
  /// In ar, this message translates to:
  /// **'ما زوّدنا الشريك بأوقات العمل'**
  String get hoursUnknown;

  /// No description provided for @allergensUnknown.
  ///
  /// In ar, this message translates to:
  /// **'معلومات الحساسية غير متوفرة — راجع الشريك قبل الطلب'**
  String get allergensUnknown;

  /// No description provided for @everythingUnavailable.
  ///
  /// In ar, this message translates to:
  /// **'كل الخدمات هنا مكتملة حالياً'**
  String get everythingUnavailable;

  /// No description provided for @serviceCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} خدمات'**
  String serviceCount(String count);

  /// No description provided for @navExplore.
  ///
  /// In ar, this message translates to:
  /// **'استكشف'**
  String get navExplore;

  /// No description provided for @navBookings.
  ///
  /// In ar, this message translates to:
  /// **'حجوزاتي'**
  String get navBookings;

  /// No description provided for @searchEverything.
  ///
  /// In ar, this message translates to:
  /// **'ابحث في نمط'**
  String get searchEverything;

  /// No description provided for @searchHint.
  ///
  /// In ar, this message translates to:
  /// **'مطعم، وجبة، ناد، مختص، منتج'**
  String get searchHint;

  /// No description provided for @searchPartnersGroup.
  ///
  /// In ar, this message translates to:
  /// **'الأماكن'**
  String get searchPartnersGroup;

  /// No description provided for @searchServicesGroup.
  ///
  /// In ar, this message translates to:
  /// **'الخدمات'**
  String get searchServicesGroup;

  /// No description provided for @searchNothing.
  ///
  /// In ar, this message translates to:
  /// **'ما لقينا شي'**
  String get searchNothing;

  /// No description provided for @searchNothingBody.
  ///
  /// In ar, this message translates to:
  /// **'جرّب كلمة أقصر أو اسم مختلف'**
  String get searchNothingBody;

  /// No description provided for @searchStart.
  ///
  /// In ar, this message translates to:
  /// **'اكتب وش تدور عليه'**
  String get searchStart;

  /// No description provided for @searchStartBody.
  ///
  /// In ar, this message translates to:
  /// **'نبحث في المطاعم والأندية والمختصين والمنتجات كلها'**
  String get searchStartBody;

  /// No description provided for @favoritesTitle.
  ///
  /// In ar, this message translates to:
  /// **'المحفوظات'**
  String get favoritesTitle;

  /// No description provided for @favoritesEmpty.
  ///
  /// In ar, this message translates to:
  /// **'ما حفظت شي بعد'**
  String get favoritesEmpty;

  /// No description provided for @favoritesEmptyBody.
  ///
  /// In ar, this message translates to:
  /// **'اضغط القلب على أي مكان أو خدمة عشان تلقاها هنا'**
  String get favoritesEmptyBody;

  /// No description provided for @savedPartners.
  ///
  /// In ar, this message translates to:
  /// **'أماكن'**
  String get savedPartners;

  /// No description provided for @savedServices.
  ///
  /// In ar, this message translates to:
  /// **'خدمات'**
  String get savedServices;

  /// No description provided for @saved.
  ///
  /// In ar, this message translates to:
  /// **'محفوظ'**
  String get saved;

  /// No description provided for @removedFromSaved.
  ///
  /// In ar, this message translates to:
  /// **'شيلناه من المحفوظات'**
  String get removedFromSaved;

  /// No description provided for @pointsTitle.
  ///
  /// In ar, this message translates to:
  /// **'نقاط نمط'**
  String get pointsTitle;

  /// No description provided for @pointsBalance.
  ///
  /// In ar, this message translates to:
  /// **'رصيدك'**
  String get pointsBalance;

  /// No description provided for @pointsHow.
  ///
  /// In ar, this message translates to:
  /// **'كيف تجمع نقاط'**
  String get pointsHow;

  /// No description provided for @pointsEarnOrder.
  ///
  /// In ar, this message translates to:
  /// **'طلب أو حجز مكتمل'**
  String get pointsEarnOrder;

  /// No description provided for @pointsEarnReview.
  ///
  /// In ar, this message translates to:
  /// **'تقييم بعد الخدمة'**
  String get pointsEarnReview;

  /// No description provided for @pointsEarnChallenge.
  ///
  /// In ar, this message translates to:
  /// **'إكمال تحدٍ'**
  String get pointsEarnChallenge;

  /// No description provided for @pointsEarnStreak.
  ///
  /// In ar, this message translates to:
  /// **'يوم جديد بدون انقطاع'**
  String get pointsEarnStreak;

  /// No description provided for @pointsEarnNewPartner.
  ///
  /// In ar, this message translates to:
  /// **'أول مرة عند شريك'**
  String get pointsEarnNewPartner;

  /// No description provided for @pointsRedeemedLabel.
  ///
  /// In ar, this message translates to:
  /// **'استبدال'**
  String get pointsRedeemedLabel;

  /// No description provided for @pointsEmpty.
  ///
  /// In ar, this message translates to:
  /// **'ما جمعت نقاط بعد'**
  String get pointsEmpty;

  /// No description provided for @pointsEmptyBody.
  ///
  /// In ar, this message translates to:
  /// **'أول طلب يبدأ الرصيد'**
  String get pointsEmptyBody;

  /// No description provided for @rewardsTitle.
  ///
  /// In ar, this message translates to:
  /// **'استبدل نقاطك'**
  String get rewardsTitle;

  /// No description provided for @redeem.
  ///
  /// In ar, this message translates to:
  /// **'استبدل'**
  String get redeem;

  /// No description provided for @pointsCost.
  ///
  /// In ar, this message translates to:
  /// **'{cost} نقطة'**
  String pointsCost(String cost);

  /// No description provided for @pointsShort.
  ///
  /// In ar, this message translates to:
  /// **'باقي {count} نقطة'**
  String pointsShort(String count);

  /// No description provided for @redeemed.
  ///
  /// In ar, this message translates to:
  /// **'تم الاستبدال'**
  String get redeemed;

  /// No description provided for @pointsEarned.
  ///
  /// In ar, this message translates to:
  /// **'+{count} نقطة'**
  String pointsEarned(String count);

  /// No description provided for @signInToOrder.
  ///
  /// In ar, this message translates to:
  /// **'سجّل دخولك عشان تكمل الطلب'**
  String get signInToOrder;

  /// No description provided for @signInToBook.
  ///
  /// In ar, this message translates to:
  /// **'سجّل دخولك عشان تحجز'**
  String get signInToBook;

  /// No description provided for @signInToJoin.
  ///
  /// In ar, this message translates to:
  /// **'سجّل دخولك عشان تنضم'**
  String get signInToJoin;

  /// No description provided for @signInToSave.
  ///
  /// In ar, this message translates to:
  /// **'سجّل دخولك عشان تحفظ'**
  String get signInToSave;

  /// No description provided for @signInToChallenge.
  ///
  /// In ar, this message translates to:
  /// **'سجّل دخولك عشان تتحدى'**
  String get signInToChallenge;

  /// No description provided for @signInBody.
  ///
  /// In ar, this message translates to:
  /// **'دقيقة وحدة برقم جوالك، وتكمل من نفس المكان'**
  String get signInBody;

  /// No description provided for @keepBrowsing.
  ///
  /// In ar, this message translates to:
  /// **'أكمل التصفح'**
  String get keepBrowsing;

  /// No description provided for @cityTitle.
  ///
  /// In ar, this message translates to:
  /// **'مدينتك'**
  String get cityTitle;

  /// No description provided for @changeCity.
  ///
  /// In ar, this message translates to:
  /// **'غيّر المدينة'**
  String get changeCity;

  /// No description provided for @citySur.
  ///
  /// In ar, this message translates to:
  /// **'صور'**
  String get citySur;

  /// No description provided for @cityBarka.
  ///
  /// In ar, this message translates to:
  /// **'بركاء'**
  String get cityBarka;

  /// No description provided for @noPartnersInCity.
  ///
  /// In ar, this message translates to:
  /// **'ما وصلنا {city} في هذا المجال بعد'**
  String noPartnersInCity(String city);

  /// No description provided for @noPartnersInCityBody.
  ///
  /// In ar, this message translates to:
  /// **'نشتغل على إضافة شركاء. تقدر تشوف المتاح في مدينة ثانية.'**
  String get noPartnersInCityBody;

  /// No description provided for @showCity.
  ///
  /// In ar, this message translates to:
  /// **'اعرض {city}'**
  String showCity(String city);

  /// No description provided for @inCity.
  ///
  /// In ar, this message translates to:
  /// **'في {city}'**
  String inCity(String city);

  /// No description provided for @otherCity.
  ///
  /// In ar, this message translates to:
  /// **'مدينة ثانية'**
  String get otherCity;

  /// No description provided for @thisWeek.
  ///
  /// In ar, this message translates to:
  /// **'رحلتك هذا الأسبوع'**
  String get thisWeek;

  /// No description provided for @viewJourney.
  ///
  /// In ar, this message translates to:
  /// **'عرض رحلتي'**
  String get viewJourney;

  /// No description provided for @weekProgress.
  ///
  /// In ar, this message translates to:
  /// **'{percent}% من أهداف الأسبوع'**
  String weekProgress(String percent);

  /// No description provided for @recommendedForYou.
  ///
  /// In ar, this message translates to:
  /// **'مناسب لهدفك'**
  String get recommendedForYou;

  /// No description provided for @nearYou.
  ///
  /// In ar, this message translates to:
  /// **'قريب منك'**
  String get nearYou;

  /// No description provided for @namatPicks.
  ///
  /// In ar, this message translates to:
  /// **'اختيارات نمط لك'**
  String get namatPicks;

  /// No description provided for @bundlesPreview.
  ///
  /// In ar, this message translates to:
  /// **'باقات نمط'**
  String get bundlesPreview;

  /// No description provided for @seeAll.
  ///
  /// In ar, this message translates to:
  /// **'الكل'**
  String get seeAll;

  /// No description provided for @noNextStep.
  ///
  /// In ar, this message translates to:
  /// **'ما عندك شي مجدول اليوم'**
  String get noNextStep;

  /// No description provided for @noNextStepBody.
  ///
  /// In ar, this message translates to:
  /// **'اختر خدمة وتلقاها هنا'**
  String get noNextStepBody;

  /// No description provided for @loadingTitle.
  ///
  /// In ar, this message translates to:
  /// **'لحظة…'**
  String get loadingTitle;

  /// No description provided for @offlineTitle.
  ///
  /// In ar, this message translates to:
  /// **'ما فيه اتصال'**
  String get offlineTitle;

  /// No description provided for @offlineBody.
  ///
  /// In ar, this message translates to:
  /// **'تأكد من الإنترنت وجرّب مرة ثانية'**
  String get offlineBody;

  /// No description provided for @paymentFailed.
  ///
  /// In ar, this message translates to:
  /// **'ما تمت العملية'**
  String get paymentFailed;

  /// No description provided for @paymentFailedBody.
  ///
  /// In ar, this message translates to:
  /// **'ما انخصم أي مبلغ. جرّب طريقة دفع ثانية.'**
  String get paymentFailedBody;

  /// No description provided for @unavailableTitle.
  ///
  /// In ar, this message translates to:
  /// **'الخدمة ما عادت متاحة'**
  String get unavailableTitle;

  /// No description provided for @unavailableBody.
  ///
  /// In ar, this message translates to:
  /// **'انحجزت قبل شوي. اختر موعداً أو خدمة ثانية.'**
  String get unavailableBody;
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
