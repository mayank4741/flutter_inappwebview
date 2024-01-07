#include "web_resource_request.h"

#include "../utils/flutter.h"

namespace flutter_inappwebview_plugin
{
    WebResourceRequest::WebResourceRequest(const std::optional<std::string>& url, const std::optional<std::string>& method,
                                       const std::optional<std::map<std::string, std::string>>& headers, const std::optional<bool>& isForMainFrame)
            : url(url), method(method), headers(headers), isForMainFrame(isForMainFrame)
    {

    }

    WebResourceRequest::WebResourceRequest(const flutter::EncodableMap& map)
            : url(get_optional_fl_map_value<std::string>(map, "url")),
              method(get_optional_fl_map_value<std::string>(map, "method")),
              headers(get_optional_fl_map_value<std::string, std::string>(map, "headers")),
              isForMainFrame(get_optional_fl_map_value<bool>(map, "isForMainFrame"))
    {

    }

    flutter::EncodableMap WebResourceRequest::toEncodableMap()
    {
        return flutter::EncodableMap{
                {make_fl_value("url"), make_fl_value(url)},
                {make_fl_value("method"), make_fl_value(method)},
                {make_fl_value("headers"), make_fl_value(headers)},
                {make_fl_value("isForMainFrame"), make_fl_value(isForMainFrame)}
        };
    }
}