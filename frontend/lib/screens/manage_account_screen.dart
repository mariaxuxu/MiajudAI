import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/constants.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';

final List<String> brazilianStates = [
  'AC', 'AL', 'AP', 'AM', 'BA', 'CE', 'DF', 'ES', 'GO', 'MA',
  'MT', 'MS', 'MG', 'PA', 'PB', 'PR', 'PE', 'PI', 'RJ', 'RN',
  'RS', 'RO', 'RR', 'SC', 'SP', 'SE', 'TO',
];


class ManageAccountScreen extends StatefulWidget {
  const ManageAccountScreen({super.key});

  @override
  State<ManageAccountScreen> createState() => _ManageAccountScreenState();
}

class _ManageAccountScreenState extends State<ManageAccountScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B4965),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Gerenciar Conta',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppDimens.paddingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionCard(
                  icon: Icons.assignment,
                  title: 'Informações pessoais',
                  subtitle: 'Nome completo, sexo e nascimento',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const _InformacoesPessoaisPage()),
                  ),
                ),
                const SizedBox(height: AppDimens.paddingMedium),
                _buildSectionCard(
                  icon: Icons.people,
                  title: 'Estado civil',
                  subtitle: 'Estado civil e informações de cônjuge',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const _EstadoCivilPage()),
                  ),
                ),
                const SizedBox(height: AppDimens.paddingMedium),
                _buildSectionCard(
                  icon: Icons.phone,
                  title: 'Contato de Emergência',
                  subtitle: 'Nomes e telefones',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const _ContatoEmergenciaPage()),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDimens.radiusDefault),
          border: Border.all(color: const Color(0xFFE8E8E8)),
        ),
        padding: const EdgeInsets.all(AppDimens.paddingMedium),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: const Color(0xFF1B4965), size: 24),
            ),
            const SizedBox(width: AppDimens.paddingMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: const Color(0xFF1B4965),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Color(0xFFFF8C00), size: 16),
          ],
        ),
      ),
    );
  }
}

class _InformacoesPessoaisPage extends StatefulWidget {
  const _InformacoesPessoaisPage();

  @override
  State<_InformacoesPessoaisPage> createState() => _InformacoesPessoaisPageState();
}

