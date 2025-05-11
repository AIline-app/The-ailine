import 'package:flutter/material.dart';
import 'package:gghgggfsfs/presentation/auth/widgets/custom_back_button.dart';
import 'package:gghgggfsfs/presentation/auth/widgets/custom_button.dart';
import 'package:gghgggfsfs/presentation/auth/widgets/custom_checkbox.dart';
import 'package:gghgggfsfs/presentation/auth/widgets/custom_text_field.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

class CarSignupScreen extends StatefulWidget {
  const CarSignupScreen({super.key});

  @override
  State<CarSignupScreen> createState() => _CarSignupScreenState();
}

class _CarSignupScreenState extends State<CarSignupScreen> {
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
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 25,
                children: [
                  Text(
                    "Регистрация",
                    style: Theme.of(context).textTheme.displayLarge,
                  ),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 15,
                    children: [
                      CustomTextField(labelText: "Как вас зовут?"),

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

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 15,
                    children: [
                      Text(
                        "Информация о машине",
                        style: Theme.of(context).textTheme.displayMedium,
                      ),
                      CustomTextField(labelText: "Номер машины"),
                    ],
                  ),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 15,
                    children: [
                      Text(
                        "Уведомления",
                        style: Theme.of(context).textTheme.displayMedium,
                      ),

                      Text(
                        "За какой период вам напомнить о записи?",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 15,
                    children: [
                      Text(
                        "Выберите мессенджер для отправки уведомлений ",
                        style: Theme.of(context).textTheme.displayMedium,
                      ),

                      Row(
                        spacing: 10,
                        children: [
                          CustomCheckboxWidget(),

                          Text(
                            "Telegram",
                            style: Theme.of(context).textTheme.displaySmall,
                          ),
                        ],
                      ),
                      Row(
                        spacing: 10,
                        children: [
                          CustomCheckboxWidget(),

                          Text(
                            "WhatsApp",
                            style: Theme.of(context).textTheme.displaySmall,
                          ),
                        ],
                      ),
                    ],
                  ),

                  CustomButton(text: "Зарегистрироваться", onPressed: () {}),

                  SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
