import 'package:flutter/material.dart';
import 'package:gghgggfsfs/core/resources/colors/app_colors.dart';
import 'package:gghgggfsfs/core/widgets/type_car_button.dart';

class TypeCar extends StatefulWidget {
  const TypeCar({super.key});

  @override
  State<TypeCar> createState() => _TypeCarState();
}

class _TypeCarState extends State<TypeCar> {
  final carTypes = ['седан', 'джип', 'минивен'];
  int selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(carTypes.length, (index) {
        final isSelected = selectedIndex == index;
        return TypeCarButton(
          onPressed: () {
            setState(() {
              selectedIndex = index;
            });
          },
          text: carTypes[index],
          textColor: isSelected ? Colors.white : customColorScheme.primary,
          backgroundColor:
              isSelected ? customColorScheme.primary : Colors.transparent,
        );
      }),
    );
  }
}
