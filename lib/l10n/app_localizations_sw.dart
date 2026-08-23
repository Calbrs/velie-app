// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Swahili (`sw`).
class AppLocalizationsSw extends AppLocalizations {
  AppLocalizationsSw([String locale = 'sw']) : super(locale);

  @override
  String get appTitle => 'Velie';

  @override
  String get cancel => 'Ghairi';

  @override
  String get confirm => 'Thibitisha';

  @override
  String get save => 'Hifadhi';

  @override
  String get delete => 'Futa';

  @override
  String get retry => 'Jaribu Tena';

  @override
  String get close => 'Funga';

  @override
  String get done => 'Imekamilika';

  @override
  String get ok => 'Sawa';

  @override
  String get skip => 'Ruka';

  @override
  String get next => 'Endelea';

  @override
  String get back => 'Rudi';

  @override
  String get send => 'Tuma';

  @override
  String get edit => 'Hariri';

  @override
  String get loading => 'Inapakia…';

  @override
  String get understood => 'Nimeelewa';

  @override
  String get helpTitle => 'Msaada';

  @override
  String get errorUnknown => 'Hitilafu isiyojulikana';

  @override
  String get pressAgainToExit => 'Bofya tena ili kutoka';

  @override
  String get selectStatusType => 'Chagua Aina ya Status';

  @override
  String get videoStatus => 'Video Status';

  @override
  String get textStatus => 'Text Status';

  @override
  String get imageStatus => 'Image Status';

  @override
  String get loginTitle => 'Ingia Velie';

  @override
  String get phoneNumber => 'Namba ya Simu';

  @override
  String get password => 'Nywila';

  @override
  String get forgotPassword => 'Umesahau nywila?';

  @override
  String get signIn => 'Ingia';

  @override
  String get noAccount => 'Huna akaunti?';

  @override
  String get register => 'Sajili';

  @override
  String loginFailed(String error) {
    return 'Kuingia haukufaulu: $error';
  }

  @override
  String get phoneNotLinked => 'Nambari Haijaunganishwa';

  @override
  String get phoneRegisteredNotLinked =>
      'Nambari yako imesajiliwa lakini haijaunganishwa na WhatsApp. Endelea na kuunganisha au sajili nambari nyingine?';

  @override
  String get continueToConnect => 'Endelea na Kuunganisha';

  @override
  String get registerOtherNumber => 'Sajili Nambari Nyingine';

  @override
  String get registerTitle => 'Tengeneza Akaunti';

  @override
  String get yourName => 'Jina lako';

  @override
  String get confirmPassword => 'Thibitisha Nywila';

  @override
  String get repeatPassword => 'Rudia Nywila';

  @override
  String get alreadyHaveAccount => 'Una akaunti tayari?';

  @override
  String get signUp => 'Sajili';

  @override
  String registerFailed(String error) {
    return 'Usajili haukufaulu: $error';
  }

  @override
  String get forgotPasswordTitle => 'Umesahau Nywila';

  @override
  String get recoverAccount => 'Rudisha Akaunti';

  @override
  String get recoverAccountBody =>
      'Ingiza namba yako ya simu kupokea OTP kupitia WhatsApp.';

  @override
  String get phoneNumberOrUsername => 'Namba ya Simu';

  @override
  String get sendOtp => 'Tuma OTP';

  @override
  String cannotSendCode(String error) {
    return 'Haiwezekani kutuma msimbo: $error';
  }

  @override
  String get verifyOtpTitle => 'Thibitisha OTP';

  @override
  String get enterOtp => 'Ingiza OTP';

  @override
  String otpSentTo(String phone) {
    return 'Tulituma msimbo kwa $phone kupitia WhatsApp.';
  }

  @override
  String get otpCode => 'Msimbo wa OTP';

  @override
  String get verify => 'Thibitisha';

  @override
  String codeExpiresIn(int seconds) {
    return 'Msimbo unaisha kwa sekunde $seconds';
  }

  @override
  String get codeExpired => 'Msimbo umeisha.';

  @override
  String get resend => 'Tuma Tena';

  @override
  String otpInvalid(String error) {
    return 'Msimbo haukubaliwi: $error';
  }

  @override
  String get newPasswordTitle => 'Nywila Mpya';

  @override
  String get setNewPassword => 'Weka Nywila Mpya';

  @override
  String get passwordMinLength => 'Hakikisha ina angalau herufi 6.';

