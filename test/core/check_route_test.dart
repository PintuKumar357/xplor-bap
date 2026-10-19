import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xplor/config/routes/path_routing.dart';
import 'package:xplor/const/local_storage/shared_preferences_helper.dart';
import 'package:xplor/core/check_route.dart';
import 'package:xplor/core/dependency_injection.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SharedPreferencesHelper preferences;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    preferences = SharedPreferencesHelper();
    await preferences.init();
    sl.registerSingleton<SharedPreferencesHelper>(preferences);
  });

  tearDown(() async {
    await sl.reset();
  });

  final homeRoutes = {
    PrefConstKeys.seekerKey: Routes.seekerHome,
    PrefConstKeys.agentKey: Routes.home,
  };

  for (final entry in homeRoutes.entries) {
    for (final kycVerified in [false, true]) {
      test('routes ${entry.key} home with kycVerified=$kycVerified', () async {
        await preferences.setString(PrefConstKeys.selectedRole, entry.key);
        await preferences.setBoolean(PrefConstKeys.kycVerified, kycVerified);

        expect(checkRouteBasedOnUserJourney(), entry.value);
        expect(preferences.getBoolean('${PrefConstKeys.kyc}Done'), isTrue);
        expect(preferences.getBoolean(PrefConstKeys.isHomeOpen), isTrue);
        expect(preferences.getBoolean(PrefConstKeys.kycVerified), kycVerified);
      });
    }
  }

  test('defaults to agent home when the role is unset', () {
    expect(checkRouteBasedOnUserJourney(), Routes.home);
    expect(preferences.getBoolean('${PrefConstKeys.kyc}Done'), isTrue);
    expect(preferences.getBoolean(PrefConstKeys.isHomeOpen), isTrue);
    expect(preferences.getBoolean(PrefConstKeys.kycVerified), isFalse);
  });
}