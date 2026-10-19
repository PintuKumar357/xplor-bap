import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';
import 'package:xplor/features/appointmet/presentation/pages/create_appointment/view_appointment.dart';
import 'package:xplor/features/seeker_home/presentation/widgets/doctor_photo.dart';

class _TestController extends PlatformWebViewController {
  _TestController()
      : super.implementation(const PlatformWebViewControllerCreationParams());

  String? url;
  late void Function(PlatformWebViewPermissionRequest) onPermissionRequest;
  late PlatformNavigationDelegate navigationDelegate;

  @override
  Future<void> setJavaScriptMode(JavaScriptMode javaScriptMode) async {}

  @override
  Future<void> setPlatformNavigationDelegate(
      PlatformNavigationDelegate delegate) async {
    navigationDelegate = delegate;
  }

  @override
  Future<void> setOnPlatformPermissionRequest(
      void Function(PlatformWebViewPermissionRequest) callback) async {
    onPermissionRequest = callback;
  }

  @override
  Future<void> loadRequest(LoadRequestParams params) async {
    url = params.uri.toString();
  }

  @override
  Future<String?> currentUrl() async => url;
}

class _TestNavigationDelegate extends PlatformNavigationDelegate {
  _TestNavigationDelegate(super.params) : super.implementation();

  late NavigationRequestCallback onNavigationRequest;

  @override
  Future<void> setOnNavigationRequest(
      NavigationRequestCallback callback) async {
    onNavigationRequest = callback;
  }

  @override
  Future<void> setOnWebResourceError(WebResourceErrorCallback callback) async {}
}

class _TestWebViewWidget extends PlatformWebViewWidget {
  _TestWebViewWidget(super.params) : super.implementation();

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

class _TestPlatform extends WebViewPlatform {
  final controller = _TestController();

  @override
  PlatformWebViewController createPlatformWebViewController(
          PlatformWebViewControllerCreationParams params) =>
      controller;

  @override
  PlatformNavigationDelegate createPlatformNavigationDelegate(
          PlatformNavigationDelegateCreationParams params) =>
      _TestNavigationDelegate(params);

  @override
  PlatformWebViewWidget createPlatformWebViewWidget(
          PlatformWebViewWidgetCreationParams params) =>
      _TestWebViewWidget(params);
}

class _PermissionRequest extends PlatformWebViewPermissionRequest {
  _PermissionRequest(Set<WebViewPermissionResourceType> types)
      : super(types: types);

  bool granted = false;
  bool denied = false;

  @override
  Future<void> grant() async => granted = true;

  @override
  Future<void> deny() async => denied = true;
}

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  final originalPlatform = WebViewPlatform.instance;
  const permissionChannel =
      MethodChannel('flutter.baseflow.com/permissions/methods');
  const consultationUrl = 'https://8x8.vc/vpaas-test/consultation-14-45';
  late _TestPlatform platform;
  late List<List<int>> requestedPermissions;
  bool denyCamera = false;
  bool navigateDuringPrompt = false;
  bool failPermissionPrompt = false;

  setUp(() {
    platform = _TestPlatform();
    WebViewPlatform.instance = platform;
    requestedPermissions = [];
    denyCamera = false;
    navigateDuringPrompt = false;
    failPermissionPrompt = false;
    binding.defaultBinaryMessenger.setMockMethodCallHandler(permissionChannel,
        (call) async {
      if (call.method != 'requestPermissions') {
        throw PlatformException(code: 'unexpected-permission-method');
      }
      final permissions = (call.arguments as List).cast<int>();
      requestedPermissions.add(permissions);
      if (failPermissionPrompt)
        throw PlatformException(code: 'permission-error');
      if (navigateDuringPrompt) {
        platform.controller.url = 'https://8x8.vc/vpaas-test/another-room';
      }
      return {
        for (final permission in permissions)
          permission:
              denyCamera && permission == Permission.camera.value ? 0 : 1,
      };
    });
  });

  tearDown(() {
    binding.defaultBinaryMessenger
        .setMockMethodCallHandler(permissionChannel, null);
    WebViewPlatform.instance = originalPlatform ?? _TestPlatform();
  });

