import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

class PhoneSignupScreen extends StatefulWidget {
  const PhoneSignupScreen({super.key});

  @override
  State<PhoneSignupScreen> createState() => _PhoneSignupScreenState();
}

class _PhoneSignupScreenState extends State<PhoneSignupScreen> {
  bool isClicked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: SvgPicture.asset(
            "assets/icons/arrow_back.svg",
            width: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          FocusScope.of(context).unfocus(); // Removes focus from TextFields
        },
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Регистрация",
                  style: Theme.of(context).textTheme.displayLarge,
                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 15,
                  children: [
                    Text(
                      "Введите номер телефона",
                      style: Theme.of(context).textTheme.displayMedium,
                    ),

                    Container(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      height: 65,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outline,
                          width: 4,
                        ),
                      ),
                      child: TextFormField(
                        style: TextStyle(fontSize: 20),
                        maxLength: 20,
                        decoration: InputDecoration(
                          counterText: "",
                          fillColor: Colors.white,
                          filled: true,
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide.none,
                          ),
                          label: Text("Номер телефона"),
                          labelStyle: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ),

                    Container(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      height: 65,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outline,
                          width: 4,
                        ),
                      ),
                      child: TextFormField(
                        style: TextStyle(fontSize: 20),
                        maxLength: 20,
                        obscureText: !isClicked,
                        decoration: InputDecoration(
                          counterText: "",
                          fillColor: Colors.white,
                          filled: true,
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide.none,
                          ),
                          label: Text("Придумайте пароль"),
                          labelStyle: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          suffixIcon: InkWell(
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
                        ),
                      ),
                    ),

                    Text(
                      "На данный номер телефона будет отправлен СМС-код для подтверждения",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),

                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    minimumSize: Size(double.infinity, 100),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.tertiary,
                        width: 5,
                      ),
                    ),
                  ),
                  onPressed: () {},
                  child: Text("Далее"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
