import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../providers/event_provider.dart';
import '../theme/app_spacing.dart';
import '../theme/tokens/app_colors_semantic.dart';
import '../theme/app_typography.dart';
import '../widgets/calendar/calendar_card.dart';
import '../widgets/calendar/calendar_empty_art.dart';
import '../widgets/calendar/calendar_event_tile.dart';
import '../widgets/common/app_feedback_snackbar.dart';
import '../widgets/common/app_form_field.dart';
import '../widgets/common/app_form_sheet.dart';
import '../widgets/common/app_module_scaffold.dart';
import '../widgets/common/app_primary_button.dart';
import '../widgets/common/empty_state_card.dart';
import '../widgets/common/module_screen_header.dart';
import '../widgets/common/section_header.dart';
import '../widgets/dialogs/app_confirm_dialog.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.authToken != null) {
        context.read<EventProvider>().loadEvents(auth.authToken!);
      }
    });
  }

  void _showAddEventBottomSheet() {
    final titleController = TextEditingController();
    final outerContext = context;

    AppFormSheet.show(
      context: context,
      title: 'Novo Compromisso',
      builder: (sheetContext) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const ExcludeSemantics(
                  child: Icon(
                    Icons.event_rounded,
                    size: AppSizes.iconMd,
                    color: AppSemanticColors.textSecondaryStrong,
                  ),
                ),
                const SizedBox(width: AppSpacing.labelGap),
                Expanded(
                  child: Text(
                    DateFormat("d 'de' MMMM 'de' y", 'pt_BR')
                        .format(_selectedDay),
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppSemanticColors.textSecondaryStrong,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.defaultGap),
            AppFormField(
              controller: titleController,
              label: 'Descrição',
              hint: 'Ex: Consulta médica',
              autofocus: true,
            ),
            const SizedBox(height: AppSpacing.blockGap),
            AppPrimaryButton(
              label: 'Salvar compromisso',
              onPressed: () {
                final title = titleController.text.trim();
                if (title.isEmpty) {
                  AppFeedbackSnackBar.error(
                      sheetContext, 'Digite uma descrição');
                  return;
                }
                final auth = outerContext.read<AuthProvider>();
                final events = outerContext.read<EventProvider>();
                if (auth.authToken != null) {
                  events
                      .addEvent(auth.authToken!, title, _selectedDay)
                      .then((_) => events.loadEvents(auth.authToken!));
                  Navigator.pop(sheetContext);
                  AppFeedbackSnackBar.success(
                      outerContext, 'Compromisso salvo!');
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppModuleScaffold(
      header: ModuleScreenHeader(
        title: 'Calendário',
        subtitle: 'Organize seus compromissos',
        onBack: () => Navigator.pop(context),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddEventBottomSheet,
        tooltip: 'Adicionar compromisso',
        child: const Icon(Icons.add),
      ),
      child: Consumer<EventProvider>(
        builder: (context, eventProvider, _) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildCalendarCard(eventProvider),
              const SizedBox(height: AppSpacing.blockGap),
              _buildEventSection(eventProvider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCalendarCard(EventProvider eventProvider) {
    return CalendarCard(
      firstDay: DateTime.utc(2000),
      lastDay: DateTime.utc(2050),
      focusedDay: _focusedDay,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });
      },
      onPageChanged: (focusedDay) => _focusedDay = focusedDay,
      eventLoader: (day) => eventProvider.eventsForDay(day),
    );
  }

  Widget _buildEventSection(EventProvider eventProvider) {
    final events = eventProvider.eventsForDay(_selectedDay);
    final dayTitle =
        DateFormat("EEEE, d 'de' MMMM", 'pt_BR').format(_selectedDay);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          title: dayTitle.isEmpty
              ? dayTitle
              : '${dayTitle[0].toUpperCase()}${dayTitle.substring(1)}',
          count: events.length,
        ),
        const SizedBox(height: AppSpacing.itemGap),
        if (events.isEmpty)
          EmptyStateCard(
            art: const CalendarEmptyArt(),
            title: 'Seu dia está livre!',
            message:
                'Nenhum compromisso neste dia.\nQue tal aproveitar para planejar algo?',
            actionLabel: 'Adicionar compromisso',
            onAction: _showAddEventBottomSheet,
          )
        else
          ...events.map((event) {
            final auth = context.read<AuthProvider>();
            final eventProv = context.read<EventProvider>();
            return CalendarEventTile(
              title: event.title,
              dateLabel:
                  DateFormat("d 'de' MMMM", 'pt_BR').format(event.eventDate),
              actions: [
                IconButton(
                  tooltip: 'Remover ${event.title}',
                  icon: const Icon(Icons.delete_outline_rounded),
                  color: AppSemanticColors.onFeedbackError,
                  onPressed: () => AppConfirmDialog.show(
                    context,
                    title: 'Deletar compromisso?',
                    message: 'Tem certeza que deseja remover "${event.title}"?',
                    onConfirm: () {
                      if (auth.authToken != null) {
                        eventProv.removeEvent(auth.authToken!, event.id);
                      }
                      AppFeedbackSnackBar.error(
                          context, 'Compromisso removido');
                    },
                  ),
                ),
              ],
            );
          }),
      ],
    );
  }
}
