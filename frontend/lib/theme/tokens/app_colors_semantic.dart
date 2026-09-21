import 'package:flutter/widgets.dart';

import 'app_primitives.dart';

/// Camada 2 do Design System: TOKENS SEMANTICOS.
///
/// Esta e a camada que os componentes consomem. Um botao nao precisa saber
/// que sua cor e `#2563EB` — ele consome [actionPrimary].
///
/// NAO substitui `AppColors` de `config/constants.dart`: aquela continua
/// valendo para as telas ainda nao redesenhadas.
abstract final class AppSemanticColors {
  // ── Superficies ────────────────────────────────────────────────────────
  static const Color background = AppPrimitives.slate50;
  static const Color surface = AppPrimitives.white;
  static const Color surfaceSubtle = AppPrimitives.slate100;
  static const Color border = AppPrimitives.slate200;
  static const Color borderStrong = AppPrimitives.slate300;

  /// Superficie de enfase (cards de destaque, ex.: hero de saldo). Gradiente
  /// de [surfaceStrong] para [surfaceStrongDeep].
  static const Color surfaceStrong = AppPrimitives.navy700;
  static const Color surfaceStrongDeep = AppPrimitives.navy800;
  static const Color onSurfaceStrong = AppPrimitives.white;

  /// Texto de apoio sobre [surfaceStrong]. Branco a 80%: contraste ~7:1.
  static const Color onSurfaceStrongMuted = Color(0xCCFFFFFF);

  // ── Acao ───────────────────────────────────────────────────────────────
  static const Color actionPrimary = AppPrimitives.blue600;
  static const Color actionPrimaryHover = AppPrimitives.blue700;
  static const Color actionPrimarySubtle = AppPrimitives.blue50;
  static const Color onAction = AppPrimitives.white;
  static const Color actionDisabled = AppPrimitives.slate200;
  static const Color onActionDisabled = AppPrimitives.slate400;

  // ── Texto ──────────────────────────────────────────────────────────────
  /// Titulos e texto de maior peso. Contraste 16.9:1 sobre [background].
  static const Color textPrimary = AppPrimitives.navy900;

  /// Texto de apoio, descricoes. Contraste 4.9:1 sobre [background].
  static const Color textSecondary = AppPrimitives.slate500;

  /// Texto de apoio sobre superficies tonais (cards de agente/modulo), onde
  /// [textSecondary] ficaria no limite do AA. Contraste >= 7:1 nos tons 50.
  static const Color textSecondaryStrong = AppPrimitives.slate600;

  /// Texto terciario / placeholders. Use apenas em texto nao essencial.
  static const Color textTertiary = AppPrimitives.slate400;

  static const Color textOnAction = AppPrimitives.white;
  static const Color textLink = AppPrimitives.blue600;

  // ── Feedback ───────────────────────────────────────────────────────────
  static const Color feedbackSuccess = AppPrimitives.emerald500;
  static const Color feedbackSuccessSubtle = AppPrimitives.emerald50;
  static const Color onFeedbackSuccess = AppPrimitives.emerald700;

  static const Color feedbackWarning = AppPrimitives.amber500;
  static const Color feedbackWarningSubtle = AppPrimitives.amber50;
  static const Color onFeedbackWarning = AppPrimitives.amber700;

  static const Color feedbackError = AppPrimitives.red500;
  static const Color feedbackErrorSubtle = AppPrimitives.red50;
  static const Color onFeedbackError = AppPrimitives.red700;

  /// Fundos SOLIDOS que carregam texto/icone branco (ex.: snackbars).
  /// Os tons 500 acima nao atingem AA com branco (2.5:1 e 3.8:1); estes 700
  /// sim (5.5:1 e 6.5:1). Ainda assim sempre acompanhados de icone + texto.
  static const Color feedbackSuccessSolid = AppPrimitives.emerald700;
  static const Color feedbackErrorSolid = AppPrimitives.red700;
  static const Color onFeedbackSolid = AppPrimitives.white;

  // ── Foco (acessibilidade: anel de foco sempre visivel) ─────────────────
  static const Color focusRing = AppPrimitives.blue600;

  // ── Modulos ────────────────────────────────────────────────────────────
  static const Color moduleAi = AppPrimitives.violet500;
  static const Color moduleAiSubtle = AppPrimitives.violet50;

  /// Fundo lilas de destaques de IA (ex.: banner dos agentes).
  static const Color moduleAiSoft = AppPrimitives.violet100;
  static const Color onModuleAi = AppPrimitives.violet700;

  static const Color moduleCleaning = AppPrimitives.cyan500;
  static const Color moduleCleaningSubtle = AppPrimitives.cyan50;
  static const Color onModuleCleaning = AppPrimitives.cyan700;

  // ── Decorativo ─────────────────────────────────────────────────────────
  /// Blobs/curvas de fundo dos protocolos visuais. Puramente ornamental.
  static const Color backdropBlob = Color(0x14BFDBFE);
  static const Color backdropBlobSoft = Color(0x0D93C5FD);
}

/// Identidade visual de cada agente.
///
/// Luna, Otto e Tina compartilham a MESMA estrutura de interface; a
/// diferenciacao acontece por avatar, nome, cor contextual e conteudo.
enum AppAgent {
  luna(
    name: 'Luna',
    role: 'Financeiro',
    assetPath: 'assets/images/luna.png',
    accent: AppPrimitives.blue600,
    surface: AppPrimitives.blue50,
    onSurface: AppPrimitives.blue700,
  ),
  otto(
    name: 'Otto',
    role: 'Cozinha',
    assetPath: 'assets/images/otto.png',
    accent: AppPrimitives.amber500,
    surface: AppPrimitives.amber50,
    onSurface: AppPrimitives.amber700,
  ),
  tina(
    name: 'Tina',
    role: 'Doméstica',
    assetPath: 'assets/images/tina.png',
    accent: AppPrimitives.emerald500,
    surface: AppPrimitives.emerald50,
    onSurface: AppPrimitives.emerald700,
  );

  const AppAgent({
    required this.name,
    required this.role,
    required this.assetPath,
    required this.accent,
    required this.surface,
    required this.onSurface,
  });

  final String name;
  final String role;
  final String assetPath;

  /// Cor de identidade do agente. Use para icones e detalhes, nunca como
  /// unico portador de significado.
  final Color accent;

  /// Fundo tonal suave do card do agente.
  final Color surface;

  /// Cor de texto legivel sobre [surface] (contraste AA).
  final Color onSurface;
}

/// Par de cores de um modulo/atalho: fundo tonal + cor do icone.
///
/// Serve para atalhos e cards que mudam de cor por significado (financas,
/// diario, casa...) sem cada tela escolher hex. O icone usa o tom 600, que
/// fica >= 3:1 sobre o fundo 100; o significado nunca depende so da cor,
/// porque todo atalho tem titulo em texto.
enum AppTone {
  blue(
    surface: AppPrimitives.blue100,
    foreground: AppPrimitives.blue600,
  ),
  violet(
    surface: AppPrimitives.violet100,
    foreground: AppPrimitives.violet600,
  ),
  green(
    surface: AppPrimitives.emerald100,
    foreground: AppPrimitives.emerald600,
  ),
  cyan(
    surface: AppPrimitives.cyan100,
    foreground: AppPrimitives.cyan600,
  ),
  red(
    surface: AppPrimitives.red100,
    foreground: AppPrimitives.red600,
  );

  const AppTone({required this.surface, required this.foreground});

  final Color surface;
  final Color foreground;
}
