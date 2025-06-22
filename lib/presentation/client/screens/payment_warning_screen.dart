import 'package:flutter/material.dart';
import 'package:gghgggfsfs/core/widgets/custom_back_button.dart';
import 'package:gghgggfsfs/core/widgets/custom_button.dart';
import 'package:gghgggfsfs/presentation/auth/screens/phone_signup_screen.dart';

class PaymentWarningScreen extends StatelessWidget {
  const PaymentWarningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: CustomBackButton()),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Оплата за бронирование",
                style: Theme.of(context).textTheme.displayLarge,
              ),
              Spacer(),
              Text(
                "Оплата доступна зарегистрированным пользователям.",
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
              Text(
                "После регистрации вам не нужно \nзаново вводить данные",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              SizedBox(height: 45),
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
