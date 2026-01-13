import 'dart:core';
import 'package:intl/intl.dart';

/// Утилиты для работы с датами и временем в приложении
class AppDateUtils {
  /// Возвращает понедельник текущей недели
  static DateTime firstDateOfWeek(DateTime dateTime) {
    return dateTime.subtract(Duration(days: dateTime.weekday - 1));
  }

  /// Возвращает воскресенье текущей недели
  static DateTime lastDateOfWeek(DateTime dateTime) {
    return dateTime.add(Duration(days: DateTime.daysPerWeek - dateTime.weekday));
  }

  /// Форматирует секунды в строку вида `hh : mm : ss` или `hh : mm`
  static String formatedTime({
    required int timeInSecond,
    bool showSeconds = true,
  }) {
    final int sec = timeInSecond % 60;
    final int totalMinutes = (timeInSecond / 60).floor();
    final int min = totalMinutes % 60;
    final int hour = (totalMinutes / 60).floor();

    final String hours = hour.toString().padLeft(2, '0');
    final String minutes = min.toString().padLeft(2, '0');
    final String seconds = sec.toString().padLeft(2, '0');

    return showSeconds ? "$hours : $minutes : $seconds" : "$hours : $minutes";
  }

  /// Форматирует секунды в строку с русскими словами ("час", "минут")
  static String formattedTimeWithoutSeconds({
    required int timeInSecond,
  }) {
    final int totalMinutes = (timeInSecond / 60).floor();
    final int min = totalMinutes % 60;
    final int hour = (totalMinutes / 60).floor();

    // Функция для выбора правильной формы слова "час"
    String getHourWord(int hours) {
      if (hours == 0) return '';
      if (hours == 1) return 'час';
      if (hours >= 2 && hours <= 4) return 'часа';
      return 'часов';
    }

    // Функция для выбора правильной формы слова "минута"
    String getMinuteWord(int minutes) {
      if (minutes == 0) return '0 минут';
      if (minutes == 1) return 'минута';
      if (minutes >= 2 && minutes <= 4) return 'минуты';
      if (minutes >= 5 && minutes <= 20) return 'минут';
      
      final lastDigit = minutes % 10;
      if (lastDigit == 1) return 'минута';
      if (lastDigit >= 2 && lastDigit <= 4) return 'минуты';
      return 'минут';
    }

    final String hourUnit = getHourWord(hour);
    final String minuteUnit = getMinuteWord(min);

    return hour > 0 ? "$hour $hourUnit $min $minuteUnit" : "$min $minuteUnit";
  }

  /// Преобразует дату из формата `dd.MM.yyyy` в `yyyy-MM-dd`
  static String reformatDateString(String inputDate) {
    DateFormat inputFormat = DateFormat('dd.MM.yyyy');
    DateTime parsedDate = inputFormat.parse(inputDate);
    return DateFormat('yyyy-MM-dd').format(parsedDate);
  }

  /// Возвращает список всех дней недели, начиная с понедельника
  static List<DateTime> getDaysInWeek(DateTime dateTime) {
    final firstDay = firstDateOfWeek(dateTime);
    return List.generate(7, (i) => firstDay.add(Duration(days: i)));
  }

  /// Возвращает день месяца в формате `dd`, например `07`
  static String getMonthDay(DateTime dateTime, {String locale = 'ru_RU'}) {
    return DateFormat("dd", locale).format(dateTime);
  }

  /// Возвращает название месяца в формате `MMM`, например `янв`
  static String getMonthName(DateTime dateTime, {String locale = 'ru_RU'}) {
    return DateFormat("MMM", locale).format(dateTime);
  }

  /// Индекс сегодняшнего дня в неделе (0 — понедельник, 6 — воскресенье)
  static int getTodayWeekIndex() {
    return DateTime.now().weekday - 1;
  }

  /// Возвращает номер недели текущего дня в месяце
  static int getTodayWeekInMonth() {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final int firstWeekday = firstDayOfMonth.weekday;
    final int today = now.day;
    return ((firstWeekday + today - 1) / 7).ceil();
  }

  /// Возвращает текущее время в виде строки (например, "14:32")
  static String currentTimeFormatted() {
    final now = DateTime.now();
    return DateFormat('HH:mm').format(now);
  }

  /// Проверяет, входит ли указанная дата в текущую неделю
  static bool isInCurrentWeek(DateTime date) {
    final now = DateTime.now();
    final start = firstDateOfWeek(now);
    final end = lastDateOfWeek(now);
    return date.isAfter(start.subtract(const Duration(seconds: 1))) && 
           date.isBefore(end.add(const Duration(days: 1)));
  }
}

/// Расширение для удобной работы с датами
extension DateExtension on DateTime {
  /// Преобразует дату в строку с заданным форматом, например `dd.MM.yyyy`
  String toFormatString(String format) => DateFormat(format).format(this);

  /// Проверяет, совпадают ли две даты по дню, месяцу и году
  bool isSameDate(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  /// Проверяет, является ли дата сегодняшним днём
  bool isToday() => isSameDate(DateTime.now());

  /// Возвращает `true`, если дата находится в прошлом (без учёта времени)
  bool isPast() => isBefore(DateTime.now().subtract(Duration(days: 1)));

  /// Возвращает `true`, если дата находится в будущем (без учёта времени)
  bool isFuture() => isAfter(DateTime.now());
}