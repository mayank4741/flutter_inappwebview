part of 'main.dart';

void getMetaTags() {
  final shouldSkip = kIsWeb
      ? false
      : ![
          TargetPlatform.android,
          TargetPlatform.iOS,
          TargetPlatform.macOS,
        ].contains(defaultTargetPlatform);

  var url = !kIsWeb ? TEST_CROSS_PLATFORM_URL_1 : TEST_WEB_PLATFORM_URL_1;

  skippableTestWidgets('getMetaTags', (WidgetTester tester) async {
    final Completer<PlatformInAppWebViewController> controllerCompleter =
        Completer<PlatformInAppWebViewController>();
    final Completer<void> pageLoaded = Completer<void>();

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialUrlRequest: URLRequest(url: url),
          onWebViewCreated: (controller) {
            controllerCompleter.complete(controller);
          },
          onLoadStop: (controller, url) {
            pageLoaded.complete();
          },
        ),
      ),
    );

    final PlatformInAppWebViewController controller = await controllerCompleter.future;
    await pageLoaded.future;

    List<MetaTag> metaTags = await controller.getMetaTags();
    expect(metaTags, isNotEmpty);
  }, skip: shouldSkip);
}
