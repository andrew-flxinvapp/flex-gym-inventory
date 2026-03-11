import '../repositories/auth_repository.dart';

/// App-level helper for registering device tokens in a provider-agnostic way.
///
/// Call `DeviceTokenManager.instance.registerToken(...)` from any place in
/// the app once you have a provider token (APNs/FCM/OneSignal). This keeps
/// token persistence logic centralized and makes it easier to add analytics
/// or retry logic later.
class DeviceTokenManager {
  DeviceTokenManager._(this._authRepository);

  final AuthRepository _authRepository;

  static final DeviceTokenManager instance = DeviceTokenManager._(AuthRepository());

  /// Register a token for the currently authenticated user.
  ///
  /// This will upsert a row into `device_tokens` and also persist a fallback
  /// value into user metadata (via `registerDeviceToken`) for quick lookups.
  Future<void> registerToken({
    required String token,
    required String platform,
    String? deviceId,
  }) async {
    if (token.isEmpty) return;

    // Upsert into device_tokens table for backend delivery later.
    await _authRepository.upsertDeviceToken(token: token, platform: platform, deviceId: deviceId);

    // Also persist a lightweight lastDeviceToken in user metadata as a
    // fallback for debugging or simple checks.
    await _authRepository.registerDeviceToken(token, platform: platform);
  }
}
