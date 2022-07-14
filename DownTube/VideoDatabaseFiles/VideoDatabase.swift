//
//  Videos.swift
//  DownTube
//
//  Created by Benjamin Nakiwala on 6/28/21.
//

import Combine
import Foundation

class VideoDatabase: NSObject, VideoDatabaseContainer, ObservableObject {
    private override init() {
        self.videoFolderStore = Self.loadVideos()
        super.init()
    }
    static var example: VideoDatabase = { () -> VideoDatabase in
        let videos = VideoDatabase()
        videos.videoFolderStore = [VideoFolder(video: Video.example, folder: nil)]
        return videos
    }()
    static let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("videos").appendingPathExtension("plist")
    @Published @objc dynamic var videoFolderStore: [VideoFolder] {
        didSet {
            Self.saveVideos()
        }
    }
    var directoryAttributes: Dictionary<FileAttributeKey, Any>? {
         try? FileManager.default.attributesOfFileSystem(forPath: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].path)
    }
    var filesAtributes: Dictionary<ObjectIdentifier, Dictionary<FileAttributeKey, Any>>? {
        var dict = [ObjectIdentifier: [FileAttributeKey: Any]]()
        var videos = [Video]()
        videoFolderStore.forEach {
            if let video = $0.video {
                videos.append(video)
            } else if let folder = $0.folder {
                videos.append(contentsOf: folder.allVideos)
            }
        }
        videos.forEach { video in
                let attributes = try? video.fileAtributes()
                if let attributes = attributes {
                    dict[video.id] = attributes
                }
        }
        return dict
    }
    static let shared = VideoDatabase()
    //MARK: VideoDatabase methods
    private static func loadVideos() -> [VideoFolder] {
        let plistDecoder = PropertyListDecoder()
        do {
            return try plistDecoder.decode([VideoFolder].self, from: try Data(contentsOf: url))
        } catch {
            print(error)
            Logs.addError(error)
            try? FileManager.default.removeItem(at: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0])
            try? FileManager.default.createDirectory(at: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0], withIntermediateDirectories: true)
            let encoder = PropertyListEncoder()
            let data = try? encoder.encode([VideoFolder]())
            try? data?.write(to: url)
            return [VideoFolder]()
        }
    }
    static func saveVideos() {
        let plistEncoder = PropertyListEncoder()
        do {
            let data = try plistEncoder.encode(VideoDatabase.shared.videoFolderStore)
            try data.write(to: url)
        } catch {
            Logs.addError(error)
            fatalError()
        }
        print(url)
    }
}
class VideoFolder: NSObject, Codable, Identifiable {
    init(video: Video? = nil, folder: Folder? = nil) {
        self.video = video
        self.folder = folder
    }
    var video: Video?
    var folder: Folder?
    enum CodingKeys: CodingKey {
        case video
        case folder
    }
    func delete() {
        if let video = video {
            video.delete()
        }
        if let folder = folder {
            folder.delete()
        }
    }
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        video = try container.decode(Video?.self, forKey: .video)
        folder = try container.decode(Folder?.self, forKey: .folder)
    }
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(video, forKey: .video)
        try container.encode(folder, forKey: .folder)
    }
}

struct ChannelInfo: Hashable, Identifiable {
    var channelId: String
    var channelName: String
    typealias ID = String
    var id: String {
        channelId
    }
}
