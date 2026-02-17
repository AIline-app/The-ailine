
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:theIline/core/widgets/tarifs_section.dart';

class CarTarifs extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Container(
            height: 310,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
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
          );
  }
}