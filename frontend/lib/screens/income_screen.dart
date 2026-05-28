import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../config/constants.dart';
import '../providers/auth_provider.dart';
import '../providers/income_provider.dart';
import '../providers/account_provider.dart';
import '../models/income_model.dart';
import '../widgets/common/custom_button.dart';
import '../widgets/dialogs/delete_confirm_dialog.dart';
import '../utils/app_snackbar.dart';

class IncomeScreen extends StatefulWidget {
  const IncomeScreen({super.key});

  @override
  State<IncomeScreen> createState() => _IncomeScreenState();
}

class _IncomeScreenState extends State<IncomeScreen> {
  late DateTime _selectedMonth;

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime.now();
    WidgetsBinding.instance.addPostFrameCallback((_) => _reload());
  }

  void _reload() {
    final auth = context.read<AuthProvider>();
    if (auth.authToken != null) {
      context.read<IncomeProvider>().loadIncome(
        auth.authToken!,
        month: _selectedMonth.month,
        year: _selectedMonth.year,
      );
    }
  }

  void _previousMonth() {
    setState(() {
      _selectedMonth =
          DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    });
    _reload();
  }

  void _nextMonth() {
    setState(() {
      _selectedMonth =
          DateTime(_selectedMonth.year, _selectedMonth.month + 1);
    });
    _reload();
  }

  static InputDecoration _inputDecoration(String label, {String? hint, String? prefix}) =>
      InputDecoration(
        labelText: label,
        hintText: hint,
        prefixText: prefix,
        labelStyle:
            const TextStyle(color: AppColors.textLabel, fontSize: 14),
      );

  void _showAddIncomeBottomSheet() {
    final descCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    String selectedType = 'salary';
    DateTime selectedDate = _selectedMonth;
    int? selectedAccountId;
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
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (innerContext, sheetSetState) {
            return SingleChildScrollView(
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
                  const Text(
                    'Nova Receita',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: amountCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    style: const TextStyle(
                        color: AppColors.textDark, fontSize: 15),
                    decoration: _inputDecoration(
                      'Valor',
                      hint: '0,00',
                      prefix: 'R\$ ',
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: descCtrl,
                    style: const TextStyle(
                        color: AppColors.textDark, fontSize: 15),
                    decoration: _inputDecoration(
                      'Descrição',
                      hint: 'Ex: Salário mensal',
                    ),
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    value: selectedType,
                    onChanged: (v) =>
                        sheetSetState(() => selectedType = v!),
                    decoration: _inputDecoration('Tipo de receita'),
                    style: const TextStyle(
                        color: AppColors.textDark, fontSize: 15),
                    items: const [
                      DropdownMenuItem(
                          value: 'salary', child: Text('Salário')),
                      DropdownMenuItem(
                          value: 'freelance',
                          child: Text('Freelance')),
                      DropdownMenuItem(
                          value: 'investment',
                          child: Text('Investimento')),
                      DropdownMenuItem(
                          value: 'gift', child: Text('Presente')),
                      DropdownMenuItem(
                          value: 'other', child: Text('Outro')),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Consumer<AccountProvider>(
                    builder: (context, accountProvider, _) {
                      return DropdownButtonFormField<int?>(
                        value: selectedAccountId,
                        onChanged: (v) =>
                            sheetSetState(() => selectedAccountId = v),
                        decoration: _inputDecoration('Conta (opcional)'),
                        style: const TextStyle(
                            color: AppColors.textDark, fontSize: 15),
                        items: [
                          const DropdownMenuItem(
                              value: null,
                              child: Text('Nenhuma conta')),
                          ...accountProvider.accounts.map(
                            (a) => DropdownMenuItem(
                              value: a.id,
                              child: Text(
                                  '${a.name} (R\$ ${a.balance.toStringAsFixed(2)})'),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 14),
                  GestureDetector(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: innerContext,
                        initialDate: selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2050),
                      );
                      if (date != null) {
                        sheetSetState(() => selectedDate = date);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.inputFill,
                        border:
                            Border.all(color: AppColors.inputBorder),
                        borderRadius: BorderRadius.circular(
                            AppDimens.radiusInput),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_outlined,
                            color: AppColors.textLabel,
                            size: 18,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            DateFormat('dd/MM/yyyy')
                                .format(selectedDate),
                            style: const TextStyle(
                              color: AppColors.textDark,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    text: 'Adicionar receita',
                    onPressed: () {
                      final amountStr = amountCtrl.text.trim();
                      final description = descCtrl.text.trim();
                      if (amountStr.isEmpty || description.isEmpty) {
                        AppSnackBar.error(sheetContext,
                            'Preencha valor e descrição');
                        return;
                      }
                      try {
                        final amount =
                            double.parse(amountStr.replaceAll(',', '.'));
                        final auth = outerContext.read<AuthProvider>();
                        final income =
                            outerContext.read<IncomeProvider>();
                        final accounts =
                            outerContext.read<AccountProvider>();
                        if (auth.authToken != null) {
                          income
                              .addIncome(
                            auth.authToken!,
                            amount,
                            description,
                            selectedType,
                            selectedDate,
                            selectedAccountId,
                            false,
                            null,
                          )
                              .then((_) {
                            if (!outerContext.mounted) return;
                            AppSnackBar.success(
                                outerContext, 'Receita adicionada!');
                            if (!sheetContext.mounted) return;
                            Navigator.pop(sheetContext);
                            // Navegar para /accounts para ver saldo atualizado
                            if (!outerContext.mounted) return;
                            Navigator.pushReplacementNamed(
                                outerContext, '/accounts');
                          });
                        }
                      } catch (_) {
                        AppSnackBar.error(sheetContext, 'Valor inválido');
                      }
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showEditIncomeBottomSheet(IncomeModel income) {
    final descCtrl =
        TextEditingController(text: income.description);
    final amountCtrl =
        TextEditingController(text: income.amount.toString());
    String selectedType = income.type;
    DateTime selectedDate = income.incomeDate;
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
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (innerContext, sheetSetState) {
            return SingleChildScrollView(
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
                  const Text(
                    'Editar Receita',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: amountCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    style: const TextStyle(
                        color: AppColors.textDark, fontSize: 15),
                    decoration: _inputDecoration(
                      'Valor',
                      hint: '0,00',
                      prefix: 'R\$ ',
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: descCtrl,
                    style: const TextStyle(
                        color: AppColors.textDark, fontSize: 15),
                    decoration: _inputDecoration('Descrição'),
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    value: selectedType,
                    onChanged: (v) =>
                        sheetSetState(() => selectedType = v!),
                    decoration: _inputDecoration('Tipo'),
                    style: const TextStyle(
                        color: AppColors.textDark, fontSize: 15),
                    items: const [
                      DropdownMenuItem(
                          value: 'salary', child: Text('Salário')),
                      DropdownMenuItem(
                          value: 'freelance',
                          child: Text('Freelance')),
                      DropdownMenuItem(
                          value: 'investment',
                          child: Text('Investimento')),
                      DropdownMenuItem(
                          value: 'gift', child: Text('Presente')),
                      DropdownMenuItem(
                          value: 'other', child: Text('Outro')),
                    ],
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    text: 'Salvar alterações',
                    onPressed: () {
                      final amountStr = amountCtrl.text.trim();
                      final description = descCtrl.text.trim();
                      if (amountStr.isEmpty || description.isEmpty) {
                        AppSnackBar.error(
                            sheetContext, 'Preencha todos os campos');
                        return;
                      }
                      try {
                        final amount =
                            double.parse(amountStr.replaceAll(',', '.'));
                        final auth = outerContext.read<AuthProvider>();
                        final incomeProvider =
                            outerContext.read<IncomeProvider>();
                        if (auth.authToken != null) {
                          incomeProvider
                              .updateIncome(
                            auth.authToken!,
                            income.id,
                            amount,
                            description,
                            selectedType,
                            selectedDate,
                          )
                              .then((_) {
                            if (!sheetContext.mounted) return;
                            Navigator.pop(sheetContext);
                            if (!outerContext.mounted) return;
                            AppSnackBar.success(
                                outerContext, 'Receita atualizada!');
                          });
                        }
                      } catch (_) {
                        AppSnackBar.error(sheetContext, 'Valor inválido');
                      }
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 20, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Receitas',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.trending_down_rounded,
                color: Colors.white, size: 22),
            onPressed: () =>
                Navigator.pushNamed(context, '/expenses'),
            tooltip: 'Despesas',
          ),
        ],
      ),
      body: Consumer<IncomeProvider>(
        builder: (context, incomeProvider, _) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(AppDimens.paddingDefault),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSummaryCard(incomeProvider),
                const SizedBox(height: 24),
                _buildSectionHeader(
                    'Registros', incomeProvider.income.length),
                const SizedBox(height: 12),
                if (incomeProvider.income.isEmpty)
                  _buildEmptyState()
                else
                  ...incomeProvider.income
                      .map((inc) => _buildIncomeCard(inc)),
                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddIncomeBottomSheet,
        backgroundColor: AppColors.success,
        elevation: 2,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSummaryCard(IncomeProvider incomeProvider) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.success, Color(0xFF16A34A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
        boxShadow: [
          BoxShadow(
            color: AppColors.success.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total do mês',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.80),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: _previousMonth,
                    child: Icon(
                      Icons.chevron_left_rounded,
                      color: Colors.white.withValues(alpha: 0.80),
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat("MMM 'de' y", 'pt_BR')
                        .format(_selectedMonth),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.90),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: _nextMonth,
                    child: Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.white.withValues(alpha: 0.80),
                      size: 26,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'R\$ ${incomeProvider.monthlyTotal.toStringAsFixed(2).replaceAll('.', ',')}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: AppColors.success,
            borderRadius: BorderRadius.circular(AppDimens.radiusFull),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
            letterSpacing: -0.2,
          ),
        ),
        if (count > 0) ...[
          const SizedBox(width: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppDimens.radiusFull),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.success,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildIncomeCard(IncomeModel inc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.09),
              borderRadius:
                  BorderRadius.circular(AppDimens.radiusMedium),
            ),
            child: Icon(
              _getIncomeIcon(inc.type),
              color: AppColors.success,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  inc.description,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                    letterSpacing: -0.1,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  DateFormat('dd/MM/yyyy').format(inc.incomeDate),
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textLabel,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'R\$ ${inc.amount.toStringAsFixed(2).replaceAll('.', ',')}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.success,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => _showEditIncomeBottomSheet(inc),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color:
                            AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(
                            AppDimens.radiusFull),
                      ),
                      child: const Text(
                        'Editar',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () => DeleteConfirmDialog.show(
                      context,
                      title: 'Deletar receita?',
                      message:
                          'Tem certeza que deseja deletar "${inc.description}"?',
                      onConfirm: () {
                        final auth = context.read<AuthProvider>();
                        if (auth.authToken != null) {
                          context
                              .read<IncomeProvider>()
                              .removeIncome(auth.authToken!, inc.id);
                        }
                        AppSnackBar.error(context, 'Receita deletada');
                      },
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(
                            AppDimens.radiusFull),
                      ),
                      child: const Text(
                        'Remover',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.trending_up_outlined,
              size: 40, color: AppColors.textSecondary),
          const SizedBox(height: 10),
          const Text(
            'Nenhuma receita registrada',
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Adicione suas fontes de renda para acompanhar seu progresso',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textLabel,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIncomeIcon(String type) {
    switch (type) {
      case 'salary':
        return Icons.payments_outlined;
      case 'freelance':
        return Icons.work_outline_rounded;
      case 'investment':
        return Icons.trending_up_rounded;
      case 'gift':
        return Icons.card_giftcard_outlined;
      default:
        return Icons.monetization_on_outlined;
    }
  }
}
