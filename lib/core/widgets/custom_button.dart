import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({super.key, required this.onPressed, required this.text});

  final Function() onPressed;
  final String text;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        minimumSize: Size(328.w, 96.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
          side: BorderSide(
            color: Theme.of(context).colorScheme.tertiary,

            width: 5.w,
          ),
        ),
      ),
      onPressed: onPressed,
      child: Text(text),
    );
  }
}
