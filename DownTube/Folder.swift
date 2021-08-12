//
//  File.swift
//  DownTube
//
//  Created by Benjamin Nakiwala on 7/13/21.
//

import Foundation
import Combine

class Folder: ObservableObject, Codable, Identifiable {
    @Published var videoFolders: [VideoFolder]
    @Published var name: String
    @Published var channelId: String?
    enum CodingKeys: CodingKey {
        case videoFolders
        case name
        case channelId
    }
    var videos: [Video] {
        videoFolders.filter {
            $0.video != nil
        }.compactMap {
            $0.video
        }
    }
    var folders: [Folder] {
        videoFolders.filter {
            $0.folder != nil
        }.compactMap {
            $0.folder
        }
    }
    init(videoFolders: [VideoFolder], name: String, channelId: String? = nil) {
        self.videoFolders = videoFolders
        self.name = name
        self.channelId = channelId
    }
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        videoFolders = try values.decode([VideoFolder].self, forKey: .videoFolders)
        name = try values.decode(String.self, forKey: .name)
        channelId = try values.decode(String?.self, forKey: .channelId)
    }
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(videoFolders, forKey: .videoFolders)
        try container.encode(name, forKey: .name)
        try container.encode(channelId, forKey: .channelId)
    }
}
