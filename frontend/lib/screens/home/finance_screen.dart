import 'package:flutter/material.dart';
import '../../config/constants.dart';

class FinanceScreen extends StatelessWidget {
  const FinanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.attach_money_outlined,
                size: 80,
                color: const Color(0xFFFF8C00),
              ),
              const SizedBox(height: 16),
              Text(
                'Gestão Financeira',
                style: AppTextStyles.displaySmall.copyWith(
                  color: const Color(0xFF1B4965),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Em breve',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
