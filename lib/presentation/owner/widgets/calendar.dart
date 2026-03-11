import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarCard extends StatelessWidget {
  const CalendarCard({
    required this.focusedDay,
    required this.rangeStart,
    required this.rangeEnd,
    required this.onRangeSelected,
    required this.onPageChanged,
  });

  final DateTime focusedDay;
  final DateTime? rangeStart;
  final DateTime? rangeEnd;

  final void Function(DateTime? start, DateTime? end, DateTime focusedDay) onRangeSelected;
  final void Function(DateTime focusedDay) onPageChanged;

  @override
  Widget build(BuildContext context) {
    const border = Color(0xFF2D8CFF);
    const text = Color(0xFF284457);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border, width: 2),
      ),
      child: TableCalendar(
        firstDay: DateTime(2020, 1, 1),
        lastDay: DateTime(2035, 12, 31),
        focusedDay: focusedDay,

        startingDayOfWeek: StartingDayOfWeek.monday,
        daysOfWeekHeight: 28,
        rowHeight: 40,

        rangeSelectionMode: RangeSelectionMode.enforced,
        rangeStartDay: rangeStart,
        rangeEndDay: rangeEnd,
        onRangeSelected: onRangeSelected,
        onPageChanged: onPageChanged,

        headerStyle: HeaderStyle(
          titleCentered: false,
          formatButtonVisible: false,
          leftChevronIcon: const Icon(Icons.chevron_left, color: text),
          rightChevronIcon: const Icon(Icons.chevron_right, color: text),
          titleTextStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: text),
          headerPadding: const EdgeInsets.only(bottom: 8),
        ),

        daysOfWeekStyle: const DaysOfWeekStyle(
          weekdayStyle: TextStyle(color: text, fontWeight: FontWeight.w800),
          weekendStyle: TextStyle(color: text, fontWeight: FontWeight.w800),
        ),

        calendarStyle: CalendarStyle(
          outsideDaysVisible: true,
          defaultTextStyle: const TextStyle(color: text, fontWeight: FontWeight.w800),
          weekendTextStyle: const TextStyle(color: text, fontWeight: FontWeight.w800),
          outsideTextStyle: TextStyle(color: text.withOpacity(0.45), fontWeight: FontWeight.w800),

          // start / end = синий кружок
          rangeStartDecoration: const BoxDecoration(
            color: Color(0xFF2D8CFF),
            shape: BoxShape.circle,
          ),
          rangeEndDecoration: const BoxDecoration(
            color: Color(0xFF2D8CFF),
            shape: BoxShape.circle,
          ),
          rangeStartTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
          rangeEndTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900),

          // середина диапазона — голубые “плашки”
          withinRangeDecoration: BoxDecoration(
            color: const Color(0xFF2D8CFF).withOpacity(0.35),
            borderRadius: BorderRadius.circular(10),
          ),
          withinRangeTextStyle: const TextStyle(color: text, fontWeight: FontWeight.w900),

          // если вдруг будет одиночный выбор
          selectedDecoration: const BoxDecoration(
            color: Color(0xFF2D8CFF),
            shape: BoxShape.circle,
          ),
          selectedTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}
