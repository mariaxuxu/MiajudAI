import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/onboarding_provider.dart';
import '../../../config/constants.dart';
import '../../../utils/validators.dart';

class SecurityStep extends StatefulWidget {
  const SecurityStep({Key? key}) : super(key: key);

  @override
  State<SecurityStep> createState() => _SecurityStepState();
}

class _SecurityStepState extends State<SecurityStep> {
  late TextEditingController _cpfController;
  late TextEditingController _contatoNomeController;
  late TextEditingController _contatoTelController;
  late TextEditingController _dietaController;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _cpfController = TextEditingController();
    _contatoNomeController = TextEditingController();
    _contatoTelController = TextEditingController();
    _dietaController = TextEditingController();
  }

  @override
  void dispose() {
    _cpfController.dispose();
    _contatoNomeController.dispose();
    _contatoTelController.dispose();
    _dietaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OnboardingProvider>(
      builder: (context, onboarding, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimens.paddingMedium),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.security_outlined,
                        size: 64,
                        color: const Color(0xFF1B4965),
                      ),
                      const SizedBox(height: AppDimens.paddingMedium),
                      Text(
                        'Segurança & Preferências',
                        style: AppTextStyles.displaySmall.copyWith(
                          color: const Color(0xFF1B4965),
                        ),
                      ),
                      const SizedBox(height: AppDimens.paddingSmall),
                      Text(
                        'Informações importantes para sua conta',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimens.paddingLarge),
                // CPF/RG
                _buildTextField(
                  label: 'CPF ou RG',
                  controller: _cpfController,
                  hint: '000.000.000-00',
                  icon: Icons.badge_outlined,
                  onChanged: onboarding.setCpfRg,
                  validator: Validators.validateCPF,
                  isRequired: true,
                ),
                const SizedBox(height: AppDimens.paddingMedium),
                // Contato Emergência - Nome (Opcional)
                _buildTextField(
                  label: 'Contato de Emergência - Nome',
                  controller: _contatoNomeController,
                  hint: 'Nome da pessoa de confiança',
                  icon: Icons.person_add_outlined,
                  onChanged: onboarding.setContatoEmergNome,
                  validator: null,
                  isRequired: false,
                ),
                const SizedBox(height: AppDimens.paddingMedium),
                // Contato Emergência - Telefone (Opcional)
                _buildTextField(
                  label: 'Contato de Emergência - Telefone',
                  controller: _contatoTelController,
                  hint: '(11) 99999-9999',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  onChanged: onboarding.setContatoEmergTel,
                  validator: Validators.validateOptionalPhone,
                  isRequired: false,
                ),
                const SizedBox(height: AppDimens.paddingMedium),
                // Preferência de Dieta (Opcional)
                _buildDietaField(
                  onboarding: onboarding,
                  controller: _dietaController,
                ),
                const SizedBox(height: AppDimens.paddingMedium),
                // Info Box
                Container(
                  padding: const EdgeInsets.all(AppDimens.paddingSmall),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B4965).withValues(alpha: 0.1),
                    borderRadius:
                        BorderRadius.circular(AppDimens.radiusDefault),
                    border: Border.all(
                      color: const Color(0xFF1B4965).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: Color(0xFF1B4965),
                        size: 20,
                      ),
                      const SizedBox(width: AppDimens.paddingSmall),
                      Expanded(
                        child: Text(
                          'Os campos com * são obrigatórios. Os demais são opcionais.',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: const Color(0xFF1B4965),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required Function(String) onChanged,
    required String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    required bool isRequired,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: AppTextStyles.titleSmall.copyWith(
                color: const Color(0xFF1B4965),
              ),
            ),
            if (isRequired)
              const Text(
                ' *',
                style: TextStyle(color: Color(0xFFF44336)),
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: const Color(0xFFFF8C00)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusDefault),
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
          ),
          keyboardType: keyboardType,
          onChanged: onChanged,
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildDietaField({
    required OnboardingProvider onboarding,
    required TextEditingController controller,
  }) {
    final dietas = ['Carnívoro', 'Vegetariano', 'Vegano', 'Sem Restrições'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Preferência de Dieta',
          style: AppTextStyles.titleSmall.copyWith(
            color: const Color(0xFF1B4965),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: AppDimens.paddingSmall,
          runSpacing: AppDimens.paddingSmall,
          children: dietas.map((dieta) {
            final isSelected = controller.text == dieta;
            return FilterChip(
              label: Text(dieta),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  controller.text = selected ? dieta : '';
                  onboarding.setPreferenciadieta(selected ? dieta : null);
                });
              },
              selectedColor: const Color(0xFFFF8C00),
              backgroundColor: Colors.grey[200],
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              side: BorderSide(
                color: isSelected
                    ? const Color(0xFFFF8C00)
                    : Colors.grey[300]!,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
