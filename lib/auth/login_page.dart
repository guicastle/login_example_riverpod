import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:login_example_riverpod/auth/auth_provider.dart';

class LoginPage extends ConsumerWidget {
  LoginPage({super.key});
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginState = ref.watch(loginProvider);
    final controller = ref.read(loginProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              const Text('USE PARA O TESTE: Usuário: admin / Senha: 1234'),
              const SizedBox(height: 20),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira um email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Senha'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira uma senha';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  elevation: 4,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                onPressed:
                    loginState.isLoading
                        ? null
                        : () {
                          if (formKey.currentState?.validate() ?? false) {
                            ref
                                .read(loginProvider.notifier)
                                .login(
                                  emailController.text,
                                  passwordController.text,
                                );
                          }
                        },
                child:
                    loginState.isLoading
                        ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                        : Text('ENTRAR', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 20),

              if (!controller.attempted) ...[
                const SizedBox.shrink(), // não mostra nada se ainda não tentou
              ] else ...[
                loginState.when(
                  data: (_) => const Text('✅ Login bem-sucedido'),
                  loading:
                      () => const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                  error: (err, _) => Text('❌ Erro: ${err.toString()}'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
