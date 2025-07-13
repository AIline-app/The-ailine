import 'package:flutter/material.dart';
import 'package:gghgggfsfs/core/theme/color_schemes.dart';
import 'package:gghgggfsfs/core/widgets/custom_back_button.dart';
import 'package:gghgggfsfs/core/widgets/custom_button.dart';
import 'package:gghgggfsfs/core/widgets/custom_checkbox.dart';
import 'package:gghgggfsfs/core/widgets/custom_text_field.dart';
import 'package:gghgggfsfs/core/widgets/main_text.dart';
import 'package:gghgggfsfs/core/widgets/type_car.dart';
import 'package:gghgggfsfs/features/director/widgets/tarifs_director_section.dart';
import 'package:go_router/go_router.dart';

class AddService extends StatefulWidget {
  const AddService({super.key});

  @override
  State<AddService> createState() => _AddServiceState();
}

class _AddServiceState extends State<AddService> {
  final carTypes = ['седан', 'джип', 'минивен'];
  int selectedIndex = 0;
  List<Map<String, dynamic>> services = [
    {
      'title': 'Стандарт',
      'subtitle': 'Пена, вода, сушка',
      'minutes': '30 мин',
      'price': '500р',
      'isAdditional': false,
    },
    {
      'title': 'Премиум',
      'subtitle': 'Пена, вода, сушка, воск',
      'minutes': '45 мин',
      'price': '800р',
      'isAdditional': false,
    },
    {
      'title': 'Полировка',
      'subtitle': 'Детальная полировка',
      'minutes': '120 мин',
      'price': '2000р',
      'isAdditional': true,
    },
  ];

  void _addNewService(Map<String, dynamic> newService) {
    print('Добавляем новую услугу: $newService');
    setState(() {
      services.add(newService);
    });
    print('Общее количество услуг: ${services.length}');
  }

  void _deleteService(int index) {
    print('Удаляем услугу с индексом: $index');
    print('Услуга: ${services[index]}');
    setState(() {
      services.removeAt(index);
    });
    print('Осталось услуг: ${services.length}');
  }

  void _editService(int index, Map<String, dynamic> updatedService) {
    print('Редактируем услугу с индексом: $index');
    print('Старые данные: ${services[index]}');
    print('Новые данные: $updatedService');
    setState(() {
      services[index] = updatedService;
    });
  }

  bool _validateServiceData(Map<String, dynamic> serviceData) {
    return serviceData['title'] != null &&
        serviceData['title'].toString().trim().isNotEmpty &&
        serviceData['subtitle'] != null &&
        serviceData['subtitle'].toString().trim().isNotEmpty &&
        serviceData['minutes'] != null &&
        serviceData['minutes'].toString().trim().isNotEmpty &&
        serviceData['price'] != null &&
        serviceData['price'].toString().trim().isNotEmpty;
  }

