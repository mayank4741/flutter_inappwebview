import 'dart:async';
import 'dart:collection';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';

///This class uses native [Chrome Custom Tabs](https://developer.android.com/reference/android/support/customtabs/package-summary) on Android
///and [SFSafariViewController](https://developer.apple.com/documentation/safariservices/sfsafariviewcontroller) on iOS.
///
///**NOTE**: If you want to use the `ChromeSafariBrowser` class on Android 11+ you need to specify your app querying for
///`android.support.customtabs.action.CustomTabsService` in your `AndroidManifest.xml`
///(you can read more about it here: https://developers.google.com/web/android/custom-tabs/best-practices#applications_targeting_android_11_api_level_30_or_above).
///
///**Supported Platforms/Implementations**:
///- Android
///- iOS
class ChromeSafariBrowser implements PlatformChromeSafariBrowserEvents {
  ///Debug settings.
  static DebugLoggingSettings debugLoggingSettings = DebugLoggingSettings();

  /// Constructs a [ChromeSafariBrowser].
  ///
  /// See [ChromeSafariBrowser.fromPlatformCreationParams] for setting
  /// parameters for a specific platform.
  ChromeSafariBrowser()
      : this.fromPlatformCreationParams(
          PlatformChromeSafariBrowserCreationParams(),
        );

  /// Constructs a [ChromeSafariBrowser] from creation params for a specific
  /// platform.
  ChromeSafariBrowser.fromPlatformCreationParams(
    PlatformChromeSafariBrowserCreationParams params,
  ) : this.fromPlatform(PlatformChromeSafariBrowser(params));

  /// Constructs a [ChromeSafariBrowser] from a specific platform
  /// implementation.
  ChromeSafariBrowser.fromPlatform(this.platform) {
    this.platform.eventHandler = this;
  }

  /// Implementation of [PlatformWebViewChromeSafariBrowser] for the current platform.
  final PlatformChromeSafariBrowser platform;

  ///{@macro flutter_inappwebview_platform_interface.PlatformChromeSafariBrowser.id}
  String get id => platform.id;

  ///Opens the [ChromeSafariBrowser] instance with an [url].
  ///
  ///[url] - The [url] to load. On iOS, the [url] is required and must use the `http` or `https` scheme.
  ///
  ///[headers] (Supported only on Android) - [whitelisted](https://fetch.spec.whatwg.org/#cors-safelisted-request-header) cross-origin request headers.
  ///It is possible to attach non-whitelisted headers to cross-origin requests, when the server and client are related using a
  ///[digital asset link](https://developers.google.com/digital-asset-links/v1/getting-started).
  ///
  ///[otherLikelyURLs] - Other likely destinations, sorted in decreasing likelihood order. Supported only on Android.
  ///
  ///[referrer] - referrer header. Supported only on Android.
  ///
  ///[options] - Deprecated. Use `settings` instead.
  ///
  ///[settings] - Settings for the [ChromeSafariBrowser].
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android
  ///- iOS
  Future<void> open(
          {WebUri? url,
          Map<String, String>? headers,
          List<WebUri>? otherLikelyURLs,
          WebUri? referrer,
          @Deprecated('Use settings instead')
          // ignore: deprecated_member_use_from_same_package
          ChromeSafariBrowserClassOptions? options,
          ChromeSafariBrowserSettings? settings}) =>
      platform.open(
          url: url,
          headers: headers,
          otherLikelyURLs: otherLikelyURLs,
          options: options,
          settings: settings);

  ///Tells the browser to launch with [url].
  ///
  ///[url] - initial url.
  ///
  ///[headers] (Supported only on Android) - [whitelisted](https://fetch.spec.whatwg.org/#cors-safelisted-request-header) cross-origin request headers.
  ///It is possible to attach non-whitelisted headers to cross-origin requests, when the server and client are related using a
  ///[digital asset link](https://developers.google.com/digital-asset-links/v1/getting-started).
  ///
  ///[otherLikelyURLs] - Other likely destinations, sorted in decreasing likelihood order.
  ///
  ///[referrer] - referrer header. Supported only on Android.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android
  Future<void> launchUrl({
    required WebUri url,
    Map<String, String>? headers,
    List<WebUri>? otherLikelyURLs,
    WebUri? referrer,
  }) =>
      platform.launchUrl(
          url: url,
          headers: headers,
          otherLikelyURLs: otherLikelyURLs,
          referrer: referrer);

