import 'package:flutter/material.dart';
import 'package:gghgggfsfs/core/widgets/custom_back_button.dart';
import 'package:gghgggfsfs/core/widgets/custom_button.dart';
import 'package:gghgggfsfs/core/widgets/custom_checkbox.dart';
import 'package:gghgggfsfs/core/widgets/custom_text_field.dart';
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
                children: [
                  Text(
                    "Регистрация",
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomTextField(labelText: "Как вас зовут?"),
                      SizedBox(
                        height: 15,
                      ),
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
                      SizedBox(
                        height: 15,
                      ),
                      Text(
                        "На данный номер телефона будет отправлен СМС-код для подтверждения",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Информация о машине",
                        style: Theme.of(context).textTheme.displayMedium,
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      CustomTextField(labelText: "Номер машины"),
                    ],
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Уведомления",
                        style: Theme.of(context).textTheme.displayMedium,
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Text(
                        "За какой период вам напомнить о записи?",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Выберите мессенджер для отправки уведомлений ",
                        style: Theme.of(context).textTheme.displayMedium,
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Row(
                        children: [
                          CustomCheckboxWidget(),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            "Telegram",
                            style: Theme.of(context).textTheme.displaySmall,
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Row(
                        children: [
                          CustomCheckboxWidget(),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            "WhatsApp",
                            style: Theme.of(context).textTheme.displaySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  CustomButton(
                    text: "Зарегистрироваться",
                    onPressed: () {
                      /* after the e lelopment of a pagt Страница ввода карточных /анных  */},
                  ),
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
