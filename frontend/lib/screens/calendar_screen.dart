import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../config/constants.dart';
import '../providers/auth_provider.dart';
import '../providers/event_provider.dart';
import '../widgets/common/custom_button.dart';
import '../widgets/dialogs/delete_confirm_dialog.dart';
import '../utils/app_snackbar.dart';

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
        return Padding(
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
                'Novo Compromisso',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat("d 'de' MMMM 'de' y", 'pt_BR')
                    .format(_selectedDay),
                style: const TextStyle(
                  color: AppColors.textLabel,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: titleController,
                autofocus: true,
                style: const TextStyle(
                    color: AppColors.textDark, fontSize: 15),
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                  hintText: 'Ex: Consulta médica',
                  prefixIcon: Icon(
                    Icons.event_note_outlined,
                    color: AppColors.textLabel,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Salvar compromisso',
                onPressed: () {
                  final title = titleController.text.trim();
                  if (title.isEmpty) {
                    AppSnackBar.error(sheetContext, 'Digite uma descrição');
                    return;
                  }
                  final auth = outerContext.read<AuthProvider>();
                  final events = outerContext.read<EventProvider>();
                  if (auth.authToken != null) {
                    events
                        .addEvent(auth.authToken!, title, _selectedDay)
                        .then((_) => events.loadEvents(auth.authToken!));
                    Navigator.pop(sheetContext);
                    AppSnackBar.success(outerContext, 'Compromisso salvo!');
                  }
                },
              ),
            ],
          ),
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
          'Calendário',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
      ),
      body: Consumer<EventProvider>(
        builder: (context, eventProvider, _) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(AppDimens.paddingDefault),
            child: Column(
              children: [
                _buildCalendarCard(eventProvider),
                const SizedBox(height: 24),
                _buildEventSection(eventProvider),
                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddEventBottomSheet,
        backgroundColor: AppColors.accent,
        elevation: 2,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildCalendarCard(EventProvider eventProvider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppDimens.paddingDefault),
      child: TableCalendar(
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
        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.18),
            shape: BoxShape.circle,
          ),
          selectedDecoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          selectedTextStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
          todayTextStyle: const TextStyle(
            color: AppColors.accent,
            fontWeight: FontWeight.w700,
          ),
          defaultTextStyle: const TextStyle(color: AppColors.textDark),
          weekendTextStyle: const TextStyle(color: AppColors.textDark),
          outsideTextStyle:
              const TextStyle(color: AppColors.textSecondary),
          markersMaxCount: 1,
          markerDecoration: const BoxDecoration(
            color: AppColors.accent,
            shape: BoxShape.circle,
          ),
          markerSize: 5,
        ),
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
            letterSpacing: -0.2,
          ),
          leftChevronIcon: Icon(
            Icons.chevron_left_rounded,
            color: AppColors.primary,
          ),
          rightChevronIcon: Icon(
            Icons.chevron_right_rounded,
            color: AppColors.primary,
          ),
        ),
        daysOfWeekStyle: const DaysOfWeekStyle(
          weekdayStyle: TextStyle(
            color: AppColors.textLabel,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          weekendStyle: TextStyle(
            color: AppColors.textLabel,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
        eventLoader: (day) => eventProvider.eventsForDay(day),
      ),
    );
  }

  Widget _buildEventSection(EventProvider eventProvider) {
    final events = eventProvider.eventsForDay(_selectedDay);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 18,
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius:
                    BorderRadius.circular(AppDimens.radiusFull),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              DateFormat("d 'de' MMMM", 'pt_BR').format(_selectedDay),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
                letterSpacing: -0.2,
              ),
            ),
            if (events.isNotEmpty) ...[
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.12),
                  borderRadius:
                      BorderRadius.circular(AppDimens.radiusFull),
                ),
                child: Text(
                  '${events.length}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accent,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 14),
        if (events.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
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
            child: const Column(
              children: [
                Icon(
                  Icons.event_available_outlined,
                  size: 36,
                  color: AppColors.textSecondary,
                ),
                SizedBox(height: 8),
                Text(
                  'Nenhum compromisso neste dia',
                  style: TextStyle(
                    color: AppColors.textLabel,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          )
        else
          ...events.map((event) {
            final auth = context.read<AuthProvider>();
            final eventProv = context.read<EventProvider>();
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(AppDimens.radiusCard),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: const BorderRadius.only(
                        topLeft:
                            Radius.circular(AppDimens.radiusCard),
                        bottomLeft:
                            Radius.circular(AppDimens.radiusCard),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Padding(
                      padding:
                          const EdgeInsets.symmetric(vertical: 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event.title,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textDark,
                              letterSpacing: -0.1,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            DateFormat("d 'de' MMMM", 'pt_BR')
                                .format(event.eventDate),
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textLabel,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      color:
                          AppColors.error.withValues(alpha: 0.65),
                      size: 20,
                    ),
                    onPressed: () => DeleteConfirmDialog.show(
                      context,
                      title: 'Deletar compromisso?',
                      message:
                          'Tem certeza que deseja remover "${event.title}"?',
                      onConfirm: () {
                        if (auth.authToken != null) {
                          eventProv.removeEvent(
                              auth.authToken!, event.id);
                        }
                        AppSnackBar.error(
                            context, 'Compromisso removido');
                      },
                    ),
                  ),
                  const SizedBox(width: 4),
                ],
              ),
            );
          }),
      ],
    );
  }
}
