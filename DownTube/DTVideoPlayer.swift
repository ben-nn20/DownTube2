//
//  DTVideoPlayer.swift
//  DTVideoPlayer
//
//  Created by Benjamin Nakiwala on 8/4/21.
//

import SwiftUI
import AVKit

final class DTVideoPlayer: UIViewControllerRepresentable {
    init(video: Video? = nil) {
        self.video = video
    }
    private var video: Video?
    var beginPlayback: Bool {
        Settings.shared.shouldAutoplay
    }
    static var shared = DTVideoPlayer()
    func setVideo(_ video: Video) -> Self {
        self.video = video
        return self
    }
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let avPlayerVC = AVPlayerViewController()
        avPlayerVC.allowsPictureInPicturePlayback = true
        avPlayerVC.entersFullScreenWhenPlaybackBegins = true
        avPlayerVC.exitsFullScreenWhenPlaybackEnds = true
        avPlayerVC.showsPlaybackControls = true
        avPlayerVC.player = video!.avPlayer
        if beginPlayback {
            avPlayerVC.player?.play()
        }
        return avPlayerVC
    }
    func stop() {
        
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        if context.environment.isPresented == false {
            uiViewController.player?.pause()
        }
    }
    
    typealias UIViewControllerType = AVPlayerViewController
    
    
}
