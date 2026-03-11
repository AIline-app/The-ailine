import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:theIline/core/widgets/custom_button.dart';
import 'package:openapi/openapi.dart';

import '../../../core/theme/text_styles.dart';
import '../../../core/widgets/custom_back_button.dart';
import '../../../data/bloc/earnings_store/earnings_cubit.dart';
import '../../../data/bloc/earnings_store/earnings_state.dart';
import '../../../data/bloc/carwash_store/carwash_cubit.dart';
import '../../../data/bloc/carwash_store/carwash_state.dart';
import '../../../routes.dart';
import '../widgets/calendar.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _rangeStart = DateTime.now().subtract(const Duration(days: 7));
  DateTime? _rangeEnd = DateTime.now();
  String? _carWashId;

  String _fmtDate(DateTime d) => DateFormat('dd.MM.yyyy').format(d);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final arguments = ModalRoute.of(context)?.settings.arguments;
      if (arguments is String) {
        setState(() => _carWashId = arguments);
        _loadData();
      }
    });
  }

  void _loadData() {
    if (_carWashId != null && _rangeStart != null) {
      context.read<EarningsCubit>().loadCarWashEarnings(
        carWashId: _carWashId!,
        dateFrom: _rangeStart!,
        dateTo: _rangeEnd,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFF1F2F3);
    const primary = Color(0xFF2D8CFF);
    const text = Color(0xFF284457);

    final rangeText = (_rangeStart != null && _rangeEnd != null)
        ? '${_fmtDate(_rangeStart!)}-${_fmtDate(_rangeEnd!)}'
        : 'Выберите период';

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        leading: const CustomBackButton(),
        backgroundColor: bg,
        elevation: 0,
        shadowColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: SafeArea(
        child: BlocBuilder<EarningsCubit, EarningsState>(
          builder: (context, state) {
            CarWashEarningsRead? earnings;
            bool isLoading = state is EarningsLoading;

            if (state is CarWashEarningsLoaded) {
              earnings = state.earnings;
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BlocBuilder<CarWashCubit, CarWashState>(
                    builder: (context, carWashState) {
                      String washName = 'Мойка';
                      if (carWashState is CarWashLoaded && _carWashId != null) {
                        final wash = carWashState.items.firstWhere((element) => element.id == _carWashId);
                        washName = wash.name;
                      }
                      return Text(
                        washName,
                        style: AppTextStyles.title,
                      );
                    },
                  ),

                  const SizedBox(height: 14),

                  // Revenue card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF3F7),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'Выручка',
                            style: TextStyle(color: text, fontWeight: FontWeight.w900),
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (isLoading)
                          const Center(child: CircularProgressIndicator())
                        else
                          Text(
                            '${_formatMoney(earnings?.revenue ?? 0)} тг',
                            style: const TextStyle(
                              fontSize: 56,
                              fontWeight: FontWeight.w900,
                              color: primary,
                              height: 1.0,
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    'Предупреждение: вывести за раз можно сумму в размере не менее 5 000 тенге и не более 2 000 000 тг.\n'
                    'Обратите внимание, что сумма высчитывается по заказам и при превышении максимума остаток останется на счету.',
                    style: TextStyle(
                      fontSize: 12.5,
                      height: 1.25,
                      color: Color(0xFF6D7780),
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 12),

                  CustomButton(onPressed: () {}, text: 'Вывести'),

                  const SizedBox(height: 14),
                  CalendarCard(
                    focusedDay: _focusedDay,
                    rangeStart: _rangeStart,
                    rangeEnd: _rangeEnd,
                    onRangeSelected: (start, end, focused) {
                      setState(() {
                        _rangeStart = start;
                        _rangeEnd = end;
                        _focusedDay = focused;
                      });
                      _loadData();
                    },
                    onPageChanged: (focused) => setState(() => _focusedDay = focused),
                  ),

                  const SizedBox(height: 12),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.keyboard_arrow_up, color: primary, size: 28),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                rangeText,
                                textAlign: TextAlign.right,
                                style: const TextStyle(color: text, fontWeight: FontWeight.w900),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        
                        if (earnings != null)
                          Wrap(
                            spacing: 16,
                            children: earnings.byCarTypes.map((e) => Text(
                              '${e.ordersCount} ${e.carType}',
                              style: const TextStyle(color: text, fontWeight: FontWeight.w800),
                            )).toList(),
                          ),
                        
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Spacer(),
                            Text(
                              '${_formatMoney(earnings?.revenue ?? 0)} тг',
                              style: const TextStyle(
                                color: primary,
                                fontWeight: FontWeight.w900,
                                fontSize: 34,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: const [
                            Text(
                              'Сумма за период',
                              style: TextStyle(color: text, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  CustomButton(
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.addCarCategory);
                    },
                    text: 'Добавить категорию',
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

String _formatMoney(int v) {
  final s = v.toString();
  final buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    final left = s.length - i;
    buf.write(s[i]);
    if (left > 1 && left % 3 == 1) buf.write(' ');
  }
  return buf.toString();
}
