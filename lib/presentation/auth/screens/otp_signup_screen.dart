import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:otp_text_field_v2/otp_field_v2.dart';
import 'package:otp_text_field_v2/otp_text_field_v2.dart';

import '../../../core/widgets/custom_back_button.dart';
import '../../../core/widgets/custom_button.dart';

class OtpSignupScreen extends StatefulWidget {
  const OtpSignupScreen({super.key});

  @override
  State<OtpSignupScreen> createState() => _OtpSignupScreenState();
}

class _OtpSignupScreenState extends State<OtpSignupScreen> {
  final OtpFieldControllerV2 otpController = OtpFieldControllerV2();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: CustomBackButton()),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          FocusScope.of(context).unfocus(); // Removes focus from TextFields
        },
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Регистрация",
                  style: Theme.of(context).textTheme.displayLarge,
                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
               
                  children: [
                    Text(
                      "Введите код из СМС",
                      style: Theme.of(context).textTheme.displayMedium,
                    ),

                    OTPTextFieldV2(
                      controller: otpController,
                      length: 4,
                      width: MediaQuery.of(context).size.width,
                      textFieldAlignment: MainAxisAlignment.spaceAround,
                      fieldWidth: 45,
                      keyboardType: TextInputType.number,
                      fieldStyle: FieldStyle.underline,
                      outlineBorderRadius: 15,
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w700,
                      ),
                      onChanged: (pin) {
                        print("Changed: $pin");
                      },
                      onCompleted: (pin) {
                        print("Completed: $pin");
                      },
                    ),
                    Text(
                      "Код будет доставлен в течение 30 секунд. Если код не пришел, проверьте правильность указанного номер телефона и попробуйте еще раз",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Center(
                      child: Text(
                        "Выслать код повторно",
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          decorationColor:
                              Theme.of(context).colorScheme.primary,
                          decorationThickness: 1.5,
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                CustomButton(
                  text: "Далее",
                  onPressed: () {
                    context.push('/car_signup');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
