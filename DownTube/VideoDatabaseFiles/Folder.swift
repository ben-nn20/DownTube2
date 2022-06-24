//
//  File.swift
//  DownTube
//
//  Created by Benjamin Nakiwala on 7/13/21.
//

import Foundation
import Combine

class Folder: NSObject, ObservableObject, Codable, Identifiable, VideoDatabaseContainer {
    @Published @objc dynamic var videoFolderStore: [VideoFolder] {
        didSet {
            var newValue = videoFolderStore
            newValue.removeAll { vF in
                oldValue.contains {
                    $0 === vF
                }
            }
            newValue.forEach {
                if !isChannelFolder {
                    if let video = $0.video {
                        video.parentFolderId = id
                    } else if let folder = $0.folder {
                        folder.parentFolderId = id
                    }
                }
            }
        }
    }
    typealias ID = String
    var id: String
    @Published var name: String
    @Published var channelId: String?
    @Published var lastOpened = Date()
    @Published var dateCreated = Date()
    var parentFolderId: String?
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
    
    override var hash: Int {
        var hasher = Hasher()
        hasher.combine(channelId)
        return hasher.finalize()
    }
    func delete() {
        videoFolderStore.forEach {
            $0.delete()
        }
        if let parentFolderId = parentFolderId, let folder = Folder.folderFrom(parentFolderId) {
            folder.videoFolderStore.removeAll {
                $0.folder === self
            }
        } else {
            VideoDatabase.shared.videoFolderStore.removeAll {
                $0.folder === self
            }
        }
    }
    func removeFolder() {
        VideoDatabase.shared.videoFolderStore.append(contentsOf: videoFolderStore)
        if let parentFolderId = parentFolderId, let folder = Folder.folderFrom(parentFolderId) {
            folder.videoFolderStore.removeAll {
                $0.folder === self
            }
        } else {
            VideoDatabase.shared.videoFolderStore.removeAll {
                $0.folder === self
            }
        }
        // Handle folder ids
        videoFolders().forEach {
            if let video = $0.video {
                video.parentFolderId = nil
            } else if let folder = $0.folder {
                folder.parentFolderId = nil
            }
        }
    }
    static func == (lhs: Folder, rhs: Folder) -> Bool {
        lhs.channelId == rhs.channelId
    }
    static func folderFrom(_ id: String) -> Folder? {
        let allFolders = VideoDatabase.shared.allFolders
        return allFolders.first {
            return $0.id == id
        }
    }
    init(videoFolders: [VideoFolder], name: String, parentFolderId: String? = nil, channelId: String? = nil, id: String? = nil) {
        self.videoFolderStore = videoFolders
        self.name = name
        self.channelId = channelId
        self.parentFolderId = parentFolderId
        self.id = UUID().uuidString
        super.init()
        self.videos.forEach {
            $0.parentFolderId = self.id
        }
    }
    enum CodingKeys: CodingKey {
        case videoFolders
        case name
        case channelId
        case parentFolderId
        case lastOpened
        case dateCreated
        case id
    }
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        videoFolderStore = try values.decode([VideoFolder].self, forKey: .videoFolders)
        name = try values.decode(String.self, forKey: .name)
        channelId = try values.decode(String?.self, forKey: .channelId)
        parentFolderId = try values.decode(String?.self, forKey: .parentFolderId)
        lastOpened = try values.decode(Date.self, forKey: .lastOpened)
        dateCreated = try values.decode(Date.self, forKey: .dateCreated)
        id = try values.decode(String.self, forKey: .id)
    }
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(videoFolderStore, forKey: .videoFolders)
        try container.encode(name, forKey: .name)
        try container.encode(channelId, forKey: .channelId)
        try container.encode(parentFolderId, forKey: .parentFolderId)
        try container.encode(lastOpened, forKey: .lastOpened)
        try container.encode(dateCreated, forKey: .dateCreated)
        try container.encode(id, forKey: .id)
    }
}
