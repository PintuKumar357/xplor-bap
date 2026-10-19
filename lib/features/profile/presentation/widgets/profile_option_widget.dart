import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import '../../domain/entities/profile_card_options_entity.dart';
import '../../../../utils/extensions/font_style/font_styles.dart';
import '../../../../utils/extensions/padding.dart';
import '../../../../config/routes/path_routing.dart';
import '../../../../gen/assets.gen.dart';
import '../../../../utils/app_colors.dart';
import '../../../../utils/app_dimensions.dart';
import '../../../on_boarding/domain/entities/user_data_entity.dart';

/// A widget that displays a profile option as a card with specific styles and functionality.
/// The [ProfileOptionWidget] displays an icon, a title, and a subtitle for a profile option.
class ProfileOptionWidget extends StatelessWidget {
  /// Creates a [ProfileOptionWidget].
  const ProfileOptionWidget({
    super.key,
    required this.item,
    required this.index,
    this.userData,
  });

  /// The [ProfileCardOptionsEntity] object that contains details of the profile option.
  final ProfileCardOptionsEntity item;

  /// The [UserDataEntity] object that contains user data. It can be null.
  final UserDataEntity? userData;

  /// The index of the profile option in a list.
  final int index;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      /// [onTap] defines the action to be taken when the profile option is tapped.
      /// It navigates to the edit profile page if the index is 0.
      onTap: () {
        // if (index == 0) {
        //Navigator.pushNamed(context, item.route ?? Routes.editProfile, arguments: userData);
        if (item.route == Routes.viewAppointmentPage) {
          // For appointments, pass only the phone number
          Navigator.pushNamed(
            context,
            item.route ?? Routes.editProfile,
            arguments:
                userData?.phoneNumber, // Pass String instead of UserDataEntity
          );
        } else {
          // For other routes, pass the full userData object
          Navigator.pushNamed(
            context,
            item.route ?? Routes.editProfile,
            arguments: userData,
          );
        }
        // }
      },
      child: Container(
        decoration: BoxDecoration(
          // Set the background color of the container.
          color: AppColors.white,
          // Define the border radius of the container.
          borderRadius: BorderRadius.circular(AppDimensions.medium),
          // Define the shadow for the container.
          boxShadow: const [
            BoxShadow(
              color: AppColors.searchShadowColor, // Shadow color
              offset: Offset(0, 1), // Offset
              blurRadius: 1, // Blur radius
            ),
          ],
        ),
        child: Card(
          // Set the elevation of the card to 0.
          elevation: 0,
          // Define the surface tint color of the card.
          surfaceTintColor: AppColors.white,
          // Set the background color of the card.
          color: AppColors.white,
          child: Row(
            children: [
              // Display the icon for the profile option.
              SvgPicture.asset(item.icon!),
              // Add horizontal space between the icon and the text.
              AppDimensions.medium.w.horizontalSpace,
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Display the title of the profile option with specific font styles.
                      item.title!.titleBold(
                        size: AppDimensions.medium.sp,
                        color: AppColors.blackMedium,
                      ),
                      // Add vertical space between the title and subtitle.
                      AppDimensions.extraSmall.verticalSpace,
                      // Display the subtitle of the profile option with specific font styles.
                      item.subTitle!.titleRegular(
                        size: AppDimensions.smallXL.sp,
                        color: AppColors.blackMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ]),
              ),
              // Display the right arrow icon.
              SvgPicture.asset(Assets.images.rightArrowProfile),
            ],
          ).paddingAll(padding: AppDimensions.smallXL),
        ),
      ),
    );
  }
}
