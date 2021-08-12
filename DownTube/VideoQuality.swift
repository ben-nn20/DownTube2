//
//  VideoQuality.swift
//  DownTube
//
//  Created by Benjamin Nakiwala on 6/4/21.
//

import Foundation
enum VideoQuality: String, Codable, CaseIterable {
    case low = "360p"
    case medium = "720p"
    var allCases: [String] {
        ["360p", "720p"]
    }
}
