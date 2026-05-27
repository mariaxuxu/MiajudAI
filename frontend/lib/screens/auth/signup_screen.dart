import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../config/constants.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/auth/auth_field.dart';
import '../../widgets/common/custom_button.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmFocus = FocusNode();

  late AnimationController _animCtrl;
  late Animation<Offset> _slideAnim;
  late Animation<double> _fadeAnim;

  int _passwordStrength = 0;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));

    Future.delayed(const Duration(milliseconds: 80), () {
      if (mounted) _animCtrl.forward();
    });
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  int _calcStrength(String password) {
    int score = 0;
    if (password.length >= 6) score++;
    if (password.length >= 10) score++;
    if (password.contains(RegExp(r'[A-Z]'))) score++;
    if (password.contains(RegExp(r'[0-9!@#\$%&*]'))) score++;
    return score;
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
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          _buildHero(context),
          _buildFormCard(context),
        ],
      ),
    );
  }

  Widget _buildHero(BuildContext context) {
    return Expanded(
      flex: 33,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.accentSurface, Color(0xFFFAF8F5)],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, '/'),
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                color: AppColors.textLabel,
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              ),
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.accent.withValues(alpha: 0.10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Image.asset(
                              'assets/images/miajudai_logo_transparent.png',
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Criar conta',
                          style: TextStyle(
                            color: AppColors.textDark,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Em poucos minutos você já está começando',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textLabel,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormCard(BuildContext context) {
    return Expanded(
      flex: 67,
      child: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppDimens.radiusHeroCard),
                topRight: Radius.circular(AppDimens.radiusHeroCard),
              ),
            ),
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(28, 28, 28, 32),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Preencha seus dados',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Nome completo
                    AuthField(
                      label: 'Nome completo',
                      hint: 'Como você quer ser chamado?',
                      controller: _nameController,
                      prefixIcon: Icons.person_outline,
                      focusNode: _nameFocus,
                      textInputAction: TextInputAction.next,
                      onEditingComplete: () =>
                          FocusScope.of(context).requestFocus(_emailFocus),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Informe seu nome';
                        }
                        if (v.trim().length < 2) return 'Nome muito curto';
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Email
                    AuthField(
                      label: 'Email',
                      hint: 'seu@email.com',
                      controller: _emailController,
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      focusNode: _emailFocus,
                      textInputAction: TextInputAction.next,
                      onEditingComplete: () =>
                          FocusScope.of(context).requestFocus(_passwordFocus),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Informe seu email';
                        }
                        if (!RegExp(r'^[\w\-.]+@([\w-]+\.)+[\w-]{2,}$')
                            .hasMatch(v.trim())) {
                          return 'Email inválido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Senha
                    AuthField(
                      label: 'Senha',
                      hint: 'Mínimo 6 caracteres',
                      controller: _passwordController,
                      prefixIcon: Icons.lock_outline,
                      isPassword: true,
                      focusNode: _passwordFocus,
                      textInputAction: TextInputAction.next,
                      onChanged: (v) =>
                          setState(() => _passwordStrength = _calcStrength(v)),
                      onEditingComplete: () =>
                          FocusScope.of(context).requestFocus(_confirmFocus),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Crie uma senha';
                        if (v.length < 6) return 'Mínimo 6 caracteres';
                        return null;
                      },
                    ),

                    // Indicador de força da senha
                    if (_passwordController.text.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      _buildStrengthIndicator(),
                    ],
                    const SizedBox(height: 20),

                    // Confirmar senha
                    AuthField(
                      label: 'Confirmar senha',
                      hint: 'Repita a senha',
                      controller: _confirmController,
                      prefixIcon: Icons.lock_open_outlined,
                      isPassword: true,
                      focusNode: _confirmFocus,
                      textInputAction: TextInputAction.done,
                      onEditingComplete: () => _submit(context),
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return 'Confirme sua senha';
                        }
                        if (v != _passwordController.text) {
                          return 'As senhas não coincidem';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 28),

                    Consumer<AuthProvider>(
                      builder: (context, auth, _) => CustomButton(
                        text: 'Criar conta',
                        isLoading: auth.isLoading,
                        onPressed:
                            auth.isLoading ? null : () => _submit(context),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildLoginLink(context),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStrengthIndicator() {
    final strengths = [
      const Color(0xFFEF4444),
      const Color(0xFFF59E0B),
      const Color(0xFF84CC16),
      AppColors.success,
    ];
    final labels = ['Muito fraca', 'Fraca', 'Boa', 'Forte'];
    final color = _passwordStrength > 0
        ? strengths[_passwordStrength - 1]
        : AppColors.inputBorder;
    final label =
        _passwordStrength > 0 ? labels[_passwordStrength - 1] : '';

    return Row(
      children: [
        ...List.generate(4, (i) {
          return Expanded(
            child: Container(
              height: 3,
              margin: EdgeInsets.only(right: i < 3 ? 4 : 0),
              decoration: BoxDecoration(
                color: i < _passwordStrength ? color : AppColors.inputBorder,
                borderRadius: BorderRadius.circular(AppDimens.radiusFull),
              ),
            ),
          );
        }),
        if (label.isNotEmpty) ...[
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLoginLink(BuildContext context) {
    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        children: [
          const Text(
            'Já tem uma conta? ',
            style: TextStyle(color: AppColors.textLabel, fontSize: 14),
          ),
          GestureDetector(
            onTap: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
            child: const Text(
              'Entrar',
              style: TextStyle(
                color: AppColors.accent,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submit(BuildContext context) async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();

    try {
      await auth.signup(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _nameController.text.trim(),
      );

      if (!context.mounted) return;

      if (auth.isAuthenticated) {
        Navigator.pushReplacementNamed(context, '/welcome');
      } else if (auth.error != null) {
        _showError(context, auth.error!);
      }
    } catch (e) {
      if (!context.mounted) return;
      _showError(context, 'Não foi possível criar a conta. Tente novamente.');
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      ),
    );
  }
}
