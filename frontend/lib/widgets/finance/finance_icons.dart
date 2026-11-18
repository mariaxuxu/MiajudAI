import 'package:flutter/material.dart';

/// Icone de uma categoria de gasto fixo (streaming, aluguel, utilidade...).
///
/// Fonte unica do mapeamento categoria -> icone, antes duplicado nas telas de
/// financas, fatura e despesas.
IconData fixedCostCategoryIcon(String category) {
  return switch (category) {
    'streaming' => Icons.play_circle_outline,
    'rent' => Icons.home_outlined,
    'utility' => Icons.lightbulb_outline,
    'subscription' => Icons.card_membership,
    'insurance' => Icons.security_outlined,
    _ => Icons.category_outlined,
  };
}
