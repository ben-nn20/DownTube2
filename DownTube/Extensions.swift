//
//  NSErrorExtension.swift
//  DownTube
//
//  Created by Benjamin Nakiwala on 7/5/21.
//

import Foundation

extension NSError: Identifiable {}
extension Set: Identifiable {
    public var id: Int {
        hashValue
    }
}
