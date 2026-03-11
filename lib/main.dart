import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:theIline/core/theme/app_theme.dart';
import 'package:theIline/core/widgets/skeleton_container.dart';
import 'package:theIline/data/bloc/box_store/box_cubit.dart';
import 'package:theIline/data/bloc/box_store/box_repository.dart';
import 'package:theIline/data/bloc/cart_store/cart_cubit.dart';
import 'package:theIline/data/bloc/car_types_store/car_types_cubit.dart';
import 'package:theIline/data/bloc/car_types_store/car_types_repository.dart';
import 'package:theIline/data/bloc/carwash_queue_store/carwash_queue_cubit.dart';
import 'package:theIline/data/bloc/carwash_queue_store/carwash_queue_repository.dart';
import 'package:theIline/data/bloc/carwash_store/carwash_repository.dart';
import 'package:theIline/data/bloc/earnings_store/earnings_cubit.dart';
import 'package:theIline/data/bloc/earnings_store/earnings_repository.dart';
import 'package:theIline/data/bloc/orders_store/orders_cubit.dart';
import 'package:theIline/data/bloc/orders_store/orders_repository.dart';
import 'package:theIline/data/bloc/popup_store/popup_bloc.dart';
import 'package:theIline/data/bloc/services_store/services_cubit.dart';
import 'package:theIline/data/bloc/services_store/services_repository.dart';
import 'package:theIline/data/bloc/user_store/user_cubit.dart';
import 'package:theIline/presentation/auth/screens/login_screen.dart';
import 'package:theIline/presentation/client/screens/map_home_screen.dart';
import 'package:theIline/routes.dart';

import 'core/api_client/api_client.dart';
import 'data/bloc/carwash_detail_store/carwash_detail_cubit.dart';
import 'data/bloc/carwash_store/carwash_cubit.dart';
import 'data/bloc/loader_model/loader_cubit.dart';
import 'data/bloc/login_view_model/login_repository_imp.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiProvider.instance.init();

  final hasToken = (ApiProvider.instance.apiKeyAuth.sessionToken ?? '').isNotEmpty;

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => CarWashRepository()),
        RepositoryProvider(create: (_) => BoxesRepository(ApiProvider.instance.api.getBoxesApi())),
        RepositoryProvider(create: (_) => CarWashQueueRepository(ApiProvider.instance.api.getCarWashApi())),
        RepositoryProvider(create: (_) => CarTypesRepository(ApiProvider.instance.api.getCarTypesApi())),
        RepositoryProvider(create: (_) => ServicesRepository(ApiProvider.instance.api.getServicesApi())),
        RepositoryProvider(create: (_) => OrdersRepository(ApiProvider.instance.api.getOrdersApi())),
        RepositoryProvider(create: (_) => EarningsRepository(ApiProvider.instance.api.getEarningsApi())),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => PopUpBloc()),
          BlocProvider(create: (context) => CarWashCubit(context.read<CarWashRepository>())),
          BlocProvider(create: (_) => LoaderCubit()),
          BlocProvider(create: (_) => UserCubit()),
          BlocProvider(create: (_) => CartCubit()),
          BlocProvider(
            create: (context) => CarWashQueueCubit(context.read<CarWashQueueRepository>()),
          ),
          BlocProvider(
            create: (context) => CarTypesCubit(context.read<CarTypesRepository>()),
          ),
          BlocProvider(
            create: (context) => ServicesCubit(context.read<ServicesRepository>()),
          ),
          BlocProvider(
            create: (context) => OrdersCubit(context.read<OrdersRepository>()),
          ),
          BlocProvider(
            create: (context) => EarningsCubit(context.read<EarningsRepository>()),
          ),
          BlocProvider(
            create: (context) => BoxesCubit(context.read<BoxesRepository>()),
          ),
          BlocProvider(create: (context) => CarWashDetailCubit(context.read<CarWashRepository>())),
        ],
        child: AilineApp(hasToken: hasToken),
      ),
    ),
  );
}

class AilineApp extends StatelessWidget {
  const AilineApp({super.key, required this.hasToken});
  final bool hasToken;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ailine',
      theme: appTheme,
      home: SkeletonContainer(
        child: hasToken
            ? const MapHomeScreen()
            : LoginPage(repo: AuthRepositoryImpl()),
      ),
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}
