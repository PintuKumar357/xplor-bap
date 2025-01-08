import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl_phone_field/countries.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../../../../../utils/common_top_header.dart';
import '../../../../multi_lang/domain/mappers/on_boarding/on_boardings_keys.dart';
import '../../../../../utils/extensions/string_to_string.dart';
import '../../../../../utils/utils.dart';
import '../../../../../utils/widgets/loading_animation.dart';
import '../../../../../config/routes/path_routing.dart';
import '../../../../../config/services/app_services.dart';
import '../../../../../const/local_storage/shared_preferences_helper.dart';
import '../../../../../core/dependency_injection.dart';
import '../../../../../gen/assets.gen.dart';
import '../../../../../utils/app_colors.dart';
import '../../../../../utils/app_dimensions.dart';
import '../../../../../utils/app_utils/app_utils.dart';
import '../../../../../utils/circluar_button.dart';
import '../../../../../utils/extensions/font_style/font_styles.dart';
import '../../../../../utils/mapping_const.dart';
import '../../../../../utils/widgets/app_background_widget.dart';
import '../../../../multi_lang/presentation/blocs/bloc/translate_bloc.dart';
import '../../../presentation/blocs/otp_bloc/otp_bloc.dart';
import '../../../presentation/blocs/phone_bloc/phone_bloc.dart';
import '../../widgets/phone_number_formatter.dart';

part 'phone_number_widgets.dart';
part 'phone_number_view_sliver.dart';

/// Widget for the sign-in view.
class PhoneNumberView extends StatefulWidget {
  const PhoneNumberView({super.key, required this.userCheck});

  final bool userCheck;

