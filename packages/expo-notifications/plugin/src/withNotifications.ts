import { ConfigPlugin, createRunOncePlugin } from 'expo/config-plugins';

import { withNotificationsAndroid } from './withNotificationsAndroid';
import { withNotificationsIOS } from './withNotificationsIOS';

const pkg = require('expo-notifications/package.json');

export type NotificationsPluginProps = {
  /**
   * Local path to an image to use as the icon for push notifications.
   * 96x96 all-white png with transparency. We recommend following
   * [Google's design guidelines](https://material.io/design/iconography/product-icons.html#design-principles).
   * @platform android
   */
  icon?: string;
  /**
   * Tint color for the push notification image when it appears in the notification tray.
   * @default '#ffffff'
   * @platform android
   */
  color?: string;
  /**
   * Default channel for FCMv1 notifications.
   * @platform android
   */
  defaultChannel?: string;
  /**
   * Array of local paths to sound files (.wav recommended) that can be used as custom notification sounds.
   */
  sounds?: string[];
  /**
   * Environment of the app: either 'development' or 'production'.
   * @default 'development'
   * @platform ios
   */
  mode?: 'development' | 'production';

  /**
   * Whether to enable background remote notifications, as described in [Apple documentation](https://developer.apple.com/documentation/usernotifications/pushing-background-updates-to-your-app).
   *
   * This sets the `UIBackgroundModes` key in the `Info.plist` to include `remote-notification`.
   * @default false
   * @platform ios
   */
  enableBackgroundRemoteNotifications?: boolean;
  /**
   * A route to deep link to when the user taps the in-app "Notification Settings" link that
   * iOS shows for your app in the system Settings app. Setting this enables iOS
   * `providesAppNotificationSettings`, so the link is displayed after the user is asked for
   * notification permissions.
   *
   * The route is opened as a deep link using your app's URL scheme, so a `scheme` must be set
   * in your app config for this to work.
   * @platform ios
   */
  settingsRoute?: string;
};

const withNotifications: ConfigPlugin<NotificationsPluginProps | void> = (config, props) => {
  config = withNotificationsAndroid(config, props || {});
  config = withNotificationsIOS(config, props || {});
  return config;
};

export default createRunOncePlugin(withNotifications, pkg.name, pkg.version);
