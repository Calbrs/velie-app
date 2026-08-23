// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Velie';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get retry => 'Retry';

  @override
  String get close => 'Close';

  @override
  String get done => 'Done';

  @override
  String get ok => 'OK';

  @override
  String get skip => 'Skip';

  @override
  String get next => 'Next';

  @override
  String get back => 'Back';

  @override
  String get send => 'Send';

  @override
  String get edit => 'Edit';

  @override
  String get loading => 'Loading…';

  @override
  String get understood => 'Got it';

  @override
  String get helpTitle => 'Help';

  @override
  String get errorUnknown => 'Unknown error';

  @override
  String get pressAgainToExit => 'Press again to exit';

  @override
  String get selectStatusType => 'Select Status Type';

  @override
  String get videoStatus => 'Video Status';

  @override
  String get textStatus => 'Text Status';

  @override
  String get imageStatus => 'Image Status';

  @override
  String get loginTitle => 'Sign in to Velie';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get password => 'Password';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get signIn => 'Sign In';

  @override
  String get noAccount => 'Don\'t have an account?';

  @override
  String get register => 'Register';

  @override
  String loginFailed(String error) {
    return 'Login failed: $error';
  }

  @override
  String get phoneNotLinked => 'Number Not Linked';

  @override
  String get phoneRegisteredNotLinked =>
      'Your number is registered but not linked to WhatsApp. Continue linking or register another number?';

  @override
  String get continueToConnect => 'Continue to Connect';

  @override
  String get registerOtherNumber => 'Register Another Number';

  @override
  String get registerTitle => 'Create Account';

  @override
  String get yourName => 'Your Name';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get repeatPassword => 'Repeat Password';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get signUp => 'Sign Up';

  @override
  String registerFailed(String error) {
    return 'Registration failed: $error';
  }

  @override
  String get forgotPasswordTitle => 'Forgot Password';

  @override
  String get recoverAccount => 'Recover Account';

  @override
  String get recoverAccountBody =>
      'Enter your phone number to receive an OTP via WhatsApp.';

  @override
  String get phoneNumberOrUsername => 'Phone Number';

  @override
  String get sendOtp => 'Send OTP';

  @override
  String cannotSendCode(String error) {
    return 'Cannot send code: $error';
  }

  @override
  String get verifyOtpTitle => 'Verify OTP';

  @override
  String get enterOtp => 'Enter OTP';

  @override
  String otpSentTo(String phone) {
    return 'We sent a code to $phone via WhatsApp.';
  }

  @override
  String get otpCode => 'OTP Code';

  @override
  String get verify => 'Verify';

  @override
  String codeExpiresIn(int seconds) {
    return 'Code expires in ${seconds}s';
  }

  @override
  String get codeExpired => 'Code expired.';

  @override
  String get resend => 'Resend';

  @override
  String otpInvalid(String error) {
    return 'Code not accepted: $error';
  }

  @override
  String get newPasswordTitle => 'New Password';

  @override
  String get setNewPassword => 'Set New Password';

  @override
  String get passwordMinLength => 'Make sure it is at least 6 characters.';

  @override
  String get newPassword => 'New Password';

  @override
  String get passwordTooShort => 'Too short';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get resetAndLogin => 'Reset & Login';

  @override
  String get passwordResetSuccess => 'Password reset successfully!';

  @override
  String passwordResetFailed(String error) {
    return 'Failed to change password: $error';
  }

  @override
  String get connectWhatsapp => 'Connect WhatsApp';

  @override
  String get pairingCodeLabel => 'PAIRING CODE';

  @override
  String get copy => 'Copy';

  @override
  String get codeCopied => 'Code copied';

  @override
  String get connected => 'Connected ✓';

  @override
  String get redirectingToDashboard => 'Redirecting to dashboard…';

  @override
  String get getNewCode => 'Get New Code';

  @override
  String get help => 'Help';

  @override
  String get rateLimited => 'Rate limit reached';

  @override
  String get cannotConnectToServer => 'Cannot connect to server';

  @override
  String get tryAgain => 'Try Again';

  @override
  String cannotGetNewCode(String error) {
    return 'Could not get new code: $error';
  }

  @override
  String get connectedSnackbar => 'Connected! ✓';

  @override
  String get howToConnect => 'How to Connect';

  @override
  String get connectStep1 => 'Open WhatsApp on your phone';

  @override
  String get connectStep2 => 'Go to: Settings → Linked Devices';

  @override
  String get connectStep3 => 'Tap \"Link a Device\"';

  @override
  String get connectStep4 => 'Choose \"Link with Phone Number\"';

  @override
  String get connectStep5 => 'Enter the code shown here in WhatsApp';

  @override
  String get signOutConfirmTitle => 'Sign Out?';

  @override
  String get signOutConfirmBody =>
      'Are you sure you want to delete your registration and start over?';

  @override
  String get signOut => 'Sign Out';

  @override
  String get dashboardNoPosts => 'No posts yet';

  @override
  String get totalStatus => 'Total Status';

  @override
  String get pending => 'Pending';

  @override
  String get sent => 'Sent';

  @override
  String get failed => 'Failed';

  @override
  String get profileTitle => 'Profile';

  @override
  String get logoutAction => 'Sign out of account';

  @override
  String get businessFallback => 'Business';

  @override
  String get logoutButton => 'Sign out of account';

  @override
  String get logoutConfirmTitle => 'Sign Out?';

  @override
  String get logoutConfirmContent =>
      'You will be removed from your Velie account.';

  @override
  String get disconnectWhatsappTitle => 'Disconnect WhatsApp?';

  @override
  String get disconnectWhatsappContent =>
      'This WhatsApp number will be disconnected from Velie. Scheduled posts will be paused.';

  @override
  String get disconnect => 'Disconnect';

  @override
  String get languageTitle => 'Language';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get reportProblemTitle => 'Report a Problem';

  @override
  String get feedback => 'Feedback';

  @override
  String get linkedAccounts => 'Linked Accounts';

  @override
  String get whatsappPrimaryNumber => 'WhatsApp (Primary number)';

  @override
  String get whatsappConnected => 'WhatsApp connected';

  @override
  String get notConnected => 'Not connected';

  @override
  String get sendMessage => 'Send Message';

  @override
  String get describeProblem => 'Describe your problem here…';

  @override
  String get messageSentSuccess => 'Your message was sent successfully.';

  @override
  String get messageSentFailed => 'Failed to send message.';

  @override
  String get createdLabel => 'Created:';

  @override
  String get unknownValue => 'Unknown';

  @override
  String get connectionLostTitle => 'Connection Lost';

  @override
  String get connectionLostBody =>
      'WhatsApp was removed from Linked Devices on your phone. Reconnect to continue posting statuses.';

  @override
  String get reconnect => 'Reconnect';

  @override
  String get statusPending => 'Pending';

  @override
  String get statusSent => 'Sent';

  @override
  String get statusFailed => 'Failed';

  @override
  String get statusDeleted => 'Deleted';

  @override
  String get statusUnknown => 'Unknown';

  @override
  String get repeatOnce => 'Once';

  @override
  String get repeatWeekdays => 'Mon–Fri';

  @override
  String get repeatDaily => 'Daily';

  @override
  String get repeatWeekly => 'Weekly';

  @override
  String get repeatMonthly => 'Monthly';

  @override
  String get repeatOnceSubtitle => 'Send once only';

  @override
  String get repeatWeekdaysSubtitle => 'Send Mon to Fri every week';

  @override
  String get repeatDailySubtitle => 'Send every day';

  @override
  String get repeatWeeklySubtitle => 'Send every week';

  @override
  String get repeatMonthlySubtitle => 'Send every month';

  @override
  String get apiErrorTimeout => 'Connection timed out — check your network';

  @override
  String get apiErrorConnectionFailed => 'Cannot connect to server';

  @override
  String get apiErrorUnauthorized => 'Authorization denied (401)';

  @override
  String get apiErrorNotFound => 'No information found (404)';

  @override
  String get apiErrorCancelled => 'Request cancelled';

  @override
  String apiErrorServer(String code) {
    return 'Server returned an error ($code)';
  }

  @override
  String get instanceIdRequired => 'Instance ID is required';

  @override
  String get backendOfflineTitle => 'Server Unavailable';

  @override
  String get backendOfflineBody =>
      'Cannot reach the Velie server. Check your internet connection.';

  @override
  String get retryConnection => 'Retry';

  @override
  String get offlineWarning => 'No internet connection';

  @override
  String get dispatchDisclaimer =>
      'Posts scheduled at the same time will be sent 30–60 seconds apart.';

  @override
  String get onboardingStep1Title => 'Open WhatsApp Menu';

  @override
  String get onboardingStep1Body =>
      'Open WhatsApp on your phone, then tap the three-dot menu (⋮) at the top right.';

  @override
  String get onboardingStep2Title => 'Select \"Linked Devices\"';

  @override
  String get onboardingStep2Body =>
      'From the menu that opens, select \"Linked Devices\".';

  @override
  String get onboardingStep3Title => 'Tap \"Link a Device\"';

  @override
  String get onboardingStep3Body =>
      'On the Linked Devices screen, tap the green \"Link a Device\" button.';

  @override
  String get onboardingStep4Title => 'Link with a Number';

  @override
  String get onboardingStep4Body =>
      'On the WhatsApp screen, tap \"Link with phone number instead\" instead of scanning the QR code.';

  @override
  String get onboardingStep5Title => 'Enter the Code Provided';

  @override
  String get onboardingStep5Body =>
      'Enter the code shown by Velie in the designated place. Do not enter the code if you did not request it yourself.';

  @override
  String get onboardingContinue => 'Continue';

  @override
  String get validatorNameRequired => 'Name is required';

  @override
  String get validatorPhoneRequired => 'Phone number is required';

  @override
  String get validatorPhoneInvalid => 'Enter a valid phone number';

  @override
  String get validatorPasswordRequired => 'Password is required';

  @override
  String get validatorPasswordShort => 'Password must be at least 6 characters';

  @override
  String get validatorPasswordMismatch => 'Passwords do not match';

  @override
  String get scheduleTitle => 'Schedule Post';

  @override
  String get scheduleDateTime => 'Date & Time';

  @override
  String get scheduleRepeat => 'Repeat';

  @override
  String get schedulePost => 'Schedule Post';

  @override
  String get queueTitle => 'Queue';

  @override
  String get queueEmpty => 'No posts found';

  @override
  String get queueFilterAll => 'All';

  @override
  String get queueSearch => 'Search posts…';

  @override
  String get postDetailTitle => 'Post Detail';

  @override
  String get postDetailCaption => 'Caption';

  @override
  String get postDetailScheduledTime => 'Scheduled Time';

  @override
  String get postDetailViewers => 'Viewers';

  @override
  String get postDetailRepeat => 'Repeat';

  @override
  String get postDetailRetries => 'Retries';

  @override
  String get postDetailPublishedAt => 'Published At';

  @override
  String get deletePostConfirmTitle => 'Delete Post?';

  @override
  String get deletePostConfirmBody => 'This post will be permanently deleted.';

  @override
  String get retryPost => 'Retry Post';

  @override
  String get createPostTitle => 'Create Post';

  @override
  String get draftSaved => 'Draft saved';

  @override
  String get saveDraftTitle => 'Save Draft?';

  @override
  String get saveDraftBody =>
      'Do you want to save this as a draft to continue later?';

  @override
  String get saveDraft => 'Save Draft';

  @override
  String get discard => 'Discard';

  @override
  String get draftsTitle => 'Drafts';

  @override
  String get noDrafts => 'No drafts yet';

  @override
  String get captionHint => 'Write your caption here…';

  @override
  String get addCaption => 'Add caption';

  @override
  String get chooseImage => 'Choose Image';

  @override
  String get chooseVideo => 'Choose Video';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get noNotifications => 'No notifications';

  @override
  String get updateAvailable => 'Update Available';

  @override
  String get updateNow => 'Update Now';

  @override
  String get updaterTitle => 'App Update';

  @override
  String get downloadingUpdate => 'Downloading update…';

  @override
  String get updateReady => 'Update ready to install';

  @override
  String get installUpdate => 'Install Update';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSwahili => 'Kiswahili';

  @override
  String get languageChinese => '中文';

  @override
  String get queueTitle2 => 'Posts Queue';

  @override
  String get queueSearchHint => 'Search by caption...';

  @override
  String get queueFilterPending => 'Pending';

  @override
  String get queueFilterSent => 'Sent';

  @override
  String get queueFilterFailed => 'Failed';

  @override
  String get queueLoadError => 'Could not load queue';

  @override
  String get queueNoPostsYet => 'No posts scheduled yet';

  @override
  String get queueNoPostsForFilter => 'No posts with this status';

  @override
  String get queueStartCreating => 'Start creating your first post';

  @override
  String get queueChangeFilter => 'Change the filter above';

  @override
  String get postDetailChannel => 'Channel';

  @override
  String get postDetailScheduledTime2 => 'Scheduled Time';

  @override
  String get postDetailRecurrence => 'Recurrence';

  @override
  String get postDetailStatus => 'Status';

  @override
  String get postDetailViewers2 => 'Viewers';

  @override
  String get postDetailRetries2 => 'Retries';

  @override
  String get postDetailCreatedAt => 'Created At';

  @override
  String get postNotFound => 'Post not found';

  @override
  String get backToQueue => 'Back to Queue';

  @override
  String get noCaption => '(No caption)';

  @override
  String get deletePostPendingContent =>
      'This post will be removed from the queue. This action cannot be undone.';

  @override
  String get deletePostSentContent =>
      'This status will also be deleted from WhatsApp. This action cannot be undone.';

  @override
  String get createPostAppBarTitle => 'Create';

  @override
  String get createPostSubtitle => 'Create a new video, text, or image status.';

  @override
  String get videoStatusSubtitle =>
      'Create or edit a video with music and text overlays.';

  @override
  String get textStatusSubtitle =>
      'Publish your message with colors and fonts.';

  @override
  String get imageStatusSubtitle => 'Upload an image with your caption.';

  @override
  String get scheduleAppBarTitle => 'Schedule Post';

  @override
  String get postPreview => 'Post Preview';

  @override
  String get scheduleSection => 'Schedule';

  @override
  String get repeatsLabel => 'Repeats';

  @override
  String get scheduleSummarySection => 'Schedule Summary';

  @override
  String get firstPost => 'First post:';

  @override
  String get repeatsPrefix => 'Repeats:';

  @override
  String get endsPrefix => 'Ends:';

  @override
  String get postDetails => 'Post Details';

  @override
  String get scheduleTime => 'Schedule Time';

  @override
  String get publishedAt => 'Published At';

  @override
  String get viewers => 'Viewers';

  @override
  String get retriesLabel => 'Retries';

  @override
  String get createdAtLabel => 'Created At';

  @override
  String get channelLabel => 'Channel';

  @override
  String get deleteAction => 'Delete';

  @override
  String get statusLabel => 'Status';

  @override
  String get schedulePastTimeError => 'Set a future time';

  @override
  String get scheduleSuccess => 'Post scheduled ✓';

  @override
  String scheduleError(String error) {
    return 'Error: $error';
  }

  @override
  String get scheduleButton => 'SCHEDULE';

  @override
  String get repeatSheetTitle => 'Repeat this schedule';

  @override
  String get doesNotRepeat => 'Does not repeat';

  @override
  String get everyDay => 'Every day';

  @override
  String get everyWeek => 'Every week';

  @override
  String get everyMonth => 'Every month';

  @override
  String get repeatOnDays => 'Repeat on';

  @override
  String get endsSection => 'Ends';

  @override
  String get endsNever => 'Never';

  @override
  String get endsOnDate => 'On a date';

  @override
  String get endsAfterCount => 'After a number of times';

  @override
  String get timesLabel => 'Times: ';

  @override
  String get neverEnds => 'Never ends';

  @override
  String endsAfterN(int count) {
    return 'Ends after $count times';
  }

  @override
  String everyWeekOn(String days) {
    return 'Every week on $days';
  }

  @override
  String everyNDays(int n) {
    return 'Every $n days';
  }

  @override
  String everyNWeeks(int n) {
    return 'Every $n weeks';
  }

  @override
  String everyNWeeksOnDays(int n, String days) {
    return 'Every $n weeks on $days';
  }

  @override
  String everyNMonths(int n) {
    return 'Every $n months';
  }

  @override
  String get customRecurrence => 'Custom recurrence';

  @override
  String get textStatusAppBarNew => 'Text Status';

  @override
  String get textStatusAppBarEdit => 'Edit Text';

  @override
  String get editingBanner => 'You are continuing to edit the original post.';

  @override
  String get textStatusHint => 'Write your status here…';

  @override
  String get recentTextStatuses => 'Recent Text Statuses';

  @override
  String get repost => 'Repost';

  @override
  String get continueToSchedule => 'Continue to Schedule';

  @override
  String get filterAll => 'All';

  @override
  String get filterPending => 'Pending';

  @override
  String get filterSent => 'Sent';

  @override
  String get filterFailed => 'Failed';

  @override
  String get searchByCaptionHint => 'Search by caption...';

  @override
  String get queueLoadFailed => 'Could not load the queue';

  @override
  String get noPostsYet => "You haven't scheduled any posts yet";

  @override
  String get noPostsForStatus => 'No posts with this status';

  @override
  String get createFirstPost => 'Start by creating your first post';

  @override
  String get changeFilterAbove => 'Try changing the filter above';

  @override
  String get imageStatusAppBarNew => 'Image Status';

  @override
  String get imageStatusAppBarEdit => 'Edit Image';

  @override
  String get imageEditingBanner =>
      'You are continuing to edit the original post. The original image will be kept if you don\'t choose a new one.';

  @override
  String get writeCaptionLabel => 'Write Your Caption';

  @override
  String get captionHint2 => 'Write your post caption here…';

  @override
  String get selectedImages => 'Selected Images';

  @override
  String get chooseImageFirst => 'Please choose an image first';

  @override
  String get videoStatusAppBarNew => 'Video Status';

  @override
  String get videoStatusAppBarEdit => 'Edit Video';

  @override
  String get videoEditingBanner =>
      'You are continuing to edit the original post. The original video will be kept if you don\'t choose a new one.';

  @override
  String get chooseVideoFirst => 'Please choose a video first';

  @override
  String videoRenderFailed(String error) {
    return 'Failed to process video: $error';
  }

  @override
  String get captionTool => 'Caption';

  @override
  String get logoTool => 'Logo';

  @override
  String get musicTool => 'Music';

  @override
  String get quickTagsTool => 'Quick Tags';

  @override
  String get volumeTool => 'Volume';

  @override
  String get volumeDrawerTitle => 'Volume';

  @override
  String get originalVolumeLabel => 'Original Audio';

  @override
  String get musicVolumeLabel => 'Music';

  @override
  String get logoWatermarkTitle => 'Logo/Watermark';

  @override
  String get captionDrawerTitle => 'Caption';

  @override
  String get videoCaptionHint => 'Write your video caption here…';

  @override
  String get quickTagsSheetTitle => 'Quick Tags';

  @override
  String get addTagChip => 'Add Tag';

  @override
  String get codeResent => 'A new code has been sent.';

  @override
  String videoFinalizing(Object pct) => 'Finishing video… $pct%';

  @override
  String get preparingVideoOnDevice => 'Preparing video on device…';

  @override
  String get continueLabel => 'Continue';

  @override
  String get editingPreviousPost =>
      "You're continuing to edit the previous post.";

  @override
  String get editTextStatus => 'Edit Text Status';

  @override
  String get addQuickTagTitle => 'Add Quick Tag';

  @override
  String get tagNameLabel => 'Name (for chip)';

  @override
  String get tagContentLabel => 'Text to insert';

  @override
  String get renderPreparing => 'Preparing video on device…';

  @override
  String renderProcessing(int pct) {
    return 'Processing video… $pct%';
  }

  @override
  String get renderWarning =>
      'Do not leave this page — processing on your phone.';

  @override
  String get renderFailed => 'Render failed';

  @override
  String get dontLeavePageRendering => "Don't leave this page — rendering on your device.";

  @override
  String get imageDraftsTitle => 'Image Drafts';

  @override
  String get noDraftsImage => 'No image drafts found';

  @override
  String get videoDraftsTitle => 'Video Drafts';

  @override
  String get noDraftsVideo => 'No video drafts found';

  @override
  String get deleteDraftTitle => 'Delete Draft';

  @override
  String get deleteDraftContent =>
      'Are you sure you want to delete this draft?';

  @override
  String get newImageButton => 'Create New Image';

  @override
  String get newVideoButton => 'Create New Video';

  @override
  String get notificationsAppBarTitle => 'Notifications';

  @override
  String get updateReadyTitle => 'New Version Ready';

  @override
  String get updateDownloadingTitle => 'Downloading New Version...';

  @override
  String get updateReadySubtitle => 'Tap here to update your App now.';

  @override
  String get noNotificationsTitle => 'No New Notifications';

  @override
  String get noNotificationsBody =>
      'All notifications about your account will appear here.';

  @override
  String get updaterAppBarTitle => 'New Version Available';

  @override
  String updaterSubtitle(String version) {
    return 'Velie v$version is ready. Download now to enjoy these improvements:';
  }

  @override
  String get featurePerformance => 'Faster performance';

  @override
  String get featureBugFixes => 'Bug fixes';

  @override
  String get featureNewLook => 'New and improved look';

  @override
  String get installButton => 'Update Now';

  @override
  String get skipForNow => 'Skip for now';

  @override
  String get backendOfflineBannerTitle => 'Server Unavailable';

  @override
  String get backendOfflineBannerBody =>
      'Cannot connect to the Velie server. Check your network and try again.';

  @override
  String get backendOfflineRetry => 'Try again';

  @override
  String get networkOfflineTitle => 'No Internet Connection';

  @override
  String get networkOfflineBody =>
      'Please check your network settings. Velie will automatically reconnect when online.';

  @override
  String get fullCaptionTitle => 'Full Caption';

  @override
  String get retryLabel => 'Retry';

  @override
  String get saveDraftTitle2 => 'Save as Draft?';

  @override
  String get saveDraftBody2 =>
      'You have unsaved changes. Would you like to save as a draft before leaving?';

  @override
  String get saveDraftButton => 'Save as Draft';

  @override
  String get validatorNameEmpty => 'Please fill in your name';

  @override
  String get validatorNameShort => 'Name is too short';

  @override
  String get validatorPhoneEmpty => 'Please fill in your phone number';

  @override
  String get validatorPhoneLength => 'Phone number must have 9 digits';

  @override
  String get validatorPasswordEmpty => 'Please fill in password';

  @override
  String get validatorPasswordLength => 'Password must be 6 or more characters';

  @override
  String get validatorConfirmEmpty => 'Please repeat your password';

  @override
  String get validatorConfirmMismatch => 'Passwords do not match';

  @override
  String get validatorCaptionEmpty => 'Please write a caption';

  @override
  String get validatorCaptionLong => 'Caption exceeds 2200 characters';
}
