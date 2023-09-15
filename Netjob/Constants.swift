//
//  Constants.swift
//  Netjob
//
//  Created by Qutaibah Essa on 01/10/2020.
//  Copyright © 2020 MRSOOL. All rights reserved.
//

import Foundation

/* TODO:
 Error handling should not be in Netjob, it's not it's responsibility. doing this here will cause confusion in the future.
 In order to fix this, all status codes errors, should have a proper NetjobError equivilant, and client can pass all errors into a handler to make some validations. in our case, the client is MrsoolSDK and the flow should be something like:
    1. Netjob will return a NetjobError for any error with proper description
    2. SDK will pass those errors into a handler to validate them and do proper actions before returning them to its client (main app)
    3. In case of `401`, the SDK will broadcast a notification or call a listener for that exact error, and send a none alertable error to the client
    4. the main app, will check if the error requires an alert or any kind of user notifing methods, or it will do nothing.
    5. the error listener should take care of taking actions for the errors passed to it
 */
public struct NetjobConstants {
    public struct Notifications {
        public static let unauthorized = Notification.Name("NotificationKey401ERROR")
        public static let prohibited = Notification.Name("NotificationKey403ERROR")
        public static let triggerManualService = Notification.Name("NotificationKeyTriggerServiceManual")
    }
}