  @override
  String get newPassword => 'Nywila Mpya';

  @override
  String get passwordTooShort => 'Nywila ni fupi sana';

  @override
  String get passwordsDoNotMatch => 'Nywila hazilingani';

  @override
  String get resetAndLogin => 'Badilisha & Ingia';

  @override
  String get passwordResetSuccess => 'Nywila imebadilishwa kikamilifu!';

  @override
  String passwordResetFailed(String error) {
    return 'Imeshindikana kubadilisha nenosiri: $error';
  }

  @override
  String get connectWhatsapp => 'Unganisha WhatsApp';

  @override
  String get pairingCodeLabel => 'MSIMBO WA KUUNGANISHA';

  @override
  String get copy => 'Nakili';

  @override
  String get codeCopied => 'Msimbo umenakiliwa';

  @override
  String get connected => 'Imeunganishwa ✓';

  @override
  String get redirectingToDashboard => 'Unaelekezwa kwenye dashibodi…';

  @override
  String get getNewCode => 'Pata Msimbo Mpya';

  @override
  String get help => 'Msaada';

  @override
  String get rateLimited => 'Umefikia kikomo';

  @override
  String get cannotConnectToServer => 'Hatuwezi kuunganishwa na seva';

  @override
  String get tryAgain => 'Jaribu Tena';

  @override
  String cannotGetNewCode(String error) {
    return 'Haikupata msimbo mpya: $error';
  }

  @override
  String get connectedSnackbar => 'Imeunganishwa! ✓';

  @override
  String get howToConnect => 'Jinsi ya Kuunganisha';

  @override
  String get connectStep1 => 'Fungua WhatsApp kwenye simu yako';

  @override
  String get connectStep2 =>
      'Nenda kwenye: Mipangilio → Vifaa Vilivyounganishwa (Linked Devices)';

  @override
  String get connectStep3 => 'Bonyeza \"Unganisha Kifaa\" (Link a Device)';

  @override
  String get connectStep4 =>
      'Chagua \"Unganisha kwa Namba ya Simu\" (Link with Phone Number)';

  @override
  String get connectStep5 => 'Ingiza msimbo ulioko hapa kwenye WhatsApp';

  @override
  String get signOutConfirmTitle => 'Toka?';

  @override
  String get signOutConfirmBody =>
      'Je, una uhakika unataka kufuta usajili na kurudi mwanzoni?';

  @override
  String get signOut => 'Toka';

  @override
  String get dashboardNoPosts => 'Bado hakuna post';

  @override
  String get totalStatus => 'Jumla ya Status';

  @override
  String get pending => 'Zinazosubiri';

  @override
  String get sent => 'Zilizotumwa';

  @override
  String get failed => 'Zimeshindwa';

  @override
  String get profileTitle => 'Wasifu';

  @override
  String get logoutButton => 'Toka kwenye akaunti';

  @override
  String get logoutConfirmTitle => 'Toka?';

  @override
  String get logoutConfirmContent =>
      'Utaondolewa kwenye akaunti yako ya Velie.';

  @override
  String get disconnectWhatsappTitle => 'Tenganisha WhatsApp?';

  @override
  String get disconnectWhatsappContent =>
      'Namba hii ya WhatsApp itakatwa kwenye Velie. Posts zilizopangwa zitasimama.';

  @override
  String get disconnect => 'Tenganisha';

  @override
  String get languageTitle => 'Lugha';

  @override
  String get selectLanguage => 'Chagua Lugha';

  @override
  String get reportProblemTitle => 'Ripoti Tatizo';

  @override
  String get feedback => 'Maoni';

  @override
  String get linkedAccounts => 'Akaunti Zilizounganishwa';

  @override
  String get whatsappPrimaryNumber => 'WhatsApp (Namba kuu)';

  @override
  String get whatsappConnected => 'WhatsApp imeunganishwa';

  @override
  String get notConnected => 'Haijaunganishwa';

  @override
  String get sendMessage => 'Tuma Ujumbe';

  @override
  String get describeProblem => 'Eleza tatizo lako hapa…';

  @override
  String get messageSentSuccess => 'Ujumbe wako umetumwa kikamilifu.';

  @override
  String get messageSentFailed => 'Imeshindwa kutuma ujumbe.';

  @override
  String get createdLabel => 'Iliundwa:';

  @override
  String get unknownValue => 'Haijulikani';

  @override
  String get connectionLostTitle => 'Muunganisho umekatwa';

