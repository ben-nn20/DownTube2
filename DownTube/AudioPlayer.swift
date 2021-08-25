//
//  AudioPlayer.swift
//  AudioPlayer
//
//  Created by Benjamin Nakiwala on 8/2/21.
//

import AVFoundation
import MediaPlayer

class AudioPlayer: ObservableObject {
    static let shared = AudioPlayer()
    private var player = AVAudioPlayer()
    let commandCenter = MPRemoteCommandCenter.shared()
    let infoCenter = MPNowPlayingInfoCenter.default()
    @Published var currentlyPlayingVideo: Video?
    @Published var currentlyPlayingFolder: Folder?
    @Published var duration = 0.0
    @Published var currentTime = 0.0
    
    var currentTimeTimer: Timer?
    private init() {
        commandCenter.playCommand.isEnabled = true
        commandCenter.playCommand.addTarget { [weak self] event in
            self?.play()
            return .success
        }
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.pauseCommand.addTarget { [weak self] event in
            self?.pause()
            return .success
        }
        commandCenter.stopCommand.isEnabled = true
        commandCenter.stopCommand.addTarget { [weak self] event in
            self?.stop()
            return .success
        }
        commandCenter.skipForwardCommand.isEnabled = true
        commandCenter.skipForwardCommand.addTarget { [weak self] event in
            let interval = (event as! MPSkipIntervalCommandEvent).interval
            self?.seekForward(interval)
            return .success
        }
        commandCenter.skipBackwardCommand.isEnabled = true
        commandCenter.skipBackwardCommand.addTarget { [weak self] event in
            let interval = (event as! MPSkipIntervalCommandEvent).interval
            self?.seekBack(interval)
            return .success
        }
        commandCenter.changePlaybackPositionCommand.isEnabled = true
        commandCenter.changePlaybackPositionCommand.addTarget { [weak self] event in
            let position = (event as! MPChangePlaybackPositionCommandEvent).positionTime
            self?.player.play(atTime: position)
            return .success
        }
    }
    func play(_ video: Video? = nil) {
        guard !player.isPlaying else { return }
        if let video = video {
            try? createPlayer(with: video)
        }
        try? AVAudioSession.sharedInstance().setActive(true, options: [])
        duration = player.duration
        updateNowPlayingInfoView(elaspedTime: nil)
        player.play()
        currentTimeTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [self] timer in
            if self.player.isPlaying {
                self.updateNowPlayingInfoView(elaspedTime: player.currentTime)
                self.currentTime = player.currentTime
                if let currentlyPlayingVideo = currentlyPlayingVideo {
                    currentlyPlayingVideo.playbackPosition = player.currentTime
                }
            } else {
                timer.invalidate()
            }
        })
    }
    func pause() {
        player.pause()
    }
    /// Releases current playing item info and stops playback.
    func stop() {
        try? AVAudioSession.sharedInstance().setActive(false, options: [])
        infoCenter.nowPlayingInfo = nil
        player.stop()
    }
    func updateNowPlayingInfoView(elaspedTime: TimeInterval?) {
        if let video = currentlyPlayingVideo {
            // setup now playing view
            var nowPlayingDict = [String: Any]()
            nowPlayingDict[MPMediaItemPropertyTitle] = video.title
            nowPlayingDict[MPMediaItemPropertyArtist] = video.channelName
            nowPlayingDict[MPMediaItemPropertyPlaybackDuration] = player.duration
            nowPlayingDict[MPNowPlayingInfoPropertyPlaybackRate] = 0
            if let elaspedTime = elaspedTime {
                nowPlayingDict[MPNowPlayingInfoPropertyElapsedPlaybackTime] = elaspedTime
            } else {
                nowPlayingDict[MPNowPlayingInfoPropertyElapsedPlaybackTime] = 0
            }
            if let data = video.imageData {
                let image = UIImage(data: data)!
                nowPlayingDict[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: image.size, requestHandler: { _ in
                    image
                })
            }
            infoCenter.nowPlayingInfo = nowPlayingDict
        }
    }
    
    /// Begins playback at specified time.
    func play(at time: CMTime) {
        player.play(atTime: time.seconds)
    }
    /// Sets player to video
    func createPlayer(with video: Video) throws {
        video.lastOpened = Date()
        do {
            player = try AVAudioPlayer(contentsOf: video.videoUrl, fileTypeHint: "mp4")
            currentlyPlayingVideo = video
        } catch {
            logs.insert(error, at: 0)
            print(error)
        }
        
    }
    /// Seeks forward by a given interval seconds
    func seekForward(_ interval: Double) {
        player.pause()
        if player.duration - player.currentTime > interval {
            print(player.play(atTime: player.currentTime + interval))
        } else {
            print(player.play(atTime: player.duration))
        }
        player.play()
    }
    /// Seeks back by a given interval seconds.
    func seekBack(_ interval: Double) {
        if player.currentTime > interval {
            print(player.play(atTime: player.currentTime - interval))
        } else {
            print(player.play(atTime: 0))
        }
    }
}

