/// Mirrors the `businesses` table / `POST /auth/register` response.
class BusinessModel {
  final int id;
  final String name;
  final String ownerPhone;
  final String plan; // "free" | "pro"
  final String? accessToken;
  final DateTime? createdAt;

  const BusinessModel({
    required this.id,
    required this.name,
    required this.ownerPhone,
    this.plan = 'free',
    this.accessToken,
    this.createdAt,
  });

  bool get isPro => plan.toLowerCase() == 'pro';

  factory BusinessModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map ? json['data'] as Map<String, dynamic> : json;
    return BusinessModel(
      id: (data['id'] ?? data['business_id'] ?? 0) is num
          ? (data['id'] ?? data['business_id'] ?? 0) as int
          : int.tryParse('${data['id'] ?? data['business_id'] ?? 0}') ?? 0,
      name: '${data['name'] ?? data['business_name'] ?? ''}',
      ownerPhone: '${data['owner_phone'] ?? data['phone'] ?? ''}',
      plan: '${data['plan'] ?? 'free'}',
      accessToken: data['access_token']?.toString(),
      createdAt: _parseDate(data['created_at'] ?? data['createdAt']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'owner_phone': ownerPhone,
        'plan': plan,
        'access_token': accessToken,
      };

  static DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    return DateTime.tryParse('$v');
  }
}
