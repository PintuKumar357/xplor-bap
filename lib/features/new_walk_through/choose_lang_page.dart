import 'package:flutter/material.dart';
import 'package:xplor/config/routes/path_routing.dart';
import 'models/language_model.dart';

class ChooseLangPage extends StatefulWidget {
  const ChooseLangPage({super.key});

  @override
  State<ChooseLangPage> createState() => _ChooseLangPageState();
}

class _ChooseLangPageState extends State<ChooseLangPage> {
  Language? selectedLanguage;

  @override
  void initState() {
    super.initState();
    if (availableLanguages.isNotEmpty) {
      selectedLanguage = availableLanguages[0];
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SafeArea(
        child: Stack(
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
                        'Language',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF000000),
                          fontFamily: 'Gilroy-Heavy',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 56), // Balance the back button width + margin
                ],
              ),
            ),

            Container(
              width: screenWidth,
              height: screenHeight - 70,
              margin: const EdgeInsets.only(top: 70),
              color: Color(0xFFF7F7F7),
              padding: const EdgeInsets.only(
                top: 20,
                left: 25,
                right: 22,
                bottom: 17,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select your preferred language for the interface.',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF091C37),
                      fontFamily: 'Gilroy-Heavy',
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Row(
                    children: [
                      Text(
                        'Recommended Languages ',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF091C37),
                          fontFamily: 'Gilroy-Heavy',
                        ),
                      ),
                      Text(
                        '(Based on your location)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF091C37),
                          fontFamily: 'Gilroy-Heavy',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: availableLanguages.length + 1,
                      // +1 for the subtitle
                      itemBuilder: (context, index) {
                        // Show subtitle after 2nd item (at index 2)
                        if (index == 2) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),
                              const Text(
                                'Other Languages',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF091C37),
                                  fontFamily: 'Gilroy-Heavy',
                                ),
                              ),
                              const SizedBox(height: 18),
                            ],
                          );
                        }

                        // Adjust language index to account for subtitle
                        final languageIndex = index > 2 ? index - 1 : index;
                        final language = availableLanguages[languageIndex];
                        final isSelected = selectedLanguage == language;

                        return Padding(
                          padding: EdgeInsets.only(
                            bottom:
                                languageIndex < availableLanguages.length - 1
                                    ? 14
                                    : 0,
                          ),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedLanguage = language;
                              });
                            },
                            child: Container(
                              width: 328,
                              height: 92,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF4CAF50).withOpacity(0.15)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: isSelected
                                    ? Border.all(
                                        color: const Color(0xFF4CAF50)
                                            .withOpacity(0.3),
                                        width: 2,
                                      )
                                    : null,
                                boxShadow: [
                                  BoxShadow(
                                    offset: const Offset(0, 8),
                                    blurRadius: 12,
                                    color: const Color(0xFFBFBFBF)
                                        .withOpacity(0.16),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    language.code,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ? const Color(0xFF4CAF50)
                                          : const Color(0xFF282828),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          language.name,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: isSelected
                                                ? const Color(0xFF4CAF50)
                                                : const Color(0xFF282828),
                                            fontFamily: 'Gilroy-Heavy',
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          language.displayText,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                            color: isSelected
                                                ? const Color(0xFF4CAF50)
                                                : const Color(0xFF393939),
                                            fontFamily: 'Gilroy-Regular',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: isSelected ? 24 : 22,
                                    height: isSelected ? 24 : 22,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isSelected
                                          ? const Color(0xFF4CAF50)
                                          : Colors.transparent,
                                      border: isSelected
                                          ? null
                                          : Border.all(
                                              color: const Color(0xFFC9C9C9),
                                              width: 1,
                                            ),
                                    ),
                                    child: isSelected
                                        ? const Icon(
                                            Icons.check,
                                            color: Colors.white,
                                            size: 16,
                                          )
                                        : null,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      // Handle continue button press
                      if (selectedLanguage != null) {
                        // Navigate to next screen or save selection
                        print('continue button tapped');
                        Navigator.pushNamed(
                            context, Routes.yourFocusPage);
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
                        'Continue',
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
