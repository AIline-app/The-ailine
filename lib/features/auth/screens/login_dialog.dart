import 'package:flutter/material.dart';
import 'package:gghgggfsfs/core/localization/generated/l10n.dart';
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
          width: 800,
          height: 830,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
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
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.close, color: Colors.white, size: 52),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 100, left: 20, right: 20),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          S.current.common_login,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 32,
                            color: Color(0xff1F3D59),
                          ),
                        ),
                        SizedBox(height: 30),
                        CustomTextField(
                          labelText: S.current.common_phone_number,
                        ),
                        SizedBox(height: 20),
                        CustomTextField(labelText: S.current.common_password),
                        SizedBox(height: 25),
                        Text(
                          S.current.common_forgot_password,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xff228CEE),
                          ),
                        ),
                        SizedBox(height: 25),
                        CustomButton(
                          text: S.current.common_login,
                          onPressed: () {},
                        ),
                        SizedBox(height: 20),
                        TextButton(
                          onPressed: () {
                            context.push('/reg');
                          },

                          child: Text(
                            S.current.common_register,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: MainColors.mainBlue,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 2,
                          child: Container(
                            width: 150,
                            height: 2,
                            color: MainColors.mainBlue,
                          ),
                        ),

                        SizedBox(height: 90),
                        TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            overlayColor: Colors.transparent,
                          ),
                          child: Text(
                            S.current.common_become_partner,
                            style: TextStyle(
                              fontSize: 27,
                              fontWeight: FontWeight.w600,
                              color: MainColors.mainOrrange,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 2,
                          child: SizedBox(width: 220, height: 2),
                        ),
                        Container(
                          width: 150,
                          height: 2,
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
