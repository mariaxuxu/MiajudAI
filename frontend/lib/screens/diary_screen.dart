import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../config/constants.dart';
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

  final List<String> _allowedMoods = ['happy', 'sad', 'neutral'];
  final List<String> _allowedTags = ['finance', 'food', 'domestic', 'calendar'];

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
      _showForm = true;
      _resetForm();
    });
  }

  void _resetForm() {
    _textController.clear();
    _selectedMood = 'neutral';
    _selectedTags.clear();
  }

  Future<void> _saveDiary() async {
    if (_textController.text.trim().isEmpty) {
      AppSnackBar.error(context, 'Please write something in your diary');
      return;
    }

    final diaryProvider = context.read<DiaryProvider>();
    final authProvider = context.read<AuthProvider>();

    if (authProvider.authToken == null) {
      AppSnackBar.error(context, 'Not authenticated');
      return;
    }

    try {
      await diaryProvider.saveDiary(
        _textController.text.trim(),
        _selectedMood,
        _selectedTags.toList(),
        authProvider.authToken!,
      );

      AppSnackBar.success(context, '✅ Diary entry saved to database!');
      _resetForm();
      setState(() => _showForm = false);
    } catch (error) {
      AppSnackBar.error(context, 'Error saving diary: $error');
    }
  }

  void _cancelEdit() {
    _resetForm();
    setState(() => _showForm = false);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Diary'),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: Consumer<DiaryProvider>(
        builder: (context, diaryProvider, _) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(AppDimens.paddingLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Calendar
                  _buildCalendar(diaryProvider),
                  const SizedBox(height: AppDimens.paddingLarge),

                  // Selected day info
                  if (_selectedDay != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppDimens.paddingMedium),
                      child: Text(
                        _formatDate(_selectedDay!),
                        style: AppTextStyles.titleSmall,
                      ),
                    ),
                  const SizedBox(height: AppDimens.paddingMedium),

                  // Form or show entry
                  if (_showForm)
                    _buildForm(diaryProvider)
                  else
                    _buildEntryView(diaryProvider),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCalendar(DiaryProvider diaryProvider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TableCalendar(
        firstDay: DateTime.utc(2024),
        lastDay: DateTime.utc(2026),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: _onDaySelected,
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
        },
        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(
            color: AppColors.accent.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          selectedDecoration: BoxDecoration(
            color: AppColors.accent,
            shape: BoxShape.circle,
          ),
          weekendTextStyle:
              AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
        ),
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: AppTextStyles.bodyLarge,
          leftChevronIcon: Icon(
            Icons.chevron_left,
            color: AppColors.primary,
          ),
          rightChevronIcon: Icon(
            Icons.chevron_right,
            color: AppColors.primary,
          ),
        ),
        locale: 'pt_BR',
      ),
    );
  }

  Widget _buildForm(DiaryProvider diaryProvider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppDimens.paddingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Text input
          CustomTextField(
            label: 'Your thoughts',
            hint: 'What\'s on your mind?',
            controller: _textController,
            maxLines: 6,
            required: true,
          ),
          const SizedBox(height: AppDimens.paddingLarge),

          // Mood selector
          Text(
            'How are you feeling?',
            style: AppTextStyles.bodySmall
                .copyWith(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          ),
          const SizedBox(height: AppDimens.paddingSmall),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _allowedMoods.map((mood) {
              final isSelected = _selectedMood == mood;
              final moodEmoji = {
                'happy': '😊',
                'sad': '😢',
                'neutral': '😐',
              }[mood];

              return GestureDetector(
                onTap: () => setState(() => _selectedMood = mood),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.paddingLarge,
                    vertical: AppDimens.paddingMedium,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.accent : AppColors.textSecondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppDimens.radiusButton),
                  ),
                  child: Column(
                    children: [
                      Text(moodEmoji!, style: const TextStyle(fontSize: 24)),
                      const SizedBox(height: 4),
                      Text(
                        mood.capitalize(),
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected
                              ? Colors.white
                              : AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppDimens.paddingLarge),

          // Tag selector
          Text(
            'Categories (optional)',
            style: AppTextStyles.bodySmall
                .copyWith(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          ),
          const SizedBox(height: AppDimens.paddingSmall),
          Wrap(
            spacing: AppDimens.paddingSmall,
            children: _allowedTags.map((tag) {
              final isSelected = _selectedTags.contains(tag);
              return FilterChip(
                label: Text(tag.capitalize()),
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
                selectedColor: AppColors.accent.withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppDimens.radiusButton),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppDimens.paddingLarge),

          // Buttons
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  label: 'Cancel',
                  onPressed: _cancelEdit,
                  variant: ButtonVariant.outlined,
                ),
              ),
              const SizedBox(width: AppDimens.paddingMedium),
              Expanded(
                child: CustomButton(
                  label: 'Save',
                  onPressed: diaryProvider.isLoading ? null : _saveDiary,
                  variant: ButtonVariant.primary,
                  isLoading: diaryProvider.isLoading,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEntryView(DiaryProvider diaryProvider) {
    if (_selectedDay == null) return const SizedBox();

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppDimens.paddingXLarge),
        child: Column(
          children: [
            Text(
              'Start by writing your first diary entry',
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppDimens.paddingMedium),
            CustomButton(
              label: 'Write entry',
              onPressed: () => setState(() => _showForm = true),
              variant: ButtonVariant.primary,
            ),
          ],
        ),
      ),
    );
  }

  Color _moodColor(String mood) {
    switch (mood) {
      case 'happy':
        return const Color(0xFF4CAF50);
      case 'sad':
        return const Color(0xFF2196F3);
      case 'neutral':
        return AppColors.textSecondary;
      default:
        return AppColors.textSecondary;
    }
  }

  String _formatDate(DateTime date) {
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final months = ['January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'];

    return '${days[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

extension StringCapitalize on String {
  String capitalize() => '${this[0].toUpperCase()}${substring(1)}';
}
