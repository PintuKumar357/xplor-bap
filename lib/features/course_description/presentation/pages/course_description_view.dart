import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../apply_course/presentation/blocs/apply_course_bloc.dart';
import '../blocs/course_description_bloc.dart';
import '../blocs/course_description_state.dart';
import '../../../../utils/app_utils/app_utils.dart';
import '../../../../utils/widgets/loading_animation.dart';
import '../../../../config/routes/path_routing.dart';
import '../../../../const/local_storage/shared_preferences_helper.dart';
import '../../../../core/dependency_injection.dart';
import '../../../../utils/widgets/app_background_widget.dart';
import '../../../../utils/widgets/build_button.dart';
import '../../../multi_lang/domain/mappers/seeker_home/seeker_home_keys.dart';
import '../widgets/description_details_widget.dart';
import '../../../../utils/extensions/string_to_string.dart';
import '../../../../utils/utils.dart';
import '../../../../gen/assets.gen.dart';
import '../../../../utils/app_dimensions.dart';
import '../widgets/description_header_widget.dart';

class CourseDescriptionView extends StatefulWidget {
  final String transactionId;

  const CourseDescriptionView({super.key, required this.transactionId});

  @override
  State<CourseDescriptionView> createState() => _CourseDescriptionViewState();
}

class _CourseDescriptionViewState extends State<CourseDescriptionView> {
  @override
  void initState() {
    super.initState();
    context.read<ApplyCourseBloc>().add(UpdateInitStateEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<ApplyCourseBloc, ApplyCourseState>(
          listener: (context, state) {
            if (state is CourseFailureState) {
              AppUtils.showSnackBar(context, state.errorMessage);
            }
            if (state is CourseUrlDataState) {
              Navigator.pushNamed(context, Routes.applyCourse);
            }

            if (state is PaymentUrlState) {
              Navigator.pushNamed(context, Routes.payment,
                  arguments: state.url);
            }
            if (state is NavigationSuccessState) {
              Navigator.pushNamedAndRemoveUntil(
                context,
                Routes.thanksForApplying,
                (routes) => false,
              );
            }
          },
          child: BlocListener<CourseDescriptionBloc, CourseDescriptionState>(
              listener: (context, state) {
            if (state is CourseDetailsFailureState) {
              AppUtils.showSnackBar(context, state.error);
            }
            if (state is CourseSelectedState && !state.course.enrolled) {
              context.read<ApplyCourseBloc>().add(CourseSelectEvent(
                  data: state.course, transactionId: widget.transactionId));
            }
          }, child: BlocBuilder<ApplyCourseBloc, ApplyCourseState>(
                  builder: (context, applyState) {
            return BlocBuilder<CourseDescriptionBloc, CourseDescriptionState>(
              builder: (context, state) {
                AppUtils.printLogs(
                    "assafsf ${applyState is SuccessOnSelectState && state is CourseSelectedState} ");

                if (state is CourseLoaderData) {
                  return const LoadingAnimation();
                }
                return state is CourseSelectedState
                    ? Stack(
                        children: [
                          AppBackgroundDecoration(
                              child: Stack(children: [
                            CustomScrollView(slivers: [
                              SliverAppBar(
                                automaticallyImplyLeading: false,
                                flexibleSpace: _headerWidget(state),
                                expandedHeight: 274.h,
                              ),
                              SliverToBoxAdapter(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      DescriptionHeaderWidget(
                                          course: state.course),
                                      DescriptionDetailsWidget(
                                          course: state.course),
                                    ]).symmetricPadding(
                                    horizontal: AppDimensions.medium),
                              ),
                            ]),
                            if (applyState is ApplyFormLoaderState)
                              const LoadingAnimation(),
                            Positioned(
                              top: 50,
                              left: 18,
                              child: GestureDetector(
                                  onTap: () => Navigator.pop(context),
                                  child: SvgPicture.asset(
                                      Assets.images.leftWhiteArrow)),
                            ),
                          ])),
                          if (!state.course.enrolled) _enrollButton(),
                        ],
                      )
                    : Container();
              },
            );
          }))),
    );
  }

  Widget _enrollButton() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        BlocBuilder<ApplyCourseBloc, ApplyCourseState>(
            builder: (context, state) {
          return ButtonWidget(
            isShadow: false,
            onPressed: () async {
              if (state is ApplyFormLoaderState) {
                return;
              }
              final bool isLoggedIn = await AppUtils.checkToken();
              if (!context.mounted) return;
              _goToNext(context, isLoggedIn);
            },
            title: state is ApplyFormLoaderState
                ? SeekerHomeKeys.plsWait.stringToString
                : SeekerHomeKeys.enrollNow.stringToString,
            isValid: context.read<ApplyCourseBloc>().isEnabledOnSelect,
          ).symmetricPadding(
              vertical: AppDimensions.large.sp,
              horizontal: AppDimensions.medium.sp);
        }),
      ],
    );
  }

  _goToNext(BuildContext context, bool isLoggedIn) {
    if (isLoggedIn) {
      context.read<ApplyCourseBloc>().add(CourseInitEvent(
          transactionId: context.read<ApplyCourseBloc>().course!.transactionId,
          domain: context.read<ApplyCourseBloc>().course!.domain));
    } else {
      sl<SharedPreferencesHelper>()
          .setString(PrefConstKeys.loginFrom, PrefConstKeys.seekerHomeKey);
      Navigator.pushNamed(context, Routes.login);
    }
  }

  Widget _headerWidget(CourseSelectedState state) {
    return Stack(children: [
      Stack(
        children: [
          SizedBox(
            height: 274.h,
            child: CachedNetworkImage(
                filterQuality: FilterQuality.high,
                imageUrl: state.course.descriptor.images.isNotEmpty
                    ? state.course.descriptor.images[0]
                    : '',
                placeholder: (context, url) => const Center(
                      child: LoadingAnimation(),
                    ),
                errorWidget: (context, url, error) => SvgPicture.asset(
                      Assets.images.productThumnail,
                      fit: BoxFit.fill,
                      width: double.infinity,
                    ).paddingAll(padding: AppDimensions.small)),
          ),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xff192835),
                  // Start color
                  Color.fromRGBO(73, 118, 155, 0),
                  // End color with opacity
                ],
              ),
            ),
          ),
        ],
      ),
    ]);
  }

