import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CustomCheckboxWidget extends StatefulWidget {
  CustomCheckboxWidget({super.key, this.isChecked = false});

  bool isChecked;

  @override
  // ignore: library_private_types_in_public_api
  _CustomCheckboxWidgetState createState() => _CustomCheckboxWidgetState();
}

class _CustomCheckboxWidgetState extends State<CustomCheckboxWidget> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          widget.isChecked = !widget.isChecked;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(2.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
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
              widget.isChecked
                  ? BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    borderRadius: BorderRadius.circular(6.0),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.secondary,
                      width: 2,
                    ),
                  )
                  : null,
        ),
      ),
    );
  }
}
