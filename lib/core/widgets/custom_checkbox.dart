import 'package:flutter/material.dart';

class CustomCheckboxWidget extends StatelessWidget {
  final bool? value;
  final ValueChanged<bool>? onChanged;

  const CustomCheckboxWidget({super.key, this.value, this.onChanged});

  @override
  Widget build(BuildContext context) {
    final bool isChecked = value ?? false;

    return GestureDetector(
      onTap: () {
        if (onChanged != null) {
          onChanged!(!isChecked);
        }
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
              isChecked
                  ? BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    borderRadius: BorderRadius.circular(6.0),
                  )
                  : null,
        ),
      ),
    );
  }
}
