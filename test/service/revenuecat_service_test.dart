import 'dart:async';

import 'package:flex_gym_inventory/service/revenuecat_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logging/logging.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('RevenueCatService initialization', () {
    test(
      'configures SDK with informational entitlement verification',
      () async {
        const channel = MethodChannel('purchases_flutter');
        final calls = <MethodCall>[];
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (call) async {
              calls.add(call);
              return null;
            });
        addTearDown(() {
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
              .setMockMethodCallHandler(channel, null);
        });

        final service = RevenueCatService();
        await service.configure(apiKey: 'appl_test_key');

        expect(calls.map((call) => call.method), [
          'setLogLevel',
          'setupPurchases',
        ]);
        expect((calls.first.arguments as Map)['level'], 'WARN');
        expect(
          (calls.last.arguments as Map)['entitlementVerificationMode'],
          'INFORMATIONAL',
        );
      },
    );

    test('reports configured after a successful SDK setup', () async {
      var attempts = 0;
      final service = RevenueCatService(
        configureSdk: ({required apiKey, appUserId}) async {
          expect(apiKey, 'appl_test_key');
          expect(appUserId, isNull);
          attempts++;
        },
      );

      service.startConfiguration(apiKey: 'appl_test_key');
      expect(
        service.initializationState.value.status,
        RevenueCatInitializationStatus.pending,
      );
      await service.initializationTask;

      expect(
        service.initializationState.value.status,
        RevenueCatInitializationStatus.configured,
      );
      service.startConfiguration(apiKey: 'appl_another_test_key');
      expect(attempts, 1);
    });

    test('reports failures without propagating an unhandled error', () async {
      const apiKey = 'appl_test_key';
      final service = RevenueCatService(
        configureSdk:
            ({required apiKey, appUserId}) async =>
                throw Exception('Failed for $apiKey'),
      );

      service.startConfiguration(apiKey: apiKey);
      await service.initializationTask;

      expect(
        service.initializationState.value.status,
        RevenueCatInitializationStatus.failed,
      );
      expect(
        service.initializationState.value.errorMessage,
        isNot(contains(apiKey)),
      );
    });

    test('configuration failures never log raw SDK exception data', () async {
      const signedData = 'eyJhbGciOiJFUzI1Ni.fake-signature';
      const account = 'private-account-marker';
      final previousLevel = Logger.root.level;
      Logger.root.level = Level.ALL;
      final records = <LogRecord>[];
      final subscription = Logger.root.onRecord.listen(records.add);
      addTearDown(() async {
        await subscription.cancel();
        Logger.root.level = previousLevel;
      });
      final service = RevenueCatService(
        configureSdk: ({required apiKey, appUserId}) async {
          throw PlatformException(
            code: 'error',
            message: '$signedData $account $apiKey',
            details: signedData,
          );
        },
      );

      service.startConfiguration(apiKey: 'appl_test_key');
      await service.initializationTask;

      expect(
        service.initializationState.value.status,
        RevenueCatInitializationStatus.failed,
      );
      expect(
        service.initializationState.value.errorMessage,
        'RevenueCat SDK configuration error.',
      );
      final output =
          records.map((record) => '${record.message} ${record.error}').join();
      expect(output, contains('RevenueCat SDK configuration error.'));
      expect(output, isNot(contains(signedData)));
      expect(output, isNot(contains(account)));
      expect(output, isNot(contains('appl_test_key')));
    });

    test('missing key is unavailable and does not call the SDK', () async {
      var attempts = 0;
      final service = RevenueCatService(
        configureSdk: ({required apiKey, appUserId}) async => attempts++,
      );

      service.startConfiguration(apiKey: '');
      await service.initializationTask;

      expect(
        service.initializationState.value.status,
        RevenueCatInitializationStatus.unavailable,
      );
      expect(attempts, 0);
    });

    test(
      'does not retry a timed-out native attempt and observes late success',
      () async {
        final nativeAttempt = Completer<void>();
        var attempts = 0;
        final service = RevenueCatService(
          configureSdk: ({required apiKey, appUserId}) {
            attempts++;
            return nativeAttempt.future;
          },
        );

        service.startConfiguration(
          apiKey: 'appl_test_key',
          timeout: const Duration(milliseconds: 20),
        );
        await service.initializationTask;

        expect(
          service.initializationState.value.status,
          RevenueCatInitializationStatus.failed,
        );
        service.startConfiguration(apiKey: 'appl_test_key');
        expect(attempts, 1);

        nativeAttempt.complete();
        await Future<void>.delayed(Duration.zero);
        expect(
          service.initializationState.value.status,
          RevenueCatInitializationStatus.configured,
        );
      },
    );

    test('returns control while the SDK configuration is still pending', () {
      final nativeAttempt = Completer<void>();
      final service = RevenueCatService(
        configureSdk: ({required apiKey, appUserId}) => nativeAttempt.future,
      );

      service.startConfiguration(apiKey: 'appl_test_key');

      expect(
        service.initializationState.value.status,
        RevenueCatInitializationStatus.pending,
      );
      expect(nativeAttempt.isCompleted, isFalse);
    });
  });
}
