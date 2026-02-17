import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  const CustomTextField({super.key, 
    this.icon,
    this.isClicked = false,
    this.textController,
    this.readOnly = false,
    required this.labelText,
  });

  final Widget? icon;
  final bool isClicked;
  final TextEditingController? textController;
  final String labelText;
  final bool readOnly;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
          width: 3,
        ),
      ),
      child: TextFormField(
        readOnly: widget.readOnly,
        style: TextStyle(fontSize: 20),
        maxLength: 20,
        obscureText: !widget.isClicked,
        decoration: InputDecoration(
          counterText: "",
          fillColor: Colors.white,
          filled: true,
          enabledBorder: OutlineInputBorder(borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderSide: BorderSide.none),
          label: Text(widget.labelText),
          labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          suffixIcon: widget.icon,
        ),
      ),
    );
  }
}
