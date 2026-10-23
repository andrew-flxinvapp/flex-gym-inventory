import 'package:supabase_flutter/supabase_flutter.dart';

typedef CurrentUserIdReader = String? Function();

class OwnershipContext {
  OwnershipContext({CurrentUserIdReader? currentUserIdReader})
    : _currentUserIdReader = currentUserIdReader ?? _readAuthenticatedUserId;

  final CurrentUserIdReader _currentUserIdReader;

  String? get currentUserId {
    final userId = _currentUserIdReader();
    return userId == null || userId.isEmpty ? null : userId;
  }

  bool isCurrentUser(String userId) => currentUserId == userId;
}

String? _readAuthenticatedUserId() =>
    Supabase.instance.client.auth.currentUser?.id;
