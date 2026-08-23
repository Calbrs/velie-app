/// Channels for `posts_schedule.channel`.
enum PostChannel {
  waStatus('wa_status', 'WhatsApp Status'),
  waGroup('wa_group', 'WhatsApp Group');

  const PostChannel(this.apiValue, this.label);

  final String apiValue;
  final String label;

  static PostChannel fromApi(String? value) {
    return PostChannel.values.firstWhere(
      (c) => c.apiValue == value,
      orElse: () => PostChannel.waStatus,
    );
  }
}
