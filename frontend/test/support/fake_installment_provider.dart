import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:miajudai/models/installment_model.dart';
import 'package:miajudai/providers/installment_provider.dart';

/// `InstallmentProvider` de teste.
///
/// O real instancia `InstallmentService` (HTTP). Este fake serve os dados que o
/// teste define e REGISTRA cada chamada com os argumentos recebidos, para
/// provar que a UI continua acionando o provider exatamente do mesmo jeito.
///
/// `getMonthlyTotal` espelha a formula do provider real (parcela ativa dentro
/// da janela de meses) e registra o mes pedido: e assim que os testes provam
/// que a tela pede o total do mes SELECIONADO.
class FakeInstallmentProvider extends ChangeNotifier
    implements InstallmentProvider {
  List<InstallmentModel> items = [];

  final List<String> loadCalls = [];
  final List<DateTime> totalCalls = [];
  final List<
      ({
        String token,
        String name,
        double totalAmount,
        int totalInstallments,
        int dueDayOfMonth,
        DateTime startDate,
        String? description,
        String paymentMethod,
        String? merchantName,
      })> addCalls = [];
  final List<({String token, int id})> removeCalls = [];

  /// Quando definido, `removeInstallment` so termina quando ele completar: o
  /// dialogo de remocao tem de continuar aberto ate la.
  Completer<void>? removeGate;

  @override
  List<InstallmentModel> get installments => items;

  @override
  double getMonthlyTotal(DateTime month) {
    totalCalls.add(month);
    return items.where((i) {
      final monthsDiff = (month.year - i.startDate.year) * 12 +
          (month.month - i.startDate.month);
      return i.isActive && monthsDiff >= 0 && monthsDiff < i.totalInstallments;
    }).fold(0, (sum, i) => sum + i.installmentValue);
  }

  @override
  Future<void> loadInstallments(String token) async {
    loadCalls.add(token);
  }

  @override
  Future<void> addInstallment(
    String token, {
    required String name,
    required double totalAmount,
    required int totalInstallments,
    required int dueDayOfMonth,
    required DateTime startDate,
    String? description,
    String paymentMethod = 'credit_card',
    String? merchantName,
  }) async {
    addCalls.add((
      token: token,
      name: name,
      totalAmount: totalAmount,
      totalInstallments: totalInstallments,
      dueDayOfMonth: dueDayOfMonth,
      startDate: startDate,
      description: description,
      paymentMethod: paymentMethod,
      merchantName: merchantName,
    ));
  }

  @override
  Future<void> removeInstallment(String token, int id) async {
    removeCalls.add((token: token, id: id));
    await removeGate?.future;
    items.removeWhere((i) => i.id == id);
    notifyListeners();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

InstallmentModel fakeInstallment({
  required int id,
  required String name,
  String? merchantName,
  double totalAmount = 1200,
  int totalInstallments = 12,
  int dueDayOfMonth = 10,
  required DateTime startDate,
  String paymentMethod = 'credit_card',
  bool isActive = true,
}) =>
    InstallmentModel(
      id: id,
      userId: 1,
      name: name,
      totalAmount: totalAmount,
      totalInstallments: totalInstallments,
      installmentValue: totalAmount / totalInstallments,
      dueDayOfMonth: dueDayOfMonth,
      startDate: startDate,
      paymentMethod: paymentMethod,
      merchantName: merchantName,
      isActive: isActive,
      createdAt: DateTime(2026, 1, 1),
    );
