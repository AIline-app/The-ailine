import 'package:flutter/material.dart';

class StarModal extends StatefulWidget {
  const StarModal({super.key});

  @override
  State<StarModal> createState() => _StarModalState();
}

class _StarModalState extends State<StarModal> {
  final int maxStars = 5;

  int currentRating = 0;
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
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Оцените мойку",
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSecondary,
                      ),
                    ),
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
                  "Автомойка на Ленинском",
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSecondary,
                  ),
                ),

                Row(
                  children: List.generate(maxStars, (index) {
                    final starIndex = index + 1;
                    return Expanded(
                      child: IconButton(
                        icon: Icon(
                          starIndex <= currentRating
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.white,
                          size: 60,
                        ),
                        onPressed: () {
                          setState(() {
                            currentRating = starIndex;
                          });
                        },
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
