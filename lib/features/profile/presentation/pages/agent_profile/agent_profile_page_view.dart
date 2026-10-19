import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../utils/app_colors.dart';
import '../../../../../utils/app_dimensions.dart';
import '../../../../../utils/extensions/string_to_string.dart';
import '../../../../../utils/utils.dart';
import '../../../../../config/routes/path_routing.dart';
import '../../../../../const/local_storage/shared_preferences_helper.dart';
import '../../../../../core/dependency_injection.dart';
import '../../../../../gen/assets.gen.dart';
import '../../../../../utils/app_utils/app_utils.dart';
import '../../../../../utils/mapping_const.dart';
import '../../../../../utils/widgets/loading_animation.dart';
import '../../../../multi_lang/domain/mappers/profile/profile_keys.dart';
import '../../../../multi_lang/presentation/blocs/bloc/translate_bloc.dart';
import '../../../domain/entities/profile_card_options_entity.dart';
import '../../bloc/agent_profile_bloc/agent_profile_bloc.dart';
import '../../widgets/agent_profile_top_header_widget.dart';
import '../../widgets/agent_titles_widget.dart';
import '../../widgets/logout_button_widget.dart';
import '../../widgets/profile_display_values.dart';
import '../../../../../utils/widgets/profile_header__widget.dart';
import '../../widgets/profile_option_widget.dart';

/// The main view for the Agent Profile page.
class AgentProfilePageView extends StatefulWidget {
  const AgentProfilePageView({super.key});

  @override
  State<AgentProfilePageView> createState() => _AgentProfilePageViewState();
}

/// The view state for the Agent Profile page.
class _AgentProfilePageViewState extends State<AgentProfilePageView> {
  /// List of profile card options.
  List<ProfileCardOptionsEntity> _profileCardOptions = [];

  /// Initializes the profile card options based on the selected language.
  @override
  void initState() {
    super.initState();
    if (sl<SharedPreferencesHelper>().getString(PrefConstKeys.selectedLanguageCode) != "en") {
      context.read<TranslationBloc>().add(TranslateDynamicTextEvent(
          langCode: sl<SharedPreferencesHelper>().getString(PrefConstKeys.selectedLanguageCode),
          moduleTypes: profileModule,
          isNavigation: true));
    } else {
      _profileCardOptions.clear();
      _profileCardOptions = [
        ProfileCardOptionsEntity(
          title: ProfileKeys.editProfile.stringToString,
          subTitle: ProfileKeys.editProfileDesc.stringToString,
          icon: Assets.images.editProfile,
        ),
        ProfileCardOptionsEntity(
          title: ProfileKeys.accountPrivacy.stringToString,
          subTitle: ProfileKeys.accountPrivacyDesc.stringToString,
          icon: Assets.images.accountPrivacy,
        ),
        ProfileCardOptionsEntity(
          title: ProfileKeys.settings.stringToString,
          subTitle: ProfileKeys.settingsDesc2.stringToString,
          icon: Assets.images.profileSetting,
        ),
      ];
    }
    context.read<AgentProfileBloc>().add(const ProfileUserDataEvent());
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
        listeners: [
          BlocListener<AgentProfileBloc, AgentProfileState>(
            listener: (context, state) {
              // Show error message if the profile state is failure.
              if (state.profileState == ProfileState.failure) {
                AppUtils.showSnackBar(context, state.message.toString());
              }
              // Navigate to the main page if the logout state is success.
              if (state is ProfileLogoutState) {
                AppUtils.clearSession();
                AppUtils.disposeAllBlocs(context);
                Navigator.pushNamedAndRemoveUntil(context, Routes.main, (routes) => false);
              }
              // Load user data if the profile state is userDataLoaded.
              if (state.profileState == ProfileState.userDataLoaded) {
                context.read<AgentProfileBloc>().add(const ProfileAndTranslationEvent());
              }
            },
          ),
          BlocListener<TranslationBloc, TranslateState>(
            listener: (context, state) {
              // Load translations after user data is loaded.
              if (state is TranslationLoaded && state.isNavigation) {
                _profileCardOptions.clear();
                _profileCardOptions = [
                  ProfileCardOptionsEntity(
                    title: ProfileKeys.editProfile.stringToString,
                    subTitle: ProfileKeys.editProfileDesc.stringToString,
                    icon: Assets.images.editProfile,
                  ),
                  ProfileCardOptionsEntity(
                    title: ProfileKeys.accountPrivacy.stringToString,
                    subTitle: ProfileKeys.accountPrivacyDesc.stringToString,
                    icon: Assets.images.accountPrivacy,
                  ),
                  ProfileCardOptionsEntity(
                    title: ProfileKeys.settings.stringToString,
                    subTitle: ProfileKeys.settingsDesc2.stringToString,
                    icon: Assets.images.profileSetting,
                  ),
                ];
                context.read<AgentProfileBloc>().add(const ProfileAndTranslationEvent(isTranslationDone: true));
              }
            },
          ),
        ],
        child: BlocBuilder<AgentProfileBloc, AgentProfileState>(builder: (context, state) {
          return Stack(
            children: [
              CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: (state.profileState == ProfileState.done && state.userData != null)
                        ? Column(
                            children: [
                              const AgentTopHeaderWidget(),
                              const Divider(color: AppColors.checkBoxDisableColor),
                              bodyView(state),
                              AppDimensions.mediumXL.verticalSpace,
                            ],
                          )
                        : Container(),
                  )
                ],
              ),
              // Show loading animation if the profile state is loading.
              if (state.profileState == ProfileState.loading || state.profileState == ProfileState.userDataLoaded)
                const LoadingAnimation(),
            ],
          );
        }));
  }

  /// Builds the main body view of the profile page.
  Widget bodyView(AgentProfileState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileHeaderWidget(
          name: profileDisplayName(state.userData),
          role: '${state.userData?.role?.type}',
          imageUrl: state.userData?.profileUrl,
          userData: state.userData,
          editOnProfile: true,
        ),
        AppDimensions.large.verticalSpace,
        const AgentTilesWidget(),
        AppDimensions.smallXL.verticalSpace,
        const Divider(color: AppColors.checkBoxDisableColor),
        AppDimensions.small.verticalSpace,
        if (_profileCardOptions.isNotEmpty)
          ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              separatorBuilder: (context, index) {
                return AppDimensions.medium.verticalSpace;
              },
              itemCount: 3,
              // Number of items in the list
              itemBuilder: (context, index) {
                final item = _profileCardOptions[index];
                return ProfileOptionWidget(
                  item: item,
                  index: index,
                  userData: state.userData,
                );
              }),
        AppDimensions.mediumXXL.verticalSpace,
        const LogoutButtonWidget(),
      ],
    ).symmetricPadding(horizontal: AppDimensions.mediumXL, vertical: AppDimensions.mediumXL);
  }

  /// Formats the address from a JSON string to a human-readable format
  String address(String? address) {
    if (address == null) {
      return "";
    }
    Map<String, dynamic> addressMap = json.decode(address);
    // Create a list of address components, filtering out null values
    List addressComponents = [
      addressMap['careOf'] ?? "",
      addressMap['houseNumber'] ?? "",
      addressMap['street'] ?? "",
      addressMap['locality'] ?? "",
      addressMap['district'] ?? "",
      addressMap['state'] ?? "",
      addressMap['pincode'] ?? "",
      addressMap['postOffice'] ?? "",
    ].where((component) => component.isNotEmpty).toList();

    // Join the non-null address components with commas
    final addressString = addressComponents.join(', ');
    return addressString;
  }
}
