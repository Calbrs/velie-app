/// Mirrors the `whatsapp_instances` table / Admin API instance response.
///
/// State machine (matches backend SessionManager):
///   starting → pending → pairing → connected
///                ↓
///            disconnected
class WhatsAppInstanceModel {
  final int id;
  final String status; // "starting" | "pending" | "pairing" | "connected" | "disconnected"
  final String? phone;
  final DateTime? connectedAt;
  final String? pairingCode;
  final DateTime? pairingCodeExpiresAt;

  const WhatsAppInstanceModel({
    required this.id,
    required this.status,
    this.phone,
    this.connectedAt,
    this.pairingCode,
    this.pairingCodeExpiresAt,
  });

  bool get isConnected => status.toLowerCase() == 'connected';
  bool get isDisconnected => status.toLowerCase() == 'disconnected';
  bool get isStarting => status.toLowerCase() == 'starting';

  /// `pending` = worker is alive, WhatsApp Web loaded, waiting for pairing code request.
  bool get isPending => status.toLowerCase() == 'pending';

  /// `pairing` = actively generating a pairing code (page.evaluate running).
  bool get isPairing => status.toLowerCase() == 'pairing';

  /// `pending` or `pairing` — both mean "not yet connected, but worker is alive".
  bool get isActive => isPending || isPairing;

  bool get hasPairingCode => pairingCode != null && pairingCode!.isNotEmpty;
  bool get isPairingCodeExpired =>
      pairingCodeExpiresAt != null && pairingCodeExpiresAt!.isBefore(DateTime.now());

  const WhatsAppInstanceModel.empty()
      : id = 0,
        status = 'disconnected',
        phone = null,
        connectedAt = null,
        pairingCode = null,
        pairingCodeExpiresAt = null;

  factory WhatsAppInstanceModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map ? json['data'] as Map<String, dynamic> : json;

    // Backend returns: { id, status, gateway_status: { status, pairCode, pairExpiresAt }, pairing_code, pairing_code_expires_at }
    // Prefer real-time gateway_status.status over DB status.
    final gatewayStatus = data['gateway_status'] is Map
        ? data['gateway_status'] as Map<String, dynamic>
        : null;
    final liveStatus = gatewayStatus?['status']?.toString() ?? '${data['status'] ?? 'disconnected'}';

    // Pairing code may come from gateway (real-time) or DB (persisted).
    String? code;
    DateTime? expiresAt;
    if (gatewayStatus != null) {
      code = gatewayStatus['pairCode']?.toString();
      expiresAt = DateTime.tryParse('${gatewayStatus['pairExpiresAt'] ?? ''}');
    }
    if (code == null || code.isEmpty) {
      code = data['pairing_code']?.toString();
      expiresAt = DateTime.tryParse('${data['pairing_code_expires_at'] ?? ''}');
    }

    return WhatsAppInstanceModel(
      id: int.tryParse('${data['id'] ?? data['instance_id'] ?? data['key'] ?? 0}') ?? 0,
      status: liveStatus,
      phone: data['phone']?.toString(),
      connectedAt: DateTime.tryParse('${data['connected_at'] ?? data['connectedAt'] ?? ''}'),
      pairingCode: code?.isNotEmpty == true ? code : null,
      pairingCodeExpiresAt: expiresAt,
    );
  }
}
