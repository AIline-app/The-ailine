import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  const CustomTextField({
    super.key,
    this.icon,
    this.isClicked = false,
    this.textController,
    required this.labelText,
    TextInputType? keyboardType,
    void Function(dynamic value)? onChanged,
    String? initialValue,
  });

  final Widget? icon;
  final bool isClicked;
  final TextEditingController? textController;
  final String labelText;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      height: 65,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
          width: 4,
        ),
      ),
      child: TextFormField(
        controller: widget.textController,
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
          labelStyle: TextStyle(color: Colors.grey),
          suffixIcon: widget.icon,
        ),
      ),
    );
  }
}
