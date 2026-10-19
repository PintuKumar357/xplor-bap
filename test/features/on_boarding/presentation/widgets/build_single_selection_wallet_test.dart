import 'dart:convert';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xplor/const/local_storage/shared_preferences_helper.dart';
import 'package:xplor/core/dependency_injection.dart';
import 'package:xplor/features/on_boarding/domain/entities/e_auth_providers_entity.dart';
import 'package:xplor/features/on_boarding/presentation/widgets/build_single_selection_wallet.dart';

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  final allowRuntimeFetching = GoogleFonts.config.allowRuntimeFetching;
  late SharedPreferencesHelper preferences;

  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    binding.defaultBinaryMessenger.setMockMessageHandler('flutter/assets',
        (message) async {
      final asset = utf8.decode(message!.buffer.asUint8List(
        message.offsetInBytes,
        message.lengthInBytes,
      ));
      if (asset == 'AssetManifest.json') {
        return ByteData.sublistView(Uint8List.fromList(utf8.encode(jsonEncode({
          'fonts/Manrope-Regular.ttf': ['fonts/Manrope-Regular.ttf'],
          'fonts/Manrope-Bold.ttf': ['fonts/Manrope-Bold.ttf'],
        }))));
      }
      if (asset.startsWith('fonts/Manrope-')) {
        return ByteData(0);
      }
      return null;
    });
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    preferences = SharedPreferencesHelper();
    await preferences.init();
    sl.registerSingleton<SharedPreferencesHelper>(preferences);
  });

  tearDown(() async {
    await sl.reset();
  });

  tearDownAll(() {
    GoogleFonts.config.allowRuntimeFetching = allowRuntimeFetching;
    binding.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', null);
  });

  for (final code in ['googleAuth', 'dummyDigilocker']) {
    testWidgets('preserves and selects the $code provider from the backend',
        (tester) async {
      final title = code == 'googleAuth' ? 'Google' : 'Dummy Digilocker';
      final provider = EAuthProviderEntity(
        code: code,
        iconLink: 'https://example.test/provider.png',
        title: title,
        subTitle: 'Continue with $title',
        redirectUrl: 'https://example.test/auth/$code',
      );
      int? selectedIndex;

      await tester.pumpWidget(ScreenUtilInit(
        designSize: const Size(393, 852),
        builder: (context, child) => MaterialApp(
          home: Scaffold(
            body: SingleSelectionWallet(
              selectedIndex: -1,
              onIndexChanged: (index) => selectedIndex = index,
              entity: provider,
            ),
          ),
        ),
      ));
      await tester.pump();

      expect(find.text(title), findsOneWidget);
      expect(find.text('Continue with $title'), findsOneWidget);
      expect(provider.title, title);
      expect(provider.subTitle, 'Continue with $title');
      expect(provider.iconLink, 'https://example.test/provider.png');
        expect(tester.widget<CachedNetworkImage>(find.byType(CachedNetworkImage))
          .imageUrl, provider.iconLink);

      await tester.tap(find.text(title));
      await tester.pump();

      expect(selectedIndex, 0);
      expect(preferences.getString(PrefConstKeys.kycRedirectUrl),
          provider.redirectUrl);
      expect(preferences.getBoolean(PrefConstKeys.kycVerified), isFalse);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }
}
