//
//  YoutubeJSONTypes.swift
//  DownTube
//
//  Created by Benjamin Nakiwala on 6/7/21.
//

import Foundation
struct VideoInfo: Codable {
    struct Thumbnail: Codable {
        struct Thumbnail: Codable {
            let height: Double?
            let url: String?
            let width: Double?
        }
        let thumbnails: [Thumbnail]?
    }
    struct StreamingData: Codable {
        struct Format: Codable {
            let audioChannels: Double?
            let qualityLabel: String?
            let width: Double?
            let itag: Double?
            let bitrate: Double?
            let approxDurationMs: String?
            let height: Double?
            let projectionType: String?
            let mimeType: String?
            let lastModified: String?
            let quality: String?
            let fps: Double?
            let audioSampleRate: String?
            let audioQuality: String?
            let url: String?
            let signatureCipher: String?
        }
        let formats: [Format]?
    }
    let streamingData: StreamingData?
    struct VideoDetails: Codable {
        let thumbnail: Thumbnail?
        let isLiveContent: Bool?
        let isPrivate: Bool?
        let shortDescription: String?
        let videoId: String?
        let author: String?
        let keywords: [String]?
        let lengthSeconds: String?
        let isOwnerViewing: Bool?
        let allowRatings: Bool?
        let isUnpluggedCorpus: Bool?
        let title: String?
        let viewCount: String?
        let isCrawlable: Bool?
        let averageRating: Double?
        let channelId: String?
    }
    let videoDetails: VideoDetails?
    struct Microformat: Codable {
        struct PlayerMicroformatRenderer: Codable {
            let thumbnail: Thumbnail?
            let ownerChannelName: String?
            let availableCountries: [String]?
            let publishDate: String?
            let uploadDate: String?
            let hasYpcMetadata: Bool?
            let category: String?
            let lengthSeconds: String?
            let isUnlisted: Bool?
            let externalChannelId: String?
            let viewCount: String?
            let isFamilySafe: Bool?
            let ownerProfileUrl: String?
        }
        let playerMicroformatRenderer: PlayerMicroformatRenderer?
    }
    let microformat: Microformat?
}
