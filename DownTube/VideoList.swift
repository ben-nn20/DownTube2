//
//  VideoList.swift
//  VideoList
//
//  Created by Benjamin Nakiwala on 8/5/21.
//

import SwiftUI

struct VideoList: View {
    @EnvironmentObject var videoDatabase: VideoDatabase
    @StateObject var settings = Settings.shared
    @State var selectionBinding: Set<String>
    var body: some View {
        List {
           if settings.groupChannelsIntoFolders {
                ForEach(videoDatabase.channelFolders) { folder in
                    NavigationLink(destination: FolderView()
                                    .environmentObject(folder)) {
                        HStack {
                            Image(systemName: "folder")
                                .foregroundColor(.red)
                            Text(folder.name)
                            Spacer()
                        }
                    }
                }
            } 
            // Show folder or video respectively
            ForEach(videoDatabase.folders) { folder in
                NavigationLink(
                    destination: FolderView()
                        .environmentObject(folder),
                    label: {
                        HStack {
                            Image(systemName: "folder")
                            Text(folder.name)
                        }
                    })
            }
            ForEach(videoDatabase.videos) { video in
                NavigationLink(
                    destination: VideoView()
                        .environmentObject(video),
                    label: {
                        VideoCell()
                            .environmentObject(video)
                })
            }
        }
    }
}

