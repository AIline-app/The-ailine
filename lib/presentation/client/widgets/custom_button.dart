import 'package:flutter/material.dart';

class CustomButton extends StatefulWidget {
  final String text_of_button;
  const CustomButton({super.key, required this.text_of_button});

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 328,
      height: 96,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          backgroundColor: Color(0xff228CEE),
          foregroundColor: Colors.white,
        ),
        onPressed: () {},
        child: Text(widget.text_of_button, style: TextStyle(fontSize: 30)),
      ),
    );
  }
}
