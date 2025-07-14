import 'package:flutter/material.dart';
import 'package:gghgggfsfs/core/widgets/custom_back_button.dart';
import 'package:gghgggfsfs/core/widgets/custom_button.dart';
import 'package:gghgggfsfs/core/widgets/custom_checkbox.dart';
import 'package:gghgggfsfs/core/widgets/tarifs_section.dart';
import 'package:gghgggfsfs/core/widgets/type_car.dart';
import 'package:gghgggfsfs/data/model_car_wash/model_car_wash.dart';
import 'package:gghgggfsfs/presentation/client/themes/main_colors.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../data/model_car_wash/service.dart';

class CarWashDetailScreen extends StatefulWidget {
  final CarWashModel carWash;
  const CarWashDetailScreen({super.key, required this.carWash});

  @override
  State<CarWashDetailScreen> createState() => _CarWashDetailScreenState();
}

class _CarWashDetailScreenState extends State<CarWashDetailScreen> {
  void _openLink(String? url) {
    if (url != null && url.isNotEmpty) {
      launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  void updateTotalPrice() {
    final allServices = [...mainServices, ...extraServices];
    totalPrice = allServices
        .where((s) => s.isSelected)
        .fold(0, (sum, item) => sum + item.price);
    setState(() {});
  }

  final carTypes = ['седан', 'джип', 'минивен'];
  int selectedIndex = 0;

  List<Service> mainServices = [
    Service(title: 'Стандарт', price: 500),
    Service(title: 'Покрытие воском', price: 200),
    Service(title: 'Покрытие воском', price: 200),
    Service(title: 'Покрытие воском', price: 200),
  ];
  List<Service> extraServices = [
    Service(title: 'Мойка кузова', price: 1000),
    Service(title: 'Пылесос', price: 800),
    Service(title: 'Мойка кузова', price: 1000),
    Service(title: 'Мойка кузова', price: 1000),
  ];

  int totalPrice = 0;

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
                        padding: const EdgeInsets.only(
                          top: 15,
                          left: 12,
                          right: 12,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  widget.carWash.address,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 7),
                                GestureDetector(
                                  onTap:
                                      () => _openLink(widget.carWash.link2gis),

                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(9),
                                    child: Image.asset(
                                      'assets/icons/2gis.png',
                                      width: 19,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Text(
                              widget.carWash.address,
                              style: Theme.of(context).textTheme.displayLarge,
                            ),
                            SizedBox(height: 6),
                            Text(
                              '${widget.carWash.distance} метров от вас',
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
                                  widget.carWash.queueLenght.toString(),
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
                              '≈${widget.carWash.startTime}',
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

                //! ТИП МАШИН
                TypeCar(),
                SizedBox(height: 20),
                Container(
                  height: 310,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  //! ОСНОВНЫЕ УСЛУГИ
                  child: ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: mainServices.length,
                    itemBuilder: (context, index) {
                      final service = mainServices[index];
                      return TarifsClientSection(
                        title: service.title,
                        subtitle: 'subtitle',
                        minutes: 'minutes',
                        price: '${service.price}₸',
                        onTap: () {
                          service.isSelected = !service.isSelected;
                          updateTotalPrice();
                        },
                        leading: Container(
                          padding: const EdgeInsets.all(2.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16.0),
                            border: Border.all(
                              color: Theme.of(context).colorScheme.secondary,
                              width: 5,
                            ),
                          ),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 20,
                            height: 20,
                            decoration:
                                service.isSelected
                                    ? BoxDecoration(
                                      color:
                                          Theme.of(
                                            context,
                                          ).colorScheme.secondary,
                                      borderRadius: BorderRadius.circular(10.0),
                                      border: Border.all(
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.secondary,
                                        width: 2,
                                      ),
                                    )
                                    : null,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 20),
                //! ДОП. УСЛУГИ
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
                Column(
                  children: [
                    ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: extraServices.length,
                      itemBuilder: (context, index) {
                        final service = extraServices[index];
                        return TarifsClientSection(
                          title: service.title,
                          subtitle: 'subtitle',
                          minutes: 'minutes',
                          price: '${service.price}₸',
                          onTap: () {
                            service.isSelected = !service.isSelected;
                            updateTotalPrice();
                          },
                          leading: Container(
                            padding: const EdgeInsets.all(2.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16.0),
                              border: Border.all(
                                color: Theme.of(context).colorScheme.secondary,
                                width: 5,
                              ),
                            ),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 20,
                              height: 20,
                              decoration:
                                  service.isSelected
                                      ? BoxDecoration(
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.secondary,
                                        borderRadius: BorderRadius.circular(
                                          10.0,
                                        ),
                                        border: Border.all(
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.secondary,
                                          width: 2,
                                        ),
                                      )
                                      : null,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
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
                        // final price
                        Text(
                          '${totalPrice.toString()} p',
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
