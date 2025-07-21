import 'package:shared_preferences/shared_preferences.dart';

class SpService {
  Future<void> setToken(String token) async {
    final pref = await SharedPreferences.getInstance();
    final success = await pref.setString("x-auth-token", token);
    if (!success) {
      throw Exception("Failed to save token to SharedPreferences.");
    }
  }

  Future<String?> getToken() async {
    final pref = await SharedPreferences.getInstance();
    return pref.getString("x-auth-token");
  }

  Future<void> clearToken() async {
    final pref = await SharedPreferences.getInstance();
    await pref.remove("x-auth-token");
  }
}
