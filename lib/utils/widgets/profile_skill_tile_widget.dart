import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import '../extensions/font_style/font_styles.dart';
import '../app_colors.dart';
import '../app_dimensions.dart';

class ProfileSkillTileWidget extends StatelessWidget {
  const ProfileSkillTileWidget({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.backgroundColor,
    this.fullWidthTitle = false,
  });

  final String title;
  final String value;
  final String icon;
  final Color backgroundColor;
  final bool fullWidthTitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: fullWidthTitle ? 104 : null,
      padding: fullWidthTitle
          ? const EdgeInsets.all(AppDimensions.smallXL)
          : EdgeInsets.all(AppDimensions.smallXL.sp),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppDimensions.medium),
      ),
      child: fullWidthTitle
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 20,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: title.titleBold(
                      size: 13,
                      color: AppColors.grey707484,
                      maxLine: 1,
                    ),
                  ),
                ),
                SizedBox(
                  height: 40,
                  child: Row(
                    children: [
                      SvgPicture.asset(icon, width: 36, height: 36),
                      const SizedBox(width: 10),
                      Expanded(
                        child: SizedBox(
                          height: 40,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: value.titleSemiBold(
                              size: AppDimensions.large,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(icon),
                10.w.horizontalSpace,
                Expanded(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    title.titleBold(size: 13.sp, color: AppColors.grey707484),
                    value.titleSemiBold(size: AppDimensions.large.sp),
                  ],
                ))
              ],
            ),
    );
  }
}
