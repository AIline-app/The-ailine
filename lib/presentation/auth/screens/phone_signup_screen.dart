import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gghgggfsfs/presentation/auth/screens/otp_signup_screen.dart';
import 'package:gghgggfsfs/presentation/auth/widgets/custom_back_button.dart';
import 'package:gghgggfsfs/presentation/auth/widgets/custom_button.dart';
import 'package:gghgggfsfs/presentation/auth/widgets/custom_text_field.dart';
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
                  spacing: 15,
                  children: [
                    Text(
                      "Введите номер телефона",
                      style: Theme.of(context).textTheme.displayMedium,
                    ),

                    CustomTextField(labelText: "Номер телефона"),

                    CustomTextField(
                      labelText: "Придумайте пароль",
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

                    Text(
                      "На данный номер телефона будет отправлен СМС-код для подтверждения",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),

                CustomButton(
                  text: "Далее",
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OtpSignupScreen(),
                      ),
                    );
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
