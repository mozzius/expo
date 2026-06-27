//  Copyright © 2024 650 Industries. All rights reserved.

import ExpoModulesCore
import UIKit
import UserNotifications

let appNotificationSettingsRouteInfoPlistKey = "EXNotificationsAppSettingsRoute"

/**
 Handles the `openSettingsFor` notification center callback, which fires when the user
 taps the in-app "Notification Settings" link that iOS shows for the app in the system
 Settings app. When a `settingsRoute` is configured via the config plugin, this deep links
 to that route using the app's URL scheme.
 */
public class AppNotificationSettingsModule: Module, NotificationDelegate {
  public func definition() -> ModuleDefinition {
    Name("ExpoNotificationsAppSettings")

    OnCreate {
      NotificationCenterManager.shared.addDelegate(self)
    }

    OnDestroy {
      NotificationCenterManager.shared.removeDelegate(self)
    }
  }

  public func openSettings(_ notification: UNNotification?) {
    guard let route = Bundle.main.object(forInfoDictionaryKey: appNotificationSettingsRouteInfoPlistKey) as? String,
      !route.isEmpty,
      let url = AppNotificationSettingsModule.deepLinkURL(forRoute: route) else {
      return
    }
    DispatchQueue.main.async {
      UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
  }

  /**
   Builds a deep link URL for the configured route. If the route is already a full URL
   (i.e. it contains a scheme), it is used as-is. Otherwise the app's first custom URL
   scheme is used to construct `<scheme>://<route>`. Returns `nil` if no scheme is available.
   */
  static func deepLinkURL(forRoute route: String) -> URL? {
    if let url = URL(string: route), url.scheme != nil {
      return url
    }
    guard let scheme = firstCustomURLScheme() else {
      return nil
    }
    let path = route.hasPrefix("/") ? String(route.dropFirst()) : route
    return URL(string: "\(scheme)://\(path)")
  }

  private static func firstCustomURLScheme() -> String? {
    guard let urlTypes = Bundle.main.object(forInfoDictionaryKey: "CFBundleURLTypes") as? [[String: Any]] else {
      return nil
    }
    for urlType in urlTypes {
      if let schemes = urlType["CFBundleURLSchemes"] as? [String], let scheme = schemes.first {
        return scheme
      }
    }
    return nil
  }
}