  @override
  String get connectionLostBody =>
      'WhatsApp iliondolewa kwenye Vifaa Vilivyounganishwa (Linked Devices) kwenye simu yako. Unganisha tena ili uendelee kutuma status.';

  @override
  String get reconnect => 'Unganisha Tena';

  @override
  String get statusPending => 'Inasubiri';

  @override
  String get statusSent => 'Imetumwa';

  @override
  String get statusFailed => 'Imeshindwa';

  @override
  String get statusDeleted => 'Imefutwa';

  @override
  String get statusUnknown => 'Haijulikani';

  @override
  String get repeatOnce => 'Mara Moja';

  @override
  String get repeatWeekdays => 'Jumatatu–Ijumaa';

  @override
  String get repeatDaily => 'Kila Siku';

  @override
  String get repeatWeekly => 'Kila Wiki';

  @override
  String get repeatMonthly => 'Kila Mwezi';

  @override
  String get repeatOnceSubtitle => 'Tuma mara moja tu';

  @override
  String get repeatWeekdaysSubtitle => 'Tuma Jumatatu hadi Ijumaa kila wiki';

  @override
  String get repeatDailySubtitle => 'Tuma kila siku';

  @override
  String get repeatWeeklySubtitle => 'Tuma kila wiki';

  @override
  String get repeatMonthlySubtitle => 'Tuma kila mwezi';

  @override
  String get apiErrorTimeout => 'Muda umeisha — angalia mtandao wako';

  @override
  String get apiErrorConnectionFailed => 'Haiwezi kuunganishwa na seva';

  @override
  String get apiErrorUnauthorized => 'Idhini imekataliwa (401)';

  @override
  String get apiErrorNotFound => 'Hakuna maelezo yaliyopatikana (404)';

  @override
  String get apiErrorCancelled => 'Ombi limeghairiwa';

  @override
  String apiErrorServer(String code) {
    return 'Seva imerudisha hitilafu ($code)';
  }

  @override
  String get instanceIdRequired => 'Instance id inahitajika';

  @override
  String get backendOfflineTitle => 'Seva Haipatikani';

  @override
  String get backendOfflineBody =>
      'Haiwezi kufikia seva ya Velie. Angalia muunganiko wako wa intaneti.';

  @override
  String get retryConnection => 'Jaribu Tena';

  @override
  String get offlineWarning => 'Hakuna muunganiko wa intaneti';

  @override
  String get dispatchDisclaimer =>
      'Posts zinazopangwa kwa wakati mmoja hutumwa kwa nafasi ya sekunde 30–60 kila moja.';

  @override
  String get onboardingStep1Title => 'Fungua Menyu ya WhatsApp';

  @override
  String get onboardingStep1Body =>
      'Fungua WhatsApp kwenye simu yako, kisha bonyeza alama ya nukta tatu (⋮) juu kulia mwa skrini.';

  @override
  String get onboardingStep2Title => 'Chagua \"Linked Devices\"';

  @override
  String get onboardingStep2Body =>
      'Kwenye menyu itakayofunguka, chagua \"Linked Devices\" (Vifaa Vilivyounganishwa).';

  @override
  String get onboardingStep3Title => 'Bonyeza \"Link a Device\"';

  @override
  String get onboardingStep3Body =>
      'Kwenye skrini ya Linked Devices, bonyeza kitufe cha kijani kilichoandikwa \"Link a Device\".';

  @override
  String get onboardingStep4Title => 'Unganisha kwa Namba';

  @override
  String get onboardingStep4Body =>
      'Kwenye skrini ya WhatsApp yako, bonyeza \"Link with phone number instead\" badala ya kutumia QR Code.';

  @override
  String get onboardingStep5Title => 'Weka Msimbo Utakaopewa';

  @override
  String get onboardingStep5Body =>
      'Andika msimbo unaoonyeshwa na Velie mahali palipoainishwa. Usiingize msimbo kama hukuuomba wewe mwenyewe.';

  @override
  String get onboardingContinue => 'Endelea';

  @override
  String get validatorNameRequired => 'Jina linahitajika';

  @override
  String get validatorPhoneRequired => 'Namba ya simu inahitajika';

  @override
  String get validatorPhoneInvalid => 'Ingiza namba sahihi ya simu';

  @override
  String get validatorPasswordRequired => 'Nywila inahitajika';

