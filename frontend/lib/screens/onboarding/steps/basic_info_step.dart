import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/onboarding_provider.dart';
import '../../../config/constants.dart';
import '../../../utils/validators.dart';

class BasicInfoStep extends StatefulWidget {
  const BasicInfoStep({Key? key}) : super(key: key);

  @override
  State<BasicInfoStep> createState() => _BasicInfoStepState();
}

class _BasicInfoStepState extends State<BasicInfoStep> {
  late TextEditingController _nomeController;
  late TextEditingController _telefoneController;
  late TextEditingController _enderecoController;
  late TextEditingController _idadeController;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController();
    _telefoneController = TextEditingController();
    _enderecoController = TextEditingController();
    _idadeController = TextEditingController();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _telefoneController.dispose();
    _enderecoController.dispose();
    _idadeController.dispose();
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
                        Icons.person_outline,
                        size: 64,
                        color: const Color(0xFF1B4965),
                      ),
                      const SizedBox(height: AppDimens.paddingMedium),
                      Text(
                        'Dados Básicos',
                        style: AppTextStyles.displaySmall.copyWith(
                          color: const Color(0xFF1B4965),
                        ),
                      ),
                      const SizedBox(height: AppDimens.paddingSmall),
                      Text(
                        'Nos ajude a conhecer você melhor',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimens.paddingLarge),
                // Nome Completo
                _buildTextField(
                  label: 'Nome Completo',
                  controller: _nomeController,
                  hint: 'Digite seu nome completo',
                  icon: Icons.person_outline,
                  onChanged: onboarding.setNomeUsuario,
                  validator: Validators.validateName,
                ),
                const SizedBox(height: AppDimens.paddingMedium),
                // Telefone
                _buildTextField(
                  label: 'Telefone',
                  controller: _telefoneController,
                  hint: '(11) 99999-9999',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  onChanged: onboarding.setTelefoneUsuario,
                  validator: Validators.validatePhone,
                ),
                const SizedBox(height: AppDimens.paddingMedium),
                // Data de Nascimento
                _buildDateField(
                  label: 'Data de Nascimento',
                  controller: _idadeController,
                  onChanged: onboarding.setIdade,
                  validator: Validators.validateBirthDate,
                ),
                const SizedBox(height: AppDimens.paddingMedium),
                // Endereço
                _buildTextField(
                  label: 'Endereço',
                  controller: _enderecoController,
                  hint: 'Rua, número, complemento',
                  icon: Icons.location_on_outlined,
                  maxLines: 2,
                  onChanged: onboarding.setEndereco,
                  validator: Validators.validateAddress,
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
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.titleSmall.copyWith(
            color: const Color(0xFF1B4965),
          ),
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
          maxLines: maxLines,
          minLines: maxLines,
          onChanged: onChanged,
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required TextEditingController controller,
    required Function(String) onChanged,
    required String? Function(String?) validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.titleSmall.copyWith(
            color: const Color(0xFF1B4965),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'DD/MM/YYYY',
            prefixIcon:
                const Icon(Icons.calendar_today, color: Color(0xFFFF8C00)),
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
          keyboardType: TextInputType.datetime,
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: DateTime.now().subtract(const Duration(days: 6570)),
              firstDate: DateTime(1950),
              lastDate: DateTime.now().subtract(const Duration(days: 6570)),
            );
            if (picked != null) {
              final formattedDate =
                  "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
              controller.text =
                  "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
              onChanged(formattedDate);
            }
          },
          onChanged: (value) {
            if (value.isNotEmpty) {
              try {
                final parts = value.split('/');
                if (parts.length == 3) {
                  final date = DateTime(
                    int.parse(parts[2]),
                    int.parse(parts[1]),
                    int.parse(parts[0]),
                  );
                  final formattedDate =
                      "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
                  onChanged(formattedDate);
                }
              } catch (e) {
                // Invalid format, ignore
              }
            }
          },
          validator: validator,
        ),
      ],
    );
  }
}
