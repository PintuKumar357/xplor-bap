import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xplor/const/local_storage/shared_preferences_helper.dart';
import 'package:xplor/core/dependency_injection.dart';
import 'package:xplor/features/on_boarding/domain/entities/user_data_entity.dart';
import 'package:xplor/features/profile/domain/entities/profile_activity_counts.dart';
import 'package:xplor/features/profile/domain/usecase/profile_usecase.dart';
import 'package:xplor/features/profile/presentation/bloc/seeker_profile_bloc/seeker_profile_bloc.dart';

class _ProfileUseCase extends Mock implements ProfileUseCase {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late _ProfileUseCase useCase;
  late UserDataEntity user;

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      PrefConstKeys.selectedLanguageCode: 'en',
    });
    final preferences = SharedPreferencesHelper();
    await preferences.init();
    sl.registerSingleton<SharedPreferencesHelper>(preferences);
    user = UserDataEntity.fromJson({
      'verified': true,
      'phoneNumber': '+910000000000',
      'wallet': 'test-wallet',
      'count': {
        'course': '0', 'scholarship': '0', 'retail': '0',
        'job': '0', 'orders': '0',
      },
    });
    useCase = _ProfileUseCase();
    when(() => useCase.getUserData()).thenAnswer((_) async => user);
    when(() => useCase.getActivityCounts(any())).thenAnswer(
      (_) async => const ProfileActivityCounts(appointments: 7, orders: 4),
    );
  });

  tearDown(() => sl.unregister<SharedPreferencesHelper>());

  blocTest<SeekerProfileBloc, SeekerProfileState>(
    'loads API totals after rendering profile data',
    build: () => SeekerProfileBloc(profileUseCase: useCase),
    act: (bloc) => bloc.add(const ProfileUserDataEvent(loadActivityCounts: true)),
    expect: () => [
      isA<SeekerProfileState>()
          .having((state) => state.profileState, 'state', ProfileState.loading),
      isA<SeekerProfileState>()
          .having((state) => state.profileState, 'state', ProfileState.done)
          .having((state) => state.isCountsLoading, 'loading counts', isTrue)
          .having((state) => state.userData, 'profile', same(user)),
      isA<SeekerProfileState>()
          .having((state) => state.profileState, 'state', ProfileState.done)
          .having((state) => state.activityCounts.appointments, 'appointments', 7)
          .having((state) => state.activityCounts.orders, 'orders', 4)
          .having((state) => state.isCountsLoading, 'loading counts', isFalse),
    ],
    verify: (_) {
      verify(() => useCase.getActivityCounts(user.phoneNumber!)).called(1);
      expect(user.count.job, '0');
      expect(user.count.orders, '0');
    },
  );

  blocTest<SeekerProfileBloc, SeekerProfileState>(
    'does not add count API requests to ordinary profile loads',
    build: () => SeekerProfileBloc(profileUseCase: useCase),
    act: (bloc) => bloc.add(const ProfileUserDataEvent()),
    expect: () => [
      isA<SeekerProfileState>()
          .having((state) => state.profileState, 'state', ProfileState.loading),
      isA<SeekerProfileState>()
          .having((state) => state.profileState, 'state', ProfileState.done),
    ],
    verify: (_) => verifyNever(() => useCase.getActivityCounts(any())),
  );

  blocTest<SeekerProfileBloc, SeekerProfileState>(
    'keeps a valid profile visible if counts fail',
    build: () {
      when(() => useCase.getActivityCounts(any()))
          .thenThrow(Exception('Counts unavailable'));
      return SeekerProfileBloc(profileUseCase: useCase);
    },
    act: (bloc) => bloc.add(const ProfileUserDataEvent(loadActivityCounts: true)),
    skip: 2,
    expect: () => [
      isA<SeekerProfileState>()
          .having((state) => state.profileState, 'state', ProfileState.done)
          .having((state) => state.userData, 'profile', same(user))
          .having((state) => state.activityCounts.appointments, 'appointments', isNull)
          .having((state) => state.activityCounts.orders, 'orders', isNull)
          .having((state) => state.isCountsLoading, 'loading counts', isFalse),
    ],
  );

  blocTest<SeekerProfileBloc, SeekerProfileState>(
    'preserves a valid zero when only one count is unavailable',
    build: () {
      when(() => useCase.getActivityCounts(any())).thenAnswer(
        (_) async => const ProfileActivityCounts(orders: 0),
      );
      return SeekerProfileBloc(profileUseCase: useCase);
    },
    act: (bloc) => bloc.add(const ProfileUserDataEvent(loadActivityCounts: true)),
    skip: 2,
    expect: () => [
      isA<SeekerProfileState>()
          .having((state) => state.activityCounts.appointments, 'appointments', isNull)
          .having((state) => state.activityCounts.orders, 'orders', 0),
    ],
  );

  test('ignores count results from an older profile refresh', () async {
    final firstCount = Completer<ProfileActivityCounts>();
    final firstStarted = Completer<void>();
    var calls = 0;
    when(() => useCase.getActivityCounts(any())).thenAnswer((_) {
      if (calls++ == 0) {
        firstStarted.complete();
        return firstCount.future;
      }
      return Future.value(const ProfileActivityCounts(appointments: 9, orders: 8));
    });
    final bloc = SeekerProfileBloc(profileUseCase: useCase);
    bloc.add(const ProfileUserDataEvent(loadActivityCounts: true));
    await firstStarted.future;
    final refreshed = bloc.stream.firstWhere(
      (state) => state.activityCounts.appointments == 9,
    );
    bloc.add(const ProfileUserDataEvent(loadActivityCounts: true));
    await refreshed;
    firstCount.complete(const ProfileActivityCounts(appointments: 1, orders: 2));
    await bloc.close();

    expect(bloc.state.activityCounts.appointments, 9);
    expect(bloc.state.activityCounts.orders, 8);
  });
}