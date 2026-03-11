import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openapi/openapi.dart';

import '../../../core/api_client/api_client.dart';
import '../../../core/theme/text_styles.dart';
import '../../../data/bloc/box_store/box_cubit.dart';
import '../../../data/bloc/box_store/box_repository.dart';
import '../../../data/bloc/box_store/box_state.dart';
import '../../../data/bloc/carwash_queue_store/carwash_queue_cubit.dart';
import '../../../data/bloc/carwash_queue_store/carwash_queue_state.dart';
import '../../../data/bloc/orders_store/orders_cubit.dart';
import '../../../data/bloc/orders_store/orders_state.dart';
import '../../../routes.dart';
import 'overlays/add_washer_dialog.dart';
import 'overlays/change_car.dart';

class AdminMainPage extends StatefulWidget {
  const AdminMainPage({super.key});

  @override
  State<AdminMainPage> createState() => _AdminMainPageState();
}

class _AdminMainPageState extends State<AdminMainPage> {
  late BoxesCubit _boxesCubit;
  int? expandedQueueIndex;

  @override
  void initState() {
    super.initState();
    const carWashId = "d6f577e4-80f3-4fc5-ae9b-934e8f923ae5";
    
    _boxesCubit = BoxesCubit(
      BoxesRepository(ApiProvider.instance.api.getBoxesApi()),
    )..loadBoxes(carWashId);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<CarWashQueueCubit>().loadQueue(carWashId);
        context.read<OrdersCubit>().fetchOrders(carWashId);
      }
    });
  }

  @override
  void dispose() {
    _boxesCubit.close();
    super.dispose();
  }

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
    return BlocProvider.value(
      value: _boxesCubit,
      child: Scaffold(
        backgroundColor: bg,
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Expanded(
                      child: Text(
                        'Автомойка Капля',
                        style: AppTextStyles.title,
                      ),
                    ),
                    BlocBuilder<CarWashQueueCubit, CarWashQueueState>(
                      builder: (context, state) {
                        if (state is CarWashQueueLoaded) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                padding: const EdgeInsets.only(right: 40, left: 20),
                                child: Text(
                                  '${state.queue.carAmount} машин',
                                  style: AppTextStyles.bold14w800.copyWith(color: Colors.black),
                                ),
                              ),
                            ],
                          );
                        }
                        if (state is CarWashQueueLoading) {
                          return const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Column(
                    children: [
                      // Boxes Grid
                      BlocBuilder<OrdersCubit, OrdersState>(
                        builder: (context, ordersState) {
                          final allOrders = ordersState is OrdersLoaded ? ordersState.orders : <OrdersRead>[];
                          
                          return BlocBuilder<BoxesCubit, BoxesState>(
                            builder: (context, state) {
                              if (state.loading) {
                                return const Center(child: CircularProgressIndicator());
                              }
                              if (state.error != null) {
                                return Center(child: Text('Ошибка: ${state.error}'));
                              }
                              final boxes = state.boxes;
                              if (boxes.isEmpty) {
                                return const Center(child: Text('Боксов не найдено'));
                              }

                              return GridView.builder(
                                itemCount: boxes.length,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 14,
                                  crossAxisSpacing: 14,
                                  childAspectRatio: 1.2,
                                ),
                                itemBuilder: (context, i) {
                                  final box = boxes[i];
                                  // Ищем активный заказ для этого бокса
                                  final activeOrder = allOrders.firstWhereOrNull(
                                    (o) => o.box?['id'] == box.id && o.status == OrdersReadStatusEnum.inProgress,
                                  );
                                  
                                  return _BoxCard(
                                    box: box,
                                    order: activeOrder,
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),

                      const SizedBox(height: 16),

                      BlocBuilder<OrdersCubit, OrdersState>(
                        builder: (context, state) {
                          if (state is OrdersLoading) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (state is OrdersError) {
                            return Center(child: Text('Ошибка: ${state.message}'));
                          }
                          if (state is OrdersLoaded) {
                            return _QueueSection(
                              expandedIndex: expandedQueueIndex,
                              items: state.orders,
                              onTapItem: (i) {
                                setState(() {
                                  expandedQueueIndex = (expandedQueueIndex == i) ? null : i;
                                });
                              },
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),

                      const SizedBox(height: 16),

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
                              SizedBox(width: 4),
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
      ),
    );
  }
}

class _BoxCard extends StatelessWidget {
  const _BoxCard({required this.box, this.order});

  final Box box;
  final OrdersRead? order;
  static const blue = Color(0xFF58AFFF);

  double _calculateProgress(OrdersRead order) {
    if (order.startedAt == null) return 0.0;
    
    try {
      final now = DateTime.now();
      final diff = now.difference(order.startedAt!);
      
      // Парсим длительность "HH:mm:ss"
      final parts = order.duration.split(':');
      final duration = Duration(
        hours: int.parse(parts[0]),
        minutes: int.parse(parts[1]),
        seconds: int.parse(parts[2]),
      );
      
      if (duration.inSeconds == 0) return 1.0;
      return (diff.inSeconds / duration.inSeconds).clamp(0.0, 1.0);
    } catch (_) {
      return 0.5; // Дефолт если ошибка парсинга
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasOrder = order != null;
    final progress = hasOrder ? _calculateProgress(order!) : 0.0;
    final plate = order?.car.number ?? '';
    final person = order?.user.username ?? '';

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, AppRoutes.boxDetail, arguments: box.id);
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1F3D59),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))],
        ),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          children: [
            // Синяя заливка прогресса
            if (hasOrder)
              Align(
                alignment: Alignment.bottomCenter,
                child: FractionallySizedBox(
                  heightFactor: progress,
                  widthFactor: 1,
                  child: Container(color: blue),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(box.name!, style: AppTextStyles.bold16w600),
                  if (hasOrder) ...[
                    const SizedBox(height: 4),
                    Text(person, style: AppTextStyles.bold14w800.copyWith(fontSize: 12)),
                    const Spacer(),
                    Text(plate, style: AppTextStyles.bold18),
                  ] else ...[
                    const Spacer(),
                    const Text(
                      'Свободен',
                      style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ],
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

  final List<OrdersRead> items;
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
                style: AppTextStyles.bold22Black,
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
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
          if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text('Очередь пуста', style: AppTextStyles.normal14),
            )
          else
            ListView.separated(
              itemCount: items.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final isExpanded = expandedIndex == i;
                return _QueueItem(
                  order: items[i],
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
    required this.order,
    required this.expanded,
    required this.onTap,
  });

  final OrdersRead order;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
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
          child: expanded ? _ExpandedQueue(order: order) : _CollapsedQueue(order: order),
        ),
      ),
    );
  }
}

class _CollapsedQueue extends StatelessWidget {
  const _CollapsedQueue({required this.order});

  final OrdersRead order;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          order.car.number,
          style: AppTextStyles.bold18Black,
        ),
        const Spacer(),
        if (order.status != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: _getStatusColor(order.status!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _getStatusText(order.status!),
              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
            ),
          ),
      ],
    );
  }

  Color _getStatusColor(OrdersReadStatusEnum status) {
    switch (status) {
      case OrdersReadStatusEnum.enRoute: return Colors.orange;
      case OrdersReadStatusEnum.onSite: return Colors.blue;
      case OrdersReadStatusEnum.inProgress: return Colors.blueAccent;
      case OrdersReadStatusEnum.completed: return Colors.green;
      case OrdersReadStatusEnum.canceled: return Colors.red;
      default: return Colors.grey;
    }
  }

  String _getStatusText(OrdersReadStatusEnum status) {
    switch (status) {
      case OrdersReadStatusEnum.enRoute: return 'В пути';
      case OrdersReadStatusEnum.onSite: return 'На месте';
      case OrdersReadStatusEnum.inProgress: return 'Моется';
      case OrdersReadStatusEnum.completed: return 'Завершено';
      case OrdersReadStatusEnum.canceled: return 'Отменено';
      default: return status.value;
    }
  }
}

