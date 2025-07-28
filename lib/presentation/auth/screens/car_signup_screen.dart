import 'package:flutter/material.dart';
import 'package:gghgggfsfs/core/localization/generated/l10n.dart';
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
                    S.current.common_register,
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                  SizedBox(height: 25),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomTextField(
                        labelText: S.current.common_what_is_your_name,
                      ),
                      SizedBox(height: 15),
                      CustomTextField(
                        labelText: S.current.common_create_password,
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
                        S.current.common_sms_verification_info,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  SizedBox(height: 25),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        S.current.common_vehicle_info,
                        style: Theme.of(context).textTheme.displayMedium,
                      ),
                      SizedBox(height: 15),
                      CustomTextField(labelText: S.current.common_car_number),
                    ],
                  ),
                  SizedBox(height: 25),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        S.current.common_notifications,
                        style: Theme.of(context).textTheme.displayMedium,
                      ),
                      SizedBox(height: 15),
                      Text(
                        S.current.common_reminder_period,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  SizedBox(height: 25),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        S.current.common_choose_messenger,
                        style: Theme.of(context).textTheme.displayMedium,
                      ),
                      SizedBox(height: 15),
                      Row(
                        children: [
                          CustomCheckboxWidget(),
                          SizedBox(width: 10),
                          Text(
                            S.current.common_telegram,
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
                            S.current.common_whatsapp,
                            style: Theme.of(context).textTheme.displaySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 25),
                  CustomButton(
                    text: S.current.common_registration,
                    onPressed: () {
                      /* after the e lelopment of a pagt Страница ввода карточных /анных  */
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
