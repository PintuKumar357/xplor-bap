import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:xplor/config/routes/path_routing.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _selectedLanguage = 'En';
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            // Expanded(
            //   child: SingleChildScrollView(
            //     child: Padding(
            //       padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            //       child: Column(
            //         crossAxisAlignment: CrossAxisAlignment.start,
            //         children: [
            //           // _buildGreetingSection(),
            //           // const SizedBox(height: 16),
            //           // _buildBanner(),
            //           // const SizedBox(height: 16),
            //           // _buildQuickActionSection(),
            //           // const SizedBox(height: 16),
            //           // _buildForecastSection(),
            //           // const SizedBox(height: 16),
            //           // _buildRecommendedCategoriesSection(),
            //           // const SizedBox(height: 16),
            //
            //           _buildAskAISection(),
            //           const SizedBox(height: 16),
            //           _buildSuggestionsSection(), // Add this line
            //           const SizedBox(height: 16),
            //           _buildAskMeAnythingSection(), // Add this line
            //           const SizedBox(height: 16),
            //         ],
            //       ),
            //     ),
            //   ),
            // ),

            Expanded(
              child: Stack(
                children: [
                  // Main content centered
                  Align(
                    alignment: Alignment.center,
                    child: _buildAskAISection(),
                  ),

                  // Bottom components above the tab bar
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 16,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildSuggestionsSection(),
                        const SizedBox(height: 24),
                        _buildAskMeAnythingSection(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomTab(),
      extendBody: true,
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 12),
      //color: const Color(0xFFFFFFFF),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Menu Icon
          GestureDetector(
            onTap: () {
              // Open drawer or menu
              print('Menu tapped');
            },
            child: SizedBox(
              width: 21,
              height: 21,
              child: Image.asset(
                'assets/images/menu_icon.png',
                width: 21,
                height: 21,
                fit: BoxFit.contain,
              ),
            ),
          ),

          // Right side icons
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Search Icon
                GestureDetector(
                  onTap: () {
                    // Navigate to search
                    print('Search tapped');
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFFFF),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.search,
                      color: Color(0xFF030229),
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Notification Icon
                GestureDetector(
                  onTap: () {
                    // Navigate to notifications
                    print('Notification tapped');
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFFFF),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        const Center(
                          child: Icon(
                            Icons.notifications_outlined,
                            color: Color(0xFF030229),
                            size: 20,
                          ),
                        ),
                        // Red dot indicator
                        Positioned(
                          top: 10,
                          left: 10,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFF0000),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Language Selector
                GestureDetector(
                  onTap: () {
                    // _showLanguageBottomSheet();
                  },
                  child: Container(
                    width: 51,
                    height: 28,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFFFF),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _selectedLanguage,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF030229),
                            fontFamily: 'Plus Jakarta Sans',
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.keyboard_arrow_down,
                          color: Color(0xFF030229),
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGreetingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Dear, John!',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: Color(0xFF323232),
            fontFamily: 'Gilroy-ExtraBold',
            height: 1.2,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            const Text(
              'Farm Location: ',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Color(0xFF9FA8B0),
                fontFamily: 'Gilroy-Regular',
                height: 1.2,
                letterSpacing: 0,
              ),
            ),
            const Text(
              'Vidarbha',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF3F3F3F),
                fontFamily: 'Gilroy-SemiBold',
                height: 1.2,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                // Navigate to edit location
                print('Edit location tapped');
              },
              child: const Text(
                'Edit',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4CAF50),
                  fontFamily: 'Gilroy-Bold',
                  height: 1.2,
                  letterSpacing: 0,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBanner() {
    return Container(
      width: double.infinity,
      height: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: const DecorationImage(
          image: AssetImage('assets/images/home_page_banner.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Colors.black.withOpacity(0.9),
              Colors.black.withOpacity(0),
            ],
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Empowering Farmers with Weather-Wise Decisions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: Color(0xFFFFFFFF),
                fontFamily: 'Gilroy-ExtraBold',
                height: 1.2,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Stay Ahead of the Weather. Make Every Crop Count!',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Color(0xFFEAEAEA),
                fontFamily: 'Gilroy-Regular',
                height: 1.2,
                letterSpacing: 0,
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () {
                // Navigate to demo
                print('Try a Demo tapped');
              },
              child: Container(
                width: 95,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.circular(50),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: const Center(
                  child: Text(
                    'Try a Demo',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF4CAF50),
                      fontFamily: 'Gilroy-SemiBold',
                      height: 1.2,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Action!',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF323232),
            fontFamily: 'Gilroy-Bold',
            height: 1.2,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 42,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildQuickActionItem(
                icon: 'assets/images/crop_planning_icon.png',
                label: 'Add Crop',
                onTap: () {
                  print('Add Crop tapped');
                },
              ),
              const SizedBox(width: 12),
              _buildQuickActionItem(
                icon: 'assets/images/scheme_access_icon.png',
                label: 'Order Input',
                onTap: () {
                  print('Order Input tapped');
                },
              ),
              const SizedBox(width: 12),
              _buildQuickActionItem(
                icon: 'assets/images/weather_alerts_icon.png',
                label: 'My Orders',
                onTap: () {
                  print('My Orders tapped');
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionItem({
    required String icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 25,
              height: 25,
              decoration: const BoxDecoration(
                color: Color(0xFFF4F4F4),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Image.asset(
                  icon,
                  width: 11.6,
                  height: 11.6,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Color(0xFF9FA8B0),
                fontFamily: 'Gilroy-Regular',
                letterSpacing: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForecastSection() {
    return Container(
      width: double.infinity,
      height: 185,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
          colors: [
            Color(0xFF1F3411),
            Color(0xFF1E825A),
          ],
          stops: [0.0039, 0.9939],
        ),
      ),
      child: Stack(
        children: [
          // Forecast Image positioned at top right
          Positioned(
            top: -12,
            right: 0,
            child: Image.asset(
              'assets/images/forecast_image.png',
              width: 136,
              height: 136,
              fit: BoxFit.contain,
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Temperature
                const Text(
                  '19°',
                  style: TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFFFFFFF),
                    height: 1.09,
                    letterSpacing: 0,
                  ),
                ),

                // Bottom section
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Weather details
                    Text(
                      'RH:24°   C:30.5°   Wind:0.7Kn',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFFEBEBF5).withOpacity(0.6),
                        fontFamily: 'Gilroy-Bold',
                        height: 1.2,
                        letterSpacing: -0.41,
                      ),
                    ),

                    // Location and View Full Forecast
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Bengaluru, India',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFFFFFFF),
                            fontFamily: 'Gilroy-Bold',
                            height: 1.2,
                            letterSpacing: -0.41,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            print('View Full Forecast tapped');
                          },
                          child: const Text(
                            'View Full Forecast',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF4CAF50),
                              fontFamily: 'Gilroy-Bold',
                              height: 1.38,
                              letterSpacing: -0.08,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedCategoriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recommended Categories',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF323232),
            fontFamily: 'Gilroy-Bold',
            height: 1.2,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 8),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 158 / 84,
          children: [
            _buildCategoryItem('Crop Advisory'),
            _buildCategoryItem('Weather Alerts'),
            _buildCategoryItem('Fertilizers & Pesticides'),
            _buildCategoryItem('Harvesting Tools'),
            _buildCategoryItem('Livestock Care'),
            _buildCategoryItem('Nearby Agri Centers'),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryItem(String title) {
    return GestureDetector(
      onTap: () {
        print('$title tapped');
      },
      child: Container(
        height: 84,
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF).withOpacity(0.62),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFBFBFBF).withOpacity(0.16),
              blurRadius: 12,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Center(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64697A),
              fontFamily: 'Gilroy-Medium',
              height: 1.2,
              letterSpacing: 0,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomTab() {
    return Container(
      margin: const EdgeInsets.only(left: 24, right: 24, bottom: 20),
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF).withOpacity(0.9),
        borderRadius: BorderRadius.circular(60),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF272C66).withOpacity(0.1),
            blurRadius: 30,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(60),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTabItem(
                index: 0,
                selectedIcon: 'assets/images/selected_home_tab_icon.svg',
                unselectedIcon: 'assets/images/unselected_home_tab_icon.svg',
                label: 'Home',
              ),
              _buildTabItem(
                index: 1,
                selectedIcon: 'assets/images/selected_ai_tab_icon.svg',
                unselectedIcon: 'assets/images/unselected_ai_tab_icon.svg',
                label: 'Your AI',
              ),
              _buildTabItem(
                index: 2,
                selectedIcon: 'assets/images/unselected_setting_tab_icon.svg',
                unselectedIcon: 'assets/images/unselected_setting_tab_icon.svg',
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem({
    required int index,
    required String selectedIcon,
    required String unselectedIcon,
    required String label,
  }) {
    final bool isSelected = _selectedTabIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTabIndex = index;
        });
        print('$label tab tapped');
      },
      child: SizedBox(
        width: 100,
        height: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon with background when selected
            Container(
              width: 56,
              height: 28,
              decoration: isSelected
                  ? BoxDecoration(
                      color: const Color(0xFF4CAF50).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(28),
                    )
                  : null,
              child: Center(
                child: SvgPicture.asset(
                  isSelected ? selectedIcon : unselectedIcon,
                  width: 24,
                  height: 24,
                ),
              ),
            ),
            const SizedBox(height: 4),
            // Label text
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10.49,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? const Color(0xFF4CAF50)
                    : const Color(0xFF49454F),
                fontFamily: isSelected ? 'Gilroy-Bold' : 'Gilroy-Regular',
                height: 13.98 / 10.49,
                letterSpacing: 0.44,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAskAISection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // AI Logo
          SvgPicture.asset(
            'assets/images/ai_logo.svg', // Replace with your logo asset path
            width: 36,
            height: 37,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 16),
          // Ask our AI anything text
          const Text(
            'Ask our AI anything',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Color(0xFF160211),
              fontFamily: 'Gilroy-Bold',
              height: 1.0,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionsSection() {
    final List<String> suggestions = [
      'How do I register on this portal?',
      'How do I apply for subsidies?',
      'How can I update my Aadhaar or bank details?',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Suggestions on what to ask Our AI',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xFF434343),
            fontFamily: 'Gilroy-Bold',
            height: 1.0,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 48,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: suggestions.length,
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              return _buildSuggestionItem(suggestions[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSuggestionItem(String text) {
    return GestureDetector(
      onTap: () {
        print('Suggestion tapped: $text');
      },
      child: Container(
        width: 134,
        height: 48,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            text,
            textAlign: TextAlign.start,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Color(0xFF64697A),
              fontFamily: 'Gilroy-Light',
              height: 1.2,
              letterSpacing: 0,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAskMeAnythingSection() {
    return Container(
      width: double.infinity,
      height: 52,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFFFFFFF),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Ask me anything text
          const Expanded(
            child: Text(
              'Ask me anything...',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF000000),
                fontFamily: 'Gilroy-SemiBold',
                height: 1.2,
                letterSpacing: 0,
              ),
            ),
          ),
          // Right side icons
          Row(
            children: [
              // Plus icon
              GestureDetector(
                onTap: () {
                  print('Plus icon tapped');
                },
                child: SvgPicture.asset(
                  'assets/images/chat_plus_icon.svg',
                  width: 16,
                  height: 16,
                ),
              ),
              const SizedBox(width: 12),
              // Mic icon
              GestureDetector(
                onTap: () {
                  print('Mic icon tapped');
                },
                child: SvgPicture.asset(
                  'assets/images/chat_mic_icon.svg',
                  width: 16,
                  height: 16,
                ),
              ),
              const SizedBox(width: 12),
              // Send chat icon
              GestureDetector(
                onTap: () {
                  print('Send chat tapped');
                },
                child: Center(
                  child: SvgPicture.asset(
                    'assets/images/chat_icon.svg',
                    width: 32,
                    height: 32,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


}
