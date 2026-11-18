// Testes do helper puro de agregacao de gastos (despesas + parcelas + fixos).
//
// A regra de "mes" replica a dos providers/FinanceScreen. Aqui provamos o
// comportamento observavel: classificacao por tipo, rotulo/valor, janela de
// meses, total e ordenacao estavel.

import 'package:flutter_test/flutter_test.dart';
import 'package:miajudai/utils/unified_gastos.dart';

import 'support/fake_expense_provider.dart';
import 'support/fake_fixed_cost_provider.dart';
import 'support/fake_installment_provider.dart';

void main() {
  final month = DateTime(2026, 9);

  group('buildUnifiedGastos', () {
    test('devolve vazio quando as tres listas sao vazias', () {
      final r = buildUnifiedGastos([], [], [], month);

      expect(r.items, isEmpty);
      expect(r.total, 0);
    });

    test('une os tres tipos com rotulo, valor e dia de vencimento', () {
      final expenses = [
        fakeExpense(
          id: 1,
          description: 'Mercado',
          amount: 320.45,
          date: DateTime(2026, 9, 5),
        ),
      ];
      final installments = [
        fakeInstallment(
          id: 1,
          name: 'iPhone',
          merchantName: 'Apple Store',
          totalAmount: 1200,
          totalInstallments: 12,
          dueDayOfMonth: 10,
          startDate: DateTime(2026, 9, 1),
        ),
      ];
      final fixedCosts = [
        fakeFixedCost(
          id: 1,
          name: 'Netflix',
          amount: 55.9,
          dueDayOfMonth: 15,
          category: 'streaming',
          createdAt: DateTime(2026, 1, 1),
        ),
      ];

      final r = buildUnifiedGastos(expenses, installments, fixedCosts, month);

      expect(
        r.items.map((g) => g.kind).toList(),
        [GastoKind.despesa, GastoKind.parcela, GastoKind.fixo],
      );
      expect(
        r.items.map((g) => g.label).toList(),
        ['Mercado', 'Apple Store', 'Netflix'],
      );
      expect(
        r.items.map((g) => g.amount).toList(),
        [320.45, 100.0, 55.9],
      );

      final despesa = r.items[0];
      expect(despesa.date, DateTime(2026, 9, 5));
      expect(despesa.dueDayOfMonth, isNull);

      final parcela = r.items[1];
      expect(parcela.dueDayOfMonth, 10);
      expect(parcela.installmentNumber, 1); // mes 1 de 12
      expect(parcela.totalInstallments, 12);

      final fixo = r.items[2];
      expect(fixo.dueDayOfMonth, 15);
    });

    test('o total e a soma dos tres tipos', () {
      final r = buildUnifiedGastos(
        [fakeExpense(id: 1, description: 'a', amount: 100, date: DateTime(2026, 9, 1))],
        [
          fakeInstallment(
            id: 1,
            name: 'i',
            totalAmount: 200,
            totalInstallments: 2,
            dueDayOfMonth: 2,
            startDate: DateTime(2026, 9, 1),
          ),
        ],
        [
          fakeFixedCost(
            id: 1,
            name: 'f',
            amount: 30,
            createdAt: DateTime(2026, 1, 1),
          ),
        ],
        month,
      );

      expect(r.total, closeTo(230, 0.001)); // 100 + 100 + 30
    });

    test('parcela so conta dentro da janela de meses', () {
      final inMonth = fakeInstallment(
        id: 1,
        name: 'ativa',
        totalAmount: 240,
        totalInstallments: 12,
        startDate: DateTime(2026, 9, 1),
      );
      final notYetStarted = fakeInstallment(
        id: 2,
        name: 'futura',
        totalAmount: 240,
        totalInstallments: 12,
        startDate: DateTime(2026, 11, 1),
      );
      final alreadyDone = fakeInstallment(
        id: 3,
        name: 'encerrada',
        totalAmount: 240,
        totalInstallments: 2,
        startDate: DateTime(2026, 6, 1),
      );
      final inactive = fakeInstallment(
        id: 4,
        name: 'inativa',
        totalAmount: 240,
        totalInstallments: 12,
        startDate: DateTime(2026, 9, 1),
        isActive: false,
      );

      final r = buildUnifiedGastos(
        [],
        [inMonth, notYetStarted, alreadyDone, inactive],
        [],
        month,
      );

      expect(r.items.map((g) => g.label).toList(), ['ativa']);
    });

    test('fixo so conta quando ativo e criado ate o mes', () {
      final active = fakeFixedCost(
        id: 1,
        name: 'ativo',
        createdAt: DateTime(2026, 9, 1),
      );
      final future = fakeFixedCost(
        id: 2,
        name: 'futuro',
        createdAt: DateTime(2026, 12, 1),
      );
      final inactive = fakeFixedCost(
        id: 3,
        name: 'inativo',
        createdAt: DateTime(2026, 1, 1),
        isActive: false,
      );

      final r = buildUnifiedGastos([], [], [active, future, inactive], month);

      expect(r.items.map((g) => g.label).toList(), ['ativo']);
    });

    test('a posicao "N de M" acompanha a parcela do mes', () {
      final fromStart = fakeInstallment(
        id: 1,
        name: 'iphone',
        totalAmount: 1200,
        totalInstallments: 12,
        startDate: DateTime(2026, 1, 1),
      );

      final r = buildUnifiedGastos([], [fromStart], [], DateTime(2026, 9));

      expect(r.items.single.installmentNumber, 9); // janeiro..setembro
      expect(r.items.single.totalInstallments, 12);
    });

    test('ordena por data/dia de vencimento e, em empate, por natureza', () {
      // despesa dia 5, fixo dia 5, parcela dia 5 -> ordem por natureza
      // despesa < parcela < fixo; e uma despesa dia 3 vem antes de todas.
      final r = buildUnifiedGastos(
        [
          fakeExpense(id: 1, description: 'desp5', amount: 1, date: DateTime(2026, 9, 5)),
          fakeExpense(id: 2, description: 'desp3', amount: 1, date: DateTime(2026, 9, 3)),
        ],
        [
          fakeInstallment(
            id: 1,
            name: 'parc5',
            totalAmount: 12,
            totalInstallments: 12,
            dueDayOfMonth: 5,
            startDate: DateTime(2026, 9, 1),
          ),
        ],
        [
          fakeFixedCost(
            id: 1,
            name: 'fixo5',
            dueDayOfMonth: 5,
            createdAt: DateTime(2026, 1, 1),
          ),
        ],
        month,
      );

      expect(
        r.items.map((g) => '${g.kind.name}:${g.label}').toList(),
        ['despesa:desp3', 'despesa:desp5', 'parcela:parc5', 'fixo:fixo5'],
      );
    });

    test('em empate total, preserva a ordem original de entrada', () {
      // Duas despesas no mesmo dia e mesma natureza: a ordem de entrada vence.
      final r = buildUnifiedGastos(
        [
          fakeExpense(id: 1, description: 'B', amount: 1, date: DateTime(2026, 9, 5)),
          fakeExpense(id: 2, description: 'A', amount: 1, date: DateTime(2026, 9, 5)),
        ],
        [],
        [],
        month,
      );

      expect(r.items.map((g) => g.label).toList(), ['B', 'A']);
    });

    test('parcela usa merchantName e cai para name quando ausente', () {
      final withMerchant = fakeInstallment(
        id: 1,
        name: 'Nome',
        merchantName: 'Loja',
        totalAmount: 10,
        totalInstallments: 10,
        startDate: DateTime(2026, 9, 1),
      );
      final withoutMerchant = fakeInstallment(
        id: 2,
        name: 'SoNome',
        totalAmount: 10,
        totalInstallments: 10,
        startDate: DateTime(2026, 9, 1),
      );

      final r = buildUnifiedGastos([], [withMerchant, withoutMerchant], [], month);

      expect(r.items.map((g) => g.label).toList(), ['Loja', 'SoNome']);
    });
  });
}