  ///Tells the browser of a likely future navigation to a URL.
  ///The most likely URL has to be specified first.
  ///Optionally, a list of other likely URLs can be provided.
  ///They are treated as less likely than the first one, and have to be sorted in decreasing priority order.
  ///These additional URLs may be ignored. All previous calls to this method will be deprioritized.
  ///
  ///[url] - Most likely URL, may be null if otherLikelyBundles is provided.
  ///
  ///[otherLikelyURLs] - Other likely destinations, sorted in decreasing likelihood order.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android ([Official API - CustomTabsSession.mayLaunchUrl](https://developer.android.com/reference/androidx/browser/customtabs/CustomTabsSession#mayLaunchUrl(android.net.Uri,android.os.Bundle,java.util.List%3Candroid.os.Bundle%3E)))
  Future<bool> mayLaunchUrl({WebUri? url, List<WebUri>? otherLikelyURLs}) =>
      platform.mayLaunchUrl(url: url, otherLikelyURLs: otherLikelyURLs);

  ///Requests to validate a relationship between the application and an origin.
  ///
  ///See [here](https://developers.google.com/digital-asset-links/v1/getting-started) for documentation about Digital Asset Links.
  ///This methods requests the browser to verify a relation with the calling application, to grant the associated rights.
  ///
  ///If this method returns `true`, the validation result will be provided through [onRelationshipValidationResult].
  ///Otherwise the request didn't succeed.
  ///
  ///[relation] – Relation to check, must be one of the [CustomTabsRelationType] constants.
  ///
  ///[origin] – Origin.
  ///
  ///[extras] – Reserved for future use.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android ([Official API - CustomTabsSession.validateRelationship](https://developer.android.com/reference/androidx/browser/customtabs/CustomTabsSession#validateRelationship(int,android.net.Uri,android.os.Bundle)))
  Future<bool> validateRelationship(
          {required CustomTabsRelationType relation, required WebUri origin}) =>
      platform.validateRelationship(relation: relation, origin: origin);

  ///Closes the [ChromeSafariBrowser] instance.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android
  ///- iOS
  Future<void> close() => platform.close();

  ///Returns `true` if the [ChromeSafariBrowser] instance is opened, otherwise `false`.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android
  ///- iOS
  bool isOpened() => platform.isOpened();

  ///Set a custom action button.
  ///
  ///**NOTE**: Not available in a Trusted Web Activity.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android ([Official API - CustomTabsIntent.Builder.setActionButton](https://developer.android.com/reference/androidx/browser/customtabs/CustomTabsIntent.Builder#setActionButton(android.graphics.Bitmap,%20java.lang.String,%20android.app.PendingIntent,%20boolean)))
  void setActionButton(ChromeSafariBrowserActionButton actionButton) =>
      platform.setActionButton(actionButton);

  ///Updates the [ChromeSafariBrowserActionButton.icon] and [ChromeSafariBrowserActionButton.description].
  ///
  ///**NOTE**: Not available in a Trusted Web Activity.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android ([Official API - CustomTabsSession.setActionButton](https://developer.android.com/reference/androidx/browser/customtabs/CustomTabsSession#setActionButton(android.graphics.Bitmap,java.lang.String)))
  Future<void> updateActionButton(
          {required Uint8List icon, required String description}) =>
      platform.updateActionButton(icon: icon, description: description);

  ///Sets the remote views displayed in the secondary toolbar in a custom tab.
  ///
  ///**NOTE**: Not available in a Trusted Web Activity.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android ([Official API - CustomTabsIntent.Builder.setSecondaryToolbarViews](https://developer.android.com/reference/androidx/browser/customtabs/CustomTabsIntent.Builder#setSecondaryToolbarViews(android.widget.RemoteViews,int[],android.app.PendingIntent)))
  void setSecondaryToolbar(
          ChromeSafariBrowserSecondaryToolbar secondaryToolbar) =>
      platform.setSecondaryToolbar(secondaryToolbar);

  ///Sets or updates (if already present) the Remote Views of the secondary toolbar in an existing custom tab session.
  ///
  ///**NOTE**: Not available in a Trusted Web Activity.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android ([Official API - CustomTabsSession.setSecondaryToolbarViews](https://developer.android.com/reference/androidx/browser/customtabs/CustomTabsSession#setSecondaryToolbarViews(android.widget.RemoteViews,int[],android.app.PendingIntent)))
  Future<void> updateSecondaryToolbar(
          ChromeSafariBrowserSecondaryToolbar secondaryToolbar) =>
      platform.updateSecondaryToolbar(secondaryToolbar);

