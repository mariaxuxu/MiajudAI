import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../config/constants.dart';
import '../providers/auth_provider.dart';
import '../providers/installment_provider.dart';
import '../providers/fixed_cost_provider.dart';
import '../models/installment_model.dart';
import '../models/fixed_cost_model.dart';
import '../widgets/common/custom_button.dart';

class InvoiceDashboardScreen extends StatefulWidget {
  const InvoiceDashboardScreen({super.key});

  @override
  State<InvoiceDashboardScreen> createState() => _InvoiceDashboardScreenState();
}

class _InvoiceDashboardScreenState extends State<InvoiceDashboardScreen> with TickerProviderStateMixin {
  late DateTime _selectedDate;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.authToken != null) {
        context.read<InstallmentProvider>().loadInstallments(auth.authToken!);
        context.read<FixedCostProvider>().loadFixedCosts(auth.authToken!);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _previousMonth() {
    setState(() => _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1));
  }

  void _nextMonth() {
    setState(() => _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + 1));
  }

  Widget _buildAccountsTab(InstallmentProvider instProvider, FixedCostProvider fixedProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimens.paddingDefault),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Parcelas', _getActiveInstallmentsForMonth(instProvider, _selectedDate).length),
          const SizedBox(height: 12),
          ..._getActiveInstallmentsForMonth(instProvider, _selectedDate).isEmpty
              ? [_buildEmptyState('Nenhuma parcela cadastrada')]
              : _getActiveInstallmentsForMonth(instProvider, _selectedDate).map((inst) => _buildInstallmentCard(context, inst)),
          const SizedBox(height: 24),
          _buildSectionHeader('Gastos Fixos', _getFixedCostsForMonth(fixedProvider, _selectedDate).length),
          const SizedBox(height: 12),
          if (_getFixedCostsForMonth(fixedProvider, _selectedDate).isEmpty)
            _buildEmptyState('Nenhum gasto fixo cadastrado')
          else
            ..._getFixedCostsForMonth(fixedProvider, _selectedDate).map((cost) => _buildFixedCostCard(context, cost)),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildDashboardTab(InstallmentProvider instProvider, FixedCostProvider fixedProvider) {
    final installmentTotal = instProvider.getMonthlyTotal(_selectedDate);
    final fixedCostTotal = fixedProvider.getMonthlyTotal(_selectedDate);
    final totalMonth = installmentTotal + fixedCostTotal;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimens.paddingDefault),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppDimens.radiusCard),
                    boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 24),
                      const SizedBox(height: 12),
                      const Text('Parcelas', style: TextStyle(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 4),
                      Text('R\$ ${installmentTotal.toStringAsFixed(2).replaceAll('.', ',')}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(AppDimens.radiusCard),
                    boxShadow: [BoxShadow(color: AppColors.accent.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.calendar_month, color: Colors.white, size: 24),
                      const SizedBox(height: 12),
                      const Text('Fixos', style: TextStyle(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 4),
                      Text('R\$ ${fixedCostTotal.toStringAsFixed(2).replaceAll('.', ',')}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.grey[800]!, Colors.grey[900]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppDimens.radiusCard),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.trending_up, color: Colors.white, size: 24),
                const SizedBox(height: 12),
                const Text('Total do Mês', style: TextStyle(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text('R\$ ${totalMonth.toStringAsFixed(2).replaceAll('.', ',')}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white)),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const Text('Pagamentos por Tipo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: -0.3, color: AppColors.textDark)),
          const SizedBox(height: 20),
          ..._buildPaymentMethodStats(instProvider),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  List<Widget> _buildPaymentMethodStats(InstallmentProvider provider) {
    final methods = <String, double>{};
    for (final inst in _getActiveInstallmentsForMonth(provider, _selectedDate)) {
      methods.update(inst.paymentMethod, (v) => v + inst.installmentValue, ifAbsent: () => inst.installmentValue);
    }
    if (methods.isEmpty) return [_buildEmptyState('Sem dados de parcelas')];
    return methods.entries.map((e) {
      final total = methods.values.reduce((a, b) => a + b);
      final percent = ((e.value / total) * 100).toStringAsFixed(1);
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            Expanded(child: Text(_getPaymentMethodLabel(e.key))),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: e.value / total,
                  minHeight: 8,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation(e.key == 'credit_card' ? AppColors.primary : AppColors.accent),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text('$percent%', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
          ],
        ),
      );
    }).toList();
  }

  void _showAddBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimens.radiusHeroCard)),
      ),
      builder: (sheetContext) => SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(sheetContext).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: AppColors.inputBorder, borderRadius: BorderRadius.circular(AppDimens.radiusFull)),
            )),
            const SizedBox(height: 20),
            const Text('Adicionar', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textDark, letterSpacing: -0.3)),
            const SizedBox(height: 20),
            CustomButton(
              text: 'Parcela',
              onPressed: () {
                Navigator.pop(sheetContext);
                _showInstallmentBottomSheet(context);
              },
            ),
            const SizedBox(height: 12),
            CustomButton(
              text: 'Gasto Fixo',
              variant: ButtonVariant.outlined,
              onPressed: () {
                Navigator.pop(sheetContext);
                _showFixedCostBottomSheet(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showInstallmentBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimens.radiusHeroCard)),
      ),
      builder: (sheetContext) => _InstallmentForm(selectedDate: _selectedDate),
    );
  }

  void _showFixedCostBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimens.radiusHeroCard)),
      ),
      builder: (sheetContext) => const _FixedCostForm(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Dashboard / Fatura', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: -0.3)),
      ),
      body: Consumer2<InstallmentProvider, FixedCostProvider>(
        builder: (context, installmentProvider, fixedCostProvider, _) {
          final installmentTotal = installmentProvider.getMonthlyTotal(_selectedDate);
          final fixedCostTotal = fixedCostProvider.getMonthlyTotal(_selectedDate);
          final totalMonth = installmentTotal + fixedCostTotal;

          return Column(
            children: [
              _buildHeroCard(totalMonth, installmentTotal, fixedCostTotal),
              Container(
                color: Colors.white,
                child: TabBar(
                  controller: _tabController,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.textLabel,
                  indicatorColor: AppColors.primary,
                  tabs: const [
                    Tab(text: 'Contas'),
                    Tab(text: 'Dashboard'),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildAccountsTab(installmentProvider, fixedCostProvider),
                    _buildDashboardTab(installmentProvider, fixedCostProvider),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.accent,
        child: const Icon(Icons.add),
        onPressed: () => _showAddBottomSheet(context),
      ),
    );
  }

  Widget _buildHeroCard(double totalMonth, double installmentTotal, double fixedCostTotal) {
    final monthName = DateFormat('MMMM', 'pt_BR').format(_selectedDate);
    final year = _selectedDate.year;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
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
              Text('Compromissos do Mês', style: TextStyle(color: Colors.white.withValues(alpha: 0.80), fontSize: 13, fontWeight: FontWeight.w500)),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.chevron_left, color: Colors.white.withValues(alpha: 0.7)),
                    onPressed: _previousMonth,
                    iconSize: 20,
                    padding: EdgeInsets.zero,
                  ),
                  Text('${monthName.capitalize()} $year', style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12, fontWeight: FontWeight.w500)),
                  IconButton(
                    icon: Icon(Icons.chevron_right, color: Colors.white.withValues(alpha: 0.7)),
                    onPressed: _nextMonth,
                    iconSize: 20,
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text('R\$ ${totalMonth.toStringAsFixed(2).replaceAll('.', ',')}', style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: -0.5)),
          const SizedBox(height: 4),
          Text('Parcelas: R\$ ${installmentTotal.toStringAsFixed(2).replaceAll('.', ',')}  •  Fixos: R\$ ${fixedCostTotal.toStringAsFixed(2).replaceAll('.', ',')}', style: TextStyle(color: Colors.white.withValues(alpha: 0.60), fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildInstallmentCard(BuildContext context, InstallmentModel inst) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.09), borderRadius: BorderRadius.circular(AppDimens.radiusMedium)),
            child: Icon(Icons.shopping_bag_outlined, color: AppColors.primary, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(inst.merchantName ?? inst.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textDark, letterSpacing: -0.1)),
                    ),
                    Text(_formatDateShort(inst.startDate), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textLabel)),
                  ],
                ),
                const SizedBox(height: 3),
                Text('${inst.getPaidInstallmentsForDate(_selectedDate)} de ${inst.totalInstallments} parcelas • vence dia ${inst.dueDayOfMonth}', style: const TextStyle(fontSize: 13, color: AppColors.textLabel)),
                const SizedBox(height: 4),
                Text(_getPaymentMethodLabel(inst.paymentMethod), style: const TextStyle(fontSize: 11, color: AppColors.textLabel, fontStyle: FontStyle.italic)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('R\$ ${inst.installmentValue.toStringAsFixed(2).replaceAll('.', ',')}', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.primary, letterSpacing: -0.2)),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: () => _deleteInstallment(context, inst.id),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(AppDimens.radiusFull)),
                  child: const Text('Remover', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.error)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFixedCostCard(BuildContext context, FixedCostModel cost) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(color: AppColors.accent.withValues(alpha: 0.09), borderRadius: BorderRadius.circular(AppDimens.radiusMedium)),
            child: Icon(_getCategoryIcon(cost.category), color: AppColors.accent, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(cost.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textDark, letterSpacing: -0.1)),
                const SizedBox(height: 3),
                Text('${_getCategoryLabel(cost.category)} • todo dia ${cost.dueDayOfMonth}', style: const TextStyle(fontSize: 13, color: AppColors.textLabel)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('R\$ ${cost.amount.toStringAsFixed(2).replaceAll('.', ',')}', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.accent, letterSpacing: -0.2)),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: () => _deleteFixedCost(context, cost.id),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(AppDimens.radiusFull)),
                  child: const Text('Remover', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.error)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Row(
      children: [
        Container(width: 4, height: 18, decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(AppDimens.radiusFull))),
        const SizedBox(width: 10),
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark, letterSpacing: -0.2)),
        if (count > 0) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(color: AppColors.accent.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(AppDimens.radiusFull)),
            child: Text('$count', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.accent)),
          ),
        ],
      ],
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Text(message, style: const TextStyle(fontSize: 14, color: AppColors.textLabel)),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    return switch (category) {
      'streaming' => Icons.play_circle_outline,
      'rent' => Icons.home_outlined,
      'utility' => Icons.lightbulb_outline,
      'subscription' => Icons.card_membership,
      'insurance' => Icons.security_outlined,
      _ => Icons.category_outlined,
    };
  }

  void _deleteInstallment(BuildContext context, int id) {
    final auth = context.read<AuthProvider>();
    if (auth.authToken == null) return;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remover Parcela?'),
        content: const Text('Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancelar')),
          TextButton(
            onPressed: () async {
              await context.read<InstallmentProvider>().removeInstallment(auth.authToken!, id);
              if (dialogContext.mounted) Navigator.pop(dialogContext);
            },
            child: const Text('Remover', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _deleteFixedCost(BuildContext context, int id) {
    final auth = context.read<AuthProvider>();
    if (auth.authToken == null) return;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remover Gasto Fixo?'),
        content: const Text('Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancelar')),
          TextButton(
            onPressed: () async {
              await context.read<FixedCostProvider>().removeFixedCost(auth.authToken!, id);
              if (dialogContext.mounted) Navigator.pop(dialogContext);
            },
            child: const Text('Remover', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  List<InstallmentModel> _getActiveInstallmentsForMonth(InstallmentProvider provider, DateTime month) {
    return provider.installments.where((inst) {
      if (!inst.isActive) return false;
      final startDate = inst.startDate;
      final monthsDiff = (month.year - startDate.year) * 12 + (month.month - startDate.month);
      return monthsDiff >= 0 && monthsDiff < inst.totalInstallments;
    }).toList();
  }

  List<FixedCostModel> _getFixedCostsForMonth(FixedCostProvider provider, DateTime month) {
    return provider.getFixedCostsForMonth(month);
  }

  String _formatDateShort(DateTime date) {
    final months = ['jan', 'fev', 'mar', 'abr', 'mai', 'jun', 'jul', 'ago', 'set', 'out', 'nov', 'dez'];
    return '${date.day} ${months[date.month - 1]}';
  }

  String _getPaymentMethodLabel(String method) {
    const labels = {
      'credit_card': '💳 Crédito',
      'debit_card': '🏧 Débito',
      'pix': '📱 PIX',
      'cash': '💵 Dinheiro',
      'transfer': '🏦 Transferência',
      'other': '📋 Outro',
    };
    return labels[method] ?? method;
  }

  String _getCategoryLabel(String category) {
    const labels = {
      'streaming': 'Streaming',
      'rent': 'Aluguel',
      'utility': 'Utilidade',
      'subscription': 'Assinatura',
      'insurance': 'Seguro',
      'other': 'Outro',
    };
    return labels[category] ?? category;
  }
}

class _InstallmentForm extends StatefulWidget {
  final DateTime selectedDate;

  const _InstallmentForm({required this.selectedDate});

  @override
  State<_InstallmentForm> createState() => _InstallmentFormState();
}

class _InstallmentFormState extends State<_InstallmentForm> {
  final _nameController = TextEditingController();
  final _merchantController = TextEditingController();
  final _totalAmountController = TextEditingController();
  final _installmentsController = TextEditingController();
  final _dayController = TextEditingController();
  late DateTime _startDate;
  String _paymentMethod = 'credit_card';

  @override
  void initState() {
    super.initState();
    _startDate = widget.selectedDate;
    _dayController.text = '10';
  }

  @override
  @override
  void dispose() {
    _merchantController.dispose();
    _nameController.dispose();
    _totalAmountController.dispose();
    _installmentsController.dispose();
    _dayController.dispose();
    super.dispose();
  }

  void _selectDate() async {
    final picked = await showDatePicker(context: context, initialDate: _startDate, firstDate: DateTime(2000), lastDate: DateTime(2100));
    if (picked != null) setState(() => _startDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.inputBorder, borderRadius: BorderRadius.circular(AppDimens.radiusFull)))),
          const SizedBox(height: 20),
          const Text('Nova Parcela', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textDark, letterSpacing: -0.3)),
          const SizedBox(height: 20),
          TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Nome da Compra', hintText: 'Ex: iPhone 15 Pro')),
          const SizedBox(height: 16),
          TextField(controller: _merchantController, decoration: const InputDecoration(labelText: 'Loja/Empresa', hintText: 'Ex: Apple Store')),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _paymentMethod,
            decoration: const InputDecoration(labelText: 'Meio de Pagamento'),
            items: const [
              DropdownMenuItem(value: 'credit_card', child: Text('💳 Cartão de Crédito')),
              DropdownMenuItem(value: 'debit_card', child: Text('🏧 Cartão de Débito')),
              DropdownMenuItem(value: 'pix', child: Text('📱 PIX')),
              DropdownMenuItem(value: 'cash', child: Text('💵 Dinheiro')),
              DropdownMenuItem(value: 'transfer', child: Text('🏦 Transferência')),
              DropdownMenuItem(value: 'other', child: Text('📋 Outro')),
            ],
            onChanged: (value) => setState(() => _paymentMethod = value ?? 'credit_card'),
          ),
          const SizedBox(height: 16),
          TextField(controller: _totalAmountController, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Valor Total', hintText: 'Ex: 2400.00')),
          const SizedBox(height: 16),
          TextField(controller: _installmentsController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Parcelas', hintText: 'Ex: 12')),
          const SizedBox(height: 16),
          TextField(controller: _dayController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Dia de Vencimento', hintText: 'Ex: 10')),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _selectDate,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.inputBorder))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Data de Início', style: TextStyle(fontSize: 14, color: AppColors.textLabel)),
                  Text(DateFormat('dd/MM/yyyy').format(_startDate), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textDark)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: 'Adicionar',
            onPressed: () {
              final auth = context.read<AuthProvider>();
              if (auth.authToken != null && _nameController.text.isNotEmpty && _totalAmountController.text.isNotEmpty && _installmentsController.text.isNotEmpty && _dayController.text.isNotEmpty) {
                context.read<InstallmentProvider>().addInstallment(
                  auth.authToken!,
                  name: _nameController.text,
                  totalAmount: double.parse(_totalAmountController.text),
                  totalInstallments: int.parse(_installmentsController.text),
                  dueDayOfMonth: int.parse(_dayController.text),
                  startDate: _startDate,
                  paymentMethod: _paymentMethod,
                  merchantName: _merchantController.text.isNotEmpty ? _merchantController.text : null,
                );
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }
}

class _FixedCostForm extends StatefulWidget {
  const _FixedCostForm();

  @override
  State<_FixedCostForm> createState() => _FixedCostFormState();
}

class _FixedCostFormState extends State<_FixedCostForm> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _dayController = TextEditingController();
  String _selectedCategory = 'other';

  @override
  void initState() {
    super.initState();
    _dayController.text = '15';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _dayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.inputBorder, borderRadius: BorderRadius.circular(AppDimens.radiusFull)))),
          const SizedBox(height: 20),
          const Text('Novo Gasto Fixo', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textDark, letterSpacing: -0.3)),
          const SizedBox(height: 20),
          TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Nome', hintText: 'Ex: Netflix')),
          const SizedBox(height: 16),
          TextField(controller: _amountController, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Valor', hintText: 'Ex: 55.90')),
          const SizedBox(height: 16),
          TextField(controller: _dayController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Dia de Vencimento', hintText: 'Ex: 15')),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedCategory,
            decoration: const InputDecoration(labelText: 'Categoria'),
            items: const [
              DropdownMenuItem(value: 'streaming', child: Text('🎬 Streaming')),
              DropdownMenuItem(value: 'rent', child: Text('🏠 Aluguel')),
              DropdownMenuItem(value: 'utility', child: Text('⚡ Utilidade')),
              DropdownMenuItem(value: 'subscription', child: Text('📜 Assinatura')),
              DropdownMenuItem(value: 'insurance', child: Text('🛡️ Seguro')),
              DropdownMenuItem(value: 'other', child: Text('📋 Outro')),
            ],
            onChanged: (v) => setState(() => _selectedCategory = v ?? 'other'),
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: 'Adicionar',
            onPressed: () {
              final auth = context.read<AuthProvider>();
              if (auth.authToken != null && _nameController.text.isNotEmpty && _amountController.text.isNotEmpty && _dayController.text.isNotEmpty) {
                try {
                  final amount = double.parse(_amountController.text.replaceAll(',', '.'));
                  context.read<FixedCostProvider>().addFixedCost(
                    auth.authToken!,
                    name: _nameController.text,
                    amount: amount,
                    dueDayOfMonth: int.parse(_dayController.text),
                    category: _selectedCategory,
                  );
                  Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Valor inválido')),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }
}

extension StringExt on String {
  String capitalize() => '${this[0].toUpperCase()}${substring(1)}';
}
