import '../../../on_boarding/domain/entities/user_data_entity.dart';
import '../entities/profile_activity_counts.dart';

/// Repository for interacting with user profile data.
abstract class ProfileRepository {
  /// Fetches the user's profile data.
  Future<UserDataEntity> getUserData();

  Future<ProfileActivityCounts> getActivityCounts(String phoneNumber);

  /// Performs a logout action for the user.
  Future<void> logout();
}
