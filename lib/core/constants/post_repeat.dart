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

  String get label => switch (this) {
        PostRepeat.once => 'Mara Moja',
        PostRepeat.weekdays => 'Jumatatu\u2013Ijumaa',
        PostRepeat.daily => 'Kila Siku',
        PostRepeat.weekly => 'Kila Wiki',
        PostRepeat.monthly => 'Kila Mwezi',
      };

  String get subtitle => switch (this) {
        PostRepeat.once => 'Tuma mara moja tu',
        PostRepeat.weekdays => 'Tuma Jumatatu hadi Ijumaa kila wiki',
        PostRepeat.daily => 'Tuma kila siku',
        PostRepeat.weekly => 'Tuma kila wiki',
        PostRepeat.monthly => 'Tuma kila mwezi',
      };

  static PostRepeat fromApi(String? value) => PostRepeat.values.firstWhere(
        (r) => r.apiValue == value,
        orElse: () => PostRepeat.once,
      );
}
