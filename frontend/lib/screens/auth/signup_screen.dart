import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/constants.dart';
import '../../providers/auth_provider.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fullNameController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.requiredField;
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return AppStrings.invalidEmail;
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.requiredField;
    }
    if (value.length < 6) {
      return AppStrings.passwordTooShort;
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.requiredField;
    }
    if (value != _passwordController.text) {
      return AppStrings.passwordMismatch;
    }
    return null;
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
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Column(
                            children: [
                              Text(
                                'Criar conta',
                                style: AppTextStyles.displaySmall.copyWith(
                                  color: const Color(0xFF1B4965),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Em poucos minutos você já estará começando',
                                textAlign: TextAlign.center,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppDimens.paddingLarge),
                        // Full Name
                        Text(
                          'Nome Completo',
                          style: AppTextStyles.titleSmall.copyWith(
                            color: const Color(0xFF1B4965),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _fullNameController,
                          decoration: _buildInputDecoration(
                            hintText: 'Digite seu nome completo',
                            icon: Icons.person_outlined,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return AppStrings.requiredField;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppDimens.paddingMedium),
                        // Email
                        Text(
                          'Email',
                          style: AppTextStyles.titleSmall.copyWith(
                            color: const Color(0xFF1B4965),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: _buildInputDecoration(
                            hintText: 'seu@email.com',
                            icon: Icons.email_outlined,
                          ),
                          validator: _validateEmail,
                        ),
                        const SizedBox(height: AppDimens.paddingMedium),
                        // Password
                        Text(
                          'Senha',
                          style: AppTextStyles.titleSmall.copyWith(
                            color: const Color(0xFF1B4965),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            hintText: 'Mínimo 6 caracteres',
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
                          validator: _validatePassword,
                        ),
                        const SizedBox(height: AppDimens.paddingMedium),
                        // Confirm Password
                        Text(
                          'Confirmar Senha',
                          style: AppTextStyles.titleSmall.copyWith(
                            color: const Color(0xFF1B4965),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirmPassword,
                          decoration: InputDecoration(
                            hintText: 'Confirme sua senha',
                            hintStyle: TextStyle(
                              color: AppColors.textHint,
                            ),
                            prefixIcon: const Icon(
                              Icons.lock_outline,
                              color: Color(0xFFFF8C00),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: const Color(0xFFFF8C00),
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword =
                                      !_obscureConfirmPassword;
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
                          validator: _validateConfirmPassword,
                        ),
                        const SizedBox(height: AppDimens.paddingLarge),
                        // Sign Up Button
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
                                          if (_formKey.currentState!
                                              .validate()) {
                                            try {
                                              await authProvider.signup(
                                                email: _emailController.text,
                                                password:
                                                    _passwordController.text,
                                                fullName:
                                                    _fullNameController.text,
                                              );

                                              if (authProvider
                                                  .isAuthenticated) {
                                                Navigator
                                                    .pushReplacementNamed(
                                                  context,
                                                  '/welcome',
                                                );
                                              } else if (authProvider
                                                      .error !=
                                                  null) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      authProvider.error!,
                                                    ),
                                                    backgroundColor:
                                                        AppColors.error,
                                                  ),
                                                );
                                              }
                                            } catch (e) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'Erro: ${e.toString()}',
                                                  ),
                                                  backgroundColor:
                                                      AppColors.error,
                                                ),
                                              );
                                            }
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
                                    disabledBackgroundColor:
                                        Colors.grey[400],
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
                                          'Criar Conta',
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
                        // Back to Login
                        Center(
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            children: [
                              Text(
                                'Já tem uma conta? ',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: GestureDetector(
                                  onTap: () => Navigator.pop(context),
                                  child: Text(
                                    'Entrar',
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hintText,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: AppColors.textHint),
      prefixIcon: Icon(icon, color: const Color(0xFFFF8C00)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusDefault),
        borderSide: const BorderSide(color: Color(0xFFE8E8E8)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusDefault),
        borderSide: const BorderSide(color: Color(0xFFE8E8E8)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusDefault),
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
    );
  }
}
