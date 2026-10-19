import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xplor/features/seeker_home/presentation/widgets/doctor_photo.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (var index = 1; index <= 3; index++) {
    test('bundled doctor portrait $index decodes', () async {
      final data = await rootBundle.load(
        'assets/images/doctor_placeholder_$index.jpg',
      );
      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List(
        data.offsetInBytes,
        data.lengthInBytes,
      ));
      final frame = await codec.getNextFrame();

      expect(frame.image.width, greaterThan(0));
      expect(frame.image.height, greaterThan(0));

      frame.image.dispose();
      codec.dispose();
    });
  }

  Future<void> pumpPhoto(
    WidgetTester tester, {
    String? imageUrl,
    String? doctorId = '1-63b60472-5667-44e2-92d0-00e417ae956d',
  }) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: DoctorPhoto(
          imageUrl: imageUrl,
          doctorId: doctorId,
        ),
      ),
    ));
    await tester.runAsync(() async {
      for (var index = 1; index <= 3; index++) {
        await precacheImage(
          AssetImage('assets/images/doctor_placeholder_$index.jpg'),
          tester.element(find.byType(DoctorPhoto)),
        );
      }
    });
    await tester.pumpAndSettle();
  }

  Finder placeholder(String asset) => find.byWidgetPredicate(
        (widget) =>
            widget is Image &&
            widget.image is AssetImage &&
            (widget.image as AssetImage).assetName == asset,
      );

  for (final imageUrl in <String?>[null, '', '   ']) {
    testWidgets('uses a local portrait for photo URL "$imageUrl"',
        (tester) async {
      await pumpPhoto(tester, imageUrl: imageUrl);

      expect(placeholder('assets/images/doctor_placeholder_1.jpg'),
          findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  const assignedDoctors = [
    (
      name: 'Ananya Sharma',
      id: '1-63b60472-5667-44e2-92d0-00e417ae956d',
      portrait: 'assets/images/doctor_placeholder_1.jpg',
    ),
    (
      name: 'Rajesh Kumar',
      id: '1-04f93c2b-9eec-48a0-a54a-b9cf0f7c1b21',
      portrait: 'assets/images/doctor_placeholder_2.jpg',
    ),
    (
      name: 'Meera Nair',
      id: '1-45839b1e-e5d1-4d73-abb5-e039aa84e871',
      portrait: 'assets/images/doctor_placeholder_3.jpg',
    ),
    (
      name: 'Pavan',
      id: '1-aba7673a-411d-4e47-bda5-a1fcfae2cc5f',
      portrait: 'assets/images/doctor_placeholder_2.jpg',
    ),
    (
      name: 'Vikram Singh',
      id: '1-3de2b7a7-a957-4b3c-8f81-7540a27eace0',
      portrait: 'assets/images/doctor_placeholder_2.jpg',
    ),
    (
      name: 'Test User',
      id: '1-b733d325-ebb1-4e7b-b7ad-41e5757a1cd6',
      portrait: 'assets/images/doctor_placeholder_2.jpg',
    ),
  ];

  for (final doctor in assignedDoctors) {
    testWidgets('uses the confirmed portrait for ${doctor.name}',
        (tester) async {
      await pumpPhoto(tester, doctorId: doctor.id);

      final portrait = placeholder(doctor.portrait);
      final image = tester.widget<Image>(portrait);
      expect(tester.getSize(find.byType(DoctorPhoto)), const Size(70, 70));
      expect(image.fit, BoxFit.cover);
      expect(image.alignment, Alignment.topCenter);
      expect(image.excludeFromSemantics, isTrue);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('keeps portraits consistent when doctors are reordered',
      (tester) async {
    for (final doctor in assignedDoctors.reversed) {
      await pumpPhoto(tester, doctorId: doctor.id);

      expect(placeholder(doctor.portrait), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });

  for (final doctorId in <String?>[null, 'unknown-doctor']) {
    testWidgets('uses a neutral fallback for unassigned doctor "$doctorId"',
        (tester) async {
      await pumpPhoto(tester, doctorId: doctorId);

      expect(find.byIcon(Icons.person_outline), findsOneWidget);
      expect(find.byType(Image), findsNothing);
      expect(tester.getSize(find.byType(DoctorPhoto)), const Size(70, 70));
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('retains supplied photo URLs and handles failed image requests',
      (tester) async {
    await pumpPhoto(
      tester,
      imageUrl: ' https://example.test/doctor.jpg ',
      doctorId: '1-04f93c2b-9eec-48a0-a54a-b9cf0f7c1b21',
    );

    final image = tester.widget<Image>(find.byWidgetPredicate(
      (widget) => widget is Image && widget.image is NetworkImage,
    ));
    expect(
        (image.image as NetworkImage).url, 'https://example.test/doctor.jpg');
    expect(
        placeholder('assets/images/doctor_placeholder_2.jpg'), findsOneWidget);
    expect(tester.getSize(find.byType(DoctorPhoto)), const Size(70, 70));
    expect(tester.takeException(), isNull);
  });
}
