import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/diary_entry_model.dart';
import '../providers/auth_provider.dart';
import '../providers/diary_provider.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../theme/tokens/app_colors_semantic.dart';
import '../theme/tokens/app_primitives.dart';
import '../widgets/calendar/calendar_card.dart';
import '../widgets/common/app_feedback_snackbar.dart';
import '../widgets/common/app_form_field.dart';
import '../widgets/common/app_module_scaffold.dart';
import '../widgets/common/app_primary_button.dart';
import '../widgets/common/empty_state_card.dart';
import '../widgets/common/module_screen_header.dart';
import '../widgets/common/section_header.dart';
import '../widgets/diary/category_chips.dart';
import '../widgets/diary/diary_empty_art.dart';
import '../widgets/diary/diary_entry_card.dart';
import '../widgets/diary/mood_selector.dart';

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
  static const _tagIcons = {
    'finance': Icons.bar_chart_rounded,
    'food': Icons.restaurant_rounded,
    'domestic': Icons.home_outlined,
    'calendar': Icons.event_outlined,
  };

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _loadMonth(_focusedDay));
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
      AppFeedbackSnackBar.error(
          context, 'Escreva algo no diário antes de salvar');
      return;
    }

    final diaryProvider = context.read<DiaryProvider>();
    final auth = context.read<AuthProvider>();

    if (auth.authToken == null) {
      AppFeedbackSnackBar.error(context, 'Não autenticado');
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
        AppFeedbackSnackBar.success(context, 'Entrada salva!');
        setState(() => _showForm = false);
        _resetForm();
      }
    } catch (e) {
      if (mounted) AppFeedbackSnackBar.error(context, 'Erro ao salvar: $e');
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppModuleScaffold(
      header: ModuleScreenHeader(
        title: 'Meu Diário',
        subtitle: 'Registre seus dias e veja sua evolução',
        onBack: () => Navigator.pop(context),
      ),
      child: Consumer<DiaryProvider>(
        builder: (context, diary, _) {
          final dayEntries = _selectedDay != null
              ? diary.entriesForDay(_selectedDay!)
              : <DiaryEntry>[];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildCalendar(diary),
              const SizedBox(height: AppSpacing.blockGap),
              if (_selectedDay != null)
                SectionHeader(title: _formatDate(_selectedDay!)),
              const SizedBox(height: AppSpacing.itemGap),
              if (_showForm)
                _buildWriteForm(diary)
              else if (dayEntries.isNotEmpty)
                _buildEntriesView(dayEntries)
              else
                _buildEmptyDayView(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCalendar(DiaryProvider diary) {
    return CalendarCard(
      firstDay: DateTime.utc(2024),
      lastDay: DateTime.utc(2027),
      focusedDay: _focusedDay,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      onDaySelected: _onDaySelected,
      onPageChanged: _onPageChanged,
      eventLoader: (day) => diary.entriesForDay(day),
    );
  }

  Widget _buildWriteForm(DiaryProvider diary) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppSemanticColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: AppPrimitives.shadowSm,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppFormField(
              label: 'Como foi seu dia?',
              hint: 'Escreva aqui seus pensamentos...',
              controller: _textController,
              maxLines: 6,
              minLines: 3,
              isRequired: true,
              keyboardType: TextInputType.text,
            ),
            const SizedBox(height: AppSpacing.blockGap),
            _buildFormLabel('Como você está se sentindo?'),
            const SizedBox(height: AppSpacing.itemGap),
            MoodSelector(
              options: [
                for (final mood in _allowedMoods)
                  MoodOption(
                    value: mood,
                    emoji: _moodEmoji[mood]!,
                    label: _moodLabel(mood),
                  ),
              ],
              selected: _selectedMood,
              onChanged: (mood) => setState(() => _selectedMood = mood),
            ),
            const SizedBox(height: AppSpacing.blockGap),
            _buildFormLabel('Categorias (opcional)'),
            const SizedBox(height: AppSpacing.itemGap),
            CategoryChips(
              options: [
                for (final tag in _allowedTags)
                  CategoryOption(
                    value: tag,
                    label: _tagLabels[tag] ?? tag,
                    icon: _tagIcons[tag]!,
                  ),
              ],
              selected: _selectedTags,
              onChanged: (tag, selected) {
                setState(() {
                  if (selected) {
                    _selectedTags.add(tag);
                  } else {
                    _selectedTags.remove(tag);
                  }
                });
              },
            ),
            const SizedBox(height: AppSpacing.blockGap),
            AppPrimaryButton(
              label: 'Salvar registro',
              onPressed: diary.isLoading ? null : _saveDiary,
              isLoading: diary.isLoading,
            ),
            const SizedBox(height: AppSpacing.itemGap),
            OutlinedButton(
              onPressed: () => setState(() {
                _showForm = false;
                _resetForm();
              }),
              child: const Text('Cancelar'),
            ),
          ],
        ),
      ),
    );
  }

  /// Pergunta do formulario (humor, categorias): um titulo de bloco.
  Widget _buildFormLabel(String text) {
    return Semantics(
      header: true,
      child: Text(
        text,
        style: AppTypography.titleMedium.copyWith(
          color: AppSemanticColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildEntriesView(List<DiaryEntry> entries) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ...entries.map((entry) => _buildEntryCard(entry)),
        const SizedBox(height: AppSpacing.labelGap),
        OutlinedButton.icon(
          onPressed: () => setState(() {
            _showForm = true;
            _resetForm();
          }),
          icon: const Icon(Icons.add_rounded, size: AppSizes.iconLg),
          label: const Text('Adicionar outra entrada'),
        ),
      ],
    );
  }

  Widget _buildEntryCard(DiaryEntry entry) {
    return DiaryEntryCard(
      emoji: _moodEmoji[entry.mood] ?? '😐',
      moodLabel: _moodLabel(entry.mood),
      moodColor: _moodColor(entry.mood),
      timeLabel: _formatTime(entry.createdAt),
      text: entry.text,
      tagLabels: [for (final tag in entry.tags) _tagLabels[tag] ?? tag],
    );
  }

  Widget _buildEmptyDayView() {
    return EmptyStateCard(
      art: const DiaryEmptyArt(),
      title: 'Nenhuma entrada para este dia',
      message: 'Registre como foi o seu dia e como você se sentiu.',
      actionLabel: 'Escrever entrada',
      onAction: () => setState(() {
        _showForm = true;
        _resetForm();
      }),
      actionStyle: EmptyStateActionStyle.filled,
    );
  }

  Color _moodColor(String mood) {
    switch (mood) {
      case 'happy':
        return AppSemanticColors.onFeedbackSuccess;
      case 'sad':
        return AppSemanticColors.actionPrimary;
      default:
        return AppSemanticColors.textSecondaryStrong;
    }
  }

  String _moodLabel(String mood) {
    switch (mood) {
      case 'happy':
        return 'Feliz';
      case 'sad':
        return 'Triste';
      default:
        return 'Neutro';
    }
  }

  /// "Segunda-feira, 21 de setembro de 2026". Requer
  /// `initializeDateFormatting('pt_BR')`, feito em `main.dart`.
  String _formatDate(DateTime date) {
    final text = DateFormat("EEEE, d 'de' MMMM 'de' y", 'pt_BR').format(date);
    return text.isEmpty ? text : '${text[0].toUpperCase()}${text.substring(1)}';
  }

  String _formatTime(DateTime date) {
    final h = date.hour.toString().padLeft(2, '0');
    final m = date.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
