import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/tokens/app_colors_semantic.dart';
import '../../theme/tokens/app_primitives.dart';

/// Navegacao inferior da area autenticada: Inicio e os tres agentes.
///
/// Flutuante, em pilula. Os destinos sao os de sempre: Inicio nao navega,
/// Luna abre `/chat`, Otto e Tina abrem o aviso de "em construcao".
class AgentBottomNav extends StatefulWidget {
  final VoidCallback? onHomeTap;

  const AgentBottomNav({super.key, this.onHomeTap});

  @override
  State<AgentBottomNav> createState() => _AgentBottomNavState();
}

class _AgentBottomNavState extends State<AgentBottomNav> {
  int _selected = 0;

  void _onHomeSelected() {
    setState(() => _selected = 0);
    HapticFeedback.selectionClick();
    widget.onHomeTap?.call();
  }

  void _onLunaSelected(BuildContext context) {
    setState(() => _selected = 1);
    HapticFeedback.selectionClick();
    Navigator.pushNamed(context, '/chat').then((_) {
      if (mounted) setState(() => _selected = 0);
    });
  }

  void _onOttoSelected(BuildContext context) {
    setState(() => _selected = 2);
    HapticFeedback.selectionClick();
    Navigator.pushNamed(context, '/chat/otto').then((_) {
      if (mounted) setState(() => _selected = 0);
    });
  }

  void _onTinaSelected(BuildContext context) {
    setState(() => _selected = 3);
    HapticFeedback.selectionClick();
    Navigator.pushNamed(context, '/chat/tina').then((_) {
      if (mounted) setState(() => _selected = 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.defaultGap,
          AppSpacing.labelGap,
          AppSpacing.defaultGap,
          AppSpacing.defaultGap,
        ),
        child: Container(
          height: 72,
          decoration: BoxDecoration(
            color: AppSemanticColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.full),
            boxShadow: AppPrimitives.shadowMd,
          ),
          child: Row(
            children: [
              _NavItem(
                label: 'Início',
                isSelected: _selected == 0,
                onTap: _onHomeSelected,
                icon: Icons.home_outlined,
                selectedIcon: Icons.home_rounded,
              ),
              _NavItem(
                label: 'Luna',
                isSelected: _selected == 1,
                onTap: () => _onLunaSelected(context),
                agent: AppAgent.luna,
              ),
              _NavItem(
                label: 'Otto',
                isSelected: _selected == 2,
                onTap: () => _onOttoSelected(context),
                agent: AppAgent.otto,
              ),
              _NavItem(
                label: 'Tina',
                isSelected: _selected == 3,
                onTap: () => _onTinaSelected(context),
                agent: AppAgent.tina,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Um item da navegacao: icone (Inicio) ou avatar (agente) + rotulo.
///
/// O estado selecionado nao depende so de cor: muda a forma (circulo azul
/// cheio / anel) e o peso do rotulo, e e anunciado por semantica.
class _NavItem extends StatefulWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  /// Inicio: icone normal e preenchido quando selecionado.
  final IconData? icon;
  final IconData? selectedIcon;

  /// Agente: avatar do agente.
  final AppAgent? agent;

  const _NavItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.icon,
    this.selectedIcon,
    this.agent,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
      lowerBound: 0.88,
      upperBound: 1.0,
    );
    _ctrl.value = 1.0;
    _scaleAnim = _ctrl.drive(CurveTween(curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Semantics(
        button: true,
        selected: widget.isSelected,
        label: widget.label,
        onTap: widget.onTap,
        excludeSemantics: true,
        child: GestureDetector(
          onTapDown: (_) => _ctrl.reverse(),
          onTapUp: (_) {
            _ctrl.forward();
            widget.onTap();
          },
          onTapCancel: () => _ctrl.forward(),
          behavior: HitTestBehavior.opaque,
          child: AnimatedBuilder(
            animation: _scaleAnim,
            builder: (_, child) =>
                Transform.scale(scale: _scaleAnim.value, child: child),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLeading(),
                const SizedBox(height: 4),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: AppTypography.labelSmall.copyWith(
                    fontWeight:
                        widget.isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: widget.isSelected
                        ? AppSemanticColors.actionPrimary
                        : AppSemanticColors.textSecondary,
                  ),
                  child: Text(widget.label),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeading() {
    final agent = widget.agent;
    if (agent == null) return _buildHomeIcon();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      width: 40,
      height: 40,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: agent.surface,
        shape: BoxShape.circle,
        border: widget.isSelected
            ? Border.all(color: AppSemanticColors.actionPrimary, width: 2)
            : null,
      ),
      child: Image.asset(
        agent.assetPath,
        fit: BoxFit.contain,
        excludeFromSemantics: true,
      ),
    );
  }

  Widget _buildHomeIcon() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: widget.isSelected
            ? AppSemanticColors.actionPrimary
            : Colors.transparent,
        shape: BoxShape.circle,
      ),
      child: Icon(
        widget.isSelected ? widget.selectedIcon : widget.icon,
        size: AppSizes.iconLg,
        color: widget.isSelected
            ? AppSemanticColors.onAction
            : AppSemanticColors.textSecondary,
      ),
    );
  }

}
