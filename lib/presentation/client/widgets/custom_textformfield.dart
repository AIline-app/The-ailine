import 'package:flutter/material.dart';

class CustomTextformfield extends StatefulWidget {
  final String text_in_button;
  const CustomTextformfield({super.key, required this.text_in_button});

  @override
  State<CustomTextformfield> createState() => _CustomTextformfieldState();
}

class _CustomTextformfieldState extends State<CustomTextformfield> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        labelText: widget.text_in_button,
        labelStyle: TextStyle(color: Colors.grey, fontSize: 15),
      ),
    );
  }
}
