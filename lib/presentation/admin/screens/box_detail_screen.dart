import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:collection/collection.dart';
import 'package:openapi/openapi.dart';

import '../../../core/theme/text_styles.dart';
import '../../../core/widgets/custom_back_button.dart';
import '../../../data/bloc/box_store/box_cubit.dart';
import '../../../data/bloc/box_store/box_state.dart';
import '../../../data/bloc/orders_store/orders_cubit.dart';
import '../../../data/bloc/orders_store/orders_state.dart';
import 'overlays/car_confirmation.dart';

class BoxDetailPage extends StatefulWidget {
  const BoxDetailPage({super.key});

  @override
  State<BoxDetailPage> createState() => _BoxDetailPageState();
}

class _BoxDetailPageState extends State<BoxDetailPage> {
  String? _boxId;
  final carWashId = "d6f577e4-80f3-4fc5-ae9b-934e8f923ae5";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final arguments = ModalRoute.of(context)?.settings.arguments;
      if (arguments is String) {
        setState(() => _boxId = arguments);
        context.read<BoxesCubit>().loadBox(carWashId, _boxId!);
        context.read<OrdersCubit>().fetchOrders(carWashId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFEDEDED);

    return Scaffold(
      appBar: AppBar(
        leading: const CustomBackButton(),
        backgroundColor: bg,
        elevation: 0,
        shadowColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      backgroundColor: bg,
      body: SafeArea(
        child: BlocBuilder<BoxesCubit, BoxesState>(
          builder: (context, boxState) {
            if (boxState.loading) return const Center(child: CircularProgressIndicator());
            if (boxState.selectedBox == null) return const Center(child: Text('Бокс не найден'));

            final box = boxState.selectedBox!;

            return BlocBuilder<OrdersCubit, OrdersState>(
              builder: (context, ordersState) {
                final orders = ordersState is OrdersLoaded ? ordersState.orders : <OrdersRead>[];
                
                // Ищем активный заказ в этом боксе
                final activeOrder = orders.firstWhereOrNull(
                  (o) => o.box?['id'] == box.id && o.status == OrdersReadStatusEnum.inProgress,
                );

                // Очередь (заказы со статусом onSite)
                final queueOrders = orders.where((o) => o.status == OrdersReadStatusEnum.onSite).toList();

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        box.name ?? 'Бокс',
                        style: AppTextStyles.bold18Black,
                      ),
                      const SizedBox(height: 14),

                      if (activeOrder != null)
                        _BoxBigCard(
                          plate: activeOrder.car.number,
                          name: activeOrder.user.username ?? '—',
                          carType: 'Седан', // Можно заменить на реальный тип, если есть в API
                          serviceTitle: activeOrder.services.firstOrNull?.name ?? '—',
                          washer: activeOrder.washer?.username ?? '—',
                          timeLeft: _calculateTimeLeft(activeOrder),
                          onCallClient: () {},
                          onCallWasher: () {},
                        )
                      else
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1F3D59),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Center(
                            child: Text(
                              'Бокс свободен',
                              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),

                      const SizedBox(height: 14),

                      if (activeOrder != null)
                        SizedBox(
                          height: 50,
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2D8CFF),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('Завершить', style: AppTextStyles.buttonPrimary),
                          ),
                        ),

                      const SizedBox(height: 14),

                      _QueueMiniSection(items: queueOrders),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  String _calculateTimeLeft(OrdersRead order) {
    if (order.startedAt == null) return '00:00';
    try {
      final now = DateTime.now();
      final parts = order.duration.split(':');
      final duration = Duration(
        hours: int.parse(parts[0]),
        minutes: int.parse(parts[1]),
        seconds: int.parse(parts[2]),
      );
      final finishTime = order.startedAt!.add(duration);
      final remaining = finishTime.difference(now);
      
      if (remaining.isNegative) return 'Время вышло';
      
      final m = remaining.inMinutes.toString().padLeft(2, '0');
      final s = (remaining.inSeconds % 60).toString().padLeft(2, '0');
      return '$m:$s';
    } catch (_) {
      return '—:—';
    }
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
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3))],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: Text(plate, style: AppTextStyles.normal22w500)),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(name, style: AppTextStyles.bold14w800),
                  const SizedBox(height: 10),
                  _CallCircle(onTap: onCallClient),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Align(alignment: Alignment.centerLeft, child: Text(carType, style: AppTextStyles.bold16w600)),
          const SizedBox(height: 6),
          Align(alignment: Alignment.centerLeft, child: Text(serviceTitle, style: AppTextStyles.bold14w700grey)),
          const SizedBox(height: 16),
          Image.asset('assets/images/car_icon.png', height: 90, fit: BoxFit.contain),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Мойщик', style: AppTextStyles.bold22w700grey),
                  Text(washer, style: AppTextStyles.bold16w700),
                ],
              ),
              const Spacer(),
              _CallCircle(onTap: onCallWasher),
            ],
          ),
          const SizedBox(height: 12),
          Text(timeLeft, style: AppTextStyles.timer),
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
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2))],
        ),
        child: const Icon(Icons.call, color: Colors.white, size: 24),
      ),
    );
  }
}

class _QueueMiniSection extends StatelessWidget {
  const _QueueMiniSection({required this.items});
  final List<OrdersRead> items;

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
          const Text('На очереди', style: AppTextStyles.normal16w500),
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 12),
          if (items.isEmpty)
            const Text('Нет машин в очереди', style: TextStyle(color: Colors.grey))
          else
            ...items.asMap().entries.map((entry) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _MiniQueueTile(order: entry.value, showSetButton: entry.key == 0),
            )),
        ],
      ),
    );
  }
}

class _MiniQueueTile extends StatelessWidget {
  const _MiniQueueTile({required this.order, this.showSetButton = false});
  final OrdersRead order;
  final bool showSetButton;

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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(color: const Color(0xFF22B26B), borderRadius: BorderRadius.circular(10)),
                child: const Text('На месте', style: AppTextStyles.status),
              ),
              const SizedBox(height: 8),
              Text(order.car.number, style: AppTextStyles.queuePlate),
            ],
          ),
          const Spacer(),
          if (showSetButton)
            GestureDetector(
              onTap: () => showConfirmSetCarDialog(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(12)),
                child: const Text('Поставить', style: AppTextStyles.miniButton),
              ),
            ),
        ],
      ),
    );
  }
}
