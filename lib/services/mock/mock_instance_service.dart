import '../../models/whatsapp_instance_model.dart';
import '../api_client.dart';
import '../instance_service.dart';
import 'mock_data_store.dart';

/// Simulated WSAPI Admin API. A pairing code is returned immediately and the
/// instance auto-connects ~8 seconds later (as if the user typed the code in
/// WhatsApp).
class MockInstanceService extends InstanceService {
  MockInstanceService() : super(client: ApiClient.instance);

  static const _connectDelay = Duration(seconds: 8);

  @override
  Future<WhatsAppInstanceModel> createInstance() async {
    await Future.delayed(const Duration(milliseconds: 800));
    final store = MockDataStore.instance;
    store.instanceId += 1;
    store.connectAfter = DateTime.now().add(_connectDelay);
    store.whatsappInstance = WhatsAppInstanceModel(
      id: store.instanceId,
      status: 'connecting',
      pairingCode: MockDataStore.generatePairingCode(),
    );
    return store.whatsappInstance!;
  }

  @override
  Future<WhatsAppInstanceModel> refreshPairingCode({int? instanceId}) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final store = MockDataStore.instance;
    final id = instanceId ?? store.whatsappInstance?.id ?? 1;
    store.connectAfter = DateTime.now().add(_connectDelay);
    store.whatsappInstance = WhatsAppInstanceModel(
      id: id,
      status: 'connecting',
      pairingCode: MockDataStore.generatePairingCode(),
    );
    return store.whatsappInstance!;
  }

  @override
  Future<WhatsAppInstanceModel> fetchInstance({int? instanceId}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final store = MockDataStore.instance;
    final inst = store.whatsappInstance;
    if (inst == null) return const WhatsAppInstanceModel.empty();
    if (inst.isConnected) return inst;

    final deadline = store.connectAfter;
    if (deadline != null && DateTime.now().isAfter(deadline)) {
      final connected = WhatsAppInstanceModel(
        id: inst.id,
        status: 'connected',
        phone: '+2557${(10000000 + inst.id * 137)}',
        connectedAt: DateTime.now(),
      );
      store.whatsappInstance = connected;
      return connected;
    }
    return inst;
  }

  @override
  Future<WhatsAppInstanceModel?> fetchCurrentInstance() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return MockDataStore.instance.whatsappInstance;
  }

  @override
  Future<void> disconnect({int? instanceId}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final store = MockDataStore.instance;
    store.whatsappInstance = null;
    store.connectAfter = null;
  }
}
