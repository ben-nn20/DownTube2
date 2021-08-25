//
//  File.swift
//  DownTube
//
//  Created by Benjamin Nakiwala on 7/13/21.
//

import Foundation
import Combine

class Folder: ObservableObject, Codable, Identifiable, Hashable {
    @Published var videoFolders: [VideoFolder] {
        didSet {
            var newValue = videoFolders
            newValue.removeAll { vF in
                oldValue.contains {
                    $0 === vF
                }
            }
            let videos = newValue.compactMap {
                $0.video
            }
            videos.forEach {
                $0.parentFolder = self
            }
        }
    }
    @Published var name: String
    @Published var channelId: String?
    @Published var lastOpened = Date()
    @Published var dateCreated = Date()
    var parentFolder: Folder?
    var isChannelFolder: Bool {
        channelId != nil
    }
    var fileSize: Int64 {
        var fileSize: Int64 = 0
        allVideos.forEach {
            if let dict = try? $0.fileAtributes() as NSDictionary {
                fileSize += Int64( dict.fileSize())
            }
        }
        return fileSize
    }
    var allVideos: [Video] {
        var videos = [Video]()
        videos.append(contentsOf: self.videos)
        folders.forEach {
            videos.append(contentsOf: $0.allVideos)
        }
        return videos
    }
    var videos: [Video] {
        videoFolders.compactMap {
            // getting videos
            $0.video
        }
    }
    var folders: [Folder] {
        videoFolders.compactMap {
            $0.folder
        }
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(channelId)
    }
    func delete() {
        videoFolders.forEach {
            $0.delete()
        }
    }
    func removeFolder() {
        VideoDatabase.shared.videoFolders.append(contentsOf: videoFolders)
        if let parentFolder = parentFolder {
            parentFolder.videoFolders.removeAll {
                $0.folder === self
            }
        } else {
            VideoDatabase.shared.videoFolders.removeAll {
                $0.folder === self
            }
        }
    }
    static func == (lhs: Folder, rhs: Folder) -> Bool {
        lhs.channelId == rhs.channelId
    }
    init(videoFolders: [VideoFolder], name: String, parentFolder: Folder? = nil, channelId: String? = nil) {
        self.videoFolders = videoFolders
        self.name = name
        self.channelId = channelId
        self.parentFolder = parentFolder
    }
    enum CodingKeys: CodingKey {
        case videoFolders
        case name
        case channelId
        case parentFolder
        case lastOpened
        case dateCreated
    }
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        videoFolders = try values.decode([VideoFolder].self, forKey: .videoFolders)
        name = try values.decode(String.self, forKey: .name)
        channelId = try values.decode(String?.self, forKey: .channelId)
        parentFolder = try values.decode(Folder?.self, forKey: .parentFolder)
        lastOpened = try values.decode(Date.self, forKey: .lastOpened)
        dateCreated = try values.decode(Date.self, forKey: .dateCreated)
    }
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(videoFolders, forKey: .videoFolders)
        try container.encode(name, forKey: .name)
        try container.encode(channelId, forKey: .channelId)
        try container.encode(parentFolder, forKey: .parentFolder)
        try container.encode(lastOpened, forKey: .lastOpened)
        try container.encode(dateCreated, forKey: .dateCreated)
    }
}
