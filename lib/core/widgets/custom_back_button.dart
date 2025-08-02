import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

class CustomBackButton extends StatelessWidget {
  const CustomBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        context.pop();
      },
      icon: SvgPicture.asset(
        "assets/icons/arrow_back.svg",
        width: 20,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
