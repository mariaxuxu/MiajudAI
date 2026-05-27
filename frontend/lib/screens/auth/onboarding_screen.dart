import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/constants.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_textfield.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late PageController _pageController;
  int _currentPage = 0;

  // Form controllers
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emergencyContactNameController = TextEditingController();
  final _emergencyContactPhoneController = TextEditingController();

  bool _notificationsEnabled = true;
  bool _darkMode = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    _emergencyContactNameController.dispose();
    _emergencyContactPhoneController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _completeOnboarding() {
    // Save data and navigate to home
    final authProvider = context.read<AuthProvider>();

    authProvider.updateProfile(
      fullName: _fullNameController.text,
      phone: _phoneController.text,
    ).then((_) {
      Navigator.pushReplacementNamed(context, '/home');
    });
  }

  void _skipOnboarding() {
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicators
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.paddingDefault,
                vertical: AppDimens.paddingDefault,
              ),
              child: Row(
                children: List.generate(
                  3,
                  (index) => Expanded(
                    child: Container(
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: index <= _currentPage
                            ? AppColors.primary
                            : AppColors.divider,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(AppDimens.paddingDefault),
                child: TextButton(
                  onPressed: _skipOnboarding,
                  child: Text(
                    AppStrings.skip,
                    style: AppTextStyles.titleSmall.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ),
            // Page view
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (page) {
                  setState(() => _currentPage = page);
                },
                children: [
                  // Page 1: Personal Data
                  _buildPersonalDataPage(),
                  // Page 2: Emergency Contact
                  _buildEmergencyContactPage(),
                  // Page 3: Preferences
                  _buildPreferencesPage(),
                ],
              ),
            ),
            // Navigation buttons
            Padding(
              padding: const EdgeInsets.all(AppDimens.paddingDefault),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    Expanded(
                      child: CustomButton(
                        text: AppStrings.back,
                        onPressed: _previousPage,
                        variant: ButtonVariant.outlined,
                      ),
                    )
                  else
                    const Spacer(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      text: _currentPage == 2 ? 'Começar' : AppStrings.next,
                      onPressed: _nextPage,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalDataPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimens.paddingDefault),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          Icon(
            Icons.person_outline,
            size: 64,
            color: AppColors.primary,
          ),
          const SizedBox(height: 24),
          Text(
            'Dados Pessoais',
            textAlign: TextAlign.center,
            style: AppTextStyles.displaySmall,
          ),
          const SizedBox(height: 12),
          Text(
            'Nos ajude a conhecer você melhor',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 32),
          CustomTextField(
            label: 'Nome Completo',
            hint: 'Digite seu nome',
            controller: _fullNameController,
            prefixIcon: Icons.person,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Telefone',
            hint: '(xx) xxxxx-xxxx',
            controller: _phoneController,
            inputType: TextInputType.phone,
            prefixIcon: Icons.phone,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildEmergencyContactPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimens.paddingDefault),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          Icon(
            Icons.emergency,
            size: 64,
            color: AppColors.error,
          ),
          const SizedBox(height: 24),
          Text(
            'Contato de Emergência',
            textAlign: TextAlign.center,
            style: AppTextStyles.displaySmall,
          ),
          const SizedBox(height: 12),
          Text(
            'Quem podemos contactar em caso de emergência?',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 32),
          CustomTextField(
            label: 'Nome do Contato',
            hint: 'Ex: Mãe, Pai, Amigo',
            controller: _emergencyContactNameController,
            prefixIcon: Icons.person,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Telefone',
            hint: '(xx) xxxxx-xxxx',
            controller: _emergencyContactPhoneController,
            inputType: TextInputType.phone,
            prefixIcon: Icons.phone,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(AppDimens.paddingDefault),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppDimens.radiusDefault),
              border: Border.all(color: AppColors.info.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.info, color: AppColors.info),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Enviaremos um código SMS para confirmar',
                    style: AppTextStyles.bodySmall,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildPreferencesPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimens.paddingDefault),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          Icon(
            Icons.settings_outlined,
            size: 64,
            color: AppColors.primary,
          ),
          const SizedBox(height: 24),
          Text(
            'Preferências',
            textAlign: TextAlign.center,
            style: AppTextStyles.displaySmall,
          ),
          const SizedBox(height: 12),
          Text(
            'Configure como você quer usar o app',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 32),
          // Notifications
          SwitchListTile(
            title: Text(
              'Notificações',
              style: AppTextStyles.titleSmall,
            ),
            subtitle: Text(
              'Receber lembretes e alertas',
              style: AppTextStyles.bodySmall,
            ),
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() => _notificationsEnabled = value);
            },
            secondary: Icon(
              Icons.notifications_active,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          // Dark mode
          SwitchListTile(
            title: Text(
              'Modo Escuro',
              style: AppTextStyles.titleSmall,
            ),
            subtitle: Text(
              'Usar tema escuro (em breve)',
              style: AppTextStyles.bodySmall,
            ),
            value: _darkMode,
            onChanged: (value) {
              setState(() => _darkMode = value);
            },
            secondary: Icon(
              Icons.dark_mode,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(AppDimens.paddingDefault),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppDimens.radiusDefault),
              border: Border.all(color: AppColors.success.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: AppColors.success),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Tudo pronto! Clique em "Começar" para entrar',
                    style: AppTextStyles.bodySmall,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
