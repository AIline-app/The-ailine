import 'package:flutter/material.dart';
import 'package:theIline/routes.dart';

import '../../../core/theme/text_styles.dart';
import '../../../core/widgets/custom_back_button.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import 'overlays/add_service.dart';

class AddCarCategoryPage extends StatelessWidget {
  const AddCarCategoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFF1F2F3);
    const primary = Color(0xFF2D8CFF);
    const text = Color(0xFF284457);
    const muted = Color(0xFF6D7780);

    final services = <_ServiceItem>[
      _ServiceItem(
        title: 'Стандарт',
        desc: 'Пена, вода, сушка',
        minutes: 30,
        price: 550,
      ),
      _ServiceItem(
        title: 'Ультра',
        desc: 'Пена, вода, сушка, воск',
        minutes: 45,
        price: 850,
      ),
      _ServiceItem(
        title: 'Ультра',
        desc: 'Пена, вода, сушка, воск',
        minutes: 45,
        price: 850,
      ),
    ];

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        leading: CustomBackButton(),
        backgroundColor: bg,
        elevation: 0,
        shadowColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // контент
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 110),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Добавление категории\nавто',
                    style: AppTextStyles.title,
                  ),

                  const SizedBox(height: 16),
                  const CustomTextField(labelText: 'Название кузова'),
                  const SizedBox(height: 12),
                  const CustomTextField(labelText: 'Описание категории'),
                  const SizedBox(height: 14),

                  // Список услуг
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        for (int i = 0; i < services.length; i++) ...[
                          _ServiceRow(
                            item: services[i],
                            onMenuTap: () {
                              // TODO: show menu (редактировать/удалить)
                            },
                          ),
                          if (i != services.length - 1)
                            const Divider(height: 1, thickness: 1, color: Color(0xFFD9DEE3)),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  InkWell(
                    onTap: () {
                      showAddServiceDialog(context);
                    },
                    child: Row(
                      children: const [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: primary,
                          child: Icon(Icons.add, size: 16, color: Colors.white),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Добавить услугу',
                          style: TextStyle(
                            color: muted,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  const Text(
                    'Добавить новую категорию авто',
                    style: TextStyle(
                      color: primary,
                      fontWeight: FontWeight.w900,
                      fontSize: 20,
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    'Вы можете изменить информацию\nпозже в личном кабинете',
                    style: TextStyle(
                      color: muted,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),

            Positioned(
              left: 18,
              right: 18,
              bottom: 18,
              child: CustomButton(
                text: 'Сохранить',
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.addCard);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceItem {
  _ServiceItem({
    required this.title,
    required this.desc,
    required this.minutes,
    required this.price,
  });

  final String title;
  final String desc;
  final int minutes;
  final int price;
}

class _ServiceRow extends StatelessWidget {
  const _ServiceRow({
    required this.item,
    required this.onMenuTap,
  });

  final _ServiceItem item;
  final VoidCallback onMenuTap;

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF2D8CFF);
    const text = Color(0xFF284457);
    const muted = Color(0xFF6D7780);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // left
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    color: text,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.desc,
                  style: const TextStyle(
                    color: muted,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // right: minutes + price + menu
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${item.minutes} мин',
                    style: const TextStyle(
                      color: text,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: onMenuTap,
                    child: const Icon(Icons.more_vert, color: primary, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${item.price}р',
                style: const TextStyle(
                  color: primary,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
