import 'package:flutter/material.dart';
import 'package:gghgggfsfs/presentation/client/screens/map_home_screen.dart';

class CarWashTimeModal extends StatelessWidget {
  const CarWashTimeModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.more_vert,
                        color: Theme.of(context).colorScheme.onSecondary,
                        size: 32,
                      ),
                    ),
                  ],
                ),

                Text(
                  "Машина моется, осталось:",
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSecondary,
                  ),
                ),

                Text(
                  "≈21мин",
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSecondary,
                  ),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      "Позвонить администратору",
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSecondary,
                      ),
                    ),
                    SizedBox(width: 20),
                    GestureDetector(
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(context).colorScheme.tertiary,
                            width: 5,
                          ),
                        ),
                        child: Icon(Icons.phone_outlined, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 20),

          ArrivalHint(
            text:
                'Для подстраховки, рекомендуем приехать  на 20 минут раньше окончания обратного отсчёта',
          ),
        ],
      ),
    );
  }
}