  @override
  String get validatorPasswordShort => 'Nywila lazima iwe na herufi angalau 6';

  @override
  String get validatorPasswordMismatch => 'Nywila hazilingani';

  @override
  String get scheduleTitle => 'Panga Post';

  @override
  String get scheduleDateTime => 'Tarehe na Muda';

  @override
  String get scheduleRepeat => 'Rudia';

  @override
  String get schedulePost => 'Panga Post';

  @override
  String get queueTitle => 'Foleni';

  @override
  String get queueEmpty => 'Hakuna posts zilizopatikana';

  @override
  String get queueFilterAll => 'Zote';

  @override
  String get queueSearch => 'Tafuta posts…';

  @override
  String get postDetailTitle => 'Maelezo ya Post';

  @override
  String get postDetailCaption => 'Maandishi';

  @override
  String get postDetailScheduledTime => 'Wakati wa Kutuma';

  @override
  String get postDetailViewers => 'Walioona';

  @override
  String get postDetailRepeat => 'Mzunguko';

  @override
  String get postDetailRetries => 'Majaribio';

  @override
  String get postDetailPublishedAt => 'Ilitumwa';

  @override
  String get deletePostConfirmTitle => 'Futa Post?';

  @override
  String get deletePostConfirmBody => 'Post hii itafutwa kabisa.';

  @override
  String get retryPost => 'Jaribu Tena Kutuma';

  @override
  String get createPostTitle => 'Unda Post';

  @override
  String get draftSaved => 'Draft imehifadhiwa';

  @override
  String get saveDraftTitle => 'Hifadhi Draft?';

  @override
  String get saveDraftBody =>
      'Unataka kuhifadhi kama draft ili uendelee baadaye?';

  @override
  String get saveDraft => 'Hifadhi Draft';

  @override
  String get discard => 'Tupa';

  @override
  String get draftsTitle => 'Drafts';

  @override
  String get noDrafts => 'Bado hakuna drafts';

  @override
  String get captionHint => 'Andika maandishi yako hapa…';

  @override
  String get addCaption => 'Ongeza maandishi';

  @override
  String get chooseImage => 'Chagua Picha';

  @override
  String get chooseVideo => 'Chagua Video';

  @override
  String get notificationsTitle => 'Arifa';

  @override
  String get noNotifications => 'Hakuna arifa';

  @override
  String get updateAvailable => 'Sasisha Zinapatikana';

  @override
  String get updateNow => 'Sasisha Sasa';

  @override
  String get updaterTitle => 'Sasisha App';

  @override
  String get downloadingUpdate => 'Inashushwa…';

  @override
  String get updateReady => 'Sasisha ipo tayari';

  @override
  String get installUpdate => 'Sakinisha Sasisha';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSwahili => 'Kiswahili';

  @override
  String get languageChinese => '中文';

  @override
  String get queueTitle2 => 'Foleni ya Posts';

  @override
  String get queueSearchHint => 'Tafuta kwa caption...';

  @override
  String get queueFilterPending => 'Zinazosubiri';

  @override
  String get queueFilterSent => 'Zilizotumwa';

  @override
  String get queueFilterFailed => 'Zimeshindwa';

  @override
  String get queueLoadError => 'Haikuweza kupakia foleni';

  @override
  String get queueNoPostsYet => 'Bado hujapanga post yoyote';

  @override
  String get queueNoPostsForFilter => 'Hakuna post za hali hii';

  @override
  String get queueStartCreating => 'Anza kutengeneza post yako ya kwanza';

  @override
  String get queueChangeFilter => 'Badilisha kichujio juu';

  @override
  String get postDetailChannel => 'Channel';

  @override
  String get postDetailScheduledTime2 => 'Muda wa Kutuma';

  @override
  String get postDetailRecurrence => 'Kurudia';

  @override
  String get postDetailStatus => 'Status';

  @override
  String get postDetailViewers2 => 'Waliotazama (Viewers)';

  @override
  String get postDetailRetries2 => 'Majaribio (Retries)';

  @override
  String get postDetailCreatedAt => 'Iliundwa';

  @override
  String get postNotFound => 'Post haikupatikana';

  @override
  String get backToQueue => 'Rudi Foleni';

  @override
  String get noCaption => '(Bila caption)';

  @override
  String get deletePostPendingContent =>
      'Post hii itaondolewa kwenye foleni. Utendo huu hauwezi kutenduliwa.';

