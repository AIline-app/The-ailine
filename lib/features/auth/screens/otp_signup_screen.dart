import 'package:flutter/material.dart';
import 'package:gghgggfsfs/core/localization/generated/l10n.dart';
import 'package:gghgggfsfs/core/widgets/custom_back_button.dart';
import 'package:gghgggfsfs/core/widgets/custom_button.dart';
import 'package:go_router/go_router.dart';
import 'package:otp_text_field_v2/otp_field_v2.dart';
import 'package:otp_text_field_v2/otp_text_field_v2.dart';

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
      resizeToAvoidBottomInset: false,
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
                  S.current.common_register,
                  style: Theme.of(context).textTheme.displayLarge,
                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      S.current.common_enter_sms_code,
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
                      S.current.common_sms_code_info,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Center(
                      child: Text(
                        S.current.common_resend_code,
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
                  text: S.current.common_next,
                  onPressed: () {
                    context.push('/auth/car_signup');
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