class _ExpandedQueue extends StatelessWidget {
  const _ExpandedQueue({required this.order});

  final OrdersRead order;

  @override
  Widget build(BuildContext context) {
    final userName = (order.user.username ?? '').trim();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (order.status != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF22B26B),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              _getStatusText(order.status!),
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ),

        const SizedBox(height: 10),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              order.car.number,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F3D59),
                height: 1.0,
              ),
            ),
            const Spacer(),
            if (userName.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  userName,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF1F3D59)),
                ),
              ),
          ],
        ),

        const SizedBox(height: 14),

        Row(
          children: [
            Text(
              order.car.number,
              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: Color(0xFF2D8CFF)),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.edit, size: 11, color: Color(0xFF2D8CFF)),
            const Spacer(),
            _CircleIconButton(icon: Icons.call, onTap: () {}),
          ],
        ),

        const SizedBox(height: 12),

        ...order.services.map((s) => Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            children: [
              const Text('• ', style: TextStyle(fontSize: 11, color: Colors.black54)),
              Text(s.name, style: const TextStyle(fontSize: 11, color: Colors.black54)),
            ],
          ),
        )),

        const SizedBox(height: 10),

        if (order.washer != null)
          Row(
            children: [
              const Text('Мойщик  ', style: TextStyle(fontSize: 11, color: Colors.black54)),
              Text(
                order.washer!.username.toString(),
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF1F3D59)),
              ),
              const Spacer(),
              _CircleIconButton(icon: Icons.call, onTap: () {}),
            ],
          ),
      ],
    );
  }

  String _getStatusText(OrdersReadStatusEnum status) {
    switch (status) {
      case OrdersReadStatusEnum.enRoute: return 'В пути';
      case OrdersReadStatusEnum.onSite: return 'На месте';
      case OrdersReadStatusEnum.inProgress: return 'Моется';
      case OrdersReadStatusEnum.completed: return 'Завершено';
      case OrdersReadStatusEnum.canceled: return 'Отменено';
      default: return status.value;
    }
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
