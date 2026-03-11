
import 'package:flutter/material.dart';
import 'package:openapi/openapi.dart';
import 'package:theIline/data/bloc/login_view_model/login_repository.dart';
import 'package:theIline/data/bloc/login_view_model/login_repository_imp.dart';
import 'package:theIline/presentation/auth/screens/login_screen.dart';
import 'package:theIline/presentation/auth/screens/phone_signup_screen.dart';

import '../../../presentation/client/themes/main_colors.dart';
import '../../../routes.dart';

class NoAuthorized extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            width: 36,
            height: 3,
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(100),
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => LoginPage(
                  repo: AuthRepositoryImpl(),
                ),
              ),
            );
          },
          child: const Text(
            'Вход',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: MainColors.mainBlue,
            ),
          ),
        ),
        //const Divider(height: 1, thickness: 0.6, color: Colors.black26),

        TextButton(
          onPressed: () {
            Navigator.pushNamed(context, AppRoutes.reg);
          },
          child: const Text(
            'Регистрация',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: MainColors.mainBlue,
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.pushNamed(context, AppRoutes.home);
          },
          child: const Text(
            'Клиент',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: MainColors.mainBlue,
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.pushNamed(context, AppRoutes.adminHome);
          },
          child: const Text(
            'Администратор',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: MainColors.mainBlue,
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.pushNamed(context, AppRoutes.ownerHome);
          },
          child: const Text(
            'Владелец',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: MainColors.mainBlue,
            ),
          ),
        ),
      ],
    );
  }
}