  @override
  State<PhoneNumberView> createState() => _PhoneNumberViewState();
}
//
// /// State class for the sign-in view.
// class _PhoneNumberViewState extends State<PhoneNumberView> {
//   @override
//   void initState() {
//     mobileNumberController = TextEditingController();
//     context.read<PhoneBloc>().add(const PhoneInitialEvent());
//     if (sl<SharedPreferencesHelper>().getString(PrefConstKeys.selectedRole) == PrefConstKeys.agentKey) {
//       context.read<TranslationBloc>().add(TranslateDynamicTextEvent(
//           langCode: sl<SharedPreferencesHelper>().getString(PrefConstKeys.selectedLanguageCode),
//           moduleTypes: homeModule,
//           isNavigation: false));
//     }
//
//     context.read<TranslationBloc>().add(TranslateDynamicTextEvent(
//         langCode: sl<SharedPreferencesHelper>().getString(PrefConstKeys.selectedLanguageCode),
//         moduleTypes: walletModule,
//         isNavigation: false));
//     //context.read<PhoneBloc>().add(const CountryCodeEvent(countryCode: "+91"));
//     _getCountryCode();
//     super.initState();
//   }
//
//   Future<void> _getCountryCode() async {
//     bool serviceEnabled;
//     LocationPermission permission;
//
//     // Test if location services are enabled.
//     serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       await Geolocator.openLocationSettings();
//       AppUtils.printLogs('Location services are disabled.');
//     }
//
//     permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         AppUtils.printLogs('Location permissions are denied');
//       }
//     }
//
//     if (permission == LocationPermission.deniedForever) {
//       await Geolocator.openAppSettings();
//       AppUtils.printLogs('Location permissions are permanently denied, we cannot request permissions.');
//     }
//
//     try {
//       Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
//       List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
//       Placemark firstPlacemark = placemarks.first;
//       setState(() {
//         countryCode = firstPlacemark.isoCountryCode;
//       });
//     } catch (e) {
//       AppUtils.printLogs("Error Country Code: $e");
//       setState(() {
//         countryCode = 'IN';
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.white,
//       body: AppBackgroundDecoration(
//         child: SafeArea(
//           child: BlocListener<PhoneBloc, PhoneState>(
//             listener: (context, state) {
//               if (state is SuccessPhoneState) {
//                 context.read<OtpBloc>().add(PhoneNumberSaveEvent(
//                     phoneNumber: state.phoneNumber, key: state.key, countryCode: countryDialCode ?? "+91"));
//                 Navigator.pushNamed(
//                   AppServices.navState.currentContext!,
//                   Routes.otp,
//                 );
//               }
//             },
//             child: BlocBuilder<PhoneBloc, PhoneState>(
//               builder: (context, state) {
//                 return Stack(
//                   children: [
//                     if (countryCode != null)
//                       CustomScrollView(
//                         slivers: <Widget>[
//                           phoneNumberSliverAppBar(context),
//                           phoneNumberSliverPadding(state, context),
//                           phoneNumberSliverFillRemaining(state, context, widget.userCheck)
//                         ],
//                       ),
//                     if (state is PhoneLoadingState || countryCode == null) const LoadingAnimation(),
//                   ],
//                 );
//               },
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     mobileNumberController.dispose();
//     super.dispose();
//   }
// }
class _PhoneNumberViewState extends State<PhoneNumberView> {
  bool showCustomScrollView = false; // State to toggle between cards and CustomScrollView
  String? selectedCard; // Tracks the card the user clicked on
  Future<void> _getCountryCode() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      AppUtils.printLogs('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        AppUtils.printLogs('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings();
      AppUtils.printLogs('Location permissions are permanently denied, we cannot request permissions.');
    }

    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      Placemark firstPlacemark = placemarks.first;
      setState(() {
        countryCode = firstPlacemark.isoCountryCode;
      });
    } catch (e) {
      AppUtils.printLogs("Error Country Code: $e");
      setState(() {
        countryCode = 'IN';
      });
    }
  }
  @override
  void initState() {
    mobileNumberController = TextEditingController();
    context.read<PhoneBloc>().add(const PhoneInitialEvent());
    if (sl<SharedPreferencesHelper>().getString(PrefConstKeys.selectedRole) == PrefConstKeys.agentKey) {
      context.read<TranslationBloc>().add(TranslateDynamicTextEvent(
          langCode: sl<SharedPreferencesHelper>().getString(PrefConstKeys.selectedLanguageCode),
          moduleTypes: homeModule,
          isNavigation: false));
    }

    context.read<TranslationBloc>().add(TranslateDynamicTextEvent(
        langCode: sl<SharedPreferencesHelper>().getString(PrefConstKeys.selectedLanguageCode),
        moduleTypes: walletModule,
        isNavigation: false));

    _getCountryCode();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: AppBackgroundDecoration(
        child: SafeArea(
          child: BlocListener<PhoneBloc, PhoneState>(
            listener: (context, state) {
              if (state is SuccessPhoneState) {
                context.read<OtpBloc>().add(PhoneNumberSaveEvent(
                    phoneNumber: state.phoneNumber, key: state.key, countryCode: countryDialCode ?? "+91"));
                Navigator.pushNamed(
                  AppServices.navState.currentContext!,
                  Routes.otp,
                );
              }
            },
            child: BlocBuilder<PhoneBloc, PhoneState>(
              builder: (context, state) {
                if (!showCustomScrollView) {
                  return Padding(
                     padding: const EdgeInsets.all(0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Replace Text with CommonTopHeader
                        CommonTopHeader(
                          title: 'Profile Verification',
                          isTitleOnly: false,
                          dividerColor: Colors.grey, // Use appropriate color
                          onBackButtonPressed: () => Navigator // Handle back button press
                        ),
                        SizedBox(height: 10.h), // Adjust spacing between header and cards

                        // ABHAID Card
                        Container(
                          margin: EdgeInsets.all(10), // Apply 10px margin below the card
                          child: GestureDetector(
                            onTap: () => _onCardTap('ABHAID'),
                            child: Card(
                              elevation: 4,
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  children: [
                                    Icon(Icons.account_circle, size: 50, color: Colors.blue),
                                    SizedBox(height: 8),
                                    Text(
                                      'ABHAID',
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 16.h), // Spacing between cards

                        // Digilocker Card
                        // Digilocker Card with Margin
                        Container(
                          margin: EdgeInsets.all(10), // Apply 10px margin below the card
                          child: GestureDetector(
                            onTap: () => _onCardTap('Digilocker'),
                            child: Card(
                              elevation: 4,
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  children: [
                                    Icon(Icons.folder_shared, size: 50, color: Colors.green),
                                    SizedBox(height: 8),
                                    Text(
                                      'Digilocker',
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );

                  // Display cards if CustomScrollView is not shown
                  // return Padding(
                  //   padding: const EdgeInsets.all(16.0),
                  //   child: Column(
                  //     crossAxisAlignment: CrossAxisAlignment.stretch,
                  //     children: [
                  //       Text(
                  //         'Profile Verification',
                  //         textAlign: TextAlign.center,
                  //         style: TextStyle(
                  //           fontSize: 20.sp,
                  //           fontWeight: FontWeight.bold,
                  //           color: AppColors.black,
                  //         ),
                  //       ),
                  //       SizedBox(height: 10.h),
                  //       GestureDetector(
                  //         onTap: () => _onCardTap('ABHAID'),
                  //         child: Card(
                  //           elevation: 4,
                  //           color: Colors.blue[100],
                  //           shape: RoundedRectangleBorder(
                  //             borderRadius: BorderRadius.circular(12),
                  //           ),
                  //           child: Padding(
                  //             padding: const EdgeInsets.all(16.0),
                  //             child: Column(
                  //               children: [
                  //                 Icon(Icons.account_circle, size: 50, color: Colors.blue),
                  //                 SizedBox(height: 8),
                  //                 Text(
                  //                   'ABHAID',
                  //                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  //                 ),
                  //               ],
                  //             ),
                  //           ),
                  //         ),
                  //       ),
                  //       SizedBox(height: 16.h),
                  //       GestureDetector(
                  //         onTap: () => _onCardTap('Digilocker'),
                  //         child: Card(
                  //           elevation: 4,
                  //           color: Colors.green[100],
                  //           shape: RoundedRectangleBorder(
                  //             borderRadius: BorderRadius.circular(12),
                  //           ),
                  //           child: Padding(
                  //             padding: const EdgeInsets.all(16.0),
                  //             child: Column(
                  //               children: [
                  //                 Icon(Icons.folder_shared, size: 50, color: Colors.green),
                  //                 SizedBox(height: 8),
                  //                 Text(
                  //                   'Digilocker',
                  //                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  //                 ),
                  //               ],
                  //             ),
                  //           ),
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // );
                }

                // Show CustomScrollView if user clicked on a card
                return Stack(
                  children: [
                    if (countryCode != null)
                      CustomScrollView(
                        slivers: <Widget>[
                          phoneNumberSliverAppBar(context),
                          phoneNumberSliverPadding(state, context),
                          phoneNumberSliverFillRemaining(state, context, widget.userCheck)
                        ],
                      ),
                    if (state is PhoneLoadingState || countryCode == null) const LoadingAnimation(),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _onCardTap(String cardName) {
    setState(() {
      showCustomScrollView = true;
      selectedCard = cardName; // Track the selected card (if needed for logic)
    });
  }

  @override
  void dispose() {
    mobileNumberController.dispose();
    super.dispose();
  }
}
