// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Velie';

  @override
  String get cancel => '取消';

  @override
  String get confirm => '确认';

  @override
  String get save => '保存';

  @override
  String get delete => '删除';

  @override
  String get retry => '重试';

  @override
  String get close => '关闭';

  @override
  String get done => '完成';

  @override
  String get ok => '确定';

  @override
  String get skip => '跳过';

  @override
  String get next => '继续';

  @override
  String get back => '返回';

  @override
  String get send => '发送';

  @override
  String get edit => '编辑';

  @override
  String get loading => '加载中…';

  @override
  String get understood => '明白了';

  @override
  String get helpTitle => '帮助';

  @override
  String get errorUnknown => '未知错误';

  @override
  String get pressAgainToExit => '再次按下退出';

  @override
  String get selectStatusType => '选择状态类型';

  @override
  String get videoStatus => '视频状态';

  @override
  String get textStatus => '文字状态';

  @override
  String get imageStatus => '图片状态';

  @override
  String get loginTitle => '登录 Velie';

  @override
  String get phoneNumber => '电话号码';

  @override
  String get password => '密码';

  @override
  String get forgotPassword => '忘记密码？';

  @override
  String get signIn => '登录';

  @override
  String get noAccount => '没有账户？';

  @override
  String get register => '注册';

  @override
  String loginFailed(String error) {
    return '登录失败：$error';
  }

  @override
  String get phoneNotLinked => '号码未绑定';

  @override
  String get phoneRegisteredNotLinked => '您的号码已注册但未绑定 WhatsApp。继续绑定还是注册其他号码？';

  @override
  String get continueToConnect => '继续绑定';

  @override
  String get registerOtherNumber => '注册其他号码';

  @override
  String get registerTitle => '创建账户';

  @override
  String get yourName => '您的姓名';

  @override
  String get confirmPassword => '确认密码';

  @override
  String get repeatPassword => '重复密码';

  @override
  String get alreadyHaveAccount => '已有账户？';

  @override
  String get signUp => '注册';

  @override
  String registerFailed(String error) {
    return '注册失败：$error';
  }

  @override
  String get forgotPasswordTitle => '忘记密码';

  @override
  String get recoverAccount => '恢复账户';

  @override
  String get recoverAccountBody => '输入您的电话号码，通过 WhatsApp 接收 OTP。';

  @override
  String get phoneNumberOrUsername => '电话号码';

  @override
  String get sendOtp => '发送 OTP';

  @override
  String cannotSendCode(String error) {
    return '无法发送验证码：$error';
  }

  @override
  String get verifyOtpTitle => '验证 OTP';

  @override
  String get enterOtp => '输入 OTP';

  @override
  String otpSentTo(String phone) {
    return '我们通过 WhatsApp 向 $phone 发送了验证码。';
  }

  @override
  String get otpCode => 'OTP 验证码';

  @override
  String get verify => '验证';

  @override
  String codeExpiresIn(int seconds) {
    return '验证码将在 $seconds 秒后过期';
  }

  @override
  String get codeExpired => '验证码已过期。';

  @override
  String get resend => '重新发送';

  @override
  String otpInvalid(String error) {
    return '验证码无效：$error';
  }

  @override
  String get newPasswordTitle => '新密码';

  @override
  String get setNewPassword => '设置新密码';

  @override
  String get passwordMinLength => '请确保至少 6 个字符。';

  @override
  String get newPassword => '新密码';

  @override
  String get passwordTooShort => '密码太短';

  @override
  String get passwordsDoNotMatch => '密码不匹配';

  @override
  String get resetAndLogin => '重置并登录';

  @override
  String get passwordResetSuccess => '密码重置成功！';

  @override
  String passwordResetFailed(String error) {
    return '更改密码失败：$error';
  }

  @override
  String get connectWhatsapp => '连接 WhatsApp';

  @override
  String get pairingCodeLabel => '配对码';

  @override
  String get copy => '复制';

  @override
  String get codeCopied => '验证码已复制';

  @override
  String get connected => '已连接 ✓';

  @override
  String get redirectingToDashboard => '正在跳转到仪表板…';

  @override
  String get getNewCode => '获取新验证码';

  @override
  String get help => '帮助';

  @override
  String get rateLimited => '已达到速率限制';

  @override
  String get cannotConnectToServer => '无法连接到服务器';

  @override
  String get tryAgain => '重试';

  @override
  String cannotGetNewCode(String error) {
    return '无法获取新验证码：$error';
  }

  @override
  String get connectedSnackbar => '已连接！✓';

  @override
  String get howToConnect => '如何连接';

  @override
  String get connectStep1 => '在您的手机上打开 WhatsApp';

  @override
  String get connectStep2 => '前往：设置 → 已关联设备';

  @override
  String get connectStep3 => '点击\"关联设备\"';

  @override
  String get connectStep4 => '选择\"使用电话号码关联\"';

  @override
  String get connectStep5 => '在 WhatsApp 中输入此处显示的验证码';

  @override
  String get signOutConfirmTitle => '退出？';

  @override
  String get signOutConfirmBody => '您确定要删除注册信息并重新开始吗？';

  @override
  String get signOut => '退出';

  @override
  String get dashboardNoPosts => '暂无帖子';

  @override
  String get totalStatus => '状态总数';

  @override
  String get pending => '待处理';

  @override
  String get sent => '已发送';

  @override
  String get failed => '失败';

  @override
  String get profileTitle => '个人资料';

  @override
  String get logoutButton => '退出账户';

  @override
  String get logoutConfirmTitle => '退出？';

  @override
  String get logoutConfirmContent => '您将从 Velie 账户中退出。';

  @override
  String get disconnectWhatsappTitle => '断开 WhatsApp？';

  @override
  String get disconnectWhatsappContent =>
      '此 WhatsApp 号码将从 Velie 断开连接。已安排的帖子将暂停。';

  @override
  String get disconnect => '断开连接';

  @override
  String get languageTitle => '语言';

  @override
  String get selectLanguage => '选择语言';

  @override
  String get reportProblemTitle => '报告问题';

  @override
  String get feedback => '反馈';

  @override
  String get linkedAccounts => '已关联账户';

  @override
  String get whatsappPrimaryNumber => 'WhatsApp（主号码）';

  @override
  String get whatsappConnected => 'WhatsApp 已连接';

  @override
  String get notConnected => '未连接';

  @override
  String get sendMessage => '发送消息';

  @override
  String get describeProblem => '在此描述您的问题…';

  @override
  String get messageSentSuccess => '您的消息已成功发送。';

  @override
  String get messageSentFailed => '消息发送失败。';

  @override
  String get createdLabel => '创建时间：';

  @override
  String get unknownValue => '未知';

  @override
  String get connectionLostTitle => '连接已断开';

  @override
  String get connectionLostBody => 'WhatsApp 已从您手机的\"已关联设备\"中移除。重新连接以继续发布状态。';

  @override
  String get reconnect => '重新连接';

  @override
  String get statusPending => '待处理';

  @override
  String get statusSent => '已发送';

  @override
  String get statusFailed => '失败';

  @override
  String get statusDeleted => '已删除';

  @override
  String get statusUnknown => '未知';

  @override
  String get repeatOnce => '一次';

  @override
  String get repeatWeekdays => '周一至周五';

  @override
  String get repeatDaily => '每天';

  @override
  String get repeatWeekly => '每周';

  @override
  String get repeatMonthly => '每月';

  @override
  String get repeatOnceSubtitle => '仅发送一次';

  @override
  String get repeatWeekdaysSubtitle => '每周周一至周五发送';

  @override
  String get repeatDailySubtitle => '每天发送';

  @override
  String get repeatWeeklySubtitle => '每周发送';

  @override
  String get repeatMonthlySubtitle => '每月发送';

  @override
  String get apiErrorTimeout => '连接超时 — 请检查您的网络';

  @override
  String get apiErrorConnectionFailed => '无法连接到服务器';

  @override
  String get apiErrorUnauthorized => '授权被拒绝 (401)';

  @override
  String get apiErrorNotFound => '未找到相关信息 (404)';

  @override
  String get apiErrorCancelled => '请求已取消';

  @override
  String apiErrorServer(String code) {
    return '服务器返回错误 ($code)';
  }

  @override
  String get instanceIdRequired => '需要实例 ID';

  @override
  String get backendOfflineTitle => '服务器不可用';

  @override
  String get backendOfflineBody => '无法访问 Velie 服务器。请检查您的网络连接。';

  @override
  String get retryConnection => '重试';

  @override
  String get offlineWarning => '无网络连接';

  @override
  String get dispatchDisclaimer => '同时安排的帖子将以 30-60 秒的间隔发送。';

  @override
  String get onboardingStep1Title => '打开 WhatsApp 菜单';

  @override
  String get onboardingStep1Body => '在手机上打开 WhatsApp，然后点击右上角的三点菜单 (⋮)。';

  @override
  String get onboardingStep2Title => '选择\"已关联设备\"';

  @override
  String get onboardingStep2Body => '在打开的菜单中，选择\"已关联设备\"。';

  @override
  String get onboardingStep3Title => '点击\"关联设备\"';

  @override
  String get onboardingStep3Body => '在已关联设备页面，点击绿色的\"关联设备\"按钮。';

  @override
  String get onboardingStep4Title => '使用号码关联';

  @override
  String get onboardingStep4Body => '在 WhatsApp 页面，点击\"改用电话号码关联\"而非扫描二维码。';

  @override
  String get onboardingStep5Title => '输入提供的验证码';

  @override
  String get onboardingStep5Body => '在指定位置输入 Velie 显示的验证码。如果不是您本人请求，请勿输入验证码。';

  @override
  String get onboardingContinue => '继续';

  @override
  String get validatorNameRequired => '姓名为必填项';

  @override
  String get validatorPhoneRequired => '电话号码为必填项';

  @override
  String get validatorPhoneInvalid => '请输入有效的电话号码';

  @override
  String get validatorPasswordRequired => '密码为必填项';

  @override
  String get validatorPasswordShort => '密码至少需要 6 个字符';

  @override
  String get validatorPasswordMismatch => '密码不匹配';

  @override
  String get scheduleTitle => '安排帖子';

  @override
  String get scheduleDateTime => '日期和时间';

  @override
  String get scheduleRepeat => '重复';

  @override
  String get schedulePost => '安排帖子';

  @override
  String get queueTitle => '队列';

  @override
  String get queueEmpty => '未找到帖子';

  @override
  String get queueFilterAll => '全部';

  @override
  String get queueSearch => '搜索帖子…';

  @override
  String get postDetailTitle => '帖子详情';

  @override
  String get postDetailCaption => '说明';

  @override
  String get postDetailScheduledTime => '预定时间';

  @override
  String get postDetailViewers => '查看者';

  @override
  String get postDetailRepeat => '重复';

  @override
  String get postDetailRetries => '重试次数';

  @override
  String get postDetailPublishedAt => '发布时间';

  @override
  String get deletePostConfirmTitle => '删除帖子？';

  @override
  String get deletePostConfirmBody => '此帖子将被永久删除。';

  @override
  String get retryPost => '重新发送帖子';

  @override
  String get createPostTitle => '创建帖子';

  @override
  String get draftSaved => '草稿已保存';

  @override
  String get saveDraftTitle => '保存草稿？';

  @override
  String get saveDraftBody => '您想将其保存为草稿以便稍后继续吗？';

  @override
  String get saveDraft => '保存草稿';

  @override
  String get discard => '丢弃';

  @override
  String get draftsTitle => '草稿';

  @override
  String get noDrafts => '暂无草稿';

  @override
  String get captionHint => '在此输入说明…';

  @override
  String get addCaption => '添加说明';

  @override
  String get chooseImage => '选择图片';

  @override
  String get chooseVideo => '选择视频';

  @override
  String get notificationsTitle => '通知';

  @override
  String get noNotifications => '无通知';

  @override
  String get updateAvailable => '有可用更新';

  @override
  String get updateNow => '立即更新';

  @override
  String get updaterTitle => '应用更新';

  @override
  String get downloadingUpdate => '正在下载更新…';

  @override
  String get updateReady => '更新已准备好安装';

  @override
  String get installUpdate => '安装更新';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSwahili => 'Kiswahili';

  @override
  String get languageChinese => '中文';

  @override
  String get queueTitle2 => '帖子队列';

  @override
  String get queueSearchHint => '按说明搜索...';

  @override
  String get queueFilterPending => '待处理';

  @override
  String get queueFilterSent => '已发送';

  @override
  String get queueFilterFailed => '失败';

  @override
  String get queueLoadError => '无法加载队列';

  @override
  String get queueNoPostsYet => '尚未安排任何帖子';

  @override
  String get queueNoPostsForFilter => '此状态下无帖子';

  @override
  String get queueStartCreating => '开始创建您的第一个帖子';

  @override
  String get queueChangeFilter => '更改上方的筛选器';

  @override
  String get postDetailChannel => '频道';

  @override
  String get postDetailScheduledTime2 => '预定时间';

  @override
  String get postDetailRecurrence => '重复';

  @override
  String get postDetailStatus => '状态';

  @override
  String get postDetailViewers2 => '查看者';

  @override
  String get postDetailRetries2 => '重试次数';

  @override
  String get postDetailCreatedAt => '创建时间';

  @override
  String get postNotFound => '未找到帖子';

  @override
  String get backToQueue => '返回队列';

  @override
  String get noCaption => '（无说明）';

  @override
  String get deletePostPendingContent => '此帖子将从队列中删除。此操作无法撤消。';

  @override
  String get deletePostSentContent => '此状态也将从 WhatsApp 中删除。此操作无法撤消。';

  @override
  String get createPostAppBarTitle => '创建';

  @override
  String get createPostSubtitle => '创建新的视频、文字或图片状态。';

  @override
  String get videoStatusSubtitle => '创建或编辑带有音乐和文字叠加的视频。';

  @override
  String get textStatusSubtitle => '用颜色和字体发布您的消息。';

  @override
  String get imageStatusSubtitle => '上传带有说明的图片。';

  @override
  String get scheduleAppBarTitle => '安排帖子';

  @override
  String get postPreview => '帖子预览';

  @override
  String get scheduleSection => '安排';

  @override
  String get repeatsLabel => '重复';

  @override
  String get scheduleSummarySection => '安排摘要';

  @override
  String get firstPost => '第一个帖子：';

  @override
  String get repeatsPrefix => '重复：';

  @override
  String get endsPrefix => '结束：';

  @override
  String get schedulePastTimeError => '请设置未来的时间';

  @override
  String get scheduleSuccess => '帖子已安排 ✓';

  @override
  String scheduleError(String error) {
    return '错误：$error';
  }

  @override
  String get scheduleButton => '安排';

  @override
  String get repeatSheetTitle => '重复此安排';

  @override
  String get doesNotRepeat => '不重复';

  @override
  String get everyDay => '每天';

  @override
  String get everyWeek => '每周';

  @override
  String get everyMonth => '每月';

  @override
  String get repeatOnDays => '重复于';

  @override
  String get endsSection => '结束';

  @override
  String get endsNever => '从不';

  @override
  String get endsOnDate => '在某天';

  @override
  String get endsAfterCount => '在一定次数后';

  @override
  String get timesLabel => '次数：';

  @override
  String get neverEnds => '永不结束';

  @override
  String endsAfterN(int count) {
    return '$count 次后结束';
  }

  @override
  String everyWeekOn(String days) {
    return '每周$days';
  }

  @override
  String everyNDays(int n) {
    return '每$n天';
  }

  @override
  String everyNWeeks(int n) {
    return '每$n周';
  }

  @override
  String everyNWeeksOnDays(int n, String days) {
    return '每$n周的$days';
  }

  @override
  String everyNMonths(int n) {
    return '每$n月';
  }

  @override
  String get customRecurrence => '自定义重复';

  @override
  String get textStatusAppBarNew => '文字状态';

  @override
  String get textStatusAppBarEdit => '编辑文字';

  @override
  String get editingBanner => '您正在继续编辑原始帖子。';

  @override
  String get textStatusHint => '在此写下您的状态…';

  @override
  String get recentTextStatuses => '最近的文字状态';

  @override
  String get repost => '重新发布';

  @override
  String get continueToSchedule => '继续安排';

  @override
  String get filterAll => '全部';

  @override
  String get filterPending => '等待中';

  @override
  String get filterSent => '已发送';

  @override
  String get filterFailed => '失败';

  @override
  String get searchByCaptionHint => '按说明文字搜索...';

  @override
  String get queueLoadFailed => '无法加载队列';

  @override
  String get noPostsYet => '你还没有安排任何帖子';

  @override
  String get noPostsForStatus => '该状态下没有帖子';

  @override
  String get createFirstPost => '创建你的第一篇帖子开始使用';

  @override
  String get changeFilterAbove => '尝试更改上方的筛选条件';

  @override
  String get imageStatusAppBarNew => '图片状态';

  @override
  String get imageStatusAppBarEdit => '编辑图片';

  @override
  String get imageEditingBanner => '您正在继续编辑原始帖子。如果不选择新图片，将保留原始图片。';

  @override
  String get writeCaptionLabel => '写下您的说明';

  @override
  String get captionHint2 => '在此写下帖子说明…';

  @override
  String get selectedImages => '已选图片';

  @override
  String get chooseImageFirst => '请先选择图片';

  @override
  String get videoStatusAppBarNew => '视频状态';

  @override
  String get videoStatusAppBarEdit => '编辑视频';

  @override
  String get videoEditingBanner => '您正在继续编辑原始帖子。如果不选择新视频，将保留原始视频。';

  @override
  String get chooseVideoFirst => '请先选择视频';

  @override
  String videoRenderFailed(String error) {
    return '处理视频失败：$error';
  }

  @override
  String get captionTool => '说明';

  @override
  String get logoTool => '标志';

  @override
  String get musicTool => '音乐';

  @override
  String get quickTagsTool => '快速标签';

  @override
  String get volumeTool => '音量';

  @override
  String get volumeDrawerTitle => '音量';

  @override
  String get originalVolumeLabel => '原始音频';

  @override
  String get musicVolumeLabel => '音乐';

  @override
  String get logoWatermarkTitle => '标志/水印';

  @override
  String get captionDrawerTitle => '说明';

  @override
  String get videoCaptionHint => '在此写下视频说明…';

  @override
  String get quickTagsSheetTitle => '快速标签';

  @override
  String get addTagChip => '添加标签';

  @override
  String get codeResent => '新验证码已发送。';

  @override
  String videoFinalizing(Object pct) => '正在完成视频… $pct%';

  @override
  String get preparingVideoOnDevice => '正在设备上准备视频…';

  @override
  String get continueLabel => '继续';

  @override
  String get editingPreviousPost => '你正在继续编辑之前的帖子。';

  @override
  String get editTextStatus => '编辑文字状态';

  @override
  String get addQuickTagTitle => '添加快速标签';

  @override
  String get tagNameLabel => '名称（用于标签）';

  @override
  String get tagContentLabel => '要插入的文字';

  @override
  String get renderPreparing => '正在设备上准备视频…';

  @override
  String renderProcessing(int pct) {
    return '正在处理视频… $pct%';
  }

  @override
  String get renderWarning => '请勿离开此页面 — 正在您的手机上处理。';

  @override
  String get renderFailed => '渲染失败';

  @override
  String get dontLeavePageRendering => '请勿离开此页面 — 正在设备上渲染。';

  @override
  String get imageDraftsTitle => '图片草稿';

  @override
  String get noDraftsImage => '未找到图片草稿';

  @override
  String get videoDraftsTitle => '视频草稿';

  @override
  String get noDraftsVideo => '未找到视频草稿';

  @override
  String get deleteDraftTitle => '删除草稿';

  @override
  String get deleteDraftContent => '确定要删除此草稿吗？';

  @override
  String get newImageButton => '创建新图片';

  @override
  String get newVideoButton => '创建新视频';

  @override
  String get notificationsAppBarTitle => '通知';

  @override
  String get updateReadyTitle => '新版本已就绪';

  @override
  String get updateDownloadingTitle => '正在下载新版本...';

  @override
  String get updateReadySubtitle => '点击此处立即更新您的应用。';

  @override
  String get noNotificationsTitle => '暂无新通知';

  @override
  String get noNotificationsBody => '所有关于您账户的通知\n将显示在这里。';

  @override
  String get updaterAppBarTitle => '有新版本可用';

  @override
  String updaterSubtitle(String version) {
    return 'Velie v$version 已就绪。立即下载以享受这些改进：';
  }

  @override
  String get featurePerformance => '更快的性能';

  @override
  String get featureBugFixes => '错误修复';

  @override
  String get featureNewLook => '全新改进的外观';

  @override
  String get installButton => '立即更新';

  @override
  String get skipForNow => '暂时跳过';

  @override
  String get backendOfflineBannerTitle => '服务器不可用';

  @override
  String get backendOfflineBannerBody => '无法连接到 Velie 服务器。请检查您的网络并重试。';

  @override
  String get backendOfflineRetry => '重试';

  @override
  String get networkOfflineTitle => '无互联网连接';

  @override
  String get networkOfflineBody => '请检查您的网络设置。Velie 将在联网后自动重新连接。';

  @override
  String get fullCaptionTitle => '完整说明';

  @override
  String get retryLabel => '重试';

  @override
  String get saveDraftTitle2 => '保存为草稿？';

  @override
  String get saveDraftBody2 => '您有未保存的更改。离开前是否要保存为草稿？';

  @override
  String get saveDraftButton => '保存为草稿';

  @override
  String get validatorNameEmpty => '请填写您的姓名';

  @override
  String get validatorNameShort => '姓名太短';

  @override
  String get validatorPhoneEmpty => '请填写您的电话号码';

  @override
  String get validatorPhoneLength => '电话号码必须有 9 位数字';

  @override
  String get validatorPasswordEmpty => '请填写密码';

  @override
  String get validatorPasswordLength => '密码必须至少 6 个字符';

  @override
  String get validatorConfirmEmpty => '请重复输入密码';

  @override
  String get validatorConfirmMismatch => '密码不匹配';

  @override
  String get validatorCaptionEmpty => '请写说明';

  @override
  String get validatorCaptionLong => '说明超过 2200 个字符';
}
