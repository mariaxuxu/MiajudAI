import 'package:flutter/material.dart';
import '../config/constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.of(context).size.height -
                MediaQuery.of(context).padding.top,
            child: FadeTransition(
              opacity: Tween<double>(begin: 0, end: 1).animate(
                CurvedAnimation(
                  parent: _animationController,
                  curve: Curves.easeOut,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top section with gradient background
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF1B4965).withValues(alpha: 0.05),
                          const Color(0xFFFF8C00).withValues(alpha: 0.05),
                        ],
                      ),
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 40),
                        // Logo Animation
                        ScaleTransition(
                          scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                            CurvedAnimation(
                              parent: _animationController,
                              curve: Curves.elasticOut,
                            ),
                          ),
                          child: Image.asset(
                            'assets/images/miajudai_logo_transparent.png',
                            height: 180,
                            width: 180,
                          ),
                        ),
                        const SizedBox(height: 60),
                      ],
                    ),
                  ),
                  // Middle section with content
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimens.paddingMedium,
                    ),
                    child: Column(
                      children: [
                        SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.3),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: _animationController,
                              curve: const Interval(0.2, 1.0,
                                  curve: Curves.easeOut),
                            ),
                          ),
                          child: Column(
                            children: [
                              RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'Domine ',
                                      style: AppTextStyles.displaySmall
                                          .copyWith(
                                        color: const Color(0xFF1B4965),
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'sua independência',
                                      style: AppTextStyles.displaySmall
                                          .copyWith(
                                        color: const Color(0xFFFF8C00),
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'Seu assistente inteligente para viver melhor, gerenciar finanças e conectar com a comunidade',
                                textAlign: TextAlign.center,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textSecondary,
                                  height: 1.6,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 60),
                        // Feature highlights
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildFeatureItem(
                              icon: Icons.attach_money_outlined,
                              label: 'Finanças',
                            ),
                            _buildFeatureItem(
                              icon: Icons.build_circle_outlined,
                              label: 'Serviços',
                            ),
                            _buildFeatureItem(
                              icon: Icons.people_outline,
                              label: 'Comunidade',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Bottom buttons
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(
                          horizontal: AppDimens.paddingMedium,
                        ),
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.5),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: _animationController,
                          curve: const Interval(0.4, 1.0,
                              curve: Curves.easeOut),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Entrar Button
                          MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFFF8C00),
                                    Color(0xFFFF9E1B),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(
                                  AppDimens.radiusDefault,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFFF8C00)
                                        .withValues(alpha: 0.3),
                                    blurRadius: 16,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    Navigator.pushReplacementNamed(
                                      context,
                                      '/login',
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(
                                    AppDimens.radiusDefault,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical:
                                          AppDimens.paddingDefault,
                                    ),
                                    child: Text(
                                      'Entrar',
                                      textAlign: TextAlign.center,
                                      style: AppTextStyles.titleSmall.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          // Cadastre-se Button
                          MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  color: const Color(0xFF1B4965),
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(
                                  AppDimens.radiusDefault,
                                ),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    Navigator.pushReplacementNamed(
                                      context,
                                      '/signup',
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(
                                    AppDimens.radiusDefault,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical:
                                          AppDimens.paddingDefault,
                                    ),
                                    child: Text(
                                      'Cadastre-se',
                                      textAlign: TextAlign.center,
                                      style: AppTextStyles.titleSmall.copyWith(
                                        color: const Color(0xFF1B4965),
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String label,
  }) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: const Color(0xFF1B4965).withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF1B4965),
            size: 28,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: const Color(0xFF1B4965),
          ),
        ),
      ],
    );
  }
}
