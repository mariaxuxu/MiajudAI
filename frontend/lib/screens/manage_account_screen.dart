import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/constants.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../widgets/common/custom_button.dart';
import '../utils/app_snackbar.dart';

final List<String> brazilianStates = [
  'AC', 'AL', 'AP', 'AM', 'BA', 'CE', 'DF', 'ES', 'GO', 'MA',
  'MT', 'MS', 'MG', 'PA', 'PB', 'PR', 'PE', 'PI', 'RJ', 'RN',
  'RS', 'RO', 'RR', 'SC', 'SP', 'SE', 'TO',
];

// ─────────────────────────────────────────────────────────────────────────────
// Tela principal — hub de seções
// ─────────────────────────────────────────────────────────────────────────────

class ManageAccountScreen extends StatelessWidget {
  const ManageAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 20, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Meu Perfil',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
            letterSpacing: -0.3,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(AppDimens.paddingDefault),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              _ProfileSectionCard(
                icon: Icons.person_outline_rounded,
                title: 'Informações pessoais',
                subtitle: 'Nome, sexo e data de nascimento',
                color: AppColors.primary,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const _InformacoesPessoaisPage(),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _ProfileSectionCard(
                icon: Icons.favorite_border_rounded,
                title: 'Estado civil',
                subtitle: 'Estado civil e informações de cônjuge',
                color: const Color(0xFF7C3AED),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const _EstadoCivilPage(),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _ProfileSectionCard(
                icon: Icons.phone_outlined,
                title: 'Contatos de Emergência',
                subtitle: 'Nomes e telefones de contato',
                color: AppColors.error,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const _ContatoEmergenciaPage(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Card de seção — estilo FeatureCard
// ─────────────────────────────────────────────────────────────────────────────

class _ProfileSectionCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ProfileSectionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  State<_ProfileSectionCard> createState() => _ProfileSectionCardState();
}

class _ProfileSectionCardState extends State<_ProfileSectionCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: _pressed ? const Color(0xFFF8F9FA) : Colors.white,
            borderRadius: BorderRadius.circular(AppDimens.radiusCard),
            boxShadow: [
              BoxShadow(
                color: Colors.black
                    .withValues(alpha: _pressed ? 0.04 : 0.07),
                blurRadius: _pressed ? 8 : 16,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: widget.color.withValues(alpha: 0.09),
                  borderRadius:
                      BorderRadius.circular(AppDimens.radiusMedium),
                ),
                child: Icon(widget.icon,
                    color: widget.color, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                        letterSpacing: -0.1,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      widget.subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textLabel,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: widget.color.withValues(alpha: 0.70),
                size: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AppBar padrão para sub-páginas de perfil
// ─────────────────────────────────────────────────────────────────────────────

PreferredSizeWidget _profileAppBar(BuildContext context, String title) {
  return AppBar(
    backgroundColor: Colors.white,
    elevation: 0,
    surfaceTintColor: Colors.white,
    centerTitle: true,
    leading: IconButton(
      icon: const Icon(Icons.arrow_back_ios_new_rounded,
          size: 20, color: AppColors.textDark),
      onPressed: () => Navigator.pop(context),
    ),
    title: Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.textDark,
        letterSpacing: -0.3,
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Widgets de campo reutilizáveis (info e data)
// ─────────────────────────────────────────────────────────────────────────────

Widget _buildInfoItem(
  String label,
  String value, {
  bool showEdit = false,
  VoidCallback? onEdit,
}) {
  return GestureDetector(
    onTap: showEdit ? onEdit : null,
    child: Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.paddingDefault, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimens.radiusInput),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textLabel,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.textDark,
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
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: AppColors.accent,
                  size: 13,
                ),
              ],
            ),
        ],
      ),
    ),
  );
}

Widget _buildDateItem(
  String label,
  String value, {
  VoidCallback? onEdit,
}) {
  return GestureDetector(
    onTap: onEdit,
    child: Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.paddingDefault, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimens.radiusInput),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textLabel,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.calendar_today_outlined,
            color: AppColors.primary,
            size: 18,
          ),
        ],
      ),
    ),
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

