import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';
import 'package:xplor/features/on_boarding/presentation/blocs/kyc_bloc/kyc_bloc.dart';
import 'package:xplor/features/on_boarding/presentation/pages/complete_kyc/complete_profile_view/complete_profile_view.dart'
    as profile;
import 'package:xplor/features/on_boarding/presentation/widgets/kyc_loader_status.dart';

class _TestController extends PlatformWebViewController {
  _TestController()
      : super.implementation(const PlatformWebViewControllerCreationParams());
}

class _TestWebViewWidget extends PlatformWebViewWidget {
  _TestWebViewWidget(super.params) : super.implementation();

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

class _OtherWebViewPlatform extends WebViewPlatform {
  @override
  PlatformWebViewWidget createPlatformWebViewWidget(
          PlatformWebViewWidgetCreationParams params) =>
      _TestWebViewWidget(params);
}

void main() {
  late WebViewController controller;
  final originalPlatform = WebViewPlatform.instance ?? _OtherWebViewPlatform();

  setUp(() {
    WebViewPlatform.instance = AndroidWebViewPlatform();
    controller = WebViewController.fromPlatform(_TestController());
    profile.webViewController = controller;
  });

  tearDown(() {
    WebViewPlatform.instance = originalPlatform;
  });

  Future<Stack> contentFor(WidgetTester tester, KycState state) async {
    late Stack content;
    await tester.pumpWidget(ScreenUtilInit(
      designSize: const Size(393, 852),
      builder: (context, child) {
        content = profile.buildMainContentBasedOnState(state, context) as Stack;
        return const SizedBox.shrink();
      },
    ));
    return content;
  }

  WebViewWidget webViewIn(Stack content) {
    final column = content.children.whereType<Column>().single;
    return (column.children.single as Expanded).child as WebViewWidget;
  }

  testWidgets('KYC uses hybrid composition on Android', (tester) async {
    final content = await contentFor(tester, const ShowWebViewState());
    final params = webViewIn(content).platform.params;

    expect(params, isA<AndroidWebViewWidgetCreationParams>());
    expect(
        (params as AndroidWebViewWidgetCreationParams)
            .displayWithHybridComposition,
        isTrue);
    expect(params.controller, same(controller.platform));
  });

  testWidgets('KYC keeps its WebView while waiting for callback verification',
      (tester) async {
    final before =
        webViewIn(await contentFor(tester, const ShowWebViewState()));
    final loadingContent = await contentFor(tester, KycWebLoadingState());
    final during = webViewIn(loadingContent);

    expect(during.platform.params.controller,
        same(before.platform.params.controller));
    expect(
        (during.platform.params as AndroidWebViewWidgetCreationParams)
            .displayWithHybridComposition,
        isTrue);
    expect(loadingContent.children.whereType<KycLoaderWidget>(), hasLength(1));
  });

  testWidgets('KYC retains default creation parameters on other platforms',
      (tester) async {
    WebViewPlatform.instance = _OtherWebViewPlatform();
    final content = await contentFor(tester, const ShowWebViewState());
    final params = webViewIn(content).platform.params;

    expect(params, isNot(isA<AndroidWebViewWidgetCreationParams>()));
    expect(params.controller, same(controller.platform));
  });
}
