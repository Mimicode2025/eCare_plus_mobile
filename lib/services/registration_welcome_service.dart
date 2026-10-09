import 'package:shared_preferences/shared_preferences.dart';

/// Local account marker until registration is connected to the patient service.
class RegistrationWelcomeService {
  static Future<bool> takeFirstRegistration(String email) async {
    final account = email.trim().toLowerCase();
    if (account.isEmpty) return false;
    final preferences = await SharedPreferences.getInstance();
    final key = 'registration_welcome_seen.$account';
    if (preferences.getBool(key) == true) return false;
    return preferences.setBool(key, true);
  }
}
