//
//  MainViewUpdator.swift
//  MainViewUpdator
//
//  Created by Benjamin Nakiwala on 8/5/21.
//

import Combine
 class MainViewUpdator: ObservableObject {
    static var shared = MainViewUpdator()
    
    @Published var audioIsPlaying = false
    
}

