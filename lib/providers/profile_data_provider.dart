import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Lightweight in-memory profile data carried through onboarding.
class ProfileData {
  final String? firstName;
  final String? lastName;
  final bool? notificationsOn;

  const ProfileData({this.firstName, this.lastName, this.notificationsOn});

  ProfileData copyWith({String? firstName, String? lastName, bool? notificationsOn}) {
    return ProfileData(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      notificationsOn: notificationsOn ?? this.notificationsOn,
    );
  }
}

class ProfileDataNotifier extends StateNotifier<ProfileData> {
  ProfileDataNotifier() : super(const ProfileData());

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
final profileDataProvider = StateNotifierProvider<ProfileDataNotifier, ProfileData>((ref) {
  return ProfileDataNotifier();
});
