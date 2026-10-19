import '../repository/profile_repository.dart';
import '../../../on_boarding/domain/entities/user_data_entity.dart';
import '../entities/profile_activity_counts.dart';

/// Use case for interacting with user profile data and actions.
class ProfileUseCase {
  /// Repository responsible for accessing and managing profile data.
  final ProfileRepository repository;

  /// Constructor for the ProfileUseCase.
  ///
  /// Requires a [repository] to handle data operations.
  ProfileUseCase({required this.repository});

  /// Fetches the user's profile data.
  Future<UserDataEntity> getUserData() async {
    return await repository.getUserData();
  }

  Future<ProfileActivityCounts> getActivityCounts(String phoneNumber) {
    return repository.getActivityCounts(phoneNumber);
  }

  /// Performs a logout action for the user.
  Future<void> logout() async {
    return await repository.logout();
  }
}