class _InformacoesPessoaisPageState extends State<_InformacoesPessoaisPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1B4965)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Informações pessoais',
          style: AppTextStyles.displaySmall.copyWith(
            color: const Color(0xFF1B4965),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppDimens.paddingMedium),
            child: Consumer<AuthProvider>(
              builder: (context, authProvider, _) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sobre mim',
                      style: AppTextStyles.titleSmall.copyWith(
                        color: const Color(0xFF1B4965),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppDimens.paddingMedium),
                    _buildInfoItem(
                      'Nome civil completo',
                      authProvider.user?.fullName ?? 'Não informado',
                      showEdit: true,
                      onEdit: () => _editField(context, 'full_name', authProvider.user?.fullName),
                    ),
                    const SizedBox(height: AppDimens.paddingMedium),
                    _buildInfoItem(
                      'Sexo',
                      authProvider.user?.gender ?? 'Não informado',
                      showEdit: true,
                      onEdit: () => _showGenderDialog(context),
                    ),
                    const SizedBox(height: AppDimens.paddingMedium),
                    Text(
                      'Nascimento',
                      style: AppTextStyles.titleSmall.copyWith(
                        color: const Color(0xFF1B4965),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildDateItem(
                      'Data de nascimento',
                      authProvider.user?.birthDate ?? 'Não informado',
                      onEdit: () => _showDatePicker(context),
                    ),
                    const SizedBox(height: AppDimens.paddingMedium),
                    _buildInfoItem(
                      'País de nascimento',
                      'Brasil',
                      showEdit: false,
                    ),
                    const SizedBox(height: AppDimens.paddingMedium),
                    _buildInfoItem(
                      'UF de nascimento',
                      authProvider.user?.birthState ?? 'Não informado',
                      showEdit: true,
                      onEdit: () => _showStateDropdown(context),
                    ),
                    const SizedBox(height: AppDimens.paddingMedium),
                    _buildInfoItem(
                      'Endereço',
                      authProvider.user?.birthCity ?? 'Não informado',
                      showEdit: true,
                      onEdit: () => _editField(context, 'birth_city', authProvider.user?.birthCity),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _editField(BuildContext context, String fieldKey, String? currentValue) {
    final controller = TextEditingController(text: currentValue ?? '');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getFieldLabel(fieldKey),
              style: AppTextStyles.titleSmall.copyWith(
                color: const Color(0xFF1B4965),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Digite aqui',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimens.radiusDefault),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                    ),
                    child: Text(
                      'Cancelar',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: const Color(0xFF1B4965),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _saveField(context, fieldKey, controller.text);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF8C00),
                    ),
                    child: const Text(
                      'Salvar',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showGenderDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sexo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildGenderOption(context, 'Masculino'),
            _buildGenderOption(context, 'Feminino'),
            _buildGenderOption(context, 'Outro'),
            _buildGenderOption(context, 'Prefiro não informar'),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderOption(BuildContext context, String gender) {
    return ListTile(
      title: Text(gender),
      onTap: () {
        _saveField(context, 'gender', gender);
        Navigator.pop(context);
      },
    );
  }

  void _saveField(BuildContext context, String fieldKey, String value) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final updatedData = {
      fieldKey: value.isEmpty ? null : value,
    };

    final apiService = ApiService();
    apiService.put(
      '/auth/profile',
      updatedData,
      token: authProvider.authToken,
    ).then((response) {
      if (response['success'] && context.mounted) {
        authProvider.updateUserFromResponse(response['user']);

        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            setState(() {});
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dados salvos com sucesso!')),
        );
      }
    }).catchError((e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar: $e')),
        );
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
          : DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    ).then((picked) {
      if (picked != null && context.mounted) {
        final age = DateTime.now().year - picked.year;
        if (age < 18) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Você deve ter pelo menos 18 anos')),
          );
          return;
        }
        _saveField(context, 'birth_date', picked.toString().split(' ')[0]);
      }
    });
  }

  void _showStateDropdown(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('UF de nascimento'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            itemCount: brazilianStates.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(brazilianStates[index]),
                onTap: () {
                  _saveField(context, 'birth_state', brazilianStates[index]);
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _EstadoCivilPage extends StatelessWidget {
  const _EstadoCivilPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B4965),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Estado civil',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppDimens.paddingMedium),
            child: Consumer<AuthProvider>(
              builder: (context, authProvider, _) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoItem(
                      'Estado civil',
                      authProvider.user?.maritalStatus ?? 'Não informado',
                      showEdit: true,
                      onEdit: () => _showMaritalStatusDialog(context),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _showMaritalStatusDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Estado Civil'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatusOption(context, 'Solteiro'),
            _buildStatusOption(context, 'Casado'),
            _buildStatusOption(context, 'Divorciado'),
            _buildStatusOption(context, 'Viúvo'),
            _buildStatusOption(context, 'União Estável'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusOption(BuildContext context, String status) {
    return ListTile(
      title: Text(status),
      onTap: () {
        _saveMaritalStatus(context, status);
        Navigator.pop(context);
      },
    );
  }

  void _saveMaritalStatus(BuildContext context, String status) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final apiService = ApiService();
    apiService.put(
      '/auth/profile',
      {'marital_status': status},
      token: authProvider.authToken,
    ).then((response) {
      if (response['success'] && context.mounted) {
        authProvider.updateUserFromResponse(response['user']);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Estado civil atualizado!')),
        );
      }
    }).catchError((e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar: $e')),
        );
      }
    });
  }
}

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
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _naoTenho1 = authProvider.user?.emergencyContact1Name == null;
    _naoTenho2 = authProvider.user?.emergencyContact2Name == null;
    _naoTenho3 = authProvider.user?.emergencyContact3Name == null;
    _showContact3 = !_naoTenho3;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B4965),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Contatos de Emergência',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppDimens.paddingMedium),
            child: Consumer<AuthProvider>(
              builder: (context, authProvider, _) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Primeiro contato (preferencial: Mãe)',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildInfoItem(
                      'Nome',
                      authProvider.user?.emergencyContact1Name ?? 'Não informado',
                      showEdit: !_naoTenho1,
                      onEdit: () => _editField(context, 1, 'name'),
                    ),
                    const SizedBox(height: 8),
                    _buildInfoItem(
                      'Telefone',
                      authProvider.user?.emergencyContact1Phone ?? 'Não informado',
                      showEdit: !_naoTenho1,
                      onEdit: () => _editField(context, 1, 'phone'),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Checkbox(
                          value: _naoTenho1,
                          onChanged: (value) {
                            setState(() => _naoTenho1 = value ?? false);
                            if (_naoTenho1) {
                              _saveEmergencyContact(context, 1, 'name', '');
                              _saveEmergencyContact(context, 1, 'phone', '');
                            }
                          },
                        ),
                        Text(
                          'Não tenho',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimens.paddingLarge),
                    Text(
                      'Segundo contato (preferencial: Pai)',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildInfoItem(
                      'Nome',
                      authProvider.user?.emergencyContact2Name ?? 'Não informado',
                      showEdit: !_naoTenho2,
                      onEdit: () => _editField(context, 2, 'name'),
                    ),
                    const SizedBox(height: 8),
                    _buildInfoItem(
                      'Telefone',
                      authProvider.user?.emergencyContact2Phone ?? 'Não informado',
                      showEdit: !_naoTenho2,
                      onEdit: () => _editField(context, 2, 'phone'),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Checkbox(
                          value: _naoTenho2,
                          onChanged: (value) {
                            setState(() => _naoTenho2 = value ?? false);
                            if (_naoTenho2) {
                              _saveEmergencyContact(context, 2, 'name', '');
                              _saveEmergencyContact(context, 2, 'phone', '');
                            }
                          },
                        ),
                        Text(
                          'Não tenho',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimens.paddingLarge),
                    if (_showContact3)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Terceiro contato',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildInfoItem(
                            'Nome',
                            authProvider.user?.emergencyContact3Name ?? 'Não informado',
                            showEdit: !_naoTenho3,
                            onEdit: () => _editField(context, 3, 'name'),
                          ),
                          const SizedBox(height: 8),
                          _buildInfoItem(
                            'Telefone',
                            authProvider.user?.emergencyContact3Phone ?? 'Não informado',
                            showEdit: !_naoTenho3,
                            onEdit: () => _editField(context, 3, 'phone'),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Checkbox(
                                value: _naoTenho3,
                                onChanged: (value) {
                                  setState(() => _naoTenho3 = value ?? false);
                                  if (_naoTenho3) {
                                    _saveEmergencyContact(context, 3, 'name', '');
                                    _saveEmergencyContact(context, 3, 'phone', '');
                                  }
                                },
                              ),
                              Text(
                                'Não tenho',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                    else
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            setState(() => _showContact3 = true);
                          },
                          icon: const Icon(Icons.add, color: Colors.white),
                          label: const Text(
                            'Adicionar contato',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF8C00),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _editField(BuildContext context, int contactNumber, String fieldType) {
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

    final controller = TextEditingController(text: currentValue ?? '');
    final fieldLabel = fieldType == 'name' ? 'Nome' : 'Telefone';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contato $contactNumber - $fieldLabel',
              style: AppTextStyles.titleSmall.copyWith(
                color: const Color(0xFF1B4965),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              autofocus: true,
              keyboardType: fieldType == 'phone' ? TextInputType.phone : TextInputType.text,
              decoration: InputDecoration(
                hintText: fieldType == 'name' ? 'Digite o nome' : 'Digite o telefone',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimens.radiusDefault),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                    ),
                    child: Text(
                      'Cancelar',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: const Color(0xFF1B4965),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _saveEmergencyContact(context, contactNumber, fieldType, controller.text);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF8C00),
                    ),
                    child: const Text(
                      'Salvar',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _saveEmergencyContact(
    BuildContext context,
    int contactNumber,
    String fieldType,
    String value,
  ) {
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

    apiService.put(
      '/auth/profile',
      {fieldKey: value.isEmpty ? null : value},
      token: authProvider.authToken,
    ).then((response) {
      if (response['success'] && context.mounted) {
        authProvider.updateUserFromResponse(response['user']);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contato de emergência atualizado!')),
        );
      }
    }).catchError((e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar: $e')),
        );
      }
    });
  }
}

Widget _buildDateItem(
  String label,
  String value, {
  VoidCallback? onEdit,
}) {
  return MouseRegion(
    cursor: SystemMouseCursors.click,
    child: GestureDetector(
      onTap: onEdit,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDimens.radiusDefault),
          border: Border.all(color: const Color(0xFFE8E8E8)),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.paddingMedium,
          vertical: AppDimens.paddingSmall,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: const Color(0xFF1B4965),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.calendar_today,
              color: Color(0xFF1B4965),
              size: 20,
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildInfoItem(
  String label,
  String value, {
  bool showEdit = false,
  VoidCallback? onEdit,
}) {
  return MouseRegion(
    cursor: showEdit ? SystemMouseCursors.click : MouseCursor.defer,
    child: GestureDetector(
      onTap: showEdit ? onEdit : null,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDimens.radiusDefault),
          border: Border.all(color: const Color(0xFFE8E8E8)),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.paddingMedium,
          vertical: AppDimens.paddingSmall,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: const Color(0xFF1B4965),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (showEdit)
              Row(
                children: [
                  Text(
                    'Editar',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: const Color(0xFFFF8C00),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: Color(0xFFFF8C00),
                    size: 14,
                  ),
                ],
              ),
          ],
        ),
      ),
    ),
  );
}
