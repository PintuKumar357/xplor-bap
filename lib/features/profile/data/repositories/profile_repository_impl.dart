import '../data_sources/profile_api_service.dart';
import '../../domain/repository/profile_repository.dart';
import '../../../../utils/extensions/string_to_string.dart';
import '../../../../core/connection/network_info.dart';
import '../../../../core/exception_errors.dart';
import '../../../on_boarding/domain/entities/user_data_entity.dart';
import '../../domain/entities/profile_activity_counts.dart';

/// Implementation of the ProfileRepository.
class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl({required this.apiService, required this.networkInfo});

  ProfileApiService apiService;
  NetworkInfo networkInfo;

  /// Fetches the user's profile data.
  @override
  Future<UserDataEntity> getUserData() async {
    if (await networkInfo.isConnected!) {
      return apiService.getUserData();
    } else {
      throw Exception(ExceptionErrors.checkInternetConnection.stringToString);
    }
  }

  @override
  Future<ProfileActivityCounts> getActivityCounts(String phoneNumber) async {
    if (await networkInfo.isConnected!) {
      return apiService.getActivityCounts(phoneNumber);
    }
    throw Exception(ExceptionErrors.checkInternetConnection.stringToString);
  }

  /// Performs a logout action for the user.
  @override
  Future<void> logout() async {
    if (await networkInfo.isConnected!) {
      return apiService.logout();
    } else {
      throw Exception(ExceptionErrors.checkInternetConnection.stringToString);
    }
  }
}
