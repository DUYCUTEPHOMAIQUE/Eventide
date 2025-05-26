import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PreferenceRepository {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final String _accessTokenKey = 'accesstoken';
  final String _emailKey = 'email';
  final String _idTokenKey = 'idtoken';

  Future<void> setAuth({
    required String accessToken,
    required String idToken,
    required String email,
  }) async {
    try {
      await _storage.write(key: _accessTokenKey, value: accessToken);
      await _storage.write(key: _emailKey, value: email);
      await _storage.write(key: _idTokenKey, value: idToken);
    } catch (e) {
      await _storage.deleteAll();
      throw Exception('Error setting auth: $e');
    }
  }

  Future<void> removeAuth() async {
    try {
      await _storage.delete(key: _accessTokenKey);
      await _storage.delete(key: _emailKey);
      await _storage.delete(key: _idTokenKey);
    } catch (e) {
      throw Exception('Error removing auth: $e');
    }
  }
}
