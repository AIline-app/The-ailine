import 'package:flutter/material.dart';
import 'package:theIline/core/widgets/custom_back_button.dart';
import 'package:theIline/core/widgets/custom_button.dart';
import 'package:theIline/core/widgets/custom_checkbox.dart';
import 'package:theIline/core/widgets/custom_text_field.dart';
import 'package:theIline/presentation/client/screens/map_home_screen.dart';
import 'package:theIline/routes.dart';

class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: CustomBackButton()),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Оплата", style: Theme.of(context).textTheme.displayLarge),
                SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.all(8),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Вы выбрали",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        "750 р",
                        style: Theme.of(context).textTheme.displayLarge,
                      ),
                      Text(
                        "2.02, вторник, 14:00",
                        style: Theme.of(context).textTheme.displayLarge,
                      ),
                      SizedBox(height: 30),

                      Row(
                        children: [
                          CustomCheckboxWidget(),
                          SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              "Я подтверждаю дату и время бронирования и ознакомлен с условиями оплаты ",
                              style: Theme.of(
                                context,
                              ).textTheme.labelSmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 8),

                Row(
                  children: [
                    Flexible(
                      child: Text(
                        "Оплата производится через эквайрингакасса 24",
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                    ),
                    Image.asset("assets/icons/kassa.png", width: 108),
                  ],
                ),

                SizedBox(height: 8),

                CustomTextField(labelText: "Номер карты"),

                SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(child: CustomTextField(labelText: "Дата")),
                    SizedBox(width: 8),
                    Expanded(child: CustomTextField(labelText: "CVV")),
                  ],
                ),

                SizedBox(height: 20),

                CustomTextField(labelText: "IVAN IVANOV"),

                Text(
                  "Отменить бронирование можно в любое время с возвратом средств за вычетом комиссии эквайринга",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),

                SizedBox(height: 20),

                Row(
                  children: [
                    Text(
                      "Mastercard",
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    SizedBox(width: 10),
                    Image.asset("assets/icons/Mastercard.png"),
                  ],
                ),

                SizedBox(height: 20),

                Row(
                  children: [
                    CustomCheckboxWidget(),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        "Запомнить данные карты",
                        style: Theme.of(
                          context,
                        ).textTheme.displaySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 8),

                Text(
                  "Отменить бронирование можно в любое время с возвратом средств за вычетом комиссии эквайринга",
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w400,
                  ),
                ),

                SizedBox(height: 16),

                CustomButton(
                  onPressed: () {
                     Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MapHomeScreen(),
                        ),
                      );
                  },
                  text: "Зарегистрироваться",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
