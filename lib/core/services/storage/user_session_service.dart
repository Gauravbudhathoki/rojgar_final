import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError("SharedPreferences main.dart ma initialize huncha");
});

final userSessionServiceProvider = Provider<UserSessionService>((ref) {
  return UserSessionService(prefs: ref.read(sharedPreferencesProvider));
});

class UserSessionService {
  final SharedPreferences _prefs;

  UserSessionService({required SharedPreferences prefs}) : _prefs = prefs;

  static const String _keyIsLoggedIn = "is_logged_in";
  static const String _keyAuthId = "auth_id";
  static const String _keyEmail = "email";
  static const String _keyUserName = "username";
  static const String _keyProfileImage = "profile_image";

  Future<void> saveUserSession({
    required String authId,
    required String email,
    required String username,
    String? profileImage,
  }) async {
    await _prefs.setBool(_keyIsLoggedIn, true);
    await _prefs.setString(_keyAuthId, authId);
    await _prefs.setString(_keyEmail, email);
    await _prefs.setString(_keyUserName, username);

    if (profileImage != null) {
      await _prefs.setString(_keyProfileImage, profileImage);
    }
  }

  //clears user session data
  Future<void> clearUserSession() async {
    await _prefs.remove(_keyIsLoggedIn);
    await _prefs.remove(_keyAuthId);
    await _prefs.remove(_keyEmail);
    await _prefs.remove(_keyUserName);
    await _prefs.remove(_keyProfileImage);
  }

  bool isUserLoggedIn() {
    return _prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  String? getAuthId() {
    return _prefs.getString(_keyAuthId);
  }

  String? getEmail() {
    return _prefs.getString(_keyEmail);
  }

  String? getFullName() {
    return _prefs.getString(_keyUserName);
  }

  String? getProfileImage() {
    return _prefs.getString(_keyProfileImage);
  }
}