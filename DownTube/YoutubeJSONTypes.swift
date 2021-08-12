//
//  YoutubeJSONTypes.swift
//  DownTube
//
//  Created by Benjamin Nakiwala on 6/7/21.
//

import Foundation
struct VideoInfo: Codable {

struct PlayabilityStatus: Codable {

    let contextParams: String?
    let status: String?
    let playableInEmbed: Bool?

}

let playabilityStatus: PlayabilityStatus?

struct Storyboards: Codable {

    struct PlayerStoryboardSpecRenderer: Codable {

        let spec: String?
    
    }

    let playerStoryboardSpecRenderer: PlayerStoryboardSpecRenderer?

}

let storyboards: Storyboards?

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

    let expiresInSeconds: String?

}

let streamingData: StreamingData?

struct PlaybackTracking: Codable {

    struct PtrackingUrl: Codable {

        let baseUrl: String?
    
    }

    let ptrackingUrl: PtrackingUrl?

    struct YoutubeRemarketingUrl: Codable {

        let elapsedMediaTimeSeconds: Int?
        let baseUrl: String?
    
    }

    let youtubeRemarketingUrl: YoutubeRemarketingUrl?

    struct GoogleRemarketingUrl: Codable {

        let elapsedMediaTimeSeconds: Int?
        let baseUrl: String?
    
    }

    let googleRemarketingUrl: GoogleRemarketingUrl?

    struct QoeUrl: Codable {

        let baseUrl: String?
    
    }

    let qoeUrl: QoeUrl?

    struct VideostatsDelayplayUrl: Codable {

        let baseUrl: String?
    
    }

    let videostatsDelayplayUrl: VideostatsDelayplayUrl?

    struct VideostatsWatchtimeUrl: Codable {

        let baseUrl: String?
    
    }

    let videostatsWatchtimeUrl: VideostatsWatchtimeUrl?

    struct VideostatsPlaybackUrl: Codable {

        let baseUrl: String?
    
    }

    let videostatsPlaybackUrl: VideostatsPlaybackUrl?

    struct AtrUrl: Codable {

        let elapsedMediaTimeSeconds: Double?
        let baseUrl: String?
    
    }

    let atrUrl: AtrUrl?

    let videostatsDefaultFlushIntervalSeconds: Double?
    let videostatsScheduledFlushWalltimeSeconds: [Double]?

}

let playbackTracking: PlaybackTracking?

struct ResponseContext: Codable {

    struct WebResponseContextExtensionData: Codable {

        let hasDecorated: Bool?
    
    }

    let webResponseContextExtensionData: WebResponseContextExtensionData?

    struct ServiceTrackingParam: Codable {

        let service: String?

        struct Param: Codable {

            let key: String?
            let value: String?
        
        }

        let params: [Param]?

    
    }

    let serviceTrackingParams: [ServiceTrackingParam]?

}

let responseContext: ResponseContext?

struct Attestation: Codable {

    struct PlayerAttestationRenderer: Codable {

        struct BotguardData: Codable {

            struct InterpreterSafeUrl: Codable {

                let privateDoNotAccessOrElseTrustedResourceUrlWrappedValue: String?
            
            }

            let interpreterSafeUrl: InterpreterSafeUrl?

            let interpreterUrl: String?
            let program: String?
        
        }

        let botguardData: BotguardData?

        let challenge: String?
    
    }

    let playerAttestationRenderer: PlayerAttestationRenderer?

}

let attestation: Attestation?

struct VideoDetails: Codable {

    struct Thumbnail: Codable {

        struct Thumbnail: Codable {

            let height: Double?
            let url: String?
            let width: Double?
        
        }

        let thumbnails: [Thumbnail]?

    
    }

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

        struct Title: Codable {

            struct Run: Codable {

                let text: String?
            
            }

            let runs: [Run]?

        
        }

        let title: Title?

        struct Embed: Codable {

            let flashSecureUrl: String?
            let flashUrl: String?
            let width: Double?
            let height: Double?
            let iframeUrl: String?
        
        }

        let embed: Embed?

        struct Description: Codable {

            struct Run: Codable {

                let text: String?
            
            }

            let runs: [Run]?

        
        }

        let description: Description?

        struct Thumbnail: Codable {

            struct Thumbnail: Codable {

                let height: Double?
                let url: String?
                let width: Double?
            
            }

            let thumbnails: [Thumbnail]?

        
        }

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

struct PlayerConfig: Codable {

    struct MediaCommonConfig: Codable {

        struct DynamicReadaheadConfig: Codable {

            let maxReadAheadMediaTimeMs: Double?
            let readAheadGrowthRateMs: Double?
            let minReadAheadMediaTimeMs: Double?
        
        }

        let dynamicReadaheadConfig: DynamicReadaheadConfig?

    
    }

    let mediaCommonConfig: MediaCommonConfig?

    struct AudioConfig: Codable {

        let loudnessDb: Double?
        let perceptualLoudnessDb: Double?
        let enablePerFormatLoudness: Bool?
    
    }

    let audioConfig: AudioConfig?

    struct StreamSelectionConfig: Codable {

        let maxBitrate: String?
    
    }

    let streamSelectionConfig: StreamSelectionConfig?

}

let playerConfig: PlayerConfig?

struct AdPlacement: Codable {

    struct AdPlacementRenderer: Codable {

        struct Renderer: Codable {

            struct AdBreakServiceRenderer: Codable {

                let getAdBreakUrl: String?
                let prefetchMilliseconds: String?
            
            }

            let adBreakServiceRenderer: AdBreakServiceRenderer?

        
        }

        let renderer: Renderer?

        struct Config: Codable {

            struct AdPlacementConfig: Codable {

                struct AdTimeOffset: Codable {

                    let offsetEndMilliseconds: String?
                    let offsetStartMilliseconds: String?
                
                }

                let adTimeOffset: AdTimeOffset?

                let hideCueRangeMarker: Bool?
                let kind: String?
            
            }

            let adPlacementConfig: AdPlacementConfig?

        
        }

        let config: Config?

    
    }

    let adPlacementRenderer: AdPlacementRenderer?

}

let adPlacements: [AdPlacement]?

struct PlayerAd: Codable {

    struct PlayerLegacyDesktopWatchAdsRenderer: Codable {

        struct PlayerAdParams: Codable {

            let showContentThumbnail: Bool?
            let enabledEngageTypes: String?
        
        }

        let playerAdParams: PlayerAdParams?

        struct GutParams: Codable {

            let tag: String?
        
        }

        let gutParams: GutParams?

        let showCompanion: Bool?
        let showInstream: Bool?
        let useGut: Bool?
    
    }

    let playerLegacyDesktopWatchAdsRenderer: PlayerLegacyDesktopWatchAdsRenderer?

}

let playerAds: [PlayerAd]?

let trackingParams: String?

}
