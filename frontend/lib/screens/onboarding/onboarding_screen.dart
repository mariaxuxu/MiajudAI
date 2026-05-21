import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/onboarding_provider.dart';
import '../../config/constants.dart';
import 'steps/basic_info_step.dart';
import 'steps/security_step.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<OnboardingProvider>(
        builder: (context, onboardingProvider, _) {
          return SafeArea(
            child: Column(
              children: [
                // Progress Indicator
                Padding(
                  padding: const EdgeInsets.all(AppDimens.paddingMedium),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Etapa ${onboardingProvider.currentStep + 1} de 2',
                            style: AppTextStyles.titleSmall.copyWith(
                              color: const Color(0xFF1B4965),
                            ),
                          ),
                          Text(
                            onboardingProvider.currentStep == 0
                                ? 'Dados Básicos'
                                : 'Segurança & Preferências',
                            style: AppTextStyles.titleSmall.copyWith(
                              color: const Color(0xFF1B4965),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimens.paddingSmall),
                      ClipRRect(
                        borderRadius:
                            BorderRadius.circular(AppDimens.radiusSmall),
                        child: LinearProgressIndicator(
                          value: (onboardingProvider.currentStep + 1) / 2,
                          minHeight: 6,
                          backgroundColor: Colors.grey[300],
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFFFF8C00),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Error Message
                if (onboardingProvider.error != null)
                  Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: AppDimens.paddingMedium,
                      vertical: AppDimens.paddingSmall,
                    ),
                    padding: const EdgeInsets.all(AppDimens.paddingSmall),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius:
                          BorderRadius.circular(AppDimens.radiusDefault),
                      border: Border.all(color: AppColors.error),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline,
                            color: Color(0xFFF44336), size: 20),
                        const SizedBox(width: AppDimens.paddingSmall),
                        Expanded(
                          child: Text(
                            onboardingProvider.error!,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: const Color(0xFFF44336),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                // Page View
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      BasicInfoStep(),
                      SecurityStep(),
                    ],
                  ),
                ),
                // Buttons
                Padding(
                  padding: const EdgeInsets.all(AppDimens.paddingMedium),
                  child: Row(
                    children: [
                      if (onboardingProvider.currentStep > 0)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              onboardingProvider.previousStep();
                              _pageController.previousPage(
                                duration:
                                    const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                vertical: AppDimens.paddingDefault,
                              ),
                              side: const BorderSide(
                                color: Color(0xFF1B4965),
                              ),
                            ),
                            child: const Text('Voltar'),
                          ),
                        ),
                      if (onboardingProvider.currentStep > 0)
                        const SizedBox(width: AppDimens.paddingMedium),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: onboardingProvider.isLoading
                              ? null
                              : () {
                                  if (onboardingProvider.currentStep == 0) {
                                    onboardingProvider.nextStep();
                                    _pageController.nextPage(
                                      duration:
                                          const Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                    );
                                  } else {
                                    _handleSubmit(context);
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF8C00),
                            padding: const EdgeInsets.symmetric(
                              vertical: AppDimens.paddingDefault,
                            ),
                          ),
                          child: onboardingProvider.isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : Text(
                                  onboardingProvider.currentStep == 0
                                      ? 'Próximo'
                                      : 'Concluir',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _handleSubmit(BuildContext context) {
    final onboardingProvider =
        Provider.of<OnboardingProvider>(context, listen: false);

    onboardingProvider.getOnboardingData();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Onboarding concluído com sucesso!')),
    );

    onboardingProvider.reset();

    Navigator.of(context).pushReplacementNamed('/home');
  }
}
