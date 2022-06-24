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

class Video: NSObject, ObservableObject, Codable, Identifiable {
    var title: String
    var channelName: String
    var channelID: String
    var uploadDate: Date
    @Published var duration: Int?
    var videoId: String
    @Published @objc dynamic var thumbnailIsDownloaded = false
    @Published var isDownloaded = false
    typealias AlertInfo = (title: String, message: String)
    @Published var alertInfo: AlertInfo = ("", "")
    @Published var showAlert = false
    var videoDescription: String
    var playbackPosition = 0.0
    var lastOpened = Date()
    var parentFolderId: String?
    var playbackPositionTimer: Timer?
    var playerIsPlayingKVO: NSKeyValueObservation?
    var downloadProgress = Progress()
    let downloadDate = Date()
    @objc dynamic var downloadStatusDidChange = false
    @Published var downloadStatus: DownloadStatus = .waiting {
        didSet {
            downloadStatusDidChange = true
        }
    }
    @Published var downloadFractionCompleted = 0.0
    static let example = Video()
    // Computed Proprieties
    var avPlayer: AVPlayer {
        let videoPlayer = AVPlayer(url: videoUrl)
        if Settings.shared.savePlaybackPosition {
            playerIsPlayingKVO = videoPlayer.observe(\.rate) { player, _ in
                if player.rate == 0 {
                    self.playbackPositionTimer?.invalidate()
                    // if close to end reset time
                    if let duration = videoPlayer.currentItem?.duration, videoPlayer.currentTime() == duration {
                        self.playbackPosition = 0
                    }
                } else {
                    self.playbackPositionTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true, block: {timer in
                        self.playbackPosition = videoPlayer.currentTime().seconds
                        print(self.playbackPosition)
                    })
                }
            }
            videoPlayer.seek(to: CMTime(seconds: playbackPosition, preferredTimescale: 1))
        }
        return videoPlayer
    }
    var aspectRatio: CGFloat {
        guard let data = imageData, let image = UIImage(data: data) else { return 1 }
        let width = image.size.width
        let height = image.size.height
        print(width / height)
        return width / height
    }
    var imageData: Data? {
        try? Data(contentsOf: thumbnailUrl)
    }
    var videoSize: String {
        ByteCountFormatter.string(fromByteCount: fileSize, countStyle: .file)
    }
    var downloadSpeedTimeStamp = CFAbsoluteTimeGetCurrent()
    @Published var downloadSpeed = ""
    var fileSize: Int64 {
        do {
            return Int64((try FileManager.default.attributesOfItem(atPath: videoUrl.path) as NSDictionary).fileSize())
        } catch {
            return 0
        }
    }
    var timeStamp: String {
        guard let duration = duration else {
            return ""
        }
        let dateFormattor = DateComponentsFormatter()
        dateFormattor.allowedUnits = [.second, .minute, .hour]
        dateFormattor.formattingContext = .listItem
        let str = dateFormattor.string(from: Double(duration))
        if let str = str {
            return str
        } else {
            return ""
        }
    }
    
    // MARK: URLS
    /// URL of  video
    var videoUrl: URL {
        try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent(videoId + ".mp4")
    }
    /// URL of the thumbnail
    var thumbnailUrl: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(videoId + "thumbnail" + ".jpg")
    }
    // MARK: URL Checking
    var hasVideo: Bool {
        FileManager.default.fileExists(atPath: videoUrl.absoluteString)
    }
    // MARK: Functions
    static func == (lhs: Video, rhs: Video) -> Bool {
        lhs.videoId == rhs.videoId
    }
    override var hash: Int {
        var hasher = Hasher()
        hasher.combine(title)
        hasher.combine(channelName)
        hasher.combine(channelID)
        hasher.combine(uploadDate)
        hasher.combine(videoId)
        return hasher.finalize()
    }
    func delete() {
        try? FileManager.default.removeItem(at: videoUrl)
        try? FileManager.default.removeItem(at: thumbnailUrl)
        if let parentFolderId = parentFolderId, let folder = Folder.folderFrom(parentFolderId) {
            print(parentFolderId)
            folder.videoFolderStore.removeAll {
                $0.video === self
            }
        } else {
            parentFolderId = nil
            VideoDatabase.shared.videoFolderStore.removeAll {
                $0.video === self
            }
        }
        DTDownloadManager.shared.cancelDownloads(for: self)
        DTSpeedDownloadManager.shared.cancelDownloads(for: self)
    }
    func fileAtributes() throws -> Dictionary<FileAttributeKey, Any> {
        try FileManager.default.attributesOfItem(atPath: videoUrl.path)
    }
    
    func reDownload() {
        delete()
        Video.video(fromVideoId: videoId, parentFolderId: parentFolderId)
    }
    
    func videoFinishedDownloading(_ video: URL) {
        Logs.addError(NSError(domain: "Video Finished Downloading for \(title).", code: 0, userInfo: nil))
        do {
            try FileManager.default.moveItem(at: video, to: videoUrl)
            duration = Int(AVAsset(url: videoUrl).duration.seconds)
            isDownloaded = true
            downloadStatus = .downloaded
        } catch {
            Logs.addError(error)
            print(error)
        }
        let tempURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0].appendingPathComponent("thumbnail.jpg")
        try? FileManager.default.copyItem(at: thumbnailUrl, to: tempURL)
        DTNotificationManager.shared.sendNotification(title: "Finished Downloading", message: "\"\(title)\" finished downloading.", identifier: videoId, thumbnailImage: tempURL)
        VideoDatabase.saveVideos()
    }
    func videoPartiallyDownloaded(_ video: URL) {
        Logs.addError(NSError(domain: "Video Partially Finished Downloading for \(title).", code: 0, userInfo: nil))
        do {
            var fileHandle = try? FileHandle(forUpdating: videoUrl)
            if fileHandle == nil {
                try Data().write(to: videoUrl)
                fileHandle = try FileHandle(forUpdating: videoUrl)
            }
            
            let offset = try fileHandle!.seekToEnd()
            try fileHandle!.write(contentsOf: try! Data(contentsOf: video))
            try fileHandle!.close()
            print("File Offset: \(offset)")
            print("Size Of Data Added: \(try Data(contentsOf: video).count)")
        } catch {
            Logs.addError(error)
            print(error)
        }
    }
    func videoDidFinishSpeedDownloading(videoSize: Int64) {
        duration = Int(AVAsset(url: videoUrl).duration.seconds)
        let tempURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0].appendingPathComponent("thumbnail.jpg")
        try? FileManager.default.copyItem(at: thumbnailUrl, to: tempURL)
        DTNotificationManager.shared.sendNotification(title: "Finished Downloading", message: "\"\(title)\" finished downloading.", identifier: videoId, thumbnailImage: tempURL)
        VideoDatabase.saveVideos()
        downloadStatus = .downloaded
        isDownloaded = true
    }
    func downloadDidFailWith(error: Error) {
        let error = error as NSError
        guard error.domain == NSURLErrorDomain else { return }
        if error.code == NSURLErrorNotConnectedToInternet {
            DispatchQueue.main.async {
                self.alertInfo = (title: "Connect to the Internet", message: "Device not connected.")
                self.showAlert = true
            }
        } else if error.code == NSURLErrorNetworkConnectionLost {
            DispatchQueue.main.async {
                self.alertInfo = (title: "Connect to the Internet", message: "Device lost connection. Redownload pending videos when connected.")
                self.showAlert = true
            }
        }
        Logs.addError(error)
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
        case videoDescription
        case playbackPosition
        case lastOpened
        case parentFolderId
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
        try container.encode(videoDescription, forKey: .videoDescription)
        try container.encode(videoId, forKey: .videoId)
        try container.encode(playbackPosition, forKey: .playbackPosition)
        try container.encode(lastOpened, forKey: .lastOpened)
        try container.encode(parentFolderId, forKey: .parentFolderId)
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
        videoDescription = try values.decode(String.self, forKey: .videoDescription)
        playbackPosition = try values.decode(Double.self, forKey: .playbackPosition)
        isDownloaded = try values.decode(Bool.self, forKey: .isDownloaded)
        lastOpened = try values.decode(Date.self, forKey: .lastOpened)
        parentFolderId = try values.decode(String?.self, forKey: .parentFolderId)
        super.init()
        if hasVideo {
            downloadStatus = .downloaded
            isDownloaded = true
        }
        if imageData == nil {
            let thumbReq = URLRequest(url: URL(string: "https://i.ytimg.com/vi/\(videoId)/sddefault.jpg")!)
            URLSession.shared.dataTask(with: thumbReq) { [self] (data, response, error) in
                guard error == nil else { return }
                try? data!.write(to: thumbnailUrl)
                DispatchQueue.main.async {
                    self.thumbnailIsDownloaded = true
                }
            }.resume()
        }
    }
    static func video(fromVideoId: String, parentFolderId: String? = nil) {
        var youtubeFormatter = YoutubeAPIParser(fromVideoId)
        youtubeFormatter.format { (videoInfo) in
            DispatchQueue.main.async {
                guard let youtubeInfo = videoInfo else { return }
                let video = Video(youtubeInfo: youtubeInfo, parentFolderId: parentFolderId)
                guard let unwrappedVideo = video else {
                    Logs.addError(NSError(domain: "Video init failed", code: 0, userInfo: nil))
                    return
                }
                if parentFolderId == nil {
                    VideoDatabase.shared.videoFolderStore.insert(VideoFolder(video: unwrappedVideo, folder: nil), at: 0)
                } else {
                    guard let parentFolder = Folder.folderFrom(parentFolderId!) else { return }
                    parentFolder.videoFolderStore.insert(VideoFolder(video: unwrappedVideo, folder: nil), at: 0)
                }
            }
        }
    }
    private override init() {
        self.title = "Title"
        self.channelName = "Channel Name"
        self.channelID = "234567"
        self.uploadDate = Date()
        self.videoId = ""
        duration = Int.random(in: 50 ... 5000)
        downloadStatus = .downloading
        videoDescription = "Sample Description"
        super.init()
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [self] timer in
            downloadProgress.completedUnitCount += 1
            downloadProgress.totalUnitCount = 100
            if downloadProgress.totalUnitCount == downloadProgress.completedUnitCount {
                timer.invalidate()
            }
        }
    }
    private init?(youtubeInfo: VideoInfo, parentFolderId: String?) {
        if let parentFolderId = parentFolderId {
            self.parentFolderId = parentFolderId
        }
        guard let videoDetails = youtubeInfo.videoDetails else { return nil}
        self.videoId = videoDetails.videoId!
        self.title = videoDetails.title!.replacingOccurrences(of: "+", with: " ")
        self.channelName = videoDetails.author!.replacingOccurrences(of: "+", with: " ")
        self.channelID = videoDetails.channelId!
        self.videoDescription = videoDetails.shortDescription!
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        guard let date = dateFormatter.date(from: youtubeInfo.microformat?.playerMicroformatRenderer!.publishDate! ?? "\(dateFormatter.string(from: Date()))") else {
            return nil
        }
        self.uploadDate = date
        guard let formats = youtubeInfo.streamingData!.formats else {
            print(youtubeInfo)
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
            Logs.addError(NSError(domain: "Video not found. Failed in Video initializer. file: Video.swift, line: 167", code: 1, userInfo: nil))
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
        super.init()
        let thumbnail = "https://i.ytimg.com/vi/\(videoId)/sddefault.jpg"
        let thumbnailUrl = URL(string: thumbnail)!
        if Settings.shared.useSpeedDownloader {
            DTSpeedDownloadManager.shared.download(video: self, videoURL: videoUrl, thumbnailURL: thumbnailUrl)
        } else {
            DTDownloadManager.shared.download(videoURL: videoUrl, thumbnailURL: thumbnailUrl, video: self)
        }
        try? FileManager.default.removeItem(at: videoUrl)
        print(videoUrl)
        print(thumbnailUrl)
        Logs.addError(NSError(domain: "Successfully parsed youtube video \(title).", code: 0, userInfo: nil))
    }
}

