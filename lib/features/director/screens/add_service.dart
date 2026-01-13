import 'package:flutter/material.dart';
import 'package:gghgggfsfs/core/localization/generated/l10n.dart';
import 'package:gghgggfsfs/core/resources/colors/app_colors.dart';
import 'package:gghgggfsfs/core/widgets/custom_back_button.dart';
import 'package:gghgggfsfs/core/widgets/custom_button.dart';
import 'package:gghgggfsfs/core/widgets/main_text.dart';
import 'package:gghgggfsfs/core/widgets/type_car_button.dart';
import 'package:gghgggfsfs/features/director/widgets/tarifs_director.dart';

class AddService extends StatefulWidget {
  const AddService({super.key});

  @override
  State<AddService> createState() => _AddServiceState();
}

class _AddServiceState extends State<AddService> {
  int selectedIndex = -1;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: CustomBackButton()),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MainText(text: S.current.common_add_service),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TypeCarButton(
                  onPressed: () {
                    setState(() {
                      selectedIndex = 0;
                    });
                  },
                  text: S.current.common_car_type_sedan,
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
                  text: S.current.common_car_type_suv,
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
                  text: S.current.common_car_type_minivan,
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
            SizedBox(height: 20),
            Column(
              children: [
                TarifsDirector(
                  title: S.current.common_standard,
                  subtitle: S.current.common_tariff_description,
                  minutes: '30 мин',
                  price: '500р',
                ),
                TarifsDirector(
                  title: S.current.common_standard,
                  subtitle: S.current.common_tariff_description,
                  minutes: '30 мин',
                  price: '500р',
                ),
                TarifsDirector(
                  title: S.current.common_standard,
                  subtitle: S.current.common_tariff_description,
                  minutes: '30 мин',
                  price: '500р',
                ),
                TarifsDirector(
                  title: S.current.common_standard,
                  subtitle: S.current.common_tariff_description,
                  minutes: '30 мин',
                  price: '500р',
                ),
              ],
            ),
            SizedBox(height: 15),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(overlayColor: Colors.transparent),
              child: Text(
                S.current.common_add_service,
                style: TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.w600,
                  color: customColorScheme.primary,
                ),
              ),
            ),
            Positioned(
              bottom: 2,
              left: 20,
              child: Container(
                width: 250,
                height: 2,
                color: customColorScheme.primary,
              ),
            ),
            SizedBox(height: 90),
            Text(
              S.current.common_edit_later_info,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            SizedBox(height: 20),
            CustomButton(onPressed: () {}, text: S.current.common_save),
          ],
        ),
      ),
    );
  }
}
