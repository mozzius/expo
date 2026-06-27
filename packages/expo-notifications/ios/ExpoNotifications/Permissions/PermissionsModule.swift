//  Copyright © 2024 650 Industries. All rights reserved.

import ExpoModulesCore
import UIKit

public class PermissionsModule: Module {
  var permissionsManager: (any EXPermissionsInterface)?
  let requester = ExpoNotificationsPermissionsRequester()

  public func definition() -> ModuleDefinition {
    Name("ExpoNotificationPermissionsModule")

    OnCreate {
      appContext?.permissions?.register([
        requester
      ])
    }

    AsyncFunction("getPermissionsAsync") { (promise: Promise) in
      appContext?
        .permissions?
        .getPermissionUsingRequesterClass(
          ExpoNotificationsPermissionsRequester.self,
          resolve: promise.resolver,
          reject: promise.legacyRejecter
        )
    }

    AsyncFunction("requestPermissionsAsync") { (requestedPermissions: NotificationPermissionRecord, promise: Promise) in
      let defaultAuthorizationOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
      var options = requestedPermissions.numberOfOptionsRequested() > 0
        ? requestedPermissions.authorizationOptionValue()
        : defaultAuthorizationOptions
      // When a settings route is configured via the config plugin, always advertise the
      // in-app notification settings link so iOS shows it in the system Settings app.
      if Bundle.main.object(forInfoDictionaryKey: "EXNotificationsAppSettingsRoute") != nil {
        options.insert(.providesAppNotificationSettings)
      }
      requester.setAuthorizationOptions(options)

      // Call `requestAuthorization` directly to ensure new options are always
      // forwarded to the OS, even if notifications were previously granted.
      // iOS safely handles repeated calls to `requestAuthorization(options:)`.
      // Expo Go notifications permissions are not scoped
      let resolver: EXPromiseResolveBlock = { result in
        if let permission = result as? [AnyHashable: Any] {
          promise.resolver(EXPermissionsService.parsePermission(fromRequester: permission))
        } else {
          promise.legacyRejecter("ERR_PERMISSIONS_REQUEST_NOTIFICATIONS", "Unexpected permission result type", nil)
        }
      }
      requester.requestAuthorizationOptions(options, resolver: resolver, rejecter: promise.legacyRejecter)
    }
  }
}
