/// Formata um valor monetario em reais, no padrao legado das telas de financas:
/// "R$ 1234,56" (duas casas, virgula decimal, sem separador de milhar).
String formatMoney(double value) =>
    'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
