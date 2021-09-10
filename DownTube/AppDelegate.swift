//
//  AppDelegate.swift
//  DownTube
//
//  Created by Benjamin Nakiwala on 6/4/21.
//

import SwiftUI
import AVFoundation
import CoreSpotlight

@main class AppDelegate: NSObject, UIApplicationDelegate {
    let window: UIWindow? = UIWindow()
    let indexer = VideoIndexDelegate()
    override init() {
        super.init()
        CSSearchableIndex.default().indexDelegate = indexer
        UNUserNotificationCenter.current().delegate = self
    }
    func applicationDidFinishLaunching(_ application: UIApplication) {
        let hostingVC = UIHostingController(rootView: ContentView())
        window?.rootViewController = hostingVC
        window?.makeKeyAndVisible()
        DTNotificationManager.shared.requestAuthorization()
        try! AVAudioSession.sharedInstance().setCategory(.playback)
    }
    func applicationDidEnterBackground(_ application: UIApplication) {
        VideoDatabase.saveVideos()
        Settings.saveSettings()
        indexer.index {}
    }
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        guard let identifier = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String, userActivity.activityType == CSSearchableItemActionType else { return false }
        let videos = VideoDatabase.shared.allVideos
        let video = videos.first {
            $0.videoId == identifier
        }
        if let video = video {
            MainViewUpdator.shared.showVideo = video
            return true
        }
        return false
    }
    func applicationWillTerminate(_ application: UIApplication) {
        if DTDownloadManager.shared.hasDownloads {
            DTNotificationManager.shared.sendNotification(title: "Background Downloads Paused", message: "Downtube has been terminated by the system. Downloads will resume when Downtube is launched.", thumbnailImage: nil)
        }
    }
    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        DTDownloadManager.shared.urlSessionCallback = completionHandler
    }
    func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
        print("Memory Warning")
    }
}


extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler( window!.isHidden ? [.list, .banner, .sound] : [.banner])
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let id = response.notification.request.identifier
        if id != "notif" {
            let videos = VideoDatabase.shared.allVideos
            let video = videos.first {
                $0.videoId == id
            }
            if let video = video {
                MainViewUpdator.shared.showVideo = video
                completionHandler()
            }
        }
    }
}
