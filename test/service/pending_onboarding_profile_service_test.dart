import 'package:flex_gym_inventory/service/pending_onboarding_profile_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('saves and loads pending names by normalized email', () async {
    await PendingOnboardingProfileService.save(
      email: ' NewUser@example.com ',
      firstName: ' Alex ',
      lastName: ' Smith ',
    );

    final names = await PendingOnboardingProfileService.load(
      'newuser@example.com',
    );

    expect(names?.firstName, 'Alex');
    expect(names?.lastName, 'Smith');
  });

  test('keeps pending names separate between email accounts', () async {
    await PendingOnboardingProfileService.save(
      email: 'first@example.com',
      firstName: 'First',
      lastName: 'User',
    );
    await PendingOnboardingProfileService.save(
      email: 'second@example.com',
      firstName: 'Second',
      lastName: 'User',
    );

    expect(
      (await PendingOnboardingProfileService.load(
        'first@example.com',
      ))?.firstName,
      'First',
    );
    expect(
      (await PendingOnboardingProfileService.load(
        'second@example.com',
      ))?.firstName,
      'Second',
    );
  });

  test('clears pending names after onboarding', () async {
    await PendingOnboardingProfileService.save(
      email: 'user@example.com',
      firstName: 'Alex',
      lastName: 'Smith',
    );

    await PendingOnboardingProfileService.clear('user@example.com');

    expect(
      await PendingOnboardingProfileService.load('user@example.com'),
      isNull,
    );
  });
}