  ///Adds a [ChromeSafariBrowserMenuItem] to the menu.
  ///
  ///**NOTE**: Not available in an Android Trusted Web Activity.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android
  ///- iOS
  void addMenuItem(ChromeSafariBrowserMenuItem menuItem) =>
      platform.addMenuItem(menuItem);

  ///Adds a list of [ChromeSafariBrowserMenuItem] to the menu.
  ///
  ///**NOTE**: Not available in an Android Trusted Web Activity.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android
  ///- iOS
  void addMenuItems(List<ChromeSafariBrowserMenuItem> menuItems) =>
      platform.addMenuItems(menuItems);

  ///Sends a request to create a two way postMessage channel between the client
  ///and the browser.
  ///If you want to specifying the target origin to communicate with, set the [targetOrigin].
  ///
  ///[sourceOrigin] - A origin that the client is requesting to be
  ///identified as during the postMessage communication.
  ///It has to either start with http or https.
  ///
  ///[targetOrigin] - The target Origin to establish the postMessage communication with.
  ///This can be the app's package name, it has to either start with http or https.
  ///
  ///Returns whether the implementation accepted the request.
  ///Note that returning true here doesn't mean an origin has already been
  ///assigned as the validation is asynchronous.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android ([Official API - CustomTabsSession.requestPostMessageChannel](https://developer.android.com/reference/androidx/browser/customtabs/CustomTabsSession#requestPostMessageChannel(android.net.Uri,android.net.Uri,android.os.Bundle)))
  Future<bool> requestPostMessageChannel(
          {required WebUri sourceOrigin, WebUri? targetOrigin}) =>
      platform.requestPostMessageChannel(
          sourceOrigin: sourceOrigin, targetOrigin: targetOrigin);

  ///Sends a postMessage request using the origin communicated via [requestPostMessageChannel].
  ///Fails when called before [onMessageChannelReady] event.
  ///
  ///[message] – The message that is being sent.
  ///
  ///Returns an integer constant about the postMessage request result.
  ///Will return CustomTabsService.RESULT_SUCCESS if successful.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android ([Official API - CustomTabsSession.postMessage](https://developer.android.com/reference/androidx/browser/customtabs/CustomTabsSession#postMessage(java.lang.String,android.os.Bundle)))
  Future<CustomTabsPostMessageResultType> postMessage(String message) =>
      platform.postMessage(message);

  ///Returns whether the Engagement Signals API is available.
  ///The availability of the Engagement Signals API may change at runtime.
  ///If an EngagementSignalsCallback has been set, an [onSessionEnded]
  ///signal will be sent if the API becomes unavailable later.
  ///
  ///Returns whether the Engagement Signals API is available.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android ([Official API - CustomTabsSession.isEngagementSignalsApiAvailable](https://developer.android.com/reference/androidx/browser/customtabs/CustomTabsSession#isEngagementSignalsApiAvailable(android.os.Bundle)))
  Future<bool> isEngagementSignalsApiAvailable() =>
      platform.isEngagementSignalsApiAvailable();

  ///On Android, returns `true` if Chrome Custom Tabs is available.
  ///On iOS, returns `true` if SFSafariViewController is available.
  ///Otherwise returns `false`.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android
  ///- iOS
  static Future<bool> isAvailable() =>
      PlatformChromeSafariBrowser.static().isAvailable();

  ///The maximum number of allowed secondary toolbar items.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android
  static Future<int> getMaxToolbarItems() =>
      PlatformChromeSafariBrowser.static().getMaxToolbarItems();

