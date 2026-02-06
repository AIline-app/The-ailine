import 'package:flutter/material.dart';
import 'package:gghgggfsfs/core/theme/text_styles.dart';
import 'package:gghgggfsfs/core/widgets/custom_back_button.dart';
import 'package:gghgggfsfs/core/widgets/custom_button.dart';
import 'package:gghgggfsfs/presentation/auth/screens/phone_signup_screen.dart';

class PaymentWarningScreen extends StatelessWidget {
  const PaymentWarningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(leading: CustomBackButton()),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Оплата за бронирование",
                style: AppTextStyles.bold28Black,
              ),
              Spacer(),
              Text(
                "Оплата доступна зарегистрированным пользователям.",
                style: AppTextStyles.bodyBold,
              ),
              Text(
                "После регистрации вам не нужно \nзаново вводить данные",
                style: AppTextStyles.body,
              ),
              Spacer(),
              CustomButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PhoneSignupScreen(),
                    ),
                  );
                },
                text: "Зарегистрироваться",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
