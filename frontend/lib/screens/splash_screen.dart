import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../theme/tokens/app_colors_semantic.dart';
import '../widgets/agents/agent_card.dart';
import '../widgets/brand/app_logo.dart';
import '../widgets/common/app_primary_button.dart';
import '../widgets/common/app_screen_scaffold.dart';
import '../widgets/common/brand_note.dart';

/// Tela publica / entrada do aplicativo (rota `/`).
///
/// Apesar do nome do arquivo, esta nao e uma tela de carregamento: e a
/// vitrine publica do produto. O nome da classe e a rota foram preservados
/// para nao alterar a navegacao existente.
///
/// Destinos preservados: "Entrar" -> `/login`, "Criar conta gratis" ->
/// `/signup`, ambos via `pushReplacementNamed`, como antes.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    )..forward();

    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return AppScreenScaffold(
      child: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Align(
                alignment: Alignment.centerRight,
                child: BrandNote(
                  text: 'Mais liberdade para o seu dia',
                  textAlign: TextAlign.right,
                  rotation: -0.07,
                  maxWidth: 132,
                ),
              ),
              const SizedBox(height: 12),
              const Center(child: AppLogo(markHeight: 50)),
              const SizedBox(height: AppSpacing.defaultGap),
              _buildHeadline(),
              const SizedBox(height: 10),
              _buildSubtitle(),
              const SizedBox(height: AppSpacing.defaultGap),
              _buildAgents(),
              const SizedBox(height: AppSpacing.defaultGap),
              _buildActions(context),
              const SizedBox(height: AppSpacing.defaultGap),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeadline() {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: 'Domine sua\n',
            style: AppTypography.displayLarge.copyWith(
              color: AppSemanticColors.textPrimary,
            ),
          ),
          TextSpan(
            text: 'independência',
            style: AppTypography.displayLarge.copyWith(
              color: AppSemanticColors.actionPrimary,
            ),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildSubtitle() {
    return Text(
      'Seu hub de assistentes inteligentes para viver melhor, '
      'gerenciar finanças e cuidar da casa.',
      textAlign: TextAlign.center,
      style: AppTypography.bodyMedium.copyWith(
        color: AppSemanticColors.textSecondary,
      ),
    );
  }

  Widget _buildAgents() {
    // Os tres agentes permanecem lado a lado na viewport de referencia
    // (390 x 844). `Expanded` garante que nunca haja overflow horizontal:
    // o que cede e o tamanho interno de cada card, nunca a linha.
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: AgentCard(
              agent: AppAgent.luna,
              description: 'Organize suas contas e realize seus planos.',
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: AgentCard(
              agent: AppAgent.otto,
              description: 'Receitas práticas para uma vida mais saudável.',
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: AgentCard(
              agent: AppAgent.tina,
              description: 'Cuide da sua casa com mais leveza e organização.',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppPrimaryButton(
          label: 'Entrar',
          trailingIcon: Icons.arrow_forward_rounded,
          onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () => Navigator.pushReplacementNamed(context, '/signup'),
          child: const Text('Criar conta grátis'),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Expanded(child: Divider(indent: 24, endIndent: 12)),
            ExcludeSemantics(
              child: Icon(
                Icons.favorite_rounded,
                size: AppSizes.iconSm,
                color: AppSemanticColors.actionPrimary,
              ),
            ),
            const Expanded(child: Divider(indent: 12, endIndent: 24)),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          'Uma vida mais simples começa aqui.',
          textAlign: TextAlign.center,
          style: AppTypography.bodySmall.copyWith(
            color: AppSemanticColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
