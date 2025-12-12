import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:xplor/config/routes/path_routing.dart';

class ThirdWalkThroughPage extends StatefulWidget {
  const ThirdWalkThroughPage({super.key});

  @override
  State<ThirdWalkThroughPage> createState() => _ThirdWalkThroughPageState();
}

class _ThirdWalkThroughPageState extends State<ThirdWalkThroughPage> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/third_walk_through_bg.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: screenHeight * 0.58,
            child: Container(
              width: screenWidth * 0.86,
              height: 280,
              margin: EdgeInsets.symmetric(
                horizontal: 28,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  width: 2,
                  color: Colors.white.withOpacity(0.5),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xffFFFFFF),
                    // Start color
                    Color(0xffFFFFFF).withOpacity(0.05),
                    // End color with opacity
                  ],
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 70, sigmaY: 70),
                  child: Container(
                    padding: const EdgeInsets.only(
                      left: 17,
                      top: 20,
                      right: 17,
                      bottom: 30,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Smart Farming Starts Here',
                          style: TextStyle(
                              height: 1.2,
                              fontSize: 34,
                              color: Color(0xff0E3D10),
                              fontWeight: FontWeight.w900,
                              fontFamily: 'Gilroy-Heavy',
                              fontStyle: FontStyle.italic),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Monitor your land, income, and inputs—all in one place.',
                          style: TextStyle(
                            //height: 1.2,
                            fontSize: 15,
                            color: Color(0xffFFFFFF),
                            fontWeight: FontWeight.w400,
                            fontFamily: 'Gilroy-Heavy',
                          ),
                        ),
                        SizedBox(height: 16),
                        Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  // Add your navigation or sign in logic here
                                  print('Skip button tapped');
                                },
                                child: Text(
                                  'Skip',
                                  style: TextStyle(
                                    fontSize: 17,
                                    color: Color(0xffFFFFFF),
                                    fontWeight: FontWeight.w400,
                                    fontFamily: 'Gilroy-Heavy',
                                  ),
                                ),
                              ),
                              Container(
                                width: 99,
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: () {
                                    // Add your button action here
                                    Navigator.pushReplacementNamed(
                                        context, Routes.chooseLangPage);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Color(0xFF4CAF50),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Next',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'Gilroy-Heavy',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20),
                        Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 6.0,
                                height: 6.0,
                                decoration: BoxDecoration(
                                  color: Color(0x33FFFFFF),
                                  borderRadius: BorderRadius.circular(
                                      3.0), // Makes it circular
                                ),
                              ),
                              SizedBox(
                                  width: 8.0), // Optional spacing between dots
                              Container(
                                width: 6.0,
                                height: 6.0,
                                decoration: BoxDecoration(
                                  color: Color(0x33FFFFFF),
                                  borderRadius: BorderRadius.circular(3.0),
                                ),
                              ),
                              SizedBox(
                                  width: 8.0), // Optional spacing between dots
                              Container(
                                width: 6.0,
                                height: 6.0,
                                decoration: BoxDecoration(
                                  color: Color(0xFF4CAF50),
                                  borderRadius: BorderRadius.circular(3.0),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
