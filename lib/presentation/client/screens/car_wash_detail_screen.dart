import 'package:flutter/material.dart';
import 'package:gghgggfsfs/core/theme/color_schemes.dart';
import 'package:gghgggfsfs/presentation/auth/widgets/custom_back_button.dart';
import 'package:gghgggfsfs/presentation/auth/widgets/custom_button.dart';
import 'package:gghgggfsfs/presentation/auth/widgets/custom_checkbox.dart';
import 'package:gghgggfsfs/presentation/client/themes/main_colors.dart';
import 'package:gghgggfsfs/presentation/client/widgets/another_service.dart';
import 'package:gghgggfsfs/presentation/client/widgets/tarifs_section.dart';
import 'package:gghgggfsfs/presentation/client/widgets/type_car_button.dart';

class CarWashDetailScreen extends StatefulWidget {
  const CarWashDetailScreen({super.key});

  @override
  State<CarWashDetailScreen> createState() => _CarWashDetailScreenState();
}

class _CarWashDetailScreenState extends State<CarWashDetailScreen> {
  bool chooseType = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 243, 241, 241),
      appBar: AppBar(leading: CustomBackButton()),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Stack(
                    children: [
                      Image(
                        image: AssetImage('assets/images/card_car.jpg'),
                        height: 410,
                        fit: BoxFit.cover,
                        color: Colors.black.withOpacity(0.5),
                        colorBlendMode: BlendMode.darken,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'г. Астана, ул. Абая, 117',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(width: 7),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(9),
                                  child: Image.asset(
                                    'assets/icons/2gis.png',
                                    width: 19,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Автомойка 777',
                              style: Theme.of(context).textTheme.displayLarge,
                            ),
                            SizedBox(height: 5),
                            Text(
                              '50 метров от вас',
                              style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 40),
                            Text(
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
                                Text(
                                  '12',
                                  style: TextStyle(
                                    height: 0.9,
                                    color: Colors.white,
                                    fontSize: 72,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  'машин',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 35),
                            Text(
                              'Вы сможете подъехать к:',
                              style: TextStyle(
                                height: 2,
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              '≈15:30',
                              style: TextStyle(
                                height: 0.9,
                                color: Colors.white,
                                fontSize: 72,
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  '± 30 мин',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TypeCarButton(
                      onPressed: () {},
                      text: 'седан',
                      textColor:
                          chooseType ? customColorScheme.primary : Colors.white,
                      backgroundColor:
                          chooseType
                              ? Colors.transparent
                              : customColorScheme.primary,
                    ),
                    TypeCarButton(
                      onPressed: () {},
                      text: 'джип',
                      textColor:
                          chooseType ? customColorScheme.primary : Colors.white,
                      backgroundColor:
                          chooseType
                              ? Colors.transparent
                              : customColorScheme.primary,
                    ),
                    TypeCarButton(
                      onPressed: () {},
                      text: 'минивен',
                      textColor:
                          chooseType ? customColorScheme.primary : Colors.white,
                      backgroundColor:
                          chooseType
                              ? Colors.transparent
                              : customColorScheme.primary,
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Container(
                  height: 310,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListView(
                    children: [
                      TarifsSection(
                        title: 'Стандарт',
                        subtitle: 'Пена, вода, сушка',
                        minutes: '30 мин',
                        price: '500р',
                      ),
                      TarifsSection(
                        title: 'Стандарт',
                        subtitle: 'Пена, вода, сушка',
                        minutes: '30 мин',
                        price: '500р',
                      ),
                      TarifsSection(
                        title: 'Стандарт',
                        subtitle: 'Пена, вода, сушка',
                        minutes: '30 мин',
                        price: '500р',
                      ),
                      TarifsSection(
                        title: 'Стандарт',
                        subtitle: 'Пена, вода, сушка',
                        minutes: '30 мин',
                        price: '500р',
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: EdgeInsets.only(left: 20),
                  child: Text(
                    'Дополнительные услуги',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 24,
                      color: MainColors.mainDeepBlue,
                    ),
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
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 32,
                            color: MainColors.mainDeepBlue,
                          ),
                        ),

                        Text(
                          '2.02, вторник, 14:00',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 32,
                            color: MainColors.mainDeepBlue,
                          ),
                        ),
                        SizedBox(height: 30),
                        Row(
                          children: [
                            CustomCheckboxWidget(),
                            SizedBox(width: 10),
                            SizedBox(
                              width: 327,
                              child: Text(
                                'Я подтверждаю дату и время бронирования и ознакомлен с условиями оплаты ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                CustomButton(text: 'Записаться', onPressed: () {}),
                SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
