import 'package:flutter/material.dart';
import 'package:gghgggfsfs/core/theme/app_theme.dart';
import 'package:gghgggfsfs/routes/app_route.dart';


void main() {
  runApp(AilineApp());
}

class AilineApp extends StatelessWidget {
  AilineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Ailine',
      theme: appTheme,
      routerConfig: router,
    );
  }
}
