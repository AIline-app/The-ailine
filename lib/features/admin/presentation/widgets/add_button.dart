import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AddButton extends StatelessWidget {
  const AddButton({super.key, required this.onPressed, required this.text});
  final Function() onPressed;
  final String text;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        minimumSize: Size(344.w, 61.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
          side: BorderSide(
            color: Theme.of(context).colorScheme.tertiary,

            width: 5.w,
          ),
        ),
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(text),
          SizedBox(width: 10.w),
          Icon(Icons.add, size: 34.sp),
        ],
      ),
    );
  }
}
