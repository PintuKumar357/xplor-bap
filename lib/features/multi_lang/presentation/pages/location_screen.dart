import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
//import 'package:platform_device_id_v3/platform_device_id.dart';
import 'package:platform_device_id_plus/platform_device_id.dart';
import '../../../../core/connection/network_info.dart';
import '../../../../utils/extensions/string_to_string.dart';
import '../../../../core/exception_errors.dart';
import '../../../../gen/assets.gen.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_dimensions.dart';
import '../../../../utils/extensions/font_style/font_styles.dart';
import '../../../../utils/utils.dart';
import '../../../../utils/widgets/app_background_widget.dart';
import '../../../../config/routes/path_routing.dart';
import '../../../../const/local_storage/shared_preferences_helper.dart';
import '../../../../core/dependency_injection.dart';
import '../../../../utils/app_utils/app_utils.dart';
import '../../../../utils/circluar_button.dart';

class LocationAccessPage extends StatefulWidget {
  const LocationAccessPage({super.key});

  @override
  State<LocationAccessPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationAccessPage> {
  bool isLoading = false;

  @override
  void initState() {
    _getDeviceId();
    // _determinePosition();

    super.initState();
  }

  _getDeviceId() async {
    String? deviceId = await PlatformDeviceId.getDeviceId;
    AppUtils.printLogs("Save language api Response====>${deviceId!}");
    sl<SharedPreferencesHelper>().setString(PrefConstKeys.deviceId, deviceId!);
  }

  /// are denied the `Future` will return an error.
  Future<Position> _determinePosition() async {
    setState(() {
      isLoading = true;
    });

    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      updateData();
      AppUtils.printLogs('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        updateData();
        AppUtils.printLogs('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings();
      updateData();
      AppUtils.printLogs(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    Position position = await Geolocator.getCurrentPosition();

    AppUtils.printLogs(
        'Latitude: ${position.latitude}, Longitude: ${position.longitude}');
    sl<SharedPreferencesHelper>()
        .setDouble(PrefConstKeys.latitude, position.latitude);
    sl<SharedPreferencesHelper>()
        .setDouble(PrefConstKeys.longitude, position.longitude);

    updateData();

    return position;
  }

  void updateData() {
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: PopScope(
      canPop: false,
      onPopInvokedWithResult: (val, result) {
        AppUtils.showAlertDialog(context, false);
      },
      child: AppBackgroundDecoration(
          child: SafeArea(
        child: Column(
          children: [
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                SvgPicture.asset(
                  Assets.images.accessLocation,
                  width: MediaQuery.of(context)
                      .size
                      .width, // Set the width of the SVG
                ).scaleYAnimated(),
                "Allow location\naccess"
                    .titleBlack(align: TextAlign.center)
                    .fadeAnimation(),
              ],
            ),
            AppDimensions.small.verticalSpace,
            RichText(
              text: TextSpan(
                style: TextStyle(
                    color: AppColors.textColor,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400),
                children: <TextSpan>[
                  const TextSpan(text: 'Allow '),
                  TextSpan(
                      text: 'Discover',
                      style: TextStyle(
                          color: AppColors.primaryColor,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w800)),
                  const TextSpan(text: ' to access this device’s location'),
                ],
              ),
            ).fadeAnimation(),
            const Spacer(),
            CircularButton(
              isValid: true,
              title: (!isLoading ? 'Allow' : 'Waiting'),
              onPressed: () {
                _getLocation();
              },
            )
                .fadeInAnimated()
                .symmetricPadding(horizontal: AppDimensions.medium),
          ],
        ).symmetricPadding(vertical: AppDimensions.medium.w),
      )),
    ));
  }

  void _getLocation() async {
    if (await sl<NetworkInfo>().isConnected!) {
      await _determinePosition();
      _goToNext();
    } else {
      _showErrorMessage();
    }
  }

  void _showErrorMessage() {
    AppUtils.showSnackBar(
        context, ExceptionErrors.checkInternetConnection.stringToString);
  }

  void _goToNext() =>
      Navigator.pushReplacementNamed(context, Routes.selectLanguageScreen);
}