  Future<void> openConsultation(WidgetTester tester,
      {String url = consultationUrl}) async {
    await tester.pumpWidget(MaterialApp(home: WebViewPage(url: url)));
    await tester.pumpAndSettle();
  }

  testWidgets('appointment cards use consistent bundled doctor portraits',
      (tester) async {
    tester.view.physicalSize = const Size(393, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final allowRuntimeFetching = GoogleFonts.config.allowRuntimeFetching;
    GoogleFonts.config.allowRuntimeFetching = false;
    final messenger = binding.defaultBinaryMessenger;
    final originalHandler = messenger.allMessagesHandler;
    messenger.allMessagesHandler = (channel, handler, message) {
      if (channel == 'flutter/assets' && message != null) {
        final asset = utf8.decode(message.buffer.asUint8List(
          message.offsetInBytes,
          message.lengthInBytes,
        ));
        if (asset == 'AssetManifest.json') {
          return Future.value(ByteData.sublistView(Uint8List.fromList(
            utf8.encode(jsonEncode({
              'fonts/Manrope-Bold.ttf': ['fonts/Manrope-Bold.ttf'],
            })),
          )));
        }
        if (asset == 'fonts/Manrope-Bold.ttf') {
          return Future.value(ByteData(0));
        }
      }
      return originalHandler?.call(channel, handler, message) ??
          handler?.call(message) ??
          messenger.delegate.send(channel, message);
    };
    addTearDown(() {
      messenger.allMessagesHandler = originalHandler;
      GoogleFonts.config.allowRuntimeFetching = allowRuntimeFetching;
    });

    const femaleDoctorId = '1-63b60472-5667-44e2-92d0-00e417ae956d';
    const maleDoctorId = '1-aba7673a-411d-4e47-bda5-a1fcfae2cc5f';
    const otherFemaleDoctorId = '1-45839b1e-e5d1-4d73-abb5-e039aa84e871';
    final doctors = [
      {'osid': femaleDoctorId, 'doctorName': 'Dr. Ananya Sharma'},
      {
        'osid': maleDoctorId,
        'doctorName': 'Dr. Pavan',
        'doctorPhoto': '   ',
      },
      {'osid': otherFemaleDoctorId, 'doctorName': 'Dr. Meera Nair'},
    ];
    final appointments = [
      for (final doctorId in [
        maleDoctorId,
        femaleDoctorId,
        maleDoctorId,
        'doctor-missing',
        otherFemaleDoctorId,
      ])
        {
          'patientName': 'Test Patient',
          'doctorOsid': doctorId,
          'appointmentDate': '2026-10-13T10:00:00',
          'status': 'completed',
        },
    ];

    await http.runWithClient(() async {
      await tester.pumpWidget(ScreenUtilInit(
        designSize: const Size(393, 852),
        builder: (context, child) => const MaterialApp(
          home: ViewAppointment(phoneNumber: 'test-phone'),
        ),
      ));
      await tester.pumpAndSettle();
    },
        () => MockClient((request) async {
              final isHospital = request.url.path.endsWith('/Hospital/search');
              expect(request.method, 'POST');
              expect(
                isHospital || request.url.path.endsWith('/Appointment/search'),
                isTrue,
              );
              return http.Response(
                jsonEncode({'data': isHospital ? doctors : appointments}),
                200,
              );
            }));

    final photos = tester.widgetList<DoctorPhoto>(find.byType(DoctorPhoto));
    expect(photos.map((photo) => photo.doctorId), [
      maleDoctorId,
      femaleDoctorId,
      maleDoctorId,
      'doctor-missing',
      otherFemaleDoctorId,
    ]);
    expect(photos.first.imageUrl, '   ');
    expect(
      tester
          .widgetList<Image>(find.descendant(
            of: find.byType(DoctorPhoto),
            matching: find.byType(Image),
          ))
          .map((image) => (image.image as AssetImage).assetName),
      [
        'assets/images/doctor_placeholder_2.jpg',
        'assets/images/doctor_placeholder_1.jpg',
        'assets/images/doctor_placeholder_2.jpg',
        'assets/images/doctor_placeholder_3.jpg',
      ],
    );
    expect(find.byIcon(Icons.person_outline), findsOneWidget);
    expect(find.text('Completed'), findsNWidgets(5));
    for (final photo in find.byType(DoctorPhoto).evaluate()) {
      expect(tester.getSize(find.byWidget(photo.widget)), const Size(70, 70));
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('loads the exact stored meeting URL', (tester) async {
    await openConsultation(tester);

    expect(platform.controller.url, consultationUrl);
    expect(requestedPermissions, isEmpty);
  });

  testWidgets('grants camera and microphone only after runtime consent',
      (tester) async {
    await openConsultation(tester);
    final request = _PermissionRequest({
      WebViewPermissionResourceType.camera,
      WebViewPermissionResourceType.microphone,
    });

    platform.controller.onPermissionRequest(request);
    await tester.pumpAndSettle();

    expect(request.granted, isTrue);
    expect(request.denied, isFalse);
    expect(requestedPermissions.single,
        [Permission.camera.value, Permission.microphone.value]);
  });

  testWidgets('denies media access when camera permission is denied',
      (tester) async {
    denyCamera = true;
    await openConsultation(tester);
    final request = _PermissionRequest({WebViewPermissionResourceType.camera});

    platform.controller.onPermissionRequest(request);
    await tester.pumpAndSettle();

    expect(request.granted, isFalse);
    expect(request.denied, isTrue);
    expect(
        find.text('Camera or microphone access was denied.'), findsOneWidget);
  });

  testWidgets('requests only the microphone for an audio-only request',
      (tester) async {
    await openConsultation(tester);
    final request =
        _PermissionRequest({WebViewPermissionResourceType.microphone});

    platform.controller.onPermissionRequest(request);
    await tester.pumpAndSettle();

    expect(request.granted, isTrue);
    expect(requestedPermissions.single, [Permission.microphone.value]);
  });

  testWidgets('denies unknown resources without a runtime prompt',
      (tester) async {
    await openConsultation(tester);
    final request =
        _PermissionRequest({AndroidWebViewPermissionResourceType.midiSysex});

    platform.controller.onPermissionRequest(request);
    await tester.pumpAndSettle();

    expect(request.denied, isTrue);
    expect(requestedPermissions, isEmpty);
  });

  testWidgets('does not grant access after navigating away during a prompt',
      (tester) async {
    navigateDuringPrompt = true;
    await openConsultation(tester);
    final request =
        _PermissionRequest({WebViewPermissionResourceType.microphone});

    platform.controller.onPermissionRequest(request);
    await tester.pumpAndSettle();

    expect(request.granted, isFalse);
    expect(request.denied, isTrue);
  });

  testWidgets('denies access when the native permission prompt fails',
      (tester) async {
    failPermissionPrompt = true;
    await openConsultation(tester);
    final request =
        _PermissionRequest({WebViewPermissionResourceType.microphone});

    platform.controller.onPermissionRequest(request);
    await tester.pumpAndSettle();

    expect(request.granted, isFalse);
    expect(request.denied, isTrue);
  });

  testWidgets('blocks navigation away from the consultation host',
      (tester) async {
    await openConsultation(tester);
    final delegate =
        platform.controller.navigationDelegate as _TestNavigationDelegate;

    expect(
        await delegate.onNavigationRequest(const NavigationRequest(
          url: 'https://example.test/',
          isMainFrame: true,
        )),
        NavigationDecision.prevent);
  });

  testWidgets('does not load an untrusted initial URL', (tester) async {
    await openConsultation(tester, url: 'https://example.test/');

    expect(platform.controller.url, isNull);
    expect(
        find.text('This consultation link is not supported.'), findsOneWidget);
  });

  for (final url in [
    null,
    'http://8x8.vc/room',
    'https://8x8.vc.example.test/room',
    'https://8x8.vc:8443/room',
    'https://user@8x8.vc/room',
  ]) {
    test('rejects an untrusted consultation URL: $url', () {
      expect(isTrustedConsultationUrl(url), isFalse);
    });
  }
}
