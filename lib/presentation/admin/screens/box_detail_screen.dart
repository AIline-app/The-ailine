import 'package:flutter/material.dart';

import '../../../core/theme/text_styles.dart';
import '../../../core/widgets/custom_back_button.dart';
import 'overlays/car_confirmation.dart';

class BoxDetailPage extends StatelessWidget {
  const BoxDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFEDEDED);

    return Scaffold(
      appBar: AppBar(
        leading: CustomBackButton(),
        backgroundColor: bg,
        elevation: 0,
        shadowColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      backgroundColor: bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Text(
                'Бокс 3',
                style: AppTextStyles.bold18Black,
              ),

              const SizedBox(height: 14),

              _BoxBigCard(
                plate: 'Ш298АН',
                name: 'Алексей',
                carType: 'Седан',
                serviceTitle: 'Быстрая мойка',
                washer: 'Иван',
                timeLeft: '28:34',
                onCallClient: () {},
                onCallWasher: () {},
              ),

              const SizedBox(height: 14),

              SizedBox(
                height: 50,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2D8CFF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Завершить',
                    style: AppTextStyles.buttonPrimary,
                  ),
                ),
              ),

              const SizedBox(height: 14),

              _QueueMiniSection(
                items: const [
                  _MiniQueueVm(plate: 'P783MT', status: 'На месте', showSetButton: true),
                  _MiniQueueVm(plate: 'У837ЛД'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SquareIconButton extends StatelessWidget {
  const _SquareIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 66,
        height: 66,
        decoration: BoxDecoration(
          color: const Color(0xFF2D8CFF),
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 34),
      ),
    );
  }
}

class _BoxBigCard extends StatelessWidget {
  const _BoxBigCard({
    required this.plate,
    required this.name,
    required this.carType,
    required this.serviceTitle,
    required this.washer,
    required this.timeLeft,
    required this.onCallClient,
    required this.onCallWasher,
  });

  final String plate;
  final String name;
  final String carType;
  final String serviceTitle;
  final String washer;
  final String timeLeft;
  final VoidCallback onCallClient;
  final VoidCallback onCallWasher;

  @override
  Widget build(BuildContext context) {
    const dark = Color(0xFF1F3D59);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: dark,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  plate,
                  style: AppTextStyles.normal22w500,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    name,
                    style: AppTextStyles.bold14w800,
                  ),
                  const SizedBox(height: 10),
                  _CallCircle(onTap: onCallClient),
                ],
              ),
            ],
          ),

          const SizedBox(height: 10),

          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              carType,
              style: AppTextStyles.bold16w600,
            ),
          ),

          const SizedBox(height: 6),

          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              serviceTitle,
              style: AppTextStyles.bold14w700grey,
            ),
          ),

          const SizedBox(height: 16),

          Image.asset(
            'assets/images/car_icon.png',
            height: 90,
            fit: BoxFit.contain,
          ),

          const SizedBox(height: 14),

          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Мойщик',
                    style: AppTextStyles.bold22w700grey,
                  ),
                  Text(
                    washer,
                    style: AppTextStyles.bold16w700,
                  ),
                ],
              ),
              const Spacer(),
              _CallCircle(onTap: onCallWasher),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            timeLeft,
            style: AppTextStyles.timer,
          ),
        ],
      ),
    );
  }
}

class _CallCircle extends StatelessWidget {
  const _CallCircle({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF2D8CFF),
          border: Border.all(color: const Color(0xFF7AC0FF), width: 4),
          boxShadow: const [
            BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2)),
          ],
        ),
        child: const Icon(Icons.call, color: Colors.white, size: 24),
      ),
    );
  }
}

class _QueueMiniSection extends StatelessWidget {
  const _QueueMiniSection({required this.items});

  final List<_MiniQueueVm> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'На очереди',
            style: AppTextStyles.normal16w500,
          ),
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 12),

          ...items.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _MiniQueueTile(vm: e),
          )),
        ],
      ),
    );
  }
}

class _MiniQueueTile extends StatelessWidget {
  const _MiniQueueTile({required this.vm});

  final _MiniQueueVm vm;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFD9E6F2),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (vm.status != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF22B26B),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    vm.status!,
                    style: AppTextStyles.status,
                  ),
                ),
              const SizedBox(height: 8),
              Text(
                vm.plate,
                style: AppTextStyles.queuePlate,
              ),
            ],
          ),
          const Spacer(),
          if (vm.showSetButton)
            GestureDetector(
              onTap: () {
                showConfirmSetCarDialog(context);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Поставить',
                  style: AppTextStyles.miniButton,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MiniQueueVm {
  const _MiniQueueVm({
    required this.plate,
    this.status,
    this.showSetButton = false,
  });

  final String plate;
  final String? status;
  final bool showSetButton;
}
