import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/constants.dart';
import '../providers/auth_provider.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  String _getFirstName(String? fullName) {
    if (fullName == null || fullName.isEmpty) {
      return '';
    }
    return fullName.split(' ').first;
  }

  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Fazer Logout?'),
        content: const Text('Tem certeza que deseja sair?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/');
            },
            child: const Text('Sair', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFF1B4965)),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.paddingMedium,
              vertical: AppDimens.paddingLarge,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Center(
                  child: Column(
                    children: [
                      Consumer<AuthProvider>(
                        builder: (context, authProvider, _) {
                          final firstName = _getFirstName(authProvider.user?.fullName);
                          return Text(
                            'Olá, $firstName!',
                            style: AppTextStyles.displaySmall.copyWith(
                              color: const Color(0xFF1B4965),
                              fontWeight: FontWeight.w700,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No que posso te ajudar hoje?',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimens.paddingLarge),
                // Funcionalidades Grid
                _buildFeatureCard(
                  context,
                  icon: Icons.person_outline,
                  title: 'Gerenciar Conta',
                  description: 'Atualize seus dados pessoais',
                  color: const Color(0xFF1B4965),
                  onTap: () {
                    Navigator.pushNamed(context, '/manage-account');
                  },
                ),
                const SizedBox(height: 12),
                _buildFeatureCard(
                  context,
                  icon: Icons.calendar_today_outlined,
                  title: 'Calendário',
                  description: 'Veja seus compromissos',
                  color: const Color(0xFFFF8C00),
                  onTap: () {
                    Navigator.pushNamed(context, '/calendar');
                  },
                ),
                const SizedBox(height: 12),
                _buildFeatureCard(
                  context,
                  icon: Icons.home_outlined,
                  title: 'Área Doméstica',
                  description: 'Gerenciar sua casa e tarefas',
                  color: const Color(0xFF1B4965),
                  onTap: () {
                    // TODO: Navegar para área doméstica
                  },
                ),
                const SizedBox(height: 12),
                _buildFeatureCard(
                  context,
                  icon: Icons.attach_money_outlined,
                  title: 'Finanças',
                  description: 'Gerencie suas finanças',
                  color: const Color(0xFFFF8C00),
                  onTap: () {
                    Navigator.pushNamed(context, '/accounts');
                  },
                ),
                const SizedBox(height: 12),
                _buildFeatureCard(
                  context,
                  icon: Icons.build_circle_outlined,
                  title: 'Serviços Externos',
                  description: 'Encontre prestadores de serviços',
                  color: const Color(0xFF1B4965),
                  onTap: () {
                    // TODO: Navegar para serviços externos
                  },
                ),
                const SizedBox(height: AppDimens.paddingLarge),
                // Falar com MiAjudAI Button
                Center(
                  child: SizedBox(
                    width: 220,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Navegar para chatbot
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF8C00),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppDimens.radiusDefault),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.chat_outlined,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Falar com MiAjudAI',
                            style: AppTextStyles.titleSmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
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
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppDimens.radiusLarge),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppDimens.paddingMedium),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius:
                        BorderRadius.circular(AppDimens.radiusMedium),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 28,
                  ),
                ),
                const SizedBox(width: AppDimens.paddingMedium),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.titleSmall.copyWith(
                          color: const Color(0xFF1B4965),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: color,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
