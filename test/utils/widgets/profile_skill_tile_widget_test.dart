import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:xplor/gen/assets.gen.dart';
import 'package:xplor/utils/widgets/profile_skill_tile_widget.dart';

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
              for (final weight in ['Bold', 'SemiBold'])
                'fonts/Manrope-$weight.ttf': ['fonts/Manrope-$weight.ttf'],
            })),
          )));
        }
        if (asset.startsWith('fonts/Manrope-')) {
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

  Future<void> pumpTiles(
    WidgetTester tester, {
    double width = 393,
    double textScale = 1,
    String appointments = '1',
    String orders = '0',
    String appointmentTitle = 'Appointments',
    VoidCallback? onOrdersTap,
  }) async {
    tester.view.physicalSize = Size(width, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(ScreenUtilInit(
      designSize: const Size(393, 852),
      builder: (context, child) => MaterialApp(
        home: Scaffold(
          body: MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(textScale),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: ProfileSkillTileWidget(
                      fullWidthTitle: true,
                      title: appointmentTitle,
                      value: appointments,
                      icon: Assets.images.job,
                      backgroundColor: Colors.green.shade50,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: onOrdersTap,
                      child: ProfileSkillTileWidget(
                        fullWidthTitle: true,
                        title: 'Orders',
                        value: orders,
                        icon: Assets.images.skilling,
                        backgroundColor: Colors.blue.shade50,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();
  }

  void expectAlignedTiles(WidgetTester tester) {
    final tiles = find.byType(ProfileSkillTileWidget);
    final first = tester.getRect(tiles.at(0));
    final second = tester.getRect(tiles.at(1));
    expect(first.height, 104);
    expect(second.height, first.height);
    expect(second.width, first.width);
    expect(second.top, first.top);
    expect(second.left - first.right, 12);
    for (var index = 0; index < 2; index++) {
      final tile = tiles.at(index);
      final bounds = tester.getRect(tile);
      final labels = find.descendant(of: tile, matching: find.byType(Text));
      for (final element in labels.evaluate()) {
        final label = find.byWidget(element.widget);
        final paragraph = tester.renderObject<RenderParagraph>(label);
        expect(paragraph.didExceedMaxLines, isFalse);
        final labelBounds = tester.getRect(label);
        expect(labelBounds.left, greaterThanOrEqualTo(bounds.left));
        expect(labelBounds.right, lessThanOrEqualTo(bounds.right + 0.01));
        expect(labelBounds.bottom, lessThanOrEqualTo(bounds.bottom + 0.01));
      }
    }
    expect(tester.takeException(), isNull);
  }

  for (final width in [320.0, 360.0, 393.0, 412.0, 600.0]) {
    testWidgets('summary labels fit equal-height tiles at width $width',
        (tester) async {
      await pumpTiles(tester, width: width);

      expect(find.text('Appointments'), findsOneWidget);
      expect(find.text('Orders'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      expect(find.text('0'), findsOneWidget);
      expect(tester.widget<Text>(find.text('Appointments')).maxLines, 1);
      expectAlignedTiles(tester);
    });
  }

  testWidgets('long counts and large text do not resize the tiles',
      (tester) async {
    await pumpTiles(
      tester,
      width: 320,
      textScale: 2,
      appointments: '1234567',
      orders: '987654',
      appointmentTitle: 'Scheduled Appointments',
    );

    expect(find.text('1234567'), findsOneWidget);
    expect(find.text('987654'), findsOneWidget);
    expectAlignedTiles(tester);
  });

  testWidgets('keeps loading and unavailable values unchanged', (tester) async {
    await pumpTiles(tester, appointments: '...', orders: '-');

    expect(find.text('...'), findsOneWidget);
    expect(find.text('-'), findsOneWidget);
    expectAlignedTiles(tester);
  });

  testWidgets('preserves the Orders tap action', (tester) async {
    var taps = 0;
    await pumpTiles(tester, onOrdersTap: () => taps++);
    await tester.tap(find.text('Orders'));

    expect(taps, 1);
    expect(tester.takeException(), isNull);
  });
}
