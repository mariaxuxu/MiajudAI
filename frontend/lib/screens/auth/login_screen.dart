import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/constants.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.paddingMedium,
              vertical: AppDimens.paddingLarge,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                // Logo Section
                Image.asset(
                  'assets/images/miajudai_logo_transparent.png',
                  height: 200,
                  width: 200,
                ),
                const SizedBox(height: 48),
                // Card
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(AppDimens.radiusLarge),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(AppDimens.paddingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Entrar na sua conta',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.displaySmall.copyWith(
                          color: const Color(0xFF1B4965),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Continue sua jornada rumo à independência',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppDimens.paddingLarge),
                      // Email Field
                      Text(
                        'Email',
                        style: AppTextStyles.titleSmall.copyWith(
                          color: const Color(0xFF1B4965),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: 'seu@email.com',
                          hintStyle: TextStyle(
                            color: AppColors.textHint,
                          ),
                          prefixIcon: const Icon(
                            Icons.email_outlined,
                            color: Color(0xFFFF8C00),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppDimens.radiusDefault,
                            ),
                            borderSide: const BorderSide(
                              color: Color(0xFFE8E8E8),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppDimens.radiusDefault,
                            ),
                            borderSide: const BorderSide(
                              color: Color(0xFFE8E8E8),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppDimens.radiusDefault,
                            ),
                            borderSide: const BorderSide(
                              color: Color(0xFFFF8C00),
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppDimens.paddingSmall,
                            vertical: AppDimens.paddingSmall,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppDimens.paddingMedium),
                      // Password Field
                      Text(
                        'Senha',
                        style: AppTextStyles.titleSmall.copyWith(
                          color: const Color(0xFF1B4965),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          hintText: 'Sua senha',
                          hintStyle: TextStyle(
                            color: AppColors.textHint,
                          ),
                          prefixIcon: const Icon(
                            Icons.lock_outline,
                            color: Color(0xFFFF8C00),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: const Color(0xFFFF8C00),
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppDimens.radiusDefault,
                            ),
                            borderSide: const BorderSide(
                              color: Color(0xFFE8E8E8),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppDimens.radiusDefault,
                            ),
                            borderSide: const BorderSide(
                              color: Color(0xFFE8E8E8),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppDimens.radiusDefault,
                            ),
                            borderSide: const BorderSide(
                              color: Color(0xFFFF8C00),
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppDimens.paddingSmall,
                            vertical: AppDimens.paddingSmall,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppDimens.paddingMedium),
                      // Login Button
                      Center(
                        child: Consumer<AuthProvider>(
                          builder: (context, authProvider, _) {
                            return SizedBox(
                              width: 200,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: authProvider.isLoading
                                    ? null
                                    : () async {
                                        if (_emailController.text.isEmpty ||
                                            _passwordController.text.isEmpty) {
                                          if (!mounted) return;
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Preencha email e senha',
                                              ),
                                              backgroundColor:
                                                  Color(0xFFFF8C00),
                                            ),
                                          );
                                          return;
                                        }

                                        try {
                                          final email =
                                              _emailController.text;
                                          final password =
                                              _passwordController.text;

                                          await authProvider.login(
                                            email: email,
                                            password: password,
                                          );

                                          if (!mounted) return;

                                          if (authProvider.isAuthenticated) {
                                            if (!mounted) return;
                                            Navigator
                                                .pushReplacementNamed(
                                              context,
                                              '/welcome',
                                            );
                                          } else if (authProvider.error !=
                                              null) {
                                            if (!mounted) return;
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Email ou senha incorretos',
                                                ),
                                                backgroundColor:
                                                    AppColors.error,
                                              ),
                                            );
                                          }
                                        } catch (e) {
                                          if (!mounted) return;
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Email ou senha incorretos',
                                              ),
                                              backgroundColor:
                                                  AppColors.error,
                                            ),
                                          );
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color(0xFFFF8C00),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppDimens.radiusDefault,
                                    ),
                                  ),
                                  disabledBackgroundColor: Colors.grey[400],
                                ),
                                child: authProvider.isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            Colors.white,
                                          ),
                                        ),
                                      )
                                    : Text(
                                        'Entrar',
                                        style: AppTextStyles.titleSmall
                                            .copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: AppDimens.paddingMedium),
                      // Sign Up Link
                      Center(
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          children: [
                            Text(
                              'Não tem uma conta? ',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(context, '/signup');
                                },
                                child: Text(
                                  'Criar conta gratuita',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: const Color(0xFFFF8C00),
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
