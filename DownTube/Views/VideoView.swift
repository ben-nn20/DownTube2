//
//  VideoView.swift
//  DownTube
//
//  Created by Benjamin Nakiwala on 8/2/21.
//

import SwiftUI

struct VideoView: UIViewControllerRepresentable {
    var video: Video
    var isSheet: Bool = false
    typealias UIViewControllerType = VideoViewController
    func makeUIViewController(context: Context) -> VideoViewController {
        VideoViewController.VC(video: video, isSheet: isSheet)
        
    }
    func updateUIViewController(_ uiViewController: VideoViewController, context: Context) {
    }
}
