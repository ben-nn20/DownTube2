//
//  DownloadStatus.swift
//  DownTube
//
//  Created by Benjamin Nakiwala on 6/29/21.
//

import Foundation

enum DownloadStatus: String, Codable {
    case downloading
    case waiting
    case failed
    case downloaded
    case exporting
}
