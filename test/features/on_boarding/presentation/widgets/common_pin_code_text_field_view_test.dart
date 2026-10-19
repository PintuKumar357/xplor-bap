import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:xplor/features/on_boarding/presentation/widgets/common_pin_code_text_field_view.dart';

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
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
  });

  Future<void> pumpPin(
    WidgetTester tester, {
    double viewportWidth = 393,
    double? fieldWidth,
    bool hidePin = false,
    bool readOnly = false,
    ValueChanged<String>? onChanged,
  }) async {
    tester.view.physicalSize = Size(viewportWidth, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(ScreenUtilInit(
      designSize: const Size(393, 852),
      builder: (context, child) => MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: CommonPinCodeTextField(
                    width: fieldWidth,
                    height: 45,
                    hidePin: hidePin,
                    isReadOnly: readOnly,
                    onChanged: onChanged,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  for (final viewportWidth in [320.0, 360.0, 393.0, 412.0, 600.0]) {
    testWidgets('all six OTP boxes fit a $viewportWidth-wide screen',
        (tester) async {
      await pumpPin(tester, viewportWidth: viewportWidth);

      final finder = find.byType(PinCodeTextField);
      final pin = tester.widget<PinCodeTextField>(finder);
      final bounds = tester.getRect(finder);
      expect(pin.length, 6);
      expect(
        (pin.pinTheme.fieldWidth + pin.pinTheme.fieldOuterPadding.horizontal) *
            pin.length,
        lessThanOrEqualTo(bounds.width + 0.01),
      );
      expect(find.text('0'), findsNWidgets(6));
      for (final digit in find.text('0').evaluate()) {
        final digitBounds = tester.getRect(find.byWidget(digit.widget));
        expect(digitBounds.left, greaterThanOrEqualTo(bounds.left));
        expect(digitBounds.right, lessThanOrEqualTo(bounds.right));
      }
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('constrains oversized custom PIN widths without changing height',
      (tester) async {
    await pumpPin(tester, viewportWidth: 320, fieldWidth: 80, hidePin: true);

    final finder = find.byType(PinCodeTextField);
    final pin = tester.widget<PinCodeTextField>(finder);
    expect(pin.pinTheme.fieldWidth, lessThan(80));
    expect(pin.pinTheme.fieldHeight, 45);
    expect(pin.obscureText, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('preserves a requested PIN width when it fits', (tester) async {
    await pumpPin(tester, fieldWidth: 30);

    final pin = tester.widget<PinCodeTextField>(find.byType(PinCodeTextField));
    expect(pin.pinTheme.fieldWidth, 30);
    expect(tester.takeException(), isNull);
  });

  testWidgets('still accepts only six digits and reports the entered value',
      (tester) async {
    final changes = <String>[];
    await pumpPin(tester, viewportWidth: 320, onChanged: changes.add);
    await tester.enterText(find.byType(TextField), '12a34567');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(changes.last, '123456');
    expect(tester.takeException(), isNull);
  });

  testWidgets('preserves the read-only state', (tester) async {
    await pumpPin(tester, viewportWidth: 320, readOnly: true);

    expect(tester.widget<TextField>(find.byType(TextField)).readOnly, isTrue);
    expect(tester.takeException(), isNull);
  });
}
