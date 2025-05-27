import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CustomBackButton extends StatelessWidget {
  const CustomBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        Navigator.of(context).pop();
      },
      icon: SvgPicture.asset(
        "assets/icons/arrow_back.svg",
        width: 20,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
