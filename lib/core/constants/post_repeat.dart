import 'package:velie_app/l10n/app_localizations.dart';

/// Repeat rule for a scheduled post.
enum PostRepeat {
  once,
  weekdays,
  daily,
  weekly,
  monthly;

  String get apiValue => switch (this) {
        PostRepeat.once => 'once',
        PostRepeat.weekdays => 'weekdays',
        PostRepeat.daily => 'daily',
        PostRepeat.weekly => 'weekly',
        PostRepeat.monthly => 'monthly',
      };

  String localizedLabel(AppLocalizations l10n) => switch (this) {
        PostRepeat.once => l10n.repeatOnce,
        PostRepeat.weekdays => l10n.repeatWeekdays,
        PostRepeat.daily => l10n.repeatDaily,
        PostRepeat.weekly => l10n.repeatWeekly,
        PostRepeat.monthly => l10n.repeatMonthly,
      };

  String localizedSubtitle(AppLocalizations l10n) => switch (this) {
        PostRepeat.once => l10n.repeatOnceSubtitle,
        PostRepeat.weekdays => l10n.repeatWeekdaysSubtitle,
        PostRepeat.daily => l10n.repeatDailySubtitle,
        PostRepeat.weekly => l10n.repeatWeeklySubtitle,
        PostRepeat.monthly => l10n.repeatMonthlySubtitle,
      };

  static PostRepeat fromApi(String? value) => PostRepeat.values.firstWhere(
        (r) => r.apiValue == value,
        orElse: () => PostRepeat.once,
      );
}