  @override
  String get deletePostSentContent =>
      'Status hii itafutwa pia kwenye WhatsApp. Utendo huu hauwezi kutenduliwa.';

  @override
  String get createPostAppBarTitle => 'Tengeneza';

  @override
  String get createPostSubtitle =>
      'Tengeneza status mpya ya video, maandishi au picha.';

  @override
  String get videoStatusSubtitle =>
      'Tengeneza au hariri video yenye muziki na majina ya maji.';

  @override
  String get textStatusSubtitle => 'Chapisha maneno yako kwa rangi na fonti.';

  @override
  String get imageStatusSubtitle => 'Pakia picha yenye caption yako.';

  @override
  String get scheduleAppBarTitle => 'Panga Post';

  @override
  String get postPreview => 'Mwonekano wa Post';

  @override
  String get scheduleSection => 'Ratiba';

  @override
  String get repeatsLabel => 'Marudio';

  @override
  String get scheduleSummarySection => 'Muhtasari wa Ratiba';

  @override
  String get firstPost => 'Post ya kwanza:';

  @override
  String get repeatsPrefix => 'Marudio:';

  @override
  String get endsPrefix => 'Inaisha:';

  @override
  String get schedulePastTimeError => 'Weka muda wa baadaye';

  @override
  String get scheduleSuccess => 'Post imepangwa ✓';

  @override
  String scheduleError(String error) {
    return 'Kosa: $error';
  }

  @override
  String get scheduleButton => 'PANGA';

  @override
  String get repeatSheetTitle => 'Rudia ratiba hii';

  @override
  String get doesNotRepeat => 'Haifanyi marudio';

  @override
  String get everyDay => 'Kila siku';

  @override
  String get everyWeek => 'Kila wiki';

  @override
  String get everyMonth => 'Kila mwezi';

  @override
  String get repeatOnDays => 'Rudia siku';

  @override
  String get endsSection => 'Inaisha';

  @override
  String get endsNever => 'Haisha';

  @override
  String get endsOnDate => 'Siku fulani';

  @override
  String get endsAfterCount => 'Baada ya idadi ya mara';

  @override
  String get timesLabel => 'Mara: ';

  @override
  String get neverEnds => 'Haina mwisho';

  @override
  String endsAfterN(int count) {
    return 'Inaisha baada ya mara $count';
  }

  @override
  String everyWeekOn(String days) {
    return 'Kila wiki siku $days';
  }

  @override
  String everyNDays(int n) {
    return 'Kila siku $n';
  }

  @override
  String everyNWeeks(int n) {
    return 'Kila wiki $n';
  }

  @override
  String everyNWeeksOnDays(int n, String days) {
    return 'Kila wiki $n siku $days';
  }

  @override
  String everyNMonths(int n) {
    return 'Kila mwezi $n';
  }

  @override
  String get customRecurrence => 'Mpangilio maalum wa kurudia';

  @override
  String get filterAll => 'Zote';

  @override
  String get filterPending => 'Zinazosubiri';

  @override
  String get filterSent => 'Zilizotumwa';

  @override
  String get filterFailed => 'Zimeshindwa';

  @override
  String get searchByCaptionHint => 'Tafuta kwa caption...';

  @override
  String get queueLoadFailed => 'Haikuweza kupakia foleni';

  @override
  String get noPostsYet => 'Bado hujapanga post yoyote';

  @override
  String get noPostsForStatus => 'Hakuna post za hali hii';

  @override
  String get createFirstPost => 'Anza kutengeneza post yako ya kwanza';

  @override
  String get changeFilterAbove => 'Badilisha kichujio juu';

  @override
  String get onb1Title => 'Fungua Menyu ya WhatsApp';

  @override
  String get onb1Body =>
      'Fungua WhatsApp kwenye simu yako, kisha bonyeza alama ya nukta tatu (⋮) juu kulia mwa skrini.';

  @override
  String get onb2Title => 'Chagua "Linked Devices"';

  @override
  String get onb2Body =>
      'Kwenye menyu itakayofunguka, chagua "Linked Devices" (Vifaa Vilivyounganishwa).';

  @override
  String get onb3Title => 'Bonyeza "Link a Device"';

  @override
  String get onb3Body =>
      'Kwenye skrini ya Linked Devices, bonyeza kitufe cha kijani kilichoandikwa "Link a Device".';

  @override
  String get onb4Title => 'Unganisha kwa Namba';

