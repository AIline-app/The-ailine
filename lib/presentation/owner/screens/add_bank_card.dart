import 'package:flutter/material.dart';
import 'package:theIline/core/widgets/custom_button.dart';
import 'package:theIline/routes.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/widgets/custom_back_button.dart';

class AddBankCardPage extends StatefulWidget {
  const AddBankCardPage({super.key});

  @override
  State<AddBankCardPage> createState() => _AddBankCardPageState();
}

class _AddBankCardPageState extends State<AddBankCardPage> {
  bool remember = false;

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
                    'Добавление счета\nбанковской карты',
                    style: AppTextStyles.title
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    'для взимания подписки',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: text,
                    ),
                  ),

                  const SizedBox(height: 16),

                  const CustomTextField(labelText: 'Номер карты'),

                  const SizedBox(height: 12),

                  Row(
                    children: const [
                      Expanded(child: CustomTextField(labelText: 'Дата')),
                      SizedBox(width: 12),
                      Expanded(child: CustomTextField(labelText: 'CVV')),
                    ],
                  ),

                  const SizedBox(height: 12),

                  const CustomTextField(labelText: 'IVAN IVANOV'),

                  const SizedBox(height: 14),

                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => setState(() => remember = !remember),
                        child: Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFFE48A13), width: 2),
                          ),
                          child: remember
                              ? const Icon(Icons.check, size: 16, color: Color(0xFFE48A13))
                              : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Запомнить данные карты',
                        style: TextStyle(
                          color: text,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

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
                  Navigator.pushNamed(context, AppRoutes.addCompany);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
