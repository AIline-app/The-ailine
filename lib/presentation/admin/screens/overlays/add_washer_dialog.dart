
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:theIline/core/widgets/custom_button.dart';
import 'package:theIline/routes.dart';

class AddWasherDialog extends StatelessWidget {
  const AddWasherDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 18),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Добавить автомойщика',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1F3D59),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Чтобы продолжить работу в системе,\nнеобходимо добавить хотя бы одного\nавтомойщика',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.black38,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 14),
            CustomButton(onPressed: () {
              Navigator.pushNamed(context, AppRoutes.washers);
              }, text: 'Добавить'),
          ],
        ),
      ),
    );
  }
}