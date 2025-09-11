extension StringValidators on String {
  /// Простейшая валидация email
  bool emailValidator() {
    final emailRegExp = RegExp(r'^[\\w\\.-]+@[\\w\\.-]+\\.\\w{2,}$');
    return emailRegExp.hasMatch(this);
  }

  /// Содержит ли строка только цифры (и необязательно + в начале)
  bool isOnlyDigits() {
    final digitsOnly = RegExp(r'^\\+?\\d+\$');
    return digitsOnly.hasMatch(this);
  }

  /// Проверка на числовую строку (возможны пробелы/символы)
  bool isNumeric() {
    return double.tryParse(this) != null;
  }
}