  ///Returns the preferred package to use for Custom Tabs.
  ///The preferred package name is the default VIEW intent handler as long as it supports Custom Tabs.
  ///To modify this preferred behavior, set [ignoreDefault] to `true` and give a
  ///non empty list of package names in packages.
  ///This method queries the `PackageManager` to determine which packages support the Custom Tabs API.
  ///On apps that target Android 11 and above, this requires adding the following
  ///package visibility elements to your manifest.
  ///
  ///[packages] – Ordered list of packages to test for Custom Tabs support, in decreasing order of priority.
  ///
  ///[ignoreDefault] – If set, the default VIEW handler won't get priority over other browsers.
  ///
  ///Returns the preferred package name for handling Custom Tabs, or null.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android ([Official API - CustomTabsClient.getPackageName](https://developer.android.com/reference/androidx/browser/customtabs/CustomTabsClient#getPackageName(android.content.Context,java.util.List%3Cjava.lang.String%3E,boolean))))
  static Future<String?> getPackageName(
          {List<String>? packages, bool ignoreDefault = false}) =>
      PlatformChromeSafariBrowser.static()
          .getPackageName(packages: packages, ignoreDefault: ignoreDefault);

  ///Clear associated website data accrued from browsing activity within your app.
  ///This includes all local storage, cached resources, and cookies.
  ///
  ///**NOTE for iOS**: available on iOS 16.0+.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - SFSafariViewController.DataStore.clearWebsiteData](https://developer.apple.com/documentation/safariservices/sfsafariviewcontroller/datastore/3981117-clearwebsitedata))
  static Future<void> clearWebsiteData() =>
      PlatformChromeSafariBrowser.static().clearWebsiteData();

  ///Prewarms a connection to each URL. SFSafariViewController will automatically use a
  ///prewarmed connection if possible when loading its initial URL.
  ///
  ///Returns a token object that corresponds to the requested URLs. You must keep a strong
  ///reference to this token as long as you expect the prewarmed connections to remain open. If the same
  ///server is requested in multiple calls to this method, all of the corresponding tokens must be
  ///invalidated or released to end the prewarmed connection to that server.
  ///
  ///This method uses a best-effort approach to prewarming connections, but may delay
  ///or drop requests based on the volume of requests made by your app. Use this method when you expect
  ///to present the browser soon. Many HTTP servers time out connections after a few minutes.
  ///After a timeout, prewarming delivers less performance benefit.
  ///
  ///[URLs] - the URLs of servers that the browser should prewarm connections to.
  ///Only supports URLs with `http://` or `https://` schemes.
  ///
  ///**NOTE for iOS**: available on iOS 15.0+.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - SFSafariViewController.prewarmConnections](https://developer.apple.com/documentation/safariservices/sfsafariviewcontroller/3752133-prewarmconnections))
  static Future<PrewarmingToken?> prewarmConnections(List<WebUri> URLs) =>
      PlatformChromeSafariBrowser.static().prewarmConnections(URLs);

  ///Ends all prewarmed connections associated with the token, except for connections that are also kept alive by other tokens.
  ///
  ///**NOTE for iOS**: available on iOS 15.0+.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - SFSafariViewController.prewarmConnections](https://developer.apple.com/documentation/safariservices/sfsafariviewcontroller/3752133-prewarmconnections))
  static Future<void> invalidatePrewarmingToken(
          PrewarmingToken prewarmingToken) =>
      PlatformChromeSafariBrowser.static()
          .invalidatePrewarmingToken(prewarmingToken);

  ///Event fired when the when connecting from Android Custom Tabs Service.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android
  void onServiceConnected() {}

  ///Event fired when the [ChromeSafariBrowser] is opened.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android
  ///- iOS
  void onOpened() {}

  ///Event fired when the initial URL load is complete.
  ///
  ///[didLoadSuccessfully] - `true` if loading completed successfully; otherwise, `false`. Supported only on iOS.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android
  ///- iOS ([Official API - SFSafariViewControllerDelegate.safariViewController](https://developer.apple.com/documentation/safariservices/sfsafariviewcontrollerdelegate/1621215-safariviewcontroller))
  void onCompletedInitialLoad(bool? didLoadSuccessfully) {}

  ///Event fired when the initial URL load is complete.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - SFSafariViewControllerDelegate.safariViewController](https://developer.apple.com/documentation/safariservices/sfsafariviewcontrollerdelegate/2923545-safariviewcontroller))
  void onInitialLoadDidRedirect(WebUri? url) {}

  ///Event fired when a navigation event happens.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android ([Official API - CustomTabsCallback.onNavigationEvent](https://developer.android.com/reference/androidx/browser/customtabs/CustomTabsCallback#onNavigationEvent(int,android.os.Bundle)))
  void onNavigationEvent(CustomTabsNavigationEventType? navigationEvent) {}