  @override
  String get onb4Body =>
      'Kwenye skrini ya WhatsApp yako, bonyeza "Link with phone number instead" badala ya kutumia QR Code.';

  @override
  String get onb5Title => 'Weka Msimbo Utakaopewa';

  @override
  String get onb5Body =>
      'Andika msimbo unaoonyeshwa na Velie mahali palipoainishwa. Usiingize msimbo kama hukuuomba wewe mwenyewe.';

  @override
  String get languagePickerTitle => 'Lugha / Language';

  @override
  String get swahiliLabel => 'Kiswahili (SW)';

  @override
  String get englishLabel => 'English (EN)';

  @override
  String get continueLabel => 'Endelea';

  @override
  String get connectedSnack => 'Imeunganishwa! ✓';

  @override
  String refreshCodeFailed(Object error) => 'Haikupata msimbo mpya: $error';

  @override
  String get howToConnectTitle => 'Jinsi ya Kuunganisha';

  @override
  String get helpStep1 => 'Fungua WhatsApp kwenye simu yako';

  @override
  String get helpStep2 =>
      'Nenda kwenye: Mipangilio → Vifaa Vilivyounganishwa (Linked Devices)';

  @override
  String get helpStep3 => 'Bonyeza "Unganisha Kifaa" (Link a Device)';

  @override
  String get helpStep4 =>
      'Chagua "Unganisha kwa Namba ya Simu" (Link with Phone Number)';

  @override
  String get helpStep5 => 'Ingiza msimbo ulioko hapa kwenye WhatsApp';

  @override
  String get pairingTitle => 'Unganisha WhatsApp';

  @override
  String get helpLabel => 'Msaada';

  @override
  String get connectedTitle => 'Imeunganishwa ✓';

  @override
  String get copyLabel => 'Nakili';

  @override
  String get rateLimitedMsg => 'Umefikia kikomo';

  @override
  String get cannotConnectServer => 'Hatuwezi kuunganishwa na seva';

  @override
  String get textStatusAppBarNew => 'Status ya Maandishi';

  @override
  String get textStatusAppBarEdit => 'Hariri Maandishi';

  @override
  String get editingBanner => 'Unaendelea kuhariri post ya awali.';

  @override
  String get textStatusHint => 'Andika status yako hapa…';

  @override
  String get recentTextStatuses => 'Status za Maandishi za Hivi Karibuni';

  @override
  String get repost => 'Tuma Tena';

  @override
  String get continueToSchedule => 'Endelea kwenye Ratiba';

  @override
  String get imageStatusAppBarNew => 'Status ya Picha';

  @override
  String get imageStatusAppBarEdit => 'Hariri Picha';

  @override
  String get imageEditingBanner =>
      'Unaendelea kuhariri post ya awali. Picha ya awali itahifadhiwa usipochagua nyingine.';

  @override
  String get writeCaptionLabel => 'Andika Caption Yako';

  @override
  String get captionHint2 => 'Andika maandishi ya post yako hapa…';

  @override
  String get selectedImages => 'Picha Zilizochaguliwa';

  @override
  String get chooseImageFirst => 'Chagua picha kwanza';

  @override
  String get videoStatusAppBarNew => 'Status ya Video';

  @override
  String get videoStatusAppBarEdit => 'Hariri Video';

  @override
  String get videoEditingBanner =>
      'Unaendelea kuhariri post ya awali. Video ya awali itahifadhiwa usipochagua nyingine.';

  @override
  String get chooseVideoFirst => 'Chagua video kwanza';

  @override
  String videoRenderFailed(String error) {
    return 'Imeshindwa kuchakata video: $error';
  }

  @override
  String get captionTool => 'Caption';

  @override
  String get logoTool => 'Logo';

  @override
  String get musicTool => 'Muziki';

  @override
  String get quickTagsTool => 'Quick Tags';

  @override
  String get volumeTool => 'Volume';

  @override
  String get volumeDrawerTitle => 'Sauti';

  @override
  String get originalVolumeLabel => 'Sauti Halisi';

  @override
  String get musicVolumeLabel => 'Muziki';

  @override
  String get logoWatermarkTitle => 'Logo/Watermark';

  @override
  String get captionDrawerTitle => 'Caption';

  @override
  String get videoCaptionHint => 'Andika maelezo ya video yako hapa…';

  @override
  String get quickTagsSheetTitle => 'Quick Tags';

  @override
  String get addTagChip => 'Ongeza Tag';

