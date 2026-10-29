import 'package:shared_preferences/shared_preferences.dart';

class PendingOnboardingNames {
  const PendingOnboardingNames({
    required this.firstName,
    required this.lastName,
  });

  final String firstName;
  final String lastName;
}

class PendingOnboardingProfileService {
  static String _key(String email, String name) =>
      'pending_onboarding_${email.trim().toLowerCase()}_$name';

  static Future<void> save({
    required String email,
    required String firstName,
    required String lastName,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final preferences = await SharedPreferences.getInstance();
    final savedFirstName = await preferences.setString(
      _key(normalizedEmail, 'first_name'),
      firstName.trim(),
    );
    final savedLastName = await preferences.setString(
      _key(normalizedEmail, 'last_name'),
      lastName.trim(),
    );

    if (!savedFirstName || !savedLastName) {
      throw StateError('Could not save pending onboarding names.');
    }
  }

  static Future<PendingOnboardingNames?> load(String? email) async {
    final normalizedEmail = email?.trim().toLowerCase();
    if (normalizedEmail == null || normalizedEmail.isEmpty) return null;

    final preferences = await SharedPreferences.getInstance();
    final firstName = preferences.getString(
      _key(normalizedEmail, 'first_name'),
    );
    final lastName = preferences.getString(_key(normalizedEmail, 'last_name'));

    if (firstName == null && lastName == null) return null;

    return PendingOnboardingNames(
      firstName: firstName ?? '',
      lastName: lastName ?? '',
    );
  }

  static Future<void> clear(String? email) async {
    final normalizedEmail = email?.trim().toLowerCase();
    if (normalizedEmail == null || normalizedEmail.isEmpty) return;

    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_key(normalizedEmail, 'first_name'));
    await preferences.remove(_key(normalizedEmail, 'last_name'));
  }
}