  ///Event fired when a relationship validation result is available.
  ///
  ///[relation] - Relation for which the result is available. Value previously passed to [validateRelationship].
  ///
  ///[requestedOrigin] - Origin requested. Value previously passed to [validateRelationship].
  ///
  ///[result] - Whether the relation was validated.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android ([Official API - CustomTabsCallback.onRelationshipValidationResult](https://developer.android.com/reference/androidx/browser/customtabs/CustomTabsCallback#onRelationshipValidationResult(int,android.net.Uri,boolean,android.os.Bundle)))
  void onRelationshipValidationResult(
      CustomTabsRelationType? relation, WebUri? requestedOrigin, bool result) {}

  ///Event fired when the user opens the current page in the default browser by tapping the toolbar button.
  ///
  ///**NOTE for iOS**: available on iOS 14.0+.
  ///
  ///**Supported Platforms/Implementations**:
  ///- iOS ([Official API - SFSafariViewControllerDelegate.safariViewControllerWillOpenInBrowser](https://developer.apple.com/documentation/safariservices/sfsafariviewcontrollerdelegate/3650426-safariviewcontrollerwillopeninbr))
  void onWillOpenInBrowser() {}

  ///Called when the [ChromeSafariBrowser] has requested a postMessage channel through
  ///[requestPostMessageChannel] and the channel is ready for sending and receiving messages on both ends.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android ([Official API - CustomTabsCallback.onMessageChannelReady](https://developer.android.com/reference/androidx/browser/customtabs/CustomTabsCallback#onMessageChannelReady(android.os.Bundle)))
  void onMessageChannelReady() {}

  ///Called when a tab controlled by this [ChromeSafariBrowser] has sent a postMessage.
  ///If [postMessage] is called from a single thread, then the messages will be posted in the same order.
  ///When received on the client side, it is the client's responsibility to preserve the ordering further.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android ([Official API - CustomTabsCallback.onPostMessage](https://developer.android.com/reference/androidx/browser/customtabs/CustomTabsCallback#onPostMessage(java.lang.String,android.os.Bundle)))
  void onPostMessage(String message) {}

  ///Called when a user scrolls the tab.
  ///
  ///[isDirectionUp] - `false` when the user scrolls farther down the page,
  ///and `true` when the user scrolls back up toward the top of the page.
  ///
  ///**NOTE**: available only if [isEngagementSignalsApiAvailable] returns `true`.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android ([Official API - EngagementSignalsCallback.onVerticalScrollEvent](https://developer.android.com/reference/androidx/browser/customtabs/EngagementSignalsCallback#onVerticalScrollEvent(boolean,android.os.Bundle)))
  void onVerticalScrollEvent(bool isDirectionUp) {}

  ///Called when a user has reached a greater scroll percentage on the page. The greatest scroll
  ///percentage is reset if the user navigates to a different page. If the current page's total
  ///height changes, this method will be called again only if the scroll progress reaches a
  ///higher percentage based on the new and current height of the page.
  ///
  ///[scrollPercentage] - An integer indicating the percent of scrollable progress
  ///the user hasmade down the current page.
  ///
  ///**NOTE**: available only if [isEngagementSignalsApiAvailable] returns `true`.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android ([Official API - EngagementSignalsCallback.onGreatestScrollPercentageIncreased](https://developer.android.com/reference/androidx/browser/customtabs/EngagementSignalsCallback#onGreatestScrollPercentageIncreased(int,android.os.Bundle)))
  void onGreatestScrollPercentageIncreased(int scrollPercentage) {}

  ///Called when a `CustomTabsSession` is ending or when no further Engagement Signals
  ///callbacks are expected to report whether any user action has occurred during the session.
  ///
  ///[didUserInteract] - Whether the user has interacted with the page in any way, e.g. scrolling.
  ///
  ///**NOTE**: available only if [isEngagementSignalsApiAvailable] returns `true`.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android ([Official API - EngagementSignalsCallback.onSessionEnded](https://developer.android.com/reference/androidx/browser/customtabs/EngagementSignalsCallback#onSessionEnded(boolean,android.os.Bundle)))
  void onSessionEnded(bool didUserInteract) {}

  ///Event fired when the [ChromeSafariBrowser] is closed.
  ///
  ///**Supported Platforms/Implementations**:
  ///- Android
  ///- iOS
  void onClosed() {}

  ///Disposes the channel.
  @mustCallSuper
  void dispose() => platform.dispose();
}
