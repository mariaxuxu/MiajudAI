import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../config/constants.dart';
import '../providers/auth_provider.dart';
import '../providers/event_provider.dart';

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
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.authToken != null) {
        Provider.of<EventProvider>(context, listen: false)
            .loadEvents(authProvider.authToken!);
      }
    });
  }

  void _showAddEventBottomSheet() {
    final titleController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Novo Compromisso',
                style: AppTextStyles.headlineSmall.copyWith(
                  color: const Color(0xFF1B4965),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '${_selectedDay.day}/${_selectedDay.month}/${_selectedDay.year}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: titleController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Descrição do compromisso',
                  hintStyle: TextStyle(color: AppColors.textHint),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimens.radiusDefault),
                    borderSide: const BorderSide(color: Color(0xFFE8E8E8)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimens.radiusDefault),
                    borderSide: const BorderSide(color: Color(0xFFE8E8E8)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimens.radiusDefault),
                    borderSide: const BorderSide(
                      color: Color(0xFFFF8C00),
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    final title = titleController.text.trim();
                    if (title.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Digite uma descrição'),
                          backgroundColor: Color(0xFF1B4965),
                        ),
                      );
                      return;
                    }

                    final authProvider =
                        Provider.of<AuthProvider>(context, listen: false);
                    final eventProvider =
                        Provider.of<EventProvider>(context, listen: false);

                    if (authProvider.authToken != null) {
                      eventProvider.addEvent(
                        authProvider.authToken!,
                        title,
                        _selectedDay,
                      ).then((_) {
                        eventProvider.loadEvents(authProvider.authToken!);
                      });
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Compromisso salvo!'),
                          backgroundColor: Color(0xFF1B4965),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF8C00),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppDimens.radiusDefault),
                    ),
                  ),
                  child: Text(
                    'Salvar',
                    style: AppTextStyles.titleSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B4965),
        elevation: 0,
        title: const Text(
          'Calendário',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<EventProvider>(
        builder: (context, eventProvider, _) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(AppDimens.paddingMedium),
              child: Column(
                children: [
                  // Calendar Widget
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(AppDimens.radiusLarge),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(AppDimens.paddingMedium),
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
                      onPageChanged: (focusedDay) {
                        _focusedDay = focusedDay;
                      },
                      calendarStyle: CalendarStyle(
                        todayDecoration: BoxDecoration(
                          color: const Color(0xFFFF8C00).withValues(alpha: 0.3),
                          shape: BoxShape.circle,
                        ),
                        selectedDecoration: const BoxDecoration(
                          color: Color(0xFF1B4965),
                          shape: BoxShape.circle,
                        ),
                        selectedTextStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        todayTextStyle: const TextStyle(
                          color: Color(0xFF1B4965),
                          fontWeight: FontWeight.bold,
                        ),
                        defaultTextStyle: const TextStyle(
                          color: Color(0xFF1B4965),
                        ),
                        weekendTextStyle: const TextStyle(
                          color: Color(0xFF1B4965),
                        ),
                        outsideTextStyle: const TextStyle(
                          color: AppColors.textSecondary,
                        ),
                        markersMaxCount: 1,
                        markerDecoration: const BoxDecoration(
                          color: Color(0xFFFF8C00),
                          shape: BoxShape.circle,
                        ),
                      ),
                      headerStyle: HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                        titleTextStyle: AppTextStyles.headlineSmall.copyWith(
                          color: const Color(0xFF1B4965),
                        ),
                        leftChevronIcon: const Icon(
                          Icons.chevron_left,
                          color: Color(0xFF1B4965),
                        ),
                        rightChevronIcon: const Icon(
                          Icons.chevron_right,
                          color: Color(0xFF1B4965),
                        ),
                      ),
                      daysOfWeekStyle: DaysOfWeekStyle(
                        weekdayStyle: const TextStyle(
                          color: Color(0xFF1B4965),
                          fontWeight: FontWeight.bold,
                        ),
                        weekendStyle: const TextStyle(
                          color: Color(0xFF1B4965),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      eventLoader: (day) {
                        return eventProvider.eventsForDay(day);
                      },
                    ),
                  ),
                  const SizedBox(height: AppDimens.paddingLarge),
                  // Events for selected day
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Compromissos de ${_selectedDay.day}/${_selectedDay.month}/${_selectedDay.year}',
                        style: AppTextStyles.titleSmall.copyWith(
                          color: const Color(0xFF1B4965),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ..._buildEventList(eventProvider),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddEventBottomSheet,
        backgroundColor: const Color(0xFFFF8C00),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  List<Widget> _buildEventList(EventProvider eventProvider) {
    final eventsForDay = eventProvider.eventsForDay(_selectedDay);

    if (eventsForDay.isEmpty) {
      return [
        Container(
          padding: const EdgeInsets.all(AppDimens.paddingMedium),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppDimens.radiusLarge),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            'Nenhum compromisso neste dia',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ];
    }

    return eventsForDay.map((event) {
      final authProvider =
          Provider.of<AuthProvider>(context, listen: false);
      final eventProvider =
          Provider.of<EventProvider>(context, listen: false);

      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDimens.radiusLarge),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(AppDimens.paddingMedium),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFFFF8C00),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: AppTextStyles.titleSmall.copyWith(
                      color: const Color(0xFF1B4965),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('dd/MM/yyyy').format(event.eventDate),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline,
                  color: Color(0xFFFF8C00)),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Deletar compromisso?'),
                    content: const Text(
                        'Tem certeza que deseja remover este compromisso?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancelar'),
                      ),
                      TextButton(
                        onPressed: () {
                          if (authProvider.authToken != null) {
                            eventProvider.removeEvent(
                              authProvider.authToken!,
                              event.id,
                            );
                          }
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Compromisso deletado'),
                              backgroundColor: AppColors.error,
                            ),
                          );
                        },
                        child: const Text(
                          'Deletar',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      );
    }).toList();
  }
}
