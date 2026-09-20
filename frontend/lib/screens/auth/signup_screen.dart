import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/tokens/app_colors_semantic.dart';
import '../../widgets/auth/auth_field.dart';
import '../../widgets/auth/auth_screen_header.dart';
import '../../widgets/common/app_primary_button.dart';
import '../../widgets/common/app_screen_scaffold.dart';

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
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return AppScreenScaffold(
      contentAlignment: Alignment.topCenter,
      child: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: _buildForm(context),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuthScreenHeader(
            title: 'Criar conta',
            subtitle: 'Em poucos minutos você já está começando',
            noteText: 'Mais liberdade para o seu dia',
            onBack: () => Navigator.pushReplacementNamed(context, '/'),
          ),
          const SizedBox(height: AppSpacing.sectionGap),

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
          const SizedBox(height: AppSpacing.defaultGap),

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
          const SizedBox(height: AppSpacing.defaultGap),

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
            const SizedBox(height: AppSpacing.itemGap),
            _buildStrengthIndicator(),
          ],
          const SizedBox(height: AppSpacing.defaultGap),

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
          const SizedBox(height: AppSpacing.sectionGap),

          Consumer<AuthProvider>(
            builder: (context, auth, _) => AppPrimaryButton(
              label: 'Criar conta',
              trailingIcon: Icons.arrow_forward_rounded,
              isLoading: auth.isLoading,
              onPressed: auth.isLoading ? null : () => _submit(context),
            ),
          ),
          const SizedBox(height: AppSpacing.itemGap),
          _buildLoginLink(context),
        ],
      ),
    );
  }

  Widget _buildStrengthIndicator() {
    // As barras usam os tons 500 (identidade); o texto usa os tons 700, que
    // atingem contraste AA sobre o fundo claro. O nivel e sempre dito por
    // extenso ("Fraca", "Forte"), nunca so por cor.
    const barColors = [
      AppSemanticColors.feedbackError,
      AppSemanticColors.feedbackWarning,
      AppSemanticColors.actionPrimary,
      AppSemanticColors.feedbackSuccess,
    ];
    const textColors = [
      AppSemanticColors.onFeedbackError,
      AppSemanticColors.onFeedbackWarning,
      AppSemanticColors.actionPrimary,
      AppSemanticColors.onFeedbackSuccess,
    ];
    const labels = ['Muito fraca', 'Fraca', 'Boa', 'Forte'];

    final color = _passwordStrength > 0
        ? barColors[_passwordStrength - 1]
        : AppSemanticColors.border;
    final textColor = _passwordStrength > 0
        ? textColors[_passwordStrength - 1]
        : AppSemanticColors.textSecondary;
    final label = _passwordStrength > 0 ? labels[_passwordStrength - 1] : '';

    return Semantics(
      container: true,
      label: label.isEmpty ? null : 'Força da senha: $label',
      child: ExcludeSemantics(
        child: Row(
          children: [
            ...List.generate(4, (i) {
              return Expanded(
                child: Container(
                  height: 4,
                  margin: EdgeInsets.only(right: i < 3 ? 4 : 0),
                  decoration: BoxDecoration(
                    color: i < _passwordStrength
                        ? color
                        : AppSemanticColors.border,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                ),
              );
            }),
            if (label.isNotEmpty) ...[
              const SizedBox(width: AppSpacing.itemGap),
              Text(
                label,
                style: AppTypography.labelSmall.copyWith(color: textColor),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLoginLink(BuildContext context) {
    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            'Já tem uma conta?',
            style: AppTypography.bodyMedium.copyWith(
              color: AppSemanticColors.textSecondary,
            ),
          ),
          TextButton(
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              minimumSize: const Size(0, AppSpacing.minTouchTarget),
            ),
            child: const Text('Entrar'),
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
            const Icon(
              Icons.error_outline,
              color: AppSemanticColors.onFeedbackSolid,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppSemanticColors.onFeedbackSolid,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppSemanticColors.feedbackErrorSolid,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.control),
        ),
        margin: const EdgeInsets.all(AppSpacing.defaultGap),
        duration: const Duration(seconds: 4),
      ),
    );
  }
}
