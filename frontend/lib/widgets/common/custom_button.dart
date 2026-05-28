import 'package:flutter/material.dart';
import '../../config/constants.dart';

enum ButtonVariant { primary, outlined, secondary }

class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final ButtonVariant variant;
  final double? width;
  final double? height;
  final Widget? icon;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.variant = ButtonVariant.primary,
    this.width,
    this.height,
    this.icon,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleCtrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.97,
      upperBound: 1.0,
    );
    _scaleAnim = _scaleCtrl.drive(CurveTween(curve: Curves.easeOut));
    _scaleCtrl.value = 1.0;
  }

  @override
  void dispose() {
    _scaleCtrl.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    if (widget.onPressed != null && !widget.isLoading) {
      _scaleCtrl.reverse();
    }
  }

  void _onTapUp(TapUpDetails _) => _scaleCtrl.forward();
  void _onTapCancel() => _scaleCtrl.forward();

  @override
  Widget build(BuildContext context) {
    final bool disabled = widget.onPressed == null || widget.isLoading;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnim.value,
          child: child,
        ),
        child: SizedBox(
          width: widget.width ?? double.infinity,
          height: widget.height ?? AppDimens.buttonHeightDefault,
          child: _buildButton(disabled),
        ),
      ),
    );
  }

  Widget _buildButton(bool disabled) {
    switch (widget.variant) {
      case ButtonVariant.primary:
        return _buildPrimary(disabled);
      case ButtonVariant.outlined:
        return _buildOutlined(disabled);
      case ButtonVariant.secondary:
        return _buildSecondary(disabled);
    }
  }

  Widget _buildPrimary(bool disabled) {
    return GestureDetector(
      onTap: disabled ? null : widget.onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          gradient: disabled
              ? null
              : const LinearGradient(
                  colors: [AppColors.accent, AppColors.accentDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          color: disabled ? const Color(0xFFD1D5DB) : null,
          borderRadius: BorderRadius.circular(AppDimens.radiusButton),
          boxShadow: disabled
              ? null
              : [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.30),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: Center(child: _buildChild(Colors.white, disabled)),
      ),
    );
  }

  Widget _buildOutlined(bool disabled) {
    return OutlinedButton(
      onPressed: disabled ? null : widget.onPressed,
      style: OutlinedButton.styleFrom(
        side: BorderSide(
          color: disabled ? AppColors.inputBorder : AppColors.primary,
          width: 1.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusButton),
        ),
        backgroundColor: Colors.transparent,
        padding: EdgeInsets.zero,
      ),
      child: _buildChild(
        disabled ? AppColors.textLabel : AppColors.primary,
        disabled,
      ),
    );
  }

  Widget _buildSecondary(bool disabled) {
    return ElevatedButton(
      onPressed: disabled ? null : widget.onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: disabled ? const Color(0xFFD1D5DB) : AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusButton),
        ),
        padding: EdgeInsets.zero,
      ),
      child: _buildChild(Colors.white, disabled),
    );
  }

  Widget _buildChild(Color textColor, bool disabled) {
    if (widget.isLoading) {
      return SizedBox(
        height: 22,
        width: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(
            widget.variant == ButtonVariant.outlined
                ? AppColors.primary
                : Colors.white,
          ),
        ),
      );
    }

    if (widget.icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          widget.icon!,
          const SizedBox(width: 8),
          Text(
            widget.text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: textColor,
              letterSpacing: 0.2,
            ),
          ),
        ],
      );
    }

    return Text(
      widget.text,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textColor,
        letterSpacing: 0.2,
      ),
    );
  }
}
