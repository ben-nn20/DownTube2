//
//  Orientation.swift
//  DownTube
//
//  Created by Benjamin Nakiwala on 8/2/21.
//

import UIKit
import Combine

class Orientation: ObservableObject {
    @Published var direction: Direction = .portriat
    var observer: ((Direction) -> Void)?
    enum Direction {
        case landscape
        case portriat
    }
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(orientationDidChange), name: UIDevice.orientationDidChangeNotification, object: nil)
        orientationDidChange()
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    @objc private func orientationDidChange() {
        switch UIDevice.current.orientation {
            case .faceDown :
                break
            case .faceUp :
                break
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
        observer?(direction)
    }
}
