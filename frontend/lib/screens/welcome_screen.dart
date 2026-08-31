import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../config/constants.dart';
import '../config/routes.dart';
import '../providers/auth_provider.dart';
import '../widgets/dialogs/logout_dialog.dart';
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

    _cardFades = List.generate(5, (i) {
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
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.accentSurface,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: _buildBody(context),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AgentBottomNav(),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.fromLTRB(8, 12, 12, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SizedBox.shrink(),
              const Expanded(
                child: Text(
                  'MiAjudAI',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => LogoutDialog.show(
                  context,
                  onConfirm: () async {
                    await context.read<AuthProvider>().logout();
                    if (!context.mounted) return;
                    Navigator.pushReplacementNamed(context, '/');
                  },
                ),
                icon: const Icon(Icons.logout_rounded,
                    color: AppColors.textLabel, size: 22),
                tooltip: 'Sair',
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
            child: Consumer<AuthProvider>(
              builder: (_, auth, __) {
                final firstName = _getFirstName(auth.user?.fullName);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Olá',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'No que posso te ajudar hoje?',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textLabel,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final cards = [
      _CardData(
        icon: Icons.calendar_today_outlined,
        title: 'Calendário',
        description: 'Veja e organize seus compromissos',
        color: AppColors.accent,
        onTap: () => Navigator.pushNamed(context, AppRoutes.calendar),
      ),
      _CardData(
        icon: Icons.account_balance_wallet_outlined,
        title: 'Finanças',
        description: 'Contas, receitas e despesas',
        color: AppColors.primary,
        onTap: () => Navigator.pushNamed(context, AppRoutes.accounts),
      ),
      _CardData(
        icon: Icons.receipt_long_outlined,
        title: 'Dashboard / Fatura',
        description: 'Parcelas e gastos fixos mensais',
        color: AppColors.primary,
        onTap: () => Navigator.pushNamed(context, AppRoutes.invoiceDashboard),
      ),
      _CardData(
        icon: Icons.home_repair_service_outlined,
        title: 'Área Doméstica',
        description: 'Gerenciar sua casa e tarefas',
        color: AppColors.tina,
        onTap: () {},
      ),
      _CardData(
        icon: Icons.handyman_outlined,
        title: 'Serviços Externos',
        description: 'Encontre prestadores de serviços',
        color: const Color(0xFF0891B2),
        onTap: () {},
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const Text(
          'Acesso rápido',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 14),
        ...cards.asMap().entries.map((entry) {
          final i = entry.key;
          final card = entry.value;
          return FadeTransition(
            opacity: _cardFades[i],
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _FeatureCard(data: card),
            ),
          );
        }),
        const SizedBox(height: 8),
        _buildAgentBanner(context),
      ],
    );
  }

  Widget _buildAgentBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFF2E6B8A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Seus agentes de IA',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Use o menu abaixo para conversar com Luna, Otto ou Tina.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Imagem conjunta dos 3 agentes
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
            child: Image.asset(
              'assets/images/todos_agents.jpg',
              width: 100,
              height: 76,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }

}

class _CardData {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap;

  const _CardData({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.onTap,
  });
}

class _FeatureCard extends StatefulWidget {
  final _CardData data;
  const _FeatureCard({required this.data});

  @override
  State<_FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<_FeatureCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.data.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: _pressed ? const Color(0xFFF8F9FA) : Colors.white,
            borderRadius: BorderRadius.circular(AppDimens.radiusLarge),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: _pressed ? 0.04 : 0.07),
                blurRadius: _pressed ? 8 : 16,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: widget.data.color.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
                ),
                child: Icon(widget.data.icon, color: widget.data.color, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.data.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                        letterSpacing: -0.1,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      widget.data.description,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textLabel,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: widget.data.color.withValues(alpha: 0.7),
                size: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
