import 'package:flutter/material.dart';
import 'package:theIline/core/theme/color_schemes.dart';
import 'package:theIline/core/theme/text_styles.dart';
import 'package:theIline/core/widgets/custom_back_button.dart';
import 'package:theIline/core/widgets/custom_button.dart';
import 'package:theIline/core/widgets/custom_checkbox.dart';
import 'package:theIline/presentation/auth/screens/phone_signup_screen.dart';
import 'package:theIline/presentation/client/screens/payment_warning_screen.dart';
import 'package:theIline/presentation/client/themes/main_colors.dart';
import 'package:theIline/core/widgets/another_service.dart';
import 'package:theIline/core/widgets/tarifs_section.dart';
import 'package:theIline/core/widgets/type_car_button.dart';

import '../../../core/widgets/car_tarifs.dart';

class CarWashDetailScreen extends StatefulWidget {
  const CarWashDetailScreen({super.key});

  @override
  State<CarWashDetailScreen> createState() => _CarWashDetailScreenState();
}

class _CarWashDetailScreenState extends State<CarWashDetailScreen> {
  int selectedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 243, 241, 241),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
        
              Padding(
                padding: EdgeInsets.all(2),
                child: Row(
                  children: [
                    CustomBackButton(),
                  ],
                ),
              ),
          ClipRRect(
          borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(8),
        ),
        child: Stack(
          children: [
            // Фон-карточка (с фиксированной высотой, иначе Spacer сломает layout)
            Padding(
              padding: const EdgeInsets.all(8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  height: 350,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        'assets/images/card_car.jpg',
                        fit: BoxFit.cover,
                      ),
        
                      Container(
                        color: const Color(0x891C1C1C),
                      ),
        
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Expanded(
                                  child: Text(
                                    'г. Астана, ул. Абая, 117',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 7),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(9),
                                  child: Image.asset(
                                    'assets/icons/2gis.png',
                                    width: 19,
                                    height: 19,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ],
                            ),
        
                            const SizedBox(height: 10),
        
                            Text(
                              'Автомойка 777',
                              style: AppTextStyles.bold28w600,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
        
                            const SizedBox(height: 5),
        
                            Text(
                              '50 метров от вас',
                              style: AppTextStyles.normalLightGrey,
                            ),
        
                            const Spacer(),
        
                            const Text(
                              'Перед вами сейчас:',
                              style: TextStyle(
                                height: 2,
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
        
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('12', style: AppTextStyles.bold40),
                                const SizedBox(width: 6),
                                Text('машин', style: AppTextStyles.normalLightGrey),
                              ],
                            ),
        
                            const SizedBox(height: 20),
        
                            const Text(
                              'Вы сможете подъехать к:',
                              style: TextStyle(
                                height: 2,
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
        
                            const SizedBox(height: 10),
        
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('≈15:30', style: AppTextStyles.bold40),
                                Text('± 30 мин', style: AppTextStyles.normalLightGrey),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        
          ],
        ),
            ),
              SizedBox(height: 10),
        
             SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Row(
                    children: [
                      TypeCarButton(
                        onPressed: () {
                          setState(() => selectedIndex = 0);
                        },
                        text: 'седан',
                        textColor:
                            selectedIndex == 0 ? Colors.white : customColorScheme.primary,
                        backgroundColor:
                            selectedIndex == 0 ? customColorScheme.primary : Colors.transparent,
                      ),
                      const SizedBox(width: 8),
                      TypeCarButton(
                        onPressed: () {
                          setState(() => selectedIndex = 1);
                        },
                        text: 'джип',
                        textColor:
                            selectedIndex == 1 ? Colors.white : customColorScheme.primary,
                        backgroundColor:
                            selectedIndex == 1 ? customColorScheme.primary : Colors.transparent,
                      ),
                      const SizedBox(width: 8),
                      TypeCarButton(
                        onPressed: () {
                          setState(() => selectedIndex = 2);
                        },
                        text: 'минивен',
                        textColor:
                            selectedIndex == 2 ? Colors.white : customColorScheme.primary,
                        backgroundColor:
                            selectedIndex == 2 ? customColorScheme.primary : Colors.transparent,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              CarTarifs(),
              SizedBox(height: 20),
              Padding(
                padding: EdgeInsets.only(left: 20),
                child: Text(
                  'Дополнительные услуги',
                  style: AppTextStyles.title,
                ),
              ),
              SizedBox(height: 5),
              AnotherService(
                title: 'Покрытие воском',
                subtitle: 'Какой-то текст',
                minutes: '10 мин',
                price: '200р',
              ),
              AnotherService(
                title: 'Покрытие воском',
                subtitle: 'Какой-то текст',
                minutes: '10 мин',
                price: '200р',
              ),
              AnotherService(
                title: 'Покрытие воском',
                subtitle: 'Какой-то текст',
                minutes: '10 мин',
                price: '200р',
              ),
              AnotherService(
                title: 'Покрытие воском',
                subtitle: 'Какой-то текст',
                minutes: '10 мин',
                price: '200р',
              ),
              SizedBox(height: 10),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(9.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Вы выбрали',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
        
                      Text(
                        '750 р',
                        style: AppTextStyles.bold28Black,
                      ),
        
                      Text(
                        '2.02, вторник, 14:00',
                        style: AppTextStyles.bold28Black,
                      ),
                      SizedBox(height: 30),
                        Row(
                        children: [
                        const SizedBox(width: 10),
                        CustomCheckboxWidget(),
                        const SizedBox(width: 10),
                        Expanded(
                        child: Text(
                        'Я подтверждаю дату и время бронирования и ознакомлен с условиями оплаты',
                        style: AppTextStyles.normal14,
                        ),
                        ),
                        ],
                        )]
                  ),
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: CustomButton(
                  text: 'Записаться',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PaymentWarningScreen(),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
