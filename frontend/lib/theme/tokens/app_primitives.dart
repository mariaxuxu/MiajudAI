import 'package:flutter/widgets.dart';

/// Camada 1 do Design System: PRIMITIVOS.
///
/// Valores crus, sem significado de uso. Nenhum widget deve consumir esta
/// classe diretamente — use a camada semantica em `app_colors_semantic.dart`.
///
/// Primitives -> Semantic Tokens -> Component Tokens -> Components -> Screens
abstract final class AppPrimitives {
  // ── Blue (acao primaria / marca) ───────────────────────────────────────
  static const Color blue50 = Color(0xFFEFF6FF);
  static const Color blue100 = Color(0xFFDBEAFE);
  static const Color blue200 = Color(0xFFBFDBFE);
  static const Color blue500 = Color(0xFF3B82F6);
  static const Color blue600 = Color(0xFF2563EB); // Primary do DS
  static const Color blue700 = Color(0xFF1D4ED8);

  // ── Navy (texto forte / marca) ─────────────────────────────────────────
  static const Color navy900 = Color(0xFF0F172A); // Brand Navy do DS
  // Navy de marca das superficies de enfase (hero de saldo). Amostrado do
  // prototipo: #174663 no topo esquerdo, #143450 na base.
  static const Color navy700 = Color(0xFF174663);
  static const Color navy800 = Color(0xFF12324E);

  // ── Slate (superficies neutras e texto) ────────────────────────────────
  static const Color slate50 = Color(0xFFF8FAFC); // Background do DS
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate200 = Color(0xFFE2E8F0); // Border do DS
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate600 = Color(0xFF475569);
  static const Color white = Color(0xFFFFFFFF); // Surface do DS

  // ── Feedback ───────────────────────────────────────────────────────────
  static const Color emerald50 = Color(0xFFECFDF5);
  static const Color emerald100 = Color(0xFFD1FAE5);
  static const Color emerald500 = Color(0xFF10B981); // Success do DS
  static const Color emerald600 = Color(0xFF059669);
  static const Color emerald700 = Color(0xFF047857);

  static const Color amber50 = Color(0xFFFFFBEB);
  static const Color amber500 = Color(0xFFF59E0B); // Warning do DS
  static const Color amber700 = Color(0xFFB45309);

  static const Color red50 = Color(0xFFFEF2F2);
  static const Color red100 = Color(0xFFFEE2E2);
  static const Color red500 = Color(0xFFEF4444); // Error do DS
  static const Color red600 = Color(0xFFDC2626);
  static const Color red700 = Color(0xFFB91C1C);

  // ── Modulos ────────────────────────────────────────────────────────────
  static const Color violet50 = Color(0xFFF5F3FF);
  static const Color violet100 = Color(0xFFEDE9FE);
  static const Color violet500 = Color(0xFF8B5CF6); // AI do DS
  static const Color violet600 = Color(0xFF7C3AED);
  static const Color violet700 = Color(0xFF6D28D9);

  static const Color cyan50 = Color(0xFFECFEFF);
  static const Color cyan100 = Color(0xFFCFFAFE);
  static const Color cyan500 = Color(0xFF06B6D4); // Cleaning do DS
  static const Color cyan600 = Color(0xFF0891B2);
  static const Color cyan700 = Color(0xFF0E7490);

  // ── Escala de espacamento: grid base 4px ───────────────────────────────
  static const double space1 = 4;
  static const double space2 = 8;
  static const double space3 = 12;
  static const double space4 = 16; // default spacing do DS
  static const double space5 = 20;
  static const double space6 = 24; // screen horizontal padding do DS
  static const double space8 = 32;
  static const double space10 = 40;
  static const double space12 = 48;
  static const double space16 = 64;

  // ── Raios ──────────────────────────────────────────────────────────────
  static const double radius8 = 8;
  static const double radius12 = 12; // button / input do DS
  static const double radius16 = 16; // card do DS
  static const double radius24 = 24;
  static const double radiusFull = 999;

  // ── Elevacao (sombras suaves, coerentes com a direcao clean) ───────────
  static const List<BoxShadow> shadowSm = [
    BoxShadow(
      color: Color(0x0F0F172A),
      blurRadius: 4,
      offset: Offset(0, 1),
    ),
  ];

  static const List<BoxShadow> shadowMd = [
    BoxShadow(
      color: Color(0x140F172A),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> shadowLg = [
    BoxShadow(
      color: Color(0x1A0F172A),
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];
}
