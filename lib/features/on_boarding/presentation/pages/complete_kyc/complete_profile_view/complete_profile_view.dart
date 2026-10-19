import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import '../../../../../multi_lang/domain/mappers/on_boarding/on_boardings_keys.dart';
import '../../../../../../utils/extensions/string_to_string.dart';
import '../../../../../../utils/utils.dart';
import '../../../../../../utils/widgets/loading_animation.dart';
import '../../../../../../config/routes/path_routing.dart';
import '../../../../../../const/local_storage/shared_preferences_helper.dart';
import '../../../../../../core/api_constants.dart';
import '../../../../../../core/check_route.dart';
import '../../../../../../core/dependency_injection.dart';
import '../../../../../../gen/assets.gen.dart';
import '../../../../../../utils/app_colors.dart';
import '../../../../../../utils/app_dimensions.dart';
import '../../../../../../utils/app_utils/app_utils.dart';
import '../../../../../../utils/circluar_button.dart';
import '../../../../../../utils/common_top_header.dart';
import '../../../../../../utils/custom_confirmation_dialog.dart';
import '../../../../../../utils/custom_dialog_view.dart';
import '../../../../../../utils/extensions/font_style/font_styles.dart';
import '../../../../../../utils/widgets/app_background_widget.dart';
import '../../../blocs/kyc_bloc/kyc_bloc.dart';
import '../../../widgets/build_custom_checkbox.dart';
import '../../../widgets/build_single_selection_wallet.dart';
import '../../../widgets/kyc_loader_status.dart';

part 'complete_profile_view_part.dart';
part 'complete_profile_view_widgets.dart';

/// Widget for the sign-in view.
class CompleteProfileView extends StatefulWidget {
  const CompleteProfileView({super.key});

  @override
  State<CompleteProfileView> createState() => _CompleteProfileViewState();
}

/// State class for the sign-in view.
class _CompleteProfileViewState extends State<CompleteProfileView> {
  @override
  void initState() {
    context.read<KycBloc>().add(const GetProvidersEvent());
    super.initState();
  }

  /// Method to set the selected index
  void setSelectedIndex(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<KycBloc, KycState>(builder: (context, state) {
      return PopScope(
          canPop: false,
          onPopInvokedWithResult: (val, result) {
            if (state is AuthorizedUserState) {
              return;
            }
            AppUtils.showAlertDialog(context, true);
          },
          child: Scaffold(
            backgroundColor: AppColors.white,
            body: AppBackgroundDecoration(
              child: SafeArea(
                child: BlocListener<KycBloc, KycState>(
                  listener: (context, state) async {
                    if (state is KycErrorState) {
                      AppUtils.showSnackBar(context, state.error);
                    }
                    // show success dialog if KYC verified successfully
                    if (state is AuthorizedUserState) {
                      _showKYCConfirmationDialog(context);
                    }
                    // shows the WebView to open the callback from API
                    else if (state is ShowWebViewState) {
                      webViewController.setNavigationDelegate(
                        NavigationDelegate(
                          onProgress: (int progress) {},
                          onPageStarted: (String url) {
                            AppUtils.printLogs('onPageStarted $url');
                          },
                          onPageFinished: (String url) {
                            // Do the task here
                            AppUtils.printLogs('onPageFinished $url');
                          },
                          onWebResourceError: (WebResourceError error) {},
                          onNavigationRequest: (NavigationRequest request) {
                            AppUtils.printLogs(
                                'onNavigationRequest ${request.url}');

                            if (request.url.startsWith(signInWebHook)) {
                              Future.delayed(const Duration(milliseconds: 500),
                                  () {
                                loader = false;
                                setState(() {});
                              });
                            }
                            AppUtils.printLogs(
                                'eAuthDigilockerWebHook $eAuthDigilockerWebHook');
                            if (request.url
                                .startsWith(eAuthDigilockerWebHook)) {
                              context
                                  .read<KycBloc>()
                                  .add(const InitSseKycEvent());
                              return NavigationDecision.navigate;
                            }
                            if (request.url.startsWith(eAuthWebHookError)) {
                              context
                                  .read<KycBloc>()
                                  .add(const EAuthFailureEvent());
                              return NavigationDecision.navigate;
                            }
                            return NavigationDecision.navigate;
                          },
                        ),
                      );
                      clearWebViewCache();
                      AppUtils.printLogs(
                          "state.requestUrl.trim()... ${state.requestUrl!.trim()}");
                      webViewController
                          .loadRequest(Uri.parse(state.requestUrl!.trim()));
                    }

                    // show failure dialog if KYC verification failed
                    else if (state is KycFailedState) {
                      _showKYCFailDialog(context);
                    }
                  },
                  child: BlocBuilder<KycBloc, KycState>(
                    builder: (context, state) {
                      if (state is ShowWebViewState ||
                          state is WebLoadingState ||
                          state is KycWebLoadingState ||
                          state is AuthProviderLoadingState) {
                        return buildMainContentBasedOnState(state, context);
                      }
                      return completeProfileViewWidget(context, state,
                          agreeConditionWidget(), setSelectedIndex);
                    },
                  ),
                ),
              ),
            ),
          ));
    });
  }

  /// Widget for the agree condition
  Widget agreeConditionWidget() {
    return Row(
      children: <Widget>[
        CustomCheckbox(
          isChecked: isValid,
          onChanged: (isChecked) {
            setState(() {
              isValid = isChecked;
            });
          },
        ),
        AppDimensions.small.w.horizontalSpace,
        richTextWidget(context),
      ],
    );
  }

  @override
  void dispose() {
    webViewController.clearCache();
    webViewController.clearLocalStorage();
    super.dispose();
  }
}
