//
//  Videos.swift
//  DownTube
//
//  Created by Benjamin Nakiwala on 6/28/21.
//

import Combine
import Foundation
let kROOTFolder = "1234567890"
class VideoDatabase: ObservableObject {
    private init() {
        self.videoFolders = Self.loadVideos()
        print(videoFolders.count)
    }
    static var example: VideoDatabase = { () -> VideoDatabase in
        let videos = VideoDatabase()
        videos.videoFolders = [VideoFolder(video: Video.example, folder: nil)]
        return videos
    }()
    static let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("videos").appendingPathExtension("plist")
    @Published dynamic var videoFolders: [VideoFolder] {
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
        videoFolders.forEach {
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
    var cancellable: AnyCancellable?
    var allVideos: [Video] {
        var videos = videoFolders.compactMap {
            // getting videos
            $0.video
        }
        folders.forEach {
            videos.append(contentsOf: $0.allVideos)
        }
        return videos
    }
    var videos: [Video] {
        if Settings.shared.groupChannelsIntoFolders {
            var videos = videoFolders.compactMap {
                // getting videos
                $0.video
            }
            var videosInChannelFolders = [Video]()
            channelFolders.forEach {
                videosInChannelFolders.append(contentsOf: $0.videos)
            }
            videos.removeAll {
                videosInChannelFolders.contains($0)
            }
            return videos
        } else {
            return videoFolders.compactMap {
                // getting videos
                $0.video
            }
        }
    }
    var allFolders: [Folder] {
        let folders = folders
        var folders2 = [Folder]()
        folders.forEach {
            folders2.append(contentsOf: $0.allFolders)
        }
        folders2.append(contentsOf: folders)
        return folders2
    }
    var folders: [Folder] {
        videoFolders.compactMap {
            $0.folder
        }
    }
    var channelInfo: [ChannelInfo] {
        let videos = videoFolders.compactMap {
            // getting videos
            $0.video
        }
        let channelIds = Set(videos.map {
            ChannelInfo(channelId: $0.channelID, channelName: $0.channelName)
        })
        return Array(channelIds)
    }
    var channelFolders: [Folder] {
        var folders = channelInfo.map {
            Folder(videoFolders: [VideoFolder](), name: $0.channelName, channelId: $0.channelId)
        }
        let videos = videoFolders.compactMap {
            // getting videos
            $0.video
        }
    videoLoop: for video in videos {
        for folder in folders {
            if video.channelID == folder.channelId {
                folder.videoFolders.append(VideoFolder(video: video, folder: nil))
                continue videoLoop
            }
        }
    }
        for folder in folders {
            if folder.videos.count < 2 {
                folders.removeAll {
                    $0 === folder
                }
            }
        }
        return folders
    }
    func add(_ vid: Video? = nil,_ folder: Folder? = nil) {
        if let vid = vid {
            videoFolders.insert(VideoFolder(video: vid), at: 0)
        }
        if let folder = folder {
            videoFolders.insert(VideoFolder(video: nil, folder: folder), at: 0)
        }
    }
    func remove(_ vid: Video? = nil, _ folder: Folder? = nil) {
        if let vid = vid {
            self.videoFolders.removeAll {
                $0.video === vid
            }
        }
        if let folder = folder {
            self.videoFolders.removeAll {
                $0.folder === folder
            }
        }
    }
    // MARK: UIKit Functions
    func videoFolders(_ filteredBy: FilterModes) -> [VideoFolder] {
        // make folders and videos and videoFolder
        let folders = folders
        let videos = videoFolders.compactMap {
            // getting videos
            $0.video
        }
        // handle channel folders
        let vF: [VideoFolder]
        switch filteredBy {
        case .dateAdded:
            // filtered folders
            let vfFolders = folders.sorted {
                $0.dateCreated > $1.dateCreated
            }.map {
                VideoFolder(video: nil, folder: $0)
            }
            // filtered videos
            let vfVideos = videos.sorted {
                $0.downloadDate > $1.downloadDate
            }.map {
                VideoFolder(video: $0, folder: nil)
            }
            // result
            vF = vfFolders + vfVideos
        case .datePublished:
            // filtered folders
            let vfFolders = folders.sorted {
                $0.dateCreated > $1.dateCreated
            }.map {
                VideoFolder(video: nil, folder: $0)
            }
            // filtered videos
            let vfVideos = videos.sorted {
                $0.uploadDate > $1.uploadDate
            }.map {
                VideoFolder(video: $0, folder: nil)
            }
            // result
            vF = vfFolders + vfVideos
        case .off:
            vF = folders.map {
                VideoFolder(video: nil, folder: $0)
            } + videos.map {
                VideoFolder(video: $0, folder: nil)
            }
        case .lastOpened:
            // filtered folders
            let vfFolders = folders.sorted {
                $0.dateCreated > $1.dateCreated
            }.map {
                VideoFolder(video: nil, folder: $0)
            }
            // filtered videos
            let vfVideos = videos.sorted {
                $0.lastOpened > $1.lastOpened
            }.map {
                VideoFolder(video: $0, folder: nil)
            }
            // result
            vF = vfFolders + vfVideos
        case .name:
            // filtered folders
            let vfFolders = folders.sorted {
                $0.name.lowercased() < $1.name.lowercased()
            }.map {
                VideoFolder(video: nil, folder: $0)
            }
            // filtered videos
            let vfVideos = videos.sorted {
                $0.title.lowercased() < $1.title.lowercased()
            }.map {
                VideoFolder(video: $0, folder: nil)
            }
            // result
            vF = vfFolders + vfVideos
        }
        return vF
    }
    private static func loadVideos() -> [VideoFolder] {
        let plistDecoder = PropertyListDecoder()
        do {
            return try plistDecoder.decode([VideoFolder].self, from: try Data(contentsOf: url))
        } catch {
            print(error)
            logs.insert(error, at: 0)
            let plistEncoder = PropertyListEncoder()
            do {
                let data = try plistEncoder.encode([VideoFolder]())
                try data.write(to: url)
            } catch {
                print(error)
                logs.insert(error, at: 0)
            }
            return [VideoFolder]()
        }
    }
    static func saveVideos() {
        let plistEncoder = PropertyListEncoder()
        do {
            let data = try plistEncoder.encode(VideoDatabase.shared.videoFolders)
            try data.write(to: url)
        } catch {
            logs.insert(error, at: 0)
            fatalError()
        }
    }
}
class VideoFolder: Codable, Identifiable {
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
