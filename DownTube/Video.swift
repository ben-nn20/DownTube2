//
//  Video.swift
//  DownTube
//
//  Created by Benjamin Nakiwala on 6/7/21.
//

import Foundation
import AVFoundation
import Combine
import UIKit

class Video: ObservableObject, Codable, Hashable, Equatable, Identifiable {
    @Published var title: String
    @Published var channelName: String
    @Published var channelID: String
    @Published var uploadDate: Date
    @Published var duration: Int?
    @Published var videoId: String
    @Published var thumbnailIsDownloaded = false
    @Published var isDownloaded = false
    @Published var description: String
    @Published var playbackPosition = 0.0
    var playbackPositionTimer: Timer?
    var playbackPositionCancellable: Any?
    typealias ID = String
    var downloadProgress = Progress()
    let downloadDate = Date()
    @Published var downloadStatus: DownloadStatus = .waiting
    static let example = Video()
    // Computed Proprieties
    var id: String {
        videoId
    }
    private var blankPlayer = AVPlayer()
    private lazy var videoPlayer = AVPlayer(url: videoUrl)
    var avPlayer: AVPlayer {
        if downloadStatus == .downloaded {
            return videoPlayer
        } else {
            return blankPlayer
        }
    }
    var asceptRatio: Double? {
        if thumbnailIsDownloaded {
            let image = UIImage(data: try!Data(contentsOf: thumbnailUrl))!
            return image.size.width / image.size.height
        }
        return nil
    }
    var imageData: Data? {
        try? Data(contentsOf: thumbnailUrl)
    }
    var videoSize: String {
        do {
            let handle = try FileHandle(forReadingFrom: videoUrl)
            let byteCount = Float(handle.availableData.count)
            if byteCount / 1000 > 1 && byteCount / 1000 < 1000 {
                // kilobyte range
                let kSize = round(byteCount * 10) / 100
                let kStr = String(kSize)
                return "\(kStr) KB"
            } else if byteCount / 1_000_000 > 1 && byteCount / 1_000_000 < 1000 {
                // megabyte range
                let mSize = round(byteCount / 10_000) / 100
                let mStr = String(mSize)
                return "\(mStr) MB"
            } else if byteCount / 1_000_000_000 > 1 {
                // gigabyte range
                let gSize = round(byteCount / 10_000_000) / 100
                let gStr = String(gSize)
                return "\(gStr) GB"
            } else {
                return "\(String(byteCount)) Bytes"
            }
        } catch {
            logs.insert(error, at: 0)
            return ""
        }
        
    }
    var timeStamp: String {
        guard let duration = duration else {
            return ""
        }
        let mins = duration / 60
        let hours = mins / 60
        let secs = -(mins * 60) + duration
        var str = String()
        if hours == 0 {
            if secs < 10 {
                str = "\(mins):0\(secs)"
            } else  {
                str = "\(mins):\(secs)"
            }
        } else {
            if mins < 10 && secs >= 10 {
                str = "\(hours):0\(mins):\(secs)"
            } else if mins < 10 && secs < 10 {
                str = "\(hours):0\(mins):0\(secs)"
            } else if mins >= 10 && secs >= 10 {
                str = "\(hours):\(mins):\(secs)"
            } else if mins >= 10 && secs < 10 {
                str = "\(hours):\(mins):0\(secs)"
            }
        }
        return str
    }
    
