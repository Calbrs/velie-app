import '../../models/business_model.dart';
import '../api_client.dart';
import '../auth_service.dart';
import 'mock_data_store.dart';

/// Simulated business registration / login.
class MockAuthService extends AuthService {
  MockAuthService() : super(client: ApiClient.instance);

  @override
  Future<BusinessModel> registerBusiness({
    required String name,
    required String ownerPhone,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final business = BusinessModel(
      id: 1,
      name: name,
      ownerPhone: ownerPhone,
      plan: 'free',
      createdAt: DateTime.now(),
    );
    MockDataStore.instance.business = business;
    return business;
  }

  @override
  Future<BusinessModel> login({
    required String ownerPhone,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final business = BusinessModel(
      id: 1,
      name: 'Mwambie',
      ownerPhone: ownerPhone,
      plan: 'free',
      createdAt: DateTime.now(),
    );
    MockDataStore.instance.business = business;
    return business;
  }

  @override
  Future<BusinessModel> me() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return MockDataStore.instance.business ??
        BusinessModel(id: 1, name: 'Mwambie', ownerPhone: '+255000000000');
  }

  @override
  Future<void> forgotPassword({required String ownerPhone}) async {
    await Future.delayed(const Duration(milliseconds: 600));
    MockDataStore.instance.lastOtp = '123456';
  }

  @override
  Future<void> verifyOtp({
    required String ownerPhone,
    required String otp,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (otp != MockDataStore.instance.lastOtp) {
      throw Exception('Msimbo si sahihi');
    }
  }

  @override
  Future<BusinessModel> resetPassword({
    required String ownerPhone,
    required String newPassword,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final business = BusinessModel(
      id: 1,
      name: 'Mwambie',
      ownerPhone: ownerPhone,
      plan: 'free',
      createdAt: DateTime.now(),
    );
    MockDataStore.instance.business = business;
    return business;
  }

  @override
  Future<bool> isBackendReachable() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return true;
  }
}
