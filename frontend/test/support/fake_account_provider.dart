import 'package:flutter/foundation.dart';
import 'package:miajudai/models/account_model.dart';
import 'package:miajudai/providers/account_provider.dart';

/// `AccountProvider` de teste.
///
/// O real instancia `AccountService` (HTTP). Este fake serve os dados que o
/// teste define e REGISTRA cada chamada com os argumentos recebidos, para
/// provar que a UI continua acionando o provider exatamente do mesmo jeito.
class FakeAccountProvider extends ChangeNotifier implements AccountProvider {
  List<AccountModel> items = [];

  final List<String> loadCalls = [];
  final List<
      ({
        String token,
        String name,
        String type,
        String? bankName,
        String? accountNumber,
      })> addCalls = [];
  final List<({String token, int accountId})> removeCalls = [];

  @override
  List<AccountModel> get accounts => items;

  @override
  double get totalBalance => items.fold(0, (sum, a) => sum + a.balance);

  @override
  Future<void> loadAccounts(String token) async => loadCalls.add(token);

  @override
  Future<void> addAccount(
    String token,
    String name,
    String type,
    String? bankName,
    String? accountNumber,
  ) async {
    addCalls.add((
      token: token,
      name: name,
      type: type,
      bankName: bankName,
      accountNumber: accountNumber,
    ));
  }

  @override
  Future<void> removeAccount(String token, int accountId) async {
    removeCalls.add((token: token, accountId: accountId));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

AccountModel fakeAccount({
  required int id,
  required String name,
  String type = 'checking',
  double balance = 0,
}) =>
    AccountModel(
      id: id,
      userId: 1,
      name: name,
      type: type,
      balance: balance,
      isActive: true,
      createdAt: DateTime(2026, 1, 1),
    );
