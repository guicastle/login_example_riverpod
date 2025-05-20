# Vamos criar um exemplo prático com **Riverpod** e mostrar **injeção de dependências** de forma clara e funcional.

---

## ✅ Cenário prático: **Login com autenticação simulada**

* Simula um botão de login.
* Ao clicar, faz um "login" com tempo de espera (como uma chamada de API).
* Gerencia loading, sucesso e erro com `AsyncValue`.
* Injeção de dependência com `Provider`.

---

## 📁 Estrutura dos arquivos

```
lib/
├── main.dart
├── auth/
│   ├── auth_service.dart
│   ├── auth_provider.dart
│   ├── login_controller.dart
│   └── login_page.dart
```

---

## 🧠 Serviço de Autenticação (`auth_service.dart`)

```dart
// lib/auth/auth_service.dart

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
```

---

## 💉 Injeção de dependência com `Provider` (`auth_provider.dart`)

```dart
// lib/auth/auth_provider.dart

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
```

---

## Monta o controller `Controller` (`login_controller.dart`)

```dart
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
```

---

## 🖥️ Tela de Login (`login_page.dart`)

```dart
// lib/auth/login_page.dart

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
```

---

## 4. 🚀 Inicialização (`main.dart`)

```dart
// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth/login_page.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Riverpod Auth Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LoginPage(),
    );
  }
}
```

---

## 📌 O que você vai aprendeu aqui:

* `Provider` → injeta uma dependência (como o `AuthService`)
* `StateNotifierProvider` → gerencia estado e lógica do login
* `AsyncValue` → facilita controle de carregamento, erro e sucesso
* `ConsumerWidget` e `WidgetRef` → acessam os estados nos widgets

---

No Riverpod (especialmente com `AsyncValue` e `AsyncNotifier`/`FutureProvider`), os termos **reload** e **refresh** têm significados diferentes — e saber isso ajuda a usar bem os parâmetros como `skipLoadingOnReload` e `skipLoadingOnRefresh`.

---

## 🔁 Diferença entre `Reload` e `Refresh`

| Conceito    | O que é                                                                 | Como acontece?                         |
| ----------- | ----------------------------------------------------------------------- | -------------------------------------- |
| **Reload**  | Riverpod refaz o cálculo porque **alguma dependência mudou**            | Automático: muda um `ref.watch(...)`   |
| **Refresh** | Você **força** a execução novamente, como se fosse um "pull to refresh" | Manual: usando `ref.refresh(provider)` |

---

## ✅ Explicando com exemplos:

### 📦 Exemplo de **reload** (mudança de dependência):

```dart
final userProvider = Provider<String>((ref) => 'admin');

final userDataProvider = FutureProvider((ref) {
  final user = ref.watch(userProvider); // depende de outro provider
  return fetchUserData(user);
});
```

> Sempre que `userProvider` mudar, o `userDataProvider` é **"reloaded"** automaticamente.

---

### 🔄 Exemplo de **refresh** (forçado manualmente):

```dart
ElevatedButton(
  onPressed: () {
    ref.refresh(userDataProvider); // força nova execução
  },
  child: Text('Atualizar dados'),
)
```

> Aqui, você está dizendo: "me dá os dados de novo, do zero" — mesmo que nada tenha mudado.

---

## ⚙️ Onde entram `skipLoadingOnReload` e `skipLoadingOnRefresh`?

| Flag                   | Serve para...                                                         |
| ---------------------- | --------------------------------------------------------------------- |
| `skipLoadingOnReload`  | Não mostrar loading quando **dependência mudar**                      |
| `skipLoadingOnRefresh` | Não mostrar loading quando você chamar `ref.refresh(...)` manualmente |

---

## 🧠 Analogia simples:

| Ação                     | Tipo    | Analogia                                               |
| ------------------------ | ------- | ------------------------------------------------------ |
| Atualiza por dependência | Reload  | Ex: troca o usuário logado                             |
| Atualiza por botão/gesto | Refresh | Ex: botão “tentar novamente” ou “puxar para atualizar” |

---

### **Diferença básica entre Reload e Refresh**:

* **Reload**: O **Riverpod** recálcula automaticamente o provider porque **algo mudou** (uma dependência foi atualizada).
* **Refresh**: Você **força** a atualização do provider manualmente, mesmo que nada tenha mudado.

### Exemplo concreto:

#### 1. **Reload (automaticamente ao mudar dependência)**

```dart
final userProvider = Provider<String>((ref) => 'admin'); // Fornece o nome do usuário

// Este provider depende do userProvider
final userDataProvider = FutureProvider<String>((ref) {
  final user = ref.watch(userProvider); // Se userProvider mudar, userDataProvider é recalculado (reload)
  return 'Dados do usuário: $user';
});
```

* Quando `userProvider` mudar (por exemplo, o nome do usuário), **`userDataProvider` será recarregado automaticamente**.

#### 2. **Refresh (forçado manualmente)**

```dart
ElevatedButton(
  onPressed: () {
    ref.refresh(userDataProvider); // Força a execução de userDataProvider manualmente (refresh)
  },
  child: const Text('Atualizar Dados'),
)
```

* Isso faz com que **`userDataProvider` seja recarregado manualmente**, independentemente de qualquer mudança.

---

### Resumo Simples:

* **Reload**: Quando algo muda no estado (por exemplo, `userProvider` muda), o **provider dependente** também é recarregado automaticamente.
* **Refresh**: Você **força** a atualização do provider chamando `ref.refresh(provider)`.

---
