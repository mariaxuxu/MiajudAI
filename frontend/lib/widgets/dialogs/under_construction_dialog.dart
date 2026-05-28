import 'package:flutter/material.dart';
import '../../config/constants.dart';
import '../common/custom_button.dart';

class UnderConstructionDialog extends StatelessWidget {
  final String agentName;
  final String agentRole;
  final String imagePath;
  final Color agentColor;

  const UnderConstructionDialog({
    super.key,
    required this.agentName,
    required this.agentRole,
    required this.imagePath,
    required this.agentColor,
  });

  static Future<void> show(
    BuildContext context, {
    required String agentName,
    required String agentRole,
    required String imagePath,
    required Color agentColor,
  }) {
    return showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (_) => UnderConstructionDialog(
        agentName: agentName,
        agentRole: agentRole,
        imagePath: imagePath,
        agentColor: agentColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusXLarge),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Logo do agente
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: agentColor.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(AppDimens.radiusCard),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Image.asset(imagePath, fit: BoxFit.contain),
              ),
            ),
            const SizedBox(height: 20),

            // Badge "em construção"
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppDimens.radiusFull),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.construction_outlined,
                      size: 13, color: AppColors.warning),
                  const SizedBox(width: 5),
                  const Text(
                    'Em construção',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.warning,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Text(
              agentName,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              agentRole,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textLabel,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Estamos construindo algo incrível!\nEm breve este agente estará disponível para te ajudar.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textLabel,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 28),

            CustomButton(
              text: 'Entendido',
              variant: ButtonVariant.secondary,
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
