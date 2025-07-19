import 'package:flutter/material.dart';
import 'package:gghgggfsfs/core/widgets/custom_back_button.dart';
import 'package:gghgggfsfs/core/widgets/custom_button.dart';
import 'package:gghgggfsfs/core/widgets/custom_text_field.dart';
import 'package:gghgggfsfs/core/widgets/main_text.dart';
import 'package:go_router/go_router.dart';

class DirectorAuth extends StatefulWidget {
  const DirectorAuth({super.key});

  @override
  State<DirectorAuth> createState() => _DirectorAuthState();
}

class _DirectorAuthState extends State<DirectorAuth> {
  String? startTime;
  String? endTime;

  Future<void> _selectTime(bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          startTime = picked.format(context);
        } else {
          endTime = picked.format(context);
        }
      });
    }
  }

  Widget _buildTimeBox({
    required String label,
    required String? time,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          height: 65,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline,
              width: 4,
            ),
          ),
          child: Center(
            child: Text(
              time ?? label,
              style: TextStyle(
                fontSize: 16,
                color: time == null ? Colors.grey : Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: CustomBackButton()),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          FocusScope.of(context).unfocus(); // Removes focus from TextFields
        },
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MainText(text: 'Подключение автомойки'),
                  SizedBox(height: 40),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 25,
                    children: [
                      CustomTextField(labelText: "ТОО/ИИН"),

                      CustomTextField(labelText: "Название"),
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        height: 65,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outline,
                            width: 4,
                          ),
                        ),
                        child: TextFormField(
                          style: TextStyle(fontSize: 20),
                          maxLength: 20,

                          decoration: InputDecoration(
                            counterText: "",
                            fillColor: Colors.white,
                            filled: true,
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide.none,
                            ),
                            label: Text(' Адрес'),
                            labelStyle: TextStyle(color: Colors.grey),
                            suffixIcon: Material(
                              shape: CircleBorder(),
                              clipBehavior: Clip.hardEdge,
                              child: Ink.image(
                                image: AssetImage('assets/icons/2gis.png'),
                                width: 30,
                              ),
                            ),
                          ),
                        ),
                      ),
                      MainText(text: 'Укажите время\nработы автомойки'),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          //! startTime
                          _buildTimeBox(
                            label: 'Начало',
                            time: startTime,
                            onTap: () => _selectTime(true),
                          ),
                          SizedBox(width: 20),
                          //! endTime
                          _buildTimeBox(
                            label: 'Конец',
                            time: endTime,
                            onTap: () => _selectTime(false),
                          ),
                          const SizedBox(width: 16),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        height: 65,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outline,
                            width: 4,
                          ),
                        ),
                        child: TextFormField(
                          style: TextStyle(fontSize: 20),
                          maxLength: 20,

                          decoration: InputDecoration(
                            counterText: "",
                            fillColor: Colors.white,
                            filled: true,
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide.none,
                            ),
                            label: Text('Количество слотов'),
                            labelStyle: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),

                      Container(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        height: 65,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outline,
                            width: 4,
                          ),
                        ),
                        child: TextFormField(
                          style: TextStyle(fontSize: 20),
                          maxLength: 20,

                          decoration: InputDecoration(
                            counterText: "",
                            fillColor: Colors.white,
                            filled: true,
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide.none,
                            ),
                            label: Text('Процент выплаты мойщикам'),
                            labelStyle: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),

                  CustomButton(
                    text: "Далее",
                    onPressed: () {
                      context.push('/add_service');
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
