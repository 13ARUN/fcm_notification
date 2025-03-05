import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:googleapis_auth/auth_io.dart' as gauth;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _tokenKey = "firebase_access_token";

  Future<Map<String, dynamic>> _loadServiceAccount() async {
    String jsonString = await rootBundle.loadString(
      "assets/service_account.json",
    );
    return json.decode(jsonString);
  }

  Future<void> _storeAccessToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<String?> _getStoredAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<String> getAccessToken({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final storedToken = await _getStoredAccessToken();
      if (storedToken != null) return storedToken;
    }

    final serviceAccount = await _loadServiceAccount();
    final accountCredentials = gauth.ServiceAccountCredentials.fromJson(
      serviceAccount,
    );

    final client = await gauth.clientViaServiceAccount(accountCredentials, [
      'https://www.googleapis.com/auth/firebase.messaging',
    ]);

    final newToken = client.credentials.accessToken.data;
    client.close();

    await _storeAccessToken(newToken);
    return newToken;
  }
}
