//
//  VideoCell.swift
//  DownTube
//
//  Created by Benjamin Nakiwala on 6/28/21.
//

import SwiftUI
import AVKit

struct VideoCell: View {
    @StateObject var orientation = Orientation()
    @EnvironmentObject var video: Video
    @State var shouldDelete: Video?
    @State var playVideo = false
    var body: some View {
        
        HStack {
            if let data = video.imageData {
                Image(uiImage: UIImage(data: data)!)
                    .resizable()
                    .frame(width: 75 * (video.asceptRatio ?? 1.77), height: 75, alignment: .center)
            } else {
                Image(systemName: "arrow.down").frame(width: 60, height: 60, alignment: .center)
            }
            
            ZStack {
                if video.downloadStatus == .downloading {
                    DTProgressView(progress: video.downloadProgress)
                }
                VStack(alignment: .leading, spacing: nil, content: {
                    VStack(alignment: .leading, spacing: nil, content: {
                        Spacer()
                        Text(video.title)
                        Text(video.channelName)
                            .font(.system(size: 10, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                    })
                    Spacer()
                    Text(video.uploadDate, style: .date)
                        .font(.footnote)
                    if video.downloadStatus == .downloaded {
                        Text(video.videoSize)
                            .foregroundColor(.secondary)
                            .font(.system(size: 12, weight: .regular, design: .rounded))
                    }
                    Spacer()
                })
            }
            Spacer()
            if video.downloadStatus == .waiting {
                ProgressView()
            } else if video.downloadStatus == .exporting {
                HStack {
                    ProgressView()
                    Text("Exporting...")
                }
            }
            Spacer()
            Text(video.timeStamp)
                .padding()
                .font(.system(size: 12, weight: .regular, design: .rounded))
                .foregroundColor(.secondary)
            Spacer()
            Spacer()
        }
        .contextMenu {
            Button {
                // Play Video
                playVideo = true
            } label: {
                HStack {
                    Text("Play Video")
                    Image(systemName: "play.tv.fill")
                }
            }
            Button {
                // Play Audio
                AudioPlayer.shared.play(video)
            } label: {
                HStack {
                    Text("Play Audio")
                    Image(systemName: "speaker.wave.3.fill")
                }
            }
            Button {
                shouldDelete = video
            } label: {
                HStack {
                    Text("Delete")
                        .foregroundColor(.red)
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
            }
            
        }
        .frame(width: UIScreen.main.bounds.width, height: 75, alignment: .center)
        .alert(item: $shouldDelete) { video in
            let text = "Delete Video?"
            return Alert(title: Text(text), message: nil, primaryButton: .cancel(), secondaryButton: .destructive(Text("Delete")) {
                DTDownloadManager.shared.cancelDownloads(for: video)
                video.delete()
            })
        }
        .fullScreenCover(isPresented: $playVideo) {
            if video.isDownloaded {
                VideoView(beginPlayback: true)
                    .environmentObject(video)
            }
        }
    }
}

struct VideoCell_Previews: PreviewProvider {
    static var previews: some View {
        VideoCell()
            .environmentObject(Video.example)
            .previewLayout(.fixed(width: UIScreen.main.bounds.width, height: 75))
    }
}
