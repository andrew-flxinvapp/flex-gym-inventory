import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Lightweight in-memory profile data carried through onboarding.
class ProfileData {
  final String? email;
  final String? firstName;
  final String? lastName;
  final bool? notificationsOn;

  const ProfileData({
    this.email,
    this.firstName,
    this.lastName,
    this.notificationsOn,
  });

  bool belongsToEmail(String? email) {
    final normalizedEmail = email?.trim().toLowerCase();
    return normalizedEmail != null &&
        normalizedEmail.isNotEmpty &&
        this.email == normalizedEmail;
  }

  ProfileData copyWith({
    String? email,
    String? firstName,
    String? lastName,
    bool? notificationsOn,
  }) {
    return ProfileData(
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      notificationsOn: notificationsOn ?? this.notificationsOn,
    );
  }
}

class ProfileDataNotifier extends StateNotifier<ProfileData> {
  ProfileDataNotifier() : super(const ProfileData());

  void setSignupDetails({
    required String email,
    required String firstName,
    required String lastName,
  }) {
    state = state.copyWith(
      email: email.trim().toLowerCase(),
      firstName: firstName.trim(),
      lastName: lastName.trim(),
    );
  }

  void setFirstName(String? value) {
    state = state.copyWith(firstName: value);
  }

  void setLastName(String? value) {
    state = state.copyWith(lastName: value);
  }

  void setNotificationsOn(bool? value) {
    state = state.copyWith(notificationsOn: value);
  }

  void clear() {
    state = const ProfileData();
  }
}

/// Exposed provider: use `ref.read(profileDataProvider.notifier)` to update.
final profileDataProvider =
    StateNotifierProvider<ProfileDataNotifier, ProfileData>((ref) {
      return ProfileDataNotifier();
    });
