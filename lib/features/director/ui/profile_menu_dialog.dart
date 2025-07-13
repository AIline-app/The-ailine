import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProfileMenuDialog extends StatefulWidget {
  @override
  _ProfileMenuDialogState createState() => _ProfileMenuDialogState();
}

class _ProfileMenuDialogState extends State<ProfileMenuDialog>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  String currentView = 'main';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showSubmenu(String view) {
    setState(() {
      currentView = view;
    });
    _controller.forward();
  }

  void _goBack() {
    _controller.reverse().then((_) {
      setState(() {
        currentView = 'main';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 280,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(Icons.close, color: Colors.blue, size: 24),
                  onPressed: () => context.pop(),
                ),
              ],
            ),

            AnimatedSwitcher(
              duration: Duration(milliseconds: 300),
              child: _buildCurrentView(),
            ),

            SizedBox(height: 20),

            TextButton(
              onPressed: () {
                context.pop();
              },
              child: Text(
                'Выйти',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentView() {
    switch (currentView) {
      case 'main':
        return _buildMainMenu();
      case 'my_cars':
        return _buildMyCarsMenu();
      case 'banking':
        return _buildBankingMenu();
      default:
        return _buildMainMenu();
    }
  }

  Widget _buildMainMenu() {
    return Column(
      key: ValueKey('main'),
      children: [
        _buildMenuItem('Профиль', Icons.person, () {
          context.pop();
        }),

        _buildMenuItem('Мои автомойки', Icons.local_car_wash, () {
          _showSubmenu('my_cars');
        }, hasSubmenu: true),

        _buildMenuItem('Администраторы', Icons.admin_panel_settings, () {
          context.pop();
        }),

        _buildMenuItem('Банковские данные', Icons.credit_card, () {
          _showSubmenu('banking');
        }, hasSubmenu: true),
      ],
    );
  }

  Widget _buildMyCarsMenu() {
    return Column(
      key: ValueKey('my_cars'),
      children: [
        Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.blue),
              onPressed: _goBack,
            ),
            Text(
              'Мои автомойки',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ],
        ),

        SizedBox(height: 10),

        // Пункты подменю
        _buildSubmenuItem('Мойка Капля', 'Основные данные'),
        _buildSubmenuItem('Рудактированные услуги', ''),
        _buildSubmenuItem('Сканировать QR', ''),
        _buildSubmenuItem('Включить автомойку', ''),
        _buildSubmenuItem('Мойка на Ленинском', ''),
        _buildSubmenuItem('Добавить автомойку', ''),
      ],
    );
  }

  Widget _buildBankingMenu() {
    return Column(
      key: ValueKey('banking'),
      children: [
        Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.blue),
              onPressed: _goBack,
            ),
            Text(
              'Банковские данные',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ],
        ),

        SizedBox(height: 10),

        _buildSubmenuItem('Мойка Капля', ''),
        _buildSubmenuItem('Мойка на Ленинском', ''),
      ],
    );
  }

  Widget _buildMenuItem(
    String title,
    IconData icon,
    VoidCallback onTap, {
    bool hasSubmenu = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 15),
        child: Row(
          children: [
            Icon(icon, size: 24, color: Colors.grey[600]),
            SizedBox(width: 15),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
            if (hasSubmenu)
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmenuItem(String title, String subtitle) {
    return InkWell(
      onTap: () {
        context.pop();
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            if (subtitle.isNotEmpty)
              Text(
                subtitle,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
          ],
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Развертывающееся меню')),
        body: Center(
          child: ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => ProfileMenuDialog(),
              );
            },
            child: Text('Показать меню'),
          ),
        ),
      ),
    );
  }
}