  void _saveAllServices() {
    print('Сохраняем все услуги: $services');
    context.go('/create_card');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(leading: CustomBackButton()),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const MainText(text: 'Добавление услуг'),
              const SizedBox(height: 30),
              const TypeCar(), // ТИП МАШИН
              const SizedBox(height: 20),
              Column(
                children: [
                  ...services.asMap().entries.map((entry) {
                    int index = entry.key;
                    Map<String, dynamic> service = entry.value;
                    return Column(
                      children: [
                        TarifsDirector(
                          title: service['title']!,
                          subtitle: service['subtitle']!,
                          minutes: service['minutes']!,
                          price: service['price']!,
                          onEdit: () {
                            _showEditServiceModal(context, index, service);
                          },
                          onDelete: () {
                            _deleteService(index);
                          },
                        ),
                        if (index < services.length - 1)
                          Divider(
                            color: Colors.grey.shade300,
                            thickness: 1,
                            indent: 15,
                            endIndent: 15,
                          ),
                      ],
                    );
                  }),
                ],
              ),
              const SizedBox(height: 15),
              GestureDetector(
                onTap: () {
                  _showAddServiceModal(context);
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Добавить услугу',
                      style: TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.w600,
                        color: customColorScheme.primary,
                      ),
                    ),
                    Container(
                      width: 240,
                      height: 2,
                      color: customColorScheme.primary,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 160),
              Text(
                "Вы можете изменить информацию позже в личном кабинете",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 20),
              CustomButton(onPressed: _saveAllServices, text: 'Сохранить'),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddServiceModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ModalWindow(
          onSave: (result) {
            print('Получили результат из модального окна: $result');
            _addNewService({
              'title': result['name']!,
              'subtitle': result['description']!,
              'minutes': result['time']!,
              'price': result['price']!,
              'isAdditional': result['isAdditional'] ?? false,
            });
          },
        );
      },
    );
  }

  void _showEditServiceModal(
    BuildContext context,
    int index,
    Map<String, dynamic> service,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ModalWindow(
          initialValues: {
            'name': service['title']!,
            'description': service['subtitle']!,
            'time': service['minutes']!,
            'price': service['price']!,
            'isAdditional': service['isAdditional'] ?? false,
          },
          onSave: (result) {
            print('Получили результат редактирования: $result');
            _editService(index, {
              'title': result['name']!,
              'subtitle': result['description']!,
              'minutes': result['time']!,
              'price': result['price']!,
              'isAdditional': result['isAdditional'] ?? false,
            });
          },
        );
      },
    );
  }
}

class ModalWindow extends StatefulWidget {
  final Function(Map<String, dynamic>) onSave;
  final Map<String, dynamic>? initialValues;

  const ModalWindow({super.key, required this.onSave, this.initialValues});

  @override
  State<ModalWindow> createState() => _ModalWindowState();
}

class _ModalWindowState extends State<ModalWindow> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  bool _isAdditional = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialValues != null) {
      _nameController.text = widget.initialValues!['name'] ?? '';
      _descriptionController.text = widget.initialValues!['description'] ?? '';
      _timeController.text = widget.initialValues!['time'] ?? '';
      _priceController.text = widget.initialValues!['price'] ?? '';
      _isAdditional = widget.initialValues!['isAdditional'] ?? false;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _timeController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  bool _validateInput() {
    return _nameController.text.trim().isNotEmpty &&
        _descriptionController.text.trim().isNotEmpty &&
        _timeController.text.trim().isNotEmpty &&
        _priceController.text.trim().isNotEmpty;
  }

  void _saveService() {
    if (!_validateInput()) {
      print('Валидация не прошла - заполните все поля');
      return;
    }

    final result = {
      'name': _nameController.text.trim(),
      'description': _descriptionController.text.trim(),
      'time': _timeController.text.trim(),
      'price': _priceController.text.trim(),
      'isAdditional': _isAdditional,
    };

    print('Сохраняем услугу: $result');
    widget.onSave(result);
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline,
            width: 3,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              CustomTextField(
                labelText: 'Название',
                textController: _nameController,
                isClicked: true,
              ),
              const SizedBox(height: 15),

              CustomTextField(
                labelText: 'Описание',
                textController: _descriptionController,
                isClicked: true,
              ),
              const SizedBox(height: 15),

              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      labelText: 'Время',
                      textController: _timeController,
                      isClicked: true,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: CustomTextField(
                      labelText: 'Стоимость',
                      textController: _priceController,
                      isClicked: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  CustomCheckboxWidget(
                    value: _isAdditional,
                    onChanged: (val) {
                      setState(() {
                        _isAdditional = val;
                      });
                    },
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Доп. услуга',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Theme.of(context).colorScheme.primary,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 3,
                          ),
                        ),
                      ),
                      onPressed: () {
                        context.pop();
                      },
                      child: const Text(
                        'Отмена',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.tertiary,
                            width: 3,
                          ),
                        ),
                      ),
                      onPressed: _saveService,
                      child: const Text(
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
      ),
    );
  }
}
