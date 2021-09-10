//
//  AudioPlayer.swift
//  AudioPlayer
//
//  Created by Benjamin Nakiwala on 8/2/21.
//

import AVFoundation
import MediaPlayer

class AudioPlayer: NSObject, ObservableObject {
    static let shared = AudioPlayer()
    private var player = AVAudioPlayer()
    let commandCenter = MPRemoteCommandCenter.shared()
    let infoCenter = MPNowPlayingInfoCenter.default()
    @Published var currentlyPlayingVideo: Video?
    @Published var currentlyPlayingFolder: Folder?
    @Published var duration = 0.0
    @Published var currentTime = 0.0
    var currentTimeTimer: Timer?
    var isPlaying: Bool {
        player.isPlaying
    }
    private func setupRemoteCommandCenter() {
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
        commandCenter.skipForwardCommand.preferredIntervals = [30]
        commandCenter.skipForwardCommand.addTarget { [weak self] event in
            let interval = (event as! MPSkipIntervalCommandEvent).interval
            self?.seekForward(interval)
            return .success
        }
        commandCenter.skipBackwardCommand.isEnabled = true
        commandCenter.skipBackwardCommand.preferredIntervals = [15]
        commandCenter.skipBackwardCommand.addTarget { [weak self] event in
            let interval = (event as! MPSkipIntervalCommandEvent).interval
            self?.seekBack(interval)
            return .success
        }
        commandCenter.changePlaybackPositionCommand.isEnabled = true
        commandCenter.changePlaybackPositionCommand.addTarget { [weak self] event in
            let position = (event as! MPChangePlaybackPositionCommandEvent).positionTime
            self?.play(at: position)
            return .success
        }
    }
    private override init() {
        super.init()
        setupRemoteCommandCenter()
        player.delegate = self
    }
    func play(_ video: Video? = nil) {
        guard !player.isPlaying else { return }
        if let video = video {
            try? createPlayer(with: video)
        }
        try? AVAudioSession.sharedInstance().setActive(true, options: [])
        duration = player.duration
        updateNowPlayingInfoView(elaspedTime: player.currentTime)
        player.play()
        currentTimeTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true, block: { [self] timer in
            if self.player.isPlaying {
                self.currentTime = player.currentTime
                if let currentlyPlayingVideo = currentlyPlayingVideo {
                    currentlyPlayingVideo.playbackPosition = player.currentTime
                }
            } else {
                timer.invalidate()
            }
        })
    }
    func updateNowPlayingInfoView(elaspedTime: TimeInterval?) {
        if let video = currentlyPlayingVideo {
            // setup now playing view
            var nowPlayingDict = [String: Any]()
            nowPlayingDict[MPMediaItemPropertyTitle] = video.title
            nowPlayingDict[MPMediaItemPropertyArtist] = video.channelName
            nowPlayingDict[MPMediaItemPropertyPlaybackDuration] = player.duration
            nowPlayingDict[MPNowPlayingInfoPropertyPlaybackRate] = 1
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
    
    func play() {
        player.play()
        updateNowPlayingInfoView(elaspedTime: player.currentTime)
    }
    func pause() {
        player.pause()
        updateNowPlayingInfoView(elaspedTime: player.currentTime)
    }
    /// Releases current playing item info and stops playback.
    func stop() {
        try? AVAudioSession.sharedInstance().setActive(false, options: [])
        infoCenter.nowPlayingInfo = nil
        player.stop()
    }
    /// Begins playback at specified time.
    func play(at time: TimeInterval) {
        let wasPlaying = player.isPlaying
        player.pause()
        player.currentTime = time
        self.currentTime = player.currentTime
        if wasPlaying {
            player.play()
        }
        updateNowPlayingInfoView(elaspedTime: player.currentTime)
        
    }
    /// Sets player to video
    func createPlayer(with video: Video) throws {
        video.lastOpened = Date()
        do {
            currentlyPlayingVideo = video
            player = try AVAudioPlayer(contentsOf: video.videoUrl, fileTypeHint: "mp4")
            player.currentTime = video.playbackPosition
            player.delegate = self
            if video.parentFolderId != kROOTFolder {
                currentlyPlayingFolder = Folder.folderFrom(video.parentFolderId)
            }
        } catch {
            //audioPlayerDidFinishPlaying(player, successfully: false)
            logs.insert(error, at: 0)
            print(error)
        }
        
    }
    /// Seeks forward by a given interval seconds
    func seekForward(_ interval: Double) {
        let wasPlaying = player.isPlaying
        player.pause()
        if player.duration - player.currentTime > interval {
            player.currentTime += interval
        } else {
            player.currentTime = player.duration
            updateNowPlayingInfoView(elaspedTime: player.currentTime)
            return
        }
        if wasPlaying {
            player.play()
        }
        updateNowPlayingInfoView(elaspedTime: player.currentTime)
    }
    /// Seeks back by a given interval seconds.
    func seekBack(_ interval: Double) {
        let wasPlaying = player.isPlaying
        player.pause()
        if player.currentTime > interval {
            player.currentTime -= interval
        } else {
            player.currentTime = 0
        }
        if wasPlaying {
            player.play()
        }
        updateNowPlayingInfoView(elaspedTime: player.currentTime)
    }
}

extension AudioPlayer: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        guard Settings.shared.usePlaybackQueue else { return }
        guard let video = currentlyPlayingVideo else { return }
        if let currentlyPlayingFolder = currentlyPlayingFolder {
            var videos = currentlyPlayingFolder.videos.filter {
                $0.isDownloaded
            }
            switch Settings.shared.filterMode {
            case .dateAdded:
                videos.sort {
                    $0.downloadDate > $1.downloadDate
                }
            case .datePublished:
                videos.sort {
                    $0.uploadDate > $1.uploadDate
                }
            case .off:
                break
            case .lastOpened:
                videos.sort {
                    $0.lastOpened > $1.lastOpened
                }
            case .name:
                videos.sort {
                    $0.title.lowercased() < $1.title.lowercased()
                }
            }
            // find currently playing video in folder or exit
            guard let index = videos.firstIndex(of: video) else { return }
            // index in zeroed, count isnt
            if videos.count - 1 > index {
                let video = videos[index + 1]
                guard video !== currentlyPlayingVideo else { return }
                play(video)
            }
        } else {
            // find currently playing video in folder or exit
            var videos = VideoDatabase.shared.videos.filter {
                $0.isDownloaded
            }
            switch Settings.shared.filterMode {
            case .dateAdded:
                videos.sort {
                    $0.downloadDate > $1.downloadDate
                }
            case .datePublished:
                videos.sort {
                    $0.uploadDate > $1.uploadDate
                }
            case .off:
                break
            case .lastOpened:
                videos.sort {
                    $0.lastOpened > $1.lastOpened
                }
            case .name:
                videos.sort {
                    $0.title.lowercased() < $1.title.lowercased()
                }
            }
            guard let index = videos.firstIndex(of: video) else { return }
            // index in zeroed, count isnt
            print(videos.count)
            print(index)
            if videos.count - 1 > index {
                let video = videos[index + 1]
                guard video !== currentlyPlayingVideo else { return }
                play(video)
            } else {
                self.stop()
            }
        }
    }
}
