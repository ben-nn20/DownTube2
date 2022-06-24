//
//  NotificationManager.swift
//  DownTube
//
//  Created by Benjamin Nakiwala on 7/5/21.
//

import UserNotifications

class DTNotificationManager {
    private let unCenter = UNUserNotificationCenter.current()
    var allowed = false
    static var shared = DTNotificationManager()
    func requestAuthorization() {
        unCenter.requestAuthorization(options: [.provisional, .sound, .badge, .alert]) { [self] granted, error in
            guard error == nil else { return }
            allowed = granted
        }
    }
    func sendNotification(title: String, message: String, identifier: String = "notif", thumbnailImage: URL?) {
        let notif = UNMutableNotificationContent()
        notif.body = message
        notif.title = title
        notif.sound = UNNotificationSound.default
        if let thumbnailImage = thumbnailImage, let imageAttachment = try? UNNotificationAttachment(identifier: "thumbnail", url: thumbnailImage, options: nil) {
            notif.attachments = [imageAttachment]
        }
        
        let request = UNNotificationRequest(identifier: identifier, content: notif, trigger: nil)
        unCenter.add(request) {
            error in
            if let error = error {
                Logs.addError(error)
            }
        }
    }
}
