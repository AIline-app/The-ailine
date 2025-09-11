import 'package:flutter/material.dart';

class CustomCircleCheckbox extends StatefulWidget {
  const CustomCircleCheckbox({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CustomCircleCheckboxState createState() => _CustomCircleCheckboxState();
}

class _CustomCircleCheckboxState extends State<CustomCircleCheckbox> {
  bool _isChecked = true;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isChecked = !_isChecked;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(2.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            color: Theme.of(context).colorScheme.secondary,
            width: 5,
          ),
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 20,
          height: 20,
          decoration:
              _isChecked
                  ? null
                  : BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.secondary,
                      width: 2,
                    ),
                  ),
        ),
      ),
    );
  }
}
