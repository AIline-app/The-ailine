import 'package:flutter/material.dart';
import 'package:gghgggfsfs/routes.dart';
import '../../data/model_car_wash/model_car_wash.dart';

class CarWashCard extends StatelessWidget {
  final CarWashModel carWash;
  final bool isSelected;

  const CarWashCard({
    super.key,
    required this.carWash,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 10),
      padding: const EdgeInsets.all(0),
      width: MediaQuery.of(context).size.width * 0.7,
       height: 160, 
      decoration: BoxDecoration(
        color: isSelected ? Colors.orange.shade50 : Colors.white,
        border: Border.all(
          color: isSelected ? Colors.orange : Colors.transparent,
          width: 3,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, AppRoutes.details);
        },
        child: ClipRRect(
            borderRadius: BorderRadius.circular(13),
            child: Stack(
              fit: StackFit.expand,
              children: [
 
                Image.asset(
                  'assets/images/card_car.jpg',
                  fit: BoxFit.cover,
                ),

                Container(
                  color: Colors.black.withOpacity(0.4),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${carWash.distance.toInt()} метров от вас',
                        style: const TextStyle(fontSize: 12, color: Colors.white70),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        carWash.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Перед вами: ${carWash.queueLenght} машин',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            '${carWash.slots} бокса',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: List.generate(
                          5,
                          (index) => Icon(
                            index < carWash.rating.round()
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.orange,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

      ),
    );
  }
}
