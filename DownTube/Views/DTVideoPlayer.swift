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
    private let videoVC = AVPlayerViewController()
    private var video: Video?
    dynamic var isPlaying = false
    func setVideo(_ video: Video) -> Self {
        self.video = video
        return self
    }
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        
        videoVC.allowsPictureInPicturePlayback = true
        videoVC.entersFullScreenWhenPlaybackBegins = true
        videoVC.exitsFullScreenWhenPlaybackEnds = true
        videoVC.showsPlaybackControls = true
        videoVC.player = video!.avPlayer
        if Settings.shared.shouldAutoplay {
            self.play()
        }
        return videoVC
    }
    @discardableResult func play() -> Self {
        if let video = video {
            video.avPlayer.play()
        }
        return self
    }
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        if context.environment.isPresented == false {
            uiViewController.player?.pause()
        }
    }
    
    typealias UIViewControllerType = AVPlayerViewController
    
    
}
