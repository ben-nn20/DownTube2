//
//  Orientation.swift
//  DownTube
//
//  Created by Benjamin Nakiwala on 8/2/21.
//

import UIKit
import Combine

class Orientation: ObservableObject {
    @Published var direction: Direction = Direction.portriat
    private var publisher: AnyCancellable?
    enum Direction {
        case landscape
        case portriat
    }
    init() {
       publisher = NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification).sink { [self] _ in
        switch UIDevice.current.orientation {
            case .faceDown :
                direction = .portriat
            case .faceUp :
                direction = .portriat
            case .landscapeLeft :
                direction = .landscape
            case .landscapeRight :
                direction = .landscape
            case .portrait :
                direction = .portriat
            case .portraitUpsideDown :
                direction = .portriat
            case .unknown:
                break
            @unknown default:
                break
            }
        }
    }
}
