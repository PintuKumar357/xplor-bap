part of 'seeker_profile_bloc.dart';

/// Enumeration representing different states of the profile.
enum ProfileState {
  loading, // Profile data is currently being loaded.
  initial, // Initial state before any actions are taken.
  done, // Profile actions have been completed successfully.
  userDataLoaded, // User data has been successfully loaded.
  failure // An error occurred while loading or processing profile data.
}

/// Base state class for the seeker profile, implementing Equatable for efficient state comparisons.
class SeekerProfileState extends Equatable {
  // Current state of the profile.
  final ProfileState profileState;

  // Optional user data associated with the profile.
  final UserDataEntity? userData;

  // Optional message for additional state information or error messages.
  final String? message;

  // Unique identifier to differentiate state instances, often used for UI updates.
  final int uniqueId;
  final ProfileActivityCounts activityCounts;
  final bool isCountsLoading;

  // Constructor for SeekerProfileState with default and named parameters.
  const SeekerProfileState({
    this.profileState = ProfileState.initial, // Default state is initial.
    this.userData, // Optional user data.
    this.message, // Optional message.
    this.uniqueId = 0, // Default uniqueId, can be replaced with DateTime.now().millisecondsSinceEpoch if needed.
    this.activityCounts = const ProfileActivityCounts(),
    this.isCountsLoading = false,
  });

  // Creates a copy of the current state with overridden values.
  SeekerProfileState copyWith({
    ProfileState? profileState,
    UserDataEntity? userData,
    String? message,
    int? uniqueId,
    ProfileActivityCounts? activityCounts,
    bool? isCountsLoading,
  }) {
    return SeekerProfileState(
      profileState: profileState ?? this.profileState,
      userData: userData ?? this.userData,
      message: message ?? this.message,
      uniqueId: uniqueId ?? this.uniqueId,
      activityCounts: activityCounts ?? this.activityCounts,
      isCountsLoading: isCountsLoading ?? this.isCountsLoading,
    );
  }

  // Equatable override to specify properties used for comparison.
  @override
  List<Object?> get props => [
        profileState, userData, message, uniqueId,
        activityCounts, isCountsLoading,
      ];
}

/// Initial state of the profile, which is a subclass of SeekerProfileState.
class ProfileInitialState extends SeekerProfileState {
  ProfileInitialState() : super(uniqueId: DateTime.now().millisecondsSinceEpoch);
}

/// State indicating that the user has logged out.
class ProfileLogoutState extends SeekerProfileState {}
