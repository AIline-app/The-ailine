import 'package:flutter/material.dart';
import 'package:openapi/openapi.dart';
import 'package:theIline/routes.dart';

class CarWashCard extends StatelessWidget {
  final CarWashPrivateRead carWash;
  final bool isSelected;
  final VoidCallback? onTap;

  const CarWashCard({
    super.key,
    required this.carWash,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final boxesCount = carWash.boxes.length;
    final isActive = carWash.isActive;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 10),
      width: MediaQuery.of(context).size.width * 0.7,
      height: 180,
      decoration: BoxDecoration(
        color: isSelected ? Colors.orange.shade50 : Colors.white,
        border: Border.all(
          color: isSelected ? Colors.orange : Colors.transparent,
          width: 3,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: GestureDetector(
        onTap: onTap ?? () {
          Navigator.pushNamed(
            context,
            AppRoutes.details,
            arguments: carWash.id,
          );
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

              // затемнение
              Container(
                color: Colors.black.withOpacity(isActive ? 0.4 : 0.6),
              ),

              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      carWash.location?.trim().isNotEmpty == true
                          ? carWash.location!
                          : 'Локация не указана',
                      style: const TextStyle(fontSize: 12, color: Colors.white70),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // вместо title
                    Text(
                      carWash.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 6),

                    Text(
                      carWash.address,
                      style: const TextStyle(fontSize: 13, color: Colors.white70),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const Spacer(),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [

                        const Text(
                          'Очередь: —',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),

                        Text(
                          '$boxesCount бокса',
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // вместо rating (если хочешь — скрывай блок полностью)
                    Row(
                      children: [
                        ...List.generate(
                          5,
                              (_) => const Icon(
                            Icons.star_border,
                            color: Colors.orange,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'нет рейтинга',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // бейдж "неактивна"
              if (!isActive)
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    margin: const EdgeInsets.all(10),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text(
                      'Неактивна',
                      style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
