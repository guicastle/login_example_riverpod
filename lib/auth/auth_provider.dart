import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:login_example_riverpod/auth/login_controller.dart';
import 'auth_service.dart';

// Injeção da dependência do serviço
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// Provider de estado assíncrono para login
final loginProvider = StateNotifierProvider<LoginController, AsyncValue<void>>(
  (ref) => LoginController(ref),
);
