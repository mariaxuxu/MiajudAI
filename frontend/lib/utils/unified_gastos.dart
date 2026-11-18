import '../models/expense_model.dart';
import '../models/fixed_cost_model.dart';
import '../models/installment_model.dart';

/// Natureza de um gasto na lista unificada de Despesas.
///
/// E um conceito de APRESENTACAO (nao uma nova entidade de dominio): as
/// entidades subjacentes continuam sendo Expense/Installment/FixedCost.
enum GastoKind { despesa, parcela, fixo }

/// Um item da lista unificada de gastos da tela de Despesas.
///
/// Exatamente uma das tres fontes ([expense], [installment] ou [fixedCost])
/// e nao-nula, correspondendo a [kind]. Os campos [label], [amount], [date] e
/// [dueDayOfMonth] trazem o que a UI precisa exibir, sem acoplar a tela aos
/// detalhes de cada model.
class GastoItem {
  final GastoKind kind;
  final String label;
  final double amount;

  /// Data do gasto (apenas [GastoKind.despesa]).
  final DateTime? date;

  /// Dia do vencimento no mes (apenas parcela e fixo).
  final int? dueDayOfMonth;

  /// Posicao "N de M" da parcela (apenas [GastoKind.parcela]).
  final int? installmentNumber;
  final int? totalInstallments;

  final ExpenseModel? expense;
  final InstallmentModel? installment;
  final FixedCostModel? fixedCost;

  const GastoItem({
    required this.kind,
    required this.label,
    required this.amount,
    this.date,
    this.dueDayOfMonth,
    this.installmentNumber,
    this.totalInstallments,
    this.expense,
    this.installment,
    this.fixedCost,
  });
}

/// Resultado da agregacao: a lista ordenada e o total mensal.
class UnifiedGastos {
  final List<GastoItem> items;
  final double total;

  const UnifiedGastos(this.items, this.total);
}

/// Intermediario interno para ordenar de forma estavel e previsivel.
class _RankedGasto {
  final GastoItem item;
  final DateTime sortDate;
  final int order;

  const _RankedGasto({
    required this.item,
    required this.sortDate,
    required this.order,
  });
}

/// Une despesas, parcelas e gastos fixos numa unica lista de gastos.
///
/// Puro e testavel: nao depende de providers nem de rede. Recebe as tres
/// listas e o [month] selecionado e devolve a lista ordenada e o total.
///
/// Regras de "mes" replicam as dos providers (e do FinanceScreen), para que o
/// total bata com o Dashboard:
///  - despesa: ja vem escopada ao mes pelo `ExpenseProvider`;
///  - parcela: ativa dentro da janela `[startDate, startDate + totalInstallments)`;
///  - fixo: ativo e criado ate o [month].
///
/// A ordenacao e por data/dia de vencimento e, em empate, pela natureza e pela
/// ordem original de entrada — estavel e previsivel entre recargas.
UnifiedGastos buildUnifiedGastos(
  List<ExpenseModel> expenses,
  List<InstallmentModel> installments,
  List<FixedCostModel> fixedCosts,
  DateTime month,
) {
  final ranked = <_RankedGasto>[];
  var order = 0;

  for (final e in expenses) {
    ranked.add(_RankedGasto(
      item: GastoItem(
        kind: GastoKind.despesa,
        label: e.description,
        amount: e.amount,
        date: e.expenseDate,
        expense: e,
      ),
      sortDate: e.expenseDate,
      order: order++,
    ));
  }

  for (final i in installments) {
    if (!_isInstallmentActiveInMonth(i, month)) continue;
    ranked.add(_RankedGasto(
      item: GastoItem(
        kind: GastoKind.parcela,
        label: i.merchantName ?? i.name,
        amount: i.installmentValue,
        dueDayOfMonth: i.dueDayOfMonth,
        installmentNumber: _installmentNumberForMonth(i, month),
        totalInstallments: i.totalInstallments,
        installment: i,
      ),
      sortDate: DateTime(month.year, month.month, i.dueDayOfMonth),
      order: order++,
    ));
  }

  for (final f in fixedCosts) {
    if (!_isFixedCostActiveInMonth(f, month)) continue;
    ranked.add(_RankedGasto(
      item: GastoItem(
        kind: GastoKind.fixo,
        label: f.name,
        amount: f.amount,
        dueDayOfMonth: f.dueDayOfMonth,
        fixedCost: f,
      ),
      sortDate: DateTime(month.year, month.month, f.dueDayOfMonth),
      order: order++,
    ));
  }

  ranked.sort((a, b) {
    final byDate = a.sortDate.compareTo(b.sortDate);
    if (byDate != 0) return byDate;
    final byKind = a.item.kind.index.compareTo(b.item.kind.index);
    if (byKind != 0) return byKind;
    return a.order.compareTo(b.order);
  });

  final items = ranked.map((r) => r.item).toList();
  final total = items.fold<double>(0, (sum, g) => sum + g.amount);
  return UnifiedGastos(items, total);
}

bool _isInstallmentActiveInMonth(InstallmentModel i, DateTime month) {
  if (!i.isActive) return false;
  final monthsDiff =
      (month.year - i.startDate.year) * 12 + (month.month - i.startDate.month);
  return monthsDiff >= 0 && monthsDiff < i.totalInstallments;
}

int _installmentNumberForMonth(InstallmentModel i, DateTime month) {
  final monthsDiff =
      (month.year - i.startDate.year) * 12 + (month.month - i.startDate.month);
  return (monthsDiff + 1).clamp(0, i.totalInstallments).toInt();
}

bool _isFixedCostActiveInMonth(FixedCostModel f, DateTime month) {
  if (!f.isActive) return false;
  return f.createdAt.year <= month.year &&
      (f.createdAt.year < month.year || f.createdAt.month <= month.month);
}
