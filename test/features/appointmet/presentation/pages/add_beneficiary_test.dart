import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xplor/features/appointmet/presentation/pages/create_appointment/add_beneficiary.dart';

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  const formatter = AbhaIdInputFormatter();

  TextEditingValue value(String text, {int? offset}) => TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: offset ?? text.length),
      );

  for (final example in [
    '70-7463-2446-5247',
    '61-5230-2840-0239',
    '91-0024-8831-5062',
  ]) {
    test('formats digits as $example', () {
      final result = formatter.formatEditUpdate(
        TextEditingValue.empty,
        value(example.replaceAll('-', '')),
      );

      expect(result.text, example);
      expect(result.selection.baseOffset, example.length);
    });

    test('accepts a pasted formatted ID $example', () {
      final result = formatter.formatEditUpdate(
        TextEditingValue.empty,
        value(example),
      );

      expect(result.text, example);
      expect(result.selection.baseOffset, example.length);
    });
  }

  test('adds separators progressively while typing', () {
    const digits = '70746324465247';
    const expected = [
      '7', '70', '70-7', '70-74', '70-746', '70-7463',
      '70-7463-2', '70-7463-24', '70-7463-244', '70-7463-2446',
      '70-7463-2446-5', '70-7463-2446-52', '70-7463-2446-524',
      '70-7463-2446-5247',
    ];
    var current = TextEditingValue.empty;
    for (var index = 0; index < digits.length; index++) {
      current = formatter.formatEditUpdate(
        current,
        value('${current.text}${digits[index]}'),
      );
      expect(current.text, expected[index]);
      expect(current.selection.baseOffset, current.text.length);
    }
  });

  test('removes letters, spaces, and user-entered punctuation', () {
    final result = formatter.formatEditUpdate(
      TextEditingValue.empty,
      value('ABHA: 70--7463 / 2446.5247!'),
    );

    expect(result.text, '70-7463-2446-5247');
  });

  test('limits pasted numbers to 14 digits', () {
    final result = formatter.formatEditUpdate(
      TextEditingValue.empty,
      value('707463244652479999'),
    );

    expect(result.text, '70-7463-2446-5247');
    expect(result.selection.baseOffset, 17);
  });

  test('does not replace the last digit when typing into a full ID', () {
    final previous = value('70-7463-2446-5247', offset: 4);
    final result = formatter.formatEditUpdate(
      previous,
      value('70-79463-2446-5247', offset: 5),
    );

    expect(result, previous);
  });

  test('keeps the cursor next to an insertion in the middle', () {
    final result = formatter.formatEditUpdate(
      value('70-746', offset: 4),
      value('70-7846', offset: 5),
    );

    expect(result.text, '70-7846');
    expect(result.selection.baseOffset, 5);
  });

  test('allows backspacing across an automatic separator', () {
    final afterSeparator = formatter.formatEditUpdate(
      value('70-7463', offset: 3),
      value('707463', offset: 2),
    );
    expect(afterSeparator.text, '70-7463');
    expect(afterSeparator.selection.baseOffset, 2);

    final afterDigit = formatter.formatEditUpdate(
      afterSeparator,
      value('7-7463', offset: 1),
    );
    expect(afterDigit.text, '77-463');
    expect(afterDigit.selection.baseOffset, 1);
  });

  test('allows clearing the field', () {
    final result = formatter.formatEditUpdate(
      value('70-7463-2446-5247'),
      value(''),
    );

    expect(result.text, isEmpty);
    expect(result.selection.baseOffset, 0);
  });

  test('reports letters even when the accepted field value is unchanged', () {
    final invalidInputs = <bool>[];
    final feedbackFormatter = AbhaIdInputFormatter(
      onInvalidInput: invalidInputs.add,
    );
    final previous = value('70');
    final rejected = feedbackFormatter.formatEditUpdate(previous, value('70a'));
    expect(rejected.text, previous.text);
    expect(invalidInputs, [true]);

    final accepted = feedbackFormatter.formatEditUpdate(rejected, value('707'));
    expect(accepted.text, '70-7');
    expect(invalidInputs, [true, false]);
  });

  test('does not flag the hyphens in a pasted formatted ID', () {
    final invalidInputs = <bool>[];
    AbhaIdInputFormatter(onInvalidInput: invalidInputs.add).formatEditUpdate(
      TextEditingValue.empty,
      value('70-7463-2446-5247'),
    );

    expect(invalidInputs, [false]);
  });

  group('ABHA ID field', () {
    const digitsHint =
        'Only digits are allowed; hyphens are added automatically.';
    late bool allowRuntimeFetching;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      allowRuntimeFetching = GoogleFonts.config.allowRuntimeFetching;
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

    Finder field(String label) => find.byWidgetPredicate(
          (widget) => widget is TextField && widget.decoration?.labelText == label,
        );

    Future<void> openForm(WidgetTester tester) async {
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(ScreenUtilInit(
        designSize: const Size(393, 852),
        builder: (context, child) => MaterialApp(
          home: Scaffold(
            body: Builder(builder: (context) {
              return TextButton(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const AddBeneficiaryPage(),
                )),
                child: const Text('Open form'),
              );
            }),
          ),
        ),
      ));
      await tester.tap(find.text('Open form'));
      await tester.pumpAndSettle();
    }

    testWidgets('shows a hint for letters and clears it after valid input',
        (tester) async {
      await openForm(tester);
      final abhaField = field('ABHA ID');
      expect(tester.widget<TextField>(abhaField).keyboardType,
          TextInputType.number);
      expect(tester.widget<TextField>(abhaField).decoration!.hintText,
          'XX-XXXX-XXXX-XXXX');

      await tester.enterText(abhaField, 'abc');
      await tester.pumpAndSettle();
      expect(tester.widget<TextField>(abhaField).controller!.text, isEmpty);
      expect(find.text(digitsHint), findsOneWidget);

      await tester.enterText(abhaField, '70');
      await tester.pumpAndSettle();
      expect(find.text(digitsHint), findsNothing);

      await tester.enterText(abhaField, '70a');
      await tester.pumpAndSettle();
      expect(tester.widget<TextField>(abhaField).controller!.text, '70');
      expect(find.text(digitsHint), findsOneWidget);

      await tester.enterText(abhaField, '70746324465247');
      await tester.pumpAndSettle();
      expect(tester.widget<TextField>(abhaField).controller!.text,
          '70-7463-2446-5247');
      expect(find.text(digitsHint), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('does not warn when a formatted ID is pasted', (tester) async {
      await openForm(tester);
      await tester.enterText(field('ABHA ID'), '61-5230-2840-0239');
      await tester.pumpAndSettle();

      expect(tester.widget<TextField>(field('ABHA ID')).controller!.text,
          '61-5230-2840-0239');
      expect(find.text(digitsHint), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('rejects an incomplete ID and saves a complete formatted ID',
        (tester) async {
      await openForm(tester);
      await tester.enterText(field('Beneficiary Name'), 'Test Beneficiary');
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Other').last);
      await tester.pumpAndSettle();
      await tester.enterText(field('Age'), '30');
      await tester.enterText(field('ABHA ID'), '707');
      tester.testTextInput.hide();
      await tester.pumpAndSettle();

      final submitButton =
          find.widgetWithText(ElevatedButton, 'Add Beneficiary');
      await tester.ensureVisible(submitButton);
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      final preferences = await SharedPreferences.getInstance();
      expect(preferences.getStringList('beneficiaries'), isNull);
      expect(find.text('Enter a 14-digit ABHA ID (XX-XXXX-XXXX-XXXX)'),
          findsOneWidget);

      await tester.enterText(field('ABHA ID'), '91002488315062');
      tester.testTextInput.hide();
      await tester.pumpAndSettle();
      await tester.ensureVisible(submitButton);
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      final saved = jsonDecode(
        preferences.getStringList('beneficiaries')!.single,
      ) as Map<String, dynamic>;
      expect(saved['abhaId'], '91-0024-8831-5062');
      expect(saved['name'], 'Test Beneficiary');
      expect(saved['relationship'], 'Other');
      expect(saved['age'], 30);
      expect(find.byType(AddBeneficiaryPage), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
}