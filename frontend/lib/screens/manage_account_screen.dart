import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';
import '../theme/app_typography.dart';
import '../theme/tokens/app_colors_semantic.dart';
import '../widgets/common/app_form_field.dart';
import '../widgets/common/app_feedback_snackbar.dart';
import '../widgets/common/app_module_scaffold.dart';
import '../widgets/common/app_primary_button.dart';
import '../widgets/common/app_form_sheet.dart';
import '../widgets/common/module_screen_header.dart';
import '../widgets/common/section_header.dart';
import '../widgets/profile/contact_group_card.dart';
import '../widgets/profile/profile_nav_card.dart';
import '../widgets/profile/profile_section_card.dart';

final List<String> brazilianStates = [
  'AC',
  'AL',
  'AP',
  'AM',
  'BA',
  'CE',
  'DF',
  'ES',
  'GO',
  'MA',
  'MT',
  'MS',
  'MG',
  'PA',
  'PB',
  'PR',
  'PE',
  'PI',
  'RJ',
  'RN',
  'RS',
  'RO',
  'RR',
  'SC',
  'SP',
  'SE',
  'TO',
];

// ─────────────────────────────────────────────────────────────────────────────
// Tela principal — hub de seções
// ─────────────────────────────────────────────────────────────────────────────

class ManageAccountScreen extends StatelessWidget {
  const ManageAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppModuleScaffold(
      header: ModuleScreenHeader(
        title: 'Gerenciar conta',
        subtitle: 'Mantenha suas informações atualizadas',
        onBack: () => Navigator.pop(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionHeader(title: 'Minha conta'),
          const SizedBox(height: AppSpacing.labelGap),
          Padding(
            padding: const EdgeInsets.only(left: AppSpacing.defaultGap),
            child: Text(
              'Gerencie seus dados e mantenha tudo atualizado.',
              style: AppTypography.bodyMedium.copyWith(
                color: AppSemanticColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.defaultGap),
          ProfileNavCard(
            icon: Icons.person_rounded,
            title: 'Informações pessoais',
            description: 'Seus dados pessoais, endereço e nascimento',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const _InformacoesPessoaisPage(),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.itemGap),
          ProfileNavCard(
            icon: Icons.phone_rounded,
            title: 'Contatos de emergência',
            description: 'Pessoas de confiança para situações importantes',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const _ContatoEmergenciaPage(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sheet de edição de texto e diálogo de escolha (visual do Design System)
// ─────────────────────────────────────────────────────────────────────────────

void _showEditSheet(
  BuildContext outerContext, {
  required String title,
  required String label,
  required String hint,
  required String initialValue,
  TextInputType? keyboardType,
  required void Function(String value) onSave,
}) {
  final controller = TextEditingController(text: initialValue);

  AppFormSheet.show<void>(
    context: outerContext,
    title: title,
    builder: (sheetContext) => Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppFormField(
          label: label,
          controller: controller,
          hint: hint,
          keyboardType: keyboardType,
          autofocus: true,
        ),
        const SizedBox(height: AppSpacing.blockGap),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(sheetContext),
                child: const Text('Cancelar'),
              ),
            ),
            const SizedBox(width: AppSpacing.itemGap),
            Expanded(
              child: AppPrimaryButton(
                label: 'Salvar',
                onPressed: () {
                  onSave(controller.text);
                  Navigator.pop(sheetContext);
                },
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

void _showChoiceDialog(
  BuildContext context, {
  required String title,
  required Widget Function(BuildContext dialogContext) body,
}) {
  showDialog<void>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.45),
    builder: (dialogContext) => Theme(
      data: AppTheme.light,
      child: Dialog(
        backgroundColor: AppSemanticColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sheet),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenGutter),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Semantics(
                header: true,
                child: Text(
                  title,
                  style: AppTypography.headlineMedium.copyWith(
                    color: AppSemanticColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.itemGap),
              body(dialogContext),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget _choiceTile(String label, VoidCallback onTap) {
  return ListTile(
    contentPadding: EdgeInsets.zero,
    minTileHeight: AppSpacing.minTouchTarget,
    title: Text(
      label,
      style: AppTypography.bodyLarge.copyWith(
        color: AppSemanticColors.textPrimary,
      ),
    ),
    onTap: onTap,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Informações pessoais
// ─────────────────────────────────────────────────────────────────────────────

class _InformacoesPessoaisPage extends StatefulWidget {
  const _InformacoesPessoaisPage();

  @override
  State<_InformacoesPessoaisPage> createState() =>
      _InformacoesPessoaisPageState();
}

class _InformacoesPessoaisPageState extends State<_InformacoesPessoaisPage> {
  @override
  Widget build(BuildContext context) {
    return AppModuleScaffold(
      header: ModuleScreenHeader(
        title: 'Informações pessoais',
        subtitle: 'Gerencie seus dados de identificação',
        onBack: () => Navigator.pop(context),
      ),
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ProfileSectionCard(
                icon: Icons.person_rounded,
                title: 'Sobre você',
                description: 'Informações básicas do seu perfil',
                children: [
                  ProfileFieldRow(
                    label: 'Nome completo',
                    value: authProvider.user?.fullName ?? 'Não informado',
                    trailingIcon: Icons.edit_rounded,
                    onTap: () => _editField(
                        context, 'full_name', authProvider.user?.fullName),
                  ),
                  ProfileFieldRow(
                    label: 'Sexo',
                    value: authProvider.user?.gender ?? 'Não informado',
                    onTap: () => _showGenderDialog(context),
                  ),
                  ProfileFieldRow(
                    label: 'Estado civil',
                    value: authProvider.user?.maritalStatus ?? 'Não informado',
                    onTap: () => _showMaritalStatusDialog(context),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.defaultGap),
              ProfileSectionCard(
                icon: Icons.calendar_month_rounded,
                title: 'Nascimento',
                description: 'Dados sobre seu nascimento',
                children: [
                  ProfileFieldRow(
                    label: 'Data de nascimento',
                    value: authProvider.user?.birthDate ?? 'Não informado',
                    trailingIcon: Icons.calendar_today_outlined,
                    onTap: () => _showDatePicker(context),
                  ),
                  const ProfileFieldRow(
                    label: 'País de nascimento',
                    value: 'Brasil',
                  ),
                  ProfileFieldRow(
                    label: 'UF de nascimento',
                    value: authProvider.user?.birthState ?? 'Não informado',
                    onTap: () => _showStateDropdown(context),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.defaultGap),
              ProfileSectionCard(
                icon: Icons.location_on_rounded,
                title: 'Endereço',
                description: 'Seu endereço atual',
                children: [
                  ProfileFieldRow(
                    label: 'Endereço',
                    value: authProvider.user?.birthCity ?? 'Não informado',
                    onTap: () => _editField(
                        context, 'birth_city', authProvider.user?.birthCity),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  void _editField(BuildContext context, String fieldKey, String? currentValue) {
    final label = _getFieldLabel(fieldKey);
    _showEditSheet(
      context,
      title: label,
      label: label,
      hint: 'Digite aqui',
      initialValue: currentValue ?? '',
      onSave: (value) => _saveField(context, fieldKey, value),
    );
  }

  void _showGenderDialog(BuildContext context) {
    _showChoiceDialog(
      context,
      title: 'Sexo',
      body: (dialogContext) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final gender in [
            'Masculino',
            'Feminino',
            'Outro',
            'Prefiro não informar',
          ])
            _choiceTile(gender, () {
              _saveField(context, 'gender', gender);
              Navigator.pop(dialogContext);
            }),
        ],
      ),
    );
  }

  void _saveField(BuildContext context, String fieldKey, String value) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final apiService = ApiService();
    apiService
        .put(
      '/auth/profile',
      {fieldKey: value.isEmpty ? null : value},
      token: authProvider.authToken,
    )
        .then((response) {
      if (response['success'] && context.mounted) {
        authProvider.updateUserFromResponse(response['user']);
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) setState(() {});
        });
        AppFeedbackSnackBar.success(context, 'Dados salvos com sucesso!');
      }
    }).catchError((e) {
      if (context.mounted) {
        AppFeedbackSnackBar.error(context, 'Erro ao salvar: $e');
      }
    });
  }

  String _getFieldLabel(String fieldKey) {
    const labels = {
      'full_name': 'Nome civil completo',
      'birth_date': 'Data de nascimento',
      'birth_country': 'País de nascimento',
      'birth_state': 'UF de nascimento',
      'birth_city': 'Cidade de nascimento',
      'nationality': 'Nacionalidade',
      'gender': 'Sexo',
    };
    return labels[fieldKey] ?? fieldKey;
  }

  void _showDatePicker(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    showDatePicker(
      context: context,
      initialDate: authProvider.user?.birthDate != null
          ? DateTime.parse(authProvider.user!.birthDate!)
          : DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (_, child) => Theme(data: AppTheme.light, child: child!),
    ).then((picked) {
      if (picked != null && context.mounted) {
        final age = DateTime.now().year - picked.year;
        if (age < 18) {
          AppFeedbackSnackBar.error(
              context, 'Você deve ter pelo menos 18 anos');
          return;
        }
        _saveField(context, 'birth_date', picked.toString().split(' ')[0]);
      }
    });
  }

  void _showStateDropdown(BuildContext context) {
    _showChoiceDialog(
      context,
      title: 'UF de nascimento',
      body: (dialogContext) => SizedBox(
        height: 280,
        child: ListView.builder(
          itemCount: brazilianStates.length,
          itemBuilder: (context, index) {
            return _choiceTile(brazilianStates[index], () {
              _saveField(context, 'birth_state', brazilianStates[index]);
              Navigator.pop(dialogContext);
            });
          },
        ),
      ),
    );
  }

  void _showMaritalStatusDialog(BuildContext context) {
    _showChoiceDialog(
      context,
      title: 'Estado Civil',
      body: (dialogContext) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final status in [
            'Solteiro',
            'Casado',
            'Divorciado',
            'Viúvo',
            'União Estável',
          ])
            _choiceTile(status, () {
              _saveMaritalStatus(context, status);
              Navigator.pop(dialogContext);
            }),
        ],
      ),
    );
  }

  void _saveMaritalStatus(BuildContext context, String status) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final apiService = ApiService();
    apiService
        .put(
      '/auth/profile',
      {'marital_status': status},
      token: authProvider.authToken,
    )
        .then((response) {
      if (response['success'] && context.mounted) {
        authProvider.updateUserFromResponse(response['user']);
        AppFeedbackSnackBar.success(context, 'Estado civil atualizado!');
      }
    }).catchError((e) {
      if (context.mounted) {
        AppFeedbackSnackBar.error(context, 'Erro ao salvar: $e');
      }
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Contatos de emergência
// ─────────────────────────────────────────────────────────────────────────────

class _ContatoEmergenciaPage extends StatefulWidget {
  const _ContatoEmergenciaPage();

  @override
  State<_ContatoEmergenciaPage> createState() => _ContatoEmergenciaPageState();
}

class _ContatoEmergenciaPageState extends State<_ContatoEmergenciaPage> {
  late bool _naoTenho1;
  late bool _naoTenho2;
  late bool _naoTenho3;
  late bool _showContact3;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    _naoTenho1 = auth.user?.emergencyContact1Name == null;
    _naoTenho2 = auth.user?.emergencyContact2Name == null;
    _naoTenho3 = auth.user?.emergencyContact3Name == null;
    _showContact3 = !_naoTenho3;
  }

  @override
  Widget build(BuildContext context) {
    return AppModuleScaffold(
      header: ModuleScreenHeader(
        title: 'Contatos de Emergência',
        subtitle: 'Pessoas de confiança para situações importantes',
        onBack: () => Navigator.pop(context),
      ),
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _contactGroup(
                context,
                authProvider,
                number: 1,
                title: 'Primeiro contato',
                hint: '(preferencial, ex.: Mãe)',
                name: authProvider.user?.emergencyContact1Name,
                phone: authProvider.user?.emergencyContact1Phone,
                naoTenho: _naoTenho1,
                onToggle: (v) {
                  setState(() => _naoTenho1 = v ?? false);
                  if (_naoTenho1) {
                    _saveContact(context, 1, 'name', '');
                    _saveContact(context, 1, 'phone', '');
                  }
                },
              ),
              const SizedBox(height: AppSpacing.defaultGap),
              _contactGroup(
                context,
                authProvider,
                number: 2,
                title: 'Segundo contato',
                hint: '(preferencial, ex.: Pai)',
                name: authProvider.user?.emergencyContact2Name,
                phone: authProvider.user?.emergencyContact2Phone,
                naoTenho: _naoTenho2,
                onToggle: (v) {
                  setState(() => _naoTenho2 = v ?? false);
                  if (_naoTenho2) {
                    _saveContact(context, 2, 'name', '');
                    _saveContact(context, 2, 'phone', '');
                  }
                },
              ),
              const SizedBox(height: AppSpacing.defaultGap),
              if (_showContact3)
                _contactGroup(
                  context,
                  authProvider,
                  number: 3,
                  title: 'Terceiro contato',
                  name: authProvider.user?.emergencyContact3Name,
                  phone: authProvider.user?.emergencyContact3Phone,
                  naoTenho: _naoTenho3,
                  onToggle: (v) {
                    setState(() => _naoTenho3 = v ?? false);
                    if (_naoTenho3) {
                      _saveContact(context, 3, 'name', '');
                      _saveContact(context, 3, 'phone', '');
                    }
                  },
                )
              else
                OutlinedButton.icon(
                  onPressed: () => setState(() => _showContact3 = true),
                  icon: const Icon(Icons.add_rounded, size: AppSizes.iconMd),
                  label: const Text('Adicionar terceiro contato'),
                ),
              const SizedBox(height: AppSpacing.defaultGap),
              const ProfileInfoCard(
                title: 'Você pode adicionar até 3 contatos',
                message: 'Mantenha seus contatos de emergência sempre '
                    'atualizados.',
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _contactGroup(
    BuildContext context,
    AuthProvider authProvider, {
    required int number,
    required String title,
    String? hint,
    required String? name,
    required String? phone,
    required bool naoTenho,
    required ValueChanged<bool?> onToggle,
  }) {
    return ContactGroupCard(
      title: title,
      hint: hint,
      name: name ?? 'Não informado',
      phone: phone ?? 'Não informado',
      noContact: naoTenho,
      onToggleNoContact: onToggle,
      onEditName: naoTenho ? null : () => _editContact(context, number, 'name'),
      onEditPhone:
          naoTenho ? null : () => _editContact(context, number, 'phone'),
    );
  }

  void _editContact(BuildContext context, int contactNumber, String fieldType) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentValue = fieldType == 'name'
        ? (contactNumber == 1
            ? authProvider.user?.emergencyContact1Name
            : contactNumber == 2
                ? authProvider.user?.emergencyContact2Name
                : authProvider.user?.emergencyContact3Name)
        : (contactNumber == 1
            ? authProvider.user?.emergencyContact1Phone
            : contactNumber == 2
                ? authProvider.user?.emergencyContact2Phone
                : authProvider.user?.emergencyContact3Phone);

    final fieldLabel = fieldType == 'name' ? 'Nome' : 'Telefone';

    _showEditSheet(
      context,
      title: 'Contato $contactNumber — $fieldLabel',
      label: fieldLabel,
      hint: fieldType == 'name' ? 'Digite o nome' : 'Digite o telefone',
      initialValue: currentValue ?? '',
      keyboardType:
          fieldType == 'phone' ? TextInputType.phone : TextInputType.text,
      onSave: (value) => _saveContact(context, contactNumber, fieldType, value),
    );
  }

  void _saveContact(
      BuildContext context, int contactNumber, String fieldType, String value) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final fieldKey = fieldType == 'name'
        ? (contactNumber == 1
            ? 'emergency_contact_1_name'
            : contactNumber == 2
                ? 'emergency_contact_2_name'
                : 'emergency_contact_3_name')
        : (contactNumber == 1
            ? 'emergency_contact_1_phone'
            : contactNumber == 2
                ? 'emergency_contact_2_phone'
                : 'emergency_contact_3_phone');

    final apiService = ApiService();
    apiService
        .put(
      '/auth/profile',
      {fieldKey: value.isEmpty ? null : value},
      token: authProvider.authToken,
    )
        .then((response) {
      if (response['success'] && context.mounted) {
        authProvider.updateUserFromResponse(response['user']);
        AppFeedbackSnackBar.success(
            context, 'Contato de emergência atualizado!');
      }
    }).catchError((e) {
      if (context.mounted) {
        AppFeedbackSnackBar.error(context, 'Erro ao salvar: $e');
      }
    });
  }
}
