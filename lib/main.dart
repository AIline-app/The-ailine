import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:theIline/core/theme/app_theme.dart';
import 'package:theIline/core/widgets/skeleton_container.dart';
import 'package:theIline/data/bloc/popup_store/popup_bloc.dart';
import 'package:theIline/presentation/admin/screens/add_car.dart';
import 'package:theIline/presentation/admin/screens/archives.dart';
import 'package:theIline/presentation/admin/screens/box_detail_screen.dart';
import 'package:theIline/presentation/admin/screens/main_screen.dart';
import 'package:theIline/presentation/auth/screens/phone_signup_screen.dart';
import 'package:theIline/presentation/client/screens/car_wash_detail_screen.dart';
import 'package:theIline/presentation/client/screens/map_home_screen.dart';
import 'package:theIline/presentation/client/screens/on_boarding.dart';
import 'package:theIline/routes.dart';

void main() {
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<PopUpBloc>(
          create: (_) => PopUpBloc(),
        ),
      ],
      child: const AilineApp(),
    ),
  );
}

class AilineApp extends StatelessWidget {
  const AilineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ailine',
      home: SkeletonContainer(child:  AdminMainPage()),
      theme: appTheme,
      initialRoute: AppRoutes.home,
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}
