//
//  Settingd.swift
//  DownTube
//
//  Created by Benjamin Nakiwala on 7/5/21.
//

import Combine
import Foundation

class Settings: ObservableObject, Codable {
    @Published var preferredVideoQuality = VideoQuality.medium
    @Published var shouldAutoplay = true
    @Published var usePlaybackQueue = false
    @Published var savePlaybackPosition = true
    @Published var groupChannelsIntoFolders = false
    @Published var filterMode: FilterModes = .off
    @Published var numberOfConcurrentDownloads = 3
    @Published var useSpeedDownloader = false {
        didSet {
            numberOfConcurrentDownloads = 1
        }
    }
    var showsDownloadDate = false
    enum CodingKeys: CodingKey {
        case preferredVideoQuality
        case shouldAutoplay
        case usePlaybackQueue
        case savePlaybackPosition
        case groupChannelsIntoFolders
        case filterMode
        case numberOfConcurrentDownloads
        case showsDownloadDate
        case useSpeedDownloader
    }
    static var shared = loadSettings()
    init() {}
    required init(from decoder: Decoder) throws {
       let container = try decoder.container(keyedBy: CodingKeys.self)
        preferredVideoQuality = try container.decode(VideoQuality.self, forKey: .preferredVideoQuality)
        shouldAutoplay = try container.decode(Bool.self, forKey: .shouldAutoplay)
        usePlaybackQueue = try container.decode(Bool.self, forKey: .usePlaybackQueue)
        savePlaybackPosition = try container.decode(Bool.self, forKey: .savePlaybackPosition)
        groupChannelsIntoFolders = try container.decode(Bool.self, forKey: .groupChannelsIntoFolders)
        filterMode = try container.decode(FilterModes.self, forKey: .filterMode)
        numberOfConcurrentDownloads = try container.decode(Int.self, forKey: .numberOfConcurrentDownloads)
        showsDownloadDate = try container.decode(Bool.self, forKey: .showsDownloadDate)
        useSpeedDownloader = try container.decode(Bool.self, forKey: .useSpeedDownloader)
    }
    func encode(to encoder: Encoder) throws {
        var containter = encoder.container(keyedBy: CodingKeys.self)
        try containter.encode(preferredVideoQuality, forKey: .preferredVideoQuality)
        try containter.encode(shouldAutoplay, forKey: .shouldAutoplay)
        try containter.encode(usePlaybackQueue, forKey: .usePlaybackQueue)
        try containter.encode(savePlaybackPosition, forKey: .savePlaybackPosition)
        try containter.encode(groupChannelsIntoFolders, forKey: .groupChannelsIntoFolders)
        try containter.encode(filterMode, forKey: .filterMode)
        try containter.encode(numberOfConcurrentDownloads, forKey: .numberOfConcurrentDownloads)
        try containter.encode(showsDownloadDate, forKey: .showsDownloadDate)
        try containter.encode(useSpeedDownloader, forKey: .useSpeedDownloader)
    }
    static func loadSettings() -> Settings {
        let url = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)[0].appendingPathComponent("Settings").appendingPathExtension("plist")
        let plistDecoder = PropertyListDecoder()
        do {
            let settings = try plistDecoder.decode(Settings.self, from: try Data(contentsOf: url))
            return settings
        } catch {
            let error = NSError(domain: "Failed to load Settings", code: 0, userInfo: nil)
            Logs.addError(error)
            return Settings()
        }
    }
    static func saveSettings() {
        let url = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)[0].appendingPathComponent("Settings").appendingPathExtension("plist")
        let plistEncoder = PropertyListEncoder()
        do {
            let data = try plistEncoder.encode(Settings.shared)
            try data.write(to: url)
        } catch {
            fatalError("Failed to save")
        }
    }
}
