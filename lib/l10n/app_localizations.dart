import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_sw.dart';
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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('en'),
    Locale('sw'),
    Locale('zh'),
  ];

  /// The app name
  ///
  /// In en, this message translates to:
  /// **'Velie'**
  String get appTitle;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get loading;

  /// No description provided for @understood.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get understood;

  /// No description provided for @helpTitle.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get helpTitle;

  /// No description provided for @errorUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown error'**
  String get errorUnknown;

  /// No description provided for @pressAgainToExit.
  ///
  /// In en, this message translates to:
  /// **'Press again to exit'**
  String get pressAgainToExit;

  /// No description provided for @selectStatusType.
  ///
  /// In en, this message translates to:
  /// **'Select Status Type'**
  String get selectStatusType;

  /// No description provided for @videoStatus.
  ///
  /// In en, this message translates to:
  /// **'Video Status'**
  String get videoStatus;

  /// No description provided for @textStatus.
  ///
  /// In en, this message translates to:
  /// **'Text Status'**
  String get textStatus;

  /// No description provided for @imageStatus.
  ///
  /// In en, this message translates to:
  /// **'Image Status'**
  String get imageStatus;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to Velie'**
  String get loginTitle;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get noAccount;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed: {error}'**
  String loginFailed(String error);

  /// No description provided for @phoneNotLinked.
  ///
  /// In en, this message translates to:
  /// **'Number Not Linked'**
  String get phoneNotLinked;

  /// No description provided for @phoneRegisteredNotLinked.
  ///
  /// In en, this message translates to:
  /// **'Your number is registered but not linked to WhatsApp. Continue linking or register another number?'**
  String get phoneRegisteredNotLinked;

  /// No description provided for @continueToConnect.
  ///
  /// In en, this message translates to:
  /// **'Continue to Connect'**
  String get continueToConnect;

  /// No description provided for @registerOtherNumber.
  ///
  /// In en, this message translates to:
  /// **'Register Another Number'**
  String get registerOtherNumber;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get registerTitle;

  /// No description provided for @yourName.
  ///
  /// In en, this message translates to:
  /// **'Your Name'**
  String get yourName;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @repeatPassword.
  ///
  /// In en, this message translates to:
  /// **'Repeat Password'**
  String get repeatPassword;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @registerFailed.
  ///
  /// In en, this message translates to:
  /// **'Registration failed: {error}'**
  String registerFailed(String error);

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get forgotPasswordTitle;

  /// No description provided for @recoverAccount.
  ///
  /// In en, this message translates to:
  /// **'Recover Account'**
  String get recoverAccount;

  /// No description provided for @recoverAccountBody.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number to receive an OTP via WhatsApp.'**
  String get recoverAccountBody;

  /// No description provided for @phoneNumberOrUsername.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumberOrUsername;

  /// No description provided for @sendOtp.
  ///
  /// In en, this message translates to:
  /// **'Send OTP'**
  String get sendOtp;

  /// No description provided for @cannotSendCode.
  ///
  /// In en, this message translates to:
  /// **'Cannot send code: {error}'**
  String cannotSendCode(String error);

  /// No description provided for @verifyOtpTitle.
  ///
  /// In en, this message translates to:
  /// **'Verify OTP'**
  String get verifyOtpTitle;

  /// No description provided for @enterOtp.
  ///
  /// In en, this message translates to:
  /// **'Enter OTP'**
  String get enterOtp;

  /// No description provided for @otpSentTo.
  ///
  /// In en, this message translates to:
  /// **'We sent a code to {phone} via WhatsApp.'**
  String otpSentTo(String phone);

  /// No description provided for @otpCode.
  ///
  /// In en, this message translates to:
  /// **'OTP Code'**
  String get otpCode;

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// No description provided for @codeExpiresIn.
  ///
  /// In en, this message translates to:
  /// **'Code expires in {seconds}s'**
  String codeExpiresIn(int seconds);

  /// No description provided for @codeExpired.
  ///
  /// In en, this message translates to:
  /// **'Code expired.'**
  String get codeExpired;

  /// No description provided for @resend.
  ///
  /// In en, this message translates to:
  /// **'Resend'**
  String get resend;

  /// No description provided for @otpInvalid.
  ///
  /// In en, this message translates to:
  /// **'Code not accepted: {error}'**
  String otpInvalid(String error);

  /// No description provided for @newPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPasswordTitle;

  /// No description provided for @setNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Set New Password'**
  String get setNewPassword;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Make sure it is at least 6 characters.'**
  String get passwordMinLength;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Too short'**
  String get passwordTooShort;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @resetAndLogin.
  ///
  /// In en, this message translates to:
  /// **'Reset & Login'**
  String get resetAndLogin;

  /// No description provided for @passwordResetSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password reset successfully!'**
  String get passwordResetSuccess;

  /// No description provided for @passwordResetFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to change password: {error}'**
  String passwordResetFailed(String error);

  /// No description provided for @connectWhatsapp.
  ///
  /// In en, this message translates to:
  /// **'Connect WhatsApp'**
  String get connectWhatsapp;

  /// No description provided for @pairingCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'PAIRING CODE'**
  String get pairingCodeLabel;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @codeCopied.
  ///
  /// In en, this message translates to:
  /// **'Code copied'**
  String get codeCopied;

  /// No description provided for @connected.
  ///
  /// In en, this message translates to:
  /// **'Connected ✓'**
  String get connected;

  /// No description provided for @redirectingToDashboard.
  ///
  /// In en, this message translates to:
  /// **'Redirecting to dashboard…'**
  String get redirectingToDashboard;

  /// No description provided for @getNewCode.
  ///
  /// In en, this message translates to:
  /// **'Get New Code'**
  String get getNewCode;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// No description provided for @rateLimited.
  ///
  /// In en, this message translates to:
  /// **'Rate limit reached'**
  String get rateLimited;

  /// No description provided for @cannotConnectToServer.
  ///
  /// In en, this message translates to:
  /// **'Cannot connect to server'**
  String get cannotConnectToServer;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @cannotGetNewCode.
  ///
  /// In en, this message translates to:
  /// **'Could not get new code: {error}'**
  String cannotGetNewCode(String error);

  /// No description provided for @connectedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Connected! ✓'**
  String get connectedSnackbar;

  /// No description provided for @howToConnect.
  ///
  /// In en, this message translates to:
  /// **'How to Connect'**
  String get howToConnect;

  /// No description provided for @connectStep1.
  ///
  /// In en, this message translates to:
  /// **'Open WhatsApp on your phone'**
  String get connectStep1;

  /// No description provided for @connectStep2.
  ///
  /// In en, this message translates to:
  /// **'Go to: Settings → Linked Devices'**
  String get connectStep2;

  /// No description provided for @connectStep3.
  ///
  /// In en, this message translates to:
  /// **'Tap \"Link a Device\"'**
  String get connectStep3;

  /// No description provided for @connectStep4.
  ///
  /// In en, this message translates to:
  /// **'Choose \"Link with Phone Number\"'**
  String get connectStep4;

  /// No description provided for @connectStep5.
  ///
  /// In en, this message translates to:
  /// **'Enter the code shown here in WhatsApp'**
  String get connectStep5;

  /// No description provided for @signOutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign Out?'**
  String get signOutConfirmTitle;

  /// No description provided for @signOutConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your registration and start over?'**
  String get signOutConfirmBody;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @dashboardNoPosts.
  ///
  /// In en, this message translates to:
  /// **'No posts yet'**
  String get dashboardNoPosts;

  /// No description provided for @totalStatus.
  ///
  /// In en, this message translates to:
  /// **'Total Status'**
  String get totalStatus;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @sent.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get sent;

  /// No description provided for @failed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get failed;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @logoutButton.
  ///
  /// In en, this message translates to:
  /// **'Sign out of account'**
  String get logoutButton;

  /// No description provided for @logoutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign Out?'**
  String get logoutConfirmTitle;

  /// No description provided for @logoutConfirmContent.
  ///
  /// In en, this message translates to:
  /// **'You will be removed from your Velie account.'**
  String get logoutConfirmContent;

  /// No description provided for @disconnectWhatsappTitle.
  ///
  /// In en, this message translates to:
  /// **'Disconnect WhatsApp?'**
  String get disconnectWhatsappTitle;

  /// No description provided for @disconnectWhatsappContent.
  ///
  /// In en, this message translates to:
  /// **'This WhatsApp number will be disconnected from Velie. Scheduled posts will be paused.'**
  String get disconnectWhatsappContent;

  /// No description provided for @disconnect.
  ///
  /// In en, this message translates to:
  /// **'Disconnect'**
  String get disconnect;

  /// No description provided for @languageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageTitle;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @reportProblemTitle.
  ///
  /// In en, this message translates to:
  /// **'Report a Problem'**
  String get reportProblemTitle;

  /// No description provided for @feedback.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get feedback;

  /// No description provided for @linkedAccounts.
  ///
  /// In en, this message translates to:
  /// **'Linked Accounts'**
  String get linkedAccounts;

  /// No description provided for @whatsappPrimaryNumber.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp (Primary number)'**
  String get whatsappPrimaryNumber;

  /// No description provided for @whatsappConnected.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp connected'**
  String get whatsappConnected;

  /// No description provided for @notConnected.
  ///
  /// In en, this message translates to:
  /// **'Not connected'**
  String get notConnected;

  /// No description provided for @sendMessage.
  ///
  /// In en, this message translates to:
  /// **'Send Message'**
  String get sendMessage;

  /// No description provided for @describeProblem.
  ///
  /// In en, this message translates to:
  /// **'Describe your problem here…'**
  String get describeProblem;

  /// No description provided for @messageSentSuccess.
  ///
  /// In en, this message translates to:
  /// **'Your message was sent successfully.'**
  String get messageSentSuccess;

  /// No description provided for @messageSentFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to send message.'**
  String get messageSentFailed;

  /// No description provided for @createdLabel.
  ///
  /// In en, this message translates to:
  /// **'Created:'**
  String get createdLabel;

  /// No description provided for @unknownValue.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknownValue;

  /// No description provided for @connectionLostTitle.
  ///
  /// In en, this message translates to:
  /// **'Connection Lost'**
  String get connectionLostTitle;

  /// No description provided for @connectionLostBody.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp was removed from Linked Devices on your phone. Reconnect to continue posting statuses.'**
  String get connectionLostBody;

  /// No description provided for @reconnect.
  ///
  /// In en, this message translates to:
  /// **'Reconnect'**
  String get reconnect;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending;

  /// No description provided for @statusSent.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get statusSent;

  /// No description provided for @statusFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get statusFailed;

  /// No description provided for @statusDeleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted'**
  String get statusDeleted;

  /// No description provided for @statusUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get statusUnknown;

  /// No description provided for @repeatOnce.
  ///
  /// In en, this message translates to:
  /// **'Once'**
  String get repeatOnce;

  /// No description provided for @repeatWeekdays.
  ///
  /// In en, this message translates to:
  /// **'Mon–Fri'**
  String get repeatWeekdays;

  /// No description provided for @repeatDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get repeatDaily;

  /// No description provided for @repeatWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get repeatWeekly;

  /// No description provided for @repeatMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get repeatMonthly;

  /// No description provided for @repeatOnceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Send once only'**
  String get repeatOnceSubtitle;

  /// No description provided for @repeatWeekdaysSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Send Mon to Fri every week'**
  String get repeatWeekdaysSubtitle;

  /// No description provided for @repeatDailySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Send every day'**
  String get repeatDailySubtitle;

  /// No description provided for @repeatWeeklySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Send every week'**
  String get repeatWeeklySubtitle;

  /// No description provided for @repeatMonthlySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Send every month'**
  String get repeatMonthlySubtitle;

  /// No description provided for @apiErrorTimeout.
  ///
  /// In en, this message translates to:
  /// **'Connection timed out — check your network'**
  String get apiErrorTimeout;

  /// No description provided for @apiErrorConnectionFailed.
  ///
  /// In en, this message translates to:
  /// **'Cannot connect to server'**
  String get apiErrorConnectionFailed;

  /// No description provided for @apiErrorUnauthorized.
  ///
  /// In en, this message translates to:
  /// **'Authorization denied (401)'**
  String get apiErrorUnauthorized;

  /// No description provided for @apiErrorNotFound.
  ///
  /// In en, this message translates to:
  /// **'No information found (404)'**
  String get apiErrorNotFound;

  /// No description provided for @apiErrorCancelled.
  ///
  /// In en, this message translates to:
  /// **'Request cancelled'**
  String get apiErrorCancelled;

  /// No description provided for @apiErrorServer.
  ///
  /// In en, this message translates to:
  /// **'Server returned an error ({code})'**
  String apiErrorServer(String code);

  /// No description provided for @instanceIdRequired.
  ///
  /// In en, this message translates to:
  /// **'Instance ID is required'**
  String get instanceIdRequired;

  /// No description provided for @backendOfflineTitle.
  ///
  /// In en, this message translates to:
  /// **'Server Unavailable'**
  String get backendOfflineTitle;

  /// No description provided for @backendOfflineBody.
  ///
  /// In en, this message translates to:
  /// **'Cannot reach the Velie server. Check your internet connection.'**
  String get backendOfflineBody;

  /// No description provided for @retryConnection.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retryConnection;

  /// No description provided for @offlineWarning.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get offlineWarning;

  /// No description provided for @dispatchDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Posts scheduled at the same time will be sent 30–60 seconds apart.'**
  String get dispatchDisclaimer;

  /// No description provided for @onboardingStep1Title.
  ///
  /// In en, this message translates to:
  /// **'Open WhatsApp Menu'**
  String get onboardingStep1Title;

  /// No description provided for @onboardingStep1Body.
  ///
  /// In en, this message translates to:
  /// **'Open WhatsApp on your phone, then tap the three-dot menu (⋮) at the top right.'**
  String get onboardingStep1Body;

  /// No description provided for @onboardingStep2Title.
  ///
  /// In en, this message translates to:
  /// **'Select \"Linked Devices\"'**
  String get onboardingStep2Title;

  /// No description provided for @onboardingStep2Body.
  ///
  /// In en, this message translates to:
  /// **'From the menu that opens, select \"Linked Devices\".'**
  String get onboardingStep2Body;

  /// No description provided for @onboardingStep3Title.
  ///
  /// In en, this message translates to:
  /// **'Tap \"Link a Device\"'**
  String get onboardingStep3Title;

  /// No description provided for @onboardingStep3Body.
  ///
  /// In en, this message translates to:
  /// **'On the Linked Devices screen, tap the green \"Link a Device\" button.'**
  String get onboardingStep3Body;

  /// No description provided for @onboardingStep4Title.
  ///
  /// In en, this message translates to:
  /// **'Link with a Number'**
  String get onboardingStep4Title;

  /// No description provided for @onboardingStep4Body.
  ///
  /// In en, this message translates to:
  /// **'On the WhatsApp screen, tap \"Link with phone number instead\" instead of scanning the QR code.'**
  String get onboardingStep4Body;

  /// No description provided for @onboardingStep5Title.
  ///
  /// In en, this message translates to:
  /// **'Enter the Code Provided'**
  String get onboardingStep5Title;

  /// No description provided for @onboardingStep5Body.
  ///
  /// In en, this message translates to:
  /// **'Enter the code shown by Velie in the designated place. Do not enter the code if you did not request it yourself.'**
  String get onboardingStep5Body;

  /// No description provided for @onboardingContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get onboardingContinue;

  /// No description provided for @validatorNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get validatorNameRequired;

  /// No description provided for @validatorPhoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Phone number is required'**
  String get validatorPhoneRequired;

  /// No description provided for @validatorPhoneInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid phone number'**
  String get validatorPhoneInvalid;

  /// No description provided for @validatorPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get validatorPasswordRequired;

  /// No description provided for @validatorPasswordShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get validatorPasswordShort;

  /// No description provided for @validatorPasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get validatorPasswordMismatch;

  /// No description provided for @scheduleTitle.
  ///
  /// In en, this message translates to:
  /// **'Schedule Post'**
  String get scheduleTitle;

  /// No description provided for @scheduleDateTime.
  ///
  /// In en, this message translates to:
  /// **'Date & Time'**
  String get scheduleDateTime;

  /// No description provided for @scheduleRepeat.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get scheduleRepeat;

  /// No description provided for @schedulePost.
  ///
  /// In en, this message translates to:
  /// **'Schedule Post'**
  String get schedulePost;

  /// No description provided for @queueTitle.
  ///
  /// In en, this message translates to:
  /// **'Queue'**
  String get queueTitle;

  /// No description provided for @queueEmpty.
  ///
  /// In en, this message translates to:
  /// **'No posts found'**
  String get queueEmpty;

  /// No description provided for @queueFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get queueFilterAll;

  /// No description provided for @queueSearch.
  ///
  /// In en, this message translates to:
  /// **'Search posts…'**
  String get queueSearch;

  /// No description provided for @postDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Post Detail'**
  String get postDetailTitle;

  /// No description provided for @postDetailCaption.
  ///
  /// In en, this message translates to:
  /// **'Caption'**
  String get postDetailCaption;

  /// No description provided for @postDetailScheduledTime.
  ///
  /// In en, this message translates to:
  /// **'Scheduled Time'**
  String get postDetailScheduledTime;

  /// No description provided for @postDetailViewers.
  ///
  /// In en, this message translates to:
  /// **'Viewers'**
  String get postDetailViewers;

  /// No description provided for @postDetailRepeat.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get postDetailRepeat;

  /// No description provided for @postDetailRetries.
  ///
  /// In en, this message translates to:
  /// **'Retries'**
  String get postDetailRetries;

  /// No description provided for @postDetailPublishedAt.
  ///
  /// In en, this message translates to:
  /// **'Published At'**
  String get postDetailPublishedAt;

  /// No description provided for @deletePostConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Post?'**
  String get deletePostConfirmTitle;

  /// No description provided for @deletePostConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This post will be permanently deleted.'**
  String get deletePostConfirmBody;

  /// No description provided for @retryPost.
  ///
  /// In en, this message translates to:
  /// **'Retry Post'**
  String get retryPost;

  /// No description provided for @createPostTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Post'**
  String get createPostTitle;

  /// No description provided for @draftSaved.
  ///
  /// In en, this message translates to:
  /// **'Draft saved'**
  String get draftSaved;

  /// No description provided for @saveDraftTitle.
  ///
  /// In en, this message translates to:
  /// **'Save Draft?'**
  String get saveDraftTitle;

  /// No description provided for @saveDraftBody.
  ///
  /// In en, this message translates to:
  /// **'Do you want to save this as a draft to continue later?'**
  String get saveDraftBody;

  /// No description provided for @saveDraft.
  ///
  /// In en, this message translates to:
  /// **'Save Draft'**
  String get saveDraft;

  /// No description provided for @discard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discard;

  /// No description provided for @draftsTitle.
  ///
  /// In en, this message translates to:
  /// **'Drafts'**
  String get draftsTitle;

  /// No description provided for @noDrafts.
  ///
  /// In en, this message translates to:
  /// **'No drafts yet'**
  String get noDrafts;

  /// No description provided for @captionHint.
  ///
  /// In en, this message translates to:
  /// **'Write your caption here…'**
  String get captionHint;

  /// No description provided for @addCaption.
  ///
  /// In en, this message translates to:
  /// **'Add caption'**
  String get addCaption;

  /// No description provided for @chooseImage.
  ///
  /// In en, this message translates to:
  /// **'Choose Image'**
  String get chooseImage;

  /// No description provided for @chooseVideo.
  ///
  /// In en, this message translates to:
  /// **'Choose Video'**
  String get chooseVideo;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications'**
  String get noNotifications;

  /// No description provided for @updateAvailable.
  ///
  /// In en, this message translates to:
  /// **'Update Available'**
  String get updateAvailable;

  /// No description provided for @updateNow.
  ///
  /// In en, this message translates to:
  /// **'Update Now'**
  String get updateNow;

  /// No description provided for @updaterTitle.
  ///
  /// In en, this message translates to:
  /// **'App Update'**
  String get updaterTitle;

  /// No description provided for @downloadingUpdate.
  ///
  /// In en, this message translates to:
  /// **'Downloading update…'**
  String get downloadingUpdate;

  /// No description provided for @updateReady.
  ///
  /// In en, this message translates to:
  /// **'Update ready to install'**
  String get updateReady;

  /// No description provided for @installUpdate.
  ///
  /// In en, this message translates to:
  /// **'Install Update'**
  String get installUpdate;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageSwahili.
  ///
  /// In en, this message translates to:
  /// **'Kiswahili'**
  String get languageSwahili;

  /// No description provided for @languageChinese.
  ///
  /// In en, this message translates to:
  /// **'中文'**
  String get languageChinese;

  /// No description provided for @queueTitle2.
  ///
  /// In en, this message translates to:
  /// **'Posts Queue'**
  String get queueTitle2;

  /// No description provided for @queueSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by caption...'**
  String get queueSearchHint;

  /// No description provided for @queueFilterPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get queueFilterPending;

  /// No description provided for @queueFilterSent.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get queueFilterSent;

  /// No description provided for @queueFilterFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get queueFilterFailed;

  /// No description provided for @queueLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load queue'**
  String get queueLoadError;

  /// No description provided for @queueNoPostsYet.
  ///
  /// In en, this message translates to:
  /// **'No posts scheduled yet'**
  String get queueNoPostsYet;

  /// No description provided for @queueNoPostsForFilter.
  ///
  /// In en, this message translates to:
  /// **'No posts with this status'**
  String get queueNoPostsForFilter;

  /// No description provided for @queueStartCreating.
  ///
  /// In en, this message translates to:
  /// **'Start creating your first post'**
  String get queueStartCreating;

  /// No description provided for @queueChangeFilter.
  ///
  /// In en, this message translates to:
  /// **'Change the filter above'**
  String get queueChangeFilter;

  /// No description provided for @postDetailChannel.
  ///
  /// In en, this message translates to:
  /// **'Channel'**
  String get postDetailChannel;

  /// No description provided for @postDetailScheduledTime2.
  ///
  /// In en, this message translates to:
  /// **'Scheduled Time'**
  String get postDetailScheduledTime2;

  /// No description provided for @postDetailRecurrence.
  ///
  /// In en, this message translates to:
  /// **'Recurrence'**
  String get postDetailRecurrence;

  /// No description provided for @postDetailStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get postDetailStatus;

  /// No description provided for @postDetailViewers2.
  ///
  /// In en, this message translates to:
  /// **'Viewers'**
  String get postDetailViewers2;

  /// No description provided for @postDetailRetries2.
  ///
  /// In en, this message translates to:
  /// **'Retries'**
  String get postDetailRetries2;

  /// No description provided for @postDetailCreatedAt.
  ///
  /// In en, this message translates to:
  /// **'Created At'**
  String get postDetailCreatedAt;

  /// No description provided for @postNotFound.
  ///
  /// In en, this message translates to:
  /// **'Post not found'**
  String get postNotFound;

  /// No description provided for @backToQueue.
  ///
  /// In en, this message translates to:
  /// **'Back to Queue'**
  String get backToQueue;

  /// No description provided for @noCaption.
  ///
  /// In en, this message translates to:
  /// **'(No caption)'**
  String get noCaption;

  /// No description provided for @deletePostPendingContent.
  ///
  /// In en, this message translates to:
  /// **'This post will be removed from the queue. This action cannot be undone.'**
  String get deletePostPendingContent;

  /// No description provided for @deletePostSentContent.
  ///
  /// In en, this message translates to:
  /// **'This status will also be deleted from WhatsApp. This action cannot be undone.'**
  String get deletePostSentContent;

  /// No description provided for @createPostAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get createPostAppBarTitle;

  /// No description provided for @createPostSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create a new video, text, or image status.'**
  String get createPostSubtitle;

  /// No description provided for @videoStatusSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create or edit a video with music and text overlays.'**
  String get videoStatusSubtitle;

  /// No description provided for @textStatusSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Publish your message with colors and fonts.'**
  String get textStatusSubtitle;

  /// No description provided for @imageStatusSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Upload an image with your caption.'**
  String get imageStatusSubtitle;

  /// No description provided for @scheduleAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Schedule Post'**
  String get scheduleAppBarTitle;

  /// No description provided for @postPreview.
  ///
  /// In en, this message translates to:
  /// **'Post Preview'**
  String get postPreview;

  /// No description provided for @scheduleSection.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get scheduleSection;

  /// No description provided for @repeatsLabel.
  ///
  /// In en, this message translates to:
  /// **'Repeats'**
  String get repeatsLabel;

  /// No description provided for @scheduleSummarySection.
  ///
  /// In en, this message translates to:
  /// **'Schedule Summary'**
  String get scheduleSummarySection;

  /// No description provided for @firstPost.
  ///
  /// In en, this message translates to:
  /// **'First post:'**
  String get firstPost;

  /// No description provided for @repeatsPrefix.
  ///
  /// In en, this message translates to:
  /// **'Repeats:'**
  String get repeatsPrefix;

  /// No description provided for @endsPrefix.
  ///
  /// In en, this message translates to:
  /// **'Ends:'**
  String get endsPrefix;

  /// No description provided for @schedulePastTimeError.
  ///
  /// In en, this message translates to:
  /// **'Set a future time'**
  String get schedulePastTimeError;

  /// No description provided for @scheduleSuccess.
  ///
  /// In en, this message translates to:
  /// **'Post scheduled ✓'**
  String get scheduleSuccess;

  /// No description provided for @scheduleError.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String scheduleError(String error);

  /// No description provided for @scheduleButton.
  ///
  /// In en, this message translates to:
  /// **'SCHEDULE'**
  String get scheduleButton;

  /// No description provided for @repeatSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Repeat this schedule'**
  String get repeatSheetTitle;

  /// No description provided for @doesNotRepeat.
  ///
  /// In en, this message translates to:
  /// **'Does not repeat'**
  String get doesNotRepeat;

  /// No description provided for @everyDay.
  ///
  /// In en, this message translates to:
  /// **'Every day'**
  String get everyDay;

  /// No description provided for @everyWeek.
  ///
  /// In en, this message translates to:
  /// **'Every week'**
  String get everyWeek;

  /// No description provided for @everyMonth.
  ///
  /// In en, this message translates to:
  /// **'Every month'**
  String get everyMonth;

  /// No description provided for @repeatOnDays.
  ///
  /// In en, this message translates to:
  /// **'Repeat on'**
  String get repeatOnDays;

  /// No description provided for @endsSection.
  ///
  /// In en, this message translates to:
  /// **'Ends'**
  String get endsSection;

  /// No description provided for @endsNever.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get endsNever;

  /// No description provided for @endsOnDate.
  ///
  /// In en, this message translates to:
  /// **'On a date'**
  String get endsOnDate;

  /// No description provided for @endsAfterCount.
  ///
  /// In en, this message translates to:
  /// **'After a number of times'**
  String get endsAfterCount;

  /// No description provided for @timesLabel.
  ///
  /// In en, this message translates to:
  /// **'Times: '**
  String get timesLabel;

  /// No description provided for @neverEnds.
  ///
  /// In en, this message translates to:
  /// **'Never ends'**
  String get neverEnds;

  /// No description provided for @endsAfterN.
  ///
  /// In en, this message translates to:
  /// **'Ends after {count} times'**
  String endsAfterN(int count);

  /// No description provided for @everyWeekOn.
  ///
  /// In en, this message translates to:
  /// **'Every week on {days}'**
  String everyWeekOn(String days);

  /// No description provided for @textStatusAppBarNew.
  ///
  /// In en, this message translates to:
  /// **'Text Status'**
  String get textStatusAppBarNew;

  /// No description provided for @textStatusAppBarEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit Text'**
  String get textStatusAppBarEdit;

  /// No description provided for @editingBanner.
  ///
  /// In en, this message translates to:
  /// **'You are continuing to edit the original post.'**
  String get editingBanner;

  /// No description provided for @textStatusHint.
  ///
  /// In en, this message translates to:
  /// **'Write your status here…'**
  String get textStatusHint;

  /// No description provided for @recentTextStatuses.
  ///
  /// In en, this message translates to:
  /// **'Recent Text Statuses'**
  String get recentTextStatuses;

  /// No description provided for @repost.
  ///
  /// In en, this message translates to:
  /// **'Repost'**
  String get repost;

  /// No description provided for @continueToSchedule.
  ///
  /// In en, this message translates to:
  /// **'Continue to Schedule'**
  String get continueToSchedule;

  /// No description provided for @imageStatusAppBarNew.
  ///
  /// In en, this message translates to:
  /// **'Image Status'**
  String get imageStatusAppBarNew;

  /// No description provided for @imageStatusAppBarEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit Image'**
  String get imageStatusAppBarEdit;

  /// No description provided for @imageEditingBanner.
  ///
  /// In en, this message translates to:
  /// **'You are continuing to edit the original post. The original image will be kept if you don\'t choose a new one.'**
  String get imageEditingBanner;

  /// No description provided for @writeCaptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Write Your Caption'**
  String get writeCaptionLabel;

  /// No description provided for @captionHint2.
  ///
  /// In en, this message translates to:
  /// **'Write your post caption here…'**
  String get captionHint2;

  /// No description provided for @selectedImages.
  ///
  /// In en, this message translates to:
  /// **'Selected Images'**
  String get selectedImages;

  /// No description provided for @chooseImageFirst.
  ///
  /// In en, this message translates to:
  /// **'Please choose an image first'**
  String get chooseImageFirst;

  /// No description provided for @videoStatusAppBarNew.
  ///
  /// In en, this message translates to:
  /// **'Video Status'**
  String get videoStatusAppBarNew;

  /// No description provided for @videoStatusAppBarEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit Video'**
  String get videoStatusAppBarEdit;

  /// No description provided for @videoEditingBanner.
  ///
  /// In en, this message translates to:
  /// **'You are continuing to edit the original post. The original video will be kept if you don\'t choose a new one.'**
  String get videoEditingBanner;

  /// No description provided for @chooseVideoFirst.
  ///
  /// In en, this message translates to:
  /// **'Please choose a video first'**
  String get chooseVideoFirst;

  /// No description provided for @videoRenderFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to process video: {error}'**
  String videoRenderFailed(String error);

  /// No description provided for @captionTool.
  ///
  /// In en, this message translates to:
  /// **'Caption'**
  String get captionTool;

  /// No description provided for @logoTool.
  ///
  /// In en, this message translates to:
  /// **'Logo'**
  String get logoTool;

  /// No description provided for @musicTool.
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get musicTool;

  /// No description provided for @quickTagsTool.
  ///
  /// In en, this message translates to:
  /// **'Quick Tags'**
  String get quickTagsTool;

  /// No description provided for @volumeTool.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get volumeTool;

  /// No description provided for @volumeDrawerTitle.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get volumeDrawerTitle;

  /// No description provided for @originalVolumeLabel.
  ///
  /// In en, this message translates to:
  /// **'Original Audio'**
  String get originalVolumeLabel;

  /// No description provided for @musicVolumeLabel.
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get musicVolumeLabel;

  /// No description provided for @logoWatermarkTitle.
  ///
  /// In en, this message translates to:
  /// **'Logo/Watermark'**
  String get logoWatermarkTitle;

  /// No description provided for @captionDrawerTitle.
  ///
  /// In en, this message translates to:
  /// **'Caption'**
  String get captionDrawerTitle;

  /// No description provided for @videoCaptionHint.
  ///
  /// In en, this message translates to:
  /// **'Write your video caption here…'**
  String get videoCaptionHint;

  /// No description provided for @quickTagsSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick Tags'**
  String get quickTagsSheetTitle;

  /// No description provided for @addTagChip.
  ///
  /// In en, this message translates to:
  /// **'Add Tag'**
  String get addTagChip;

  /// No description provided for @addQuickTagTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Quick Tag'**
  String get addQuickTagTitle;

  /// No description provided for @tagNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name (for chip)'**
  String get tagNameLabel;

  /// No description provided for @tagContentLabel.
  ///
  /// In en, this message translates to:
  /// **'Text to insert'**
  String get tagContentLabel;

  /// No description provided for @renderPreparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing video on device…'**
  String get renderPreparing;

  /// No description provided for @renderProcessing.
  ///
  /// In en, this message translates to:
  /// **'Processing video… {pct}%'**
  String renderProcessing(int pct);

  /// No description provided for @renderWarning.
  ///
  /// In en, this message translates to:
  /// **'Do not leave this page — processing on your phone.'**
  String get renderWarning;

  /// No description provided for @imageDraftsTitle.
  ///
  /// In en, this message translates to:
  /// **'Image Drafts'**
  String get imageDraftsTitle;

  /// No description provided for @noDraftsImage.
  ///
  /// In en, this message translates to:
  /// **'No image drafts found'**
  String get noDraftsImage;

  /// No description provided for @videoDraftsTitle.
  ///
  /// In en, this message translates to:
  /// **'Video Drafts'**
  String get videoDraftsTitle;

  /// No description provided for @noDraftsVideo.
  ///
  /// In en, this message translates to:
  /// **'No video drafts found'**
  String get noDraftsVideo;

  /// No description provided for @deleteDraftTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Draft'**
  String get deleteDraftTitle;

  /// No description provided for @deleteDraftContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this draft?'**
  String get deleteDraftContent;

  /// No description provided for @newImageButton.
  ///
  /// In en, this message translates to:
  /// **'Create New Image'**
  String get newImageButton;

  /// No description provided for @newVideoButton.
  ///
  /// In en, this message translates to:
  /// **'Create New Video'**
  String get newVideoButton;

  /// No description provided for @notificationsAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsAppBarTitle;

  /// No description provided for @updateReadyTitle.
  ///
  /// In en, this message translates to:
  /// **'New Version Ready'**
  String get updateReadyTitle;

  /// No description provided for @updateDownloadingTitle.
  ///
  /// In en, this message translates to:
  /// **'Downloading New Version...'**
  String get updateDownloadingTitle;

  /// No description provided for @updateReadySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap here to update your App now.'**
  String get updateReadySubtitle;

  /// No description provided for @noNotificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'No New Notifications'**
  String get noNotificationsTitle;

  /// No description provided for @noNotificationsBody.
  ///
  /// In en, this message translates to:
  /// **'All notifications about your account will appear here.'**
  String get noNotificationsBody;

  /// No description provided for @updaterAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'New Version Available'**
  String get updaterAppBarTitle;

  /// No description provided for @updaterSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Velie v{version} is ready. Download now to enjoy these improvements:'**
  String updaterSubtitle(String version);

  /// No description provided for @featurePerformance.
  ///
  /// In en, this message translates to:
  /// **'Faster performance'**
  String get featurePerformance;

  /// No description provided for @featureBugFixes.
  ///
  /// In en, this message translates to:
  /// **'Bug fixes'**
  String get featureBugFixes;

  /// No description provided for @featureNewLook.
  ///
  /// In en, this message translates to:
  /// **'New and improved look'**
  String get featureNewLook;

  /// No description provided for @installButton.
  ///
  /// In en, this message translates to:
  /// **'Update Now'**
  String get installButton;

  /// No description provided for @skipForNow.
  ///
  /// In en, this message translates to:
  /// **'Skip for now'**
  String get skipForNow;

  /// No description provided for @backendOfflineBannerTitle.
  ///
  /// In en, this message translates to:
  /// **'Server Unavailable'**
  String get backendOfflineBannerTitle;

  /// No description provided for @backendOfflineBannerBody.
  ///
  /// In en, this message translates to:
  /// **'Cannot connect to the Velie server. Check your network and try again.'**
  String get backendOfflineBannerBody;

  /// No description provided for @backendOfflineRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get backendOfflineRetry;

  /// No description provided for @networkOfflineTitle.
  ///
  /// In en, this message translates to:
  /// **'No Internet Connection'**
  String get networkOfflineTitle;

  /// No description provided for @networkOfflineBody.
  ///
  /// In en, this message translates to:
  /// **'Please check your network settings. Velie will automatically reconnect when online.'**
  String get networkOfflineBody;

  /// No description provided for @fullCaptionTitle.
  ///
  /// In en, this message translates to:
  /// **'Full Caption'**
  String get fullCaptionTitle;

  /// No description provided for @retryLabel.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retryLabel;

  /// No description provided for @saveDraftTitle2.
  ///
  /// In en, this message translates to:
  /// **'Save as Draft?'**
  String get saveDraftTitle2;

  /// No description provided for @saveDraftBody2.
  ///
  /// In en, this message translates to:
  /// **'You have unsaved changes. Would you like to save as a draft before leaving?'**
  String get saveDraftBody2;

  /// No description provided for @saveDraftButton.
  ///
  /// In en, this message translates to:
  /// **'Save as Draft'**
  String get saveDraftButton;

  /// No description provided for @validatorNameEmpty.
  ///
  /// In en, this message translates to:
  /// **'Please fill in your name'**
  String get validatorNameEmpty;

  /// No description provided for @validatorNameShort.
  ///
  /// In en, this message translates to:
  /// **'Name is too short'**
  String get validatorNameShort;

  /// No description provided for @validatorPhoneEmpty.
  ///
  /// In en, this message translates to:
  /// **'Please fill in your phone number'**
  String get validatorPhoneEmpty;

  /// No description provided for @validatorPhoneLength.
  ///
  /// In en, this message translates to:
  /// **'Phone number must have 9 digits'**
  String get validatorPhoneLength;

  /// No description provided for @validatorPasswordEmpty.
  ///
  /// In en, this message translates to:
  /// **'Please fill in password'**
  String get validatorPasswordEmpty;

  /// No description provided for @validatorPasswordLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be 6 or more characters'**
  String get validatorPasswordLength;

  /// No description provided for @validatorConfirmEmpty.
  ///
  /// In en, this message translates to:
  /// **'Please repeat your password'**
  String get validatorConfirmEmpty;

  /// No description provided for @validatorConfirmMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get validatorConfirmMismatch;

  /// No description provided for @validatorCaptionEmpty.
  ///
  /// In en, this message translates to:
  /// **'Please write a caption'**
  String get validatorCaptionEmpty;

  /// No description provided for @validatorCaptionLong.
  ///
  /// In en, this message translates to:
  /// **'Caption exceeds 2200 characters'**
  String get validatorCaptionLong;

  /// No description provided for @everyNDays.
  ///
  /// In en, this message translates to:
  /// **'Every {n} days'**
  String everyNDays(int n);

  /// No description provided for @everyNWeeksOnDays.
  ///
  /// In en, this message translates to:
  /// **'Every {n} weeks on {days}'**
  String everyNWeeksOnDays(int n, String days);

  /// No description provided for @everyNWeeks.
  ///
  /// In en, this message translates to:
  /// **'Every {n} weeks'**
  String everyNWeeks(int n);

  /// No description provided for @everyNMonths.
  ///
  /// In en, this message translates to:
  /// **'Every {n} months'**
  String everyNMonths(int n);

  /// No description provided for @customRecurrence.
  ///
  /// In en, this message translates to:
  /// **'Custom recurrence'**
  String get customRecurrence;

  /// No description provided for @preparingVideoOnDevice.
  ///
  /// In en, this message translates to:
  /// **'Preparing video on device...'**
  String get preparingVideoOnDevice;

  /// No description provided for @videoFinalizing.
  ///
  /// In en, this message translates to:
  /// **'Finishing video... {pct}%'**
  String videoFinalizing(int pct);

  /// No description provided for @dontLeavePageRendering.
  ///
  /// In en, this message translates to:
  /// **'Don\'t leave this page — rendering on your device.'**
  String get dontLeavePageRendering;

  /// No description provided for @renderFailed.
  ///
  /// In en, this message translates to:
  /// **'Render failed'**
  String get renderFailed;

  /// No description provided for @editTextStatus.
  ///
  /// In en, this message translates to:
  /// **'Edit Text Status'**
  String get editTextStatus;

  /// No description provided for @editingPreviousPost.
  ///
  /// In en, this message translates to:
  /// **'You\'re continuing to edit the previous post.'**
  String get editingPreviousPost;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @musicLabel.
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get musicLabel;

  /// No description provided for @codeResent.
  ///
  /// In en, this message translates to:
  /// **'A new code has been sent.'**
  String get codeResent;

  /// No description provided for @logoutAction.
  ///
  /// In en, this message translates to:
  /// **'Sign out of account'**
  String get logoutAction;

  /// No description provided for @businessFallback.
  ///
  /// In en, this message translates to:
  /// **'Business'**
  String get businessFallback;

  /// No description provided for @deleteAction.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteAction;

  /// No description provided for @postDetails.
  ///
  /// In en, this message translates to:
  /// **'Post Details'**
  String get postDetails;

  /// No description provided for @channelLabel.
  ///
  /// In en, this message translates to:
  /// **'Channel'**
  String get channelLabel;

  /// No description provided for @scheduleTime.
  ///
  /// In en, this message translates to:
  /// **'Schedule Time'**
  String get scheduleTime;

  /// No description provided for @publishedAt.
  ///
  /// In en, this message translates to:
  /// **'Published At'**
  String get publishedAt;

  /// No description provided for @statusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get statusLabel;

  /// No description provided for @viewers.
  ///
  /// In en, this message translates to:
  /// **'Viewers'**
  String get viewers;

  /// No description provided for @retriesLabel.
  ///
  /// In en, this message translates to:
  /// **'Retries'**
  String get retriesLabel;

  /// No description provided for @createdAtLabel.
  ///
  /// In en, this message translates to:
  /// **'Created At'**
  String get createdAtLabel;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get filterPending;

  /// No description provided for @filterSent.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get filterSent;

  /// No description provided for @filterFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get filterFailed;

  /// No description provided for @searchByCaptionHint.
  ///
  /// In en, this message translates to:
  /// **'Search by caption...'**
  String get searchByCaptionHint;

  /// No description provided for @queueLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load the queue'**
  String get queueLoadFailed;

  /// No description provided for @noPostsYet.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t scheduled any posts yet'**
  String get noPostsYet;

  /// No description provided for @noPostsForStatus.
  ///
  /// In en, this message translates to:
  /// **'No posts with this status'**
  String get noPostsForStatus;

  /// No description provided for @createFirstPost.
  ///
  /// In en, this message translates to:
  /// **'Start by creating your first post'**
  String get createFirstPost;

  /// No description provided for @changeFilterAbove.
  ///
  /// In en, this message translates to:
  /// **'Try changing the filter above'**
  String get changeFilterAbove;

  /// No description provided for @audioUploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not upload audio. Please try again.'**
  String get audioUploadFailed;

  /// No description provided for @addMusic.
  ///
  /// In en, this message translates to:
  /// **'Add Music'**
  String get addMusic;

  /// No description provided for @audioFormats.
  ///
  /// In en, this message translates to:
  /// **'Audio only (mp3/m4a/wav)'**
  String get audioFormats;

  /// No description provided for @selectedMusic.
  ///
  /// In en, this message translates to:
  /// **'Selected Music'**
  String get selectedMusic;

  /// No description provided for @changeMusic.
  ///
  /// In en, this message translates to:
  /// **'Change Music'**
  String get changeMusic;

  /// No description provided for @removeMusic.
  ///
  /// In en, this message translates to:
  /// **'Remove Music'**
  String get removeMusic;

  /// No description provided for @permissionDeniedAudio.
  ///
  /// In en, this message translates to:
  /// **'Permission to read audio denied. Enable it in Settings.'**
  String get permissionDeniedAudio;

  /// No description provided for @selectSong.
  ///
  /// In en, this message translates to:
  /// **'Select Song'**
  String get selectSong;

  /// No description provided for @searchSong.
  ///
  /// In en, this message translates to:
  /// **'Search song...'**
  String get searchSong;

  /// No description provided for @retryButton.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get retryButton;

  /// No description provided for @noSongsOnDevice.
  ///
  /// In en, this message translates to:
  /// **'No songs on device.'**
  String get noSongsOnDevice;

  /// No description provided for @noSearchResults.
  ///
  /// In en, this message translates to:
  /// **'No search results.'**
  String get noSearchResults;

  /// No description provided for @imageUploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not upload image. Please try again.'**
  String get imageUploadFailed;

  /// No description provided for @cropImageTitle.
  ///
  /// In en, this message translates to:
  /// **'Crop Image'**
  String get cropImageTitle;

  /// No description provided for @cropImageFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not crop image. Please try again.'**
  String get cropImageFailed;

  /// No description provided for @noImage.
  ///
  /// In en, this message translates to:
  /// **'No Image'**
  String get noImage;

  /// No description provided for @aspectRatioHint.
  ///
  /// In en, this message translates to:
  /// **'1:1 (WhatsApp Status)'**
  String get aspectRatioHint;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'sw', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'sw':
      return AppLocalizationsSw();
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
