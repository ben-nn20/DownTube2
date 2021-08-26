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
//    @StateObject var mainViewUpdator = MainViewUpdator.shared
    @EnvironmentObject var video: Video
    @State var shouldDelete: Video?
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
            }
            Spacer()
            Text(video.timeStamp)
                .font(.system(size: 12, weight: .regular, design: .rounded))
                .foregroundColor(.secondary)
                
            Spacer()
            Spacer()
        }
        .contextMenu {
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
            Button {
                video.reDownload()
            } label: {
                HStack {
                    Text("Re-Download")
                    Image(systemName: "arrow.down")
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
        .alert(isPresented: $video.showAlert) {
            Alert(title: Text(video.alertInfo.title), message: Text(video.alertInfo.message), dismissButton: .cancel())
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
