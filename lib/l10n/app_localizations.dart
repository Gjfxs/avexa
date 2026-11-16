import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_pl.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
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
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('ja'),
    Locale('pl'),
    Locale('pt'),
    Locale('ru'),
    Locale('zh'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Avexa'**
  String get appName;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @chooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose language'**
  String get chooseLanguage;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @general.
  ///
  /// In en, this message translates to:
  /// **'GENERAL'**
  String get general;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @notificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage alerts and notification preferences.'**
  String get notificationsSubtitle;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @languageSection.
  ///
  /// In en, this message translates to:
  /// **'LANGUAGE'**
  String get languageSection;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get lightMode;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get darkMode;

  /// No description provided for @systemDefault.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get systemDefault;

  /// No description provided for @alerts.
  ///
  /// In en, this message translates to:
  /// **'ALERTS'**
  String get alerts;

  /// No description provided for @pushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get pushNotifications;

  /// No description provided for @pushNotificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Receive important notifications from Avexa.'**
  String get pushNotificationsSubtitle;

  /// No description provided for @freeSignals.
  ///
  /// In en, this message translates to:
  /// **'FREE Signals'**
  String get freeSignals;

  /// No description provided for @freeSignalsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get notified when a new FREE signal is generated.'**
  String get freeSignalsSubtitle;

  /// No description provided for @proSignals.
  ///
  /// In en, this message translates to:
  /// **'PRO Signals'**
  String get proSignals;

  /// No description provided for @proSignalsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get notified when a new PRO signal is generated.'**
  String get proSignalsSubtitle;

  /// No description provided for @takeProfitHits.
  ///
  /// In en, this message translates to:
  /// **'Take Profit Hits'**
  String get takeProfitHits;

  /// No description provided for @takeProfitHitsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get notified when TP1, TP2 or TP3 is reached.'**
  String get takeProfitHitsSubtitle;

  /// No description provided for @experience.
  ///
  /// In en, this message translates to:
  /// **'EXPERIENCE'**
  String get experience;

  /// No description provided for @hapticFeedback.
  ///
  /// In en, this message translates to:
  /// **'Haptic Feedback'**
  String get hapticFeedback;

  /// No description provided for @hapticFeedbackSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use vibration for important alerts and actions.'**
  String get hapticFeedbackSubtitle;

  /// No description provided for @savingPreferences.
  ///
  /// In en, this message translates to:
  /// **'Saving preferences...'**
  String get savingPreferences;

  /// No description provided for @notificationPreferences.
  ///
  /// In en, this message translates to:
  /// **'Notification preferences'**
  String get notificationPreferences;

  /// No description provided for @themeSection.
  ///
  /// In en, this message translates to:
  /// **'THEME'**
  String get themeSection;

  /// No description provided for @darkModeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Best for low-light environments.'**
  String get darkModeSubtitle;

  /// No description provided for @lightModeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use a brighter appearance.'**
  String get lightModeSubtitle;

  /// No description provided for @systemDefaultSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Follow your device settings.'**
  String get systemDefaultSubtitle;

  /// No description provided for @appIconSection.
  ///
  /// In en, this message translates to:
  /// **'APP ICON'**
  String get appIconSection;

  /// No description provided for @lightAppIcon.
  ///
  /// In en, this message translates to:
  /// **'Light App Icon'**
  String get lightAppIcon;

  /// No description provided for @useLightAvexaIcon.
  ///
  /// In en, this message translates to:
  /// **'Use the light Avexa icon.'**
  String get useLightAvexaIcon;

  /// No description provided for @useDarkAvexaIcon.
  ///
  /// In en, this message translates to:
  /// **'Use the dark Avexa icon.'**
  String get useDarkAvexaIcon;

  /// No description provided for @contactSupport.
  ///
  /// In en, this message translates to:
  /// **'Contact Support'**
  String get contactSupport;

  /// No description provided for @supportIntroTitle.
  ///
  /// In en, this message translates to:
  /// **'We\'re here to help'**
  String get supportIntroTitle;

  /// No description provided for @supportIntroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tell us what you need help with and our team will get back to you.'**
  String get supportIntroSubtitle;

  /// No description provided for @supportTopicQuestion.
  ///
  /// In en, this message translates to:
  /// **'WHAT CAN WE HELP WITH?'**
  String get supportTopicQuestion;

  /// No description provided for @supportSelectTopic.
  ///
  /// In en, this message translates to:
  /// **'Select a topic'**
  String get supportSelectTopic;

  /// No description provided for @supportTapToChange.
  ///
  /// In en, this message translates to:
  /// **'Tap to change'**
  String get supportTapToChange;

  /// No description provided for @supportYourTopic.
  ///
  /// In en, this message translates to:
  /// **'YOUR TOPIC'**
  String get supportYourTopic;

  /// No description provided for @supportCustomTopicHint.
  ///
  /// In en, this message translates to:
  /// **'What is your question about?'**
  String get supportCustomTopicHint;

  /// No description provided for @supportMessage.
  ///
  /// In en, this message translates to:
  /// **'MESSAGE'**
  String get supportMessage;

  /// No description provided for @supportMessageHint.
  ///
  /// In en, this message translates to:
  /// **'Tell us how we can help...'**
  String get supportMessageHint;

  /// No description provided for @supportSendMessage.
  ///
  /// In en, this message translates to:
  /// **'SEND MESSAGE'**
  String get supportSendMessage;

  /// No description provided for @supportResponseTime.
  ///
  /// In en, this message translates to:
  /// **'We usually respond within 24 hours.'**
  String get supportResponseTime;

  /// No description provided for @supportAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get supportAccount;

  /// No description provided for @supportSubscriptionBilling.
  ///
  /// In en, this message translates to:
  /// **'Subscription & Billing'**
  String get supportSubscriptionBilling;

  /// No description provided for @supportTradingSignals.
  ///
  /// In en, this message translates to:
  /// **'Trading Signals'**
  String get supportTradingSignals;

  /// No description provided for @supportTechnicalIssue.
  ///
  /// In en, this message translates to:
  /// **'Technical Issue'**
  String get supportTechnicalIssue;

  /// No description provided for @supportBugReport.
  ///
  /// In en, this message translates to:
  /// **'Bug Report'**
  String get supportBugReport;

  /// No description provided for @supportFeatureRequest.
  ///
  /// In en, this message translates to:
  /// **'Feature Request'**
  String get supportFeatureRequest;

  /// No description provided for @supportOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get supportOther;

  /// No description provided for @supportMessageSent.
  ///
  /// In en, this message translates to:
  /// **'Message Sent'**
  String get supportMessageSent;

  /// No description provided for @supportSuccessDescription.
  ///
  /// In en, this message translates to:
  /// **'Your message has been sent to the Avexa support team. We will get back to you as soon as possible.'**
  String get supportSuccessDescription;

  /// No description provided for @supportDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get supportDone;

  /// No description provided for @supportLoginRequired.
  ///
  /// In en, this message translates to:
  /// **'You must be logged in to contact support.'**
  String get supportLoginRequired;

  /// No description provided for @supportSelectTopicError.
  ///
  /// In en, this message translates to:
  /// **'Please select a topic.'**
  String get supportSelectTopicError;

  /// No description provided for @supportEnterTopicError.
  ///
  /// In en, this message translates to:
  /// **'Please enter your topic.'**
  String get supportEnterTopicError;

  /// No description provided for @supportEnterMessageError.
  ///
  /// In en, this message translates to:
  /// **'Please enter your message.'**
  String get supportEnterMessageError;

  /// No description provided for @supportMessageMinLengthError.
  ///
  /// In en, this message translates to:
  /// **'Message must contain at least 10 characters.'**
  String get supportMessageMinLengthError;

  /// No description provided for @supportSendError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get supportSendError;

  /// No description provided for @supportSending.
  ///
  /// In en, this message translates to:
  /// **'Sending message...'**
  String get supportSending;

  /// No description provided for @reportBug.
  ///
  /// In en, this message translates to:
  /// **'Report a Bug'**
  String get reportBug;

  /// No description provided for @bugIntroTitle.
  ///
  /// In en, this message translates to:
  /// **'Found a problem?'**
  String get bugIntroTitle;

  /// No description provided for @bugIntroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tell us what went wrong and we will look into it.'**
  String get bugIntroSubtitle;

  /// No description provided for @bugCategorySection.
  ///
  /// In en, this message translates to:
  /// **'CATEGORY'**
  String get bugCategorySection;

  /// No description provided for @bugWhatHappened.
  ///
  /// In en, this message translates to:
  /// **'WHAT HAPPENED?'**
  String get bugWhatHappened;

  /// No description provided for @bugDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Describe the problem, what you were doing and what happened...'**
  String get bugDescriptionHint;

  /// No description provided for @bugSendButton.
  ///
  /// In en, this message translates to:
  /// **'Send Bug Report'**
  String get bugSendButton;

  /// No description provided for @bugFooter.
  ///
  /// In en, this message translates to:
  /// **'Your report will be sent directly to the Avexa support team.'**
  String get bugFooter;

  /// No description provided for @bugPickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Bug Category'**
  String get bugPickerTitle;

  /// No description provided for @bugCategoryApp.
  ///
  /// In en, this message translates to:
  /// **'App Bug'**
  String get bugCategoryApp;

  /// No description provided for @bugCategorySignals.
  ///
  /// In en, this message translates to:
  /// **'Signals'**
  String get bugCategorySignals;

  /// No description provided for @bugCategoryTrading.
  ///
  /// In en, this message translates to:
  /// **'Trading'**
  String get bugCategoryTrading;

  /// No description provided for @bugCategoryAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get bugCategoryAccount;

  /// No description provided for @bugCategorySubscription.
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get bugCategorySubscription;

  /// No description provided for @bugCategoryNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get bugCategoryNotifications;

  /// No description provided for @bugCategoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get bugCategoryOther;

  /// No description provided for @bugPleaseDescribe.
  ///
  /// In en, this message translates to:
  /// **'Please describe the problem.'**
  String get bugPleaseDescribe;

  /// No description provided for @bugLoginRequired.
  ///
  /// In en, this message translates to:
  /// **'You must be logged in to report a bug.'**
  String get bugLoginRequired;

  /// No description provided for @bugSentSuccess.
  ///
  /// In en, this message translates to:
  /// **'Bug report sent successfully.'**
  String get bugSentSuccess;

  /// No description provided for @bugSendFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to send the report. Please try again.'**
  String get bugSendFailed;

  /// No description provided for @bugSending.
  ///
  /// In en, this message translates to:
  /// **'Sending report...'**
  String get bugSending;

  /// No description provided for @helpCenter.
  ///
  /// In en, this message translates to:
  /// **'Help Center'**
  String get helpCenter;

  /// No description provided for @helpMainTitle.
  ///
  /// In en, this message translates to:
  /// **'How can we help?'**
  String get helpMainTitle;

  /// No description provided for @helpMainSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Find answers and learn more about Avexa.'**
  String get helpMainSubtitle;

  /// No description provided for @helpSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search help...'**
  String get helpSearchHint;

  /// No description provided for @helpPopularTopics.
  ///
  /// In en, this message translates to:
  /// **'POPULAR TOPICS'**
  String get helpPopularTopics;

  /// No description provided for @helpSearchResults.
  ///
  /// In en, this message translates to:
  /// **'SEARCH RESULTS'**
  String get helpSearchResults;

  /// No description provided for @helpNeedMore.
  ///
  /// In en, this message translates to:
  /// **'NEED MORE HELP?'**
  String get helpNeedMore;

  /// No description provided for @helpNoResults.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get helpNoResults;

  /// No description provided for @helpTryAnotherSearch.
  ///
  /// In en, this message translates to:
  /// **'Try searching for something else.'**
  String get helpTryAnotherSearch;

  /// No description provided for @helpSupportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We\'re here to help'**
  String get helpSupportSubtitle;

  /// No description provided for @helpFaqTitle.
  ///
  /// In en, this message translates to:
  /// **'Frequently Asked Questions'**
  String get helpFaqTitle;

  /// No description provided for @helpStillNeed.
  ///
  /// In en, this message translates to:
  /// **'Still need help?'**
  String get helpStillNeed;

  /// No description provided for @helpContactPrompt.
  ///
  /// In en, this message translates to:
  /// **'If you cannot find the answer, contact our support team.'**
  String get helpContactPrompt;

  /// No description provided for @helpSignals.
  ///
  /// In en, this message translates to:
  /// **'Signals'**
  String get helpSignals;

  /// No description provided for @helpSignalsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'How Avexa signals work'**
  String get helpSignalsSubtitle;

  /// No description provided for @helpPro.
  ///
  /// In en, this message translates to:
  /// **'Avexa PRO'**
  String get helpPro;

  /// No description provided for @helpProSubtitle.
  ///
  /// In en, this message translates to:
  /// **'PRO features & subscription'**
  String get helpProSubtitle;

  /// No description provided for @helpTrading.
  ///
  /// In en, this message translates to:
  /// **'Trading'**
  String get helpTrading;

  /// No description provided for @helpTradingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Trading, TP, SL & entries'**
  String get helpTradingSubtitle;

  /// No description provided for @helpAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get helpAccount;

  /// No description provided for @helpAccountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Account & profile'**
  String get helpAccountSubtitle;

  /// No description provided for @helpNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get helpNotifications;

  /// No description provided for @helpNotificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Alerts & notifications'**
  String get helpNotificationsSubtitle;

  /// No description provided for @faqSignalsQ1.
  ///
  /// In en, this message translates to:
  /// **'What are Avexa signals?'**
  String get faqSignalsQ1;

  /// No description provided for @faqSignalsA1.
  ///
  /// In en, this message translates to:
  /// **'Avexa signals are trading opportunities generated from market data and analysis. Each signal can include information such as entry price, take profit, stop loss and market direction.'**
  String get faqSignalsA1;

  /// No description provided for @faqSignalsQ2.
  ///
  /// In en, this message translates to:
  /// **'How often are new signals released?'**
  String get faqSignalsQ2;

  /// No description provided for @faqSignalsA2.
  ///
  /// In en, this message translates to:
  /// **'The number of available signals depends on your Avexa plan. Free users have limited access, while PRO users receive access to additional premium signals.'**
  String get faqSignalsA2;

  /// No description provided for @faqSignalsQ3.
  ///
  /// In en, this message translates to:
  /// **'What do Entry, TP and SL mean?'**
  String get faqSignalsQ3;

  /// No description provided for @faqSignalsA3.
  ///
  /// In en, this message translates to:
  /// **'Entry is the suggested price or price range for entering a trade. TP (Take Profit) represents the target where the trade may be closed for profit. SL (Stop Loss) represents the level where the trade may be closed to limit potential losses.'**
  String get faqSignalsA3;

  /// No description provided for @faqSignalsQ4.
  ///
  /// In en, this message translates to:
  /// **'Are Avexa signals guaranteed to be profitable?'**
  String get faqSignalsQ4;

  /// No description provided for @faqSignalsA4.
  ///
  /// In en, this message translates to:
  /// **'No. No trading signal can guarantee a profit. Signals are based on analysis and available market data, but cryptocurrency markets are volatile and every trade carries risk.'**
  String get faqSignalsA4;

  /// No description provided for @faqSignalsQ5.
  ///
  /// In en, this message translates to:
  /// **'Where can I see my available signals?'**
  String get faqSignalsQ5;

  /// No description provided for @faqSignalsA5.
  ///
  /// In en, this message translates to:
  /// **'Your available signals can be found in the Signals section of Avexa. Access and availability depend on your current plan.'**
  String get faqSignalsA5;

  /// No description provided for @faqProQ1.
  ///
  /// In en, this message translates to:
  /// **'What is Avexa PRO?'**
  String get faqProQ1;

  /// No description provided for @faqProA1.
  ///
  /// In en, this message translates to:
  /// **'Avexa PRO is the premium version of Avexa. It provides access to additional trading intelligence, premium signals and advanced features that are not available on the Free plan.'**
  String get faqProA1;

  /// No description provided for @faqProQ2.
  ///
  /// In en, this message translates to:
  /// **'How do I upgrade to PRO?'**
  String get faqProQ2;

  /// No description provided for @faqProA2.
  ///
  /// In en, this message translates to:
  /// **'Open your Subscription screen and select Upgrade to PRO. Follow the payment instructions to complete your subscription.'**
  String get faqProA2;

  /// No description provided for @faqProQ3.
  ///
  /// In en, this message translates to:
  /// **'How do I know if I have PRO?'**
  String get faqProQ3;

  /// No description provided for @faqProA3.
  ///
  /// In en, this message translates to:
  /// **'You can check your current plan in your Profile or Subscription screen. PRO accounts will show an active PRO membership.'**
  String get faqProA3;

  /// No description provided for @faqProQ4.
  ///
  /// In en, this message translates to:
  /// **'Can I cancel my PRO subscription?'**
  String get faqProQ4;

  /// No description provided for @faqProA4.
  ///
  /// In en, this message translates to:
  /// **'Yes. You can manage or cancel your subscription from the Subscription screen. Your access may remain active until the end of your current billing period.'**
  String get faqProA4;

  /// No description provided for @faqProQ5.
  ///
  /// In en, this message translates to:
  /// **'What happens when my PRO subscription expires?'**
  String get faqProQ5;

  /// No description provided for @faqProA5.
  ///
  /// In en, this message translates to:
  /// **'When your PRO access expires, your account returns to the Free plan and premium features become unavailable until PRO is activated again.'**
  String get faqProA5;

  /// No description provided for @faqTradingQ1.
  ///
  /// In en, this message translates to:
  /// **'What is a Take Profit (TP)?'**
  String get faqTradingQ1;

  /// No description provided for @faqTradingA1.
  ///
  /// In en, this message translates to:
  /// **'Take Profit is a predefined target price. When the market reaches that level, a trader may choose to close the position and secure the planned profit.'**
  String get faqTradingA1;

  /// No description provided for @faqTradingQ2.
  ///
  /// In en, this message translates to:
  /// **'What is a Stop Loss (SL)?'**
  String get faqTradingQ2;

  /// No description provided for @faqTradingA2.
  ///
  /// In en, this message translates to:
  /// **'Stop Loss is a predefined level used to limit potential losses if the market moves against the trade.'**
  String get faqTradingA2;

  /// No description provided for @faqTradingQ3.
  ///
  /// In en, this message translates to:
  /// **'What is an Entry?'**
  String get faqTradingQ3;

  /// No description provided for @faqTradingA3.
  ///
  /// In en, this message translates to:
  /// **'Entry is the price or price range where the signal suggests considering opening a position.'**
  String get faqTradingA3;

  /// No description provided for @faqTradingQ4.
  ///
  /// In en, this message translates to:
  /// **'Why can my result differ from the signal?'**
  String get faqTradingQ4;

  /// No description provided for @faqTradingA4.
  ///
  /// In en, this message translates to:
  /// **'Market prices can change very quickly. Slippage, execution speed, liquidity and fees can cause your actual entry or exit price to differ from the price shown in a signal.'**
  String get faqTradingA4;

  /// No description provided for @faqTradingQ5.
  ///
  /// In en, this message translates to:
  /// **'Does Avexa execute trades automatically?'**
  String get faqTradingQ5;

  /// No description provided for @faqTradingA5.
  ///
  /// In en, this message translates to:
  /// **'Avexa signals are designed to provide trading intelligence. Unless a specific automated trading feature is enabled and supported, you remain responsible for executing and managing your trades.'**
  String get faqTradingA5;

  /// No description provided for @faqAccountQ1.
  ///
  /// In en, this message translates to:
  /// **'How do I change my username?'**
  String get faqAccountQ1;

  /// No description provided for @faqAccountA1.
  ///
  /// In en, this message translates to:
  /// **'Open Profile and select Personal Information. From there you can update the information associated with your profile.'**
  String get faqAccountA1;

  /// No description provided for @faqAccountQ2.
  ///
  /// In en, this message translates to:
  /// **'How do I change my password?'**
  String get faqAccountQ2;

  /// No description provided for @faqAccountA2.
  ///
  /// In en, this message translates to:
  /// **'Open Profile → Security and use the available password management options.'**
  String get faqAccountA2;

  /// No description provided for @faqAccountQ3.
  ///
  /// In en, this message translates to:
  /// **'Can I change my email address?'**
  String get faqAccountQ3;

  /// No description provided for @faqAccountA3.
  ///
  /// In en, this message translates to:
  /// **'Email account changes should be handled through the account security settings when the option is available. Additional verification may be required.'**
  String get faqAccountA3;

  /// No description provided for @faqAccountQ4.
  ///
  /// In en, this message translates to:
  /// **'How do I log out?'**
  String get faqAccountQ4;

  /// No description provided for @faqAccountA4.
  ///
  /// In en, this message translates to:
  /// **'Open your Profile and scroll to the bottom of the screen. Select LOG OUT to end your current session.'**
  String get faqAccountA4;

  /// No description provided for @faqAccountQ5.
  ///
  /// In en, this message translates to:
  /// **'Can I delete my account?'**
  String get faqAccountQ5;

  /// No description provided for @faqAccountA5.
  ///
  /// In en, this message translates to:
  /// **'Account deletion can be requested through the account or security section. Make sure you understand that deleting an account may permanently remove associated data.'**
  String get faqAccountA5;

  /// No description provided for @faqNotificationsQ1.
  ///
  /// In en, this message translates to:
  /// **'How do I enable notifications?'**
  String get faqNotificationsQ1;

  /// No description provided for @faqNotificationsA1.
  ///
  /// In en, this message translates to:
  /// **'Open More → App Settings → Notifications. From there you can control general notifications, signal alerts and haptic feedback.'**
  String get faqNotificationsA1;

  /// No description provided for @faqNotificationsQ2.
  ///
  /// In en, this message translates to:
  /// **'What are Signal Alerts?'**
  String get faqNotificationsQ2;

  /// No description provided for @faqNotificationsA2.
  ///
  /// In en, this message translates to:
  /// **'Signal Alerts notify you when a new relevant trading signal becomes available.'**
  String get faqNotificationsA2;

  /// No description provided for @faqNotificationsQ3.
  ///
  /// In en, this message translates to:
  /// **'Why am I not receiving notifications?'**
  String get faqNotificationsQ3;

  /// No description provided for @faqNotificationsA3.
  ///
  /// In en, this message translates to:
  /// **'First check that notifications are enabled in Avexa Settings and in your device settings. Also make sure Signal Alerts are enabled if you want to receive signal notifications.'**
  String get faqNotificationsA3;

  /// No description provided for @faqNotificationsQ4.
  ///
  /// In en, this message translates to:
  /// **'What is Haptic Feedback?'**
  String get faqNotificationsQ4;

  /// No description provided for @faqNotificationsA4.
  ///
  /// In en, this message translates to:
  /// **'Haptic Feedback uses your device vibration to provide additional feedback for supported interactions and alerts.'**
  String get faqNotificationsA4;

  /// No description provided for @aboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About Avexa'**
  String get aboutTitle;

  /// No description provided for @aboutTagline.
  ///
  /// In en, this message translates to:
  /// **'AI-powered crypto intelligence'**
  String get aboutTagline;

  /// No description provided for @aboutVersion.
  ///
  /// In en, this message translates to:
  /// **'VERSION 1.0.0'**
  String get aboutVersion;

  /// No description provided for @aboutSection.
  ///
  /// In en, this message translates to:
  /// **'ABOUT AVEXA'**
  String get aboutSection;

  /// No description provided for @aboutDescription.
  ///
  /// In en, this message translates to:
  /// **'Avexa is an AI-powered crypto intelligence platform designed to help traders understand the market, discover opportunities and make more informed decisions.'**
  String get aboutDescription;

  /// No description provided for @aboutGettingStarted.
  ///
  /// In en, this message translates to:
  /// **'GETTING STARTED'**
  String get aboutGettingStarted;

  /// No description provided for @aboutViewOnboarding.
  ///
  /// In en, this message translates to:
  /// **'View Onboarding'**
  String get aboutViewOnboarding;

  /// No description provided for @aboutOnboardingDescription.
  ///
  /// In en, this message translates to:
  /// **'Take a quick tour of the main Avexa features.'**
  String get aboutOnboardingDescription;

  /// No description provided for @aboutWhatWeDo.
  ///
  /// In en, this message translates to:
  /// **'WHAT WE DO'**
  String get aboutWhatWeDo;

  /// No description provided for @aboutTradingSignals.
  ///
  /// In en, this message translates to:
  /// **'Trading Signals'**
  String get aboutTradingSignals;

  /// No description provided for @aboutTradingSignalsDescription.
  ///
  /// In en, this message translates to:
  /// **'AI-powered signals designed to highlight potential market opportunities.'**
  String get aboutTradingSignalsDescription;

  /// No description provided for @aboutWhaleTracking.
  ///
  /// In en, this message translates to:
  /// **'Whale Tracking'**
  String get aboutWhaleTracking;

  /// No description provided for @aboutWhaleTrackingDescription.
  ///
  /// In en, this message translates to:
  /// **'Follow significant wallet activity and discover unusual market movements.'**
  String get aboutWhaleTrackingDescription;

  /// No description provided for @aboutMarketIntelligence.
  ///
  /// In en, this message translates to:
  /// **'Market Intelligence'**
  String get aboutMarketIntelligence;

  /// No description provided for @aboutMarketIntelligenceDescription.
  ///
  /// In en, this message translates to:
  /// **'Understand what is moving the market with advanced AI-powered analysis.'**
  String get aboutMarketIntelligenceDescription;

  /// No description provided for @aboutOurMission.
  ///
  /// In en, this message translates to:
  /// **'OUR MISSION'**
  String get aboutOurMission;

  /// No description provided for @aboutMissionStatement.
  ///
  /// In en, this message translates to:
  /// **'Make advanced crypto market intelligence accessible to everyone.'**
  String get aboutMissionStatement;

  /// No description provided for @aboutBuiltForTraders.
  ///
  /// In en, this message translates to:
  /// **'Built for traders.'**
  String get aboutBuiltForTraders;

  /// No description provided for @aboutPoweredByIntelligence.
  ///
  /// In en, this message translates to:
  /// **'Powered by intelligence.'**
  String get aboutPoweredByIntelligence;

  /// No description provided for @aboutCopyright.
  ///
  /// In en, this message translates to:
  /// **'© 2026 Avexa'**
  String get aboutCopyright;

  /// No description provided for @onboardingHomeSection.
  ///
  /// In en, this message translates to:
  /// **'HOME'**
  String get onboardingHomeSection;

  /// No description provided for @onboardingHomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Your crypto command center'**
  String get onboardingHomeTitle;

  /// No description provided for @onboardingHomeDescription.
  ///
  /// In en, this message translates to:
  /// **'Everything important at a glance. Follow the market and discover what is happening across Avexa.'**
  String get onboardingHomeDescription;

  /// No description provided for @onboardingChartsSection.
  ///
  /// In en, this message translates to:
  /// **'CHARTS'**
  String get onboardingChartsSection;

  /// No description provided for @onboardingChartsTitle.
  ///
  /// In en, this message translates to:
  /// **'Explore the market'**
  String get onboardingChartsTitle;

  /// No description provided for @onboardingChartsDescription.
  ///
  /// In en, this message translates to:
  /// **'Explore DEX, Trending, Spot and Futures markets and keep an eye on price action.'**
  String get onboardingChartsDescription;

  /// No description provided for @onboardingSignalsSection.
  ///
  /// In en, this message translates to:
  /// **'SIGNALS'**
  String get onboardingSignalsSection;

  /// No description provided for @onboardingSignalsTitle.
  ///
  /// In en, this message translates to:
  /// **'AI-powered signals'**
  String get onboardingSignalsTitle;

  /// No description provided for @onboardingSignalsDescription.
  ///
  /// In en, this message translates to:
  /// **'Discover AI-generated setups with clear entry, stop loss, take profit and confidence data.'**
  String get onboardingSignalsDescription;

  /// No description provided for @onboardingAiChartSection.
  ///
  /// In en, this message translates to:
  /// **'AI CHART'**
  String get onboardingAiChartSection;

  /// No description provided for @onboardingAiChartTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Chart Analysis'**
  String get onboardingAiChartTitle;

  /// No description provided for @onboardingAiChartDescription.
  ///
  /// In en, this message translates to:
  /// **'Upload any crypto chart and let Avexa AI analyze trends, momentum, support and resistance.'**
  String get onboardingAiChartDescription;

  /// No description provided for @onboardingPortfolioSection.
  ///
  /// In en, this message translates to:
  /// **'PORTFOLIO'**
  String get onboardingPortfolioSection;

  /// No description provided for @onboardingPortfolioTitle.
  ///
  /// In en, this message translates to:
  /// **'Your portfolio'**
  String get onboardingPortfolioTitle;

  /// No description provided for @onboardingPortfolioDescription.
  ///
  /// In en, this message translates to:
  /// **'Connect your supported accounts and keep your crypto portfolio organized in one place.'**
  String get onboardingPortfolioDescription;

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'SKIP'**
  String get onboardingSkip;

  /// No description provided for @onboardingNext.
  ///
  /// In en, this message translates to:
  /// **'NEXT'**
  String get onboardingNext;

  /// No description provided for @onboardingGetStarted.
  ///
  /// In en, this message translates to:
  /// **'GET STARTED'**
  String get onboardingGetStarted;

  /// No description provided for @securityTitle.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get securityTitle;

  /// No description provided for @securityAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Account security'**
  String get securityAccountTitle;

  /// No description provided for @securityAccountDescription.
  ///
  /// In en, this message translates to:
  /// **'Manage your password and account security.'**
  String get securityAccountDescription;

  /// No description provided for @securityAccountSection.
  ///
  /// In en, this message translates to:
  /// **'ACCOUNT'**
  String get securityAccountSection;

  /// No description provided for @securityAccountEmail.
  ///
  /// In en, this message translates to:
  /// **'Account email'**
  String get securityAccountEmail;

  /// No description provided for @securityChangePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get securityChangePassword;

  /// No description provided for @securityCurrentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get securityCurrentPassword;

  /// No description provided for @securityNewPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get securityNewPassword;

  /// No description provided for @securityConfirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get securityConfirmNewPassword;

  /// No description provided for @securityEnterNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your new password.'**
  String get securityEnterNewPassword;

  /// No description provided for @securityPasswordLengthError.
  ///
  /// In en, this message translates to:
  /// **'Password must contain at least 6 characters.'**
  String get securityPasswordLengthError;

  /// No description provided for @securityPasswordsMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get securityPasswordsMismatch;

  /// No description provided for @securityPasswordChanged.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully.'**
  String get securityPasswordChanged;

  /// No description provided for @securityPasswordChangeError.
  ///
  /// In en, this message translates to:
  /// **'Could not change your password.'**
  String get securityPasswordChangeError;

  /// No description provided for @securityAppLockSection.
  ///
  /// In en, this message translates to:
  /// **'APP LOCK'**
  String get securityAppLockSection;

  /// No description provided for @securityAppLockTitle.
  ///
  /// In en, this message translates to:
  /// **'Require Face ID / iPhone Passcode'**
  String get securityAppLockTitle;

  /// No description provided for @securityAppLockEnabledDescription.
  ///
  /// In en, this message translates to:
  /// **'Protect Avexa when reopening the app.'**
  String get securityAppLockEnabledDescription;

  /// No description provided for @securityAppLockDisabledDescription.
  ///
  /// In en, this message translates to:
  /// **'Use Face ID or your iPhone passcode to protect Avexa.'**
  String get securityAppLockDisabledDescription;

  /// No description provided for @securityVerificationCancelled.
  ///
  /// In en, this message translates to:
  /// **'Verification cancelled.'**
  String get securityVerificationCancelled;

  /// No description provided for @securityVerificationRequired.
  ///
  /// In en, this message translates to:
  /// **'Verification required to disable App Lock.'**
  String get securityVerificationRequired;

  /// No description provided for @securityAppLockEnabled.
  ///
  /// In en, this message translates to:
  /// **'App Lock enabled.'**
  String get securityAppLockEnabled;

  /// No description provided for @securityAppLockDisabled.
  ///
  /// In en, this message translates to:
  /// **'App Lock disabled.'**
  String get securityAppLockDisabled;

  /// No description provided for @securityAppLockChangeError.
  ///
  /// In en, this message translates to:
  /// **'Could not change App Lock settings.'**
  String get securityAppLockChangeError;

  /// No description provided for @securitySafetyNotice.
  ///
  /// In en, this message translates to:
  /// **'Never share your password, recovery codes or private wallet keys with anyone.'**
  String get securitySafetyNotice;

  /// No description provided for @securityCreatePin.
  ///
  /// In en, this message translates to:
  /// **'Create App PIN'**
  String get securityCreatePin;

  /// No description provided for @securityCreatePinDescription.
  ///
  /// In en, this message translates to:
  /// **'Create a PIN that can be used to unlock Avexa when Face ID is unavailable.'**
  String get securityCreatePinDescription;

  /// No description provided for @securityEnterPin.
  ///
  /// In en, this message translates to:
  /// **'Enter App PIN'**
  String get securityEnterPin;

  /// No description provided for @securityPin.
  ///
  /// In en, this message translates to:
  /// **'PIN'**
  String get securityPin;

  /// No description provided for @securityConfirmPin.
  ///
  /// In en, this message translates to:
  /// **'Confirm PIN'**
  String get securityConfirmPin;

  /// No description provided for @securityPinLengthError.
  ///
  /// In en, this message translates to:
  /// **'PIN must contain 4–6 digits.'**
  String get securityPinLengthError;

  /// No description provided for @securityPinDigitsError.
  ///
  /// In en, this message translates to:
  /// **'PIN must contain only numbers.'**
  String get securityPinDigitsError;

  /// No description provided for @securityPinsMismatch.
  ///
  /// In en, this message translates to:
  /// **'PINs do not match.'**
  String get securityPinsMismatch;

  /// No description provided for @securityCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get securityCancel;

  /// No description provided for @securitySave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get securitySave;

  /// No description provided for @securityUnlock.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get securityUnlock;

  /// No description provided for @connectedAccountsTitle.
  ///
  /// In en, this message translates to:
  /// **'Connected Accounts'**
  String get connectedAccountsTitle;

  /// No description provided for @connectedAccountsWalletsExchanges.
  ///
  /// In en, this message translates to:
  /// **'Wallets & Exchanges'**
  String get connectedAccountsWalletsExchanges;

  /// No description provided for @connectedAccountsDescription.
  ///
  /// In en, this message translates to:
  /// **'Connect your wallets and exchanges to use trading features inside Avexa.'**
  String get connectedAccountsDescription;

  /// No description provided for @connectedAccountsSolanaWallet.
  ///
  /// In en, this message translates to:
  /// **'Solana Wallet'**
  String get connectedAccountsSolanaWallet;

  /// No description provided for @connectedAccountsEthereumWallet.
  ///
  /// In en, this message translates to:
  /// **'Ethereum Wallet'**
  String get connectedAccountsEthereumWallet;

  /// No description provided for @connectedAccountsExchanges.
  ///
  /// In en, this message translates to:
  /// **'Exchanges'**
  String get connectedAccountsExchanges;

  /// No description provided for @connectedAccountsExchangeAccount.
  ///
  /// In en, this message translates to:
  /// **'Exchange account'**
  String get connectedAccountsExchangeAccount;

  /// No description provided for @connectedAccountsSecurityNotice.
  ///
  /// In en, this message translates to:
  /// **'Avexa uses public blockchain addresses only. Your private keys and funds remain under your control. Connecting an address does not authorize transactions.'**
  String get connectedAccountsSecurityNotice;

  /// No description provided for @connectedAccountsComingSoon.
  ///
  /// In en, this message translates to:
  /// **'This connection will be available in a future version of Avexa.'**
  String get connectedAccountsComingSoon;

  /// No description provided for @connectedAccountsOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get connectedAccountsOk;

  /// No description provided for @personalInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInfoTitle;

  /// No description provided for @personalInfoDescription.
  ///
  /// In en, this message translates to:
  /// **'Manage your profile information and avatar.'**
  String get personalInfoDescription;

  /// No description provided for @personalInfoDefaultUser.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get personalInfoDefaultUser;

  /// No description provided for @personalInfoLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load your profile.'**
  String get personalInfoLoadError;

  /// No description provided for @personalInfoAvatarSaveError.
  ///
  /// In en, this message translates to:
  /// **'Could not save profile picture.'**
  String get personalInfoAvatarSaveError;

  /// No description provided for @personalInfoAvatarUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile picture updated.'**
  String get personalInfoAvatarUpdated;

  /// No description provided for @personalInfoAvatarUpdateError.
  ///
  /// In en, this message translates to:
  /// **'Could not update profile picture.'**
  String get personalInfoAvatarUpdateError;

  /// No description provided for @personalInfoNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name.'**
  String get personalInfoNameRequired;

  /// No description provided for @personalInfoUsernameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a username.'**
  String get personalInfoUsernameRequired;

  /// No description provided for @personalInfoUsernameLengthError.
  ///
  /// In en, this message translates to:
  /// **'Username must contain at least 3 characters.'**
  String get personalInfoUsernameLengthError;

  /// No description provided for @personalInfoUpdateError.
  ///
  /// In en, this message translates to:
  /// **'Could not update your profile.'**
  String get personalInfoUpdateError;

  /// No description provided for @personalInfoDetailsSection.
  ///
  /// In en, this message translates to:
  /// **'PERSONAL DETAILS'**
  String get personalInfoDetailsSection;

  /// No description provided for @personalInfoDisplayName.
  ///
  /// In en, this message translates to:
  /// **'DISPLAY NAME'**
  String get personalInfoDisplayName;

  /// No description provided for @personalInfoNameHint.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get personalInfoNameHint;

  /// No description provided for @personalInfoUsername.
  ///
  /// In en, this message translates to:
  /// **'USERNAME'**
  String get personalInfoUsername;

  /// No description provided for @personalInfoUsernameHint.
  ///
  /// In en, this message translates to:
  /// **'username'**
  String get personalInfoUsernameHint;

  /// No description provided for @personalInfoUsernameDescription.
  ///
  /// In en, this message translates to:
  /// **'This username will be visible across Avexa.'**
  String get personalInfoUsernameDescription;

  /// No description provided for @personalInfoEmailSection.
  ///
  /// In en, this message translates to:
  /// **'ACCOUNT EMAIL'**
  String get personalInfoEmailSection;

  /// No description provided for @personalInfoVerifiedEmail.
  ///
  /// In en, this message translates to:
  /// **'Verified account email'**
  String get personalInfoVerifiedEmail;

  /// No description provided for @personalInfoEmailCannotChange.
  ///
  /// In en, this message translates to:
  /// **'Your email address cannot be changed here.'**
  String get personalInfoEmailCannotChange;

  /// No description provided for @personalInfoSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'SAVE CHANGES'**
  String get personalInfoSaveChanges;

  /// No description provided for @personalInfoSecureSaveNotice.
  ///
  /// In en, this message translates to:
  /// **'Your changes are securely saved to your account.'**
  String get personalInfoSecureSaveNotice;

  /// No description provided for @subscriptionTitle.
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get subscriptionTitle;

  /// No description provided for @subscriptionChoosePlan.
  ///
  /// In en, this message translates to:
  /// **'CHOOSE YOUR PLAN'**
  String get subscriptionChoosePlan;

  /// No description provided for @subscriptionYourPlan.
  ///
  /// In en, this message translates to:
  /// **'YOUR PLAN'**
  String get subscriptionYourPlan;

  /// No description provided for @subscriptionFeatures.
  ///
  /// In en, this message translates to:
  /// **'FEATURES'**
  String get subscriptionFeatures;

  /// No description provided for @subscriptionMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get subscriptionMonthly;

  /// No description provided for @subscriptionYearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get subscriptionYearly;

  /// No description provided for @subscriptionSave33.
  ///
  /// In en, this message translates to:
  /// **'SAVE 33%'**
  String get subscriptionSave33;

  /// No description provided for @subscriptionPerMonth.
  ///
  /// In en, this message translates to:
  /// **'/ month'**
  String get subscriptionPerMonth;

  /// No description provided for @subscriptionPerYear.
  ///
  /// In en, this message translates to:
  /// **'/ year'**
  String get subscriptionPerYear;

  /// No description provided for @subscriptionProMonthly.
  ///
  /// In en, this message translates to:
  /// **'PRO MONTHLY'**
  String get subscriptionProMonthly;

  /// No description provided for @subscriptionProYearly.
  ///
  /// In en, this message translates to:
  /// **'PRO YEARLY'**
  String get subscriptionProYearly;

  /// No description provided for @subscriptionUpgradeMonthly.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to PRO — {price}/month'**
  String subscriptionUpgradeMonthly(String price);

  /// No description provided for @subscriptionUpgradeYearly.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to PRO — {price}/year'**
  String subscriptionUpgradeYearly(String price);

  /// No description provided for @subscriptionManagePurchases.
  ///
  /// In en, this message translates to:
  /// **'Manage Purchases'**
  String get subscriptionManagePurchases;

  /// No description provided for @subscriptionRestorePurchases.
  ///
  /// In en, this message translates to:
  /// **'Restore Purchases'**
  String get subscriptionRestorePurchases;

  /// No description provided for @subscriptionManageSubscription.
  ///
  /// In en, this message translates to:
  /// **'Manage Subscription'**
  String get subscriptionManageSubscription;

  /// No description provided for @subscriptionChangePlan.
  ///
  /// In en, this message translates to:
  /// **'Change Plan'**
  String get subscriptionChangePlan;

  /// No description provided for @subscriptionCancelSubscription.
  ///
  /// In en, this message translates to:
  /// **'Cancel Subscription'**
  String get subscriptionCancelSubscription;

  /// No description provided for @subscriptionUnavailable.
  ///
  /// In en, this message translates to:
  /// **'The subscription is currently unavailable.'**
  String get subscriptionUnavailable;

  /// No description provided for @subscriptionCheckingPurchases.
  ///
  /// In en, this message translates to:
  /// **'Checking your previous purchases...'**
  String get subscriptionCheckingPurchases;

  /// No description provided for @subscriptionManagementComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Subscription management will be available soon.'**
  String get subscriptionManagementComingSoon;

  /// No description provided for @subscriptionDailySignals.
  ///
  /// In en, this message translates to:
  /// **'Daily Signals'**
  String get subscriptionDailySignals;

  /// No description provided for @subscriptionOnePerDay.
  ///
  /// In en, this message translates to:
  /// **'1/day'**
  String get subscriptionOnePerDay;

  /// No description provided for @subscriptionUnlimited.
  ///
  /// In en, this message translates to:
  /// **'Unlimited'**
  String get subscriptionUnlimited;

  /// No description provided for @subscriptionAiMarketAnalysis.
  ///
  /// In en, this message translates to:
  /// **'AI Market Analysis'**
  String get subscriptionAiMarketAnalysis;

  /// No description provided for @subscriptionWhaleTracking.
  ///
  /// In en, this message translates to:
  /// **'Whale Tracking'**
  String get subscriptionWhaleTracking;

  /// No description provided for @subscriptionAdvancedCharts.
  ///
  /// In en, this message translates to:
  /// **'Advanced Charts'**
  String get subscriptionAdvancedCharts;

  /// No description provided for @subscriptionFuturesIntelligence.
  ///
  /// In en, this message translates to:
  /// **'Futures Intelligence'**
  String get subscriptionFuturesIntelligence;

  /// No description provided for @subscriptionWalletTracker.
  ///
  /// In en, this message translates to:
  /// **'Wallet Tracker'**
  String get subscriptionWalletTracker;

  /// No description provided for @subscriptionNewsSentiment.
  ///
  /// In en, this message translates to:
  /// **'News & Sentiment'**
  String get subscriptionNewsSentiment;

  /// No description provided for @subscriptionLimited.
  ///
  /// In en, this message translates to:
  /// **'Limited'**
  String get subscriptionLimited;

  /// No description provided for @subscriptionPrioritySupport.
  ///
  /// In en, this message translates to:
  /// **'Priority Support'**
  String get subscriptionPrioritySupport;

  /// No description provided for @subscriptionFreeInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re on the FREE plan'**
  String get subscriptionFreeInfoTitle;

  /// No description provided for @subscriptionFreeInfoDescription.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to PRO to unlock all features and take your trading to the next level.'**
  String get subscriptionFreeInfoDescription;

  /// No description provided for @subscriptionActiveTitle.
  ///
  /// In en, this message translates to:
  /// **'Your PRO subscription is active'**
  String get subscriptionActiveTitle;

  /// No description provided for @subscriptionActiveDescription.
  ///
  /// In en, this message translates to:
  /// **'All premium features are currently unlocked.'**
  String get subscriptionActiveDescription;

  /// No description provided for @subscriptionProInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re PRO'**
  String get subscriptionProInfoTitle;

  /// No description provided for @subscriptionProInfoDescription.
  ///
  /// In en, this message translates to:
  /// **'Thanks for being part of Avexa PRO. Keep trading smarter.'**
  String get subscriptionProInfoDescription;

  /// No description provided for @profileActive.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE'**
  String get profileActive;

  /// No description provided for @profileProPlan.
  ///
  /// In en, this message translates to:
  /// **'PRO PLAN'**
  String get profileProPlan;

  /// No description provided for @profileFreePlan.
  ///
  /// In en, this message translates to:
  /// **'FREE PLAN'**
  String get profileFreePlan;

  /// No description provided for @profileMemberSince.
  ///
  /// In en, this message translates to:
  /// **'Member since {year}'**
  String profileMemberSince(String year);

  /// No description provided for @profileFreeSignals.
  ///
  /// In en, this message translates to:
  /// **'FREE Signals'**
  String get profileFreeSignals;

  /// No description provided for @profileAiAnalyses.
  ///
  /// In en, this message translates to:
  /// **'AI Analyses'**
  String get profileAiAnalyses;

  /// No description provided for @profileSubscriptionSection.
  ///
  /// In en, this message translates to:
  /// **'SUBSCRIPTION'**
  String get profileSubscriptionSection;

  /// No description provided for @profileAccountSection.
  ///
  /// In en, this message translates to:
  /// **'ACCOUNT'**
  String get profileAccountSection;

  /// No description provided for @profilePreferencesSection.
  ///
  /// In en, this message translates to:
  /// **'PREFERENCES'**
  String get profilePreferencesSection;

  /// No description provided for @profileSupportSection.
  ///
  /// In en, this message translates to:
  /// **'SUPPORT'**
  String get profileSupportSection;

  /// No description provided for @profilePersonalInformation.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get profilePersonalInformation;

  /// No description provided for @profileConnectedAccounts.
  ///
  /// In en, this message translates to:
  /// **'Connected Accounts'**
  String get profileConnectedAccounts;

  /// No description provided for @profileSecurity.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get profileSecurity;

  /// No description provided for @profileAppSettings.
  ///
  /// In en, this message translates to:
  /// **'App Settings'**
  String get profileAppSettings;

  /// No description provided for @profileRateUs.
  ///
  /// In en, this message translates to:
  /// **'Rate Us'**
  String get profileRateUs;

  /// No description provided for @profileAboutAvexa.
  ///
  /// In en, this message translates to:
  /// **'About Avexa'**
  String get profileAboutAvexa;

  /// No description provided for @profileHelpCenter.
  ///
  /// In en, this message translates to:
  /// **'Help Center'**
  String get profileHelpCenter;

  /// No description provided for @profileReportBug.
  ///
  /// In en, this message translates to:
  /// **'Report a Bug'**
  String get profileReportBug;

  /// No description provided for @profileContactSupport.
  ///
  /// In en, this message translates to:
  /// **'Contact Support'**
  String get profileContactSupport;

  /// No description provided for @profileLogOut.
  ///
  /// In en, this message translates to:
  /// **'LOG OUT'**
  String get profileLogOut;

  /// No description provided for @profileActiveSubscription.
  ///
  /// In en, this message translates to:
  /// **'Active subscription'**
  String get profileActiveSubscription;

  /// No description provided for @profileCurrentSubscription.
  ///
  /// In en, this message translates to:
  /// **'Current subscription'**
  String get profileCurrentSubscription;

  /// No description provided for @profileAvatarSaveError.
  ///
  /// In en, this message translates to:
  /// **'Could not save profile picture.'**
  String get profileAvatarSaveError;

  /// No description provided for @profileAvatarUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile picture updated.'**
  String get profileAvatarUpdated;

  /// No description provided for @profileAvatarUpdateError.
  ///
  /// In en, this message translates to:
  /// **'Could not update profile picture.'**
  String get profileAvatarUpdateError;

  /// No description provided for @portfolioHeaderProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get portfolioHeaderProfile;

  /// No description provided for @portfolioTapToViewProfile.
  ///
  /// In en, this message translates to:
  /// **'Tap to view your profile'**
  String get portfolioTapToViewProfile;

  /// No description provided for @portfolioValue.
  ///
  /// In en, this message translates to:
  /// **'Portfolio Value'**
  String get portfolioValue;

  /// No description provided for @portfolioNoPortfolioConnected.
  ///
  /// In en, this message translates to:
  /// **'No Portfolio Connected'**
  String get portfolioNoPortfolioConnected;

  /// No description provided for @portfolioConnectDescription.
  ///
  /// In en, this message translates to:
  /// **'Connect your exchange or wallet to unlock live portfolio tracking, AI insights and risk analysis.'**
  String get portfolioConnectDescription;

  /// No description provided for @portfolioConnectButton.
  ///
  /// In en, this message translates to:
  /// **'CONNECT PORTFOLIO'**
  String get portfolioConnectButton;

  /// No description provided for @portfolioConnectedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Portfolio connected successfully'**
  String get portfolioConnectedSuccessfully;

  /// No description provided for @portfolioLastSync.
  ///
  /// In en, this message translates to:
  /// **'Last sync: Just now'**
  String get portfolioLastSync;

  /// No description provided for @portfolioManageConnections.
  ///
  /// In en, this message translates to:
  /// **'Manage connections'**
  String get portfolioManageConnections;

  /// No description provided for @portfolioRefreshPortfolio.
  ///
  /// In en, this message translates to:
  /// **'REFRESH PORTFOLIO'**
  String get portfolioRefreshPortfolio;

  /// No description provided for @portfolioSyncComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Portfolio synchronization coming soon'**
  String get portfolioSyncComingSoon;

  /// No description provided for @portfolioDisconnect.
  ///
  /// In en, this message translates to:
  /// **'Disconnect Portfolio'**
  String get portfolioDisconnect;

  /// No description provided for @portfolioOverview.
  ///
  /// In en, this message translates to:
  /// **'Portfolio Overview'**
  String get portfolioOverview;

  /// No description provided for @portfolioTotalValue.
  ///
  /// In en, this message translates to:
  /// **'Total Portfolio Value'**
  String get portfolioTotalValue;

  /// No description provided for @portfolioAssets.
  ///
  /// In en, this message translates to:
  /// **'Assets'**
  String get portfolioAssets;

  /// No description provided for @portfolioChains.
  ///
  /// In en, this message translates to:
  /// **'Chains'**
  String get portfolioChains;

  /// No description provided for @portfolioNfts.
  ///
  /// In en, this message translates to:
  /// **'NFTs'**
  String get portfolioNfts;

  /// No description provided for @portfolioNoAssetsSynced.
  ///
  /// In en, this message translates to:
  /// **'No assets synchronized'**
  String get portfolioNoAssetsSynced;

  /// No description provided for @portfolioConnectToImport.
  ///
  /// In en, this message translates to:
  /// **'Connect your wallet to automatically import your cryptocurrencies.'**
  String get portfolioConnectToImport;

  /// No description provided for @portfolioAiScore.
  ///
  /// In en, this message translates to:
  /// **'AI Portfolio Score'**
  String get portfolioAiScore;

  /// No description provided for @portfolioExcellent.
  ///
  /// In en, this message translates to:
  /// **'Excellent Portfolio'**
  String get portfolioExcellent;

  /// No description provided for @portfolioRiskDescription.
  ///
  /// In en, this message translates to:
  /// **'Diversified portfolio with medium risk exposure.'**
  String get portfolioRiskDescription;

  /// No description provided for @portfolioAiInsights.
  ///
  /// In en, this message translates to:
  /// **'AI Insights'**
  String get portfolioAiInsights;

  /// No description provided for @portfolioInsightDiversified.
  ///
  /// In en, this message translates to:
  /// **'Portfolio is well diversified across large-cap cryptocurrencies.'**
  String get portfolioInsightDiversified;

  /// No description provided for @portfolioInsightModerateRisk.
  ///
  /// In en, this message translates to:
  /// **'Risk level is currently Moderate.'**
  String get portfolioInsightModerateRisk;

  /// No description provided for @portfolioInsightStablecoins.
  ///
  /// In en, this message translates to:
  /// **'Adding stablecoins could reduce volatility.'**
  String get portfolioInsightStablecoins;

  /// No description provided for @portfolioInsightNoSuspiciousTokens.
  ///
  /// In en, this message translates to:
  /// **'No suspicious token concentration detected.'**
  String get portfolioInsightNoSuspiciousTokens;

  /// No description provided for @portfolioProPlan.
  ///
  /// In en, this message translates to:
  /// **'PRO PLAN'**
  String get portfolioProPlan;

  /// No description provided for @portfolioFreePlan.
  ///
  /// In en, this message translates to:
  /// **'FREE PLAN'**
  String get portfolioFreePlan;

  /// No description provided for @portfolioActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get portfolioActive;

  /// No description provided for @portfolioNotificationsEnabled.
  ///
  /// In en, this message translates to:
  /// **'Notifications Enabled'**
  String get portfolioNotificationsEnabled;

  /// No description provided for @portfolioMemberSince.
  ///
  /// In en, this message translates to:
  /// **'Member since {year}'**
  String portfolioMemberSince(int year);

  /// No description provided for @aiAssistantClearChat.
  ///
  /// In en, this message translates to:
  /// **'Clear chat'**
  String get aiAssistantClearChat;

  /// No description provided for @aiAssistantMinimize.
  ///
  /// In en, this message translates to:
  /// **'Minimize'**
  String get aiAssistantMinimize;

  /// No description provided for @aiAssistantTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Trading Assistant'**
  String get aiAssistantTitle;

  /// No description provided for @aiAssistantSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your personal crypto analyst'**
  String get aiAssistantSubtitle;

  /// No description provided for @aiAssistantAnalyzeBtc.
  ///
  /// In en, this message translates to:
  /// **'📈 Analyze BTC'**
  String get aiAssistantAnalyzeBtc;

  /// No description provided for @aiAssistantBestTrade.
  ///
  /// In en, this message translates to:
  /// **'🔥 Best trade'**
  String get aiAssistantBestTrade;

  /// No description provided for @aiAssistantMarketRisk.
  ///
  /// In en, this message translates to:
  /// **'⚠️ Market risk'**
  String get aiAssistantMarketRisk;

  /// No description provided for @aiAssistantHiddenGems.
  ///
  /// In en, this message translates to:
  /// **'💎 Hidden gems'**
  String get aiAssistantHiddenGems;

  /// No description provided for @aiAssistantWelcome.
  ///
  /// In en, this message translates to:
  /// **'What can I help you with today?'**
  String get aiAssistantWelcome;

  /// No description provided for @aiAssistantAnalyzeBitcoin.
  ///
  /// In en, this message translates to:
  /// **'📈 Analyze Bitcoin'**
  String get aiAssistantAnalyzeBitcoin;

  /// No description provided for @aiAssistantSuggestionMarketRisk.
  ///
  /// In en, this message translates to:
  /// **'⚠️ Market Risk'**
  String get aiAssistantSuggestionMarketRisk;

  /// No description provided for @aiAssistantSuggestionHiddenGems.
  ///
  /// In en, this message translates to:
  /// **'💎 Hidden Gems'**
  String get aiAssistantSuggestionHiddenGems;

  /// No description provided for @aiAssistantSavedAnalyses.
  ///
  /// In en, this message translates to:
  /// **'Saved Analyses'**
  String get aiAssistantSavedAnalyses;

  /// No description provided for @aiAssistantNoSavedAnalyses.
  ///
  /// In en, this message translates to:
  /// **'No saved analyses'**
  String get aiAssistantNoSavedAnalyses;

  /// No description provided for @aiAssistantAnalysisRemoved.
  ///
  /// In en, this message translates to:
  /// **'Analysis removed'**
  String get aiAssistantAnalysisRemoved;

  /// No description provided for @aiAssistantAnalysisSaved.
  ///
  /// In en, this message translates to:
  /// **'Analysis saved'**
  String get aiAssistantAnalysisSaved;

  /// No description provided for @aiAssistantFeedbackThanks.
  ///
  /// In en, this message translates to:
  /// **'Thanks for your feedback!'**
  String get aiAssistantFeedbackThanks;

  /// No description provided for @aiAssistantFeedbackQuestion.
  ///
  /// In en, this message translates to:
  /// **'Why wasn\'t this helpful?'**
  String get aiAssistantFeedbackQuestion;

  /// No description provided for @aiAssistantFeedbackIncorrect.
  ///
  /// In en, this message translates to:
  /// **'❌ Incorrect information'**
  String get aiAssistantFeedbackIncorrect;

  /// No description provided for @aiAssistantFeedbackGeneric.
  ///
  /// In en, this message translates to:
  /// **'🤔 Too generic'**
  String get aiAssistantFeedbackGeneric;

  /// No description provided for @aiAssistantFeedbackNoAnswer.
  ///
  /// In en, this message translates to:
  /// **'💬 Didn\'t answer my question'**
  String get aiAssistantFeedbackNoAnswer;

  /// No description provided for @aiAssistantFeedbackOutdated.
  ///
  /// In en, this message translates to:
  /// **'📉 Outdated market data'**
  String get aiAssistantFeedbackOutdated;

  /// No description provided for @aiAssistantFeedbackOther.
  ///
  /// In en, this message translates to:
  /// **'✍️ Other'**
  String get aiAssistantFeedbackOther;

  /// No description provided for @aiAssistantFeedbackThanksImprove.
  ///
  /// In en, this message translates to:
  /// **'Thanks for helping improve the AI!'**
  String get aiAssistantFeedbackThanksImprove;

  /// No description provided for @aiAssistantInputHint.
  ///
  /// In en, this message translates to:
  /// **'Ask anything about crypto...'**
  String get aiAssistantInputHint;

  /// No description provided for @aiAssistantAnalyzingMarket.
  ///
  /// In en, this message translates to:
  /// **'Analyzing market...'**
  String get aiAssistantAnalyzingMarket;

  /// No description provided for @chartsTitle.
  ///
  /// In en, this message translates to:
  /// **'Charts'**
  String get chartsTitle;

  /// No description provided for @chartsSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search coin or token...'**
  String get chartsSearchHint;

  /// No description provided for @chartsMarketCap.
  ///
  /// In en, this message translates to:
  /// **'Market Cap'**
  String get chartsMarketCap;

  /// No description provided for @chartsVolume.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get chartsVolume;

  /// No description provided for @chartsChange24.
  ///
  /// In en, this message translates to:
  /// **'24H Change'**
  String get chartsChange24;

  /// No description provided for @chartsRank.
  ///
  /// In en, this message translates to:
  /// **'Rank'**
  String get chartsRank;

  /// No description provided for @chartsFavorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get chartsFavorites;

  /// No description provided for @chartsTrending.
  ///
  /// In en, this message translates to:
  /// **'Trending'**
  String get chartsTrending;

  /// No description provided for @chartsSpot.
  ///
  /// In en, this message translates to:
  /// **'Spot'**
  String get chartsSpot;

  /// No description provided for @chartsFutures.
  ///
  /// In en, this message translates to:
  /// **'Futures'**
  String get chartsFutures;

  /// No description provided for @chartsTrendingCoins.
  ///
  /// In en, this message translates to:
  /// **'Trending Coins'**
  String get chartsTrendingCoins;

  /// No description provided for @chartsSpotMarket.
  ///
  /// In en, this message translates to:
  /// **'Spot Market'**
  String get chartsSpotMarket;

  /// No description provided for @chartsFuturesMarket.
  ///
  /// In en, this message translates to:
  /// **'Futures Market'**
  String get chartsFuturesMarket;

  /// No description provided for @chartsMostActive.
  ///
  /// In en, this message translates to:
  /// **'Most active right now'**
  String get chartsMostActive;

  /// No description provided for @chartsSpotAssets.
  ///
  /// In en, this message translates to:
  /// **'Live spot market assets'**
  String get chartsSpotAssets;

  /// No description provided for @chartsFuturesAssets.
  ///
  /// In en, this message translates to:
  /// **'Major assets available for futures'**
  String get chartsFuturesAssets;

  /// No description provided for @chartsTopGainers.
  ///
  /// In en, this message translates to:
  /// **'Top Gainers'**
  String get chartsTopGainers;

  /// No description provided for @chartsTopLosers.
  ///
  /// In en, this message translates to:
  /// **'Top Losers'**
  String get chartsTopLosers;

  /// No description provided for @charts24HourPerformance.
  ///
  /// In en, this message translates to:
  /// **'24 hour performance'**
  String get charts24HourPerformance;

  /// No description provided for @chartsGainers.
  ///
  /// In en, this message translates to:
  /// **'Gainers'**
  String get chartsGainers;

  /// No description provided for @chartsLosers.
  ///
  /// In en, this message translates to:
  /// **'Losers'**
  String get chartsLosers;

  /// No description provided for @chartsPrice.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get chartsPrice;

  /// No description provided for @chartsMarketCapShort.
  ///
  /// In en, this message translates to:
  /// **'MCap'**
  String get chartsMarketCapShort;

  /// No description provided for @chartsAiMarketScore.
  ///
  /// In en, this message translates to:
  /// **'AI Market Score'**
  String get chartsAiMarketScore;

  /// No description provided for @chartsNoFavorites.
  ///
  /// In en, this message translates to:
  /// **'No favorite coins yet'**
  String get chartsNoFavorites;

  /// No description provided for @chartsAddFavoritesHint.
  ///
  /// In en, this message translates to:
  /// **'Add coins to quickly track them here.'**
  String get chartsAddFavoritesHint;

  /// No description provided for @chartsDexScanner.
  ///
  /// In en, this message translates to:
  /// **'DEX Scanner'**
  String get chartsDexScanner;

  /// No description provided for @chartsDexSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Discover on-chain opportunities'**
  String get chartsDexSubtitle;

  /// No description provided for @chartsFilters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get chartsFilters;

  /// No description provided for @chartsFiltersCount.
  ///
  /// In en, this message translates to:
  /// **'Filters {count}'**
  String chartsFiltersCount(int count);

  /// No description provided for @chartsAllChains.
  ///
  /// In en, this message translates to:
  /// **'All Chains'**
  String get chartsAllChains;

  /// No description provided for @chartsDexPairsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} pairs'**
  String chartsDexPairsCount(int count);

  /// No description provided for @chartsSortLabel.
  ///
  /// In en, this message translates to:
  /// **'Sort: {sort}'**
  String chartsSortLabel(String sort);

  /// No description provided for @chartsDexFilters.
  ///
  /// In en, this message translates to:
  /// **'DEX Filters'**
  String get chartsDexFilters;

  /// No description provided for @chartsDexFiltersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tune the scanner like a DEX screener.'**
  String get chartsDexFiltersSubtitle;

  /// No description provided for @chartsPairAge.
  ///
  /// In en, this message translates to:
  /// **'Pair Age'**
  String get chartsPairAge;

  /// No description provided for @chartsReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get chartsReset;

  /// No description provided for @chartsApplyFilters.
  ///
  /// In en, this message translates to:
  /// **'Apply Filters'**
  String get chartsApplyFilters;

  /// No description provided for @chartsAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get chartsAll;

  /// No description provided for @chartsNoDexPairs.
  ///
  /// In en, this message translates to:
  /// **'No DEX pairs found'**
  String get chartsNoDexPairs;

  /// No description provided for @chartsWidenFilters.
  ///
  /// In en, this message translates to:
  /// **'Try widening your filters.'**
  String get chartsWidenFilters;

  /// No description provided for @chartsMarketCapUpper.
  ///
  /// In en, this message translates to:
  /// **'MARKET CAP'**
  String get chartsMarketCapUpper;

  /// No description provided for @chartsLiquidity.
  ///
  /// In en, this message translates to:
  /// **'Liquidity'**
  String get chartsLiquidity;

  /// No description provided for @chartsLiquidityUpper.
  ///
  /// In en, this message translates to:
  /// **'LIQUIDITY'**
  String get chartsLiquidityUpper;

  /// No description provided for @chartsVolume24Upper.
  ///
  /// In en, this message translates to:
  /// **'24H VOLUME'**
  String get chartsVolume24Upper;

  /// No description provided for @chartsFlow24Upper.
  ///
  /// In en, this message translates to:
  /// **'24H FLOW'**
  String get chartsFlow24Upper;

  /// No description provided for @chartsBuysCount.
  ///
  /// In en, this message translates to:
  /// **'{count} buys'**
  String chartsBuysCount(int count);

  /// No description provided for @chartsSellsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} sells'**
  String chartsSellsCount(int count);

  /// No description provided for @aiChartTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Chart'**
  String get aiChartTitle;

  /// No description provided for @aiChartDescription.
  ///
  /// In en, this message translates to:
  /// **'Take a photo of a chart and let Avexa analyze it.'**
  String get aiChartDescription;

  /// No description provided for @aiChartAnalysisTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Chart Analysis'**
  String get aiChartAnalysisTitle;

  /// No description provided for @aiChartDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get aiChartDone;

  /// No description provided for @aiChartScannerTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Chart Scanner'**
  String get aiChartScannerTitle;

  /// No description provided for @aiChartScannerDescription.
  ///
  /// In en, this message translates to:
  /// **'Position your chart inside the frame and capture a clear image for AI analysis.'**
  String get aiChartScannerDescription;

  /// No description provided for @aiChartEnableCamera.
  ///
  /// In en, this message translates to:
  /// **'Enable Camera'**
  String get aiChartEnableCamera;

  /// No description provided for @aiChartStartingCamera.
  ///
  /// In en, this message translates to:
  /// **'Starting camera...'**
  String get aiChartStartingCamera;

  /// No description provided for @aiChartAnalyze.
  ///
  /// In en, this message translates to:
  /// **'Analyze Chart'**
  String get aiChartAnalyze;

  /// No description provided for @aiChartAnalyzing.
  ///
  /// In en, this message translates to:
  /// **'Analyzing Chart...'**
  String get aiChartAnalyzing;

  /// No description provided for @aiChartAnalysisHistory.
  ///
  /// In en, this message translates to:
  /// **'Analysis History'**
  String get aiChartAnalysisHistory;

  /// No description provided for @aiChartRecentAnalyses.
  ///
  /// In en, this message translates to:
  /// **'Your recent chart analyses'**
  String get aiChartRecentAnalyses;

  /// No description provided for @aiChartHistoryNotice.
  ///
  /// In en, this message translates to:
  /// **'Analysis history is available for 24 hours.'**
  String get aiChartHistoryNotice;

  /// No description provided for @aiChartHistoryLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load history'**
  String get aiChartHistoryLoadError;

  /// No description provided for @aiChartTryAgainLater.
  ///
  /// In en, this message translates to:
  /// **'Please try again later.'**
  String get aiChartTryAgainLater;

  /// No description provided for @aiChartNoAnalyses.
  ///
  /// In en, this message translates to:
  /// **'No analyses yet'**
  String get aiChartNoAnalyses;

  /// No description provided for @aiChartHistoryEmptyDescription.
  ///
  /// In en, this message translates to:
  /// **'Your chart analyses from the last 24 hours will appear here.'**
  String get aiChartHistoryEmptyDescription;

  /// No description provided for @aiChartHistoryCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Chart Analysis'**
  String get aiChartHistoryCardTitle;

  /// No description provided for @aiChartCameraUnavailable.
  ///
  /// In en, this message translates to:
  /// **'No camera available'**
  String get aiChartCameraUnavailable;

  /// No description provided for @aiChartCameraError.
  ///
  /// In en, this message translates to:
  /// **'Unable to start the camera. Please check camera permissions.'**
  String get aiChartCameraError;

  /// No description provided for @aiChartCaptureError.
  ///
  /// In en, this message translates to:
  /// **'Unable to capture the photo. Please try again.'**
  String get aiChartCaptureError;

  /// No description provided for @aiChartSelectImageError.
  ///
  /// In en, this message translates to:
  /// **'Unable to select the image. Please try again.'**
  String get aiChartSelectImageError;

  /// No description provided for @aiChartAnalysisError.
  ///
  /// In en, this message translates to:
  /// **'AI Chart error: {error}'**
  String aiChartAnalysisError(String error);

  /// No description provided for @aiChartNoImageError.
  ///
  /// In en, this message translates to:
  /// **'No image selected.'**
  String get aiChartNoImageError;

  /// No description provided for @aiChartUnexpectedResponseError.
  ///
  /// In en, this message translates to:
  /// **'Unexpected response format: {response}'**
  String aiChartUnexpectedResponseError(String response);

  /// No description provided for @aiChartEmptyAnalysisError.
  ///
  /// In en, this message translates to:
  /// **'AI returned an empty analysis.'**
  String get aiChartEmptyAnalysisError;

  /// No description provided for @homeTagline.
  ///
  /// In en, this message translates to:
  /// **'AI Crypto Intelligence'**
  String get homeTagline;

  /// No description provided for @homeRugCheck.
  ///
  /// In en, this message translates to:
  /// **'Rug Check'**
  String get homeRugCheck;

  /// No description provided for @homeRugCheckDescription.
  ///
  /// In en, this message translates to:
  /// **'Scan tokens for potential risks'**
  String get homeRugCheckDescription;

  /// No description provided for @homeWalletTracker.
  ///
  /// In en, this message translates to:
  /// **'Wallet Tracker'**
  String get homeWalletTracker;

  /// No description provided for @homeWalletTrackerDescription.
  ///
  /// In en, this message translates to:
  /// **'Track wallets & get live alerts'**
  String get homeWalletTrackerDescription;

  /// No description provided for @homeLiveMarketData.
  ///
  /// In en, this message translates to:
  /// **'📈 Live Market Data'**
  String get homeLiveMarketData;

  /// No description provided for @homeTopMovers.
  ///
  /// In en, this message translates to:
  /// **'🚀 Top Movers'**
  String get homeTopMovers;

  /// No description provided for @homeLiveLiquidations.
  ///
  /// In en, this message translates to:
  /// **'💀 Live Liquidations'**
  String get homeLiveLiquidations;

  /// No description provided for @signalDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Signal Details'**
  String get signalDetailTitle;

  /// No description provided for @signalDetailSolanaMeme.
  ///
  /// In en, this message translates to:
  /// **'SOLANA MEME'**
  String get signalDetailSolanaMeme;

  /// No description provided for @signalDetailDirection.
  ///
  /// In en, this message translates to:
  /// **'DIRECTION'**
  String get signalDetailDirection;

  /// No description provided for @signalDetailTier.
  ///
  /// In en, this message translates to:
  /// **'TIER'**
  String get signalDetailTier;

  /// No description provided for @signalDetailAiConfidence.
  ///
  /// In en, this message translates to:
  /// **'AI CONFIDENCE'**
  String get signalDetailAiConfidence;

  /// No description provided for @signalDetailConfidenceDescription.
  ///
  /// In en, this message translates to:
  /// **'AI-generated confidence score based on market conditions.'**
  String get signalDetailConfidenceDescription;

  /// No description provided for @signalDetailTradeLevels.
  ///
  /// In en, this message translates to:
  /// **'TRADE LEVELS'**
  String get signalDetailTradeLevels;

  /// No description provided for @signalDetailEntry.
  ///
  /// In en, this message translates to:
  /// **'ENTRY'**
  String get signalDetailEntry;

  /// No description provided for @signalDetailStopLoss.
  ///
  /// In en, this message translates to:
  /// **'STOP LOSS'**
  String get signalDetailStopLoss;

  /// No description provided for @signalDetailTakeProfit1.
  ///
  /// In en, this message translates to:
  /// **'TAKE PROFIT 1'**
  String get signalDetailTakeProfit1;

  /// No description provided for @signalDetailTakeProfit2.
  ///
  /// In en, this message translates to:
  /// **'TAKE PROFIT 2'**
  String get signalDetailTakeProfit2;

  /// No description provided for @signalDetailTakeProfit3.
  ///
  /// In en, this message translates to:
  /// **'TAKE PROFIT 3'**
  String get signalDetailTakeProfit3;

  /// No description provided for @signalDetailRiskLevel.
  ///
  /// In en, this message translates to:
  /// **'RISK LEVEL'**
  String get signalDetailRiskLevel;

  /// No description provided for @signalDetailRiskReward.
  ///
  /// In en, this message translates to:
  /// **'RISK / REWARD'**
  String get signalDetailRiskReward;

  /// No description provided for @signalDetailRiskLow.
  ///
  /// In en, this message translates to:
  /// **'LOW'**
  String get signalDetailRiskLow;

  /// No description provided for @signalDetailRiskMedium.
  ///
  /// In en, this message translates to:
  /// **'MEDIUM'**
  String get signalDetailRiskMedium;

  /// No description provided for @signalDetailRiskHigh.
  ///
  /// In en, this message translates to:
  /// **'HIGH'**
  String get signalDetailRiskHigh;

  /// No description provided for @signalDetailTokenAddress.
  ///
  /// In en, this message translates to:
  /// **'TOKEN ADDRESS'**
  String get signalDetailTokenAddress;

  /// No description provided for @signalDetailAddressUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Address unavailable'**
  String get signalDetailAddressUnavailable;

  /// No description provided for @signalDetailCopyAddress.
  ///
  /// In en, this message translates to:
  /// **'COPY TOKEN ADDRESS'**
  String get signalDetailCopyAddress;

  /// No description provided for @signalDetailViewDexScreener.
  ///
  /// In en, this message translates to:
  /// **'VIEW ON DEX SCREENER'**
  String get signalDetailViewDexScreener;

  /// No description provided for @signalDetailDexLinkUnavailable.
  ///
  /// In en, this message translates to:
  /// **'DEX Screener link is unavailable.'**
  String get signalDetailDexLinkUnavailable;

  /// No description provided for @signalDetailDexOpenError.
  ///
  /// In en, this message translates to:
  /// **'Could not open DEX Screener.'**
  String get signalDetailDexOpenError;

  /// No description provided for @signalDetailAddressCopied.
  ///
  /// In en, this message translates to:
  /// **'Token address copied'**
  String get signalDetailAddressCopied;

  /// No description provided for @signalDetailAiAnalysis.
  ///
  /// In en, this message translates to:
  /// **'AI ANALYSIS'**
  String get signalDetailAiAnalysis;

  /// No description provided for @signalDetailDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Signals are AI-generated market analysis,\nnot financial advice.'**
  String get signalDetailDisclaimer;

  /// No description provided for @coinDetailsCoinBadge.
  ///
  /// In en, this message translates to:
  /// **'COIN'**
  String get coinDetailsCoinBadge;

  /// No description provided for @coinDetailsDexBadge.
  ///
  /// In en, this message translates to:
  /// **'DEX'**
  String get coinDetailsDexBadge;

  /// No description provided for @coinDetailsCurrentPrice.
  ///
  /// In en, this message translates to:
  /// **'Current Price'**
  String get coinDetailsCurrentPrice;

  /// No description provided for @coinDetails24H.
  ///
  /// In en, this message translates to:
  /// **'24H'**
  String get coinDetails24H;

  /// No description provided for @coinDetails24HVolume.
  ///
  /// In en, this message translates to:
  /// **'24H Volume'**
  String get coinDetails24HVolume;

  /// No description provided for @coinDetails24HChange.
  ///
  /// In en, this message translates to:
  /// **'24H Change'**
  String get coinDetails24HChange;

  /// No description provided for @coinDetailsLiquidity.
  ///
  /// In en, this message translates to:
  /// **'Liquidity'**
  String get coinDetailsLiquidity;

  /// No description provided for @coinDetailsFdv.
  ///
  /// In en, this message translates to:
  /// **'FDV'**
  String get coinDetailsFdv;

  /// No description provided for @coinDetailsMarketCap.
  ///
  /// In en, this message translates to:
  /// **'Market Cap'**
  String get coinDetailsMarketCap;

  /// No description provided for @coinDetailsPriceChart.
  ///
  /// In en, this message translates to:
  /// **'Price Chart'**
  String get coinDetailsPriceChart;

  /// No description provided for @coinDetailsMarketData.
  ///
  /// In en, this message translates to:
  /// **'Market Data'**
  String get coinDetailsMarketData;

  /// No description provided for @coinDetails24HHigh.
  ///
  /// In en, this message translates to:
  /// **'24H High'**
  String get coinDetails24HHigh;

  /// No description provided for @coinDetails24HLow.
  ///
  /// In en, this message translates to:
  /// **'24H Low'**
  String get coinDetails24HLow;

  /// No description provided for @coinDetailsAllTimeHigh.
  ///
  /// In en, this message translates to:
  /// **'All-Time High'**
  String get coinDetailsAllTimeHigh;

  /// No description provided for @coinDetailsAllTimeLow.
  ///
  /// In en, this message translates to:
  /// **'All-Time Low'**
  String get coinDetailsAllTimeLow;

  /// No description provided for @coinDetailsMarketCapRank.
  ///
  /// In en, this message translates to:
  /// **'Market Cap Rank'**
  String get coinDetailsMarketCapRank;

  /// No description provided for @coinDetailsCirculatingSupply.
  ///
  /// In en, this message translates to:
  /// **'Circulating Supply'**
  String get coinDetailsCirculatingSupply;

  /// No description provided for @coinDetailsTotalSupply.
  ///
  /// In en, this message translates to:
  /// **'Total Supply'**
  String get coinDetailsTotalSupply;

  /// No description provided for @coinDetailsMaxSupply.
  ///
  /// In en, this message translates to:
  /// **'Max Supply'**
  String get coinDetailsMaxSupply;

  /// No description provided for @coinDetailsSupply.
  ///
  /// In en, this message translates to:
  /// **'Supply'**
  String get coinDetailsSupply;

  /// No description provided for @coinDetailsInCirculation.
  ///
  /// In en, this message translates to:
  /// **'in circulation'**
  String get coinDetailsInCirculation;

  /// No description provided for @coinDetailsCirculatingAmount.
  ///
  /// In en, this message translates to:
  /// **'{amount} circulating'**
  String coinDetailsCirculatingAmount(String amount);

  /// No description provided for @coinDetailsDexPair.
  ///
  /// In en, this message translates to:
  /// **'DEX Pair'**
  String get coinDetailsDexPair;

  /// No description provided for @coinDetailsNetwork.
  ///
  /// In en, this message translates to:
  /// **'Network'**
  String get coinDetailsNetwork;

  /// No description provided for @coinDetailsDex.
  ///
  /// In en, this message translates to:
  /// **'DEX'**
  String get coinDetailsDex;

  /// No description provided for @coinDetailsPair.
  ///
  /// In en, this message translates to:
  /// **'Pair'**
  String get coinDetailsPair;

  /// No description provided for @coinDetails24HBuys.
  ///
  /// In en, this message translates to:
  /// **'24H Buys'**
  String get coinDetails24HBuys;

  /// No description provided for @coinDetails24HSells.
  ///
  /// In en, this message translates to:
  /// **'24H Sells'**
  String get coinDetails24HSells;

  /// No description provided for @coinDetailsPairAge.
  ///
  /// In en, this message translates to:
  /// **'Pair Age'**
  String get coinDetailsPairAge;

  /// No description provided for @coinDetailsDexMetrics.
  ///
  /// In en, this message translates to:
  /// **'DEX Metrics'**
  String get coinDetailsDexMetrics;

  /// No description provided for @coinDetailsDexSourceNotice.
  ///
  /// In en, this message translates to:
  /// **'Pair data is provided by DexScreener.'**
  String get coinDetailsDexSourceNotice;

  /// No description provided for @coinDetailsDays.
  ///
  /// In en, this message translates to:
  /// **'{count}d'**
  String coinDetailsDays(int count);

  /// No description provided for @coinDetailsHours.
  ///
  /// In en, this message translates to:
  /// **'{count}h'**
  String coinDetailsHours(int count);

  /// No description provided for @coinDetailsMinutes.
  ///
  /// In en, this message translates to:
  /// **'{count}m'**
  String coinDetailsMinutes(int count);

  /// No description provided for @portfolioConnectTitle.
  ///
  /// In en, this message translates to:
  /// **'Connect Portfolio'**
  String get portfolioConnectTitle;

  /// No description provided for @portfolioReadOnlyApiConnection.
  ///
  /// In en, this message translates to:
  /// **'Read-only API connection'**
  String get portfolioReadOnlyApiConnection;

  /// No description provided for @portfolioWalletAddressConnection.
  ///
  /// In en, this message translates to:
  /// **'Wallet address connection'**
  String get portfolioWalletAddressConnection;

  /// No description provided for @portfolioConnected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get portfolioConnected;

  /// No description provided for @connectedAccountsYourAccounts.
  ///
  /// In en, this message translates to:
  /// **'Your connected accounts'**
  String get connectedAccountsYourAccounts;

  /// No description provided for @connectedAccountsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 connected account} other{{count} connected accounts}}'**
  String connectedAccountsCount(int count);

  /// No description provided for @connectedAccountsConnectDescription.
  ///
  /// In en, this message translates to:
  /// **'Connect your wallets and exchanges to use trading features inside Avexa.'**
  String get connectedAccountsConnectDescription;

  /// No description provided for @connectedAccountsRenameTitle.
  ///
  /// In en, this message translates to:
  /// **'Rename account'**
  String get connectedAccountsRenameTitle;

  /// No description provided for @connectedAccountsAccountName.
  ///
  /// In en, this message translates to:
  /// **'Account name'**
  String get connectedAccountsAccountName;

  /// No description provided for @connectedAccountsCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get connectedAccountsCancel;

  /// No description provided for @connectedAccountsSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get connectedAccountsSave;

  /// No description provided for @connectedAccountsRemoveTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove account?'**
  String get connectedAccountsRemoveTitle;

  /// No description provided for @connectedAccountsRemoveConfirmation.
  ///
  /// In en, this message translates to:
  /// **'This will remove {account} from Connected Accounts in Avexa.'**
  String connectedAccountsRemoveConfirmation(String account);

  /// No description provided for @connectedAccountsRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get connectedAccountsRemove;

  /// No description provided for @connectedAccountsChangeName.
  ///
  /// In en, this message translates to:
  /// **'Change name'**
  String get connectedAccountsChangeName;

  /// No description provided for @connectedAccountsNoAccounts.
  ///
  /// In en, this message translates to:
  /// **'No accounts connected'**
  String get connectedAccountsNoAccounts;

  /// No description provided for @connectedAccountsEmptyDescription.
  ///
  /// In en, this message translates to:
  /// **'Connect your first public wallet address to start building your Avexa portfolio.'**
  String get connectedAccountsEmptyDescription;

  /// No description provided for @connectedAccountsConnectPortfolio.
  ///
  /// In en, this message translates to:
  /// **'Connect Portfolio'**
  String get connectedAccountsConnectPortfolio;

  /// No description provided for @connectedAccountsBalancesNotice.
  ///
  /// In en, this message translates to:
  /// **'Your balances and assets remain in Portfolio.'**
  String get connectedAccountsBalancesNotice;

  /// No description provided for @connectedAccountsAddAccount.
  ///
  /// In en, this message translates to:
  /// **'Add Account'**
  String get connectedAccountsAddAccount;

  /// No description provided for @connectedAccountsReadOnlyApi.
  ///
  /// In en, this message translates to:
  /// **'Read-only API'**
  String get connectedAccountsReadOnlyApi;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Continue with your Avexa account'**
  String get loginSubtitle;

  /// No description provided for @loginEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get loginEmail;

  /// No description provided for @loginPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get loginPassword;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'LOGIN'**
  String get loginButton;

  /// No description provided for @loginOrContinueWith.
  ///
  /// In en, this message translates to:
  /// **'Or continue with'**
  String get loginOrContinueWith;

  /// No description provided for @loginForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get loginForgotPassword;

  /// No description provided for @loginNoAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get loginNoAccount;

  /// No description provided for @loginSignUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get loginSignUp;

  /// No description provided for @loginResetPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get loginResetPasswordTitle;

  /// No description provided for @loginResetPasswordDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter your email and we\'ll send you a link to reset your password.'**
  String get loginResetPasswordDescription;

  /// No description provided for @loginEnterEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get loginEnterEmail;

  /// No description provided for @loginSendResetLink.
  ///
  /// In en, this message translates to:
  /// **'SEND RESET LINK'**
  String get loginSendResetLink;

  /// No description provided for @loginCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get loginCancel;

  /// No description provided for @loginEnterEmailError.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address.'**
  String get loginEnterEmailError;

  /// No description provided for @loginInvalidEmailError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address.'**
  String get loginInvalidEmailError;

  /// No description provided for @loginResetGenericError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get loginResetGenericError;

  /// No description provided for @loginResetSuccess.
  ///
  /// In en, this message translates to:
  /// **'Reset link sent. Check your inbox.'**
  String get loginResetSuccess;

  /// No description provided for @loginAppleSignInFailed.
  ///
  /// In en, this message translates to:
  /// **'Apple Sign In failed: {message}'**
  String loginAppleSignInFailed(String message);

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get registerTitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start your AI trading journey.'**
  String get registerSubtitle;

  /// No description provided for @registerEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get registerEmail;

  /// No description provided for @registerPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get registerPassword;

  /// No description provided for @registerConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get registerConfirmPassword;

  /// No description provided for @registerButton.
  ///
  /// In en, this message translates to:
  /// **'CREATE ACCOUNT'**
  String get registerButton;

  /// No description provided for @registerPasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get registerPasswordMismatch;

  /// No description provided for @registerSuccess.
  ///
  /// In en, this message translates to:
  /// **'Account created successfully. Check your email.'**
  String get registerSuccess;

  /// No description provided for @registerGenericError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get registerGenericError;

  /// No description provided for @rugCheckTitle.
  ///
  /// In en, this message translates to:
  /// **'Rug Check'**
  String get rugCheckTitle;

  /// No description provided for @rugCheckHeadline.
  ///
  /// In en, this message translates to:
  /// **'Scan Before You Trade'**
  String get rugCheckHeadline;

  /// No description provided for @rugCheckDescription.
  ///
  /// In en, this message translates to:
  /// **'Check a token for potential security risks before entering a trade.'**
  String get rugCheckDescription;

  /// No description provided for @rugCheckTokenAddress.
  ///
  /// In en, this message translates to:
  /// **'TOKEN ADDRESS'**
  String get rugCheckTokenAddress;

  /// No description provided for @rugCheckAddressHint.
  ///
  /// In en, this message translates to:
  /// **'Paste Solana token address'**
  String get rugCheckAddressHint;

  /// No description provided for @rugCheckScanning.
  ///
  /// In en, this message translates to:
  /// **'SCANNING...'**
  String get rugCheckScanning;

  /// No description provided for @rugCheckScanButton.
  ///
  /// In en, this message translates to:
  /// **'SCAN TOKEN'**
  String get rugCheckScanButton;

  /// No description provided for @rugCheckWhatWeCheck.
  ///
  /// In en, this message translates to:
  /// **'What Avexa checks'**
  String get rugCheckWhatWeCheck;

  /// No description provided for @rugCheckLiquiditySecurity.
  ///
  /// In en, this message translates to:
  /// **'Liquidity & LP security'**
  String get rugCheckLiquiditySecurity;

  /// No description provided for @rugCheckHolderConcentration.
  ///
  /// In en, this message translates to:
  /// **'Holder concentration'**
  String get rugCheckHolderConcentration;

  /// No description provided for @rugCheckAuthorities.
  ///
  /// In en, this message translates to:
  /// **'Mint & freeze authorities'**
  String get rugCheckAuthorities;

  /// No description provided for @rugCheckDevExposure.
  ///
  /// In en, this message translates to:
  /// **'Developer wallet exposure'**
  String get rugCheckDevExposure;

  /// No description provided for @rugCheckEnterAddress.
  ///
  /// In en, this message translates to:
  /// **'Enter a token address first.'**
  String get rugCheckEnterAddress;

  /// No description provided for @rugCheckAnalysisTitle.
  ///
  /// In en, this message translates to:
  /// **'Token Security Analysis'**
  String get rugCheckAnalysisTitle;

  /// No description provided for @rugCheckTokenOverview.
  ///
  /// In en, this message translates to:
  /// **'TOKEN OVERVIEW'**
  String get rugCheckTokenOverview;

  /// No description provided for @rugCheckLiquidity.
  ///
  /// In en, this message translates to:
  /// **'Liquidity'**
  String get rugCheckLiquidity;

  /// No description provided for @rugCheckLpLocked.
  ///
  /// In en, this message translates to:
  /// **'LP Locked'**
  String get rugCheckLpLocked;

  /// No description provided for @rugCheckHolders.
  ///
  /// In en, this message translates to:
  /// **'Holders'**
  String get rugCheckHolders;

  /// No description provided for @rugCheckTopHolder.
  ///
  /// In en, this message translates to:
  /// **'Top Holder'**
  String get rugCheckTopHolder;

  /// No description provided for @rugCheckTop10Holders.
  ///
  /// In en, this message translates to:
  /// **'Top 10 Holders'**
  String get rugCheckTop10Holders;

  /// No description provided for @rugCheckSecurityChecks.
  ///
  /// In en, this message translates to:
  /// **'SECURITY CHECKS'**
  String get rugCheckSecurityChecks;

  /// No description provided for @rugCheckMintAuthority.
  ///
  /// In en, this message translates to:
  /// **'Mint Authority'**
  String get rugCheckMintAuthority;

  /// No description provided for @rugCheckFreezeAuthority.
  ///
  /// In en, this message translates to:
  /// **'Freeze Authority'**
  String get rugCheckFreezeAuthority;

  /// No description provided for @rugCheckDevWallet.
  ///
  /// In en, this message translates to:
  /// **'Dev Wallet'**
  String get rugCheckDevWallet;

  /// No description provided for @rugCheckEnabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get rugCheckEnabled;

  /// No description provided for @rugCheckDisabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get rugCheckDisabled;

  /// No description provided for @rugCheckUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get rugCheckUnknown;

  /// No description provided for @rugCheckExposure.
  ///
  /// In en, this message translates to:
  /// **'{value}% exposure'**
  String rugCheckExposure(String value);

  /// No description provided for @rugCheckDetectedRisks.
  ///
  /// In en, this message translates to:
  /// **'DETECTED RISKS'**
  String get rugCheckDetectedRisks;

  /// No description provided for @rugCheckNoRisks.
  ///
  /// In en, this message translates to:
  /// **'No significant risks were detected by the scanner.'**
  String get rugCheckNoRisks;

  /// No description provided for @rugCheckRiskDetected.
  ///
  /// In en, this message translates to:
  /// **'Risk detected'**
  String get rugCheckRiskDetected;

  /// No description provided for @rugCheckDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Rug Check analyzes available token security indicators. A low-risk score does not guarantee that a token is safe.'**
  String get rugCheckDisclaimer;

  /// No description provided for @rugCheckUnknownToken.
  ///
  /// In en, this message translates to:
  /// **'Unknown Token'**
  String get rugCheckUnknownToken;

  /// No description provided for @rugCheckUnavailable.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get rugCheckUnavailable;

  /// No description provided for @walletTrackerTitle.
  ///
  /// In en, this message translates to:
  /// **'Wallet Tracker'**
  String get walletTrackerTitle;

  /// No description provided for @walletTrackerAddWallet.
  ///
  /// In en, this message translates to:
  /// **'Add Wallet'**
  String get walletTrackerAddWallet;

  /// No description provided for @walletTrackerWalletName.
  ///
  /// In en, this message translates to:
  /// **'Wallet Name'**
  String get walletTrackerWalletName;

  /// No description provided for @walletTrackerWalletNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Smart Money'**
  String get walletTrackerWalletNameHint;

  /// No description provided for @walletTrackerWalletAddress.
  ///
  /// In en, this message translates to:
  /// **'Wallet Address'**
  String get walletTrackerWalletAddress;

  /// No description provided for @walletTrackerAddressHint.
  ///
  /// In en, this message translates to:
  /// **'Solana wallet address'**
  String get walletTrackerAddressHint;

  /// No description provided for @walletTrackerCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get walletTrackerCancel;

  /// No description provided for @walletTrackerAddError.
  ///
  /// In en, this message translates to:
  /// **'Could not add wallet'**
  String get walletTrackerAddError;

  /// No description provided for @walletTrackerYourWallets.
  ///
  /// In en, this message translates to:
  /// **'YOUR WALLETS'**
  String get walletTrackerYourWallets;

  /// No description provided for @walletTrackerTracked.
  ///
  /// In en, this message translates to:
  /// **'TRACKED'**
  String get walletTrackerTracked;

  /// No description provided for @walletTrackerEyebrow.
  ///
  /// In en, this message translates to:
  /// **'WALLET INTELLIGENCE'**
  String get walletTrackerEyebrow;

  /// No description provided for @walletTrackerHeroTitle.
  ///
  /// In en, this message translates to:
  /// **'Track Smart Money'**
  String get walletTrackerHeroTitle;

  /// No description provided for @walletTrackerHeroDescription.
  ///
  /// In en, this message translates to:
  /// **'Follow wallet activity and see what tracked wallets buy or sell.'**
  String get walletTrackerHeroDescription;

  /// No description provided for @walletTrackerLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load wallets'**
  String get walletTrackerLoadError;

  /// No description provided for @walletTrackerRetry.
  ///
  /// In en, this message translates to:
  /// **'Pull down to try again.'**
  String get walletTrackerRetry;

  /// No description provided for @walletTrackerEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No wallets added yet'**
  String get walletTrackerEmptyTitle;

  /// No description provided for @walletTrackerEmptyDescription.
  ///
  /// In en, this message translates to:
  /// **'Add a wallet to start tracking its activity.'**
  String get walletTrackerEmptyDescription;

  /// No description provided for @walletTrackerDefaultName.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get walletTrackerDefaultName;

  /// No description provided for @walletTrackerActive.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE'**
  String get walletTrackerActive;

  /// No description provided for @walletTrackerInactive.
  ///
  /// In en, this message translates to:
  /// **'INACTIVE'**
  String get walletTrackerInactive;

  /// No description provided for @walletTrackerAddButton.
  ///
  /// In en, this message translates to:
  /// **'ADD WALLET'**
  String get walletTrackerAddButton;

  /// No description provided for @languagePickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose language'**
  String get languagePickerTitle;

  /// No description provided for @languagePolish.
  ///
  /// In en, this message translates to:
  /// **'Polish'**
  String get languagePolish;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageGerman.
  ///
  /// In en, this message translates to:
  /// **'German'**
  String get languageGerman;

  /// No description provided for @languageJapanese.
  ///
  /// In en, this message translates to:
  /// **'Japanese'**
  String get languageJapanese;

  /// No description provided for @languageRussian.
  ///
  /// In en, this message translates to:
  /// **'Russian'**
  String get languageRussian;

  /// No description provided for @languageArabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get languageArabic;

  /// No description provided for @languageChinese.
  ///
  /// In en, this message translates to:
  /// **'Chinese'**
  String get languageChinese;

  /// No description provided for @languageSpanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get languageSpanish;

  /// No description provided for @languagePortuguese.
  ///
  /// In en, this message translates to:
  /// **'Portuguese'**
  String get languagePortuguese;

  /// No description provided for @deleteAccountSection.
  ///
  /// In en, this message translates to:
  /// **'DANGER ZONE'**
  String get deleteAccountSection;

  /// No description provided for @deleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccountTitle;

  /// No description provided for @deleteAccountDescription.
  ///
  /// In en, this message translates to:
  /// **'Permanently delete your Avexa account and all associated data.'**
  String get deleteAccountDescription;

  /// No description provided for @deleteAccountButton.
  ///
  /// In en, this message translates to:
  /// **'DELETE ACCOUNT'**
  String get deleteAccountButton;

  /// No description provided for @deleteAccountWarningTitle.
  ///
  /// In en, this message translates to:
  /// **'Are you sure?'**
  String get deleteAccountWarningTitle;

  /// No description provided for @deleteAccountWarningDescription.
  ///
  /// In en, this message translates to:
  /// **'This action is permanent and cannot be undone. Your profile, saved analyses, connected accounts and other associated data will be deleted.'**
  String get deleteAccountWarningDescription;

  /// No description provided for @deleteAccountSubscriptionWarning.
  ///
  /// In en, this message translates to:
  /// **'Important: Deleting your Avexa account does not cancel your Apple PRO subscription. You must cancel it separately in Settings → Apple Account → Subscriptions.'**
  String get deleteAccountSubscriptionWarning;

  /// No description provided for @deleteAccountConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Final confirmation'**
  String get deleteAccountConfirmTitle;

  /// No description provided for @deleteAccountConfirmDescription.
  ///
  /// In en, this message translates to:
  /// **'To permanently delete your account, type DELETE below.'**
  String get deleteAccountConfirmDescription;

  /// No description provided for @deleteAccountConfirmHint.
  ///
  /// In en, this message translates to:
  /// **'Type DELETE'**
  String get deleteAccountConfirmHint;

  /// No description provided for @deleteAccountConfirmButton.
  ///
  /// In en, this message translates to:
  /// **'PERMANENTLY DELETE'**
  String get deleteAccountConfirmButton;

  /// No description provided for @deleteAccountCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get deleteAccountCancel;

  /// No description provided for @deleteAccountDeleting.
  ///
  /// In en, this message translates to:
  /// **'Deleting account...'**
  String get deleteAccountDeleting;

  /// No description provided for @deleteAccountSuccess.
  ///
  /// In en, this message translates to:
  /// **'Your account has been permanently deleted.'**
  String get deleteAccountSuccess;

  /// No description provided for @deleteAccountError.
  ///
  /// In en, this message translates to:
  /// **'Could not delete your account. Please try again.'**
  String get deleteAccountError;

  /// No description provided for @deleteAccountConfirmationError.
  ///
  /// In en, this message translates to:
  /// **'Please type DELETE to confirm.'**
  String get deleteAccountConfirmationError;

  /// No description provided for @deleteAccountLoginRequired.
  ///
  /// In en, this message translates to:
  /// **'You must be logged in to delete your account.'**
  String get deleteAccountLoginRequired;

  /// No description provided for @portfolioWalletCount.
  ///
  /// In en, this message translates to:
  /// **'{count} / {max} wallets'**
  String portfolioWalletCount(int count, int max);

  /// No description provided for @portfolioNoWallets.
  ///
  /// In en, this message translates to:
  /// **'No wallets connected'**
  String get portfolioNoWallets;

  /// No description provided for @portfolioConnectSolanaWallet.
  ///
  /// In en, this message translates to:
  /// **'Connect a Solana wallet to view its balance.'**
  String get portfolioConnectSolanaWallet;

  /// No description provided for @portfolioConnectWallet.
  ///
  /// In en, this message translates to:
  /// **'Connect wallet'**
  String get portfolioConnectWallet;

  /// No description provided for @portfolioRefreshWallet.
  ///
  /// In en, this message translates to:
  /// **'Refresh wallet'**
  String get portfolioRefreshWallet;

  /// No description provided for @portfolioWalletPosition.
  ///
  /// In en, this message translates to:
  /// **'Wallet {current} of {total}'**
  String portfolioWalletPosition(int current, int total);

  /// No description provided for @portfolioLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get portfolioLoading;

  /// No description provided for @portfolioUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get portfolioUnavailable;

  /// No description provided for @portfolioWalletBalance.
  ///
  /// In en, this message translates to:
  /// **'Wallet balance'**
  String get portfolioWalletBalance;

  /// No description provided for @portfolioSwipeWallets.
  ///
  /// In en, this message translates to:
  /// **'Swipe sideways to view another wallet'**
  String get portfolioSwipeWallets;

  /// No description provided for @portfolioCombinedValue.
  ///
  /// In en, this message translates to:
  /// **'Combined value of all wallets'**
  String get portfolioCombinedValue;

  /// No description provided for @portfolioConnectedWallets.
  ///
  /// In en, this message translates to:
  /// **'Connected wallets'**
  String get portfolioConnectedWallets;

  /// No description provided for @portfolioConnectedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} connected'**
  String portfolioConnectedCount(int count);

  /// No description provided for @portfolioWalletAddressesConnected.
  ///
  /// In en, this message translates to:
  /// **'Wallet addresses connected'**
  String get portfolioWalletAddressesConnected;

  /// No description provided for @portfolioManageAddressesNetworks.
  ///
  /// In en, this message translates to:
  /// **'Manage your addresses and networks'**
  String get portfolioManageAddressesNetworks;

  /// No description provided for @portfolioConnectPublicAddress.
  ///
  /// In en, this message translates to:
  /// **'Connect a public wallet address to begin'**
  String get portfolioConnectPublicAddress;

  /// No description provided for @portfolioMaxWalletsReached.
  ///
  /// In en, this message translates to:
  /// **'Maximum 3 wallets reached'**
  String get portfolioMaxWalletsReached;

  /// No description provided for @portfolioAddAnotherWallet.
  ///
  /// In en, this message translates to:
  /// **'Add another wallet'**
  String get portfolioAddAnotherWallet;

  /// No description provided for @portfolioConnectToBuild.
  ///
  /// In en, this message translates to:
  /// **'Connect a wallet to start building your portfolio.'**
  String get portfolioConnectToBuild;

  /// No description provided for @portfolioAssetsSyncPending.
  ///
  /// In en, this message translates to:
  /// **'Wallet addresses are connected. Asset synchronization has not been implemented yet.'**
  String get portfolioAssetsSyncPending;

  /// No description provided for @portfolioAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Portfolio analytics'**
  String get portfolioAnalytics;

  /// No description provided for @portfolioAnalyticsDescription.
  ///
  /// In en, this message translates to:
  /// **'Historical performance, allocation analysis and AI insights will become available after real wallet balances and portfolio history are synchronized.'**
  String get portfolioAnalyticsDescription;

  /// No description provided for @portfolioLoadError.
  ///
  /// In en, this message translates to:
  /// **'Unable to load portfolio.'**
  String get portfolioLoadError;

  /// No description provided for @portfolioSyncError.
  ///
  /// In en, this message translates to:
  /// **'Unable to synchronize wallet balances.'**
  String get portfolioSyncError;

  /// No description provided for @portfolioDefaultUser.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get portfolioDefaultUser;

  /// No description provided for @loginLegalNotice.
  ///
  /// In en, this message translates to:
  /// **'By creating an account or logging in, you confirm that you are at least 16 years old and acknowledge the legal documents below.'**
  String get loginLegalNotice;

  /// No description provided for @loginLegalTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get loginLegalTerms;

  /// No description provided for @loginLegalPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get loginLegalPrivacy;

  /// No description provided for @loginLegalRisk.
  ///
  /// In en, this message translates to:
  /// **'Risk Disclaimer'**
  String get loginLegalRisk;

  /// No description provided for @connectedAccountsAddressCopied.
  ///
  /// In en, this message translates to:
  /// **'Wallet address copied.'**
  String get connectedAccountsAddressCopied;

  /// No description provided for @connectedAccountsRenameWallet.
  ///
  /// In en, this message translates to:
  /// **'Rename wallet'**
  String get connectedAccountsRenameWallet;

  /// No description provided for @connectedAccountsWalletNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Main Wallet'**
  String get connectedAccountsWalletNameHint;

  /// No description provided for @connectedAccountsRenameSuccess.
  ///
  /// In en, this message translates to:
  /// **'Wallet name updated.'**
  String get connectedAccountsRenameSuccess;

  /// No description provided for @connectedAccountsRenameError.
  ///
  /// In en, this message translates to:
  /// **'Unable to rename wallet: {error}'**
  String connectedAccountsRenameError(String error);

  /// No description provided for @connectedAccountsRemoveWalletTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove wallet?'**
  String get connectedAccountsRemoveWalletTitle;

  /// No description provided for @connectedAccountsRemoveWalletDescription.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove this address from Avexa? You can add it again at any time.'**
  String get connectedAccountsRemoveWalletDescription;

  /// No description provided for @connectedAccountsRemoveSuccess.
  ///
  /// In en, this message translates to:
  /// **'Wallet removed successfully.'**
  String get connectedAccountsRemoveSuccess;

  /// No description provided for @connectedAccountsRemoveError.
  ///
  /// In en, this message translates to:
  /// **'Unable to remove wallet: {error}'**
  String connectedAccountsRemoveError(String error);

  /// No description provided for @connectedAccountsHeader.
  ///
  /// In en, this message translates to:
  /// **'Connected wallets'**
  String get connectedAccountsHeader;

  /// No description provided for @connectedAccountsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage your blockchain addresses'**
  String get connectedAccountsSubtitle;

  /// No description provided for @connectedAccountsConnectedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} CONNECTED'**
  String connectedAccountsConnectedCount(int count);

  /// No description provided for @connectedAccountsHeaderDescription.
  ///
  /// In en, this message translates to:
  /// **'All your wallets are managed in one place. Each address is tracked separately by its blockchain network.'**
  String get connectedAccountsHeaderDescription;

  /// No description provided for @connectedAccountsWallet.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get connectedAccountsWallet;

  /// No description provided for @connectedAccountsRename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get connectedAccountsRename;

  /// No description provided for @connectedAccountsRemoveWallet.
  ///
  /// In en, this message translates to:
  /// **'Remove wallet'**
  String get connectedAccountsRemoveWallet;

  /// No description provided for @connectedAccountsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No wallets connected yet'**
  String get connectedAccountsEmptyTitle;

  /// No description provided for @connectedAccountsConnectWallet.
  ///
  /// In en, this message translates to:
  /// **'Connect wallet'**
  String get connectedAccountsConnectWallet;

  /// No description provided for @connectedAccountsLegacyNotice.
  ///
  /// In en, this message translates to:
  /// **'{count} older connection(s) are saved from the previous Portfolio system. They have been preserved and are not included in the new wallet list.'**
  String connectedAccountsLegacyNotice(int count);

  /// No description provided for @connectedAccountsRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get connectedAccountsRefresh;

  /// No description provided for @connectedAccountsYourWallets.
  ///
  /// In en, this message translates to:
  /// **'Your wallets'**
  String get connectedAccountsYourWallets;

  /// No description provided for @connectedAccountsAddWallet.
  ///
  /// In en, this message translates to:
  /// **'Add wallet'**
  String get connectedAccountsAddWallet;

  /// No description provided for @connectPortfolioSolanaDescription.
  ///
  /// In en, this message translates to:
  /// **'Solana blockchain'**
  String get connectPortfolioSolanaDescription;

  /// No description provided for @connectPortfolioEthereumDescription.
  ///
  /// In en, this message translates to:
  /// **'Ethereum mainnet'**
  String get connectPortfolioEthereumDescription;

  /// No description provided for @connectPortfolioBaseDescription.
  ///
  /// In en, this message translates to:
  /// **'Base network'**
  String get connectPortfolioBaseDescription;

  /// No description provided for @connectPortfolioArbitrumDescription.
  ///
  /// In en, this message translates to:
  /// **'Arbitrum One'**
  String get connectPortfolioArbitrumDescription;

  /// No description provided for @connectPortfolioPolygonDescription.
  ///
  /// In en, this message translates to:
  /// **'Polygon PoS'**
  String get connectPortfolioPolygonDescription;

  /// No description provided for @connectPortfolioEnterAddress.
  ///
  /// In en, this message translates to:
  /// **'Please enter a wallet address.'**
  String get connectPortfolioEnterAddress;

  /// No description provided for @connectPortfolioInvalidSolanaAddress.
  ///
  /// In en, this message translates to:
  /// **'Invalid Solana wallet address.'**
  String get connectPortfolioInvalidSolanaAddress;

  /// No description provided for @connectPortfolioInvalidNetworkAddress.
  ///
  /// In en, this message translates to:
  /// **'Invalid {network} wallet address.'**
  String connectPortfolioInvalidNetworkAddress(String network);

  /// No description provided for @connectPortfolioAlreadyConnected.
  ///
  /// In en, this message translates to:
  /// **'This address is already connected to {network}.'**
  String connectPortfolioAlreadyConnected(String network);

  /// No description provided for @connectPortfolioSuccess.
  ///
  /// In en, this message translates to:
  /// **'{network} wallet connected successfully.'**
  String connectPortfolioSuccess(String network);

  /// No description provided for @connectPortfolioError.
  ///
  /// In en, this message translates to:
  /// **'Unable to connect wallet. Please try again.'**
  String get connectPortfolioError;

  /// No description provided for @connectPortfolioSelectNetwork.
  ///
  /// In en, this message translates to:
  /// **'Select network'**
  String get connectPortfolioSelectNetwork;

  /// No description provided for @connectPortfolioChooseNetwork.
  ///
  /// In en, this message translates to:
  /// **'Choose a blockchain network'**
  String get connectPortfolioChooseNetwork;

  /// No description provided for @connectPortfolioSectionNetwork.
  ///
  /// In en, this message translates to:
  /// **'01  Select network'**
  String get connectPortfolioSectionNetwork;

  /// No description provided for @connectPortfolioSectionNetworkSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose the blockchain where your wallet exists.'**
  String get connectPortfolioSectionNetworkSubtitle;

  /// No description provided for @connectPortfolioSectionAddress.
  ///
  /// In en, this message translates to:
  /// **'02  Wallet address'**
  String get connectPortfolioSectionAddress;

  /// No description provided for @connectPortfolioSectionAddressSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Paste your public wallet address.'**
  String get connectPortfolioSectionAddressSubtitle;

  /// No description provided for @connectPortfolioAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'{network} address'**
  String connectPortfolioAddressLabel(String network);

  /// No description provided for @connectPortfolioSolanaAddressHint.
  ///
  /// In en, this message translates to:
  /// **'Paste your Solana address'**
  String get connectPortfolioSolanaAddressHint;

  /// No description provided for @connectPortfolioSectionWalletName.
  ///
  /// In en, this message translates to:
  /// **'03  Wallet name'**
  String get connectPortfolioSectionWalletName;

  /// No description provided for @connectPortfolioSectionWalletNameSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Optional. Give this address a recognizable name.'**
  String get connectPortfolioSectionWalletNameSubtitle;

  /// No description provided for @connectPortfolioCustomNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Custom name (optional)'**
  String get connectPortfolioCustomNameLabel;

  /// No description provided for @connectPortfolioCustomNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Main Wallet'**
  String get connectPortfolioCustomNameHint;

  /// No description provided for @connectPortfolioSecurityTitle.
  ///
  /// In en, this message translates to:
  /// **'Your assets stay yours.'**
  String get connectPortfolioSecurityTitle;

  /// No description provided for @connectPortfolioSecurityDescription.
  ///
  /// In en, this message translates to:
  /// **'Avexa only uses publicly available blockchain data. We never ask for private keys, Secret Keys or API credentials, and cannot execute transactions from your wallet.'**
  String get connectPortfolioSecurityDescription;

  /// No description provided for @connectPortfolioHeader.
  ///
  /// In en, this message translates to:
  /// **'Connect your wallet'**
  String get connectPortfolioHeader;

  /// No description provided for @connectPortfolioSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add a public wallet address to track your assets across multiple blockchain networks in one portfolio.'**
  String get connectPortfolioSubtitle;

  /// No description provided for @connectPortfolioButton.
  ///
  /// In en, this message translates to:
  /// **'CONNECT WALLET'**
  String get connectPortfolioButton;

  /// No description provided for @walletTrackerEnterWalletDetails.
  ///
  /// In en, this message translates to:
  /// **'Enter a wallet name and address.'**
  String get walletTrackerEnterWalletDetails;

  /// No description provided for @walletTrackerSyncComplete.
  ///
  /// In en, this message translates to:
  /// **'Sync complete: wallets {wallets}, checked {checked}, swaps {swaps}, inserted {inserted}.'**
  String walletTrackerSyncComplete(
    int wallets,
    int checked,
    int swaps,
    int inserted,
  );

  /// No description provided for @walletTrackerSyncError.
  ///
  /// In en, this message translates to:
  /// **'Wallet sync error: {error}'**
  String walletTrackerSyncError(String error);

  /// No description provided for @walletDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Wallet Details'**
  String get walletDetailsTitle;

  /// No description provided for @walletDetailsRename.
  ///
  /// In en, this message translates to:
  /// **'Rename wallet'**
  String get walletDetailsRename;

  /// No description provided for @walletDetailsLiveActivity.
  ///
  /// In en, this message translates to:
  /// **'LIVE WALLET ACTIVITY'**
  String get walletDetailsLiveActivity;

  /// No description provided for @walletDetailsTransactionCount.
  ///
  /// In en, this message translates to:
  /// **'{count} TRANSACTIONS'**
  String walletDetailsTransactionCount(int count);

  /// No description provided for @walletDetailsRefreshActivity.
  ///
  /// In en, this message translates to:
  /// **'Refresh wallet activity'**
  String get walletDetailsRefreshActivity;

  /// No description provided for @walletDetailsNotifications.
  ///
  /// In en, this message translates to:
  /// **'NOTIFICATIONS'**
  String get walletDetailsNotifications;

  /// No description provided for @walletDetailsSaving.
  ///
  /// In en, this message translates to:
  /// **'SAVING...'**
  String get walletDetailsSaving;

  /// No description provided for @walletDetailsActive.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE'**
  String get walletDetailsActive;

  /// No description provided for @walletDetailsRefreshing.
  ///
  /// In en, this message translates to:
  /// **'Refreshing activity...'**
  String get walletDetailsRefreshing;

  /// No description provided for @walletDetailsNoTransactions.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet'**
  String get walletDetailsNoTransactions;

  /// No description provided for @walletDetailsActivityDescription.
  ///
  /// In en, this message translates to:
  /// **'Wallet activity will appear here.'**
  String get walletDetailsActivityDescription;

  /// No description provided for @walletDetailsBuy.
  ///
  /// In en, this message translates to:
  /// **'BUY'**
  String get walletDetailsBuy;

  /// No description provided for @walletDetailsSell.
  ///
  /// In en, this message translates to:
  /// **'SELL'**
  String get walletDetailsSell;

  /// No description provided for @walletDetailsTransaction.
  ///
  /// In en, this message translates to:
  /// **'TRANSACTION'**
  String get walletDetailsTransaction;

  /// No description provided for @walletDetailsWalletAlerts.
  ///
  /// In en, this message translates to:
  /// **'Wallet Alerts'**
  String get walletDetailsWalletAlerts;

  /// No description provided for @walletDetailsWalletAlertsDescription.
  ///
  /// In en, this message translates to:
  /// **'Enable notifications for this wallet'**
  String get walletDetailsWalletAlertsDescription;

  /// No description provided for @walletDetailsBuyAlerts.
  ///
  /// In en, this message translates to:
  /// **'Buy Alerts'**
  String get walletDetailsBuyAlerts;

  /// No description provided for @walletDetailsBuyAlertsDescription.
  ///
  /// In en, this message translates to:
  /// **'Notify when this wallet buys'**
  String get walletDetailsBuyAlertsDescription;

  /// No description provided for @walletDetailsSellAlerts.
  ///
  /// In en, this message translates to:
  /// **'Sell Alerts'**
  String get walletDetailsSellAlerts;

  /// No description provided for @walletDetailsSellAlertsDescription.
  ///
  /// In en, this message translates to:
  /// **'Notify when this wallet sells'**
  String get walletDetailsSellAlertsDescription;

  /// No description provided for @walletDetailsLargeTransactions.
  ///
  /// In en, this message translates to:
  /// **'Large Transactions'**
  String get walletDetailsLargeTransactions;

  /// No description provided for @walletDetailsLargeTransactionsDescription.
  ///
  /// In en, this message translates to:
  /// **'Notify about large wallet movements'**
  String get walletDetailsLargeTransactionsDescription;

  /// No description provided for @walletDetailsDeleteWallet.
  ///
  /// In en, this message translates to:
  /// **'Delete Wallet'**
  String get walletDetailsDeleteWallet;

  /// No description provided for @walletDetailsDeleteWalletDescription.
  ///
  /// In en, this message translates to:
  /// **'Remove this wallet and its history'**
  String get walletDetailsDeleteWalletDescription;

  /// No description provided for @walletDetailsDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Wallet?'**
  String get walletDetailsDeleteTitle;

  /// No description provided for @walletDetailsDeleteDescription.
  ///
  /// In en, this message translates to:
  /// **'This wallet and its tracked transaction history will be removed.'**
  String get walletDetailsDeleteDescription;

  /// No description provided for @walletDetailsCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get walletDetailsCancel;

  /// No description provided for @walletDetailsDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get walletDetailsDelete;

  /// No description provided for @walletDetailsSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get walletDetailsSave;

  /// No description provided for @walletDetailsRenameTitle.
  ///
  /// In en, this message translates to:
  /// **'Rename Wallet'**
  String get walletDetailsRenameTitle;

  /// No description provided for @walletDetailsWalletNameHint.
  ///
  /// In en, this message translates to:
  /// **'Wallet name'**
  String get walletDetailsWalletNameHint;

  /// No description provided for @walletDetailsUnknownTime.
  ///
  /// In en, this message translates to:
  /// **'Unknown time'**
  String get walletDetailsUnknownTime;

  /// No description provided for @walletDetailsSyncComplete.
  ///
  /// In en, this message translates to:
  /// **'Wallet synced. Checked {count} transactions.'**
  String walletDetailsSyncComplete(int count);

  /// No description provided for @walletDetailsSyncError.
  ///
  /// In en, this message translates to:
  /// **'Could not sync wallet. Check the logs.'**
  String get walletDetailsSyncError;

  /// No description provided for @walletDetailsUpdateSettingsError.
  ///
  /// In en, this message translates to:
  /// **'Could not update wallet settings.'**
  String get walletDetailsUpdateSettingsError;

  /// No description provided for @walletDetailsRenameError.
  ///
  /// In en, this message translates to:
  /// **'Could not rename wallet.'**
  String get walletDetailsRenameError;

  /// No description provided for @walletDetailsDeleteError.
  ///
  /// In en, this message translates to:
  /// **'Could not delete wallet.'**
  String get walletDetailsDeleteError;

  /// No description provided for @liveMarketLive.
  ///
  /// In en, this message translates to:
  /// **'LIVE'**
  String get liveMarketLive;

  /// No description provided for @liveMarketUpdateInterval.
  ///
  /// In en, this message translates to:
  /// **'Updates every 30s'**
  String get liveMarketUpdateInterval;

  /// No description provided for @liveMarket24hLabel.
  ///
  /// In en, this message translates to:
  /// **'24h Market'**
  String get liveMarket24hLabel;

  /// No description provided for @liveMarketLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading live market data...'**
  String get liveMarketLoading;

  /// No description provided for @liveMarketError.
  ///
  /// In en, this message translates to:
  /// **'Unable to load live market data.'**
  String get liveMarketError;

  /// No description provided for @liveMarketEmpty.
  ///
  /// In en, this message translates to:
  /// **'No market data available.'**
  String get liveMarketEmpty;

  /// No description provided for @communityPartnersTitle.
  ///
  /// In en, this message translates to:
  /// **'AVEXA COMMUNITY'**
  String get communityPartnersTitle;

  /// No description provided for @communityPartnersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Join communities we work with'**
  String get communityPartnersSubtitle;

  /// No description provided for @communityPartnersDefaultName.
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get communityPartnersDefaultName;

  /// No description provided for @communityPartnersTelegramError.
  ///
  /// In en, this message translates to:
  /// **'Unable to open Telegram.'**
  String get communityPartnersTelegramError;

  /// No description provided for @marketSentimentTitle.
  ///
  /// In en, this message translates to:
  /// **'Market Sentiment'**
  String get marketSentimentTitle;

  /// No description provided for @marketSentimentLoading.
  ///
  /// In en, this message translates to:
  /// **'LOADING'**
  String get marketSentimentLoading;

  /// No description provided for @marketSentimentFear.
  ///
  /// In en, this message translates to:
  /// **'Fear'**
  String get marketSentimentFear;

  /// No description provided for @marketSentimentNeutral.
  ///
  /// In en, this message translates to:
  /// **'Neutral'**
  String get marketSentimentNeutral;

  /// No description provided for @marketSentimentGreed.
  ///
  /// In en, this message translates to:
  /// **'Greed'**
  String get marketSentimentGreed;

  /// No description provided for @marketSentimentExtremeGreed.
  ///
  /// In en, this message translates to:
  /// **'EXTREME GREED'**
  String get marketSentimentExtremeGreed;

  /// No description provided for @marketSentimentExtremeFear.
  ///
  /// In en, this message translates to:
  /// **'EXTREME FEAR'**
  String get marketSentimentExtremeFear;

  /// No description provided for @marketSentimentBalanced.
  ///
  /// In en, this message translates to:
  /// **'Market conditions are currently balanced.'**
  String get marketSentimentBalanced;

  /// No description provided for @marketSentimentStrongBullish.
  ///
  /// In en, this message translates to:
  /// **'Strong bullish momentum is visible across the market.'**
  String get marketSentimentStrongBullish;

  /// No description provided for @marketSentimentBullish.
  ///
  /// In en, this message translates to:
  /// **'Bullish momentum is currently dominating the market.'**
  String get marketSentimentBullish;

  /// No description provided for @marketSentimentBearish.
  ///
  /// In en, this message translates to:
  /// **'Bearish pressure is building across the market.'**
  String get marketSentimentBearish;

  /// No description provided for @marketSentimentStrongBearish.
  ///
  /// In en, this message translates to:
  /// **'Strong bearish pressure is dominating the market.'**
  String get marketSentimentStrongBearish;

  /// No description provided for @marketSentimentError.
  ///
  /// In en, this message translates to:
  /// **'Unable to load market sentiment.'**
  String get marketSentimentError;

  /// No description provided for @marketSentimentLoadingDescription.
  ///
  /// In en, this message translates to:
  /// **'Analyzing current market conditions...'**
  String get marketSentimentLoadingDescription;

  /// No description provided for @marketSentimentLiveUpdates.
  ///
  /// In en, this message translates to:
  /// **'LIVE • Updates every 30s'**
  String get marketSentimentLiveUpdates;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'de',
    'en',
    'es',
    'ja',
    'pl',
    'pt',
    'ru',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'ja':
      return AppLocalizationsJa();
    case 'pl':
      return AppLocalizationsPl();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
