import 'package:flutter/material.dart';
import 'package:gghgggfsfs/core/theme/color_schemes.dart';
import 'package:gghgggfsfs/core/widgets/custom_back_button.dart';
import 'package:gghgggfsfs/core/widgets/custom_button.dart';
import 'package:gghgggfsfs/core/widgets/custom_circle_checkbox.dart';
import 'package:gghgggfsfs/core/widgets/custom_text_field.dart';
import 'package:gghgggfsfs/core/widgets/main_text.dart';
import 'package:go_router/go_router.dart';

class CreateAdmin extends StatefulWidget {
  const CreateAdmin({super.key});

  @override
  State<CreateAdmin> createState() => _CreateAdminState();
}

class _CreateAdminState extends State<CreateAdmin> {
  List<Administrator> administrators = [
    Administrator(id: 1, name: 'Валера Валерьев', carWash: 'Автомойка 100'),
    Administrator(id: 2, name: 'Валера Валерьев', carWash: 'Автомойка 100'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: CustomBackButton()),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MainText(text: 'Администраторы'),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: administrators.length,
                itemBuilder: (context, index) {
                  final admin = administrators[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: _buildAdministratorCard(admin),
                  );
                },
              ),
            ),
            Container(
              width: double.infinity,
              child: TextButton(
                onPressed: () async {
                  final result = await _showAddAdministratorDialog();

                  final phone = result?['phone_number']?.trim();
                  final wash = result?['name_wash']?.trim();

                  if (phone != null &&
                      phone.isNotEmpty &&
                      wash != null &&
                      wash.isNotEmpty) {
                    setState(() {
                      administrators.add(
                        Administrator(
                          id: administrators.length + 1,
                          name: phone,
                          carWash: wash,
                        ),
                      );
                    });
                  }
                },
                style: TextButton.styleFrom(
                  overlayColor: Colors.transparent,
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  'Добавить администратора',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: customColorScheme.primary,
                    decoration: TextDecoration.underline,
                    decorationColor: customColorScheme.primary,
                    decorationThickness: 2,
                  ),
                ),
              ),
            ),
            SizedBox(height: 40),
            Text(
              'Вы можете изменить информацию\nпозже в личном кабинете',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
            SizedBox(height: 20),
            CustomButton(onPressed: _saveAdministrators, text: 'Сохранить'),
          ],
        ),
      ),
    );
  }

  Widget _buildAdministratorCard(Administrator admin) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  admin.name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  admin.carWash,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              _showDeleteConfirmation(admin);
            },
            style: TextButton.styleFrom(overlayColor: Colors.transparent),
            child: Text(
              'Удалить',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: customColorScheme.primary,
                decoration: TextDecoration.underline,
                decorationColor: customColorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<Map<String, String>?> _showAddAdministratorDialog() {
    final phoneController = TextEditingController();
    final washController = TextEditingController();

    return showDialog<Map<String, String>>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            margin: EdgeInsets.all(16),
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline,
                width: 3,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                CustomTextField(
                  labelText: 'Номер телефона',
                  textController: phoneController,
                  isClicked: true,
                ),
                SizedBox(height: 15),
                CustomTextField(
                  labelText: 'Название автомойки',
                  textController: washController,
                  isClicked: true,
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    CustomCircleCheckbox(),

                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Отправить ссылку для регистрации на WhatsApp',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => context.pop(),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor:
                              Theme.of(context).colorScheme.primary,
                          minimumSize: Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                              width: 3,
                            ),
                          ),
                        ),
                        child: Text(
                          'Отмена',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 15),
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          final phone = phoneController.text.trim();
                          final wash = washController.text.trim();

                          if (phone.isNotEmpty && wash.isNotEmpty) {
                            context.pop({
                              'phone_number': phone,
                              'name_wash': wash,
                            });
                          }
                        },
                        style: TextButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                          minimumSize: Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(
                              color: Theme.of(context).colorScheme.tertiary,
                              width: 3,
                            ),
                          ),
                        ),
                        child: Text(
                          'Сохранить',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(Administrator admin) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Удалить администратора'),
          content: Text('Вы уверены, что хотите удалить ${admin.name}?'),
          actions: [
            TextButton(onPressed: () => context.pop(), child: Text('Отмена')),
            TextButton(
              onPressed: () {
                setState(() {
                  administrators.removeWhere((a) => a.id == admin.id);
                });
                context.pop();
              },
              child: Text('Удалить', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _saveAdministrators() {
    print('Сохранение администраторов: ${administrators.length}');
    for (var admin in administrators) {
      print('ID: ${admin.id}, Имя: ${admin.name}, Автомойка: ${admin.carWash}');
    }

    context.pop();
  }
}

class Administrator {
  final int id;
  final String name;
  final String carWash;

  Administrator({required this.id, required this.name, required this.carWash});
}
