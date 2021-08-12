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
        let hostingVC = UIHostingController(rootView: ContentView()
                                                .environmentObject(videoDatabase))
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
}


