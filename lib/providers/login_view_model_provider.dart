import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../view_models/login_view_model.dart';

/// Provides a singleton instance of LoginViewModel for the login screen.
final loginViewModelProvider = ChangeNotifierProvider<LoginViewModel>((ref) {
  final viewModel = LoginViewModel();
  ref.onDispose(() => viewModel.dispose());
  return viewModel;
});
