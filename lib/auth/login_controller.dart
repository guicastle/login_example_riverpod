import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:login_example_riverpod/auth/auth_provider.dart';

class LoginController extends StateNotifier<AsyncValue<void>> {
  final Ref ref;
  bool _attempted = false; // <- flag privada

  bool get attempted => _attempted;

  LoginController(this.ref) : super(const AsyncValue.data(null));

  Future<void> login(String email, String password) async {
    _attempted = true;
    state = const AsyncValue.loading();

    try {
      await ref.read(authServiceProvider).login(email, password);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
