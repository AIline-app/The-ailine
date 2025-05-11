
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gghgggfsfs/core/theme/app_theme.dart';
import 'package:gghgggfsfs/presentation/client/screens/map_home_screen.dart';
import 'package:gghgggfsfs/routes.dart';

void main() {
  runApp(AilineApp());
  
}

class AilineApp extends StatelessWidget {
  const AilineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ailine',
      home: const MapHomeScreen(),
      theme: appTheme,
      initialRoute: AppRoutes.home,
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}
