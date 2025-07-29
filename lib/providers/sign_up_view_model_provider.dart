import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flex_gym_inventory/view_models/sign_up_view_model.dart';

/// Provider for SignUpViewModel using Riverpod.
final signUpViewModelProvider = ChangeNotifierProvider<SignUpViewModel>((ref) {
  return SignUpViewModel();
});
