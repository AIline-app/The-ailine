import 'package:flutter/material.dart';
import '../../data/model_car_wash/model_car_wash.dart';

class CarWashCard extends StatelessWidget {
  final CarWashModel carWash;
  final bool isSelected;

  const CarWashCard({
    Key? key,
    required this.carWash,
    this.isSelected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      padding: const EdgeInsets.all(16),
      width: MediaQuery.of(context).size.width * 0.7,
      decoration: BoxDecoration(
        color: isSelected ? Colors.orange.shade50 : Colors.white,
        border: Border.all(
          color: isSelected ? Colors.orange : Colors.transparent,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${carWash.distance.toInt()} метров от вас',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            carWash.name,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Перед вами: ${carWash.queueLength} машин',
                style: const TextStyle(color: Colors.blue, fontSize: 14),
              ),
              Text(
                '${carWash.boxCount} бокса',
                style: const TextStyle(color: Colors.blue, fontSize: 14),
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
    );
  }
}
