//
//  AudioPlayer.swift
//  AudioPlayer
//
//  Created by Benjamin Nakiwala on 8/2/21.
//

import AVFoundation
import MediaPlayer
import Combine

class AudioPlayer: ObservableObject {
    static var shared = AudioPlayer()
    var player = AVAudioPlayer()
    var commandCenter = MPRemoteCommandCenter.shared()
    var infoCenter = MPNowPlayingInfoCenter.default()
    @Published var currentlyPlayingVideo: Video?
    @Published var currentlyPlayingFolder: Folder?
    @Published var duration = 0.0
    @Published var currentTime = 0.0
    
    var currentTimeCancellable: AnyCancellable?
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
            self?.play(at: CMTime(seconds: position, preferredTimescale: 1))
            return .success
        }
    }
    func play(_ video: Video? = nil) {
        
        if let video = video {
            try? createPlayer(with: video)
        }
        let success: ()? = try? AVAudioSession.sharedInstance().setActive(true, options: [])
        if success != nil {
            player.prepareToPlay()
            player.play()
            updateNowPlayingInfoView(elaspedTime: nil)
            currentTimeCancellable = player.publisher(for: \.currentTime).sink { [weak self] in
                self?.updateNowPlayingInfoView(elaspedTime: $0)
            }
        }
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
        Task.init {
            guard let data = await video.getAudio() else {
                print("Failed to get audio data")
                throw NSError(domain: "Unable to get audio.", code: 0, userInfo: nil)
            }
            do {
                player = try AVAudioPlayer(data: data)
                currentlyPlayingVideo = video
            } catch {
                logs.insert(error, at: 0)
                print(error)
            }
        }
    }
    /// Seeks forward by fifteen seconds
    func seekForward(_ interval: Double) {
        // If remaining time is greater than 15 seconds skip ahead else skip to the end.
        if player.duration - player.currentTime > interval {
            player.play(atTime: player.currentTime + interval)
        } else {
            player.play(atTime: player.duration)
        }
    }
    /// Seeks back by fifteen seconds.
    func seekBack(_ interval: Double) {
        // If current time is greater that 15 seconds skip back else play at the beginning.
        if player.currentTime > interval {
            player.play(atTime: player.currentTime - interval)
        } else {
            player.play(atTime: 0)
        }
    }
}

