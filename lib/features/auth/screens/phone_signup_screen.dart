import 'package:flutter/material.dart';
import 'package:gghgggfsfs/core/localization/generated/l10n.dart';
import 'package:gghgggfsfs/core/widgets/custom_back_button.dart';
import 'package:gghgggfsfs/core/widgets/custom_button.dart';
import 'package:gghgggfsfs/core/widgets/custom_text_field.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

class PhoneSignupScreen extends StatefulWidget {
  const PhoneSignupScreen({super.key});

  @override
  State<PhoneSignupScreen> createState() => _PhoneSignupScreenState();
}

class _PhoneSignupScreenState extends State<PhoneSignupScreen> {
  bool isClicked = false;

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
                  S.current.common_registration,
                  style: Theme.of(context).textTheme.displayLarge,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      S.current.common_enter_phone,
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
                    SizedBox(height: 15),

                    CustomTextField(labelText: S.current.common_phone_number),

                    CustomTextField(labelText: "Номер телефона"),

                    SizedBox(height: 15),
                    CustomTextField(
                      labelText: S.current.common_create_password,
                      icon: InkWell(
                        onTap: () {
                          setState(() {
                            isClicked = !isClicked;
                          });
                        },
                        child: Icon(
                          isClicked
                              ? IconsaxPlusLinear.eye
                              : IconsaxPlusLinear.eye_slash,
                          size: 30,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                      isClicked: isClicked,
                    ),
                    SizedBox(height: 15),
                    Text(
                      S.current.common_sms_verification_info,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                CustomButton(
                  text: S.current.common_next,
                  onPressed: () {
                    context.push('/otp');
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
