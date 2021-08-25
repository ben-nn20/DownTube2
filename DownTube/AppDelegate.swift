//
//  AppDelegate.swift
//  DownTube
//
//  Created by Benjamin Nakiwala on 6/4/21.
//

import SwiftUI
import AVFoundation

@main class AppDelegate: NSObject, UIApplicationDelegate {
    let window: UIWindow? = UIWindow()
    func applicationDidFinishLaunching(_ application: UIApplication) {
        let hostingVC = UIHostingController(rootView: ContentView())
        window?.rootViewController = hostingVC
        window?.makeKeyAndVisible()
        DTNotificationManager.shared.requestAuthorization()
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0])
        try! AVAudioSession.sharedInstance().setCategory(.playback)
    }
    func applicationDidEnterBackground(_ application: UIApplication) {
        VideoDatabase.saveVideos()
        Settings.saveSettings()
    }
    func applicationWillTerminate(_ application: UIApplication) {
        if !DTDownloadManager.shared.hasDownloads {
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


