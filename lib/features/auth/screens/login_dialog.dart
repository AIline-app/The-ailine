import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gghgggfsfs/core/localization/generated/l10n.dart';
import 'package:gghgggfsfs/core/resources/colors/app_colors.dart';
import 'package:gghgggfsfs/core/widgets/custom_button.dart';
import 'package:gghgggfsfs/core/widgets/custom_text_field.dart';
import 'package:gghgggfsfs/features/client/themes/main_colors.dart';
import 'package:go_router/go_router.dart';

class LoginDialog extends StatefulWidget {
  const LoginDialog({super.key});

  @override
  State<LoginDialog> createState() => _LoginDialogState();
}

class _LoginDialogState extends State<LoginDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.transparent,
      contentPadding: EdgeInsets.zero,
      content: Center(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 56.w,
                        height: 56.h,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Icon(Icons.close, color: Colors.white, size: 52),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(
                    top: 100.sp,
                    left: 20.sp,
                    right: 20.sp,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        S.current.common_login,
                        style: Theme.of(context).textTheme.displayLarge!
                            .copyWith(color: AppColors.deepBlue),
                      ),
                      SizedBox(height: 30.h),
                      CustomTextField(labelText: S.current.common_phone_number),
                      SizedBox(height: 20.h),
                      CustomTextField(labelText: S.current.common_password),
                      SizedBox(height: 25.h),
                      Text(
                        S.current.common_forgot_password,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: Color(0xff228CEE),
                        ),
                      ),
                      SizedBox(height: 25.h),
                      CustomButton(
                        text: S.current.common_login,
                        onPressed: () {},
                      ),
                      SizedBox(height: 20.h),
                      TextButton(
                        onPressed: () {
                          context.push('/auth');
                        },

                        child: Text(
                          S.current.common_register,
                          style: TextStyle(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.w600,
                            color: MainColors.mainBlue,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 2.sp,
                        child: Container(
                          width: 150.w,
                          height: 2.h,
                          color: MainColors.mainBlue,
                        ),
                      ),

                      SizedBox(height: 90.h),
                      TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          overlayColor: Colors.transparent,
                        ),
                        child: Text(
                          S.current.common_become_partner,
                          style: TextStyle(
                            fontSize: 27.sp,
                            fontWeight: FontWeight.w600,
                            color: MainColors.mainOrrange,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 2.sp,
                        child: SizedBox(width: 220.w, height: 2.h),
                      ),
                      Container(
                        width: 150.h,
                        height: 2.h,
                        color: MainColors.mainBlue,
                      ),
                      SizedBox(height: 90),
                      TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          overlayColor: Colors.transparent,
                        ),

                        child: Text(
                          'Стать партнером',
                          style: TextStyle(
                            fontSize: 27,
                            fontWeight: FontWeight.w600,

                            color: MainColors.mainOrrange,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
