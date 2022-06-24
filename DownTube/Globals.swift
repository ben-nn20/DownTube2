//
//  Globals.swift
//  DownTube
//
//  Created by Benjamin Nakiwala on 6/7/21.
//

import Foundation
import Combine

class Logs: ObservableObject {
    static let shared = Logs()
    private init() {
        
    }
    @Published var logs = [NSError]()
    static func addError(_ error: Error) {
        Logs.shared.logs.insert(error as NSError, at: 0)
    }
}
