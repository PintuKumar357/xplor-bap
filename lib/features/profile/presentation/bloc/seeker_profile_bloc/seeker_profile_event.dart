part of 'seeker_profile_bloc.dart';

/// Base class for all events related to seeker profile management.
/// Extends Equatable for efficient state comparison.
/// The `sealed` keyword indicates that this class is intended to be extended by a limited number of subclasses.
sealed class SeekerProfileEvent extends Equatable {
  const SeekerProfileEvent();

  /// Override of the props getter from Equatable.
  /// This helps in comparing instances of SeekerProfileEvent based on their properties.
  @override
  List<Object?> get props => [];
}

/// Event to load user data for the seeker profile.
/// This event can be dispatched to trigger the loading of user data from a repository or API.
class ProfileUserDataEvent extends SeekerProfileEvent {
  const ProfileUserDataEvent({this.loadActivityCounts = false});

  final bool loadActivityCounts;

  @override
  List<Object?> get props => [loadActivityCounts];
}

/// Event to handle profile and translation operations.
/// Includes an optional parameter to indicate if the translation process is complete.
class ProfileAndTranslationEvent extends SeekerProfileEvent {
  // Indicates whether the translation process has been completed.
  final bool? isTranslationDone;

  // Constructor with an optional parameter to indicate the status of translation.
  const ProfileAndTranslationEvent({this.isTranslationDone});

  // The props method is overridden to include the `isTranslationDone` property.
  // This allows Equatable to compare instances based on this property.
  @override
  List<Object?> get props => [isTranslationDone];
}

/// Event to handle user logout in the seeker profile.
/// This event can be dispatched to trigger the logout process, such as clearing user data and navigating to a login screen.
class SeekerProfileLogoutEvent extends SeekerProfileEvent {
  const SeekerProfileLogoutEvent();
}
