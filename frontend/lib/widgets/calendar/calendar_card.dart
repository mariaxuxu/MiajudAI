import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';
import '../../theme/tokens/app_colors_semantic.dart';
import '../../theme/tokens/app_primitives.dart';

/// Card de calendario mensal no visual do Design System: titulo do mes a
/// esquerda, navegacao a direita e a grade de dias abaixo.
///
/// Envolve o `TableCalendar` e so o ESTILIZA. Dia focado, selecao, intervalo
/// navegavel, callbacks e carregador de eventos chegam de fora e sao repassados
/// SEM alteracao: quem usa continua dono do estado (inclusive de decidir se um
/// `onPageChanged` reconstroi a tela ou nao).
///
/// O cabecalho nativo do `TableCalendar` foi trocado pelo titulo do proprio
/// widget para que os botoes de mes fiquem a direita e tenham 48dp e rotulo. Os
/// botoes movem a MESMA `PageController` que os chevrons nativos moveriam, com
/// a mesma duracao e curva, entao `onPageChanged` dispara como antes. O titulo
/// vem do proprio cabecalho do calendario e por isso acompanha qualquer troca
/// de mes (botoes ou gesto de arrastar).
///
/// Os marcadores de evento tem cor unica: um compromisso nao tem tipo.
class CalendarCard extends StatefulWidget {
  const CalendarCard({
    super.key,
    required this.firstDay,
    required this.lastDay,
    required this.focusedDay,
    required this.selectedDayPredicate,
    required this.onDaySelected,
    required this.onPageChanged,
    required this.eventLoader,
  });

  final DateTime firstDay;
  final DateTime lastDay;
  final DateTime focusedDay;
  final bool Function(DateTime day) selectedDayPredicate;
  final void Function(DateTime selectedDay, DateTime focusedDay) onDaySelected;
  final void Function(DateTime focusedDay) onPageChanged;
  final List<dynamic> Function(DateTime day) eventLoader;

  /// Mesmos valores que o `TableCalendar` usa por padrao nos chevrons nativos.
  static const Duration _pageDuration = Duration(milliseconds: 300);
  static const Curve _pageCurve = Curves.easeOut;

  static const String _locale = 'pt_BR';

  /// "Setembro 2026". Requer `initializeDateFormatting('pt_BR')`, feito em
  /// `main.dart`.
  static String monthLabel(DateTime month) =>
      _capitalize(DateFormat('MMMM y', _locale).format(month));

  /// "Dom", "Seg"...: o `intl` devolve "dom." com ponto e em minuscula.
  static String _weekdayLabel(DateTime day, dynamic locale) {
    final text = DateFormat.E(locale).format(day).replaceAll('.', '');
    return _capitalize(text);
  }

  static String _capitalize(String text) =>
      text.isEmpty ? text : '${text[0].toUpperCase()}${text.substring(1)}';

  @override
  State<CalendarCard> createState() => _CalendarCardState();
}

class _CalendarCardState extends State<CalendarCard> {
  PageController? _pageController;

  void _previousMonth() => _pageController?.previousPage(
        duration: CalendarCard._pageDuration,
        curve: CalendarCard._pageCurve,
      );

  void _nextMonth() => _pageController?.nextPage(
        duration: CalendarCard._pageDuration,
        curve: CalendarCard._pageCurve,
      );

  static final BorderRadius _dayRadius =
      BorderRadius.circular(AppRadius.control);

  /// Lado do destaque do dia (selecionado ou hoje): sempre um quadrado, em
  /// qualquer largura. O toque vale a celula inteira (a largura de 1/7 da grade
  /// por 48 de altura), nao so o destaque, e a margem de baixo abriga o marcador
  /// de evento sem encostar no destaque.
  static const double _dayHighlight = 34;

