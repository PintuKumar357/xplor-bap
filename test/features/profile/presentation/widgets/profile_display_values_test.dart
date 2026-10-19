import 'package:flutter_test/flutter_test.dart';
import 'package:xplor/features/on_boarding/domain/entities/user_data_entity.dart';
import 'package:xplor/features/profile/presentation/widgets/profile_display_values.dart';

UserDataEntity userWithKyc(Map<String, dynamic>? kyc) {
  return UserDataEntity.fromJson({
    'verified': true,
    'kycStatus': false,
    'kyc': kyc == null
        ? null
        : {
            ...kyc,
            'provider': {'id': 'test-provider-id', 'name': 'test-provider'},
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
  test('uses the requested defaults without a profile', () {
    expect(profileDisplayName(null), 'Pintu Kumar');
    expect(profileDisplayEmail(null), 'kushpintu355@gamil.com');
  });

  test('uses display defaults without creating or verifying KYC', () {
    final user = userWithKyc(null);

    expect(profileDisplayName(user), 'Pintu Kumar');
    expect(profileDisplayEmail(user), 'kushpintu355@gamil.com');
    expect(user.kyc, isNull);
    expect(user.kycStatus, isFalse);
  });

  for (final missingValue in ['', 'NA', 'null', ' Null ']) {
    test('does not display placeholder "$missingValue" as a name or email', () {
      final user = userWithKyc({
        'firstName': missingValue,
        'lastName': missingValue,
        'email': missingValue,
      });

      expect(profileDisplayName(user), 'Pintu Kumar');
      expect(profileDisplayEmail(user), 'kushpintu355@gamil.com');
    });
  }

  test('preserves real server values', () {
    final user = userWithKyc({
      'firstName': 'Existing',
      'lastName': 'User',
      'email': 'existing@example.test',
    });
    final originalKyc = user.kyc!.toJson();

    expect(profileDisplayName(user), 'Existing User');
    expect(profileDisplayEmail(user), 'existing@example.test');
    expect(user.kyc!.toJson(), originalKyc);
  });

  test('shows a partial name without appending null', () {
    final user = userWithKyc({'firstName': ' Pintu ', 'lastName': null});

    expect(profileDisplayName(user), 'Pintu');
  });
}