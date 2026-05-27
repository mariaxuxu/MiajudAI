import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/constants.dart';
import '../dialogs/under_construction_dialog.dart';

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
    HapticFeedback.selectionClick();
    UnderConstructionDialog.show(
      context,
      agentName: 'Otto',
      agentRole: 'Assistente de Cozinha',
      imagePath: 'assets/images/otto.png',
      agentColor: AppColors.accent,
    );
  }

  void _onTinaSelected(BuildContext context) {
    HapticFeedback.selectionClick();
    UnderConstructionDialog.show(
      context,
      agentName: 'Tina',
      agentRole: 'Assistente Doméstica',
      imagePath: 'assets/images/tina.png',
      agentColor: AppColors.tina,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 72,
          child: Row(
            children: [
              _NavHomeItem(
                isSelected: _selected == 0,
                onTap: _onHomeSelected,
              ),
              _NavAgentItem(
                imagePath: 'assets/images/luna.png',
                label: 'Luna',
                bgColor: AppColors.primarySurface,
                isSelected: _selected == 1,
                onTap: () => _onLunaSelected(context),
              ),
              _NavAgentItem(
                imagePath: 'assets/images/otto.png',
                label: 'Otto',
                bgColor: AppColors.accentSurface,
                isSelected: false,
                showBadge: true,
                onTap: () => _onOttoSelected(context),
              ),
              _NavAgentItem(
                imagePath: 'assets/images/tina.png',
                label: 'Tina',
                bgColor: const Color(0xFFEAF7EF),
                isSelected: false,
                showBadge: true,
                onTap: () => _onTinaSelected(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavHomeItem extends StatefulWidget {
  final bool isSelected;
  final VoidCallback onTap;

  const _NavHomeItem({required this.isSelected, required this.onTap});

  @override
  State<_NavHomeItem> createState() => _NavHomeItemState();
}

class _NavHomeItemState extends State<_NavHomeItem>
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
          builder: (_, child) => Transform.scale(scale: _scaleAnim.value, child: child),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: widget.isSelected
                      ? AppColors.primary.withValues(alpha: 0.10)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
                ),
                child: Icon(
                  widget.isSelected ? Icons.home_rounded : Icons.home_outlined,
                  color: widget.isSelected
                      ? AppColors.primary
                      : AppColors.textLabel,
                  size: 24,
                ),
              ),
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: widget.isSelected ? FontWeight.w700 : FontWeight.w400,
                  color: widget.isSelected ? AppColors.primary : AppColors.textLabel,
                ),
                child: const Text('Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavAgentItem extends StatefulWidget {
  final String imagePath;
  final String label;
  final Color bgColor;
  final bool isSelected;
  final bool showBadge;
  final VoidCallback onTap;

  const _NavAgentItem({
    required this.imagePath,
    required this.label,
    required this.bgColor,
    required this.isSelected,
    required this.onTap,
    this.showBadge = false,
  });

  @override
  State<_NavAgentItem> createState() => _NavAgentItemState();
}

class _NavAgentItemState extends State<_NavAgentItem>
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
          builder: (_, child) => Transform.scale(scale: _scaleAnim.value, child: child),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutCubic,
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: widget.isSelected
                          ? widget.bgColor
                          : widget.bgColor.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
                      border: widget.isSelected
                          ? Border.all(
                              color: AppColors.primary.withValues(alpha: 0.25),
                              width: 1.5,
                            )
                          : null,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Image.asset(
                        widget.imagePath,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  if (widget.showBadge)
                    Positioned(
                      top: -4,
                      right: -4,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: AppColors.warning,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        child: const Center(
                          child: Text(
                            '!',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              height: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: widget.isSelected ? FontWeight.w700 : FontWeight.w400,
                  color: widget.isSelected ? AppColors.primary : AppColors.textLabel,
                ),
                child: Text(widget.label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
