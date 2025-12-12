import 'package:flutter/material.dart';
import 'package:xplor/config/routes/path_routing.dart';

class YourFocusPage extends StatefulWidget {
  const YourFocusPage({super.key});

  @override
  State<YourFocusPage> createState() => _YourFocusPageState();
}

class _YourFocusPageState extends State<YourFocusPage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      //backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: screenWidth,
              height: 70,
              color: const Color(0xFFFFFFFF),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 38,
                      height: 38,
                      margin: const EdgeInsets.only(left: 18),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Image.asset(
                          'assets/images/choose_lang_back_icon.png',
                          width: 18,
                          height: 15,
                        ),
                      ),
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Your Focus',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF000000),
                          fontFamily: 'Gilroy-Heavy',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 56),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ListView(
                  padding: const EdgeInsets.only(top: 20),
                  children: [
                    _buildFocusItem(
                      icon: 'assets/images/crop_planning_icon.png',
                      title: 'Crop Planning',
                      description: 'Plan sowing schedules, get seasonal advice.',
                      index: 0,
                    ),
                    const SizedBox(height: 14),
                    _buildFocusItem(
                      icon: 'assets/images/scheme_access_icon.png',
                      title: 'Scheme Access',
                      description: 'Apply for government subsidies & benefits.',
                      index: 1,
                    ),
                    const SizedBox(height: 14),
                    _buildFocusItem(
                      icon: 'assets/images/market_rates_icon.png',
                      title: 'Market Rates',
                      description: 'Check daily mandi prices for your crops.',
                      index: 2,
                    ),
                    const SizedBox(height: 14),
                    _buildFocusItem(
                      icon: 'assets/images/weather_alerts_icon.png',
                      title: 'Weather Alerts',
                      description: 'Check daily mandi prices for your crops.',
                      index: 3,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20, left: 24, right: 24),
              child: GestureDetector(
                onTap: () {
                  // Handle continue button press
                  if (_selectedIndex != null) {
                    // Navigate to next screen or save selection
                    print('Next button tapped');
                    Navigator.pushNamed(context, Routes.categoryPage);
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25,
                    vertical: 15,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Text(
                    'Next',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontFamily: 'Gilroy-Heavy',
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildFocusItem({
    required String icon,
    required String title,
    required String description,
    required int index,
  }) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Container(
        height: 84,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          border: Border.all(
            color: isSelected ? const Color(0xFF4CAF50) : const Color(0xFFFFFFFF),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              offset: const Offset(0, 8),
              blurRadius: 12,
              color: const Color(0xFFBFBFBF)
                  .withOpacity(0.25),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(
                color: Color(0xFFF4F4F4),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Image.asset(
                  icon,
                  width: 24,
                  height: 24,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF000000),
                      fontFamily: 'Gilroy-Heavy',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF757575),
                      fontFamily: 'Gilroy-Medium',
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFF4CAF50),
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
