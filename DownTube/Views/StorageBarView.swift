//
//  StorageBarView.swift
//  StorageBarView
//
//  Created by Benjamin Nakiwala on 8/24/21.
//

import SwiftUI

struct StorageBarView: View {
    @StateObject var videoDatabase = VideoDatabase.shared
    var totalSpace: Int64 {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let values = try? url.resourceValues(forKeys: [.volumeTotalCapacityKey])
        if let values = values {
            return Int64(values.volumeTotalCapacity ?? 0)
        } else {
            return 0
        }
    }
    var availableSpace: Int64 {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let values = try? url.resourceValues(forKeys: [.volumeAvailableCapacityKey])
        if let values = values {
            return Int64(values.volumeAvailableCapacity ?? 0)
        } else {
            return 0
        }
    }
    var usedSpace: Int64 {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let values = try? url.resourceValues(forKeys: [.totalFileSizeKey])
        if let values = values {
            return Int64(values.totalFileSize ?? 0)
        } else {
            return 0
        }
    }
    @State var storageView: StorageView = .channels
    func computeColorFor<Value: Hashable>(_ value: Value) -> Color {
        let hash = value.hashValue
        var red = Double(hash & 500), green = Double(hash & 300), blue = Double(hash & 100)
        // keep under 255
        red = red > 255 ? 255 : red
        green = green > 255 ? 155 : green
        blue = blue > 255 ? 55 : blue
        return Color(.sRGB, red: red, green: green, blue: blue, opacity: 1)
    }
    var body: some View {
        VStack {
            // bar
            ZStack {
                RoundedRectangle(cornerRadius: 5)
                    .frame(width: UIScreen.main.bounds.width - 32, height: 20, alignment: .center)
                    .foregroundColor(.secondary)
                HStack(alignment: .center, spacing: nil) {
                    if storageView == .channels {
                        ForEach(videoDatabase.channelFolders) { folder in
                            StorageRectangeView(size: folder.fileSize, parentBarWidth: UIScreen.main.bounds.width - 32, totalDiskSpace: totalSpace, color: computeColorFor(folder))
                        }
                    } else {
                        ForEach(videoDatabase.folders) { folder in
                            StorageRectangeView(size: folder.fileSize, parentBarWidth: UIScreen.main.bounds.width - 32, totalDiskSpace: totalSpace, color: computeColorFor(folder))
                        }
                    }
                    Spacer()
                }
                // key for colors
                
                // Control selector for view type
                HStack {
                    
                }
                if storageView == .channels {
                    List(videoDatabase.channelFolders) { folder in
                        FolderCell(shouldShowFileSize: true)
                            .environmentObject(folder)
                    }
                } else if storageView == .folders {
                    List(videoDatabase.folders) { folder in
                        FolderCell(shouldShowFileSize: true)
                            .environmentObject(folder)
                    }
                } else if storageView == .videos {
                    List(videoDatabase.allVideos) { video in
                        VideoCell()
                            .environmentObject(video)
                    }
                }
            }
        }
    }
}

struct StorageBarView_Previews: PreviewProvider {
    static var previews: some View {
        StorageBarView()
    }
}
