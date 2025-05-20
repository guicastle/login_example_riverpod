class AuthService {
  Future<void> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 2));
    if (email == 'admin' && password == '1234') {
      return;
    } else {
      throw Exception('Credenciais inválidas');
    }
  }
}
