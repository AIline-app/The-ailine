import 'package:flutter/material.dart';
import 'package:theIline/core/widgets/custom_button.dart';
import 'package:theIline/core/widgets/custom_text_field.dart';

import '../../../core/widgets/custom_back_button.dart';

class AddWashersPage extends StatelessWidget {
  const AddWashersPage({super.key});

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFEFEFEF);
    const primary = Color(0xFF2D8CFF);
    const text = Color(0xFF284457);


    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        leading: CustomBackButton(),
        backgroundColor: bg,
        elevation: 0,
        shadowColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 110),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const SizedBox(height: 22),

                  const Text(
                    'Мойщики',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      color: text,
                    ),
                  ),

                  const SizedBox(height: 12),
                  CustomTextField(labelText: 'Имя Фамилия'),
                  const SizedBox(height: 12),
                  CustomTextField(labelText: 'Номер телефона')
                ],
              ),
            ),

            Positioned(
              left: 18,
              right: 18,
              bottom: 18,
              child: CustomButton(text: 'Готово', onPressed: () {  },),
            ),
          ],
        ),
      ),
    );
  }
}