  @override
  String get addQuickTagTitle => 'Ongeza Quick Tag';

  @override
  String get tagNameLabel => 'Jina (kwa chip)';

  @override
  String get tagContentLabel => 'Maandishi ya kuingiza';

  @override
  String get renderPreparing => 'Inatayarisha video kwenye kifaa…';

  @override
  String renderProcessing(int pct) {
    return 'Inakamilisha video… $pct%';
  }

  @override
  String get renderWarning =>
      'Usiondoke ukurasa huu — inachakatwa kwenye simu yako.';

  @override
  String get imageDraftsTitle => 'Rasimu za Picha';

  @override
  String get noDraftsImage => 'Hakuna rasimu za picha';

  @override
  String get videoDraftsTitle => 'Rasimu za Video';

  @override
  String get noDraftsVideo => 'Hakuna rasimu za video';

  @override
  String get deleteDraftTitle => 'Futa Rasimu';

  @override
  String get deleteDraftContent => 'Je, una uhakika unataka kufuta rasimu hii?';

  @override
  String get newImageButton => 'Tengeneza Picha Mpya';

  @override
  String get newVideoButton => 'Tengeneza Video Mpya';

  @override
  String get notificationsAppBarTitle => 'Taarifa';

  @override
  String get updateReadyTitle => 'Toleo Jipya Tayari';

  @override
  String get updateDownloadingTitle => 'Inapakua Toleo Jipya...';

  @override
  String get updateReadySubtitle => 'Bofya hapa kusasisha App yako sasa hivi.';

  @override
  String get noNotificationsTitle => 'Hakuna Taarifa Mpya';

  @override
  String get noNotificationsBody =>
      'Taarifa zote kuhusu akaunti yako\nzitaonekana hapa.';

  @override
  String get updaterAppBarTitle => 'Toleo Jipya Linapatikana';

  @override
  String updaterSubtitle(String version) {
    return 'Velie v$version ipo tayari. Pakua sasa ili kufurahia maboresho haya:';
  }

  @override
  String get featurePerformance => 'Utendaji wa haraka zaidi';

  @override
  String get featureBugFixes => 'Marekebisho ya makosa (Bug fixes)';

  @override
  String get featureNewLook => 'Muonekano mpya na mzuri zaidi';

  @override
  String get installButton => 'Sasisha Sasa (Update)';

  @override
  String get skipForNow => 'Ruka kwa sasa';

  @override
  String get backendOfflineBannerTitle => 'Seva haipatikani';

  @override
  String get backendOfflineBannerBody =>
      'Haiwezi kuunganishwa na seva ya Velie. Angalia mtandao wako na ujaribu tena.';

  @override
  String get backendOfflineRetry => 'Jaribu tena';

  @override
  String get networkOfflineTitle => 'Hakuna Muunganiko wa Intaneti';

  @override
  String get networkOfflineBody =>
      'Tafadhali angalia mipangilio ya mtandao wako. Velie itaunganika tena moja kwa moja unapokuwa mtandaoni.';

  @override
  String get fullCaptionTitle => 'Maandishi Kamili';

  @override
  String get retryLabel => 'Jaribu Tena';

  @override
  String get saveDraftTitle2 => 'Hifadhi kama Rasimu?';

  @override
  String get saveDraftBody2 =>
      'Una mabadiliko ambayo hayajahifadhiwa. Je, ungependa kuyahifadhi kama rasimu kabla ya kuondoka?';

  @override
  String get saveDraftButton => 'Hifadhi kama Rasimu';

  @override
  String get validatorNameEmpty => 'Tafadhali jaza jina lako';

  @override
  String get validatorNameShort => 'Jina ni fupi mno';

  @override
  String get validatorPhoneEmpty => 'Tafadhali jaza namba ya simu';

  @override
  String get validatorPhoneLength => 'Namba ya simu lazima iwe na tarakimu 9';

  @override
  String get validatorPasswordEmpty => 'Tafadhali jaza password';

  @override
  String get validatorPasswordLength =>
      'Password lazima iwe na herufi 6 au zaidi';

  @override
  String get validatorConfirmEmpty => 'Tafadhali rudia password';

  @override
  String get validatorConfirmMismatch => 'Password hazilingani';

  @override
  String get validatorCaptionEmpty => 'Tafadhali andika caption';

  @override
  String get validatorCaptionLong => 'Caption imezidi herufi 2200';
}