/*Widget _buildTabItem(int index) {
    return Container(
      decoration: BoxDecoration(
          color: AppColors.dashboardTabBackgroundColor,
          borderRadius: BorderRadius.circular(AppDimensions.smallXL.r) // Set border radius for all corners
          ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              style: ButtonStyle(
                elevation: MaterialStateProperty.all<double>(0),
                backgroundColor: MaterialStateProperty.all<Color>(index == 0 ? AppColors.white : Colors.transparent),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(AppDimensions.small),
                    ), // To remove the default radius.
                  ),
                ),
              ),
              onPressed: () {
                setState(() {
                  _currentIndex = 0;
                });
              },
              child: SeekerHomeKeys.about.stringToString.titleBold(
                  size: AppDimensions.smallXXL.sp, color: index == 0 ? AppColors.black : AppColors.grey9898a5),
            ),
          ),
          Expanded(
            child: ElevatedButton(
              style: ButtonStyle(
                elevation: MaterialStateProperty.all<double>(0),
                backgroundColor: MaterialStateProperty.all<Color>(index == 1 ? AppColors.white : Colors.transparent),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(AppDimensions.small),
                    ), // To remove the default radius.
                  ),
                ),
              ),
              onPressed: () {
                setState(() {
                  _currentIndex = 1;
                });
              },
              child: SeekerHomeKeys.curriculum.stringToString.titleBold(
                  size: AppDimensions.smallXXL.sp, color: index == 1 ? AppColors.black : AppColors.grey9898a5),
            ),
          ),
        ],
      ).symmetricPadding(horizontal: AppDimensions.extraSmall.sp),
    );
  }*/
}