  static EdgeInsets _cellMarginFor(double gridWidth) => EdgeInsets.symmetric(
        horizontal:
            math.max(0, (gridWidth / DateTime.daysPerWeek - _dayHighlight) / 2),
        vertical: (AppSpacing.minTouchTarget - _dayHighlight) / 2,
      );

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppSemanticColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: AppPrimitives.shadowSm,
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.labelGap),
        child: LayoutBuilder(
          builder: (context, constraints) =>
              _buildCalendar(constraints.maxWidth),
        ),
      ),
    );
  }

  Widget _buildCalendar(double width) {
    return TableCalendar<dynamic>(
      locale: CalendarCard._locale,
      firstDay: widget.firstDay,
      lastDay: widget.lastDay,
      focusedDay: widget.focusedDay,
      selectedDayPredicate: widget.selectedDayPredicate,
      onDaySelected: widget.onDaySelected,
      onPageChanged: widget.onPageChanged,
      onCalendarCreated: (controller) => _pageController = controller,
      eventLoader: widget.eventLoader,
      pageAnimationDuration: CalendarCard._pageDuration,
      pageAnimationCurve: CalendarCard._pageCurve,
      rowHeight: AppSpacing.minTouchTarget,
      daysOfWeekHeight: 28,
      calendarBuilders: CalendarBuilders(
        headerTitleBuilder: (context, month) => _CalendarHeader(
          month: month,
          onPrevious: _previousMonth,
          onNext: _nextMonth,
        ),
      ),
      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
        leftChevronVisible: false,
        rightChevronVisible: false,
        headerPadding: EdgeInsets.fromLTRB(
          AppSpacing.cardPadding,
          AppSpacing.cardPadding,
          AppSpacing.cardPadding,
          AppSpacing.labelGap,
        ),
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
        dowTextFormatter: CalendarCard._weekdayLabel,
        weekdayStyle: AppTypography.labelMedium.copyWith(
          color: AppSemanticColors.textSecondary,
        ),
        weekendStyle: AppTypography.labelMedium.copyWith(
          color: AppSemanticColors.textSecondary,
        ),
      ),
      calendarStyle: CalendarStyle(
        cellMargin: _cellMarginFor(width),
        defaultTextStyle: _dayText(AppSemanticColors.textPrimary),
        weekendTextStyle: _dayText(AppSemanticColors.textPrimary),
        // Dias de outros meses continuam tocaveis (levam ao mes); o
        // secundario fica a 4.9:1, mais claro que o texto do mes.
        outsideTextStyle: _dayText(AppSemanticColors.textSecondary),
        todayTextStyle: _dayText(
          AppSemanticColors.actionPrimary,
          weight: FontWeight.w600,
        ),
        selectedTextStyle: _dayText(
          AppSemanticColors.onAction,
          weight: FontWeight.w600,
        ),
        todayDecoration: BoxDecoration(
          color: AppTone.blue.surface,
          borderRadius: _dayRadius,
        ),
        selectedDecoration: BoxDecoration(
          color: AppSemanticColors.actionPrimary,
          borderRadius: _dayRadius,
        ),
        markersMaxCount: 1,
        markerSize: 5,
        // Sem alinhamento automatico o marcador fica colado na base da
        // celula, na margem de baixo do destaque do dia.
        markersAutoAligned: false,
        markerDecoration: const BoxDecoration(
          color: AppSemanticColors.actionPrimary,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  static TextStyle _dayText(Color color, {FontWeight? weight}) =>
      AppTypography.bodyLarge.copyWith(color: color, fontWeight: weight);
}

/// Titulo do mes a esquerda e os botoes de mes a direita.
class _CalendarHeader extends StatelessWidget {
  const _CalendarHeader({
    required this.month,
    required this.onPrevious,
    required this.onNext,
  });

  final DateTime month;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          // Regiao viva: leitores de tela anunciam o novo mes a cada troca.
          child: Semantics(
            liveRegion: true,
            header: true,
            child: Text(
              CalendarCard.monthLabel(month),
              style: AppTypography.headlineMedium.copyWith(
                color: AppSemanticColors.textPrimary,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.labelGap),
        _MonthButton(
          icon: Icons.chevron_left_rounded,
          tooltip: 'Mês anterior',
          onPressed: onPrevious,
        ),
        const SizedBox(width: AppSpacing.labelGap),
        _MonthButton(
          icon: Icons.chevron_right_rounded,
          tooltip: 'Próximo mês',
          onPressed: onNext,
        ),
      ],
    );
  }
}

class _MonthButton extends StatelessWidget {
  const _MonthButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icon),
      style: IconButton.styleFrom(
        fixedSize: const Size.square(AppSpacing.minTouchTarget),
        backgroundColor: AppSemanticColors.actionPrimarySubtle,
        foregroundColor: AppSemanticColors.actionPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.control),
        ),
      ),
    );
  }
}
