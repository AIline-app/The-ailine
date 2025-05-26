import 'package:flutter/material.dart';

class TypeCarButton extends StatelessWidget {
  const TypeCarButton({
    super.key,
    required this.onPressed,
    required this.text,
    required this.backgroundColor,
    required this.textColor,
  });
  final Function() onPressed;
  final String text;
  final Color backgroundColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        minimumSize: Size(125, 72),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: Theme.of(context).colorScheme.tertiary,
            width: 3,
          ),
        ),
      ),
      onPressed: onPressed,
      child: Text(text, style: TextStyle(fontSize: 20, color: textColor)),
    );
  }
}
