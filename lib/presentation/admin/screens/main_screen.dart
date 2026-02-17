import 'package:flutter/material.dart';

import '../../../core/theme/text_styles.dart';
import '../../../routes.dart';
import 'overlays/add_washer_dialog.dart';
import 'overlays/change_car.dart';

class AdminMainPage extends StatefulWidget {
  const AdminMainPage({super.key});

  @override
  State<AdminMainPage> createState() => _AdminMainPageState();
}

class _AdminMainPageState extends State<AdminMainPage> {

  int? expandedQueueIndex;

  final boxes = <BoxVm>[
    BoxVm(id: 1, name: 'Бокс 1', person: 'Алексей', plate: 'Ы780ШЛ', progress: 0.35),
    BoxVm(id: 2, name: 'Бокс 2', person: 'Алексей', plate: 'H798ПР', progress: 0.75),
    BoxVm(id: 3, name: 'Бокс 3', person: 'Алексей', plate: 'Ш298АН', progress: 0.55),
    BoxVm(id: 4, name: 'Бокс 4', person: '', plate: 'ВРЕМЯ\nВЫШЛО', isOverdue: true, overdueTime: '04:24'),
    BoxVm(id: 5, name: 'Бокс 5', person: 'Алексей', plate: 'P783MT', progress: 0.45),
    BoxVm(id: 6, name: 'Бокс 6', person: 'Алексей', plate: 'У837ЛД', progress: 0.65),
  ];

  final queue = <QueueVm>[
    QueueVm(
      plate: 'P783MT',
      name: 'Алексей',
      status: 'На месте',
      carType: 'Седан',
      services: const ['Стандарт', 'Покрытие воском'],
      washer: 'Иван',
    ),
    QueueVm(plate: 'У837ЛД', name: '', status: '', carType: '', services: const [], washer: ''),
    QueueVm(plate: 'B819OA', name: '', status: 'Оплачено', carType: '', services: const [], washer: '', rightTag: 'Опаздывает'),
  ];

  void showAddWasherDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.35),
      builder: (_) => const AddWasherDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFEDEDED);
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 10,),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Автомойка Капля',
                  style: AppTextStyles.title,
                ),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Column(
                  children: [
                    GridView.builder(
                      itemCount: boxes.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 14,
                        crossAxisSpacing: 14,
                        childAspectRatio: 1.2,
                      ),
                      itemBuilder: (context, i) => _BoxCard(vm: boxes[i]),
                    ),

                    const SizedBox(height: 16),

                    // Queue section
                    _QueueSection(
                      expandedIndex: expandedQueueIndex,
                      items: queue,
                      onTapItem: (i) {
                        setState(() {
                          expandedQueueIndex = (expandedQueueIndex == i) ? null : i;
                        });
                      },
                    ),

                    const SizedBox(height: 16),

                    // Bottom big button
                    SizedBox(
                      height: 50,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          showAddWasherDialog(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2D8CFF),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Добавить',
                              style: AppTextStyles.bold16w600,
                            ),
                            SizedBox(width: 12),
                            Icon(Icons.add, size: 28, color: Colors.white),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
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
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))],
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}

class _BoxCard extends StatelessWidget {
  const _BoxCard({required this.vm});

  final BoxVm vm;
  static const dark = Color(0xFF1F3D59);
  static const blue = Color(0xFF58AFFF);


