import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/auth_service.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_typography.dart';
import '../../theme/tokens/app_colors_semantic.dart';
import '../../widgets/auth/auth_field.dart';
import '../../widgets/auth/auth_screen_header.dart';
import '../../widgets/common/app_primary_button.dart';
import '../../widgets/common/app_screen_scaffold.dart';
import '../../widgets/common/brand_note.dart';
import '../../widgets/common/cropped_asset_image.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  late AnimationController _animCtrl;
  late Animation<Offset> _slideAnim;
  late Animation<double> _fadeAnim;

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
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
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
      footer: FadeTransition(opacity: _fadeAnim, child: _buildFooter()),
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
            title: 'Bem-vindo de volta!',
            subtitle: 'Continue sua jornada rumo à independência.',
            noteText: 'Mais organização para uma vida mais leve.',
            onBack: () => Navigator.pushReplacementNamed(context, '/'),
          ),
          const SizedBox(height: AppSpacing.sectionGap),
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
          AuthField(
            label: 'Senha',
            hint: 'Sua senha',
            controller: _passwordController,
            prefixIcon: Icons.lock_outline,
            isPassword: true,
            focusNode: _passwordFocus,
            textInputAction: TextInputAction.done,
            onEditingComplete: () => _submit(context),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Informe sua senha';
              if (v.length < 6) return 'Mínimo 6 caracteres';
              return null;
            },
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => _showForgotPassword(context),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, AppSpacing.minTouchTarget),
              ),
              child: const Text('Esqueci minha senha'),
            ),
          ),
          const SizedBox(height: AppSpacing.itemGap),
          Consumer<AuthProvider>(
            builder: (context, auth, _) => AppPrimaryButton(
              label: 'Entrar',
              trailingIcon: Icons.arrow_forward_rounded,
              isLoading: auth.isLoading,
              onPressed: auth.isLoading ? null : () => _submit(context),
            ),
          ),
          const SizedBox(height: AppSpacing.itemGap),
          _buildSignupLink(context),
        ],
      ),
    );
  }

  Widget _buildSignupLink(BuildContext context) {
    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            'Não tem uma conta?',
            style: AppTypography.bodyMedium.copyWith(
              color: AppSemanticColors.textSecondary,
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/signup'),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              minimumSize: const Size(0, AppSpacing.minTouchTarget),
            ),
            child: const Text('Criar conta gratuita'),
          ),
        ],
      ),
    );
  }

  /// Nota de marca a esquerda e o grupo de agentes a direita, ancorados na
  /// base da tela. Puramente decorativo.
  Widget _buildFooter() {
    return const Padding(
      padding: EdgeInsets.only(top: AppSpacing.itemGap),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.itemGap),
                child: BrandNote(
                  text: 'Pequenas decisões hoje, uma vida mais livre amanhã.',
                  rotation: -0.07,
                  maxWidth: 120,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: CroppedAssetImage(
              // Grupo de agentes. JPEG de fundo branco: dissolvido no fundo da
              // tela e recortado nas margens (ver CroppedAssetImage).
              asset: 'assets/images/todos_agents.jpg',
              assetSize: Size(1421, 1536),
              widthFactor: 0.82,
              heightFactor: 0.72,
              anchor: Alignment(-0.24, 0),
              blendInto: AppSemanticColors.background,
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
      await auth.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!context.mounted) return;

      if (auth.isAuthenticated) {
        Navigator.pushReplacementNamed(context, '/welcome');
      } else if (auth.error != null) {
        _showError(context, 'Email ou senha incorretos. Tente novamente.');
      }
    } catch (_) {
      if (!context.mounted) return;
      _showError(context, 'Não foi possível entrar. Verifique sua conexão.');
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
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showForgotPassword(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      // A sheet vive numa rota propria, fora do Theme local do
      // AppScreenScaffold; o tema e reaplicado explicitamente.
      builder: (_) => Theme(
        data: AppTheme.light,
        child: const _ForgotPasswordSheet(),
      ),
    );
  }
}

class _ForgotPasswordSheet extends StatefulWidget {
  const _ForgotPasswordSheet();

  @override
  State<_ForgotPasswordSheet> createState() => _ForgotPasswordSheetState();
}

class _ForgotPasswordSheetState extends State<_ForgotPasswordSheet> {
  final _emailCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  bool _sent = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendResetEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authService.sendPasswordResetEmail(_emailCtrl.text.trim());

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _sent = true;
      });

      // Show success toast
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.email_outlined,
                color: AppSemanticColors.onFeedbackSolid,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Email de recuperação enviado com sucesso',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppSemanticColors.onFeedbackSolid,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: AppSemanticColors.feedbackSuccessSolid,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.control),
          ),
          margin: const EdgeInsets.all(AppSpacing.defaultGap),
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      String errorMsg = 'Erro ao enviar email';
      if (e.toString().contains('user-not-found')) {
        errorMsg = 'Email não encontrado';
      } else if (e.toString().contains('invalid-email')) {
        errorMsg = 'Email inválido';
      } else if (e.toString().contains('too-many-requests')) {
        errorMsg = 'Muitas tentativas. Tente novamente mais tarde';
      }

      setState(() {
        _isLoading = false;
        _errorMessage = errorMsg;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      decoration: const BoxDecoration(
        color: AppSemanticColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppRadius.sheet),
          topRight: Radius.circular(AppRadius.sheet),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screenGutter,
        AppSpacing.screenGutter,
        AppSpacing.screenGutter,
        AppSpacing.screenGutter + bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppSemanticColors.border,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.screenGutter),
          Semantics(
            header: true,
            child: Text(
              'Recuperar senha',
              style: AppTypography.headlineMedium.copyWith(
                color: AppSemanticColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Informe seu email e enviaremos um link de recuperação.',
            style: AppTypography.bodyMedium.copyWith(
              color: AppSemanticColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.screenGutter),
          if (!_sent) ...[
            Form(
              key: _formKey,
              child: AuthField(
                label: 'Email cadastrado',
                hint: 'seu@email.com',
                controller: _emailCtrl,
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Informe o email';
                  if (!RegExp(r'^[\w\-.]+@([\w-]+\.)+[\w-]{2,}$')
                      .hasMatch(v.trim())) {
                    return 'Email inválido';
                  }
                  return null;
                },
              ),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: AppSpacing.itemGap),
              Container(
                padding: const EdgeInsets.all(AppSpacing.itemGap),
                decoration: BoxDecoration(
                  color: AppSemanticColors.feedbackErrorSubtle,
                  borderRadius: BorderRadius.circular(AppRadius.control),
                  border: Border.all(color: AppSemanticColors.feedbackError),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: AppSemanticColors.onFeedbackError,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppSemanticColors.onFeedbackError,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.screenGutter),
            AppPrimaryButton(
              label: 'Enviar link',
              isLoading: _isLoading,
              onPressed: _isLoading ? null : _sendResetEmail,
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(AppSpacing.defaultGap),
              decoration: BoxDecoration(
                color: AppSemanticColors.feedbackSuccessSubtle,
                borderRadius: BorderRadius.circular(AppRadius.control),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    color: AppSemanticColors.onFeedbackSuccess,
                    size: 24,
                  ),
                  const SizedBox(width: AppSpacing.itemGap),
                  Expanded(
                    child: Text(
                      'Link enviado para ${_emailCtrl.text}. Verifique sua caixa de entrada.',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppSemanticColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.screenGutter),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fechar'),
            ),
          ],
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
