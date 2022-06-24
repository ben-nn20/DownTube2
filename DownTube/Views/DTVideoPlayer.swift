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
    private var playTimer: Timer?
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        
        videoVC.allowsPictureInPicturePlayback = true
        videoVC.entersFullScreenWhenPlaybackBegins = true
        videoVC.exitsFullScreenWhenPlaybackEnds = true
        videoVC.showsPlaybackControls = true
        videoVC.player = video!.avPlayer
        if Settings.shared.shouldAutoplay {
            playTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [self] _ in
                if video?.avPlayer.rate == 0 {
                    play()
                }
            }
        }
        if AudioPlayer.shared.isPlaying {
            AudioPlayer.shared.pause()
        }
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
