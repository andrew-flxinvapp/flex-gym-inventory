import 'package:flex_gym_inventory/providers/profile_data_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('keeps signup names tied to their email through preference updates', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(profileDataProvider.notifier);
    notifier.setSignupDetails(
      email: ' NewUser@example.com ',
      firstName: ' Alex ',
      lastName: ' Smith ',
    );
    notifier.setNotificationsOn(false);

    final profile = container.read(profileDataProvider);
    expect(profile.email, 'newuser@example.com');
    expect(profile.firstName, 'Alex');
    expect(profile.lastName, 'Smith');
    expect(profile.notificationsOn, isFalse);
    expect(profile.belongsToEmail('NEWUSER@example.com'), isTrue);
    expect(profile.belongsToEmail('another@example.com'), isFalse);
  });
}
