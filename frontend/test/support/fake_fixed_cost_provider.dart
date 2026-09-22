import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:miajudai/models/fixed_cost_model.dart';
import 'package:miajudai/providers/fixed_cost_provider.dart';

/// `FixedCostProvider` de teste.
///
/// O real instancia `FixedCostService` (HTTP). Este fake serve os dados que o
/// teste define e REGISTRA cada chamada com os argumentos recebidos.
///
/// `getFixedCostsForMonth` e `getMonthlyTotal` espelham a regra do provider
/// real (gasto ativo criado ate o mes pedido) e registram o mes pedido.
class FakeFixedCostProvider extends ChangeNotifier
    implements FixedCostProvider {
  List<FixedCostModel> items = [];

  final List<String> loadCalls = [];
  final List<DateTime> totalCalls = [];
  final List<
      ({
        String token,
        String name,
        double amount,
        int dueDayOfMonth,
        String category,
        String? description,
      })> addCalls = [];
  final List<({String token, int id})> removeCalls = [];

  /// Quando definido, `removeFixedCost` so termina quando ele completar: o
  /// dialogo de remocao tem de continuar aberto ate la.
  Completer<void>? removeGate;

  @override
  List<FixedCostModel> get fixedCosts => items;

  @override
  List<FixedCostModel> getFixedCostsForMonth(DateTime month) {
    return items
        .where((f) =>
            f.isActive &&
            f.createdAt.year <= month.year &&
            (f.createdAt.year < month.year || f.createdAt.month <= month.month))
        .toList();
  }

  @override
  double getMonthlyTotal(DateTime month) {
    totalCalls.add(month);
    return getFixedCostsForMonth(month).fold(0, (sum, f) => sum + f.amount);
  }

  @override
  Future<void> loadFixedCosts(String token) async {
    loadCalls.add(token);
  }

  @override
  Future<void> addFixedCost(
    String token, {
    required String name,
    required double amount,
    required int dueDayOfMonth,
    required String category,
    String? description,
  }) async {
    addCalls.add((
      token: token,
      name: name,
      amount: amount,
      dueDayOfMonth: dueDayOfMonth,
      category: category,
      description: description,
    ));
  }

  @override
  Future<void> removeFixedCost(String token, int id) async {
    removeCalls.add((token: token, id: id));
    await removeGate?.future;
    items.removeWhere((f) => f.id == id);
    notifyListeners();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

FixedCostModel fakeFixedCost({
  required int id,
  required String name,
  double amount = 50,
  int dueDayOfMonth = 15,
  String category = 'other',
  required DateTime createdAt,
  bool isActive = true,
}) =>
    FixedCostModel(
      id: id,
      userId: 1,
      name: name,
      amount: amount,
      dueDayOfMonth: dueDayOfMonth,
      category: category,
      isActive: isActive,
      createdAt: createdAt,
    );
