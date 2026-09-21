import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../config/routes.dart';
import '../providers/auth_provider.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../theme/tokens/app_colors_semantic.dart';
import '../theme/tokens/app_primitives.dart';
import '../widgets/brand/app_logo.dart';
import '../widgets/common/app_screen_scaffold.dart';
import '../widgets/common/cropped_asset_image.dart';
import '../widgets/common/speech_bubble.dart';
import '../widgets/dialogs/logout_dialog.dart';
import '../widgets/dialogs/under_construction_dialog.dart';
import '../widgets/home/agents_banner.dart';
import '../widgets/home/quick_action_card.dart';
import '../widgets/navigation/agent_bottom_nav.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late List<Animation<double>> _cardFades;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    // Stagger de fade para os cards (6 cards)
    _cardFades = List.generate(6, (i) {
      final start = i * 0.12;
      final end = (start + 0.5).clamp(0.0, 1.0);
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _ctrl,
          curve: Interval(start, end, curve: Curves.easeOut),
        ),
      );
    });

    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  String _getFirstName(String? fullName) {
    if (fullName == null || fullName.trim().isEmpty) return '';
    return fullName.trim().split(' ').first;
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
      contentAlignment: Alignment.topCenter,
      bottomNavigationBar: const AgentBottomNav(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(context),
          const SizedBox(height: AppSpacing.blockGap),
          _buildHero(),
          const SizedBox(height: AppSpacing.sectionGap),
          Semantics(
            header: true,
            child: Text(
              'Acesso rápido',
              style: AppTypography.headlineSmall.copyWith(
                color: AppSemanticColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.itemGap),
          _buildQuickActions(context),
          const SizedBox(height: AppSpacing.defaultGap),
          const AgentsBanner(),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        const AppLogo(variant: AppLogoVariant.wordmark, wordmarkFontSize: 26),
        const Spacer(),
        DecoratedBox(
          decoration: const BoxDecoration(
            color: AppSemanticColors.surface,
            shape: BoxShape.circle,
            boxShadow: AppPrimitives.shadowSm,
          ),
          child: IconButton(
            onPressed: () => LogoutDialog.show(
              context,
              onConfirm: () async {
                await context.read<AuthProvider>().logout();
                if (!context.mounted) return;
                Navigator.pushReplacementNamed(context, '/');
              },
            ),
            icon: const Icon(
              Icons.logout_rounded,
              size: AppSizes.iconLg,
              color: AppSemanticColors.actionPrimary,
            ),
            tooltip: 'Sair',
            constraints: const BoxConstraints.tightFor(
              width: AppSpacing.minTouchTarget,
              height: AppSpacing.minTouchTarget,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHero() {
    return Consumer<AuthProvider>(
      builder: (_, auth, __) {
        final firstName = _getFirstName(auth.user?.fullName);
        return _HomeHero(
          greeting: firstName.isEmpty ? 'Olá!' : 'Olá, $firstName!',
        );
      },
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final cards = [
      _CardData(
        icon: Icons.calendar_today_outlined,
        title: 'Calendário',
        description: 'Veja e organize seus compromissos',
        tone: AppTone.blue,
        onTap: () => Navigator.pushNamed(context, AppRoutes.calendar),
      ),
      _CardData(
        icon: Icons.menu_book_outlined,
        title: 'Meu Diário',
        description: 'Registre seus pensamentos e humor',
        tone: AppTone.violet,
        onTap: () => Navigator.pushNamed(context, AppRoutes.diary),
      ),
      _CardData(
        icon: Icons.account_balance_wallet_outlined,
        title: 'Finanças',
        description: 'Contas, receitas e despesas',
        tone: AppTone.blue,
        onTap: () => Navigator.pushNamed(context, AppRoutes.accounts),
      ),
      _CardData(
        icon: Icons.receipt_long_outlined,
        title: 'Dashboard / Fatura',
        description: 'Parcelas e gastos fixos mensais',
        tone: AppTone.blue,
        onTap: () => Navigator.pushNamed(context, AppRoutes.invoiceDashboard),
      ),
      _CardData(
        icon: Icons.home_outlined,
        title: 'Área Doméstica',
        description: 'Gerenciar sua casa e tarefas',
        tone: AppTone.green,
        onTap: () => UnderConstructionDialog.show(
          context,
          agentName: 'Área Doméstica',
          agentRole: 'Gerenciar sua casa e tarefas',
          imagePath: AppAgent.tina.assetPath,
          agentColor: AppTone.green.foreground,
        ),
      ),
      _CardData(
        icon: Icons.handyman_outlined,
        title: 'Serviços Externos',
        description: 'Encontre prestadores de serviços',
        tone: AppTone.cyan,
        onTap: () => UnderConstructionDialog.show(
          context,
          agentName: 'Serviços Externos',
          agentRole: 'Encontre prestadores de serviços',
          imagePath: 'assets/images/brand/logo_mark.png',
          agentColor: AppTone.cyan.foreground,
        ),
      ),
    ];

    Widget cell(int i) => FadeTransition(
          opacity: _cardFades[i],
          child: QuickActionCard(
            icon: cards[i].icon,
            title: cards[i].title,
            description: cards[i].description,
            tone: cards[i].tone,
            onTap: cards[i].onTap,
          ),
        );

    // Duas colunas. IntrinsicHeight iguala a altura dos dois cards da linha
    // (os titulos podem quebrar em duas linhas).
    return Column(
      children: [
        for (var i = 0; i < cards.length; i += 2) ...[
          if (i > 0) const SizedBox(height: AppSpacing.itemGap),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: cell(i)),
                const SizedBox(width: AppSpacing.itemGap),
                Expanded(
                  child: i + 1 < cards.length
                      ? cell(i + 1)
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _CardData {
  final IconData icon;
  final String title;
  final String description;
  final AppTone tone;
  final VoidCallback onTap;

  const _CardData({
    required this.icon,
    required this.title,
    required this.description,
    required this.tone,
    required this.onTap,
  });
}

/// Saudacao e titulo a esquerda; Luna e um balao de marca a direita.
/// A ilustracao e ornamental.
class _HomeHero extends StatelessWidget {
  const _HomeHero({required this.greeting});

  final String greeting;

  static const double _artHeight = 196;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 10,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: AppTypography.bodyLarge.copyWith(
                  color: AppSemanticColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Semantics(
                header: true,
                child: Text(
                  'No que posso\nte ajudar hoje?',
                  style: AppTypography.headlineLarge.copyWith(
                    color: AppSemanticColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.labelGap),
              Text(
                'Organize sua rotina, cuide da sua casa e tenha mais controle '
                'da sua vida.',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppSemanticColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.labelGap),
        Expanded(
          flex: 9,
          child: SizedBox(
            height: _artHeight,
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.bottomRight,
                  child: SizedBox(
                    height: 108,
                    child: const CroppedAssetImage(
                      // Luna. PNG com transparencia. Caixa util medida no arquivo:
                      // x 0,051-0,804 e y 0,074-0,958 (margem de ~3% em volta).
                      asset: 'assets/images/luna.png',
                      assetSize: Size(2048, 2048),
                      widthFactor: 0.78,
                      heightFactor: 0.91,
                      anchor: Alignment(-0.66, 0.36),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 120),
                    child: const SpeechBubble(
                      text: 'Pequenas decisões hoje, uma vida melhor amanhã.',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
