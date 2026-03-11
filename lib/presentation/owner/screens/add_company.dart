import 'package:flutter/material.dart';
import 'package:theIline/core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/widgets/custom_back_button.dart';

class AddCompanyDataPage extends StatelessWidget {
  const AddCompanyDataPage({super.key});

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFF1F2F3);
    const primary = Color(0xFF2D8CFF);
    const text = Color(0xFF284457);
    const muted = Color(0xFF6D7780);

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
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 110),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Добавление данные\nкомпании',
                    style: AppTextStyles.title,
                  ),

                  const SizedBox(height: 18),

                  const CustomTextField(labelText: 'Название ИП или ТОО'),
                  const SizedBox(height: 12),
                  const CustomTextField(labelText: 'ИИН или БИН'),
                  const SizedBox(height: 12),
                  const CustomTextField(labelText: 'Юридический адрес'),
                  const SizedBox(height: 12),
                  const CustomTextField(labelText: 'Расчётный счёт'),

                  const SizedBox(height: 42),

                  const Text(
                    'Вы можете изменить информацию\nпозже в личном кабинете',
                    style: TextStyle(
                      color: muted,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),

            Positioned(
              left: 18,
              right: 18,
              bottom: 18,
              child: CustomButton(
                text: 'Сохранить',
                onPressed: () {
                  // TODO: save
                  // Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
