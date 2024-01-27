#include <DispatcherQueue.h>
#include <flutter/method_channel.h>
#include <flutter/standard_method_codec.h>

#include "../in_app_webview/in_app_webview_settings.h"
#include "../utils/flutter.h"
#include "../utils/log.h"
#include "../utils/string.h"
#include "../utils/vector.h"
#include "webview_environment_manager.h"

namespace flutter_inappwebview_plugin
{
  WebViewEnvironmentManager::WebViewEnvironmentManager(const FlutterInappwebviewWindowsPlugin* plugin)
    : plugin(plugin),
    ChannelDelegate(plugin->registrar->messenger(), WebViewEnvironmentManager::METHOD_CHANNEL_NAME)
  {
    windowClass_.lpszClassName = WebViewEnvironmentManager::CLASS_NAME;
    windowClass_.lpfnWndProc = &DefWindowProc;

    RegisterClass(&windowClass_);

    hwnd_ = CreateWindowEx(0, windowClass_.lpszClassName, L"", 0, 0,
      0, 0, 0,
      plugin->registrar->GetView()->GetNativeWindow(),
      nullptr,
      windowClass_.hInstance, nullptr);
  }

  void WebViewEnvironmentManager::HandleMethodCall(const flutter::MethodCall<flutter::EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result)
  {
    auto* arguments = std::get_if<flutter::EncodableMap>(method_call.arguments());
    auto& methodName = method_call.method_name();

    if (string_equals(methodName, "create")) {
      auto id = get_fl_map_value<std::string>(*arguments, "id");
      auto settingsMap = get_optional_fl_map_value<flutter::EncodableMap>(*arguments, "settings");
      auto settings = settingsMap.has_value() ? std::make_unique<WebViewEnvironmentSettings>(settingsMap.value()) : nullptr;
      createWebViewEnvironment(id, std::move(settings), std::move(result));
    }
    else {
      result->NotImplemented();
    }
  }

  void WebViewEnvironmentManager::createWebViewEnvironment(const std::string& id, std::unique_ptr<WebViewEnvironmentSettings> settings, std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result)
  {
    auto result_ = std::shared_ptr<flutter::MethodResult<flutter::EncodableValue>>(std::move(result));

    auto webViewEnvironment = std::make_unique<WebViewEnvironment>(plugin, id);
    webViewEnvironment->create(std::move(settings),
      [this, id, result_](HRESULT errorCode)
      {
        if (succeededOrLog(errorCode)) {
          result_->Success(true);
        }
        else {
          result_->Error("0", "Cannot create WebViewEnvironment: " + getHRMessage(errorCode));
          if (map_contains(webViewEnvironments, id)) {
            webViewEnvironments.erase(id);
          }
        }
      });
    webViewEnvironments.insert({ id, std::move(webViewEnvironment) });
  }

  void WebViewEnvironmentManager::createOrGetDefaultWebViewEnvironment(const std::function<void(WebViewEnvironment*)> completionHandler)
  {
    if (defaultEnvironment_) {
      if (completionHandler) {
        completionHandler(defaultEnvironment_.get());
      }
      return;
    }

    defaultEnvironment_ = std::make_unique<WebViewEnvironment>(plugin, "-1");
    defaultEnvironment_->create(nullptr, [this, completionHandler](HRESULT errorCode)
      {
        if (succeededOrLog(errorCode)) {
          if (completionHandler) {
            completionHandler(defaultEnvironment_.get());
          }
        }
        else if (completionHandler) {
          defaultEnvironment_ = nullptr;
          completionHandler(nullptr);
        }
      });
  }

  WebViewEnvironmentManager::~WebViewEnvironmentManager()
  {
    debugLog("dealloc WebViewEnvironmentManager");
    webViewEnvironments.clear();
    plugin = nullptr;
    defaultEnvironment_ = nullptr;
    if (hwnd_) {
      DestroyWindow(hwnd_);
    }
  }
}