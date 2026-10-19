import 'dart:convert';
import 'dart:typed_data';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:intl/intl.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xplor/core/dependency_injection.dart';
import 'package:xplor/features/appointmet/presentation/pages/create_appointment/create_appointment.dart';
import 'package:xplor/features/appointmet/presentation/pages/doctor/doctor.dart';
import 'package:xplor/features/on_boarding/domain/entities/user_data_entity.dart';
import 'package:xplor/features/profile/presentation/bloc/seeker_profile_bloc/seeker_profile_bloc.dart';
import 'package:xplor/features/wallet/domain/usecase/wallet_usecase.dart';

class _BookingProfileBloc
    extends MockBloc<SeekerProfileEvent, SeekerProfileState>
    implements SeekerProfileBloc {}

class _BookingWalletUseCase extends Mock implements WalletUseCase {}

UserDataEntity _bookingUser({String? email, String? wallet}) {
  return UserDataEntity.fromJson({
    'phoneNumber': '+910000000000',
    'verified': true,
    'kycStatus': email != null,
    'wallet': wallet,
    'kyc': email == null
        ? null
        : {
            'firstName': 'Account Holder',
            'email': email,
            'provider': {'id': 'account-abha-id', 'name': 'ABHA'},
          },
    'count': {
      'course': '0',
      'scholarship': '0',
      'retail': '0',
      'job': '0',
      'orders': '0',
    },
  });
}

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  for (final spacing in {
    'plain': ' ',
    'narrow no-break': '\u202F',
    'no-break': '\u00A0',
  }.entries) {
    test('normalizes ${spacing.key} spacing in appointment times', () {
      final time = convertTo24HourFormat('2:45${spacing.value}PM');

      expect(time, '14:45');
      expect(time.replaceAll(':', '-'), '14-45');
    });
  }

  test('converts the actual time-slot picker output', () {
    final slot = DateFormat.jm('en_US').format(DateTime(2026, 10, 13, 14, 45));

    expect(convertTo24HourFormat(slot), '14:45');
  });

  test('converts midnight and noon with narrow spaces', () {
    expect(convertTo24HourFormat('12:00\u202FAM'), '00:00');
    expect(convertTo24HourFormat('12:00\u202FPM'), '12:00');
  });

  test('preserves the existing fallback for invalid times', () {
    expect(convertTo24HourFormat('invalid'), 'invalid');
  });

  test('uses a valid profile wallet without fetching another wallet', () async {
    final walletId = await resolveAppointmentWalletId(
      profileWalletId: '  profile-wallet  ',
      fetchWalletId: () async {
        fail('A valid profile wallet must not trigger a wallet request.');
      },
    );

    expect(walletId, 'profile-wallet');
  });

  for (final missingWallet in <String?>[
    null,
    '',
    '   ',
    'null',
    ' NA ',
    'n/a',
    'undefined',
  ]) {
    test(
        'fetches the wallet when profile has "$missingWallet" (${missingWallet.runtimeType})',
        () async {
      var requests = 0;
      final walletId = await resolveAppointmentWalletId(
        profileWalletId: missingWallet,
        fetchWalletId: () async {
          requests++;
          return '  fetched-wallet  ';
        },
      );

      expect(walletId, 'fetched-wallet');
      expect(requests, 1);
    });
  }

  for (final missingWallet in ['', '   ', 'null', 'NA', 'n/a', 'undefined']) {
    test('rejects an unavailable wallet returned as "$missingWallet"',
        () async {
      await expectLater(
        resolveAppointmentWalletId(
          profileWalletId: null,
          fetchWalletId: () async => missingWallet,
        ),
        throwsA(isA<StateError>().having(
          (error) => error.message,
          'message',
          contains('Wallet ID is unavailable'),
        )),
      );
    });
  }

  test('does not suppress wallet lookup failures', () async {
    final failure = Exception('Wallet service unavailable');

    await expectLater(
      resolveAppointmentWalletId(
        profileWalletId: '',
        fetchWalletId: () async => throw failure,
      ),
      throwsA(same(failure)),
    );
  });

  final beneficiary = Beneficiary(
    name: 'Test Patient',
    relationship: 'family',
    age: 30,
    abhaId: 'test-abha-id',
  );

  for (final email in [null, '', 'NA', 'null', 'patient@example.test']) {
    final hasKyc = email != null;
    for (final hasWallet in [false, true]) {
      test(
          'booking validates wallet with KYC=$hasKyc, email=$email and wallet=$hasWallet',
          () {
        final user = _bookingUser(
          email: email,
          wallet: hasWallet ? 'test-wallet' : null,
        );

        Map<String, dynamic> buildPayload({String? walletId}) =>
            buildAppointmentPayload(
              beneficiary: beneficiary,
              userData: user,
              doctorId: 'test-doctor',
              appointmentDate: '2026-10-13 14:01',
              link: 'https://example.test/consultation',
              walletId: walletId,
            );

        if (!hasWallet) {
          expect(() => buildPayload(), throwsStateError);
        }

        final payload = jsonDecode(jsonEncode(buildPayload(
          walletId: hasWallet ? null : '  fetched-wallet  ',
        ))) as Map<String, dynamic>;

        expect(payload.values, isNot(contains(null)));
        expect(payload['email'],
            email == 'patient@example.test' ? email : 'kushpintu355@gamil.com');
        expect(
            payload['walletId'], hasWallet ? 'test-wallet' : 'fetched-wallet');
        expect(user.wallet, hasWallet ? 'test-wallet' : '');
        expect(payload['abhaId'], beneficiary.abhaId);
        expect(payload['patientName'], beneficiary.name);
        expect(payload['mobile'], user.phoneNumber);
        expect(payload['doctorOsid'], 'test-doctor');
        expect(payload['appointmentDate'], '2026-10-13 14:01');
        expect(payload['link'], 'https://example.test/consultation');
        expect(payload['status'], 'new');
        expect(payload['prescription'], '');
      });
    }
  }

  for (final fetchedWallet in ['', 'authenticated-wallet']) {
    testWidgets('booking request is gated by wallet "$fetchedWallet"',
        (tester) async {
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      SharedPreferences.setMockInitialValues({});

      final profileBloc = _BookingProfileBloc();
      when(() => profileBloc.state).thenReturn(SeekerProfileState(
        profileState: ProfileState.done,
        userData: _bookingUser(email: 'patient@example.test'),
      ));
      addTearDown(profileBloc.close);

      final walletUseCase = _BookingWalletUseCase();
      when(() => walletUseCase.getWalletId())
          .thenAnswer((_) async => fetchedWallet);
      sl.registerSingleton<WalletUseCase>(walletUseCase);
      addTearDown(() => sl.unregister<WalletUseCase>());

      final notificationCalls = <String>[];
      final allowRuntimeFetching = GoogleFonts.config.allowRuntimeFetching;
      GoogleFonts.config.allowRuntimeFetching = false;
      final messenger = binding.defaultBinaryMessenger;
      final originalHandler = messenger.allMessagesHandler;
      messenger.allMessagesHandler = (channel, handler, message) {
        if (channel.contains('awesome_notifications')) {
          notificationCalls.add(channel);
        }
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

      final postedAppointments = <Map<String, dynamic>>[];
      await http.runWithClient(() async {
        await tester.pumpWidget(BlocProvider<SeekerProfileBloc>.value(
          value: profileBloc,
          child: ScreenUtilInit(
            designSize: const Size(393, 852),
            builder: (context, child) => MaterialApp(
              home: CreateAppointment(
                doctor: Doctor(
                  name: 'Test Doctor',
                  specialty: 'General',
                  imageUrl: 'https://example.test/doctor.jpg',
                  hospital: 'Test Hospital',
                  id: 'test-doctor',
                ),
              ),
            ),
          ),
        ));
        await tester.pump();
        await tester.pump();

        final availableSlot = find
            .byWidgetPredicate(
              (widget) => widget is ChoiceChip && widget.onSelected != null,
            )
            .first;
        await tester.ensureVisible(availableSlot);
        await tester.tap(availableSlot);
        await tester.pump();
        final bookButton =
            find.widgetWithText(ElevatedButton, 'Book Appointment');
        await tester.ensureVisible(bookButton);
        await tester.tap(bookButton);
        await tester.pump();
        await tester.pump();
      },
          () => MockClient((request) async {
                expect(request.method, 'POST');
                expect(request.url.path, '/registry/api/v1/Appointment');
                postedAppointments
                    .add(jsonDecode(request.body) as Map<String, dynamic>);
                return http.Response('{}', 500);
              }));

      verify(() => walletUseCase.getWalletId()).called(1);
      if (fetchedWallet.isEmpty) {
        expect(postedAppointments, isEmpty);
        expect(find.textContaining('Wallet ID is unavailable'), findsOneWidget);
      } else {
        expect(postedAppointments.single['walletId'], fetchedWallet);
        expect(postedAppointments.single['doctorOsid'], 'test-doctor');
        expect(find.textContaining('HTTP 500'), findsOneWidget);
      }
      expect(notificationCalls, isEmpty);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }
}
