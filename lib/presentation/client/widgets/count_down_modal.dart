
import 'package:flutter/material.dart';
import 'package:theIline/presentation/client/screens/map_home_screen.dart';

class CountDownModal extends StatelessWidget {
  const CountDownModal({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "±30 мин ",
                      style: Theme.of(
                        context,
                      ).textTheme.displaySmall?.copyWith(
                        color:
                            Theme.of(
                              context,
                            ).colorScheme.onSecondary,
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.more_vert,
                        color:
                            Theme.of(
                              context,
                            ).colorScheme.onSecondary,
                        size: 32,
                      ),
                    ),
                  ],
                ),
    
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
    
                  children: [
                    Text(
                      "Времени осталось",
                      style: Theme.of(
                        context,
                      ).textTheme.labelSmall?.copyWith(
                        color:
                            Theme.of(
                              context,
                            ).colorScheme.onSecondary,
                      ),
                    ),
    
                    Text(
                      "Машин в очереди",
                      style: Theme.of(
                        context,
                      ).textTheme.labelSmall?.copyWith(
                        color:
                            Theme.of(
                              context,
                            ).colorScheme.onSecondary,
                      ),
                    ),
                  ],
                ),
    
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
    
                  children: [
                    Text(
                      "≈01:02:01",
                      style: Theme.of(
                        context,
                      ).textTheme.displayLarge?.copyWith(
                        color:
                            Theme.of(
                              context,
                            ).colorScheme.onSecondary,
                      ),
                    ),
    
                    Text(
                      "9",
                      style: Theme.of(
                        context,
                      ).textTheme.displayMedium?.copyWith(
                        color:
                            Theme.of(
                              context,
                            ).colorScheme.onSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
    
          SizedBox(height: 6),
    
          ArrivalHint(
            text:
                'По прибытию на автомойку нажмите пожалуйста  на кнопку "Я на месте".',
          ),
    
          SizedBox(height: 6),
    
          Container(
            height: 45,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.grey.shade300,
                width: 5,
              ),
            ),
            child: TabBar(
              labelPadding: const EdgeInsets.symmetric(
                horizontal: 0,
              ),
              indicator: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(8),
              ),
              dividerColor: Colors.transparent,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.black,
              indicatorSize: TabBarIndicatorSize.tab,
              tabs: const [
                Tab(text: 'В пути'),
                Tab(text: 'Я на месте'),
              ],
            ),
          ),
    
          SizedBox(height: 6),
    
          ArrivalHint(
            text:
                "Для подстраховки, рекомендуем приехать  на 20 минут раньше окончания обратного отсчёта",
          ),
        ],
      ),
    );
  }
}