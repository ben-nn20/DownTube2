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
     @State var shouldDelete = false
     @State var showShareScreen = false
     var body: some View {
         HStack {
             // image
            if let data = video.imageData {
                 Image(uiImage: UIImage(data: data)!)
                     .resizable()
                     .frame(width: 93.1, height: 70)
              } else {
                 Image(systemName: "arrow.down").frame(width: 60, height: 60, alignment: .center)
             }
             // video stats
                 VStack(alignment: .leading, spacing: nil, content: {
                     Spacer()
                         Text(video.title)
                         Text(video.channelName)
                             .font(.system(size: 10, weight: .medium, design: .rounded))
                             .foregroundColor(.secondary)
                     Spacer()
                     Text(video.uploadDate, style: .date)
                         .font(.footnote)
                     if video.downloadStatus == .downloaded {
                         Text(video.videoSize)
                             .foregroundColor(.secondary)
                             .font(.system(size: 12, weight: .regular, design: .rounded))
                     } else if video.downloadStatus == .paused {
                         Text("Paused")
                             .foregroundColor(.secondary)
                             .font(.system(size: 12, weight: .regular, design: .rounded))
                     } else if video.downloadStatus == .downloading {
                         Text("\(Int(video.downloadProgress.fractionCompleted * 100))% (\(ByteCountFormatter.string(fromByteCount: video.downloadedVideoSize, countStyle: .file)) of \(ByteCountFormatter.string(fromByteCount: video.totalVideoSize, countStyle: .file))) | \(video.downloadSpeed)")
                             .foregroundColor(.secondary)
                             .font(.system(size: 12, weight: .regular, design: .rounded))
                     }
                     Spacer()
                 })
             Spacer()
             if video.downloadStatus == .waiting {
                 ProgressView()
                     .offset(x: -30)
             } else if video.downloadStatus == .paused {
                 Image(systemName: "arrow.triangle.2.circlepath")
                     .offset(x: -30)
             } else {
                 Text(video.timeStamp)
                     .font(.system(size: 12, weight: .regular, design: .rounded))
                     .foregroundColor(.secondary)
                     .offset(x: -30)
             }
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
                 shouldDelete = true
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
             Button  {
                 showShareScreen = true
             } label: {
                 HStack {
                     Text("Share")
                     Image(systemName: "square.and.arrow.up")
                 }
             }
         }
         .onDrag {
             let provider = NSItemProvider(object: video)
             provider.registerDataRepresentation(forTypeIdentifier: "public.video", visibility: .all) { handler in
                 handler(video.sharingData(), nil)
                 return nil
            }
             return provider
         }
         .frame(width: UIScreen.main.bounds.width, height: 70, alignment: .center)
         .alert(Text(video.alertInfo.title), isPresented: $video.showAlert) {
             Button("Dismiss", role: .cancel) {}
         } message: {
             Text(video.alertInfo.message)
         }
         .alert(Text("Delete Video?"), isPresented: $shouldDelete) {
             Button("Delete", role: .destructive) {
                 video.delete()
             }
             Button("Cancel", role: .cancel) {}
         }
         .sheet(isPresented: $showShareScreen) {
             SharingView()
                 .environmentObject(video)
         }
     }
     static func cell(video: Video) -> some View {
         VideoCell()
             .environmentObject(video)
     }
 }
 //*/
