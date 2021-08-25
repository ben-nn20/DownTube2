//
//  Enumerations.swift
//  Enumerations
//
//  Created by Benjamin Nakiwala on 8/24/21.
//

import Foundation
enum FilterModes: String, CaseIterable, Codable {
    case dateAdded = "Date added:"
    case datePublished = "Date Published:"
    case off = "None:"
    case lastOpened = "Date Opened:"
    case name = "Name:"
}
enum VideoQuality: String, Codable, CaseIterable {
    case low = "360p"
    case medium = "720p"
    var allCases: [String] {
        ["360p", "720p"]
    }
}
enum StorageView: String, CaseIterable {
    case channels = "By Channels"
    case folders = "By Folders"
    case videos = "By Videos"
}
enum DownloadStatus: String, Codable {
    case downloading
    case waiting
    case failed
    case downloaded
    case exporting
}
