import 'package:flutter/material.dart';
import 'package:gghgggfsfs/core/theme/color_schemes.dart';
import 'package:gghgggfsfs/core/widgets/custom_back_button.dart';
import 'package:gghgggfsfs/core/widgets/custom_button.dart';
import 'package:gghgggfsfs/core/widgets/custom_checkbox.dart';
import 'package:gghgggfsfs/core/widgets/custom_text_field.dart';
import 'package:gghgggfsfs/core/widgets/type_car_button.dart';
import 'package:gghgggfsfs/presentation/client/screens/payment_screen.dart';
import 'package:gghgggfsfs/routes.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

class CarSignupScreen extends StatefulWidget {
  const CarSignupScreen({super.key});

  @override
  State<CarSignupScreen> createState() => _CarSignupScreenState();
}

class _CarSignupScreenState extends State<CarSignupScreen> {
  bool isClicked = false;
  int selectedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: CustomBackButton(),
        backgroundColor: Colors.white,
        elevation: 0,           // убирает тень
        shadowColor: Colors.transparent, // гарантированно убирает тень
        foregroundColor: Colors.black,   // цвет текста и иконок
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          FocusScope.of(context).unfocus(); // Removes focus from TextFields
        },
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Регистрация",
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                  SizedBox(height: 25),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomTextField(labelText: "Как вас зовут?"),
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
                  SizedBox(height: 25),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Информация о машине",
                        style: Theme.of(context).textTheme.displayMedium,
                      ),
                      SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TypeCarButton(
                            onPressed: () {
                              setState(() {
                                selectedIndex = 0;
                              });
                            },
                            text: 'седан',
                            textColor:
                                selectedIndex == 0
                                    ? Colors.white
                                    : customColorScheme.primary,
                            backgroundColor:
                                selectedIndex == 0
                                    ? customColorScheme.primary
                                    : Colors.transparent,
                          ),
                          TypeCarButton(
                            onPressed: () {
                              setState(() {
                                selectedIndex = 1;
                              });
                            },
                            text: 'джип',
                            textColor:
                                selectedIndex == 1
                                    ? Colors.white
                                    : customColorScheme.primary,
                            backgroundColor:
                                selectedIndex == 1
                                    ? customColorScheme.primary
                                    : Colors.transparent,
                          ),
                          TypeCarButton(
                            onPressed: () {
                              setState(() {
                                selectedIndex = 2;
                              });
                            },
                            text: 'минивен',
                            textColor:
                                selectedIndex == 2
                                    ? Colors.white
                                    : customColorScheme.primary,
                            backgroundColor:
                                selectedIndex == 2
                                    ? customColorScheme.primary
                                    : Colors.transparent,
                          ),
                        ],
                      ),
                      SizedBox(height: 15),
                      CustomTextField(labelText: "Номер машины"),
                    ],
                  ),
                  SizedBox(height: 25),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Уведомления",
                        style: Theme.of(context).textTheme.displayMedium,
                      ),
                      SizedBox(height: 15),
                      Text(
                        "За какой период вам напомнить о записи?",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      SizedBox(height: 15),
                      CustomSlider(),
                    ],
                  ),
                  SizedBox(height: 25),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Выберите мессенджер для отправки уведомлений ",
                        style: Theme.of(context).textTheme.displayMedium,
                      ),
                      SizedBox(height: 15),

                      Row(
                        children: [
                          CustomCheckboxWidget(),
                          SizedBox(width: 10),
                          Text(
                            "Telegram",
                            style: Theme.of(context).textTheme.displaySmall,
                          ),
                        ],
                      ),
                      SizedBox(height: 15),
                      Row(
                        children: [
                          CustomCheckboxWidget(),
                          SizedBox(width: 10),
                          Text(
                            "WhatsApp",
                            style: Theme.of(context).textTheme.displaySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 25),
                  CustomButton(
                    text: "Зарегистрироваться",
                    onPressed: () {
                      
                       Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PaymentScreen(),
                        ),
                      );
                    },
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

class CustomSlider extends StatefulWidget {
  const CustomSlider({super.key});

  @override
  State<CustomSlider> createState() => _CustomSliderState();
}

class _CustomSliderState extends State<CustomSlider> {
  double _currentValue = 20;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(8, 6, 8, 20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "При записи в живую очередь",
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
          Stack(
            alignment: Alignment.centerLeft,
            children: [
              // Left dot
              const Positioned(left: 5, child: Dot()),
              // Right dot
              const Positioned(right: 5, child: Dot()),

              // Slider
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  thumbShape: LabelBelowThumbShape(context: context),
                  overlayShape: SliderComponentShape.noOverlay,
                ),
                child: Slider(
                  value: _currentValue,
                  min: 0,
                  max: 60,
                  divisions: 6,
                  activeColor: Theme.of(context).colorScheme.onPrimary,
                  onChanged: (val) {
                    setState(() {
                      _currentValue = val;
                    });
                  },
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _currentValue != 0
                    ? Icon(
                      Icons.remove,
                      color: Theme.of(context).colorScheme.onPrimary,
                    )
                    : SizedBox(),
                _currentValue != 60
                    ? Icon(
                      Icons.add,
                      color: Theme.of(context).colorScheme.onPrimary,
                    )
                    : SizedBox(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Dot extends StatelessWidget {
  const Dot({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onPrimary,
        borderRadius: BorderRadius.circular(9),
      ),
    );
  }
}

class LabelBelowThumbShape extends SliderComponentShape {
  final double thumbRadius;
  final BuildContext context;

  LabelBelowThumbShape({this.thumbRadius = 16.0, required this.context});

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) =>
      Size.fromRadius(thumbRadius);

  @override
  void paint(
    PaintingContext cntx,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter? labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = cntx.canvas;

    // Draw the thumb (circle)
    final Paint thumbPaint =
        Paint()
          ..color = sliderTheme.thumbColor ?? Colors.blue
          ..style = PaintingStyle.fill;

    canvas.drawCircle(center, thumbRadius, thumbPaint);

    final double actualValue = 0 + (value * (60 - 0));

    // Draw the label BELOW the thumb
    final textSpan = TextSpan(
      text:
          actualValue == 0 && actualValue == 60
              ? ""
              : "≈${(actualValue).toInt()} минут",
      style: Theme.of(context).textTheme.displaySmall?.copyWith(
        color: Theme.of(context).colorScheme.onPrimary,
      ),
    );

    // (value * 100).toInt().toString()
    final TextPainter tp = TextPainter(
      text: textSpan,
      textAlign: TextAlign.center,
      textDirection: textDirection,
    )..layout();

    final Offset labelOffset = Offset(
      center.dx - tp.width / 2,
      center.dy + thumbRadius + 6, // 6px spacing below thumb
    );

    tp.paint(canvas, labelOffset);
  }
}
