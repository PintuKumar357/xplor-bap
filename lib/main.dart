import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'DataTable_Page.dart';
import 'app/xplorapp.dart';
import 'utils/app_utils/app_utils.dart';
import 'const/bootstrap.dart';
import 'core/dependency_injection.dart';

void main() async {
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
