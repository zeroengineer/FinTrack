import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class PinRepository {
  Future<bool> hasPin();
  Future<void> setPin(String pin);
  Future<bool> verifyPin(String pin);
  Future<void> clearPin();
}

class SecureStoragePinRepository implements PinRepository {
  static const _key = 'app_pin';
  final FlutterSecureStorage storage;
  SecureStoragePinRepository(this.storage);

  @override
  Future<bool> hasPin() async => (await storage.read(key: _key)) != null;

  @override
  Future<void> setPin(String pin) => storage.write(key: _key, value: pin);

  @override
  Future<bool> verifyPin(String pin) async => (await storage.read(key: _key)) == pin;

  @override
  Future<void> clearPin() => storage.delete(key: _key);
}

final pinRepositoryProvider = Provider<PinRepository>((ref) {
  return SecureStoragePinRepository(const FlutterSecureStorage());
});
