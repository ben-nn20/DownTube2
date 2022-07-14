//
//  MainViewUpdator.swift
//  MainViewUpdator
//
//  Created by Benjamin Nakiwala on 8/5/21.
//

import Combine
import Foundation

class MainViewUpdator: ObservableObject {
    static var shared = MainViewUpdator()
    @Published var audioIsPlaying = false
    @Published var showVideo: Video?
    @Published var acceptConnection = false
    var incomingDeviceName = ""
    var handler: ((Bool) -> Void)?
    var userAccepted: Bool? {
        didSet {
            guard let userAccepted = userAccepted else {
                return
            }
            handler?(userAccepted)
        }
    }
    func getUserInputToAcceptConnection(name: String, _ handler: @escaping ((Bool) -> Void)) {
        self.handler = handler
        DispatchQueue.main.async {
            self.incomingDeviceName = name
            self.acceptConnection = true
        }
    }
}

