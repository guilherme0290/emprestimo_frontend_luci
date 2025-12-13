import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const _secureStorage = FlutterSecureStorage();

  static Future<void> saveToken(String token) async {
    if (!kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwt_token', token);
    } else {
      await _secureStorage.write(key: 'jwt_token', value: token);
    }
  }

  static Future<String?> getToken() async {
    if (!kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('jwt_token');
    } else {
      return await _secureStorage.read(key: 'jwt_token');
    }
  }

  static Future<String?> getLoginResponse() async {
    if (!kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('loginResponse');
    } else {
      return await _secureStorage.read(key: 'loginResponse');
    }
  }

  static Future<void> removeAll() async {
    if (!kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('jwt_token');
      await prefs.remove('loginResponse');
    } else {
      await _secureStorage.delete(key: 'jwt_token');
      await _secureStorage.delete(key: 'loginResponse');
    }
  }

  static Future<void> clearAll() async {
    if (!kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } else {
      await _secureStorage.deleteAll();
    }
  }

  static getEmpresaTemporariaId() async {
    if (!kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('empresa_temporaria_id');
    } else {
      return await _secureStorage.read(key: 'empresa_temporaria_id');
    }
  }

  static Future<void> saveEmpresaTemporaria(String response) async {
    if (!kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('empresa_temporaria_id', response);
    } else {
      await _secureStorage.write(key: 'empresa_temporaria_id', value: response);
    }
  }

  static Future<void> saveLoginResponse(String response) async {
    if (!kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('loginResponse', response);
    } else {
      await _secureStorage.write(key: 'loginResponse', value: response);
    }
  }

  static Future<void> salvarEmpresaIdTemporario(int id) async {
    if (!kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('empresa_temporaria_id', id);
    } else {
      await _secureStorage.write(
          key: 'empresa_temporaria_id', value: id.toString());
    }
  }
}
