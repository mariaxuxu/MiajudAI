import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/constants.dart';
import '../widgets/common/custom_button.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  late Animation<double> _scaleLogoAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();

    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0, 0.6, curve: Curves.easeOut)),
    );
    _scaleLogoAnim = Tween<double>(begin: 0.75, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0, 0.55, curve: Curves.easeOutBack)),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.25, 1.0, curve: Curves.easeOutCubic)),
    );
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
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.accentSurface,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 52),
                      _buildLogo(),
                      const SizedBox(height: 36),
                      SlideTransition(
                        position: _slideAnim,
                        child: _buildHeroText(),
                      ),
                      const SizedBox(height: 48),
                      SlideTransition(
                        position: _slideAnim,
                        child: _buildAgentHighlights(),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
              SlideTransition(
                position: _slideAnim,
                child: _buildButtons(),
              ),
              const SizedBox(height: 36),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return ScaleTransition(
      scale: _scaleLogoAnim,
      child: Container(
        width: 152,
        height: 152,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.accent.withValues(alpha: 0.10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(26),
          child: Image.asset('assets/images/miajudai_logo_transparent.png'),
        ),
      ),
    );
  }

  Widget _buildHeroText() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          RichText(
            textAlign: TextAlign.center,
            text: const TextSpan(
              children: [
                TextSpan(
                  text: 'Domine ',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                    letterSpacing: -0.5,
                    height: 1.2,
                  ),
                ),
                TextSpan(
                  text: 'sua independência',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accent,
                    letterSpacing: -0.5,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Seu hub de assistentes inteligentes para viver melhor, gerenciar finanças e cuidar da casa.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textLabel,
              fontSize: 15,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgentHighlights() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildAgentItem(
            imagePath: 'assets/images/luna.png',
            name: 'Luna',
            role: 'Financeiro',
            bgColor: AppColors.primarySurface,
          ),
          _buildAgentItem(
            imagePath: 'assets/images/otto.png',
            name: 'Otto',
            role: 'Cozinha',
            bgColor: AppColors.accentSurface,
          ),
          _buildAgentItem(
            imagePath: 'assets/images/tina.png',
            name: 'Tina',
            role: 'Doméstico',
            bgColor: const Color(0xFFEAF7EF),
          ),
        ],
      ),
    );
  }

  Widget _buildAgentItem({
    required String imagePath,
    required String name,
    required String role,
    required Color bgColor,
  }) {
    return Column(
      children: [
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(AppDimens.radiusCard),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.07),
                blurRadius: 16,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(13),
            child: Image.asset(imagePath, fit: BoxFit.contain),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          name,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          role,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textLabel,
          ),
        ),
      ],
    );
  }

  Widget _buildButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomButton(
            text: 'Entrar',
            onPressed: () =>
                Navigator.pushReplacementNamed(context, '/login'),
          ),
          const SizedBox(height: 12),
          CustomButton(
            text: 'Criar conta grátis',
            variant: ButtonVariant.outlined,
            onPressed: () =>
                Navigator.pushReplacementNamed(context, '/signup'),
          ),
        ],
      ),
    );
  }
}
