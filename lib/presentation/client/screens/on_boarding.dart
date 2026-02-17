import 'package:flutter/material.dart';

import '../../../routes.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _controller = PageController();
  int _index = 0;

  final String logoAsset = 'assets/images/logo.png';

  final String photoAsset = 'assets/images/image_6.png';

  final List<String> titles = const [
    'i-Line – это мобильное\nприложение для бронирования\nживой очереди в автомойках.\nБольше никаких очередей!',
    'Выберите автомойку онлайн',
    'Встаньте в очередь',
    'Приезжайте ко времени',
  ];

  void _skip() {

    Navigator.pop(context);
  }

  void _next() {
    if (_index < 3) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    } else {
        Navigator.pushNamed(context, AppRoutes.home);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFFEDEDED), // фон как на скринах 2-4
      body: SafeArea(
        child: Stack(
          children: [
            // PageView
            PageView.builder(
              controller: _controller,
              itemCount: 4,
              onPageChanged: (i) => setState(() => _index = i),
              itemBuilder: (context, i) {
                final isFirst = i == 0;

                return _OnboardSlide(
                  isFirst: isFirst,
                  logoAsset: logoAsset,
                  photoAsset: photoAsset,
                  title: titles[i],
                  onSkip: _skip,
                  dots: _Dots(activeIndex: _index, count: 4),
                );
              },
            ),
            Positioned(
              top: 20,
              right: 20,
              child: SkipButton(onSkip: _skip),
            ),
            Positioned(
                top: 20,
                left: 20,
              child: Image.asset(logoAsset, height: 28)
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 10 + bottom,

              child: SizedBox(
                height: 58,
                child: ElevatedButton(
                  onPressed: _next,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2D8CFF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Далее',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(child: Positioned(
              left: MediaQuery.of(context).size.width /2 - 48,
              bottom: 100,
              child: Center(child: _Dots(activeIndex: _index, count: 4),),
            ),)
          ],
        ),
      ),
    );
  }
}

class _OnboardSlide extends StatelessWidget {
  const _OnboardSlide({
    required this.isFirst,
    required this.logoAsset,
    required this.photoAsset,
    required this.title,
    required this.onSkip,
    required this.dots,
  });

  final bool isFirst;
  final String logoAsset;
  final String photoAsset;
  final String title;
  final VoidCallback onSkip;
  final Widget dots;

  @override
  Widget build(BuildContext context) {
    const bottomReserved = 120.0;

    if (isFirst) {

      return Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/card_car.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.55)),
          ),
          Positioned(
            left: 24,
            right: 24,
            top: 0,
            bottom: bottomReserved,
            child: Center(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  height: 1.25,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

        ],
      );
    }
    return Column(
      children: [
        const SizedBox(height: 52),
        Center(
          child: Container(
            height: 340, child: Image.asset(photoAsset, fit: BoxFit.cover)),
        ),

        const SizedBox(height: 18),

        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF1F3D59),
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class SkipButton extends StatelessWidget{
  final onSkip;
  SkipButton({this.onSkip});

  @override
  Widget build(BuildContext context) {
    return  GestureDetector(
      onTap: onSkip,
      child: const Text(
        'Пропустить',
        style: TextStyle(
          color: Colors.black45,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.activeIndex, required this.count});

  final int activeIndex;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (i) {
        final isActive = i == activeIndex;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 6),
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF2D8CFF) : const Color(0xFFBDBDBD),
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }
}
