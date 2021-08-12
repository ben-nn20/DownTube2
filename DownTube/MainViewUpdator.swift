//
//  MainViewUpdator.swift
//  MainViewUpdator
//
//  Created by Benjamin Nakiwala on 8/5/21.
//

import Combine
import AVFAudio

class MainViewUpdator: ObservableObject {
    @Published var audioIsPlaying = false
    static var shared = MainViewUpdator()
}