    // MARK: URLS
    /// URL of  video
    var videoUrl: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(id + ".mp4")
    }
    /// URL of the thumbnail
    var thumbnailUrl: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(id + "thumbnail" + ".jpg")
    }
    // MARK: URL Checking
    var hasVideo: Bool {
        FileManager.default.fileExists(atPath: videoUrl.absoluteString)
    }
    // MARK: Functions
    static func == (lhs: Video, rhs: Video) -> Bool {
        lhs.id == rhs.id
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
        hasher.combine(channelName)
        hasher.combine(channelID)
        hasher.combine(uploadDate)
        hasher.combine(id)
    }
    func delete() {
            try? FileManager.default.removeItem(at: videoUrl)
            try? FileManager.default.removeItem(at: thumbnailUrl)
        videoDatabase.videoFolders.removeAll {
            $0.video === self
        }
    }
    
    func reDownload() {
        delete()
        Video.video(fromVideoId: id)
        videoDatabase.videoFolders.removeAll {
            $0 === self
        }
    }
    func getAudio() async -> Data? {
        if isDownloaded {
            let videoAssest = AVAsset(url: videoUrl)
            let composition = AVMutableComposition()
            let audioTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: 0)
            try? audioTrack?.insertTimeRange(CMTimeRange(start: .zero, duration: videoAssest.duration), of: videoAssest.tracks(withMediaType: .audio)[0], at: .zero)
            let exporter = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetAppleM4A)!
            let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("\(id)audio.m4a")
            exporter.outputURL = url
            exporter.outputFileType = .m4a
            await exporter.export()
            if let error = exporter.error {
                print("AVExporter Error")
                print(error as NSError)
            }
            let data = try? Data(contentsOf: url)
            try? FileManager.default.removeItem(at: url)
            return data
        }
        return nil
    }
    func videoFinishedDownloading(_ video: URL) {
        isDownloaded = true
        downloadStatus = .downloaded
        logs.insert(NSError(domain: "Video Finished Downloading for \(title).", code: 0, userInfo: nil), at: 0)
        do {
            try FileManager.default.moveItem(at: video, to: videoUrl)
        } catch {
            logs.insert(error, at: 0)
            print(error)
        }
        duration = Int(AVAsset(url: videoUrl).duration.seconds)
        DTNotificationManager.shared.sendNotification(title: "Finished Downloading", message: "\"\(title)\" finished downloading.", thumbnailImage: thumbnailUrl)
    }
    func downloadDidFailWith(error: Error) {
        logs.insert(error, at: 0)
    }
    enum CodingKeys: String, CodingKey {
        case title
        case channelName
        case channelID
        case uploadDate
        case duration
        case downloadStatus
        case videoId
        case thumbnailIsDownloaded
        case isDownloaded
        case description
        case playbackPosition
    }
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(title, forKey: .title)
        try container.encode(channelName, forKey: .channelName)
        try container.encode(channelID, forKey: .channelID)
        try container.encode(uploadDate, forKey: .uploadDate)
        try container.encode(duration, forKey: .duration)
        try container.encode(downloadStatus, forKey: .downloadStatus)
        try container.encode(thumbnailIsDownloaded, forKey: .thumbnailIsDownloaded)
        try container.encode(isDownloaded, forKey: .isDownloaded)
        try container.encode(description, forKey: .description)
        try container.encode(videoId, forKey: .videoId)
        try container.encode(playbackPosition, forKey: .playbackPosition)
    }
    // MARK: Initializers
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        title = try values.decode(String.self, forKey: .title)
        channelName = try values.decode(String.self, forKey: .channelName)
        channelID = try values.decode(String.self, forKey: .channelID)
        uploadDate = try values.decode(Date.self, forKey: .uploadDate)
        duration = try values.decode(Int?.self, forKey: .duration)
        downloadStatus = try values.decode(DownloadStatus.self, forKey: .downloadStatus)
        videoId = try values.decode(String.self, forKey: .videoId)
        thumbnailIsDownloaded = try values.decode(Bool.self, forKey: .thumbnailIsDownloaded)
        description = try values.decode(String.self, forKey: .description)
        playbackPosition = try values.decode(Double.self, forKey: .playbackPosition)
        isDownloaded = try values.decode(Bool.self, forKey: .isDownloaded)
        if !isDownloaded {
            reDownload()
        }
        if imageData == nil {
            var thumbReq = URLRequest(url: URL(string: "https://i.ytimg.com/vi/\(videoId)/sddefault.jpg")!)
            thumbReq.allowsCellularAccess = Settings.shared.useCellularData
            URLSession.shared.dataTask(with: thumbReq) { [self] (data, response, error) in
                guard error == nil else { return }
                try? data!.write(to: thumbnailUrl)
                DispatchQueue.main.async {
                    thumbnailIsDownloaded = true
                }
            }.resume()
        }
    }
    static func video(fromVideoId: String) {
        var youtubeFormatter = YoutubeAPIParser(fromVideoId)
        youtubeFormatter.format { (videoInfo) in
            DispatchQueue.main.async {
                guard let youtubeInfo = videoInfo else { return }
                let video = Video(youtubeInfo: youtubeInfo)
                guard let unwrappedVideo = video else {
                    logs.insert(NSError(domain: "Video init failed", code: 0, userInfo: nil), at: 0)
                    return
                }
                videoDatabase.videoFolders.insert(VideoFolder(video: unwrappedVideo, folder: nil), at: 0)
            }
        }
    }
    private init() {
        self.title = "Title"
        self.channelName = "Channel Name"
        self.channelID = "234567"
        self.uploadDate = Date()
        self.videoId = ""
        duration = Int.random(in: 50 ... 5000)
        downloadStatus = .downloading
        description = "Sample Description"
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [self] timer in
            downloadProgress.completedUnitCount += 1
            downloadProgress.totalUnitCount = 100
            if downloadProgress.totalUnitCount == downloadProgress.completedUnitCount {
                timer.invalidate()
            }
        }
    }
    private init?(youtubeInfo: VideoInfo) {
        self.videoId = youtubeInfo.videoDetails!.videoId!
        let videoDetails = youtubeInfo.videoDetails
        self.title = videoDetails!.title!.replacingOccurrences(of: "+", with: " ")
        self.channelName = videoDetails!.author!.replacingOccurrences(of: "+", with: " ")
        self.channelID = videoDetails!.channelId!
        self.description = videoDetails!.shortDescription!
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        guard let date = dateFormatter.date(from: youtubeInfo.microformat?.playerMicroformatRenderer!.publishDate! ?? "\(dateFormatter.string(from: Date()))") else {
            return nil
        }
        self.uploadDate = date
        guard let formats = youtubeInfo.streamingData!.formats else {
            return nil
        }
        var videoFormat: VideoInfo.StreamingData.Format?
        switch Settings.shared.preferredVideoQuality {
        case .medium:
            videoFormat = formats.first {
                $0.itag! == 22
            }
            
        case .low:
            videoFormat = formats.first {
                $0.itag == 18
            }
        }
        if videoFormat == nil {
            // try low
            videoFormat = formats.first {
                $0.itag == 18
            }
        }
        // if nil exit
        if videoFormat == nil {
            logs.insert(NSError(domain: "Video not found. Failed in Video initializer. file: Video.swift, line: 167", code: 1, userInfo: nil), at: 0)
            return nil
        }
        let videoUrl: URL
        if let url = videoFormat!.url {
            videoUrl = URL(string: url)!
        } else {
            var sig = videoFormat!.signatureCipher!
            sig.replaceOccurances(of: "url=", with: "Ω")
            let ohmIndex = sig.firstIndex(of: "Ω")!
            sig.removeSubrange(sig.firstIndex(of: sig.first!)! ... ohmIndex)
            videoUrl = URL(string: sig)!
        }
        let thumbnails = videoDetails!.thumbnail!.thumbnails!.sorted {
            $0.height! > $1.height!
        }
        let thumbnail = thumbnails[0].url!
        let thumbnailUrl = URL(string: thumbnail)!
        DTDownloadManager.shared.download(videoURL: videoUrl, thumbnailURL: thumbnailUrl, video: self)
        try? FileManager.default.removeItem(at: videoUrl)
        print(videoUrl)
        print(thumbnailUrl)
        logs.insert(NSError(domain: "Successfully parsed youtube video \(title).", code: 0, userInfo: nil), at: 0)
    }
}