class _InformacoesPessoaisPageState
    extends State<_InformacoesPessoaisPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _profileAppBar(context, 'Informações pessoais'),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(AppDimens.paddingDefault),
          child: Consumer<AuthProvider>(
            builder: (context, authProvider, _) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionLabel('Sobre mim'),
                  const SizedBox(height: 10),
                  _buildInfoItem(
                    'Nome civil completo',
                    authProvider.user?.fullName ?? 'Não informado',
                    showEdit: true,
                    onEdit: () => _editField(context, 'full_name',
                        authProvider.user?.fullName),
                  ),
                  const SizedBox(height: 10),
                  _buildInfoItem(
                    'Sexo',
                    authProvider.user?.gender ?? 'Não informado',
                    showEdit: true,
                    onEdit: () => _showGenderDialog(context),
                  ),
                  const SizedBox(height: 20),
                  _sectionLabel('Nascimento'),
                  const SizedBox(height: 10),
                  _buildDateItem(
                    'Data de nascimento',
                    authProvider.user?.birthDate ?? 'Não informado',
                    onEdit: () => _showDatePicker(context),
                  ),
                  const SizedBox(height: 10),
                  _buildInfoItem(
                    'País de nascimento',
                    'Brasil',
                  ),
                  const SizedBox(height: 10),
                  _buildInfoItem(
                    'UF de nascimento',
                    authProvider.user?.birthState ?? 'Não informado',
                    showEdit: true,
                    onEdit: () => _showStateDropdown(context),
                  ),
                  const SizedBox(height: 10),
                  _buildInfoItem(
                    'Endereço',
                    authProvider.user?.birthCity ?? 'Não informado',
                    showEdit: true,
                    onEdit: () => _editField(context, 'birth_city',
                        authProvider.user?.birthCity),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textLabel,
        letterSpacing: 0.4,
      ),
    );
  }

  void _editField(BuildContext context, String fieldKey,
      String? currentValue) {
    final controller =
        TextEditingController(text: currentValue ?? '');
    final outerContext = context;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimens.radiusHeroCard),
        ),
      ),
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.fromLTRB(
          24, 16, 24,
          MediaQuery.of(sheetContext).viewInsets.bottom + 24,
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
                  color: AppColors.inputBorder,
                  borderRadius:
                      BorderRadius.circular(AppDimens.radiusFull),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _getFieldLabel(fieldKey),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              autofocus: true,
              style: const TextStyle(
                  color: AppColors.textDark, fontSize: 15),
              decoration: const InputDecoration(
                hintText: 'Digite aqui',
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Cancelar',
                    variant: ButtonVariant.outlined,
                    onPressed: () => Navigator.pop(sheetContext),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomButton(
                    text: 'Salvar',
                    onPressed: () {
                      _saveField(outerContext, fieldKey,
                          controller.text);
                      Navigator.pop(sheetContext);
                    },
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
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusXLarge),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Sexo',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 12),
              ...['Masculino', 'Feminino', 'Outro',
                      'Prefiro não informar']
                  .map(
                (gender) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(gender,
                      style: const TextStyle(
                          color: AppColors.textDark, fontSize: 15)),
                  onTap: () {
                    _saveField(context, 'gender', gender);
                    Navigator.pop(dialogContext);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveField(
      BuildContext context, String fieldKey, String value) {
    final authProvider =
        Provider.of<AuthProvider>(context, listen: false);
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
        AppSnackBar.success(context, 'Dados salvos com sucesso!');
      }
    }).catchError((e) {
      if (context.mounted) {
        AppSnackBar.error(context, 'Erro ao salvar: $e');
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
    final authProvider =
        Provider.of<AuthProvider>(context, listen: false);
    showDatePicker(
      context: context,
      initialDate: authProvider.user?.birthDate != null
          ? DateTime.parse(authProvider.user!.birthDate!)
          : DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    ).then((picked) {
      if (picked != null && context.mounted) {
        final age = DateTime.now().year - picked.year;
        if (age < 18) {
          AppSnackBar.error(
              context, 'Você deve ter pelo menos 18 anos');
          return;
        }
        _saveField(context, 'birth_date',
            picked.toString().split(' ')[0]);
      }
    });
  }

  void _showStateDropdown(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusXLarge),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'UF de nascimento',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 280,
                child: ListView.builder(
                  itemCount: brazilianStates.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(brazilianStates[index],
                          style: const TextStyle(
                              color: AppColors.textDark,
                              fontSize: 15)),
                      onTap: () {
                        _saveField(context, 'birth_state',
                            brazilianStates[index]);
                        Navigator.pop(dialogContext);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Estado civil
// ─────────────────────────────────────────────────────────────────────────────

class _EstadoCivilPage extends StatelessWidget {
  const _EstadoCivilPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _profileAppBar(context, 'Estado civil'),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(AppDimens.paddingDefault),
          child: Consumer<AuthProvider>(
            builder: (context, authProvider, _) {
              return _buildInfoItem(
                'Estado civil',
                authProvider.user?.maritalStatus ?? 'Não informado',
                showEdit: true,
                onEdit: () => _showMaritalStatusDialog(context),
              );
            },
          ),
        ),
      ),
    );
  }

  void _showMaritalStatusDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusXLarge),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Estado Civil',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 12),
              ...['Solteiro', 'Casado', 'Divorciado', 'Viúvo',
                      'União Estável']
                  .map(
                (status) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(status,
                      style: const TextStyle(
                          color: AppColors.textDark, fontSize: 15)),
                  onTap: () {
                    _saveMaritalStatus(context, status);
                    Navigator.pop(dialogContext);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveMaritalStatus(BuildContext context, String status) {
    final authProvider =
        Provider.of<AuthProvider>(context, listen: false);
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
        AppSnackBar.success(context, 'Estado civil atualizado!');
      }
    }).catchError((e) {
      if (context.mounted) {
        AppSnackBar.error(context, 'Erro ao salvar: $e');
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
  State<_ContatoEmergenciaPage> createState() =>
      _ContatoEmergenciaPageState();
}

class _ContatoEmergenciaPageState
    extends State<_ContatoEmergenciaPage> {
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _profileAppBar(context, 'Contatos de Emergência'),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(AppDimens.paddingDefault),
          child: Consumer<AuthProvider>(
            builder: (context, authProvider, _) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _contactGroup(
                    context,
                    authProvider,
                    number: 1,
                    label: 'Primeiro contato (preferencial: Mãe)',
                    name: authProvider.user
                        ?.emergencyContact1Name,
                    phone: authProvider.user
                        ?.emergencyContact1Phone,
                    naoTenho: _naoTenho1,
                    onToggle: (v) {
                      setState(() => _naoTenho1 = v ?? false);
                      if (_naoTenho1) {
                        _saveContact(context, 1, 'name', '');
                        _saveContact(context, 1, 'phone', '');
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  _contactGroup(
                    context,
                    authProvider,
                    number: 2,
                    label: 'Segundo contato (preferencial: Pai)',
                    name: authProvider.user
                        ?.emergencyContact2Name,
                    phone: authProvider.user
                        ?.emergencyContact2Phone,
                    naoTenho: _naoTenho2,
                    onToggle: (v) {
                      setState(() => _naoTenho2 = v ?? false);
                      if (_naoTenho2) {
                        _saveContact(context, 2, 'name', '');
                        _saveContact(context, 2, 'phone', '');
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  if (_showContact3)
                    _contactGroup(
                      context,
                      authProvider,
                      number: 3,
                      label: 'Terceiro contato',
                      name: authProvider.user
                          ?.emergencyContact3Name,
                      phone: authProvider.user
                          ?.emergencyContact3Phone,
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
                    CustomButton(
                      text: 'Adicionar terceiro contato',
                      variant: ButtonVariant.outlined,
                      icon: const Icon(Icons.add,
                          color: AppColors.primary, size: 18),
                      onPressed: () =>
                          setState(() => _showContact3 = true),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _contactGroup(
    BuildContext context,
    AuthProvider authProvider, {
    required int number,
    required String label,
    required String? name,
    required String? phone,
    required bool naoTenho,
    required ValueChanged<bool?> onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textLabel,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 10),
        _buildInfoItem(
          'Nome',
          name ?? 'Não informado',
          showEdit: !naoTenho,
          onEdit: () => _editContact(context, number, 'name'),
        ),
        const SizedBox(height: 8),
        _buildInfoItem(
          'Telefone',
          phone ?? 'Não informado',
          showEdit: !naoTenho,
          onEdit: () => _editContact(context, number, 'phone'),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: naoTenho,
                onChanged: onToggle,
                activeColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Não tenho',
              style: TextStyle(
                  color: AppColors.textLabel, fontSize: 13),
            ),
          ],
        ),
      ],
    );
  }

  void _editContact(
      BuildContext context, int contactNumber, String fieldType) {
    final authProvider =
        Provider.of<AuthProvider>(context, listen: false);
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

    final controller =
        TextEditingController(text: currentValue ?? '');
    final fieldLabel =
        fieldType == 'name' ? 'Nome' : 'Telefone';
    final outerContext = context;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimens.radiusHeroCard),
        ),
      ),
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.fromLTRB(
          24, 16, 24,
          MediaQuery.of(sheetContext).viewInsets.bottom + 24,
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
                  color: AppColors.inputBorder,
                  borderRadius:
                      BorderRadius.circular(AppDimens.radiusFull),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Contato $contactNumber — $fieldLabel',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              autofocus: true,
              keyboardType: fieldType == 'phone'
                  ? TextInputType.phone
                  : TextInputType.text,
              style: const TextStyle(
                  color: AppColors.textDark, fontSize: 15),
              decoration: InputDecoration(
                hintText: fieldType == 'name'
                    ? 'Digite o nome'
                    : 'Digite o telefone',
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Cancelar',
                    variant: ButtonVariant.outlined,
                    onPressed: () => Navigator.pop(sheetContext),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomButton(
                    text: 'Salvar',
                    onPressed: () {
                      _saveContact(outerContext, contactNumber,
                          fieldType, controller.text);
                      Navigator.pop(sheetContext);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _saveContact(BuildContext context, int contactNumber,
      String fieldType, String value) {
    final authProvider =
        Provider.of<AuthProvider>(context, listen: false);
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
        AppSnackBar.success(
            context, 'Contato de emergência atualizado!');
      }
    }).catchError((e) {
      if (context.mounted) {
        AppSnackBar.error(context, 'Erro ao salvar: $e');
      }
    });
  }
}
