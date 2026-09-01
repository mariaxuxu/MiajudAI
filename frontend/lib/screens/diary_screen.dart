import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../config/constants.dart';
import '../models/diary_entry_model.dart';
import '../providers/auth_provider.dart';
import '../providers/diary_provider.dart';
import '../utils/app_snackbar.dart';
import '../widgets/common/custom_button.dart';
import '../widgets/common/custom_textfield.dart';

class DiaryScreen extends StatefulWidget {
  const DiaryScreen({Key? key}) : super(key: key);

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final TextEditingController _textController = TextEditingController();
  String _selectedMood = 'neutral';
  Set<String> _selectedTags = {};
  bool _showForm = false;

  static const _allowedMoods = ['happy', 'sad', 'neutral'];
  static const _allowedTags = ['finance', 'food', 'domestic', 'calendar'];

  static const _moodEmoji = {'happy': '😊', 'sad': '😢', 'neutral': '😐'};
  static const _tagLabels = {
    'finance': 'Finanças',
    'food': 'Alimentação',
    'domestic': 'Casa',
    'calendar': 'Agenda',
  };

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadMonth(_focusedDay));
  }

  void _loadMonth(DateTime month) {
    final auth = context.read<AuthProvider>();
    if (auth.authToken == null) return;
    context.read<DiaryProvider>().loadEntriesForMonth(month, auth.authToken!);
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
      _showForm = false;
      _resetForm();
    });
  }

  void _onPageChanged(DateTime focusedDay) {
    _focusedDay = focusedDay;
    _loadMonth(focusedDay);
  }

  void _resetForm() {
    _textController.clear();
    _selectedMood = 'neutral';
    _selectedTags.clear();
  }

  Future<void> _saveDiary() async {
    if (_textController.text.trim().isEmpty) {
      AppSnackBar.error(context, 'Escreva algo no diário antes de salvar');
      return;
    }

    final diaryProvider = context.read<DiaryProvider>();
    final auth = context.read<AuthProvider>();

    if (auth.authToken == null) {
      AppSnackBar.error(context, 'Não autenticado');
      return;
    }

    try {
      await diaryProvider.saveDiary(
        _textController.text.trim(),
        _selectedMood,
        _selectedTags.toList(),
        auth.authToken!,
        date: _selectedDay,
      );

      if (mounted) {
        AppSnackBar.success(context, 'Entrada salva!');
        setState(() => _showForm = false);
        _resetForm();
      }
    } catch (e) {
      if (mounted) AppSnackBar.error(context, 'Erro ao salvar: $e');
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Meu Diário'),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<DiaryProvider>(
        builder: (context, diary, _) {
          final dayEntries = _selectedDay != null ? diary.entriesForDay(_selectedDay!) : <DiaryEntry>[];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimens.paddingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCalendar(diary),
                const SizedBox(height: AppDimens.paddingLarge),
                if (_selectedDay != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      _formatDate(_selectedDay!),
                      style: AppTextStyles.titleSmall,
                    ),
                  ),
                const SizedBox(height: AppDimens.paddingMedium),
                if (_showForm)
                  _buildWriteForm(diary)
                else if (dayEntries.isNotEmpty)
                  _buildEntriesView(dayEntries)
                else
                  _buildEmptyDayView(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCalendar(DiaryProvider diary) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: TableCalendar(
        firstDay: DateTime.utc(2024),
        lastDay: DateTime.utc(2027),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: _onDaySelected,
        onPageChanged: _onPageChanged,
        eventLoader: (day) => diary.entriesForDay(day),
        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(
            color: AppColors.accent.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          selectedDecoration: BoxDecoration(
            color: AppColors.accent,
            shape: BoxShape.circle,
          ),
          weekendTextStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
          markerDecoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          markerSize: 6,
          markersMaxCount: 1,
        ),
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: AppTextStyles.titleSmall,
          leftChevronIcon: Icon(Icons.chevron_left, color: AppColors.primary),
          rightChevronIcon: Icon(Icons.chevron_right, color: AppColors.primary),
        ),
        locale: 'pt_BR',
      ),
    );
  }

  Widget _buildWriteForm(DiaryProvider diary) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.all(AppDimens.paddingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextField(
            label: 'Como foi seu dia?',
            hint: 'Escreva aqui seus pensamentos...',
            controller: _textController,
            maxLines: 6,
            isRequired: true,
          ),
          const SizedBox(height: AppDimens.paddingLarge),
          Text(
            'Como você está se sentindo?',
            style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          ),
          const SizedBox(height: AppDimens.paddingSmall),
          Row(
            children: _allowedMoods.map((mood) {
              final isSelected = _selectedMood == mood;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedMood = mood),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: AppDimens.paddingMedium),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.accent : AppColors.textSecondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppDimens.radiusButton),
                    ),
                    child: Column(
                      children: [
                        Text(_moodEmoji[mood]!, style: const TextStyle(fontSize: 24)),
                        const SizedBox(height: 4),
                        Text(
                          _moodLabel(mood),
                          style: TextStyle(
                            fontSize: 11,
                            color: isSelected ? Colors.white : AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppDimens.paddingLarge),
          Text(
            'Categorias (opcional)',
            style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          ),
          const SizedBox(height: AppDimens.paddingSmall),
          Wrap(
            spacing: AppDimens.paddingSmall,
            runSpacing: 4,
            children: _allowedTags.map((tag) {
              final isSelected = _selectedTags.contains(tag);
              return FilterChip(
                label: Text(_tagLabels[tag] ?? tag),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedTags.add(tag);
                    } else {
                      _selectedTags.remove(tag);
                    }
                  });
                },
                backgroundColor: Colors.transparent,
                selectedColor: AppColors.accent.withOpacity(0.2),
                checkmarkColor: AppColors.accent,
                labelStyle: TextStyle(
                  color: isSelected ? AppColors.accent : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimens.radiusButton),
                  side: BorderSide(color: isSelected ? AppColors.accent : AppColors.inputBorder),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppDimens.paddingLarge),
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'Cancelar',
                  onPressed: () => setState(() { _showForm = false; _resetForm(); }),
                  variant: ButtonVariant.outlined,
                ),
              ),
              const SizedBox(width: AppDimens.paddingMedium),
              Expanded(
                child: CustomButton(
                  text: 'Salvar',
                  onPressed: diary.isLoading ? null : _saveDiary,
                  variant: ButtonVariant.primary,
                  isLoading: diary.isLoading,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEntriesView(List<DiaryEntry> entries) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...entries.map((entry) => _buildEntryCard(entry)),
        const SizedBox(height: AppDimens.paddingMedium),
        CustomButton(
          text: 'Adicionar outra entrada',
          onPressed: () => setState(() { _showForm = true; _resetForm(); }),
          variant: ButtonVariant.outlined,
        ),
      ],
    );
  }

  Widget _buildEntryCard(DiaryEntry entry) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimens.paddingMedium),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.all(AppDimens.paddingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(_moodEmoji[entry.mood] ?? '😐', style: const TextStyle(fontSize: 28)),
              const SizedBox(width: AppDimens.paddingSmall),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _moodLabel(entry.mood),
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.w700,
                      color: _moodColor(entry.mood),
                    ),
                  ),
                  Text(
                    _formatTime(entry.createdAt),
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppDimens.paddingMedium),
          Text(
            entry.text,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textPrimary, height: 1.5),
          ),
          if (entry.tags.isNotEmpty) ...[
            const SizedBox(height: AppDimens.paddingMedium),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: entry.tags.map((tag) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _tagLabels[tag] ?? tag,
                  style: TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600),
                ),
              )).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyDayView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppDimens.paddingXLarge),
        child: Column(
          children: [
            Icon(Icons.edit_note_rounded, size: 48, color: AppColors.textSecondary.withOpacity(0.4)),
            const SizedBox(height: AppDimens.paddingMedium),
            Text(
              'Nenhuma entrada para este dia',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppDimens.paddingLarge),
            CustomButton(
              text: 'Escrever entrada',
              onPressed: () => setState(() { _showForm = true; _resetForm(); }),
              variant: ButtonVariant.primary,
            ),
          ],
        ),
      ),
    );
  }

  Color _moodColor(String mood) {
    switch (mood) {
      case 'happy': return const Color(0xFF4CAF50);
      case 'sad': return const Color(0xFF2196F3);
      default: return AppColors.textSecondary;
    }
  }

  String _moodLabel(String mood) {
    switch (mood) {
      case 'happy': return 'Feliz';
      case 'sad': return 'Triste';
      default: return 'Neutro';
    }
  }

  String _formatDate(DateTime date) {
    const days = ['Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado', 'Domingo'];
    const months = ['jan', 'fev', 'mar', 'abr', 'mai', 'jun', 'jul', 'ago', 'set', 'out', 'nov', 'dez'];
    return '${days[date.weekday - 1]}, ${date.day} de ${months[date.month - 1]} de ${date.year}';
  }

  String _formatTime(DateTime date) {
    final h = date.hour.toString().padLeft(2, '0');
    final m = date.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