  @override
  Widget build(BuildContext context) {

      return GestureDetector(
        onTap: (){
          Navigator.pushNamed(context, AppRoutes.boxDetail);
        },
        child: Container(
          decoration: BoxDecoration(
            color: vm.isOverdue ? const Color(0xFFF1A022) : Color(0xFF1F3D59),
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))],
          ),
          clipBehavior: Clip.hardEdge,
          child: Stack(
            children: [
              Align(
                alignment: Alignment.bottomCenter,
                child: FractionallySizedBox(
                  heightFactor: (vm.progress ?? 0.0).clamp(0.0, 1.0),
                  widthFactor: 1,
                  child: Container(color: blue),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(vm.name, style: AppTextStyles.bold16w600),
                    const SizedBox(height: 4),
                    Text(vm.person, style: AppTextStyles.bold14w800),
                    const Spacer(),
                    Text(
                      vm.plate,
                      style: AppTextStyles.bold18,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
  }
}

class _QueueSection extends StatelessWidget {
  const _QueueSection({
    required this.items,
    required this.expandedIndex,
    required this.onTapItem,
  });

  final List<QueueVm> items;
  final int? expandedIndex;
  final void Function(int index) onTapItem;

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
        children: [
          Row(
            children: [
              const Text(
                'На очереди',
                style: AppTextStyles.bold22,
              ),
              const Spacer(),
              GestureDetector(
                onTap: (){
                  Navigator.pushNamed(context, AppRoutes.archives);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF2D8CFF),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  child: const Text(
                    'Архив',
                    style: AppTextStyles.normal14white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1),

          const SizedBox(height: 12),

          ListView.separated(
            itemCount: items.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final isExpanded = expandedIndex == i;
              return _QueueItem(
                vm: items[i],
                expanded: isExpanded,
                onTap: () => onTapItem(i),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _QueueItem extends StatelessWidget {
  const _QueueItem({
    required this.vm,
    required this.expanded,
    required this.onTap,
  });

  final QueueVm vm;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // collapsed height как на первом скрине
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: const Color(0xFFD9E6F2),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
        border: expanded ? Border.all(color: const Color(0xFF2D8CFF), width: 2) : null,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: expanded ? _ExpandedQueue(vm: vm) : _CollapsedQueue(vm: vm),
        ),
      ),
    );
  }
}

class _CollapsedQueue extends StatelessWidget {
  const _CollapsedQueue({required this.vm});

  final QueueVm vm;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          vm.plate,
          style: AppTextStyles.bold18Black,
        ),
        const Spacer(),
        if ((vm.rightTag ?? '').isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(color: const Color(0xFFB33A26), borderRadius: BorderRadius.circular(8)),
            child: Text(
              vm.rightTag!,
              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
            ),
          ),
      ],
    );
  }
}

class _ExpandedQueue extends StatelessWidget {
  const _ExpandedQueue({required this.vm});

  final QueueVm vm;

  Future<void> showChooseBodyDialog(
      BuildContext context, {
        String initialValue = 'Седан',
      }) async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.35),
      builder: (_) => ChooseBodyDialog(initialValue: initialValue),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if ((vm.status ?? '').isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(color: const Color(0xFF22B26B), borderRadius: BorderRadius.circular(10)),
            child: Text(vm.status!, style: const TextStyle(color: Colors.white, fontSize: 3, fontWeight: FontWeight.w700)),
          ),

        const SizedBox(height: 10),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              vm.plate,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F3D59),
                height: 1.0,
              ),
            ),
            const Spacer(),
            if ((vm.name ?? '').isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  vm.name!,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF1F3D59)),
                ),
              ),
          ],
        ),

        const SizedBox(height: 14),

        if ((vm.carType ?? '').isNotEmpty)
          GestureDetector(
            onTap: (){
              showChooseBodyDialog(context);
            },
            child: Row(
              children: [
                Text(
                  vm.carType!,
                  style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: Color(0xFF2D8CFF)),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.edit, size: 11, color: Color(0xFF2D8CFF)),
                const Spacer(),
                _CircleIconButton(icon: Icons.call, onTap: () {}),
              ],
            ),
          ),

        const SizedBox(height: 12),

        ...vm.services.map((s) => Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            children: [
              const Text('• ', style: TextStyle(fontSize: 11, color: Colors.black54)),
              Text(s, style: const TextStyle(fontSize: 11, color: Colors.black54)),
            ],
          ),
        )),

        const SizedBox(height: 10),

        if ((vm.washer ?? '').isNotEmpty)
          Row(
            children: [
              const Text('Мойщик  ', style: TextStyle(fontSize: 11, color: Colors.black54)),
              Text(vm.washer!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF1F3D59))),
              const Spacer(),
              _CircleIconButton(icon: Icons.call, onTap: () {}),
            ],
          ),
      ],
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFF2D8CFF),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))],
        ),
        child: Icon(icon, color: Colors.white, size: 19),
      ),
    );
  }
}

/// -------------------- View models --------------------

class BoxVm {
  BoxVm({
    required this.id,
    required this.name,
    this.person = '',
    this.plate = '',
    this.progress,
    this.isOverdue = false,
    this.overdueTime,
  });

  final int id;
  final String name;
  final String person;
  final String plate;

  /// 0..1 — чем больше, тем больше синяя заливка (время/прогресс)
  final double? progress;

  final bool isOverdue;
  final String? overdueTime;
}

class QueueVm {
  QueueVm({
    required this.plate,
    this.name,
    this.status,
    this.carType,
    required this.services,
    this.washer,
    this.rightTag,
  });

  final String plate;
  final String? name;
  final String? status;   // "На месте" / "Оплачено" и т.п.
  final String? carType;  // "Седан"
  final List<String> services;
  final String? washer;   // "Иван"
  final String? rightTag;
}
