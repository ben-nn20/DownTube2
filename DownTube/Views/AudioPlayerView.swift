//
//  AudioPlayerView.swift
//  AudioPlayerView
//
//  Created by Benjamin Nakiwala on 8/5/21.
//

import SwiftUI

struct AudioPlayerView: View {
    @StateObject var audioPlayer = AudioPlayer.shared
    @State var isFullScreen = false
    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .foregroundColor(.clear)
            .frame(height: 50, alignment: .center)
            .background(BlurView())
            .overlay {
                HStack {
                    if let video = audioPlayer.currentlyPlayingVideo, let image = UIImage(contentsOfFile: video.thumbnailUrl.path) {
                        Image(uiImage: image)
                        VStack {
                            Text(video.title)
                            Text(video.channelName)
                                .font(.system(size: 10, weight: .medium, design: .rounded))
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        MediaPlayerButton(buttonType: .skipBack) {
                            audioPlayer.seekBack(15)
                        }
                        MediaPlayerButton(buttonType: .playPause) {
                            audioPlayer.play()
                        }
                        MediaPlayerButton(buttonType: .skipForward) {
                            audioPlayer.seekForward(30)
                        }
                    } else {
                        Image(systemName: "")
                        Text("Not Playing")
                    }
                }
            }
                
    }
}

struct AudioPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        AudioPlayerView()
    }
}
