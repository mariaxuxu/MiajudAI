import 'package:flutter/foundation.dart';
import 'package:miajudai/providers/auth_provider.dart';

/// `AuthProvider` de teste.
///
/// O real instancia `AuthService`, que le `FirebaseAuth.instance` no
/// construtor e falha sem Firebase inicializado. Este fake expoe so o que as
/// telas de autenticacao consomem e REGISTRA as chamadas, para os testes
/// provarem que a UI continua acionando o provider do mesmo jeito.
class FakeAuthProvider extends ChangeNotifier implements AuthProvider {
  bool loading = false;
  bool authenticated = false;
  String? errorMessage;

  final List<({String email, String password})> loginCalls = [];
  final List<({String email, String password, String fullName})> signupCalls =
      [];

  void setLoading(bool value) {
    loading = value;
    notifyListeners();
  }

  @override
  bool get isLoading => loading;

  @override
  bool get isAuthenticated => authenticated;

  @override
  String? get error => errorMessage;

  @override
  Future<void> login({required String email, required String password}) async {
    loginCalls.add((email: email, password: password));
  }

  @override
  Future<void> signup({
    required String email,
    required String password,
    required String fullName,
  }) async {
    signupCalls.add((email: email, password: password, fullName: fullName));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
