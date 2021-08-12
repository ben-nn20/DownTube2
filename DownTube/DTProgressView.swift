//
//  DTProgressView.swift
//  DownTube
//
//  Created by Benjamin Nakiwala on 7/5/21.
//

import SwiftUI

struct DTProgressView: UIViewRepresentable {
    var progress: Progress
    typealias UIViewType = UIView
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        let progressView = UIProgressView()
        view.addSubview(progressView)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            progressView.topAnchor.constraint(equalTo: view.topAnchor),
            progressView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            progressView.rightAnchor.constraint(equalTo: view.rightAnchor),
            progressView.leftAnchor.constraint(equalTo: view.leftAnchor)
        ])
        progressView.observedProgress = progress
        progressView.progressTintColor = .red.withAlphaComponent(0.35)
        progressView.trackTintColor = .tertiarySystemBackground
        view.backgroundColor = .clear
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
    }
}

struct DTProgressView_Previews: PreviewProvider {
    static var previews: some View {
        DTProgressView(progress: Progress())
            .previewLayout(.fixed(width: 300, height: 100))
    }
}
