//
//  VideoView.swift
//  DownTube
//
//  Created by Benjamin Nakiwala on 8/2/21.
//

import SwiftUI
import AVKit

struct VideoView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var orientation = Orientation()
    @EnvironmentObject var video: Video
    var isSheet = false
    var body: some View {
        if isSheet {
            NavigationView {
                VStack(alignment: .leading) {
                    DTVideoPlayer(video: video)
                        .cornerRadius(10)
                        .padding(.all, 8)
                        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width * 0.5625, alignment: .top)
                    Divider()
                    DTTextView(video: video)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                video.lastOpened = Date()
            }
            .navigationBarItems(leading: EmptyView(), trailing: Button("Done") {
                dismiss()
            })
        } else {
            VStack(alignment: .leading) {
                DTVideoPlayer(video: video)
                    .cornerRadius(10)
                    .padding(.all, 8)
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width * 0.5625, alignment: .top)
                Divider()
                DTTextView(video: video)
            }
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                video.lastOpened = Date()
            }
        }
    }
}

struct VideoView_Previews: PreviewProvider {
    static var previews: some View {
        VideoView()
            .environmentObject(Video.example)
    }
}
