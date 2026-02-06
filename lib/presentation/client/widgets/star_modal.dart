import 'package:flutter/material.dart';
import 'package:gghgggfsfs/core/theme/text_styles.dart';

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
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Оцените мойку",
                      style: AppTextStyles.caption,
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.more_vert,
                        color: Theme.of(context).colorScheme.onSecondary,
                        size: 26,
                      ),
                    ),
                  ],
                ),

                Text(
                  "Автомойка на Ленинском",
                  style: AppTextStyles.bold22,
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
                          size: 39,
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
