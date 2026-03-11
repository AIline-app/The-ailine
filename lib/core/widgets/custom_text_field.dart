import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum FieldType {
  text,
  phone,
  password,
}

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    this.icon,
    this.controller,
    this.onChanged,
    this.readOnly = false,
    required this.labelText,
    this.obscureText = false,
    this.maxLength,
    this.keyboardType,
    this.type = FieldType.text,  isClicked,
  });

  final Widget? icon;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;

  final String labelText;
  final bool readOnly;
  final bool obscureText;
  final int? maxLength;
  final TextInputType? keyboardType;
  final FieldType type;

  @override
  Widget build(BuildContext context) {
    final isPhone = type == FieldType.phone;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
          width: 3,
        ),
      ),
      child: TextFormField(
        controller: controller,
        onChanged: onChanged,
        readOnly: readOnly,
        keyboardType: isPhone
            ? TextInputType.phone
            : keyboardType,
        maxLength: isPhone ? 18 : maxLength,
        obscureText: type == FieldType.password ? obscureText : false,
        inputFormatters: isPhone
            ? [
          FilteringTextInputFormatter.digitsOnly,
          _PhoneFormatter(),
          LengthLimitingTextInputFormatter(11),
        ]
            : null,
        style: const TextStyle(fontSize: 20),
        decoration: InputDecoration(
          counterText: "",
          fillColor: Colors.white,
          filled: true,
          enabledBorder: const OutlineInputBorder(borderSide: BorderSide.none),
          focusedBorder: const OutlineInputBorder(borderSide: BorderSide.none),
          label: Text(labelText),
          labelStyle:
          TextStyle(color: Theme.of(context).colorScheme.onSurface),
          suffixIcon: icon,
        ),
      ),
    );
  }
}

class _PhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');

    if (digits.isEmpty) return newValue;

    final buffer = StringBuffer();

    buffer.write('+7 ');

    if (digits.length > 1) {
      buffer.write('(${digits.substring(1, digits.length.clamp(1, 4))}');
    }

    if (digits.length >= 4) {
      buffer.write(') ');
      buffer.write(digits.substring(4, digits.length.clamp(4, 7)));
    }

    if (digits.length >= 7) {
      buffer.write(' ');
      buffer.write(digits.substring(7, digits.length.clamp(7, 9)));
    }

    if (digits.length >= 9) {
      buffer.write(' ');
      buffer.write(digits.substring(9, digits.length.clamp(9, 11)));
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}