//
//  DTVideoPlayer.swift
//  DTVideoPlayer
//
//  Created by Benjamin Nakiwala on 8/4/21.
//

import SwiftUI
import AVKit

struct DTVideoPlayer: UIViewControllerRepresentable {
    init(video: Video? = nil) {
        self.video = video
    }
    private let videoVC = AVPlayerViewController()
    private var video: Video?
    dynamic var isPlaying = false
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        
        videoVC.allowsPictureInPicturePlayback = true
        videoVC.entersFullScreenWhenPlaybackBegins = true
        videoVC.exitsFullScreenWhenPlaybackEnds = true
        videoVC.showsPlaybackControls = true
        videoVC.player = video!.avPlayer
        return videoVC
    }
    @discardableResult func play() -> Self {
        videoVC.player?.play()
        return self
    }
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        if context.environment.isPresented == false {
            uiViewController.player?.pause()
        }
        if videoVC.player?.rate == 0 && Settings.shared.shouldAutoplay && context.environment.isPresented {
            self.play()
        }
    }
    
    typealias UIViewControllerType = AVPlayerViewController
    
    
}
