import 'package:flutter/foundation.dart';
import 'package:miajudai/models/expense_model.dart';
import 'package:miajudai/providers/expense_provider.dart';

/// `ExpenseProvider` de teste.
///
/// O real instancia `ExpenseService` (HTTP). Este fake serve os dados que o
/// teste define e REGISTRA cada chamada com os argumentos recebidos, para
/// provar que a UI continua acionando o provider exatamente do mesmo jeito.
class FakeExpenseProvider extends ChangeNotifier implements ExpenseProvider {
  List<ExpenseModel> items = [];

  final List<({String token, int? month, int? year})> loadCalls = [];
  final List<
      ({
        String token,
        int categoryId,
        double amount,
        String description,
        DateTime date,
        int? accountId,
        String paymentMethod,
        String status,
        bool isRecurring,
        String? recurrenceType,
        String? tags,
      })> addCalls = [];
  final List<
      ({
        String token,
        int id,
        int categoryId,
        double amount,
        String description,
        DateTime date,
        String paymentMethod,
        String status,
        String? tags,
      })> updateCalls = [];
  final List<({String token, int id})> removeCalls = [];

  @override
  List<ExpenseModel> get expenses => items;

  @override
  Future<void> loadExpenses(String token, {int? month, int? year}) async {
    loadCalls.add((token: token, month: month, year: year));
  }

  @override
  Future<void> addExpense(
    String token,
    int categoryId,
    double amount,
    String description,
    DateTime expenseDate,
    int? accountId,
    String paymentMethod,
    String status,
    bool isRecurring,
    String? recurrenceType,
    String? tags,
  ) async {
    addCalls.add((
      token: token,
      categoryId: categoryId,
      amount: amount,
      description: description,
      date: expenseDate,
      accountId: accountId,
      paymentMethod: paymentMethod,
      status: status,
      isRecurring: isRecurring,
      recurrenceType: recurrenceType,
      tags: tags,
    ));
  }

  @override
  Future<void> updateExpense(
    String token,
    int expenseId,
    int categoryId,
    double amount,
    String description,
    DateTime expenseDate,
    String paymentMethod,
    String status,
    String? tags,
  ) async {
    updateCalls.add((
      token: token,
      id: expenseId,
      categoryId: categoryId,
      amount: amount,
      description: description,
      date: expenseDate,
      paymentMethod: paymentMethod,
      status: status,
      tags: tags,
    ));
  }

  @override
  Future<void> removeExpense(String token, int expenseId) async {
    removeCalls.add((token: token, id: expenseId));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

ExpenseModel fakeExpense({
  required int id,
  required String description,
  double amount = 0,
  int categoryId = 5,
  String paymentMethod = 'cash',
  String status = 'paid',
  DateTime? date,
}) =>
    ExpenseModel(
      id: id,
      userId: 1,
      categoryId: categoryId,
      amount: amount,
      description: description,
      expenseDate: date ?? DateTime(2026, 9, 5),
      isRecurring: false,
      paymentMethod: paymentMethod,
      status: status,
      createdAt: DateTime(2026, 9, 1),
    );
