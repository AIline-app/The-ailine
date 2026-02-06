import 'package:flutter/material.dart';
import 'package:gghgggfsfs/core/widgets/custom_back_button.dart';
import 'package:gghgggfsfs/core/widgets/custom_button.dart';
import 'package:gghgggfsfs/core/widgets/custom_text_field.dart';
import 'package:gghgggfsfs/presentation/auth/screens/otp_signup_screen.dart';
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
      backgroundColor: Colors.white,
      appBar: AppBar(leading: CustomBackButton(), backgroundColor: Colors.white,),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          FocusScope.of(context).unfocus(); // Removes focus from TextFields
        },
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16),
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
                      "Введите номер телефона",
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
                    SizedBox(height: 15),
                    CustomTextField(labelText: "Номер телефона"),
                    SizedBox(height: 15),
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
                    SizedBox(height: 15),
                    Text(
                      "На данный номер телефона будет отправлен СМС-код для подтверждения",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                CustomButton(
                  text: "Далeе",
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
