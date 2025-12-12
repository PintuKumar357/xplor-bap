import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'DataTable_Page.dart';
import 'app/xplorapp.dart';
import 'utils/app_utils/app_utils.dart';
import 'const/bootstrap.dart';
import 'core/dependency_injection.dart';
import '../../../../../config/routes/path_routing.dart';
import 'config/services/app_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'features/appointmet/presentation/pages/create_appointment/view_appointment.dart';

void main() async {
  AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: 'basic_channel',
          channelName: 'Basic Notifications',
          channelDescription: 'Notification channel for basic tests',
          importance: NotificationImportance.High,
          enableVibration: true,
          playSound: true,
          enableLights: true,
          ledColor: Colors.white,
          channelShowBadge: true,
        ),
      ],
      debug: true);

  // Set up notification action listeners
  AwesomeNotifications().setListeners(
    onActionReceivedMethod: onActionReceivedMethod,
    onNotificationCreatedMethod: onNotificationCreatedMethod,
    onNotificationDisplayedMethod: onNotificationDisplayedMethod,
  );

  AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
    if (!isAllowed) {
      AwesomeNotifications().requestPermissionToSendNotifications();
    }
  });

  AwesomeNotifications().checkPermissionList(
    permissions: [NotificationPermission.PreciseAlarms],
  ).then((permissions) {
    if (!permissions.contains(NotificationPermission.PreciseAlarms)) {
      AwesomeNotifications().requestPermissionToSendNotifications(
        permissions: [NotificationPermission.PreciseAlarms],
      );
    }
  });

  WidgetsFlutterBinding.ensureInitialized();

  await initializeDependencies();

  // Check if token is saved
  final bool isLoggedIn = await AppUtils.checkToken();
  //const bool isLoggedIn = false;
  print("ok.........................................");
  print(isLoggedIn);
  print("ok.........................................");
  // Bootstrap the app
  bootstrap(() {
    return ScreenUtilInit(
      designSize: const Size(393, 852),
      builder: (context, child) {
        return XplorApp(isLoggedIn: isLoggedIn);
        //   return MaterialApp(
        //     debugShowCheckedModeBanner: false,
        //     title: 'Xplor App',
        //     initialRoute: isLoggedIn ? '/home' : '/registration', // Navigate based on login status
        //
        //     home: DataTablePage(), // Show RegistrationPage if not logged in
        //   );
      },
    );
  });
}

// Notification action handler
@pragma("vm:entry-point")
Future<void> onActionReceivedMethod(ReceivedAction receivedAction) async {
  print(
      'Notification tapped: ${receivedAction.payload} and ${AppServices.navState.currentContext}');

  // Navigate to ViewAppointment screen when notification is tapped
  // if (AppServices.navState.currentContext != null) {
  //   AppServices.navState.currentState?.pushNamed(
  //     Routes.viewAppointmentPage,
  //     arguments: receivedAction.payload,
  //   );
  // }

  await Future.delayed(Duration(milliseconds: 5000));

  // if (AppServices.navState.currentState != null) {
  //   try {
  //     // Get SharedPreferences and print all content
  //     final prefs = await SharedPreferences.getInstance();
  //     String? phoneNumber =
  //         prefs.getString('phoneNumber'); // This is the exact key

  //     if (phoneNumber != null) {
  //       phoneNumber = phoneNumber.replaceAll(' ', '');
  //     }

  //     // Pass null as userData since we don't have the full UserDataEntity from notification
  //     await AppServices.navState.currentState!.pushNamed(
  //       Routes.viewAppointmentPage,
  //       arguments:
  //           phoneNumber, // or create a UserDataEntity if you have the data
  //     );
  //     print('Navigation successful');
  //   } catch (e) {
  //     print('Navigation error: $e');
  //   }
  // }

  // if (AppServices.navState.currentState != null) {
  //   try {
  //     // Navigate directly to WebView with the test URL
  //     Navigator.push(
  //       AppServices.navState.currentContext!,
  //       MaterialPageRoute(
  //         builder: (context) => WebViewPage(
  //           url:
  //               'https://8x8.vc/vpaas-magic-cookie-cf5217ce8a4048d89baa3f88ab649551/tejash-TeleConsultation-2025-06-25-1-45%20PM',
  //         ),
  //       ),
  //     );
  //     print('WebView navigation successful');
  //   } catch (e) {
  //     print('WebView navigation error: $e');
  //   }
  // }

  if (AppServices.navState.currentState != null) {
    try {
      String? webViewLink = receivedAction.payload?['link'];
      String? minutesBefore = receivedAction.payload?['minutesBefore'];

      if (webViewLink != null && webViewLink.isNotEmpty) {
        // This is the 2-minute notification with WebView link
        Navigator.push(
          AppServices.navState.currentContext!,
          MaterialPageRoute(
            builder: (context) => WebViewPage(url: webViewLink),
          ),
        );
        print('WebView navigation successful with link: $webViewLink');
      } else {
        // This is the 15-minute notification, navigate to ViewAppointment
        final prefs = await SharedPreferences.getInstance();
        String? phoneNumber = prefs.getString('phoneNumber');

        if (phoneNumber != null) {
          phoneNumber = phoneNumber.replaceAll(' ', '');
        }

        await AppServices.navState.currentState!.pushNamed(
          Routes.viewAppointmentPage,
          arguments: phoneNumber,
        );
        print('ViewAppointment navigation successful');
      }
    } catch (e) {
      print('Navigation error: $e');
    }
  }
}

@pragma("vm:entry-point")
Future<void> onNotificationCreatedMethod(
    ReceivedNotification receivedNotification) async {
  // Handle when notification is created
}

@pragma("vm:entry-point")
Future<void> onNotificationDisplayedMethod(
    ReceivedNotification receivedNotification) async {
  // Handle when notification is displayed
}
