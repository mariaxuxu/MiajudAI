import 'package:flutter/foundation.dart';
import 'package:miajudai/models/income_model.dart';
import 'package:miajudai/providers/income_provider.dart';

/// `IncomeProvider` de teste.
///
/// O real instancia `IncomeService` (HTTP). Este fake serve os dados que o
/// teste define e REGISTRA cada chamada com os argumentos recebidos, para
/// provar que a UI continua acionando o provider exatamente do mesmo jeito.
class FakeIncomeProvider extends ChangeNotifier implements IncomeProvider {
  List<IncomeModel> items = [];
  double total = 0;

  final List<({String token, int? month, int? year})> loadCalls = [];
  final List<
      ({
        String token,
        double amount,
        String description,
        String type,
        DateTime date,
        int? accountId,
        bool isRecurring,
        String? recurrenceType,
      })> addCalls = [];
  final List<
      ({
        String token,
        int id,
        double amount,
        String description,
        String type,
        DateTime date,
      })> updateCalls = [];
  final List<({String token, int id})> removeCalls = [];

  @override
  List<IncomeModel> get income => items;

  @override
  double get monthlyTotal => total;

  @override
  Future<void> loadIncome(String token, {int? month, int? year}) async {
    loadCalls.add((token: token, month: month, year: year));
  }

  @override
  Future<void> addIncome(
    String token,
    double amount,
    String description,
    String type,
    DateTime incomeDate,
    int? accountId,
    bool isRecurring,
    String? recurrenceType,
  ) async {
    addCalls.add((
      token: token,
      amount: amount,
      description: description,
      type: type,
      date: incomeDate,
      accountId: accountId,
      isRecurring: isRecurring,
      recurrenceType: recurrenceType,
    ));
  }

  @override
  Future<void> updateIncome(
    String token,
    int incomeId,
    double amount,
    String description,
    String type,
    DateTime incomeDate,
  ) async {
    updateCalls.add((
      token: token,
      id: incomeId,
      amount: amount,
      description: description,
      type: type,
      date: incomeDate,
    ));
  }

  @override
  Future<void> removeIncome(String token, int incomeId) async {
    removeCalls.add((token: token, id: incomeId));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

IncomeModel fakeIncome({
  required int id,
  required String description,
  double amount = 0,
  String type = 'salary',
  DateTime? date,
}) =>
    IncomeModel(
      id: id,
      userId: 1,
      amount: amount,
      description: description,
      type: type,
      incomeDate: date ?? DateTime(2026, 9, 5),
      isRecurring: false,
      createdAt: DateTime(2026, 9, 1),
    );
