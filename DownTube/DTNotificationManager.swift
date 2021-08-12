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
        unCenter.requestAuthorization(options: [.provisional, .sound]) { [self] granted, error in
            guard error == nil else { return }
            allowed = granted
        }
    }
    func sendNotification(title: String, message: String, thumbnailImage: URL) {
        let notif = UNMutableNotificationContent()
        notif.body = message
        notif.title = title
        notif.sound = UNNotificationSound.default
        if let attachment = try? UNNotificationAttachment(identifier: "thumbnail", url: thumbnailImage, options: nil) {
            notif.attachments = [attachment]
        }
        
        let request = UNNotificationRequest(identifier: "DownloadNotif", content: notif, trigger: nil)
        unCenter.add(request, withCompletionHandler: nil)
    }
}
