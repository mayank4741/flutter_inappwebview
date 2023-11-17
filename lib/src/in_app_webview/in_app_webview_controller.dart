import 'dart:convert';
import 'dart:core';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

import '../web_message/main.dart';
import 'android/in_app_webview_controller.dart';
import 'apple/in_app_webview_controller.dart';

import '../in_app_browser/in_app_browser.dart';

import 'headless_in_app_webview.dart';
import 'in_app_webview.dart';
import '../print_job/main.dart';
import '../find_interaction/main.dart';

///Controls a WebView, such as an [InAppWebView] widget instance, a [HeadlessInAppWebView] instance or [InAppBrowser] WebView instance.
///
///If you are using the [InAppWebView] widget, an [InAppWebViewController] instance can be obtained by setting the [InAppWebView.onWebViewCreated]
///callback. Instead, if you are using an [InAppBrowser] instance, you can get it through the [InAppBrowser.webViewController] attribute.
class InAppWebViewController {
  ///Use [InAppWebViewController] instead.
  @Deprecated("Use InAppWebViewController instead")
  late AndroidInAppWebViewController android;

  ///Use [InAppWebViewController] instead.
  @Deprecated("Use InAppWebViewController instead")
  late IOSInAppWebViewController ios;

  /// Constructs a [InAppWebViewController].
  ///
  /// See [InAppWebViewController.fromPlatformCreationParams] for setting parameters for
  /// a specific platform.
  InAppWebViewController.fromPlatformCreationParams({
    required PlatformInAppWebViewControllerCreationParams params,
  }) : this.fromPlatform(platform: PlatformInAppWebViewController(params));

  /// Constructs a [InAppWebViewController] from a specific platform implementation.
  InAppWebViewController.fromPlatform({required this.platform}) {
    android = AndroidInAppWebViewController(controller: this.platform);
    ios = IOSInAppWebViewController(controller: this.platform);
  }

  /// Implementation of [PlatformInAppWebViewController] for the current platform.
  final PlatformInAppWebViewController platform;

  ///Provides access to the JavaScript [Web Storage API](https://developer.mozilla.org/en-US/docs/Web/API/Web_Storage_API): `window.sessionStorage` and `window.localStorage`.
  PlatformWebStorage get webStorage => platform.webStorage;

  ///Gets the URL for the current page.
  ///This is not always the same as the URL passed to [WebView.onLoadStart] because although the load for that URL has begun, the current page may not have changed.
  ///
  ///**NOTE for Web**: If `window.location.href` isn't accessible inside the iframe,
  ///it will return the current value of the `iframe.src` attribute.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.getUrl](https://developer.android.com/reference/android/webkit/WebView#getUrl()))
  ///- iOS ([Official API - WKWebView.url](https://developer.apple.com/documentation/webkit/wkwebview/1415005-url))
  ///- MacOS ([Official API - WKWebView.url](https://developer.apple.com/documentation/webkit/wkwebview/1415005-url))
  ///- Web
  Future<WebUri?> getUrl() => platform.getUrl();

  ///Gets the title for the current page.
  ///
  ///**NOTE for Web**: this method will have effect only if the iframe has the same origin.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.getTitle](https://developer.android.com/reference/android/webkit/WebView#getTitle()))
  ///- iOS ([Official API - WKWebView.title](https://developer.apple.com/documentation/webkit/wkwebview/1415015-title))
  ///- MacOS ([Official API - WKWebView.title](https://developer.apple.com/documentation/webkit/wkwebview/1415015-title))
  ///- Web
  Future<String?> getTitle() => platform.getTitle();

  ///Gets the progress for the current page. The progress value is between 0 and 100.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.getProgress](https://developer.android.com/reference/android/webkit/WebView#getProgress()))
  ///- iOS ([Official API - WKWebView.estimatedProgress](https://developer.apple.com/documentation/webkit/wkwebview/1415007-estimatedprogress))
  ///- MacOS ([Official API - WKWebView.estimatedProgress](https://developer.apple.com/documentation/webkit/wkwebview/1415007-estimatedprogress))
  Future<int?> getProgress() => platform.getProgress();

  ///Gets the content html of the page. It first tries to get the content through javascript.
  ///If this doesn't work, it tries to get the content reading the file:
  ///- checking if it is an asset (`file:///`) or
  ///- downloading it using an `HttpClient` through the WebView's current url.
  ///
  ///Returns `null` if it was unable to get it.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  ///- Web
  Future<String?> getHtml() => platform.getHtml();

  ///Gets the list of all favicons for the current page.
  ///
  ///**NOTE for Web**: this method will have effect only if the iframe has the same origin.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  ///- Web
  Future<List<Favicon>> getFavicons() => platform.getFavicons();

  ///Loads the given [urlRequest].
  ///
  ///- [allowingReadAccessTo], used in combination with [urlRequest] (using the `file://` scheme),
  ///it represents the URL from which to read the web content.
  ///This URL must be a file-based URL (using the `file://` scheme).
  ///Specify the same value as the URL parameter to prevent WebView from reading any other content.
  ///Specify a directory to give WebView permission to read additional files in the specified directory.
  ///**NOTE**: available only on iOS and MacOS.
  ///
  ///**NOTE for Android**: when loading an URL Request using "POST" method, headers are ignored.
  ///
  ///**NOTE for Web**: if method is "GET" and headers are empty, it will change the `src` of the iframe.
  ///For all other cases it will try to create an XMLHttpRequest and load the result inside the iframe.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.loadUrl](https://developer.android.com/reference/android/webkit/WebView#loadUrl(java.lang.String))). If method is "POST", [Official API - WebView.postUrl](https://developer.android.com/reference/android/webkit/WebView#postUrl(java.lang.String,%20byte[]))
  ///- iOS ([Official API - WKWebView.load](https://developer.apple.com/documentation/webkit/wkwebview/1414954-load). If [allowingReadAccessTo] is used, [Official API - WKWebView.loadFileURL](https://developer.apple.com/documentation/webkit/wkwebview/1414973-loadfileurl))
  ///- MacOS ([Official API - WKWebView.load](https://developer.apple.com/documentation/webkit/wkwebview/1414954-load). If [allowingReadAccessTo] is used, [Official API - WKWebView.loadFileURL](https://developer.apple.com/documentation/webkit/wkwebview/1414973-loadfileurl))
  ///- Web
  Future<void> loadUrl(
          {required URLRequest urlRequest,
          @Deprecated('Use allowingReadAccessTo instead')
          Uri? iosAllowingReadAccessTo,
          WebUri? allowingReadAccessTo}) =>
      platform.loadUrl(
          urlRequest: urlRequest,
          iosAllowingReadAccessTo: iosAllowingReadAccessTo,
          allowingReadAccessTo: allowingReadAccessTo);

  ///Loads the given [url] with [postData] (x-www-form-urlencoded) using `POST` method into this WebView.
  ///
  ///Example:
  ///```dart
  ///var postData = Uint8List.fromList(utf8.encode("firstname=Foo&surname=Bar"));
  ///controller.postUrl(url: WebUri("https://www.example.com/"), postData: postData);
  ///```
  ///
  ///**NOTE for Web**: it will try to create an XMLHttpRequest and load the result inside the iframe.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.postUrl](https://developer.android.com/reference/android/webkit/WebView#postUrl(java.lang.String,%20byte[])))
  ///- iOS
  ///- MacOS
  ///- Web
  Future<void> postUrl({required WebUri url, required Uint8List postData}) =>
      platform.postUrl(url: url, postData: postData);

  ///Loads the given [data] into this WebView, using [baseUrl] as the base URL for the content.
  ///
  ///- [mimeType] argument specifies the format of the data. The default value is `"text/html"`.
  ///- [encoding] argument specifies the encoding of the data. The default value is `"utf8"`.
  ///**NOTE**: not used on Web.
  ///- [historyUrl] is an Android-specific argument that represents the URL to use as the history entry. The default value is `about:blank`. If non-null, this must be a valid URL.
  ///**NOTE**: not used on Web.
  ///- [allowingReadAccessTo], used in combination with [baseUrl] (using the `file://` scheme),
  ///it represents the URL from which to read the web content.
  ///This [baseUrl] must be a file-based URL (using the `file://` scheme).
  ///Specify the same value as the [baseUrl] parameter to prevent WebView from reading any other content.
  ///Specify a directory to give WebView permission to read additional files in the specified directory.
  ///**NOTE**: available only on iOS and MacOS.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.loadDataWithBaseURL](https://developer.android.com/reference/android/webkit/WebView#loadDataWithBaseURL(java.lang.String,%20java.lang.String,%20java.lang.String,%20java.lang.String,%20java.lang.String)))
  ///- iOS ([Official API - WKWebView.loadHTMLString](https://developer.apple.com/documentation/webkit/wkwebview/1415004-loadhtmlstring) or [Official API - WKWebView.load](https://developer.apple.com/documentation/webkit/wkwebview/1415011-load))
  ///- MacOS ([Official API - WKWebView.loadHTMLString](https://developer.apple.com/documentation/webkit/wkwebview/1415004-loadhtmlstring) or [Official API - WKWebView.load](https://developer.apple.com/documentation/webkit/wkwebview/1415011-load))
  ///- Web
  Future<void> loadData(
          {required String data,
          String mimeType = "text/html",
          String encoding = "utf8",
          WebUri? baseUrl,
          @Deprecated('Use historyUrl instead') Uri? androidHistoryUrl,
          WebUri? historyUrl,
          @Deprecated('Use allowingReadAccessTo instead')
          Uri? iosAllowingReadAccessTo,
          WebUri? allowingReadAccessTo}) =>
      platform.loadData(
          data: data,
          mimeType: mimeType,
          encoding: encoding,
          baseUrl: baseUrl,
          androidHistoryUrl: androidHistoryUrl,
          historyUrl: historyUrl,
          iosAllowingReadAccessTo: iosAllowingReadAccessTo,
          allowingReadAccessTo: allowingReadAccessTo);

