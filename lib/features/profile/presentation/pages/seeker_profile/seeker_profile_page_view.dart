import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../config/routes/path_routing.dart';
import '../../bloc/seeker_profile_bloc/seeker_profile_bloc.dart';
import '../../../../../utils/mapping_const.dart';
import '../../../../../const/local_storage/shared_preferences_helper.dart';
import '../../../../../core/dependency_injection.dart';
import '../../../../../utils/app_utils/app_utils.dart';
import '../../../../../utils/widgets/loading_animation.dart';
import '../../../../multi_lang/presentation/blocs/bloc/translate_bloc.dart';
import '../../widgets/logout_button_widget.dart';
import '../../widgets/profile_display_values.dart';
import '../../widgets/profile_option_widget.dart';
import '../../../../../utils/common_top_header.dart';
import '../../../../../utils/extensions/padding.dart';
import '../../../../../utils/extensions/string_to_string.dart';
import '../../../../../gen/assets.gen.dart';
import '../../../../../utils/app_colors.dart';
import '../../../../../utils/app_dimensions.dart';
import '../../../../multi_lang/domain/mappers/profile/profile_keys.dart';
import '../../../domain/entities/profile_card_options_entity.dart';
import '../../../../../utils/widgets/profile_header__widget.dart';
import '../../../../../utils/widgets/profile_skill_tile_widget.dart';

/// The main view for the Seeker Profile page.
/// Displays profile information, various options, and a logout button.
class SeekerProfilePageView extends StatefulWidget {
  const SeekerProfilePageView({super.key});

  @override
  State<SeekerProfilePageView> createState() => _SeekerProfilePageViewState();
}

class _SeekerProfilePageViewState extends State<SeekerProfilePageView> {
  /// List of profile card options.
  List<ProfileCardOptionsEntity> _profileCardOptions = [];

  @override
  void initState() {
    super.initState();
    // Load the profile card options based on the selected language.
    if (sl<SharedPreferencesHelper>().getString(PrefConstKeys.selectedLanguageCode) != "en") {
      context.read<TranslationBloc>().add(TranslateDynamicTextEvent(
          langCode: sl<SharedPreferencesHelper>().getString(PrefConstKeys.selectedLanguageCode),
          moduleTypes: profileModule,
          isNavigation: true));
    } else {
      // Initialize profile card options for the default language (English).
      _profileCardOptions.clear();
      _profileCardOptions = __profileCardOptions();
    }
    // Trigger an event to load user data for the profile.
    context.read<SeekerProfileBloc>().add(
      const ProfileUserDataEvent(loadActivityCounts: true),
    );
  }

