part of 'complete_profile_view.dart';

bool isValid = false;
bool isChecked = false;
int selectedIndex = -1;
bool loader = false;

WebViewController webViewController = WebViewController()
  ..setJavaScriptMode(JavaScriptMode.unrestricted)
  ..setBackgroundColor(AppColors.white)
  ..setUserAgent("random");

/// Method to show the KYC confirmation dialog
void _showKYCConfirmationDialog(BuildContext context) {
  sl<SharedPreferencesHelper>().setBoolean(PrefConstKeys.isHomeOpen, true);
  sl<SharedPreferencesHelper>().setBoolean('${PrefConstKeys.kyc}Done', true);
  showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return CustomConfirmationDialog(
          title: OnBoardingKeys.kycSuccessful.stringToString.titleExtraBold(
            color: AppColors.countryCodeColor,
            size: 20.sp,
          ),
          message: OnBoardingKeys.youHaveBeenSuccessFullyVerified.stringToString
              .titleRegular(size: 14.sp, color: AppColors.grey64697a, align: TextAlign.center),
          onConfirmPressed: () {
            // Implement the action when OK button is pressed
            var role = sl<SharedPreferencesHelper>().getString(PrefConstKeys.selectedRole);
            var route = role == PrefConstKeys.seekerKey ? Routes.seekerHome : Routes.home;

            if (sl<SharedPreferencesHelper>().getString(PrefConstKeys.loginFrom) == PrefConstKeys.seekerHomeKey) {
              //Navigator.pop(context);
              Navigator.pop(context);

              Navigator.of(context).pop();
            } else {
              Navigator.pushNamedAndRemoveUntil(
                context,
                route,
                (route) => false, // Do not allow back navigation
              );
            } // Close the dialog
          },
          assetPath: Assets.images.icKycSuccess,
        );
      });
}

/// Method to show the KYC confirmation dialog
void _showKYCFailDialog(BuildContext context) {
  showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return CustomConfirmationDialog(
          title: OnBoardingKeys.kycUnsuccessful.stringToString.titleExtraBold(
            color: AppColors.countryCodeColor,
            size: 20.sp,
          ),
          buttonTitle: OnBoardingKeys.tryAgain.stringToString,
          message: OnBoardingKeys.kycVerificationFailedMessage.stringToString
              .titleRegular(size: 14.sp, color: AppColors.grey64697a, align: TextAlign.center),
          onConfirmPressed: () {
            // Implement the action when OK button is pressed
            Navigator.of(context).pop(); // Close the dialog
          },
          assetPath: Assets.images.icKycFail,
        );
      });
}

/// Method to show the consent dialog
void _showConsentDialog(BuildContext context) {
  showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return CustomDialogView(
          title: OnBoardingKeys.consentToAuthorizeTitle.stringToString,
          message: OnBoardingKeys.consentToAuthorizeMessage.stringToString,
          onConfirmPressed: () {
            // Implement the action when OK button is pressed
            Navigator.of(context).pop(); // Close the dialog
          },
        );
      });
}

Widget buildMainContentBasedOnState(KycState state, BuildContext context) {
  return Stack(children: [
    if (state is ShowWebViewState || state is KycWebLoadingState)
      Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: WebViewWidget.fromPlatformCreationParams(
                params: WebViewPlatform.instance is AndroidWebViewPlatform
                    ? AndroidWebViewWidgetCreationParams(
                        controller: webViewController.platform,
                        displayWithHybridComposition: true,
                      )
                    : PlatformWebViewWidgetCreationParams(
                        controller: webViewController.platform,
                      ),
              ),
            ),
          ]),
    if (state is! KycWebLoadingState && state is! AuthProviderLoadingState)
      Positioned(
          right: AppDimensions.medium,
          top: AppDimensions.medium,
          child: GestureDetector(
            onTap: () {
              context.read<KycBloc>().add(const CloseEAuthWebView());
            },
            child: const Icon(Icons.close, color: AppColors.black),
          )),
    // if (state is WebLoadingState || loader || state is AuthProviderLoadingState) const LoadingAnimation(),
    if (state is KycWebLoadingState) const KycLoaderWidget()
  ]);
}

/// Widget for building the bottom view content
Widget _bottomViewContent(BuildContext context, KycState state, Widget agreeConditionWidget) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      agreeConditionWidget,
      AppDimensions.smallXL.verticalSpace,
      CircularButton(
        isValid: isValid && selectedIndex != -1,
        title: OnBoardingKeys.verify.stringToString,
        onPressed: () {
          loader = true;
          context.read<KycBloc>().add(
              OpenWebViewEvent(redirectUrl: sl<SharedPreferencesHelper>().getString(PrefConstKeys.kycRedirectUrl)));
        },
      ),
      TextButton(
        onPressed: () {
          Navigator.pushNamedAndRemoveUntil(
            context,
            checkRouteBasedOnUserJourney(),
            (route) => false,
          );
        },
        child: Text(OnBoardingKeys.skip.stringToString),
      ),
      AppDimensions.large.verticalSpace
    ],
  ).symmetricPadding(
    horizontal: AppDimensions.medium,
  );
}

Widget richTextWidget(BuildContext context) {
  return Flexible(
    child: GestureDetector(
      onTap: () {
        _showConsentDialog(context); // Call method to show dialog
      },
      child: RichText(
        text: TextSpan(
          children: [
            '${OnBoardingKeys.iHereConfirmMy.stringToString} '
                .textSpanRegular(color: AppColors.alertDialogMessageColor),
            OnBoardingKeys.consentToAuthorize.stringToString.textSpanSemiBold(decoration: TextDecoration.underline),
          ],
        ),
      ),
    ),
  );
}