  ///Loads the given [assetFilePath].
  ///
  ///To be able to load your local files (assets, js, css, etc.), you need to add them in the `assets` section of the `pubspec.yaml` file, otherwise they cannot be found!
  ///
  ///Example of a `pubspec.yaml` file:
  ///```yaml
  ///...
  ///
  ///# The following section is specific to Flutter.
  ///flutter:
  ///
  ///  # The following line ensures that the Material Icons font is
  ///  # included with your application, so that you can use the icons in
  ///  # the material Icons class.
  ///  uses-material-design: true
  ///
  ///  assets:
  ///    - assets/index.html
  ///    - assets/css/
  ///    - assets/images/
  ///
  ///...
  ///```
  ///Example:
  ///```dart
  ///...
  ///controller.loadFile(assetFilePath: "assets/index.html");
  ///...
  ///```
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.loadUrl](https://developer.android.com/reference/android/webkit/WebView#loadUrl(java.lang.String)))
  ///- iOS ([Official API - WKWebView.load](https://developer.apple.com/documentation/webkit/wkwebview/1414954-load))
  ///- MacOS ([Official API - WKWebView.load](https://developer.apple.com/documentation/webkit/wkwebview/1414954-load))
  ///- Web
  Future<void> loadFile({required String assetFilePath}) =>
      platform.loadFile(assetFilePath: assetFilePath);

  ///Reloads the WebView.
  ///
  ///**NOTE for Web**: if `window.location.reload()` is not accessible inside the iframe, it will reload using the iframe `src` attribute.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.reload](https://developer.android.com/reference/android/webkit/WebView#reload()))
  ///- iOS ([Official API - WKWebView.reload](https://developer.apple.com/documentation/webkit/wkwebview/1414969-reload))
  ///- MacOS ([Official API - WKWebView.reload](https://developer.apple.com/documentation/webkit/wkwebview/1414969-reload))
  ///- Web ([Official API - Location.reload](https://developer.mozilla.org/en-US/docs/Web/API/Location/reload))
  Future<void> reload() => platform.reload();

  ///Goes back in the history of the WebView.
  ///
  ///**NOTE for Web**: this method will have effect only if the iframe has the same origin.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.goBack](https://developer.android.com/reference/android/webkit/WebView#goBack()))
  ///- iOS ([Official API - WKWebView.goBack](https://developer.apple.com/documentation/webkit/wkwebview/1414952-goback))
  ///- MacOS ([Official API - WKWebView.goBack](https://developer.apple.com/documentation/webkit/wkwebview/1414952-goback))
  ///- Web ([Official API - History.back](https://developer.mozilla.org/en-US/docs/Web/API/History/back))
  Future<void> goBack() => platform.goBack();

  ///Returns a boolean value indicating whether the WebView can move backward.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.canGoBack](https://developer.android.com/reference/android/webkit/WebView#canGoBack()))
  ///- iOS ([Official API - WKWebView.canGoBack](https://developer.apple.com/documentation/webkit/wkwebview/1414966-cangoback))
  ///- MacOS ([Official API - WKWebView.canGoBack](https://developer.apple.com/documentation/webkit/wkwebview/1414966-cangoback))
  Future<bool> canGoBack() => platform.canGoBack();

  ///Goes forward in the history of the WebView.
  ///
  ///**NOTE for Web**: this method will have effect only if the iframe has the same origin.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.goForward](https://developer.android.com/reference/android/webkit/WebView#goForward()))
  ///- iOS ([Official API - WKWebView.goForward](https://developer.apple.com/documentation/webkit/wkwebview/1414993-goforward))
  ///- MacOS ([Official API - WKWebView.goForward](https://developer.apple.com/documentation/webkit/wkwebview/1414993-goforward))
  ///- Web ([Official API - History.forward](https://developer.mozilla.org/en-US/docs/Web/API/History/forward))
  Future<void> goForward() => platform.goForward();

  ///Returns a boolean value indicating whether the WebView can move forward.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.canGoForward](https://developer.android.com/reference/android/webkit/WebView#canGoForward()))
  ///- iOS ([Official API - WKWebView.canGoForward](https://developer.apple.com/documentation/webkit/wkwebview/1414962-cangoforward))
  ///- MacOS ([Official API - WKWebView.canGoForward](https://developer.apple.com/documentation/webkit/wkwebview/1414962-cangoforward))
  Future<bool> canGoForward() => platform.canGoForward();

  ///Goes to the history item that is the number of steps away from the current item. Steps is negative if backward and positive if forward.
  ///
  ///**NOTE for Web**: this method will have effect only if the iframe has the same origin.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.goBackOrForward](https://developer.android.com/reference/android/webkit/WebView#goBackOrForward(int)))
  ///- iOS ([Official API - WKWebView.go](https://developer.apple.com/documentation/webkit/wkwebview/1414991-go))
  ///- MacOS ([Official API - WKWebView.go](https://developer.apple.com/documentation/webkit/wkwebview/1414991-go))
  ///- Web ([Official API - History.go](https://developer.mozilla.org/en-US/docs/Web/API/History/go))
  Future<void> goBackOrForward({required int steps}) =>
      platform.goBackOrForward(steps: steps);

  ///Returns a boolean value indicating whether the WebView can go back or forward the given number of steps. Steps is negative if backward and positive if forward.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.canGoBackOrForward](https://developer.android.com/reference/android/webkit/WebView#canGoBackOrForward(int)))
  ///- iOS
  ///- MacOS
  Future<bool> canGoBackOrForward({required int steps}) =>
      platform.canGoBackOrForward(steps: steps);

  ///Navigates to a [WebHistoryItem] from the back-forward [WebHistory.list] and sets it as the current item.
  ///
  ///**NOTE for Web**: this method will have effect only if the iframe has the same origin.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  ///- Web
  Future<void> goTo({required WebHistoryItem historyItem}) =>
      platform.goTo(historyItem: historyItem);

  ///Check if the WebView instance is in a loading state.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  ///- Web
  Future<bool> isLoading() => platform.isLoading();

  ///Stops the WebView from loading.
  ///
  ///**NOTE for Web**: this method will have effect only if the iframe has the same origin.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.stopLoading](https://developer.android.com/reference/android/webkit/WebView#stopLoading()))
  ///- iOS ([Official API - WKWebView.stopLoading](https://developer.apple.com/documentation/webkit/wkwebview/1414981-stoploading))
  ///- MacOS ([Official API - WKWebView.stopLoading](https://developer.apple.com/documentation/webkit/wkwebview/1414981-stoploading))
  ///- Web ([Official API - Window.stop](https://developer.mozilla.org/en-US/docs/Web/API/Window/stop))
  Future<void> stopLoading() => platform.stopLoading();

  ///Evaluates JavaScript [source] code into the WebView and returns the result of the evaluation.
  ///
  ///[contentWorld], on iOS, it represents the namespace in which to evaluate the JavaScript [source] code.
  ///Instead, on Android, it will run the [source] code into an iframe, using `eval(source);` to get and return the result.
  ///This parameter doesn’t apply to changes you make to the underlying web content, such as the document’s DOM structure.
  ///Those changes remain visible to all scripts, regardless of which content world you specify.
  ///For more information about content worlds, see [ContentWorld].
  ///Available on iOS 14.0+ and MacOS 11.0+.
  ///**NOTE**: not used on Web.
  ///
  ///**NOTE**: This method shouldn't be called in the [WebView.onWebViewCreated] or [WebView.onLoadStart] events,
  ///because, in these events, the [WebView] is not ready to handle it yet.
  ///Instead, you should call this method, for example, inside the [WebView.onLoadStop] event or in any other events
  ///where you know the page is ready "enough".
  ///
  ///**NOTE for Web**: this method will have effect only if the iframe has the same origin.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.evaluateJavascript](https://developer.android.com/reference/android/webkit/WebView#evaluateJavascript(java.lang.String,%20android.webkit.ValueCallback%3Cjava.lang.String%3E)))
  ///- iOS ([Official API - WKWebView.evaluateJavascript](https://developer.apple.com/documentation/webkit/wkwebview/3656442-evaluatejavascript))
  ///- MacOS ([Official API - WKWebView.evaluateJavascript](https://developer.apple.com/documentation/webkit/wkwebview/3656442-evaluatejavascript))
  ///- Web ([Official API - Window.eval](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/eval?retiredLocale=it))
  Future<dynamic> evaluateJavascript(
          {required String source, ContentWorld? contentWorld}) =>
      platform.evaluateJavascript(source: source, contentWorld: contentWorld);

  ///Injects an external JavaScript file into the WebView from a defined url.
  ///
  ///[scriptHtmlTagAttributes] represents the possible the `<script>` HTML attributes to be set.
  ///
  ///**NOTE**: This method shouldn't be called in the [WebView.onWebViewCreated] or [WebView.onLoadStart] events,
  ///because, in these events, the [WebView] is not ready to handle it yet.
  ///Instead, you should call this method, for example, inside the [WebView.onLoadStop] event or in any other events
  ///where you know the page is ready "enough".
  ///
  ///**NOTE for Web**: this method will have effect only if the iframe has the same origin.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  ///- Web
  Future<void> injectJavascriptFileFromUrl(
          {required WebUri urlFile,
          ScriptHtmlTagAttributes? scriptHtmlTagAttributes}) =>
      platform.injectJavascriptFileFromUrl(
          urlFile: urlFile, scriptHtmlTagAttributes: scriptHtmlTagAttributes);

  ///Evaluates the content of a JavaScript file into the WebView from the flutter assets directory.
  ///
  ///**NOTE**: This method shouldn't be called in the [WebView.onWebViewCreated] or [WebView.onLoadStart] events,
  ///because, in these events, the [WebView] is not ready to handle it yet.
  ///Instead, you should call this method, for example, inside the [WebView.onLoadStop] event or in any other events
  ///where you know the page is ready "enough".
  ///
  ///**NOTE for Web**: this method will have effect only if the iframe has the same origin.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  ///- Web
  Future<dynamic> injectJavascriptFileFromAsset(
          {required String assetFilePath}) =>
      platform.injectJavascriptFileFromAsset(assetFilePath: assetFilePath);

  ///Injects CSS into the WebView.
  ///
  ///**NOTE**: This method shouldn't be called in the [WebView.onWebViewCreated] or [WebView.onLoadStart] events,
  ///because, in these events, the [WebView] is not ready to handle it yet.
  ///Instead, you should call this method, for example, inside the [WebView.onLoadStop] event or in any other events
  ///where you know the page is ready "enough".
  ///
  ///**NOTE for Web**: this method will have effect only if the iframe has the same origin.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  ///- Web
  Future<void> injectCSSCode({required String source}) =>
      platform.injectCSSCode(source: source);

  ///Injects an external CSS file into the WebView from a defined url.
  ///
  ///[cssLinkHtmlTagAttributes] represents the possible CSS stylesheet `<link>` HTML attributes to be set.
  ///
  ///**NOTE**: This method shouldn't be called in the [WebView.onWebViewCreated] or [WebView.onLoadStart] events,
  ///because, in these events, the [WebView] is not ready to handle it yet.
  ///Instead, you should call this method, for example, inside the [WebView.onLoadStop] event or in any other events
  ///where you know the page is ready "enough".
  ///
  ///**NOTE for Web**: this method will have effect only if the iframe has the same origin.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  ///- Web
  Future<void> injectCSSFileFromUrl(
          {required WebUri urlFile,
          CSSLinkHtmlTagAttributes? cssLinkHtmlTagAttributes}) =>
      platform.injectCSSFileFromUrl(
          urlFile: urlFile, cssLinkHtmlTagAttributes: cssLinkHtmlTagAttributes);

  ///Injects a CSS file into the WebView from the flutter assets directory.
  ///
  ///**NOTE**: This method shouldn't be called in the [WebView.onWebViewCreated] or [WebView.onLoadStart] events,
  ///because, in these events, the [WebView] is not ready to handle it yet.
  ///Instead, you should call this method, for example, inside the [WebView.onLoadStop] event or in any other events
  ///where you know the page is ready "enough".
  ///
  ///**NOTE for Web**: this method will have effect only if the iframe has the same origin.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  ///- Web
  Future<void> injectCSSFileFromAsset({required String assetFilePath}) =>
      platform.injectCSSFileFromAsset(assetFilePath: assetFilePath);

  ///Adds a JavaScript message handler [callback] ([JavaScriptHandlerCallback]) that listen to post messages sent from JavaScript by the handler with name [handlerName].
  ///
  ///The Android implementation uses [addJavascriptInterface](https://developer.android.com/reference/android/webkit/WebView#addJavascriptInterface(java.lang.Object,%20java.lang.String)).
  ///The iOS implementation uses [addScriptMessageHandler](https://developer.apple.com/documentation/webkit/wkusercontentcontroller/1537172-addscriptmessagehandler?language=objc)
  ///
  ///The JavaScript function that can be used to call the handler is `window.flutter_inappwebview.callHandler(handlerName <String>, ...args)`, where `args` are [rest parameters](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Functions/rest_parameters).
  ///The `args` will be stringified automatically using `JSON.stringify(args)` method and then they will be decoded on the Dart side.
  ///
  ///In order to call `window.flutter_inappwebview.callHandler(handlerName <String>, ...args)` properly, you need to wait and listen the JavaScript event `flutterInAppWebViewPlatformReady`.
  ///This event will be dispatched as soon as the platform (Android or iOS) is ready to handle the `callHandler` method.
  ///```javascript
  ///   window.addEventListener("flutterInAppWebViewPlatformReady", function(event) {
  ///     console.log("ready");
  ///   });
  ///```
  ///
  ///`window.flutter_inappwebview.callHandler` returns a JavaScript [Promise](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise)
  ///that can be used to get the json result returned by [JavaScriptHandlerCallback].
  ///In this case, simply return data that you want to send and it will be automatically json encoded using [jsonEncode] from the `dart:convert` library.
  ///
  ///So, on the JavaScript side, to get data coming from the Dart side, you will use:
  ///```html
  ///<script>
  ///   window.addEventListener("flutterInAppWebViewPlatformReady", function(event) {
  ///     window.flutter_inappwebview.callHandler('handlerFoo').then(function(result) {
  ///       console.log(result);
  ///     });
  ///
  ///     window.flutter_inappwebview.callHandler('handlerFooWithArgs', 1, true, ['bar', 5], {foo: 'baz'}).then(function(result) {
  ///       console.log(result);
  ///     });
  ///   });
  ///</script>
  ///```
  ///
  ///Instead, on the `onLoadStop` WebView event, you can use `callHandler` directly:
  ///```dart
  ///  // Inject JavaScript that will receive data back from Flutter
  ///  inAppWebViewController.evaluateJavascript(source: """
  ///    window.flutter_inappwebview.callHandler('test', 'Text from Javascript').then(function(result) {
  ///      console.log(result);
  ///    });
  ///  """);
  ///```
  ///
  ///Forbidden names for JavaScript handlers are defined in [_JAVASCRIPT_HANDLER_FORBIDDEN_NAMES].
  ///
  ///**NOTE**: This method should be called, for example, in the [WebView.onWebViewCreated] or [WebView.onLoadStart] events or, at least,
  ///before you know that your JavaScript code will call the `window.flutter_inappwebview.callHandler` method,
  ///otherwise you won't be able to intercept the JavaScript message.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  void addJavaScriptHandler(
          {required String handlerName,
          required JavaScriptHandlerCallback callback}) =>
      platform.addJavaScriptHandler(
          handlerName: handlerName, callback: callback);

  ///Removes a JavaScript message handler previously added with the [addJavaScriptHandler] associated to [handlerName] key.
  ///Returns the value associated with [handlerName] before it was removed.
  ///Returns `null` if [handlerName] was not found.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  JavaScriptHandlerCallback? removeJavaScriptHandler(
          {required String handlerName}) =>
      platform.removeJavaScriptHandler(handlerName: handlerName);

  ///Returns `true` if a JavaScript handler with [handlerName] already exists, otherwise `false`.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  bool hasJavaScriptHandler({required String handlerName}) =>
      platform.hasJavaScriptHandler(handlerName: handlerName);

  ///Takes a screenshot of the WebView's visible viewport and returns a [Uint8List]. Returns `null` if it wasn't be able to take it.
  ///
  ///[screenshotConfiguration] represents the configuration data to use when generating an image from a web view’s contents.
  ///
  ///**NOTE for iOS**: available on iOS 11.0+.
  ///
  ///**NOTE for MacOS**: available on MacOS 10.13+.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS ([Official API - WKWebView.takeSnapshot](https://developer.apple.com/documentation/webkit/wkwebview/2873260-takesnapshot))
  ///- MacOS ([Official API - WKWebView.takeSnapshot](https://developer.apple.com/documentation/webkit/wkwebview/2873260-takesnapshot))
  Future<Uint8List?> takeScreenshot(
          {ScreenshotConfiguration? screenshotConfiguration}) =>
      platform.takeScreenshot(screenshotConfiguration: screenshotConfiguration);

  ///Use [setSettings] instead.
  @Deprecated('Use setSettings instead')
  Future<void> setOptions({required InAppWebViewGroupOptions options}) =>
      platform.setOptions(options: options);

  ///Use [getSettings] instead.
  @Deprecated('Use getSettings instead')
  Future<InAppWebViewGroupOptions?> getOptions() => platform.getOptions();

  ///Sets the WebView settings with the new [settings] and evaluates them.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  ///- Web
  Future<void> setSettings({required InAppWebViewSettings settings}) =>
      platform.setSettings(settings: settings);

  ///Gets the current WebView settings. Returns `null` if it wasn't able to get them.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  ///- Web
  Future<InAppWebViewSettings?> getSettings() => platform.getSettings();

  ///Gets the WebHistory for this WebView. This contains the back/forward list for use in querying each item in the history stack.
  ///This contains only a snapshot of the current state.
  ///Multiple calls to this method may return different objects.
  ///The object returned from this method will not be updated to reflect any new state.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.copyBackForwardList](https://developer.android.com/reference/android/webkit/WebView#copyBackForwardList()))
  ///- iOS ([Official API - WKWebView.backForwardList](https://developer.apple.com/documentation/webkit/wkwebview/1414977-backforwardlist))
  ///- MacOS ([Official API - WKWebView.backForwardList](https://developer.apple.com/documentation/webkit/wkwebview/1414977-backforwardlist))
  Future<WebHistory?> getCopyBackForwardList() =>
      platform.getCopyBackForwardList();

  ///Clears all the WebView's cache.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  Future<void> clearCache() => platform.clearCache();

  ///Use [FindInteractionController.findAll] instead.
  @Deprecated("Use FindInteractionController.findAll instead")
  Future<void> findAllAsync({required String find}) =>
      platform.findAllAsync(find: find);

  ///Use [FindInteractionController.findNext] instead.
  @Deprecated("Use FindInteractionController.findNext instead")
  Future<void> findNext({required bool forward}) =>
      platform.findNext(forward: forward);

  ///Use [FindInteractionController.clearMatches] instead.
  @Deprecated("Use FindInteractionController.clearMatches instead")
  Future<void> clearMatches() => platform.clearMatches();

  ///Use [tRexRunnerHtml] instead.
  @Deprecated("Use tRexRunnerHtml instead")
  Future<String> getTRexRunnerHtml() => platform.getTRexRunnerHtml();

  ///Use [tRexRunnerCss] instead.
  @Deprecated("Use tRexRunnerCss instead")
  Future<String> getTRexRunnerCss() => platform.getTRexRunnerCss();

  ///Scrolls the WebView to the position.
  ///
  ///[x] represents the x position to scroll to.
  ///
  ///[y] represents the y position to scroll to.
  ///
  ///[animated] `true` to animate the scroll transition, `false` to make the scoll transition immediate.
  ///
  ///**NOTE for Web**: this method will have effect only if the iframe has the same origin.
  ///
  ///**NOTE for MacOS**: this method is implemented using JavaScript.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - View.scrollTo](https://developer.android.com/reference/android/view/View#scrollTo(int,%20int)))
  ///- iOS ([Official API - UIScrollView.setContentOffset](https://developer.apple.com/documentation/uikit/uiscrollview/1619400-setcontentoffset))
  ///- MacOS
  ///- Web ([Official API - Window.scrollTo](https://developer.mozilla.org/en-US/docs/Web/API/Window/scrollTo))
  Future<void> scrollTo(
          {required int x, required int y, bool animated = false}) =>
      platform.scrollTo(x: x, y: y, animated: animated);

  ///Moves the scrolled position of the WebView.
  ///
  ///[x] represents the amount of pixels to scroll by horizontally.
  ///
  ///[y] represents the amount of pixels to scroll by vertically.
  ///
  ///[animated] `true` to animate the scroll transition, `false` to make the scoll transition immediate.
  ///
  ///**NOTE for Web**: this method will have effect only if the iframe has the same origin.
  ///
  ///**NOTE for MacOS**: this method is implemented using JavaScript.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - View.scrollBy](https://developer.android.com/reference/android/view/View#scrollBy(int,%20int)))
  ///- iOS ([Official API - UIScrollView.setContentOffset](https://developer.apple.com/documentation/uikit/uiscrollview/1619400-setcontentoffset))
  ///- MacOS
  ///- Web ([Official API - Window.scrollBy](https://developer.mozilla.org/en-US/docs/Web/API/Window/scrollBy))
  Future<void> scrollBy(
          {required int x, required int y, bool animated = false}) =>
      platform.scrollBy(x: x, y: y, animated: animated);

  ///On Android native WebView, it pauses all layout, parsing, and JavaScript timers for all WebViews.
  ///This is a global requests, not restricted to just this WebView. This can be useful if the application has been paused.
  ///
  ///**NOTE for iOS**: it is implemented using JavaScript and it is restricted to just this WebView.
  ///
  ///**NOTE for MacOS**: it is implemented using JavaScript and it is restricted to just this WebView.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.pauseTimers](https://developer.android.com/reference/android/webkit/WebView#pauseTimers()))
  ///- iOS
  ///- MacOS
  Future<void> pauseTimers() => platform.pauseTimers();

  ///On Android, it resumes all layout, parsing, and JavaScript timers for all WebViews. This will resume dispatching all timers.
  ///
  ///**NOTE for iOS**: it is implemented using JavaScript and it is restricted to just this WebView.
  ///
  ///**NOTE for MacOS**: it is implemented using JavaScript and it is restricted to just this WebView.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.resumeTimers](https://developer.android.com/reference/android/webkit/WebView#resumeTimers()))
  ///- iOS
  ///- MacOS
  Future<void> resumeTimers() => platform.resumeTimers();

  ///Prints the current page.
  ///
  ///To obtain the [PrintJobController], use [settings] argument with [PrintJobSettings.handledByClient] to `true`.
  ///Otherwise this method will return `null` and the [PrintJobController] will be handled and disposed automatically by the system.
  ///
  ///**NOTE for Android**: available on Android 19+.
  ///
  ///**NOTE for MacOS**: [PrintJobController] is available on MacOS 11.0+.
  ///
  ///**NOTE for Web**: this method will have effect only if the iframe has the same origin. Also, [PrintJobController] is always `null`.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - PrintManager.print](https://developer.android.com/reference/android/print/PrintManager#print(java.lang.String,%20android.print.PrintDocumentAdapter,%20android.print.PrintAttributes)))
  ///- iOS ([Official API - UIPrintInteractionController.present](https://developer.apple.com/documentation/uikit/uiprintinteractioncontroller/1618149-present))
  ///- MacOS (if 11.0+, [Official API - WKWebView.printOperation](https://developer.apple.com/documentation/webkit/wkwebview/3516861-printoperation), else [Official API - NSView.printView](https://developer.apple.com/documentation/appkit/nsview/1483705-printview))
  ///- Web ([Official API - Window.print](https://developer.mozilla.org/en-US/docs/Web/API/Window/print))
  Future<PlatformPrintJobController?> printCurrentPage(
          {PrintJobSettings? settings}) =>
      platform.printCurrentPage(settings: settings);

  ///Gets the height of the HTML content.
  ///
  ///**NOTE for Web**: this method will have effect only if the iframe has the same origin.
  ///
  ///**NOTE for MacOS**: it is implemented using JavaScript.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.getContentHeight](https://developer.android.com/reference/android/webkit/WebView#getContentHeight()))
  ///- iOS ([Official API - UIScrollView.contentSize](https://developer.apple.com/documentation/uikit/uiscrollview/1619399-contentsize))
  ///- MacOS
  ///- Web ([Official API - Document.documentElement.scrollHeight](https://developer.mozilla.org/en-US/docs/Web/API/Element/scrollHeight))
  Future<int?> getContentHeight() => platform.getContentHeight();

  ///Gets the width of the HTML content.
  ///
  ///**NOTE for Android**: it is implemented using JavaScript.
  ///
  ///**NOTE for Web**: this method will have effect only if the iframe has the same origin.
  ///
  ///**NOTE for MacOS**: it is implemented using JavaScript.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS ([Official API - UIScrollView.contentSize](https://developer.apple.com/documentation/uikit/uiscrollview/1619399-contentsize))
  ///- MacOS
  ///- Web ([Official API - Document.documentElement.scrollWidth](https://developer.mozilla.org/en-US/docs/Web/API/Element/scrollWidth))
  Future<int?> getContentWidth() => platform.getContentWidth();

  ///Performs a zoom operation in this WebView.
  ///
  ///[zoomFactor] represents the zoom factor to apply. On Android, the zoom factor will be clamped to the Webview's zoom limits and, also, this value must be in the range 0.01 (excluded) to 100.0 (included).
  ///
  ///[animated] `true` to animate the transition to the new scale, `false` to make the transition immediate.
  ///**NOTE**: available only on iOS.
  ///
  ///**NOTE**: available on Android 21+.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.zoomBy](https://developer.android.com/reference/android/webkit/WebView#zoomBy(float)))
  ///- iOS ([Official API - UIScrollView.setZoomScale](https://developer.apple.com/documentation/uikit/uiscrollview/1619412-setzoomscale))
  Future<void> zoomBy(
          {required double zoomFactor,
          @Deprecated('Use animated instead') bool? iosAnimated,
          bool animated = false}) =>
      platform.zoomBy(
          zoomFactor: zoomFactor, iosAnimated: iosAnimated, animated: animated);

  ///Gets the URL that was originally requested for the current page.
  ///This is not always the same as the URL passed to [InAppWebView.onLoadStart] because although the load for that URL has begun,
  ///the current page may not have changed. Also, there may have been redirects resulting in a different URL to that originally requested.
  ///
  ///**NOTE for Web**: it will return the current value of the `iframe.src` attribute.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.getOriginalUrl](https://developer.android.com/reference/android/webkit/WebView#getOriginalUrl()))
  ///- iOS
  ///- MacOS
  ///- Web
  Future<WebUri?> getOriginalUrl() => platform.getOriginalUrl();

  ///Gets the current zoom scale of the WebView.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS ([Official API - UIScrollView.zoomScale](https://developer.apple.com/documentation/uikit/uiscrollview/1619419-zoomscale))
  Future<double?> getZoomScale() => platform.getZoomScale();

  ///Use [getZoomScale] instead.
  @Deprecated('Use getZoomScale instead')
  Future<double?> getScale() => platform.getScale();

  ///Gets the selected text.
  ///
  ///**NOTE**: this method is implemented with using JavaScript.
  ///
  ///**NOTE for Android native WebView**: available only on Android 19+.
  ///
  ///**NOTE for Web**: this method will have effect only if the iframe has the same origin.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  ///- Web
  Future<String?> getSelectedText() => platform.getSelectedText();

  ///Gets the hit result for hitting an HTML elements.
  ///
  ///**NOTE**: On iOS, it is implemented using JavaScript.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.getHitTestResult](https://developer.android.com/reference/android/webkit/WebView#getHitTestResult()))
  ///- iOS
  Future<InAppWebViewHitTestResult?> getHitTestResult() =>
      platform.getHitTestResult();

  ///Clears the current focus. On iOS and Android native WebView, it will clear also, for example, the current text selection.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - ViewGroup.clearFocus](https://developer.android.com/reference/android/view/ViewGroup#clearFocus()))
  ///- iOS ([Official API - UIResponder.resignFirstResponder](https://developer.apple.com/documentation/uikit/uiresponder/1621097-resignfirstresponder))
  Future<void> clearFocus() => platform.clearFocus();

  ///Sets or updates the WebView context menu to be used next time it will appear.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  Future<void> setContextMenu(ContextMenu? contextMenu) =>
      platform.setContextMenu(contextMenu);

  ///Requests the anchor or image element URL at the last tapped point.
  ///
  ///**NOTE**: On iOS, it is implemented using JavaScript.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.requestFocusNodeHref](https://developer.android.com/reference/android/webkit/WebView#requestFocusNodeHref(android.os.Message)))
  ///- iOS
  Future<RequestFocusNodeHrefResult?> requestFocusNodeHref() =>
      platform.requestFocusNodeHref();

  ///Requests the URL of the image last touched by the user.
  ///
  ///**NOTE**: On iOS, it is implemented using JavaScript.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.requestImageRef](https://developer.android.com/reference/android/webkit/WebView#requestImageRef(android.os.Message)))
  ///- iOS
  Future<RequestImageRefResult?> requestImageRef() =>
      platform.requestImageRef();

  ///Returns the list of `<meta>` tags of the current WebView.
  ///
  ///**NOTE**: It is implemented using JavaScript.
  ///
  ///**NOTE for Web**: this method will have effect only if the iframe has the same origin.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  ///- Web
  Future<List<MetaTag>> getMetaTags() => platform.getMetaTags();

  ///Returns an instance of [Color] representing the `content` value of the
  ///`<meta name="theme-color" content="">` tag of the current WebView, if available, otherwise `null`.
  ///
  ///**NOTE**: on Android, Web, iOS < 15.0 and MacOS < 12.0, it is implemented using JavaScript.
  ///
  ///**NOTE for Web**: this method will have effect only if the iframe has the same origin.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS ([Official API - WKWebView.themeColor](https://developer.apple.com/documentation/webkit/wkwebview/3794258-themecolor))
  ///- MacOS ([Official API - WKWebView.themeColor](https://developer.apple.com/documentation/webkit/wkwebview/3794258-themecolor))
  ///- Web
  Future<Color?> getMetaThemeColor() => platform.getMetaThemeColor();

  ///Returns the scrolled left position of the current WebView.
  ///
  ///**NOTE for Web**: this method will have effect only if the iframe has the same origin.
  ///
  ///**NOTE for MacOS**: it is implemented using JavaScript.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - View.getScrollX](https://developer.android.com/reference/android/view/View#getScrollX()))
  ///- iOS ([Official API - UIScrollView.contentOffset](https://developer.apple.com/documentation/uikit/uiscrollview/1619404-contentoffset))
  ///- MacOS
  ///- Web ([Official API - Window.scrollX](https://developer.mozilla.org/en-US/docs/Web/API/Window/scrollX))
  Future<int?> getScrollX() => platform.getScrollX();

  ///Returns the scrolled top position of the current WebView.
  ///
  ///**NOTE for Web**: this method will have effect only if the iframe has the same origin.
  ///
  ///**NOTE for MacOS**: it is implemented using JavaScript.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - View.getScrollY](https://developer.android.com/reference/android/view/View#getScrollY()))
  ///- iOS ([Official API - UIScrollView.contentOffset](https://developer.apple.com/documentation/uikit/uiscrollview/1619404-contentoffset))
  ///- MacOS
  ///- Web ([Official API - Window.scrollY](https://developer.mozilla.org/en-US/docs/Web/API/Window/scrollY))
  Future<int?> getScrollY() => platform.getScrollY();

  ///Gets the SSL certificate for the main top-level page or null if there is no certificate (the site is not secure).
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.getCertificate](https://developer.android.com/reference/android/webkit/WebView#getCertificate()))
  ///- iOS
  ///- MacOS
  Future<SslCertificate?> getCertificate() => platform.getCertificate();

  ///Injects the specified [userScript] into the webpage’s content.
  ///
  ///**NOTE for iOS and MacOS**: this method will throw an error if the [WebView.windowId] has been set.
  ///There isn't any way to add/remove user scripts specific to window WebViews.
  ///This is a limitation of the native WebKit APIs.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS ([Official API - WKUserContentController.addUserScript](https://developer.apple.com/documentation/webkit/wkusercontentcontroller/1537448-adduserscript))
  ///- MacOS ([Official API - WKUserContentController.addUserScript](https://developer.apple.com/documentation/webkit/wkusercontentcontroller/1537448-adduserscript))
  Future<void> addUserScript({required UserScript userScript}) =>
      platform.addUserScript(userScript: userScript);

  ///Injects the [userScripts] into the webpage’s content.
  ///
  ///**NOTE for iOS and MacOS**: this method will throw an error if the [WebView.windowId] has been set.
  ///There isn't any way to add/remove user scripts specific to window WebViews.
  ///This is a limitation of the native WebKit APIs.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  Future<void> addUserScripts({required List<UserScript> userScripts}) =>
      platform.addUserScripts(userScripts: userScripts);

  ///Removes the specified [userScript] from the webpage’s content.
  ///User scripts already loaded into the webpage's content cannot be removed. This will have effect only on the next page load.
  ///Returns `true` if [userScript] was in the list, `false` otherwise.
  ///
  ///**NOTE for iOS and MacOS**: this method will throw an error if the [WebView.windowId] has been set.
  ///There isn't any way to add/remove user scripts specific to window WebViews.
  ///This is a limitation of the native WebKit APIs.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  Future<bool> removeUserScript({required UserScript userScript}) =>
      platform.removeUserScript(userScript: userScript);

  ///Removes all the [UserScript]s with [groupName] as group name from the webpage’s content.
  ///User scripts already loaded into the webpage's content cannot be removed. This will have effect only on the next page load.
  ///
  ///**NOTE for iOS and MacOS**: this method will throw an error if the [WebView.windowId] has been set.
  ///There isn't any way to add/remove user scripts specific to window WebViews.
  ///This is a limitation of the native WebKit APIs.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  Future<void> removeUserScriptsByGroupName({required String groupName}) =>
      platform.removeUserScriptsByGroupName(groupName: groupName);

  ///Removes the [userScripts] from the webpage’s content.
  ///User scripts already loaded into the webpage's content cannot be removed. This will have effect only on the next page load.
  ///
  ///**NOTE for iOS and MacOS**: this method will throw an error if the [WebView.windowId] has been set.
  ///There isn't any way to add/remove user scripts specific to window WebViews.
  ///This is a limitation of the native WebKit APIs.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  Future<void> removeUserScripts({required List<UserScript> userScripts}) =>
      platform.removeUserScripts(userScripts: userScripts);

  ///Removes all the user scripts from the webpage’s content.
  ///
  ///**NOTE for iOS and MacOS**: this method will throw an error if the [WebView.windowId] has been set.
  ///There isn't any way to add/remove user scripts specific to window WebViews.
  ///This is a limitation of the native WebKit APIs.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS ([Official API - WKUserContentController.removeAllUserScripts](https://developer.apple.com/documentation/webkit/wkusercontentcontroller/1536540-removealluserscripts))
  ///- MacOS ([Official API - WKUserContentController.removeAllUserScripts](https://developer.apple.com/documentation/webkit/wkusercontentcontroller/1536540-removealluserscripts))
  Future<void> removeAllUserScripts() => platform.removeAllUserScripts();

  ///Returns `true` if the [userScript] has been already added, otherwise `false`.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  bool hasUserScript({required UserScript userScript}) =>
      platform.hasUserScript(userScript: userScript);

  ///Executes the specified string as an asynchronous JavaScript function.
  ///
  ///[functionBody] is the JavaScript string to use as the function body.
  ///This method treats the string as an anonymous JavaScript function body and calls it with the named arguments in the arguments parameter.
  ///
  ///[arguments] is a `Map` of the arguments to pass to the function call.
  ///Each key in the `Map` corresponds to the name of an argument in the [functionBody] string,
  ///and the value of that key is the value to use during the evaluation of the code.
  ///Supported value types can be found in the official Flutter docs:
  ///[Platform channel data types support and codecs](https://flutter.dev/docs/development/platform-integration/platform-channels#codec),
  ///except for [Uint8List], [Int32List], [Int64List], and [Float64List] that should be converted into a [List].
  ///All items in a `List` or `Map` must also be one of the supported types.
  ///
  ///[contentWorld], on iOS, it represents the namespace in which to evaluate the JavaScript [source] code.
  ///Instead, on Android, it will run the [source] code into an iframe.
  ///This parameter doesn’t apply to changes you make to the underlying web content, such as the document’s DOM structure.
  ///Those changes remain visible to all scripts, regardless of which content world you specify.
  ///For more information about content worlds, see [ContentWorld].
  ///Available on iOS 14.3+.
  ///
  ///**NOTE**: This method shouldn't be called in the [WebView.onWebViewCreated] or [WebView.onLoadStart] events,
  ///because, in these events, the [WebView] is not ready to handle it yet.
  ///Instead, you should call this method, for example, inside the [WebView.onLoadStop] event or in any other events
  ///where you know the page is ready "enough".
  ///
  ///**NOTE for iOS**: available only on iOS 10.3+.
  ///
  ///**NOTE for Android**: available only on Android 21+.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS ([Official API - WKWebView.callAsyncJavaScript](https://developer.apple.com/documentation/webkit/wkwebview/3656441-callasyncjavascript))
  ///- MacOS ([Official API - WKWebView.callAsyncJavaScript](https://developer.apple.com/documentation/webkit/wkwebview/3656441-callasyncjavascript))
  Future<CallAsyncJavaScriptResult?> callAsyncJavaScript(
          {required String functionBody,
          Map<String, dynamic> arguments = const <String, dynamic>{},
          ContentWorld? contentWorld}) =>
      platform.callAsyncJavaScript(
          functionBody: functionBody,
          arguments: arguments,
          contentWorld: contentWorld);

  ///Saves the current WebView as a web archive.
  ///Returns the file path under which the web archive file was saved, or `null` if saving the file failed.
  ///
  ///[filePath] represents the file path where the archive should be placed. This value cannot be `null`.
  ///
  ///[autoname] if `false`, takes [filePath] to be a file.
  ///If `true`, [filePath] is assumed to be a directory in which a filename will be chosen according to the URL of the current page.
  ///
  ///**NOTE for iOS**: Available on iOS 14.0+. If [autoname] is `false`, the [filePath] must ends with the [WebArchiveFormat.WEBARCHIVE] file extension.
  ///
  ///**NOTE for MacOS**: Available on MacOS 11.0+. If [autoname] is `false`, the [filePath] must ends with the [WebArchiveFormat.WEBARCHIVE] file extension.
  ///
  ///**NOTE for Android**: if [autoname] is `false`, the [filePath] must ends with the [WebArchiveFormat.MHT] file extension.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.saveWebArchive](https://developer.android.com/reference/android/webkit/WebView#saveWebArchive(java.lang.String,%20boolean,%20android.webkit.ValueCallback%3Cjava.lang.String%3E)))
  ///- iOS
  ///- MacOS
  Future<String?> saveWebArchive(
          {required String filePath, bool autoname = false}) =>
      platform.saveWebArchive(filePath: filePath, autoname: autoname);

  ///Indicates whether the webpage context is capable of using features that require [secure contexts](https://developer.mozilla.org/en-US/docs/Web/Security/Secure_Contexts).
  ///This is implemented using Javascript (see [window.isSecureContext](https://developer.mozilla.org/en-US/docs/Web/API/Window/isSecureContext)).
  ///
  ///**NOTE for Android**: available Android 21.0+.
  ///
  ///**NOTE for Web**: this method will have effect only if the iframe has the same origin. Returns `false` otherwise.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  ///- Web ([Official API - Window.isSecureContext](https://developer.mozilla.org/en-US/docs/Web/API/Window/isSecureContext))
  Future<bool> isSecureContext() => platform.isSecureContext();

  ///Creates a message channel to communicate with JavaScript and returns the message channel with ports that represent the endpoints of this message channel.
  ///The HTML5 message channel functionality is described [here](https://html.spec.whatwg.org/multipage/comms.html#messagechannel).
  ///
  ///The returned message channels are entangled and already in started state.
  ///
  ///This method should be called when the page is loaded, for example, when the [WebView.onLoadStop] is fired, otherwise the [WebMessageChannel] won't work.
  ///
  ///**NOTE for Android native WebView**: This method should only be called if [WebViewFeature.isFeatureSupported] returns `true` for [WebViewFeature.CREATE_WEB_MESSAGE_CHANNEL].
  ///
  ///**NOTE for iOS**: it is implemented using JavaScript.
  ///
  ///**NOTE for MacOS**: it is implemented using JavaScript.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebViewCompat.createWebMessageChannel](https://developer.android.com/reference/androidx/webkit/WebViewCompat#createWebMessageChannel(android.webkit.WebView)))
  ///- iOS
  ///- MacOS
  Future<PlatformWebMessageChannel?> createWebMessageChannel() =>
      platform.createWebMessageChannel();

  ///Post a message to main frame. The embedded application can restrict the messages to a certain target origin.
  ///See [HTML5 spec](https://html.spec.whatwg.org/multipage/comms.html#posting-messages) for how target origin can be used.
  ///
  ///A target origin can be set as a wildcard ("*"). However this is not recommended.
  ///
  ///**NOTE for Android native WebView**: This method should only be called if [WebViewFeature.isFeatureSupported] returns `true` for [WebViewFeature.POST_WEB_MESSAGE].
  ///
  ///**NOTE for iOS**: it is implemented using JavaScript.
  ///
  ///**NOTE for MacOS**: it is implemented using JavaScript.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebViewCompat.postWebMessage](https://developer.android.com/reference/androidx/webkit/WebViewCompat#postWebMessage(android.webkit.WebView,%20androidx.webkit.WebMessageCompat,%20android.net.Uri)))
  ///- iOS
  ///- MacOS
  Future<void> postWebMessage(
          {required WebMessage message, WebUri? targetOrigin}) =>
      platform.postWebMessage(message: message, targetOrigin: targetOrigin);

  ///Adds a [WebMessageListener] to the WebView and injects a JavaScript object into each frame that the [WebMessageListener] will listen on.
  ///
  ///The injected JavaScript object will be named [WebMessageListener.jsObjectName] in the global scope.
  ///This will inject the JavaScript object in any frame whose origin matches [WebMessageListener.allowedOriginRules]
  ///for every navigation after this call, and the JavaScript object will be available immediately when the page begins to load.
  ///
  ///Each [WebMessageListener.allowedOriginRules] entry must follow the format `SCHEME "://" [ HOSTNAME_PATTERN [ ":" PORT ] ]`, each part is explained in the below table:
  ///
  ///<table>
  ///   <colgroup>
  ///      <col width="25%">
  ///   </colgroup>
  ///   <tbody>
  ///      <tr>
  ///         <th>Rule</th>
  ///         <th>Description</th>
  ///         <th>Example</th>
  ///      </tr>
  ///      <tr>
  ///         <td>http/https with hostname</td>
  ///         <td><code translate="no" dir="ltr">SCHEME</code> is http or https; <code translate="no" dir="ltr">HOSTNAME_<wbr>PATTERN</code> is a regular hostname; <code translate="no" dir="ltr">PORT</code> is optional, when not present, the rule will match port <code translate="no" dir="ltr">80</code> for http and port
  ///            <code translate="no" dir="ltr">443</code> for https.
  ///         </td>
  ///         <td>
  ///            <ul>
  ///               <li><code translate="no" dir="ltr">https://foobar.com:8080</code> - Matches https:// URL on port 8080, whose normalized
  ///                  host is foobar.com.
  ///               </li>
  ///               <li><code translate="no" dir="ltr">https://www.example.com</code> - Matches https:// URL on port 443, whose normalized host
  ///                  is www.example.com.
  ///               </li>
  ///            </ul>
  ///         </td>
  ///      </tr>
  ///      <tr>
  ///         <td>http/https with pattern matching</td>
  ///         <td><code translate="no" dir="ltr">SCHEME</code> is http or https; <code translate="no" dir="ltr">HOSTNAME_<wbr>PATTERN</code> is a sub-domain matching
  ///            pattern with a leading <code translate="no" dir="ltr">*.<wbr></code>; <code translate="no" dir="ltr">PORT</code> is optional, when not present, the rule will
  ///            match port <code translate="no" dir="ltr">80</code> for http and port <code translate="no" dir="ltr">443</code> for https.
  ///         </td>
  ///         <td>
  ///            <ul>
  ///               <li><code translate="no" dir="ltr">https://*.example.com</code> - Matches https://calendar.example.com and
  ///                  https://foo.bar.example.com but not https://example.com.
  ///               </li>
  ///               <li><code translate="no" dir="ltr">https://*.example.com:8080</code> - Matches https://calendar.example.com:8080</li>
  ///            </ul>
  ///         </td>
  ///      </tr>
  ///      <tr>
  ///         <td>http/https with IP literal</td>
  ///         <td><code translate="no" dir="ltr">SCHEME</code> is https or https; <code translate="no" dir="ltr">HOSTNAME_<wbr>PATTERN</code> is IP literal; <code translate="no" dir="ltr">PORT</code> is
  ///            optional, when not present, the rule will match port <code translate="no" dir="ltr">80</code> for http and port <code translate="no" dir="ltr">443</code>
  ///            for https.
  ///         </td>
  ///         <td>
  ///            <ul>
  ///               <li><code translate="no" dir="ltr">https://127.0.0.1</code> - Matches https:// URL on port 443, whose IPv4 address is
  ///                  127.0.0.1
  ///               </li>
  ///               <li><code translate="no" dir="ltr">https://[::1]</code> or <code translate="no" dir="ltr">https://[0:0::1]</code>- Matches any URL to the IPv6 loopback
  ///                  address with port 443.
  ///               </li>
  ///               <li><code translate="no" dir="ltr">https://[::1]:99</code> - Matches any https:// URL to the IPv6 loopback on port 99.</li>
  ///            </ul>
  ///         </td>
  ///      </tr>
  ///      <tr>
  ///         <td>Custom scheme</td>
  ///         <td><code translate="no" dir="ltr">SCHEME</code> is a custom scheme; <code translate="no" dir="ltr">HOSTNAME_<wbr>PATTERN</code> and <code translate="no" dir="ltr">PORT</code> must not be
  ///            present.
  ///         </td>
  ///         <td>
  ///            <ul>
  ///               <li><code translate="no" dir="ltr">my-app-scheme://</code> - Matches any my-app-scheme:// URL.</li>
  ///            </ul>
  ///         </td>
  ///      </tr>
  ///      <tr>
  ///         <td><code translate="no" dir="ltr">*</code></td>
  ///         <td>Wildcard rule, matches any origin.</td>
  ///         <td>
  ///            <ul>
  ///               <li><code translate="no" dir="ltr">*</code></li>
  ///            </ul>
  ///         </td>
  ///      </tr>
  ///   </tbody>
  ///</table>
  ///
  ///Note that this is a powerful API, as the JavaScript object will be injected when the frame's origin matches any one of the allowed origins.
  ///The HTTPS scheme is strongly recommended for security; allowing HTTP origins exposes the injected object to any potential network-based attackers.
  ///If a wildcard "*" is provided, it will inject the JavaScript object to all frames.
  ///A wildcard should only be used if the app wants **any** third party web page to be able to use the injected object.
  ///When using a wildcard, the app must treat received messages as untrustworthy and validate any data carefully.
  ///
  ///This method can be called multiple times to inject multiple JavaScript objects.
  ///
  ///Let's say the injected JavaScript object is named `myObject`. We will have following methods on that object once it is available to use:
  ///
  ///```javascript
  /// // Web page (in JavaScript)
  /// // message needs to be a JavaScript String, MessagePorts is an optional parameter.
  /// myObject.postMessage(message[, MessagePorts]) // on Android
  /// myObject.postMessage(message) // on iOS
  ///
  /// // To receive messages posted from the app side, assign a function to the "onmessage"
  /// // property. This function should accept a single "event" argument. "event" has a "data"
  /// // property, which is the message string from the app side.
  /// myObject.onmessage = function(event) { ... }
  ///
  /// // To be compatible with DOM EventTarget's addEventListener, it accepts type and listener
  /// // parameters, where type can be only "message" type and listener can only be a JavaScript
  /// // function for myObject. An event object will be passed to listener with a "data" property,
  /// // which is the message string from the app side.
  /// myObject.addEventListener(type, listener)
  ///
  /// // To be compatible with DOM EventTarget's removeEventListener, it accepts type and listener
  /// // parameters, where type can be only "message" type and listener can only be a JavaScript
  /// // function for myObject.
  /// myObject.removeEventListener(type, listener)
  ///```
  ///
  ///We start the communication between JavaScript and the app from the JavaScript side.
  ///In order to send message from the app to JavaScript, it needs to post a message from JavaScript first,
  ///so the app will have a [JavaScriptReplyProxy] object to respond. Example:
  ///
  ///```javascript
  /// // Web page (in JavaScript)
  /// myObject.onmessage = function(event) {
  ///   // prints "Got it!" when we receive the app's response.
  ///   console.log(event.data);
  /// }
  /// myObject.postMessage("I'm ready!");
  ///```
  ///
  ///```dart
  /// // Flutter App
  /// child: InAppWebView(
  ///   onWebViewCreated: (controller) async {
  ///     if (defaultTargetPlatform != TargetPlatform.android || await WebViewFeature.isFeatureSupported(WebViewFeature.WEB_MESSAGE_LISTENER)) {
  ///       await controller.addWebMessageListener(WebMessageListener(
  ///         jsObjectName: "myObject",
  ///         onPostMessage: (message, sourceOrigin, isMainFrame, replyProxy) {
  ///           // do something about message, sourceOrigin and isMainFrame.
  ///           replyProxy.postMessage("Got it!");
  ///         },
  ///       ));
  ///     }
  ///     await controller.loadUrl(urlRequest: URLRequest(url: WebUri("https://www.example.com")));
  ///   },
  /// ),
  ///```
  ///
  ///**NOTE for Android**: This method should only be called if [WebViewFeature.isFeatureSupported] returns `true` for [WebViewFeature.WEB_MESSAGE_LISTENER].
  ///
  ///**NOTE for iOS**: it is implemented using JavaScript.
  ///
  ///**NOTE for MacOS**: it is implemented using JavaScript.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebViewCompat.WebMessageListener](https://developer.android.com/reference/androidx/webkit/WebViewCompat#addWebMessageListener(android.webkit.WebView,%20java.lang.String,%20java.util.Set%3Cjava.lang.String%3E,%20androidx.webkit.WebViewCompat.WebMessageListener)))
  ///- iOS
  ///- MacOS
  Future<void> addWebMessageListener(WebMessageListener webMessageListener) =>
      platform.addWebMessageListener(webMessageListener.platform);

  ///Returns `true` if the [webMessageListener] has been already added, otherwise `false`.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  bool hasWebMessageListener(WebMessageListener webMessageListener) =>
      platform.hasWebMessageListener(webMessageListener.platform);

  ///Returns `true` if the webpage can scroll vertically, otherwise `false`.
  ///
  ///**NOTE for Web**: this method will have effect only if the iframe has the same origin.
  ///
  ///**NOTE for MacOS**: it is implemented using JavaScript.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  ///- Web
  Future<bool> canScrollVertically() => platform.canScrollVertically();

  ///Returns `true` if the webpage can scroll horizontally, otherwise `false`.
  ///
  ///**NOTE for Web**: this method will have effect only if the iframe has the same origin.
  ///
  ///**NOTE for MacOS**: it is implemented using JavaScript.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  ///- Web
  Future<bool> canScrollHorizontally() => platform.canScrollHorizontally();

  ///Starts Safe Browsing initialization.
  ///
  ///URL loads are not guaranteed to be protected by Safe Browsing until after the this method returns true.
  ///Safe Browsing is not fully supported on all devices. For those devices this method will returns false.
  ///
  ///This should not be called if Safe Browsing has been disabled by manifest tag or [AndroidInAppWebViewOptions.safeBrowsingEnabled].
  ///This prepares resources used for Safe Browsing.
  ///
  ///This method should only be called if [WebViewFeature.isFeatureSupported] returns `true` for [WebViewFeature.START_SAFE_BROWSING].
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.startSafeBrowsing](https://developer.android.com/reference/android/webkit/WebView#startSafeBrowsing(android.content.Context,%20android.webkit.ValueCallback%3Cjava.lang.Boolean%3E)))
  Future<bool> startSafeBrowsing() => platform.startSafeBrowsing();

  ///Clears the SSL preferences table stored in response to proceeding with SSL certificate errors.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.clearSslPreferences](https://developer.android.com/reference/android/webkit/WebView#clearSslPreferences()))
  Future<void> clearSslPreferences() => platform.clearSslPreferences();

  ///Does a best-effort attempt to pause any processing that can be paused safely, such as animations and geolocation. Note that this call does not pause JavaScript.
  ///To pause JavaScript globally, use [InAppWebViewController.pauseTimers]. To resume WebView, call [resume].
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.onPause](https://developer.android.com/reference/android/webkit/WebView#onPause()))
  Future<void> pause() => platform.pause();

  ///Resumes a WebView after a previous call to [pause].
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.onResume](https://developer.android.com/reference/android/webkit/WebView#onResume()))
  Future<void> resume() => platform.resume();

  ///Scrolls the contents of this WebView down by half the page size.
  ///Returns `true` if the page was scrolled.
  ///
  ///[bottom] `true` to jump to bottom of page.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.pageDown](https://developer.android.com/reference/android/webkit/WebView#pageDown(boolean)))
  Future<bool> pageDown({required bool bottom}) =>
      platform.pageDown(bottom: bottom);

  ///Scrolls the contents of this WebView up by half the view size.
  ///Returns `true` if the page was scrolled.
  ///
  ///[top] `true` to jump to the top of the page.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.pageUp](https://developer.android.com/reference/android/webkit/WebView#pageUp(boolean)))
  Future<bool> pageUp({required bool top}) => platform.pageUp(top: top);

  ///Performs zoom in in this WebView.
  ///Returns `true` if zoom in succeeds, `false` if no zoom changes.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.zoomIn](https://developer.android.com/reference/android/webkit/WebView#zoomIn()))
  Future<bool> zoomIn() => platform.zoomIn();

  ///Performs zoom out in this WebView.
  ///Returns `true` if zoom out succeeds, `false` if no zoom changes.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.zoomOut](https://developer.android.com/reference/android/webkit/WebView#zoomOut()))
  Future<bool> zoomOut() => platform.zoomOut();

  ///Clears the internal back/forward list.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.clearHistory](https://developer.android.com/reference/android/webkit/WebView#clearHistory()))
  Future<void> clearHistory() => platform.clearHistory();

  ///Reloads the current page, performing end-to-end revalidation using cache-validating conditionals if possible.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - WKWebView.reloadFromOrigin](https://developer.apple.com/documentation/webkit/wkwebview/1414956-reloadfromorigin))
  ///- MacOS ([Official API - WKWebView.reloadFromOrigin](https://developer.apple.com/documentation/webkit/wkwebview/1414956-reloadfromorigin))
  Future<void> reloadFromOrigin() => platform.reloadFromOrigin();

  ///Generates PDF data from the web view’s contents asynchronously.
  ///Returns `null` if a problem occurred.
  ///
  ///[pdfConfiguration] represents the object that specifies the portion of the web view to capture as PDF data.
  ///
  ///**NOTE for iOS**: available only on iOS 14.0+.
  ///
  ///**NOTE for MacOS**: available only on MacOS 11.0+.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - WKWebView.createPdf](https://developer.apple.com/documentation/webkit/wkwebview/3650490-createpdf))
  ///- MacOS ([Official API - WKWebView.createPdf](https://developer.apple.com/documentation/webkit/wkwebview/3650490-createpdf))
  Future<Uint8List?> createPdf(
          {@Deprecated("Use pdfConfiguration instead")
          // ignore: deprecated_member_use_from_same_package
          IOSWKPDFConfiguration? iosWKPdfConfiguration,
          PDFConfiguration? pdfConfiguration}) =>
      platform.createPdf(
          iosWKPdfConfiguration: iosWKPdfConfiguration,
          pdfConfiguration: pdfConfiguration);

  ///Creates a web archive of the web view’s current contents asynchronously.
  ///Returns `null` if a problem occurred.
  ///
  ///**NOTE for iOS**: available only on iOS 14.0+.
  ///
  ///**NOTE for MacOS**: available only on MacOS 11.0+.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - WKWebView.createWebArchiveData](https://developer.apple.com/documentation/webkit/wkwebview/3650491-createwebarchivedata))
  ///- MacOS ([Official API - WKWebView.createWebArchiveData](https://developer.apple.com/documentation/webkit/wkwebview/3650491-createwebarchivedata))
  Future<Uint8List?> createWebArchiveData() => platform.createWebArchiveData();

  ///A Boolean value indicating whether all resources on the page have been loaded over securely encrypted connections.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - WKWebView.hasOnlySecureContent](https://developer.apple.com/documentation/webkit/wkwebview/1415002-hasonlysecurecontent))
  ///- MacOS ([Official API - WKWebView.hasOnlySecureContent](https://developer.apple.com/documentation/webkit/wkwebview/1415002-hasonlysecurecontent))
  Future<bool> hasOnlySecureContent() => platform.hasOnlySecureContent();

  ///Pauses playback of all media in the web view.
  ///
  ///**NOTE for iOS**: available on iOS 15.0+.
  ///
  ///**NOTE for MacOS**: available on MacOS 12.0+.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - WKWebView.pauseAllMediaPlayback](https://developer.apple.com/documentation/webkit/wkwebview/3752240-pauseallmediaplayback)).
  ///- MacOS ([Official API - WKWebView.pauseAllMediaPlayback](https://developer.apple.com/documentation/webkit/wkwebview/3752240-pauseallmediaplayback)).
  Future<void> pauseAllMediaPlayback() => platform.pauseAllMediaPlayback();

  ///Changes whether the webpage is suspending playback of all media in the page.
  ///Pass `true` to pause all media the web view is playing. Neither the user nor the webpage can resume playback until you call this method again with `false`.
  ///
  ///[suspended] represents a [bool] value that indicates whether the webpage should suspend media playback.
  ///
  ///**NOTE for iOS**: available on iOS 15.0+.
  ///
  ///**NOTE for MacOS**: available on MacOS 12.0+.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - WKWebView.setAllMediaPlaybackSuspended](https://developer.apple.com/documentation/webkit/wkwebview/3752242-setallmediaplaybacksuspended)).
  ///- MacOS ([Official API - WKWebView.setAllMediaPlaybackSuspended](https://developer.apple.com/documentation/webkit/wkwebview/3752242-setallmediaplaybacksuspended)).
  Future<void> setAllMediaPlaybackSuspended({required bool suspended}) =>
      platform.setAllMediaPlaybackSuspended(suspended: suspended);

  ///Closes all media the web view is presenting, including picture-in-picture video and fullscreen video.
  ///
  ///**NOTE for iOS**: available on iOS 14.5+.
  ///
  ///**NOTE for MacOS**: available on MacOS 11.3+.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - WKWebView.closeAllMediaPresentations](https://developer.apple.com/documentation/webkit/wkwebview/3752235-closeallmediapresentations)).
  ///- MacOS ([Official API - WKWebView.closeAllMediaPresentations](https://developer.apple.com/documentation/webkit/wkwebview/3752235-closeallmediapresentations)).
  Future<void> closeAllMediaPresentations() =>
      platform.closeAllMediaPresentations();

  ///Requests the playback status of media in the web view.
  ///Returns a [MediaPlaybackState] that indicates whether the media in the web view is playing, paused, or suspended.
  ///If there’s no media in the web view to play, this method provides [MediaPlaybackState.NONE].
  ///
  ///**NOTE for iOS**: available on iOS 15.0+.
  ///
  ///**NOTE for MacOS**: available on MacOS 12.0+.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - WKWebView.requestMediaPlaybackState](https://developer.apple.com/documentation/webkit/wkwebview/3752241-requestmediaplaybackstate)).
  ///- MacOS ([Official API - WKWebView.requestMediaPlaybackState](https://developer.apple.com/documentation/webkit/wkwebview/3752241-requestmediaplaybackstate)).
  Future<MediaPlaybackState?> requestMediaPlaybackState() =>
      platform.requestMediaPlaybackState();

  ///Returns `true` if the [WebView] is in fullscreen mode, otherwise `false`.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  Future<bool> isInFullscreen() => platform.isInFullscreen();

  ///Returns a [MediaCaptureState] that indicates whether the webpage is using the camera to capture images or video.
  ///
  ///**NOTE for iOS**: available on iOS 15.0+.
  ///
  ///**NOTE for MacOS**: available on MacOS 12.0+.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - WKWebView.cameraCaptureState](https://developer.apple.com/documentation/webkit/wkwebview/3763093-cameracapturestate)).
  ///- MacOS ([Official API - WKWebView.cameraCaptureState](https://developer.apple.com/documentation/webkit/wkwebview/3763093-cameracapturestate)).
  Future<MediaCaptureState?> getCameraCaptureState() =>
      platform.getCameraCaptureState();

  ///Changes whether the webpage is using the camera to capture images or video.
  ///
  ///**NOTE for iOS**: available on iOS 15.0+.
  ///
  ///**NOTE for MacOS**: available on MacOS 12.0+.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - WKWebView.setCameraCaptureState](https://developer.apple.com/documentation/webkit/wkwebview/3763097-setcameracapturestate)).
  ///- MacOS ([Official API - WKWebView.setCameraCaptureState](https://developer.apple.com/documentation/webkit/wkwebview/3763097-setcameracapturestate)).
  Future<void> setCameraCaptureState({required MediaCaptureState state}) =>
      platform.setCameraCaptureState(state: state);

  ///Returns a [MediaCaptureState] that indicates whether the webpage is using the microphone to capture audio.
  ///
  ///**NOTE for iOS**: available on iOS 15.0+.
  ///
  ///**NOTE for MacOS**: available on MacOS 12.0+.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - WKWebView.microphoneCaptureState](https://developer.apple.com/documentation/webkit/wkwebview/3763096-microphonecapturestate)).
  ///- MacOS ([Official API - WKWebView.microphoneCaptureState](https://developer.apple.com/documentation/webkit/wkwebview/3763096-microphonecapturestate)).
  Future<MediaCaptureState?> getMicrophoneCaptureState() =>
      platform.getMicrophoneCaptureState();

  ///Changes whether the webpage is using the microphone to capture audio.
  ///
  ///**NOTE for iOS**: available on iOS 15.0+.
  ///
  ///**NOTE for MacOS**: available on MacOS 12.0+.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - WKWebView.setMicrophoneCaptureState](https://developer.apple.com/documentation/webkit/wkwebview/3763098-setmicrophonecapturestate)).
  ///- MacOS ([Official API - WKWebView.setMicrophoneCaptureState](https://developer.apple.com/documentation/webkit/wkwebview/3763098-setmicrophonecapturestate)).
  Future<void> setMicrophoneCaptureState({required MediaCaptureState state}) =>
      platform.setMicrophoneCaptureState(state: state);

  ///Loads the web content from the data you provide as if the data were the response to the request.
  ///If [urlResponse] is `null`, it loads the web content from the data as an utf8 encoded HTML string as the response to the request.
  ///
  ///[urlRequest] represents a URL request that specifies the base URL and other loading details the system uses to interpret the data you provide.
  ///
  ///[urlResponse] represents a response the system uses to interpret the data you provide.
  ///
  ///[data] represents the data or the utf8 encoded HTML string to use as the contents of the webpage.
  ///
  ///Example:
  ///```dart
  ///controller.loadSimulateloadSimulatedRequestdRequest(urlRequest: URLRequest(
  ///    url: WebUri("https://flutter.dev"),
  ///  ),
  ///  data: Uint8List.fromList(utf8.encode("<h1>Hello</h1>"))
  ///);
  ///```
  ///
  ///**NOTE for iOS**: available on iOS 15.0+.
  ///
  ///**NOTE for MacOS**: available on MacOS 12.0+.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - WKWebView.loadSimulatedRequest(_:response:responseData:)](https://developer.apple.com/documentation/webkit/wkwebview/3763094-loadsimulatedrequest) and [Official API - WKWebView.loadSimulatedRequest(_:responseHTML:)](https://developer.apple.com/documentation/webkit/wkwebview/3763095-loadsimulatedrequest)).
  ///- MacOS ([Official API - WKWebView.loadSimulatedRequest(_:response:responseData:)](https://developer.apple.com/documentation/webkit/wkwebview/3763094-loadsimulatedrequest) and [Official API - WKWebView.loadSimulatedRequest(_:responseHTML:)](https://developer.apple.com/documentation/webkit/wkwebview/3763095-loadsimulatedrequest)).
  Future<void> loadSimulatedRequest(
          {required URLRequest urlRequest,
          required Uint8List data,
          URLResponse? urlResponse}) =>
      platform.loadSimulatedRequest(urlRequest: urlRequest, data: data);

  ///Returns the iframe `id` attribute used on the Web platform.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Web
  Future<String?> getIFrameId() => platform.getIFrameId();

  ///Gets the default user agent.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebSettings.getDefaultUserAgent](https://developer.android.com/reference/android/webkit/WebSettings#getDefaultUserAgent(android.content.Context)))
  ///- iOS
  ///- MacOS
  static Future<String> getDefaultUserAgent() =>
      PlatformInAppWebViewController.static().getDefaultUserAgent();

  ///Clears the client certificate preferences stored in response to proceeding/cancelling client cert requests.
  ///Note that WebView automatically clears these preferences when the system keychain is updated.
  ///The preferences are shared by all the WebViews that are created by the embedder application.
  ///
  ///**NOTE**: On iOS certificate-based credentials are never stored permanently.
  ///
  ///**NOTE**: available on Android 21+.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.clearClientCertPreferences](https://developer.android.com/reference/android/webkit/WebView#clearClientCertPreferences(java.lang.Runnable)))
  static Future<void> clearClientCertPreferences() =>
      PlatformInAppWebViewController.static().clearClientCertPreferences();

  ///Returns a URL pointing to the privacy policy for Safe Browsing reporting.
  ///
  ///This method should only be called if [WebViewFeature.isFeatureSupported] returns `true` for [WebViewFeature.SAFE_BROWSING_PRIVACY_POLICY_URL].
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebViewCompat.getSafeBrowsingPrivacyPolicyUrl](https://developer.android.com/reference/androidx/webkit/WebViewCompat#getSafeBrowsingPrivacyPolicyUrl()))
  static Future<WebUri?> getSafeBrowsingPrivacyPolicyUrl() =>
      PlatformInAppWebViewController.static().getSafeBrowsingPrivacyPolicyUrl();

  ///Use [setSafeBrowsingAllowlist] instead.
  @Deprecated("Use setSafeBrowsingAllowlist instead")
  static Future<bool> setSafeBrowsingWhitelist({required List<String> hosts}) =>
      PlatformInAppWebViewController.static()
          .setSafeBrowsingWhitelist(hosts: hosts);

  ///Sets the list of hosts (domain names/IP addresses) that are exempt from SafeBrowsing checks. The list is global for all the WebViews.
  ///
  /// Each rule should take one of these:
  ///| Rule | Example | Matches Subdomain |
  ///| -- | -- | -- |
  ///| HOSTNAME | example.com | Yes |
  ///| .HOSTNAME | .example.com | No |
  ///| IPV4_LITERAL | 192.168.1.1 | No |
  ///| IPV6_LITERAL_WITH_BRACKETS | [10:20:30:40:50:60:70:80] | No |
  ///
  ///All other rules, including wildcards, are invalid. The correct syntax for hosts is defined by [RFC 3986](https://tools.ietf.org/html/rfc3986#section-3.2.2).
  ///
  ///This method should only be called if [WebViewFeature.isFeatureSupported] returns `true` for [WebViewFeature.SAFE_BROWSING_ALLOWLIST].
  ///
  ///[hosts] represents the list of hosts. This value must never be `null`.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebViewCompat.setSafeBrowsingAllowlist](https://developer.android.com/reference/androidx/webkit/WebViewCompat#setSafeBrowsingAllowlist(java.util.Set%3Cjava.lang.String%3E,%20android.webkit.ValueCallback%3Cjava.lang.Boolean%3E)))
  static Future<bool> setSafeBrowsingAllowlist({required List<String> hosts}) =>
      PlatformInAppWebViewController.static()
          .setSafeBrowsingAllowlist(hosts: hosts);

  ///If WebView has already been loaded into the current process this method will return the package that was used to load it.
  ///Otherwise, the package that would be used if the WebView was loaded right now will be returned;
  ///this does not cause WebView to be loaded, so this information may become outdated at any time.
  ///The WebView package changes either when the current WebView package is updated, disabled, or uninstalled.
  ///It can also be changed through a Developer Setting. If the WebView package changes, any app process that
  ///has loaded WebView will be killed.
  ///The next time the app starts and loads WebView it will use the new WebView package instead.
  ///
  ///**NOTE**: available only on Android 21+.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebViewCompat.getCurrentWebViewPackage](https://developer.android.com/reference/androidx/webkit/WebViewCompat#getCurrentWebViewPackage(android.content.Context)))
  static Future<WebViewPackageInfo?> getCurrentWebViewPackage() =>
      PlatformInAppWebViewController.static().getCurrentWebViewPackage();

  ///Enables debugging of web contents (HTML / CSS / JavaScript) loaded into any WebViews of this application.
  ///This flag can be enabled in order to facilitate debugging of web layouts and JavaScript code running inside WebViews.
  ///Please refer to WebView documentation for the debugging guide. The default is `false`.
  ///
  ///[debuggingEnabled] whether to enable web contents debugging.
  ///
  ///**NOTE**: available only on Android 19+.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.setWebContentsDebuggingEnabled](https://developer.android.com/reference/android/webkit/WebView#setWebContentsDebuggingEnabled(boolean)))
  static Future<void> setWebContentsDebuggingEnabled(bool debuggingEnabled) =>
      PlatformInAppWebViewController.static()
          .setWebContentsDebuggingEnabled(debuggingEnabled);

  ///Gets the WebView variations encoded to be used as the X-Client-Data HTTP header.
  ///
  ///The app is responsible for adding the X-Client-Data header to any request
  ///that may use variations metadata, such as requests to Google web properties.
  ///The returned string will be a base64 encoded ClientVariations proto:
  ///https://source.chromium.org/chromium/chromium/src/+/main:components/variations/proto/client_variations.proto
  ///
  ///The string may be empty if the header is not available.
  ///
  ///**NOTE for Android native WebView**: This method should only be called if [WebViewFeature.isFeatureSupported] returns `true` for [WebViewFeature.GET_VARIATIONS_HEADER].
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebViewCompat.getVariationsHeader](https://developer.android.com/reference/androidx/webkit/WebViewCompat#getVariationsHeader()))
  static Future<String?> getVariationsHeader() =>
      PlatformInAppWebViewController.static().getVariationsHeader();

  ///Returns `true` if WebView is running in multi process mode.
  ///
  ///In Android O and above, WebView may run in "multiprocess" mode.
  ///In multiprocess mode, rendering of web content is performed by a sandboxed
  ///renderer process separate to the application process.
  ///This renderer process may be shared with other WebViews in the application,
  ///but is not shared with other application processes.
  ///
  ///**NOTE for Android native WebView**: This method should only be called if [WebViewFeature.isFeatureSupported] returns `true` for [WebViewFeature.MULTI_PROCESS].
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebViewCompat.isMultiProcessEnabled](https://developer.android.com/reference/androidx/webkit/WebViewCompat#isMultiProcessEnabled()))
  static Future<bool> isMultiProcessEnabled() =>
      PlatformInAppWebViewController.static().isMultiProcessEnabled();

  ///Indicate that the current process does not intend to use WebView,
  ///and that an exception should be thrown if a WebView is created or any other
  ///methods in the `android.webkit` package are used.
  ///
  ///Applications with multiple processes may wish to call this in processes that
  ///are not intended to use WebView to avoid accidentally incurring the memory usage
  ///of initializing WebView in long-lived processes that have no need for it,
  ///and to prevent potential data directory conflicts (see [ProcessGlobalConfigSettings.dataDirectorySuffix]).
  ///
  ///**NOTE for Android**: available only on Android 28+.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView ([Official API - WebView.disableWebView](https://developer.android.com/reference/android/webkit/WebView.html#disableWebView()))
  static Future<void> disableWebView() =>
      PlatformInAppWebViewController.static().disableWebView();

  ///Returns a Boolean value that indicates whether WebKit natively supports resources with the specified URL scheme.
  ///
  ///[urlScheme] represents the URL scheme associated with the resource.
  ///
  ///**NOTE for iOS**: available only on iOS 11.0+.
  ///
  ///**NOTE for MacOS**: available only on MacOS 10.13+.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - WKWebView.handlesURLScheme](https://developer.apple.com/documentation/webkit/wkwebview/2875370-handlesurlscheme))
  ///- MacOS ([Official API - WKWebView.handlesURLScheme](https://developer.apple.com/documentation/webkit/wkwebview/2875370-handlesurlscheme))
  static Future<bool> handlesURLScheme(String urlScheme) =>
      PlatformInAppWebViewController.static().handlesURLScheme(urlScheme);

  ///Disposes the WebView that is using the [keepAlive] instance
  ///for the keep alive feature.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  static Future<void> disposeKeepAlive(InAppWebViewKeepAlive keepAlive) =>
      PlatformInAppWebViewController.static().disposeKeepAlive(keepAlive);

  ///Gets the html (with javascript) of the Chromium's t-rex runner game. Used in combination with [tRexRunnerCss].
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  static Future<String> get tRexRunnerHtml =>
      PlatformInAppWebViewController.static().tRexRunnerHtml;

  ///Gets the css of the Chromium's t-rex runner game. Used in combination with [tRexRunnerHtml].
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android native WebView
  ///- iOS
  ///- MacOS
  static Future<String> get tRexRunnerCss =>
      PlatformInAppWebViewController.static().tRexRunnerCss;

  ///View ID used internally.
  dynamic getViewId() => platform.getViewId();

  ///Disposes the controller.
  void dispose({bool isKeepAlive = false}) =>
      platform.dispose(isKeepAlive: isKeepAlive);
}