  List<ProfileCardOptionsEntity> __profileCardOptions() {
    return [
      ProfileCardOptionsEntity(
        title: ProfileKeys.myAccount.stringToString,
        subTitle: ProfileKeys.editProfile.stringToString,
        icon: Assets.images.editProfile,
      ),
      ProfileCardOptionsEntity(
          title: "Beneficiary",
          subTitle: " Add or Edit Beneficiary",
          icon: Assets.images.user,
          route: Routes.ViewBeneficiaryPage
      ),
      // ProfileCardOptionsEntity(
      //     title: "View Beneficiary",
      //     subTitle: "Appointment",
      //     icon: Assets.images.editProfile,
      //     route: Routes.ViewBeneficiaryPage
      // ),
      ProfileCardOptionsEntity(
          title: "Appointments",
          subTitle: "View Appointment",
          icon: Assets.images.benificary,
          route: Routes.viewAppointmentPage
      ),
      ProfileCardOptionsEntity(
          title: "Prescription",
          subTitle: "Order Medicine",
          icon: Assets.images.prescription,
          route: Routes.IssuePrescriptionPage
      ),
      ProfileCardOptionsEntity(
          title: "Health Records",
          subTitle: "Records",
          icon: Assets.images.records,
          route: Routes.HealthDocuments
      ),
      ProfileCardOptionsEntity(
        title: ProfileKeys.accountPrivacy.stringToString,
        subTitle: ProfileKeys.accountPrivacyDesc.stringToString,
        icon: Assets.images.accountPrivacy,
      ),
      ProfileCardOptionsEntity(
        title: ProfileKeys.settings.stringToString,
        subTitle: ProfileKeys.settingsDesc.stringToString,
        icon: Assets.images.profileSetting,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // Listen for changes in SeekerProfileBloc state.
        BlocListener<SeekerProfileBloc, SeekerProfileState>(
          listener: (context, state) {
            // Show a snackbar for errors.
            if (state.profileState == ProfileState.failure) {
              AppUtils.showSnackBar(context, state.message.toString());
            }
            // Handle logout state.
            if (state is ProfileLogoutState) {
              AppUtils.clearSession();
              AppUtils.disposeAllBlocs(context);
              Navigator.pushNamedAndRemoveUntil(context, Routes.main, (routes) => false);
            }
            // Load translations after user data is loaded.
            if (state.profileState == ProfileState.userDataLoaded) {
              context.read<SeekerProfileBloc>().add(const ProfileAndTranslationEvent());
            }
          },
        ),
        // Listen for changes in TranslationBloc state.
        BlocListener<TranslationBloc, TranslateState>(
          listener: (context, state) {
            if (state is TranslationLoaded && state.isNavigation) {
              _profileCardOptions.clear();
              _profileCardOptions = __profileCardOptions();
              context.read<SeekerProfileBloc>().add(const ProfileAndTranslationEvent(isTranslationDone: true));
            }
          },
        ),
      ],
      child: BlocBuilder<SeekerProfileBloc, SeekerProfileState>(
        builder: (context, state) {
          return Stack(
            children: [
              CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: (state.profileState == ProfileState.done && state.userData != null)
                        ? Column(
                            children: [
                              CommonTopHeader(
                                title: ProfileKeys.myProfile.stringToString,
                                isTitleOnly: true,
                                dividerColor: AppColors.checkBoxDisableColor,
                                onBackButtonPressed: () {},
                              ),
                              bodyView(state),
                              AppDimensions.mediumXL.verticalSpace,
                            ],
                          )
                        : Container(),
                  ),
                ],
              ),
              // Show loading animation if the profile data is being loaded.
              if (state.profileState == ProfileState.loading || state.profileState == ProfileState.userDataLoaded)
                const LoadingAnimation(),
            ],
          );
        },
      ),
    );
  }

  /// Builds the main body view of the profile page.
  Widget bodyView(SeekerProfileState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Display profile header.
        ProfileHeaderWidget(
          name: profileDisplayName(state.userData),
          role: '${state.userData?.role?.type}',
          imageUrl: state.userData?.profileUrl,
          userData: state.userData,
          editOnProfile: false,
        ),
        AppDimensions.large.verticalSpace,
        // Display titles and options.
        titlesWidget(state),
        AppDimensions.smallXL.verticalSpace,
        const Divider(color: AppColors.checkBoxDisableColor),
        AppDimensions.small.verticalSpace,
        // Display profile card options if they are available.
        if (_profileCardOptions.isNotEmpty)
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            separatorBuilder: (context, index) => AppDimensions.medium.verticalSpace,
            itemCount: _profileCardOptions.length,
            itemBuilder: (context, index) {
              final item = _profileCardOptions[index];
               return ProfileOptionWidget(item: item, index: index, userData: state.userData);
            },
          ),
        AppDimensions.medium.verticalSpace,
        // Display logout button.
        const LogoutButtonWidget(),
      ],
    ).symmetricPadding(
      horizontal: AppDimensions.mediumXL,
      vertical: AppDimensions.mediumXL,
    );
  }

  /// Builds the titles section of the profile page, including job and orders.
  Widget titlesWidget(SeekerProfileState state) {
    return Row(
      children: [
        Expanded(
          child: ProfileSkillTileWidget(
            title: ProfileKeys.myJob.stringToString,
            fullWidthTitle: true,
            icon: Assets.images.job,
            value: state.isCountsLoading
              ? '...'
              : state.activityCounts.appointments?.toString() ?? '-',
            backgroundColor: AppColors.lightGreen.withOpacity(0.25),
          ),
        ),
        const SizedBox(width: AppDimensions.smallXL),
        Expanded(
          child: GestureDetector(
            onTap: () async {
              await Navigator.pushNamed(context, Routes.myOrders);
              if (!mounted) return;
              context.read<SeekerProfileBloc>().add(
                const ProfileUserDataEvent(loadActivityCounts: true),
              );
            },
            child: ProfileSkillTileWidget(
              title: ProfileKeys.orders.stringToString,
              fullWidthTitle: true,
              icon: Assets.images.skilling,
                value: state.isCountsLoading
                  ? '...'
                  : state.activityCounts.orders?.toString() ?? '-',
              backgroundColor: AppColors.lightBlueProfileTiles,
            ),
          ),
        ),
      ],
    );
  }
}
