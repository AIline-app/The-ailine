import 'package:flutter/material.dart';
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
      title: 'Ailine',
      home: const MapHomeScreen(),
      initialRoute: AppRoutes.home,
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}
