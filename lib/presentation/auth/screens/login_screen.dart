import 'package:flutter/material.dart';

import '../../../core/widgets/custom_back_button.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../routes.dart';
import '../../client/themes/main_colors.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: CustomBackButton(),
        backgroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.transparent,
        foregroundColor: Colors.black,
        ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            const Text(
              'Вход',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 32,
                color: Color(0xff1F3D59),
              ),
            ),

            const SizedBox(height: 30),

            const CustomTextField(labelText: 'Номер телефона'),
            const SizedBox(height: 20),

            const CustomTextField(labelText: 'Пароль'),

            const SizedBox(height: 25),

            const Text(
              'Забыли пароль?',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Color(0xff228CEE),
              ),
            ),

            const SizedBox(height: 25),

            CustomButton(
              text: 'Войти',
              onPressed: () {},
            ),

            const SizedBox(height: 20),

            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.reg);
              },
              child: const Text(
                'Регистрация',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: MainColors.mainBlue,
                ),
              ),
            ),

            Container(
              width: 150,
              height: 2,
              color: MainColors.mainBlue,
            ),

            const SizedBox(height: 60),

            TextButton(
              onPressed: () {},
              child: const Text(
                'Стать партнером',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: MainColors.mainOrrange,
                ),
              ),
            ),

            Container(
              width: 220,
              height: 2,
              color: MainColors.mainOrrange,
            ),

          ],
        ),
      ),
    );
  }
}
