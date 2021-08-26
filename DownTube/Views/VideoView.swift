//
//  VideoView.swift
//  DownTube
//
//  Created by Benjamin Nakiwala on 8/2/21.
//

import SwiftUI
import AVKit

struct VideoView: View {
    @StateObject var orientation = Orientation()
    @EnvironmentObject var video: Video
    var body: some View {
         VStack {
            ScrollView {
                LazyVStack(alignment: .leading) {
                    DTVideoPlayer(video: video)
                        .cornerRadius(10)
                        .padding(.all, 8)
                        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width * 0.5625, alignment: .top)
                    Divider()
                    VStack(alignment: .leading) {
                        Text(video.title)
                            .font(.largeTitle)
                        Text(video.videoDescription)
                    }
                    .padding(.leading, 5)
                    
                }
            }
        }
         .onAppear {
             video.lastOpened = Date()
         }
    }
}

struct VideoView_Previews: PreviewProvider {
    static var previews: some View {
        VideoView()
            .environmentObject(Video.example)
    }
}
