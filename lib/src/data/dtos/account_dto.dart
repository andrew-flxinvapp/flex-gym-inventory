// Generated scaffold for Account DTO used by account screen and data layer
import 'dart:convert';
class AccountDto {
  final String id;
  final String email;
  final String? phoneNumber;
  final String? displayName;
  final String? avatarUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? settings;
  final String? subscriptionStatus;
  final String? subscriptionPlan;
  final String? subscriptionProvider;
  final DateTime? subscriptionExpiresAt;
  final bool subscriptionActive;
  final DateTime? subscriptionLastSynced;
  final Map<String, dynamic>? subscriptionMetadata;
  final List<String>? deviceIds;
  final int wishlistCount;

  const AccountDto({
    required this.id,
    required this.email,
    this.displayName,
    this.phoneNumber,
    this.avatarUrl,
    this.createdAt,
    this.updatedAt,
    this.settings,
    this.subscriptionStatus,
    this.deviceIds,
    this.wishlistCount = 0,
    this.subscriptionPlan,
    this.subscriptionProvider,
    this.subscriptionExpiresAt,
    this.subscriptionActive = false,
    this.subscriptionLastSynced,
    this.subscriptionMetadata,
  });

  factory AccountDto.fromJson(Map<String, dynamic> json) {
    return AccountDto(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['display_name'] as String?,
      phoneNumber: json['phone_number'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
      settings: json['settings'] as Map<String, dynamic>?,
      subscriptionStatus: json['subscription_status'] as String?,
      subscriptionPlan: json['subscription_plan'] as String?,
      subscriptionProvider: json['subscription_provider'] as String?,
      subscriptionExpiresAt: json['subscription_expires_at'] != null ? DateTime.tryParse(json['subscription_expires_at'] as String) : null,
      subscriptionActive: json['subscription_active'] == true || json['subscription_active'] == 'true',
      subscriptionLastSynced: json['subscription_last_synced'] != null ? DateTime.tryParse(json['subscription_last_synced'] as String) : null,
      subscriptionMetadata: json['subscription_metadata'] as Map<String, dynamic>?,
      deviceIds: json['device_ids'] != null ? List<String>.from(json['device_ids'] as List) : null,
      wishlistCount: json['wishlist_count'] is int ? json['wishlist_count'] as int : (json['wishlist_count'] != null ? int.tryParse(json['wishlist_count'].toString()) ?? 0 : 0),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'display_name': displayName,
        'phone_number': phoneNumber,
        'avatar_url': avatarUrl,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
        'settings': settings,
        'subscription_status': subscriptionStatus,
        'device_ids': deviceIds,
        'wishlist_count': wishlistCount,
        'subscription_plan': subscriptionPlan,
        'subscription_provider': subscriptionProvider,
        'subscription_expires_at': subscriptionExpiresAt?.toIso8601String(),
        'subscription_active': subscriptionActive,
        'subscription_last_synced': subscriptionLastSynced?.toIso8601String(),
        'subscription_metadata': subscriptionMetadata,
      };

  factory AccountDto.fromSupabase(Map<String, dynamic> row) => AccountDto.fromJson(row);

  Map<String, dynamic> toSupabaseRow() => toJson();

  Map<String, dynamic> toIsarMap() => {
        'id': id,
        'email': email,
      'displayName': displayName,
      'phoneNumber': phoneNumber,
      'avatarUrl': avatarUrl,
        'createdAt': createdAt?.millisecondsSinceEpoch,
        'updatedAt': updatedAt?.millisecondsSinceEpoch,
        // Store settings as JSON string for Isar compatibility.
        'settingsJson': settings != null ? jsonEncode(settings) : null,
        'subscriptionStatus': subscriptionStatus,
      'deviceIds': deviceIds,
      'wishlistCount': wishlistCount,
      'subscriptionPlan': subscriptionPlan,
      'subscriptionProvider': subscriptionProvider,
      'subscriptionExpiresAt': subscriptionExpiresAt?.millisecondsSinceEpoch,
      'subscriptionActive': subscriptionActive,
      'subscriptionLastSynced': subscriptionLastSynced?.millisecondsSinceEpoch,
      'subscriptionMetadataJson': subscriptionMetadata != null ? jsonEncode(subscriptionMetadata) : null,
      };

  factory AccountDto.fromIsarMap(Map<String, dynamic> map) {
    return AccountDto(
      id: map['id'] as String,
      email: map['email'] as String,
      displayName: map['displayName'] as String?,
      phoneNumber: map['phoneNumber'] as String?,
      avatarUrl: map['avatarUrl'] as String?,
      createdAt: map['createdAt'] != null ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int) : null,
      updatedAt: map['updatedAt'] != null ? DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int) : null,
      settings: map['settingsJson'] != null ? Map<String, dynamic>.from(jsonDecode(map['settingsJson'] as String) as Map) : null,
      subscriptionStatus: map['subscriptionStatus'] as String?,
      subscriptionPlan: map['subscriptionPlan'] as String?,
      subscriptionProvider: map['subscriptionProvider'] as String?,
      subscriptionExpiresAt: map['subscriptionExpiresAt'] != null ? DateTime.fromMillisecondsSinceEpoch(map['subscriptionExpiresAt'] as int) : null,
      subscriptionActive: map['subscriptionActive'] == true || map['subscriptionActive'] == 1,
      subscriptionLastSynced: map['subscriptionLastSynced'] != null ? DateTime.fromMillisecondsSinceEpoch(map['subscriptionLastSynced'] as int) : null,
      subscriptionMetadata: map['subscriptionMetadataJson'] != null ? Map<String, dynamic>.from(jsonDecode(map['subscriptionMetadataJson'] as String) as Map) : null,
      deviceIds: map['deviceIds'] != null ? List<String>.from(map['deviceIds'] as List) : null,
      wishlistCount: map['wishlistCount'] is int ? map['wishlistCount'] as int : (map['wishlistCount'] != null ? int.tryParse(map['wishlistCount'].toString()) ?? 0 : 0),
    );
  }

  AccountDto copyWith({
    String? phoneNumber,
    String? displayName,
    String? avatarUrl,
    String? subscriptionPlan,
    String? subscriptionProvider,
    DateTime? subscriptionExpiresAt,
    bool? subscriptionActive,
    DateTime? subscriptionLastSynced,
    Map<String, dynamic>? subscriptionMetadata,
    Map<String, dynamic>? settings,
    String? subscriptionStatus,
    List<String>? deviceIds,
    DateTime? updatedAt,
    int? wishlistCount,
  }) {
    return AccountDto(
      id: id,
      email: email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      settings: settings ?? this.settings,
      subscriptionStatus: subscriptionStatus ?? this.subscriptionStatus,
      deviceIds: deviceIds ?? this.deviceIds,
      wishlistCount: wishlistCount ?? this.wishlistCount,
      subscriptionPlan: subscriptionPlan ?? this.subscriptionPlan,
      subscriptionProvider: subscriptionProvider ?? this.subscriptionProvider,
      subscriptionExpiresAt: subscriptionExpiresAt ?? this.subscriptionExpiresAt,
      subscriptionActive: subscriptionActive ?? this.subscriptionActive,
      subscriptionLastSynced: subscriptionLastSynced ?? this.subscriptionLastSynced,
      subscriptionMetadata: subscriptionMetadata ?? this.subscriptionMetadata,
    );
  }

  /// Convenience: true when the user's subscription plan is `pro`.
  bool get isPro => (subscriptionPlan ?? '').toLowerCase() == 'pro';
}
