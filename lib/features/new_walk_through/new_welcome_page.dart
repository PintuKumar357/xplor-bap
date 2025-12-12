import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:xplor/config/routes/path_routing.dart';
import 'package:xplor/utils/app_colors.dart';
import 'package:xplor/utils/app_dimensions.dart';

class NewWelcomeScreen extends StatefulWidget {
  const NewWelcomeScreen({super.key});

  @override
  State<NewWelcomeScreen> createState() => _NewWelcomeScreenState();
}

class _NewWelcomeScreenState extends State<NewWelcomeScreen> {
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
                image: AssetImage('assets/images/overlay.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: screenHeight * 0.50,
            child: Container(
                width: screenWidth,
                padding: EdgeInsets.symmetric(
                  horizontal: 25,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome \nto AgriServe',
                      style: TextStyle(
                        height: 1,
                        fontSize: 56,
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Gilroy-Heavy',
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Your one-stop solution for farmer support,\nschemes & digital records.',
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors.grey400,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Gilroy-Heavy',
                      ),
                    ),
                    SizedBox(height: 110),
                    Container(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          // Add your button action here
                          Navigator.pushNamed(
                              context, Routes.firstWalkThroughPage);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF4CAF50),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Get Started',
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
                    SizedBox(height: 16),
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already Registered? ',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.white,
                              fontWeight: FontWeight.w400,
                              fontFamily: 'Gilroy-Heavy',
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              // Add your navigation or sign in logic here
                              print('Sign In button tapped');
                            },
                            child: Text(
                              'Sign In',
                              style: TextStyle(
                                fontSize: 15,
                                color: Color(0xFF4CAF50),
                                fontWeight: FontWeight.w800,
                                fontFamily: 'Gilroy-Heavy',
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                )),
          ),
        ],
      ),
    );
  }
}
