import 'package:flutter/material.dart';

class CustomCheckboxWidget extends StatefulWidget {
  const CustomCheckboxWidget({super.key});

  @override
  _CustomCheckboxWidgetState createState() => _CustomCheckboxWidgetState();
}

class _CustomCheckboxWidgetState extends State<CustomCheckboxWidget> {
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
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color:
                // _isChecked
                //     ? Colors.grey
                //     :
                Theme.of(context).colorScheme.secondary,
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
                    borderRadius: BorderRadius.circular(6.0),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.secondary,
                      width: 2,
                    ),
                  ),
          // child:
          //     _isChecked
          //         ? const Icon(
          //           CupertinoIcons.check_mark,
          //           color: Colors.white,
          //           size: 25,
          //           weight: 1,
          //         )
          //         : const SizedBox.shrink(),
        ),
      ),
    );
  }
}
